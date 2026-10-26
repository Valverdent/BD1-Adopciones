create or replace PACKAGE pkg_adoption_administration AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_parametro_faltante   CONSTANT NUMBER := 1020;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_error_bd             CONSTANT NUMBER := 9000;

PROCEDURE pr_register_adoption (
   pnId_person        IN  NUMBER,
   pnId_adopter       IN  NUMBER,
   pnId_pet           IN  NUMBER,
   pdAdoption_date    IN  DATE,
   pnId_adoption      OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_get_adoptions (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR);

PROCEDURE pr_register_photo (
   pnId_pet           IN  NUMBER,
   pnId_follow_up     IN  NUMBER,
   pnId_photo_type    IN  NUMBER,
   pcPhoto_url        IN  VARCHAR2,
   pnId_photo         OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_get_photos_filtered (
   pnId_pet           IN  NUMBER,
   pnId_follow_up     IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR);

PROCEDURE pr_register_follow_up (
   pnId_adoption      IN  NUMBER,
   pdFollow_up_date   IN  DATE,
   pcNotes            IN  VARCHAR2,
   pnId_photo_type    IN  NUMBER,
   pcPhoto_url        IN  VARCHAR2,
   pnId_follow_up     OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_get_follow_ups (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR);

PROCEDURE pr_register_rating (
   pnId_adoption      IN  NUMBER,
   pnRating           IN  NUMBER,
   pcNotes            IN  VARCHAR2,
   pnId_rating        OUT NUMBER,
   pnResult           OUT NUMBER);

PROCEDURE pr_get_adoption_rating (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR);

END pkg_adoption_administration;
 
create or replace PACKAGE BODY pkg_adoption_administration AS

-- Errores con nombre propio
eDatoNulo     EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,     -1400);
eDatoNuloUpd  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNuloUpd,  -1407);
eDatoLargo    EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,    -12899);
eNumeroGrande EXCEPTION;
PRAGMA EXCEPTION_INIT(eNumeroGrande, -1438);
eCheckViolado EXCEPTION;
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);
eFkNoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste,   -2291);

-----------------------------------------------------------------------------------
---------------------------------- Adopciones -------------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar una adoption en la BD
PROCEDURE pr_register_adoption (
   pnId_person        IN  NUMBER,
   pnId_adopter       IN  NUMBER,
   pnId_pet           IN  NUMBER,
   pdAdoption_date    IN  DATE,
   pnId_adoption      OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_adoption      NUMBER;
   vnId_status_adopt  NUMBER;
   vcStatus_adopted   VARCHAR2(30);
BEGIN
   pnResult := c_exito;

   vcStatus_adopted := pkg_parameter.fn_get_text('PET_STATUS_ADOPTED');

   SELECT id INTO vnId_status_adopt
   FROM petStatus
   WHERE name = vcStatus_adopted;

   INSERT INTO adoption (id, idPerson, idAdopter, idPet, adoptionDate)
   VALUES (s_adoption.NEXTVAL, pnId_person, pnId_adopter, pnId_pet, NVL(pdAdoption_date, SYSDATE))
   RETURNING id INTO vnId_adoption;

   UPDATE pet
   SET idPetStatus = vnId_status_adopt
   WHERE id = pnId_pet;

   COMMIT;
   pnId_adoption := vnId_adoption;

EXCEPTION                                       -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_parametro_faltante;
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
END pr_register_adoption;

-- Procedimiento para traer todos los adoptions
PROCEDURE pr_get_adoptions (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT a.id AS adoptionId,
             a.adoptionDate,
             a.idPet              AS petId,
             pt.name              AS petName,
             tp.name              AS petTypeName,
             pb.name              AS petBreedName,
             a.idAdopter          AS adopterId,
             TRIM(pad.firstName  || ' ' || pad.firstLastName || ' ' || pad.secondLastName) AS adopterName,
             a.idPerson           AS givenById,
             TRIM(pgv.firstName  || ' ' || pgv.firstLastName || ' ' || pgv.secondLastName) AS givenByName,
             (SELECT ROUND(AVG(r.rating), 2)
              FROM petOwnerRating r
              WHERE r.idAdoption = a.id) AS rating
      FROM adoption a
      INNER JOIN pet pt
      ON pt.id = a.idPet
      INNER JOIN petBreed pb
      ON pb.id = pt.idPetBreed
      INNER JOIN petType tp
      ON tp.id = pb.idPetType
      INNER JOIN person pad
      ON pad.id = a.idAdopter
      INNER JOIN person pgv
      ON pgv.id = a.idPerson
      WHERE a.id = NVL(pnId_adoption, a.id)
      ORDER BY a.adoptionDate DESC, a.id DESC;
END pr_get_adoptions;

-----------------------------------------------------------------------------------
------------------------------------ Fotos ----------------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar una photo
PROCEDURE pr_register_photo (
   pnId_pet           IN  NUMBER,
   pnId_follow_up     IN  NUMBER,
   pnId_photo_type    IN  NUMBER,
   pcPhoto_url        IN  VARCHAR2,
   pnId_photo         OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_photo         NUMBER;
BEGIN
   pnResult := c_exito;

   INSERT INTO photo (id, idPet, idFollowUp, idPhotoType, photoURL)
   VALUES (s_photo.NEXTVAL, pnId_pet, pnId_follow_up, pnId_photo_type, TRIM(pcPhoto_url))
   RETURNING id INTO vnId_photo;

   COMMIT;
   pnId_photo := vnId_photo;

EXCEPTION                                -- Manejo de las excepciones
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
END pr_register_photo;

-- Getter de fotos filtrado por sus entidades asociadas (pet o follow_up)
PROCEDURE pr_get_photos_filtered (
   pnId_pet           IN  NUMBER,
   pnId_follow_up     IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR)
AS
BEGIN
   -- Filtros opcionales (NULL = todos). Corregido: con pnId_follow_up en NULL también se
   -- devuelven las fotos propias de la mascota (antes/después), que no tienen seguimiento.
   OPEN p_cursor FOR
      SELECT p.id AS photoId,
             p.photoURL,
             p.idPet AS petId,
             p.idFollowUp AS followUpId,
             pt.id AS photoTypeId,
             pt.name AS photoTypeName
      FROM photo p
      INNER JOIN photoType pt
      ON pt.id = p.idPhotoType
      WHERE (pnId_pet IS NULL OR p.idPet = pnId_pet)
        AND (pnId_follow_up IS NULL OR p.idFollowUp = pnId_follow_up)
      ORDER BY p.id DESC;
END pr_get_photos_filtered;

-----------------------------------------------------------------------------------
---------------------------------- Seguimientos -----------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar un follow_up (delegando el registro de la foto directamente)
PROCEDURE pr_register_follow_up (
   pnId_adoption      IN  NUMBER,
   pdFollow_up_date   IN  DATE,
   pcNotes            IN  VARCHAR2,
   pnId_photo_type    IN  NUMBER,
   pcPhoto_url        IN  VARCHAR2,
   pnId_follow_up     OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_follow_up     NUMBER;
   vnId_pet           NUMBER;
   vnId_photo         NUMBER;
   vnPhoto_result     NUMBER;
BEGIN
   pnResult := c_exito;

   -- 1. Registro del seguimiento
   INSERT INTO followUp (id, idAdoption, followUpDate, comments)
   VALUES (s_followUp.NEXTVAL, pnId_adoption, NVL(pdFollow_up_date, SYSDATE), TRIM(pcNotes))
   RETURNING id INTO vnId_follow_up;

   -- 2. Si se recibe la URL, se obtiene la mascota de la adopción y se registra la foto modularmente
   SELECT idPet INTO vnId_pet
   FROM adoption
   WHERE id = pnId_adoption;

   pr_register_photo(vnId_pet, vnId_follow_up, pnId_photo_type, pcPhoto_url, vnId_photo, vnPhoto_result);

   IF vnPhoto_result <> c_exito THEN
      ROLLBACK;
      pnResult := vnPhoto_result;
      RETURN;
   END IF;

   COMMIT;
   pnId_follow_up := vnId_follow_up;

EXCEPTION                                        -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
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
END pr_register_follow_up;

-- Procedimiento para mostrar todos los get follow_up de la BD
PROCEDURE pr_get_follow_ups (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT f.id,
             f.followUpDate,
             f.comments,
             ph.id AS photoId,
             pht.name AS photoTypeName,
             ph.photoURL
      FROM followUp f
      LEFT JOIN photo ph
      ON ph.idFollowUp = f.id
      LEFT JOIN photoType pht
      ON pht.id = ph.idPhotoType
      WHERE f.idAdoption = NVL(pnId_adoption, f.idAdoption)
      ORDER BY f.followUpDate DESC, f.id DESC;
END pr_get_follow_ups;

-----------------------------------------------------------------------------------
--------------------------------- Calificaciones ----------------------------------
-----------------------------------------------------------------------------------
-- Procedimiento para registrar un petOwnerRating
PROCEDURE pr_register_rating (
   pnId_adoption      IN  NUMBER,
   pnRating           IN  NUMBER,
   pcNotes            IN  VARCHAR2,
   pnId_rating        OUT NUMBER,
   pnResult           OUT NUMBER)
AS
   vnId_rating        NUMBER;
BEGIN
   pnResult := c_exito;

   INSERT INTO petOwnerRating (id, idAdoption, rating, notes)
   VALUES (s_petOwnerRating.NEXTVAL, pnId_adoption, pnRating, TRIM(pcNotes))
   RETURNING id INTO vnId_rating;

   COMMIT;
   pnId_rating := vnId_rating;

EXCEPTION                                   -- Manejo de excepciones
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
END pr_register_rating;

-- Procedimiento para mostrar todos los petOwnerRating de la BD
PROCEDURE pr_get_adoption_rating (
   pnId_adoption      IN  NUMBER,
   p_cursor           OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT r.id,
             r.rating,
             r.notes,
             a.adoptionDate,
             a.idAdopter        AS adopterId,
             TRIM(pad.firstName || ' ' || pad.firstLastName || ' ' || pad.secondLastName) AS adopterName
      FROM petOwnerRating r
      INNER JOIN adoption a
      ON a.id = r.idAdoption
      INNER JOIN person pad
      ON pad.id = a.idAdopter
      WHERE r.idAdoption = NVL(pnId_adoption, r.idAdoption);
END pr_get_adoption_rating;

END pkg_adoption_administration;
