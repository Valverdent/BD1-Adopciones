package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.AdopcionManager;
import com.mycompany.bd_proyecto1.manager.ListaNegraManager;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.util.StringConverter;

/**
 * Controlador del formulario de adopciones (AdopcionFormulario.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionFormularioController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    /** En el ComboBox de calificación, 0 significa "sin calificar". */
    private static final int SIN_CALIFICAR = 0;

    @FXML private Label lblTitulo;
    @FXML private Label lblEntregadaPor;
    @FXML private Label lblAvisoSoloLectura;
    @FXML private VBox contenedorCampos;
    @FXML private Button btnGuardar;

    @FXML private ComboBox<Mascota> cmbMascota;
    @FXML private ComboBox<ItemCatalogo> cmbAdoptante;
    @FXML private DatePicker dpFecha;
    @FXML private Label lblAyudaMascota;

    @FXML private VBox panelFormulario;
    @FXML private ComboBox<ItemCatalogo> cmbVivienda;
    @FXML private ComboBox<ItemCatalogo> cmbEjercicio;
    @FXML private CheckBox chkPatio;
    @FXML private ComboBox<ItemCatalogo> cmbTipoOtra;
    @FXML private ComboBox<ItemCatalogo> cmbRazaOtra;
    @FXML private ListView<ItemCatalogo> lstOtrasMascotas;

    @FXML private ComboBox<Integer> cmbCalificacion;
    @FXML private TextArea txtNotasCalificacion;
    @FXML private TextField txtFotoAdoptante;

    @FXML private VBox panelSeguimientos;
    @FXML private TableView<SeguimientoAdopcion> tblSeguimientos;
    @FXML private TableColumn<SeguimientoAdopcion, String> colFechaSeguimiento;
    @FXML private TableColumn<SeguimientoAdopcion, String> colComentario;
    @FXML private TableColumn<SeguimientoAdopcion, String> colFotoSeguimiento;
    @FXML private Label lblTotalSeguimientos;
    @FXML private VBox panelNuevoSeguimiento;
    @FXML private DatePicker dpFechaSeguimiento;
    @FXML private TextField txtComentarioSeguimiento;
    @FXML private TextField txtFotoSeguimiento;

    private final AdopcionManager adopcionManager = new AdopcionManager();

    /** Adopción que se está editando; null si es un registro nuevo. */
    private Adopcion adopcionActual;

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cmbAdoptante.setItems(FXCollections.observableArrayList(adopcionManager.listarPersonas()));
        cmbVivienda.setItems(FXCollections.observableArrayList(adopcionManager.listarCatalogo(TipoCatalogo.TIPO_VIVIENDA)));
        cmbEjercicio.setItems(FXCollections.observableArrayList(adopcionManager.listarCatalogo(TipoCatalogo.TIEMPO_EJERCICIO)));
        cmbTipoOtra.setItems(FXCollections.observableArrayList(adopcionManager.listarCatalogo(TipoCatalogo.TIPO_MASCOTA)));
        cmbMascota.setConverter(new ConvertidorMascota());

        // La raza de la otra mascota depende del tipo elegido.
        cmbRazaOtra.setDisable(true);
        cmbTipoOtra.valueProperty().addListener((observable, anterior, nuevo) -> {
            cmbRazaOtra.setItems(FXCollections.observableArrayList(adopcionManager.listarRazas(nuevo)));
            cmbRazaOtra.setValue(null);
            cmbRazaOtra.setDisable(nuevo == null);
        });

        // Calificación: 0 = sin calificar, 1 a 5 = estrellas.
        List<Integer> opciones = new ArrayList<>();
        for (int i = SIN_CALIFICAR; i <= AdopcionManager.CALIFICACION_MAXIMA; i++) {
            opciones.add(i);
        }
        cmbCalificacion.setItems(FXCollections.observableArrayList(opciones));
        cmbCalificacion.setConverter(new StringConverter<>() {
            @Override
            public String toString(Integer valor) {
                return valor == null || valor == SIN_CALIFICAR ? "Sin calificar" : AdopcionManager.textoCalificacion(valor);
            }

            @Override
            public Integer fromString(String texto) {
                return null;
            }
        });

        colFechaSeguimiento.setCellValueFactory(fila -> texto(fila.getValue().getFecha().format(FORMATO_FECHA)));
        colComentario.setCellValueFactory(fila -> texto(fila.getValue().getComentarios()));
        colFotoSeguimiento.setCellValueFactory(fila -> texto(fila.getValue().getFoto()));
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    // ------------------------------------------------------------------------
    // ------------------------- Carga de la adopción -------------------------
    // ------------------------------------------------------------------------

    /** Prepara el formulario para registrar una adopción nueva. */
    public void prepararNueva() {
        adopcionActual = null;
        lblTitulo.setText("Registrar adopción");
        mostrar(lblEntregadaPor, false);

        List<Mascota> disponibles = adopcionManager.listarMascotasDisponibles();
        cmbMascota.setItems(FXCollections.observableArrayList(disponibles));
        lblAyudaMascota.setText(disponibles.isEmpty()
                ? "No tiene mascotas disponibles. Solo se pueden adoptar mascotas en estado \"En adopción\" que usted registró."
                : "Solo aparecen mascotas en estado \"En adopción\". Al guardar, la mascota pasa a \"Adoptada\".");

        dpFecha.setValue(LocalDate.now());
        cmbCalificacion.setValue(SIN_CALIFICAR);
        permitirEdicion(true);
        dpFecha.setDisable(false);
        panelFormulario.setDisable(false);
        cmbCalificacion.setDisable(false);
        txtNotasCalificacion.setDisable(false);
        mostrar(panelSeguimientos, false);
    }

    /** Carga una adopción existente; si el usuario no puede gestionarla, en solo lectura. */
    public void mostrarAdopcion(Adopcion adopcion) {
        adopcionActual = adopcion;

        cmbMascota.setItems(FXCollections.observableArrayList(adopcion.getMascota()));
        cmbMascota.setValue(adopcion.getMascota());
        cmbAdoptante.setValue(adopcion.getAdoptante());
        dpFecha.setValue(adopcion.getFechaAdopcion());
        // La mascota y el adoptante no se cambian después de registrar la adopción.
        cmbMascota.setDisable(true);
        cmbAdoptante.setDisable(true);
        mostrar(lblAyudaMascota, false);

        cmbVivienda.setValue(adopcion.getTipoVivienda());
        cmbEjercicio.setValue(adopcion.getTiempoEjercicio());
        chkPatio.setSelected(adopcion.isTienePatio());
        lstOtrasMascotas.setItems(FXCollections.observableArrayList(adopcion.getOtrasMascotas()));

        cmbCalificacion.setValue(adopcion.getCalificacion() == null ? SIN_CALIFICAR : adopcion.getCalificacion());
        txtNotasCalificacion.setText(adopcion.getNotasCalificacion());
        txtFotoAdoptante.setText(adopcion.getFotoAdoptante());

        lblEntregadaPor.setText("Entregada por: " + adopcion.getNombrePersonaEntrega());
        mostrar(lblEntregadaPor, true);

        boolean editable = adopcionManager.puedeGestionar(adopcion);
        lblTitulo.setText(editable ? "Editar adopción" : "Detalle de adopción");
        permitirEdicion(editable);
        // Después de registrarla, la base no permite cambiar la fecha ni las respuestas del
        // formulario; la calificación se registra una sola vez.
        dpFecha.setDisable(true);
        panelFormulario.setDisable(true);
        boolean yaCalificada = adopcion.getCalificacion() != null;
        cmbCalificacion.setDisable(yaCalificada);
        txtNotasCalificacion.setDisable(yaCalificada);

        mostrar(panelSeguimientos, true);
        mostrar(panelNuevoSeguimiento, editable);
        dpFechaSeguimiento.setValue(LocalDate.now());
        cargarSeguimientos();
    }

    private void permitirEdicion(boolean editable) {
        contenedorCampos.setDisable(!editable);
        mostrar(btnGuardar, editable);
        mostrar(lblAvisoSoloLectura, !editable);
    }

    private void mostrar(Node nodo, boolean visible) {
        nodo.setVisible(visible);
        nodo.setManaged(visible);
    }

    private void cargarSeguimientos() {
        List<SeguimientoAdopcion> seguimientos = adopcionManager.listarSeguimientos(adopcionActual);
        tblSeguimientos.setItems(FXCollections.observableArrayList(seguimientos));
        lblTotalSeguimientos.setText("Total de seguimientos: " + seguimientos.size());
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Guardado -------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onGuardar() {
        try {
            Adopcion adopcion = leerFormulario();
            boolean esNueva = adopcion.getId() == 0;
            if (esNueva && adoptanteEnListaNegra(adopcion)
                    && !Alertas.confirmar("Adoptante en lista negra",
                    "El adoptante seleccionado está en la lista negra. ¿Desea registrar la adopción de todas formas?")) {
                return;
            }
            adopcionManager.guardar(adopcion);
            if (esNueva) {
                Alertas.mostrarInformacion("Adopción registrada",
                        "La adopción se registró y la mascota quedó como \"Adoptada\". Ahora puede registrar seguimientos.");
                mostrarAdopcion(adopcion);
            } else {
                Alertas.mostrarInformacion("Adopción guardada", "Los datos de la adopción se guardaron correctamente.");
                volverAConsulta();
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    /** Si la lista negra aún no está integrada con Oracle, no se bloquea el registro. */
    private boolean adoptanteEnListaNegra(Adopcion adopcion) {
        if (adopcion.getAdoptante() == null) {
            return false;
        }
        try {
            return new ListaNegraManager().estaEnListaNegra(adopcion.getAdoptante().getId());
        } catch (IntegracionPendienteException e) {
            return false;
        }
    }

    /** Crea una adopción con los valores de la pantalla. */
    private Adopcion leerFormulario() {
        Adopcion a = new Adopcion();
        if (adopcionActual != null) {
            a.setId(adopcionActual.getId());
            a.setIdPersonaEntrega(adopcionActual.getIdPersonaEntrega());
            a.setNombrePersonaEntrega(adopcionActual.getNombrePersonaEntrega());
            a.setMascota(adopcionActual.getMascota());
            a.setAdoptante(adopcionActual.getAdoptante());
        } else {
            a.setMascota(cmbMascota.getValue());
            a.setAdoptante(cmbAdoptante.getValue());
        }
        a.setFechaAdopcion(dpFecha.getValue());
        a.setTipoVivienda(cmbVivienda.getValue());
        a.setTiempoEjercicio(cmbEjercicio.getValue());
        a.setTienePatio(chkPatio.isSelected());
        a.setOtrasMascotas(new ArrayList<>(lstOtrasMascotas.getItems()));

        Integer calificacion = cmbCalificacion.getValue();
        a.setCalificacion(calificacion == null || calificacion == SIN_CALIFICAR ? null : calificacion);
        a.setNotasCalificacion(txtNotasCalificacion.getText());
        a.setFotoAdoptante(txtFotoAdoptante.getText());
        return a;
    }

    // ------------------------------------------------------------------------
    // ---------------------------- Otras mascotas ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onAgregarOtraMascota() {
        ItemCatalogo raza = cmbRazaOtra.getValue();
        if (raza == null) {
            Alertas.mostrarInformacion("Seleccione la raza", "Elija el tipo y la raza de la otra mascota para agregarla.");
            return;
        }
        lstOtrasMascotas.getItems().add(raza);
        cmbRazaOtra.setValue(null);
    }

    @FXML
    private void onQuitarOtraMascota() {
        int indice = lstOtrasMascotas.getSelectionModel().getSelectedIndex();
        if (indice < 0) {
            Alertas.mostrarInformacion("Seleccione una mascota", "Seleccione en la lista la mascota que desea quitar.");
            return;
        }
        lstOtrasMascotas.getItems().remove(indice);
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Seguimientos -----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onAgregarSeguimiento() {
        SeguimientoAdopcion seguimiento = new SeguimientoAdopcion();
        seguimiento.setFecha(dpFechaSeguimiento.getValue());
        seguimiento.setComentarios(txtComentarioSeguimiento.getText());
        seguimiento.setFoto(txtFotoSeguimiento.getText());
        try {
            adopcionManager.registrarSeguimiento(adopcionActual, seguimiento);
            txtComentarioSeguimiento.clear();
            txtFotoSeguimiento.clear();
            dpFechaSeguimiento.setValue(LocalDate.now());
            cargarSeguimientos();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise el seguimiento", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // -------------------------- Navegación y fotos --------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onVolver() {
        volverAConsulta();
    }

    private void volverAConsulta() {
        Navegador.mostrarEnContenido("AdopcionConsulta.fxml");
    }

    @FXML
    private void onVerFotoAdoptante() {
        VistaFoto.mostrar(txtFotoAdoptante.getText(), "Foto del adoptante con la mascota");
    }

    @FXML
    private void onVerFotoSeguimiento() {
        VistaFoto.mostrar(txtFotoSeguimiento.getText(), "Foto de la nueva vida");
    }

    /** Muestra cada mascota del ComboBox como "Nombre · Tipo · Raza". */
    private static class ConvertidorMascota extends StringConverter<Mascota> {
        @Override
        public String toString(Mascota m) {
            if (m == null) {
                return "";
            }
            String nombre = m.getNombre() == null || m.getNombre().isBlank() ? "(sin nombre)" : m.getNombre();
            return nombre + " · " + m.getTipo().getNombre() + " · " + m.getRaza().getNombre();
        }

        @Override
        public Mascota fromString(String texto) {
            return null;
        }
    }
}
