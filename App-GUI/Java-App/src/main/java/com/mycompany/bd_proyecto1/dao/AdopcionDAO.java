package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.ResumenAdoptante;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import java.util.List;

/**
 * Contrato de acceso a las adopciones y sus seguimientos (requisito 4.f).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface AdopcionDAO {

    /** Busca adopciones según los criterios indicados. */
    List<Adopcion> consultar(FiltroAdopcion filtro);

    /** Lista las mascotas que se pueden adoptar. */
    List<Mascota> listarMascotasDisponibles();

    /** Registra una adopción. */
    int insertar(Adopcion adopcion);

    /** Actualiza una adopción existente. */
    void actualizar(Adopcion adopcion);

    /** Lista los seguimientos de una adopción. */
    List<SeguimientoAdopcion> listarSeguimientos(int idAdopcion);

    /** Registra un seguimiento de una adopción. */
    int insertarSeguimiento(SeguimientoAdopcion seguimiento);

    /** Lista las adopciones en las que una persona fue la adoptante. */
    List<Adopcion> listarAdopcionesDeAdoptante(int idPersona);

    /** Consulta adicional: adopciones agrupadas por adoptante. */
    List<ResumenAdoptante> consultarPorAdoptante(FiltroAdoptante filtro);
}
