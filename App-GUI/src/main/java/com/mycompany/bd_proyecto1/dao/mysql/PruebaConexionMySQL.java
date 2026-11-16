package com.mycompany.bd_proyecto1.dao.mysql;

import com.mycompany.bd_proyecto1.dao.ConexionBD;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;

/**
 * Diagnóstico de la conexión con MySQL: se conecta con los datos de db.properties, muestra la
 * versión y la zona horaria del servidor, y compara los procedimientos que usaba la aplicación en
 * Oracle con los que existen en MySQL. Se ejecuta con clic derecho &gt; Run File.
 *
 * @author Carlos Hidalgo
 * @since 2026-11-14
 */
public final class PruebaConexionMySQL {

    /** Procedimientos y funciones que llaman los DAO de Oracle (paquete.nombre). */
    private static final String[] PROCEDIMIENTOS_ORACLE = {
            "pkg_administration_donation_association.pr_get_associations_filtered",
            "pkg_administration_donation_association.pr_get_donation_history",
            "pkg_administration_donation_association.pr_register_association",
            "pkg_administration_donation_association.pr_register_donation",
            "pkg_administration_donation_association.pr_update_association",
            "pkg_administration_donation_association.pr_update_donation_amount",
            "pkg_adoption_administration.pr_get_adoption_rating",
            "pkg_adoption_administration.pr_get_adoptions",
            "pkg_adoption_administration.pr_get_follow_ups",
            "pkg_adoption_administration.pr_get_photos_filtered",
            "pkg_adoption_administration.pr_register_adoption",
            "pkg_adoption_administration.pr_register_follow_up",
            "pkg_adoption_administration.pr_register_photo",
            "pkg_adoption_administration.pr_register_rating",
            "pkg_catalog.pr_delete_catalog",
            "pkg_catalog.pr_get_catalog",
            "pkg_catalog.pr_get_donation_types",
            "pkg_catalog.pr_get_photo_types",
            "pkg_catalog.pr_get_roles",
            "pkg_catalog.pr_get_user_statuses",
            "pkg_catalog.pr_insert_catalog",
            "pkg_catalog.pr_update_catalog",
            "pkg_parameter.fn_get_number",
            "pkg_parameter.fn_get_text",
            "pkg_parameter.pr_get_parameters",
            "pkg_parameter.pr_update_parameter",
            "pkg_person_administration.pr_add_blacklist",
            "pkg_person_administration.pr_add_email",
            "pkg_person_administration.pr_add_phone",
            "pkg_person_administration.pr_delete_blacklist",
            "pkg_person_administration.pr_delete_email",
            "pkg_person_administration.pr_delete_phone",
            "pkg_person_administration.pr_get_adopter",
            "pkg_person_administration.pr_get_foster_home_accepts",
            "pkg_person_administration.pr_get_foster_homes",
            "pkg_person_administration.pr_get_other_pets",
            "pkg_person_administration.pr_get_person_contacts",
            "pkg_person_administration.pr_get_person_ratings",
            "pkg_person_administration.pr_get_persons",
            "pkg_person_administration.pr_query_veterinarians",
            "pkg_person_administration.pr_register_adopter",
            "pkg_person_administration.pr_register_foster_home",
            "pkg_person_administration.pr_register_person",
            "pkg_person_administration.pr_register_veterinarian",
            "pkg_person_administration.pr_report_blacklist",
            "pkg_person_administration.pr_update_foster_home",
            "pkg_person_administration.pr_update_person_location",
            "pkg_person_administration.pr_update_person_names",
            "pkg_pet_administration.pr_delete_disease",
            "pkg_pet_administration.pr_get_disease_treatments",
            "pkg_pet_administration.pr_get_pet_diseases",
            "pkg_pet_administration.pr_insert_disease",
            "pkg_pet_administration.pr_insert_reward",
            "pkg_pet_administration.pr_match_lost_found",
            "pkg_pet_administration.pr_query_pets",
            "pkg_pet_administration.pr_register_pet",
            "pkg_pet_administration.pr_update_pet",
            "pkg_queries_extras.pr_get_changelog",
            "pkg_queries_extras.pr_get_changelog_tables",
            "pkg_queries_extras.pr_get_foster_home_availability",
            "pkg_queries_extras.pr_get_lost_pets",
            "pkg_statistics.pr_stat_adoption_rate",
            "pkg_statistics.pr_stat_donations_by_rescuer",
            "pkg_statistics.pr_stat_pets_by_canton",
            "pkg_statistics.pr_stat_pets_status",
            "pkg_statistics.pr_stat_unadopted_age",
            "pkg_user_administration.fn_active_status_name",
            "pkg_user_administration.fn_email_exists",
            "pkg_user_administration.fn_phone_exists",
            "pkg_user_administration.fn_username_exists",
            "pkg_user_administration.pr_get_users",
            "pkg_user_administration.pr_login_user",
            "pkg_user_administration.pr_register_user",
            "pkg_user_administration.pr_update_user_role",
            "pkg_user_administration.pr_update_user_status"
    };

    private PruebaConexionMySQL() {
        // Solo tiene el método main.
    }

    public static void main(String[] args) {
        try {
            Connection c = ConexionBD.obtener();
            mostrarServidor(c);
            Set<String> rutinas = listarRutinas(c);
            compararConOracle(rutinas);
        } catch (RuntimeException | SQLException e) {
            System.out.println("ERROR: " + e.getMessage());
        } finally {
            ConexionBD.cerrar();
        }
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Servidor -------------------------------
    // ------------------------------------------------------------------------

    private static void mostrarServidor(Connection c) throws SQLException {
        String consulta = "SELECT VERSION(), DATABASE(), CURRENT_USER(), "
                + "@@global.time_zone, @@system_time_zone";
        try (Statement st = c.createStatement(); ResultSet fila = st.executeQuery(consulta)) {
            fila.next();
            System.out.println("Conexión correcta con MySQL " + fila.getString(1));
            System.out.println("Base: " + fila.getString(2) + "   Usuario: " + fila.getString(3));
            System.out.println("Zona horaria: global=" + fila.getString(4) + ", sistema=" + fila.getString(5)
                    + "  (debe coincidir con serverTimezone de db.properties)");
        }
    }

    // ------------------------------------------------------------------------
    // --------------------------- Procedimientos -----------------------------
    // ------------------------------------------------------------------------

    /** Nombres en minúscula de los procedimientos y funciones de la base actual. */
    private static Set<String> listarRutinas(Connection c) throws SQLException {
        String consulta = "SELECT ROUTINE_NAME FROM information_schema.ROUTINES "
                + "WHERE ROUTINE_SCHEMA = DATABASE()";
        Set<String> rutinas = new TreeSet<>();
        try (Statement st = c.createStatement(); ResultSet filas = st.executeQuery(consulta)) {
            while (filas.next()) {
                rutinas.add(filas.getString(1).toLowerCase(Locale.ROOT));
            }
        }
        System.out.println("Procedimientos y funciones en MySQL: " + rutinas.size());
        return rutinas;
    }

    /** Busca cada procedimiento de Oracle en MySQL por su nombre, sin el paquete. */
    private static void compararConOracle(Set<String> rutinas) {
        List<String> faltan = new ArrayList<>();
        Set<String> usados = new TreeSet<>();
        for (String completo : PROCEDIMIENTOS_ORACLE) {
            String nombre = completo.substring(completo.indexOf('.') + 1);
            if (rutinas.contains(nombre)) {
                usados.add(nombre);
            } else {
                faltan.add(completo);
            }
        }
        System.out.println();
        System.out.println("Encontrados con el mismo nombre: " + usados.size() + " de "
                + PROCEDIMIENTOS_ORACLE.length);
        System.out.println("No encontrados (cambiaron de nombre o faltan en MySQL): " + faltan.size());
        faltan.forEach(p -> System.out.println("   " + p));

        Set<String> nuevos = new TreeSet<>(rutinas);
        nuevos.removeAll(usados);
        System.out.println("En MySQL pero no usados por la versión de Oracle: " + nuevos.size());
        nuevos.forEach(p -> System.out.println("   " + p));
    }
}
