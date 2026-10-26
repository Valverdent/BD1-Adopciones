package com.mycompany.bd_proyecto1.model;

/**
 * Medicamento que forma parte de un tratamiento, con su dosis.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MedicamentoTratamiento {

    private final ItemCatalogo medicamento;
    private final String dosis;

    public MedicamentoTratamiento(ItemCatalogo medicamento, String dosis) {
        this.medicamento = medicamento;
        this.dosis = dosis;
    }

    public ItemCatalogo getMedicamento() {
        return medicamento;
    }

    public String getDosis() {
        return dosis;
    }
}
