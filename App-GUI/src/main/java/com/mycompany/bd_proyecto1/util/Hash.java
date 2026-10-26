package com.mycompany.bd_proyecto1.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Convierte una contraseña en su hash SHA-256, que es lo que guarda y compara la base de datos
 * (PKG_USER_ADMINISTRATION exige 64 caracteres hexadecimales).
 *
 * @author Carlos Hidalgo
 * @since 2026-10-22
 */
public final class Hash {

    private Hash() {
        // Clase de utilidad: no se instancia.
    }

    /** SHA-256 de la contraseña en hexadecimal (64 caracteres, mayúsculas). */
    public static String sha256(String contrasena) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(contrasena.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : bytes) {
                hex.append(String.format("%02X", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // Todas las versiones de Java incluyen SHA-256
            throw new IllegalStateException("SHA-256 no está disponible", e);
        }
    }
}
