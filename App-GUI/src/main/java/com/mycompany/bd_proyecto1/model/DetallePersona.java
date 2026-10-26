package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Lo que se muestra al abrir una persona (requisito 4.g): sus datos, sus reportes de lista negra y
 * sus adopciones como adoptante con calificación y notas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DetallePersona {

    private Persona persona;
    private List<ReporteListaNegra> reportes = new ArrayList<>();
    private List<Adopcion> adopciones = new ArrayList<>();
    /** Promedio de las calificaciones recibidas; null si ninguna adopción está calificada. */
    private BigDecimal calificacionPromedio;

    public Persona getPersona() { return persona; }
    public void setPersona(Persona persona) { this.persona = persona; }

    public List<ReporteListaNegra> getReportes() { return reportes; }
    public void setReportes(List<ReporteListaNegra> reportes) { this.reportes = reportes; }

    public List<Adopcion> getAdopciones() { return adopciones; }
    public void setAdopciones(List<Adopcion> adopciones) { this.adopciones = adopciones; }

    public BigDecimal getCalificacionPromedio() { return calificacionPromedio; }
    public void setCalificacionPromedio(BigDecimal calificacionPromedio) { this.calificacionPromedio = calificacionPromedio; }

    public boolean estaEnListaNegra() {
        return !reportes.isEmpty();
    }
}
