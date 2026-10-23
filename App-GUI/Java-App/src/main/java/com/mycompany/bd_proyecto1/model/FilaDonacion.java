package com.mycompany.bd_proyecto1.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Una fila de la consulta de donaciones: la parte de una donación que recibe una asociación
 * (requisito 5.b). Una donación repartida entre dos asociaciones produce dos filas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FilaDonacion {

    private int idDonacion;
    private LocalDate fecha;
    private String nombreDonador;
    private TipoDonacion tipo;
    private ItemCatalogo moneda;
    private AsociacionBienestar asociacion;
    /** null si la donación fue completa a una sola asociación. */
    private BigDecimal porcentaje;
    /** Monto que recibe esta asociación. */
    private BigDecimal monto;
    /** Monto total de la donación completa. */
    private BigDecimal montoTotalDonacion;
    /** Nombre de la mascota si es una donación de recompensa; si no, null. */
    private String nombreMascota;

    public int getIdDonacion() { return idDonacion; }
    public void setIdDonacion(int idDonacion) { this.idDonacion = idDonacion; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public String getNombreDonador() { return nombreDonador; }
    public void setNombreDonador(String nombreDonador) { this.nombreDonador = nombreDonador; }

    public TipoDonacion getTipo() { return tipo; }
    public void setTipo(TipoDonacion tipo) { this.tipo = tipo; }

    public ItemCatalogo getMoneda() { return moneda; }
    public void setMoneda(ItemCatalogo moneda) { this.moneda = moneda; }

    public AsociacionBienestar getAsociacion() { return asociacion; }
    public void setAsociacion(AsociacionBienestar asociacion) { this.asociacion = asociacion; }

    public BigDecimal getPorcentaje() { return porcentaje; }
    public void setPorcentaje(BigDecimal porcentaje) { this.porcentaje = porcentaje; }

    public BigDecimal getMonto() { return monto; }
    public void setMonto(BigDecimal monto) { this.monto = monto; }

    public BigDecimal getMontoTotalDonacion() { return montoTotalDonacion; }
    public void setMontoTotalDonacion(BigDecimal montoTotalDonacion) { this.montoTotalDonacion = montoTotalDonacion; }

    public String getNombreMascota() { return nombreMascota; }
    public void setNombreMascota(String nombreMascota) { this.nombreMascota = nombreMascota; }
}
