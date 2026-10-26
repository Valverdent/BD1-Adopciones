package com.mycompany.bd_proyecto1.dao.oracle;

import static com.mycompany.bd_proyecto1.dao.oracle.UtilOracle.*;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.FiltroAdoptante;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.ResumenAdoptante;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.Collator;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Implementación de AdopcionDAO con Oracle (paquetes PKG_ADOPTION_ADMINISTRATION y
 * PKG_PERSON_ADMINISTRATION).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AdopcionDAOOracle implements AdopcionDAO {

    /** Comienzo del nombre de los tipos de foto (tabla PhotoType). */
    static final String FOTO_ADOPTANTE = "adoptante";
    static final String FOTO_NUEVA_VIDA = "nueva";

    private final MascotaDAOOracle mascotas = new MascotaDAOOracle();
    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Adopcion> consultar(FiltroAdopcion f) {
        List<Adopcion> resultado = new ArrayList<>();
        for (Adopcion a : todas()) {
            Mascota m = a.getMascota();
            boolean cumple = (f.getTipoMascota() == null || f.getTipoMascota().equals(m.getTipo()))
                    && PersonaDAOOracle.contiene(m.getNombre(), f.getNombreMascota())
                    && PersonaDAOOracle.contiene(a.getAdoptante().getNombre(), f.getAdoptante())
                    && PersonaDAOOracle.contiene(a.getNombrePersonaEntrega(), f.getEntregadoPor())
                    && dentroDelRango(a.getFechaAdopcion(), f.getFechaDesde(), f.getFechaHasta());
            if (cumple) {
                resultado.add(a);
            }
        }
        return resultado;
    }

    @Override
    public List<Mascota> listarMascotasDisponibles() {
        // En adopción y sin adopción registrada: el reporte de sin adoptar con 0 meses
        List<Mascota> disponibles = new ArrayList<>(mascotas.listarSinAdoptar(0, null));
        disponibles.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return disponibles;
    }

    // ------------------------------------------------------------------------
    // -------------------------- Registro y edición --------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(Adopcion a) {
        int idAdoptante = a.getAdoptante().getId();
        // 1. Perfil del adoptante (solo la primera vez que adopta)
        if (!esAdoptante(idAdoptante)) {
            try (CallableStatement cs = preparar("{call pkg_person_administration.pr_register_adopter(?, ?, ?, ?, ?, ?)}")) {
                cs.setInt(1, idAdoptante);
                ponerId(cs, 2, a.getTipoVivienda());
                ponerBooleano(cs, 3, a.isTienePatio());
                ponerId(cs, 4, a.getTiempoEjercicio());
                ponerTexto(cs, 5, a.getOtrasMascotas().stream().map(r -> String.valueOf(r.getId()))
                        .collect(Collectors.joining(",")));
                cs.registerOutParameter(6, Types.NUMERIC);
                cs.execute();
                revisar(cs, 6, "registrar el perfil del adoptante");
            } catch (SQLException e) {
                throw error("registrar el perfil del adoptante", e);
            }
        }
        // 2. Adopción (la mascota pasa a "Adoptada")
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_register_adoption(?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, a.getIdPersonaEntrega());
            cs.setInt(2, idAdoptante);
            cs.setInt(3, a.getMascota().getId());
            ponerFecha(cs, 4, a.getFechaAdopcion());
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.execute();
            revisar(cs, 6, "registrar la adopción");
            a.setId(cs.getInt(5));
        } catch (SQLException e) {
            throw error("registrar la adopción", e);
        }
        // 3. Calificación y foto (opcionales)
        guardarCalificacionYFoto(a, null, null);
        return a.getId();
    }

    @Override
    public void actualizar(Adopcion a) {
        Adopcion actual = todas().stream().filter(x -> x.getId() == a.getId()).findFirst()
                .orElseThrow(() -> new IllegalStateException("No existe la adopción con id " + a.getId()));
        if (actual.getCalificacion() != null && !Objects.equals(actual.getCalificacion(), a.getCalificacion())) {
            throw new IllegalArgumentException("La calificación ya se registró y no se puede cambiar.");
        }
        // La fecha y las respuestas del formulario no se pueden cambiar en la base
        guardarCalificacionYFoto(a, actual.getCalificacion(), actual.getFotoAdoptante());
    }

    // ------------------------------------------------------------------------
    // ----------------------------- Seguimientos -----------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<SeguimientoAdopcion> listarSeguimientos(int idAdopcion) {
        // Un seguimiento puede tener varias fotos (una fila por foto): se toma la primera
        Map<Integer, SeguimientoAdopcion> porId = new LinkedHashMap<>();
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_follow_ups(?, ?)}")) {
            cs.setInt(1, idAdopcion);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    int id = fila.getInt("id");
                    if (!porId.containsKey(id)) {
                        SeguimientoAdopcion s = new SeguimientoAdopcion();
                        s.setId(id);
                        s.setIdAdopcion(idAdopcion);
                        s.setFecha(fecha(fila, "followUpDate"));
                        s.setComentarios(texto(fila, "comments"));
                        s.setFoto(texto(fila, "photoURL"));
                        porId.put(id, s);
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar los seguimientos", e);
        }
        return new ArrayList<>(porId.values());
    }

    @Override
    public int insertarSeguimiento(SeguimientoAdopcion s) {
        try (CallableStatement cs = preparar(
                "{call pkg_adoption_administration.pr_register_follow_up(?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setInt(1, s.getIdAdopcion());
            ponerFecha(cs, 2, s.getFecha());
            ponerTexto(cs, 3, s.getComentarios());
            cs.setInt(4, tipoDeFoto(FOTO_NUEVA_VIDA));
            ponerTexto(cs, 5, s.getFoto());
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.registerOutParameter(7, Types.NUMERIC);
            cs.execute();
            revisar(cs, 7, "registrar el seguimiento");
            s.setId(cs.getInt(6));
            return s.getId();
        } catch (SQLException e) {
            throw error("registrar el seguimiento", e);
        }
    }

    // ------------------------------------------------------------------------
    // ---------------------------- Por adoptante -----------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<Adopcion> listarAdopcionesDeAdoptante(int idPersona) {
        return todas().stream().filter(a -> a.getAdoptante().getId() == idPersona).toList();
    }

    @Override
    public List<ResumenAdoptante> consultarPorAdoptante(FiltroAdoptante filtro) {
        Map<Integer, List<Adopcion>> porAdoptante = new LinkedHashMap<>();
        for (Adopcion a : todas()) {
            if (dentroDelRango(a.getFechaAdopcion(), filtro.getFechaDesde(), filtro.getFechaHasta())
                    && PersonaDAOOracle.contiene(a.getAdoptante().getNombre(), filtro.getNombre())) {
                porAdoptante.computeIfAbsent(a.getAdoptante().getId(), k -> new ArrayList<>()).add(a);
            }
        }
        List<ResumenAdoptante> resultado = new ArrayList<>();
        for (List<Adopcion> adopciones : porAdoptante.values()) {
            ResumenAdoptante r = new ResumenAdoptante();
            r.setIdPersona(adopciones.get(0).getAdoptante().getId());
            r.setNombrePersona(adopciones.get(0).getAdoptante().getNombre());
            r.setCantidadAdopciones(adopciones.size());
            r.setUltimaAdopcion(adopciones.stream().map(Adopcion::getFechaAdopcion)
                    .max(Comparator.naturalOrder()).orElse(null));
            List<Integer> calificaciones = adopciones.stream().map(Adopcion::getCalificacion)
                    .filter(Objects::nonNull).toList();
            if (!calificaciones.isEmpty()) {
                int suma = calificaciones.stream().mapToInt(Integer::intValue).sum();
                r.setCalificacionPromedio(BigDecimal.valueOf(suma)
                        .divide(BigDecimal.valueOf(calificaciones.size()), 2, RoundingMode.HALF_UP));
            }
            resultado.add(r);
        }
        resultado.sort(Comparator.comparingInt(ResumenAdoptante::getCantidadAdopciones).reversed());
        return resultado;
    }

    // ------------------------------------------------------------------------
    // ------------------------------ Auxiliares ------------------------------
    // ------------------------------------------------------------------------

    /** Ids de las mascotas que ya tienen una adopción (también los usa el DAO de mascotas). */
    static Set<Integer> idsMascotasAdoptadas() {
        Set<Integer> ids = new HashSet<>();
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_adoptions(?, ?)}")) {
            cs.setNull(1, Types.NUMERIC);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    ids.add(fila.getInt("petId"));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las adopciones", e);
        }
        return ids;
    }

    // ------------------------------------------------------------------ consulta

    /** Todas las adopciones con todos sus datos, de la más reciente a la más antigua. */
    private List<Adopcion> todas() {
        List<Adopcion> adopciones = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_adoptions(?, ?)}")) {
            cs.setNull(1, Types.NUMERIC);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    Adopcion a = new Adopcion();
                    a.setId(fila.getInt("adoptionId"));
                    a.setFechaAdopcion(fecha(fila, "adoptionDate"));
                    a.setIdPersonaEntrega(fila.getInt("givenById"));
                    a.setNombrePersonaEntrega(texto(fila, "givenByName"));
                    a.setAdoptante(new ItemCatalogo(fila.getInt("adopterId"), texto(fila, "adopterName")));
                    // Datos mínimos de la mascota; se completan después
                    Mascota m = new Mascota();
                    m.setId(fila.getInt("petId"));
                    m.setNombre(texto(fila, "petName"));
                    a.setMascota(m);
                    adopciones.add(a);
                }
            }
        } catch (SQLException e) {
            throw error("consultar las adopciones", e);
        }
        Map<Integer, Mascota> cacheMascotas = new HashMap<>();
        for (Adopcion a : adopciones) {
            completar(a, cacheMascotas);
        }
        return adopciones;
    }

    /** Mascota completa, perfil del adoptante, calificación, foto y cantidad de seguimientos. */
    private void completar(Adopcion a, Map<Integer, Mascota> cacheMascotas) {
        Mascota completa = cacheMascotas.computeIfAbsent(a.getMascota().getId(), mascotas::buscar);
        if (completa != null) {
            a.setMascota(completa);
        }
        // Perfil del adoptante
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_adopter(?, ?)}")) {
            cs.setInt(1, a.getAdoptante().getId());
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                if (fila.next()) {
                    a.setTipoVivienda(item(fila, "idHouseType", "houseTypeName"));
                    a.setTienePatio(booleano(fila, "hasYard"));
                    a.setTiempoEjercicio(item(fila, "idExerciseTime", "exerciseTimeValue"));
                }
            }
        } catch (SQLException e) {
            throw error("consultar el perfil del adoptante", e);
        }
        a.setOtrasMascotas(otrasMascotas(a.getAdoptante().getId()));
        // Calificación
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_adoption_rating(?, ?)}")) {
            cs.setInt(1, a.getId());
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                if (fila.next()) {
                    a.setCalificacion(fila.getInt("rating"));
                    a.setNotasCalificacion(texto(fila, "notes"));
                }
            }
        } catch (SQLException e) {
            throw error("consultar la calificación", e);
        }
        a.setFotoAdoptante(ultimaFotoDeTipo(a.getMascota().getId(), FOTO_ADOPTANTE));
        a.setCantidadSeguimientos(listarSeguimientos(a.getId()).size());
    }

    /** Otras mascotas del adoptante; el id es el de la fila OtherPet y el nombre, la raza. */
    private List<ItemCatalogo> otrasMascotas(int idAdoptante) {
        List<ItemCatalogo> otras = new ArrayList<>();
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_other_pets(?, ?)}")) {
            cs.setInt(1, idAdoptante);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                while (fila.next()) {
                    otras.add(new ItemCatalogo(fila.getInt("id"), texto(fila, "breedName")));
                }
            }
        } catch (SQLException e) {
            throw error("consultar las otras mascotas del adoptante", e);
        }
        return otras;
    }

    private boolean esAdoptante(int idPersona) {
        try (CallableStatement cs = preparar("{call pkg_person_administration.pr_get_adopter(?, ?)}")) {
            cs.setInt(1, idPersona);
            cs.registerOutParameter(2, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 2)) {
                return fila.next();
            }
        } catch (SQLException e) {
            throw error("consultar el perfil del adoptante", e);
        }
    }

    /** Enlace de la foto más reciente de la mascota cuyo tipo empieza con el prefijo (sin seguimiento). */
    private static String ultimaFotoDeTipo(int idMascota, String prefijoTipo) {
        try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_get_photos_filtered(?, ?, ?)}")) {
            cs.setInt(1, idMascota);
            cs.setNull(2, Types.NUMERIC);
            cs.registerOutParameter(3, CURSOR);
            cs.execute();
            try (ResultSet fila = cursor(cs, 3)) {                // por id descendente
                while (fila.next()) {
                    if (entero(fila, "followUpId") == null
                            && MascotaDAOOracle.empiezaCon(texto(fila, "photoTypeName"), prefijoTipo)) {
                        return texto(fila, "photoURL");
                    }
                }
            }
        } catch (SQLException e) {
            throw error("consultar las fotos de la mascota", e);
        }
        return null;
    }

    // ------------------------------------------------------------------ guardar

    private void guardarCalificacionYFoto(Adopcion a, Integer calificacionAnterior, String fotoAnterior) {
        if (a.getCalificacion() != null && calificacionAnterior == null) {
            try (CallableStatement cs = preparar("{call pkg_adoption_administration.pr_register_rating(?, ?, ?, ?, ?)}")) {
                cs.setInt(1, a.getId());
                cs.setInt(2, a.getCalificacion());
                ponerTexto(cs, 3, a.getNotasCalificacion());
                cs.registerOutParameter(4, Types.NUMERIC);
                cs.registerOutParameter(5, Types.NUMERIC);
                cs.execute();
                revisar(cs, 5, "registrar la calificación");
            } catch (SQLException e) {
                throw error("registrar la calificación", e);
            }
        }
        String foto = a.getFotoAdoptante();
        if (foto != null && !foto.equals(fotoAnterior)) {
            MascotaDAOOracle.registrarFoto(a.getMascota().getId(), null, tipoDeFoto(FOTO_ADOPTANTE), foto);
        }
    }

    /** Id del tipo de foto cuyo nombre empieza con el prefijo. */
    private static int tipoDeFoto(String prefijo) {
        for (ItemCatalogo tipo : listarItems("{call pkg_catalog.pr_get_photo_types(?)}", "name",
                "consultar los tipos de foto")) {
            if (MascotaDAOOracle.empiezaCon(tipo.getNombre(), prefijo)) {
                return tipo.getId();
            }
        }
        throw new IllegalStateException("No existe en la base un tipo de foto que empiece con \"" + prefijo + "\".");
    }

    private static boolean dentroDelRango(LocalDate fecha, LocalDate desde, LocalDate hasta) {
        if (fecha == null) {
            return desde == null && hasta == null;
        }
        if (desde != null && fecha.isBefore(desde)) {
            return false;
        }
        return hasta == null || !fecha.isAfter(hasta);
    }
}
