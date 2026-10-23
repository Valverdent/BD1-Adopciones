package com.mycompany.bd_proyecto1.model;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * Mascota en adopción que lleva un tiempo sin ser adoptada (requisito 4.o).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaSinAdoptar {

    private final Mascota mascota;
    private final long diasEspera;

    public MascotaSinAdoptar(Mascota mascota, LocalDate hoy) {
        this.mascota = mascota;
        this.diasEspera = ChronoUnit.DAYS.between(mascota.getFechaEvento(), hoy);
    }

    public Mascota getMascota() { return mascota; }

    public long getDiasEspera() { return diasEspera; }
}
