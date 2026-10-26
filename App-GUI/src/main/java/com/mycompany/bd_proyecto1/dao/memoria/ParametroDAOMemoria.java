package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.ParametroDAO;
import com.mycompany.bd_proyecto1.model.Parametro;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación de ParametroDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class ParametroDAOMemoria implements ParametroDAO {

    private final BitacoraDAOMemoria bitacora;
    private final List<Parametro> parametros = DatosPrueba.crearParametros();

    /** Sin bitácora (se usa en algunas pruebas). */
    public ParametroDAOMemoria() {
        this(null);
    }

    public ParametroDAOMemoria(BitacoraDAOMemoria bitacora) {
        this.bitacora = bitacora;
    }

    @Override
    public List<Parametro> listar() {
        return new ArrayList<>(parametros);
    }

    @Override
    public void actualizarValor(int id, String valor) {
        for (Parametro p : parametros) {
            if (p.getId() == id) {
                if (bitacora != null) {
                    bitacora.registrarCambio(BitacoraDAOMemoria.TABLA_PARAMETRO, "Valor", id,
                            p.getValor(), valor, "Cambio del parámetro " + p.getNombre() + ".");
                }
                p.setValor(valor);
                return;
            }
        }
        throw new IllegalStateException("No existe el parámetro con id " + id);
    }
}
