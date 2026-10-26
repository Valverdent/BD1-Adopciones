package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.NuevoUsuario;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.PerfilInterfaz;
import java.util.List;
import java.util.Optional;

/**
 * Contrato de acceso a los datos de usuarios.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public interface UsuarioDAO {

    /** Verifica las credenciales de un usuario. */
    Optional<Usuario> autenticar(String nombreUsuario, String contrasena);

    /** Lista todas las cuentas, activas e inactivas. */
    List<CuentaUsuario> listar();

    /** Crea la persona y su cuenta de acceso. */
    int crear(NuevoUsuario nuevo);

    /** Cambia el rol de una cuenta. Error si la cuenta no existe. */
    void cambiarPerfil(int idUsuario, PerfilInterfaz perfil);

    /** Activa o desactiva una cuenta. Una cuenta inactiva no puede iniciar sesión. */
    void cambiarEstado(int idUsuario, boolean activo);

    /** true si ya existe una cuenta con ese usuario (sin distinguir mayúsculas). */
    boolean existeNombreUsuario(String nombreUsuario);

    /** true si alguna persona ya tiene ese correo (sin distinguir mayúsculas). */
    boolean existeCorreo(String correo);

    /** true si alguna persona ya tiene ese teléfono (comparando solo los dígitos). */
    boolean existeTelefono(String telefono);
}
