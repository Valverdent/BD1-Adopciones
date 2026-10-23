package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CasaCunaDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.util.List;
import java.util.Optional;

/**
 * Lógica de negocio de las casas cuna (hogares temporales).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCunaManager {


    private final CasaCunaDAO casaCunaDAO;
    private final CatalogoDAO catalogoDAO;
    private final PersonaDAO personaDAO;
    private final UbicacionManager ubicacionManager;

    public CasaCunaManager() {
        this(Repositorios.casasCuna(), Repositorios.catalogos(), Repositorios.personas());
    }

    public CasaCunaManager(CasaCunaDAO casaCunaDAO, CatalogoDAO catalogoDAO, PersonaDAO personaDAO) {
        this.casaCunaDAO = casaCunaDAO;
        this.catalogoDAO = catalogoDAO;
        this.personaDAO = personaDAO;
        this.ubicacionManager = new UbicacionManager(catalogoDAO);
    }

    // ------------------------------------------------------------------------
    // ----------------------- Listas para la pantalla ------------------------
    // ------------------------------------------------------------------------

    public List<ItemCatalogo> listarCatalogo(TipoCatalogo tipo) {
        return catalogoDAO.listar(tipo);
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    public List<CasaCuna> consultar(FiltroCasaCuna filtro) {
        return casaCunaDAO.consultar(filtro);
    }

    /** La casa cuna de la persona en sesión, si la tiene. */
    public Optional<CasaCuna> miCasaCuna() {
        Usuario usuario = Sesion.getUsuario();
        return usuario == null ? Optional.empty() : casaCunaDAO.buscarPorPersona(usuario.getIdPersona());
    }

    public boolean puedeEditar(CasaCuna casa) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || casa == null) {
            return false;
        }
        return usuario.esAdministrador() || casa.getIdPersona() == usuario.getIdPersona();
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Guardar --------------------------------
    // ------------------------------------------------------------------------

    /**
     * Valida y guarda una casa cuna. Si esNueva, se registra para la persona en sesión (o la
     * indicada en la casa si es administrador).
     */
    public void guardar(CasaCuna casa, boolean esNueva) {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null) {
            throw new IllegalStateException("Debe iniciar sesión.");
        }
        if (esNueva) {
            if (casa.getIdPersona() == 0 || !usuario.esAdministrador()) {
                casa.setIdPersona(usuario.getIdPersona());
            }
            if (casaCunaDAO.buscarPorPersona(casa.getIdPersona()).isPresent()) {
                throw new IllegalStateException("Esa persona ya tiene una casa cuna registrada; edítela en lugar de crear otra.");
            }
        } else if (!puedeEditar(casa)) {
            throw new IllegalStateException("Solo el dueño de la casa cuna o un administrador puede editarla.");
        }

        casa.setUbicacion(ubicacionManager.validar(casa.getUbicacion(), true, "lugar de la casa cuna"));
        if (casa.getEstado() == null) {
            throw new IllegalArgumentException("Seleccione el estado de la casa cuna.");
        }
        if (casa.getCapacidadMaxima() <= 0) {
            throw new IllegalArgumentException("La capacidad máxima debe ser mayor que cero.");
        }
        // Las mascotas que tiene ahora las cuenta la base; no puede quedar con menos capacidad
        if (casa.getCapacidadMaxima() < casa.getCantidadActual()) {
            throw new IllegalArgumentException("La capacidad máxima no puede ser menor que las mascotas que tiene ahora ("
                    + casa.getCantidadActual() + ").");
        }
        if (casa.getTamanos().isEmpty()) {
            throw new IllegalArgumentException("Seleccione al menos un tamaño de mascota que acepta.");
        }
        if (casa.getTipos().isEmpty()) {
            throw new IllegalArgumentException("Seleccione al menos un tipo de mascota que acepta.");
        }
        Persona dueno = personaDAO.obtener(casa.getIdPersona());
        if (dueno.getTelefonos().isEmpty() && dueno.getCorreos().isEmpty()) {
            throw new IllegalArgumentException("La persona debe tener al menos un teléfono o correo para que la contacten.");
        }

        if (esNueva) {
            casaCunaDAO.insertar(casa);
        } else {
            casaCunaDAO.actualizar(casa);
        }
    }

    // ------------------------------------------------------------------------
    // ---------------- Conversión de números para la pantalla ----------------
    // ------------------------------------------------------------------------

    /** @throws IllegalArgumentException si el texto no es un entero */
    public static int convertirEntero(String texto, String campo) {
        String t = Validador.limpiar(texto);
        if (t == null) {
            throw new IllegalArgumentException("Indique " + campo + ".");
        }
        try {
            return Integer.parseInt(t);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(campo.substring(0, 1).toUpperCase() + campo.substring(1)
                    + " debe ser un número entero.");
        }
    }
}
