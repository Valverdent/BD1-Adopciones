package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.CasaCunaDAO;
import com.mycompany.bd_proyecto1.dao.ConsultaAdicionalDAO;
import com.mycompany.bd_proyecto1.dao.MascotaDAO;
import com.mycompany.bd_proyecto1.model.CasaCuna;
import com.mycompany.bd_proyecto1.model.DisponibilidadCasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroCasaCuna;
import com.mycompany.bd_proyecto1.model.FiltroMascota;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.Mascota;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Implementación de ConsultaAdicionalDAO con DATOS DE PRUEBA en memoria, con los mismos criterios
 * que PKG_QUERIES_EXTRAS.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public class ConsultaAdicionalDAOMemoria implements ConsultaAdicionalDAO {

    private final CasaCunaDAO casaCunaDAO;
    private final MascotaDAO mascotaDAO;

    public ConsultaAdicionalDAOMemoria(CasaCunaDAO casaCunaDAO, MascotaDAO mascotaDAO) {
        this.casaCunaDAO = casaCunaDAO;
        this.mascotaDAO = mascotaDAO;
    }

    @Override
    public List<DisponibilidadCasaCuna> casasCunaConEspacio(ItemCatalogo provincia, ItemCatalogo tipo,
                                                            int espaciosMinimos) {
        List<DisponibilidadCasaCuna> filas = new ArrayList<>();
        for (CasaCuna c : casaCunaDAO.consultar(new FiltroCasaCuna())) {
            boolean enProvincia = provincia == null || provincia.equals(c.getUbicacion().getProvincia());
            boolean conEspacio = c.getCapacidadMaxima() - c.getCantidadActual() >= espaciosMinimos;
            if (!enProvincia || !conEspacio) {
                continue;
            }
            for (ItemCatalogo aceptado : c.getTipos()) {
                if (tipo == null || tipo.equals(aceptado)) {
                    DisponibilidadCasaCuna d = new DisponibilidadCasaCuna();
                    d.setIdPersona(c.getIdPersona());
                    d.setNombrePersona(c.getNombrePersona());
                    d.setProvincia(c.getUbicacion().getProvincia().getNombre());
                    d.setCanton(c.getUbicacion().getCanton().getNombre());
                    d.setDistrito(c.getUbicacion().getDistrito().getNombre());
                    d.setSenas(c.getUbicacion().getSenas());
                    d.setEstado(c.getEstado().getNombre());
                    d.setTipoMascota(aceptado.getNombre());
                    d.setCapacidadMaxima(c.getCapacidadMaxima());
                    d.setCantidadActual(c.getCantidadActual());
                    d.setRequiereDonacionAlimentos(c.isRequiereDonacionAlimentos());
                    filas.add(d);
                }
            }
        }
        filas.sort(Comparator.comparing(DisponibilidadCasaCuna::getProvincia)
                .thenComparing(Comparator.comparingInt(DisponibilidadCasaCuna::getEspaciosLibres).reversed()));
        return filas;
    }

    @Override
    public List<Mascota> mascotasPerdidasPorRecompensa(ItemCatalogo tipo, ItemCatalogo provincia) {
        FiltroMascota filtro = new FiltroMascota();
        filtro.setEstado(DatosPrueba.PERDIDA);
        filtro.setTipo(tipo);
        List<Mascota> perdidas = new ArrayList<>();
        for (Mascota m : mascotaDAO.consultar(filtro)) {
            if (provincia == null || (m.getUbicacion() != null && provincia.equals(m.getUbicacion().getProvincia()))) {
                perdidas.add(m);
            }
        }
        perdidas.sort(Comparator.comparing((Mascota m) -> m.getMontoRecompensa() == null
                        ? BigDecimal.ZERO : m.getMontoRecompensa()).reversed()
                .thenComparing(Mascota::getFechaEvento, Comparator.reverseOrder()));
        return perdidas;
    }
}
