package com.mycompany.bd_proyecto1.model;

import com.mycompany.bd_proyecto1.util.PerfilInterfaz;

/**
 * Fila de la pantalla de administración de usuarios: una cuenta de acceso con su persona, rol y
 * estado. No incluye la contraseña.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class CuentaUsuario {

    private final int idUsuario;
    private final int idPersona;
    private final String nombreUsuario;
    private final String nombreCompleto;
    private final PerfilInterfaz perfil;
    private final boolean activo;

    public CuentaUsuario(int idUsuario, int idPersona, String nombreUsuario, String nombreCompleto,
                         PerfilInterfaz perfil, boolean activo) {
        this.idUsuario = idUsuario;
        this.idPersona = idPersona;
        this.nombreUsuario = nombreUsuario;
        this.nombreCompleto = nombreCompleto;
        this.perfil = perfil;
        this.activo = activo;
    }

    public int getIdUsuario() { return idUsuario; }

    public int getIdPersona() { return idPersona; }

    public String getNombreUsuario() { return nombreUsuario; }

    public String getNombreCompleto() { return nombreCompleto; }

    public PerfilInterfaz getPerfil() { return perfil; }

    public boolean isActivo() { return activo; }
}
