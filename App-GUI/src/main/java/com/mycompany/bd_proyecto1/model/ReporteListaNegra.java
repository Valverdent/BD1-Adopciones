package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Un reporte de una persona en la lista negra (tabla BlackList): fecha y motivo. El diagrama no
 * guarda quién reportó (ver INTEGRACIONES_PENDIENTES.md).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ReporteListaNegra {

    private int id;
    private int idPersona;
    private LocalDate fecha;
    private String motivo;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
}
