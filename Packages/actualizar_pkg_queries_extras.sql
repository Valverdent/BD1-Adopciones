-- ============================================================
-- actualizar_pkg_queries_extras.sql
-- Actualiza PKG_QUERIES_EXTRAS (codigo tomado de la base el 22/10/2026).
-- Cambios:
--   Agrega pr_get_changelog (consulta filtrable de la bitacora) y pr_get_changelog_tables.
--   Usan SQL dinamico: si falta el permiso de lectura sobre ADOPCION_AUDIT.ChangeLog,
--   solo esos dos fallan (pnResult = 9000) y el resto del paquete sigue funcionando.
-- No cambia la firma de ningun procedimiento existente.
--
-- ESCRIBE EN LA BASE. Ejecutar con F5 (Run Script), conectado como ADOPCION_APP.
-- 1) Primero revisa que nadie haya modificado el paquete desde la revision;
--    si cambio, se detiene SIN tocar nada.
-- 2) Reemplaza la especificacion y el cuerpo.
-- 3) Recompila lo que haya quedado invalido y muestra el estado (todo debe decir VALID).
-- Para deshacer: ejecutar la seccion de este paquete en respaldo_paquetes_originales.sql.
-- ============================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
   vnLineas NUMBER;
   vnChars  NUMBER;
BEGIN
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_QUERIES_EXTRAS' AND type = 'PACKAGE';
   IF vnLineas <> 22 OR vnChars <> 952 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE PKG_QUERIES_EXTRAS cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 22). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_QUERIES_EXTRAS' AND type = 'PACKAGE BODY';
   IF vnLineas <> 148 OR vnChars <> 4394 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE BODY PKG_QUERIES_EXTRAS cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 148). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   DBMS_OUTPUT.PUT_LINE('OK  PKG_QUERIES_EXTRAS sin cambios desde la revision.');
END;
/

WHENEVER SQLERROR CONTINUE

CREATE OR REPLACE PACKAGE pkg_queries_extras AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_parametro_faltante   CONSTANT NUMBER := 1020;
c_error_bd             CONSTANT NUMBER := 9000;

-- Disponibilidad de casas cuna por provincia, tipo de mascota aceptada y espacios libres mínimos
PROCEDURE pr_get_foster_home_availability (
   pnId_province  IN  NUMBER,     -- NULL = todas las provincias
   pnId_pet_type  IN  NUMBER,     -- NULL = todos los tipos de mascota aceptados
   pnMin_spots    IN  NUMBER,     -- Espacios libres mínimos. NULL = 1 (solo casas con espacio)
   p_cursor       OUT SYS_REFCURSOR);

-- Mascotas perdidas por tipo de mascota y provincia, ordenadas por recompensa de mayor a menor
PROCEDURE pr_get_lost_pets (
   pnId_pet_type  IN  NUMBER,     -- NULL = todos los tipos de mascota
   pnId_province  IN  NUMBER,     -- NULL = todas las provincias
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER);

-- Consulta de la bitácora (ADOPCION_AUDIT.ChangeLog). Todos los filtros son opcionales (NULL = todos).
-- Usuario, tabla y campo por coincidencia parcial; el texto se busca en el valor anterior, el nuevo
-- y la descripción. El usuario es el de la base que hizo el cambio (createdBy).
PROCEDURE pr_get_changelog (
   pcUsername     IN  VARCHAR2,
   pcTable_name   IN  VARCHAR2,
   pcField_name   IN  VARCHAR2,
   pcRecord_id    IN  VARCHAR2,
   pcText         IN  VARCHAR2,
   pdDate_from    IN  DATE,
   pdDate_to      IN  DATE,
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER);

-- Nombres de las tablas que aparecen en la bitácora (para el filtro de la pantalla)
PROCEDURE pr_get_changelog_tables (
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER);

END pkg_queries_extras;
/

CREATE OR REPLACE PACKAGE BODY pkg_queries_extras AS

-- Procedimiento que consulta la disponibilidad de las casas cuna, filtrando por provincia,
-- tipo de mascota que aceptan y cantidad mínima de espacios libres
PROCEDURE pr_get_foster_home_availability (
   pnId_province  IN  NUMBER,
   pnId_pet_type  IN  NUMBER,
   pnMin_spots    IN  NUMBER,
   p_cursor       OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT fh.idFosterHome AS id,
             TRIM(pe.firstName || ' ' || pe.firstLastName || ' ' || pe.secondLastName) AS ownerName,
             pv.id   AS provinceId,
             pv.name AS provinceName,
             ca.name AS cantonName,
             di.name AS districtName,
             lo.address,
             fs.name AS statusName,
             pt.id   AS petTypeId,
             pt.name AS petTypeName,
             fh.maxCapacity,
             (SELECT COUNT(1)
              FROM pet pe2
              WHERE pe2.idFosterHome = fh.idFosterHome) AS currentPets,
             fh.maxCapacity - (SELECT COUNT(1)
                               FROM pet pe2
                               WHERE pe2.idFosterHome = fh.idFosterHome) AS availableSpots,
             fh.requiresFoodDonation
      FROM fosterHome fh
      INNER JOIN person pe
      ON pe.id = fh.idFosterHome

      INNER JOIN location lo
      ON lo.id = fh.idLocation

      INNER JOIN district di
      ON di.id = lo.idDistrict

      INNER JOIN canton ca
      ON ca.id = di.idCanton

      INNER JOIN province pv
      ON pv.id = ca.idProvince

      INNER JOIN fosterHomeStatus fs
      ON fs.id = fh.idFosterHomeStatus

      INNER JOIN fosterHome_x_petType ft
      ON ft.idFosterHome = fh.idFosterHome

      INNER JOIN petType pt
      ON pt.id = ft.idPetType

      WHERE pv.id = NVL(pnId_province, pv.id)
      AND pt.id = NVL(pnId_pet_type, pt.id)
      AND fh.maxCapacity - (SELECT COUNT(1)
                            FROM pet pe2
                            WHERE pe2.idFosterHome = fh.idFosterHome) >= NVL(pnMin_spots, 1)

      ORDER BY pv.name, availableSpots DESC, ca.name, di.name, fh.idFosterHome, pt.name;
END pr_get_foster_home_availability;


-- Procedimiento que consulta las mascotas perdidas por tipo de mascota y provincia,
-- ordenadas por monto de recompensa de mayor a menor
PROCEDURE pr_get_lost_pets (
   pnId_pet_type  IN  NUMBER,
   pnId_province  IN  NUMBER,
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER)
AS
   vnStatus_lost  NUMBER;
BEGIN
   pnResult := c_exito;

   -- El estado "perdida" se obtiene del parámetro, igual que en pr_match_lost_found
   SELECT id INTO vnStatus_lost
   FROM petStatus
   WHERE name = pkg_parameter.fn_get_text('PET_STATUS_LOST');

   OPEN p_cursor FOR
      SELECT p.id,
             p.name,
             p.chipId,
             pt.name            AS typeName,
             pb.name            AS breedName,
             sz.name            AS sizeName,
             co.name            AS colorName,
             p.eventDate        AS lostDate,
             pv.name            AS provinceName,
             ca.name            AS cantonName,
             di.name            AS districtName,
             lo.address,
             p.idPerson         AS reporterId,
             pe.firstName       || ' ' || pe.firstLastName AS reporterName,
             cu.name            AS currencyName,
             rw.amount          AS rewardAmount,
             p.notesDescription
      FROM pet p
      INNER JOIN petBreed pb
      ON pb.id = p.idPetBreed

      INNER JOIN petType pt
      ON pt.id = pb.idPetType

      INNER JOIN petSize sz
      ON sz.id = p.idPetSize

      INNER JOIN petColor co
      ON co.id = p.idPetColor

      INNER JOIN location lo
      ON lo.id = p.idLocation

      INNER JOIN district di
      ON di.id = lo.idDistrict

      INNER JOIN canton ca
      ON ca.id = di.idCanton

      INNER JOIN province pv
      ON pv.id = ca.idProvince

      INNER JOIN person pe
      ON pe.id = p.idPerson

      LEFT  JOIN reward rw
      ON rw.idPet = p.id

      LEFT  JOIN currencyType cu
      ON cu.id = rw.idCurrencyType

      WHERE p.idPetStatus = vnStatus_lost
      AND pb.idPetType = NVL(pnId_pet_type, pb.idPetType)
      AND pv.id = NVL(pnId_province, pv.id)

      ORDER BY NVL(rw.amount, 0) DESC, p.eventDate DESC, p.id DESC;

EXCEPTION                                   -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      pnResult := c_parametro_faltante;
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_get_lost_pets;

-----------------------------------------------------------------------------------
------------------------------------ Bitácora -------------------------------------
-----------------------------------------------------------------------------------
-- La bitácora está en otro esquema (ADOPCION_AUDIT). Se consulta con SQL dinámico para que,
-- si falta el permiso de lectura, solo fallen estos dos procedimientos (pnResult = c_error_bd)
-- y no todo el paquete.

-- Procedimiento que consulta la bitácora con filtros opcionales
PROCEDURE pr_get_changelog (
   pcUsername     IN  VARCHAR2,
   pcTable_name   IN  VARCHAR2,
   pcField_name   IN  VARCHAR2,
   pcRecord_id    IN  VARCHAR2,
   pcText         IN  VARCHAR2,
   pdDate_from    IN  DATE,
   pdDate_to      IN  DATE,
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER)
AS
   vcUsername  VARCHAR2(4000) := LOWER(TRIM(pcUsername));
   vcTable     VARCHAR2(4000) := LOWER(TRIM(pcTable_name));
   vcField     VARCHAR2(4000) := LOWER(TRIM(pcField_name));
   vcRecord    VARCHAR2(4000) := TRIM(pcRecord_id);
   vcText      VARCHAR2(4000) := LOWER(TRIM(pcText));
   vdFrom      DATE          := TRUNC(pdDate_from);
   vdTo        DATE          := TRUNC(pdDate_to) + 1;
BEGIN
   pnResult := c_exito;

   -- Cada :valor se enlaza en orden en el USING (por eso algunos se repiten)
   OPEN p_cursor FOR
      'SELECT c.id,
              c.createdBy AS username,
              c.schemeName,
              c.tableName,
              c.fieldName,
              c.recordId,
              c.oldValue,
              c.newValue,
              c.changeDescription,
              c.changeDate
       FROM adopcion_audit.changeLog c
       WHERE (:u1 IS NULL OR LOWER(c.createdBy) LIKE ''%'' || :u2 || ''%'')
       AND (:t1 IS NULL OR LOWER(c.tableName) LIKE ''%'' || :t2 || ''%'')
       AND (:f1 IS NULL OR LOWER(c.fieldName) LIKE ''%'' || :f2 || ''%'')
       AND (:r1 IS NULL OR c.recordId = :r2)
       AND (:x1 IS NULL
            OR LOWER(c.oldValue) LIKE ''%'' || :x2 || ''%''
            OR LOWER(c.newValue) LIKE ''%'' || :x3 || ''%''
            OR LOWER(c.changeDescription) LIKE ''%'' || :x4 || ''%'')
       AND (:d1 IS NULL OR c.changeDate >= :d2)
       AND (:h1 IS NULL OR c.changeDate < :h2)
       ORDER BY c.changeDate DESC, c.id DESC'
   USING vcUsername, vcUsername,
         vcTable, vcTable,
         vcField, vcField,
         vcRecord, vcRecord,
         vcText, vcText, vcText, vcText,
         vdFrom, vdFrom,
         vdTo, vdTo;

EXCEPTION                                 -- Manejo de excepciones (ej. falta el permiso de lectura)
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_get_changelog;

-- Procedimiento que retorna los nombres de tabla presentes en la bitácora
PROCEDURE pr_get_changelog_tables (
   p_cursor       OUT SYS_REFCURSOR,
   pnResult       OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   OPEN p_cursor FOR
      'SELECT DISTINCT tableName
       FROM adopcion_audit.changeLog
       WHERE tableName IS NOT NULL
       ORDER BY tableName';

EXCEPTION                                 -- Manejo de excepciones
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_get_changelog_tables;

END pkg_queries_extras;
/

-- Recompila los objetos que dependian del paquete (solo los invalidos)
BEGIN
   DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE);
END;
/

-- Comprobacion: todo debe decir VALID
SHOW ERRORS PACKAGE PKG_QUERIES_EXTRAS
SHOW ERRORS PACKAGE BODY PKG_QUERIES_EXTRAS
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
AND (status <> 'VALID' OR object_name = 'PKG_QUERIES_EXTRAS')
ORDER BY object_name, object_type;
