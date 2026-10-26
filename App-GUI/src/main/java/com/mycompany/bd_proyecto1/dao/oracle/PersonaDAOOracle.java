package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Persona;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.Collator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Implementación de PersonaDAO con Oracle (paquete PKG_PERSON_ADMINISTRATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaDAOOracle implements PersonaDAO {

    private static final String CORREO = "EMAIL";
    private static final String TELEFONO = "PHONE";

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<ItemCatalogo> listar() {
        List<ItemCatalogo> personas = new ArrayList<>();
        for (Persona p : consultarBase(null)) {
            personas.add(new ItemCatalogo(p.getId(), p.getNombreCompleto()));
        }
        personas.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return personas;
    }

    @Override
    public List<Persona> consultar(FiltroPersona filtro) {
        List<Persona> resultado = new ArrayList<>();
        for (Persona p : consultarBase(null)) {
            if (contiene(p.getNombreCompleto(), filtro.getNombre()) && filtro.getUbicacion().cumple(p.getUbicacion())) {
                cargarContactos(p);
                resultado.add(p);
            }
        }
        resultado.sort((a, b) -> ordenEspanol.compare(a.getNombreCompleto(), b.getNombreCompleto()));
        return resultado;
    }

    @Override
    public Persona obtener(int idPersona) {
        List<Persona> encontradas = consultarBase(idPersona);
        if (encontradas.isEmpty()) {
            throw new IllegalStateException("No existe la persona con id " + idPersona);
        }
        Persona persona = encontradas.get(0);
        cargarContactos(persona);
        return persona;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Registro y edición --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Persona persona) {
        int idPersona;
        try (CallableStatement cs = preparar(
                "{call pkg_person_administration.pr_register_person(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            ponerTexto(cs, 1, persona.getNombre());
            ponerTexto(cs, 2, persona.getSegundoNombre());
            ponerTexto(cs, 3, persona.getPrimerApellido());
            ponerTexto(cs, 4, persona.getSegundoApellido());
            ponerId(cs, 5, persona.getUbicacion().getDistrito());
            ponerTexto(cs, 6, persona.getUbicacion().getSenas());
            ponerTexto(cs, 7, persona.getTelefonos().get(0));       // el manager exige al menos uno de cada uno
            ponerTexto(cs, 8, persona.getCorreos().get(0));
            cs.registerOutParameter(9, Types.NUMERIC);
            cs.registerOutParameter(10, Types.NUMERIC);
            cs.execute();
            revisar(cs, 10, "registrar la persona");
            idPersona = cs.getInt(9);
        } catch (SQLException e) {
            throw error("registrar la persona", e);
        }
        // Los demás contactos
        for (String telefono : persona.getTelefonos().subList(1, persona.getTelefonos().size())) {
            agregarContacto(TELEFONO, idPersona, telefono);
        }
        for (String correo : persona.getCorreos().subList(1, persona.getCorreos().size())) {
            agregarContacto(CORREO, idPersona, correo);
        }
        persona.setId(idPersona);
        return idPersona;
    }

    @Override
    public void actualizar(Persona persona) {
        int id = persona.getId();
        // 1. Nombres
        try (CallableStatement cs = preparar(
                "{call pkg_person_administration.pr_update_person_names(?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, id);
            ponerTexto(cs, 2, persona.getNombre());
            ponerTexto(cs, 3, persona.getSegundoNombre());
            ponerTexto(cs, 4, persona.getPrimerApellido());
            ponerTexto(cs, 5, persona.getSegundoApellido());
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.execute();
            revisar(cs, 6, "cambiar los nombres");
        } catch (SQLException e) {
            throw error("cambiar los nombres de la persona", e);
        }
        // 2. Lugar de residencia
        try (CallableStatement cs = preparar(
                "{call pkg_person_administration.pr_update_person_location(?, ?, ?, ?)}")) {
            cs.setInt(1, id);
            ponerId(cs, 2, persona.getUbicacion().getDistrito());
            ponerTexto(cs, 3, persona.getUbicacion().getSenas());
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "cambiar el lugar de residencia");
        } catch (SQLException e) {
            throw error("cambiar el lugar de residencia", e);
        }
        // 3. Contactos: primero agrega los nuevos y después quita los que sobran
        List<Contacto> actuales = contactos(id);
        for (String telefono : persona.getTelefonos()) {
            if (buscar(actuales, TELEFONO, telefono) == null) {
                agregarContacto(TELEFONO, id, telefono);
            }
        }
        for (String correo : persona.getCorreos()) {
            if (buscar(actuales, CORREO, correo) == null) {
                agregarContacto(CORREO, id, correo);
            }
        }
        for (Contacto c : actuales) {
            List<String> nuevos = TELEFONO.equals(c.tipo()) ? persona.getTelefonos() : persona.getCorreos();
            boolean sigue = nuevos.stream().anyMatch(valor -> valor.equalsIgnoreCase(c.valor()));
            if (!sigue) {
                quitarContacto(c, id);
            }
        }
    }

    // ------------------------------------------------------------------ veterinarios

    // ------------------------------------------------------------------------
    // ----------------------------- Veterinarios -----------------------------
    // ------------------------------------------------------------------------

    @Override
    public boolean esVeterinario(int idPersona) {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_query_veterinarians(?)}")) {
            cs.registerOutParameter(1, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 1)) {
                while (fila.next()) {
                    if (fila.getInt("personId") == idPersona) {
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar los veterinarios", e);
        }
        return false;
    }

    @Override
    public void registrarVeterinario(int idPersona) {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_register_veterinarian(?, ?, ?)}")) {
            cs.setInt(1, idPersona);
            cs.registerOutParameter(2, Types.NUMERIC);      // id del veterinario (no se usa)
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "registrar a la persona como veterinaria");
        } catch (SQLException e) {
            throw error("registrar a la persona como veterinaria", e);
        }
    }

    // ------------------------------------------------------------------ consultas

    // ------------------------------------------------------------------------
    // -------------------------- Lectura de la base --------------------------
    // ------------------------------------------------------------------------

    /** PR_GET_PERSONS con todos los filtros en NULL (o solo el id). Sin contactos. */
    private List<Persona> consultarBase(Integer idPersona) {
        Map<Integer, ItemCatalogo> paises = LugaresOracle.paisesPorProvincia();
        List<Persona> personas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_persons(?, ?, ?, ?, ?)}")) {
            ponerNumero(cs, 1, idPersona);
            cs.setNull(2, Types.NUMERIC);
            cs.setNull(3, Types.NUMERIC);
            cs.setNull(4, Types.NUMERIC);
            cs.registerOutParameter(5, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 5)) {
                while (fila.next()) {
                    Persona p = new Persona();
                    p.setId(fila.getInt("id"));
                    p.setNombre(texto(fila, "firstName"));
                    p.setSegundoNombre(texto(fila, "middleName"));
                    p.setPrimerApellido(texto(fila, "firstLastName"));
                    p.setSegundoApellido(texto(fila, "secondLastName"));
                    p.setUbicacion(LugaresOracle.ubicacion(fila, paises));
                    personas.add(p);
                }
            }
        } catch (SQLException e) {
            throw error("consultar las personas", e);
        }
        return personas;
    }

    private void cargarContactos(Persona persona) {
        List<String> telefonos = new ArrayList<>();
        List<String> correos = new ArrayList<>();
        for (Contacto c : contactos(persona.getId())) {
            (TELEFONO.equals(c.tipo()) ? telefonos : correos).add(c.valor());
        }
        persona.setTelefonos(telefonos);
        persona.setCorreos(correos);
    }

    // ------------------------------------------------------------------------
    // ------------------------- Teléfonos y correos --------------------------
    // ------------------------------------------------------------------------

    /** Un teléfono o correo guardado, con su id (para poder quitarlo). */
    record Contacto(String tipo, int id, String valor) {
    }

    /** Teléfonos y correos de una persona (también los usan otros DAO). */
    static List<Contacto> contactos(int idPersona) {
        List<Contacto> lista = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_person_contacts(?, ?)}")) {
            cs.setInt(1, idPersona);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    lista.add(new Contacto(texto(fila, "contactType"), fila.getInt("contactId"),
                            texto(fila, "contactValue")));
                }
            }
        } catch (SQLException e) {
            throw error("consultar los contactos de la persona", e);
        }
        return lista;
    }

    /** Teléfonos de una persona. */
    static List<String> telefonos(int idPersona) {
        return contactos(idPersona).stream().filter(c -> TELEFONO.equals(c.tipo())).map(Contacto::valor).toList();
    }

    /** Correos de una persona. */
    static List<String> correos(int idPersona) {
        return contactos(idPersona).stream().filter(c -> CORREO.equals(c.tipo())).map(Contacto::valor).toList();
    }

    // ------------------------------------------------------------------ contactos

    private void agregarContacto(String tipo, int idPersona, String valor) {
        String llamada = TELEFONO.equals(tipo)
                ? "{call pkg_person_administration.pr_add_phone(?, ?, ?)}"
                : "{call pkg_person_administration.pr_add_email(?, ?, ?)}";
        try (CallableStatement cs = preparar(llamada)) {
            cs.setInt(1, idPersona);
            ponerTexto(cs, 2, valor);
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "agregar el contacto " + valor);
        } catch (SQLException e) {
            throw error("agregar el contacto " + valor, e);
        }
    }

    private void quitarContacto(Contacto contacto, int idPersona) {
        String llamada = TELEFONO.equals(contacto.tipo())
                ? "{call pkg_person_administration.pr_delete_phone(?, ?, ?)}"
                : "{call pkg_person_administration.pr_delete_email(?, ?, ?)}";
        try (CallableStatement cs = preparar(llamada)) {
            cs.setInt(1, idPersona);
            cs.setInt(2, contacto.id());
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, "quitar el contacto " + contacto.valor());
        } catch (SQLException e) {
            throw error("quitar el contacto " + contacto.valor(), e);
        }
    }

    private static Contacto buscar(List<Contacto> contactos, String tipo, String valor) {
        for (Contacto c : contactos) {
            if (c.tipo().equals(tipo) && c.valor().equalsIgnoreCase(valor)) {
                return c;
            }
        }
        return null;
    }

    static boolean contiene(String valor, String criterio) {
        if (criterio == null || criterio.isBlank()) {
            return true;
        }
        return valor != null && valor.toLowerCase().contains(criterio.trim().toLowerCase());
    }
}
