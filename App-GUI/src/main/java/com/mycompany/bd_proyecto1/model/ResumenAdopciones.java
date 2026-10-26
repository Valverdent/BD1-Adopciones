package com.mycompany.bd_proyecto1.model;

import com.mycompany.bd_proyecto1.util.Porcentajes;
import java.math.BigDecimal;

/**
 * Adopciones exitosas frente a mascotas que siguen en espera (estadística 8.c).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ResumenAdopciones {

    private final int adoptadas;
    private final int enEspera;

    public ResumenAdopciones(int adoptadas, int enEspera) {
        this.adoptadas = adoptadas;
        this.enEspera = enEspera;
    }

    public int getAdoptadas() { return adoptadas; }

    public int getEnEspera() { return enEspera; }

    public int getTotal() { return adoptadas + enEspera; }

    public BigDecimal getPorcentajeAdoptadas() { return Porcentajes.de(adoptadas, getTotal()); }

    public BigDecimal getPorcentajeEnEspera() { return Porcentajes.de(enEspera, getTotal()); }
}
