package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.ResumenAdoptante;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Collator;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Implementación de AdopcionDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionDAOMemoria implements AdopcionDAO {

    private final MascotaDAO mascotaDAO;
    private final List<Adopcion> adopciones;
    private final List<SeguimientoAdopcion> seguimientos = DatosPrueba.crearSeguimientos();
    private int siguienteIdAdopcion;
    private int siguienteIdSeguimiento = seguimientos.size() + 1;

    /** Bitácora donde se registran los cambios sensibles; puede ser nula. */
    private final BitacoraDAOMemoria bitacora;

    /** Sin bitácora (se usa en algunas pruebas). */
    public AdopcionDAOMemoria(MascotaDAO mascotaDAO) {
        this(mascotaDAO, null);
    }

    public AdopcionDAOMemoria(MascotaDAO mascotaDAO, BitacoraDAOMemoria bitacora) {
        this.mascotaDAO = mascotaDAO;
        this.bitacora = bitacora;
        this.adopciones = DatosPrueba.crearAdopciones(mascotaDAO.consultar(new FiltroMascota()));
        this.siguienteIdAdopcion = adopciones.size() + 1;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Adopcion> consultar(FiltroAdopcion filtro) {
        List<Adopcion> resultado = new ArrayList<>();
        for (Adopcion a : adopciones) {
            if (cumpleFiltro(a, filtro)) {
                a.setCantidadSeguimientos(listarSeguimientos(a.getId()).size());
                resultado.add(a);
            }
        }
        resultado.sort(Comparator.comparing(Adopcion::getFechaAdopcion).reversed());
        return resultado;
    }

    @Override
    public List<Mascota> listarMascotasDisponibles() {
        List<Mascota> disponibles = new ArrayList<>();
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if (DatosPrueba.EN_ADOPCION.equals(m.getEstado()) && !tieneAdopcion(m.getId())) {
                disponibles.add(m);
            }
        }
        Collator orden = Collator.getInstance(Locale.forLanguageTag("es"));
        disponibles.sort((a, b) -> orden.compare(nombre(a), nombre(b)));
        return disponibles;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Registro y edición --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Adopcion adopcion) {
        adopcion.setId(siguienteIdAdopcion);
        siguienteIdAdopcion++;
        adopciones.add(adopcion);

        // Igual que en la base de datos: la mascota pasa a "Adoptada". Se cambia
        // la misma mascota guardada, así el cambio de estado queda una sola vez
        // en la bitácora (la registra esta clase, no el repositorio de mascotas).
        Mascota mascota = buscarMascotaGuardada(adopcion.getMascota());
        ItemCatalogo estadoAnterior = mascota.getEstado();
        mascota.setEstado(DatosPrueba.ADOPTADA);
        adopcion.getMascota().setEstado(DatosPrueba.ADOPTADA);
        mascotaDAO.actualizar(mascota);
        if (bitacora != null) {
            bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_MASCOTA, "Estado", mascota.getId(),
                    estadoAnterior, DatosPrueba.ADOPTADA,
                    "Mascota " + mascota.getNombre() + " adoptada (adopción " + adopcion.getId() + ").");
        }
        return adopcion.getId();
    }

    @Override
    public void actualizar(Adopcion datos) {
        for (Adopcion a : adopciones) {
            if (a.getId() == datos.getId()) {
                registrarEnBitacora(a, datos);
                // Solo se copian los datos editables.
                a.setFechaAdopcion(datos.getFechaAdopcion());
                a.setTipoVivienda(datos.getTipoVivienda());
                a.setTienePatio(datos.isTienePatio());
                a.setTiempoEjercicio(datos.getTiempoEjercicio());
                a.setOtrasMascotas(new ArrayList<>(datos.getOtrasMascotas()));
                a.setFotoAdoptante(datos.getFotoAdoptante());
                a.setCalificacion(datos.getCalificacion());
                a.setNotasCalificacion(datos.getNotasCalificacion());
                return;
            }
        }
        throw new IllegalStateException("No existe la adopción con id " + datos.getId());
    }

    private Mascota buscarMascotaGuardada(Mascota mascota) {
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if (m.getId() == mascota.getId()) {
                return m;
            }
        }
        return mascota;
    }

    /** Hace lo que haría el trigger de la tabla de adopciones en Oracle. */
    private void registrarEnBitacora(Adopcion anterior, Adopcion nueva) {
        if (bitacora == null) {
            return;
        }
        String deQuien = " de la adopción de " + anterior.getMascota().getNombre() + ".";
        bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_ADOPCION, "Calificación", anterior.getId(),
                anterior.getCalificacion(), nueva.getCalificacion(), "Cambio de calificación" + deQuien);
        bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_ADOPCION, "Notas de calificación", anterior.getId(),
                anterior.getNotasCalificacion(), nueva.getNotasCalificacion(), "Cambio de notas" + deQuien);
        bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_ADOPCION, "Fecha de adopción", anterior.getId(),
                anterior.getFechaAdopcion(), nueva.getFechaAdopcion(), "Cambio de fecha" + deQuien);
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Seguimientos -----------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<SeguimientoAdopcion> listarSeguimientos(int idAdopcion) {
        List<SeguimientoAdopcion> resultado = new ArrayList<>();
        for (SeguimientoAdopcion s : seguimientos) {
            if (s.getIdAdopcion() == idAdopcion) {
                resultado.add(s);
            }
        }
        resultado.sort(Comparator.comparing(SeguimientoAdopcion::getFecha).reversed());
        return resultado;
    }

    @Override
    public int insertarSeguimiento(SeguimientoAdopcion seguimiento) {
        seguimiento.setId(siguienteIdSeguimiento);
        siguienteIdSeguimiento++;
        seguimientos.add(seguimiento);
        return seguimiento.getId();
    }

    private boolean tieneAdopcion(int idMascota) {
        for (Adopcion a : adopciones) {
            if (a.getMascota().getId() == idMascota) {
                return true;
            }
        }
        return false;
    }

    private String nombre(Mascota m) {
        return m.getNombre() == null ? "" : m.getNombre();
    }

    private boolean cumpleFiltro(Adopcion a, FiltroAdopcion f) {
        Mascota m = a.getMascota();
        return (f.getTipoMascota() == null || f.getTipoMascota().equals(m.getTipo()))
                && contiene(m.getNombre(), f.getNombreMascota())
                && contiene(a.getAdoptante().getNombre(), f.getAdoptante())
                && contiene(a.getNombrePersonaEntrega(), f.getEntregadoPor())
                && dentroDelRango(a.getFechaAdopcion(), f.getFechaDesde(), f.getFechaHasta());
    }

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

    // ------------------------------------------------------------------------
    // ---------------------------- Por adoptante -----------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Adopcion> listarAdopcionesDeAdoptante(int idPersona) {
        List<Adopcion> resultado = new ArrayList<>();
        for (Adopcion a : adopciones) {
            if (a.getAdoptante().getId() == idPersona) {
                a.setCantidadSeguimientos(listarSeguimientos(a.getId()).size());
                resultado.add(a);
            }
        }
        resultado.sort(Comparator.comparing(Adopcion::getFechaAdopcion).reversed());
        return resultado;
    }

    @Override
    public List<ResumenAdoptante> consultarPorAdoptante(FiltroAdoptante filtro) {
        Map<Integer, ResumenAdoptante> porAdoptante = new LinkedHashMap<>();
        Map<Integer, Integer> sumas = new LinkedHashMap<>();
        Map<Integer, Integer> calificadas = new LinkedHashMap<>();
        for (Adopcion a : adopciones) {
            int id = a.getAdoptante().getId();
            if (!contiene(a.getAdoptante().getNombre(), filtro.getNombre())
                    || !dentroDelRango(a.getFechaAdopcion(), filtro.getFechaDesde(), filtro.getFechaHasta())) {
                continue;
            }
            ResumenAdoptante fila = porAdoptante.get(id);
            if (fila == null) {
                fila = new ResumenAdoptante();
                fila.setIdPersona(id);
                fila.setNombrePersona(a.getAdoptante().getNombre());
                porAdoptante.put(id, fila);
            }
            fila.setCantidadAdopciones(fila.getCantidadAdopciones() + 1);
            if (fila.getUltimaAdopcion() == null || a.getFechaAdopcion().isAfter(fila.getUltimaAdopcion())) {
                fila.setUltimaAdopcion(a.getFechaAdopcion());
            }
            if (a.getCalificacion() != null) {
                sumas.merge(id, a.getCalificacion(), Integer::sum);
                calificadas.merge(id, 1, Integer::sum);
            }
        }
        for (ResumenAdoptante fila : porAdoptante.values()) {
            Integer cantidad = calificadas.get(fila.getIdPersona());
            if (cantidad != null) {
                fila.setCalificacionPromedio(BigDecimal.valueOf(sumas.get(fila.getIdPersona()))
                        .divide(BigDecimal.valueOf(cantidad), 2, RoundingMode.HALF_UP));
            }
        }
        List<ResumenAdoptante> resultado = new ArrayList<>(porAdoptante.values());
        resultado.sort(Comparator.comparingInt(ResumenAdoptante::getCantidadAdopciones).reversed()
                .thenComparing(ResumenAdoptante::getNombrePersona));
        return resultado;
    }
}
