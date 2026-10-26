package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.AdopcionManager;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
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
 * Controlador de la consulta de adopciones (AdopcionConsulta.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionConsultaController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private ComboBox<ItemCatalogo> cmbTipo;
    @FXML private TextField txtNombreMascota;
    @FXML private TextField txtAdoptante;
    @FXML private TextField txtEntregadoPor;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;

    @FXML private TableView<Adopcion> tblAdopciones;
    @FXML private TableColumn<Adopcion, String> colFecha;
    @FXML private TableColumn<Adopcion, String> colMascota;
    @FXML private TableColumn<Adopcion, String> colTipo;
    @FXML private TableColumn<Adopcion, String> colAdoptante;
    @FXML private TableColumn<Adopcion, String> colEntregadoPor;
    @FXML private TableColumn<Adopcion, String> colCalificacion;
    @FXML private TableColumn<Adopcion, String> colSeguimientos;

    @FXML private Label lblTotalRegistros;

    private final AdopcionManager adopcionManager = new AdopcionManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cmbTipo.setItems(FXCollections.observableArrayList(adopcionManager.listarCatalogo(TipoCatalogo.TIPO_MASCOTA)));
        configurarColumnas();

        // Doble clic en una fila: abrir la adopción.
        tblAdopciones.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblAdopciones.getSelectionModel().getSelectedItem() != null) {
                onAbrir();
            }
        });

        onBuscar();
    }

    private void configurarColumnas() {
        colFecha.setCellValueFactory(fila -> texto(fila.getValue().getFechaAdopcion().format(FORMATO_FECHA)));
        colMascota.setCellValueFactory(fila -> texto(nombreMascota(fila.getValue())));
        colTipo.setCellValueFactory(fila -> texto(fila.getValue().getMascota().getTipo().getNombre()));
        colAdoptante.setCellValueFactory(fila -> texto(fila.getValue().getAdoptante().getNombre()));
        colEntregadoPor.setCellValueFactory(fila -> texto(fila.getValue().getNombrePersonaEntrega()));
        colCalificacion.setCellValueFactory(fila -> texto(AdopcionManager.textoCalificacion(fila.getValue().getCalificacion())));
        colSeguimientos.setCellValueFactory(fila -> texto(String.valueOf(fila.getValue().getCantidadSeguimientos())));
    }

    private String nombreMascota(Adopcion a) {
        String nombre = a.getMascota().getNombre();
        return nombre == null || nombre.isBlank() ? "(sin nombre)" : nombre;
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Búsqueda -------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscar() {
        try {
            List<Adopcion> resultados = adopcionManager.consultar(leerFiltro());
            tblAdopciones.setItems(FXCollections.observableArrayList(resultados));
            lblTotalRegistros.setText("Total de registros: " + resultados.size());
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        }
    }

    private FiltroAdopcion leerFiltro() {
        FiltroAdopcion filtro = new FiltroAdopcion();
        filtro.setTipoMascota(cmbTipo.getValue());
        filtro.setNombreMascota(txtNombreMascota.getText());
        filtro.setAdoptante(txtAdoptante.getText());
        filtro.setEntregadoPor(txtEntregadoPor.getText());
        filtro.setFechaDesde(dpDesde.getValue());
        filtro.setFechaHasta(dpHasta.getValue());
        return filtro;
    }

    @FXML
    private void onLimpiar() {
        cmbTipo.setValue(null);
        txtNombreMascota.clear();
        txtAdoptante.clear();
        txtEntregadoPor.clear();
        dpDesde.setValue(null);
        dpHasta.setValue(null);
        onBuscar();
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Navegación ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onPorAdoptante() {
        Navegador.mostrarEnContenido("AdopcionesPorAdoptante.fxml");
    }

    @FXML
    private void onNueva() {
        AdopcionFormularioController formulario = Navegador.mostrarEnContenido("AdopcionFormulario.fxml");
        formulario.prepararNueva();
    }

    @FXML
    private void onAbrir() {
        Adopcion seleccionada = tblAdopciones.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una adopción", "Seleccione una fila de la tabla para verla o editarla.");
            return;
        }
        AdopcionFormularioController formulario = Navegador.mostrarEnContenido("AdopcionFormulario.fxml");
        formulario.mostrarAdopcion(seleccionada);
    }
}
