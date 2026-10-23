package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Fila de la consulta "Adopciones por adoptante": cuántas adopciones tiene una persona y la
 * calificación promedio que recibió.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ResumenAdoptante {

    private int idPersona;
    private String nombrePersona;
    private int cantidadAdopciones;
    private LocalDate ultimaAdopcion;
    private BigDecimal calificacionPromedio; // null si ninguna adopción está calificada

    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }

    public String getNombrePersona() { return nombrePersona; }
    public void setNombrePersona(String nombrePersona) { this.nombrePersona = nombrePersona; }

    public int getCantidadAdopciones() { return cantidadAdopciones; }
    public void setCantidadAdopciones(int cantidadAdopciones) { this.cantidadAdopciones = cantidadAdopciones; }

    public LocalDate getUltimaAdopcion() { return ultimaAdopcion; }
    public void setUltimaAdopcion(LocalDate ultimaAdopcion) { this.ultimaAdopcion = ultimaAdopcion; }

    public BigDecimal getCalificacionPromedio() { return calificacionPromedio; }
    public void setCalificacionPromedio(BigDecimal calificacionPromedio) { this.calificacionPromedio = calificacionPromedio; }
}
