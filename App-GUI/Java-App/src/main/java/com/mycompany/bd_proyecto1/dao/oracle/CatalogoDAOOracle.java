package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.MedicamentoTratamiento;
import com.mycompany.bd_proyecto1.model.TratamientoEnfermedad;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.Collator;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Implementación de CatalogoDAO con Oracle (paquete PKG_CATALOG).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CatalogoDAOOracle implements CatalogoDAO {

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<ItemCatalogo> listar(TipoCatalogo tipo) {
        if (tipo == TipoCatalogo.VETERINARIO) {
            return ordenar(listarVeterinarios());
        }
        return ordenar(consultarCatalogo(tipo, null));
    }

    @Override
    public List<ItemCatalogo> listarHijos(TipoCatalogo tipo, int idPadre) {
        if (!tipo.tienePadre()) {
            throw new IllegalArgumentException("El catálogo " + tipo + " no depende de otro catálogo.");
        }
        return ordenar(consultarCatalogo(tipo, idPadre));
    }

    @Override
    public List<TratamientoEnfermedad> listarTratamientos(int idEnfermedad) {
        // Una fila por tratamiento y medicamento: se agrupan por tratamiento conservando el orden
        Map<Integer, TratamientoEnfermedad> porTratamiento = new LinkedHashMap<>();
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_get_disease_treatments(?, ?)}")) {
            cs.setInt(1, idEnfermedad);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    int idTratamiento = fila.getInt("treatmentId");
                    TratamientoEnfermedad tratamiento = porTratamiento.get(idTratamiento);
                    if (tratamiento == null) {
                        tratamiento = new TratamientoEnfermedad(
                                new ItemCatalogo(idTratamiento, texto(fila, "treatmentName")),
                                texto(fila, "timeLength"), new ArrayList<>());
                        porTratamiento.put(idTratamiento, tratamiento);
                    }
                    ItemCatalogo medicamento = item(fila, "medicationId", "medicationName");
                    if (medicamento != null) {
                        tratamiento.getMedicamentos().add(new MedicamentoTratamiento(medicamento, texto(fila, "dosage")));
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar los tratamientos de la enfermedad", e);
        }
        return new ArrayList<>(porTratamiento.values());
    }

    // ------------------------------------------------------------------------
    // ----------------------- Cambios en los catálogos -----------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(TipoCatalogo tipo, String nombre) {
        return insertarEnBase(tipo, null, nombre);
    }

    @Override
    public int insertarHijo(TipoCatalogo tipo, int idPadre, String nombre) {
        return insertarEnBase(tipo, idPadre, nombre);
    }

    @Override
    public void actualizar(TipoCatalogo tipo, int id, String nombre) {
        try (CallableStatement cs = preparar("{call pkg_catalog.pr_update_catalog(?, ?, ?, ?, ?)}")) {
            cs.setString(1, codigo(tipo));
            cs.setInt(2, id);
            ponerTexto(cs, 3, nombre);
            cs.setNull(4, Types.NUMERIC);                   // NULL = conserva el padre actual
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            revisar(cs, 5, "cambiar el nombre");
        } catch (SQLException e) {
            throw error("cambiar el nombre del elemento", e);
        }
    }

    @Override
    public void eliminar(TipoCatalogo tipo, int id) {
        try (CallableStatement cs = preparar("{call pkg_catalog.pr_delete_catalog(?, ?, ?)}")) {
            cs.setString(1, codigo(tipo));
            cs.setInt(2, id);
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "eliminar el elemento");       // 1102 = en uso, 1103 = lo usa un parámetro
        } catch (SQLException e) {
            throw error("eliminar el elemento", e);
        }
    }

    // ------------------------------------------------------------------ auxiliares

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    /** Nombre del catálogo que esperan los procedimientos generales de PKG_CATALOG. */
    static String codigo(TipoCatalogo tipo) {
        return switch (tipo) {
            case TIPO_MASCOTA -> "PET_TYPE";
            case RAZA -> "PET_BREED";
            case COLOR -> "PET_COLOR";
            case TAMANO -> "PET_SIZE";
            case ESTADO_MASCOTA -> "PET_STATUS";
            case SEVERIDAD -> "PET_SEVERITY";
            case NIVEL_ENERGIA -> "PET_ENERGY";
            case FACILIDAD_ENTRENAMIENTO -> "PET_TRAINABILITY";
            case MONEDA -> "CURRENCY_TYPE";
            case ENFERMEDAD -> "DISEASE";
            case TIPO_VIVIENDA -> "HOUSE_TYPE";
            case TIEMPO_EJERCICIO -> "EXERCISE_TIME";
            case ESTADO_CASA_CUNA -> "FOSTER_HOME_STATUS";
            case PAIS -> "COUNTRY";
            case PROVINCIA -> "PROVINCE";
            case CANTON -> "CANTON";
            case DISTRITO -> "DISTRICT";
            case VETERINARIO -> throw new IllegalArgumentException(
                    "Los veterinarios se registran en Personas, no en catálogos.");
        };
    }

    /** PR_GET_CATALOG: columnas id, name e idParent. Con idPadre NULL retorna todos. */
    private List<ItemCatalogo> consultarCatalogo(TipoCatalogo tipo, Integer idPadre) {
        try (CallableStatement cs = preparar("{call pkg_catalog.pr_get_catalog(?, ?, ?, ?)}")) {
            cs.setString(1, codigo(tipo));
            ponerNumero(cs, 2, idPadre);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "consultar el catálogo");
            return leerItems(cursor(cs, 3), "name");
        } catch (SQLException e) {
            throw error("consultar el catálogo " + codigo(tipo), e);
        }
    }

    private List<ItemCatalogo> listarVeterinarios() {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_query_veterinarians(?)}")) {
            cs.registerOutParameter(1, CURSOR);
            cs.execute();
            return leerItems(cursor(cs, 1), "fullName");
        } catch (SQLException e) {
            throw error("consultar los veterinarios", e);
        }
    }

    private int insertarEnBase(TipoCatalogo tipo, Integer idPadre, String nombre) {
        try (CallableStatement cs = preparar("{call pkg_catalog.pr_insert_catalog(?, ?, ?, ?, ?)}")) {
            cs.setString(1, codigo(tipo));
            ponerTexto(cs, 2, nombre);
            ponerNumero(cs, 3, idPadre);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            revisar(cs, 5, "agregar el elemento");
            return cs.getInt(4);
        } catch (SQLException e) {
            throw error("agregar el elemento", e);
        }
    }

    private List<ItemCatalogo> ordenar(List<ItemCatalogo> lista) {
        lista.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return lista;
    }
}
