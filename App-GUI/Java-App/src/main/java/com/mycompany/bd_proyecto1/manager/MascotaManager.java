package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MedicamentoTratamiento;
import com.mycompany.bd_proyecto1.model.TratamientoEnfermedad;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Lógica de negocio del módulo de mascotas (requisitos 4.a a 4.d, 4.k, 4.m).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaManager {

    /**
     * Edad estimada máxima que se acepta, en años. Es una regla de validación (evita errores de
     * digitación): la base no tiene un parámetro para esto.
     */
    private static final int EDAD_MAXIMA = 50;

    /** Largos de las columnas de la tabla Pet y Photo en la base. */
    private static final int MAX_NOMBRE = 30;
    private static final int MAX_DESCRIPCION = 255;
    private static final int MAX_URL_FOTO = 2048;

    private final MascotaDAO mascotaDAO;
    private final CatalogoDAO catalogoDAO;
    private final UbicacionManager ubicacionManager;

    public MascotaManager() {
        this(Repositorios.mascotas(), Repositorios.catalogos());
    }

    public MascotaManager(MascotaDAO mascotaDAO, CatalogoDAO catalogoDAO) {
        this.mascotaDAO = mascotaDAO;
        this.catalogoDAO = catalogoDAO;
        this.ubicacionManager = new UbicacionManager(catalogoDAO);
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Catálogos -------------------------------
    // ------------------------------------------------------------------------

    public List<ItemCatalogo> listarCatalogo(TipoCatalogo tipo) {
        return catalogoDAO.listar(tipo);
    }

    /** Razas del tipo indicado; lista vacía si no hay tipo seleccionado. */
    public List<ItemCatalogo> listarRazas(ItemCatalogo tipo) {
        return tipo == null ? List.of() : catalogoDAO.listarRazas(tipo.getId());
    }

    /** Tratamientos (con medicamentos) de una enfermedad; se derivan de ella. */
    public List<TratamientoEnfermedad> listarTratamientos(ItemCatalogo enfermedad) {
        return enfermedad == null ? List.of() : catalogoDAO.listarTratamientos(enfermedad.getId());
    }

    /**
     * Arma un resumen legible de los tratamientos y medicamentos de una lista de enfermedades,
     * para mostrarlo en la pantalla.
     */
    public String resumenTratamientos(List<ItemCatalogo> enfermedades) {
        if (enfermedades == null || enfermedades.isEmpty()) {
            return "Sin enfermedades registradas.";
        }
        StringBuilder texto = new StringBuilder();
        for (ItemCatalogo enfermedad : enfermedades) {
            texto.append(enfermedad.getNombre()).append(":\n");
            List<TratamientoEnfermedad> tratamientos = listarTratamientos(enfermedad);
            if (tratamientos.isEmpty()) {
                texto.append("   Sin tratamientos registrados.\n");
            }
            for (TratamientoEnfermedad t : tratamientos) {
                texto.append("   - ").append(t.getTratamiento().getNombre())
                        .append(" (").append(t.getDuracion()).append(")\n");
                for (MedicamentoTratamiento m : t.getMedicamentos()) {
                    texto.append("        ").append(m.getMedicamento().getNombre())
                            .append(": ").append(m.getDosis()).append("\n");
                }
            }
        }
        return texto.toString().trim();
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    /** Busca mascotas con los criterios indicados, de la más reciente a la más antigua. */
    public List<Mascota> consultar(FiltroMascota filtro) {
        if (filtro.getFechaDesde() != null && filtro.getFechaHasta() != null
                && filtro.getFechaDesde().isAfter(filtro.getFechaHasta())) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
        return mascotaDAO.consultar(filtro);
    }

    /** Suma las recompensas de una lista de mascotas, separadas por moneda (5.f). */
    public Map<String, BigDecimal> totalRecompensasPorMoneda(List<Mascota> mascotas) {
        Map<String, BigDecimal> totales = new LinkedHashMap<>();
        for (Mascota m : mascotas) {
            if (m.getMontoRecompensa() != null && m.getMonedaRecompensa() != null) {
                String moneda = m.getMonedaRecompensa().getNombre();
                totales.put(moneda, totales.getOrDefault(moneda, BigDecimal.ZERO).add(m.getMontoRecompensa()));
            }
        }
        return totales;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Permisos -------------------------------
    // ------------------------------------------------------------------------

    /** El administrador edita todas; el usuario común solo las que registró. */
    public boolean puedeEditar(Mascota mascota) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || mascota == null) {
            return false;
        }
        return usuario.esAdministrador() || mascota.getIdPersonaRegistro() == usuario.getIdPersona();
    }

    // ------------------------------------------------------------------------
    // ------------------------- Conversión de datos --------------------------
    // ------------------------------------------------------------------------

    /** Convierte el texto del monto de recompensa. Vacío significa sin recompensa. */
    public BigDecimal convertirMonto(String texto) {
        if (Validador.estaVacio(texto)) {
            return null;
        }
        try {
            BigDecimal monto = new BigDecimal(texto.trim());
            if (monto.signum() < 0) {
                throw new IllegalArgumentException("El monto de la recompensa no puede ser negativo.");
            }
            // La base guarda la recompensa sin decimales (Reward.amount es NUMBER(9))
            if (monto.stripTrailingZeros().scale() > 0) {
                throw new IllegalArgumentException("El monto de la recompensa debe ser un número entero, sin decimales.");
            }
            return monto;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("El monto de la recompensa debe ser un número entero, por ejemplo 25000.");
        }
    }

    /** Convierte el texto de la edad estimada en años. Vacío significa desconocida. */
    public Integer convertirEdad(String texto) {
        if (Validador.estaVacio(texto)) {
            return null;
        }
        try {
            int edad = Integer.parseInt(texto.trim());
            if (edad < 0 || edad > EDAD_MAXIMA) {
                throw new IllegalArgumentException("La edad estimada debe estar entre 0 y " + EDAD_MAXIMA + " años.");
            }
            return edad;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("La edad estimada debe ser un número entero de años (0 si es menor de un año).");
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Guardado -------------------------------
    // ------------------------------------------------------------------------

    /**
     * Valida y guarda una mascota. Si su id es 0 la registra como nueva a nombre del usuario en
     * sesión; si no, la actualiza.
     */
    public int guardar(Mascota mascota) {
        normalizarTextos(mascota);
        validar(mascota);

        if (mascota.getId() == 0) {
            Usuario usuario = Sesion.getUsuario();
            if (usuario == null) {
                throw new IllegalStateException("Debe iniciar sesión para registrar mascotas.");
            }
            mascota.setIdPersonaRegistro(usuario.getIdPersona());
            mascota.setNombrePersonaRegistro(usuario.getNombreCompleto());
            return mascotaDAO.insertar(mascota);
        }

        if (!puedeEditar(mascota)) {
            throw new IllegalStateException("Solo puede editar las mascotas que usted registró.");
        }
        mascotaDAO.actualizar(mascota);
        return mascota.getId();
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Validaciones -----------------------------
    // ------------------------------------------------------------------------

    private void normalizarTextos(Mascota m) {
        m.setNombre(Validador.limpiar(m.getNombre()));
        m.setChip(Validador.limpiar(m.getChip()));
        m.setDescripcionAbandono(Validador.limpiar(m.getDescripcionAbandono()));
        m.setNotas(Validador.limpiar(m.getNotas()));
        m.setFotoAntes(Validador.limpiar(m.getFotoAntes()));
        m.setFotoDespues(Validador.limpiar(m.getFotoDespues()));
    }

    private void validar(Mascota m) {
        requerido(m.getTipo(), "el tipo de mascota");
        requerido(m.getRaza(), "la raza");
        requerido(m.getEstado(), "el estado");
        requerido(m.getColor(), "el color");
        requerido(m.getTamano(), "el tamaño");
        requerido(m.getSeveridad(), "la severidad");
        requerido(m.getNivelEnergia(), "el nivel de energía");
        requerido(m.getFacilidadEntrenamiento(), "la facilidad de entrenamiento");

        if (m.getFechaEvento() == null) {
            throw new IllegalArgumentException("Indique la fecha del extravío o hallazgo.");
        }
        if (m.getFechaEvento().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("La fecha del extravío o hallazgo no puede ser futura.");
        }
        // Distrito y señas obligatorios: la base guarda la dirección de toda ubicación.
        m.setUbicacion(ubicacionManager.validar(m.getUbicacion(), true, "lugar del extravío o hallazgo"));

        // El contacto de la mascota es el de la persona que la registró (no se escribe aquí).

        // La base exige nombre y notas (columnas NOT NULL de Pet)
        if (m.getNombre() == null) {
            throw new IllegalArgumentException("Indique el nombre de la mascota (si no se conoce, un nombre descriptivo).");
        }
        largoMaximo(m.getNombre(), MAX_NOMBRE, "El nombre");
        if (m.getNotas() == null) {
            throw new IllegalArgumentException("Escriba las notas o descripción de la mascota.");
        }
        largoMaximo(m.getNotas(), MAX_DESCRIPCION, "Las notas");
        largoMaximo(m.getDescripcionAbandono(), MAX_DESCRIPCION, "La situación de abandono");
        validarFoto(m.getFotoAntes(), "del antes");
        validarFoto(m.getFotoDespues(), "del después");

        if (m.getChip() != null) {
            if (!Validador.esChipValido(m.getChip())) {
                throw new IllegalArgumentException("El chip solo admite letras, números y guiones (máximo 15).");
            }
            if (mascotaDAO.existeChip(m.getChip(), m.getId())) {
                throw new IllegalArgumentException("Ya existe otra mascota registrada con ese número de chip.");
            }
        }

        Set<ItemCatalogo> sinRepetir = new HashSet<>(m.getEnfermedades());
        if (sinRepetir.size() != m.getEnfermedades().size()) {
            throw new IllegalArgumentException("Hay una enfermedad repetida en la lista.");
        }

        boolean hayMonto = m.getMontoRecompensa() != null && m.getMontoRecompensa().signum() > 0;
        if (hayMonto && m.getMonedaRecompensa() == null) {
            throw new IllegalArgumentException("Indique la moneda de la recompensa.");
        }
        if (!hayMonto) {
            // Sin monto (o monto cero) no se guarda recompensa.
            m.setMontoRecompensa(null);
            m.setMonedaRecompensa(null);
        }
    }

    private static void largoMaximo(String texto, int maximo, String campo) {
        if (texto != null && texto.length() > maximo) {
            throw new IllegalArgumentException(campo + " no puede tener más de " + maximo + " caracteres.");
        }
    }

    /**
     * Las fotos se guardan como un enlace de internet (http o https) para que todos los
     * integrantes las vean, sin depender de un archivo de una computadora.
     */
    private static void validarFoto(String enlace, String cual) {
        if (enlace == null) {
            return;
        }
        if (!Validador.esEnlaceWeb(enlace)) {
            throw new IllegalArgumentException("La foto " + cual + " debe ser un enlace de internet que empiece con "
                    + "http:// o https://.");
        }
        largoMaximo(enlace, MAX_URL_FOTO, "El enlace de la foto " + cual);
    }

    private void requerido(ItemCatalogo valor, String campo) {
        if (valor == null) {
            throw new IllegalArgumentException("Seleccione " + campo + ".");
        }
    }
}
