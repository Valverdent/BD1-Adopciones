package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.PersonaManager;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

/**
 * Controlador de la consulta de personas (PersonaConsulta.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaConsultaController {

    static final String ARCHIVO = "PersonaConsulta.fxml";

    @FXML private TextField txtNombre;
    /** Filtro por lugar: bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private Button btnNueva;

    @FXML private TableView<Persona> tblPersonas;
    @FXML private TableColumn<Persona, String> colNombre;
    @FXML private TableColumn<Persona, String> colLugar;
    @FXML private TableColumn<Persona, String> colTelefonos;
    @FXML private TableColumn<Persona, String> colCorreos;
    @FXML private Label lblTotalRegistros;

    private final PersonaManager personaManager = new PersonaManager();

    @FXML
    private void initialize() {
        // Solo el administrador registra personas nuevas.
        boolean admin = Sesion.getUsuario() != null && Sesion.getUsuario().esAdministrador();
        btnNueva.setVisible(admin);
        btnNueva.setManaged(admin);
        ubicacionController.usarComoFiltro();

        colNombre.setCellValueFactory(fila -> texto(fila.getValue().getNombreCompleto()));
        colLugar.setCellValueFactory(fila -> texto(Ubicacion.resumenDe(fila.getValue().getUbicacion())));
        colTelefonos.setCellValueFactory(fila -> texto(String.join(", ", fila.getValue().getTelefonos())));
        colCorreos.setCellValueFactory(fila -> texto(String.join(", ", fila.getValue().getCorreos())));

        tblPersonas.setOnMouseClicked(evento -> {
            if (evento.getClickCount() == 2 && tblPersonas.getSelectionModel().getSelectedItem() != null) {
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
        FiltroPersona filtro = new FiltroPersona();
        filtro.setNombre(txtNombre.getText());
        filtro.setUbicacion(ubicacionController.leerFiltro());
        List<Persona> resultados = personaManager.consultar(filtro);
        tblPersonas.setItems(FXCollections.observableArrayList(resultados));
        lblTotalRegistros.setText("Total de registros: " + resultados.size());
    }

    @FXML
    private void onLimpiar() {
        txtNombre.clear();
        ubicacionController.limpiar();
        onBuscar();
    }

    @FXML
    private void onNueva() {
        PersonaFormularioController formulario = Navegador.mostrarEnContenido("PersonaFormulario.fxml");
        formulario.prepararNueva();
    }

    @FXML
    private void onAbrir() {
        Persona seleccionada = tblPersonas.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una persona", "Seleccione una fila de la tabla para ver su detalle.");
            return;
        }
        PersonaDetalleController detalle = Navegador.mostrarEnContenido("PersonaDetalle.fxml");
        detalle.mostrar(seleccionada.getId(), ARCHIVO);
    }
}
