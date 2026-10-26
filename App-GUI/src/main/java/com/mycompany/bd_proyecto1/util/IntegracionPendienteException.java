package com.mycompany.bd_proyecto1.util;

/**
 * Indica que una operación todavía no está conectada con Oracle porque el equipo de base de datos
 * no ha entregado el procedimiento o la consulta correspondiente.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class IntegracionPendienteException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public IntegracionPendienteException(String operacion) {
        super("Funcionalidad pendiente de integración con la base de datos: " + operacion);
    }
}
