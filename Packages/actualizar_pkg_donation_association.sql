-- ============================================================
-- actualizar_pkg_donation_association.sql
-- Actualiza PKG_ADMINISTRATION_DONATION_ASSOCIATION (codigo tomado de la base el 22/10/2026).
-- Cambios:
--   Agrega pr_update_donation_amount (cambiar el monto de una donacion).
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
   WHERE name = 'PKG_ADMINISTRATION_DONATION_ASSOCIATION' AND type = 'PACKAGE';
   IF vnLineas <> 52 OR vnChars <> 1555 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE PKG_ADMINISTRATION_DONATION_ASSOCIATION cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 52). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_ADMINISTRATION_DONATION_ASSOCIATION' AND type = 'PACKAGE BODY';
   IF vnLineas <> 292 OR vnChars <> 9889 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE BODY PKG_ADMINISTRATION_DONATION_ASSOCIATION cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 292). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   DBMS_OUTPUT.PUT_LINE('OK  PKG_ADMINISTRATION_DONATION_ASSOCIATION sin cambios desde la revision.');
END;
/

WHENEVER SQLERROR CONTINUE

CREATE OR REPLACE PACKAGE pkg_administration_donation_association AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_error_bd             CONSTANT NUMBER := 9000;

FUNCTION fn_association_exists ( pcName IN VARCHAR2) RETURN NUMBER;

PROCEDURE pr_register_association (
   pcName            IN  VARCHAR2,
   pnId_district     IN  NUMBER,
   pcAddress         IN  VARCHAR2,
   pnId_association  OUT NUMBER,
   pnResult          OUT NUMBER);

PROCEDURE pr_update_association (
   pnId_association  IN  NUMBER,
   pcName            IN  VARCHAR2,
   pnId_district     IN  NUMBER,
   pcAddress         IN  VARCHAR2,
   pnResult          OUT NUMBER);

PROCEDURE pr_get_associations_filtered (
   pnId_association IN  NUMBER,
   pnId_province    IN  NUMBER,
   pnId_canton      IN  NUMBER,
   pnId_district    IN  NUMBER,
   p_cursor         OUT SYS_REFCURSOR);

PROCEDURE pr_register_donation (
   pnId_person         IN  NUMBER,
   pnId_donation_type  IN  NUMBER,
   pnId_currency_type  IN  NUMBER,
   pnAmount            IN  NUMBER,
   pnId_reward         IN  NUMBER,
   pdDonation_date     IN  DATE,
   pcDistribution      IN  VARCHAR2,
   pnId_donation       OUT NUMBER,
   pnResult            OUT NUMBER);


PROCEDURE pr_get_donation_history (
   pdDate_from       IN  DATE,
   pdDate_to         IN  DATE,
   pnId_person       IN  NUMBER,
   pnId_association  IN  NUMBER,
   p_cursor          OUT SYS_REFCURSOR);

-- Cambia el monto total de una donación: recalcula el monto de cada asociación con su
-- porcentaje, igual que pr_register_donation (el trigger de DonationDetail lo registra en la bitácora)
PROCEDURE pr_update_donation_amount (
   pnId_donation  IN  NUMBER,
   pnAmount       IN  NUMBER,
   pnResult       OUT NUMBER);
END pkg_administration_donation_association;
/

CREATE OR REPLACE PACKAGE BODY pkg_administration_donation_association AS

-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo     EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,     -1400);    -- NULL en columna NOT NULL (INSERT)
eDatoNuloUpd  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNuloUpd,  -1407);    -- NULL en columna NOT NULL (UPDATE)
eDatoLargo    EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,    -12899);   -- valor mas largo que la columna
eNumeroGrande EXCEPTION;
PRAGMA EXCEPTION_INIT(eNumeroGrande, -1438);    -- numero con mas digitos de los permitidos
eCheckViolado EXCEPTION;
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);    -- CHECK (ej. porcentaje fuera de 1 a 100)
eFkNoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste,   -2291);    -- FK: distrito, persona, asociacion, tipo, moneda o recompensa no existe

-----------------------------------------------------------------------------------
-------------------------------- Asociaciones -------------------------------------
-----------------------------------------------------------------------------------

-- Función que verifica si ya existe una asociación con ese nombre
FUNCTION fn_association_exists ( pcName IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   SELECT 1
   INTO vnTest
   FROM animalWelfareAssociation
   WHERE name = LOWER(TRIM(pcName));

   RETURN 1;
EXCEPTION                         -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END fn_association_exists;


-- Procedimiento para el registro de una asociación a la BD
PROCEDURE pr_register_association (
   pcName            IN  VARCHAR2,
   pnId_district     IN  NUMBER,
   pcAddress         IN  VARCHAR2,
   pnId_association  OUT NUMBER,
   pnResult          OUT NUMBER)
AS
   vnId_location      NUMBER;
   vnId_association   NUMBER;
BEGIN
   pnResult := c_exito;

   pkg_person_administration.pr_insert_location(pnId_district, pcAddress, vnId_location);   -- Inserta la locación ingresada en la tabla Location

   INSERT INTO animalWelfareAssociation (id, idLocation, name)    -- Inserta la asociación de bienestar animal
   VALUES (s_animalWelfareAssociation.NEXTVAL, vnId_location, TRIM(pcName))
   RETURNING id INTO vnId_association;

   COMMIT;
   pnId_association := vnId_association;

EXCEPTION                                    -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_association;


-- Procedimiento para la actualización de datos de una asociación existente en la BD
PROCEDURE pr_update_association (
   pnId_association  IN  NUMBER,
   pcName            IN  VARCHAR2,
   pnId_district     IN  NUMBER,
   pcAddress         IN  VARCHAR2,
   pnResult          OUT NUMBER)
AS
   vnId_location     NUMBER;
   vnUpdate_result   NUMBER;
BEGIN
   pnResult := c_exito;

   -- Obtiene el idLocation de la association
   SELECT idLocation
   INTO vnId_location
   FROM animalWelfareAssociation
   WHERE id = pnId_association;

   -- Delega la actualización al procedimiento especializado
   pkg_person_administration.pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);

   -- Transfiere el resultado obtenido
   IF vnUpdate_result <> c_exito THEN
      pnResult := vnUpdate_result;
      RETURN;
   END IF;

   -- Actualiza el nombre de la associaation
   UPDATE animalWelfareAssociation
   SET name = TRIM(pcName)
   WHERE id = pnId_association;

   COMMIT;

EXCEPTION                                  -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_association;

-- Procedimiento getter universal para asociaciones con atributos calculados (donationCount y totalAmount)
PROCEDURE pr_get_associations_filtered (
   pnId_association IN  NUMBER,
   pnId_province    IN  NUMBER,
   pnId_canton      IN  NUMBER,
   pnId_district    IN  NUMBER,
   p_cursor         OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT a.id AS associationId,
         a.name AS associationName,
         lo.id AS locationId,
         lo.address,
         di.id AS districtId,
         di.name AS districtName,
         ca.id AS cantonId,
         ca.name AS cantonName,
         pv.id AS provinceId,
         pv.name AS provinceName,
         -- Atributos calculados basados en donationDetail
         NVL((SELECT COUNT(1)
              FROM donationDetail dd
              WHERE dd.idAnimalWelfareAssociation = a.id), 0) AS donationCount,
         NVL((SELECT SUM(dd.amount)
              FROM donationDetail dd
              WHERE dd.idAnimalWelfareAssociation = a.id), 0) AS totalAmount
      FROM animalWelfareAssociation a
      INNER JOIN location lo
      ON lo.id = a.idLocation

      INNER JOIN district di
      ON di.id = lo.idDistrict

      INNER JOIN canton ca
      ON ca.id = di.idCanton

      INNER JOIN province pv
      ON pv.id = ca.idProvince

      WHERE a.id  = NVL(pnId_association, a.id)
        AND pv.id = NVL(pnId_province, pv.id)
        AND ca.id = NVL(pnId_canton, ca.id)
        AND di.id = NVL(pnId_district, di.id)
      ORDER BY a.name;
END pr_get_associations_filtered;

-----------------------------------------------------------------------------------
---------------------------------- Donaciones -------------------------------------
-----------------------------------------------------------------------------------
-- Registro de una donación (soporta recompensas opcionales o voluntarias a una o múltiples asociaciones con porcentajes enteros)[cite: 3]
PROCEDURE pr_register_donation (
   pnId_person          IN  NUMBER,
   pnId_donation_type   IN  NUMBER,
   pnId_currency_type   IN  NUMBER,
   pnAmount             IN  NUMBER,
   pnId_reward          IN  NUMBER,
   pdDonation_date      IN  DATE,
   pcDistribution       IN  VARCHAR2,
   pnId_donation        OUT NUMBER,
   pnResult             OUT NUMBER)
AS
   vnId_donation      NUMBER;
   vnAmount           NUMBER;
   vnId_currency      NUMBER;
   vcList             VARCHAR2(4000);
   vcPair             VARCHAR2(50);
   vnId_association   NUMBER;
   vnPercentage       NUMBER;
   vnDetail_amount    NUMBER;
BEGIN
   pnResult := c_exito;

   -- Si se dona una recompensa (idReward opcional), el monto y la moneda salen de la recompensa[cite: 3]
   SELECT NVL((SELECT r.amount FROM reward r WHERE r.id = pnId_reward), pnAmount),
          NVL((SELECT r.idCurrencyType FROM reward r WHERE r.id = pnId_reward), pnId_currency_type)
   INTO vnAmount, vnId_currency
   FROM dual;

   -- Encabezado de la donacion en la tabla Donation[cite: 3]
   INSERT INTO donation (id, idPerson, idDonationType, idCurrencyType, idReward, donationDate)
   VALUES (s_donation.NEXTVAL, pnId_person, pnId_donation_type, vnId_currency, pnId_reward, NVL(pdDonation_date, SYSDATE))
   RETURNING id INTO vnId_donation;

   -- Detalle: procesa cada par 'idAsociacion:porcentaje'[cite: 3]
   vcList := TRIM(pcDistribution) || ',';
   WHILE INSTR(vcList, ',') > 0 LOOP
      vcPair := SUBSTR(vcList, 1, INSTR(vcList, ',') - 1);
      vcList := SUBSTR(vcList, INSTR(vcList, ',') + 1);

      vnId_association := TO_NUMBER(SUBSTR(vcPair, 1, INSTR(vcPair, ':') - 1));
      vnPercentage     := TO_NUMBER(SUBSTR(vcPair, INSTR(vcPair, ':') + 1));

      -- Calcula el monto para este porcentaje entero
      vnDetail_amount  := TRUNC(vnAmount * vnPercentage / 100, 2);

      INSERT INTO donationDetail (idAnimalWelfareAssociation, idDonation, amount, percentage)
      VALUES (vnId_association, vnId_donation, vnDetail_amount, vnPercentage);
   END LOOP;

   COMMIT;
   pnId_donation := vnId_donation;

EXCEPTION                                       -- Manejo de excepciones
   WHEN INVALID_NUMBER OR VALUE_ERROR THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_donation;

-- Consulta de donaciones con filtros por rango de fecha, donador y asociación
PROCEDURE pr_get_donation_history (
   pdDate_from       IN  DATE,
   pdDate_to         IN  DATE,
   pnId_person       IN  NUMBER,
   pnId_association  IN  NUMBER,
   p_cursor          OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT d.id AS donationId,
             d.donationDate,
             dt.name AS donationTypeName,
             p.id AS donorId,
             TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS donorName,
             a.id AS associationId,
             a.name AS associationName,
             c.name AS currencyName,
             dd.amount,
             dd.percentage
      FROM donation d
      INNER JOIN donationDetail dd
      ON dd.idDonation = d.id

      INNER JOIN animalWelfareAssociation a
      ON a.id = dd.idAnimalWelfareAssociation

      INNER JOIN person p
      ON p.id = d.idPerson

      INNER JOIN currencyType c
      ON c.id = d.idCurrencyType

      INNER JOIN donationType dt
      ON dt.id = d.idDonationType

      WHERE p.id = NVL(pnId_person, p.id)
        AND a.id = NVL(pnId_association, a.id)
        AND d.donationDate >= NVL(pdDate_from, d.donationDate)
        AND d.donationDate < TRUNC(NVL(pdDate_to, SYSDATE)) + 1
      ORDER BY d.donationDate DESC, d.id DESC, a.name;
END pr_get_donation_history;


-----------------------------------------------------------------------------------
--------------------------- Cambio de monto de donación ---------------------------
-----------------------------------------------------------------------------------
-- Procedimiento que cambia el monto total de una donación. El monto de cada asociación se
-- recalcula con su porcentaje entero, con el mismo cálculo de pr_register_donation.
PROCEDURE pr_update_donation_amount (
   pnId_donation  IN  NUMBER,
   pnAmount       IN  NUMBER,
   pnResult       OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   IF pnAmount IS NULL OR pnAmount <= 0 THEN       -- Monto vacío o no positivo
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   UPDATE donationDetail
   SET amount = TRUNC(pnAmount * percentage / 100, 2)
   WHERE idDonation = pnId_donation;

   IF SQL%ROWCOUNT = 0 THEN                         -- La donación no existe o no tiene detalle
      ROLLBACK;
      pnResult := c_referencia_no_existe;
      RETURN;
   END IF;

   COMMIT;

EXCEPTION                                       -- Manejo de excepciones
   WHEN eDatoNuloUpd OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_donation_amount;

END pkg_administration_donation_association;
/

-- Recompila los objetos que dependian del paquete (solo los invalidos)
BEGIN
   DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE);
END;
/

-- Comprobacion: todo debe decir VALID
SHOW ERRORS PACKAGE PKG_ADMINISTRATION_DONATION_ASSOCIATION
SHOW ERRORS PACKAGE BODY PKG_ADMINISTRATION_DONATION_ASSOCIATION
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
AND (status <> 'VALID' OR object_name = 'PKG_ADMINISTRATION_DONATION_ASSOCIATION')
ORDER BY object_name, object_type;
