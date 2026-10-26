package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Criterios opcionales para consultar donaciones. Un criterio null o vacío no filtra.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroDonacion {

    private String donador;
    private AsociacionBienestar asociacion;
    private BigDecimal montoMinimo;
    private BigDecimal montoMaximo;
    private LocalDate fechaDesde;
    private LocalDate fechaHasta;

    public String getDonador() { return donador; }
    public void setDonador(String donador) { this.donador = donador; }

    public AsociacionBienestar getAsociacion() { return asociacion; }
    public void setAsociacion(AsociacionBienestar asociacion) { this.asociacion = asociacion; }

    public BigDecimal getMontoMinimo() { return montoMinimo; }
    public void setMontoMinimo(BigDecimal montoMinimo) { this.montoMinimo = montoMinimo; }

    public BigDecimal getMontoMaximo() { return montoMaximo; }
    public void setMontoMaximo(BigDecimal montoMaximo) { this.montoMaximo = montoMaximo; }

    public LocalDate getFechaDesde() { return fechaDesde; }
    public void setFechaDesde(LocalDate fechaDesde) { this.fechaDesde = fechaDesde; }

    public LocalDate getFechaHasta() { return fechaHasta; }
    public void setFechaHasta(LocalDate fechaHasta) { this.fechaHasta = fechaHasta; }
}
