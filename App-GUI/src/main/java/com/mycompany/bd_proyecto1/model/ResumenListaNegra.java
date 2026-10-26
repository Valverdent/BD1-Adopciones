package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Fila del reporte de lista negra (requisito 5.c): una persona con la cantidad de reportes, el
 * último y su calificación promedio como adoptante.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ResumenListaNegra {

    private int idPersona;
    private String nombrePersona;
    private int cantidadReportes;
    private LocalDate ultimoReporte;
    /** Promedio de las calificaciones de sus adopciones; null si no tiene ninguna. */
    private BigDecimal calificacionPromedio;

    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }

    public String getNombrePersona() { return nombrePersona; }
    public void setNombrePersona(String nombrePersona) { this.nombrePersona = nombrePersona; }

    public int getCantidadReportes() { return cantidadReportes; }
    public void setCantidadReportes(int cantidadReportes) { this.cantidadReportes = cantidadReportes; }

    public LocalDate getUltimoReporte() { return ultimoReporte; }
    public void setUltimoReporte(LocalDate ultimoReporte) { this.ultimoReporte = ultimoReporte; }

    public BigDecimal getCalificacionPromedio() { return calificacionPromedio; }
    public void setCalificacionPromedio(BigDecimal calificacionPromedio) { this.calificacionPromedio = calificacionPromedio; }
}
