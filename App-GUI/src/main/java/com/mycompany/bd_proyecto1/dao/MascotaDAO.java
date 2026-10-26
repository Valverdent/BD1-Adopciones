package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import java.util.List;

/**
 * Contrato de acceso a los datos de mascotas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface MascotaDAO {

    /** Busca mascotas según los criterios indicados. */
    List<Mascota> consultar(FiltroMascota filtro);

    /** Registra una mascota nueva. */
    int insertar(Mascota mascota);

    /** Actualiza todos los datos de una mascota existente (requisito 4.b). */
    void actualizar(Mascota mascota);

    /** Indica si un número de chip ya está registrado en otra mascota. */
    boolean existeChip(String chip, int idExcluir);

    /** Mascotas que llevan tiempo en adopción sin ser adoptadas (requisito 4.o). */
    List<Mascota> listarSinAdoptar(int mesesMinimos, ItemCatalogo tipo);
}
