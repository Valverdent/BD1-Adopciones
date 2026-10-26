package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.ReporteManager;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.ResumenAdoptante;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
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
 * Controlador de la consulta "Adopciones por adoptante" (AdopcionesPorAdoptante.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionesPorAdoptanteController {

    private static final String ARCHIVO = "AdopcionesPorAdoptante.fxml";
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private TextField txtNombre;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;

    @FXML private TableView<ResumenAdoptante> tblAdoptantes;
    @FXML private TableColumn<ResumenAdoptante, String> colAdoptante;
    @FXML private TableColumn<ResumenAdoptante, String> colCantidad;
    @FXML private TableColumn<ResumenAdoptante, String> colUltima;
    @FXML private TableColumn<ResumenAdoptante, String> colPromedio;
    @FXML private Label lblTotalRegistros;
    @FXML private Label lblTotalAdopciones;

    private final ReporteManager reporteManager = new ReporteManager();

    @FXML
    private void initialize() {
        colAdoptante.setCellValueFactory(fila -> texto(fila.getValue().getNombrePersona()));
        colCantidad.setCellValueFactory(fila -> texto(String.valueOf(fila.getValue().getCantidadAdopciones())));
        colUltima.setCellValueFactory(fila -> texto(fila.getValue().getUltimaAdopcion().format(FORMATO_FECHA)));
        colPromedio.setCellValueFactory(fila -> texto(fila.getValue().getCalificacionPromedio() == null
                ? "Sin calificaciones" : fila.getValue().getCalificacionPromedio() + " de 5"));

        tblAdoptantes.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblAdoptantes.getSelectionModel().getSelectedItem() != null) {
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
            FiltroAdoptante filtro = new FiltroAdoptante();
            filtro.setNombre(txtNombre.getText());
            filtro.setFechaDesde(dpDesde.getValue());
            filtro.setFechaHasta(dpHasta.getValue());
            List<ResumenAdoptante> resultados = reporteManager.consultarAdopcionesPorAdoptante(filtro);
            tblAdoptantes.setItems(FXCollections.observableArrayList(resultados));
            lblTotalRegistros.setText("Total de adoptantes: " + resultados.size());
            lblTotalAdopciones.setText("Total de adopciones: " + reporteManager.totalAdopciones(resultados));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
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
        ResumenAdoptante seleccionado = tblAdoptantes.getSelectionModel().getSelectedItem();
        if (seleccionado == null) {
            Alertas.mostrarInformacion("Seleccione un adoptante", "Seleccione una fila de la tabla para ver su ficha.");
            return;
        }
        PersonaDetalleController detalle = Navegador.mostrarEnContenido("PersonaDetalle.fxml");
        detalle.mostrar(seleccionado.getIdPersona(), ARCHIVO);
    }

    @FXML
    private void onVolver() {
        Navegador.mostrarEnContenido("AdopcionConsulta.fxml");
    }
}
