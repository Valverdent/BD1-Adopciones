package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;

/**
 * Cantidad de mascotas de un tipo y un estado (estadística 8.a). El porcentaje es sobre el total
 * de mascotas del rango y lo calcula el manager.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ConteoMascotas {

    private ItemCatalogo tipo;
    private ItemCatalogo estado;
    private int cantidad;
    private BigDecimal porcentaje = BigDecimal.ZERO;

    public ConteoMascotas() {
    }

    public ConteoMascotas(ItemCatalogo tipo, ItemCatalogo estado, int cantidad) {
        this.tipo = tipo;
        this.estado = estado;
        this.cantidad = cantidad;
    }

    public ItemCatalogo getTipo() { return tipo; }
    public void setTipo(ItemCatalogo tipo) { this.tipo = tipo; }

    public ItemCatalogo getEstado() { return estado; }
    public void setEstado(ItemCatalogo estado) { this.estado = estado; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public BigDecimal getPorcentaje() { return porcentaje; }
    public void setPorcentaje(BigDecimal porcentaje) { this.porcentaje = porcentaje; }
}
