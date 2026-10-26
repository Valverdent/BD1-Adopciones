package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.AdopcionDAO;
import com.mycompany.bd_proyecto1.dao.AsociacionDAO;
import com.mycompany.bd_proyecto1.dao.CasaCunaDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.dao.PersonaDAO;
import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroAdopcion;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.FiltroPersona;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.TratamientoEnfermedad;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.text.Collator;
import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.function.Predicate;

/**
 * Implementación de CatalogoDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class CatalogoDAOMemoria implements CatalogoDAO {

    /** Catálogos que la aplicación usa internamente: no se editan. */
    private static final Set<TipoCatalogo> SOLO_LECTURA =
            EnumSet.of(TipoCatalogo.ESTADO_MASCOTA, TipoCatalogo.MONEDA,
                    TipoCatalogo.VETERINARIO, TipoCatalogo.ESTADO_CASA_CUNA);

    private final Collator ordenEspanol = Collator.getInstance(Locale.forLanguageTag("es"));
    private final MascotaDAO mascotaDAO;
    private final AdopcionDAO adopcionDAO;
    private final CasaCunaDAO casaCunaDAO;
    private final PersonaDAO personaDAO;
    private final AsociacionDAO asociacionDAO;
    /** Catálogos sin padre. */
    private final Map<TipoCatalogo, List<ItemCatalogo>> catalogos = new EnumMap<>(TipoCatalogo.class);
    /** Catálogos con padre: tipo -> (id del padre -> elementos). */
    private final Map<TipoCatalogo, Map<Integer, List<ItemCatalogo>>> hijos = new EnumMap<>(TipoCatalogo.class);

    /** Sin datos de uso: no puede saber si un elemento está en uso (solo pruebas). */
    public CatalogoDAOMemoria() {
        this(null, null, null, null, null);
    }

    /** Sin personas ni asociaciones: los distritos solo cuentan usos en mascotas y casas cuna. */
    public CatalogoDAOMemoria(MascotaDAO mascotaDAO, AdopcionDAO adopcionDAO, CasaCunaDAO casaCunaDAO) {
        this(mascotaDAO, adopcionDAO, casaCunaDAO, null, null);
    }

    public CatalogoDAOMemoria(MascotaDAO mascotaDAO, AdopcionDAO adopcionDAO, CasaCunaDAO casaCunaDAO,
                              PersonaDAO personaDAO, AsociacionDAO asociacionDAO) {
        this.mascotaDAO = mascotaDAO;
        this.adopcionDAO = adopcionDAO;
        this.casaCunaDAO = casaCunaDAO;
        this.personaDAO = personaDAO;
        this.asociacionDAO = asociacionDAO;
        for (TipoCatalogo tipo : TipoCatalogo.values()) {
            if (tipo.tienePadre()) {
                Map<Integer, List<ItemCatalogo>> grupos = new HashMap<>();
                origenHijos(tipo).forEach((idPadre, lista) -> grupos.put(idPadre, new ArrayList<>(lista)));
                hijos.put(tipo, grupos);
            } else {
                catalogos.put(tipo, new ArrayList<>(origen(tipo)));
            }
        }
    }

    // ------------------------------------------------------------------------
    // --------------------------- Datos de origen ----------------------------
    // ------------------------------------------------------------------------

    private List<ItemCatalogo> origen(TipoCatalogo tipo) {
        return switch (tipo) {
            case TIPO_MASCOTA -> DatosPrueba.TIPOS_MASCOTA;
            case COLOR -> DatosPrueba.COLORES;
            case TAMANO -> DatosPrueba.TAMANOS;
            case ESTADO_MASCOTA -> DatosPrueba.ESTADOS_MASCOTA;
            case SEVERIDAD -> DatosPrueba.SEVERIDADES;
            case NIVEL_ENERGIA -> DatosPrueba.NIVELES_ENERGIA;
            case FACILIDAD_ENTRENAMIENTO -> DatosPrueba.FACILIDADES_ENTRENAMIENTO;
            case MONEDA -> DatosPrueba.MONEDAS;
            case ENFERMEDAD -> DatosPrueba.ENFERMEDADES;
            case VETERINARIO -> DatosPrueba.VETERINARIOS;
            case TIPO_VIVIENDA -> DatosPrueba.TIPOS_VIVIENDA;
            case TIEMPO_EJERCICIO -> DatosPrueba.TIEMPOS_EJERCICIO;
            case ESTADO_CASA_CUNA -> DatosPrueba.ESTADOS_CASA_CUNA;
            case PAIS -> DatosPrueba.PAISES;
            default -> List.of();
        };
    }

    private Map<Integer, List<ItemCatalogo>> origenHijos(TipoCatalogo tipo) {
        return switch (tipo) {
            case RAZA -> DatosPrueba.RAZAS_POR_TIPO;
            case PROVINCIA -> DatosPrueba.PROVINCIAS_POR_PAIS;
            case CANTON -> DatosPrueba.CANTONES_POR_PROVINCIA;
            case DISTRITO -> DatosPrueba.DISTRITOS_POR_CANTON;
            default -> Map.of();
        };
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Consulta -------------------------------
    // ------------------------------------------------------------------------

    @Override
    public List<ItemCatalogo> listar(TipoCatalogo tipo) {
        List<ItemCatalogo> lista = new ArrayList<>(elementosDe(tipo));
        if (tipo == TipoCatalogo.VETERINARIO && personaDAO != null) {
            // Personas registradas como veterinarias (id propio para no chocar con los de ejemplo)
            for (ItemCatalogo persona : personaDAO.listar()) {
                if (personaDAO.esVeterinario(persona.getId())) {
                    lista.add(new ItemCatalogo(ID_VETERINARIO_PERSONA + persona.getId(), persona.getNombre()));
                }
            }
        }
        return ordenar(lista);
    }

    /** Base del id de catálogo de una persona registrada como veterinaria (solo en memoria). */
    private static final int ID_VETERINARIO_PERSONA = 1000;

    @Override
    public List<ItemCatalogo> listarHijos(TipoCatalogo tipo, int idPadre) {
        return ordenar(new ArrayList<>(hijosDe(tipo, idPadre)));
    }

    @Override
    public List<TratamientoEnfermedad> listarTratamientos(int idEnfermedad) {
        return DatosPrueba.TRATAMIENTOS_POR_ENFERMEDAD.getOrDefault(idEnfermedad, List.of());
    }

    private List<ItemCatalogo> hijosDe(TipoCatalogo tipo, int idPadre) {
        validarConPadre(tipo);
        return hijos.get(tipo).getOrDefault(idPadre, List.of());
    }

    private List<ItemCatalogo> ordenar(List<ItemCatalogo> lista) {
        lista.sort((a, b) -> ordenEspanol.compare(a.getNombre(), b.getNombre()));
        return lista;
    }

    // ------------------------------------------------------------------------
    // ------------------------------- Cambios --------------------------------
    // ------------------------------------------------------------------------

    @Override
    public int insertar(TipoCatalogo tipo, String nombre) {
        validarEditable(tipo);
        if (tipo.tienePadre()) {
            throw new IllegalArgumentException("El catálogo " + tipo + " necesita un padre: use insertarHijo.");
        }
        List<ItemCatalogo> lista = catalogos.get(tipo);
        int id = siguienteId(lista);
        lista.add(new ItemCatalogo(id, nombre.trim()));
        return id;
    }

    @Override
    public int insertarHijo(TipoCatalogo tipo, int idPadre, String nombre) {
        validarEditable(tipo);
        validarConPadre(tipo);
        buscar(tipo.getPadre(), idPadre);
        int id = siguienteId(elementosDe(tipo));
        hijos.get(tipo).computeIfAbsent(idPadre, k -> new ArrayList<>()).add(new ItemCatalogo(id, nombre.trim()));
        return id;
    }

    @Override
    public void actualizar(TipoCatalogo tipo, int id, String nombre) {
        validarEditable(tipo);
        ItemCatalogo item = buscar(tipo, id);
        item.setNombre(nombre.trim());
    }

    @Override
    public void eliminar(TipoCatalogo tipo, int id) {
        validarEditable(tipo);
        buscar(tipo, id);
        if (contarUsos(tipo, id) > 0) {
            // Mismo mensaje que da la base (código 1102) cuando una llave foránea lo impide
            throw new IllegalArgumentException("No se puede eliminar porque está en uso.");
        }
        if (tipo.tienePadre()) {
            hijos.get(tipo).values().forEach(lista -> lista.removeIf(item -> item.getId() == id));
        } else {
            catalogos.get(tipo).removeIf(item -> item.getId() == id);
        }
    }

    // ------------------------------------------------------------------------
    // ---------------------------- Conteo de usos ----------------------------
    // ------------------------------------------------------------------------

    /** Cuántos registros usan el elemento (en la base lo impiden las llaves foráneas). */
    int contarUsos(TipoCatalogo tipo, int id) {
        validarEditable(tipo);
        long usos = switch (tipo) {
            case TIPO_MASCOTA -> mascotasCon(m -> mismo(m.getTipo(), id)) + cantidadHijos(TipoCatalogo.RAZA, id)
                    + casasCuna().stream().mapToLong(c -> contar(c.getTipos(), id)).sum();
            case RAZA -> mascotasCon(m -> mismo(m.getRaza(), id))
                    + adopciones().stream().mapToLong(a -> contar(a.getOtrasMascotas(), id)).sum();
            case COLOR -> mascotasCon(m -> mismo(m.getColor(), id));
            case TAMANO -> mascotasCon(m -> mismo(m.getTamano(), id))
                    + casasCuna().stream().mapToLong(c -> contar(c.getTamanos(), id)).sum();
            case SEVERIDAD -> mascotasCon(m -> mismo(m.getSeveridad(), id));
            case NIVEL_ENERGIA -> mascotasCon(m -> mismo(m.getNivelEnergia(), id));
            case FACILIDAD_ENTRENAMIENTO -> mascotasCon(m -> mismo(m.getFacilidadEntrenamiento(), id));
            case ENFERMEDAD -> mascotasCon(m -> contar(m.getEnfermedades(), id) > 0)
                    + DatosPrueba.TRATAMIENTOS_POR_ENFERMEDAD.getOrDefault(id, List.of()).size();
            case TIPO_VIVIENDA -> adopcionesCon(a -> mismo(a.getTipoVivienda(), id));
            case TIEMPO_EJERCICIO -> adopcionesCon(a -> mismo(a.getTiempoEjercicio(), id));
            case PAIS -> cantidadHijos(TipoCatalogo.PROVINCIA, id);
            case PROVINCIA -> cantidadHijos(TipoCatalogo.CANTON, id);
            case CANTON -> cantidadHijos(TipoCatalogo.DISTRITO, id);
            case DISTRITO -> registrosEnDistrito(id);
            default -> throw new IllegalArgumentException("No se calculan usos para el catálogo " + tipo + ".");
        };
        return (int) usos;
    }

    /** Mascotas, personas, casas cuna y asociaciones ubicadas en el distrito. */
    private long registrosEnDistrito(int idDistrito) {
        long total = mascotasCon(m -> enDistrito(m.getUbicacion(), idDistrito));
        total += casasCuna().stream().filter(c -> enDistrito(c.getUbicacion(), idDistrito)).count();
        if (personaDAO != null) {
            for (Persona p : personaDAO.consultar(new FiltroPersona())) {
                if (enDistrito(p.getUbicacion(), idDistrito)) {
                    total++;
                }
            }
        }
        if (asociacionDAO != null) {
            for (AsociacionBienestar a : asociacionDAO.listar()) {
                if (enDistrito(a.getUbicacion(), idDistrito)) {
                    total++;
                }
            }
        }
        return total;
    }

    private static boolean enDistrito(Ubicacion u, int idDistrito) {
        return u != null && mismo(u.getDistrito(), idDistrito);
    }

    private long cantidadHijos(TipoCatalogo tipo, int idPadre) {
        return hijos.get(tipo).getOrDefault(idPadre, List.of()).size();
    }

    private long mascotasCon(Predicate<Mascota> condicion) {
        if (mascotaDAO == null) {
            return 0;
        }
        return mascotaDAO.consultar(new FiltroMascota()).stream().filter(condicion).count();
    }

    private long adopcionesCon(Predicate<Adopcion> condicion) {
        return adopciones().stream().filter(condicion).count();
    }

    private List<Adopcion> adopciones() {
        return adopcionDAO == null ? List.of() : adopcionDAO.consultar(new FiltroAdopcion());
    }

    private List<CasaCuna> casasCuna() {
        return casaCunaDAO == null ? List.of() : casaCunaDAO.consultar(new FiltroCasaCuna());
    }

    private static boolean mismo(ItemCatalogo valor, int id) {
        return valor != null && valor.getId() == id;
    }

    private static long contar(List<ItemCatalogo> lista, int id) {
        return lista.stream().filter(item -> mismo(item, id)).count();
    }

    // ------------------------------------------------------------------------
    // ---------------------- Validaciones y auxiliares -----------------------
    // ------------------------------------------------------------------------

    private void validarEditable(TipoCatalogo tipo) {
        if (tipo == null || SOLO_LECTURA.contains(tipo)) {
            throw new IllegalArgumentException("El catálogo " + tipo + " es de solo lectura.");
        }
    }

    private void validarConPadre(TipoCatalogo tipo) {
        if (tipo == null || !tipo.tienePadre()) {
            throw new IllegalArgumentException("El catálogo " + tipo + " no depende de otro catálogo.");
        }
    }

    private ItemCatalogo buscar(TipoCatalogo tipo, int id) {
        for (ItemCatalogo item : elementosDe(tipo)) {
            if (item.getId() == id) {
                return item;
            }
        }
        throw new IllegalStateException("No existe el elemento " + id + " en " + tipo + ".");
    }

    /** Todos los elementos de un catálogo (de todos los padres si tiene padre). */
    private List<ItemCatalogo> elementosDe(TipoCatalogo tipo) {
        if (!tipo.tienePadre()) {
            return catalogos.get(tipo);
        }
        List<ItemCatalogo> todos = new ArrayList<>();
        hijos.get(tipo).values().forEach(todos::addAll);
        return todos;
    }

    private static int siguienteId(Collection<ItemCatalogo> items) {
        int mayor = 0;
        for (ItemCatalogo item : items) {
            mayor = Math.max(mayor, item.getId());
        }
        return mayor + 1;
    }
}
