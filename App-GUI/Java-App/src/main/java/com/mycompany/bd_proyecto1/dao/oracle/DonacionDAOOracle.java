package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.DonacionDAO;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.DetalleDonacion;
import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.TipoDonacion;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.Collator;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Implementación de DonacionDAO con Oracle (paquete PKG_ADMINISTRATION_DONATION_ASSOCIATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DonacionDAOOracle implements DonacionDAO {

    private static final BigDecimal CIEN = BigDecimal.valueOf(100);

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));

    /** Una fila de PR_GET_DONATION_HISTORY. */
    private record Fila(int idDonacion, LocalDate fecha, String tipo, int idDonador, String donador,
                        int idAsociacion, String asociacion, String moneda, BigDecimal monto,
                        BigDecimal porcentaje) {
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<FilaDonacion> consultar(FiltroDonacion filtro) {
        List<Fila> filas = historial(filtro.getFechaDesde(), filtro.getFechaHasta());
        Map<Integer, BigDecimal> totales = totalesPorDonacion(filas);
        Map<Integer, Integer> partes = partesPorDonacion(filas);
        Map<String, ItemCatalogo> monedas = monedasPorNombre();

        List<FilaDonacion> resultado = new ArrayList<>();
        for (Fila f : filas) {
            boolean cumple = PersonaDAOOracle.contiene(f.donador(), filtro.getDonador())
                    && (filtro.getAsociacion() == null || filtro.getAsociacion().getId() == f.idAsociacion())
                    && (filtro.getMontoMinimo() == null || f.monto().compareTo(filtro.getMontoMinimo()) >= 0)
                    && (filtro.getMontoMaximo() == null || f.monto().compareTo(filtro.getMontoMaximo()) <= 0);
            if (!cumple) {
                continue;
            }
            FilaDonacion fila = new FilaDonacion();
            fila.setIdDonacion(f.idDonacion());
            fila.setFecha(f.fecha());
            fila.setNombreDonador(f.donador());
            fila.setTipo(tipoDe(f.tipo()));
            fila.setMoneda(monedas.getOrDefault(f.moneda().toLowerCase(), new ItemCatalogo(0, f.moneda())));
            fila.setAsociacion(new AsociacionBienestar(f.idAsociacion(), f.asociacion(), null));
            // Completa a una asociación: sin porcentaje, igual que en la aplicación
            fila.setPorcentaje(partes.get(f.idDonacion()) == 1 ? null : f.porcentaje());
            fila.setMonto(f.monto());
            fila.setMontoTotalDonacion(totales.get(f.idDonacion()));
            resultado.add(fila);
        }
        return resultado;
    }

    @Override
    public List<TotalAsociacion> totalesPorAsociacion(LocalDate desde, LocalDate hasta) {
        Map<String, ItemCatalogo> monedas = monedasPorNombre();
        Map<String, TotalAsociacion> porClave = new LinkedHashMap<>();
        Map<String, Set<Integer>> donacionesPorClave = new HashMap<>();
        for (Fila f : historial(desde, hasta)) {
            String clave = f.idAsociacion() + "|" + f.moneda();
            TotalAsociacion total = porClave.get(clave);
            if (total == null) {
                total = new TotalAsociacion();
                total.setAsociacion(new AsociacionBienestar(f.idAsociacion(), f.asociacion(), null));
                total.setMoneda(monedas.getOrDefault(f.moneda().toLowerCase(), new ItemCatalogo(0, f.moneda())));
                porClave.put(clave, total);
            }
            total.setTotal(total.getTotal().add(f.monto()));
            donacionesPorClave.computeIfAbsent(clave, k -> new HashSet<>()).add(f.idDonacion());
        }
        porClave.forEach((clave, total) -> total.setCantidadDonaciones(donacionesPorClave.get(clave).size()));
        List<TotalAsociacion> resultado = new ArrayList<>(porClave.values());
        resultado.sort((a, b) -> ordenEspanol.compare(a.getAsociacion().getNombre(), b.getAsociacion().getNombre()));
        return resultado;
    }

    @Override
    public List<Mascota> listarRecompensasDisponibles() {
        // Mascotas con recompensa. No se pueden quitar las ya donadas: el historial de
        // donaciones no trae la recompensa (pendiente con el equipo de base de datos).
        List<Mascota> conRecompensa = new ArrayList<>();
        for (Mascota m : new MascotaDAOOracle().consultar(new FiltroMascota())) {
            if (m.getMontoRecompensa() != null && m.getMonedaRecompensa() != null) {
                conRecompensa.add(m);
            }
        }
        conRecompensa.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return conRecompensa;
    }

    @Override
    public Donacion obtener(int idDonacion) {
        List<Fila> partes = historial(null, null).stream().filter(f -> f.idDonacion() == idDonacion).toList();
        if (partes.isEmpty()) {
            throw new IllegalStateException("No existe la donación con id " + idDonacion);
        }
        Fila primera = partes.get(0);
        Donacion d = new Donacion();
        d.setId(idDonacion);
        d.setFecha(primera.fecha());
        d.setTipo(tipoDe(primera.tipo()));
        d.setIdPersonaDonador(primera.idDonador());
        d.setNombreDonador(primera.donador());
        d.setMoneda(monedasPorNombre().getOrDefault(primera.moneda().toLowerCase(),
                new ItemCatalogo(0, primera.moneda())));
        BigDecimal total = BigDecimal.ZERO;
        List<DetalleDonacion> detalles = new ArrayList<>();
        for (Fila f : partes) {
            DetalleDonacion detalle = new DetalleDonacion(new AsociacionBienestar(f.idAsociacion(), f.asociacion(), null),
                    partes.size() == 1 ? null : f.porcentaje());
            detalle.setMonto(f.monto());
            detalles.add(detalle);
            total = total.add(f.monto());
        }
        d.setDetalles(detalles);
        d.setMontoTotal(total);
        return d;
    }

    // ------------------------------------------------------------------------
    // ------------------------ Registro y corrección -------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Donacion d) {
        Integer idRecompensa = null;
        if (d.getTipo() == TipoDonacion.RECOMPENSA) {
            idRecompensa = new MascotaDAOOracle().idRecompensa(d.getMascota().getId());
            if (idRecompensa == null) {
                throw new IllegalArgumentException("La mascota no tiene una recompensa registrada.");
            }
        }
        // "idAsociación:porcentaje,..." (porcentajes enteros; una sola asociación recibe el 100)
        String reparto = d.getDetalles().stream()
                .map(p -> p.getAsociacion().getId() + ":"
                        + (p.getPorcentaje() == null ? CIEN : p.getPorcentaje()).toBigInteger())
                .collect(Collectors.joining(","));

        try (CallableStatement cs = preparar("{call pkg_administration_donation_association.pr_register_donation("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, d.getIdPersonaDonador());
            cs.setInt(2, idTipoDonacion(d.getTipo()));
            ponerId(cs, 3, d.getMoneda());
            ponerDecimal(cs, 4, d.getMontoTotal());
            ponerNumero(cs, 5, idRecompensa);
            ponerFecha(cs, 6, d.getFecha());
            cs.setString(7, reparto);
            cs.registerOutParameter(8, Types.NUMERIC);
            cs.registerOutParameter(9, Types.NUMERIC);
            cs.execute();
            revisar(cs, 9, "registrar la donación");
            d.setId(cs.getInt(8));
            return d.getId();
        } catch (SQLException e) {
            throw error("registrar la donación", e);
        }
    }

    @Override
    public void actualizarMonto(Donacion d) {
        try (CallableStatement cs = preparar(
                "{call pkg_administration_donation_association.pr_update_donation_amount(?, ?, ?)}")) {
            cs.setInt(1, d.getId());
            ponerDecimal(cs, 2, d.getMontoTotal());
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "cambiar el monto de la donación");
        } catch (SQLException e) {
            throw error("cambiar el monto de la donación", e);
        }
    }

    // ------------------------------------------------------------------ auxiliares

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    private List<Fila> historial(LocalDate desde, LocalDate hasta) {
        List<Fila> filas = new ArrayList<>();
        try (CallableStatement cs = preparar(
                "{call pkg_administration_donation_association.pr_get_donation_history(?, ?, ?, ?, ?)}")) {
            ponerFecha(cs, 1, desde);
            ponerFecha(cs, 2, hasta);
            cs.setNull(3, Types.NUMERIC);
            cs.setNull(4, Types.NUMERIC);
            cs.registerOutParameter(5, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 5)) {                // por fecha descendente
                while (fila.next()) {
                    filas.add(new Fila(fila.getInt("donationId"), fecha(fila, "donationDate"),
                            texto(fila, "donationTypeName"), fila.getInt("donorId"), texto(fila, "donorName"),
                            fila.getInt("associationId"), texto(fila, "associationName"),
                            texto(fila, "currencyName"), decimal(fila, "amount"), decimal(fila, "percentage")));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las donaciones", e);
        }
        return filas;
    }

    private static Map<Integer, BigDecimal> totalesPorDonacion(List<Fila> filas) {
        Map<Integer, BigDecimal> totales = new HashMap<>();
        for (Fila f : filas) {
            totales.merge(f.idDonacion(), f.monto(), BigDecimal::add);
        }
        return totales;
    }

    private static Map<Integer, Integer> partesPorDonacion(List<Fila> filas) {
        Map<Integer, Integer> partes = new HashMap<>();
        for (Fila f : filas) {
            partes.merge(f.idDonacion(), 1, Integer::sum);
        }
        return partes;
    }

    /** El cursor trae el nombre de la moneda; el id se busca en el catálogo. */
    private static Map<String, ItemCatalogo> monedasPorNombre() {
        Map<String, ItemCatalogo> monedas = new HashMap<>();
        for (ItemCatalogo m : new CatalogoDAOOracle().listar(TipoCatalogo.MONEDA)) {
            monedas.put(m.getNombre().toLowerCase(), m);
        }
        return monedas;
    }

    /** Tipo de la aplicación según el nombre en la tabla DonationType ("Voluntaria" o "Recompensa"). */
    private static TipoDonacion tipoDe(String nombre) {
        for (TipoDonacion tipo : TipoDonacion.values()) {
            if (tipo.getDescripcion().equalsIgnoreCase(nombre)) {
                return tipo;
            }
        }
        return TipoDonacion.VOLUNTARIA;
    }

    private static int idTipoDonacion(TipoDonacion tipo) {
        for (ItemCatalogo t : listarItems("{call pkg_catalog.pr_get_donation_types(?)}", "name",
                "consultar los tipos de donación")) {
            if (t.getNombre().equalsIgnoreCase(tipo.getDescripcion())) {
                return t.getId();
            }
        }
        throw new IllegalStateException("No existe el tipo de donación \"" + tipo.getDescripcion()
                + "\" en la base de datos.");
    }
}
