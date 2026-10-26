package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.CasaCunaDAO;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.Persona;
import java.text.Collator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * Implementación de CasaCunaDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCunaDAOMemoria implements CasaCunaDAO {

    private final PersonaDAO personaDAO;
    private final List<CasaCuna> casas = DatosPrueba.crearCasasCuna();

    public CasaCunaDAOMemoria(PersonaDAO personaDAO) {
        this.personaDAO = personaDAO;
    }

    @Override
    public List<CasaCuna> consultar(FiltroCasaCuna filtro) {
        List<CasaCuna> resultado = new ArrayList<>();
        for (CasaCuna guardada : casas) {
            CasaCuna casa = completar(guardada);
            if (cumpleFiltro(casa, filtro)) {
                resultado.add(casa);
            }
        }
        Collator orden = Collator.getInstance(Locale.forLanguageTag("es"));
        resultado.sort((a, b) -> orden.compare(a.getNombrePersona(), b.getNombrePersona()));
        return resultado;
    }

    @Override
    public Optional<CasaCuna> buscarPorPersona(int idPersona) {
        for (CasaCuna c : casas) {
            if (c.getIdPersona() == idPersona) {
                return Optional.of(completar(c));
            }
        }
        return Optional.empty();
    }

    @Override
    public void insertar(CasaCuna casa) {
        if (buscarPorPersona(casa.getIdPersona()).isPresent()) {
            throw new IllegalStateException("La persona " + casa.getIdPersona() + " ya tiene una casa cuna.");
        }
        CasaCuna nueva = copiarDatos(casa);
        nueva.setCantidadActual(0);                     // una casa nueva todavía no tiene mascotas
        casas.add(nueva);
    }

    @Override
    public void actualizar(CasaCuna casa) {
        for (int i = 0; i < casas.size(); i++) {
            if (casas.get(i).getIdPersona() == casa.getIdPersona()) {
                CasaCuna nueva = copiarDatos(casa);
                nueva.setCantidadActual(casas.get(i).getCantidadActual());   // no se edita: la calcula la base
                casas.set(i, nueva);
                return;
            }
        }
        throw new IllegalStateException("No existe la casa cuna de la persona " + casa.getIdPersona());
    }

    /** Copia solo los datos que se guardan. */
    private CasaCuna copiarDatos(CasaCuna o) {
        CasaCuna c = new CasaCuna();
        c.setIdPersona(o.getIdPersona());
        c.setUbicacion(o.getUbicacion() == null ? null : o.getUbicacion().copiar());
        c.setEstado(o.getEstado());
        c.setCapacidadMaxima(o.getCapacidadMaxima());
        c.setCantidadActual(o.getCantidadActual());
        c.setRequiereDonacionAlimentos(o.isRequiereDonacionAlimentos());
        c.setTamanos(new ArrayList<>(o.getTamanos()));
        c.setTipos(new ArrayList<>(o.getTipos()));
        return c;
    }

    /** Devuelve una copia con el nombre, los contactos y la disponibilidad calculados. */
    private CasaCuna completar(CasaCuna guardada) {
        CasaCuna c = copiarDatos(guardada);
        Persona persona = personaDAO.obtener(guardada.getIdPersona());
        c.setNombrePersona(persona.getNombreCompleto());
        c.setTelefonos(new ArrayList<>(persona.getTelefonos()));
        c.setCorreos(new ArrayList<>(persona.getCorreos()));
        c.setDisponible(DatosPrueba.ESTADO_CASA_DISPONIBLE.equals(c.getEstado())
                && c.getCantidadActual() < c.getCapacidadMaxima());
        return c;
    }

    private boolean cumpleFiltro(CasaCuna c, FiltroCasaCuna f) {
        return (f.getTamano() == null || c.getTamanos().contains(f.getTamano()))
                && (f.getEstado() == null || f.getEstado().equals(c.getEstado()))
                && (f.getRequiereDonacionAlimentos() == null
                    || f.getRequiereDonacionAlimentos() == c.isRequiereDonacionAlimentos())
                && f.getUbicacion().cumple(c.getUbicacion())
                && (!f.isSoloDisponibles() || c.isDisponible())
                && (f.getTipoMascota() == null || c.getTipos().contains(f.getTipoMascota()));
    }
}
