package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.BitacoraManager;
import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

/**
 * Controlador de la consulta de bitácora (Bitacora.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class BitacoraController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final String VACIO = "(vacío)";

    @FXML private TextField txtUsuario;
    @FXML private ComboBox<String> cmbTabla;
    @FXML private TextField txtCampo;
    @FXML private TextField txtIdRegistro;
    @FXML private TextField txtTexto;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;
    @FXML private TableView<RegistroBitacora> tblBitacora;
    @FXML private TableColumn<RegistroBitacora, String> colFecha;
    @FXML private TableColumn<RegistroBitacora, String> colUsuario;
    @FXML private TableColumn<RegistroBitacora, String> colTabla;
    @FXML private TableColumn<RegistroBitacora, String> colCampo;
    @FXML private TableColumn<RegistroBitacora, String> colRegistro;
    @FXML private TableColumn<RegistroBitacora, String> colAnterior;
    @FXML private TableColumn<RegistroBitacora, String> colNuevo;
    @FXML private TableColumn<RegistroBitacora, String> colDescripcion;
    @FXML private Label lblTotalRegistros;

    private final BitacoraManager bitacoraManager = new BitacoraManager();

    @FXML
    private void initialize() {
        colFecha.setCellValueFactory(f -> texto(f.getValue().getFecha().format(FORMATO_FECHA)));
        colUsuario.setCellValueFactory(f -> texto(f.getValue().getNombreUsuario()));
        colTabla.setCellValueFactory(f -> texto(f.getValue().getTabla()));
        colCampo.setCellValueFactory(f -> texto(f.getValue().getCampo()));
        colRegistro.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getIdRegistro())));
        colAnterior.setCellValueFactory(f -> texto(valor(f.getValue().getValorAnterior())));
        colNuevo.setCellValueFactory(f -> texto(valor(f.getValue().getValorNuevo())));
        colDescripcion.setCellValueFactory(f -> texto(f.getValue().getDescripcion()));

        try {
            cmbTabla.setItems(FXCollections.observableArrayList(bitacoraManager.listarTablas()));
            onBuscar();
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        } catch (IllegalStateException e) {
            Alertas.mostrarError("Acceso no permitido", e.getMessage());
        }
    }

    @FXML
    private void onBuscar() {
        try {
            FiltroBitacora filtro = new FiltroBitacora();
            filtro.setUsuario(txtUsuario.getText());
            filtro.setTabla(cmbTabla.getValue());
            filtro.setCampo(txtCampo.getText());
            filtro.setIdRegistro(bitacoraManager.convertirIdRegistro(txtIdRegistro.getText()));
            filtro.setTexto(txtTexto.getText());
            filtro.setFechaDesde(dpDesde.getValue());
            filtro.setFechaHasta(dpHasta.getValue());

            List<RegistroBitacora> registros = bitacoraManager.consultar(filtro);
            tblBitacora.setItems(FXCollections.observableArrayList(registros));
            lblTotalRegistros.setText("Cambios encontrados: " + registros.size());
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise los filtros", e.getMessage());
        } catch (IllegalStateException e) {
            Alertas.mostrarError("Acceso no permitido", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    @FXML
    private void onLimpiar() {
        txtUsuario.clear();
        cmbTabla.setValue(null);
        txtCampo.clear();
        txtIdRegistro.clear();
        txtTexto.clear();
        dpDesde.setValue(null);
        dpHasta.setValue(null);
        onBuscar();
    }

    private String valor(String valor) {
        return valor == null ? VACIO : valor;
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }
}
