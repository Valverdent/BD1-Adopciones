package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Criterios de búsqueda de mascotas (requisitos 4.d y 5.a).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroMascota {

    private ItemCatalogo tipo;
    private ItemCatalogo raza;
    private ItemCatalogo estado;
    private ItemCatalogo color;
    private ItemCatalogo tamano;
    private String chip;
    private String nombre;
    private FiltroUbicacion ubicacion = new FiltroUbicacion();
    private String registradoPor;
    private LocalDate fechaDesde;
    private LocalDate fechaHasta;

    public ItemCatalogo getTipo() {
        return tipo;
    }

    public void setTipo(ItemCatalogo tipo) {
        this.tipo = tipo;
    }

    public ItemCatalogo getRaza() {
        return raza;
    }

    public void setRaza(ItemCatalogo raza) {
        this.raza = raza;
    }

    public ItemCatalogo getEstado() {
        return estado;
    }

    public void setEstado(ItemCatalogo estado) {
        this.estado = estado;
    }

    public ItemCatalogo getColor() {
        return color;
    }

    public void setColor(ItemCatalogo color) {
        this.color = color;
    }

    public ItemCatalogo getTamano() {
        return tamano;
    }

    public void setTamano(ItemCatalogo tamano) {
        this.tamano = tamano;
    }

    public String getChip() {
        return chip;
    }

    public void setChip(String chip) {
        this.chip = chip;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public FiltroUbicacion getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(FiltroUbicacion ubicacion) {
        this.ubicacion = ubicacion == null ? new FiltroUbicacion() : ubicacion;
    }

    public String getRegistradoPor() {
        return registradoPor;
    }

    public void setRegistradoPor(String registradoPor) {
        this.registradoPor = registradoPor;
    }

    public LocalDate getFechaDesde() {
        return fechaDesde;
    }

    public void setFechaDesde(LocalDate fechaDesde) {
        this.fechaDesde = fechaDesde;
    }

    public LocalDate getFechaHasta() {
        return fechaHasta;
    }

    public void setFechaHasta(LocalDate fechaHasta) {
        this.fechaHasta = fechaHasta;
    }
}
