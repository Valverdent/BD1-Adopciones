package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Fila de la estadística adicional "donaciones de recompensa por rescatista".
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class TotalPorRescatista {

    private final String rescatista;
    private final String moneda;
    private final BigDecimal total;
    private final BigDecimal porcentaje;

    public TotalPorRescatista(String rescatista, String moneda, BigDecimal total, BigDecimal porcentaje) {
        this.rescatista = rescatista;
        this.moneda = moneda;
        this.total = total;
        this.porcentaje = porcentaje;
    }

    public String getRescatista() { return rescatista; }

    public String getMoneda() { return moneda; }

    public BigDecimal getTotal() { return total; }

    public BigDecimal getPorcentaje() { return porcentaje; }
}
