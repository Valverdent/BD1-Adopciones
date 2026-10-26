package com.mycompany.bd_proyecto1.model;

import com.mycompany.bd_proyecto1.util.PerfilInterfaz;

/**
 * Usuario que inició sesión en la aplicación.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class Usuario {

    private final int idUsuario;
    private final int idPersona;
    private final String nombreUsuario;
    private final String nombreCompleto;
    private final PerfilInterfaz perfil;

    public Usuario(int idUsuario, int idPersona, String nombreUsuario, String nombreCompleto,
                   PerfilInterfaz perfil) {
        this.idUsuario = idUsuario;
        this.idPersona = idPersona;
        this.nombreUsuario = nombreUsuario;
        this.nombreCompleto = nombreCompleto;
        this.perfil = perfil;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public int getIdPersona() {
        return idPersona;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public PerfilInterfaz getPerfil() {
        return perfil;
    }

    public boolean esAdministrador() {
        return perfil == PerfilInterfaz.ADMINISTRADOR;
    }
}
