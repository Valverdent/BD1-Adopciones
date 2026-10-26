package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.BitacoraDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.util.List;

/**
 * Reglas de la consulta de bitácora (requisito 7). Solo los administradores pueden consultarla.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class BitacoraManager {

    private final BitacoraDAO bitacoraDAO;

    public BitacoraManager() {
        this(Repositorios.bitacora());
    }

    public BitacoraManager(BitacoraDAO bitacoraDAO) {
        this.bitacoraDAO = bitacoraDAO;
    }

    /** Consulta la bitácora con los criterios indicados. */
    public List<RegistroBitacora> consultar(FiltroBitacora filtro) {
        validarAdministrador();
        if (filtro.getFechaDesde() != null && filtro.getFechaHasta() != null
                && filtro.getFechaDesde().isAfter(filtro.getFechaHasta())) {
            throw new IllegalArgumentException("La fecha inicial no puede ser posterior a la fecha final.");
        }
        return bitacoraDAO.consultar(filtro);
    }

    /** Tablas que aparecen en la bitácora, para el filtro. */
    public List<String> listarTablas() {
        validarAdministrador();
        return bitacoraDAO.listarTablas();
    }

    /** Convierte el id de registro escrito en la pantalla. Vacío significa "sin filtro". */
    public Integer convertirIdRegistro(String texto) {
        if (texto == null || texto.isBlank()) {
            return null;
        }
        try {
            int id = Integer.parseInt(texto.trim());
            if (id <= 0) {
                throw new NumberFormatException();
            }
            return id;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("El id del registro debe ser un número entero mayor que cero.");
        }
    }

    private void validarAdministrador() {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || !usuario.esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede consultar la bitácora.");
        }
    }
}
