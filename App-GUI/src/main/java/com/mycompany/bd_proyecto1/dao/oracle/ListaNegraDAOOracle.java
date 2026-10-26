package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.ListaNegraDAO;
import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementación de ListaNegraDAO con Oracle (paquete PKG_PERSON_ADMINISTRATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ListaNegraDAOOracle implements ListaNegraDAO {

    /** Un reporte con el nombre de la persona reportada. */
    private record Fila(ReporteListaNegra reporte, String nombrePersona) {
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<ResumenListaNegra> consultar(FiltroListaNegra filtro) {
        Map<Integer, ResumenListaNegra> porPersona = new LinkedHashMap<>();
        for (Fila f : todos()) {
            ReporteListaNegra r = f.reporte();
            if (!dentroDelRango(r.getFecha(), filtro.getFechaDesde(), filtro.getFechaHasta())
                    || !PersonaDAOOracle.contiene(f.nombrePersona(), filtro.getNombre())) {
                continue;
            }
            ResumenListaNegra resumen = porPersona.get(r.getIdPersona());
            if (resumen == null) {
                resumen = new ResumenListaNegra();
                resumen.setIdPersona(r.getIdPersona());
                resumen.setNombrePersona(f.nombrePersona());
                resumen.setCalificacionPromedio(promedioCalificaciones(r.getIdPersona()));
                porPersona.put(r.getIdPersona(), resumen);
            }
            resumen.setCantidadReportes(resumen.getCantidadReportes() + 1);
            if (resumen.getUltimoReporte() == null || r.getFecha().isAfter(resumen.getUltimoReporte())) {
                resumen.setUltimoReporte(r.getFecha());
            }
        }
        List<ResumenListaNegra> resultado = new ArrayList<>(porPersona.values());
        resultado.sort(Comparator.comparing(ResumenListaNegra::getUltimoReporte).reversed());
        return resultado;
    }

    @Override
    public List<ReporteListaNegra> listarReportes(int idPersona) {
        List<ReporteListaNegra> resultado = new ArrayList<>();
        for (Fila f : todos()) {
            if (f.reporte().getIdPersona() == idPersona) {
                resultado.add(f.reporte());
            }
        }
        resultado.sort(Comparator.comparing(ReporteListaNegra::getFecha)
                .thenComparing(ReporteListaNegra::getId).reversed());
        return resultado;
    }

    // ------------------------------------------------------------------------
    // ------------------ Registro y eliminación de reportes ------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(ReporteListaNegra reporte) {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_add_blacklist(?, ?, ?)}")) {
            cs.setInt(1, reporte.getIdPersona());
            ponerTexto(cs, 2, reporte.getMotivo());
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "registrar el reporte");
        } catch (SQLException e) {
            throw error("registrar el reporte de lista negra", e);
        }
        // El procedimiento no devuelve el id: es el reporte más nuevo de la persona
        int id = listarReportes(reporte.getIdPersona()).stream()
                .mapToInt(ReporteListaNegra::getId).max().orElse(0);
        reporte.setId(id);
        return id;
    }

    @Override
    public void eliminar(int idReporte) {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_delete_blacklist(?, ?)}")) {
            cs.setInt(1, idReporte);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.execute();
            revisar(cs, 2, "eliminar el reporte");
        } catch (SQLException e) {
            throw error("eliminar el reporte de lista negra", e);
        }
    }

    @Override
    public boolean estaEnListaNegra(int idPersona) {
        return todos().stream().anyMatch(f -> f.reporte().getIdPersona() == idPersona);
    }

    // ------------------------------------------------------------------ auxiliares

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    /** Todos los reportes (PR_REPORT_BLACKLIST con pnOnly_adopters = 0). */
    private List<Fila> todos() {
        List<Fila> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_report_blacklist(?, ?)}")) {
            cs.setInt(1, 0);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    ReporteListaNegra r = new ReporteListaNegra();
                    r.setId(fila.getInt("blacklistId"));
                    r.setIdPersona(fila.getInt("personId"));
                    r.setFecha(fecha(fila, "blackListDate"));
                    r.setMotivo(texto(fila, "blackListReason"));
                    filas.add(new Fila(r, texto(fila, "fullName")));
                }
            }
        } catch (SQLException e) {
            throw error("consultar la lista negra", e);
        }
        return filas;
    }

    /** Promedio de las calificaciones que recibió la persona en sus adopciones, o null si no tiene. */
    static BigDecimal promedioCalificaciones(int idPersona) {
        Map<Integer, Integer> porCalificacion = new HashMap<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_person_ratings(?, ?)}")) {
            cs.setInt(1, idPersona);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    Integer idCalificacion = entero(fila, "ratingId");
                    if (idCalificacion != null) {
                        porCalificacion.put(idCalificacion, fila.getInt("rating"));
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar las calificaciones de la persona", e);
        }
        if (porCalificacion.isEmpty()) {
            return null;
        }
        int suma = porCalificacion.values().stream().mapToInt(Integer::intValue).sum();
        return BigDecimal.valueOf(suma).divide(BigDecimal.valueOf(porCalificacion.size()), 2, RoundingMode.HALF_UP);
    }

    private static boolean dentroDelRango(LocalDate fecha, LocalDate desde, LocalDate hasta) {
        if (desde != null && fecha.isBefore(desde)) {
            return false;
        }
        return hasta == null || !fecha.isAfter(hasta);
    }
}
