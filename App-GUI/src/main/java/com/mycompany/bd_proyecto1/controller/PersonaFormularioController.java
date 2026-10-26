package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.PersonaManager;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import java.util.ArrayList;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextField;

/**
 * Controlador del formulario de personas (PersonaFormulario.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaFormularioController {

    @FXML private Label lblTitulo;
    @FXML private TextField txtNombre;
    @FXML private TextField txtSegundoNombre;
    @FXML private TextField txtPrimerApellido;
    @FXML private TextField txtSegundoApellido;
    /** Bloque UbicacionCampos.fxml (fx:id="ubicacion"). */
    @FXML private UbicacionCamposController ubicacionController;
    @FXML private TextField txtTelefono;
    @FXML private TextField txtCorreo;
    @FXML private ListView<String> lstTelefonos;
    @FXML private ListView<String> lstCorreos;
    @FXML private CheckBox chkVeterinario;

    private final PersonaManager personaManager = new PersonaManager();
    private int idPersona; // 0 = persona nueva
    private String origen = PersonaConsultaController.ARCHIVO;
    private boolean yaEraVeterinario;

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        lstTelefonos.setItems(FXCollections.observableArrayList());
        lstCorreos.setItems(FXCollections.observableArrayList());
        boolean admin = personaManager.puedeRegistrarVeterinario();
        chkVeterinario.setVisible(admin);
        chkVeterinario.setManaged(admin);
    }

    public void prepararNueva() {
        idPersona = 0;
        yaEraVeterinario = false;
        lblTitulo.setText("Registrar persona");
    }

    /** Carga una persona para editarla; origenFxml es la pantalla a la que se vuelve. */
    public void mostrarPersona(Persona persona, String origenFxml) {
        idPersona = persona.getId();
        origen = origenFxml;
        lblTitulo.setText("Editar persona");
        txtNombre.setText(persona.getNombre());
        txtSegundoNombre.setText(persona.getSegundoNombre());
        txtPrimerApellido.setText(persona.getPrimerApellido());
        txtSegundoApellido.setText(persona.getSegundoApellido());
        ubicacionController.mostrar(persona.getUbicacion());
        lstTelefonos.getItems().setAll(persona.getTelefonos());
        lstCorreos.getItems().setAll(persona.getCorreos());

        if (chkVeterinario.isVisible()) {
            yaEraVeterinario = personaManager.esVeterinario(idPersona);
            chkVeterinario.setSelected(yaEraVeterinario);
            // La base no tiene un procedimiento para quitar veterinarios
            chkVeterinario.setDisable(yaEraVeterinario);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------- Teléfonos y correos --------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onAgregarTelefono() {
        try {
            String telefono = personaManager.validarTelefono(txtTelefono.getText());
            if (lstTelefonos.getItems().contains(telefono)) {
                throw new IllegalArgumentException("Ese teléfono ya está en la lista.");
            }
            lstTelefonos.getItems().add(telefono);
            txtTelefono.clear();
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Teléfono no válido", e.getMessage());
        }
    }

    @FXML
    private void onQuitarTelefono() {
        String seleccionado = lstTelefonos.getSelectionModel().getSelectedItem();
        if (seleccionado != null) {
            lstTelefonos.getItems().remove(seleccionado);
        }
    }

    @FXML
    private void onAgregarCorreo() {
        try {
            String correo = personaManager.validarCorreo(txtCorreo.getText());
            if (lstCorreos.getItems().stream().anyMatch(c -> c.equalsIgnoreCase(correo))) {
                throw new IllegalArgumentException("Ese correo ya está en la lista.");
            }
            lstCorreos.getItems().add(correo);
            txtCorreo.clear();
        } catch (IllegalArgumentException e) {
            Alertas.mostrarError("Correo no válido", e.getMessage());
        }
    }

    @FXML
    private void onQuitarCorreo() {
        String seleccionado = lstCorreos.getSelectionModel().getSelectedItem();
        if (seleccionado != null) {
            lstCorreos.getItems().remove(seleccionado);
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------ Guardado y navegación -------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onGuardar() {
        try {
            Persona p = new Persona();
            p.setId(idPersona);
            p.setNombre(txtNombre.getText());
            p.setSegundoNombre(txtSegundoNombre.getText());
            p.setPrimerApellido(txtPrimerApellido.getText());
            p.setSegundoApellido(txtSegundoApellido.getText());
            p.setUbicacion(ubicacionController.leer());
            p.setTelefonos(new ArrayList<>(lstTelefonos.getItems()));
            p.setCorreos(new ArrayList<>(lstCorreos.getItems()));

            int id = personaManager.guardar(p);
            idPersona = id;                     // si algo falla después, ya no es "nueva"
            String mensaje = "Los datos de la persona se guardaron correctamente.";
            if (chkVeterinario.isVisible() && chkVeterinario.isSelected() && !yaEraVeterinario) {
                try {
                    personaManager.registrarVeterinario(id);
                    yaEraVeterinario = true;
                    mensaje += "\nTambién quedó registrada como veterinaria.";
                } catch (IllegalArgumentException | IllegalStateException e) {
                    Alertas.mostrarError("Persona guardada sin registrar como veterinaria", e.getMessage());
                    abrirDetalle(id);
                    return;
                }
            }
            Alertas.mostrarInformacion("Persona guardada", mensaje);
            abrirDetalle(id);
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("Revise los datos", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    @FXML
    private void onCancelar() {
        if (idPersona == 0) {
            Navegador.mostrarEnContenido(PersonaConsultaController.ARCHIVO);
        } else {
            abrirDetalle(idPersona);
        }
    }

    private void abrirDetalle(int id) {
        PersonaDetalleController detalle = Navegador.mostrarEnContenido("PersonaDetalle.fxml");
        detalle.mostrar(id, origen);
    }
}
