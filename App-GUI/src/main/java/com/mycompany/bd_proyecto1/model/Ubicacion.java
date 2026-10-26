package com.mycompany.bd_proyecto1.model;

/**
 * Lugar registrado: país, provincia, cantón y distrito elegidos de los catálogos, más las señas
 * escritas a mano (tabla Location: distrito + dirección).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-21
 */
public class Ubicacion {

    private ItemCatalogo pais;
    private ItemCatalogo provincia;
    private ItemCatalogo canton;
    private ItemCatalogo distrito;
    /** Dirección exacta u otras señas (opcional en mascotas). */
    private String senas;

    public Ubicacion() {
    }

    public Ubicacion(ItemCatalogo pais, ItemCatalogo provincia, ItemCatalogo canton, ItemCatalogo distrito,
                     String senas) {
        this.pais = pais;
        this.provincia = provincia;
        this.canton = canton;
        this.distrito = distrito;
        this.senas = senas;
    }

    /** Copia con los mismos elementos de catálogo y las mismas señas. */
    public Ubicacion copiar() {
        return new Ubicacion(pais, provincia, canton, distrito, senas);
    }

    public ItemCatalogo getPais() { return pais; }
    public void setPais(ItemCatalogo pais) { this.pais = pais; }

    public ItemCatalogo getProvincia() { return provincia; }
    public void setProvincia(ItemCatalogo provincia) { this.provincia = provincia; }

    public ItemCatalogo getCanton() { return canton; }
    public void setCanton(ItemCatalogo canton) { this.canton = canton; }

    public ItemCatalogo getDistrito() { return distrito; }
    public void setDistrito(ItemCatalogo distrito) { this.distrito = distrito; }

    public String getSenas() { return senas; }
    public void setSenas(String senas) { this.senas = senas; }

    /** Texto corto para tablas: "Distrito, Cantón, Provincia". */
    public String getResumen() {
        return unir(distrito, canton, provincia);
    }

    /** Texto completo: "Distrito, Cantón, Provincia, País. Señas". */
    public String getDescripcion() {
        String lugar = unir(distrito, canton, provincia, pais);
        if (senas == null || senas.isBlank()) {
            return lugar;
        }
        return lugar.isEmpty() ? senas.trim() : lugar + ". " + senas.trim();
    }

    /** Resumen para tablas, o texto vacío si no hay ubicación. */
    public static String resumenDe(Ubicacion u) {
        return u == null ? "" : u.getResumen();
    }

    /** Descripción completa, o texto vacío si no hay ubicación. */
    public static String descripcionDe(Ubicacion u) {
        return u == null ? "" : u.getDescripcion();
    }

    @Override
    public String toString() {
        return getDescripcion();
    }

    private static String unir(ItemCatalogo... partes) {
        StringBuilder texto = new StringBuilder();
        for (ItemCatalogo parte : partes) {
            if (parte != null) {
                if (texto.length() > 0) {
                    texto.append(", ");
                }
                texto.append(parte.getNombre());
            }
        }
        return texto.toString();
    }
}
