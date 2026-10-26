package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import java.util.List;

/**
 * Contrato de acceso a la lista negra (requisitos 4.g y 5.c).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface ListaNegraDAO {

    /** Reporte de lista negra (5.c). */
    List<ResumenListaNegra> consultar(FiltroListaNegra filtro);

    /** Lista los reportes de una persona. */
    List<ReporteListaNegra> listarReportes(int idPersona);

    /** Registra un reporte. */
    int insertar(ReporteListaNegra reporte);

    /** Elimina un reporte. */
    void eliminar(int idReporte);

    /** Indica si una persona está en la lista negra. */
    boolean estaEnListaNegra(int idPersona);
}
