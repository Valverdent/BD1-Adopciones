package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import java.util.List;

/**
 * Consulta de la bitácora de cambios (requisito 7).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface BitacoraDAO {

    /**
     * Recibe los criterios (todos opcionales; fechas inclusivas sobre el día del cambio). Retorna
     * los registros que cumplen todos, del más reciente al más antiguo.
     */
    List<RegistroBitacora> consultar(FiltroBitacora filtro);

    /** Retorna los nombres de tabla que aparecen en la bitácora, ordenados. */
    List<String> listarTablas();
}
