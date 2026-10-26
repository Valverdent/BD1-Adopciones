package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.manager.AutenticacionManager;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

/**
 * Controlador de la pantalla de inicio de sesión (Login.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class LoginController {

    @FXML
    private TextField txtUsuario;

    @FXML
    private PasswordField txtContrasena;

    @FXML
    private Label lblMensaje;

    @FXML
    private Label lblModoDesarrollo;

    private final AutenticacionManager autenticacionManager = new AutenticacionManager();

    @FXML
    private void initialize() {
        limpiarMensaje();
        boolean datosDePrueba = Repositorios.usaDatosDePrueba();
        lblModoDesarrollo.setVisible(datosDePrueba);
        lblModoDesarrollo.setManaged(datosDePrueba);
    }

    @FXML
    private void onIngresar() {
        limpiarMensaje();
        try {
            autenticacionManager.iniciarSesion(txtUsuario.getText(), txtContrasena.getText());
            Navegador.mostrarMenuPrincipal();
        } catch (IllegalArgumentException e) {
            mostrarMensaje(e.getMessage());
            txtContrasena.clear();
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    private void mostrarMensaje(String mensaje) {
        lblMensaje.setText(mensaje);
        lblMensaje.setVisible(true);
        lblMensaje.setManaged(true);
    }

    private void limpiarMensaje() {
        lblMensaje.setText("");
        lblMensaje.setVisible(false);
        lblMensaje.setManaged(false);
    }
}
