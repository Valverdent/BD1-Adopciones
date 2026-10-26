package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.CasaCunaManager;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;

/**
 * Controlador de la consulta de casas cuna (CasaCunaConsulta.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCunaConsultaController {

    private static final String OPCION_SI = "Sí";
    private static final String OPCION_NO = "No";

    @FXML private ComboBox<ItemCatalogo> cmbTipo;
    @FXML private ComboBox<ItemCatalogo> cmbTamano;
    @FXML private ComboBox<ItemCatalogo> cmbEstado;
    @FXML private ComboBox<String> cmbDonacion;
    /** Filtro por lugar: bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private CheckBox chkSoloDisponibles;
    @FXML private Button btnMiCasa;

    @FXML private TableView<CasaCuna> tblCasas;
    @FXML private TableColumn<CasaCuna, String> colPersona;
    @FXML private TableColumn<CasaCuna, String> colLugar;
    @FXML private TableColumn<CasaCuna, String> colEstado;
    @FXML private TableColumn<CasaCuna, String> colOcupacion;
    @FXML private TableColumn<CasaCuna, String> colDisponible;
    @FXML private TableColumn<CasaCuna, String> colTamanos;
    @FXML private TableColumn<CasaCuna, String> colDonacion;
    @FXML private TableColumn<CasaCuna, String> colContacto;
    @FXML private Label lblTotalRegistros;

    private final CasaCunaManager casaCunaManager = new CasaCunaManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cmbTipo.setItems(FXCollections.observableArrayList(casaCunaManager.listarCatalogo(TipoCatalogo.TIPO_MASCOTA)));
        cmbTamano.setItems(FXCollections.observableArrayList(casaCunaManager.listarCatalogo(TipoCatalogo.TAMANO)));
        cmbEstado.setItems(FXCollections.observableArrayList(casaCunaManager.listarCatalogo(TipoCatalogo.ESTADO_CASA_CUNA)));
        cmbDonacion.setItems(FXCollections.observableArrayList(OPCION_SI, OPCION_NO));
        ubicacionController.usarComoFiltro();

        colPersona.setCellValueFactory(fila -> texto(fila.getValue().getNombrePersona()));
        colLugar.setCellValueFactory(fila -> texto(Ubicacion.resumenDe(fila.getValue().getUbicacion())));
        colEstado.setCellValueFactory(fila -> texto(fila.getValue().getEstado().getNombre()));
        colOcupacion.setCellValueFactory(fila -> texto(fila.getValue().getCantidadActual() + " / " + fila.getValue().getCapacidadMaxima()));
        colDisponible.setCellValueFactory(fila -> texto(fila.getValue().isDisponible() ? "Sí" : "No"));
        colTamanos.setCellValueFactory(fila -> texto(nombres(fila.getValue().getTamanos())));
        colDonacion.setCellValueFactory(fila -> texto(fila.getValue().isRequiereDonacionAlimentos() ? "Sí" : "No"));
        colContacto.setCellValueFactory(fila -> texto(contacto(fila.getValue())));

        tblCasas.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblCasas.getSelectionModel().getSelectedItem() != null) {
                onAbrir();
            }
        });
        onBuscar();
    }

    /**
     * Aplica un tipo y un tamaño (por ejemplo, desde el formulario de una mascota) y busca solo
     * las disponibles.
     */
    public void prefiltrar(ItemCatalogo tipo, ItemCatalogo tamano) {
        cmbTipo.setValue(tipo);
        cmbTamano.setValue(tamano);
        chkSoloDisponibles.setSelected(true);
        onBuscar();
    }

    private String nombres(List<ItemCatalogo> items) {
        List<String> nombres = new ArrayList<>();
        for (ItemCatalogo i : items) {
            nombres.add(i.getNombre());
        }
        return String.join(", ", nombres);
    }

    private String contacto(CasaCuna c) {
        List<String> partes = new ArrayList<>(c.getTelefonos());
        partes.addAll(c.getCorreos());
        return String.join(" | ", partes);
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Búsqueda -------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onBuscar() {
        FiltroCasaCuna filtro = new FiltroCasaCuna();
        filtro.setTipoMascota(cmbTipo.getValue());
        filtro.setTamano(cmbTamano.getValue());
        filtro.setEstado(cmbEstado.getValue());
        String donacion = cmbDonacion.getValue();
        filtro.setRequiereDonacionAlimentos(donacion == null ? null : OPCION_SI.equals(donacion));
        filtro.setUbicacion(ubicacionController.leerFiltro());
        filtro.setSoloDisponibles(chkSoloDisponibles.isSelected());

        List<CasaCuna> resultados = casaCunaManager.consultar(filtro);
        tblCasas.setItems(FXCollections.observableArrayList(resultados));
        lblTotalRegistros.setText("Total de registros: " + resultados.size());
    }

    @FXML
    private void onLimpiar() {
        cmbTipo.setValue(null);
        cmbTamano.setValue(null);
        cmbEstado.setValue(null);
        cmbDonacion.setValue(null);
        ubicacionController.limpiar();
        chkSoloDisponibles.setSelected(false);
        onBuscar();
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Navegación ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onMiCasa() {
        Optional<CasaCuna> mia = casaCunaManager.miCasaCuna();
        CasaCunaFormularioController formulario = Navegador.mostrarEnContenido("CasaCunaFormulario.fxml");
        if (mia.isPresent()) {
            formulario.mostrarCasa(mia.get());
        } else {
            formulario.prepararNueva();
        }
    }

    @FXML
    private void onAbrir() {
        CasaCuna seleccionada = tblCasas.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una casa cuna", "Seleccione una fila de la tabla para verla.");
            return;
        }
        CasaCunaFormularioController formulario = Navegador.mostrarEnContenido("CasaCunaFormulario.fxml");
        formulario.mostrarCasa(seleccionada);
    }
}
