package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.AsociacionDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.DonacionDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.DetalleDonacion;
import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.TipoDonacion;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Lógica de negocio de donaciones y asociaciones (requisitos 4.h, 4.i y 5.b).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DonacionManager {

    /** Texto que ve en lugar del donador quien no es administrador. */
    public static final String DONADOR_OCULTO = "Anónimo";

    private static final BigDecimal CIEN = new BigDecimal("100");
    private static final int LARGO_MAXIMO_NOMBRE = 100;
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final DonacionDAO donacionDAO;
    private final AsociacionDAO asociacionDAO;
    private final CatalogoDAO catalogoDAO;
    private final UbicacionManager ubicacionManager;

    public DonacionManager() {
        this(Repositorios.donaciones(), Repositorios.asociaciones(), Repositorios.catalogos());
    }

    public DonacionManager(DonacionDAO donacionDAO, AsociacionDAO asociacionDAO, CatalogoDAO catalogoDAO) {
        this.donacionDAO = donacionDAO;
        this.asociacionDAO = asociacionDAO;
        this.catalogoDAO = catalogoDAO;
        this.ubicacionManager = new UbicacionManager(catalogoDAO);
    }

    // ------------------------------------------------------------------------
    // ------------------------- Catálogos y permisos -------------------------
    // ------------------------------------------------------------------------

    public boolean esAdministrador() {
        Usuario usuario = Sesion.getUsuario();
        return usuario != null && usuario.esAdministrador();
    }

    public List<ItemCatalogo> listarMonedas() {
        return catalogoDAO.listar(TipoCatalogo.MONEDA);
    }

    public List<AsociacionBienestar> listarAsociaciones() {
        return asociacionDAO.listar();
    }

    /**
     * Recompensas que el usuario en sesión puede donar: todas las disponibles para el
     * administrador; solo las de sus mascotas para el usuario común.
     */
    public List<Mascota> listarRecompensasDisponibles() {
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : donacionDAO.listarRecompensasDisponibles()) {
            if (puedeDonarRecompensa(m)) {
                resultado.add(m);
            }
        }
        return resultado;
    }

    private boolean puedeDonarRecompensa(Mascota mascota) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || mascota == null) {
            return false;
        }
        return usuario.esAdministrador() || mascota.getIdPersonaRegistro() == usuario.getIdPersona();
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Asociaciones -----------------------------
    // ------------------------------------------------------------------------

    /** Valida y guarda una asociación. Si su id es 0 la registra como nueva. */
    public int guardarAsociacion(AsociacionBienestar asociacion) {
        if (!esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede administrar las asociaciones.");
        }
        asociacion.setNombre(Validador.limpiar(asociacion.getNombre()));

        if (asociacion.getNombre() == null) {
            throw new IllegalArgumentException("Indique el nombre de la asociación.");
        }
        if (asociacion.getNombre().length() > LARGO_MAXIMO_NOMBRE) {
            throw new IllegalArgumentException("El nombre de la asociación admite como máximo "
                    + LARGO_MAXIMO_NOMBRE + " caracteres.");
        }
        asociacion.setUbicacion(ubicacionManager.validar(asociacion.getUbicacion(), true, "ubicación de la asociación"));
        if (asociacionDAO.existeNombre(asociacion.getNombre(), asociacion.getId())) {
            throw new IllegalArgumentException("Ya existe una asociación con ese nombre.");
        }

        if (asociacion.getId() == 0) {
            return asociacionDAO.insertar(asociacion);
        }
        asociacionDAO.actualizar(asociacion);
        return asociacion.getId();
    }

    // ------------------------------------------------------------------------
    // ------------------ Conversión y validación de montos -------------------
    // ------------------------------------------------------------------------

    /** Convierte el texto de un monto de donación. */
    public BigDecimal convertirMonto(String texto) {
        if (Validador.estaVacio(texto)) {
            throw new IllegalArgumentException("Indique el monto de la donación.");
        }
        BigDecimal monto = convertirNumero(texto, "El monto debe ser un número entero, por ejemplo 25000.");
        validarMonto(monto);
        return monto;
    }

    /** Convierte el texto de un monto usado como criterio de búsqueda. Vacío significa sin criterio. */
    public BigDecimal convertirMontoDeBusqueda(String texto) {
        if (Validador.estaVacio(texto)) {
            return null;
        }
        BigDecimal monto = convertirNumero(texto, "Los montos de búsqueda deben ser números, por ejemplo 25000.");
        if (monto.signum() < 0) {
            throw new IllegalArgumentException("Los montos de búsqueda no pueden ser negativos.");
        }
        return monto;
    }

    /** Convierte el texto de un porcentaje del reparto (mayor que 0 y hasta 100). */
    public BigDecimal convertirPorcentaje(String texto) {
        if (Validador.estaVacio(texto)) {
            throw new IllegalArgumentException("Indique el porcentaje de la asociación.");
        }
        BigDecimal porcentaje = convertirNumero(texto, "El porcentaje debe ser un número entero, por ejemplo 60 o 40.");
        validarPorcentaje(porcentaje);
        return porcentaje;
    }

    private BigDecimal convertirNumero(String texto, String mensajeError) {
        try {
            return new BigDecimal(texto.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(mensajeError);
        }
    }

    private void validarMonto(BigDecimal monto) {
        if (monto == null || monto.signum() <= 0) {
            throw new IllegalArgumentException("El monto de la donación debe ser mayor que cero.");
        }
        // La base guarda los montos sin decimales (DonationDetail.amount es NUMBER(9))
        if (monto.stripTrailingZeros().scale() > 0) {
            throw new IllegalArgumentException("El monto de la donación debe ser un número entero, sin decimales.");
        }
    }

    private void validarPorcentaje(BigDecimal porcentaje) {
        if (porcentaje.signum() <= 0 || porcentaje.compareTo(CIEN) > 0) {
            throw new IllegalArgumentException("El porcentaje debe ser mayor que 0 y no puede pasar de 100.");
        }
        // La base guarda los porcentajes sin decimales (DonationDetail.percentage es NUMBER(3))
        if (porcentaje.stripTrailingZeros().scale() > 0) {
            throw new IllegalArgumentException("El porcentaje debe ser un número entero, sin decimales.");
        }
    }

    /** Suma los porcentajes del reparto (los detalles sin porcentaje no suman). */
    public BigDecimal sumaPorcentajes(List<DetalleDonacion> detalles) {
        BigDecimal suma = BigDecimal.ZERO;
        for (DetalleDonacion d : detalles) {
            if (d.getPorcentaje() != null) {
                suma = suma.add(d.getPorcentaje());
            }
        }
        return suma;
    }

    // ------------------------------------------------------------------------
    // ------------------------- Consultas y totales --------------------------
    // ------------------------------------------------------------------------

    /**
     * Consulta las donaciones (requisito 5.b), de la más reciente a la más antigua. Quien no es
     * administrador no puede buscar por donador y ve "Anónimo" en lugar del nombre.
     */
    public List<FilaDonacion> consultar(FiltroDonacion filtro) {
        validarRangoFechas(filtro.getFechaDesde(), filtro.getFechaHasta());
        if (filtro.getMontoMinimo() != null && filtro.getMontoMaximo() != null
                && filtro.getMontoMinimo().compareTo(filtro.getMontoMaximo()) > 0) {
            throw new IllegalArgumentException("El monto mínimo no puede ser mayor que el monto máximo.");
        }

        boolean admin = esAdministrador();
        if (!admin) {
            filtro.setDonador(null);
        }
        List<FilaDonacion> filas = donacionDAO.consultar(filtro);
        if (!admin) {
            for (FilaDonacion fila : filas) {
                fila.setNombreDonador(DONADOR_OCULTO);
            }
        }
        return filas;
    }

    /** Suma los montos de las filas, separados por moneda (requisito 5.f). */
    public Map<String, BigDecimal> totalMontosPorMoneda(List<FilaDonacion> filas) {
        Map<String, BigDecimal> totales = new LinkedHashMap<>();
        for (FilaDonacion fila : filas) {
            String moneda = fila.getMoneda().getNombre();
            totales.put(moneda, totales.getOrDefault(moneda, BigDecimal.ZERO).add(fila.getMonto()));
        }
        return totales;
    }

    /** Total donado a cada asociación en un rango de fechas (opcional). */
    public List<TotalAsociacion> totalesPorAsociacion(LocalDate desde, LocalDate hasta) {
        validarRangoFechas(desde, hasta);
        return donacionDAO.totalesPorAsociacion(desde, hasta);
    }

    /** Suma los totales de todas las asociaciones, separados por moneda. */
    public Map<String, BigDecimal> totalGeneralPorMoneda(List<TotalAsociacion> totales) {
        Map<String, BigDecimal> resultado = new LinkedHashMap<>();
        for (TotalAsociacion t : totales) {
            String moneda = t.getMoneda().getNombre();
            resultado.put(moneda, resultado.getOrDefault(moneda, BigDecimal.ZERO).add(t.getTotal()));
        }
        return resultado;
    }

    private void validarRangoFechas(LocalDate desde, LocalDate hasta) {
        if (desde != null && hasta != null && desde.isAfter(hasta)) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------ Registro de donaciones ------------------------
    // ------------------------------------------------------------------------

    /** Valida y registra una donación con su reparto. */
    public int registrarDonacion(Donacion donacion) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null) {
            throw new IllegalStateException("Debe iniciar sesión para donar.");
        }
        if (donacion.getTipo() == null) {
            throw new IllegalArgumentException("Seleccione el tipo de donación.");
        }

        if (donacion.getTipo() == TipoDonacion.RECOMPENSA) {
            prepararRecompensa(donacion);
        } else {
            prepararVoluntaria(donacion, usuario);
        }
        validarFecha(donacion);
        validarReparto(donacion.getDetalles());
        calcularReparto(donacion.getMontoTotal(), donacion.getDetalles());
        return donacionDAO.insertar(donacion);
    }

    private void prepararVoluntaria(Donacion d, Usuario usuario) {
        d.setMascota(null);
        d.setIdPersonaDonador(usuario.getIdPersona());
        d.setNombreDonador(usuario.getNombreCompleto());
        if (d.getMoneda() == null) {
            throw new IllegalArgumentException("Seleccione la moneda de la donación.");
        }
        validarMonto(d.getMontoTotal());
    }

    private void prepararRecompensa(Donacion d) {
        if (d.getMascota() == null) {
            throw new IllegalArgumentException("Seleccione la mascota cuya recompensa desea donar.");
        }
        Mascota mascota = null;
        for (Mascota m : donacionDAO.listarRecompensasDisponibles()) {
            if (m.getId() == d.getMascota().getId()) {
                mascota = m;
            }
        }
        if (mascota == null) {
            throw new IllegalArgumentException("Esa recompensa no está disponible (la mascota no tiene recompensa o ya fue donada).");
        }
        if (!puedeDonarRecompensa(mascota)) {
            throw new IllegalStateException("Solo puede donar la recompensa de las mascotas que usted registró.");
        }
        d.setMascota(mascota);
        d.setIdPersonaDonador(mascota.getIdPersonaRegistro());
        d.setNombreDonador(mascota.getNombrePersonaRegistro());
        d.setMontoTotal(mascota.getMontoRecompensa());
        d.setMoneda(mascota.getMonedaRecompensa());
    }

    private void validarFecha(Donacion d) {
        if (d.getFecha() == null) {
            throw new IllegalArgumentException("Indique la fecha de la donación.");
        }
        if (d.getFecha().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("La fecha de la donación no puede ser futura.");
        }
        if (d.getMascota() != null && d.getFecha().isBefore(d.getMascota().getFechaEvento())) {
            throw new IllegalArgumentException("La fecha de la donación no puede ser anterior al "
                    + d.getMascota().getFechaEvento().format(FORMATO_FECHA)
                    + ", fecha en que se registró la mascota.");
        }
    }

    /**
     * Revisa el reparto: una sola asociación sin porcentaje, o varias (o una) con porcentajes que
     * suman exactamente 100.
     */
    private void validarReparto(List<DetalleDonacion> detalles) {
        if (detalles.isEmpty()) {
            throw new IllegalArgumentException("Seleccione al menos una asociación beneficiaria.");
        }
        Set<AsociacionBienestar> sinRepetir = new HashSet<>();
        for (DetalleDonacion d : detalles) {
            if (d.getAsociacion() == null) {
                throw new IllegalArgumentException("Seleccione la asociación beneficiaria.");
            }
            if (!sinRepetir.add(d.getAsociacion())) {
                throw new IllegalArgumentException("La asociación \"" + d.getAsociacion().getNombre()
                        + "\" aparece repetida en el reparto.");
            }
        }

        // Una sola asociación que recibe todo: no lleva porcentaje.
        if (detalles.size() == 1 && detalles.get(0).getPorcentaje() == null) {
            return;
        }
        for (DetalleDonacion d : detalles) {
            if (d.getPorcentaje() == null) {
                throw new IllegalArgumentException("Indique el porcentaje de cada asociación del reparto.");
            }
            validarPorcentaje(d.getPorcentaje());
        }
        BigDecimal suma = sumaPorcentajes(detalles);
        if (suma.compareTo(CIEN) != 0) {
            throw new IllegalArgumentException("Los porcentajes deben sumar exactamente 100 (ahora suman "
                    + suma.stripTrailingZeros().toPlainString() + ").");
        }
    }

    /** Calcula el monto de cada asociación a partir del total. */
    public void calcularReparto(BigDecimal total, List<DetalleDonacion> detalles) {
        if (detalles.size() == 1) {
            detalles.get(0).setMonto(total);
            return;
        }
        BigDecimal acumulado = BigDecimal.ZERO;
        for (int i = 0; i < detalles.size() - 1; i++) {
            DetalleDonacion d = detalles.get(i);
            BigDecimal monto = total.multiply(d.getPorcentaje()).divide(CIEN, 0, RoundingMode.HALF_UP);
            d.setMonto(monto);
            acumulado = acumulado.add(monto);
        }
        detalles.get(detalles.size() - 1).setMonto(total.subtract(acumulado));

        for (DetalleDonacion d : detalles) {
            if (d.getMonto().signum() <= 0) {
                throw new IllegalArgumentException("El monto es muy pequeño para repartirlo con esos porcentajes.");
            }
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------- Corrección de montos -------------------------
    // ------------------------------------------------------------------------

    /**
     * Corrige el monto total de una donación y recalcula su reparto con los mismos porcentajes.
     * Solo el administrador; el cambio queda en la bitácora (trigger de la base de datos).
     */
    public void corregirMonto(int idDonacion, BigDecimal nuevoMonto) {
        if (!esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede corregir el monto de una donación.");
        }
        validarMonto(nuevoMonto);
        Donacion donacion = donacionDAO.obtener(idDonacion);
        donacion.setMontoTotal(nuevoMonto);
        calcularReparto(nuevoMonto, donacion.getDetalles());
        donacionDAO.actualizarMonto(donacion);
    }
}
