package com.mycompany.bd_proyecto1.model;

import java.util.Objects;

/**
 * Elemento de un catálogo (tipo de mascota, raza, color, estado, moneda...).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ItemCatalogo {

    private final int id;
    private String nombre;

    public ItemCatalogo(int id, String nombre) {
        this.id = id;
        this.nombre = nombre;
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    /** Cambia el nombre; las mascotas que usan este elemento ven el nuevo nombre. */
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    /** Un elemento inactivo no aparece en los formularios, pero sigue en los registros. */
    @Override
    public String toString() {
        return nombre;
    }

    /** Dos elementos son iguales si tienen el mismo identificador. */
    @Override
    public boolean equals(Object otro) {
        if (this == otro) {
            return true;
        }
        if (!(otro instanceof ItemCatalogo)) {
            return false;
        }
        return id == ((ItemCatalogo) otro).id;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
