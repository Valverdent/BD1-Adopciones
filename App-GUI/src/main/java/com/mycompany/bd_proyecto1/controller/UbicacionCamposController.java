package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.model.FiltroUbicacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.util.List;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

/**
 * Controlador del bloque reutilizable UbicacionCampos.fxml.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class UbicacionCamposController {

    @FXML private Label lblPais;
    @FXML private Label lblProvincia;
    @FXML private Label lblCanton;
    @FXML private Label lblDistrito;
    @FXML private Label lblSenas;
    @FXML private ComboBox<ItemCatalogo> cmbPais;
    @FXML private ComboBox<ItemCatalogo> cmbProvincia;
    @FXML private ComboBox<ItemCatalogo> cmbCanton;
    @FXML private ComboBox<ItemCatalogo> cmbDistrito;
    @FXML private TextField txtSenas;

    private SelectorUbicacion selector;

    @FXML
    private void initialize() {
        selector = new SelectorUbicacion(cmbPais, cmbProvincia, cmbCanton, cmbDistrito);
    }

    /** Para formularios donde las señas no son obligatorias (por ejemplo, mascotas). */
    public void setSenasOpcionales() {
        lblSenas.setText("Señas o dirección exacta (opcional)");
    }

    /** Para filtros: sin señas, sin asteriscos y con "Todos" como texto de los combos vacíos. */
    public void usarComoFiltro() {
        lblPais.setText("País");
        lblProvincia.setText("Provincia");
        lblCanton.setText("Cantón");
        lblDistrito.setText("Distrito");
        for (ComboBox<ItemCatalogo> combo : List.of(cmbPais, cmbProvincia, cmbCanton, cmbDistrito)) {
            combo.setPromptText("Todos");
        }
        lblSenas.setVisible(false);
        lblSenas.setManaged(false);
        txtSenas.setVisible(false);
        txtSenas.setManaged(false);
    }

    /** Lo elegido y las señas escritas. */
    public Ubicacion leer() {
        return selector.leer(txtSenas.getText());
    }

    public FiltroUbicacion leerFiltro() {
        return selector.leerFiltro();
    }

    public void mostrar(Ubicacion ubicacion) {
        selector.mostrar(ubicacion);
        txtSenas.setText(ubicacion == null ? "" : ubicacion.getSenas());
    }

    public void limpiar() {
        selector.limpiar();
        txtSenas.clear();
    }

    /** Bloquea los combos y las señas (por ejemplo, si el usuario no puede editar el registro). */
    public void setBloqueado(boolean bloqueado) {
        selector.setBloqueado(bloqueado);
        txtSenas.setDisable(bloqueado);
    }
}
