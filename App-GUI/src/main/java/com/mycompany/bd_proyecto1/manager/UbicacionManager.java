package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.util.List;

/**
 * Lugares registrados: listas para los combos (país > provincia > cantón > distrito) y la
 * validación de una ubicación, que comparten todos los módulos que piden un lugar.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class UbicacionManager {

    /** Largo de la columna Location.address. */
    public static final int MAX_SENAS = 255;

    private final CatalogoDAO catalogoDAO;

    public UbicacionManager() {
        this(Repositorios.catalogos());
    }

    public UbicacionManager(CatalogoDAO catalogoDAO) {
        this.catalogoDAO = catalogoDAO;
    }

    // ------------------------------------------------------------------------
    // ---------------- Listas para los combos ------------------------------
    // ------------------------------------------------------------------------

    public List<ItemCatalogo> listarPaises() {
        return catalogoDAO.listar(TipoCatalogo.PAIS);
    }

    public List<ItemCatalogo> listarProvincias(ItemCatalogo pais) {
        return hijos(TipoCatalogo.PROVINCIA, pais);
    }

    public List<ItemCatalogo> listarCantones(ItemCatalogo provincia) {
        return hijos(TipoCatalogo.CANTON, provincia);
    }

    public List<ItemCatalogo> listarDistritos(ItemCatalogo canton) {
        return hijos(TipoCatalogo.DISTRITO, canton);
    }

    private List<ItemCatalogo> hijos(TipoCatalogo tipo, ItemCatalogo padre) {
        return padre == null ? List.of() : catalogoDAO.listarHijos(tipo, padre.getId());
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Validación ------------------------------
    // ------------------------------------------------------------------------

    /** Valida una ubicación escrita en un formulario y limpia sus señas. */
    public Ubicacion validar(Ubicacion ubicacion, boolean senasObligatorias, String queEs) {
        Ubicacion u = ubicacion == null ? new Ubicacion() : ubicacion;
        exigir(u.getPais(), "el país", queEs);
        exigir(u.getProvincia(), "la provincia", queEs);
        exigir(u.getCanton(), "el cantón", queEs);
        exigir(u.getDistrito(), "el distrito", queEs);

        // Se revisa contra todos los elementos (también inactivos) para que un
        // registro viejo con un lugar desactivado se pueda volver a guardar.
        pertenece(TipoCatalogo.PROVINCIA, u.getPais(), u.getProvincia(), "La provincia no pertenece al país elegido.");
        pertenece(TipoCatalogo.CANTON, u.getProvincia(), u.getCanton(), "El cantón no pertenece a la provincia elegida.");
        pertenece(TipoCatalogo.DISTRITO, u.getCanton(), u.getDistrito(), "El distrito no pertenece al cantón elegido.");

        u.setSenas(Validador.limpiar(u.getSenas()));
        if (senasObligatorias && u.getSenas() == null) {
            throw new IllegalArgumentException("Indique las señas o dirección exacta (" + queEs + ").");
        }
        if (u.getSenas() != null && u.getSenas().length() > MAX_SENAS) {
            throw new IllegalArgumentException("Las señas no pueden superar los " + MAX_SENAS + " caracteres.");
        }
        return u;
    }

    private void exigir(ItemCatalogo nivel, String nombre, String queEs) {
        if (nivel == null) {
            throw new IllegalArgumentException("Seleccione " + nombre + " (" + queEs + ").");
        }
    }

    private void pertenece(TipoCatalogo tipo, ItemCatalogo padre, ItemCatalogo hijo, String mensaje) {
        if (!catalogoDAO.listarHijos(tipo, padre.getId()).contains(hijo)) {
            throw new IllegalArgumentException(mensaje);
        }
    }
}
