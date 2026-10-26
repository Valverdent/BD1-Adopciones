package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Persona;
import java.text.Collator;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * Implementación de PersonaDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaDAOMemoria implements PersonaDAO {

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));
    private final List<Persona> personas = DatosPrueba.crearPersonas();
    private int siguienteId = personas.size() + 1;
    /**
     * Personas registradas como veterinarias en esta sesión. Los veterinarios de ejemplo de
     * VETERINARIOS no son personas.
     */
    private final Set<Integer> veterinarios = new HashSet<>();

    @Override
    public List<ItemCatalogo> listar() {
        List<ItemCatalogo> resultado = new ArrayList<>();
        for (Persona p : personas) {
            resultado.add(new ItemCatalogo(p.getId(), p.getNombreCompleto()));
        }
        resultado.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return resultado;
    }

    @Override
    public List<Persona> consultar(FiltroPersona filtro) {
        List<Persona> resultado = new ArrayList<>();
        for (Persona p : personas) {
            if (contiene(p.getNombreCompleto(), filtro.getNombre())
                    && filtro.getUbicacion().cumple(p.getUbicacion())) {
                resultado.add(copiar(p));
            }
        }
        resultado.sort((a, b) -> ordenEspanol.compare(a.getNombreCompleto(), b.getNombreCompleto()));
        return resultado;
    }

    @Override
    public Persona obtener(int idPersona) {
        for (Persona p : personas) {
            if (p.getId() == idPersona) {
                return copiar(p);
            }
        }
        throw new IllegalStateException("No existe la persona con id " + idPersona);
    }

    @Override
    public int insertar(Persona persona) {
        persona.setId(siguienteId);
        siguienteId++;
        personas.add(copiar(persona));
        return persona.getId();
    }

    @Override
    public void actualizar(Persona persona) {
        for (int i = 0; i < personas.size(); i++) {
            if (personas.get(i).getId() == persona.getId()) {
                personas.set(i, copiar(persona));
                return;
            }
        }
        throw new IllegalStateException("No existe la persona con id " + persona.getId());
    }

    @Override
    public boolean esVeterinario(int idPersona) {
        return veterinarios.contains(idPersona);
    }

    @Override
    public void registrarVeterinario(int idPersona) {
        obtener(idPersona);                         // error si la persona no existe
        veterinarios.add(idPersona);
    }

    private boolean contiene(String valor, String criterio) {
        if (criterio == null || criterio.isBlank()) {
            return true;
        }
        return valor != null && valor.toLowerCase().contains(criterio.trim().toLowerCase());
    }

    private Persona copiar(Persona o) {
        Persona c = new Persona();
        c.setId(o.getId());
        c.setNombre(o.getNombre());
        c.setSegundoNombre(o.getSegundoNombre());
        c.setPrimerApellido(o.getPrimerApellido());
        c.setSegundoApellido(o.getSegundoApellido());
        c.setUbicacion(o.getUbicacion() == null ? null : o.getUbicacion().copiar());
        c.setTelefonos(new ArrayList<>(o.getTelefonos()));
        c.setCorreos(new ArrayList<>(o.getCorreos()));
        return c;
    }
}
