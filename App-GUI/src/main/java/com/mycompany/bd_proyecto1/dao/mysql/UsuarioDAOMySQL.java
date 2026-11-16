package com.mycompany.bd_proyecto1.dao.mysql;

import static com.mycompany.bd_proyecto1.dao.mysql.UtilMySQL.*;

import com.mycompany.bd_proyecto1.dao.UsuarioDAO;
import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.NuevoUsuario;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.AccesoDatosException;
import com.mycompany.bd_proyecto1.util.Hash;
import com.mycompany.bd_proyecto1.util.PerfilInterfaz;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación de UsuarioDAO con MySQL. Misma lógica que la versión de Oracle: los
 * procedimientos se llaman igual, sin el paquete y sin el parámetro del cursor.
 *
 * @author Carlos Hidalgo
 * @since 2026-11-15
 */
public class UsuarioDAOMySQL implements UsuarioDAO {

    /** Nombre del rol de administrador en la tabla Role. */
    static final String ROL_ADMINISTRADOR = "Administrador";

    // ------------------------------------------------------------------------
    // --------------------------- Inicio de sesión ---------------------------
    // ------------------------------------------------------------------------

    @Override
    public Optional<Usuario> autenticar(String nombreUsuario, String contrasena) {
        String estadoActivo = textoDeFuncion("{? = call fn_active_status_name()}");
        try (CallableStatement cs = preparar("{call pr_login_user(?, ?)}")) {
            ponerTexto(cs, 1, nombreUsuario);
            cs.setString(2, Hash.sha256(contrasena));
            cs.execute();
            try (ResultSet fila = resultado(cs)) {
                if (!fila.next()) {
                    return Optional.empty();                 // usuario o contraseña incorrectos
                }
                if (!texto(fila, "statusName").equalsIgnoreCase(estadoActivo)) {
                    return Optional.empty();                 // cuenta inactiva: mismo mensaje, sin dar pistas
                }
                return Optional.of(new Usuario(fila.getInt("id"), fila.getInt("idPerson"),
                        texto(fila, "username"), texto(fila, "fullName"), perfilDe(texto(fila, "roleName"))));
            }
        } catch (SQLException e) {
            throw error("iniciar sesión", e);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<CuentaUsuario> listar() {
        String estadoActivo = textoDeFuncion("{? = call fn_active_status_name()}");
        List<CuentaUsuario> cuentas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pr_get_users(?, ?)}")) {
            cs.setNull(1, Types.NUMERIC);
            cs.setNull(2, Types.NUMERIC);
            cs.execute();
            try (ResultSet fila = resultado(cs)) {
                while (fila.next()) {
                    cuentas.add(new CuentaUsuario(fila.getInt("id"), fila.getInt("idPerson"),
                            texto(fila, "username"), texto(fila, "fullName"),
                            perfilDe(texto(fila, "roleName")),
                            texto(fila, "statusName").equalsIgnoreCase(estadoActivo)));
                }
            }
        } catch (SQLException e) {
            throw error("consultar los usuarios", e);
        }
        return cuentas;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Creación y cambios --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int crear(NuevoUsuario nuevo) {
        // 1. Persona, ubicación, contactos y cuenta (queda con el rol y estado por defecto)
        try (CallableStatement cs = preparar(
                "{call pr_register_user(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            ponerTexto(cs, 1, nuevo.getNombre());
            ponerTexto(cs, 2, nuevo.getSegundoNombre());
            ponerTexto(cs, 3, nuevo.getPrimerApellido());
            ponerTexto(cs, 4, nuevo.getSegundoApellido());
            ponerId(cs, 5, nuevo.getUbicacion().getDistrito());
            ponerTexto(cs, 6, nuevo.getUbicacion().getSenas());
            ponerTexto(cs, 7, nuevo.getTelefono());
            ponerTexto(cs, 8, nuevo.getCorreo());
            ponerTexto(cs, 9, nuevo.getNombreUsuario());
            cs.setString(10, Hash.sha256(nuevo.getContrasena()));
            cs.registerOutParameter(11, Types.NUMERIC);
            cs.execute();
            revisar(cs, 11, "crear el usuario");
        } catch (SQLException e) {
            throw error("crear el usuario", e);
        }

        // 2. El procedimiento no devuelve el id: se busca por nombre de usuario
        int idUsuario = listar().stream()
                .filter(c -> c.getNombreUsuario().equalsIgnoreCase(nuevo.getNombreUsuario().trim()))
                .mapToInt(CuentaUsuario::getIdUsuario)
                .findFirst()
                .orElseThrow(() -> new AccesoDatosException("La cuenta se creó, pero no se encontró al consultarla."));

        // 3. Rol elegido (el procedimiento siempre asigna el rol por defecto)
        cambiarPerfil(idUsuario, nuevo.getPerfil());
        return idUsuario;
    }

    @Override
    public void cambiarPerfil(int idUsuario, PerfilInterfaz perfil) {
        String nombreRol = perfil == PerfilInterfaz.ADMINISTRADOR
                ? ROL_ADMINISTRADOR
                : textoDeFuncion("{? = call fn_get_text('DEFAULT_ROLE_NAME')}");
        int idRol = buscarPorNombre(UtilMySQL.listarItems("{call pr_get_roles()}", "name",
                "consultar los roles"), nombreRol, "rol");
        actualizarUsuario("{call pr_update_user_role(?, ?, ?)}", idUsuario, idRol,
                "cambiar el rol");
    }

    @Override
    public void cambiarEstado(int idUsuario, boolean activo) {
        String estadoActivo = textoDeFuncion("{? = call fn_active_status_name()}");
        List<ItemCatalogo> estados = UtilMySQL.listarItems("{call pr_get_user_statuses()}",
                "name", "consultar los estados de usuario");
        int idEstado;
        if (activo) {
            idEstado = buscarPorNombre(estados, estadoActivo, "estado de usuario");
        } else {
            idEstado = estados.stream()
                    .filter(e -> !e.getNombre().equalsIgnoreCase(estadoActivo))
                    .mapToInt(ItemCatalogo::getId)
                    .findFirst()
                    .orElseThrow(() -> new IllegalStateException(
                            "No hay un estado de usuario inactivo registrado en la base de datos."));
        }
        actualizarUsuario("{call pr_update_user_status(?, ?, ?)}", idUsuario, idEstado,
                "cambiar el estado");
    }

    // ------------------------------------------------------------------------
    // ---------------------------- Verificaciones ----------------------------
    // ------------------------------------------------------------------------

    @Override
    public boolean existeNombreUsuario(String nombreUsuario) {
        return funcionExiste("{? = call fn_username_exists(?)}", nombreUsuario);
    }

    @Override
    public boolean existeCorreo(String correo) {
        return funcionExiste("{? = call fn_email_exists(?)}", correo);
    }

    @Override
    public boolean existeTelefono(String telefono) {
        return funcionExiste("{? = call fn_phone_exists(?)}", telefono);
    }

    // ------------------------------------------------------------------ auxiliares

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    static PerfilInterfaz perfilDe(String nombreRol) {
        return ROL_ADMINISTRADOR.equalsIgnoreCase(nombreRol) ? PerfilInterfaz.ADMINISTRADOR
                : PerfilInterfaz.USUARIO_COMUN;
    }

    private void actualizarUsuario(String llamada, int idUsuario, int idValor, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.setInt(1, idUsuario);
            cs.setInt(2, idValor);
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, operacion);
        } catch (SQLException e) {
            throw error(operacion + " del usuario", e);
        }
    }

    private int buscarPorNombre(List<ItemCatalogo> items, String nombre, String queEs) {
        return items.stream()
                .filter(i -> i.getNombre().equalsIgnoreCase(nombre))
                .mapToInt(ItemCatalogo::getId)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el " + queEs + " \"" + nombre + "\" en la base de datos."));
    }

    /** Llama una función de la base que devuelve 1 si el valor existe. */
    private boolean funcionExiste(String llamada, String valor) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.registerOutParameter(1, Types.NUMERIC);
            ponerTexto(cs, 2, valor);
            cs.execute();
            return cs.getInt(1) == 1;
        } catch (SQLException e) {
            throw error("validar el dato", e);
        }
    }

    /** Llama una función sin parámetros (o con los valores ya escritos) que devuelve texto. */
    static String textoDeFuncion(String llamada) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.registerOutParameter(1, Types.VARCHAR);
            cs.execute();
            String valor = cs.getString(1);
            if (valor == null) {
                throw new IllegalStateException("Falta un parámetro del sistema (" + llamada + ").");
            }
            return valor.trim();
        } catch (SQLException e) {
            throw error("leer un parámetro del sistema", e);
        }
    }
}
