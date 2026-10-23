package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.ListaNegraDAO;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementación de ListaNegraDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ListaNegraDAOMemoria implements ListaNegraDAO {

    private final PersonaDAO personaDAO;
    private final AdopcionDAO adopcionDAO;
    private final List<ReporteListaNegra> reportes = DatosPrueba.crearReportesListaNegra();
    private int siguienteId = reportes.size() + 1;

    public ListaNegraDAOMemoria(PersonaDAO personaDAO, AdopcionDAO adopcionDAO) {
        this.personaDAO = personaDAO;
        this.adopcionDAO = adopcionDAO;
    }

    @Override
    public List<ResumenListaNegra> consultar(FiltroListaNegra filtro) {
        // Se agrupan los reportes que están dentro del rango, por persona.
        Map<Integer, ResumenListaNegra> porPersona = new LinkedHashMap<>();
        for (ReporteListaNegra r : reportes) {
            if (!dentroDelRango(r.getFecha(), filtro.getFechaDesde(), filtro.getFechaHasta())) {
                continue;
            }
            String nombre = personaDAO.obtener(r.getIdPersona()).getNombreCompleto();
            if (!contiene(nombre, filtro.getNombre())) {
                continue;
            }
            ResumenListaNegra fila = porPersona.get(r.getIdPersona());
            if (fila == null) {
                fila = new ResumenListaNegra();
                fila.setIdPersona(r.getIdPersona());
                fila.setNombrePersona(nombre);
                fila.setCalificacionPromedio(promedio(r.getIdPersona()));
                porPersona.put(r.getIdPersona(), fila);
            }
            fila.setCantidadReportes(fila.getCantidadReportes() + 1);
            if (fila.getUltimoReporte() == null || r.getFecha().isAfter(fila.getUltimoReporte())) {
                fila.setUltimoReporte(r.getFecha());
            }
        }
        List<ResumenListaNegra> resultado = new ArrayList<>(porPersona.values());
        resultado.sort(Comparator.comparing(ResumenListaNegra::getUltimoReporte).reversed());
        return resultado;
    }

    @Override
    public List<ReporteListaNegra> listarReportes(int idPersona) {
        List<ReporteListaNegra> resultado = new ArrayList<>();
        for (ReporteListaNegra r : reportes) {
            if (r.getIdPersona() == idPersona) {
                resultado.add(r);
            }
        }
        resultado.sort(Comparator.comparing(ReporteListaNegra::getFecha)
                .thenComparing(ReporteListaNegra::getId).reversed());
        return resultado;
    }

    @Override
    public int insertar(ReporteListaNegra reporte) {
        reporte.setId(siguienteId);
        siguienteId++;
        reportes.add(reporte);
        return reporte.getId();
    }

    @Override
    public void eliminar(int idReporte) {
        for (int i = 0; i < reportes.size(); i++) {
            if (reportes.get(i).getId() == idReporte) {
                reportes.remove(i);
                return;
            }
        }
        throw new IllegalStateException("No existe el reporte con id " + idReporte);
    }

    @Override
    public boolean estaEnListaNegra(int idPersona) {
        for (ReporteListaNegra r : reportes) {
            if (r.getIdPersona() == idPersona) {
                return true;
            }
        }
        return false;
    }

    /** Promedio de las calificaciones de las adopciones de la persona; null si no hay ninguna. */
    private BigDecimal promedio(int idPersona) {
        BigDecimal suma = BigDecimal.ZERO;
        int cantidad = 0;
        for (Adopcion a : adopcionDAO.listarAdopcionesDeAdoptante(idPersona)) {
            if (a.getCalificacion() != null) {
                suma = suma.add(BigDecimal.valueOf(a.getCalificacion()));
                cantidad++;
            }
        }
        return cantidad == 0 ? null : suma.divide(BigDecimal.valueOf(cantidad), 2, RoundingMode.HALF_UP);
    }

    private boolean contiene(String valor, String criterio) {
        if (criterio == null || criterio.isBlank()) {
            return true;
        }
        return valor != null && valor.toLowerCase().contains(criterio.trim().toLowerCase());
    }

    private boolean dentroDelRango(LocalDate fecha, LocalDate desde, LocalDate hasta) {
        if (desde != null && fecha.isBefore(desde)) {
            return false;
        }
        return hasta == null || !fecha.isAfter(hasta);
    }
}
