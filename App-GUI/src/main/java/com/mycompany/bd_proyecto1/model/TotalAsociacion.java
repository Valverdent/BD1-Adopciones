package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Total donado a una asociación en una moneda (requisitos 4.h y 4.i). Las monedas no se suman
 * entre sí, por eso hay un total por cada una.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class TotalAsociacion {

    private AsociacionBienestar asociacion;
    private ItemCatalogo moneda;
    private BigDecimal total = BigDecimal.ZERO;
    private int cantidadDonaciones;

    public AsociacionBienestar getAsociacion() { return asociacion; }
    public void setAsociacion(AsociacionBienestar asociacion) { this.asociacion = asociacion; }

    public ItemCatalogo getMoneda() { return moneda; }
    public void setMoneda(ItemCatalogo moneda) { this.moneda = moneda; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public int getCantidadDonaciones() { return cantidadDonaciones; }
    public void setCantidadDonaciones(int cantidadDonaciones) { this.cantidadDonaciones = cantidadDonaciones; }
}
