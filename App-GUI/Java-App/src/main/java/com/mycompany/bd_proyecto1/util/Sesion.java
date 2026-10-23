package com.mycompany.bd_proyecto1.util;

import com.mycompany.bd_proyecto1.model.Usuario;

/**
 * Guarda el usuario que inició sesión mientras la aplicación está abierta.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public final class Sesion {

    private static Usuario usuarioActual;

    private Sesion() {
        // Clase de utilidad: no se instancia.
    }

    public static void iniciar(Usuario usuario) {
        usuarioActual = usuario;
    }

    public static void cerrar() {
        usuarioActual = null;
    }

    public static boolean estaActiva() {
        return usuarioActual != null;
    }

    public static Usuario getUsuario() {
        return usuarioActual;
    }

    /** Perfil del usuario actual, o null si no hay sesión. */
    public static PerfilInterfaz getPerfil() {
        return usuarioActual == null ? null : usuarioActual.getPerfil();
    }
}
