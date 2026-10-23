package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Arma la Ubicacion de la aplicación (país, provincia, cantón, distrito y señas) a partir de las
 * columnas de los cursores.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
final class LugaresOracle {

    private LugaresOracle() {
        // Clase de utilidad: no se instancia.
    }

    /** País de cada provincia: id de la provincia -> país (id y nombre). */
    static Map<Integer, ItemCatalogo> paisesPorProvincia() {
        Map<Integer, ItemCatalogo> paises = new HashMap<>();
        for (Fila pais : catalogo("COUNTRY")) {
            paises.put(pais.id, new ItemCatalogo(pais.id, pais.nombre));
        }
        Map<Integer, ItemCatalogo> porProvincia = new HashMap<>();
        for (Fila provincia : catalogo("PROVINCE")) {
            porProvincia.put(provincia.id, paises.get(provincia.idPadre));
        }
        return porProvincia;
    }

    /**
     * Ubicación con las columnas de nombres habituales: provinceId, provinceName, cantonId,
     * cantonName, districtId, districtName y address. Retorna null si la fila no tiene distrito.
     */
    static Ubicacion ubicacion(ResultSet fila, Map<Integer, ItemCatalogo> paises) throws SQLException {
        ItemCatalogo distrito = item(fila, "districtId", "districtName");
        if (distrito == null) {
            return null;
        }
        ItemCatalogo provincia = item(fila, "provinceId", "provinceName");
        return new Ubicacion(provincia == null ? null : paises.get(provincia.getId()), provincia,
                item(fila, "cantonId", "cantonName"), distrito, texto(fila, "address"));
    }

    // ------------------------------------------------------------------ auxiliares

    private record Fila(int id, String nombre, Integer idPadre) {
    }

    /** PKG_CATALOG.PR_GET_CATALOG con padre NULL: todos los elementos con su padre. */
    private static List<Fila> catalogo(String codigo) {
        List<Fila> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_catalog.pr_get_catalog(?, ?, ?, ?)}")) {
            cs.setString(1, codigo);
            cs.setNull(2, Types.NUMERIC);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "consultar los lugares");
            try (ResultSet fila = cursor(cs, 3)) {
                while (fila.next()) {
                    filas.add(new Fila(fila.getInt("id"), texto(fila, "name"), entero(fila, "idParent")));
                }
            }
        } catch (SQLException e) {
            throw error("consultar los lugares", e);
        }
        return filas;
    }
}
