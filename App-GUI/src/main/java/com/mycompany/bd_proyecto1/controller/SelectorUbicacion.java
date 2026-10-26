package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.UbicacionManager;
import com.mycompany.bd_proyecto1.model.FiltroUbicacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.util.List;
import javafx.collections.FXCollections;
import javafx.scene.control.ComboBox;

/**
 * Conecta cuatro combos en cascada: país > provincia > cantón > distrito.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class SelectorUbicacion {

    private final ComboBox<ItemCatalogo> cmbPais;
    private final ComboBox<ItemCatalogo> cmbProvincia;
    private final ComboBox<ItemCatalogo> cmbCanton;
    private final ComboBox<ItemCatalogo> cmbDistrito;
    private final UbicacionManager ubicacionManager;
    private boolean bloqueado;

    public SelectorUbicacion(ComboBox<ItemCatalogo> cmbPais, ComboBox<ItemCatalogo> cmbProvincia,
                             ComboBox<ItemCatalogo> cmbCanton, ComboBox<ItemCatalogo> cmbDistrito) {
        this(cmbPais, cmbProvincia, cmbCanton, cmbDistrito, new UbicacionManager());
    }

    public SelectorUbicacion(ComboBox<ItemCatalogo> cmbPais, ComboBox<ItemCatalogo> cmbProvincia,
                             ComboBox<ItemCatalogo> cmbCanton, ComboBox<ItemCatalogo> cmbDistrito,
                             UbicacionManager ubicacionManager) {
        this.cmbPais = cmbPais;
        this.cmbProvincia = cmbProvincia;
        this.cmbCanton = cmbCanton;
        this.cmbDistrito = cmbDistrito;
        this.ubicacionManager = ubicacionManager;

        cmbPais.setItems(FXCollections.observableArrayList(ubicacionManager.listarPaises()));
        cmbPais.valueProperty().addListener((observable, anterior, nuevo) ->
                cargar(cmbProvincia, ubicacionManager.listarProvincias(nuevo)));
        cmbProvincia.valueProperty().addListener((observable, anterior, nueva) ->
                cargar(cmbCanton, ubicacionManager.listarCantones(nueva)));
        cmbCanton.valueProperty().addListener((observable, anterior, nuevo) ->
                cargar(cmbDistrito, ubicacionManager.listarDistritos(nuevo)));
        actualizarHabilitados();
    }

    /** Llena el combo del siguiente nivel y lo deja sin selección (lo que limpia los niveles de abajo). */
    private void cargar(ComboBox<ItemCatalogo> combo, List<ItemCatalogo> elementos) {
        combo.setItems(FXCollections.observableArrayList(elementos));
        combo.setValue(null);
        actualizarHabilitados();
    }

    /** Cada nivel se habilita solo cuando el anterior tiene valor. */
    private void actualizarHabilitados() {
        cmbPais.setDisable(bloqueado);
        cmbProvincia.setDisable(bloqueado || cmbPais.getValue() == null);
        cmbCanton.setDisable(bloqueado || cmbProvincia.getValue() == null);
        cmbDistrito.setDisable(bloqueado || cmbCanton.getValue() == null);
    }

    /** Lo elegido, con las señas indicadas (para formularios). */
    public Ubicacion leer(String senas) {
        return new Ubicacion(cmbPais.getValue(), cmbProvincia.getValue(), cmbCanton.getValue(),
                cmbDistrito.getValue(), senas);
    }

    /** Lo elegido como criterio de búsqueda; los combos vacíos no filtran. */
    public FiltroUbicacion leerFiltro() {
        return new FiltroUbicacion(id(cmbPais), id(cmbProvincia), id(cmbCanton), id(cmbDistrito));
    }

    /**
     * Muestra una ubicación guardada. Si algún nivel fue desactivado después, se agrega a su combo
     * para que el registro se vea completo.
     */
    public void mostrar(Ubicacion u) {
        if (u == null) {
            limpiar();
            return;
        }
        elegir(cmbPais, u.getPais());
        elegir(cmbProvincia, u.getProvincia());
        elegir(cmbCanton, u.getCanton());
        elegir(cmbDistrito, u.getDistrito());
        actualizarHabilitados();
    }

    public void limpiar() {
        cmbPais.setValue(null);
    }

    /**
     * Vuelve a leer las listas (por ejemplo, después de agregar o desactivar un lugar en
     * Catálogos) y conserva lo elegido mientras siga en las listas.
     */
    public void recargar() {
        Ubicacion anterior = leer(null);
        cmbPais.setValue(null);
        cmbPais.setItems(FXCollections.observableArrayList(ubicacionManager.listarPaises()));
        reelegir(cmbPais, anterior.getPais());
        reelegir(cmbProvincia, anterior.getProvincia());
        reelegir(cmbCanton, anterior.getCanton());
        reelegir(cmbDistrito, anterior.getDistrito());
        actualizarHabilitados();
    }

    private static void reelegir(ComboBox<ItemCatalogo> combo, ItemCatalogo valor) {
        if (valor != null && combo.getItems().contains(valor)) {
            combo.setValue(valor);
        }
    }

    /** Bloquea o desbloquea los cuatro combos (por ejemplo, si no puede editar). */
    public void setBloqueado(boolean bloqueado) {
        this.bloqueado = bloqueado;
        actualizarHabilitados();
    }

    private static void elegir(ComboBox<ItemCatalogo> combo, ItemCatalogo valor) {
        if (valor != null && !combo.getItems().contains(valor)) {
            combo.getItems().add(valor);
        }
        combo.setValue(valor);
    }

    private static Integer id(ComboBox<ItemCatalogo> combo) {
        return combo.getValue() == null ? null : combo.getValue().getId();
    }
}
