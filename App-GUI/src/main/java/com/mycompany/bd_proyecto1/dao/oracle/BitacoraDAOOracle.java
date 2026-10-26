package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.BitacoraDAO;
import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación de BitacoraDAO con Oracle (PKG_QUERIES_EXTRAS.PR_GET_CHANGELOG, que lee
 * ADOPCION_AUDIT.ChangeLog).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class BitacoraDAOOracle implements BitacoraDAO {

    @Override
    public List<RegistroBitacora> consultar(FiltroBitacora filtro) {
        List<RegistroBitacora> registros = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_queries_extras.pr_get_changelog(?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            ponerTexto(cs, 1, filtro.getUsuario());
            ponerTexto(cs, 2, filtro.getTabla());
            ponerTexto(cs, 3, filtro.getCampo());
            ponerTexto(cs, 4, filtro.getIdRegistro() == null ? null : String.valueOf(filtro.getIdRegistro()));
            ponerTexto(cs, 5, filtro.getTexto());
            ponerFecha(cs, 6, filtro.getFechaDesde());
            ponerFecha(cs, 7, filtro.getFechaHasta());
            cs.registerOutParameter(8, CURSOR);
            cs.registerOutParameter(9, Types.NUMERIC);
            cs.execute();
            revisar(cs, 9, "consultar la bitácora (revise que ADOPCION_APP pueda leer ADOPCION_AUDIT.ChangeLog)");
            try (ResultSet fila = cursor(cs, 8)) {                // del más reciente al más antiguo
                while (fila.next()) {
                    RegistroBitacora r = new RegistroBitacora();
                    r.setId(fila.getInt("id"));
                    r.setNombreUsuario(texto(fila, "username"));
                    r.setTabla(texto(fila, "tableName"));
                    r.setCampo(texto(fila, "fieldName"));
                    r.setIdRegistro(numero(texto(fila, "recordId")));
                    r.setValorAnterior(texto(fila, "oldValue"));
                    r.setValorNuevo(texto(fila, "newValue"));
                    r.setDescripcion(texto(fila, "changeDescription"));
                    r.setFecha(fechaHora(fila, "changeDate"));
                    registros.add(r);
                }
            }
        } catch (SQLException e) {
            throw error("consultar la bitácora", e);
        }
        return registros;
    }

    @Override
    public List<String> listarTablas() {
        List<String> tablas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_queries_extras.pr_get_changelog_tables(?, ?)}")) {
            cs.registerOutParameter(1, CURSOR);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.execute();
            revisar(cs, 2, "consultar las tablas de la bitácora");
            try (ResultSet fila = cursor(cs, 1)) {
                while (fila.next()) {
                    tablas.add(texto(fila, "tableName"));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las tablas de la bitácora", e);
        }
        return tablas;
    }

    /** El id del registro se guarda como texto en la bitácora; 0 si no es un número. */
    private static int numero(String texto) {
        try {
            return texto == null ? 0 : Integer.parseInt(texto.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
