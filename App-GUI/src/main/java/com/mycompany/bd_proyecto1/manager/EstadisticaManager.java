package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.DonacionDAO;
import com.mycompany.bd_proyecto1.dao.EstadisticaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.ConteoMascotas;
import com.mycompany.bd_proyecto1.model.FilaPorcentaje;
import com.mycompany.bd_proyecto1.model.FilaTotalDonacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.ConteoPorCanton;
import com.mycompany.bd_proyecto1.model.TotalPorRescatista;
import com.mycompany.bd_proyecto1.model.ResumenAdopciones;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import com.mycompany.bd_proyecto1.util.Porcentajes;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Lógica de negocio de las estadísticas (requisito 8). Todos los usuarios las pueden consultar.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class EstadisticaManager {

    private final EstadisticaDAO estadisticaDAO;
    private final DonacionDAO donacionDAO;
    private final CatalogoDAO catalogoDAO;

    public EstadisticaManager() {
        this(Repositorios.estadisticas(), Repositorios.donaciones(), Repositorios.catalogos());
    }

    public EstadisticaManager(EstadisticaDAO estadisticaDAO, DonacionDAO donacionDAO, CatalogoDAO catalogoDAO) {
        this.estadisticaDAO = estadisticaDAO;
        this.donacionDAO = donacionDAO;
        this.catalogoDAO = catalogoDAO;
    }

    // ------------------------------------------------------------------------
    // ------------------- Valores por defecto y catálogos --------------------
    // ------------------------------------------------------------------------

    /** Primer día del año actual (valor por defecto de "desde" en 8.a y 8.b). */
    public LocalDate fechaDesdePorDefecto() {
        return LocalDate.of(LocalDate.now().getYear(), 1, 1);
    }

    /** Hoy (valor por defecto de "hasta" en 8.a y 8.b). */
    public LocalDate fechaHastaPorDefecto() {
        return LocalDate.now();
    }

    public List<ItemCatalogo> listarTipos() {
        return catalogoDAO.listar(TipoCatalogo.TIPO_MASCOTA);
    }

    public List<ItemCatalogo> listarRazas(ItemCatalogo tipo) {
        return tipo == null ? List.of() : catalogoDAO.listarRazas(tipo.getId());
    }

    // ------------------------------------------------------------------------
    // ---------------------- Mascotas por tipo y estado ----------------------
    // ------------------------------------------------------------------------

    /**
     * @throws IllegalArgumentException si el rango de fechas no es válido
     */
    public List<ConteoMascotas> mascotasPorTipoYEstado(LocalDate desde, LocalDate hasta) {
        validarRango(desde, hasta);
        List<ConteoMascotas> conteos = estadisticaDAO.contarMascotasPorTipoYEstado(desde, hasta);
        int total = totalMascotas(conteos);
        for (ConteoMascotas c : conteos) {
            c.setPorcentaje(Porcentajes.de(c.getCantidad(), total));
        }
        return conteos;
    }

    public int totalMascotas(List<ConteoMascotas> conteos) {
        int total = 0;
        for (ConteoMascotas c : conteos) {
            total += c.getCantidad();
        }
        return total;
    }

    // ------------------------------------------------------------------------
    // ---------------------- Donaciones por asociación -----------------------
    // ------------------------------------------------------------------------

    /** Total donado a cada asociación; el porcentaje es sobre el total de la misma moneda. */
    public List<FilaTotalDonacion> donacionesPorAsociacion(LocalDate desde, LocalDate hasta) {
        validarRango(desde, hasta);
        List<TotalAsociacion> totales = donacionDAO.totalesPorAsociacion(desde, hasta);

        Map<Integer, BigDecimal> totalPorMoneda = new LinkedHashMap<>();
        for (TotalAsociacion t : totales) {
            totalPorMoneda.merge(t.getMoneda().getId(), t.getTotal(), BigDecimal::add);
        }
        List<FilaTotalDonacion> filas = new ArrayList<>();
        for (TotalAsociacion t : totales) {
            BigDecimal porcentaje = Porcentajes.de(t.getTotal(), totalPorMoneda.get(t.getMoneda().getId()));
            filas.add(new FilaTotalDonacion(t.getAsociacion().getNombre(), t.getMoneda(), t.getTotal(),
                    t.getCantidadDonaciones(), porcentaje));
        }
        return filas;
    }

    /** Suma lo donado en cada moneda (las monedas no se suman entre sí). */
    public Map<String, BigDecimal> totalPorMoneda(List<FilaTotalDonacion> filas) {
        Map<String, BigDecimal> resultado = new LinkedHashMap<>();
        for (FilaTotalDonacion f : filas) {
            resultado.merge(f.getMoneda().getNombre(), f.getTotal(), BigDecimal::add);
        }
        return resultado;
    }

    // ------------------------------------------------------------------------
    // ------------------ Adopciones exitosas vs. en espera -------------------
    // ------------------------------------------------------------------------

    /**
     * @param tipo tipo de mascota (opcional)
     * @param raza raza (opcional; solo se puede indicar junto con un tipo y debe pertenecer a él)
     * @throws IllegalArgumentException si la raza no corresponde al tipo
     */
    public ResumenAdopciones adopciones(ItemCatalogo tipo, ItemCatalogo raza) {
        if (raza != null) {
            if (tipo == null) {
                throw new IllegalArgumentException("Para filtrar por raza, primero seleccione el tipo de mascota.");
            }
            if (!listarRazas(tipo).contains(raza)) {
                throw new IllegalArgumentException("La raza seleccionada no corresponde al tipo de mascota.");
            }
        }
        return estadisticaDAO.resumirAdopciones(tipo, raza);
    }

    // ------------------------------------------------------------------------
    // --------------- Mascotas no adoptadas por rango de edad ----------------
    // ------------------------------------------------------------------------

    /** Una fila por rango de edad con al menos una mascota no adoptada. */
    public List<FilaPorcentaje> noAdoptadasPorEdad() {
        return estadisticaDAO.contarNoAdoptadasPorEdad();
    }

    public int totalFilas(List<FilaPorcentaje> filas) {
        int total = 0;
        for (FilaPorcentaje f : filas) {
            total += f.getCantidad();
        }
        return total;
    }

    // ------------------------------------------------------------------------
    // ----------------- Estadísticas adicionales del equipo ------------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si el rango de fechas no es válido */
    public List<ConteoPorCanton> perdidasYEncontradasPorCanton(LocalDate desde, LocalDate hasta) {
        validarRango(desde, hasta);
        return estadisticaDAO.contarPerdidasYEncontradasPorCanton(desde, hasta);
    }

    /** @throws IllegalArgumentException si el rango de fechas no es válido */
    public List<TotalPorRescatista> donacionesPorRescatista(LocalDate desde, LocalDate hasta) {
        validarRango(desde, hasta);
        return estadisticaDAO.totalizarDonacionesPorRescatista(desde, hasta);
    }

    private void validarRango(LocalDate desde, LocalDate hasta) {
        if (desde != null && hasta != null && desde.isAfter(hasta)) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
    }
}
