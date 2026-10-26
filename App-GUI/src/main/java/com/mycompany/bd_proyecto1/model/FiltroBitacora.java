package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;

/**
 * Criterios de la consulta de bitácora. Un criterio nulo o vacío no filtra.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroBitacora {

    private String usuario;
    private String tabla;
    private String campo;
    private Integer idRegistro;
    private String texto;
    private LocalDate fechaDesde;
    private LocalDate fechaHasta;

    /** Nombre de usuario (coincidencia parcial). */
    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }

    /** Tabla exacta, tal como la devuelve la lista de tablas. */
    public String getTabla() { return tabla; }
    public void setTabla(String tabla) { this.tabla = tabla; }

    /** Nombre del campo (coincidencia parcial). */
    public String getCampo() { return campo; }
    public void setCampo(String campo) { this.campo = campo; }

    public Integer getIdRegistro() { return idRegistro; }
    public void setIdRegistro(Integer idRegistro) { this.idRegistro = idRegistro; }

    /** Texto buscado en el valor anterior, el valor nuevo o la descripción. */
    public String getTexto() { return texto; }
    public void setTexto(String texto) { this.texto = texto; }

    public LocalDate getFechaDesde() { return fechaDesde; }
    public void setFechaDesde(LocalDate fechaDesde) { this.fechaDesde = fechaDesde; }

    public LocalDate getFechaHasta() { return fechaHasta; }
    public void setFechaHasta(LocalDate fechaHasta) { this.fechaHasta = fechaHasta; }
}
