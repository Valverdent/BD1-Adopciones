package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.util.Alertas;
import javafx.scene.control.Alert;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;

/**
 * Muestra en una ventana la foto de un enlace de internet, para que la persona confirme que el
 * enlace es correcto antes de guardarlo.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
final class VistaFoto {

    private VistaFoto() {
        // Clase de utilidad: no se instancia.
    }

    static void mostrar(String enlace, String titulo) {
        if (enlace == null || enlace.isBlank()) {
            Alertas.mostrarInformacion(titulo, "Escriba primero el enlace de la foto.");
            return;
        }
        Image imagen;
        try {
            // Se descarga en segundo plano, ajustada a 520 x 400 sin deformarla
            imagen = new Image(enlace.trim(), 520, 400, true, true, true);
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError(titulo, "El enlace no es válido.");
            return;
        }
        Label estado = new Label("Cargando la imagen...");
        imagen.progressProperty().addListener((observable, anterior, progreso) -> {
            if (progreso.doubleValue() >= 1 && !imagen.isError()) {
                estado.setText("Si ve la foto, el enlace es correcto.");
            }
        });
        imagen.errorProperty().addListener((observable, anterior, hayError) -> {
            if (hayError) {
                estado.setText("No se pudo cargar la imagen. Revise que el enlace lleve directo a la foto "
                        + "(normalmente termina en .jpg o .png) y que haya conexión a internet.");
            }
        });

        Alert ventana = new Alert(Alert.AlertType.INFORMATION);
        ventana.setTitle(titulo);
        ventana.setHeaderText(null);
        estado.setWrapText(true);
        estado.setMaxWidth(520);
        ventana.getDialogPane().setContent(new VBox(10, estado, new ImageView(imagen)));
        ventana.showAndWait();
    }
}
