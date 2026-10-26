package com.mycompany.bd_proyecto1.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Posible coincidencia entre una mascota perdida y una encontrada (requisitos 5.d y 6.b).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MatchMascotas {

    private Mascota perdida;
    private Mascota encontrada;
    private int porcentaje;
    private List<String> criterios = new ArrayList<>();

    public Mascota getPerdida() { return perdida; }
    public void setPerdida(Mascota perdida) { this.perdida = perdida; }

    public Mascota getEncontrada() { return encontrada; }
    public void setEncontrada(Mascota encontrada) { this.encontrada = encontrada; }

    /** Porcentaje de coincidencia, de 0 a 100. */
    public int getPorcentaje() { return porcentaje; }
    public void setPorcentaje(int porcentaje) { this.porcentaje = porcentaje; }

    /** Características que coincidieron, en texto (por ejemplo "Mismo color"). */
    public List<String> getCriterios() { return criterios; }
    public void setCriterios(List<String> criterios) { this.criterios = criterios; }
}
