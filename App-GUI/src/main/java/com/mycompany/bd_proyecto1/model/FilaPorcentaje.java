package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Fila genérica de una estadística: una etiqueta, una cantidad y su porcentaje (por ejemplo, un
 * rango de edad en la estadística 8.d).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FilaPorcentaje {

    private final String etiqueta;
    private final int cantidad;
    private final BigDecimal porcentaje;

    public FilaPorcentaje(String etiqueta, int cantidad, BigDecimal porcentaje) {
        this.etiqueta = etiqueta;
        this.cantidad = cantidad;
        this.porcentaje = porcentaje;
    }

    public String getEtiqueta() { return etiqueta; }

    public int getCantidad() { return cantidad; }

    public BigDecimal getPorcentaje() { return porcentaje; }
}
