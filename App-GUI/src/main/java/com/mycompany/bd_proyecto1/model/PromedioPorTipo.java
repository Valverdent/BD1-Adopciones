package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Calificación promedio de las adopciones de un tipo de mascota (estadística 8.e).
 *
 * @author carlo
 * @since 2026-10-20
 */
public class PromedioPorTipo {

    private final ItemCatalogo tipo;
    private final BigDecimal promedio;
    private final int cantidadCalificadas;

    public PromedioPorTipo(ItemCatalogo tipo, BigDecimal promedio, int cantidadCalificadas) {
        this.tipo = tipo;
        this.promedio = promedio;
        this.cantidadCalificadas = cantidadCalificadas;
    }

    public ItemCatalogo getTipo() { return tipo; }

    public BigDecimal getPromedio() { return promedio; }

    public int getCantidadCalificadas() { return cantidadCalificadas; }
}
