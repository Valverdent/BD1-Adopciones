package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.dao.UsuarioDAO;
import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.NuevoUsuario;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.PerfilInterfaz;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.util.List;

/**
 * Lógica de negocio de la administración de cuentas de usuario.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class UsuarioManager {

    public static final int MAX_NOMBRE = 30;
    public static final int MIN_USUARIO = 4;
    public static final int MAX_USUARIO = 50;
    public static final int MIN_CONTRASENA = 6;
    public static final int MAX_CONTRASENA = 50;

    private static final String PATRON_USUARIO = "^[A-Za-z0-9._-]+$";

    private final UsuarioDAO usuarioDAO;
    private final UbicacionManager ubicacionManager = new UbicacionManager();

    public UsuarioManager() {
        this(Repositorios.usuarios());
    }

    public UsuarioManager(UsuarioDAO usuarioDAO) {
        this.usuarioDAO = usuarioDAO;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    /** Todas las cuentas, activas e inactivas. */
    public List<CuentaUsuario> listar() {
        exigirAdministrador();
        return usuarioDAO.listar();
    }

    // ------------------------------------------------------------------------
    // -------------------------- Creación y cambios --------------------------
    // ------------------------------------------------------------------------

    /** Valida y crea la persona y su cuenta. */
    public int crear(NuevoUsuario nuevo, String confirmacion) {
        exigirAdministrador();

        nuevo.setNombre(Validador.limpiar(nuevo.getNombre()));
        nuevo.setSegundoNombre(Validador.limpiar(nuevo.getSegundoNombre()));
        nuevo.setPrimerApellido(Validador.limpiar(nuevo.getPrimerApellido()));
        nuevo.setSegundoApellido(Validador.limpiar(nuevo.getSegundoApellido()));
        nuevo.setTelefono(Validador.limpiar(nuevo.getTelefono()));
        nuevo.setCorreo(Validador.limpiar(nuevo.getCorreo()));
        nuevo.setNombreUsuario(Validador.limpiar(nuevo.getNombreUsuario()));

        exigir(nuevo.getNombre(), "el nombre", MAX_NOMBRE);
        opcional(nuevo.getSegundoNombre(), "El segundo nombre", MAX_NOMBRE);
        exigir(nuevo.getPrimerApellido(), "el primer apellido", MAX_NOMBRE);
        opcional(nuevo.getSegundoApellido(), "El segundo apellido", MAX_NOMBRE);
        nuevo.setUbicacion(ubicacionManager.validar(nuevo.getUbicacion(), true, "lugar de residencia"));

        if (nuevo.getTelefono() == null || !Validador.esTelefonoValido(nuevo.getTelefono())) {
            throw new IllegalArgumentException("El teléfono no es válido (use 8 dígitos, por ejemplo 8888-1111).");
        }
        if (nuevo.getCorreo() == null || !Validador.esCorreoValido(nuevo.getCorreo())) {
            throw new IllegalArgumentException("El correo electrónico no es válido.");
        }
        nuevo.setCorreo(nuevo.getCorreo().toLowerCase());

        validarNombreUsuario(nuevo.getNombreUsuario());
        validarContrasena(nuevo.getContrasena(), confirmacion);
        if (nuevo.getPerfil() == null) {
            throw new IllegalArgumentException("Seleccione el rol de la cuenta.");
        }

        if (usuarioDAO.existeNombreUsuario(nuevo.getNombreUsuario())) {
            throw new IllegalArgumentException("Ya existe una cuenta con el usuario «" + nuevo.getNombreUsuario() + "».");
        }
        if (usuarioDAO.existeCorreo(nuevo.getCorreo())) {
            throw new IllegalArgumentException("El correo " + nuevo.getCorreo() + " ya está registrado.");
        }
        if (usuarioDAO.existeTelefono(nuevo.getTelefono())) {
            throw new IllegalArgumentException("El teléfono " + nuevo.getTelefono() + " ya está registrado.");
        }
        return usuarioDAO.crear(nuevo);
    }

    /** Cambia el rol de una cuenta. */
    public void cambiarPerfil(CuentaUsuario cuenta, PerfilInterfaz perfil) {
        Usuario actual = exigirAdministrador();
        exigirCuenta(cuenta);
        if (perfil == null) {
            throw new IllegalArgumentException("Seleccione el nuevo rol.");
        }
        if (cuenta.getIdUsuario() == actual.getIdUsuario()) {
            throw new IllegalStateException("No puede cambiar el rol de su propia cuenta.");
        }
        if (cuenta.getPerfil() == perfil) {
            throw new IllegalArgumentException("La cuenta ya tiene el rol " + perfil.getDescripcion() + ".");
        }
        usuarioDAO.cambiarPerfil(cuenta.getIdUsuario(), perfil);
    }

    /** Activa una cuenta inactiva o desactiva una activa. */
    public void cambiarEstado(CuentaUsuario cuenta) {
        Usuario actual = exigirAdministrador();
        exigirCuenta(cuenta);
        if (cuenta.getIdUsuario() == actual.getIdUsuario()) {
            throw new IllegalStateException("No puede desactivar su propia cuenta.");
        }
        usuarioDAO.cambiarEstado(cuenta.getIdUsuario(), !cuenta.isActivo());
    }

    /** true si la cuenta es la de quien inició sesión (la pantalla desactiva sus botones). */
    public boolean esCuentaPropia(CuentaUsuario cuenta) {
        Usuario actual = Sesion.getUsuario();
        return actual != null && cuenta != null && cuenta.getIdUsuario() == actual.getIdUsuario();
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Validaciones -----------------------------
    // ------------------------------------------------------------------------

    private void validarNombreUsuario(String nombreUsuario) {
        if (nombreUsuario == null) {
            throw new IllegalArgumentException("Indique el nombre de usuario.");
        }
        if (nombreUsuario.length() < MIN_USUARIO || nombreUsuario.length() > MAX_USUARIO) {
            throw new IllegalArgumentException("El usuario debe tener entre " + MIN_USUARIO + " y "
                    + MAX_USUARIO + " caracteres.");
        }
        if (!nombreUsuario.matches(PATRON_USUARIO)) {
            throw new IllegalArgumentException("El usuario solo puede tener letras sin tilde, números, punto, guion y guion bajo (sin espacios).");
        }
    }

    private void validarContrasena(String contrasena, String confirmacion) {
        if (Validador.estaVacio(contrasena)) {
            throw new IllegalArgumentException("Indique la contraseña.");
        }
        if (contrasena.length() < MIN_CONTRASENA || contrasena.length() > MAX_CONTRASENA) {
            throw new IllegalArgumentException("La contraseña debe tener entre " + MIN_CONTRASENA + " y "
                    + MAX_CONTRASENA + " caracteres.");
        }
        if (!contrasena.equals(contrasena.trim())) {
            throw new IllegalArgumentException("La contraseña no puede empezar ni terminar con espacios.");
        }
        if (!contrasena.equals(confirmacion)) {
            throw new IllegalArgumentException("La contraseña y su confirmación no coinciden.");
        }
    }

    private Usuario exigirAdministrador() {
        Usuario actual = Sesion.getUsuario();
        if (actual == null || !actual.esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede gestionar usuarios.");
        }
        return actual;
    }

    private void exigirCuenta(CuentaUsuario cuenta) {
        if (cuenta == null) {
            throw new IllegalArgumentException("Seleccione una cuenta de la tabla.");
        }
    }

    private void exigir(String valor, String campo, int max) {
        if (valor == null) {
            throw new IllegalArgumentException("Indique " + campo + ".");
        }
        if (valor.length() > max) {
            throw new IllegalArgumentException(campo.substring(0, 1).toUpperCase() + campo.substring(1)
                    + " no puede superar los " + max + " caracteres.");
        }
    }

    private void opcional(String valor, String campo, int max) {
        if (valor != null && valor.length() > max) {
            throw new IllegalArgumentException(campo + " no puede superar los " + max + " caracteres.");
        }
    }
}
