package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.ParametroManager;
import com.mycompany.bd_proyecto1.manager.ReporteManager;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MatchMascotas;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import java.io.File;
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
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.GridPane;

/**
 * Controlador del reporte de matches (Matches.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MatchesController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private TextField txtPorcentaje;
    @FXML private ComboBox<ItemCatalogo> cmbTipo;

    @FXML private TableView<MatchMascotas> tblMatches;
    @FXML private TableColumn<MatchMascotas, String> colPorcentaje;
    @FXML private TableColumn<MatchMascotas, String> colPerdida;
    @FXML private TableColumn<MatchMascotas, String> colEncontrada;
    @FXML private TableColumn<MatchMascotas, String> colTipo;
    @FXML private TableColumn<MatchMascotas, String> colCriterios;
    @FXML private Label lblTotal;

    @FXML private GridPane panelDetalle;
    @FXML private ImageView imgPerdida;
    @FXML private ImageView imgEncontrada;
    @FXML private Label lblFotoPerdida;
    @FXML private Label lblFotoEncontrada;
    @FXML private Label lblDatosPerdida;
    @FXML private Label lblDatosEncontrada;

    private final ReporteManager reporteManager = new ReporteManager();
    private final ParametroManager parametroManager = new ParametroManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        txtPorcentaje.setText(String.valueOf(parametroManager.valorEntero(ParametroManager.PORCENTAJE_MINIMO_MATCH)));
        cmbTipo.setItems(FXCollections.observableArrayList(reporteManager.listarTipos()));

        colPorcentaje.setCellValueFactory(fila -> texto(fila.getValue().getPorcentaje() + " %"));
        colPerdida.setCellValueFactory(fila -> texto(nombre(fila.getValue().getPerdida())));
        colEncontrada.setCellValueFactory(fila -> texto(nombre(fila.getValue().getEncontrada())));
        colTipo.setCellValueFactory(fila -> texto(fila.getValue().getPerdida().getTipo().getNombre()));
        colCriterios.setCellValueFactory(fila -> texto(String.join(", ", fila.getValue().getCriterios())));

        tblMatches.getSelectionModel().selectedItemProperty().addListener(
                (observable, anterior, nuevo) -> mostrarDetalle(nuevo));
        panelDetalle.setVisible(false);
        panelDetalle.setManaged(false);
        lblTotal.setText("Pulse \"Generar reporte\" para buscar matches.");
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    private String nombre(Mascota m) {
        return m.getNombre() == null || m.getNombre().isBlank() ? "(sin nombre)" : m.getNombre();
    }

    // ------------------------------------------------------------------------
    // ------------------------ Generación de matches -------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onGenerar() {
        try {
            int minimo = reporteManager.convertirPorcentaje(txtPorcentaje.getText());
            List<MatchMascotas> resultados = reporteManager.generarMatches(minimo, cmbTipo.getValue());
            tblMatches.setItems(FXCollections.observableArrayList(resultados));
            lblTotal.setText("Total de matches: " + resultados.size());
            mostrarDetalle(null);
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // -------------------------- Detalle del match ---------------------------
    // ------------------------------------------------------------------------

    private void mostrarDetalle(MatchMascotas match) {
        boolean hay = match != null;
        panelDetalle.setVisible(hay);
        panelDetalle.setManaged(hay);
        if (!hay) {
            return;
        }
        mostrarMascota(match.getPerdida(), imgPerdida, lblFotoPerdida, lblDatosPerdida);
        mostrarMascota(match.getEncontrada(), imgEncontrada, lblFotoEncontrada, lblDatosEncontrada);
    }

    private void mostrarMascota(Mascota m, ImageView imagen, Label lblFoto, Label lblDatos) {
        String ruta = m.getFotoAntes() != null && !m.getFotoAntes().isBlank() ? m.getFotoAntes() : m.getFotoDespues();
        imagen.setImage(cargarImagen(ruta));
        lblFoto.setText(imagen.getImage() == null ? "Sin foto" : "");

        StringBuilder datos = new StringBuilder();
        datos.append(nombre(m)).append(" - ").append(m.getTipo().getNombre()).append(", ").append(m.getRaza().getNombre()).append('\n');
        datos.append("Color: ").append(m.getColor().getNombre()).append("  |  Tamaño: ").append(m.getTamano().getNombre()).append('\n');
        datos.append("Fecha: ").append(m.getFechaEvento().format(FORMATO_FECHA)).append('\n');
        datos.append("Lugar: ").append(Ubicacion.descripcionDe(m.getUbicacion())).append('\n');
        if (m.getChip() != null && !m.getChip().isBlank()) {
            datos.append("Chip: ").append(m.getChip()).append('\n');
        }
        datos.append("Registrada por: ").append(m.getNombrePersonaRegistro()).append('\n');
        datos.append("Contacto: ").append(contacto(m));
        lblDatos.setText(datos.toString());
    }

    private String contacto(Mascota m) {
        boolean tel = m.getTelefonoContacto() != null && !m.getTelefonoContacto().isBlank();
        boolean cor = m.getCorreoContacto() != null && !m.getCorreoContacto().isBlank();
        if (tel && cor) {
            return m.getTelefonoContacto() + " | " + m.getCorreoContacto();
        }
        return tel ? m.getTelefonoContacto() : cor ? m.getCorreoContacto() : "sin datos de contacto";
    }

    /**
     * Devuelve la imagen del enlace de internet (o del archivo, en los datos de prueba), o null si
     * no hay foto.
     */
    private Image cargarImagen(String ruta) {
        if (ruta == null || ruta.isBlank()) {
            return null;
        }
        String minusculas = ruta.toLowerCase();
        if (minusculas.startsWith("http://") || minusculas.startsWith("https://")) {
            return new Image(ruta.trim(), 220, 160, true, true, true);   // se descarga en segundo plano
        }
        File archivo = new File(ruta);
        return archivo.isFile() ? new Image(archivo.toURI().toString(), 220, 160, true, true) : null;
    }
}
