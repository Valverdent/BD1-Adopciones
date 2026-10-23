package com.mycompany.bd_proyecto1.model;

/**
 * Criterios opcionales para consultar casas cuna. Un criterio null o vacío no filtra.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroCasaCuna {

    /** Casas que aceptan al menos una raza de este tipo de mascota. */
    private ItemCatalogo tipoMascota;
    private ItemCatalogo tamano;
    private ItemCatalogo estado;
    /** true: solo las que requieren donación; false: solo las que no; null: todas. */
    private Boolean requiereDonacionAlimentos;
    private FiltroUbicacion ubicacion = new FiltroUbicacion();
    private boolean soloDisponibles;

    public ItemCatalogo getTipoMascota() { return tipoMascota; }
    public void setTipoMascota(ItemCatalogo tipoMascota) { this.tipoMascota = tipoMascota; }

    public ItemCatalogo getTamano() { return tamano; }
    public void setTamano(ItemCatalogo tamano) { this.tamano = tamano; }

    public ItemCatalogo getEstado() { return estado; }
    public void setEstado(ItemCatalogo estado) { this.estado = estado; }

    public Boolean getRequiereDonacionAlimentos() { return requiereDonacionAlimentos; }
    public void setRequiereDonacionAlimentos(Boolean requiereDonacionAlimentos) { this.requiereDonacionAlimentos = requiereDonacionAlimentos; }

    public FiltroUbicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(FiltroUbicacion ubicacion) {
        this.ubicacion = ubicacion == null ? new FiltroUbicacion() : ubicacion;
    }

    public boolean isSoloDisponibles() { return soloDisponibles; }
    public void setSoloDisponibles(boolean soloDisponibles) { this.soloDisponibles = soloDisponibles; }
}
