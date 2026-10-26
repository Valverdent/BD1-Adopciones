package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Implementación de MascotaDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaDAOMemoria implements MascotaDAO {

    private final List<Mascota> mascotas = DatosPrueba.crearMascotas();
    private int siguienteId = mascotas.size() + 1;
    /** Bitácora donde se registran los cambios sensibles; puede ser nula. */
    private final BitacoraDAOMemoria bitacora;

    /** Sin bitácora (se usa en algunas pruebas). */
    public MascotaDAOMemoria() {
        this(null);
    }

    public MascotaDAOMemoria(BitacoraDAOMemoria bitacora) {
        this.bitacora = bitacora;
    }

    @Override
    public List<Mascota> consultar(FiltroMascota filtro) {
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : mascotas) {
            if (cumpleFiltro(m, filtro)) {
                resultado.add(m);
            }
        }
        resultado.sort(Comparator.comparing(Mascota::getFechaEvento).reversed());
        return resultado;
    }

    @Override
    public int insertar(Mascota mascota) {
        mascota.setId(siguienteId);
        siguienteId++;
        mascotas.add(mascota);
        return mascota.getId();
    }

    @Override
    public void actualizar(Mascota mascota) {
        for (int i = 0; i < mascotas.size(); i++) {
            if (mascotas.get(i).getId() == mascota.getId()) {
                registrarEnBitacora(mascotas.get(i), mascota);
                mascotas.set(i, mascota);
                return;
            }
        }
        throw new IllegalStateException("No existe la mascota con id " + mascota.getId());
    }

    /** Hace lo que haría el trigger de la tabla de mascotas en Oracle. */
    private void registrarEnBitacora(Mascota anterior, Mascota nueva) {
        if (bitacora == null) {
            return;
        }
        bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_MASCOTA, "Estado", nueva.getId(),
                anterior.getEstado(), nueva.getEstado(), "Cambio de estado de " + nueva.getNombre() + ".");
        bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_MASCOTA, "Monto de recompensa", nueva.getId(),
                anterior.getMontoRecompensa(), nueva.getMontoRecompensa(),
                "Cambio de la recompensa de " + nueva.getNombre() + ".");
    }

    @Override
    public boolean existeChip(String chip, int idExcluir) {
        for (Mascota m : mascotas) {
            if (m.getId() != idExcluir && m.getChip() != null && m.getChip().equalsIgnoreCase(chip)) {
                return true;
            }
        }
        return false;
    }

    private boolean cumpleFiltro(Mascota m, FiltroMascota f) {
        return coincide(m.getTipo(), f.getTipo())
                && coincide(m.getRaza(), f.getRaza())
                && coincide(m.getEstado(), f.getEstado())
                && coincide(m.getColor(), f.getColor())
                && coincide(m.getTamano(), f.getTamano())
                && contiene(m.getChip(), f.getChip())
                && contiene(m.getNombre(), f.getNombre())
                && f.getUbicacion().cumple(m.getUbicacion())
                && contiene(m.getNombrePersonaRegistro(), f.getRegistradoPor())
                && dentroDelRango(m.getFechaEvento(), f.getFechaDesde(), f.getFechaHasta());
    }

    /** Un criterio de catálogo vacío no filtra. */
    private boolean coincide(ItemCatalogo valor, ItemCatalogo criterio) {
        return criterio == null || criterio.equals(valor);
    }

    /** Un criterio de texto vacío no filtra; si no, busca coincidencia parcial. */
    private boolean contiene(String valor, String criterio) {
        if (criterio == null || criterio.isBlank()) {
            return true;
        }
        return valor != null && valor.toLowerCase().contains(criterio.trim().toLowerCase());
    }

    private boolean dentroDelRango(LocalDate fecha, LocalDate desde, LocalDate hasta) {
        if (desde != null && fecha.isBefore(desde)) {
            return false;
        }
        return hasta == null || !fecha.isAfter(hasta);
    }

    @Override
    public List<Mascota> listarSinAdoptar(int mesesMinimos, ItemCatalogo tipo) {
        LocalDate limite = LocalDate.now().minusMonths(mesesMinimos);
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : mascotas) {
            if (DatosPrueba.EN_ADOPCION.equals(m.getEstado())
                    && !m.getFechaEvento().isAfter(limite)
                    && coincide(m.getTipo(), tipo)) {
                resultado.add(m);
            }
        }
        resultado.sort(Comparator.comparing(Mascota::getFechaEvento));
        return resultado;
    }
}
