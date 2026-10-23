package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.MascotaManager;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.time.LocalDate;
import java.util.ArrayList;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;

/**
 * Controlador del formulario de mascotas (MascotaFormulario.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaFormularioController {

    @FXML private Label lblTitulo;
    @FXML private Label lblRegistradoPor;
    @FXML private Label lblAvisoSoloLectura;
    @FXML private VBox contenedorCampos;
    @FXML private Button btnGuardar;

    @FXML private ComboBox<ItemCatalogo> cmbTipo;
    @FXML private ComboBox<ItemCatalogo> cmbRaza;
    @FXML private ComboBox<ItemCatalogo> cmbEstado;
    @FXML private TextField txtNombre;
    @FXML private TextField txtChip;
    @FXML private TextField txtEdad;
    @FXML private ComboBox<ItemCatalogo> cmbColor;
    @FXML private ComboBox<ItemCatalogo> cmbTamano;

    @FXML private DatePicker dpFecha;
    /** Bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private TextField txtMonto;
    @FXML private ComboBox<ItemCatalogo> cmbMoneda;

    @FXML private Label lblContacto;

    @FXML private ComboBox<ItemCatalogo> cmbSeveridad;
    @FXML private ComboBox<ItemCatalogo> cmbEnergia;
    @FXML private ComboBox<ItemCatalogo> cmbEntrenamiento;
    @FXML private CheckBox chkRequiereEspacio;

    @FXML private ComboBox<ItemCatalogo> cmbEnfermedad;
    @FXML private ListView<ItemCatalogo> lstEnfermedades;
    @FXML private TextArea txtTratamientos;
    @FXML private ComboBox<ItemCatalogo> cmbVeterinario;

    @FXML private TextArea txtDescripcionAbandono;
    @FXML private TextArea txtNotas;
    @FXML private TextField txtFotoAntes;
    @FXML private TextField txtFotoDespues;

    private final MascotaManager mascotaManager = new MascotaManager();

    /** Mascota que se está editando; null si es un registro nuevo. */
    private Mascota mascotaActual;

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cmbTipo.setItems(catalogo(TipoCatalogo.TIPO_MASCOTA));
        cmbEstado.setItems(catalogo(TipoCatalogo.ESTADO_MASCOTA));
        cmbColor.setItems(catalogo(TipoCatalogo.COLOR));
        cmbTamano.setItems(catalogo(TipoCatalogo.TAMANO));
        cmbMoneda.setItems(catalogo(TipoCatalogo.MONEDA));
        cmbSeveridad.setItems(catalogo(TipoCatalogo.SEVERIDAD));
        cmbEnergia.setItems(catalogo(TipoCatalogo.NIVEL_ENERGIA));
        cmbEntrenamiento.setItems(catalogo(TipoCatalogo.FACILIDAD_ENTRENAMIENTO));
        cmbEnfermedad.setItems(catalogo(TipoCatalogo.ENFERMEDAD));
        cmbVeterinario.setItems(catalogo(TipoCatalogo.VETERINARIO));
        actualizarTratamientos();

        // La lista de razas depende del tipo elegido.
        cmbRaza.setDisable(true);
        cmbTipo.valueProperty().addListener((observable, anterior, nuevo) -> {
            cmbRaza.setItems(FXCollections.observableArrayList(mascotaManager.listarRazas(nuevo)));
            cmbRaza.setValue(null);
            cmbRaza.setDisable(nuevo == null);
        });
    }

    private ObservableList<ItemCatalogo> catalogo(TipoCatalogo tipo) {
        return FXCollections.observableArrayList(mascotaManager.listarCatalogo(tipo));
    }

    // ------------------------------------------------------------------------
    // ------------------------- Carga de la mascota --------------------------
    // ------------------------------------------------------------------------

    /** Prepara el formulario para registrar una mascota nueva. */
    public void prepararNueva() {
        mascotaActual = null;
        lblTitulo.setText("Registrar mascota");
        ocultar(lblRegistradoPor);
        dpFecha.setValue(LocalDate.now());
        lblContacto.setText("Se usarán el teléfono y el correo de su perfil.");
        permitirEdicion(true);
    }

    /** Carga una mascota existente; si no le pertenece al usuario, en solo lectura. */
    public void mostrarMascota(Mascota mascota) {
        mascotaActual = mascota;

        cmbTipo.setValue(mascota.getTipo());
        cmbRaza.setValue(mascota.getRaza());   // después del tipo, que carga las razas
        cmbEstado.setValue(mascota.getEstado());
        txtNombre.setText(mascota.getNombre());
        txtChip.setText(mascota.getChip());
        txtEdad.setText(mascota.getEdadEstimada() == null ? "" : String.valueOf(mascota.getEdadEstimada()));
        cmbColor.setValue(mascota.getColor());
        cmbTamano.setValue(mascota.getTamano());

        dpFecha.setValue(mascota.getFechaEvento());
        ubicacionController.mostrar(mascota.getUbicacion());
        txtMonto.setText(mascota.getMontoRecompensa() == null ? "" : mascota.getMontoRecompensa().toPlainString());
        cmbMoneda.setValue(mascota.getMonedaRecompensa());

        lblContacto.setText("Teléfono: " + valor(mascota.getTelefonoContacto())
                + "    Correo: " + valor(mascota.getCorreoContacto()));

        cmbSeveridad.setValue(mascota.getSeveridad());
        cmbEnergia.setValue(mascota.getNivelEnergia());
        cmbEntrenamiento.setValue(mascota.getFacilidadEntrenamiento());
        chkRequiereEspacio.setSelected(mascota.isRequiereEspacio());

        lstEnfermedades.setItems(FXCollections.observableArrayList(mascota.getEnfermedades()));
        cmbVeterinario.setValue(mascota.getVeterinario());
        actualizarTratamientos();

        txtDescripcionAbandono.setText(mascota.getDescripcionAbandono());
        txtNotas.setText(mascota.getNotas());
        txtFotoAntes.setText(mascota.getFotoAntes());
        txtFotoDespues.setText(mascota.getFotoDespues());

        lblRegistradoPor.setText("Registrada por: " + mascota.getNombrePersonaRegistro());
        boolean editable = mascotaManager.puedeEditar(mascota);
        lblTitulo.setText(editable ? "Editar mascota" : "Detalle de mascota");
        permitirEdicion(editable);
    }

    private void permitirEdicion(boolean editable) {
        contenedorCampos.setDisable(!editable);
        btnGuardar.setVisible(editable);
        btnGuardar.setManaged(editable);
        lblAvisoSoloLectura.setVisible(!editable);
        lblAvisoSoloLectura.setManaged(!editable);
    }

    private void ocultar(Label etiqueta) {
        etiqueta.setVisible(false);
        etiqueta.setManaged(false);
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Guardado -------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onGuardar() {
        try {
            Mascota mascota = leerFormulario();
            mascotaManager.guardar(mascota);
            Alertas.mostrarInformacion("Mascota guardada", "Los datos de la mascota se guardaron correctamente.");
            volverAConsulta();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    /** Crea una mascota con los valores de la pantalla. */
    private Mascota leerFormulario() {
        Mascota m = new Mascota();
        if (mascotaActual != null) {
            m.setId(mascotaActual.getId());
            m.setIdPersonaRegistro(mascotaActual.getIdPersonaRegistro());
            m.setNombrePersonaRegistro(mascotaActual.getNombrePersonaRegistro());
        }

        m.setTipo(cmbTipo.getValue());
        m.setRaza(cmbRaza.getValue());
        m.setEstado(cmbEstado.getValue());
        m.setNombre(txtNombre.getText());
        m.setChip(txtChip.getText());
        m.setEdadEstimada(mascotaManager.convertirEdad(txtEdad.getText()));
        m.setColor(cmbColor.getValue());
        m.setTamano(cmbTamano.getValue());

        m.setFechaEvento(dpFecha.getValue());
        m.setUbicacion(ubicacionController.leer());
        m.setMontoRecompensa(mascotaManager.convertirMonto(txtMonto.getText()));
        m.setMonedaRecompensa(cmbMoneda.getValue());


        m.setSeveridad(cmbSeveridad.getValue());
        m.setNivelEnergia(cmbEnergia.getValue());
        m.setFacilidadEntrenamiento(cmbEntrenamiento.getValue());
        m.setRequiereEspacio(chkRequiereEspacio.isSelected());

        m.setEnfermedades(new ArrayList<>(lstEnfermedades.getItems()));
        m.setVeterinario(cmbVeterinario.getValue());

        m.setDescripcionAbandono(txtDescripcionAbandono.getText());
        m.setNotas(txtNotas.getText());
        m.setFotoAntes(txtFotoAntes.getText());
        m.setFotoDespues(txtFotoDespues.getText());
        return m;
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Enfermedades -----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onAgregarEnfermedad() {
        ItemCatalogo enfermedad = cmbEnfermedad.getValue();
        if (enfermedad == null) {
            Alertas.mostrarInformacion("Seleccione una enfermedad", "Elija una enfermedad de la lista para agregarla.");
            return;
        }
        if (lstEnfermedades.getItems().contains(enfermedad)) {
            Alertas.mostrarInformacion("Enfermedad repetida", "Esa enfermedad ya está en la lista.");
            return;
        }
        lstEnfermedades.getItems().add(enfermedad);
        cmbEnfermedad.setValue(null);
        actualizarTratamientos();
    }

    @FXML
    private void onQuitarEnfermedad() {
        ItemCatalogo seleccionada = lstEnfermedades.getSelectionModel().getSelectedItem();
        if (seleccionada == null) {
            Alertas.mostrarInformacion("Seleccione una enfermedad", "Seleccione en la lista la enfermedad que desea quitar.");
            return;
        }
        lstEnfermedades.getItems().remove(seleccionada);
        actualizarTratamientos();
    }

    /** Muestra los tratamientos y medicamentos que corresponden a las enfermedades de la lista. */
    private void actualizarTratamientos() {
        txtTratamientos.setText(mascotaManager.resumenTratamientos(lstEnfermedades.getItems()));
    }

    // ------------------------------------------------------------------------
    // -------------------------- Navegación y fotos --------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onVolver() {
        volverAConsulta();
    }

    /** Abre las casas cuna disponibles que aceptan el tipo y el tamaño indicados en este formulario. */
    @FXML
    private void onBuscarCasaCuna() {
        if (!Alertas.confirmar("Buscar casa cuna",
                "Se abrirá la consulta de casas cuna y se perderán los cambios sin guardar de esta mascota. ¿Desea continuar?")) {
            return;
        }
        CasaCunaConsultaController consulta = Navegador.mostrarEnContenido("CasaCunaConsulta.fxml");
        consulta.prefiltrar(cmbTipo.getValue(), cmbTamano.getValue());
    }

    private void volverAConsulta() {
        Navegador.mostrarEnContenido("MascotaConsulta.fxml");
    }

    @FXML
    private void onVerFotoAntes() {
        VistaFoto.mostrar(txtFotoAntes.getText(), "Foto del antes");
    }

    @FXML
    private void onVerFotoDespues() {
        VistaFoto.mostrar(txtFotoDespues.getText(), "Foto del después");
    }

    private static String valor(String texto) {
        return texto == null || texto.isBlank() ? "—" : texto;
    }
}
