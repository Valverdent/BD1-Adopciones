package com.mycompany.bd_proyecto1.manager;

import com.mycompany.bd_proyecto1.dao.CatalogoDAO;
import com.mycompany.bd_proyecto1.dao.CatalogoDAO.TipoCatalogo;
import com.mycompany.bd_proyecto1.dao.ConsultaAdicionalDAO;
import com.mycompany.bd_proyecto1.dao.Repositorios;
import com.mycompany.bd_proyecto1.model.DisponibilidadCasaCuna;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import com.mycompany.bd_proyecto1.util.Validador;
import java.util.List;

/**
 * Consultas adicionales que propuso el equipo: casas cuna con espacio y mascotas perdidas
 * ordenadas por recompensa. Todos los usuarios las pueden usar.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class ConsultaAdicionalManager {

    private final ConsultaAdicionalDAO consultaDAO;
    private final CatalogoDAO catalogoDAO;

    public ConsultaAdicionalManager() {
        this(Repositorios.consultasAdicionales(), Repositorios.catalogos());
    }

    public ConsultaAdicionalManager(ConsultaAdicionalDAO consultaDAO, CatalogoDAO catalogoDAO) {
        this.consultaDAO = consultaDAO;
        this.catalogoDAO = catalogoDAO;
    }

    public List<ItemCatalogo> listarProvincias() {
        return catalogoDAO.listar(TipoCatalogo.PROVINCIA);
    }

    public List<ItemCatalogo> listarTipos() {
        return catalogoDAO.listar(TipoCatalogo.TIPO_MASCOTA);
    }

    /**
     * @param espaciosTexto espacios libres mínimos escritos en la pantalla (vacío = 1)
     * @throws IllegalArgumentException si los espacios no son un entero de 1 o más
     */
    public List<DisponibilidadCasaCuna> casasCunaConEspacio(ItemCatalogo provincia, ItemCatalogo tipo,
                                                            String espaciosTexto) {
        int espacios = 1;
        if (!Validador.estaVacio(espaciosTexto)) {
            try {
                espacios = Integer.parseInt(espaciosTexto.trim());
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Los espacios libres deben ser un número entero.");
            }
        }
        if (espacios < 1) {
            throw new IllegalArgumentException("Los espacios libres deben ser 1 o más.");
        }
        return consultaDAO.casasCunaConEspacio(provincia, tipo, espacios);
    }

    public List<Mascota> mascotasPerdidasPorRecompensa(ItemCatalogo tipo, ItemCatalogo provincia) {
        return consultaDAO.mascotasPerdidasPorRecompensa(tipo, provincia);
    }
}
