package com.mycompany.bd_proyecto1.model;

/**
 * Fila de la consulta adicional "casas cuna con espacio": una casa y uno de los tipos de mascota
 * que acepta, con sus espacios libres.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class DisponibilidadCasaCuna {

    private int idPersona;
    private String nombrePersona;
    private String provincia;
    private String canton;
    private String distrito;
    private String senas;
    private String estado;
    private String tipoMascota;
    private int capacidadMaxima;
    private int cantidadActual;
    private boolean requiereDonacionAlimentos;

    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }

    public String getNombrePersona() { return nombrePersona; }
    public void setNombrePersona(String nombrePersona) { this.nombrePersona = nombrePersona; }

    public String getProvincia() { return provincia; }
    public void setProvincia(String provincia) { this.provincia = provincia; }

    public String getCanton() { return canton; }
    public void setCanton(String canton) { this.canton = canton; }

    public String getDistrito() { return distrito; }
    public void setDistrito(String distrito) { this.distrito = distrito; }

    public String getSenas() { return senas; }
    public void setSenas(String senas) { this.senas = senas; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getTipoMascota() { return tipoMascota; }
    public void setTipoMascota(String tipoMascota) { this.tipoMascota = tipoMascota; }

    public int getCapacidadMaxima() { return capacidadMaxima; }
    public void setCapacidadMaxima(int capacidadMaxima) { this.capacidadMaxima = capacidadMaxima; }

    public int getCantidadActual() { return cantidadActual; }
    public void setCantidadActual(int cantidadActual) { this.cantidadActual = cantidadActual; }

    public boolean isRequiereDonacionAlimentos() { return requiereDonacionAlimentos; }
    public void setRequiereDonacionAlimentos(boolean requiereDonacionAlimentos) {
        this.requiereDonacionAlimentos = requiereDonacionAlimentos;
    }

    /** Espacios libres: capacidad menos las mascotas que tiene. */
    public int getEspaciosLibres() { return capacidadMaxima - cantidadActual; }

    /** "Distrito, Cantón, Provincia". */
    public String getLugar() { return distrito + ", " + canton + ", " + provincia; }
}
