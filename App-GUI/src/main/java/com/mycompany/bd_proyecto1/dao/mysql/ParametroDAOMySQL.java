package com.mycompany.bd_proyecto1.dao.mysql;

import static com.mycompany.bd_proyecto1.dao.mysql.UtilMySQL.*;

import com.mycompany.bd_proyecto1.dao.ParametroDAO;
import com.mycompany.bd_proyecto1.model.Parametro;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación de ParametroDAO con MySQL. Misma lógica que la versión de Oracle: los
 * procedimientos se llaman igual, sin el paquete y sin el parámetro del cursor.
 *
 * @author Carlos Hidalgo
 * @since 2026-11-15
 */
public class ParametroDAOMySQL implements ParametroDAO {

    @Override
    public List<Parametro> listar() {
        List<Parametro> parametros = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pr_get_parameters(?)}")) {
            cs.setNull(1, Types.VARCHAR);                   // NULL = todos los parámetros
            cs.execute();
            try (ResultSet fila = resultado(cs)) {
                while (fila.next()) {
                    Parametro p = new Parametro();
                    p.setId(fila.getInt("id"));
                    p.setNombre(texto(fila, "name"));
                    p.setDescripcion(texto(fila, "description"));
                    BigDecimal numero = decimal(fila, "numberValue");
                    p.setNumerico(numero != null);
                    p.setValor(numero != null ? numero.stripTrailingZeros().toPlainString()
                            : texto(fila, "textValue"));
                    parametros.add(p);
                }
            }
        } catch (SQLException e) {
            throw error("consultar los parámetros", e);
        }
        return parametros;
    }

    @Override
    public void actualizarValor(int id, String valor) {
        Parametro actual = listar().stream()
                .filter(p -> p.getId() == id)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("No existe el parámetro indicado."));

        try (CallableStatement cs = preparar("{call pr_update_parameter(?, ?, ?, ?)}")) {
            cs.setInt(1, id);
            if (actual.isNumerico()) {
                cs.setNull(2, Types.VARCHAR);
                cs.setBigDecimal(3, new BigDecimal(valor.trim()));
            } else {
                ponerTexto(cs, 2, valor);
                cs.setNull(3, Types.NUMERIC);
            }
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "cambiar el parámetro");
        } catch (SQLException e) {
            throw error("cambiar el parámetro", e);
        }
    }
}
