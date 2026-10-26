package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.ListaNegraManager;
import com.mycompany.bd_proyecto1.model.FiltroListaNegra;
import com.mycompany.bd_proyecto1.model.ResumenListaNegra;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

/**
 * Controlador de la lista negra (ListaNegra.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class ListaNegraController {

    private static final String ARCHIVO = "ListaNegra.fxml";
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private TextField txtNombre;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;

    @FXML private TableView<ResumenListaNegra> tblListaNegra;
    @FXML private TableColumn<ResumenListaNegra, String> colPersona;
    @FXML private TableColumn<ResumenListaNegra, String> colReportes;
    @FXML private TableColumn<ResumenListaNegra, String> colUltimo;
    @FXML private TableColumn<ResumenListaNegra, String> colPromedio;
    @FXML private Label lblTotalRegistros;

    private final ListaNegraManager listaNegraManager = new ListaNegraManager();

    @FXML
    private void initialize() {
        colPersona.setCellValueFactory(fila -> texto(fila.getValue().getNombrePersona()));
        colReportes.setCellValueFactory(fila -> texto(String.valueOf(fila.getValue().getCantidadReportes())));
        colUltimo.setCellValueFactory(fila -> texto(fila.getValue().getUltimoReporte().format(FORMATO_FECHA)));
        colPromedio.setCellValueFactory(fila -> texto(fila.getValue().getCalificacionPromedio() == null
                ? "Sin calificaciones" : fila.getValue().getCalificacionPromedio() + " de 5"));

        tblListaNegra.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblListaNegra.getSelectionModel().getSelectedItem() != null) {
                onAbrir();
            }
        });
        onBuscar();
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    @FXML
    private void onBuscar() {
        try {
            FiltroListaNegra filtro = new FiltroListaNegra();
            filtro.setNombre(txtNombre.getText());
            filtro.setFechaDesde(dpDesde.getValue());
            filtro.setFechaHasta(dpHasta.getValue());
            List<ResumenListaNegra> resultados = listaNegraManager.consultar(filtro);
            tblListaNegra.setItems(FXCollections.observableArrayList(resultados));
            lblTotalRegistros.setText("Total de registros: " + resultados.size());
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        }
    }

    @FXML
    private void onLimpiar() {
        txtNombre.clear();
        dpDesde.setValue(null);
        dpHasta.setValue(null);
        onBuscar();
    }

    @FXML
    private void onAbrir() {
        ResumenListaNegra seleccionada = tblListaNegra.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una persona", "Seleccione una fila de la tabla para ver su detalle.");
            return;
        }
        PersonaDetalleController detalle = Navegador.mostrarEnContenido("PersonaDetalle.fxml");
        detalle.mostrar(seleccionada.getIdPersona(), ARCHIVO);
    }
}
