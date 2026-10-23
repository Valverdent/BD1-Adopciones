package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.model.Adopcion;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.DetalleDonacion;
import com.mycompany.bd_proyecto1.model.Donacion;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.model.MedicamentoTratamiento;
import com.mycompany.bd_proyecto1.model.Parametro;
import com.mycompany.bd_proyecto1.model.Persona;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import com.mycompany.bd_proyecto1.model.ReporteListaNegra;
import com.mycompany.bd_proyecto1.model.SeguimientoAdopcion;
import com.mycompany.bd_proyecto1.model.TipoDonacion;
import com.mycompany.bd_proyecto1.model.TratamientoEnfermedad;
import com.mycompany.bd_proyecto1.model.Ubicacion;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * DATOS DE PRUEBA compartidos por los DAO en memoria. Solo para desarrollo.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public final class DatosPrueba {

    // Personas asociadas a los usuarios de prueba (ver UsuarioDAOMemoria)
    public static final int PERSONA_ADMIN = 1;
    public static final int PERSONA_USUARIO = 2;
    public static final int PERSONA_USUARIO2 = 3;

    // ------------------------------------------------------------------------
    // ------------------------------ Catálogos -------------------------------
    // ------------------------------------------------------------------------
    public static final ItemCatalogo PERRO = new ItemCatalogo(1, "Perro");
    public static final ItemCatalogo GATO = new ItemCatalogo(2, "Gato");
    public static final ItemCatalogo OTRO = new ItemCatalogo(3, "Otro");
    public static final List<ItemCatalogo> TIPOS_MASCOTA = List.of(PERRO, GATO, OTRO);

    public static final ItemCatalogo ZAGUATE = new ItemCatalogo(1, "Zaguate (mestizo)");
    public static final ItemCatalogo LABRADOR = new ItemCatalogo(2, "Labrador");
    public static final ItemCatalogo PASTOR_ALEMAN = new ItemCatalogo(3, "Pastor alemán");
    public static final ItemCatalogo CHIHUAHUA = new ItemCatalogo(4, "Chihuahua");
    public static final ItemCatalogo POODLE = new ItemCatalogo(5, "Poodle");
    public static final ItemCatalogo CRIOLLO = new ItemCatalogo(6, "Criollo (mestizo)");
    public static final ItemCatalogo SIAMES = new ItemCatalogo(7, "Siamés");
    public static final ItemCatalogo PERSA = new ItemCatalogo(8, "Persa");
    public static final ItemCatalogo RAZA_UNICA = new ItemCatalogo(9, "Raza única");
    public static final Map<Integer, List<ItemCatalogo>> RAZAS_POR_TIPO = Map.of(
            PERRO.getId(), List.of(ZAGUATE, LABRADOR, PASTOR_ALEMAN, CHIHUAHUA, POODLE),
            GATO.getId(), List.of(CRIOLLO, SIAMES, PERSA),
            OTRO.getId(), List.of(RAZA_UNICA)
    );

    public static final ItemCatalogo NEGRO = new ItemCatalogo(1, "Negro");
    public static final ItemCatalogo BLANCO = new ItemCatalogo(2, "Blanco");
    public static final ItemCatalogo CAFE = new ItemCatalogo(3, "Café");
    public static final ItemCatalogo GRIS = new ItemCatalogo(4, "Gris");
    public static final ItemCatalogo ATIGRADO = new ItemCatalogo(5, "Atigrado");
    public static final ItemCatalogo MANCHADO = new ItemCatalogo(6, "Manchado");
    public static final List<ItemCatalogo> COLORES = List.of(NEGRO, BLANCO, CAFE, GRIS, ATIGRADO, MANCHADO);

    public static final ItemCatalogo PEQUENO = new ItemCatalogo(1, "Pequeño");
    public static final ItemCatalogo MEDIANO = new ItemCatalogo(2, "Mediano");
    public static final ItemCatalogo GRANDE = new ItemCatalogo(3, "Grande");
    public static final List<ItemCatalogo> TAMANOS = List.of(PEQUENO, MEDIANO, GRANDE);

    // Decisión P04: estos son los únicos estados de mascota.
    public static final ItemCatalogo PERDIDA = new ItemCatalogo(1, "Perdida");
    public static final ItemCatalogo ENCONTRADA = new ItemCatalogo(2, "Encontrada");
    public static final ItemCatalogo EN_ADOPCION = new ItemCatalogo(3, "En adopción");
    public static final ItemCatalogo ADOPTADA = new ItemCatalogo(4, "Adoptada");
    public static final List<ItemCatalogo> ESTADOS_MASCOTA = List.of(PERDIDA, ENCONTRADA, EN_ADOPCION, ADOPTADA);

    public static final ItemCatalogo CRITICO = new ItemCatalogo(1, "Crítico");
    public static final ItemCatalogo MAL_ESTADO = new ItemCatalogo(2, "Mal estado");
    public static final ItemCatalogo BUEN_ESTADO = new ItemCatalogo(3, "Buen estado");
    public static final List<ItemCatalogo> SEVERIDADES = List.of(CRITICO, MAL_ESTADO, BUEN_ESTADO);

    public static final ItemCatalogo ATLETICO = new ItemCatalogo(1, "Atlético");
    public static final ItemCatalogo CORREDOR = new ItemCatalogo(2, "Corredor");
    public static final ItemCatalogo CAMINADOR = new ItemCatalogo(3, "Caminador");
    public static final ItemCatalogo PARA_VER_TV = new ItemCatalogo(4, "Para ver TV");
    public static final ItemCatalogo ENERGIA_NO_IMPORTA = new ItemCatalogo(5, "No es importante");
    public static final List<ItemCatalogo> NIVELES_ENERGIA =
            List.of(ATLETICO, CORREDOR, CAMINADOR, PARA_VER_TV, ENERGIA_NO_IMPORTA);

    public static final ItemCatalogo FACIL = new ItemCatalogo(1, "Fácil");
    public static final ItemCatalogo MODERADA = new ItemCatalogo(2, "Moderada");
    public static final ItemCatalogo DIFICIL = new ItemCatalogo(3, "Difícil");
    public static final List<ItemCatalogo> FACILIDADES_ENTRENAMIENTO = List.of(FACIL, MODERADA, DIFICIL);

    public static final ItemCatalogo COLONES = new ItemCatalogo(1, "Colones (₡)");
    public static final ItemCatalogo DOLARES = new ItemCatalogo(2, "Dólares ($)");
    public static final List<ItemCatalogo> MONEDAS = List.of(COLONES, DOLARES);

    // Salud: enfermedades, tratamientos (por enfermedad) y medicamentos (por tratamiento).
    // Valores de ejemplo para probar la aplicación; no son indicaciones veterinarias.
    public static final ItemCatalogo SARNA = new ItemCatalogo(1, "Sarna");
    public static final ItemCatalogo MOQUILLO = new ItemCatalogo(2, "Moquillo");
    public static final ItemCatalogo PARVOVIRUS = new ItemCatalogo(3, "Parvovirus");
    public static final ItemCatalogo EHRLICHIOSIS = new ItemCatalogo(4, "Ehrlichiosis (garrapata)");
    public static final ItemCatalogo DESNUTRICION = new ItemCatalogo(5, "Desnutrición");
    public static final List<ItemCatalogo> ENFERMEDADES =
            List.of(SARNA, MOQUILLO, PARVOVIRUS, EHRLICHIOSIS, DESNUTRICION);

    private static final ItemCatalogo BANOS_MEDICADOS = new ItemCatalogo(1, "Baños medicados");
    private static final ItemCatalogo DESPARASITACION = new ItemCatalogo(2, "Desparasitación");
    private static final ItemCatalogo TRATAMIENTO_SOPORTE = new ItemCatalogo(3, "Tratamiento de soporte");
    private static final ItemCatalogo HIDRATACION = new ItemCatalogo(4, "Hidratación");
    private static final ItemCatalogo ANTIBIOTICO = new ItemCatalogo(5, "Antibioticoterapia");
    private static final ItemCatalogo DIETA = new ItemCatalogo(6, "Dieta de recuperación");

    private static final ItemCatalogo CHAMPU = new ItemCatalogo(1, "Champú medicado");
    private static final ItemCatalogo ANTIPARASITARIO = new ItemCatalogo(2, "Antiparasitario");
    private static final ItemCatalogo ANTIBIOTICO_ORAL = new ItemCatalogo(3, "Antibiótico oral");
    private static final ItemCatalogo SUERO_ORAL = new ItemCatalogo(4, "Suero oral");
    private static final ItemCatalogo SUPLEMENTO = new ItemCatalogo(5, "Suplemento vitamínico");

    public static final Map<Integer, List<TratamientoEnfermedad>> TRATAMIENTOS_POR_ENFERMEDAD = Map.of(
            SARNA.getId(), List.of(
                    new TratamientoEnfermedad(BANOS_MEDICADOS, "4 semanas",
                            List.of(new MedicamentoTratamiento(CHAMPU, "2 baños por semana"))),
                    new TratamientoEnfermedad(DESPARASITACION, "1 semana",
                            List.of(new MedicamentoTratamiento(ANTIPARASITARIO, "1 vez al día")))),
            MOQUILLO.getId(), List.of(
                    new TratamientoEnfermedad(TRATAMIENTO_SOPORTE, "2 semanas",
                            List.of(new MedicamentoTratamiento(ANTIBIOTICO_ORAL, "Cada 12 horas"),
                                    new MedicamentoTratamiento(SUPLEMENTO, "1 vez al día")))),
            PARVOVIRUS.getId(), List.of(
                    new TratamientoEnfermedad(HIDRATACION, "1 semana",
                            List.of(new MedicamentoTratamiento(SUERO_ORAL, "Cada 8 horas")))),
            EHRLICHIOSIS.getId(), List.of(
                    new TratamientoEnfermedad(ANTIBIOTICO, "4 semanas",
                            List.of(new MedicamentoTratamiento(ANTIBIOTICO_ORAL, "1 vez al día")))),
            DESNUTRICION.getId(), List.of(
                    new TratamientoEnfermedad(DIETA, "6 semanas",
                            List.of(new MedicamentoTratamiento(SUPLEMENTO, "1 vez al día"))))
    );

    // Veterinarios registrados (personas de ejemplo)
    public static final ItemCatalogo VET_ROJAS = new ItemCatalogo(1, "Ana Rojas (Clínica Veterinaria San José)");
    public static final ItemCatalogo VET_MORA = new ItemCatalogo(2, "Luis Mora (Clínica Veterinaria del Caribe)");
    public static final ItemCatalogo VET_VARGAS = new ItemCatalogo(3, "Sofía Vargas (Veterinaria Heredia)");
    public static final List<ItemCatalogo> VETERINARIOS = List.of(VET_ROJAS, VET_MORA, VET_VARGAS);

    // Formulario de adopción (4.o)
    public static final ItemCatalogo CASA = new ItemCatalogo(1, "Casa");
    public static final ItemCatalogo APARTAMENTO = new ItemCatalogo(2, "Apartamento");
    public static final ItemCatalogo CONDOMINIO = new ItemCatalogo(3, "Condominio");
    public static final ItemCatalogo FINCA = new ItemCatalogo(4, "Finca");
    public static final List<ItemCatalogo> TIPOS_VIVIENDA = List.of(CASA, APARTAMENTO, CONDOMINIO, FINCA);

    public static final ItemCatalogo EJERCICIO_POCO = new ItemCatalogo(1, "Menos de 30 minutos al día");
    public static final ItemCatalogo EJERCICIO_MEDIO = new ItemCatalogo(2, "De 30 a 60 minutos al día");
    public static final ItemCatalogo EJERCICIO_MUCHO = new ItemCatalogo(3, "Más de una hora al día");
    public static final List<ItemCatalogo> TIEMPOS_EJERCICIO = List.of(EJERCICIO_POCO, EJERCICIO_MEDIO, EJERCICIO_MUCHO);

    // ------------------------------------------------------------------------
    // ------------------------------- Personas -------------------------------
    // ------------------------------------------------------------------------
    // Las tres primeras son las de los usuarios de prueba; las demás son adoptantes de ejemplo.
    public static final int PERSONA_MARIA = 4;
    public static final int PERSONA_JORGE = 5;
    public static final List<ItemCatalogo> PERSONAS = List.of(
            new ItemCatalogo(PERSONA_ADMIN, "Administrador de prueba"),
            new ItemCatalogo(PERSONA_USUARIO, "Usuario de prueba"),
            new ItemCatalogo(PERSONA_USUARIO2, "Segundo usuario de prueba"),
            new ItemCatalogo(PERSONA_MARIA, "María Jiménez Solano"),
            new ItemCatalogo(PERSONA_JORGE, "Jorge Castro Rojas"),
            new ItemCatalogo(6, "Daniela Quesada Mora"));

    // Estados de una casa cuna
    public static final ItemCatalogo ESTADO_CASA_DISPONIBLE = new ItemCatalogo(1, "Disponible");
    public static final ItemCatalogo ESTADO_CASA_OCUPADA = new ItemCatalogo(2, "Ocupada");
    public static final ItemCatalogo ESTADO_CASA_INACTIVA = new ItemCatalogo(3, "Inactiva");
    public static final List<ItemCatalogo> ESTADOS_CASA_CUNA =
            List.of(ESTADO_CASA_DISPONIBLE, ESTADO_CASA_OCUPADA, ESTADO_CASA_INACTIVA);

    // ------------------------------------------------------------------------
    // ------------ Lugares: país > provincia > cantón > distrito -------------
    // ------------------------------------------------------------------------
    // Nombres reales. Panamá se incluye para probar que hay varios países.
    public static final ItemCatalogo COSTA_RICA = new ItemCatalogo(1, "Costa Rica");
    public static final ItemCatalogo PANAMA = new ItemCatalogo(2, "Panamá");
    public static final List<ItemCatalogo> PAISES = List.of(COSTA_RICA, PANAMA);

    public static final ItemCatalogo P_SAN_JOSE = new ItemCatalogo(1, "San José");
    public static final ItemCatalogo P_ALAJUELA = new ItemCatalogo(2, "Alajuela");
    public static final ItemCatalogo P_CARTAGO = new ItemCatalogo(3, "Cartago");
    public static final ItemCatalogo P_HEREDIA = new ItemCatalogo(4, "Heredia");
    public static final ItemCatalogo P_GUANACASTE = new ItemCatalogo(5, "Guanacaste");
    public static final ItemCatalogo P_PUNTARENAS = new ItemCatalogo(6, "Puntarenas");
    public static final ItemCatalogo P_LIMON = new ItemCatalogo(7, "Limón");
    public static final ItemCatalogo P_PANAMA = new ItemCatalogo(8, "Panamá");
    public static final ItemCatalogo P_CHIRIQUI = new ItemCatalogo(9, "Chiriquí");
    public static final Map<Integer, List<ItemCatalogo>> PROVINCIAS_POR_PAIS = Map.of(
            COSTA_RICA.getId(), List.of(P_SAN_JOSE, P_ALAJUELA, P_CARTAGO, P_HEREDIA, P_GUANACASTE,
                    P_PUNTARENAS, P_LIMON),
            PANAMA.getId(), List.of(P_PANAMA, P_CHIRIQUI));

    public static final ItemCatalogo C_SAN_JOSE = new ItemCatalogo(1, "San José");
    public static final ItemCatalogo C_ESCAZU = new ItemCatalogo(2, "Escazú");
    public static final ItemCatalogo C_CURRIDABAT = new ItemCatalogo(3, "Curridabat");
    public static final ItemCatalogo C_ALAJUELA = new ItemCatalogo(4, "Alajuela");
    public static final ItemCatalogo C_GRECIA = new ItemCatalogo(5, "Grecia");
    public static final ItemCatalogo C_CARTAGO = new ItemCatalogo(6, "Cartago");
    public static final ItemCatalogo C_PARAISO = new ItemCatalogo(7, "Paraíso");
    public static final ItemCatalogo C_HEREDIA = new ItemCatalogo(8, "Heredia");
    public static final ItemCatalogo C_SANTO_DOMINGO = new ItemCatalogo(9, "Santo Domingo");
    public static final ItemCatalogo C_LIBERIA = new ItemCatalogo(10, "Liberia");
    public static final ItemCatalogo C_ESPARZA = new ItemCatalogo(11, "Esparza");
    public static final ItemCatalogo C_PUNTARENAS = new ItemCatalogo(12, "Puntarenas");
    public static final ItemCatalogo C_LIMON = new ItemCatalogo(13, "Limón");
    public static final ItemCatalogo C_PANAMA = new ItemCatalogo(14, "Panamá");
    public static final ItemCatalogo C_DAVID = new ItemCatalogo(15, "David");
    public static final Map<Integer, List<ItemCatalogo>> CANTONES_POR_PROVINCIA = Map.of(
            P_SAN_JOSE.getId(), List.of(C_SAN_JOSE, C_ESCAZU, C_CURRIDABAT),
            P_ALAJUELA.getId(), List.of(C_ALAJUELA, C_GRECIA),
            P_CARTAGO.getId(), List.of(C_CARTAGO, C_PARAISO),
            P_HEREDIA.getId(), List.of(C_HEREDIA, C_SANTO_DOMINGO),
            P_GUANACASTE.getId(), List.of(C_LIBERIA),
            P_PUNTARENAS.getId(), List.of(C_PUNTARENAS, C_ESPARZA),
            P_LIMON.getId(), List.of(C_LIMON),
            P_PANAMA.getId(), List.of(C_PANAMA),
            P_CHIRIQUI.getId(), List.of(C_DAVID));

    public static final ItemCatalogo D_CARMEN = new ItemCatalogo(1, "Carmen");
    public static final ItemCatalogo D_HOSPITAL = new ItemCatalogo(2, "Hospital");
    public static final ItemCatalogo D_ESCAZU = new ItemCatalogo(3, "Escazú");
    public static final ItemCatalogo D_SAN_RAFAEL = new ItemCatalogo(4, "San Rafael");
    public static final ItemCatalogo D_CURRIDABAT = new ItemCatalogo(5, "Curridabat");
    public static final ItemCatalogo D_GRANADILLA = new ItemCatalogo(6, "Granadilla");
    public static final ItemCatalogo D_ALAJUELA = new ItemCatalogo(7, "Alajuela");
    public static final ItemCatalogo D_GRECIA = new ItemCatalogo(8, "Grecia");
    public static final ItemCatalogo D_ORIENTAL = new ItemCatalogo(9, "Oriental");
    public static final ItemCatalogo D_OCCIDENTAL = new ItemCatalogo(10, "Occidental");
    public static final ItemCatalogo D_PARAISO = new ItemCatalogo(11, "Paraíso");
    public static final ItemCatalogo D_OROSI = new ItemCatalogo(12, "Orosi");
    public static final ItemCatalogo D_HEREDIA = new ItemCatalogo(13, "Heredia");
    public static final ItemCatalogo D_SANTO_DOMINGO = new ItemCatalogo(14, "Santo Domingo");
    public static final ItemCatalogo D_LIBERIA = new ItemCatalogo(15, "Liberia");
    public static final ItemCatalogo D_ESPIRITU_SANTO = new ItemCatalogo(16, "Espíritu Santo");
    public static final ItemCatalogo D_PUNTARENAS = new ItemCatalogo(17, "Puntarenas");
    public static final ItemCatalogo D_LIMON = new ItemCatalogo(18, "Limón");
    public static final ItemCatalogo D_BELLA_VISTA = new ItemCatalogo(19, "Bella Vista");
    public static final ItemCatalogo D_DAVID = new ItemCatalogo(20, "David");
    public static final Map<Integer, List<ItemCatalogo>> DISTRITOS_POR_CANTON = Map.ofEntries(
            Map.entry(C_SAN_JOSE.getId(), List.of(D_CARMEN, D_HOSPITAL)),
            Map.entry(C_ESCAZU.getId(), List.of(D_ESCAZU, D_SAN_RAFAEL)),
            Map.entry(C_CURRIDABAT.getId(), List.of(D_CURRIDABAT, D_GRANADILLA)),
            Map.entry(C_ALAJUELA.getId(), List.of(D_ALAJUELA)),
            Map.entry(C_GRECIA.getId(), List.of(D_GRECIA)),
            Map.entry(C_CARTAGO.getId(), List.of(D_ORIENTAL, D_OCCIDENTAL)),
            Map.entry(C_PARAISO.getId(), List.of(D_PARAISO, D_OROSI)),
            Map.entry(C_HEREDIA.getId(), List.of(D_HEREDIA)),
            Map.entry(C_SANTO_DOMINGO.getId(), List.of(D_SANTO_DOMINGO)),
            Map.entry(C_LIBERIA.getId(), List.of(D_LIBERIA)),
            Map.entry(C_ESPARZA.getId(), List.of(D_ESPIRITU_SANTO)),
            Map.entry(C_PUNTARENAS.getId(), List.of(D_PUNTARENAS)),
            Map.entry(C_LIMON.getId(), List.of(D_LIMON)),
            Map.entry(C_PANAMA.getId(), List.of(D_BELLA_VISTA)),
            Map.entry(C_DAVID.getId(), List.of(D_DAVID)));

    /**
     * Arma la ubicación completa a partir del distrito, buscando su cantón, provincia y país en
     * los mapas de arriba.
     */
    public static Ubicacion ubicacion(ItemCatalogo distrito, String senas) {
        ItemCatalogo canton = padre(DISTRITOS_POR_CANTON, distrito, CANTONES_POR_PROVINCIA);
        ItemCatalogo provincia = padre(CANTONES_POR_PROVINCIA, canton, PROVINCIAS_POR_PAIS);
        ItemCatalogo pais = padre(PROVINCIAS_POR_PAIS, provincia, Map.of(0, PAISES));
        return new Ubicacion(pais, provincia, canton, distrito, senas);
    }

    /** Busca, entre los posibles padres, el que tiene al hijo en su lista. */
    private static ItemCatalogo padre(Map<Integer, List<ItemCatalogo>> hijosPorPadre, ItemCatalogo hijo,
                                      Map<Integer, List<ItemCatalogo>> padresPosibles) {
        for (Map.Entry<Integer, List<ItemCatalogo>> entrada : hijosPorPadre.entrySet()) {
            if (entrada.getValue().contains(hijo)) {
                for (List<ItemCatalogo> padres : padresPosibles.values()) {
                    for (ItemCatalogo p : padres) {
                        if (p.getId() == entrada.getKey()) {
                            return p;
                        }
                    }
                }
            }
        }
        throw new IllegalStateException("Falta el lugar padre de " + hijo);
    }

    private DatosPrueba() {
        // Clase de utilidad: no se instancia.
    }

    // ------------------------------------------------------------------------
    // ------------------------- Mascotas de ejemplo --------------------------
    // ------------------------------------------------------------------------

    /** Crea una lista nueva de mascotas de ejemplo (se puede modificar). */
    public static List<Mascota> crearMascotas() {
        List<Mascota> lista = new ArrayList<>();

        Mascota max = base(1, PERRO, LABRADOR, "Max", NEGRO, GRANDE, PERDIDA,
                LocalDate.of(2026, 10, 10), ubicacion(D_CURRIDABAT, "Cerca del parque central"),
                PERSONA_USUARIO, "Usuario de prueba");
        max.setEdadEstimada(4);
        max.setMontoRecompensa(new BigDecimal("50000"));
        max.setMonedaRecompensa(COLONES);
        max.setTelefonoContacto("8888-1111");
        max.setNivelEnergia(ATLETICO);
        max.setNotas("Lleva collar azul. Responde a su nombre.");
        lista.add(max);

        Mascota luna = base(2, GATO, SIAMES, "Luna", BLANCO, PEQUENO, ENCONTRADA,
                LocalDate.of(2026, 10, 12), ubicacion(D_SANTO_DOMINGO, "Frente a la iglesia"),
                PERSONA_USUARIO2, "Segundo usuario de prueba");
        luna.setEdadEstimada(2);
        luna.setCorreoContacto("usuario2@correo.com");
        luna.setSeveridad(BUEN_ESTADO);
        lista.add(luna);

        Mascota sinNombre = base(3, PERRO, ZAGUATE, "Zaguate café", CAFE, MEDIANO, EN_ADOPCION,
                LocalDate.of(2026, 9, 20), ubicacion(D_ORIENTAL, "Lote baldío detrás del colegio"),
                PERSONA_ADMIN, "Administrador de prueba");
        sinNombre.setEdadEstimada(1);
        sinNombre.setTelefonoContacto("8777-2222");
        sinNombre.setSeveridad(MAL_ESTADO);
        sinNombre.setRequiereEspacio(true);
        sinNombre.setEnfermedades(new ArrayList<>(List.of(SARNA, DESNUTRICION)));
        sinNombre.setVeterinario(VET_ROJAS);
        sinNombre.setDescripcionAbandono("Encontrado amarrado en un lote baldío.");
        lista.add(sinNombre);

        Mascota toby = base(4, PERRO, CHIHUAHUA, "Toby", CAFE, PEQUENO, ADOPTADA,
                LocalDate.of(2026, 8, 5), ubicacion(D_GRECIA, "Barrio San Isidro"),
                PERSONA_USUARIO, "Usuario de prueba");
        toby.setEdadEstimada(6);
        toby.setTelefonoContacto("8888-1111");
        toby.setNivelEnergia(PARA_VER_TV);
        lista.add(toby);

        Mascota michi = base(5, GATO, CRIOLLO, "Michi", GRIS, MEDIANO, PERDIDA,
                LocalDate.of(2026, 10, 15), ubicacion(D_ESCAZU, "Calle principal, cerca del Multiplaza"),
                PERSONA_USUARIO2, "Segundo usuario de prueba");
        michi.setChip("985141000123456");
        michi.setEdadEstimada(3);
        michi.setMontoRecompensa(new BigDecimal("100"));
        michi.setMonedaRecompensa(DOLARES);
        michi.setCorreoContacto("usuario2@correo.com");
        lista.add(michi);

        Mascota rocky = base(6, PERRO, PASTOR_ALEMAN, "Rocky", NEGRO, GRANDE, ENCONTRADA,
                LocalDate.of(2026, 10, 1), ubicacion(D_LIMON, "Cerca del muelle"),
                PERSONA_ADMIN, "Administrador de prueba");
        rocky.setChip("985141000654321");
        rocky.setEdadEstimada(5);
        rocky.setTelefonoContacto("8777-2222");
        rocky.setSeveridad(CRITICO);
        rocky.setEnfermedades(new ArrayList<>(List.of(EHRLICHIOSIS)));
        rocky.setVeterinario(VET_MORA);
        lista.add(rocky);

        Mascota canela = base(7, GATO, CRIOLLO, "Canela", ATIGRADO, PEQUENO, EN_ADOPCION,
                LocalDate.of(2026, 9, 25), ubicacion(D_LIBERIA, "Parque central"),
                PERSONA_USUARIO, "Usuario de prueba");
        canela.setEdadEstimada(1);
        canela.setTelefonoContacto("8888-1111");
        lista.add(canela);

        Mascota pelusa = base(8, GATO, PERSA, "Pelusa", BLANCO, PEQUENO, ADOPTADA,
                LocalDate.of(2026, 7, 10), ubicacion(D_ESPIRITU_SANTO, "Contiguo a la escuela"),
                PERSONA_USUARIO2, "Segundo usuario de prueba");
        pelusa.setEdadEstimada(7);
        pelusa.setCorreoContacto("usuario2@correo.com");
        lista.add(pelusa);

        return lista;
    }

    // ------------------------------------------------------------------------
    // ------------------------ Adopciones de ejemplo -------------------------
    // ------------------------------------------------------------------------

    /** Crea las adopciones de ejemplo de Toby (id 4) y Pelusa (id 8). */
    public static List<Adopcion> crearAdopciones(List<Mascota> mascotas) {
        List<Adopcion> lista = new ArrayList<>();

        Adopcion toby = new Adopcion();
        toby.setId(1);
        toby.setMascota(buscar(mascotas, 4));
        toby.setIdPersonaEntrega(PERSONA_USUARIO);
        toby.setNombrePersonaEntrega("Usuario de prueba");
        toby.setAdoptante(PERSONAS.get(3));
        toby.setFechaAdopcion(LocalDate.of(2026, 8, 20));
        toby.setTipoVivienda(CASA);
        toby.setTienePatio(true);
        toby.setTiempoEjercicio(EJERCICIO_MEDIO);
        toby.setOtrasMascotas(new ArrayList<>(List.of(CRIOLLO)));
        toby.setCalificacion(5);
        toby.setNotasCalificacion("Familia muy responsable; envía fotos con frecuencia.");
        lista.add(toby);

        Adopcion pelusa = new Adopcion();
        pelusa.setId(2);
        pelusa.setMascota(buscar(mascotas, 8));
        pelusa.setIdPersonaEntrega(PERSONA_USUARIO2);
        pelusa.setNombrePersonaEntrega("Segundo usuario de prueba");
        pelusa.setAdoptante(PERSONAS.get(4));
        pelusa.setFechaAdopcion(LocalDate.of(2026, 9, 15));
        pelusa.setTipoVivienda(APARTAMENTO);
        pelusa.setTiempoEjercicio(EJERCICIO_POCO);
        pelusa.setCalificacion(2);
        pelusa.setNotasCalificacion("No ha respondido los mensajes de seguimiento.");
        lista.add(pelusa);

        return lista;
    }

    /** Crea los seguimientos de ejemplo (de la adopción de Toby). */
    public static List<SeguimientoAdopcion> crearSeguimientos() {
        List<SeguimientoAdopcion> lista = new ArrayList<>();
        lista.add(seguimiento(1, 1, LocalDate.of(2026, 9, 1), "Toby se adaptó bien a la casa y al otro gato."));
        lista.add(seguimiento(2, 1, LocalDate.of(2026, 10, 1), "Ya fue vacunado y salió a pasear al parque."));
        return lista;
    }

    private static SeguimientoAdopcion seguimiento(int id, int idAdopcion, LocalDate fecha, String comentarios) {
        SeguimientoAdopcion s = new SeguimientoAdopcion();
        s.setId(id);
        s.setIdAdopcion(idAdopcion);
        s.setFecha(fecha);
        s.setComentarios(comentarios);
        return s;
    }

    // ------------------------------------------------------------------------
    // ------------ Personas, lista negra y casas cuna de ejemplo -------------
    // ------------------------------------------------------------------------

    /**
     * Crea las personas de ejemplo. Los nombres completos coinciden con los de PERSONAS. Las tres
     * primeras son las de los usuarios de prueba.
     */
    public static List<Persona> crearPersonas() {
        List<Persona> lista = new ArrayList<>();
        lista.add(persona(PERSONA_ADMIN, "Administrador", null, "de prueba", null, ubicacion(D_CARMEN, "Avenida 2, calle 5"),
                List.of("2222-0001"), List.of("admin@bienestar.test")));
        lista.add(persona(PERSONA_USUARIO, "Usuario", null, "de prueba", null, ubicacion(D_CURRIDABAT, "Del Walmart 200 m sur"),
                List.of("8888-1111"), List.of("usuario@correo.com")));
        lista.add(persona(PERSONA_USUARIO2, "Segundo", "usuario", "de prueba", null, ubicacion(D_SANTO_DOMINGO, "Frente a la iglesia"),
                List.of("8777-3333"), List.of("usuario2@correo.com")));
        lista.add(persona(PERSONA_MARIA, "María", null, "Jiménez", "Solano", ubicacion(D_ESCAZU, "Residencial Los Laureles, casa 12"),
                List.of("8333-4444"), List.of("maria.jimenez@correo.com")));
        lista.add(persona(PERSONA_JORGE, "Jorge", null, "Castro", "Rojas", ubicacion(D_ALAJUELA, "Barrio San José, casa 40"),
                List.of("8444-5555"), List.of("jorge.castro@correo.com")));
        lista.add(persona(6, "Daniela", null, "Quesada", "Mora", ubicacion(D_ORIENTAL, "Detrás de la basílica"),
                List.of("8555-6666"), List.of("daniela.quesada@correo.com")));
        return lista;
    }

    private static Persona persona(int id, String nombre, String segundoNombre, String apellido1, String apellido2,
                                   Ubicacion ubicacion, List<String> telefonos, List<String> correos) {
        Persona p = new Persona();
        p.setId(id);
        p.setNombre(nombre);
        p.setSegundoNombre(segundoNombre);
        p.setPrimerApellido(apellido1);
        p.setSegundoApellido(apellido2);
        p.setUbicacion(ubicacion);
        p.setTelefonos(new ArrayList<>(telefonos));
        p.setCorreos(new ArrayList<>(correos));
        return p;
    }

    /** Crea los reportes de lista negra de ejemplo (dos sobre Jorge Castro, el adoptante de Pelusa). */
    public static List<ReporteListaNegra> crearReportesListaNegra() {
        List<ReporteListaNegra> lista = new ArrayList<>();
        lista.add(reporte(1, PERSONA_JORGE, LocalDate.of(2026, 9, 28),
                "No respondió los mensajes de seguimiento de la adopción de Pelusa."));
        lista.add(reporte(2, PERSONA_JORGE, LocalDate.of(2026, 10, 5),
                "Se reportó que la mascota adoptada no recibe atención veterinaria."));
        return lista;
    }

    private static ReporteListaNegra reporte(int id, int idPersona, LocalDate fecha, String motivo) {
        ReporteListaNegra r = new ReporteListaNegra();
        r.setId(id);
        r.setIdPersona(idPersona);
        r.setFecha(fecha);
        r.setMotivo(motivo);
        return r;
    }

    /**
     * Crea las casas cuna de ejemplo: María (disponible, perros pequeños y medianos), usuario2
     * (sin cupo, gatos pequeños) y Daniela (inactiva, perros grandes).
     */
    public static List<CasaCuna> crearCasasCuna() {
        List<CasaCuna> lista = new ArrayList<>();
        lista.add(casaCuna(PERSONA_MARIA, ubicacion(D_ESCAZU, "Residencial Los Laureles, casa 12"), ESTADO_CASA_DISPONIBLE, 3, 1, true,
                List.of(PEQUENO, MEDIANO), List.of(PERRO)));
        lista.add(casaCuna(PERSONA_USUARIO2, ubicacion(D_SANTO_DOMINGO, "Frente a la iglesia"), ESTADO_CASA_DISPONIBLE, 2, 2, false,
                List.of(PEQUENO), List.of(GATO)));
        lista.add(casaCuna(6, ubicacion(D_ORIENTAL, "Detrás de la basílica"), ESTADO_CASA_INACTIVA, 4, 0, true,
                List.of(MEDIANO, GRANDE), List.of(PERRO)));
        return lista;
    }

    private static CasaCuna casaCuna(int idPersona, Ubicacion ubicacion, ItemCatalogo estado, int capacidad, int actual,
                                     boolean requiereDonacion, List<ItemCatalogo> tamanos, List<ItemCatalogo> tipos) {
        CasaCuna c = new CasaCuna();
        c.setIdPersona(idPersona);
        c.setUbicacion(ubicacion);
        c.setEstado(estado);
        c.setCapacidadMaxima(capacidad);
        c.setCantidadActual(actual);
        c.setRequiereDonacionAlimentos(requiereDonacion);
        c.setTamanos(new ArrayList<>(tamanos));
        c.setTipos(new ArrayList<>(tipos));
        return c;
    }

    // ------------------------------------------------------------------------
    // ----------------- Asociaciones y donaciones de ejemplo -----------------
    // ------------------------------------------------------------------------

    /** Crea una lista nueva de asociaciones de ejemplo (se puede modificar). */
    public static List<AsociacionBienestar> crearAsociaciones() {
        List<AsociacionBienestar> lista = new ArrayList<>();
        lista.add(new AsociacionBienestar(1, "Patitas Felices", ubicacion(D_SAN_RAFAEL, "Centro comercial Plaza Rolex, local 3")));
        lista.add(new AsociacionBienestar(2, "Huellas de Esperanza", ubicacion(D_HEREDIA, "100 m norte del parque central")));
        lista.add(new AsociacionBienestar(3, "Refugio Animal Cartago", ubicacion(D_ORIENTAL, "Carretera a Paraíso, km 2")));
        return lista;
    }

    /**
     * Crea las donaciones de ejemplo. La donación 4 es la recompensa de Michi (mascota 5), por eso
     * esa recompensa ya no está disponible.
     */
    public static List<Donacion> crearDonaciones(List<AsociacionBienestar> asociaciones, List<Mascota> mascotas) {
        List<Donacion> lista = new ArrayList<>();

        Donacion d1 = donacion(1, TipoDonacion.VOLUNTARIA, PERSONAS.get(1), COLONES, null,
                "20000", LocalDate.of(2026, 9, 5));
        d1.getDetalles().add(detalle(asociacion(asociaciones, 1), null, "20000"));
        lista.add(d1);

        Donacion d2 = donacion(2, TipoDonacion.VOLUNTARIA, PERSONAS.get(3), DOLARES, null,
                "100", LocalDate.of(2026, 9, 20));
        d2.getDetalles().add(detalle(asociacion(asociaciones, 1), "60", "60.00"));
        d2.getDetalles().add(detalle(asociacion(asociaciones, 2), "40", "40.00"));
        lista.add(d2);

        Donacion d3 = donacion(3, TipoDonacion.VOLUNTARIA, PERSONAS.get(2), COLONES, null,
                "15000", LocalDate.of(2026, 10, 2));
        d3.getDetalles().add(detalle(asociacion(asociaciones, 3), null, "15000"));
        lista.add(d3);

        Donacion d4 = donacion(4, TipoDonacion.RECOMPENSA, PERSONAS.get(2), DOLARES, buscar(mascotas, 5),
                "100", LocalDate.of(2026, 10, 16));
        d4.getDetalles().add(detalle(asociacion(asociaciones, 2), "50", "50.00"));
        d4.getDetalles().add(detalle(asociacion(asociaciones, 3), "50", "50.00"));
        lista.add(d4);

        return lista;
    }

    private static Donacion donacion(int id, TipoDonacion tipo, ItemCatalogo donador, ItemCatalogo moneda,
                                     Mascota mascota, String monto, LocalDate fecha) {
        Donacion d = new Donacion();
        d.setId(id);
        d.setTipo(tipo);
        d.setIdPersonaDonador(donador.getId());
        d.setNombreDonador(donador.getNombre());
        d.setMoneda(moneda);
        d.setMascota(mascota);
        d.setMontoTotal(new BigDecimal(monto));
        d.setFecha(fecha);
        return d;
    }

    private static DetalleDonacion detalle(AsociacionBienestar asociacion, String porcentaje, String monto) {
        DetalleDonacion d = new DetalleDonacion(asociacion, porcentaje == null ? null : new BigDecimal(porcentaje));
        d.setMonto(new BigDecimal(monto));
        return d;
    }

    private static AsociacionBienestar asociacion(List<AsociacionBienestar> asociaciones, int id) {
        for (AsociacionBienestar a : asociaciones) {
            if (a.getId() == id) {
                return a;
            }
        }
        throw new IllegalStateException("Falta la asociación de prueba con id " + id);
    }

    private static Mascota buscar(List<Mascota> mascotas, int id) {
        for (Mascota m : mascotas) {
            if (m.getId() == id) {
                return m;
            }
        }
        throw new IllegalStateException("Falta la mascota de prueba con id " + id);
    }

    private static Mascota base(int id, ItemCatalogo tipo, ItemCatalogo raza, String nombre,
                                ItemCatalogo color, ItemCatalogo tamano, ItemCatalogo estado,
                                LocalDate fecha, Ubicacion ubicacion, int idPersona, String nombrePersona) {
        Mascota m = new Mascota();
        m.setId(id);
        m.setTipo(tipo);
        m.setRaza(raza);
        m.setNombre(nombre);
        m.setColor(color);
        m.setTamano(tamano);
        m.setEstado(estado);
        m.setFechaEvento(fecha);
        m.setUbicacion(ubicacion);
        m.setIdPersonaRegistro(idPersona);
        m.setNombrePersonaRegistro(nombrePersona);
        // Campos que la base exige; cada mascota puede cambiarlos después
        m.setSeveridad(BUEN_ESTADO);
        m.setNivelEnergia(CAMINADOR);
        m.setFacilidadEntrenamiento(MODERADA);
        m.setNotas("Sin notas adicionales.");
        return m;
    }

    /**
     * Crea la bitácora de ejemplo: cambios que, en Oracle, habrían registrado los triggers.
     * Coinciden con el estado actual de los datos de prueba.
     */
    public static List<RegistroBitacora> crearBitacora() {
        List<RegistroBitacora> lista = new ArrayList<>();
        lista.add(cambio(1, 2, "usuario", BitacoraDAOMemoria.TABLA_MASCOTA, "Estado", 4,
                "En adopción", "Adoptada", "Mascota Toby adoptada (adopción 1).",
                LocalDateTime.of(2026, 8, 20, 14, 30)));
        lista.add(cambio(2, 2, "usuario", BitacoraDAOMemoria.TABLA_ADOPCION, "Calificación", 1,
                "4", "5", "Cambio de calificación de la adopción de Toby.",
                LocalDateTime.of(2026, 9, 1, 9, 0)));
        lista.add(cambio(3, 1, "admin", BitacoraDAOMemoria.TABLA_DONACION, "Monto total", 1,
                "25000", "20000", "Corrección del monto de la donación 1 (Colones (₡)).",
                LocalDateTime.of(2026, 9, 6, 10, 15)));
        lista.add(cambio(4, 3, "usuario2", BitacoraDAOMemoria.TABLA_ADOPCION, "Calificación", 2,
                "3", "2", "Cambio de calificación de la adopción de Pelusa.",
                LocalDateTime.of(2026, 10, 1, 16, 45)));
        lista.add(cambio(5, 1, "admin", BitacoraDAOMemoria.TABLA_MASCOTA, "Monto de recompensa", 5,
                "150", "100", "Cambio de la recompensa de Michi.",
                LocalDateTime.of(2026, 10, 10, 11, 20)));
        return lista;
    }

    private static RegistroBitacora cambio(int id, int idUsuario, String usuario, String tabla, String campo,
                                           int idRegistro, String anterior, String nuevo, String descripcion,
                                           LocalDateTime fecha) {
        RegistroBitacora r = new RegistroBitacora();
        r.setId(id);
        r.setIdUsuario(idUsuario);
        r.setNombreUsuario(usuario);
        r.setTabla(tabla);
        r.setCampo(campo);
        r.setIdRegistro(idRegistro);
        r.setValorAnterior(anterior);
        r.setValorNuevo(nuevo);
        r.setDescripcion(descripcion);
        r.setFecha(fecha);
        return r;
    }

    /**
     * Parámetros del sistema con sus valores iniciales (requisito 12: parametrización). Mismos
     * nombres y valores que la tabla Parameter de la base.
     */
    public static List<Parametro> crearParametros() {
        List<Parametro> lista = new ArrayList<>();
        lista.add(parametro(2, "MATCH_JOB_INTERVAL_HOURS", "Intervalo horas job matching mascotas perdidas y encontradas", "4", true));
        lista.add(parametro(3, "DEFAULT_ROLE_NAME", "Rol que recibe un usuario nuevo", "Usuario", false));
        lista.add(parametro(4, "DEFAULT_USER_STATUS", "Estado que recibe un usuario nuevo", "Activo", false));
        lista.add(parametro(5, "ACTIVE_USER_STATUS", "Nombre del estado que permite iniciar sesion", "Activo", false));
        lista.add(parametro(6, "PET_STATUS_LOST", "Nombre del estado de una mascota perdida", "Perdida", false));
        lista.add(parametro(7, "PET_STATUS_FOUND", "Nombre del estado de una mascota encontrada", "Encontrada", false));
        lista.add(parametro(8, "PET_STATUS_IN_ADOPTION", "Nombre del estado de una mascota en adopción", "En adopción", false));
        lista.add(parametro(9, "PET_STATUS_ADOPTED", "Nombre del estado de una mascota adoptada", "Adoptada", false));
        lista.add(parametro(10, "MATCH_WEIGHT_CHIP", "Puntos si el chip es el mismo", "30", true));
        lista.add(parametro(11, "MATCH_WEIGHT_BREED", "Puntos si la raza es la misma", "25", true));
        lista.add(parametro(12, "MATCH_WEIGHT_COLOR", "Puntos si el color es el mismo", "20", true));
        lista.add(parametro(13, "MATCH_WEIGHT_SIZE", "Puntos si el tamaño es el mismo", "15", true));
        lista.add(parametro(14, "MATCH_WEIGHT_CANTON", "Puntos si el cantón es el mismo", "10", true));
        lista.add(parametro(15, "MATCH_MIN_SCORE", "Puntaje mínimo para considerar un match (0 a 100)", "50", true));
        lista.add(parametro(16, "UNADOPTED_ALERT_MONTHS", "Meses en adopción sin ser adoptada para aparecer en el reporte", "2", true));
        lista.add(parametro(17, "AGE_LIMIT_1", "Límite del primer rango de edad (años)", "1", true));
        lista.add(parametro(18, "AGE_LIMIT_2", "Límite del segundo rango de edad (años)", "5", true));
        lista.add(parametro(19, "AGE_LIMIT_3", "Límite del tercer rango de edad (años)", "10", true));
        lista.add(parametro(20, "AGE_LIMIT_4", "Límite del cuarto rango de edad (años)", "12", true));
        lista.add(parametro(21, "AGE_LIMIT_5", "Límite del quinto rango de edad (años)", "16", true));
        return lista;
    }

    private static Parametro parametro(int id, String nombre, String descripcion, String valor, boolean numerico) {
        Parametro p = new Parametro();
        p.setId(id);
        p.setNombre(nombre);
        p.setDescripcion(descripcion);
        p.setValor(valor);
        p.setNumerico(numerico);
        return p;
    }
}
