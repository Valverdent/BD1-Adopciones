package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Lógica de negocio del módulo de adopciones (requisitos 4.f y 4.o).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionManager {

    public static final int CALIFICACION_MINIMA = 1;
    public static final int CALIFICACION_MAXIMA = 5;

    private final AdopcionDAO adopcionDAO;
    private final CatalogoDAO catalogoDAO;
    private final PersonaDAO personaDAO;

    public AdopcionManager() {
        this(Repositorios.adopciones(), Repositorios.catalogos(), Repositorios.personas());
    }

    public AdopcionManager(AdopcionDAO adopcionDAO, CatalogoDAO catalogoDAO, PersonaDAO personaDAO) {
        this.adopcionDAO = adopcionDAO;
        this.catalogoDAO = catalogoDAO;
        this.personaDAO = personaDAO;
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Catálogos -------------------------------
    // ------------------------------------------------------------------------

    public List<ItemCatalogo> listarCatalogo(TipoCatalogo tipo) {
        return catalogoDAO.listar(tipo);
    }

    public List<ItemCatalogo> listarRazas(ItemCatalogo tipo) {
        return tipo == null ? List.of() : catalogoDAO.listarRazas(tipo.getId());
    }

    public List<ItemCatalogo> listarPersonas() {
        return personaDAO.listar();
    }

    /**
     * Mascotas que el usuario en sesión puede dar en adopción: todas las disponibles para el
     * administrador; solo las propias para el usuario común.
     */
    public List<Mascota> listarMascotasDisponibles() {
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : adopcionDAO.listarMascotasDisponibles()) {
            if (puedeDarEnAdopcion(m)) {
                resultado.add(m);
            }
        }
        return resultado;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si el rango de fechas no es válido */
    public List<Adopcion> consultar(FiltroAdopcion filtro) {
        if (filtro.getFechaDesde() != null && filtro.getFechaHasta() != null
                && filtro.getFechaDesde().isAfter(filtro.getFechaHasta())) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
        return adopcionDAO.consultar(filtro);
    }

    public List<SeguimientoAdopcion> listarSeguimientos(Adopcion adopcion) {
        return adopcion == null || adopcion.getId() == 0 ? List.of() : adopcionDAO.listarSeguimientos(adopcion.getId());
    }

    /** Texto de la calificación con estrellas, por ejemplo "★★★☆☆ (3)". */
    public static String textoCalificacion(Integer calificacion) {
        if (calificacion == null) {
            return "Sin calificar";
        }
        return "★".repeat(calificacion) + "☆".repeat(CALIFICACION_MAXIMA - calificacion) + " (" + calificacion + ")";
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Permisos -------------------------------
    // ------------------------------------------------------------------------

    public boolean puedeDarEnAdopcion(Mascota mascota) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || mascota == null) {
            return false;
        }
        return usuario.esAdministrador() || mascota.getIdPersonaRegistro() == usuario.getIdPersona();
    }

    /** Editar, calificar y registrar seguimientos. */
    public boolean puedeGestionar(Adopcion adopcion) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || adopcion == null) {
            return false;
        }
        return usuario.esAdministrador() || adopcion.getIdPersonaEntrega() == usuario.getIdPersona();
    }

    // ------------------------------------------------------------------------
    // ------------------------ Guardado de adopciones ------------------------
    // ------------------------------------------------------------------------

    /**
     * Valida y guarda una adopción. Si su id es 0 la registra (y la mascota pasa a "Adoptada"); si
     * no, actualiza los datos editables.
     */
    public int guardar(Adopcion adopcion) {
        adopcion.setFotoAdoptante(Validador.limpiar(adopcion.getFotoAdoptante()));
        adopcion.setNotasCalificacion(Validador.limpiar(adopcion.getNotasCalificacion()));

        if (adopcion.getId() == 0) {
            return registrar(adopcion);
        }
        if (!puedeGestionar(adopcion)) {
            throw new IllegalStateException("Solo la persona que entregó la mascota o un administrador puede editar esta adopción.");
        }
        validarDatos(adopcion);
        LocalDate primerSeguimiento = fechaPrimerSeguimiento(adopcion);
        if (primerSeguimiento != null && adopcion.getFechaAdopcion().isAfter(primerSeguimiento)) {
            throw new IllegalArgumentException("La fecha de adopción no puede ser posterior al primer seguimiento ("
                    + primerSeguimiento.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) + ").");
        }
        adopcionDAO.actualizar(adopcion);
        return adopcion.getId();
    }

    private int registrar(Adopcion adopcion) {
        if (Sesion.getUsuario() == null) {
            throw new IllegalStateException("Debe iniciar sesión para registrar adopciones.");
        }
        Mascota mascota = adopcion.getMascota();
        if (mascota == null) {
            throw new IllegalArgumentException("Seleccione la mascota que se da en adopción.");
        }
        if (!estaDisponible(mascota)) {
            throw new IllegalArgumentException("La mascota no está disponible para adopción (debe estar \"En adopción\" y sin otra adopción).");
        }
        if (!puedeDarEnAdopcion(mascota)) {
            throw new IllegalStateException("Solo puede dar en adopción las mascotas que usted registró.");
        }

        // Quien entrega es la persona que registró la mascota.
        adopcion.setIdPersonaEntrega(mascota.getIdPersonaRegistro());
        adopcion.setNombrePersonaEntrega(mascota.getNombrePersonaRegistro());

        validarDatos(adopcion);
        return adopcionDAO.insertar(adopcion);
    }

    private boolean estaDisponible(Mascota mascota) {
        for (Mascota m : adopcionDAO.listarMascotasDisponibles()) {
            if (m.getId() == mascota.getId()) {
                return true;
            }
        }
        return false;
    }

    private void validarDatos(Adopcion a) {
        if (a.getAdoptante() == null) {
            throw new IllegalArgumentException("Seleccione el adoptante.");
        }
        if (a.getAdoptante().getId() == a.getIdPersonaEntrega()) {
            throw new IllegalArgumentException("El adoptante no puede ser la misma persona que entrega la mascota.");
        }
        if (a.getTipoVivienda() == null) {
            throw new IllegalArgumentException("Seleccione el tipo de vivienda del adoptante.");
        }
        if (a.getTiempoEjercicio() == null) {
            throw new IllegalArgumentException("Seleccione el tiempo de ejercicio que puede dar el adoptante.");
        }
        if (a.getFechaAdopcion() == null) {
            throw new IllegalArgumentException("Indique la fecha de adopción.");
        }
        if (a.getFechaAdopcion().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("La fecha de adopción no puede ser futura.");
        }
        LocalDate fechaMascota = a.getMascota() == null ? null : a.getMascota().getFechaEvento();
        if (fechaMascota != null && a.getFechaAdopcion().isBefore(fechaMascota)) {
            throw new IllegalArgumentException("La fecha de adopción no puede ser anterior a la fecha en que se registró el hallazgo o extravío de la mascota.");
        }
        Integer c = a.getCalificacion();
        if (c != null && (c < CALIFICACION_MINIMA || c > CALIFICACION_MAXIMA)) {
            throw new IllegalArgumentException("La calificación debe estar entre 1 y 5 estrellas.");
        }
        // La base exige notas en cada calificación (PetOwnerRating.notes)
        if (c != null && a.getNotasCalificacion() == null) {
            throw new IllegalArgumentException("Escriba las notas sobre los nuevos dueños para registrar la calificación.");
        }
        largoMaximo(a.getNotasCalificacion(), MAX_TEXTO, "Las notas de la calificación");
        validarFoto(a.getFotoAdoptante(), "del adoptante con la mascota");
    }

    private LocalDate fechaPrimerSeguimiento(Adopcion adopcion) {
        LocalDate primera = null;
        for (SeguimientoAdopcion s : adopcionDAO.listarSeguimientos(adopcion.getId())) {
            if (primera == null || s.getFecha().isBefore(primera)) {
                primera = s.getFecha();
            }
        }
        return primera;
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Seguimientos -----------------------------
    // ------------------------------------------------------------------------

    /** Valida y registra un seguimiento de la adopción indicada. */
    public int registrarSeguimiento(Adopcion adopcion, SeguimientoAdopcion seguimiento) {
        if (adopcion == null || adopcion.getId() == 0) {
            throw new IllegalStateException("Primero guarde la adopción para poder registrar seguimientos.");
        }
        if (!puedeGestionar(adopcion)) {
            throw new IllegalStateException("Solo la persona que entregó la mascota o un administrador puede registrar seguimientos.");
        }
        seguimiento.setComentarios(Validador.limpiar(seguimiento.getComentarios()));
        seguimiento.setFoto(Validador.limpiar(seguimiento.getFoto()));

        if (seguimiento.getComentarios() == null) {
            throw new IllegalArgumentException("Escriba el comentario del seguimiento.");
        }
        largoMaximo(seguimiento.getComentarios(), MAX_TEXTO, "El comentario");
        // La base registra cada seguimiento junto con su foto (PR_REGISTER_FOLLOW_UP)
        if (seguimiento.getFoto() == null) {
            throw new IllegalArgumentException("Indique el enlace de la foto de la nueva vida.");
        }
        validarFoto(seguimiento.getFoto(), "de la nueva vida");
        if (seguimiento.getFecha() == null) {
            throw new IllegalArgumentException("Indique la fecha del seguimiento.");
        }
        if (seguimiento.getFecha().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("La fecha del seguimiento no puede ser futura.");
        }
        if (seguimiento.getFecha().isBefore(adopcion.getFechaAdopcion())) {
            throw new IllegalArgumentException("La fecha del seguimiento no puede ser anterior a la fecha de adopción.");
        }
        seguimiento.setIdAdopcion(adopcion.getId());
        return adopcionDAO.insertarSeguimiento(seguimiento);
    }

    // ------------------------------------------------------------------------
    // --------------------------- Límites de texto ---------------------------
    // ------------------------------------------------------------------------

    /** Largo de las columnas de notas y comentarios en la base. */
    private static final int MAX_TEXTO = 255;
    private static final int MAX_URL_FOTO = 2048;

    // ------------------------------------------------------------------------
    // ----------------------- Validaciones auxiliares ------------------------
    // ------------------------------------------------------------------------

    private static void largoMaximo(String texto, int maximo, String campo) {
        if (texto != null && texto.length() > maximo) {
            throw new IllegalArgumentException(campo + " no puede tener más de " + maximo + " caracteres.");
        }
    }

    /** Las fotos se guardan como enlaces de internet (http o https). */
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
}
