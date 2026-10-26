package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.MatchDAO;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MatchMascotas;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Implementación de MatchDAO con Oracle (PKG_PET_ADMINISTRATION.PR_MATCH_LOST_FOUND, el mismo que
 * usa el job).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MatchDAOOracle implements MatchDAO {

    private final MascotaDAOOracle mascotas = new MascotaDAOOracle();

    @Override
    public List<MatchMascotas> generarMatches(int porcentajeMinimo, ItemCatalogo tipo) {
        int minimoBase = (int) numeroParametro("MATCH_MIN_SCORE");
        if (porcentajeMinimo < minimoBase) {
            throw new IllegalArgumentException("La base solo calcula los matches desde " + minimoBase
                    + " % (parámetro MATCH_MIN_SCORE). Escriba un mínimo de " + minimoBase + " o más.");
        }
        Map<Integer, Mascota> cache = new HashMap<>();
        List<MatchMascotas> resultado = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_match_lost_found(?, ?)}")) {
            cs.registerOutParameter(1, CURSOR);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.execute();
            revisar(cs, 2, "calcular los matches");
            try (ResultSet fila = cursor(cs, 1)) {          // ordenado por puntaje descendente
                while (fila.next()) {
                    int puntaje = fila.getInt("matchScore");
                    if (puntaje < porcentajeMinimo) {
                        continue;
                    }
                    Mascota perdida = cache.computeIfAbsent(fila.getInt("lostPetId"), mascotas::buscar);
                    Mascota encontrada = cache.computeIfAbsent(fila.getInt("foundPetId"), mascotas::buscar);
                    if (perdida == null || encontrada == null || (tipo != null && !tipo.equals(perdida.getTipo()))) {
                        continue;
                    }
                    MatchMascotas match = new MatchMascotas();
                    match.setPerdida(perdida);
                    match.setEncontrada(encontrada);
                    match.setPorcentaje(Math.min(puntaje, 100));
                    match.setCriterios(criterios(perdida, encontrada));
                    resultado.add(match);
                }
            }
        } catch (SQLException e) {
            throw error("calcular los matches", e);
        }
        return resultado;
    }

    /** Características que suman puntos en la base (mismo tipo es condición para comparar). */
    private static List<String> criterios(Mascota p, Mascota e) {
        List<String> criterios = new ArrayList<>();
        criterios.add("Mismo tipo");
        if (Objects.equals(p.getRaza(), e.getRaza())) {
            criterios.add("Misma raza");
        }
        if (Objects.equals(p.getColor(), e.getColor())) {
            criterios.add("Mismo color");
        }
        if (Objects.equals(p.getTamano(), e.getTamano())) {
            criterios.add("Mismo tamaño");
        }
        if (p.getUbicacion() != null && e.getUbicacion() != null
                && Objects.equals(p.getUbicacion().getCanton(), e.getUbicacion().getCanton())) {
            criterios.add("Mismo cantón");
        }
        if (p.getChip() != null && p.getChip().equalsIgnoreCase(e.getChip())) {
            criterios.add("Mismo chip");
        }
        return criterios;
    }

    /** PKG_PARAMETER.FN_GET_NUMBER. */
    static double numeroParametro(String nombre) {
        try (CallableStatement cs = preparar("{? = call pkg_parameter.fn_get_number(?)}")) {
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setString(2, nombre);
            cs.execute();
            return cs.getDouble(1);
        } catch (SQLException e) {
            throw error("leer el parámetro " + nombre, e);
        }
    }
}
