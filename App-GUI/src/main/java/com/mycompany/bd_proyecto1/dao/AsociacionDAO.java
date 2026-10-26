package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import java.util.List;

/**
 * Contrato de acceso a las asociaciones de bienestar animal (requisito 4.i).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface AsociacionDAO {

    /** Lista las asociaciones. */
    List<AsociacionBienestar> listar();

    /** Registra una asociación. */
    int insertar(AsociacionBienestar asociacion);

    /** Actualiza el nombre y la ubicación de una asociación. */
    void actualizar(AsociacionBienestar asociacion);

    /** Indica si ya existe otra asociación con ese nombre. */
    boolean existeNombre(String nombre, int idExcluir);
}
