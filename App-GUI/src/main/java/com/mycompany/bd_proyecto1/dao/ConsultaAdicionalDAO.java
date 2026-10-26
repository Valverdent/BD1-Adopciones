package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.DisponibilidadCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import java.util.List;

/**
 * Consultas adicionales que propuso el equipo (paquete PKG_QUERIES_EXTRAS).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public interface ConsultaAdicionalDAO {

    /** Casas cuna con espacio. */
    List<DisponibilidadCasaCuna> casasCunaConEspacio(ItemCatalogo provincia, ItemCatalogo tipo, int espaciosMinimos);

    /** Mascotas perdidas, de la recompensa más alta a la más baja. */
    List<Mascota> mascotasPerdidasPorRecompensa(ItemCatalogo tipo, ItemCatalogo provincia);
}
