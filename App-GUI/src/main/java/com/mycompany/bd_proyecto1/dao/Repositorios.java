package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.dao.memoria.AdopcionDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.AsociacionDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.BitacoraDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.ParametroDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.CasaCunaDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.CatalogoDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.ConsultaAdicionalDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.DonacionDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.EstadisticaDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.ListaNegraDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.MascotaDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.MatchDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.PersonaDAOMemoria;
import com.mycompany.bd_proyecto1.dao.memoria.UsuarioDAOMemoria;
import com.mycompany.bd_proyecto1.dao.mysql.AdopcionDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.AsociacionDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.BitacoraDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.CasaCunaDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.CatalogoDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.ConsultaAdicionalDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.DonacionDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.EstadisticaDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.ListaNegraDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.MascotaDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.MatchDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.ParametroDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.PersonaDAOMySQL;
import com.mycompany.bd_proyecto1.dao.mysql.UsuarioDAOMySQL;
import com.mycompany.bd_proyecto1.dao.oracle.AdopcionDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.AsociacionDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.BitacoraDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.ParametroDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.CasaCunaDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.CatalogoDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.ConsultaAdicionalDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.DonacionDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.EstadisticaDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.ListaNegraDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.MascotaDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.MatchDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.PersonaDAOOracle;
import com.mycompany.bd_proyecto1.dao.oracle.UsuarioDAOOracle;

/**
 * Punto único donde se decide de dónde salen los datos de la aplicación.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public final class Repositorios {

    /** Origen de los datos de la aplicación. */
    public enum FuenteDatos {
        /** Datos de prueba escritos en el código (solo desarrollo). */
        MEMORIA,
        /** Funciones y procedimientos de la base de datos Oracle. */
        ORACLE,
        /** Procedimientos de la base de datos MySQL. */
        MYSQL
    }

    /** ORACLE o MYSQL = base de datos real; MEMORIA = datos de prueba sin conexión. */
    public static final FuenteDatos FUENTE_DATOS = FuenteDatos.MYSQL;

    private static final boolean MEMORIA = FUENTE_DATOS == FuenteDatos.MEMORIA;
    private static final boolean MYSQL = FUENTE_DATOS == FuenteDatos.MYSQL;

    // En memoria no hay triggers: los repositorios de mascotas, adopciones y
    // donaciones escriben en esta bitácora cuando cambia un campo sensible.
    private static final BitacoraDAOMemoria BITACORA_MEMORIA = MEMORIA ? new BitacoraDAOMemoria() : null;
    private static final BitacoraDAO BITACORA = MEMORIA
            ? BITACORA_MEMORIA
            : MYSQL ? new BitacoraDAOMySQL() : new BitacoraDAOOracle();
    private static final MascotaDAO MASCOTAS = MEMORIA
            ? new MascotaDAOMemoria(BITACORA_MEMORIA)
            : MYSQL ? new MascotaDAOMySQL() : new MascotaDAOOracle();
    private static final PersonaDAO PERSONAS = MEMORIA
            ? new PersonaDAOMemoria()
            : MYSQL ? new PersonaDAOMySQL() : new PersonaDAOOracle();
    // En memoria, las cuentas nuevas crean su persona en las mismas personas de la aplicación.
    private static final UsuarioDAO USUARIOS = MEMORIA
            ? new UsuarioDAOMemoria(PERSONAS)
            : MYSQL ? new UsuarioDAOMySQL() : new UsuarioDAOOracle();
    // En memoria, las adopciones usan las mismas mascotas para cambiarles el estado.
    private static final AdopcionDAO ADOPCIONES = MEMORIA
            ? new AdopcionDAOMemoria(MASCOTAS, BITACORA_MEMORIA)
            : MYSQL ? new AdopcionDAOMySQL() : new AdopcionDAOOracle();
    private static final AsociacionDAO ASOCIACIONES = MEMORIA
            ? new AsociacionDAOMemoria()
            : MYSQL ? new AsociacionDAOMySQL() : new AsociacionDAOOracle();
    // En memoria, las donaciones de recompensa usan las mismas mascotas y asociaciones.
    private static final DonacionDAO DONACIONES = MEMORIA
            ? new DonacionDAOMemoria(MASCOTAS, ASOCIACIONES, BITACORA_MEMORIA)
            : MYSQL ? new DonacionDAOMySQL() : new DonacionDAOOracle();
    // En memoria, la lista negra usa las personas y las adopciones (calificación promedio).
    private static final ListaNegraDAO LISTA_NEGRA = MEMORIA
            ? new ListaNegraDAOMemoria(PERSONAS, ADOPCIONES)
            : MYSQL ? new ListaNegraDAOMySQL() : new ListaNegraDAOOracle();
    private static final ParametroDAO PARAMETROS = MEMORIA
            ? new ParametroDAOMemoria(BITACORA_MEMORIA)
            : MYSQL ? new ParametroDAOMySQL() : new ParametroDAOOracle();
    // En memoria, los rangos de edad salen de los mismos parámetros.
    private static final EstadisticaDAO ESTADISTICAS = MEMORIA
            ? new EstadisticaDAOMemoria(MASCOTAS, PARAMETROS)
            : MYSQL ? new EstadisticaDAOMySQL() : new EstadisticaDAOOracle();
    private static final MatchDAO MATCHES = MEMORIA
            ? new MatchDAOMemoria(MASCOTAS)
            : MYSQL ? new MatchDAOMySQL() : new MatchDAOOracle();
    private static final CasaCunaDAO CASAS_CUNA = MEMORIA
            ? new CasaCunaDAOMemoria(PERSONAS)
            : MYSQL ? new CasaCunaDAOMySQL() : new CasaCunaDAOOracle();
    // El catálogo necesita los registros (mascotas, adopciones, casas cuna, personas y
    // asociaciones) para contar los usos de cada elemento, incluidos los distritos.
    private static final CatalogoDAO CATALOGOS = MEMORIA
            ? new CatalogoDAOMemoria(MASCOTAS, ADOPCIONES, CASAS_CUNA, PERSONAS, ASOCIACIONES)
            : MYSQL ? new CatalogoDAOMySQL() : new CatalogoDAOOracle();
    private static final ConsultaAdicionalDAO CONSULTAS_ADICIONALES = MEMORIA
            ? new ConsultaAdicionalDAOMemoria(CASAS_CUNA, MASCOTAS)
            : MYSQL ? new ConsultaAdicionalDAOMySQL() : new ConsultaAdicionalDAOOracle();

    private Repositorios() {
        // Clase de utilidad: no se instancia.
    }

    // ------------------------------------------------------------------------
    // -------------------------- Acceso a cada DAO ---------------------------
    // ------------------------------------------------------------------------

    public static UsuarioDAO usuarios() {
        return USUARIOS;
    }

    public static CatalogoDAO catalogos() {
        return CATALOGOS;
    }

    public static MascotaDAO mascotas() {
        return MASCOTAS;
    }

    public static PersonaDAO personas() {
        return PERSONAS;
    }

    public static AdopcionDAO adopciones() {
        return ADOPCIONES;
    }

    public static AsociacionDAO asociaciones() {
        return ASOCIACIONES;
    }

    public static DonacionDAO donaciones() {
        return DONACIONES;
    }

    public static ListaNegraDAO listaNegra() {
        return LISTA_NEGRA;
    }

    public static EstadisticaDAO estadisticas() {
        return ESTADISTICAS;
    }

    public static MatchDAO matches() {
        return MATCHES;
    }

    public static CasaCunaDAO casasCuna() {
        return CASAS_CUNA;
    }

    public static ParametroDAO parametros() {
        return PARAMETROS;
    }

    public static BitacoraDAO bitacora() {
        return BITACORA;
    }

    public static ConsultaAdicionalDAO consultasAdicionales() {
        return CONSULTAS_ADICIONALES;
    }

    // ------------------------------------------------------------------------
    // --------------------------- Fuente de datos ----------------------------
    // ------------------------------------------------------------------------

    public static boolean usaDatosDePrueba() {
        return MEMORIA;
    }
}
