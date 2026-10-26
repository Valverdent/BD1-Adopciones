package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Parte de una donación que recibe una asociación (tabla DonationDetail).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DetalleDonacion {

    private AsociacionBienestar asociacion;
    private BigDecimal porcentaje;
    private BigDecimal monto;

    public DetalleDonacion() {
    }

    public DetalleDonacion(AsociacionBienestar asociacion, BigDecimal porcentaje) {
        this.asociacion = asociacion;
        this.porcentaje = porcentaje;
    }

    public AsociacionBienestar getAsociacion() { return asociacion; }
    public void setAsociacion(AsociacionBienestar asociacion) { this.asociacion = asociacion; }

    public BigDecimal getPorcentaje() { return porcentaje; }
    public void setPorcentaje(BigDecimal porcentaje) { this.porcentaje = porcentaje; }

    public BigDecimal getMonto() { return monto; }
    public void setMonto(BigDecimal monto) { this.monto = monto; }
}
