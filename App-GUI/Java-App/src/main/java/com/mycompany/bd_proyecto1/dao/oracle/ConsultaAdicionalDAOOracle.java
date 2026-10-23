package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.ConsultaAdicionalDAO;
import com.mycompany.bd_proyecto1.model.DisponibilidadCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación de ConsultaAdicionalDAO con Oracle (paquete PKG_QUERIES_EXTRAS).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class ConsultaAdicionalDAOOracle implements ConsultaAdicionalDAO {

    @Override
    public List<DisponibilidadCasaCuna> casasCunaConEspacio(ItemCatalogo provincia, ItemCatalogo tipo,
                                                            int espaciosMinimos) {
        List<DisponibilidadCasaCuna> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_queries_extras.pr_get_foster_home_availability(?, ?, ?, ?)}")) {
            ponerId(cs, 1, provincia);
            ponerId(cs, 2, tipo);
            cs.setInt(3, espaciosMinimos);
            cs.registerOutParameter(4, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 4)) {
                while (fila.next()) {
                    DisponibilidadCasaCuna d = new DisponibilidadCasaCuna();
                    d.setIdPersona(fila.getInt("id"));
                    d.setNombrePersona(texto(fila, "ownerName"));
                    d.setProvincia(texto(fila, "provinceName"));
                    d.setCanton(texto(fila, "cantonName"));
                    d.setDistrito(texto(fila, "districtName"));
                    d.setSenas(texto(fila, "address"));
                    d.setEstado(texto(fila, "statusName"));
                    d.setTipoMascota(texto(fila, "petTypeName"));
                    d.setCapacidadMaxima(fila.getInt("maxCapacity"));
                    d.setCantidadActual(fila.getInt("currentPets"));
                    d.setRequiereDonacionAlimentos(booleano(fila, "requiresFoodDonation"));
                    filas.add(d);
                }
            }
        } catch (SQLException e) {
            throw error("consultar las casas cuna con espacio", e);
        }
        return filas;
    }

    @Override
    public List<Mascota> mascotasPerdidasPorRecompensa(ItemCatalogo tipo, ItemCatalogo provincia) {
        List<Mascota> perdidas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_queries_extras.pr_get_lost_pets(?, ?, ?, ?)}")) {
            ponerId(cs, 1, tipo);
            ponerId(cs, 2, provincia);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "consultar las mascotas perdidas");
            try (ResultSet fila = cursor(cs, 3)) {                // de la recompensa más alta a la más baja
                while (fila.next()) {
                    Mascota m = new Mascota();
                    m.setId(fila.getInt("id"));
                    m.setNombre(texto(fila, "name"));
                    m.setChip(texto(fila, "chipId"));
                    m.setTipo(nombre(texto(fila, "typeName")));
                    m.setRaza(nombre(texto(fila, "breedName")));
                    m.setTamano(nombre(texto(fila, "sizeName")));
                    m.setColor(nombre(texto(fila, "colorName")));
                    m.setFechaEvento(fecha(fila, "lostDate"));
                    m.setUbicacion(new Ubicacion(null, nombre(texto(fila, "provinceName")),
                            nombre(texto(fila, "cantonName")), nombre(texto(fila, "districtName")),
                            texto(fila, "address")));
                    m.setIdPersonaRegistro(fila.getInt("reporterId"));
                    m.setNombrePersonaRegistro(texto(fila, "reporterName"));
                    m.setMontoRecompensa(decimal(fila, "rewardAmount"));
                    String moneda = texto(fila, "currencyName");
                    m.setMonedaRecompensa(moneda == null ? null : nombre(moneda));
                    m.setNotas(texto(fila, "notesDescription"));
                    perdidas.add(m);
                }
            }
        } catch (SQLException e) {
            throw error("consultar las mascotas perdidas", e);
        }
        return perdidas;
    }

    /** Elemento solo para mostrar (el cursor no trae el id). */
    private static ItemCatalogo nombre(String texto) {
        return new ItemCatalogo(0, texto);
    }
}
