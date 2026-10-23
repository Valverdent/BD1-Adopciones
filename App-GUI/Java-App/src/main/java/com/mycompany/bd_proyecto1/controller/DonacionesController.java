package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.DonacionManager;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.DetalleDonacion;
import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.FilaDonacion;
import com.mycompany.bd_proyecto1.model.FiltroDonacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.TipoDonacion;
import com.mycompany.bd_proyecto1.model.TotalAsociacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.TabPane;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.TextInputDialog;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.VBox;
import javafx.util.StringConverter;

/**
 * Controlador de la pantalla de donaciones (Donaciones.fxml), con tres pestañas: consulta, nueva
 * donación y totales por asociación. Las reglas las valida el DonacionManager.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class DonacionesController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private TabPane tabPane;

    // ------------------------------------------------------------------------
    // --------------------------- Campos: Consulta ---------------------------
    // ------------------------------------------------------------------------
    @FXML private VBox boxDonador;
    @FXML private TextField txtDonador;
    @FXML private ComboBox<AsociacionBienestar> cmbFiltroAsociacion;
    @FXML private TextField txtMontoMinimo;
    @FXML private TextField txtMontoMaximo;
    @FXML private DatePicker dpDesde;
    @FXML private DatePicker dpHasta;
    @FXML private TableView<FilaDonacion> tblDonaciones;
    @FXML private TableColumn<FilaDonacion, String> colFecha;
    @FXML private TableColumn<FilaDonacion, String> colDonador;
    @FXML private TableColumn<FilaDonacion, String> colTipo;
    @FXML private TableColumn<FilaDonacion, String> colAsociacion;
    @FXML private TableColumn<FilaDonacion, String> colPorcentaje;
    @FXML private TableColumn<FilaDonacion, String> colMonto;
    @FXML private TableColumn<FilaDonacion, String> colMoneda;
    @FXML private TableColumn<FilaDonacion, String> colMascota;
    @FXML private Label lblTotalRegistros;
    @FXML private Label lblTotalMontos;
    @FXML private Button btnCorregir;

    // ------------------------------------------------------------------------
    // ------------------------ Campos: Nueva donación ------------------------
    // ------------------------------------------------------------------------
    @FXML private ToggleGroup grupoTipo;
    @FXML private ToggleGroup grupoReparto;
    @FXML private RadioButton rbVoluntaria;
    @FXML private RadioButton rbRecompensa;
    @FXML private RadioButton rbUna;
    @FXML private RadioButton rbPorcentaje;
    @FXML private GridPane panelVoluntaria;
    @FXML private TextField txtMonto;
    @FXML private ComboBox<ItemCatalogo> cmbMoneda;
    @FXML private VBox panelRecompensa;
    @FXML private ComboBox<Mascota> cmbMascotaRecompensa;
    @FXML private Label lblRecompensa;
    @FXML private Label lblSinRecompensas;
    @FXML private DatePicker dpFechaDonacion;
    @FXML private ComboBox<AsociacionBienestar> cmbAsociacion;
    @FXML private VBox boxPorcentaje;
    @FXML private TextField txtPorcentaje;
    @FXML private TableView<DetalleDonacion> tblReparto;
    @FXML private TableColumn<DetalleDonacion, String> colRepartoAsociacion;
    @FXML private TableColumn<DetalleDonacion, String> colRepartoPorcentaje;
    @FXML private Label lblSumaPorcentajes;

    // ------------------------------------------------------------------------
    // -------------------- Campos: Totales por asociación --------------------
    // ------------------------------------------------------------------------
    @FXML private DatePicker dpTotalesDesde;
    @FXML private DatePicker dpTotalesHasta;
    @FXML private TableView<TotalAsociacion> tblTotales;
    @FXML private TableColumn<TotalAsociacion, String> colTotAsociacion;
    @FXML private TableColumn<TotalAsociacion, String> colTotMoneda;
    @FXML private TableColumn<TotalAsociacion, String> colTotCantidad;
    @FXML private TableColumn<TotalAsociacion, String> colTotMonto;
    @FXML private Label lblTotalGeneral;

    private final DonacionManager donacionManager = new DonacionManager();
    private final ObservableList<DetalleDonacion> repartoActual = FXCollections.observableArrayList();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        boolean admin = donacionManager.esAdministrador();
        mostrar(boxDonador, admin);
        mostrar(btnCorregir, admin);

        List<AsociacionBienestar> asociaciones = donacionManager.listarAsociaciones();
        cmbFiltroAsociacion.setItems(FXCollections.observableArrayList(asociaciones));
        cmbAsociacion.setItems(FXCollections.observableArrayList(asociaciones));
        cmbMoneda.setItems(FXCollections.observableArrayList(donacionManager.listarMonedas()));

        configurarColumnas();
        configurarNuevaDonacion();

        // Totales: por defecto, desde el inicio del año hasta hoy.
        dpTotalesDesde.setValue(LocalDate.of(LocalDate.now().getYear(), 1, 1));
        dpTotalesHasta.setValue(LocalDate.now());

        onBuscar();
        onConsultarTotales();
    }

    private void mostrar(Node nodo, boolean visible) {
        nodo.setVisible(visible);
        nodo.setManaged(visible);
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String dinero(BigDecimal monto) {
        return String.format("%,.2f", monto);
    }

    private void configurarColumnas() {
        colFecha.setCellValueFactory(fila -> texto(fila.getValue().getFecha().format(FORMATO_FECHA)));
        colDonador.setCellValueFactory(fila -> texto(fila.getValue().getNombreDonador()));
        colTipo.setCellValueFactory(fila -> texto(fila.getValue().getTipo().getDescripcion()));
        colAsociacion.setCellValueFactory(fila -> texto(fila.getValue().getAsociacion().getNombre()));
        colPorcentaje.setCellValueFactory(fila -> texto(fila.getValue().getPorcentaje() == null
                ? "—" : fila.getValue().getPorcentaje().stripTrailingZeros().toPlainString() + " %"));
        colMonto.setCellValueFactory(fila -> texto(dinero(fila.getValue().getMonto())));
        colMoneda.setCellValueFactory(fila -> texto(fila.getValue().getMoneda().getNombre()));
        colMascota.setCellValueFactory(fila -> texto(fila.getValue().getNombreMascota()));

        colRepartoAsociacion.setCellValueFactory(fila -> texto(fila.getValue().getAsociacion().getNombre()));
        colRepartoPorcentaje.setCellValueFactory(fila -> texto(fila.getValue().getPorcentaje() == null
                ? "100 % (completa)" : fila.getValue().getPorcentaje().stripTrailingZeros().toPlainString() + " %"));

        colTotAsociacion.setCellValueFactory(fila -> texto(fila.getValue().getAsociacion().getNombre()));
        colTotMoneda.setCellValueFactory(fila -> texto(fila.getValue().getMoneda().getNombre()));
        colTotCantidad.setCellValueFactory(fila -> texto(String.valueOf(fila.getValue().getCantidadDonaciones())));
        colTotMonto.setCellValueFactory(fila -> texto(dinero(fila.getValue().getTotal())));
    }

    // ================= Consulta =================

    // ------------------------------------------------------------------------
    // ----------------------- Historial de donaciones ------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscar() {
        try {
            FiltroDonacion filtro = new FiltroDonacion();
            filtro.setDonador(txtDonador.getText());
            filtro.setAsociacion(cmbFiltroAsociacion.getValue());
            filtro.setMontoMinimo(donacionManager.convertirMontoDeBusqueda(txtMontoMinimo.getText()));
            filtro.setMontoMaximo(donacionManager.convertirMontoDeBusqueda(txtMontoMaximo.getText()));
            filtro.setFechaDesde(dpDesde.getValue());
            filtro.setFechaHasta(dpHasta.getValue());

            List<FilaDonacion> filas = donacionManager.consultar(filtro);
            tblDonaciones.setItems(FXCollections.observableArrayList(filas));
            mostrarTotales(filas);
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    private void mostrarTotales(List<FilaDonacion> filas) {
        lblTotalRegistros.setText("Total de registros: " + filas.size());
        lblTotalMontos.setText("Total de montos: " + textoTotales(donacionManager.totalMontosPorMoneda(filas)));
    }

    private String textoTotales(Map<String, BigDecimal> totales) {
        if (totales.isEmpty()) {
            return "0";
        }
        StringBuilder texto = new StringBuilder();
        for (Map.Entry<String, BigDecimal> total : totales.entrySet()) {
            if (texto.length() > 0) {
                texto.append("  |  ");
            }
            texto.append(dinero(total.getValue())).append(" ").append(total.getKey());
        }
        return texto.toString();
    }

    @FXML
    private void onLimpiar() {
        txtDonador.clear();
        cmbFiltroAsociacion.setValue(null);
        txtMontoMinimo.clear();
        txtMontoMaximo.clear();
        dpDesde.setValue(null);
        dpHasta.setValue(null);
        onBuscar();
    }

    @FXML
    private void onCorregirMonto() {
        FilaDonacion fila = tblDonaciones.getSelectionModel().getSelectedItem();
        if (fila == null) {
            Alertas.mostrarInformacion("Seleccione una donación", "Seleccione una fila de la tabla para corregir el monto de su donación.");
            return;
        }
        TextInputDialog dialogo = new TextInputDialog();
        dialogo.setTitle("Corregir monto");
        dialogo.setHeaderText("Donación del " + fila.getFecha().format(FORMATO_FECHA) + ": "
                + dinero(fila.getMontoTotalDonacion()) + " " + fila.getMoneda().getNombre()
                + ".\nEl reparto entre las asociaciones se recalcula con los mismos porcentajes.");
        dialogo.setContentText("Nuevo monto total:");
        Optional<String> respuesta = dialogo.showAndWait();
        if (respuesta.isEmpty()) {
            return;
        }
        try {
            donacionManager.corregirMonto(fila.getIdDonacion(), donacionManager.convertirMonto(respuesta.get()));
            Alertas.mostrarInformacion("Monto corregido", "El monto de la donación se actualizó. El cambio queda en la bitácora.");
            onBuscar();
            onConsultarTotales();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise el monto", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ================= Nueva donación =================

    // ------------------------------------------------------------------------
    // ---------------------------- Nueva donación ----------------------------
    // ------------------------------------------------------------------------

    private void configurarNuevaDonacion() {
        tblReparto.setItems(repartoActual);
        cmbMascotaRecompensa.setConverter(new StringConverter<>() {
            @Override
            public String toString(Mascota m) {
                if (m == null) {
                    return "";
                }
                String nombre = m.getNombre() == null || m.getNombre().isBlank() ? "(sin nombre)" : m.getNombre();
                return nombre + " · " + m.getTipo().getNombre() + " · " + textoRecompensa(m);
            }

            @Override
            public Mascota fromString(String texto) {
                return null;
            }
        });
        cmbMascotaRecompensa.valueProperty().addListener((observable, anterior, nueva) ->
                lblRecompensa.setText(nueva == null ? "" : "Se donará toda la recompensa: " + textoRecompensa(nueva)));

        // Cambiar el tipo muestra los campos que corresponden.
        grupoTipo.selectedToggleProperty().addListener((observable, anterior, nuevo) -> actualizarTipo());
        // Cambiar la forma de repartir vacía la lista, para no mezclar formas.
        grupoReparto.selectedToggleProperty().addListener((observable, anterior, nuevo) -> {
            repartoActual.clear();
            actualizarReparto();
        });

        cargarRecompensas();
        dpFechaDonacion.setValue(LocalDate.now());
        actualizarTipo();
        actualizarReparto();
    }

    private String textoRecompensa(Mascota m) {
        return dinero(m.getMontoRecompensa()) + " " + m.getMonedaRecompensa().getNombre();
    }

    private void cargarRecompensas() {
        List<Mascota> disponibles = donacionManager.listarRecompensasDisponibles();
        cmbMascotaRecompensa.setItems(FXCollections.observableArrayList(disponibles));
        cmbMascotaRecompensa.setValue(null);
        lblSinRecompensas.setText(disponibles.isEmpty()
                ? "No tiene mascotas con recompensa disponible para donar." : "");
    }

    private void actualizarTipo() {
        boolean recompensa = rbRecompensa.isSelected();
        mostrar(panelVoluntaria, !recompensa);
        mostrar(panelRecompensa, recompensa);
    }

    private void actualizarReparto() {
        boolean porcentaje = rbPorcentaje.isSelected();
        mostrar(boxPorcentaje, porcentaje);
        if (porcentaje) {
            BigDecimal suma = donacionManager.sumaPorcentajes(repartoActual);
            lblSumaPorcentajes.setText("Suma de porcentajes: " + suma.stripTrailingZeros().toPlainString() + " % (debe ser 100)");
        } else {
            lblSumaPorcentajes.setText("");
        }
    }

    @FXML
    private void onAgregarAsociacion() {
        AsociacionBienestar asociacion = cmbAsociacion.getValue();
        if (asociacion == null) {
            Alertas.mostrarInformacion("Seleccione una asociación", "Elija una asociación de la lista para agregarla.");
            return;
        }
        if (rbUna.isSelected()) {
            // Una sola asociación: la nueva elección reemplaza a la anterior.
            repartoActual.setAll(new DetalleDonacion(asociacion, null));
        } else {
            BigDecimal porcentaje;
            try {
                porcentaje = donacionManager.convertirPorcentaje(txtPorcentaje.getText());
            } catch (IllegalArgumentException e) {
                Alertas.mostrarError("Revise el porcentaje", e.getMessage());
                return;
            }
            for (DetalleDonacion existente : repartoActual) {
                if (existente.getAsociacion().equals(asociacion)) {
                    Alertas.mostrarInformacion("Asociación repetida", "Esa asociación ya está en el reparto.");
                    return;
                }
            }
            repartoActual.add(new DetalleDonacion(asociacion, porcentaje));
            txtPorcentaje.clear();
        }
        cmbAsociacion.setValue(null);
        actualizarReparto();
    }

    @FXML
    private void onQuitarAsociacion() {
        DetalleDonacion seleccionada = tblReparto.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una asociación", "Seleccione en la tabla la asociación que desea quitar.");
            return;
        }
        repartoActual.remove(seleccionada);
        actualizarReparto();
    }

    @FXML
    private void onRegistrar() {
        try {
            Donacion donacion = new Donacion();
            if (rbRecompensa.isSelected()) {
                donacion.setTipo(TipoDonacion.RECOMPENSA);
                donacion.setMascota(cmbMascotaRecompensa.getValue());
            } else {
                donacion.setTipo(TipoDonacion.VOLUNTARIA);
                donacion.setMontoTotal(donacionManager.convertirMonto(txtMonto.getText()));
                donacion.setMoneda(cmbMoneda.getValue());
            }
            donacion.setFecha(dpFechaDonacion.getValue());
            donacion.setDetalles(new ArrayList<>(repartoActual));

            donacionManager.registrarDonacion(donacion);
            Alertas.mostrarInformacion("Donación registrada", "La donación se registró correctamente. ¡Gracias por ayudar!");
            onLimpiarNueva();
            cargarRecompensas();
            onBuscar();
            onConsultarTotales();
            tabPane.getSelectionModel().select(0);
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    @FXML
    private void onLimpiarNueva() {
        rbVoluntaria.setSelected(true);
        rbUna.setSelected(true);
        txtMonto.clear();
        cmbMoneda.setValue(null);
        cmbMascotaRecompensa.setValue(null);
        dpFechaDonacion.setValue(LocalDate.now());
        cmbAsociacion.setValue(null);
        txtPorcentaje.clear();
        repartoActual.clear();
        actualizarTipo();
        actualizarReparto();
    }

    // ================= Totales por asociación =================

    // ------------------------------------------------------------------------
    // ------------------------ Totales por asociación ------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onConsultarTotales() {
        try {
            List<TotalAsociacion> totales = donacionManager.totalesPorAsociacion(
                    dpTotalesDesde.getValue(), dpTotalesHasta.getValue());
            tblTotales.setItems(FXCollections.observableArrayList(totales));
            lblTotalGeneral.setText("Total general: " + textoTotales(donacionManager.totalGeneralPorMoneda(totales)));
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise las fechas", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }
}
