package com.mycompany.bd_proyecto1.util;

/**
 * Validaciones de formato reutilizables por los managers (PDF 9.h).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public final class Validador {

    private static final String PATRON_CORREO = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$";
    private static final String PATRON_TELEFONO = "^[0-9 +()\\-]+$";
    private static final String PATRON_CHIP = "^[A-Za-z0-9\\-]{1,15}$";

    private Validador() {
        // Clase de utilidad: no se instancia.
    }

    public static boolean estaVacio(String texto) {
        return texto == null || texto.isBlank();
    }

    /** Quita los espacios de los extremos; si queda vacío, devuelve null. */
    public static String limpiar(String texto) {
        return estaVacio(texto) ? null : texto.trim();
    }

    public static boolean esCorreoValido(String correo) {
        return correo != null && correo.matches(PATRON_CORREO);
    }

    /** Acepta dígitos, espacios, guiones, paréntesis y +, con 8 a 15 dígitos. */
    public static boolean esTelefonoValido(String telefono) {
        if (telefono == null || !telefono.matches(PATRON_TELEFONO)) {
            return false;
        }
        int digitos = telefono.replaceAll("[^0-9]", "").length();
        return digitos >= 8 && digitos <= 15;
    }

    /** Letras, números y guiones, de 1 a 20 caracteres. */
    /** true si el texto es un enlace de internet (empieza con http:// o https://). */
    public static boolean esEnlaceWeb(String texto) {
        if (texto == null) {
            return false;
        }
        String minusculas = texto.trim().toLowerCase();
        return minusculas.startsWith("http://") || minusculas.startsWith("https://");
    }

    public static boolean esChipValido(String chip) {
        return chip != null && chip.matches(PATRON_CHIP);
    }
}
