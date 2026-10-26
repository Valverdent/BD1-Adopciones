package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/**
 * Implementación de MascotaDAO con Oracle (paquete PKG_PET_ADMINISTRATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class MascotaDAOOracle implements MascotaDAO {

    /** Comienzo del nombre de los tipos de foto (tabla PhotoType). */
    static final String FOTO_ANTES = "antes";
    static final String FOTO_DESPUES = "despu";

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Mascota> consultar(FiltroMascota filtro) {
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : consultarBase(null, filtro)) {
            boolean cumple = PersonaDAOOracle.contiene(m.getNombre(), filtro.getNombre())
                    && PersonaDAOOracle.contiene(m.getChip(), filtro.getChip())
                    && PersonaDAOOracle.contiene(m.getNombrePersonaRegistro(), filtro.getRegistradoPor())
                    && filtro.getUbicacion().cumple(m.getUbicacion());
            if (cumple) {
                completar(m);
                resultado.add(m);
            }
        }
        return resultado;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Registro y edición --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Mascota mascota) {
        int idMascota;
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_register_pet("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, mascota.getIdPersonaRegistro());
            ponerDatos(cs, 2, mascota);                     // posiciones 2 a 19
            cs.registerOutParameter(20, Types.NUMERIC);
            cs.registerOutParameter(21, Types.NUMERIC);
            cs.execute();
            revisar(cs, 21, "registrar la mascota");
            idMascota = cs.getInt(20);
        } catch (SQLException e) {
            throw error("registrar la mascota", e);
        }
        mascota.setId(idMascota);
        guardarDetalles(mascota, null);
        return idMascota;
    }

    @Override
    public void actualizar(Mascota mascota) {
        Mascota anterior = buscar(mascota.getId());
        if (anterior == null) {
            throw new IllegalStateException("No existe la mascota con id " + mascota.getId());
        }
        if (mascota.getIdCasaCuna() == null) {
            mascota.setIdCasaCuna(anterior.getIdCasaCuna());   // la pantalla no la cambia
        }
        if (mascota.getMontoRecompensa() == null && anterior.getMontoRecompensa() != null) {
            throw new IllegalArgumentException("No se puede quitar la recompensa: la base guarda el historial de "
                    + "recompensas. Puede cambiar el monto.");
        }
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_update_pet("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, mascota.getId());
            ponerDatos(cs, 2, mascota);
            cs.registerOutParameter(20, Types.NUMERIC);
            cs.execute();
            revisar(cs, 20, "actualizar la mascota");
        } catch (SQLException e) {
            throw error("actualizar la mascota", e);
        }
        guardarDetalles(mascota, anterior);
    }

    @Override
    public boolean existeChip(String chip, int idExcluir) {
        FiltroMascota filtro = new FiltroMascota();
        filtro.setChip(chip);
        for (Mascota m : consultarBase(null, filtro)) {
            if (m.getId() != idExcluir && chip.trim().equalsIgnoreCase(m.getChip())) {
                return true;
            }
        }
        return false;
    }

    // ------------------------------------------------------------------------
    // ------------------------- Mascotas sin adoptar -------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Mascota> listarSinAdoptar(int mesesMinimos, ItemCatalogo tipo) {
        // Mismo criterio que PR_UNADOPTED_PETS, pero con los meses que se escriben en la pantalla
        String estadoEnAdopcion = UsuarioDAOOracle.textoDeFuncion(
                "{? = call pkg_parameter.fn_get_text('PET_STATUS_IN_ADOPTION')}");
        Set<Integer> adoptadas = AdopcionDAOOracle.idsMascotasAdoptadas();
        LocalDate limite = LocalDate.now().minusMonths(mesesMinimos);

        FiltroMascota filtro = new FiltroMascota();
        filtro.setTipo(tipo);
        List<Mascota> resultado = new ArrayList<>();
        for (Mascota m : consultarBase(null, filtro)) {
            boolean enAdopcion = m.getEstado() != null && m.getEstado().getNombre().equalsIgnoreCase(estadoEnAdopcion);
            if (enAdopcion && !adoptadas.contains(m.getId())
                    && m.getFechaEvento() != null && !m.getFechaEvento().isAfter(limite)) {
                completar(m);
                resultado.add(m);
            }
        }
        resultado.sort(Comparator.comparing(Mascota::getFechaEvento));
        return resultado;
    }

    /** Una mascota con todos sus datos, o null si no existe (la usan otros DAO). */
    Mascota buscar(int idMascota) {
        List<Mascota> encontradas = consultarBase(idMascota, new FiltroMascota());
        if (encontradas.isEmpty()) {
            return null;
        }
        Mascota m = encontradas.get(0);
        completar(m);
        return m;
    }

    /** Id de la recompensa más reciente de la mascota (la que se dona), o null si no tiene. */
    Integer idRecompensa(int idMascota) {
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_query_pets("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, idMascota);
            for (int i = 2; i <= 19; i++) {
                cs.setNull(i, i <= 3 ? Types.VARCHAR : (i >= 18 ? Types.DATE : Types.NUMERIC));
            }
            cs.registerOutParameter(20, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 20)) {
                return fila.next() ? entero(fila, "rewardId") : null;
            }
        } catch (SQLException e) {
            throw error("consultar la recompensa de la mascota", e);
        }
    }

    // ------------------------------------------------------------------ consulta

    // ------------------------------------------------------------------------
    // -------------------------- Lectura de la base --------------------------
    // ------------------------------------------------------------------------

    /**
     * PR_QUERY_PETS con los filtros de catálogo y fechas (los de texto van en NULL). Lee las
     * columnas originales del cursor y las que se agregaron al final (ids para editar).
     */
    private List<Mascota> consultarBase(Integer idMascota, FiltroMascota f) {
        List<Mascota> mascotas = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_query_pets("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            ponerNumero(cs, 1, idMascota);
            cs.setNull(2, Types.VARCHAR);                   // nombre: se filtra aquí
            cs.setNull(3, Types.VARCHAR);                   // chip: se filtra aquí (parcial)
            ponerId(cs, 4, f.getEstado());
            ponerId(cs, 5, f.getTipo());
            ponerId(cs, 6, f.getRaza());
            ponerId(cs, 7, f.getTamano());
            ponerId(cs, 8, f.getColor());
            cs.setNull(9, Types.NUMERIC);                   // provincia, cantón y distrito: se filtran aquí
            cs.setNull(10, Types.NUMERIC);
            cs.setNull(11, Types.NUMERIC);
            cs.setNull(12, Types.NUMERIC);                  // casa cuna
            cs.setNull(13, Types.NUMERIC);                  // severidad
            cs.setNull(14, Types.NUMERIC);                  // energía
            cs.setNull(15, Types.NUMERIC);                  // entrenamiento
            cs.setNull(16, Types.NUMERIC);                  // enfermedad
            cs.setNull(17, Types.NUMERIC);                  // persona que registró
            ponerFecha(cs, 18, f.getFechaDesde());
            ponerFecha(cs, 19, f.getFechaHasta());
            cs.registerOutParameter(20, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 20)) {
                while (fila.next()) {
                    mascotas.add(leer(fila));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las mascotas", e);
        }
        return mascotas;
    }

    private Mascota leer(ResultSet fila) throws SQLException {
        Mascota m = new Mascota();
        m.setId(fila.getInt("id"));
        m.setNombre(texto(fila, "name"));
        m.setChip(texto(fila, "chipId"));
        m.setEstado(item(fila, "idPetStatus", "statusName"));
        m.setTipo(item(fila, "idPetType", "typeName"));
        m.setRaza(item(fila, "idPetBreed", "breedName"));
        m.setTamano(item(fila, "idPetSize", "sizeName"));
        m.setColor(item(fila, "idPetColor", "colorName"));
        m.setNivelEnergia(item(fila, "idPetEnergy", "energyName"));
        m.setSeveridad(item(fila, "idPetSeverity", "severityName"));
        m.setFacilidadEntrenamiento(item(fila, "idPetTrainability", "trainabilityName"));
        m.setRequiereEspacio(booleano(fila, "requiresSpace"));
        m.setEdadEstimada(entero(fila, "estimatedAge"));
        m.setFechaEvento(fecha(fila, "eventDate"));

        ItemCatalogo distrito = item(fila, "districtId", "districtName");
        if (distrito != null) {
            m.setUbicacion(new Ubicacion(item(fila, "countryId", "countryName"),
                    item(fila, "provinceId", "provinceName"), item(fila, "cantonId", "cantonName"),
                    distrito, texto(fila, "address")));
        }
        m.setIdCasaCuna(entero(fila, "fosterHomeId"));
        m.setIdPersonaRegistro(fila.getInt("reporterId"));
        m.setNombrePersonaRegistro(texto(fila, "reporterName"));
        m.setMontoRecompensa(decimal(fila, "rewardAmount"));
        m.setMonedaRecompensa(item(fila, "currencyId", "currencyName"));
        m.setNotas(texto(fila, "notesDescription"));
        m.setDescripcionAbandono(texto(fila, "abandonmentNotesDescription"));
        m.setVeterinario(item(fila, "veterinarianId", "veterinarianName"));
        return m;
    }

    /** Enfermedades, fotos y contacto de quien la registró. */
    private void completar(Mascota m) {
        m.setEnfermedades(enfermedades(m.getId()));
        for (Foto foto : fotos(m.getId())) {           // de la más nueva a la más vieja
            if (m.getFotoAntes() == null && empiezaCon(foto.tipo(), FOTO_ANTES)) {
                m.setFotoAntes(foto.enlace());
            }
            if (m.getFotoDespues() == null && empiezaCon(foto.tipo(), FOTO_DESPUES)) {
                m.setFotoDespues(foto.enlace());
            }
        }
        List<String> telefonos = PersonaDAOOracle.telefonos(m.getIdPersonaRegistro());
        List<String> correos = PersonaDAOOracle.correos(m.getIdPersonaRegistro());
        m.setTelefonoContacto(telefonos.isEmpty() ? null : telefonos.get(0));
        m.setCorreoContacto(correos.isEmpty() ? null : correos.get(0));
    }

    private List<ItemCatalogo> enfermedades(int idMascota) {
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_get_pet_diseases(?, ?)}")) {
            cs.setInt(1, idMascota);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            return leerItems(cursor(cs, 2), "name");
        } catch (SQLException e) {
            throw error("consultar las enfermedades de la mascota", e);
        }
    }

    /** Una foto propia de la mascota (no de un seguimiento) con el nombre de su tipo. */
    private record Foto(String tipo, String enlace) {
    }

    private List<Foto> fotos(int idMascota) {
        List<Foto> fotos = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_photos_filtered(?, ?, ?)}")) {
            cs.setInt(1, idMascota);
            cs.setNull(2, Types.NUMERIC);
            cs.registerOutParameter(3, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 3)) {                // ordenadas por id descendente
                while (fila.next()) {
                    if (entero(fila, "followUpId") == null) {
                        fotos.add(new Foto(texto(fila, "photoTypeName"), texto(fila, "photoURL")));
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar las fotos de la mascota", e);
        }
        return fotos;
    }

    // ------------------------------------------------------------------ guardar

    // ------------------------------------------------------------------------
    // ------------------------- Escritura en la base -------------------------
    // ------------------------------------------------------------------------

    /**
     * Parámetros comunes de PR_REGISTER_PET y PR_UPDATE_PET (18 valores, desde pnId_pet_breed
     * hasta pdEvent_date), a partir de la posición indicada.
     */
    private void ponerDatos(CallableStatement cs, int desde, Mascota m) throws SQLException {
        int i = desde;
        ponerId(cs, i++, m.getRaza());
        ponerId(cs, i++, m.getTamano());
        ponerId(cs, i++, m.getColor());
        ponerId(cs, i++, m.getSeveridad());
        ponerId(cs, i++, m.getNivelEnergia());
        ponerId(cs, i++, m.getFacilidadEntrenamiento());
        ponerId(cs, i++, m.getEstado());
        ponerId(cs, i++, m.getVeterinario());
        ponerNumero(cs, i++, m.getIdCasaCuna());
        ponerId(cs, i++, m.getUbicacion() == null ? null : m.getUbicacion().getDistrito());
        ponerTexto(cs, i++, m.getUbicacion() == null ? null : m.getUbicacion().getSenas());
        ponerTexto(cs, i++, m.getChip());
        ponerTexto(cs, i++, m.getNombre());
        ponerBooleano(cs, i++, m.isRequiereEspacio());
        ponerTexto(cs, i++, m.getNotas());
        ponerTexto(cs, i++, m.getDescripcionAbandono());
        ponerNumero(cs, i++, m.getEdadEstimada());
        ponerFecha(cs, i, m.getFechaEvento());
    }

    /** Enfermedades, recompensa y fotos. anterior es null si la mascota es nueva. */
    private void guardarDetalles(Mascota m, Mascota anterior) {
        int id = m.getId();
        List<ItemCatalogo> antes = anterior == null ? List.of() : anterior.getEnfermedades();
        for (ItemCatalogo e : m.getEnfermedades()) {
            if (!antes.contains(e)) {
                llamarConResultado("{call pkg_pet_administration.pr_insert_disease(?, ?, ?)}", id, e.getId(),
                        "agregar la enfermedad " + e.getNombre());
            }
        }
        for (ItemCatalogo e : antes) {
            if (!m.getEnfermedades().contains(e)) {
                // Este procedimiento recibe primero la enfermedad y después la mascota
                llamarConResultado("{call pkg_pet_administration.pr_delete_disease(?, ?, ?)}", e.getId(), id,
                        "quitar la enfermedad " + e.getNombre());
            }
        }

        guardarRecompensa(m, anterior);
        guardarFoto(id, m.getFotoAntes(), anterior == null ? null : anterior.getFotoAntes(), FOTO_ANTES);
        guardarFoto(id, m.getFotoDespues(), anterior == null ? null : anterior.getFotoDespues(), FOTO_DESPUES);
    }

    /**
     * La base guarda un historial de recompensas (se muestra la última). Solo se agrega una si
     * cambió el monto o la moneda; no se puede quitar una ya registrada.
     */
    private void guardarRecompensa(Mascota m, Mascota anterior) {
        BigDecimal montoAnterior = anterior == null ? null : anterior.getMontoRecompensa();
        ItemCatalogo monedaAnterior = anterior == null ? null : anterior.getMonedaRecompensa();
        if (m.getMontoRecompensa() == null) {
            return;                                     // sin recompensa (quitarla se impide en actualizar)
        }
        boolean igual = montoAnterior != null && montoAnterior.compareTo(m.getMontoRecompensa()) == 0
                && Objects.equals(monedaAnterior, m.getMonedaRecompensa());
        if (igual) {
            return;
        }
        try (CallableStatement cs = preparar("{call pkg_pet_administration.pr_insert_reward(?, ?, ?, ?)}")) {
            cs.setInt(1, m.getId());
            ponerId(cs, 2, m.getMonedaRecompensa());
            ponerDecimal(cs, 3, m.getMontoRecompensa());
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            revisar(cs, 4, "registrar la recompensa");
        } catch (SQLException e) {
            throw error("registrar la recompensa", e);
        }
    }

    /** Registra una foto nueva si el enlace cambió (la anterior queda en el historial). */
    private void guardarFoto(int idMascota, String enlace, String enlaceAnterior, String prefijoTipo) {
        if (enlace == null || enlace.equals(enlaceAnterior)) {
            return;
        }
        Integer idTipo = null;
        for (ItemCatalogo tipo : listarItems("{call pkg_catalog.pr_get_photo_types(?)}", "name",
                "consultar los tipos de foto")) {
            if (empiezaCon(tipo.getNombre(), prefijoTipo)) {
                idTipo = tipo.getId();
            }
        }
        if (idTipo == null) {
            throw new IllegalStateException("No existe en la base un tipo de foto que empiece con \"" + prefijoTipo + "\".");
        }
        registrarFoto(idMascota, null, idTipo, enlace);
    }

    /** PKG_ADOPTION_ADMINISTRATION.PR_REGISTER_PHOTO (también la usan los seguimientos). */
    static void registrarFoto(int idMascota, Integer idSeguimiento, int idTipo, String enlace) {
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_register_photo(?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, idMascota);
            ponerNumero(cs, 2, idSeguimiento);
            cs.setInt(3, idTipo);
            ponerTexto(cs, 4, enlace);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.execute();
            revisar(cs, 6, "guardar la foto");
        } catch (SQLException e) {
            throw error("guardar la foto", e);
        }
    }

    /** Procedimientos con (número, número, pnResult). */
    private static void llamarConResultado(String llamada, int primero, int segundo, String operacion) {
        try (CallableStatement cs = preparar(llamada)) {
            cs.setInt(1, primero);
            cs.setInt(2, segundo);
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.execute();
            revisar(cs, 3, operacion);
        } catch (SQLException e) {
            throw error(operacion, e);
        }
    }

    static boolean empiezaCon(String texto, String prefijo) {
        return texto != null && texto.toLowerCase().startsWith(prefijo);
    }
}
