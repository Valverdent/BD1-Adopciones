package com.mycompany.bd_proyecto1.util;

/**
 * Perfiles funcionales de la interfaz.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public enum PerfilInterfaz {

    /** Ciudadano, rescatista o adoptante. */
    USUARIO_COMUN("Usuario común"),

    /** Responsable de funciones administrativas y de parametrización. */
    ADMINISTRADOR("Administrador");

    private final String descripcion;

    PerfilInterfaz(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDescripcion() {
        return descripcion;
    }
}
