package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.AutenticacionManager;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import com.mycompany.bd_proyecto1.util.OpcionMenu;
import com.mycompany.bd_proyecto1.util.Sesion;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;

/**
 * Controlador del menú principal (MenuPrincipal.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class MenuPrincipalController {

    private static final String CLASE_SELECCIONADA = "seleccionado";

    @FXML
    private Label lblNombreUsuario;

    @FXML
    private Label lblPerfil;

    @FXML
    private VBox menuOpciones;

    @FXML
    private StackPane areaContenido;

    @FXML
    private VBox panelMensaje;

    @FXML
    private Label lblTituloContenido;

    @FXML
    private Label lblDescripcionContenido;

    private final AutenticacionManager autenticacionManager = new AutenticacionManager();
    private Button botonSeleccionado;

    @FXML
    private void initialize() {
        Usuario usuario = Sesion.getUsuario();
        lblNombreUsuario.setText(usuario.getNombreCompleto());
        lblPerfil.setText(usuario.getPerfil().getDescripcion());
        Navegador.setAreaContenido(areaContenido);

        crearOpcionesDelMenu();
        mostrarMensaje("Bienvenido, " + usuario.getNombreCompleto(),
                "Seleccione una opción del menú para comenzar.");
    }

    private void crearOpcionesDelMenu() {
        for (OpcionMenu opcion : OpcionMenu.values()) {
            if (opcion.estaPermitidaPara(Sesion.getPerfil())) {
                Button boton = new Button(opcion.getTexto());
                boton.getStyleClass().add("boton-menu");
                boton.setMaxWidth(Double.MAX_VALUE);
                boton.setOnAction(evento -> abrirOpcion(opcion, boton));
                menuOpciones.getChildren().add(boton);
            }
        }
    }

    private void abrirOpcion(OpcionMenu opcion, Button boton) {
        marcarSeleccionado(boton);
        try {
            switch (opcion) {
                case MASCOTAS -> Navegador.mostrarEnContenido("MascotaConsulta.fxml");
                case ADOPCIONES -> Navegador.mostrarEnContenido("AdopcionConsulta.fxml");
                case DONACIONES -> Navegador.mostrarEnContenido("Donaciones.fxml");
                case ASOCIACIONES -> Navegador.mostrarEnContenido("Asociaciones.fxml");
                case PERSONAS -> Navegador.mostrarEnContenido("PersonaConsulta.fxml");
                case LISTA_NEGRA -> Navegador.mostrarEnContenido("ListaNegra.fxml");
                case CASAS_CUNA -> Navegador.mostrarEnContenido("CasaCunaConsulta.fxml");
                case MATCHES -> Navegador.mostrarEnContenido("Matches.fxml");
                case ESTADISTICAS -> Navegador.mostrarEnContenido("Estadisticas.fxml");
                case CONSULTAS -> Navegador.mostrarEnContenido("ConsultasAdicionales.fxml");
                case BITACORA -> Navegador.mostrarEnContenido("Bitacora.fxml");
                case PARAMETROS -> Navegador.mostrarEnContenido("Parametros.fxml");
                default -> mostrarMensaje(opcion.getTexto(),
                        "Este módulo está en construcción y se implementará en una próxima etapa.");
            }
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        } catch (RuntimeException e) {
            // Sin esto, un error al cargar una pantalla no muestra nada.
            e.printStackTrace();
            Alertas.mostrarError("No se pudo abrir " + opcion.getTexto(), describirError(e));
        }
    }

    /** Arma un texto con el error y su causa original, para poder diagnosticarlo. */
    private String describirError(Throwable error) {
        Throwable causa = error;
        while (causa.getCause() != null && causa.getCause() != causa) {
            causa = causa.getCause();
        }
        String texto = error.getMessage() == null ? error.getClass().getSimpleName() : error.getMessage();
        if (causa != error) {
            texto += "\n\nCausa: " + causa.getClass().getSimpleName()
                    + (causa.getMessage() == null ? "" : " - " + causa.getMessage());
        }
        return texto;
    }

    /** Muestra un título y un texto en el área central. */
    private void mostrarMensaje(String titulo, String descripcion) {
        lblTituloContenido.setText(titulo);
        lblDescripcionContenido.setText(descripcion);
        areaContenido.getChildren().setAll(panelMensaje);
    }

    private void marcarSeleccionado(Button boton) {
        if (botonSeleccionado != null) {
            botonSeleccionado.getStyleClass().remove(CLASE_SELECCIONADA);
        }
        boton.getStyleClass().add(CLASE_SELECCIONADA);
        botonSeleccionado = boton;
    }

    @FXML
    private void onCerrarSesion() {
        autenticacionManager.cerrarSesion();
        Navegador.mostrarLogin();
    }
}
