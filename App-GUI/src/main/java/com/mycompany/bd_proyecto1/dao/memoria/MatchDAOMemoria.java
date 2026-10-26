package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.dao.MatchDAO;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MatchMascotas;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Implementación de MatchDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MatchDAOMemoria implements MatchDAO {

    static final int PUNTOS_TIPO = 25;
    static final int PUNTOS_RAZA = 20;
    static final int PUNTOS_COLOR = 20;
    static final int PUNTOS_TAMANO = 15;
    static final int PUNTOS_PROVINCIA = 5;
    static final int PUNTOS_CANTON = 5;
    static final int PUNTOS_FECHA = 10;
    static final int DIAS_FECHA_CERCANA = 30;

    private final MascotaDAO mascotaDAO;

    public MatchDAOMemoria(MascotaDAO mascotaDAO) {
        this.mascotaDAO = mascotaDAO;
    }

    @Override
    public List<MatchMascotas> generarMatches(int porcentajeMinimo, ItemCatalogo tipo) {
        List<Mascota> perdidas = new ArrayList<>();
        List<Mascota> encontradas = new ArrayList<>();
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if (DatosPrueba.PERDIDA.equals(m.getEstado())) {
                perdidas.add(m);
            } else if (DatosPrueba.ENCONTRADA.equals(m.getEstado())) {
                encontradas.add(m);
            }
        }

        List<MatchMascotas> resultado = new ArrayList<>();
        for (Mascota perdida : perdidas) {
            if (tipo != null && !tipo.equals(perdida.getTipo())) {
                continue;
            }
            for (Mascota encontrada : encontradas) {
                MatchMascotas match = comparar(perdida, encontrada);
                if (match != null && match.getPorcentaje() >= porcentajeMinimo) {
                    resultado.add(match);
                }
            }
        }
        resultado.sort(Comparator.comparingInt(MatchMascotas::getPorcentaje).reversed()
                .thenComparing(m -> m.getPerdida().getFechaEvento(), Comparator.reverseOrder()));
        return resultado;
    }

    /** @return el match, o null si los tipos son distintos */
    private MatchMascotas comparar(Mascota perdida, Mascota encontrada) {
        if (perdida.getTipo() == null || !perdida.getTipo().equals(encontrada.getTipo())) {
            return null;
        }
        List<String> criterios = new ArrayList<>();
        int puntos = PUNTOS_TIPO;
        criterios.add("Mismo tipo");

        if (perdida.getRaza() != null && perdida.getRaza().equals(encontrada.getRaza())) {
            puntos += PUNTOS_RAZA;
            criterios.add("Misma raza");
        }
        if (perdida.getColor() != null && perdida.getColor().equals(encontrada.getColor())) {
            puntos += PUNTOS_COLOR;
            criterios.add("Mismo color");
        }
        if (perdida.getTamano() != null && perdida.getTamano().equals(encontrada.getTamano())) {
            puntos += PUNTOS_TAMANO;
            criterios.add("Mismo tamaño");
        }
        Ubicacion lugarPerdida = perdida.getUbicacion();
        Ubicacion lugarEncontrada = encontrada.getUbicacion();
        if (lugarPerdida != null && lugarEncontrada != null
                && mismo(lugarPerdida.getProvincia(), lugarEncontrada.getProvincia())) {
            puntos += PUNTOS_PROVINCIA;
            criterios.add("Misma provincia");
            if (mismo(lugarPerdida.getCanton(), lugarEncontrada.getCanton())) {
                puntos += PUNTOS_CANTON;
                criterios.add("Mismo cantón");
            }
        }
        long dias = Math.abs(ChronoUnit.DAYS.between(perdida.getFechaEvento(), encontrada.getFechaEvento()));
        if (dias <= DIAS_FECHA_CERCANA) {
            puntos += PUNTOS_FECHA;
            criterios.add("Fechas cercanas (" + dias + " días de diferencia)");
        }
        if (mismoChip(perdida, encontrada)) {
            puntos = 100;
            criterios.add("Mismo chip");
        }

        MatchMascotas match = new MatchMascotas();
        match.setPerdida(perdida);
        match.setEncontrada(encontrada);
        match.setPorcentaje(Math.min(puntos, 100));
        match.setCriterios(criterios);
        return match;
    }

    private boolean mismoChip(Mascota a, Mascota b) {
        return a.getChip() != null && !a.getChip().isBlank() && a.getChip().equalsIgnoreCase(b.getChip());
    }

    /** Mismo elemento registrado (se compara por identificador, no por nombre). */
    private static boolean mismo(ItemCatalogo a, ItemCatalogo b) {
        return a != null && a.equals(b);
    }
}
