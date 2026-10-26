package com.mycompany.bd_proyecto1.model;

import java.util.List;

/**
 * Tratamiento asociado a una enfermedad, con su duración y sus medicamentos.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class TratamientoEnfermedad {

    private final ItemCatalogo tratamiento;
    private final String duracion;
    private final List<MedicamentoTratamiento> medicamentos;

    public TratamientoEnfermedad(ItemCatalogo tratamiento, String duracion,
                                 List<MedicamentoTratamiento> medicamentos) {
        this.tratamiento = tratamiento;
        this.duracion = duracion;
        this.medicamentos = medicamentos;
    }

    public ItemCatalogo getTratamiento() {
        return tratamiento;
    }

    public String getDuracion() {
        return duracion;
    }

    public List<MedicamentoTratamiento> getMedicamentos() {
        return medicamentos;
    }
}
