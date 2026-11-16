package com.mycompany.bd_proyecto1.dao.mysql;

import static com.mycompany.bd_proyecto1.dao.mysql.UtilMySQL.*;

import com.mycompany.bd_proyecto1.dao.AsociacionDAO;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Implementación de AsociacionDAO con MySQL. Misma lógica que la versión de Oracle: los
 * procedimientos se llaman igual, sin el paquete y sin el parámetro del cursor.
 *
 * @author Carlos Hidalgo
 * @since 2026-11-15
 */
public class AsociacionDAOMySQL implements AsociacionDAO {

    @Override
    public List<AsociacionBienestar> listar() {
        Map<Integer, ItemCatalogo> paises = LugaresMySQL.paisesPorProvincia();
        List<AsociacionBienestar> asociaciones = new ArrayList<>();
        try (CallableStatement cs = preparar(
                "{call pr_get_associations_filtered(?, ?, ?, ?)}")) {
            cs.setNull(1, Types.NUMERIC);
            cs.setNull(2, Types.NUMERIC);
            cs.setNull(3, Types.NUMERIC);
            cs.setNull(4, Types.NUMERIC);
            cs.execute();
            try (ResultSet fila = resultado(cs)) {                // ordenadas por nombre
                while (fila.next()) {
                    asociaciones.add(new AsociacionBienestar(fila.getInt("associationId"),
                            texto(fila, "associationName"), LugaresMySQL.ubicacion(fila, paises)));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las asociaciones", e);
        }
        return asociaciones;
    }

    @Override
    public int insertar(AsociacionBienestar asociacion) {
        try (CallableStatement cs = preparar(
                "{call pr_register_association(?, ?, ?, ?, ?)}")) {
            ponerTexto(cs, 1, asociacion.getNombre());
            ponerId(cs, 2, asociacion.getUbicacion().getDistrito());
            ponerTexto(cs, 3, asociacion.getUbicacion().getSenas());
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            revisar(cs, 5, "registrar la asociación");
            asociacion.setId(cs.getInt(4));
            return asociacion.getId();
        } catch (SQLException e) {
            throw error("registrar la asociación", e);
        }
    }

    @Override
    public void actualizar(AsociacionBienestar asociacion) {
        try (CallableStatement cs = preparar(
                "{call pr_update_association(?, ?, ?, ?, ?)}")) {
            cs.setInt(1, asociacion.getId());
            ponerTexto(cs, 2, asociacion.getNombre());
            ponerId(cs, 3, asociacion.getUbicacion().getDistrito());
            ponerTexto(cs, 4, asociacion.getUbicacion().getSenas());
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            revisar(cs, 5, "actualizar la asociación");
        } catch (SQLException e) {
            throw error("actualizar la asociación", e);
        }
    }

    @Override
    public boolean existeNombre(String nombre, int idExcluir) {
        // FN_ASSOCIATION_EXISTS no permite excluir la asociación que se edita: se compara aquí
        for (AsociacionBienestar a : listar()) {
            if (a.getId() != idExcluir && a.getNombre().equalsIgnoreCase(nombre.trim())) {
                return true;
            }
        }
        return false;
    }
}
