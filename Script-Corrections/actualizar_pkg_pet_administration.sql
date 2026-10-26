-- ============================================================
-- actualizar_pkg_pet_administration.sql
-- Actualiza PKG_PET_ADMINISTRATION (codigo tomado de la base el 22/10/2026).
-- Cambios:
--   Corrige pr_query_pets (misma firma): incluye mascotas sin chip/fecha, nombre por
--     coincidencia parcial, no repite filas; agrega al FINAL del cursor los ids
--     (estado, tipo, raza, tamano, color, energia, severidad, entrenabilidad, pais,
--     provincia, canton, distrito, ubicacion, veterinario, recompensa y moneda).
--   Agrega pr_get_disease_treatments.
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
   WHERE name = 'PKG_PET_ADMINISTRATION' AND type = 'PACKAGE';
   IF vnLineas <> 119 OR vnChars <> 3678 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE PKG_PET_ADMINISTRATION cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 119). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_PET_ADMINISTRATION' AND type = 'PACKAGE BODY';
   IF vnLineas <> 644 OR vnChars <> 24459 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE BODY PKG_PET_ADMINISTRATION cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 644). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   DBMS_OUTPUT.PUT_LINE('OK  PKG_PET_ADMINISTRATION sin cambios desde la revision.');
END;
/

WHENEVER SQLERROR CONTINUE

CREATE OR REPLACE PACKAGE pkg_pet_administration AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_parametro_faltante   CONSTANT NUMBER := 1020;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_chip_existe          CONSTANT NUMBER := 1101;
c_error_bd             CONSTANT NUMBER := 9000;


FUNCTION fn_chipId_exists (pcChip_id IN VARCHAR2) RETURN NUMBER;

PROCEDURE pr_register_pet (
   pnId_person            IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_pet_status        IN  NUMBER,
   pnId_veterinarian      IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_district          IN  NUMBER,
   pcAddress              IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pcName                 IN  VARCHAR2,
   pnRequires_space       IN  NUMBER,
   pcNotes_description    IN  VARCHAR2,
   pcAbandonment_notes    IN  VARCHAR2,
   pnEstimated_age        IN  NUMBER,
   pdEvent_date           IN  DATE,
   pnId_pet               OUT NUMBER,
   pnResult               OUT NUMBER);

PROCEDURE pr_update_pet (
   pnId_pet               IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_pet_status        IN  NUMBER,
   pnId_veterinarian      IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_district          IN  NUMBER,
   pcAddress              IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pcName                 IN  VARCHAR2,
   pnRequires_space       IN  NUMBER,
   pcNotes_description    IN  VARCHAR2,
   pcAbandonment_notes    IN  VARCHAR2,
   pnEstimated_age        IN  NUMBER,
   pdEvent_date           IN  DATE,
   pnResult               OUT NUMBER);

PROCEDURE pr_insert_reward (
   pnId_pet            IN  NUMBER,
   pnId_currency_type  IN  NUMBER,
   pnReward_amount     IN  NUMBER,
   pnResult            OUT NUMBER);


PROCEDURE pr_insert_disease (
   pnId_pet      IN  NUMBER,
   pnId_disease  IN  NUMBER,
   pnResult      OUT NUMBER);

PROCEDURE pr_delete_disease (
   pnId_disease_remove IN NUMBER,
   pnId_pet            IN NUMBER,
   pnResult            OUT NUMBER);

PROCEDURE pr_query_pets (
   pnId_pet               IN  NUMBER,
   pcName                 IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pnId_pet_status        IN  NUMBER,
   pnId_pet_type          IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_province          IN  NUMBER,
   pnId_canton            IN  NUMBER,
   pnId_district          IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_disease           IN  NUMBER,
   pnId_person            IN  NUMBER,
   pdDate_from            IN  DATE,
   pdDate_to              IN  DATE,
   p_cursor               OUT SYS_REFCURSOR);


PROCEDURE pr_get_pet_diseases (
   pnId_pet  IN  NUMBER,
   p_cursor  OUT SYS_REFCURSOR);

-- Tratamientos de una enfermedad con su duración y, por cada uno, sus medicamentos y dosis
PROCEDURE pr_get_disease_treatments (
   pnId_disease  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR);

PROCEDURE pr_get_pet_contacts (
   pnId_pet  IN  NUMBER,
   p_cursor  OUT SYS_REFCURSOR);

PROCEDURE pr_unadopted_pets (
   p_cursor  OUT SYS_REFCURSOR,
   pnResult  OUT NUMBER);

PROCEDURE pr_match_lost_found (
   p_cursor  OUT SYS_REFCURSOR,
   pnResult  OUT NUMBER);

PROCEDURE pr_job_match_exec(
   pv_brevo_sender IN VARCHAR2 DEFAULT 'javalgonz@gmail.com');

END pkg_pet_administration;
/

CREATE OR REPLACE PACKAGE BODY pkg_pet_administration AS

-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo     EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,     -1400);    -- NULL en columna NOT NULL (INSERT)
eDatoNuloUpd  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNuloUpd,  -1407);    -- NULL en columna NOT NULL (UPDATE)
eDatoLargo    EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,    -12899);   -- valor mas largo que la columna
eCheckViolado EXCEPTION;
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);    -- CHECK (ej. requiresSpace distinto de 0 o 1)
eFkNoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste,   -2291);    -- FK: el registro padre no existe (catalogo, persona, distrito)

-------------------------------------------------------------------------
------------------- Verificacion de duplicados --------------------------
-------------------------------------------------------------------------

-- Función que verifica la existencia de una mascota con un chip de identificación en la BD
FUNCTION fn_chipId_exists (pcChip_id IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   -- Intenta seleccionar un 1 si el usuario existe
   SELECT 1
   INTO vnTest
   FROM pet
   WHERE chipId = TRIM(pcChip_id);

   RETURN 1;
EXCEPTION                                        -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      RETURN 0; -- Si no lo encontró, atrapa el error y retorna 0
END fn_chipId_exists;

-----------------------------------------------------------------------------------
------------------------- Registro y edicion Basica de Pet ------------------------
-----------------------------------------------------------------------------------
-- Procedimiento encargado del registro de una mascota con manejo de ubicación opcional
PROCEDURE pr_register_pet (
   pnId_person            IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_pet_status        IN  NUMBER,
   pnId_veterinarian      IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_district          IN  NUMBER,
   pcAddress              IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pcName                 IN  VARCHAR2,
   pnRequires_space       IN  NUMBER,
   pcNotes_description    IN  VARCHAR2,
   pcAbandonment_notes    IN  VARCHAR2,
   pnEstimated_age        IN  NUMBER,
   pdEvent_date           IN  DATE,
   pnId_pet               OUT NUMBER,
   pnResult               OUT NUMBER)
AS
   vnId_pet       NUMBER;
   vnId_location  NUMBER := NULL;
BEGIN
   pnResult := c_exito;

   -- Si se proporciona un distrito, se registra la ubicación; de lo contrario, queda NULL
   IF pnId_district IS NOT NULL THEN
      pkg_person_administration.pr_insert_location(pnId_district, pcAddress, vnId_location);
   END IF;

   -- Registra la mascota a la BD usando el idLocation (generado o nulo)
   INSERT INTO pet (id, idLocation, idPerson, idPetBreed, idPetSize, idPetColor, idPetSeverity,
                    idPetEnergy, idPetTrainability, idPetStatus, idVeterinarian, idFosterHome, chipId, name,
                    requiresSpace, notesDescription, abandonmentNotesDescription, estimatedAge, eventDate)
   VALUES (s_pet.NEXTVAL, vnId_location, pnId_person, pnId_pet_breed, pnId_pet_size, pnId_pet_color,
           pnId_pet_severity, pnId_pet_energy, pnId_pet_trainability, pnId_pet_status, pnId_veterinarian,
           pnId_foster_home, TRIM(pcChip_id), TRIM(pcName), pnRequires_space, TRIM(pcNotes_description), TRIM(pcAbandonment_notes),
           pnEstimated_age, pdEvent_date)
   RETURNING id INTO vnId_pet;

   COMMIT;
   pnId_pet := vnId_pet;

EXCEPTION                                             -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_chip_existe;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_pet;


-- Procedimiento encargado de actualizar los datos de una mascota y su ubicación
PROCEDURE pr_update_pet (
   pnId_pet               IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_pet_status        IN  NUMBER,
   pnId_veterinarian      IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_district          IN  NUMBER,
   pcAddress              IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pcName                 IN  VARCHAR2,
   pnRequires_space       IN  NUMBER,
   pcNotes_description    IN  VARCHAR2,
   pcAbandonment_notes    IN  VARCHAR2,
   pnEstimated_age        IN  NUMBER,
   pdEvent_date           IN  DATE,
   pnResult               OUT NUMBER)
AS
   vnId_location    NUMBER;
   vnUpdate_result  NUMBER;
BEGIN
   pnResult := c_exito;

   -- Obtener la ubicación actual que tiene la mascota en la BD
   SELECT idLocation INTO vnId_location
   FROM pet
   WHERE id = pnId_pet;

   -- Gestionar la ubicación según los parámetros recibidos
   IF pnId_district IS NOT NULL THEN
      IF vnId_location IS NOT NULL THEN
         -- Si ya tenía ubicación previa, se actualiza
         pkg_person_administration.pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);
         IF vnUpdate_result <> c_exito THEN
            pnResult := vnUpdate_result;
            RETURN;
         END IF;
      ELSE
         -- Si no tenía ubicación pero ahora se le asigna un distrito, se crea una nueva
         pkg_person_administration.pr_insert_location(pnId_district, pcAddress, vnId_location);
      END IF;
   ELSE
      -- Si se pasa distrito nulo, podemos limpiar la ubicación si así se desea
      vnId_location := NULL;
   END IF;

   -- Actualización de los datos básicos, estado y ubicación de la mascota
   UPDATE pet
   SET idPetBreed                  = pnId_pet_breed,
       idPetSize                   = pnId_pet_size,
       idPetColor                  = pnId_pet_color,
       idPetSeverity               = pnId_pet_severity,
       idPetEnergy                 = pnId_pet_energy,
       idPetTrainability           = pnId_pet_trainability,
       idPetStatus                 = pnId_pet_status,
       idVeterinarian              = pnId_veterinarian,
       idFosterHome                = pnId_foster_home,
       idLocation                  = vnId_location,
       chipId                      = TRIM(pcChip_id),
       name                        = TRIM(pcName),
       requiresSpace               = pnRequires_space,
       notesDescription            = TRIM(pcNotes_description),
       abandonmentNotesDescription = TRIM(pcAbandonment_notes),
       estimatedAge                = pnEstimated_age,
       eventDate                   = pdEvent_date
   WHERE id = pnId_pet;

   COMMIT;

EXCEPTION                                 -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_chip_existe;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_pet;


-----------------------------------------------------------------------------------
--------------------------------- Reward ------------------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar una recompensa vinculada a una mascota (permite múltiples si se vuelve a perder)
PROCEDURE pr_insert_reward (
   pnId_pet            IN  NUMBER,
   pnId_currency_type  IN  NUMBER,
   pnReward_amount     IN  NUMBER,
   pnResult            OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   -- Inserta la recompensa sin alterar estados ni ubicaciones de manera forzosa
   INSERT INTO reward (id, idPet, idCurrencyType, amount)
   VALUES (s_reward.NEXTVAL, pnId_pet, pnId_currency_type, pnReward_amount);

   COMMIT;
EXCEPTION                                       -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_insert_reward;


-----------------------------------------------------------------------------------
----------------------------- Operaciones Disease ---------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar una enfermedad a una mascota
PROCEDURE pr_insert_disease (
   pnId_pet      IN  NUMBER,
   pnId_disease  IN  NUMBER,
   pnResult      OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO disease_x_pet (idDisease, idPet)
   VALUES (pnId_disease, pnId_pet);

   COMMIT;
EXCEPTION                              -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_insert_disease;

-- Procedimiento para borrar una disease asociada a una mascota
PROCEDURE pr_delete_disease (
   pnId_disease_remove IN NUMBER,
   pnId_pet            IN NUMBER,
   pnResult            OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   DELETE FROM disease_x_pet
   WHERE idPet = pnId_pet
   AND idDisease = pnId_disease_remove;

   COMMIT;
EXCEPTION                     -- Manejo de excepciones
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_disease;


-----------------------------------------------------------------------------------
------------------------------- Consultas -----------------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento de consulta de mascota con filtros en atributos.
-- Todos los filtros son opcionales (NULL = todos). El nombre se busca por coincidencia parcial.
-- Corregido: incluye mascotas sin chip, sin ubicación o sin fecha, no repite filas cuando la
-- mascota tiene varias enfermedades o recompensas (se muestra la recompensa más reciente) y,
-- al final del cursor, devuelve los ids que la aplicación necesita para editar.
PROCEDURE pr_query_pets (
   pnId_pet               IN  NUMBER,
   pcName                 IN  VARCHAR2,
   pcChip_id              IN  VARCHAR2,
   pnId_pet_status        IN  NUMBER,
   pnId_pet_type          IN  NUMBER,
   pnId_pet_breed         IN  NUMBER,
   pnId_pet_size          IN  NUMBER,
   pnId_pet_color         IN  NUMBER,
   pnId_province          IN  NUMBER,
   pnId_canton            IN  NUMBER,
   pnId_district          IN  NUMBER,
   pnId_foster_home       IN  NUMBER,
   pnId_pet_severity      IN  NUMBER,
   pnId_pet_energy        IN  NUMBER,
   pnId_pet_trainability  IN  NUMBER,
   pnId_disease           IN  NUMBER,
   pnId_person            IN  NUMBER,
   pdDate_from            IN  DATE,
   pdDate_to              IN  DATE,
   p_cursor               OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT p.id,
             p.name,
             p.chipId,
             st.name            AS statusName,
             pt.name            AS typeName,
             pb.name            AS breedName,
             sz.name            AS sizeName,
             co.name            AS colorName,
             en.name            AS energyName,
             sv.name            AS severityName,
             tr.name            AS trainabilityName,
             p.requiresSpace,
             p.estimatedAge,
             p.eventDate,
             pv.name            AS provinceName,
             ca.name            AS cantonName,
             di.name            AS districtName,
             lo.address,
             p.idFosterHome     AS fosterHomeId,
             pf.firstName       || ' ' || pf.firstLastName AS fosterHomeName,
             p.idPerson         AS reporterId,
             pe.firstName       || ' ' || pe.firstLastName AS reporterName,
             cu.name            AS currencyName,
             rw.amount          AS rewardAmount,
             p.notesDescription,
             p.abandonmentNotesDescription,
             -- Columnas agregadas (ids para editar la mascota)
             p.idPetStatus,
             pb.idPetType,
             p.idPetBreed,
             p.idPetSize,
             p.idPetColor,
             p.idPetEnergy,
             p.idPetSeverity,
             p.idPetTrainability,
             cn.id              AS countryId,
             cn.name            AS countryName,
             pv.id              AS provinceId,
             ca.id              AS cantonId,
             di.id              AS districtId,
             lo.id              AS locationId,
             p.idVeterinarian   AS veterinarianId,
             TRIM(pvt.firstName || ' ' || pvt.firstLastName || ' ' || pvt.secondLastName) AS veterinarianName,
             rw.id              AS rewardId,
             rw.idCurrencyType  AS currencyId
      FROM pet p
      INNER JOIN petStatus st ON st.id = p.idPetStatus
      INNER JOIN petBreed pb ON pb.id = p.idPetBreed
      INNER JOIN petType pt ON pt.id = pb.idPetType
      INNER JOIN petSize sz ON sz.id = p.idPetSize
      INNER JOIN petColor co ON co.id = p.idPetColor
      INNER JOIN petEnergy en ON en.id = p.idPetEnergy
      INNER JOIN petSeverity sv ON sv.id = p.idPetSeverity
      INNER JOIN petTrainability tr ON tr.id = p.idPetTrainability
      INNER JOIN person pe ON pe.id = p.idPerson
      LEFT  JOIN location lo ON lo.id = p.idLocation
      LEFT  JOIN district di ON di.id = lo.idDistrict
      LEFT  JOIN canton ca ON ca.id = di.idCanton
      LEFT  JOIN province pv ON pv.id = ca.idProvince
      LEFT  JOIN country cn ON cn.id = pv.idCountry
      LEFT  JOIN person pf ON pf.id = p.idFosterHome
      LEFT  JOIN veterinarian vt ON vt.id = p.idVeterinarian
      LEFT  JOIN person pvt ON pvt.id = vt.idPerson
      LEFT  JOIN reward rw ON rw.id = (SELECT MAX(r2.id)          -- Recompensa más reciente
                                       FROM reward r2
                                       WHERE r2.idPet = p.id)
      LEFT  JOIN currencyType cu ON cu.id = rw.idCurrencyType
      WHERE (pnId_pet IS NULL OR p.id = pnId_pet)
      AND (TRIM(pcName) IS NULL OR LOWER(p.name) LIKE '%' || LOWER(TRIM(pcName)) || '%')
      AND (TRIM(pcChip_id) IS NULL OR p.chipId = TRIM(pcChip_id))
      AND (pnId_pet_status IS NULL OR p.idPetStatus = pnId_pet_status)
      AND (pnId_pet_type IS NULL OR pb.idPetType = pnId_pet_type)
      AND (pnId_pet_breed IS NULL OR p.idPetBreed = pnId_pet_breed)
      AND (pnId_pet_size IS NULL OR p.idPetSize = pnId_pet_size)
      AND (pnId_pet_color IS NULL OR p.idPetColor = pnId_pet_color)
      AND (pnId_province IS NULL OR pv.id = pnId_province)
      AND (pnId_canton IS NULL OR ca.id = pnId_canton)
      AND (pnId_district IS NULL OR di.id = pnId_district)
      AND (pnId_foster_home IS NULL OR p.idFosterHome = pnId_foster_home)
      AND (pnId_pet_severity IS NULL OR p.idPetSeverity = pnId_pet_severity)
      AND (pnId_pet_energy IS NULL OR p.idPetEnergy = pnId_pet_energy)
      AND (pnId_pet_trainability IS NULL OR p.idPetTrainability = pnId_pet_trainability)
      AND (pnId_disease IS NULL OR EXISTS (SELECT 1
                                           FROM disease_x_pet dp
                                           WHERE dp.idPet = p.id
                                           AND dp.idDisease = pnId_disease))
      AND (pnId_person IS NULL OR p.idPerson = pnId_person)
      AND (pdDate_from IS NULL OR p.eventDate >= TRUNC(pdDate_from))
      AND (pdDate_to IS NULL OR p.eventDate < TRUNC(pdDate_to) + 1)
      ORDER BY p.eventDate DESC NULLS LAST, p.id DESC;
END pr_query_pets;


-- Procedimiento que retorna las enfermedades de una mascota
PROCEDURE pr_get_pet_diseases (
   pnId_pet  IN  NUMBER,
   p_cursor  OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT d.id,
             d.name
      FROM disease d
      JOIN disease_x_pet dp ON dp.idDisease = d.id
      WHERE dp.idPet = pnId_pet
      ORDER BY d.name;
END pr_get_pet_diseases;

-- Procedimiento que retorna los contactos de la persona que registró la mascota
PROCEDURE pr_get_pet_contacts (
   pnId_pet  IN  NUMBER,
   p_cursor  OUT SYS_REFCURSOR)
AS
   vnId_person NUMBER;
BEGIN
   SELECT idPerson INTO vnId_person
   FROM pet
   WHERE id = pnId_pet;

   pkg_person_administration.pr_get_person_contacts(vnId_person, p_cursor);

EXCEPTION                                     -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      NULL;
   WHEN OTHERS THEN
      NULL;
END pr_get_pet_contacts;

-----------------------------------------------------------------------------------
------------------------ Tratamientos de una enfermedad ---------------------------
-----------------------------------------------------------------------------------
-- Procedimiento que retorna los tratamientos de una enfermedad (con su duración) y los
-- medicamentos de cada tratamiento (con su dosis). Una fila por tratamiento y medicamento;
-- un tratamiento sin medicamentos aparece una vez con el medicamento en NULL.
PROCEDURE pr_get_disease_treatments (
   pnId_disease  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT t.id          AS treatmentId,
             t.name        AS treatmentName,
             td.timeLength,
             m.id          AS medicationId,
             m.name        AS medicationName,
             mt.dosage
      FROM treatment_x_disease td
      INNER JOIN treatment t ON t.id = td.idTreatment
      LEFT  JOIN medication_x_treatment mt ON mt.idTreatment = t.id
      LEFT  JOIN medication m ON m.id = mt.idMedication
      WHERE td.idDisease = pnId_disease
      ORDER BY t.name, m.name;
END pr_get_disease_treatments;

-----------------------------------------------------------------------------------
-------------------- Mascotas sin adoptar y match perdidas/encontradas ------------
-----------------------------------------------------------------------------------
-- Procedimiento que devuelve las mascotas no adoptadas por tiempo parametrizable
PROCEDURE pr_unadopted_pets (
   p_cursor  OUT SYS_REFCURSOR,
   pnResult  OUT NUMBER)
AS
   vcStatus_in_adoption  VARCHAR2(30);
   vnMonths              NUMBER;
BEGIN
   pnResult := c_exito;

   vcStatus_in_adoption := pkg_parameter.fn_get_text('PET_STATUS_IN_ADOPTION');
   vnMonths := pkg_parameter.fn_get_number('UNADOPTED_ALERT_MONTHS');

   OPEN p_cursor FOR
      SELECT p.id,
             p.name,
             pt.name AS typeName,
             pb.name AS breedName,
             p.estimatedAge,
             p.eventDate,
             TRUNC(MONTHS_BETWEEN(SYSDATE, p.eventDate)) AS monthsWaiting
      FROM pet p
      JOIN petBreed pb ON pb.id = p.idPetBreed
      JOIN petType pt ON pt.id = pb.idPetType
      JOIN petStatus st ON st.id = p.idPetStatus
      LEFT JOIN adoption a ON a.idPet = p.id
      WHERE st.name = vcStatus_in_adoption
      AND p.eventDate <= ADD_MONTHS(SYSDATE, -vnMonths)
      AND a.id IS NULL
      ORDER BY p.eventDate;

EXCEPTION                                        -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      pnResult := c_parametro_faltante;
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_unadopted_pets;

-- Procedimiento de match de mascotas en estado encontrada y perdida (Para el job)
PROCEDURE pr_match_lost_found (
   p_cursor  OUT SYS_REFCURSOR,
   pnResult  OUT NUMBER)
AS
   vnStatus_lost   NUMBER;
   vnStatus_found  NUMBER;
   vnW_breed       NUMBER;
   vnW_color       NUMBER;
   vnW_size        NUMBER;
   vnW_canton      NUMBER;
   vnW_chip        NUMBER;
   vnMin_score     NUMBER;
BEGIN
   pnResult := c_exito;

   SELECT id INTO vnStatus_lost
   FROM petStatus
   WHERE name = pkg_parameter.fn_get_text('PET_STATUS_LOST');

   SELECT id INTO vnStatus_found
   FROM petStatus
   WHERE name = pkg_parameter.fn_get_text('PET_STATUS_FOUND');

   vnW_breed   := pkg_parameter.fn_get_number('MATCH_WEIGHT_BREED');
   vnW_color   := pkg_parameter.fn_get_number('MATCH_WEIGHT_COLOR');
   vnW_size    := pkg_parameter.fn_get_number('MATCH_WEIGHT_SIZE');
   vnW_canton  := pkg_parameter.fn_get_number('MATCH_WEIGHT_CANTON');
   vnW_chip    := pkg_parameter.fn_get_number('MATCH_WEIGHT_CHIP');
   vnMin_score := pkg_parameter.fn_get_number('MATCH_MIN_SCORE');

   OPEN p_cursor FOR
      SELECT m.*
      FROM (SELECT l.id           AS lostPetId,
                   l.name         AS lostPetName,
                   lb.name        AS lostBreedName,
                   lc.name        AS lostColorName,
                   ls.name        AS lostSizeName,
                   l.eventDate    AS lostDate,
                   lca.name       AS lostCantonName,
                   lpe.firstName  || ' ' || lpe.firstLastName AS lostReporterName,
                   f.id           AS foundPetId,
                   f.name         AS foundPetName,
                   fb.name        AS foundBreedName,
                   fc.name        AS foundColorName,
                   fs.name        AS foundSizeName,
                   f.eventDate    AS foundDate,
                   fca.name       AS foundCantonName,
                   fpe.firstName  || ' ' || fpe.firstLastName AS foundReporterName,
                   (CASE WHEN l.idPetBreed = f.idPetBreed THEN vnW_breed ELSE 0 END
                    + CASE WHEN l.idPetColor = f.idPetColor THEN vnW_color ELSE 0 END
                    + CASE WHEN l.idPetSize = f.idPetSize THEN vnW_size ELSE 0 END
                    + CASE WHEN dl.idCanton = df.idCanton THEN vnW_canton ELSE 0 END
                    + CASE WHEN l.chipId = f.chipId THEN vnW_chip ELSE 0 END) AS matchScore
            FROM pet l
            JOIN petBreed lb ON lb.id = l.idPetBreed
            JOIN petColor lc ON lc.id = l.idPetColor
            JOIN petSize ls ON ls.id = l.idPetSize
            JOIN location ll ON ll.id = l.idLocation
            JOIN district dl ON dl.id = ll.idDistrict
            JOIN canton lca ON lca.id = dl.idCanton
            JOIN person lpe ON lpe.id = l.idPerson
            JOIN pet f ON f.idPetStatus = vnStatus_found
            JOIN petBreed fb ON fb.id = f.idPetBreed
            JOIN petColor fc ON fc.id = f.idPetColor
            JOIN petSize fs ON fs.id = f.idPetSize
            JOIN location fl ON fl.id = f.idLocation
            JOIN district df ON df.id = fl.idDistrict
            JOIN canton fca ON fca.id = df.idCanton
            JOIN person fpe ON fpe.id = f.idPerson
            WHERE l.idPetStatus = vnStatus_lost
            AND fb.idPetType = lb.idPetType
            AND (l.eventDate IS NULL OR f.eventDate IS NULL OR f.eventDate >= l.eventDate)) m
      WHERE m.matchScore >= vnMin_score
      ORDER BY m.matchScore DESC, m.foundDate DESC;

EXCEPTION                                   -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      pnResult := c_parametro_faltante;
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_match_lost_found;

-- Procedimiento llamado por el JOB
PROCEDURE pr_job_match_exec (
   pv_brevo_sender IN VARCHAR2 DEFAULT 'javalgonz@gmail.com'
) AS
   v_cursor SYS_REFCURSOR;
   v_result NUMBER;

   TYPE t_match_rec IS RECORD (
      lostPetId         NUMBER,
      lostPetName       VARCHAR2(50),
      lostBreedName     VARCHAR2(50),
      lostColorName     VARCHAR2(50),
      lostSizeName      VARCHAR2(50),
      lostDate          DATE,
      lostCantonName    VARCHAR2(50),
      lostReporterName  VARCHAR2(100),
      foundPetId        NUMBER,
      foundPetName      VARCHAR2(50),
      foundBreedName    VARCHAR2(50),
      foundColorName    VARCHAR2(50),
      foundSizeName     VARCHAR2(50),
      foundDate         DATE,
      foundCantonName   VARCHAR2(50),
      foundReporterName VARCHAR2(100),
      matchScore        NUMBER
   );

   rec t_match_rec;
   v_html_body VARCHAR2(4000);
BEGIN
   pr_match_lost_found(v_cursor, v_result);

   IF v_result = 0 AND v_cursor IS NOT NULL THEN

      LOOP
         FETCH v_cursor INTO rec;
         EXIT WHEN v_cursor%NOTFOUND;

         INSERT INTO PetMatch(id, idLostPet, idFoundPet, matchDate, matchScore, notified)
         SELECT s_match.NEXTVAL, rec.lostPetId, rec.foundPetId, SYSDATE, rec.matchScore, 0
         FROM DUAL
         WHERE NOT EXISTS (
            SELECT 1 FROM PetMatch
            WHERE idLostPet = rec.lostPetId AND idFoundPet = rec.foundPetId
         );
      END LOOP;

      CLOSE v_cursor;

      -- Servicio de envios de correo
      FOR p IN (
         -- SELECT DISTINCT para que no devuelva el mismo dato (id, correo) más de una vez
         SELECT DISTINCT p.id AS person_id, ce.email, p.firstName || ' ' || p.firstLastName AS person_name
         FROM PetMatch pm
         JOIN Pet pet_l ON pm.idLostPet = pet_l.id
         JOIN Pet pet_f ON pm.idFoundPet = pet_f.id
         JOIN Person p ON p.id IN (pet_l.idPerson, pet_f.idPerson)
         JOIN ContactEmail ce ON ce.idPerson = p.id
         WHERE pm.notified = 0 AND (ce.email IS NOT NULL AND TRIM(ce.email) IS NOT NULL)
      ) LOOP
         v_html_body := '<h2>Coincidencias de Mascotas Encontradas</h2><ul>';

         FOR m IN (
            SELECT pl.name AS lost_name, pf.name AS found_name, pm.matchScore,
               (SELECT photoURL FROM Photo ph WHERE ph.idPet = pf.id AND ROWNUM = 1) AS found_photo
            FROM PetMatch pm
            JOIN Pet pl ON pm.idLostPet = pl.id
            JOIN Pet pf ON pm.idFoundPet = pf.id
            WHERE (pl.idPerson = p.person_id OR pf.idPerson = p.person_id)
                      AND pm.notified = 0
         ) LOOP
            v_html_body := v_html_body ||
               '<li style="margin-bottom: 15px; list-style: none;">' ||
               '  <table style="border-collapse: collapse;">' ||
               '    <tr>' ||
               '      <td style="padding-right: 15px; vertical-align: top;">' ||
               '        <img src="' || m.found_photo || '" alt="Foto Mascota" ' ||
               '             style="width: 120px; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #ccc;" />' ||
               '      </td>' ||
               '      <td style="vertical-align: top;">' ||
               '        <p style="margin: 0 0 5px 0;"><b>Mascota Perdida:</b> ' || NVL(m.lost_name, 'Sin nombre') || '</p>' ||
               '        <p style="margin: 0 0 5px 0;"><b>Encontrada:</b> ' || NVL(m.found_name, 'Sin nombre') || '</p>' ||
               '        <p style="margin: 0; color: #27ae60;"><b>Coincidencia:</b> ' || m.matchScore || '%</p>' ||
               '      </td>' ||
               '    </tr>' ||
               '  </table>' ||
               '</li><br>';
         END LOOP;

         v_html_body := v_html_body || '</ul>';

         BEGIN
            UTL_MAIL.send(
               sender      => pv_brevo_sender,
               recipients  => p.email,
               subject     => 'Coincidencia detectada de mascota',
               message     => v_html_body,
               mime_type   => 'text/html; chartset=UTF-8'
            );
         END;
      END LOOP;

      UPDATE PetMatch SET notified = 1 WHERE notified = 0;
      COMMIT;

   END IF;
END pr_job_match_exec;

END pkg_pet_administration;
/

-- Recompila los objetos que dependian del paquete (solo los invalidos)
BEGIN
   DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE);
END;
/

-- Comprobacion: todo debe decir VALID
SHOW ERRORS PACKAGE PKG_PET_ADMINISTRATION
SHOW ERRORS PACKAGE BODY PKG_PET_ADMINISTRATION
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
AND (status <> 'VALID' OR object_name = 'PKG_PET_ADMINISTRATION')
ORDER BY object_name, object_type;
