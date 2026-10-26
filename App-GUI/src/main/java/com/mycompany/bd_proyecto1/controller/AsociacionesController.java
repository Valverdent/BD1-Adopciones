package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.DonacionManager;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

/**
 * Controlador de la administración de asociaciones (Asociaciones.fxml). Solo el administrador
 * llega a esta pantalla; las reglas las valida el DonacionManager.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AsociacionesController {

    @FXML private TableView<AsociacionBienestar> tblAsociaciones;
    @FXML private TableColumn<AsociacionBienestar, String> colNombre;
    @FXML private TableColumn<AsociacionBienestar, String> colUbicacion;
    @FXML private Label lblTotalRegistros;
    @FXML private Label lblTituloFormulario;
    @FXML private TextField txtNombre;
    /** Bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;

    private final DonacionManager donacionManager = new DonacionManager();

    /** Asociación que se está editando; null si se registra una nueva. */
    private AsociacionBienestar asociacionActual;

    @FXML
    private void initialize() {
        colNombre.setCellValueFactory(fila -> new SimpleStringProperty(fila.getValue().getNombre()));
        colUbicacion.setCellValueFactory(fila -> new SimpleStringProperty(
                Ubicacion.descripcionDe(fila.getValue().getUbicacion())));

        // Al seleccionar una fila, sus datos pasan al formulario.
        tblAsociaciones.getSelectionModel().selectedItemProperty().addListener((observable, anterior, nueva) -> {
            if (nueva != null) {
                asociacionActual = nueva;
                txtNombre.setText(nueva.getNombre());
                ubicacionController.mostrar(nueva.getUbicacion());
                lblTituloFormulario.setText("Editar asociación");
            }
        });

        cargarTabla();
        onNueva();
    }

    private void cargarTabla() {
        List<AsociacionBienestar> asociaciones = donacionManager.listarAsociaciones();
        tblAsociaciones.setItems(FXCollections.observableArrayList(asociaciones));
        lblTotalRegistros.setText("Total de registros: " + asociaciones.size());
    }

    @FXML
    private void onNueva() {
        asociacionActual = null;
        tblAsociaciones.getSelectionModel().clearSelection();
        txtNombre.clear();
        ubicacionController.limpiar();
        lblTituloFormulario.setText("Nueva asociación");
    }

    @FXML
    private void onGuardar() {
        AsociacionBienestar asociacion = new AsociacionBienestar();
        if (asociacionActual != null) {
            asociacion.setId(asociacionActual.getId());
        }
        asociacion.setNombre(txtNombre.getText());
        asociacion.setUbicacion(ubicacionController.leer());
        try {
            donacionManager.guardarAsociacion(asociacion);
            Alertas.mostrarInformacion("Asociación guardada", "Los datos de la asociación se guardaron correctamente.");
            cargarTabla();
            onNueva();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }
}
