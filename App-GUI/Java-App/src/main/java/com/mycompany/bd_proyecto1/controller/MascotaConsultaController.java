package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.MascotaManager;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
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
 * Controlador de la consulta de mascotas (MascotaConsulta.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaConsultaController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private ComboBox<ItemCatalogo> cmbTipo;
    @FXML private ComboBox<ItemCatalogo> cmbRaza;
    @FXML private ComboBox<ItemCatalogo> cmbEstado;
    @FXML private ComboBox<ItemCatalogo> cmbColor;
    @FXML private ComboBox<ItemCatalogo> cmbTamano;
    @FXML private TextField txtChip;
    @FXML private TextField txtNombre;
    /** Filtro por lugar: bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private TextField txtRegistradoPor;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;

    @FXML private TableView<Mascota> tblMascotas;
    @FXML private TableColumn<Mascota, String> colFecha;
    @FXML private TableColumn<Mascota, String> colNombre;
    @FXML private TableColumn<Mascota, String> colTipo;
    @FXML private TableColumn<Mascota, String> colRaza;
    @FXML private TableColumn<Mascota, String> colEstado;
    @FXML private TableColumn<Mascota, String> colLugar;
    @FXML private TableColumn<Mascota, String> colChip;
    @FXML private TableColumn<Mascota, String> colRecompensa;
    @FXML private TableColumn<Mascota, String> colRegistradoPor;

    @FXML private Label lblTotalRegistros;
    @FXML private Label lblTotalRecompensas;

    private final MascotaManager mascotaManager = new MascotaManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cargarCatalogos();
        configurarColumnas();
        ubicacionController.usarComoFiltro();

        // Doble clic en una fila: abrir la mascota.
        tblMascotas.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblMascotas.getSelectionModel().getSelectedItem() != null) {
                onAbrir();
            }
        });

        onBuscar();
    }

    private void cargarCatalogos() {
        cmbTipo.setItems(FXCollections.observableArrayList(mascotaManager.listarCatalogo(TipoCatalogo.TIPO_MASCOTA)));
        cmbEstado.setItems(FXCollections.observableArrayList(mascotaManager.listarCatalogo(TipoCatalogo.ESTADO_MASCOTA)));
        cmbColor.setItems(FXCollections.observableArrayList(mascotaManager.listarCatalogo(TipoCatalogo.COLOR)));
        cmbTamano.setItems(FXCollections.observableArrayList(mascotaManager.listarCatalogo(TipoCatalogo.TAMANO)));

        // La lista de razas depende del tipo elegido.
        cmbRaza.setDisable(true);
        cmbTipo.valueProperty().addListener((observable, anterior, nuevo) -> {
            cmbRaza.setItems(FXCollections.observableArrayList(mascotaManager.listarRazas(nuevo)));
            cmbRaza.setValue(null);
            cmbRaza.setDisable(nuevo == null);
        });
    }

    private void configurarColumnas() {
        colFecha.setCellValueFactory(fila -> texto(fila.getValue().getFechaEvento().format(FORMATO_FECHA)));
        colNombre.setCellValueFactory(fila -> texto(fila.getValue().getNombre() == null
                ? "(sin nombre)" : fila.getValue().getNombre()));
        colTipo.setCellValueFactory(fila -> texto(fila.getValue().getTipo().getNombre()));
        colRaza.setCellValueFactory(fila -> texto(fila.getValue().getRaza().getNombre()));
        colEstado.setCellValueFactory(fila -> texto(fila.getValue().getEstado().getNombre()));
        colLugar.setCellValueFactory(fila -> texto(Ubicacion.resumenDe(fila.getValue().getUbicacion())));
        colChip.setCellValueFactory(fila -> texto(fila.getValue().getChip()));
        colRecompensa.setCellValueFactory(fila -> texto(textoRecompensa(fila.getValue())));
        colRegistradoPor.setCellValueFactory(fila -> texto(fila.getValue().getNombrePersonaRegistro()));
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String textoRecompensa(Mascota m) {
        if (m.getMontoRecompensa() == null) {
            return "";
        }
        return String.format("%,.2f %s", m.getMontoRecompensa(), m.getMonedaRecompensa().getNombre());
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Búsqueda -------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscar() {
        try {
            List<Mascota> resultados = mascotaManager.consultar(leerFiltro());
            tblMascotas.setItems(FXCollections.observableArrayList(resultados));
            mostrarTotales(resultados);
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        }
    }

    private FiltroMascota leerFiltro() {
        FiltroMascota filtro = new FiltroMascota();
        filtro.setTipo(cmbTipo.getValue());
        filtro.setRaza(cmbRaza.getValue());
        filtro.setEstado(cmbEstado.getValue());
        filtro.setColor(cmbColor.getValue());
        filtro.setTamano(cmbTamano.getValue());
        filtro.setChip(txtChip.getText());
        filtro.setNombre(txtNombre.getText());
        filtro.setUbicacion(ubicacionController.leerFiltro());
        filtro.setRegistradoPor(txtRegistradoPor.getText());
        filtro.setFechaDesde(dpDesde.getValue());
        filtro.setFechaHasta(dpHasta.getValue());
        return filtro;
    }

    private void mostrarTotales(List<Mascota> resultados) {
        lblTotalRegistros.setText("Total de registros: " + resultados.size());

        Map<String, BigDecimal> totales = mascotaManager.totalRecompensasPorMoneda(resultados);
        if (totales.isEmpty()) {
            lblTotalRecompensas.setText("Total de recompensas: 0");
            return;
        }
        StringBuilder texto = new StringBuilder("Total de recompensas: ");
        boolean primero = true;
        for (Map.Entry<String, BigDecimal> total : totales.entrySet()) {
            if (!primero) {
                texto.append("  |  ");
            }
            texto.append(String.format("%,.2f %s", total.getValue(), total.getKey()));
            primero = false;
        }
        lblTotalRecompensas.setText(texto.toString());
    }

    @FXML
    private void onLimpiar() {
        cmbTipo.setValue(null);
        cmbEstado.setValue(null);
        cmbColor.setValue(null);
        cmbTamano.setValue(null);
        txtChip.clear();
        txtNombre.clear();
        ubicacionController.limpiar();
        txtRegistradoPor.clear();
        dpDesde.setValue(null);
        dpHasta.setValue(null);
        onBuscar();
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Navegación ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onSinAdoptar() {
        Navegador.mostrarEnContenido("MascotasSinAdoptar.fxml");
    }

    @FXML
    private void onNueva() {
        MascotaFormularioController formulario = Navegador.mostrarEnContenido("MascotaFormulario.fxml");
        formulario.prepararNueva();
    }

    @FXML
    private void onAbrir() {
        Mascota seleccionada = tblMascotas.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una mascota", "Seleccione una fila de la tabla para verla o editarla.");
            return;
        }
        MascotaFormularioController formulario = Navegador.mostrarEnContenido("MascotaFormulario.fxml");
        formulario.mostrarMascota(seleccionada);
    }
}
