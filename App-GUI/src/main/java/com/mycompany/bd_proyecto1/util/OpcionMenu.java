package com.mycompany.bd_proyecto1.util;

import static com.mycompany.bd_proyecto1.util.PerfilInterfaz.ADMINISTRADOR;
import static com.mycompany.bd_proyecto1.util.PerfilInterfaz.USUARIO_COMUN;

import java.util.EnumSet;
import java.util.Set;

/**
 * Opciones del menú principal y los perfiles que pueden verlas.
 *
 * @author Carlos Hidalgo
 * @since 2026-10-13
 */
public enum OpcionMenu {

    MASCOTAS("Mascotas", USUARIO_COMUN, ADMINISTRADOR),
    PERSONAS("Rescatistas y adoptantes", USUARIO_COMUN, ADMINISTRADOR),
    CASAS_CUNA("Casas cuna", USUARIO_COMUN, ADMINISTRADOR),
    ADOPCIONES("Adopciones", USUARIO_COMUN, ADMINISTRADOR),
    LISTA_NEGRA("Lista negra", USUARIO_COMUN, ADMINISTRADOR),
    DONACIONES("Donaciones", USUARIO_COMUN, ADMINISTRADOR),
    ASOCIACIONES("Asociaciones", ADMINISTRADOR),
    MATCHES("Matches", USUARIO_COMUN, ADMINISTRADOR),
    ESTADISTICAS("Estadísticas", USUARIO_COMUN, ADMINISTRADOR),
    CONSULTAS("Consultas adicionales", USUARIO_COMUN, ADMINISTRADOR),
    BITACORA("Bitácora", ADMINISTRADOR),
    PARAMETROS("Catálogos, parámetros y usuarios", ADMINISTRADOR);

    private final String texto;
    private final Set<PerfilInterfaz> perfilesPermitidos;

    OpcionMenu(String texto, PerfilInterfaz primerPerfil, PerfilInterfaz... otrosPerfiles) {
        this.texto = texto;
        this.perfilesPermitidos = EnumSet.of(primerPerfil, otrosPerfiles);
    }

    public String getTexto() {
        return texto;
    }

    public boolean estaPermitidaPara(PerfilInterfaz perfil) {
        return perfil != null && perfilesPermitidos.contains(perfil);
    }
}
