package com.mycompany.bd_proyecto1.model;

import java.util.Objects;

/**
 * Asociación de bienestar animal que recibe donaciones (requisito 4.i).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AsociacionBienestar {

    private int id;
    private String nombre;
    /** Lugar registrado de la asociación (tabla Location: distrito + señas). */
    private Ubicacion ubicacion;

    public AsociacionBienestar() {
    }

    public AsociacionBienestar(int id, String nombre, Ubicacion ubicacion) {
        this.id = id;
        this.nombre = nombre;
        this.ubicacion = ubicacion;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public Ubicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(Ubicacion ubicacion) { this.ubicacion = ubicacion; }

    @Override
    public String toString() {
        return nombre;
    }

    /** Dos asociaciones son iguales si tienen el mismo identificador. */
    @Override
    public boolean equals(Object otro) {
        if (this == otro) {
            return true;
        }
        return otro instanceof AsociacionBienestar && id == ((AsociacionBienestar) otro).id;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
