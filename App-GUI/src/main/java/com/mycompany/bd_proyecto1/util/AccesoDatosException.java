package com.mycompany.bd_proyecto1.util;

/**
 * Error al comunicarse con la base de datos Oracle.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class AccesoDatosException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public AccesoDatosException(String mensaje) {
        super(mensaje);
    }

    public AccesoDatosException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}
