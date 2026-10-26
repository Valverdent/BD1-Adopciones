package com.mycompany.bd_proyecto1.model;

/**
 * Parámetro del sistema (tabla Parameter del diagrama): un valor que la aplicación usa en lugar de
 * un dato escrito en el código.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class Parametro {

    private int id;
    /** Clave interna, por ejemplo MATCH_MIN_SCORE. */
    private String nombre;
    private String descripcion;
    /** Valor guardado como texto; el gestor lo convierte según el parámetro. */
    private String valor;
    /** true si el valor es un número (columna numberValue); false si es texto (textValue). */
    private boolean numerico = true;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getValor() { return valor; }
    public void setValor(String valor) { this.valor = valor; }

    public boolean isNumerico() { return numerico; }
    public void setNumerico(boolean numerico) { this.numerico = numerico; }
}
