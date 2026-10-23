package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Total donado a una asociación en una moneda (estadística 8.b). El porcentaje es sobre el total
 * de esa misma moneda: las monedas no se suman entre sí.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FilaTotalDonacion {

    private final String asociacion;
    private final ItemCatalogo moneda;
    private final BigDecimal total;
    private final int cantidadDonaciones;
    private final BigDecimal porcentaje;

    public FilaTotalDonacion(String asociacion, ItemCatalogo moneda, BigDecimal total,
                             int cantidadDonaciones, BigDecimal porcentaje) {
        this.asociacion = asociacion;
        this.moneda = moneda;
        this.total = total;
        this.cantidadDonaciones = cantidadDonaciones;
        this.porcentaje = porcentaje;
    }

    public String getAsociacion() { return asociacion; }

    public ItemCatalogo getMoneda() { return moneda; }

    public BigDecimal getTotal() { return total; }

    public int getCantidadDonaciones() { return cantidadDonaciones; }

    public BigDecimal getPorcentaje() { return porcentaje; }
}
