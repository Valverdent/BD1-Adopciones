package com.mycompany.bd_proyecto1.model;

/**
 * Una fila de la pantalla de catálogos: el elemento y cuántos registros lo usan.
 *
 * @author carlo
 * @since 2026-10-21
 */
public class FilaCatalogo {

    /** Valor de {@link #getUsos()} cuando el catálogo es de solo lectura. */
    public static final int NO_APLICA = -1;

    private final ItemCatalogo item;
    private final int usos;

    public FilaCatalogo(ItemCatalogo item, int usos) {
        this.item = item;
        this.usos = usos;
    }

    public ItemCatalogo getItem() { return item; }

    /** Cantidad de registros que usan el elemento, o {@link #NO_APLICA}. */
    public int getUsos() { return usos; }
}
