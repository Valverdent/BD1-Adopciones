package com.mycompany.bd_proyecto1.dao.oracle;

import com.mycompany.bd_proyecto1.util.AccesoDatosException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Conexión única con la base de datos Oracle.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public final class ConexionBD {

    private static final String ARCHIVO = "db.properties";

    private static Connection conexion;

    private ConexionBD() {
        // Clase de utilidad: no se instancia.
    }

    /** Retorna la conexión abierta, o la abre si todavía no existe o se perdió. */
    public static synchronized Connection obtener() {
        try {
            if (conexion == null || conexion.isClosed() || !conexion.isValid(5)) {
                conexion = abrir();
            }
            return conexion;
        } catch (SQLException e) {
            conexion = null;
            throw new AccesoDatosException("No se pudo conectar con la base de datos. Revise que Tailscale "
                    + "esté conectado, que la base esté encendida y los datos de " + ARCHIVO
                    + ".\nDetalle: " + e.getMessage(), e);
        }
    }

    /** Cierra la conexión (al salir de la aplicación). */
    public static synchronized void cerrar() {
        if (conexion != null) {
            try {
                conexion.close();
            } catch (SQLException e) {
                // Al salir no importa si falla el cierre
            }
            conexion = null;
        }
    }

    private static Connection abrir() throws SQLException {
        Properties datos = leerArchivo();
        String url = requerido(datos, "db.url");
        String usuario = requerido(datos, "db.usuario");
        String contrasena = requerido(datos, "db.contrasena");

        Connection nueva = DriverManager.getConnection(url, usuario, contrasena);
        nueva.setAutoCommit(true);
        return nueva;
    }

    private static Properties leerArchivo() {
        Path ruta = Paths.get(ARCHIVO).toAbsolutePath();
        if (!Files.exists(ruta)) {
            throw new AccesoDatosException("No se encontró " + ruta + ".\nCopie db.properties.example "
                    + "como db.properties en la carpeta del proyecto y escriba la contraseña.");
        }
        Properties datos = new Properties();
        try (InputStream entrada = Files.newInputStream(ruta)) {
            datos.load(entrada);
        } catch (IOException e) {
            throw new AccesoDatosException("No se pudo leer " + ruta + ": " + e.getMessage(), e);
        }
        return datos;
    }

    private static String requerido(Properties datos, String clave) {
        String valor = datos.getProperty(clave);
        if (valor == null || valor.isBlank()) {
            throw new AccesoDatosException("Falta el valor de " + clave + " en " + ARCHIVO + ".");
        }
        return valor.trim();
    }
}
