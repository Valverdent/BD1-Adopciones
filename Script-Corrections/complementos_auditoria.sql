-- ============================================================
-- complementos_auditoria.sql
--
-- Permite que ADOPCION_APP lea la bitacora. No cambia triggers, tablas
-- ni createLog: la bitacora sigue registrando el usuario de la base.
-- ============================================================

GRANT SELECT ON changeLog TO adopcion_app;

