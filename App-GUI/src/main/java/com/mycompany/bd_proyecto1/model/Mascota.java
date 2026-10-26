package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Mascota registrada como perdida, encontrada, en adopción o adoptada.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class Mascota {

    private int id;

    // Datos generales
    private ItemCatalogo tipo;
    private ItemCatalogo raza;
    private String nombre;
    private String chip;
    private ItemCatalogo color;
    private ItemCatalogo tamano;
    private ItemCatalogo estado;
    private Integer edadEstimada;

    // Extravío o hallazgo
    private LocalDate fechaEvento;
    /** Dónde se perdió o se encontró: distrito obligatorio, señas opcionales. */
    private Ubicacion ubicacion;
    private BigDecimal montoRecompensa;
    private ItemCatalogo monedaRecompensa;

    // Contacto
    private String telefonoContacto;
    private String correoContacto;

    // Características
    private boolean requiereEspacio;
    private ItemCatalogo nivelEnergia;
    private ItemCatalogo facilidadEntrenamiento;
    private ItemCatalogo severidad;

    // Salud
    private List<ItemCatalogo> enfermedades = new ArrayList<>();
    private ItemCatalogo veterinario;

    // Descripción y fotos
    private String descripcionAbandono;
    private String notas;
    private String fotoAntes;
    private String fotoDespues;

    // Quién registró la mascota
    private int idPersonaRegistro;
    private String nombrePersonaRegistro;
    /**
     * Casa cuna donde está la mascota (id de la persona dueña), o null. La pantalla no lo cambia;
     * se conserva para no perderlo al editar.
     */
    private Integer idCasaCuna;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

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

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getChip() {
        return chip;
    }

    public void setChip(String chip) {
        this.chip = chip;
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

    public ItemCatalogo getEstado() {
        return estado;
    }

    public void setEstado(ItemCatalogo estado) {
        this.estado = estado;
    }

    public Integer getEdadEstimada() {
        return edadEstimada;
    }

    public void setEdadEstimada(Integer edadEstimada) {
        this.edadEstimada = edadEstimada;
    }

    public LocalDate getFechaEvento() {
        return fechaEvento;
    }

    public void setFechaEvento(LocalDate fechaEvento) {
        this.fechaEvento = fechaEvento;
    }

    public Ubicacion getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(Ubicacion ubicacion) {
        this.ubicacion = ubicacion;
    }

    public BigDecimal getMontoRecompensa() {
        return montoRecompensa;
    }

    public void setMontoRecompensa(BigDecimal montoRecompensa) {
        this.montoRecompensa = montoRecompensa;
    }

    public ItemCatalogo getMonedaRecompensa() {
        return monedaRecompensa;
    }

    public void setMonedaRecompensa(ItemCatalogo monedaRecompensa) {
        this.monedaRecompensa = monedaRecompensa;
    }

    public String getTelefonoContacto() {
        return telefonoContacto;
    }

    public void setTelefonoContacto(String telefonoContacto) {
        this.telefonoContacto = telefonoContacto;
    }

    public String getCorreoContacto() {
        return correoContacto;
    }

    public void setCorreoContacto(String correoContacto) {
        this.correoContacto = correoContacto;
    }

    public boolean isRequiereEspacio() {
        return requiereEspacio;
    }

    public void setRequiereEspacio(boolean requiereEspacio) {
        this.requiereEspacio = requiereEspacio;
    }

    public ItemCatalogo getNivelEnergia() {
        return nivelEnergia;
    }

    public void setNivelEnergia(ItemCatalogo nivelEnergia) {
        this.nivelEnergia = nivelEnergia;
    }

    public ItemCatalogo getFacilidadEntrenamiento() {
        return facilidadEntrenamiento;
    }

    public void setFacilidadEntrenamiento(ItemCatalogo facilidadEntrenamiento) {
        this.facilidadEntrenamiento = facilidadEntrenamiento;
    }

    public ItemCatalogo getSeveridad() {
        return severidad;
    }

    public void setSeveridad(ItemCatalogo severidad) {
        this.severidad = severidad;
    }

    public List<ItemCatalogo> getEnfermedades() {
        return enfermedades;
    }

    public void setEnfermedades(List<ItemCatalogo> enfermedades) {
        this.enfermedades = enfermedades == null ? new ArrayList<>() : enfermedades;
    }

    public ItemCatalogo getVeterinario() {
        return veterinario;
    }

    public void setVeterinario(ItemCatalogo veterinario) {
        this.veterinario = veterinario;
    }

    public String getDescripcionAbandono() {
        return descripcionAbandono;
    }

    public void setDescripcionAbandono(String descripcionAbandono) {
        this.descripcionAbandono = descripcionAbandono;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }

    public String getFotoAntes() {
        return fotoAntes;
    }

    public void setFotoAntes(String fotoAntes) {
        this.fotoAntes = fotoAntes;
    }

    public String getFotoDespues() {
        return fotoDespues;
    }

    public void setFotoDespues(String fotoDespues) {
        this.fotoDespues = fotoDespues;
    }

    public int getIdPersonaRegistro() {
        return idPersonaRegistro;
    }

    public void setIdPersonaRegistro(int idPersonaRegistro) {
        this.idPersonaRegistro = idPersonaRegistro;
    }

    public String getNombrePersonaRegistro() {
        return nombrePersonaRegistro;
    }

    public void setNombrePersonaRegistro(String nombrePersonaRegistro) {
        this.nombrePersonaRegistro = nombrePersonaRegistro;
    }

    public Integer getIdCasaCuna() {
        return idCasaCuna;
    }

    public void setIdCasaCuna(Integer idCasaCuna) {
        this.idCasaCuna = idCasaCuna;
    }
}
