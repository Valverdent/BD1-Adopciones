package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.ListaNegraDAO;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.DetallePersona;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

/**
 * Lógica de negocio del módulo de personas (requisitos 1 y 2 del PDF).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaManager {

    private static final int MAX_TEXTO = 50;

    private final PersonaDAO personaDAO;
    private final ListaNegraDAO listaNegraDAO;
    private final AdopcionDAO adopcionDAO;
    private final UbicacionManager ubicacionManager = new UbicacionManager();

    public PersonaManager() {
        this(Repositorios.personas(), Repositorios.listaNegra(), Repositorios.adopciones());
    }

    public PersonaManager(PersonaDAO personaDAO, ListaNegraDAO listaNegraDAO, AdopcionDAO adopcionDAO) {
        this.personaDAO = personaDAO;
        this.listaNegraDAO = listaNegraDAO;
        this.adopcionDAO = adopcionDAO;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    public List<Persona> consultar(FiltroPersona filtro) {
        return personaDAO.consultar(filtro);
    }

    public Persona obtener(int idPersona) {
        return personaDAO.obtener(idPersona);
    }

    public boolean puedeEditar(Persona persona) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || persona == null) {
            return false;
        }
        return usuario.esAdministrador() || persona.getId() == usuario.getIdPersona();
    }

    /** Persona + reportes + adopciones + calificación promedio, para la pantalla de detalle. */
    public DetallePersona obtenerDetalle(int idPersona) {
        DetallePersona detalle = new DetallePersona();
        detalle.setPersona(personaDAO.obtener(idPersona));
        detalle.setReportes(listaNegraDAO.listarReportes(idPersona));
        List<Adopcion> adopciones = adopcionDAO.listarAdopcionesDeAdoptante(idPersona);
        detalle.setAdopciones(adopciones);

        BigDecimal suma = BigDecimal.ZERO;
        int cantidad = 0;
        for (Adopcion a : adopciones) {
            if (a.getCalificacion() != null) {
                suma = suma.add(BigDecimal.valueOf(a.getCalificacion()));
                cantidad++;
            }
        }
        detalle.setCalificacionPromedio(cantidad == 0 ? null
                : suma.divide(BigDecimal.valueOf(cantidad), 2, RoundingMode.HALF_UP));
        return detalle;
    }

    // ------------------------------------------------------------------------
    // ------------------------- Teléfonos y correos --------------------------
    // ------------------------------------------------------------------------

    /** @return el teléfono limpio @throws IllegalArgumentException si no es válido */
    public String validarTelefono(String telefono) {
        String t = Validador.limpiar(telefono);
        if (t == null || !Validador.esTelefonoValido(t)) {
            throw new IllegalArgumentException("El teléfono no es válido (use 8 dígitos, por ejemplo 8888-1111).");
        }
        return t;
    }

    /** @return el correo limpio @throws IllegalArgumentException si no es válido */
    public String validarCorreo(String correo) {
        String c = Validador.limpiar(correo);
        if (c == null || !Validador.esCorreoValido(c)) {
            throw new IllegalArgumentException("El correo electrónico no es válido.");
        }
        return c;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Guardado -------------------------------
    // ------------------------------------------------------------------------

    /** Valida y guarda una persona: id 0 = nueva, otro = actualización. */
    public int guardar(Persona p) {
        if (Sesion.getUsuario() == null) {
            throw new IllegalStateException("Debe iniciar sesión.");
        }
        if (p.getId() == 0) {
            if (!Sesion.getUsuario().esAdministrador()) {
                throw new IllegalStateException("Solo un administrador puede registrar personas nuevas.");
            }
        } else if (!puedeEditar(p)) {
            throw new IllegalStateException("Solo puede editar sus propios datos (o ser administrador).");
        }

        p.setNombre(Validador.limpiar(p.getNombre()));
        p.setSegundoNombre(Validador.limpiar(p.getSegundoNombre()));
        p.setPrimerApellido(Validador.limpiar(p.getPrimerApellido()));
        p.setSegundoApellido(Validador.limpiar(p.getSegundoApellido()));

        exigir(p.getNombre(), "el nombre", MAX_TEXTO);
        exigir(p.getPrimerApellido(), "el primer apellido", MAX_TEXTO);
        opcional(p.getSegundoNombre(), "El segundo nombre", MAX_TEXTO);
        opcional(p.getSegundoApellido(), "El segundo apellido", MAX_TEXTO);
        p.setUbicacion(ubicacionManager.validar(p.getUbicacion(), true, "lugar de residencia"));

        List<String> telefonos = new ArrayList<>();
        for (String t : p.getTelefonos()) {
            String limpio = validarTelefono(t);
            if (telefonos.contains(limpio)) {
                throw new IllegalArgumentException("El teléfono " + limpio + " está repetido.");
            }
            telefonos.add(limpio);
        }
        List<String> correos = new ArrayList<>();
        for (String c : p.getCorreos()) {
            String limpio = validarCorreo(c);
            if (correos.contains(limpio.toLowerCase())) {
                throw new IllegalArgumentException("El correo " + limpio + " está repetido.");
            }
            correos.add(limpio.toLowerCase());
        }
        // La base registra a la persona con un teléfono y un correo (PR_REGISTER_PERSON)
        if (telefonos.isEmpty() || correos.isEmpty()) {
            throw new IllegalArgumentException("Indique al menos un teléfono y un correo de contacto.");
        }
        p.setTelefonos(telefonos);
        p.setCorreos(correos);

        if (p.getId() == 0) {
            return personaDAO.insertar(p);
        }
        personaDAO.actualizar(p);
        return p.getId();
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Veterinarios -----------------------------
    // ------------------------------------------------------------------------

    /** Solo el administrador registra veterinarios. */
    public boolean puedeRegistrarVeterinario() {
        return Sesion.getUsuario() != null && Sesion.getUsuario().esAdministrador();
    }

    public boolean esVeterinario(int idPersona) {
        return personaDAO.esVeterinario(idPersona);
    }

    /** Registra a una persona ya guardada como veterinaria. */
    public void registrarVeterinario(int idPersona) {
        if (!puedeRegistrarVeterinario()) {
            throw new IllegalStateException("Solo un administrador puede registrar veterinarios.");
        }
        // La base no tiene restricción única en Veterinarian.idPerson: se revisa aquí
        if (personaDAO.esVeterinario(idPersona)) {
            throw new IllegalArgumentException("Esta persona ya está registrada como veterinaria.");
        }
        personaDAO.registrarVeterinario(idPersona);
    }

    // ------------------------------------------------------------------------
    // ----------------------- Validaciones auxiliares ------------------------
    // ------------------------------------------------------------------------

    private void exigir(String valor, String campo, int max) {
        if (valor == null) {
            throw new IllegalArgumentException("Indique " + campo + ".");
        }
        if (valor.length() > max) {
            throw new IllegalArgumentException("" + campo.substring(0, 1).toUpperCase() + campo.substring(1)
                    + " no puede superar los " + max + " caracteres.");
        }
    }

    private void opcional(String valor, String campo, int max) {
        if (valor != null && valor.length() > max) {
            throw new IllegalArgumentException(campo + " no puede superar los " + max + " caracteres.");
        }
    }
}
