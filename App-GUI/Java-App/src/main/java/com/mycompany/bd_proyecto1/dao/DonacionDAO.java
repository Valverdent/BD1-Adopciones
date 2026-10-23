package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import java.time.LocalDate;
import java.util.List;

/**
 * Contrato de acceso a las donaciones (requisitos 4.h, 4.i, 5.b y 7).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface DonacionDAO {

    /** Consulta las donaciones según los criterios indicados. */
    List<FilaDonacion> consultar(FiltroDonacion filtro);

    /** Totaliza lo donado a cada asociación. */
    List<TotalAsociacion> totalesPorAsociacion(LocalDate desde, LocalDate hasta);

    /** Lista las recompensas que todavía se pueden donar. */
    List<Mascota> listarRecompensasDisponibles();

    /** Obtiene una donación completa. */
    Donacion obtener(int idDonacion);

    /** Registra una donación con su reparto. */
    int insertar(Donacion donacion);

    /** Corrige el monto de una donación. */
    void actualizarMonto(Donacion donacion);
}
