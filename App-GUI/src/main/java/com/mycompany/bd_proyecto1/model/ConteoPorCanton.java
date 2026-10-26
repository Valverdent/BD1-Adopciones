package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Fila de la estadística adicional "mascotas perdidas y encontradas por cantón": cantón, estado
 * (perdida o encontrada), cantidad y porcentaje sobre el total del rango de fechas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class ConteoPorCanton {

    private final String canton;
    private final String estado;
    private final int cantidad;
    private final BigDecimal porcentaje;

    public ConteoPorCanton(String canton, String estado, int cantidad, BigDecimal porcentaje) {
        this.canton = canton;
        this.estado = estado;
        this.cantidad = cantidad;
        this.porcentaje = porcentaje;
    }

    public String getCanton() { return canton; }

    public String getEstado() { return estado; }

    public int getCantidad() { return cantidad; }

    public BigDecimal getPorcentaje() { return porcentaje; }
}
