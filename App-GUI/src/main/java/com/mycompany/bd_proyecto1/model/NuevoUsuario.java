package com.mycompany.bd_proyecto1.model;

import com.mycompany.bd_proyecto1.util.PerfilInterfaz;

/**
 * Datos que escribe el administrador para crear una cuenta.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class NuevoUsuario {

    private String nombre;
    private String segundoNombre;
    private String primerApellido;
    private String segundoApellido;
    /** Lugar de residencia (distrito + señas), igual que en Personas. */
    private Ubicacion ubicacion;
    private String telefono;
    private String correo;
    private String nombreUsuario;
    private String contrasena;
    private PerfilInterfaz perfil;

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getSegundoNombre() { return segundoNombre; }
    public void setSegundoNombre(String segundoNombre) { this.segundoNombre = segundoNombre; }

    public String getPrimerApellido() { return primerApellido; }
    public void setPrimerApellido(String primerApellido) { this.primerApellido = primerApellido; }

    public String getSegundoApellido() { return segundoApellido; }
    public void setSegundoApellido(String segundoApellido) { this.segundoApellido = segundoApellido; }

    public Ubicacion getUbicacion() { return ubicacion; }
    public void setUbicacion(Ubicacion ubicacion) { this.ubicacion = ubicacion; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }

    public PerfilInterfaz getPerfil() { return perfil; }
    public void setPerfil(PerfilInterfaz perfil) { this.perfil = perfil; }
}
