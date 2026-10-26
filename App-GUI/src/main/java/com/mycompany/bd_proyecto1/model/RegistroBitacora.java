package com.mycompany.bd_proyecto1.model;

import java.time.LocalDateTime;

/**
 * Una fila de la bitácora de cambios (ChangeLog en el diagrama): quién cambió qué campo de qué
 * registro, con el valor anterior y el nuevo.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class RegistroBitacora {

    private int id;
    private int idUsuario;
    private String nombreUsuario;
    private String tabla;
    private String campo;
    private int idRegistro;
    private String valorAnterior;
    private String valorNuevo;
    private String descripcion;
    private LocalDateTime fecha;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public String getTabla() { return tabla; }
    public void setTabla(String tabla) { this.tabla = tabla; }

    public String getCampo() { return campo; }
    public void setCampo(String campo) { this.campo = campo; }

    public int getIdRegistro() { return idRegistro; }
    public void setIdRegistro(int idRegistro) { this.idRegistro = idRegistro; }

    /** Puede ser nulo si el campo estaba vacío. */
    public String getValorAnterior() { return valorAnterior; }
    public void setValorAnterior(String valorAnterior) { this.valorAnterior = valorAnterior; }

    /** Puede ser nulo si el campo quedó vacío. */
    public String getValorNuevo() { return valorNuevo; }
    public void setValorNuevo(String valorNuevo) { this.valorNuevo = valorNuevo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }
}
