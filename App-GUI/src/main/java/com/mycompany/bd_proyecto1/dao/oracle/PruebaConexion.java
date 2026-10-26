package com.mycompany.bd_proyecto1.dao.oracle;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Diagnóstico de la conexión con Oracle: llama, una por una, a las consultas que usa la aplicación
 * e indica cuáles funcionan y cuáles fallan.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public final class PruebaConexion {

    private static int correctas = 0;
    private static final List<String> fallidas = new ArrayList<>();

    private PruebaConexion() {
        // Solo tiene el método main.
    }

    public static void main(String[] args) {
        System.out.println("=== Diagnóstico de la conexión con Oracle (solo lectura) ===\n");

        // ------------------------------------------------------------------------
        // ------------------------------- Conexión -------------------------------
        // ------------------------------------------------------------------------
        boolean conectado = paso("Conexión", () -> {
            Connection c = ConexionBD.obtener();
            DatabaseMetaData datos = c.getMetaData();
            return datos.getUserName() + " en " + datos.getURL() + " (" + datos.getDatabaseProductVersion()
                    .lines().findFirst().orElse("") + ", driver " + datos.getDriverVersion() + ")";
        });
        if (!conectado) {
            System.out.println("\nSin conexión no se puede seguir. Revise db.properties y Tailscale.");
            return;
        }

        // ------------------------------------------------------------------------
        // ------------------------ Usuarios y parámetros -------------------------
        // ------------------------------------------------------------------------
        UsuarioDAOOracle usuarios = new UsuarioDAOOracle();
        paso("Usuarios: PR_GET_USERS", () -> {
            List<CuentaUsuario> lista = usuarios.listar();
            return lista.size() + " usuarios" + (lista.isEmpty() ? "" : "; primero: "
                    + lista.get(0).getNombreUsuario() + " (" + lista.get(0).getPerfil() + ")");
        });
        paso("Usuarios: FN_ACTIVE_STATUS_NAME", () -> "estado activo = '"
                + UsuarioDAOOracle.textoDeFuncion("{? = call pkg_user_administration.fn_active_status_name()}") + "'");
        paso("Usuarios: FN_USERNAME_EXISTS / FN_EMAIL_EXISTS / FN_PHONE_EXISTS", () ->
                "nombre=" + usuarios.existeNombreUsuario("__diagnostico__")
                + ", correo=" + usuarios.existeCorreo("__diagnostico__@x.com")
                + ", teléfono=" + usuarios.existeTelefono("0000-0000") + " (lo normal es false)");
        paso("Usuarios: PR_LOGIN_USER con un usuario inexistente", () ->
                "inicio de sesión = " + usuarios.autenticar("__diagnostico__", "x").isPresent() + " (lo normal es false)");

        ParametroDAOOracle parametros = new ParametroDAOOracle();
        paso("Parámetros: PR_GET_PARAMETERS", () -> parametros.listar().size() + " parámetros");
        paso("Parámetros: FN_GET_NUMBER (MATCH_MIN_SCORE)", () ->
                "valor = " + MatchDAOOracle.numeroParametro("MATCH_MIN_SCORE"));

        // ------------------------------------------------------------------------
        // ------------------------- Catálogos y lugares --------------------------
        // ------------------------------------------------------------------------
        CatalogoDAOOracle catalogos = new CatalogoDAOOracle();
        for (TipoCatalogo tipo : TipoCatalogo.values()) {
            if (tipo.tienePadre()) {
                paso("Catálogo " + tipo + " (hijos del primer " + tipo.getPadre() + ")", () -> {
                    List<ItemCatalogo> padres = catalogos.listar(tipo.getPadre());
                    if (padres.isEmpty()) {
                        return "no hay elementos de " + tipo.getPadre();
                    }
                    return catalogos.listarHijos(tipo, padres.get(0).getId()).size() + " de " + padres.get(0).getNombre();
                });
            } else {
                paso("Catálogo " + tipo, () -> catalogos.listar(tipo).size() + " elementos");
            }
        }
        paso("Catálogos: PR_GET_DISEASE_TREATMENTS (primera enfermedad con tratamientos)", () -> {
            for (ItemCatalogo enfermedad : catalogos.listar(TipoCatalogo.ENFERMEDAD)) {
                int cantidad = catalogos.listarTratamientos(enfermedad.getId()).size();
                if (cantidad > 0) {
                    return cantidad + " tratamientos de " + enfermedad.getNombre();
                }
            }
            return "ninguna enfermedad tiene tratamientos";
        });

        // ------------------------------------------------------------------------
        // ------------------ Personas, lista negra y casas cuna ------------------
        // ------------------------------------------------------------------------
        PersonaDAOOracle personas = new PersonaDAOOracle();
        List<Persona> listaPersonas = new ArrayList<>();
        paso("Personas: PR_GET_PERSONS + PR_GET_PERSON_CONTACTS", () -> {
            listaPersonas.addAll(personas.consultar(new FiltroPersona()));
            return listaPersonas.size() + " personas" + (listaPersonas.isEmpty() ? "" : "; primera: "
                    + listaPersonas.get(0).getNombreCompleto() + ", tel " + listaPersonas.get(0).getTelefonos()
                    + ", lugar " + resumen(listaPersonas.get(0)));
        });
        if (!listaPersonas.isEmpty()) {
            paso("Personas: obtener una (id " + listaPersonas.get(0).getId() + ")", () ->
                    personas.obtener(listaPersonas.get(0).getId()).getNombreCompleto());
        }

        ListaNegraDAOOracle listaNegra = new ListaNegraDAOOracle();
        paso("Lista negra: PR_REPORT_BLACKLIST + PR_GET_PERSON_RATINGS", () -> {
            List<ResumenListaNegra> lista = listaNegra.consultar(new FiltroListaNegra());
            String detalle = lista.size() + " personas en lista negra";
            if (!lista.isEmpty()) {
                detalle += "; reportes de la primera: " + listaNegra.listarReportes(lista.get(0).getIdPersona()).size();
            }
            return detalle;
        });

        CasaCunaDAOOracle casas = new CasaCunaDAOOracle();
        paso("Casas cuna: PR_GET_FOSTER_HOMES + PR_GET_FOSTER_HOME_ACCEPTS", () -> {
            List<CasaCuna> lista = casas.consultar(new FiltroCasaCuna());
            return lista.size() + " casas cuna" + (lista.isEmpty() ? "" : "; primera acepta tipos "
                    + lista.get(0).getTipos() + " y tamaños " + lista.get(0).getTamanos());
        });

        // ------------------------------------------------------------------------
        // ------------------------- Mascotas y reportes --------------------------
        // ------------------------------------------------------------------------
        MascotaDAOOracle mascotas = new MascotaDAOOracle();
        paso("Mascotas: PR_QUERY_PETS + enfermedades + fotos", () -> {
            List<Mascota> lista = mascotas.consultar(new FiltroMascota());
            if (lista.isEmpty()) {
                return "0 mascotas";
            }
            Mascota m = lista.get(0);
            return lista.size() + " mascotas; primera: " + m.getNombre() + " (" + m.getTipo() + ", " + m.getEstado()
                    + "), enfermedades " + m.getEnfermedades().size() + ", lugar "
                    + (m.getUbicacion() == null ? "-" : m.getUbicacion().getResumen());
        });
        paso("Mascotas: chip inexistente", () -> "existe = " + mascotas.existeChip("__diagnostico__", 0) + " (lo normal es false)");
        paso("Mascotas sin adoptar (0 meses)", () -> mascotas.listarSinAdoptar(0, null).size() + " mascotas");
        paso("Matches: PR_MATCH_LOST_FOUND (puntaje mínimo del parámetro)", () -> {
            int minimo = (int) MatchDAOOracle.numeroParametro("MATCH_MIN_SCORE");
            return new MatchDAOOracle().generarMatches(minimo, null).size() + " matches con " + minimo + " o más";
        });

        // ------------------------------------------------------------------------
        // ------------------------------ Adopciones ------------------------------
        // ------------------------------------------------------------------------
        AdopcionDAOOracle adopciones = new AdopcionDAOOracle();
        paso("Adopciones: PR_GET_ADOPTIONS + calificación + fotos", () -> {
            List<Adopcion> lista = adopciones.consultar(new FiltroAdopcion());
            String detalle = lista.size() + " adopciones";
            if (!lista.isEmpty()) {
                Adopcion a = lista.get(0);
                detalle += "; primera: " + a.getMascota().getNombre() + " -> " + a.getAdoptante()
                        + ", seguimientos " + adopciones.listarSeguimientos(a.getId()).size();
            }
            return detalle;
        });
        paso("Adopciones: mascotas disponibles para adoptar", () -> adopciones.listarMascotasDisponibles().size() + " mascotas");
        paso("Adopciones por adoptante", () -> adopciones.consultarPorAdoptante(new FiltroAdoptante()).size() + " adoptantes");

        // ------------------------------------------------------------------------
        // ---------------------- Asociaciones y donaciones -----------------------
        // ------------------------------------------------------------------------
        paso("Asociaciones: PR_GET_ASSOCIATIONS_FILTERED", () -> {
            List<AsociacionBienestar> lista = new AsociacionDAOOracle().listar();
            return lista.size() + " asociaciones";
        });
        DonacionDAOOracle donaciones = new DonacionDAOOracle();
        LocalDate desde = LocalDate.of(2000, 1, 1);
        LocalDate hoy = LocalDate.now();
        paso("Donaciones: PR_GET_DONATION_HISTORY", () -> {
            FiltroDonacion filtro = new FiltroDonacion();
            filtro.setFechaDesde(desde);
            filtro.setFechaHasta(hoy);
            List<FilaDonacion> lista = donaciones.consultar(filtro);
            String detalle = lista.size() + " filas";
            if (!lista.isEmpty()) {
                detalle += "; donación " + lista.get(0).getIdDonacion() + " por "
                        + donaciones.obtener(lista.get(0).getIdDonacion()).getMontoTotal();
            }
            return detalle;
        });
        paso("Donaciones: totales por asociación", () -> donaciones.totalesPorAsociacion(desde, hoy).size() + " filas");
        paso("Donaciones: recompensas disponibles", () -> donaciones.listarRecompensasDisponibles().size() + " mascotas con recompensa");

        // ------------------------------------------------------------------------
        // ----------------------------- Estadísticas -----------------------------
        // ------------------------------------------------------------------------
        EstadisticaDAOOracle estadisticas = new EstadisticaDAOOracle();
        paso("Estadística 8.a: PR_STAT_PETS_STATUS", () -> estadisticas.contarMascotasPorTipoYEstado(desde, hoy).size() + " filas");
        paso("Estadística 8.c: PR_STAT_ADOPTION_RATE", () -> {
            var r = estadisticas.resumirAdopciones(null, null);
            return r.getAdoptadas() + " adoptadas, " + r.getEnEspera() + " en espera";
        });
        paso("Estadística 8.d: PR_STAT_UNADOPTED_AGE", () -> estadisticas.contarNoAdoptadasPorEdad().size() + " rangos");
        paso("Estadística: PR_STAT_PETS_BY_CANTON", () -> estadisticas.contarPerdidasYEncontradasPorCanton(desde, hoy).size() + " filas");
        paso("Estadística: PR_STAT_DONATIONS_BY_RESCUER", () -> estadisticas.totalizarDonacionesPorRescatista(desde, hoy).size() + " filas");

        // ------------------------------------------------------------------------
        // ------------------- Consultas adicionales y bitácora -------------------
        // ------------------------------------------------------------------------
        ConsultaAdicionalDAOOracle consultas = new ConsultaAdicionalDAOOracle();
        paso("Consultas: PR_GET_FOSTER_HOME_AVAILABILITY", () -> consultas.casasCunaConEspacio(null, null, 0).size() + " filas");
        paso("Consultas: PR_GET_LOST_PETS", () -> consultas.mascotasPerdidasPorRecompensa(null, null).size() + " mascotas");

        BitacoraDAOOracle bitacora = new BitacoraDAOOracle();
        paso("Bitácora: PR_GET_CHANGELOG_TABLES", () -> bitacora.listarTablas().toString());
        paso("Bitácora: PR_GET_CHANGELOG (últimos 7 días)", () -> {
            FiltroBitacora filtro = new FiltroBitacora();
            filtro.setFechaDesde(hoy.minusDays(7));
            filtro.setFechaHasta(hoy);
            return bitacora.consultar(filtro).size() + " cambios";
        });

        ConexionBD.cerrar();

        // ------------------------------------------------------------------------
        // ------------------------------- Resumen --------------------------------
        // ------------------------------------------------------------------------
        System.out.println("\n=== Resultado: " + correctas + " correctas, " + fallidas.size() + " con error ===");
        for (String f : fallidas) {
            System.out.println("  - " + f);
        }
    }

    /** Interfaz funcional que permite lanzar excepciones verificadas (SQLException). */
    private interface Prueba {
        String ejecutar() throws Exception;
    }

    private static boolean paso(String nombre, Prueba prueba) {
        long inicio = System.currentTimeMillis();
        try {
            String detalle = prueba.ejecutar();
            correctas++;
            System.out.println("OK    " + nombre + " -> " + detalle + "  [" + (System.currentTimeMillis() - inicio) + " ms]");
            return true;
        } catch (Exception | Error e) {
            fallidas.add(nombre);
            System.out.println("FALLO " + nombre + " -> " + causas(e));
            return false;
        }
    }

    /** Mensaje de la excepción y de sus causas (ahí viene el ORA-xxxxx). */
    private static String causas(Throwable e) {
        StringBuilder texto = new StringBuilder(e.getClass().getSimpleName() + ": " + e.getMessage());
        for (Throwable c = e.getCause(); c != null && c != c.getCause(); c = c.getCause()) {
            texto.append("\n        causa: ").append(c.getClass().getSimpleName()).append(": ").append(c.getMessage());
            if (c.getCause() == c) {
                break;
            }
        }
        return texto.toString().replace("\n\n", "\n");
    }

    private static String resumen(Persona p) {
        return p.getUbicacion() == null ? "-" : p.getUbicacion().getResumen();
    }
}
