create or replace PACKAGE pkg_person_administration AS

-- Códigos de resultado (todos declarados para evitar el error PLS-00201)
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_persona_no_existe    CONSTANT NUMBER := 1010;
c_ubicacion_no_existe  CONSTANT NUMBER := 1011;
c_ultimo_contacto      CONSTANT NUMBER := 1012;   -- La persona debe conservar al menos un correo o un teléfono
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_error_bd             CONSTANT NUMBER := 9000;

FUNCTION fn_person_exists (pnId_person IN NUMBER) RETURN NUMBER;
FUNCTION fn_email_exists  (pcEmail     IN VARCHAR2) RETURN NUMBER;
FUNCTION fn_phone_exists  (pcPhone     IN VARCHAR2) RETURN NUMBER;

-- Ubicación
PROCEDURE pr_insert_location (
   pnId_district  IN  NUMBER,
   pcAddress      IN  VARCHAR2,
   pnId_location  OUT NUMBER);

PROCEDURE pr_update_location (
   pnId_location  IN  NUMBER,
   pnId_district  IN  NUMBER,
   pcAddress      IN  VARCHAR2,
   pnResult       OUT NUMBER);

-- Contactos de una persona (correos y teléfonos)
PROCEDURE pr_add_email (
   pnId_person IN  NUMBER,
   pcEmail     IN  VARCHAR2,
   pnResult    OUT NUMBER);

PROCEDURE pr_delete_email (
   pnId_person IN  NUMBER,
   pnId_email  IN  NUMBER,
   pnResult    OUT NUMBER);

PROCEDURE pr_add_phone (
   pnId_person IN  NUMBER,
   pcPhone     IN  VARCHAR2,
   pnResult    OUT NUMBER);

PROCEDURE pr_delete_phone (
   pnId_person IN  NUMBER,
   pnId_phone  IN  NUMBER,
   pnResult    OUT NUMBER);

PROCEDURE pr_get_person_contacts (
   pnId_person  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR);

-- Personas
PROCEDURE pr_register_person (
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnId_district      IN  NUMBER,
   pcAddress          IN  VARCHAR2,
   pcPhone            IN  VARCHAR2,
   pcEmail            IN  VARCHAR2,
   pnId_person        OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_update_person_location (
   pnId_person   IN  NUMBER,
   pnId_district IN  NUMBER,
   pcAddress     IN  VARCHAR2,
   pnResult      OUT NUMBER);

PROCEDURE pr_get_persons (
   pnId_person    IN  NUMBER,
   pnId_province  IN  NUMBER,
   pnId_canton    IN  NUMBER,
   pnId_district  IN  NUMBER,
   p_cursor       OUT SYS_REFCURSOR);

-- Adoptantes
PROCEDURE pr_register_adopter (
   pnId_person         IN  NUMBER,
   pnId_house_type     IN  NUMBER,
   pnHas_yard          IN  NUMBER,
   pnId_exercise_time  IN  NUMBER,
   pcOther_pet_breeds  IN  VARCHAR2,
   pnResult            OUT NUMBER);

PROCEDURE pr_get_adopter (
   pnId_adopter  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR);

PROCEDURE pr_get_other_pets (
   pnId_adopter  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR);

-- Casas cuna
PROCEDURE pr_register_foster_home (
   pnId_person               IN  NUMBER,
   pnId_district             IN  NUMBER,
   pcAddress                 IN  VARCHAR2,
   pnId_foster_home_status   IN  NUMBER,
   pnMax_capacity            IN  NUMBER,
   pnRequires_food_donation  IN  NUMBER,
   pcPet_types               IN  VARCHAR2,
   pcPet_sizes               IN  VARCHAR2,
   pnResult                  OUT NUMBER);

PROCEDURE pr_get_foster_homes (
   pnId_foster_home IN  NUMBER,
   pnId_province    IN  NUMBER,
   pnId_canton      IN  NUMBER,
   pnId_district    IN  NUMBER,
   pnId_pet_type    IN  NUMBER,
   pnId_pet_size    IN  NUMBER,
   pnOnly_available IN  NUMBER,
   p_cursor         OUT SYS_REFCURSOR);

PROCEDURE pr_get_foster_home_accepts (
   pnId_foster_home  IN  NUMBER,
   p_cursor          OUT SYS_REFCURSOR);

-- Veterinarios
PROCEDURE pr_register_veterinarian (
   pnId_person        IN  NUMBER,
   pnId_veterinarian  OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_query_veterinarians (
   p_cursor  OUT SYS_REFCURSOR);

-- Lista negra y reputación
PROCEDURE pr_add_blacklist (
   pnId_person  IN  NUMBER,
   pcReason     IN  VARCHAR2,
   pnResult     OUT NUMBER);

PROCEDURE pr_report_blacklist (
   pnOnly_adopters  IN  NUMBER,
   p_cursor         OUT SYS_REFCURSOR);

PROCEDURE pr_get_person_ratings (
   pnId_person  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR);

-- Edición de los nombres de una persona (la ubicación se cambia con pr_update_person_location)
PROCEDURE pr_update_person_names (
   pnId_person        IN  NUMBER,
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnResult           OUT NUMBER);

-- Edición de una casa cuna: ubicación, estado, capacidad, donación de alimento y lo que acepta.
-- pcPet_types y pcPet_sizes con el mismo formato de pr_register_foster_home ('1,2,3');
-- reemplazan por completo los tipos y tamaños aceptados.
PROCEDURE pr_update_foster_home (
   pnId_foster_home          IN  NUMBER,
   pnId_district             IN  NUMBER,
   pcAddress                 IN  VARCHAR2,
   pnId_foster_home_status   IN  NUMBER,
   pnMax_capacity            IN  NUMBER,
   pnRequires_food_donation  IN  NUMBER,
   pcPet_types               IN  VARCHAR2,
   pcPet_sizes               IN  VARCHAR2,
   pnResult                  OUT NUMBER);

-- Elimina un reporte de la lista negra (pnId_blacklist = blacklistId de pr_report_blacklist)
PROCEDURE pr_delete_blacklist (
   pnId_blacklist  IN  NUMBER,
   pnResult        OUT NUMBER);

END pkg_person_administration;


create or replace PACKAGE BODY pkg_person_administration AS

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
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);    -- CHECK (ej. hasYard distinto de 0 o 1)
eFkNoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste,   -2291);    -- FK: el registro padre no existe

-------------------------------------------------------------------------
-------------------- Ubicación y contactos de la persona ----------------
-------------------------------------------------------------------------

PROCEDURE pr_insert_contacts (
   pnId_person  IN  NUMBER,
   pcEmail      IN  VARCHAR2,
   pcPhone      IN  VARCHAR2)
AS
BEGIN
   INSERT INTO contactEmail (id, idPerson, email)
   VALUES (s_contactEmail.NEXTVAL, pnId_person, TRIM(pcEmail));

   INSERT INTO contactNumber (id, idPerson, phoneNumber)
   VALUES (s_contactNumber.NEXTVAL, pnId_person, TRIM(pcPhone));
END pr_insert_contacts;

-------------------------------------------------------------------------
------------------- Verificaciones de existencia ------------------------
-------------------------------------------------------------------------

FUNCTION fn_person_exists (pnId_person IN NUMBER)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   SELECT 1
   INTO vnTest
   FROM person
   WHERE id = pnId_person;

   RETURN 1;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END fn_person_exists;

FUNCTION fn_email_exists (pcEmail IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   SELECT 1
   INTO vnTest
   FROM contactEmail
   WHERE LOWER(email) = LOWER(TRIM(pcEmail));

   RETURN 1;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END fn_email_exists;

FUNCTION fn_phone_exists (pcPhone IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   SELECT 1
   INTO vnTest
   FROM contactNumber
   WHERE phoneNumber = TRIM(pcPhone);

   RETURN 1;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END fn_phone_exists;

-----------------------------------------------------------------------------------
--------------------- Insertar y actualizar locación ------------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_insert_location (
   pnId_district  IN  NUMBER,
   pcAddress      IN  VARCHAR2,
   pnId_location  OUT NUMBER)
AS
BEGIN
   INSERT INTO location (id, idDistrict, address)
   VALUES (s_location.NEXTVAL, pnId_district, TRIM(pcAddress))
   RETURNING id INTO pnId_location;
END pr_insert_location;

PROCEDURE pr_update_location (
   pnId_location  IN  NUMBER,
   pnId_district  IN  NUMBER,
   pcAddress      IN  VARCHAR2,
   pnResult       OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   UPDATE location
   SET idDistrict = pnId_district,
       address    = TRIM(pcAddress)
   WHERE id = pnId_location;

EXCEPTION
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_ubicacion_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_location;

-----------------------------------------------------------------------------------
------------------------ Insertar y eliminar email --------------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_add_email (
   pnId_person IN  NUMBER,
   pcEmail     IN  VARCHAR2,
   pnResult    OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO contactEmail (id, idPerson, email)
   VALUES (s_contactEmail.NEXTVAL, pnId_person, TRIM(pcEmail));

   COMMIT;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_email;

PROCEDURE pr_delete_email (
   pnId_person IN  NUMBER,
   pnId_email  IN  NUMBER,
   pnResult    OUT NUMBER)
AS
   vnEmailCount NUMBER;
BEGIN
   pnResult := c_exito;

   SELECT COUNT(1)
   INTO vnEmailCount
   FROM contactEmail
   WHERE idPerson = pnId_person;

   IF vnEmailCount <= 1 THEN
      pnResult := c_ultimo_contacto;
      RETURN;
   END IF;

   DELETE FROM contactEmail
   WHERE id = pnId_email
   AND idPerson = pnId_person;

   COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_email;

-----------------------------------------------------------------------------------
---------------------- Insertar y eliminar un teléfono ----------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_add_phone (
   pnId_person IN  NUMBER,
   pcPhone     IN  VARCHAR2,
   pnResult    OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO contactNumber (id, idPerson, phoneNumber)
   VALUES (s_contactNumber.NEXTVAL, pnId_person, TRIM(pcPhone));

   COMMIT;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_phone;

PROCEDURE pr_delete_phone (
   pnId_person IN  NUMBER,
   pnId_phone  IN  NUMBER,
   pnResult    OUT NUMBER)
AS
   vnPhoneCount NUMBER;
BEGIN
   pnResult := c_exito;

   SELECT COUNT(1)
   INTO vnPhoneCount
   FROM contactNumber
   WHERE idPerson = pnId_person;

   IF vnPhoneCount <= 1 THEN
      pnResult := c_ultimo_contacto;
      RETURN;
   END IF;

   DELETE FROM contactNumber
   WHERE id = pnId_phone
   AND idPerson = pnId_person;

   COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_phone;

PROCEDURE pr_get_person_contacts (
   pnId_person  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT 'EMAIL' AS contactType,
             id AS contactId,
             email AS contactValue
      FROM  contactEmail
      WHERE idPerson = pnId_person
      UNION ALL
      SELECT 'PHONE' AS contactType,
             id AS contactId,
             phoneNumber AS contactValue
      FROM contactNumber
      WHERE idPerson = pnId_person
      ORDER BY contactType, contactValue;
END pr_get_person_contacts;

-----------------------------------------------------------------------------------
---------------------------------- Personas ---------------------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_register_person (
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnId_district      IN  NUMBER,
   pcAddress          IN  VARCHAR2,
   pcPhone            IN  VARCHAR2,
   pcEmail            IN  VARCHAR2,
   pnId_person        OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_location      NUMBER;
   vnId_person        NUMBER;
BEGIN
   pnResult := c_exito;

   pr_insert_location(pnId_district, pcAddress, vnId_location);

   INSERT INTO person (id, idLocation, firstName, middleName, firstLastName, secondLastName)
   VALUES (s_person.NEXTVAL, vnId_location, TRIM(pcFirst_name), TRIM(pcMiddle_name), TRIM(pcFirst_lastName), TRIM(pcSecond_lastName))
   RETURNING id INTO vnId_person;

   pr_insert_contacts(vnId_person, pcEmail, pcPhone);

   pnId_person := vnId_person;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_ubicacion_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_person;

PROCEDURE pr_update_person_location (
   pnId_person   IN  NUMBER,
   pnId_district IN  NUMBER,
   pcAddress     IN  VARCHAR2,
   pnResult      OUT NUMBER)
AS
   vnId_location   NUMBER;
   vnUpdate_result  NUMBER;
BEGIN
   pnResult := c_exito;

   SELECT idLocation
   INTO vnId_location
   FROM person
   WHERE id = pnId_person;

   pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);

   IF vnUpdate_result <> c_exito THEN
      pnResult := vnUpdate_result;
      RETURN;
   END IF;

   COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_person_location;

PROCEDURE pr_get_persons (
   pnId_person    IN  NUMBER,
   pnId_province  IN  NUMBER,
   pnId_canton    IN  NUMBER,
   pnId_district  IN  NUMBER,
   p_cursor       OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT p.id,
             p.firstName      AS firstName,
             p.middleName     AS middleName,
             p.firstLastName  AS firstLastName,
             p.secondLastName AS secondLastName,
             lo.id   AS locationId,
             lo.address,
             di.id   AS districtId,
             di.name AS districtName,
             ca.id   AS cantonId,
             ca.name AS cantonName,
             pv.id   AS provinceId,
             pv.name AS provinceName
      FROM person p
      INNER JOIN location lo ON lo.id = p.idLocation
      INNER JOIN district di ON di.id = lo.idDistrict
      INNER JOIN canton ca ON ca.id = di.idCanton
      INNER JOIN province pv ON pv.id = ca.idProvince
      WHERE p.id  = NVL(pnId_person, p.id)
        AND pv.id = NVL(pnId_province, pv.id)
        AND ca.id = NVL(pnId_canton, ca.id)
        AND di.id = NVL(pnId_district, di.id)
      ORDER BY p.firstLastName, p.firstName;
END pr_get_persons;

-----------------------------------------------------------------------------------
--------------------------- Adoptantes (hijo de Person) ---------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_register_adopter (
   pnId_person         IN  NUMBER,
   pnId_house_type     IN  NUMBER,
   pnHas_yard          IN  NUMBER,
   pnId_exercise_time  IN  NUMBER,
   pcOther_pet_breeds  IN  VARCHAR2,
   pnResult            OUT NUMBER)
AS
   vnId_house  NUMBER;
   vnCount     NUMBER;
BEGIN
   pnResult := c_exito;

   INSERT INTO house (id, idHouseType, hasYard)
   VALUES (s_house.NEXTVAL, pnId_house_type, pnHas_yard)
   RETURNING id INTO vnId_house;

   INSERT INTO adopter (idAdopter, idHouse, idExerciseTime)
   VALUES (pnId_person, vnId_house, pnId_exercise_time);

   IF pcOther_pet_breeds IS NOT NULL THEN
      vnCount := REGEXP_COUNT(pcOther_pet_breeds, '[^,]+');
      FOR i IN 1 .. vnCount LOOP
         INSERT INTO otherPet (id, idPetBreed, idAdopter)
         VALUES (s_otherPet.NEXTVAL, TO_NUMBER(TRIM(REGEXP_SUBSTR(pcOther_pet_breeds, '[^,]+', 1, i))), pnId_person);
      END LOOP;
   END IF;

   COMMIT;

EXCEPTION
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
END pr_register_adopter;

PROCEDURE pr_get_adopter (
   pnId_adopter  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT ad.idAdopter,
             ho.idHouseType,
             ht.name AS houseTypeName,
             ho.hasYard,
             ad.idExerciseTime,
             ex.value AS exerciseTimeValue
      FROM adopter ad
      INNER JOIN house ho ON ho.id = ad.idHouse
      INNER JOIN houseType ht ON ht.id = ho.idHouseType
      INNER JOIN exerciseTime ex ON ex.id = ad.idExerciseTime
      WHERE ad.idAdopter = pnId_adopter;
END pr_get_adopter;

PROCEDURE pr_get_other_pets (
   pnId_adopter  IN  NUMBER,
   p_cursor      OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT op.id,
             pt.name AS typeName,
             pb.name AS breedName
      FROM otherPet op
      INNER JOIN petBreed pb ON pb.id = op.idPetBreed
      INNER JOIN petType pt ON pt.id = pb.idPetType
      WHERE op.idAdopter = pnId_adopter
      ORDER BY pt.name, pb.name;
END pr_get_other_pets;

-----------------------------------------------------------------------------------
------------------------- Casas cuna (hijo de Person) -----------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_register_foster_home (
   pnId_person               IN  NUMBER,
   pnId_district             IN  NUMBER,
   pcAddress                 IN  VARCHAR2,
   pnId_foster_home_status   IN  NUMBER,
   pnMax_capacity            IN  NUMBER,
   pnRequires_food_donation  IN  NUMBER,
   pcPet_types               IN  VARCHAR2,
   pcPet_sizes               IN  VARCHAR2,
   pnResult                  OUT NUMBER)
AS
   vnId_location NUMBER;
   vnCount       NUMBER;
BEGIN
   pnResult := c_exito;

   pr_insert_location(pnId_district, pcAddress, vnId_location);

   INSERT INTO fosterHome (idFosterHome, idLocation, idFosterHomeStatus, maxCapacity, requiresFoodDonation, petCount)
   VALUES (pnId_person, vnId_location, pnId_foster_home_status, pnMax_capacity, pnRequires_food_donation, 0);

   IF pcPet_types IS NOT NULL THEN
      vnCount := REGEXP_COUNT(pcPet_types, '[^,]+');
      FOR i IN 1 .. vnCount LOOP
         INSERT INTO fosterHome_x_petType (idFosterHome, idPetType)
         VALUES (pnId_person, TO_NUMBER(TRIM(REGEXP_SUBSTR(pcPet_types, '[^,]+', 1, i))));
      END LOOP;
   END IF;

   IF pcPet_sizes IS NOT NULL THEN
      vnCount := REGEXP_COUNT(pcPet_sizes, '[^,]+');
      FOR i IN 1 .. vnCount LOOP
         INSERT INTO fosterHome_x_petSize (idFosterHome, idPetSize)
         VALUES (pnId_person, TO_NUMBER(TRIM(REGEXP_SUBSTR(pcPet_sizes, '[^,]+', 1, i))));
      END LOOP;
   END IF;

   COMMIT;

EXCEPTION
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
END pr_register_foster_home;

PROCEDURE pr_get_foster_homes (
   pnId_foster_home IN  NUMBER,
   pnId_province    IN  NUMBER,
   pnId_canton      IN  NUMBER,
   pnId_district    IN  NUMBER,
   pnId_pet_type    IN  NUMBER,
   pnId_pet_size    IN  NUMBER,
   pnOnly_available IN  NUMBER,
   p_cursor         OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT DISTINCT
         fh.idFosterHome AS id,
         TRIM(pe.firstName || ' ' || pe.firstLastName || ' ' || pe.secondLastName) AS ownerName,
         pv.id   AS provinceId,
         pv.name AS provinceName,
         ca.id   AS cantonId,
         ca.name AS cantonName,
         di.id   AS districtId,
         di.name AS districtName,
         lo.address,
         fh.idFosterHomeStatus,
         fs.name AS statusName,
         fh.maxCapacity, (SELECT COUNT(1)
                          FROM pet pt
                          WHERE pt.idFosterHome = fh.idFosterHome) AS currentPets,
         fh.maxCapacity - (SELECT COUNT(1)
                           FROM pet pt
                           WHERE pt.idFosterHome = fh.idFosterHome) AS availableSpots,
         fh.requiresFoodDonation
      FROM fosterHome fh
      INNER JOIN person pe ON pe.id = fh.idFosterHome
      INNER JOIN location lo ON lo.id = fh.idLocation
      INNER JOIN district di ON di.id = lo.idDistrict
      INNER JOIN canton ca ON ca.id = di.idCanton
      INNER JOIN province pv ON pv.id = ca.idProvince
      INNER JOIN fosterHomeStatus fs ON fs.id = fh.idFosterHomeStatus
      LEFT JOIN fosterHome_x_petType ft ON ft.idFosterHome = fh.idFosterHome
      LEFT JOIN fosterHome_x_petSize fz ON fz.idFosterHome = fh.idFosterHome
      WHERE fh.idFosterHome = NVL(pnId_foster_home, fh.idFosterHome)
        AND pv.id           = NVL(pnId_province, pv.id)
        AND ca.id           = NVL(pnId_canton, ca.id)
        AND di.id           = NVL(pnId_district, di.id)
        AND NVL(ft.idPetType, -1) = NVL(pnId_pet_type, NVL(ft.idPetType, -1))
        AND NVL(fz.idPetSize, -1) = NVL(pnId_pet_size, NVL(fz.idPetSize, -1))
        AND (NVL(pnOnly_available, 0) = 0 OR fh.maxCapacity > (SELECT COUNT(1)
                                                               FROM pet pt
                                                               WHERE pt.idFosterHome = fh.idFosterHome))
      ORDER BY pv.name, ca.name, di.name, fh.idFosterHome;
END pr_get_foster_homes;

PROCEDURE pr_get_foster_home_accepts (
   pnId_foster_home  IN  NUMBER,
   p_cursor          OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT 'TYPE'     AS acceptType,
             pt.id      AS acceptId,
             pt.name    AS acceptName
      FROM fosterHome_x_petType ft
      JOIN petType pt ON pt.id = ft.idPetType
      WHERE ft.idFosterHome = pnId_foster_home
      UNION ALL
      SELECT 'SIZE'     AS acceptType,
             sz.id      AS acceptId,
             sz.name    AS acceptName
      FROM fosterHome_x_petSize fz
      JOIN petSize sz ON sz.id = fz.idPetSize
      WHERE fz.idFosterHome = pnId_foster_home
      ORDER BY acceptType, acceptName;
END pr_get_foster_home_accepts;

-----------------------------------------------------------------------------------
----------------------------------- Veterinarios ----------------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_register_veterinarian (
   pnId_person        IN  NUMBER,
   pnId_veterinarian  OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_veterinarian  NUMBER;
BEGIN
   pnResult := c_exito;

   INSERT INTO veterinarian (id, idPerson)
   VALUES (s_veterinarian.NEXTVAL, pnId_person)
   RETURNING id INTO vnId_veterinarian;

   COMMIT;
   pnId_veterinarian := vnId_veterinarian;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_veterinarian;

PROCEDURE pr_query_veterinarians (
   p_cursor  OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT v.id,
             p.id AS personId,
             TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS fullName
      FROM veterinarian v
      JOIN person p ON p.id = v.idPerson
      ORDER BY p.firstLastName, p.firstName, v.id;
END pr_query_veterinarians;

-----------------------------------------------------------------------------------
------------------------------ Lista negra y reputacion ---------------------------
-----------------------------------------------------------------------------------

PROCEDURE pr_add_blacklist (
   pnId_person  IN  NUMBER,
   pcReason     IN  VARCHAR2,
   pnResult     OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO blackList (id, idPerson, blackListReason)
   VALUES (s_blackList.NEXTVAL, pnId_person, TRIM(pcReason));

   COMMIT;

EXCEPTION
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_blacklist;

PROCEDURE pr_report_blacklist (
   pnOnly_adopters IN  NUMBER,
   p_cursor        OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT bl.id AS blacklistId,
         p.id  AS personId,
         TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS fullName,
         bl.blackListDate,
         bl.blackListReason,
         CASE
            WHEN ad.idAdopter IS NOT NULL THEN 1
            ELSE 0
         END AS isAdopter
      FROM blackList bl
      INNER JOIN person p ON p.id = bl.idPerson
      LEFT JOIN adopter ad ON ad.idAdopter = p.id
      WHERE (NVL(pnOnly_adopters, 0) = 0 OR ad.idAdopter IS NOT NULL)
      ORDER BY bl.blackListDate DESC, p.id;
END pr_report_blacklist;

PROCEDURE pr_get_person_ratings (
   pnId_person IN  NUMBER,
   p_cursor    OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT p.id AS personId,
             TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS fullName,
             r.id AS ratingId,
             r.rating,
             r.notes,
             a.adoptionDate,
             pt.name AS petName,
             TRIM(g.firstName || ' ' || g.firstLastName || ' ' || g.secondLastName) AS givenByName,
             CASE
                WHEN bl.idPerson IS NOT NULL THEN 1
                ELSE 0 END AS isBlacklisted,
             bl.blackListReason,
             bl.blackListDate
      FROM person p
      LEFT JOIN adoption a ON a.idAdopter = p.id
      LEFT JOIN petOwnerRating r ON r.idAdoption = a.id
      LEFT JOIN pet pt ON pt.id = a.idPet
      LEFT JOIN person g ON g.id = a.idPerson
      LEFT JOIN blackList bl ON bl.idPerson = p.id
      WHERE p.id = pnId_person
      ORDER BY a.adoptionDate DESC, r.id DESC;
END pr_get_person_ratings;

-----------------------------------------------------------------------------------
--------------------------- Ediciones (personas y casas cuna) ---------------------
-----------------------------------------------------------------------------------

-- Procedimiento que actualiza los nombres de una persona
PROCEDURE pr_update_person_names (
   pnId_person        IN  NUMBER,
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnResult           OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   UPDATE person
   SET firstName      = TRIM(pcFirst_name),
       middleName     = TRIM(pcMiddle_name),
       firstLastName  = TRIM(pcFirst_lastName),
       secondLastName = TRIM(pcSecond_lastName)
   WHERE id = pnId_person;

   IF SQL%ROWCOUNT = 0 THEN                         -- La persona no existe
      ROLLBACK;
      pnResult := c_persona_no_existe;
      RETURN;
   END IF;

   COMMIT;

EXCEPTION
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_person_names;

-- Procedimiento que actualiza una casa cuna y reemplaza los tipos y tamaños que acepta
PROCEDURE pr_update_foster_home (
   pnId_foster_home          IN  NUMBER,
   pnId_district             IN  NUMBER,
   pcAddress                 IN  VARCHAR2,
   pnId_foster_home_status   IN  NUMBER,
   pnMax_capacity            IN  NUMBER,
   pnRequires_food_donation  IN  NUMBER,
   pcPet_types               IN  VARCHAR2,
   pcPet_sizes               IN  VARCHAR2,
   pnResult                  OUT NUMBER)
AS
   vnId_location    NUMBER;
   vnPets           NUMBER;
   vnCount          NUMBER;
   vnUpdate_result  NUMBER;
BEGIN
   pnResult := c_exito;

   SELECT idLocation
   INTO vnId_location
   FROM fosterHome
   WHERE idFosterHome = pnId_foster_home;

   -- La capacidad no puede quedar por debajo de las mascotas que ya tiene
   SELECT COUNT(1)
   INTO vnPets
   FROM pet
   WHERE idFosterHome = pnId_foster_home;

   IF pnMax_capacity IS NULL OR pnMax_capacity < vnPets THEN
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);

   IF vnUpdate_result <> c_exito THEN
      pnResult := vnUpdate_result;                  -- pr_update_location ya hizo ROLLBACK
      RETURN;
   END IF;

   UPDATE fosterHome
   SET idFosterHomeStatus   = pnId_foster_home_status,
       maxCapacity          = pnMax_capacity,
       requiresFoodDonation = pnRequires_food_donation
   WHERE idFosterHome = pnId_foster_home;

   -- Reemplaza los tipos aceptados
   DELETE FROM fosterHome_x_petType
   WHERE idFosterHome = pnId_foster_home;

   IF pcPet_types IS NOT NULL THEN
      vnCount := REGEXP_COUNT(pcPet_types, '[^,]+');
      FOR i IN 1 .. vnCount LOOP
         INSERT INTO fosterHome_x_petType (idFosterHome, idPetType)
         VALUES (pnId_foster_home, TO_NUMBER(TRIM(REGEXP_SUBSTR(pcPet_types, '[^,]+', 1, i))));
      END LOOP;
   END IF;

   -- Reemplaza los tamaños aceptados
   DELETE FROM fosterHome_x_petSize
   WHERE idFosterHome = pnId_foster_home;

   IF pcPet_sizes IS NOT NULL THEN
      vnCount := REGEXP_COUNT(pcPet_sizes, '[^,]+');
      FOR i IN 1 .. vnCount LOOP
         INSERT INTO fosterHome_x_petSize (idFosterHome, idPetSize)
         VALUES (pnId_foster_home, TO_NUMBER(TRIM(REGEXP_SUBSTR(pcPet_sizes, '[^,]+', 1, i))));
      END LOOP;
   END IF;

   COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN                          -- La casa cuna no existe
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN DUP_VAL_ON_INDEX THEN                       -- Tipo o tamaño repetido en la lista
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN INVALID_NUMBER OR VALUE_ERROR THEN          -- Lista de ids mal escrita
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_foster_home;

-- Procedimiento que elimina un reporte de la lista negra
PROCEDURE pr_delete_blacklist (
   pnId_blacklist  IN  NUMBER,
   pnResult        OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   DELETE FROM blackList
   WHERE id = pnId_blacklist;

   IF SQL%ROWCOUNT = 0 THEN                         -- El reporte no existe
      ROLLBACK;
      pnResult := c_referencia_no_existe;
      RETURN;
   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_blacklist;

END pkg_person_administration;
