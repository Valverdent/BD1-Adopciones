package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.ListaNegraDAO;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import com.mycompany.bd_proyecto1.util.Sesion;
import com.mycompany.bd_proyecto1.util.Validador;
import java.time.LocalDate;
import java.util.List;

/**
 * Lógica de negocio de la lista negra de adoptantes.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ListaNegraManager {

    public static final int MOTIVO_MINIMO = 10;
    /** Largo de la columna BlackList.blackListReason en la base. */
    public static final int MOTIVO_MAXIMO = 255;

    private final ListaNegraDAO listaNegraDAO;
    private final PersonaDAO personaDAO;

    public ListaNegraManager() {
        this(Repositorios.listaNegra(), Repositorios.personas());
    }

    public ListaNegraManager(ListaNegraDAO listaNegraDAO, PersonaDAO personaDAO) {
        this.listaNegraDAO = listaNegraDAO;
        this.personaDAO = personaDAO;
    }

    /** @throws IllegalArgumentException si el rango de fechas no es válido */
    public List<ResumenListaNegra> consultar(FiltroListaNegra filtro) {
        if (filtro.getFechaDesde() != null && filtro.getFechaHasta() != null
                && filtro.getFechaDesde().isAfter(filtro.getFechaHasta())) {
            throw new IllegalArgumentException("La fecha \"desde\" no puede ser posterior a la fecha \"hasta\".");
        }
        return listaNegraDAO.consultar(filtro);
    }

    public List<ReporteListaNegra> listarReportes(int idPersona) {
        return listaNegraDAO.listarReportes(idPersona);
    }

    public boolean estaEnListaNegra(int idPersona) {
        return listaNegraDAO.estaEnListaNegra(idPersona);
    }

    public boolean puedeEliminar() {
        return Sesion.getUsuario() != null && Sesion.getUsuario().esAdministrador();
    }

    /** Reporta a una persona (la fecha del reporte es la de hoy). */
    public int reportar(int idPersona, String motivo) {
        if (Sesion.getUsuario() == null) {
            throw new IllegalStateException("Debe iniciar sesión para reportar a una persona.");
        }
        if (idPersona == Sesion.getUsuario().getIdPersona()) {
            throw new IllegalStateException("No puede reportarse a sí mismo.");
        }
        personaDAO.obtener(idPersona); // falla si la persona no existe

        String texto = Validador.limpiar(motivo);
        if (texto == null) {
            throw new IllegalArgumentException("Escriba el motivo del reporte.");
        }
        if (texto.length() < MOTIVO_MINIMO) {
            throw new IllegalArgumentException("El motivo debe tener al menos " + MOTIVO_MINIMO + " caracteres.");
        }
        if (texto.length() > MOTIVO_MAXIMO) {
            throw new IllegalArgumentException("El motivo no puede superar los " + MOTIVO_MAXIMO + " caracteres.");
        }
        ReporteListaNegra reporte = new ReporteListaNegra();
        reporte.setIdPersona(idPersona);
        reporte.setFecha(LocalDate.now());
        reporte.setMotivo(texto);
        return listaNegraDAO.insertar(reporte);
    }

    /** @throws IllegalStateException si el usuario no es administrador */
    public void eliminarReporte(int idReporte) {
        if (!puedeEliminar()) {
            throw new IllegalStateException("Solo un administrador puede quitar reportes de la lista negra.");
        }
        listaNegraDAO.eliminar(idReporte);
    }
}
