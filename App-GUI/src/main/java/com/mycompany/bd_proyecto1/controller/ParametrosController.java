package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.CatalogoManager;
import com.mycompany.bd_proyecto1.manager.ParametroManager;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Parametro;
import com.mycompany.bd_proyecto1.util.Alertas;
import java.util.List;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.util.StringConverter;

/**
 * Controlador de catálogos y parámetros (Parametros.fxml). Solo administradores.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class ParametrosController {

    private static final String VACIO = "";

    // Pestaña de parámetros
    @FXML private TableView<Parametro> tblParametros;
    @FXML private TableColumn<Parametro, String> colParamDescripcion;
    @FXML private TableColumn<Parametro, String> colParamClave;
    @FXML private TableColumn<Parametro, String> colParamValor;
    @FXML private TextField txtValorParametro;
    @FXML private Label lblMensajeParametro;

    // Pestaña de catálogos
    @FXML private ComboBox<TipoCatalogo> cmbCatalogo;
    @FXML private Label lblPadre;
    @FXML private ComboBox<ItemCatalogo> cmbTipoRaza;
    @FXML private ComboBox<ItemCatalogo> cmbLugarPais;
    @FXML private ComboBox<ItemCatalogo> cmbLugarProvincia;
    @FXML private ComboBox<ItemCatalogo> cmbLugarCanton;
    @FXML private ComboBox<ItemCatalogo> cmbLugarDistrito;
    @FXML private Label lblSoloLectura;
    @FXML private TableView<ItemCatalogo> tblCatalogo;
    @FXML private TableColumn<ItemCatalogo, String> colCatNombre;
    @FXML private TextField txtNombreCatalogo;
    @FXML private Button btnAgregar;
    @FXML private Button btnGuardarNombre;
    @FXML private Button btnEliminar;
    @FXML private Label lblMensajeCatalogo;

    private final ParametroManager parametroManager = new ParametroManager();
    private final CatalogoManager catalogoManager = new CatalogoManager();
    /** Elige el padre de provincias (país), cantones (provincia) y distritos (cantón). */
    private SelectorUbicacion selectorPadre;

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        configurarParametros();
        configurarCatalogos();
    }

    // ------------------------------------------------------------------------
    // ------------------------ Parámetros del sistema ------------------------
    // ------------------------------------------------------------------------

    private void configurarParametros() {
        colParamDescripcion.setCellValueFactory(f -> texto(f.getValue().getDescripcion()));
        colParamClave.setCellValueFactory(f -> texto(f.getValue().getNombre()));
        colParamValor.setCellValueFactory(f -> texto(f.getValue().getValor()));
        tblParametros.getSelectionModel().selectedItemProperty().addListener((observable, anterior, nuevo) -> {
            txtValorParametro.setText(nuevo == null ? VACIO : nuevo.getValor());
            lblMensajeParametro.setText(VACIO);
        });
        cargarParametros();
    }

    private void cargarParametros() {
        tblParametros.setItems(FXCollections.observableArrayList(parametroManager.listar()));
    }

    @FXML
    private void onGuardarParametro() {
        Parametro seleccionado = tblParametros.getSelectionModel().getSelectedItem();
        if (seleccionado == null) {
            lblMensajeParametro.setText("Seleccione un parámetro de la tabla.");
            return;
        }
        try {
            parametroManager.actualizar(seleccionado.getId(), txtValorParametro.getText());
            cargarParametros();
            tblParametros.getItems().stream()
                    .filter(p -> p.getId() == seleccionado.getId())
                    .findFirst()
                    .ifPresent(p -> tblParametros.getSelectionModel().select(p));
            lblMensajeParametro.setText("Parámetro guardado. El cambio ya se usa en el sistema.");
        } catch (RuntimeException e) {
            informarError(e);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Catálogos -------------------------------
    // ------------------------------------------------------------------------

    private void configurarCatalogos() {
        cmbCatalogo.setConverter(new StringConverter<TipoCatalogo>() {
            @Override
            public String toString(TipoCatalogo tipo) {
                return tipo == null ? VACIO : etiqueta(tipo);
            }

            @Override
            public TipoCatalogo fromString(String texto) {
                return null;
            }
        });
        cmbCatalogo.setItems(FXCollections.observableArrayList(catalogoManager.listarCatalogos()));
        cmbCatalogo.setValue(TipoCatalogo.TIPO_MASCOTA);
        cmbCatalogo.valueProperty().addListener((observable, anterior, nuevo) -> refrescarCatalogo());

        cmbTipoRaza.setItems(FXCollections.observableArrayList(catalogoManager.listarTiposDeMascota()));
        if (!cmbTipoRaza.getItems().isEmpty()) {
            cmbTipoRaza.setValue(cmbTipoRaza.getItems().get(0));
        }
        cmbTipoRaza.valueProperty().addListener((observable, anterior, nuevo) -> refrescarCatalogo());

        selectorPadre = new SelectorUbicacion(cmbLugarPais, cmbLugarProvincia, cmbLugarCanton, cmbLugarDistrito);
        for (ComboBox<ItemCatalogo> combo : List.of(cmbLugarPais, cmbLugarProvincia, cmbLugarCanton)) {
            combo.valueProperty().addListener((observable, anterior, nuevo) -> refrescarCatalogo());
        }

        colCatNombre.setCellValueFactory(f -> texto(f.getValue().getNombre()));
        tblCatalogo.getSelectionModel().selectedItemProperty().addListener(
                (observable, anterior, nuevo) -> mostrarSeleccion(nuevo));
        refrescarCatalogo();
    }

    /** Vuelve a cargar la tabla según el catálogo y, para razas, el tipo de mascota elegido. */
    private void refrescarCatalogo() {
        TipoCatalogo tipo = cmbCatalogo.getValue();
        if (tipo == null) {
            return;
        }
        mostrarSelectoresDePadre(tipo);
        ItemCatalogo padre = padreActual();
        boolean hayPadre = !tipo.tienePadre() || padre != null;
        boolean editable = catalogoManager.esEditable(tipo) && hayPadre;

        lblSoloLectura.setText(catalogoManager.esEditable(tipo) ? VACIO
                : "Este catálogo es de solo lectura: lo usa la lógica de la aplicación.");
        lblMensajeCatalogo.setText(hayPadre ? VACIO
                : "Elija primero " + (tipo.getPadre() == TipoCatalogo.PROVINCIA ? "la " : "el ")
                        + CatalogoManager.nombrePadre(tipo) + " para ver sus elementos.");
        btnAgregar.setDisable(!editable);
        btnGuardarNombre.setDisable(!editable);
        btnEliminar.setDisable(!editable);
        txtNombreCatalogo.setDisable(!editable);

        tblCatalogo.setItems(FXCollections.observableArrayList(
                hayPadre ? catalogoManager.elementos(tipo, padre) : List.of()));
        tblCatalogo.getSelectionModel().clearSelection();
        txtNombreCatalogo.clear();
    }

    private void mostrarSeleccion(ItemCatalogo elemento) {
        if (elemento == null) {
            txtNombreCatalogo.clear();
            return;
        }
        txtNombreCatalogo.setText(elemento.getNombre());
    }

    @FXML
    private void onAgregar() {
        try {
            catalogoManager.agregar(cmbCatalogo.getValue(), padreActual(), txtNombreCatalogo.getText());
            recargarLugares();
            refrescarCatalogo();
            lblMensajeCatalogo.setText("Elemento agregado.");
        } catch (RuntimeException e) {
            informarError(e);
        }
    }

    @FXML
    private void onGuardarNombre() {
        try {
            catalogoManager.cambiarNombre(cmbCatalogo.getValue(), padreActual(),
                    elementoSeleccionado(), txtNombreCatalogo.getText());
            recargarLugares();
            refrescarCatalogo();
            lblMensajeCatalogo.setText("Nombre guardado.");
        } catch (RuntimeException e) {
            informarError(e);
        }
    }

    @FXML
    private void onEliminar() {
        ItemCatalogo elemento = elementoSeleccionado();
        if (elemento == null) {
            lblMensajeCatalogo.setText("Seleccione un elemento de la tabla.");
            return;
        }
        if (!Alertas.confirmar("Eliminar elemento", "¿Eliminar «" + elemento.getNombre() + "»?")) {
            return;
        }
        try {
            catalogoManager.eliminar(cmbCatalogo.getValue(), elemento);
            recargarLugares();
            refrescarCatalogo();
            lblMensajeCatalogo.setText("Elemento eliminado.");
        } catch (RuntimeException e) {
            informarError(e);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    /** Padre elegido para el catálogo actual, o null si el catálogo no tiene padre. */
    private ItemCatalogo padreActual() {
        TipoCatalogo tipo = cmbCatalogo.getValue();
        if (tipo == null) {
            return null;
        }
        return switch (tipo) {
            case RAZA -> cmbTipoRaza.getValue();
            case PROVINCIA -> cmbLugarPais.getValue();
            case CANTON -> cmbLugarProvincia.getValue();
            case DISTRITO -> cmbLugarCanton.getValue();
            default -> null;
        };
    }

    /** Muestra solo los combos que hacen falta para elegir el padre del catálogo actual. */
    private void mostrarSelectoresDePadre(TipoCatalogo tipo) {
        boolean esLugar = tipo == TipoCatalogo.PROVINCIA || tipo == TipoCatalogo.CANTON || tipo == TipoCatalogo.DISTRITO;
        mostrar(cmbTipoRaza, tipo == TipoCatalogo.RAZA);
        mostrar(cmbLugarPais, esLugar);
        mostrar(cmbLugarProvincia, tipo == TipoCatalogo.CANTON || tipo == TipoCatalogo.DISTRITO);
        mostrar(cmbLugarCanton, tipo == TipoCatalogo.DISTRITO);
        lblPadre.setVisible(tipo.tienePadre());
        lblPadre.setText(esLugar ? "Ubicación a la que pertenece" : "Tipo de mascota al que pertenece");
    }

    private static void mostrar(ComboBox<ItemCatalogo> combo, boolean visible) {
        combo.setVisible(visible);
        combo.setManaged(visible);
    }

    /** Si cambió un país, provincia o cantón, actualiza las listas de los combos de ubicación. */
    private void recargarLugares() {
        TipoCatalogo tipo = cmbCatalogo.getValue();
        if (tipo == TipoCatalogo.PAIS || tipo == TipoCatalogo.PROVINCIA || tipo == TipoCatalogo.CANTON) {
            selectorPadre.recargar();
        }
    }

    private ItemCatalogo elementoSeleccionado() {
        return tblCatalogo.getSelectionModel().getSelectedItem();
    }

    /** Muestra un mensaje de validación o de regla de negocio; no deja que la pantalla falle. */
    private void informarError(RuntimeException e) {
        Alertas.mostrarError("No se puede completar", e.getMessage());
    }

    private static String etiqueta(TipoCatalogo tipo) {
        return switch (tipo) {
            case TIPO_MASCOTA -> "Tipos de mascota";
            case RAZA -> "Razas (por tipo de mascota)";
            case COLOR -> "Colores";
            case TAMANO -> "Tamaños";
            case ESTADO_MASCOTA -> "Estados de mascota (solo lectura)";
            case SEVERIDAD -> "Severidad";
            case NIVEL_ENERGIA -> "Nivel de energía";
            case FACILIDAD_ENTRENAMIENTO -> "Facilidad de entrenamiento";
            case MONEDA -> "Monedas (solo lectura)";
            case ENFERMEDAD -> "Enfermedades";
            case VETERINARIO -> "Veterinarios (solo lectura)";
            case PAIS -> "Países";
            case PROVINCIA -> "Provincias (por país)";
            case CANTON -> "Cantones (por provincia)";
            case DISTRITO -> "Distritos (por cantón)";
            case TIPO_VIVIENDA -> "Tipos de vivienda";
            case TIEMPO_EJERCICIO -> "Tiempo de ejercicio";
            case ESTADO_CASA_CUNA -> "Estados de casa cuna (solo lectura)";
        };
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? VACIO : valor);
    }
}
