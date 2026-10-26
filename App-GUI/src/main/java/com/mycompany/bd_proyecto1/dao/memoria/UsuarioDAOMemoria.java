package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.dao.UsuarioDAO;
import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.NuevoUsuario;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.PerfilInterfaz;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

/**
 * Implementación de UsuarioDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class UsuarioDAOMemoria implements UsuarioDAO {

    /** Registro interno de prueba: incluye la contraseña y el estado. */
    private static class CuentaPrueba {
        private final int id;
        private final int idPersona;
        private final String nombreUsuario;
        private final String contrasena;
        private PerfilInterfaz perfil;
        private boolean activo;

        CuentaPrueba(int id, int idPersona, String nombreUsuario, String contrasena,
                     PerfilInterfaz perfil, boolean activo) {
            this.id = id;
            this.idPersona = idPersona;
            this.nombreUsuario = nombreUsuario;
            this.contrasena = contrasena;
            this.perfil = perfil;
            this.activo = activo;
        }
    }

    private final PersonaDAO personaDAO;
    private final List<CuentaPrueba> cuentas = new ArrayList<>();
    private int siguienteId;

    /** Usa sus propias personas de prueba (para pruebas aisladas). */
    public UsuarioDAOMemoria() {
        this(new PersonaDAOMemoria());
    }

    /** Usa las mismas personas que el resto de la aplicación. */
    public UsuarioDAOMemoria(PersonaDAO personaDAO) {
        this.personaDAO = personaDAO;
        cuentas.add(new CuentaPrueba(1, DatosPrueba.PERSONA_ADMIN, "admin", "admin",
                PerfilInterfaz.ADMINISTRADOR, true));
        cuentas.add(new CuentaPrueba(2, DatosPrueba.PERSONA_USUARIO, "usuario", "usuario",
                PerfilInterfaz.USUARIO_COMUN, true));
        cuentas.add(new CuentaPrueba(3, DatosPrueba.PERSONA_USUARIO2, "usuario2", "usuario2",
                PerfilInterfaz.USUARIO_COMUN, true));
        siguienteId = cuentas.size() + 1;
    }

    // ------------------------------------------------------------------------
    // --------------------------- Inicio de sesión ---------------------------
    // ------------------------------------------------------------------------

    @Override
    public Optional<Usuario> autenticar(String nombreUsuario, String contrasena) {
        for (CuentaPrueba c : cuentas) {
            if (c.nombreUsuario.equals(nombreUsuario) && c.contrasena.equals(contrasena) && c.activo) {
                return Optional.of(new Usuario(c.id, c.idPersona, c.nombreUsuario,
                        nombreDePersona(c.idPersona), c.perfil));
            }
        }
        return Optional.empty();
    }

    @Override
    public List<CuentaUsuario> listar() {
        List<CuentaUsuario> resultado = new ArrayList<>();
        for (CuentaPrueba c : cuentas) {
            resultado.add(new CuentaUsuario(c.id, c.idPersona, c.nombreUsuario,
                    nombreDePersona(c.idPersona), c.perfil, c.activo));
        }
        resultado.sort(Comparator.comparing(CuentaUsuario::getNombreUsuario, String.CASE_INSENSITIVE_ORDER));
        return resultado;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Creación y cambios --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int crear(NuevoUsuario nuevo) {
        Persona persona = new Persona();
        persona.setNombre(nuevo.getNombre());
        persona.setSegundoNombre(nuevo.getSegundoNombre());
        persona.setPrimerApellido(nuevo.getPrimerApellido());
        persona.setSegundoApellido(nuevo.getSegundoApellido());
        persona.setUbicacion(nuevo.getUbicacion());
        persona.setTelefonos(new ArrayList<>(List.of(nuevo.getTelefono())));
        persona.setCorreos(new ArrayList<>(List.of(nuevo.getCorreo())));
        int idPersona = personaDAO.insertar(persona);

        CuentaPrueba cuenta = new CuentaPrueba(siguienteId, idPersona, nuevo.getNombreUsuario(),
                nuevo.getContrasena(), nuevo.getPerfil(), true);
        siguienteId++;
        cuentas.add(cuenta);
        return cuenta.id;
    }

    @Override
    public void cambiarPerfil(int idUsuario, PerfilInterfaz perfil) {
        buscar(idUsuario).perfil = perfil;
    }

    @Override
    public void cambiarEstado(int idUsuario, boolean activo) {
        buscar(idUsuario).activo = activo;
    }

    // ------------------------------------------------------------------------
    // ---------------------------- Verificaciones ----------------------------
    // ------------------------------------------------------------------------

    @Override
    public boolean existeNombreUsuario(String nombreUsuario) {
        for (CuentaPrueba c : cuentas) {
            if (c.nombreUsuario.equalsIgnoreCase(nombreUsuario)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean existeCorreo(String correo) {
        for (Persona p : personaDAO.consultar(new FiltroPersona())) {
            for (String c : p.getCorreos()) {
                if (c.equalsIgnoreCase(correo)) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public boolean existeTelefono(String telefono) {
        String digitos = soloDigitos(telefono);
        for (Persona p : personaDAO.consultar(new FiltroPersona())) {
            for (String t : p.getTelefonos()) {
                if (soloDigitos(t).equals(digitos)) {
                    return true;
                }
            }
        }
        return false;
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    private CuentaPrueba buscar(int idUsuario) {
        for (CuentaPrueba c : cuentas) {
            if (c.id == idUsuario) {
                return c;
            }
        }
        throw new IllegalStateException("No existe el usuario con id " + idUsuario);
    }

    private String nombreDePersona(int idPersona) {
        return personaDAO.obtener(idPersona).getNombreCompleto();
    }

    private static String soloDigitos(String texto) {
        return texto == null ? "" : texto.replaceAll("[^0-9]", "");
    }
}
