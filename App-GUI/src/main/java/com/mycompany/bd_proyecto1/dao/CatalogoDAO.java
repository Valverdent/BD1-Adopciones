package com.mycompany.bd_proyecto1.dao;

import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.TratamientoEnfermedad;
import java.util.List;

/**
 * Contrato de acceso a los catálogos del sistema.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public interface CatalogoDAO {

    /** Catálogos simples que la aplicación necesita. */
    enum TipoCatalogo {
        TIPO_MASCOTA,
        /** Razas: cada raza pertenece a un tipo de mascota (ver getPadre). */
        RAZA,
        COLOR,
        TAMANO,
        ESTADO_MASCOTA,
        SEVERIDAD,
        NIVEL_ENERGIA,
        FACILIDAD_ENTRENAMIENTO,
        MONEDA,
        ENFERMEDAD,
        /** El nombre de cada elemento es el nombre completo de la persona veterinaria. */
        VETERINARIO,
        /** Formulario de adopción: tipo de vivienda del adoptante. */
        TIPO_VIVIENDA,
        /** Formulario de adopción: tiempo de ejercicio que puede dar el adoptante. */
        TIEMPO_EJERCICIO,
        /** Estado de una casa cuna (Disponible, Ocupada, Inactiva...). */
        ESTADO_CASA_CUNA,
        /** Lugares: país > provincia > cantón > distrito (tablas Country, Province, Canton, District). */
        PAIS,
        PROVINCIA,
        CANTON,
        DISTRITO;

        /**
         * Catálogo del que depende cada elemento: una raza pertenece a un tipo de mascota, una
         * provincia a un país, un cantón a una provincia y un distrito a un cantón.
         */
        public TipoCatalogo getPadre() {
            return switch (this) {
                case RAZA -> TIPO_MASCOTA;
                case PROVINCIA -> PAIS;
                case CANTON -> PROVINCIA;
                case DISTRITO -> CANTON;
                default -> null;
            };
        }

        public boolean tienePadre() {
            return getPadre() != null;
        }
    }

    /** Lista los elementos de un catálogo simple. */
    List<ItemCatalogo> listar(TipoCatalogo tipo);

    /**
     * Lista los elementos que dependen de un padre: las razas de un tipo de mascota, las
     * provincias de un país, los cantones de una provincia o los distritos de un cantón.
     */
    List<ItemCatalogo> listarHijos(TipoCatalogo tipo, int idPadre);

    /** Razas de un tipo de mascota. */
    default List<ItemCatalogo> listarRazas(int idTipoMascota) {
        return listarHijos(TipoCatalogo.RAZA, idTipoMascota);
    }

    /** Lista los tratamientos de una enfermedad, con sus medicamentos. */
    List<TratamientoEnfermedad> listarTratamientos(int idEnfermedad);

    /** Agrega un elemento a un catálogo editable. Retorna el identificador asignado. */
    int insertar(TipoCatalogo tipo, String nombre);

    /**
     * Agrega un elemento a un catálogo con padre (raza, provincia, cantón o distrito). Retorna el
     * identificador asignado.
     */
    int insertarHijo(TipoCatalogo tipo, int idPadre, String nombre);

    /** Cambia el nombre de un elemento. Sirve para cualquier catálogo editable, incluido RAZA. */
    void actualizar(TipoCatalogo tipo, int id, String nombre);

    /** Elimina un elemento de un catálogo editable, incluido RAZA. */
    void eliminar(TipoCatalogo tipo, int id);
}
