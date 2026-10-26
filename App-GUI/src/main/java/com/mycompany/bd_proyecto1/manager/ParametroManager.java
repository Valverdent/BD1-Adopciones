package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.ParametroDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.Parametro;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.util.List;
import java.util.Map;

/**
 * Reglas de los parámetros del sistema (requisito 12).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class ParametroManager {

    /** Puntaje mínimo (0 a 100) para que un match aparezca en el reporte. */
    public static final String PORCENTAJE_MINIMO_MATCH = "MATCH_MIN_SCORE";
    /** Meses en adopción sin ser adoptada para aparecer en el reporte de mascotas sin adoptar. */
    public static final String MESES_SIN_ADOPTAR = "UNADOPTED_ALERT_MONTHS";
    /** Cada cuántas horas corre el job de matches (lo ejecuta la base de datos). */
    public static final String HORAS_JOB_MATCH = "MATCH_JOB_INTERVAL_HOURS";

    private record Rango(int minimo, int maximo) {
    }

    /** Rangos válidos de los parámetros numéricos: reglas de validación, no datos del sistema. */
    private static final Map<String, Rango> RANGOS = Map.ofEntries(
            Map.entry(PORCENTAJE_MINIMO_MATCH, new Rango(0, 100)),
            Map.entry(MESES_SIN_ADOPTAR, new Rango(1, 120)),
            Map.entry(HORAS_JOB_MATCH, new Rango(1, 24)),
            Map.entry("MATCH_WEIGHT_CHIP", new Rango(0, 100)),
            Map.entry("MATCH_WEIGHT_BREED", new Rango(0, 100)),
            Map.entry("MATCH_WEIGHT_COLOR", new Rango(0, 100)),
            Map.entry("MATCH_WEIGHT_SIZE", new Rango(0, 100)),
            Map.entry("MATCH_WEIGHT_CANTON", new Rango(0, 100)),
            Map.entry("AGE_LIMIT_1", new Rango(0, 50)),
            Map.entry("AGE_LIMIT_2", new Rango(0, 50)),
            Map.entry("AGE_LIMIT_3", new Rango(0, 50)),
            Map.entry("AGE_LIMIT_4", new Rango(0, 50)),
            Map.entry("AGE_LIMIT_5", new Rango(0, 50)));

    private final ParametroDAO parametroDAO;

    public ParametroManager() {
        this(Repositorios.parametros());
    }

    public ParametroManager(ParametroDAO parametroDAO) {
        this.parametroDAO = parametroDAO;
    }

    /** Todos los parámetros, para la pantalla de administración. */
    public List<Parametro> listar() {
        return parametroDAO.listar();
    }

    /**
     * Lee un parámetro como número entero. Lo usan las demás reglas del sistema en lugar de
     * valores escritos en el código.
     */
    public int valorEntero(String nombre) {
        for (Parametro p : parametroDAO.listar()) {
            if (p.getNombre().equals(nombre)) {
                try {
                    return Integer.parseInt(p.getValor().trim());
                } catch (NumberFormatException e) {
                    throw new IllegalStateException("El parámetro " + nombre + " no tiene un número válido.");
                }
            }
        }
        throw new IllegalStateException("No existe el parámetro " + nombre + ".");
    }

    /** Cambia el valor de un parámetro después de validarlo. */
    public void actualizar(int id, String texto) {
        validarAdministrador();
        Parametro parametro = buscar(id);
        String valor = texto == null ? "" : texto.trim();
        if (valor.isEmpty()) {
            throw new IllegalArgumentException("El valor no puede estar vacío.");
        }
        if (!parametro.isNumerico()) {
            // Parámetros de texto: nombres de estados y roles; deben coincidir con el catálogo
            parametroDAO.actualizarValor(id, valor);
            return;
        }
        int numero;
        try {
            numero = Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("El valor debe ser un número entero.");
        }
        Rango rango = RANGOS.get(parametro.getNombre());
        if (rango != null && (numero < rango.minimo() || numero > rango.maximo())) {
            throw new IllegalArgumentException("El valor de «" + parametro.getDescripcion()
                    + "» debe estar entre " + rango.minimo() + " y " + rango.maximo() + ".");
        }
        parametroDAO.actualizarValor(id, String.valueOf(numero));
    }

    private Parametro buscar(int id) {
        for (Parametro p : parametroDAO.listar()) {
            if (p.getId() == id) {
                return p;
            }
        }
        throw new IllegalArgumentException("No existe el parámetro indicado.");
    }

    private void validarAdministrador() {
        Usuario usuario = Sesion.getUsuario();
        if (usuario == null || !usuario.esAdministrador()) {
            throw new IllegalStateException("Solo un administrador puede cambiar los parámetros.");
        }
    }
}
