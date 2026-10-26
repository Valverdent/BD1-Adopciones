package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.AsociacionDAO;
import com.mycompany.bd_proyecto1.dao.DonacionDAO;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.model.DetalleDonacion;
import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import java.math.BigDecimal;
import java.text.Collator;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Implementación de DonacionDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DonacionDAOMemoria implements DonacionDAO {

    private final MascotaDAO mascotaDAO;
    private final List<Donacion> donaciones;
    private int siguienteId;

    /** Bitácora donde se registran los cambios sensibles; puede ser nula. */
    private final BitacoraDAOMemoria bitacora;

    /** Sin bitácora (se usa en algunas pruebas). */
    public DonacionDAOMemoria(MascotaDAO mascotaDAO, AsociacionDAO asociacionDAO) {
        this(mascotaDAO, asociacionDAO, null);
    }

    public DonacionDAOMemoria(MascotaDAO mascotaDAO, AsociacionDAO asociacionDAO, BitacoraDAOMemoria bitacora) {
        this.mascotaDAO = mascotaDAO;
        this.bitacora = bitacora;
        this.donaciones = DatosPrueba.crearDonaciones(asociacionDAO.listar(), mascotaDAO.consultar(new FiltroMascota()));
        this.siguienteId = donaciones.size() + 1;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<FilaDonacion> consultar(FiltroDonacion filtro) {
        List<FilaDonacion> filas = new ArrayList<>();
        for (Donacion d : donaciones) {
            for (DetalleDonacion det : d.getDetalles()) {
                if (cumpleFiltro(d, det, filtro)) {
                    filas.add(crearFila(d, det));
                }
            }
        }
        filas.sort(Comparator.comparing(FilaDonacion::getFecha).reversed());
        return filas;
    }

    @Override
    public List<TotalAsociacion> totalesPorAsociacion(LocalDate desde, LocalDate hasta) {
        Map<String, TotalAsociacion> totales = new LinkedHashMap<>();
        for (Donacion d : donaciones) {
            if (!dentroDelRango(d.getFecha(), desde, hasta)) {
                continue;
            }
            for (DetalleDonacion det : d.getDetalles()) {
                String clave = det.getAsociacion().getId() + "|" + d.getMoneda().getId();
                TotalAsociacion total = totales.get(clave);
                if (total == null) {
                    total = new TotalAsociacion();
                    total.setAsociacion(det.getAsociacion());
                    total.setMoneda(d.getMoneda());
                    totales.put(clave, total);
                }
                total.setTotal(total.getTotal().add(det.getMonto()));
                total.setCantidadDonaciones(total.getCantidadDonaciones() + 1);
            }
        }
        List<TotalAsociacion> resultado = new ArrayList<>(totales.values());
        Collator orden = Collator.getInstance(Locale.forLanguageTag("es"));
        resultado.sort((a, b) -> {
            int porNombre = orden.compare(a.getAsociacion().getNombre(), b.getAsociacion().getNombre());
            return porNombre != 0 ? porNombre : orden.compare(a.getMoneda().getNombre(), b.getMoneda().getNombre());
        });
        return resultado;
    }

    @Override
    public List<Mascota> listarRecompensasDisponibles() {
        List<Mascota> disponibles = new ArrayList<>();
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if (m.getMontoRecompensa() != null && m.getMonedaRecompensa() != null && !fueDonada(m.getId())) {
                disponibles.add(m);
            }
        }
        Collator orden = Collator.getInstance(Locale.forLanguageTag("es"));
        disponibles.sort((a, b) -> orden.compare(nombre(a), nombre(b)));
        return disponibles;
    }

    @Override
    public Donacion obtener(int idDonacion) {
        for (Donacion d : donaciones) {
            if (d.getId() == idDonacion) {
                return copiar(d);
            }
        }
        throw new IllegalStateException("No existe la donación con id " + idDonacion);
    }

    // ------------------------------------------------------------------------
    // ------------------------ Registro y corrección -------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Donacion donacion) {
        donacion.setId(siguienteId);
        siguienteId++;
        donaciones.add(donacion);
        return donacion.getId();
    }

    @Override
    public void actualizarMonto(Donacion datos) {
        for (Donacion d : donaciones) {
            if (d.getId() == datos.getId()) {
                // Lo que haría el trigger de auditoría del monto (requisito 7).
                if (bitacora != null) {
                    bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_DONACION, "Monto total", d.getId(),
                            d.getMontoTotal(), datos.getMontoTotal(),
                            "Corrección del monto de la donación " + d.getId()
                                    + " (" + d.getMoneda().getNombre() + ").");
                }
                d.setMontoTotal(datos.getMontoTotal());
                for (DetalleDonacion nuevo : datos.getDetalles()) {
                    for (DetalleDonacion actual : d.getDetalles()) {
                        if (actual.getAsociacion().equals(nuevo.getAsociacion())) {
                            actual.setMonto(nuevo.getMonto());
                        }
                    }
                }
                return;
            }
        }
        throw new IllegalStateException("No existe la donación con id " + datos.getId());
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    private boolean fueDonada(int idMascota) {
        for (Donacion d : donaciones) {
            if (d.getMascota() != null && d.getMascota().getId() == idMascota) {
                return true;
            }
        }
        return false;
    }

    private String nombre(Mascota m) {
        return m.getNombre() == null ? "" : m.getNombre();
    }

    private FilaDonacion crearFila(Donacion d, DetalleDonacion det) {
        FilaDonacion fila = new FilaDonacion();
        fila.setIdDonacion(d.getId());
        fila.setFecha(d.getFecha());
        fila.setNombreDonador(d.getNombreDonador());
        fila.setTipo(d.getTipo());
        fila.setMoneda(d.getMoneda());
        fila.setAsociacion(det.getAsociacion());
        fila.setPorcentaje(det.getPorcentaje());
        fila.setMonto(det.getMonto());
        fila.setMontoTotalDonacion(d.getMontoTotal());
        if (d.getMascota() != null) {
            fila.setNombreMascota(nombre(d.getMascota()));
        }
        return fila;
    }

    private Donacion copiar(Donacion o) {
        Donacion c = new Donacion();
        c.setId(o.getId());
        c.setTipo(o.getTipo());
        c.setIdPersonaDonador(o.getIdPersonaDonador());
        c.setNombreDonador(o.getNombreDonador());
        c.setMoneda(o.getMoneda());
        c.setMascota(o.getMascota());
        c.setMontoTotal(o.getMontoTotal());
        c.setFecha(o.getFecha());
        for (DetalleDonacion det : o.getDetalles()) {
            DetalleDonacion copia = new DetalleDonacion(det.getAsociacion(), det.getPorcentaje());
            copia.setMonto(det.getMonto());
            c.getDetalles().add(copia);
        }
        return c;
    }

    private boolean cumpleFiltro(Donacion d, DetalleDonacion det, FiltroDonacion f) {
        BigDecimal monto = det.getMonto();
        return contiene(d.getNombreDonador(), f.getDonador())
                && (f.getAsociacion() == null || f.getAsociacion().equals(det.getAsociacion()))
                && (f.getMontoMinimo() == null || monto.compareTo(f.getMontoMinimo()) >= 0)
                && (f.getMontoMaximo() == null || monto.compareTo(f.getMontoMaximo()) <= 0)
                && dentroDelRango(d.getFecha(), f.getFechaDesde(), f.getFechaHasta());
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
}
