package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.EstadisticaDAO;
import com.mycompany.bd_proyecto1.model.ConteoMascotas;
import com.mycompany.bd_proyecto1.model.ConteoPorCanton;
import com.mycompany.bd_proyecto1.model.FilaPorcentaje;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.ResumenAdopciones;
import com.mycompany.bd_proyecto1.model.TotalPorRescatista;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación de EstadisticaDAO con Oracle (paquete PKG_STATISTICS).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class EstadisticaDAOOracle implements EstadisticaDAO {

    @Override
    public List<ConteoMascotas> contarMascotasPorTipoYEstado(LocalDate desde, LocalDate hasta) {
        List<ConteoMascotas> conteos = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_statistics.pr_stat_pets_status(?, ?, ?, ?)}")) {
            ponerFecha(cs, 1, desde);
            ponerFecha(cs, 2, hasta);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "calcular las mascotas por tipo y estado");
            try (ResultSet fila = cursor(cs, 3)) {
                while (fila.next()) {
                    conteos.add(new ConteoMascotas(new ItemCatalogo(0, texto(fila, "typeName")),
                            new ItemCatalogo(0, texto(fila, "statusName")), fila.getInt("total")));
                }
            }
        } catch (SQLException e) {
            throw error("calcular las mascotas por tipo y estado", e);
        }
        return conteos;
    }

    @Override
    public ResumenAdopciones resumirAdopciones(ItemCatalogo tipo, ItemCatalogo raza) {
        String adoptada = UsuarioDAOOracle.textoDeFuncion("{? = call pkg_parameter.fn_get_text('PET_STATUS_ADOPTED')}");
        int adoptadas = 0;
        int enEspera = 0;
        try (CallableStatement cs = preparar("{call pkg_statistics.pr_stat_adoption_rate(?, ?, ?, ?)}")) {
            ponerId(cs, 1, tipo);
            ponerId(cs, 2, raza);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "calcular las adopciones");
            try (ResultSet fila = cursor(cs, 3)) {                // solo "Adoptada" y "En adopción"
                while (fila.next()) {
                    if (texto(fila, "statusName").equalsIgnoreCase(adoptada)) {
                        adoptadas = fila.getInt("total");
                    } else {
                        enEspera = fila.getInt("total");
                    }
                }
            }
        } catch (SQLException e) {
            throw error("calcular las adopciones", e);
        }
        return new ResumenAdopciones(adoptadas, enEspera);
    }

    @Override
    public List<FilaPorcentaje> contarNoAdoptadasPorEdad() {
        List<FilaPorcentaje> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_statistics.pr_stat_unadopted_age(?, ?)}")) {
            cs.registerOutParameter(1, CURSOR);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.execute();
            revisar(cs, 2, "calcular las mascotas no adoptadas por edad");
            try (ResultSet fila = cursor(cs, 1)) {
                while (fila.next()) {
                    filas.add(new FilaPorcentaje(texto(fila, "ageRange"), fila.getInt("total"),
                            decimal(fila, "percentage")));
                }
            }
        } catch (SQLException e) {
            throw error("calcular las mascotas no adoptadas por edad", e);
        }
        return filas;
    }

    @Override
    public List<ConteoPorCanton> contarPerdidasYEncontradasPorCanton(LocalDate desde, LocalDate hasta) {
        List<ConteoPorCanton> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_statistics.pr_stat_pets_by_canton(?, ?, ?, ?)}")) {
            ponerFecha(cs, 1, desde);
            ponerFecha(cs, 2, hasta);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "calcular las mascotas por cantón");
            try (ResultSet fila = cursor(cs, 3)) {
                while (fila.next()) {
                    filas.add(new ConteoPorCanton(texto(fila, "cantonName"), texto(fila, "statusType"),
                            fila.getInt("totalIncidents"), decimal(fila, "percentage")));
                }
            }
        } catch (SQLException e) {
            throw error("calcular las mascotas por cantón", e);
        }
        return filas;
    }

    @Override
    public List<TotalPorRescatista> totalizarDonacionesPorRescatista(LocalDate desde, LocalDate hasta) {
        List<TotalPorRescatista> filas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_statistics.pr_stat_donations_by_rescuer(?, ?, ?, ?)}")) {
            ponerFecha(cs, 1, desde);
            ponerFecha(cs, 2, hasta);
            cs.registerOutParameter(3, CURSOR);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "calcular las donaciones por rescatista");   // este no asigna 0 al salir bien
            try (ResultSet fila = cursor(cs, 3)) {
                while (fila.next()) {
                    filas.add(new TotalPorRescatista(texto(fila, "rescuerName"), texto(fila, "currencyName"),
                            decimal(fila, "total"), decimal(fila, "percentage")));
                }
            }
        } catch (SQLException e) {
            throw error("calcular las donaciones por rescatista", e);
        }
        return filas;
    }
}
