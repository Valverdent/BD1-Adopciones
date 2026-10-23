package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Criterios opcionales para consultar adopciones. Un criterio null o vacío no filtra.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroAdopcion {

    private ItemCatalogo tipoMascota;
    private String nombreMascota;
    private String adoptante;
    private String entregadoPor;
    private LocalDate fechaDesde;
    private LocalDate fechaHasta;

    public ItemCatalogo getTipoMascota() { return tipoMascota; }
    public void setTipoMascota(ItemCatalogo tipoMascota) { this.tipoMascota = tipoMascota; }

    public String getNombreMascota() { return nombreMascota; }
    public void setNombreMascota(String nombreMascota) { this.nombreMascota = nombreMascota; }

    public String getAdoptante() { return adoptante; }
    public void setAdoptante(String adoptante) { this.adoptante = adoptante; }

    public String getEntregadoPor() { return entregadoPor; }
    public void setEntregadoPor(String entregadoPor) { this.entregadoPor = entregadoPor; }

    public LocalDate getFechaDesde() { return fechaDesde; }
    public void setFechaDesde(LocalDate fechaDesde) { this.fechaDesde = fechaDesde; }

    public LocalDate getFechaHasta() { return fechaHasta; }
    public void setFechaHasta(LocalDate fechaHasta) { this.fechaHasta = fechaHasta; }
}
