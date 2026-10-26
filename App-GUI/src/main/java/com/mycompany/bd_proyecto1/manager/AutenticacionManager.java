package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.dao.UsuarioDAO;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;

/**
 * Lógica de negocio del inicio de sesión.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class AutenticacionManager {

    private final UsuarioDAO usuarioDAO;

    public AutenticacionManager() {
        this(Repositorios.usuarios());
    }

    public AutenticacionManager(UsuarioDAO usuarioDAO) {
        this.usuarioDAO = usuarioDAO;
    }

    /** Valida las credenciales e inicia la sesión si son correctas. */
    public Usuario iniciarSesion(String nombreUsuario, String contrasena) {
        validarCampos(nombreUsuario, contrasena);

        Usuario usuario = usuarioDAO.autenticar(nombreUsuario.trim(), contrasena)
                .orElseThrow(() -> new IllegalArgumentException("Usuario o contraseña incorrectos."));

        Sesion.iniciar(usuario);
        return usuario;
    }

    /** Cierra la sesión activa. */
    public void cerrarSesion() {
        Sesion.cerrar();
    }

    private void validarCampos(String nombreUsuario, String contrasena) {
        if (estaVacio(nombreUsuario) && estaVacio(contrasena)) {
            throw new IllegalArgumentException("Ingrese el usuario y la contraseña.");
        }
        if (estaVacio(nombreUsuario)) {
            throw new IllegalArgumentException("Ingrese el usuario.");
        }
        if (estaVacio(contrasena)) {
            throw new IllegalArgumentException("Ingrese la contraseña.");
        }
    }

    private boolean estaVacio(String texto) {
        return texto == null || texto.isBlank();
    }
}
