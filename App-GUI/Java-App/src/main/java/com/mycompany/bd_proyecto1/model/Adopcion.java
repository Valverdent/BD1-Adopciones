package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Adopción de una mascota (requisito 4.f) con las respuestas del formulario de adopción (4.o) y la
 * calificación de los nuevos dueños.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class Adopcion {

    private int id;

    /** Mascota adoptada: se usan su id, nombre, tipo, raza y fecha. */
    private Mascota mascota;

    private int idPersonaEntrega;
    private String nombrePersonaEntrega;

    /** Persona adoptante: id y nombre completo. */
    private ItemCatalogo adoptante;

    // Formulario de adopción (4.o)
    private ItemCatalogo tipoVivienda;
    private boolean tienePatio;
    private ItemCatalogo tiempoEjercicio;
    /** Razas de las otras mascotas que tiene el adoptante. Nunca null. */
    private List<ItemCatalogo> otrasMascotas = new ArrayList<>();

    private LocalDate fechaAdopcion;
    private String fotoAdoptante;

    /** Calificación de 1 a 5 estrellas; null si aún no se califica. */
    private Integer calificacion;
    private String notasCalificacion;

    /** Dato informativo para la consulta. */
    private int cantidadSeguimientos;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Mascota getMascota() { return mascota; }
    public void setMascota(Mascota mascota) { this.mascota = mascota; }

    public int getIdPersonaEntrega() { return idPersonaEntrega; }
    public void setIdPersonaEntrega(int idPersonaEntrega) { this.idPersonaEntrega = idPersonaEntrega; }

    public String getNombrePersonaEntrega() { return nombrePersonaEntrega; }
    public void setNombrePersonaEntrega(String nombrePersonaEntrega) { this.nombrePersonaEntrega = nombrePersonaEntrega; }

    public ItemCatalogo getAdoptante() { return adoptante; }
    public void setAdoptante(ItemCatalogo adoptante) { this.adoptante = adoptante; }

    public ItemCatalogo getTipoVivienda() { return tipoVivienda; }
    public void setTipoVivienda(ItemCatalogo tipoVivienda) { this.tipoVivienda = tipoVivienda; }

    public boolean isTienePatio() { return tienePatio; }
    public void setTienePatio(boolean tienePatio) { this.tienePatio = tienePatio; }

    public ItemCatalogo getTiempoEjercicio() { return tiempoEjercicio; }
    public void setTiempoEjercicio(ItemCatalogo tiempoEjercicio) { this.tiempoEjercicio = tiempoEjercicio; }

    public List<ItemCatalogo> getOtrasMascotas() { return otrasMascotas; }
    public void setOtrasMascotas(List<ItemCatalogo> otrasMascotas) {
        this.otrasMascotas = otrasMascotas == null ? new ArrayList<>() : otrasMascotas;
    }

    public LocalDate getFechaAdopcion() { return fechaAdopcion; }
    public void setFechaAdopcion(LocalDate fechaAdopcion) { this.fechaAdopcion = fechaAdopcion; }

    public String getFotoAdoptante() { return fotoAdoptante; }
    public void setFotoAdoptante(String fotoAdoptante) { this.fotoAdoptante = fotoAdoptante; }

    public Integer getCalificacion() { return calificacion; }
    public void setCalificacion(Integer calificacion) { this.calificacion = calificacion; }

    public String getNotasCalificacion() { return notasCalificacion; }
    public void setNotasCalificacion(String notasCalificacion) { this.notasCalificacion = notasCalificacion; }

    public int getCantidadSeguimientos() { return cantidadSeguimientos; }
    public void setCantidadSeguimientos(int cantidadSeguimientos) { this.cantidadSeguimientos = cantidadSeguimientos; }
}
