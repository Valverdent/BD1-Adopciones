package com.mycompany.bd_proyecto1.util;

import javafx.scene.control.Alert;
import javafx.scene.control.ButtonType;

/**
 * Centraliza los mensajes emergentes que se muestran al usuario.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public final class Alertas {

    private Alertas() {
        // Clase de utilidad: no se instancia.
    }

    public static void mostrarInformacion(String titulo, String mensaje) {
        mostrar(Alert.AlertType.INFORMATION, titulo, mensaje);
    }

    public static void mostrarError(String titulo, String mensaje) {
        mostrar(Alert.AlertType.ERROR, titulo, mensaje);
    }

    /** Pregunta Aceptar/Cancelar; devuelve true si la persona acepta. */
    public static boolean confirmar(String titulo, String mensaje) {
        Alert alerta = new Alert(Alert.AlertType.CONFIRMATION);
        alerta.setTitle(titulo);
        alerta.setHeaderText(null);
        alerta.setContentText(mensaje);
        return alerta.showAndWait().filter(boton -> boton == ButtonType.OK).isPresent();
    }

    private static void mostrar(Alert.AlertType tipo, String titulo, String mensaje) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setHeaderText(null);
        alerta.setContentText(mensaje);
        alerta.showAndWait();
    }
}
