package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.UsuarioManager;
import com.mycompany.bd_proyecto1.model.CuentaUsuario;
import com.mycompany.bd_proyecto1.model.NuevoUsuario;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.PerfilInterfaz;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.util.StringConverter;

/**
 * Controlador de la pestaña de usuarios (Usuarios.fxml, incluida en Parametros.fxml). Solo
 * administradores. Las validaciones están en UsuarioManager.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class UsuariosController {

    private static final String VACIO = "";

    @FXML private TableView<CuentaUsuario> tblUsuarios;
    @FXML private TableColumn<CuentaUsuario, String> colUsuario;
    @FXML private TableColumn<CuentaUsuario, String> colNombre;
    @FXML private TableColumn<CuentaUsuario, String> colRol;
    @FXML private TableColumn<CuentaUsuario, String> colEstado;

    @FXML private ComboBox<PerfilInterfaz> cmbNuevoRol;
    @FXML private Button btnCambiarRol;
    @FXML private Button btnCambiarEstado;
    @FXML private Label lblMensajeCuenta;

    @FXML private TextField txtNombre;
    @FXML private TextField txtSegundoNombre;
    @FXML private TextField txtPrimerApellido;
    @FXML private TextField txtSegundoApellido;
    /** Bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private TextField txtTelefono;
    @FXML private TextField txtCorreo;
    @FXML private TextField txtUsuario;
    @FXML private PasswordField txtContrasena;
    @FXML private PasswordField txtConfirmacion;
    @FXML private ComboBox<PerfilInterfaz> cmbRol;
    @FXML private Label lblMensajeCrear;

    private final UsuarioManager usuarioManager = new UsuarioManager();

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        colUsuario.setCellValueFactory(f -> new SimpleStringProperty(f.getValue().getNombreUsuario()));
        colNombre.setCellValueFactory(f -> new SimpleStringProperty(f.getValue().getNombreCompleto()));
        colRol.setCellValueFactory(f -> new SimpleStringProperty(f.getValue().getPerfil().getDescripcion()));
        colEstado.setCellValueFactory(f -> new SimpleStringProperty(f.getValue().isActivo() ? "Activo" : "Inactivo"));

        configurarCombo(cmbNuevoRol);
        configurarCombo(cmbRol);
        cmbRol.setValue(PerfilInterfaz.USUARIO_COMUN);

        tblUsuarios.getSelectionModel().selectedItemProperty().addListener(
                (observable, anterior, nueva) -> mostrarSeleccion(nueva));
        cargarUsuarios();
        mostrarSeleccion(null);
    }

    private void configurarCombo(ComboBox<PerfilInterfaz> combo) {
        combo.setItems(FXCollections.observableArrayList(PerfilInterfaz.values()));
        combo.setConverter(new StringConverter<PerfilInterfaz>() {
            @Override
            public String toString(PerfilInterfaz perfil) {
                return perfil == null ? VACIO : perfil.getDescripcion();
            }

            @Override
            public PerfilInterfaz fromString(String texto) {
                return null;
            }
        });
    }

    private void cargarUsuarios() {
        try {
            tblUsuarios.setItems(FXCollections.observableArrayList(usuarioManager.listar()));
        } catch (RuntimeException e) {
            Alertas.mostrarError("Usuarios", e.getMessage());
        }
    }

    /** Habilita los botones según la cuenta elegida; la propia no se puede modificar. */
    private void mostrarSeleccion(CuentaUsuario cuenta) {
        boolean bloqueada = cuenta == null || usuarioManager.esCuentaPropia(cuenta);
        cmbNuevoRol.setDisable(bloqueada);
        btnCambiarRol.setDisable(bloqueada);
        btnCambiarEstado.setDisable(bloqueada);
        btnCambiarEstado.setText(cuenta != null && !cuenta.isActivo() ? "Activar" : "Desactivar");
        cmbNuevoRol.setValue(cuenta == null ? null : cuenta.getPerfil());
        if (cuenta == null) {
            lblMensajeCuenta.setText("Seleccione una cuenta de la tabla.");
        } else if (bloqueada) {
            lblMensajeCuenta.setText("Es su propia cuenta: no puede cambiarle el rol ni desactivarla.");
        } else {
            lblMensajeCuenta.setText(VACIO);
        }
    }

    // ------------------------------------------------------------------------
    // ----------------------- Cambios sobre un usuario -----------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onCambiarRol() {
        CuentaUsuario cuenta = tblUsuarios.getSelectionModel().getSelectedItem();
        try {
            usuarioManager.cambiarPerfil(cuenta, cmbNuevoRol.getValue());
            recargarSeleccionando(cuenta.getIdUsuario());
            lblMensajeCuenta.setText("Rol actualizado. Se aplica la próxima vez que la persona inicie sesión.");
        } catch (RuntimeException e) {
            lblMensajeCuenta.setText(e.getMessage());
        }
    }

    @FXML
    private void onCambiarEstado() {
        CuentaUsuario cuenta = tblUsuarios.getSelectionModel().getSelectedItem();
        if (cuenta == null) {
            lblMensajeCuenta.setText("Seleccione una cuenta de la tabla.");
            return;
        }
        String accion = cuenta.isActivo() ? "desactivar" : "activar";
        if (!Alertas.confirmar("Usuarios", "¿Desea " + accion + " la cuenta «" + cuenta.getNombreUsuario() + "»?")) {
            return;
        }
        try {
            usuarioManager.cambiarEstado(cuenta);
            recargarSeleccionando(cuenta.getIdUsuario());
            lblMensajeCuenta.setText(cuenta.isActivo()
                    ? "Cuenta desactivada: ya no puede iniciar sesión."
                    : "Cuenta activada: ya puede iniciar sesión.");
        } catch (RuntimeException e) {
            lblMensajeCuenta.setText(e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------- Creación de usuarios -------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onCrear() {
        NuevoUsuario nuevo = new NuevoUsuario();
        nuevo.setNombre(txtNombre.getText());
        nuevo.setSegundoNombre(txtSegundoNombre.getText());
        nuevo.setPrimerApellido(txtPrimerApellido.getText());
        nuevo.setSegundoApellido(txtSegundoApellido.getText());
        nuevo.setUbicacion(ubicacionController.leer());
        nuevo.setTelefono(txtTelefono.getText());
        nuevo.setCorreo(txtCorreo.getText());
        nuevo.setNombreUsuario(txtUsuario.getText());
        nuevo.setContrasena(txtContrasena.getText());
        nuevo.setPerfil(cmbRol.getValue());
        try {
            int idUsuario = usuarioManager.crear(nuevo, txtConfirmacion.getText());
            limpiarFormulario();
            recargarSeleccionando(idUsuario);
            lblMensajeCrear.setText("Cuenta «" + nuevo.getNombreUsuario() + "» creada. Ya puede iniciar sesión.");
        } catch (RuntimeException e) {
            lblMensajeCrear.setText(e.getMessage());
        }
    }

    @FXML
    private void onLimpiar() {
        limpiarFormulario();
        lblMensajeCrear.setText(VACIO);
    }

    private void limpiarFormulario() {
        for (TextField campo : new TextField[] {txtNombre, txtSegundoNombre, txtPrimerApellido, txtSegundoApellido,
                txtTelefono, txtCorreo, txtUsuario, txtContrasena, txtConfirmacion}) {
            campo.clear();
        }
        cmbRol.setValue(PerfilInterfaz.USUARIO_COMUN);
        ubicacionController.limpiar();
    }

    private void recargarSeleccionando(int idUsuario) {
        cargarUsuarios();
        tblUsuarios.getItems().stream()
                .filter(c -> c.getIdUsuario() == idUsuario)
                .findFirst()
                .ifPresent(c -> {
                    tblUsuarios.getSelectionModel().select(c);
                    tblUsuarios.scrollTo(c);
                });
    }
}
