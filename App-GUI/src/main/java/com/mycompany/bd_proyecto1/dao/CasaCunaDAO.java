package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import java.util.List;
import java.util.Optional;

/**
 * Contrato de acceso a las casas cuna (requisito 4.e).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface CasaCunaDAO {

    /** Busca casas cuna según los criterios indicados. */
    List<CasaCuna> consultar(FiltroCasaCuna filtro);

    /** Busca la casa cuna de una persona. */
    Optional<CasaCuna> buscarPorPersona(int idPersona);

    /** Registra la casa cuna de una persona. */
    void insertar(CasaCuna casa);

    /** Actualiza una casa cuna. */
    void actualizar(CasaCuna casa);
}
