package com.mycompany.bd_proyecto1.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Persona rescatista, adoptante, donadora o usuaria del sistema (requisito 4.n).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class Persona {

    private int id;
    private String nombre;
    private String segundoNombre;
    private String primerApellido;
    private String segundoApellido;
    /** Lugar de residencia (tabla Location: distrito + señas). */
    private Ubicacion ubicacion;
    private List<String> telefonos = new ArrayList<>();
    private List<String> correos = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getSegundoNombre() { return segundoNombre; }
    public void setSegundoNombre(String segundoNombre) { this.segundoNombre = segundoNombre; }

    public String getPrimerApellido() { return primerApellido; }
    public void setPrimerApellido(String primerApellido) { this.primerApellido = primerApellido; }

    public String getSegundoApellido() { return segundoApellido; }
    public void setSegundoApellido(String segundoApellido) { this.segundoApellido = segundoApellido; }


    public Ubicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(Ubicacion ubicacion) { this.ubicacion = ubicacion; }

    public List<String> getTelefonos() { return telefonos; }
    public void setTelefonos(List<String> telefonos) {
        this.telefonos = telefonos == null ? new ArrayList<>() : telefonos;
    }

    public List<String> getCorreos() { return correos; }
    public void setCorreos(List<String> correos) {
        this.correos = correos == null ? new ArrayList<>() : correos;
    }

    /** Nombre, segundo nombre y apellidos, sin los que estén vacíos. */
    public String getNombreCompleto() {
        StringBuilder texto = new StringBuilder();
        for (String parte : new String[] {nombre, segundoNombre, primerApellido, segundoApellido}) {
            if (parte != null && !parte.isBlank()) {
                if (texto.length() > 0) {
                    texto.append(' ');
                }
                texto.append(parte.trim());
            }
        }
        return texto.toString();
    }
}
