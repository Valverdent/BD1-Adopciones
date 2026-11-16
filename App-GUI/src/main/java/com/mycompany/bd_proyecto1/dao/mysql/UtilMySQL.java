package com.mycompany.bd_proyecto1.dao.mysql;

import com.mycompany.bd_proyecto1.dao.ConexionBD;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.util.AccesoDatosException;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Utilidades comunes de los DAO de MySQL. Tiene los mismos métodos que UtilOracle, pero en MySQL
 * no hay cursores: el procedimiento hace un SELECT y su resultado se lee con resultado(cs), en
 * lugar de cursor(cs, n). El driver de MySQL lee los parámetros OUT (como pnResult) al ejecutar,
 * así que se pueden revisar antes de leer las filas, igual que en Oracle.
 *
 * <pre>
 * try (CallableStatement cs = preparar("{call procedimiento(?, ?)}")) {
 *     ponerNumero(cs, 1, idMascota);
 *     cs.registerOutParameter(2, Types.NUMERIC);   // pnResult
 *     cs.execute();
 *     revisar(cs, 2, "consultar las mascotas");
 *     try (ResultSet fila = resultado(cs)) {
 *         while (fila.next()) { ... }
 *     }
 * } catch (SQLException e) {
 *     throw error("consultar las mascotas", e);
 * }
 * </pre>
 *
 * @author Carlos Hidalgo
 * @since 2026-11-14
 */
final class UtilMySQL {

    private UtilMySQL() {
        // Clase de utilidad: no se instancia.
    }

    // ------------------------------------------------------------------------
    // -------------------------- Llamadas y errores --------------------------
    // ------------------------------------------------------------------------

    /** Prepara una llamada como "{call procedimiento(?, ?)}" sobre la conexión única. */
    static CallableStatement preparar(String llamada) throws SQLException {
        return ConexionBD.obtener().prepareCall(llamada);
    }

    /**
     * Resultado del SELECT de un procedimiento ya ejecutado (reemplaza al cursor de Oracle). Salta
     * los conteos de filas de los INSERT o UPDATE que el procedimiento haga antes del SELECT.
     */
    static ResultSet resultado(CallableStatement llamada) throws SQLException {
        ResultSet filas = llamada.getResultSet();
        while (filas == null && (llamada.getMoreResults() || llamada.getUpdateCount() != -1)) {
            filas = llamada.getResultSet();
        }
        if (filas == null) {
            throw new SQLException("El procedimiento no devolvió ningún SELECT.");
        }
        return filas;
    }

    /** Ejecuta la llamada y retorna el resultado de su SELECT. */
    static ResultSet consultar(CallableStatement llamada) throws SQLException {
        llamada.execute();
        return resultado(llamada);
    }

    /**
     * Convierte un error de MySQL en un mensaje para el usuario. Los errores de datos (duplicado,
     * en uso, dato rechazado o un SIGNAL del procedimiento) se muestran como validaciones; los
     * demás, como error de base de datos.
     */
    static RuntimeException error(String operacion, SQLException e) {
        // SIGNAL SQLSTATE '45000' en un procedimiento: su MESSAGE_TEXT es el mensaje
        if ("45000".equals(e.getSQLState())) {
            return new IllegalArgumentException(e.getMessage());
        }
        String mensaje = switch (e.getErrorCode()) {
            // Llave única repetida
            case 1062 -> "Ya existe un registro con esos datos.";
            // Llave foránea: el registro está en uso, o el dato elegido no existe
            case 1451 -> "No se puede eliminar porque está en uso.";
            case 1452 -> "Alguno de los datos seleccionados ya no existe en la base de datos.";
            // Dato nulo, muy largo, fuera de rango o que no cumple un CHECK
            case 1048, 1406, 1264, 3819 ->
                "La base de datos rechazó algún dato (vacío, muy largo o fuera de rango).";
            default -> null;
        };
        if (mensaje != null) {
            return new IllegalArgumentException(mensaje);
        }
        return new AccesoDatosException("Error de base de datos al " + operacion + ".\nDetalle: "
                + e.getMessage(), e);
    }

    /**
     * Revisa el código de resultado (pnResult) de un procedimiento. Son los mismos códigos que en
     * Oracle; si el equipo de base de datos los cambia en MySQL, se ajustan aquí.
     */
    static void revisar(Integer resultado, String operacion) {
        if (resultado == null || resultado == 0) {
            return;
        }
        String mensaje = switch (resultado) {
            case 1001 -> "Ese nombre de usuario ya existe.";
            case 1002 -> "Ese correo ya está registrado.";
            case 1003 -> "Ese teléfono ya está registrado.";
            case 1004 -> "Ya existe un registro con esos datos.";
            case 1010 -> "La persona no existe en la base de datos.";
            case 1011 -> "El lugar seleccionado no existe en la base de datos.";
            case 1012 -> "La persona debe conservar al menos un correo o un teléfono.";
            case 1020 -> "Falta un parámetro del sistema que necesita esta operación. "
                    + "Revíselo en la pantalla de parámetros.";
            case 1030 -> "La base de datos rechazó algún dato (vacío, muy largo o fuera de rango).";
            case 1100 -> "Alguno de los datos seleccionados ya no existe en la base de datos.";
            case 1101 -> "Ese número de chip ya está registrado.";
            case 1102 -> "No se puede eliminar porque está en uso.";
            case 1103 -> "No se puede cambiar ni eliminar porque lo usa un parámetro del sistema.";
            default -> null;
        };
        if (mensaje != null) {
            throw new IllegalArgumentException(mensaje);
        }
        throw new AccesoDatosException("La base de datos no pudo " + operacion + " (código " + resultado + ").");
    }

    /** Lee pnResult de la posición indicada y lo revisa (después de leer el SELECT, si hay). */
    static void revisar(CallableStatement llamada, int posicion, String operacion) throws SQLException {
        revisar(leerEntero(llamada, posicion), operacion);
    }

    // ------------------------------------------------------------------------
    // ------------------------ Parámetros de entrada -------------------------
    // ------------------------------------------------------------------------

    static void ponerNumero(CallableStatement llamada, int posicion, Integer valor) throws SQLException {
        if (valor == null) {
            llamada.setNull(posicion, Types.INTEGER);
        } else {
            llamada.setInt(posicion, valor);
        }
    }

    /** Identificador de un elemento de catálogo, o NULL si no hay elemento. */
    static void ponerId(CallableStatement llamada, int posicion, ItemCatalogo item) throws SQLException {
        ponerNumero(llamada, posicion, item == null ? null : item.getId());
    }

    /** Identificador mayor que cero, o NULL si es 0 (la aplicación usa 0 como "sin valor"). */
    static void ponerIdOpcional(CallableStatement llamada, int posicion, int id) throws SQLException {
        ponerNumero(llamada, posicion, id > 0 ? id : null);
    }

    static void ponerDecimal(CallableStatement llamada, int posicion, BigDecimal valor) throws SQLException {
        if (valor == null) {
            llamada.setNull(posicion, Types.DECIMAL);
        } else {
            llamada.setBigDecimal(posicion, valor);
        }
    }

    /** Texto sin espacios al inicio y al final; un texto vacío se envía como NULL. */
    static void ponerTexto(CallableStatement llamada, int posicion, String valor) throws SQLException {
        if (valor == null || valor.isBlank()) {
            llamada.setNull(posicion, Types.VARCHAR);
        } else {
            llamada.setString(posicion, valor.trim());
        }
    }

    /** Fecha sin hora. Se envía como LocalDate para que la zona horaria no la cambie de día. */
    static void ponerFecha(CallableStatement llamada, int posicion, LocalDate valor) throws SQLException {
        if (valor == null) {
            llamada.setNull(posicion, Types.DATE);
        } else {
            llamada.setObject(posicion, valor);
        }
    }

    /** Booleano como 1 o 0 (en MySQL, BOOLEAN es TINYINT(1)). */
    static void ponerBooleano(CallableStatement llamada, int posicion, boolean valor) throws SQLException {
        llamada.setInt(posicion, valor ? 1 : 0);
    }

    // ------------------------------------------------------------------------
    // ------------------------ Lectura de resultados -------------------------
    // ------------------------------------------------------------------------

    /** Parámetro OUT entero (por ejemplo, pnResult o el id nuevo), o null si viene vacío. */
    static Integer leerEntero(CallableStatement llamada, int posicion) throws SQLException {
        int valor = llamada.getInt(posicion);
        return llamada.wasNull() ? null : valor;
    }

    /** Número entero de una columna, o null si viene vacía. */
    static Integer entero(ResultSet fila, String columna) throws SQLException {
        int valor = fila.getInt(columna);
        return fila.wasNull() ? null : valor;
    }

    /** Número entero de una columna, o 0 si viene vacía (identificadores opcionales). */
    static int id(ResultSet fila, String columna) throws SQLException {
        return fila.getInt(columna);
    }

    static BigDecimal decimal(ResultSet fila, String columna) throws SQLException {
        return fila.getBigDecimal(columna);
    }

    static double doble(ResultSet fila, String columna) throws SQLException {
        return fila.getDouble(columna);
    }

    static String texto(ResultSet fila, String columna) throws SQLException {
        String valor = fila.getString(columna);
        return valor == null ? null : valor.trim();
    }

    /** Fecha de una columna DATE o DATETIME, sin conversión de zona horaria. */
    static LocalDate fecha(ResultSet fila, String columna) throws SQLException {
        return fila.getObject(columna, LocalDate.class);
    }

    static LocalDateTime fechaHora(ResultSet fila, String columna) throws SQLException {
        return fila.getObject(columna, LocalDateTime.class);
    }

    static boolean booleano(ResultSet fila, String columna) throws SQLException {
        return fila.getInt(columna) == 1;
    }

    /**
     * Elemento de catálogo armado con dos columnas (id y nombre), o null si el id viene vacío (por
     * ejemplo, una mascota sin veterinario).
     */
    static ItemCatalogo item(ResultSet fila, String columnaId, String columnaNombre) throws SQLException {
        Integer id = entero(fila, columnaId);
        return id == null ? null : new ItemCatalogo(id, texto(fila, columnaNombre));
    }

    // ------------------------------------------------------------------------
    // -------------------------- Catálogos simples ---------------------------
    // ------------------------------------------------------------------------

    /** Ejecuta un procedimiento sin parámetros cuyo SELECT trae las columnas id y nombre. */
    static List<ItemCatalogo> listarItems(String llamada, String columnaNombre, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            return leerItems(consultar(cs), columnaNombre);
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    /** Igual que listarItems, para procedimientos que reciben el id del padre. */
    static List<ItemCatalogo> listarItemsDe(String llamada, Integer idPadre, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            ponerNumero(cs, 1, idPadre);
            return leerItems(consultar(cs), "name");
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    /** Lee un resultado con columnas id y nombre, y lo cierra. */
    static List<ItemCatalogo> leerItems(ResultSet filas, String columnaNombre) throws SQLException {
        List<ItemCatalogo> items = new ArrayList<>();
        try (filas) {
            while (filas.next()) {
                items.add(new ItemCatalogo(filas.getInt("id"), texto(filas, columnaNombre)));
            }
        }
        return items;
    }
}
