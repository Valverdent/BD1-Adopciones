package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.manager.CasaCunaManager;
import com.mycompany.bd_proyecto1.manager.PersonaManager;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;

/**
 * Controlador del formulario de casas cuna (CasaCunaFormulario.fxml). Si la persona en sesión no
 * es la dueña (ni administradora), se muestra en solo lectura.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CasaCunaFormularioController {

    @FXML private Label lblTitulo;
    @FXML private Label lblDueno;
    @FXML private Label lblSoloLectura;
    @FXML private Label lblDisponible;
    @FXML private Label lblContacto;
    /** Bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private ComboBox<ItemCatalogo> cmbEstado;
    @FXML private TextField txtCapacidad;
    @FXML private Label lblActual;
    @FXML private CheckBox chkDonacion;
    @FXML private HBox boxTamanos;
    @FXML private HBox boxTipos;
    @FXML private Button btnGuardar;

    private final CasaCunaManager casaCunaManager = new CasaCunaManager();
    private final PersonaManager personaManager = new PersonaManager();
    private final Map<ItemCatalogo, CheckBox> checksTamano = new LinkedHashMap<>();
    private final Map<ItemCatalogo, CheckBox> checksTipo = new LinkedHashMap<>();

    private CasaCuna casaActual; // null = casa nueva

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        cmbEstado.setItems(FXCollections.observableArrayList(casaCunaManager.listarCatalogo(TipoCatalogo.ESTADO_CASA_CUNA)));
        crearCasillas(TipoCatalogo.TAMANO, checksTamano, boxTamanos);
        crearCasillas(TipoCatalogo.TIPO_MASCOTA, checksTipo, boxTipos);
    }

    /** Una casilla por cada elemento del catálogo (tamaños o tipos de mascota). */
    private void crearCasillas(TipoCatalogo tipo, Map<ItemCatalogo, CheckBox> casillas, HBox contenedor) {
        for (ItemCatalogo elemento : casaCunaManager.listarCatalogo(tipo)) {
            CheckBox check = new CheckBox(elemento.getNombre());
            casillas.put(elemento, check);
            contenedor.getChildren().add(check);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------ Carga de la casa cuna -------------------------
    // ------------------------------------------------------------------------

    public void prepararNueva() {
        casaActual = null;
        lblTitulo.setText("Registrar mi casa cuna");
        Persona yo = personaManager.obtener(Sesion.getUsuario().getIdPersona());
        lblDueno.setText("Dueño: " + yo.getNombreCompleto());
        lblContacto.setText(textoContacto(yo.getTelefonos(), yo.getCorreos()));
        txtCapacidad.setText("1");
        lblActual.setText("0");
        cmbEstado.setValue(casaCunaManager.listarCatalogo(TipoCatalogo.ESTADO_CASA_CUNA).get(0));
        lblDisponible.setText("");
        configurarPermisos(true);
    }

    public void mostrarCasa(CasaCuna casa) {
        casaActual = casa;
        lblTitulo.setText("Casa cuna de " + casa.getNombrePersona());
        lblDueno.setText("Dueño: " + casa.getNombrePersona());
        lblContacto.setText(textoContacto(casa.getTelefonos(), casa.getCorreos()));
        ubicacionController.mostrar(casa.getUbicacion());
        cmbEstado.setValue(casa.getEstado());
        txtCapacidad.setText(String.valueOf(casa.getCapacidadMaxima()));
        lblActual.setText(String.valueOf(casa.getCantidadActual()));
        chkDonacion.setSelected(casa.isRequiereDonacionAlimentos());
        for (Map.Entry<ItemCatalogo, CheckBox> e : checksTamano.entrySet()) {
            e.getValue().setSelected(casa.getTamanos().contains(e.getKey()));
        }
        for (Map.Entry<ItemCatalogo, CheckBox> e : checksTipo.entrySet()) {
            e.getValue().setSelected(casa.getTipos().contains(e.getKey()));
        }
        lblDisponible.setText(casa.isDisponible()
                ? "Esta casa está disponible para recibir mascotas."
                : "Esta casa no está disponible ahora (estado distinto de \"Disponible\" o sin cupo).");
        configurarPermisos(casaCunaManager.puedeEditar(casa));
    }

    private String textoContacto(List<String> telefonos, List<String> correos) {
        String tel = telefonos.isEmpty() ? "—" : String.join(", ", telefonos);
        String cor = correos.isEmpty() ? "—" : String.join(", ", correos);
        return "Teléfonos: " + tel + "\nCorreos: " + cor;
    }

    /** En solo lectura se deshabilitan los campos y se oculta el botón Guardar. */
    private void configurarPermisos(boolean puedeEditar) {
        ubicacionController.setBloqueado(!puedeEditar);
        cmbEstado.setDisable(!puedeEditar);
        txtCapacidad.setDisable(!puedeEditar);
        chkDonacion.setDisable(!puedeEditar);
        boxTamanos.setDisable(!puedeEditar);
        boxTipos.setDisable(!puedeEditar);
        btnGuardar.setVisible(puedeEditar);
        btnGuardar.setManaged(puedeEditar);
        lblSoloLectura.setVisible(!puedeEditar);
        lblSoloLectura.setManaged(!puedeEditar);
    }

    // ------------------------------------------------------------------------
    // ------------------------ Guardado y navegación -------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onGuardar() {
        try {
            CasaCuna casa = new CasaCuna();
            if (casaActual != null) {
                casa.setIdPersona(casaActual.getIdPersona());
                casa.setCantidadActual(casaActual.getCantidadActual());
            }
            casa.setUbicacion(ubicacionController.leer());
            casa.setEstado(cmbEstado.getValue());
            casa.setCapacidadMaxima(CasaCunaManager.convertirEntero(txtCapacidad.getText(), "la capacidad máxima"));
            casa.setRequiereDonacionAlimentos(chkDonacion.isSelected());
            casa.setTamanos(marcados(checksTamano));
            casa.setTipos(marcados(checksTipo));

            boolean esNueva = casaActual == null;
            casaCunaManager.guardar(casa, esNueva);
            Alertas.mostrarInformacion("Casa cuna guardada", "Los datos de la casa cuna se guardaron correctamente.");
            onVolver();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    /** Elementos cuya casilla está marcada. */
    private static List<ItemCatalogo> marcados(Map<ItemCatalogo, CheckBox> casillas) {
        List<ItemCatalogo> resultado = new ArrayList<>();
        for (Map.Entry<ItemCatalogo, CheckBox> e : casillas.entrySet()) {
            if (e.getValue().isSelected()) {
                resultado.add(e.getKey());
            }
        }
        return resultado;
    }

    @FXML
    private void onVolver() {
        Navegador.mostrarEnContenido("CasaCunaConsulta.fxml");
    }
}
