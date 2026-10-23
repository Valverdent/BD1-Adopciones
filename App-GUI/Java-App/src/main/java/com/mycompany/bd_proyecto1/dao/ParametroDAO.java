package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.Parametro;
import java.util.List;

/**
 * Acceso a los parámetros del sistema (tabla Parameter del diagrama).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public interface ParametroDAO {

    /**
     * Retorna todos los parámetros con su identificador, clave, descripción y valor (texto). Nunca
     * null.
     */
    List<Parametro> listar();

    /**
     * Cambia el valor de un parámetro. Recibe el identificador y el nuevo valor ya validado por la
     * aplicación. Si el cambio se registra en la bitácora, lo hace la base de datos (trigger).
     */
    void actualizarValor(int id, String valor);
}
