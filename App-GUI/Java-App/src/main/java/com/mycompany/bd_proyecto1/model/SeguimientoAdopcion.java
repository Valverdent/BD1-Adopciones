package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Seguimiento de una mascota adoptada: comentario, fecha y una foto de su nueva vida (requisito
 * 4.f).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class SeguimientoAdopcion {

    private int id;
    private int idAdopcion;
    private LocalDate fecha;
    private String comentarios;
    private String foto;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getIdAdopcion() { return idAdopcion; }
    public void setIdAdopcion(int idAdopcion) { this.idAdopcion = idAdopcion; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public String getComentarios() { return comentarios; }
    public void setComentarios(String comentarios) { this.comentarios = comentarios; }

    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }
}
