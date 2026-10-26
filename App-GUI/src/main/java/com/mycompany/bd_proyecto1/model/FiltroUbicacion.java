package com.mycompany.bd_proyecto1.model;

/**
 * Criterio de búsqueda por lugar. Cada nivel es opcional (null = todos).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class FiltroUbicacion {

    private Integer idPais;
    private Integer idProvincia;
    private Integer idCanton;
    private Integer idDistrito;

    public FiltroUbicacion() {
    }

    public FiltroUbicacion(Integer idPais, Integer idProvincia, Integer idCanton, Integer idDistrito) {
        this.idPais = idPais;
        this.idProvincia = idProvincia;
        this.idCanton = idCanton;
        this.idDistrito = idDistrito;
    }

    public Integer getIdPais() { return idPais; }
    public void setIdPais(Integer idPais) { this.idPais = idPais; }

    public Integer getIdProvincia() { return idProvincia; }
    public void setIdProvincia(Integer idProvincia) { this.idProvincia = idProvincia; }

    public Integer getIdCanton() { return idCanton; }
    public void setIdCanton(Integer idCanton) { this.idCanton = idCanton; }

    public Integer getIdDistrito() { return idDistrito; }
    public void setIdDistrito(Integer idDistrito) { this.idDistrito = idDistrito; }

    /** true si no se eligió ningún nivel. */
    public boolean estaVacio() {
        return idPais == null && idProvincia == null && idCanton == null && idDistrito == null;
    }

    /**
     * true si la ubicación cumple todos los niveles elegidos. Sin ubicación solo cumple un filtro
     * vacío.
     */
    public boolean cumple(Ubicacion u) {
        if (estaVacio()) {
            return true;
        }
        if (u == null) {
            return false;
        }
        return coincide(u.getPais(), idPais) && coincide(u.getProvincia(), idProvincia)
                && coincide(u.getCanton(), idCanton) && coincide(u.getDistrito(), idDistrito);
    }

    private static boolean coincide(ItemCatalogo valor, Integer id) {
        return id == null || (valor != null && valor.getId() == id);
    }
}
