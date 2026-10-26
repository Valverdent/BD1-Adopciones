package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.util.Alertas;
import javafx.scene.control.Alert;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;

/**
 * Muestra en una ventana la foto de un enlace de internet, para que la persona confirme que el
 * enlace es correcto antes de guardarlo.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
final class VistaFoto {

    /** Tamaño máximo con que se muestra la foto (se ajusta sin deformarla). */
    private static final double ANCHO = 520;
    private static final double ALTO = 400;

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
            imagen = new Image(enlace.trim(), ANCHO, ALTO, true, true, true);
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

        // La ventana se abre antes de que termine la descarga: se reserva el espacio de la
        // foto desde el inicio para que no quede del tamaño de una imagen vacía y la recorte.
        ImageView vista = new ImageView(imagen);
        vista.setFitWidth(ANCHO);
        vista.setFitHeight(ALTO);
        vista.setPreserveRatio(true);
        StackPane marco = new StackPane(vista);
        marco.setMinSize(ANCHO, ALTO);
        marco.setPrefSize(ANCHO, ALTO);

        Alert ventana = new Alert(Alert.AlertType.INFORMATION);
        ventana.setTitle(titulo);
        ventana.setHeaderText(null);
        ventana.setGraphic(null);
        ventana.setResizable(true);
        estado.setWrapText(true);
        estado.setMaxWidth(ANCHO);
        ventana.getDialogPane().setContent(new VBox(10, estado, marco));
        ventana.showAndWait();
    }
}
