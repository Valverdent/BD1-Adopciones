package com.mycompany.bd_proyecto1.model;

/**
 * Tipo de una donación (requisito 4.h).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public enum TipoDonacion {

    VOLUNTARIA("Voluntaria"),
    RECOMPENSA("Recompensa");

    private final String descripcion;

    TipoDonacion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDescripcion() {
        return descripcion;
    }

    @Override
    public String toString() {
        return descripcion;
    }
}
