package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.ConsultaAdicionalManager;
import com.mycompany.bd_proyecto1.model.DisponibilidadCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

/**
 * Controlador de las consultas adicionales (ConsultasAdicionales.fxml): casas cuna con espacio y
 * mascotas perdidas ordenadas por recompensa.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class ConsultasAdicionalesController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DecimalFormat FORMATO_MONTO = new DecimalFormat("#,##0");

    // Casas cuna con espacio
    @FXML private ComboBox<ItemCatalogo> cmbProvinciaCasas;
    @FXML private ComboBox<ItemCatalogo> cmbTipoCasas;
    @FXML private TextField txtEspacios;
    @FXML private TableView<DisponibilidadCasaCuna> tblCasas;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaPersona;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaLugar;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaTipo;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaEspacios;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaOcupacion;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaEstado;
    @FXML private TableColumn<DisponibilidadCasaCuna, String> colCasaDonacion;
    @FXML private Label lblTotalCasas;

    // Mascotas perdidas por recompensa
    @FXML private ComboBox<ItemCatalogo> cmbTipoPerdidas;
    @FXML private ComboBox<ItemCatalogo> cmbProvinciaPerdidas;
    @FXML private TableView<Mascota> tblPerdidas;
    @FXML private TableColumn<Mascota, String> colPerdNombre;
    @FXML private TableColumn<Mascota, String> colPerdTipo;
    @FXML private TableColumn<Mascota, String> colPerdDescripcion;
    @FXML private TableColumn<Mascota, String> colPerdFecha;
    @FXML private TableColumn<Mascota, String> colPerdLugar;
    @FXML private TableColumn<Mascota, String> colPerdRecompensa;
    @FXML private TableColumn<Mascota, String> colPerdPersona;
    @FXML private Label lblTotalPerdidas;

    private final ConsultaAdicionalManager consultaManager = new ConsultaAdicionalManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        List<ItemCatalogo> provincias = consultaManager.listarProvincias();
        List<ItemCatalogo> tipos = consultaManager.listarTipos();
        cmbProvinciaCasas.setItems(FXCollections.observableArrayList(provincias));
        cmbProvinciaPerdidas.setItems(FXCollections.observableArrayList(provincias));
        cmbTipoCasas.setItems(FXCollections.observableArrayList(tipos));
        cmbTipoPerdidas.setItems(FXCollections.observableArrayList(tipos));

        colCasaPersona.setCellValueFactory(f -> texto(f.getValue().getNombrePersona()));
        colCasaLugar.setCellValueFactory(f -> texto(f.getValue().getLugar()));
        colCasaTipo.setCellValueFactory(f -> texto(f.getValue().getTipoMascota()));
        colCasaEspacios.setCellValueFactory(f -> texto(String.valueOf(f.getValue().getEspaciosLibres())));
        colCasaOcupacion.setCellValueFactory(f -> texto(f.getValue().getCantidadActual() + " / "
                + f.getValue().getCapacidadMaxima()));
        colCasaEstado.setCellValueFactory(f -> texto(f.getValue().getEstado()));
        colCasaDonacion.setCellValueFactory(f -> texto(f.getValue().isRequiereDonacionAlimentos() ? "Sí" : "No"));

        colPerdNombre.setCellValueFactory(f -> texto(f.getValue().getNombre()));
        colPerdTipo.setCellValueFactory(f -> texto(f.getValue().getTipo().getNombre() + ", "
                + f.getValue().getRaza().getNombre()));
        colPerdDescripcion.setCellValueFactory(f -> texto(f.getValue().getColor().getNombre() + ", "
                + f.getValue().getTamano().getNombre()));
        colPerdFecha.setCellValueFactory(f -> texto(f.getValue().getFechaEvento() == null ? ""
                : f.getValue().getFechaEvento().format(FORMATO_FECHA)));
        colPerdLugar.setCellValueFactory(f -> texto(Ubicacion.resumenDe(f.getValue().getUbicacion())));
        colPerdRecompensa.setCellValueFactory(f -> texto(recompensa(f.getValue())));
        colPerdPersona.setCellValueFactory(f -> texto(f.getValue().getNombrePersonaRegistro()));

        onBuscarCasas();
        onBuscarPerdidas();
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String recompensa(Mascota m) {
        if (m.getMontoRecompensa() == null) {
            return "Sin recompensa";
        }
        String moneda = m.getMonedaRecompensa() == null ? "" : " " + m.getMonedaRecompensa().getNombre();
        return FORMATO_MONTO.format(m.getMontoRecompensa()) + moneda;
    }

    // ------------------------------------------------------------------------
    // ------------------------ Casas cuna disponibles ------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscarCasas() {
        try {
            List<DisponibilidadCasaCuna> filas = consultaManager.casasCunaConEspacio(
                    cmbProvinciaCasas.getValue(), cmbTipoCasas.getValue(), txtEspacios.getText());
            tblCasas.setItems(FXCollections.observableArrayList(filas));
            lblTotalCasas.setText("Total de registros: " + filas.size());
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        }
    }

    @FXML
    private void onLimpiarCasas() {
        cmbProvinciaCasas.setValue(null);
        cmbTipoCasas.setValue(null);
        txtEspacios.setText("1");
        onBuscarCasas();
    }

    // ------------------------------------------------------------------------
    // -------------------------- Mascotas perdidas ---------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscarPerdidas() {
        List<Mascota> filas = consultaManager.mascotasPerdidasPorRecompensa(
                cmbTipoPerdidas.getValue(), cmbProvinciaPerdidas.getValue());
        tblPerdidas.setItems(FXCollections.observableArrayList(filas));
        lblTotalPerdidas.setText("Total de mascotas: " + filas.size());
    }

    @FXML
    private void onLimpiarPerdidas() {
        cmbTipoPerdidas.setValue(null);
        cmbProvinciaPerdidas.setValue(null);
        onBuscarPerdidas();
    }
}
