package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.ConteoMascotas;
import com.mycompany.bd_proyecto1.model.ConteoPorCanton;
import com.mycompany.bd_proyecto1.model.FilaPorcentaje;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.ResumenAdopciones;
import com.mycompany.bd_proyecto1.model.TotalPorRescatista;
import java.time.LocalDate;
import java.util.List;

/**
 * Acceso a los datos de las estadísticas (requisito 8), calculadas por el paquete PKG_STATISTICS
 * de la base. Los totales de donaciones por asociación (8.b) usan totalesPorAsociacion.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface EstadisticaDAO {

    /** Estadística 8.a. */
    List<ConteoMascotas> contarMascotasPorTipoYEstado(LocalDate desde, LocalDate hasta);

    /** Estadística 8.c. */
    ResumenAdopciones resumirAdopciones(ItemCatalogo tipo, ItemCatalogo raza);

    /** Estadística 8.d. */
    List<FilaPorcentaje> contarNoAdoptadasPorEdad();

    /** Estadística adicional: mascotas perdidas y encontradas por cantón. */
    List<ConteoPorCanton> contarPerdidasYEncontradasPorCanton(LocalDate desde, LocalDate hasta);

    /** Estadística adicional: donaciones de recompensa por rescatista. */
    List<TotalPorRescatista> totalizarDonacionesPorRescatista(LocalDate desde, LocalDate hasta);
}
