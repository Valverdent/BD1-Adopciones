package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.EstadisticaDAO;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.dao.ParametroDAO;
import com.mycompany.bd_proyecto1.model.ConteoMascotas;
import com.mycompany.bd_proyecto1.model.ConteoPorCanton;
import com.mycompany.bd_proyecto1.model.FilaPorcentaje;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Parametro;
import com.mycompany.bd_proyecto1.model.ResumenAdopciones;
import com.mycompany.bd_proyecto1.model.TotalPorRescatista;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Porcentajes;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementación de EstadisticaDAO con DATOS DE PRUEBA en memoria: cuenta sobre las mascotas que
 * ya existen en memoria, con los mismos criterios que el paquete PKG_STATISTICS.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class EstadisticaDAOMemoria implements EstadisticaDAO {

    private final MascotaDAO mascotaDAO;
    /** Para los límites de los rangos de edad (AGE_LIMIT_1 a AGE_LIMIT_5). */
    private final ParametroDAO parametroDAO;

    public EstadisticaDAOMemoria(MascotaDAO mascotaDAO, ParametroDAO parametroDAO) {
        this.mascotaDAO = mascotaDAO;
        this.parametroDAO = parametroDAO;
    }

    @Override
    public List<ConteoMascotas> contarMascotasPorTipoYEstado(LocalDate desde, LocalDate hasta) {
        Map<String, ConteoMascotas> conteos = new LinkedHashMap<>();
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if ((desde != null && m.getFechaEvento().isBefore(desde))
                    || (hasta != null && m.getFechaEvento().isAfter(hasta))) {
                continue;
            }
            String clave = m.getTipo().getId() + "-" + m.getEstado().getId();
            ConteoMascotas c = conteos.get(clave);
            if (c == null) {
                c = new ConteoMascotas(m.getTipo(), m.getEstado(), 0);
                conteos.put(clave, c);
            }
            c.setCantidad(c.getCantidad() + 1);
        }
        List<ConteoMascotas> resultado = new ArrayList<>(conteos.values());
        resultado.sort(Comparator.comparingInt((ConteoMascotas c) -> c.getTipo().getId())
                .thenComparingInt(c -> c.getEstado().getId()));
        return resultado;
    }

    @Override
    public ResumenAdopciones resumirAdopciones(ItemCatalogo tipo, ItemCatalogo raza) {
        int adoptadas = 0;
        int enEspera = 0;
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if ((tipo != null && !tipo.equals(m.getTipo())) || (raza != null && !raza.equals(m.getRaza()))) {
                continue;
            }
            if (DatosPrueba.ADOPTADA.equals(m.getEstado())) {
                adoptadas++;
            } else if (DatosPrueba.EN_ADOPCION.equals(m.getEstado())) {
                enEspera++;
            }
        }
        return new ResumenAdopciones(adoptadas, enEspera);
    }

    /**
     * Mismos rangos que PKG_STATISTICS.PR_STAT_UNADOPTED_AGE: hasta AGE_LIMIT_1, de AGE_LIMIT_1 a
     * AGE_LIMIT_2 ... y más de AGE_LIMIT_5 (límite superior incluido).
     */
    @Override
    public List<FilaPorcentaje> contarNoAdoptadasPorEdad() {
        int[] limites = limitesDeEdad();
        Map<String, Integer> porRango = new LinkedHashMap<>();
        for (int i = 0; i <= limites.length; i++) {
            porRango.put(etiquetaDeRango(limites, i), 0);
        }
        int total = 0;
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            if (DatosPrueba.ADOPTADA.equals(m.getEstado()) || m.getEdadEstimada() == null) {
                continue;
            }
            int indice = limites.length;
            for (int i = limites.length - 1; i >= 0; i--) {
                if (m.getEdadEstimada() <= limites[i]) {
                    indice = i;
                }
            }
            porRango.merge(etiquetaDeRango(limites, indice), 1, Integer::sum);
            total++;
        }
        List<FilaPorcentaje> filas = new ArrayList<>();
        for (Map.Entry<String, Integer> e : porRango.entrySet()) {
            if (e.getValue() > 0) {                     // la base solo devuelve rangos con mascotas
                filas.add(new FilaPorcentaje(e.getKey(), e.getValue(), Porcentajes.de(e.getValue(), total)));
            }
        }
        return filas;
    }

    private int[] limitesDeEdad() {
        int[] limites = new int[5];
        for (Parametro p : parametroDAO.listar()) {
            if (p.getNombre().startsWith("AGE_LIMIT_")) {
                limites[Integer.parseInt(p.getNombre().substring("AGE_LIMIT_".length())) - 1] =
                        Integer.parseInt(p.getValor());
            }
        }
        return limites;
    }

    private static String etiquetaDeRango(int[] limites, int indice) {
        if (indice == 0) {
            return "0 - " + limites[0];
        }
        if (indice == limites.length) {
            return limites[limites.length - 1] + " +";
        }
        return limites[indice - 1] + " - " + limites[indice];
    }

    @Override
    public List<ConteoPorCanton> contarPerdidasYEncontradasPorCanton(LocalDate desde, LocalDate hasta) {
        Map<String, Integer> conteos = new LinkedHashMap<>();
        int total = 0;
        for (Mascota m : mascotaDAO.consultar(new FiltroMascota())) {
            boolean perdidaOEncontrada = DatosPrueba.PERDIDA.equals(m.getEstado())
                    || DatosPrueba.ENCONTRADA.equals(m.getEstado());
            if (!perdidaOEncontrada || m.getUbicacion() == null
                    || (desde != null && m.getFechaEvento().isBefore(desde))
                    || (hasta != null && m.getFechaEvento().isAfter(hasta))) {
                continue;
            }
            conteos.merge(m.getUbicacion().getCanton().getNombre() + "|" + m.getEstado().getNombre(), 1, Integer::sum);
            total++;
        }
        List<ConteoPorCanton> filas = new ArrayList<>();
        for (Map.Entry<String, Integer> e : conteos.entrySet()) {
            String[] partes = e.getKey().split("\\|");
            filas.add(new ConteoPorCanton(partes[0], partes[1], e.getValue(), Porcentajes.de(e.getValue(), total)));
        }
        filas.sort(Comparator.comparingInt(ConteoPorCanton::getCantidad).reversed());
        return filas;
    }

    @Override
    public List<TotalPorRescatista> totalizarDonacionesPorRescatista(LocalDate desde, LocalDate hasta) {
        // Los datos de prueba no guardan qué recompensa se donó con cada donación
        throw new IntegracionPendienteException("donaciones por rescatista (solo con la base de datos)");
    }
}
