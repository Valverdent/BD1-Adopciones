package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.dao.MatchDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MascotaSinAdoptar;
import com.mycompany.bd_proyecto1.model.MatchMascotas;
import com.mycompany.bd_proyecto1.model.ResumenAdoptante;
import com.mycompany.bd_proyecto1.util.Validador;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Lógica de negocio de las consultas y reportes.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ReporteManager {

    private static final int MESES_MAXIMOS = 120;

    private final MatchDAO matchDAO;
    private final AdopcionDAO adopcionDAO;
    private final MascotaDAO mascotaDAO;
    private final CatalogoDAO catalogoDAO;

    public ReporteManager() {
        this(Repositorios.matches(), Repositorios.adopciones(), Repositorios.mascotas(), Repositorios.catalogos());
    }

    public ReporteManager(MatchDAO matchDAO, AdopcionDAO adopcionDAO, MascotaDAO mascotaDAO, CatalogoDAO catalogoDAO) {
        this.matchDAO = matchDAO;
        this.adopcionDAO = adopcionDAO;
        this.mascotaDAO = mascotaDAO;
        this.catalogoDAO = catalogoDAO;
    }

    public List<ItemCatalogo> listarTipos() {
        return catalogoDAO.listar(TipoCatalogo.TIPO_MASCOTA);
    }

    // ------------------------------------------------------------------------
    // ----------------- Conversión de números de la pantalla -----------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si no es un entero entre 0 y 100 */
    public int convertirPorcentaje(String texto) {
        int valor = convertirEntero(texto, "el porcentaje mínimo");
        if (valor < 0 || valor > 100) {
            throw new IllegalArgumentException("El porcentaje mínimo debe estar entre 0 y 100.");
        }
        return valor;
    }

    /** @throws IllegalArgumentException si no es un entero entre 0 y 3650 */
    public int convertirMeses(String texto) {
        int valor = convertirEntero(texto, "la cantidad de meses");
        if (valor < 0 || valor > MESES_MAXIMOS) {
            throw new IllegalArgumentException("La cantidad de meses debe estar entre 0 y " + MESES_MAXIMOS + ".");
        }
        return valor;
    }

    private int convertirEntero(String texto, String campo) {
        String t = Validador.limpiar(texto);
        if (t == null) {
            throw new IllegalArgumentException("Indique " + campo + ".");
        }
        try {
            return Integer.parseInt(t);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Indique " + campo + " como un número entero.");
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Matches --------------------------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si el porcentaje mínimo no está entre 0 y 100 */
    public List<MatchMascotas> generarMatches(int porcentajeMinimo, ItemCatalogo tipo) {
        if (porcentajeMinimo < 0 || porcentajeMinimo > 100) {
            throw new IllegalArgumentException("El porcentaje mínimo debe estar entre 0 y 100.");
        }
        return matchDAO.generarMatches(porcentajeMinimo, tipo);
    }

    // ------------------------------------------------------------------------
    // ----------------------- Adopciones por adoptante -----------------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si el rango de fechas no es válido */
    public List<ResumenAdoptante> consultarAdopcionesPorAdoptante(FiltroAdoptante filtro) {
        if (filtro.getFechaDesde() != null && filtro.getFechaHasta() != null
                && filtro.getFechaDesde().isAfter(filtro.getFechaHasta())) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
        return adopcionDAO.consultarPorAdoptante(filtro);
    }

    /** Total de adopciones de las filas indicadas (para mostrar el total de la consulta). */
    public int totalAdopciones(List<ResumenAdoptante> filas) {
        int total = 0;
        for (ResumenAdoptante f : filas) {
            total += f.getCantidadAdopciones();
        }
        return total;
    }

    // ------------------------------------------------------------------------
    // ------------------------- Mascotas sin adoptar -------------------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si los meses no están entre 0 y 120 */
    public List<MascotaSinAdoptar> listarSinAdoptar(int mesesMinimos, ItemCatalogo tipo) {
        if (mesesMinimos < 0 || mesesMinimos > MESES_MAXIMOS) {
            throw new IllegalArgumentException("La cantidad de meses debe estar entre 0 y " + MESES_MAXIMOS + ".");
        }
        LocalDate hoy = LocalDate.now();
        List<MascotaSinAdoptar> resultado = new ArrayList<>();
        for (Mascota m : mascotaDAO.listarSinAdoptar(mesesMinimos, tipo)) {
            resultado.add(new MascotaSinAdoptar(m, hoy));
        }
        return resultado;
    }
}
