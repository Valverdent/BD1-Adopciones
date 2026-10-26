package com.mycompany.bd_proyecto1.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Casa cuna: persona que cuida temporalmente mascotas (requisito 4.e). Hay una casa cuna por
 * persona, así que idPersona la identifica.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCuna {

    private int idPersona;
    private String nombrePersona;
    private Ubicacion ubicacion;
    private ItemCatalogo estado;
    private int capacidadMaxima;
    /** Mascotas que tiene ahora (solo lectura: la base las cuenta por idFosterHome de Pet). */
    private int cantidadActual;
    private boolean requiereDonacionAlimentos;
    /** Tamaños de mascota que acepta. */
    private List<ItemCatalogo> tamanos = new ArrayList<>();
    /** Tipos de mascota que acepta (tabla FosterHome_x_PetType). */
    private List<ItemCatalogo> tipos = new ArrayList<>();

    // Solo lectura: los calcula el DAO.
    private List<String> telefonos = new ArrayList<>();
    private List<String> correos = new ArrayList<>();
    /** Estado "Disponible" y todavía con cupo. */
    private boolean disponible;

    public int getIdPersona() { return idPersona; }
    public void setIdPersona(int idPersona) { this.idPersona = idPersona; }

    public String getNombrePersona() { return nombrePersona; }
    public void setNombrePersona(String nombrePersona) { this.nombrePersona = nombrePersona; }

    public Ubicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(Ubicacion ubicacion) { this.ubicacion = ubicacion; }

    public ItemCatalogo getEstado() { return estado; }
    public void setEstado(ItemCatalogo estado) { this.estado = estado; }

    public int getCapacidadMaxima() { return capacidadMaxima; }
    public void setCapacidadMaxima(int capacidadMaxima) { this.capacidadMaxima = capacidadMaxima; }

    public int getCantidadActual() { return cantidadActual; }
    public void setCantidadActual(int cantidadActual) { this.cantidadActual = cantidadActual; }

    public boolean isRequiereDonacionAlimentos() { return requiereDonacionAlimentos; }
    public void setRequiereDonacionAlimentos(boolean requiereDonacionAlimentos) { this.requiereDonacionAlimentos = requiereDonacionAlimentos; }

    public List<ItemCatalogo> getTamanos() { return tamanos; }
    public void setTamanos(List<ItemCatalogo> tamanos) { this.tamanos = tamanos == null ? new ArrayList<>() : tamanos; }

    public List<ItemCatalogo> getTipos() { return tipos; }
    public void setTipos(List<ItemCatalogo> tipos) { this.tipos = tipos == null ? new ArrayList<>() : tipos; }

    public List<String> getTelefonos() { return telefonos; }
    public void setTelefonos(List<String> telefonos) { this.telefonos = telefonos == null ? new ArrayList<>() : telefonos; }

    public List<String> getCorreos() { return correos; }
    public void setCorreos(List<String> correos) { this.correos = correos == null ? new ArrayList<>() : correos; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }
}
