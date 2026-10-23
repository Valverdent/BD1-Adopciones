package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.MatchMascotas;
import java.util.List;

/**
 * Acceso a los matches entre mascotas perdidas y encontradas (requisitos 5.d y 6).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface MatchDAO {

    /** Genera el reporte de matches a demanda. */
    List<MatchMascotas> generarMatches(int porcentajeMinimo, ItemCatalogo tipo);
}
