package com.mycompany.bd_proyecto1.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Cálculo de porcentajes para las estadísticas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public final class Porcentajes {

    private Porcentajes() {
        // Clase de utilidad: no se instancia.
    }

    /** Porcentaje de parte sobre total, con 2 decimales. Si el total es 0, devuelve 0. */
    public static BigDecimal de(int parte, int total) {
        return de(BigDecimal.valueOf(parte), BigDecimal.valueOf(total));
    }

    public static BigDecimal de(BigDecimal parte, BigDecimal total) {
        if (total.signum() == 0) {
            return BigDecimal.ZERO.setScale(2);
        }
        return parte.multiply(BigDecimal.valueOf(100)).divide(total, 2, RoundingMode.HALF_UP);
    }
}
