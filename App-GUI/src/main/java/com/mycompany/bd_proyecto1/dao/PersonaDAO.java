package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Persona;
import java.util.List;

/**
 * Contrato de acceso a las personas del sistema (requisito 4.n).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface PersonaDAO {

    /** Lista las personas registradas. */
    List<ItemCatalogo> listar();

    /** Busca personas según los criterios indicados. */
    List<Persona> consultar(FiltroPersona filtro);

    /** Obtiene una persona con todos sus datos y contactos. */
    Persona obtener(int idPersona);

    /** Registra una persona. */
    int insertar(Persona persona);

    /** Actualiza todos los datos de una persona. */
    void actualizar(Persona persona);

    /** Indica si la persona está registrada como veterinaria. */
    boolean esVeterinario(int idPersona);

    /**
     * Registra a una persona existente como veterinaria. Desde ese momento aparece en la lista de
     * veterinarios del formulario de mascotas.
     */
    void registrarVeterinario(int idPersona);
}
