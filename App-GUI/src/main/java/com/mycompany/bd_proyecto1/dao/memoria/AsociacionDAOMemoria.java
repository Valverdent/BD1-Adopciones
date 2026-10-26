package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.AsociacionDAO;
import com.mycompany.bd_proyecto1.model.AsociacionBienestar;
import java.text.Collator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Implementación de AsociacionDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class AsociacionDAOMemoria implements AsociacionDAO {

    private final List<AsociacionBienestar> asociaciones = DatosPrueba.crearAsociaciones();
    private int siguienteId = asociaciones.size() + 1;

    @Override
    public List<AsociacionBienestar> listar() {
        List<AsociacionBienestar> copia = new ArrayList<>(asociaciones);
        Collator orden = Collator.getInstance(Locale.forLanguageTag("es"));
        copia.sort((a, b) -> orden.compare(a.getNombre(), b.getNombre()));
        return copia;
    }

    @Override
    public int insertar(AsociacionBienestar asociacion) {
        asociacion.setId(siguienteId);
        siguienteId++;
        asociaciones.add(asociacion);
        return asociacion.getId();
    }

    @Override
    public void actualizar(AsociacionBienestar datos) {
        for (AsociacionBienestar a : asociaciones) {
            if (a.getId() == datos.getId()) {
                a.setNombre(datos.getNombre());
                a.setUbicacion(datos.getUbicacion());
                return;
            }
        }
        throw new IllegalStateException("No existe la asociación con id " + datos.getId());
    }

    @Override
    public boolean existeNombre(String nombre, int idExcluir) {
        for (AsociacionBienestar a : asociaciones) {
            if (a.getId() != idExcluir && a.getNombre().equalsIgnoreCase(nombre)) {
                return true;
            }
        }
        return false;
    }
}
