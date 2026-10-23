package com.mycompany.bd_proyecto1.controller;

import com.mycompany.bd_proyecto1.manager.AdopcionManager;
import com.mycompany.bd_proyecto1.manager.ListaNegraManager;
import com.mycompany.bd_proyecto1.manager.PersonaManager;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.DetallePersona;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import com.mycompany.bd_proyecto1.util.Alertas;
import com.mycompany.bd_proyecto1.util.IntegracionPendienteException;
import com.mycompany.bd_proyecto1.util.Navegador;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.time.format.DateTimeFormatter;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.layout.VBox;

/**
 * Controlador del detalle de una persona (PersonaDetalle.fxml).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class PersonaDetalleController {

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @FXML private Label lblNombre;
    @FXML private Label lblLugar;
    @FXML private Label lblTelefonos;
    @FXML private Label lblCorreos;
    @FXML private Label lblEstadoListaNegra;
    @FXML private Label lblPromedio;
    @FXML private Label lblVeterinario;
    @FXML private Button btnVeterinario;
    @FXML private Button btnEditar;
    @FXML private Button btnQuitarReporte;
    @FXML private VBox panelReportar;
    @FXML private TextArea txtMotivo;

    @FXML private TableView<ReporteListaNegra> tblReportes;
    @FXML private TableColumn<ReporteListaNegra, String> colRepFecha;
    @FXML private TableColumn<ReporteListaNegra, String> colRepMotivo;

    @FXML private TableView<Adopcion> tblAdopciones;
    @FXML private TableColumn<Adopcion, String> colAdopFecha;
    @FXML private TableColumn<Adopcion, String> colAdopMascota;
    @FXML private TableColumn<Adopcion, String> colAdopCalificacion;
    @FXML private TableColumn<Adopcion, String> colAdopNotas;

    private final PersonaManager personaManager = new PersonaManager();
    private final ListaNegraManager listaNegraManager = new ListaNegraManager();

    private int idPersona;
    private String origen = PersonaConsultaController.ARCHIVO;
    private Persona persona;

    // ------------------------------------------------------------------------
    // ---------------------------- Inicialización ----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void initialize() {
        colRepFecha.setCellValueFactory(fila -> texto(fila.getValue().getFecha().format(FORMATO_FECHA)));
        colRepMotivo.setCellValueFactory(fila -> texto(fila.getValue().getMotivo()));
        colAdopFecha.setCellValueFactory(fila -> texto(fila.getValue().getFechaAdopcion().format(FORMATO_FECHA)));
        colAdopMascota.setCellValueFactory(fila -> {
            String nombre = fila.getValue().getMascota().getNombre();
            return texto(nombre == null || nombre.isBlank() ? "(sin nombre)" : nombre);
        });
        colAdopCalificacion.setCellValueFactory(fila -> texto(AdopcionManager.textoCalificacion(fila.getValue().getCalificacion())));
        colAdopNotas.setCellValueFactory(fila -> texto(fila.getValue().getNotasCalificacion()));

        boolean admin = Sesion.getUsuario() != null && Sesion.getUsuario().esAdministrador();
        btnQuitarReporte.setVisible(admin);
        btnQuitarReporte.setManaged(admin);
    }

    private SimpleStringProperty texto(String valor) {
        return new SimpleStringProperty(valor == null ? "" : valor);
    }

    // ------------------------------------------------------------------------
    // ------------------------- Carga de la persona --------------------------
    // ------------------------------------------------------------------------

    /** Muestra la persona; origenFxml es la pantalla a la que vuelve el botón "Volver". */
    public void mostrar(int idPersona, String origenFxml) {
        this.idPersona = idPersona;
        this.origen = origenFxml;
        recargar();
    }

    private void recargar() {
        DetallePersona detalle = personaManager.obtenerDetalle(idPersona);
        persona = detalle.getPersona();

        lblNombre.setText(persona.getNombreCompleto());
        lblLugar.setText("Lugar de residencia: " + valor(Ubicacion.descripcionDe(persona.getUbicacion())));
        lblTelefonos.setText("Teléfonos: " + (persona.getTelefonos().isEmpty() ? "—" : String.join(", ", persona.getTelefonos())));
        lblCorreos.setText("Correos: " + (persona.getCorreos().isEmpty() ? "—" : String.join(", ", persona.getCorreos())));

        btnEditar.setVisible(personaManager.puedeEditar(persona));
        btnEditar.setManaged(btnEditar.isVisible());

        boolean veterinario = personaManager.esVeterinario(idPersona);
        lblVeterinario.setText("Veterinario/a: " + (veterinario ? "Sí" : "No"));
        boolean mostrarBoton = !veterinario && personaManager.puedeRegistrarVeterinario();
        btnVeterinario.setVisible(mostrarBoton);
        btnVeterinario.setManaged(mostrarBoton);

        if (detalle.estaEnListaNegra()) {
            lblEstadoListaNegra.setText("⚠ Esta persona está en la lista negra (" + detalle.getReportes().size() + " reporte(s)).");
        } else {
            lblEstadoListaNegra.setText("Esta persona no está en la lista negra.");
        }
        tblReportes.setItems(FXCollections.observableArrayList(detalle.getReportes()));

        // No se puede reportar a uno mismo.
        boolean propia = Sesion.getUsuario() != null && Sesion.getUsuario().getIdPersona() == idPersona;
        panelReportar.setVisible(!propia);
        panelReportar.setManaged(!propia);

        tblAdopciones.setItems(FXCollections.observableArrayList(detalle.getAdopciones()));
        lblPromedio.setText(detalle.getCalificacionPromedio() == null
                ? "Calificación promedio: sin calificaciones"
                : "Calificación promedio: " + detalle.getCalificacionPromedio() + " de 5 ("
                  + detalle.getAdopciones().size() + " adopción(es))");
    }

    private String valor(String texto) {
        return texto == null || texto.isBlank() ? "—" : texto;
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Lista negra ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onReportar() {
        try {
            if (!Alertas.confirmar("Reportar en lista negra",
                    "¿Desea reportar a " + persona.getNombreCompleto() + " en la lista negra?")) {
                return;
            }
            listaNegraManager.reportar(idPersona, txtMotivo.getText());
            txtMotivo.clear();
            Alertas.mostrarInformacion("Reporte registrado", "El reporte se agregó a la lista negra.");
            recargar();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("No se pudo reportar", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    @FXML
    private void onQuitarReporte() {
        ReporteListaNegra seleccionado = tblReportes.getSelectionModel().getSelectedItem();
        if (seleccionado == null) {
            Alertas.mostrarInformacion("Seleccione un reporte", "Seleccione el reporte que desea quitar.");
            return;
        }
        try {
            if (!Alertas.confirmar("Quitar reporte", "¿Desea quitar el reporte seleccionado de la lista negra?")) {
                return;
            }
            listaNegraManager.eliminarReporte(seleccionado.getId());
            recargar();
        } catch (IllegalStateException e) {
            Alertas.mostrarError("No se pudo quitar", e.getMessage());
        } catch (IntegracionPendienteException e) {
            Alertas.mostrarInformacion("Integración pendiente", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Veterinarios -----------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onRegistrarVeterinario() {
        try {
            if (!Alertas.confirmar("Registrar veterinario/a",
                    "¿Desea registrar a " + persona.getNombreCompleto() + " como veterinario/a?\n"
                    + "Después no se puede quitar desde la aplicación.")) {
                return;
            }
            personaManager.registrarVeterinario(idPersona);
            Alertas.mostrarInformacion("Veterinario/a registrado",
                    "Ya aparece en la lista de veterinarios del formulario de mascotas.");
            recargar();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Alertas.mostrarError("No se pudo registrar", e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Navegación ------------------------------
    // ------------------------------------------------------------------------

    @FXML
    private void onEditar() {
        PersonaFormularioController formulario = Navegador.mostrarEnContenido("PersonaFormulario.fxml");
        formulario.mostrarPersona(persona, origen);
    }

    @FXML
    private void onVolver() {
        Navegador.mostrarEnContenido(origen);
    }
}
