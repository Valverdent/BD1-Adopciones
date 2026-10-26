package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Donación completa, con su reparto entre asociaciones (requisito 4.h).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class Donacion {

    private int id;
    private TipoDonacion tipo;
    private int idPersonaDonador;
    private String nombreDonador;
    private ItemCatalogo moneda;
    /** Mascota cuya recompensa se dona; null en las donaciones voluntarias. */
    private Mascota mascota;
    private BigDecimal montoTotal;
    private LocalDate fecha;
    /** Reparto entre asociaciones. Nunca null. */
    private List<DetalleDonacion> detalles = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public TipoDonacion getTipo() { return tipo; }
    public void setTipo(TipoDonacion tipo) { this.tipo = tipo; }

    public int getIdPersonaDonador() { return idPersonaDonador; }
    public void setIdPersonaDonador(int idPersonaDonador) { this.idPersonaDonador = idPersonaDonador; }

    public String getNombreDonador() { return nombreDonador; }
    public void setNombreDonador(String nombreDonador) { this.nombreDonador = nombreDonador; }

    public ItemCatalogo getMoneda() { return moneda; }
    public void setMoneda(ItemCatalogo moneda) { this.moneda = moneda; }

    public Mascota getMascota() { return mascota; }
    public void setMascota(Mascota mascota) { this.mascota = mascota; }

    public BigDecimal getMontoTotal() { return montoTotal; }
    public void setMontoTotal(BigDecimal montoTotal) { this.montoTotal = montoTotal; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public List<DetalleDonacion> getDetalles() { return detalles; }
    public void setDetalles(List<DetalleDonacion> detalles) {
        this.detalles = detalles == null ? new ArrayList<>() : detalles;
    }
}
