package com.mycompany.bd_proyecto1.util;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URL;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

/**
 * Cambia la pantalla mostrada en la ventana principal.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public final class Navegador {

    private static final String RUTA_VISTAS = "/com/mycompany/bd_proyecto1/view/";
    private static final String HOJA_ESTILOS = "/com/mycompany/bd_proyecto1/css/estilos.css";
    private static final String TITULO_APP = "Bienestar Animal";

    private static Stage ventana;
    private static StackPane areaContenido;

    private Navegador() {
        // Clase de utilidad: no se instancia.
    }

    /** Debe llamarse una vez al iniciar la aplicación. */
    public static void inicializar(Stage ventanaPrincipal) {
        ventana = ventanaPrincipal;
    }

    public static void mostrarLogin() {
        areaContenido = null;
        mostrar("Login.fxml", TITULO_APP + " - Iniciar sesión");
    }

    public static void mostrarMenuPrincipal() {
        mostrar("MenuPrincipal.fxml", TITULO_APP);
    }

    /** El menú principal registra aquí su área central. */
    public static void setAreaContenido(StackPane area) {
        areaContenido = area;
    }

    /** Muestra una vista de módulo en el área central del menú principal. */
    public static <T> T mostrarEnContenido(String archivoFxml) {
        FXMLLoader cargador = new FXMLLoader(obtenerRecurso(RUTA_VISTAS + archivoFxml));
        try {
            Parent vista = cargador.load();
            areaContenido.getChildren().setAll(vista);
            return cargador.getController();
        } catch (IOException e) {
            // Si la vista falló porque falta una integración con Oracle o por un
            // error de la base, se relanza ese aviso para que se pueda mostrar.
            for (Throwable causa = e.getCause(); causa != null; causa = causa.getCause()) {
                if (causa instanceof IntegracionPendienteException pendiente) {
                    throw pendiente;
                }
                if (causa instanceof AccesoDatosException accesoDatos) {
                    throw accesoDatos;          // Sin conexión o error al cargar los datos de la pantalla
                }
            }
            throw new UncheckedIOException("No se pudo cargar la vista " + archivoFxml, e);
        }
    }

    private static void mostrar(String archivoFxml, String titulo) {
        Parent raiz = cargarVista(archivoFxml);
        Scene escena = ventana.getScene();
        if (escena == null) {
            escena = new Scene(raiz, 1100, 700);
            escena.getStylesheets().add(obtenerRecurso(HOJA_ESTILOS).toExternalForm());
            ventana.setScene(escena);
        } else {
            escena.setRoot(raiz);
        }
        ventana.setTitle(titulo);
    }

    private static Parent cargarVista(String archivoFxml) {
        try {
            return FXMLLoader.load(obtenerRecurso(RUTA_VISTAS + archivoFxml));
        } catch (IOException e) {
            throw new UncheckedIOException("No se pudo cargar la vista " + archivoFxml, e);
        }
    }

    /** Busca un recurso y falla con un mensaje claro si no existe. */
    private static URL obtenerRecurso(String ruta) {
        URL recurso = Navegador.class.getResource(ruta);
        if (recurso == null) {
            throw new IllegalStateException("No se encontró el recurso: " + ruta);
        }
        return recurso;
    }
}
