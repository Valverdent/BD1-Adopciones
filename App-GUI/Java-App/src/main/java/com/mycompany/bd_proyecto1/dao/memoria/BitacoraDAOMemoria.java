package com.mycompany.bd_proyecto1.dao.memoria;

import com.mycompany.bd_proyecto1.dao.BitacoraDAO;
import com.mycompany.bd_proyecto1.model.FiltroBitacora;
import com.mycompany.bd_proyecto1.model.ItemCatalogo;
import com.mycompany.bd_proyecto1.model.RegistroBitacora;
import com.mycompany.bd_proyecto1.model.Usuario;
import com.mycompany.bd_proyecto1.util.Sesion;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.TreeSet;

/**
 * Implementación de BitacoraDAO con DATOS DE PRUEBA en memoria.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-20
 */
public class BitacoraDAOMemoria implements BitacoraDAO {

    public static final String TABLA_MASCOTA = "Mascota";
    public static final String TABLA_ADOPCION = "Adopción";
    public static final String TABLA_DONACION = "Donación";
    public static final String TABLA_PARAMETRO = "Parámetro";

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final List<RegistroBitacora> registros = DatosPrueba.crearBitacora();
    private int siguienteId = registros.size() + 1;

    /** Registra un cambio si el valor realmente cambió. El usuario es el de la sesión abierta. */
    public boolean registrarCambio(String tabla, String campo, int idRegistro,
                                   Object anterior, Object nuevo, String descripcion) {
        if (sonIguales(anterior, nuevo)) {
            return false;
        }
        Usuario usuario = Sesion.getUsuario();
        RegistroBitacora r = new RegistroBitacora();
        r.setId(siguienteId);
        siguienteId++;
        r.setIdUsuario(usuario == null ? 0 : usuario.getIdUsuario());
        r.setNombreUsuario(usuario == null ? "sistema" : usuario.getNombreUsuario());
        r.setTabla(tabla);
        r.setCampo(campo);
        r.setIdRegistro(idRegistro);
        r.setValorAnterior(comoTexto(anterior));
        r.setValorNuevo(comoTexto(nuevo));
        r.setDescripcion(descripcion);
        r.setFecha(LocalDateTime.now());
        registros.add(r);
        return true;
    }

    private boolean sonIguales(Object a, Object b) {
        if (a instanceof BigDecimal x && b instanceof BigDecimal y) {
            return x.compareTo(y) == 0;
        }
        return Objects.equals(a, b);
    }

    private String comoTexto(Object valor) {
        if (valor == null) {
            return null;
        }
        if (valor instanceof ItemCatalogo item) {
            return item.getNombre();
        }
        if (valor instanceof BigDecimal monto) {
            return monto.toPlainString();
        }
        if (valor instanceof LocalDate fecha) {
            return fecha.format(FORMATO_FECHA);
        }
        return valor.toString();
    }

    @Override
    public List<RegistroBitacora> consultar(FiltroBitacora filtro) {
        List<RegistroBitacora> resultado = new ArrayList<>();
        for (RegistroBitacora r : registros) {
            if (cumpleFiltro(r, filtro)) {
                resultado.add(r);
            }
        }
        resultado.sort(Comparator.comparing(RegistroBitacora::getFecha)
                .thenComparing(RegistroBitacora::getId).reversed());
        return resultado;
    }

    @Override
    public List<String> listarTablas() {
        TreeSet<String> tablas = new TreeSet<>();
        for (RegistroBitacora r : registros) {
            tablas.add(r.getTabla());
        }
        return new ArrayList<>(tablas);
    }

    private boolean cumpleFiltro(RegistroBitacora r, FiltroBitacora f) {
        LocalDate dia = r.getFecha().toLocalDate();
        return contiene(r.getNombreUsuario(), f.getUsuario())
                && (vacio(f.getTabla()) || r.getTabla().equalsIgnoreCase(f.getTabla().trim()))
                && contiene(r.getCampo(), f.getCampo())
                && (f.getIdRegistro() == null || r.getIdRegistro() == f.getIdRegistro())
                && (vacio(f.getTexto()) || contiene(r.getValorAnterior(), f.getTexto())
                        || contiene(r.getValorNuevo(), f.getTexto())
                        || contiene(r.getDescripcion(), f.getTexto()))
                && (f.getFechaDesde() == null || !dia.isBefore(f.getFechaDesde()))
                && (f.getFechaHasta() == null || !dia.isAfter(f.getFechaHasta()));
    }

    private boolean vacio(String texto) {
        return texto == null || texto.isBlank();
    }

    /** Un criterio vacío no filtra; si no, busca coincidencia parcial sin mayúsculas. */
    private boolean contiene(String valor, String criterio) {
        if (vacio(criterio)) {
            return true;
        }
        return valor != null && valor.toLowerCase().contains(criterio.trim().toLowerCase());
    }
}
