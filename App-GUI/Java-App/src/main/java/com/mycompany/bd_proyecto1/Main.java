package com.mycompany.bd_proyecto1;

import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.dao.oracle.ConexionBD;
import com.mycompany.bd_proyecto1.util.AccesoDatosException;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.Navegador;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.stage.Stage;

/**
 * Punto de entrada JavaFX: prepara la ventana principal y muestra la pantalla de inicio de sesión.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public class Main extends Application {

    @Override
    public void start(Stage ventanaPrincipal) {
        // Si una pantalla no atrapa un error (por ejemplo, se perdió la conexión
        // con la base), se muestra un mensaje en vez de que no pase nada.
        Thread.currentThread().setUncaughtExceptionHandler((hilo, error) -> mostrarErrorNoAtrapado(error));

        Navegador.inicializar(ventanaPrincipal);
        Navegador.mostrarLogin();

        ventanaPrincipal.setMinWidth(800);
        ventanaPrincipal.setMinHeight(550);
        ventanaPrincipal.show();
    }

    @Override
    public void stop() {
        if (!Repositorios.usaDatosDePrueba()) {
            ConexionBD.cerrar();
        }
    }

    private static void mostrarErrorNoAtrapado(Throwable error) {
        error.printStackTrace();
        Throwable causa = error;
        // Busca el error original (los de las pantallas vienen envueltos al cargar el FXML)
        while (causa.getCause() != null && !(causa instanceof AccesoDatosException)
                && !(causa instanceof IllegalArgumentException)) {
            causa = causa.getCause();
        }
        String mensaje = causa.getMessage() != null ? causa.getMessage() : causa.toString();
        String titulo = causa instanceof AccesoDatosException ? "Error de base de datos" : "Error";
        Platform.runLater(() -> Alertas.mostrarError(titulo, mensaje));
    }

    public static void main(String[] args) {
        launch(args);
    }
}
