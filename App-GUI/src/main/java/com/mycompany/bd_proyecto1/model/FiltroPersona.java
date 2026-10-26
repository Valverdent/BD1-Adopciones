package com.mycompany.bd_proyecto1.model;

/**
 * Criterios opcionales para consultar personas. Un criterio null o vacío no filtra; los de texto
 * buscan coincidencias parciales sin distinguir mayúsculas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class FiltroPersona {

    private String nombre;
    private FiltroUbicacion ubicacion = new FiltroUbicacion();

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }


    public FiltroUbicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(FiltroUbicacion ubicacion) {
        this.ubicacion = ubicacion == null ? new FiltroUbicacion() : ubicacion;
    }
}
