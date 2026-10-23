package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Criterios opcionales para el reporte de lista negra. El rango de fechas se aplica a la fecha de
 * los reportes.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroListaNegra {

    private String nombre;
    private LocalDate fechaDesde;
    private LocalDate fechaHasta;

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public LocalDate getFechaDesde() { return fechaDesde; }
    public void setFechaDesde(LocalDate fechaDesde) { this.fechaDesde = fechaDesde; }

    public LocalDate getFechaHasta() { return fechaHasta; }
    public void setFechaHasta(LocalDate fechaHasta) { this.fechaHasta = fechaHasta; }
}
