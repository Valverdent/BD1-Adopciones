package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.EstadisticaManager;
import com.mycompany.bd_proyecto1.model.ConteoMascotas;
import com.mycompany.bd_proyecto1.model.FilaPorcentaje;
import com.mycompany.bd_proyecto1.model.FilaTotalDonacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.ConteoPorCanton;
import com.mycompany.bd_proyecto1.model.TotalPorRescatista;
import com.mycompany.bd_proyecto1.model.ResumenAdopciones;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.PieChart;
import javafx.scene.chart.XYChart;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TabPane;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;

/**
 * Controlador de las estadísticas (Estadisticas.fxml). Cada pestaña carga sus datos al abrirse,
 * para no consultar a la base las seis estadísticas a la vez.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class EstadisticasController {

    private static final DecimalFormat FORMATO_NUMERO = new DecimalFormat("#,##0.00");

    @FXML private TabPane tabPane;

    // 8.a
    @FXML private DatePicker dpDesdeMascotas;
    @FXML private DatePicker dpHastaMascotas;
    @FXML private TableView<ConteoMascotas> tblMascotas;
    @FXML private TableColumn<ConteoMascotas, String> colMascTipo;
    @FXML private TableColumn<ConteoMascotas, String> colMascEstado;
    @FXML private TableColumn<ConteoMascotas, String> colMascCantidad;
    @FXML private TableColumn<ConteoMascotas, String> colMascPorcentaje;
    @FXML private Label lblTotalMascotas;
    @FXML private BarChart<String, Number> grafMascotas;

    // 8.b
    @FXML private DatePicker dpDesdeDonaciones;
    @FXML private DatePicker dpHastaDonaciones;
    @FXML private TableView<FilaTotalDonacion> tblDonaciones;
    @FXML private TableColumn<FilaTotalDonacion, String> colDonAsociacion;
    @FXML private TableColumn<FilaTotalDonacion, String> colDonMoneda;
    @FXML private TableColumn<FilaTotalDonacion, String> colDonTotal;
    @FXML private TableColumn<FilaTotalDonacion, String> colDonCantidad;
    @FXML private TableColumn<FilaTotalDonacion, String> colDonPorcentaje;
    @FXML private Label lblTotalDonaciones;
    @FXML private BarChart<String, Number> grafDonaciones;

    // 8.c
    @FXML private ComboBox<ItemCatalogo> cmbTipoAdopciones;
    @FXML private ComboBox<ItemCatalogo> cmbRazaAdopciones;
    @FXML private TableView<FilaPorcentaje> tblAdopciones;
    @FXML private TableColumn<FilaPorcentaje, String> colAdopSituacion;
    @FXML private TableColumn<FilaPorcentaje, String> colAdopCantidad;
    @FXML private TableColumn<FilaPorcentaje, String> colAdopPorcentaje;
    @FXML private Label lblTotalAdopciones;
    @FXML private PieChart grafAdopciones;

    // 8.d
    @FXML private TableView<FilaPorcentaje> tblEdades;
    @FXML private TableColumn<FilaPorcentaje, String> colEdadRango;
    @FXML private TableColumn<FilaPorcentaje, String> colEdadCantidad;
    @FXML private TableColumn<FilaPorcentaje, String> colEdadPorcentaje;
    @FXML private Label lblTotalEdades;
    @FXML private BarChart<String, Number> grafEdades;

    // Adicional: perdidas y encontradas por cantón
    @FXML private DatePicker dpDesdeCantones;
    @FXML private DatePicker dpHastaCantones;
    @FXML private TableView<ConteoPorCanton> tblCantones;
    @FXML private TableColumn<ConteoPorCanton, String> colCantCanton;
    @FXML private TableColumn<ConteoPorCanton, String> colCantEstado;
    @FXML private TableColumn<ConteoPorCanton, String> colCantCantidad;
    @FXML private TableColumn<ConteoPorCanton, String> colCantPorcentaje;
    @FXML private Label lblTotalCantones;
    @FXML private BarChart<String, Number> grafCantones;

    // Adicional: donaciones por rescatista
    @FXML private DatePicker dpDesdeRescatistas;
    @FXML private DatePicker dpHastaRescatistas;
    @FXML private TableView<TotalPorRescatista> tblRescatistas;
    @FXML private TableColumn<TotalPorRescatista, String> colResPersona;
    @FXML private TableColumn<TotalPorRescatista, String> colResMoneda;
    @FXML private TableColumn<TotalPorRescatista, String> colResTotal;
    @FXML private TableColumn<TotalPorRescatista, String> colResPorcentaje;

    private final EstadisticaManager estadisticaManager = new EstadisticaManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        configurarColumnas();
        restablecerFechasMascotas();
        restablecerFechasDonaciones();
        for (DatePicker desde : List.of(dpDesdeCantones, dpDesdeRescatistas)) {
            desde.setValue(estadisticaManager.fechaDesdePorDefecto());
        }
        for (DatePicker hasta : List.of(dpHastaCantones, dpHastaRescatistas)) {
            hasta.setValue(estadisticaManager.fechaHastaPorDefecto());
        }

        cmbTipoAdopciones.setItems(FXCollections.observableArrayList(estadisticaManager.listarTipos()));
        cmbTipoAdopciones.valueProperty().addListener((observable, anterior, nuevo) -> {
            cmbRazaAdopciones.setItems(FXCollections.observableArrayList(estadisticaManager.listarRazas(nuevo)));
            cmbRazaAdopciones.setValue(null);
        });

        // Cada pestaña se carga cuando se abre.
        tabPane.getSelectionModel().selectedIndexProperty().addListener(
                (observable, anterior, nuevo) -> cargarPestana(nuevo.intValue()));
        cargarPestana(0);
    }

    private void cargarPestana(int indice) {
        switch (indice) {
            case 0 -> onActualizarMascotas();
            case 1 -> onActualizarDonaciones();
            case 2 -> onActualizarAdopciones();
            case 3 -> onActualizarEdades();
            case 4 -> onActualizarCantones();
            case 5 -> onActualizarRescatistas();
            default -> { }
        }
    }

    private void configurarColumnas() {
        colMascTipo.setCellValueFactory(f -> texto(f.getValue().getTipo().getNombre()));
        colMascEstado.setCellValueFactory(f -> texto(f.getValue().getEstado().getNombre()));
        colMascCantidad.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getCantidad())));
        colMascPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));

        colDonAsociacion.setCellValueFactory(f -> texto(f.getValue().getAsociacion()));
        colDonMoneda.setCellValueFactory(f -> texto(f.getValue().getMoneda().getNombre()));
        colDonTotal.setCellValueFactory(f -> texto(FORMATO_NUMERO.format(f.getValue().getTotal())));
        colDonCantidad.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getCantidadDonaciones())));
        colDonPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));

        colAdopSituacion.setCellValueFactory(f -> texto(f.getValue().getEtiqueta()));
        colAdopCantidad.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getCantidad())));
        colAdopPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));

        colEdadRango.setCellValueFactory(f -> texto(f.getValue().getEtiqueta()));
        colEdadCantidad.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getCantidad())));
        colEdadPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));

        colCantCanton.setCellValueFactory(f -> texto(f.getValue().getCanton()));
        colCantEstado.setCellValueFactory(f -> texto(f.getValue().getEstado()));
        colCantCantidad.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getCantidad())));
        colCantPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));

        colResPersona.setCellValueFactory(f -> texto(f.getValue().getRescatista()));
        colResMoneda.setCellValueFactory(f -> texto(f.getValue().getMoneda()));
        colResTotal.setCellValueFactory(f -> texto(FORMATO_NUMERO.format(f.getValue().getTotal())));
        colResPorcentaje.setCellValueFactory(f -> texto(porcentaje(f.getValue().getPorcentaje())));
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String porcentaje(BigDecimal valor) {
        return valor == null ? "" : valor.toPlainString() + " %";
    }

    // ------------------------------------------------------------------------
    // ---------------------- Mascotas por tipo y estado ----------------------
    // ------------------------------------------------------------------------

    private void restablecerFechasMascotas() {
        dpDesdeMascotas.setValue(estadisticaManager.fechaDesdePorDefecto());
        dpHastaMascotas.setValue(estadisticaManager.fechaHastaPorDefecto());
    }

    @FXML
    private void onRestablecerMascotas() {
        restablecerFechasMascotas();
        onActualizarMascotas();
    }

    @FXML
    private void onActualizarMascotas() {
        try {
            List<ConteoMascotas> conteos = estadisticaManager.mascotasPorTipoYEstado(
                    dpDesdeMascotas.getValue(), dpHastaMascotas.getValue());
            tblMascotas.setItems(FXCollections.observableArrayList(conteos));
            lblTotalMascotas.setText("Total de mascotas: " + estadisticaManager.totalMascotas(conteos));

            // Una serie por estado; cada barra es un tipo de mascota.
            Map<String, XYChart.Series<String, Number>> series = new LinkedHashMap<>();
            for (ConteoMascotas c : conteos) {
                XYChart.Series<String, Number> serie = series.computeIfAbsent(c.getEstado().getNombre(), nombre -> {
                    XYChart.Series<String, Number> nueva = new XYChart.Series<>();
                    nueva.setName(nombre);
                    return nueva;
                });
                serie.getData().add(new XYChart.Data<>(c.getTipo().getNombre(), c.getCantidad()));
            }
            grafMascotas.setData(FXCollections.observableArrayList(series.values()));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise las fechas", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ---------------------- Donaciones por asociación -----------------------
    // ------------------------------------------------------------------------

    private void restablecerFechasDonaciones() {
        dpDesdeDonaciones.setValue(estadisticaManager.fechaDesdePorDefecto());
        dpHastaDonaciones.setValue(estadisticaManager.fechaHastaPorDefecto());
    }

    @FXML
    private void onRestablecerDonaciones() {
        restablecerFechasDonaciones();
        onActualizarDonaciones();
    }

    @FXML
    private void onActualizarDonaciones() {
        try {
            List<FilaTotalDonacion> filas = estadisticaManager.donacionesPorAsociacion(
                    dpDesdeDonaciones.getValue(), dpHastaDonaciones.getValue());
            tblDonaciones.setItems(FXCollections.observableArrayList(filas));

            List<String> totales = new ArrayList<>();
            for (Map.Entry<String, BigDecimal> e : estadisticaManager.totalPorMoneda(filas).entrySet()) {
                totales.add(e.getKey() + ": " + FORMATO_NUMERO.format(e.getValue()));
            }
            lblTotalDonaciones.setText(totales.isEmpty() ? "Total donado: 0" : "Total donado - " + String.join("  |  ", totales));

            // Una serie por moneda; cada barra es el porcentaje de una asociación.
            Map<String, XYChart.Series<String, Number>> series = new LinkedHashMap<>();
            for (FilaTotalDonacion f : filas) {
                XYChart.Series<String, Number> serie = series.computeIfAbsent(f.getMoneda().getNombre(), nombre -> {
                    XYChart.Series<String, Number> nueva = new XYChart.Series<>();
                    nueva.setName(nombre);
                    return nueva;
                });
                serie.getData().add(new XYChart.Data<>(f.getAsociacion(), f.getPorcentaje()));
            }
            grafDonaciones.setData(FXCollections.observableArrayList(series.values()));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise las fechas", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Adopciones ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onLimpiarAdopciones() {
        cmbTipoAdopciones.setValue(null);
        cmbRazaAdopciones.setValue(null);
        onActualizarAdopciones();
    }

    @FXML
    private void onActualizarAdopciones() {
        try {
            ResumenAdopciones resumen = estadisticaManager.adopciones(
                    cmbTipoAdopciones.getValue(), cmbRazaAdopciones.getValue());
            List<FilaPorcentaje> filas = List.of(
                    new FilaPorcentaje("Adoptadas (exitosas)", resumen.getAdoptadas(), resumen.getPorcentajeAdoptadas()),
                    new FilaPorcentaje("En espera de adopción", resumen.getEnEspera(), resumen.getPorcentajeEnEspera()));
            tblAdopciones.setItems(FXCollections.observableArrayList(filas));
            lblTotalAdopciones.setText("Total de mascotas consideradas: " + resumen.getTotal());

            if (resumen.getTotal() == 0) {
                grafAdopciones.setData(FXCollections.observableArrayList());
            } else {
                grafAdopciones.setData(FXCollections.observableArrayList(
                        new PieChart.Data("Adoptadas (" + resumen.getAdoptadas() + ")", resumen.getAdoptadas()),
                        new PieChart.Data("En espera (" + resumen.getEnEspera() + ")", resumen.getEnEspera())));
            }
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise los filtros", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------ No adoptadas por edad -------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onActualizarEdades() {
        try {
            List<FilaPorcentaje> filas = estadisticaManager.noAdoptadasPorEdad();
            tblEdades.setItems(FXCollections.observableArrayList(filas));
            lblTotalEdades.setText("Total de mascotas no adoptadas: " + estadisticaManager.totalFilas(filas));

            XYChart.Series<String, Number> serie = new XYChart.Series<>();
            for (FilaPorcentaje f : filas) {
                serie.getData().add(new XYChart.Data<>(f.getEtiqueta(), f.getCantidad()));
            }
            grafEdades.setData(FXCollections.observableArrayList(List.of(serie)));
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ------------------ Perdidas y encontradas por cantón -------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onActualizarCantones() {
        try {
            List<ConteoPorCanton> filas = estadisticaManager.perdidasYEncontradasPorCanton(
                    dpDesdeCantones.getValue(), dpHastaCantones.getValue());
            tblCantones.setItems(FXCollections.observableArrayList(filas));
            int total = 0;
            for (ConteoPorCanton f : filas) {
                total += f.getCantidad();
            }
            lblTotalCantones.setText("Total de mascotas: " + total);

            // Una serie por estado (perdida o encontrada); cada barra es un cantón.
            Map<String, XYChart.Series<String, Number>> series = new LinkedHashMap<>();
            for (ConteoPorCanton f : filas) {
                XYChart.Series<String, Number> serie = series.computeIfAbsent(f.getEstado(), nombre -> {
                    XYChart.Series<String, Number> nueva = new XYChart.Series<>();
                    nueva.setName(nombre);
                    return nueva;
                });
                serie.getData().add(new XYChart.Data<>(f.getCanton(), f.getCantidad()));
            }
            grafCantones.setData(FXCollections.observableArrayList(series.values()));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise las fechas", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ---------------------- Donaciones por rescatista -----------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onActualizarRescatistas() {
        try {
            tblRescatistas.setItems(FXCollections.observableArrayList(estadisticaManager.donacionesPorRescatista(
                    dpDesdeRescatistas.getValue(), dpHastaRescatistas.getValue())));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise las fechas", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }
}
