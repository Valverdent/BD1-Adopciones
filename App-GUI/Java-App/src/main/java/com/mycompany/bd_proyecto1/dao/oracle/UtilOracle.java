package com.mycompany.bd_proyecto1.dao.oracle;

import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.util.AccesoDatosException;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import oracle.jdbc.OracleTypes;

/**
 * Utilidades comunes de los DAO de Oracle: preparar llamadas a procedimientos, pasar valores que
 * pueden ser nulos, leer columnas de los cursores y traducir los códigos de resultado (pnResult)
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
final class UtilOracle {

    /** Tipo de parámetro de salida para un SYS_REFCURSOR. */
    static final int CURSOR = OracleTypes.CURSOR;

    private UtilOracle() {
        // Clase de utilidad: no se instancia.
    }

    // ------------------------------------------------------------------ llamadas

    // ------------------------------------------------------------------------
    // -------------------------- Llamadas y errores --------------------------
    // ------------------------------------------------------------------------

    /** Prepara una llamada como "{call pkg.procedimiento(?, ?)}" sobre la conexión única. */
    static CallableStatement preparar(String llamada) throws SQLException {
        return ConexionBD.obtener().prepareCall(llamada);
    }

    /** Envuelve un error de JDBC con la operación que se intentaba hacer. */
    static AccesoDatosException error(String operacion, SQLException e) {
        return new AccesoDatosException("Error de base de datos al " + operacion + ".\nDetalle: "
                + e.getMessage(), e);
    }

    /** Cursor de salida en la posición indicada (ya ejecutada la llamada). */
    static ResultSet cursor(CallableStatement llamada, int posicion) throws SQLException {
        return (ResultSet) llamada.getObject(posicion);
    }

    /** Revisa el código de resultado (pnResult) de un procedimiento. */
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

    /** Lee pnResult de la posición indicada y lo revisa. */
    static void revisar(CallableStatement llamada, int posicion, String operacion) throws SQLException {
        revisar(leerEntero(llamada, posicion), operacion);
    }

    // ------------------------------------------------------------------ parámetros de entrada

    // ------------------------------------------------------------------------
    // ------------------------ Parámetros de entrada -------------------------
    // ------------------------------------------------------------------------

    static void ponerNumero(CallableStatement llamada, int posicion, Integer valor) throws SQLException {
        if (valor == null) {
            llamada.setNull(posicion, Types.NUMERIC);
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
            llamada.setNull(posicion, Types.NUMERIC);
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

    static void ponerFecha(CallableStatement llamada, int posicion, LocalDate valor) throws SQLException {
        if (valor == null) {
            llamada.setNull(posicion, Types.DATE);
        } else {
            llamada.setDate(posicion, Date.valueOf(valor));
        }
    }

    static void ponerBooleano(CallableStatement llamada, int posicion, boolean valor) throws SQLException {
        llamada.setInt(posicion, valor ? 1 : 0);
    }

    // ------------------------------------------------------------------ parámetros de salida

    // ------------------------------------------------------------------------
    // ------------------------ Lectura de resultados -------------------------
    // ------------------------------------------------------------------------

    static Integer leerEntero(CallableStatement llamada, int posicion) throws SQLException {
        int valor = llamada.getInt(posicion);
        return llamada.wasNull() ? null : valor;
    }

    // ------------------------------------------------------------------ columnas de cursores

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

    static LocalDate fecha(ResultSet fila, String columna) throws SQLException {
        Timestamp valor = fila.getTimestamp(columna);
        return valor == null ? null : valor.toLocalDateTime().toLocalDate();
    }

    static LocalDateTime fechaHora(ResultSet fila, String columna) throws SQLException {
        Timestamp valor = fila.getTimestamp(columna);
        return valor == null ? null : valor.toLocalDateTime();
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

    // ------------------------------------------------------------------ listas sencillas

    // ------------------------------------------------------------------------
    // -------------------------- Catálogos simples ---------------------------
    // ------------------------------------------------------------------------

    /**
     * Ejecuta un procedimiento cuyo único parámetro es un cursor de salida con columnas id y
     * nombre, y retorna los elementos.
     */
    static List<ItemCatalogo> listarItems(String llamada, String columnaNombre, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.registerOutParameter(1, CURSOR);
            cs.execute();
            return leerItems(cursor(cs, 1), columnaNombre);
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    /** Igual que listarItems, para procedimientos (padre IN, cursor OUT). */
    static List<ItemCatalogo> listarItemsDe(String llamada, Integer idPadre, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            ponerNumero(cs, 1, idPadre);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            return leerItems(cursor(cs, 2), "name");
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    /** Lee un cursor con columnas id y nombre, y lo cierra. */
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
