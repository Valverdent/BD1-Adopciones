package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.ParametroManager;
import com.mycompany.bd_proyecto1.manager.ReporteManager;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MascotaSinAdoptar;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
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
 * Controlador de la consulta de mascotas sin adoptar (MascotasSinAdoptar.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotasSinAdoptarController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private TextField txtMeses;
    @FXML private ComboBox<ItemCatalogo> cmbTipo;

    @FXML private TableView<MascotaSinAdoptar> tblMascotas;
    @FXML private TableColumn<MascotaSinAdoptar, String> colNombre;
    @FXML private TableColumn<MascotaSinAdoptar, String> colTipo;
    @FXML private TableColumn<MascotaSinAdoptar, String> colRaza;
    @FXML private TableColumn<MascotaSinAdoptar, String> colLugar;
    @FXML private TableColumn<MascotaSinAdoptar, String> colFecha;
    @FXML private TableColumn<MascotaSinAdoptar, String> colDias;
    @FXML private TableColumn<MascotaSinAdoptar, String> colRegistradaPor;
    @FXML private TableColumn<MascotaSinAdoptar, String> colContacto;
    @FXML private Label lblTotalRegistros;

    private final ReporteManager reporteManager = new ReporteManager();
    private final ParametroManager parametroManager = new ParametroManager();

    @FXML
    private void initialize() {
        txtMeses.setText(String.valueOf(parametroManager.valorEntero(ParametroManager.MESES_SIN_ADOPTAR)));
        cmbTipo.setItems(FXCollections.observableArrayList(reporteManager.listarTipos()));

        colNombre.setCellValueFactory(fila -> texto(nombre(fila.getValue().getMascota())));
        colTipo.setCellValueFactory(fila -> texto(fila.getValue().getMascota().getTipo().getNombre()));
        colRaza.setCellValueFactory(fila -> texto(fila.getValue().getMascota().getRaza().getNombre()));
        colLugar.setCellValueFactory(fila -> texto(Ubicacion.resumenDe(fila.getValue().getMascota().getUbicacion())));
        colFecha.setCellValueFactory(fila -> texto(fila.getValue().getMascota().getFechaEvento().format(FORMATO_FECHA)));
        colDias.setCellValueFactory(fila -> texto(String.valueOf(fila.getValue().getDiasEspera())));
        colRegistradaPor.setCellValueFactory(fila -> texto(fila.getValue().getMascota().getNombrePersonaRegistro()));
        colContacto.setCellValueFactory(fila -> texto(contacto(fila.getValue().getMascota())));
        onBuscar();
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String nombre(Mascota m) {
        return m.getNombre() == null || m.getNombre().isBlank() ? "(sin nombre)" : m.getNombre();
    }

    private String contacto(Mascota m) {
        boolean tel = m.getTelefonoContacto() != null && !m.getTelefonoContacto().isBlank();
        boolean cor = m.getCorreoContacto() != null && !m.getCorreoContacto().isBlank();
        if (tel && cor) {
            return m.getTelefonoContacto() + " | " + m.getCorreoContacto();
        }
        return tel ? m.getTelefonoContacto() : cor ? m.getCorreoContacto() : "";
    }

    @FXML
    private void onBuscar() {
        try {
            int meses = reporteManager.convertirMeses(txtMeses.getText());
            List<MascotaSinAdoptar> resultados = reporteManager.listarSinAdoptar(meses, cmbTipo.getValue());
            tblMascotas.setItems(FXCollections.observableArrayList(resultados));
            lblTotalRegistros.setText("Total de registros: " + resultados.size());
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise la búsqueda", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    @FXML
    private void onLimpiar() {
        txtMeses.setText(String.valueOf(parametroManager.valorEntero(ParametroManager.MESES_SIN_ADOPTAR)));
        cmbTipo.setValue(null);
        onBuscar();
    }

    @FXML
    private void onVolver() {
        Navegador.mostrarEnContenido("MascotaConsulta.fxml");
    }
}
