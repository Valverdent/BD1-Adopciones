package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

/**
 * Reglas de la administración de catálogos (requisito 12).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class CatalogoManager {

    /** Largo máximo del nombre de un elemento de catálogo. */
    public static final int LARGO_MAXIMO_NOMBRE = 60;

    /** Catálogos que la aplicación usa internamente: solo se consultan. */
    private static final Set<TipoCatalogo> SOLO_LECTURA =
            EnumSet.of(TipoCatalogo.ESTADO_MASCOTA, TipoCatalogo.MONEDA,
                    TipoCatalogo.VETERINARIO, TipoCatalogo.ESTADO_CASA_CUNA);

    private final CatalogoDAO catalogoDAO;

    public CatalogoManager() {
        this(Repositorios.catalogos());
    }

    public CatalogoManager(CatalogoDAO catalogoDAO) {
        this.catalogoDAO = catalogoDAO;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    /** Todos los catálogos, en el orden en que se muestran. */
    public List<TipoCatalogo> listarCatalogos() {
        return List.of(TipoCatalogo.values());
    }

    public boolean esEditable(TipoCatalogo tipo) {
        return tipo != null && !SOLO_LECTURA.contains(tipo);
    }

    /** Tipos de mascota activos, para elegir el tipo de las razas. */
    public List<ItemCatalogo> listarTiposDeMascota() {
        return catalogoDAO.listar(TipoCatalogo.TIPO_MASCOTA);
    }

    /** Nombre del catálogo padre, para las etiquetas y los mensajes ("tipo de mascota", "país"...). */
    public static String nombrePadre(TipoCatalogo tipo) {
        if (tipo == null || !tipo.tienePadre()) {
            return "";
        }
        return switch (tipo.getPadre()) {
            case TIPO_MASCOTA -> "tipo de mascota";
            case PAIS -> "país";
            case PROVINCIA -> "provincia";
            case CANTON -> "cantón";
            default -> tipo.getPadre().name().toLowerCase();
        };
    }

    /**
     * Elementos de la tabla. Para un catálogo con padre se necesita el padre; sin él la lista va
     * vacía.
     */
    public List<ItemCatalogo> elementos(TipoCatalogo tipo, ItemCatalogo padre) {
        if (tipo.tienePadre()) {
            return padre == null ? List.of() : catalogoDAO.listarHijos(tipo, padre.getId());
        }
        return catalogoDAO.listar(tipo);
    }

    // ------------------------------------------------------------------------
    // ----------------------- Cambios en los catálogos -----------------------
    // ------------------------------------------------------------------------

    /** Agrega un elemento al catálogo. Si el catálogo tiene padre, el padre es obligatorio. */
    public int agregar(TipoCatalogo tipo, ItemCatalogo padre, String nombre) {
        validarAdministrador();
        validarEditable(tipo);
        if (tipo.tienePadre()) {
            requerirPadre(tipo, padre);
        }
        String limpio = validarNombre(nombre);
        validarNoRepetido(tipo, padre, limpio, null);
        if (tipo.tienePadre()) {
            return catalogoDAO.insertarHijo(tipo, padre.getId(), limpio);
        }
        return catalogoDAO.insertar(tipo, limpio);
    }

    /**
     * Cambia el nombre de un elemento. Puede dejar el mismo nombre (solo cambian mayúsculas o
     * espacios); no puede repetir el de otro elemento.
     */
    public void cambiarNombre(TipoCatalogo tipo, ItemCatalogo padre, ItemCatalogo elemento, String nombre) {
        validarAdministrador();
        validarEditable(tipo);
        requerirElemento(elemento);
        if (tipo.tienePadre()) {
            requerirPadre(tipo, padre);
        }
        String limpio = validarNombre(nombre);
        validarNoRepetido(tipo, padre, limpio, elemento.getId());
        catalogoDAO.actualizar(tipo, elemento.getId(), limpio);
    }

    /** Elimina un elemento. */
    public void eliminar(TipoCatalogo tipo, ItemCatalogo elemento) {
        validarAdministrador();
        validarEditable(tipo);
        requerirElemento(elemento);
        catalogoDAO.eliminar(tipo, elemento.getId());
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Validaciones -----------------------------
    // ------------------------------------------------------------------------

    private String validarNombre(String nombre) {
        String limpio = nombre == null ? "" : nombre.trim();
        if (limpio.isEmpty()) {
            throw new IllegalArgumentException("El nombre no puede estar vacío.");
        }
        if (limpio.length() > LARGO_MAXIMO_NOMBRE) {
            throw new IllegalArgumentException("El nombre no puede tener más de " + LARGO_MAXIMO_NOMBRE + " caracteres.");
        }
        return limpio;
    }

    /** Compara sin importar mayúsculas, dentro del mismo catálogo (o del mismo padre). */
    private void validarNoRepetido(TipoCatalogo tipo, ItemCatalogo padre, String nombre, Integer idExcluido) {
        for (ItemCatalogo elemento : elementos(tipo, padre)) {
            boolean esOtro = idExcluido == null || elemento.getId() != idExcluido;
            if (esOtro && elemento.getNombre().equalsIgnoreCase(nombre)) {
                throw new IllegalArgumentException("Ya existe «" + elemento.getNombre() + "» en este catálogo.");
            }
        }
    }

    private void validarEditable(TipoCatalogo tipo) {
        if (!esEditable(tipo)) {
            throw new IllegalArgumentException("Este catálogo es de solo lectura: lo usa la lógica de la aplicación.");
        }
    }

    private void requerirPadre(TipoCatalogo tipo, ItemCatalogo padre) {
        if (padre == null) {
            String articulo = tipo.getPadre() == TipoCatalogo.PROVINCIA ? "la " : "el ";
            throw new IllegalArgumentException("Elija primero " + articulo + nombrePadre(tipo) + ".");
        }
    }

    private void requerirElemento(ItemCatalogo elemento) {
        if (elemento == null) {
            throw new IllegalArgumentException("Seleccione un elemento de la tabla.");
        }
    }

    private void validarAdministrador() {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || !usuario.esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede cambiar los catálogos.");
        }
    }
}
