package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.CasaCunaDAO;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.Collator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Implementación de CasaCunaDAO con Oracle (paquete PKG_PERSON_ADMINISTRATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCunaDAOOracle implements CasaCunaDAO {

    /**
     * Nombre del estado de casa cuna que permite recibir mascotas. La base no tiene un parámetro
     * para este nombre (ver INTEGRACIONES_PENDIENTES.md).
     */
    static final String ESTADO_DISPONIBLE = "Disponible";

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<CasaCuna> consultar(FiltroCasaCuna filtro) {
        List<CasaCuna> resultado = new ArrayList<>();
        for (CasaCuna casa : consultarBase(null, filtro.getTipoMascota(), filtro.getTamano())) {
            boolean cumple = (filtro.getEstado() == null || filtro.getEstado().equals(casa.getEstado()))
                    && (filtro.getRequiereDonacionAlimentos() == null
                        || filtro.getRequiereDonacionAlimentos() == casa.isRequiereDonacionAlimentos())
                    && filtro.getUbicacion().cumple(casa.getUbicacion())
                    && (!filtro.isSoloDisponibles() || casa.isDisponible());
            if (cumple) {
                completar(casa);
                resultado.add(casa);
            }
        }
        resultado.sort((a, b) -> ordenEspanol.compare(a.getNombrePersona(), b.getNombrePersona()));
        return resultado;
    }

    @Override
    public Optional<CasaCuna> buscarPorPersona(int idPersona) {
        List<CasaCuna> casas = consultarBase(idPersona, null, null);
        if (casas.isEmpty()) {
            return Optional.empty();
        }
        CasaCuna casa = casas.get(0);
        completar(casa);
        return Optional.of(casa);
    }

    // ------------------------------------------------------------------------
    // -------------------------- Registro y edición --------------------------
    // ------------------------------------------------------------------------

    @Override
    public void insertar(CasaCuna casa) {
        guardar("{call pkg_person_administration.pr_register_foster_home(?, ?, ?, ?, ?, ?, ?, ?, ?)}", casa,
                "registrar la casa cuna");
    }

    @Override
    public void actualizar(CasaCuna casa) {
        guardar("{call pkg_person_administration.pr_update_foster_home(?, ?, ?, ?, ?, ?, ?, ?, ?)}", casa,
                "actualizar la casa cuna");
    }

    // ------------------------------------------------------------------ auxiliares

    /** Los dos procedimientos reciben los mismos parámetros en el mismo orden. */
    private void guardar(String llamada, CasaCuna casa, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.setInt(1, casa.getIdPersona());
            ponerId(cs, 2, casa.getUbicacion().getDistrito());
            ponerTexto(cs, 3, casa.getUbicacion().getSenas());
            ponerId(cs, 4, casa.getEstado());
            cs.setInt(5, casa.getCapacidadMaxima());
            ponerBooleano(cs, 6, casa.isRequiereDonacionAlimentos());
            ponerTexto(cs, 7, listaDeIds(casa.getTipos()));
            ponerTexto(cs, 8, listaDeIds(casa.getTamanos()));
            cs.registerOutParameter(9, Types.NUMERIC);
            cs.execute();
            revisar(cs, 9, operacion);
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    /** "1,2,3": formato que esperan los procedimientos de casas cuna. */
    private static String listaDeIds(List<ItemCatalogo> items) {
        return items.stream().map(i -> String.valueOf(i.getId())).collect(Collectors.joining(","));
    }

    // ------------------------------------------------------------------------
    // -------------------------- Lectura de la base --------------------------
    // ------------------------------------------------------------------------

    /** PR_GET_FOSTER_HOMES: datos de la casa sin lo que acepta ni los contactos. */
    private List<CasaCuna> consultarBase(Integer idCasa, ItemCatalogo tipo, ItemCatalogo tamano) {
        Map<Integer, ItemCatalogo> paises = LugaresOracle.paisesPorProvincia();
        List<CasaCuna> casas = new ArrayList<>();
        try (CallableStatement cs = preparar(
                "{call pkg_person_administration.pr_get_foster_homes(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            ponerNumero(cs, 1, idCasa);
            cs.setNull(2, Types.NUMERIC);
            cs.setNull(3, Types.NUMERIC);
            cs.setNull(4, Types.NUMERIC);
            ponerId(cs, 5, tipo);
            ponerId(cs, 6, tamano);
            cs.setInt(7, 0);                                // la disponibilidad se calcula aquí
            cs.registerOutParameter(8, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 8)) {
                while (fila.next()) {
                    CasaCuna c = new CasaCuna();
                    c.setIdPersona(fila.getInt("id"));
                    c.setNombrePersona(texto(fila, "ownerName"));
                    c.setUbicacion(LugaresOracle.ubicacion(fila, paises));
                    c.setEstado(item(fila, "idFosterHomeStatus", "statusName"));
                    c.setCapacidadMaxima(fila.getInt("maxCapacity"));
                    c.setCantidadActual(fila.getInt("currentPets"));
                    c.setRequiereDonacionAlimentos(booleano(fila, "requiresFoodDonation"));
                    c.setDisponible(c.getEstado() != null
                            && ESTADO_DISPONIBLE.equalsIgnoreCase(c.getEstado().getNombre())
                            && c.getCantidadActual() < c.getCapacidadMaxima());
                    casas.add(c);
                }
            }
        } catch (SQLException e) {
            throw error("consultar las casas cuna", e);
        }
        return casas;
    }

    /** Agrega los tipos y tamaños aceptados y los contactos de la persona. */
    private void completar(CasaCuna casa) {
        List<ItemCatalogo> tipos = new ArrayList<>();
        List<ItemCatalogo> tamanos = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_foster_home_accepts(?, ?)}")) {
            cs.setInt(1, casa.getIdPersona());
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    ItemCatalogo elemento = new ItemCatalogo(fila.getInt("acceptId"), texto(fila, "acceptName"));
                    ("TYPE".equals(texto(fila, "acceptType")) ? tipos : tamanos).add(elemento);
                }
            }
        } catch (SQLException e) {
            throw error("consultar lo que acepta la casa cuna", e);
        }
        casa.setTipos(tipos);
        casa.setTamanos(tamanos);
        casa.setTelefonos(new ArrayList<>(PersonaDAOOracle.telefonos(casa.getIdPersona())));
        casa.setCorreos(new ArrayList<>(PersonaDAOOracle.correos(casa.getIdPersona())));
    }
}
