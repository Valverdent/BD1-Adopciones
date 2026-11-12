USE ADOPCION_APP;

DELIMITER //

-- ---------------------------------------------------------------------------------
-- ---------------------------------- Adopciones -----------------------------------
-- ---------------------------------------------------------------------------------

-- Procedimiento para registrar una adopción en la BD
CREATE PROCEDURE pr_register_adoption (
    IN pnId_person INT,
    IN pnId_adopter INT,
    IN pnId_pet INT,
    IN pdAdoption_date DATE,
    OUT pnId_adoption INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_status_adopt INT DEFAULT NULL;
    DECLARE vcStatus_adopted VARCHAR(30);

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END; -- c_dato_duplicado
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END; -- c_referencia_no_existe
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END; -- c_error_bd

    SET pnResult = 0;
    START TRANSACTION;

    -- Se asume que la función fn_get_text (antes en pkg_parameter) existe a nivel global
    SET vcStatus_adopted = fn_get_text('PET_STATUS_ADOPTED');

    SELECT id INTO vnId_status_adopt
    FROM PetStatus
    WHERE name = vcStatus_adopted LIMIT 1;

    IF vnId_status_adopt IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
        ROLLBACK;
    ELSE
        INSERT INTO Adoption (idPerson, idAdopter, idPet, adoptionDate)
        VALUES (pnId_person, pnId_adopter, pnId_pet, COALESCE(pdAdoption_date, CURDATE()));

        SET pnId_adoption = LAST_INSERT_ID();

        UPDATE Pet
        SET idPetStatus = vnId_status_adopt
        WHERE id = pnId_pet;

        COMMIT;
    END IF;
END //

-- Procedimiento para traer todas las adopciones (Retorno implícito de Result Set)
CREATE PROCEDURE pr_get_adoptions (
    IN pnId_adoption INT
)
BEGIN
    SELECT a.id AS adoptionId,
           a.adoptionDate,
           a.idPet AS petId,
           pt.name AS petName,
           tp.name AS petTypeName,
           pb.name AS petBreedName,
           a.idAdopter AS adopterId,
           TRIM(CONCAT(pad.firstName, ' ', pad.firstLastName, ' ', COALESCE(pad.secondLastName, ''))) AS adopterName,
           a.idPerson AS givenById,
           TRIM(CONCAT(pgv.firstName, ' ', pgv.firstLastName, ' ', COALESCE(pgv.secondLastName, ''))) AS givenByName,
           (SELECT ROUND(AVG(r.rating), 2) FROM PetOwnerRating r WHERE r.idAdoption = a.id) AS rating
    FROM Adoption a
             INNER JOIN Pet pt ON pt.id = a.idPet
             INNER JOIN PetBreed pb ON pb.id = pt.idPetBreed
             INNER JOIN PetType tp ON tp.id = pb.idPetType
             INNER JOIN Person pad ON pad.id = a.idAdopter
             INNER JOIN Person pgv ON pgv.id = a.idPerson
    WHERE (pnId_adoption IS NULL OR a.id = pnId_adoption)
    ORDER BY a.adoptionDate DESC, a.id DESC;
END //

-- ---------------------------------------------------------------------------------
-- ------------------------------------ Fotos --------------------------------------
-- ---------------------------------------------------------------------------------

-- Procedimiento para registrar una foto
CREATE PROCEDURE pr_register_photo (
    IN pnId_pet INT,
    IN pnId_follow_up INT,
    IN pnId_photo_type INT,
    IN pcPhoto_url VARCHAR(255),
    OUT pnId_photo INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO Photo (idPet, idFollowUp, idPhotoType, photoURL)
    VALUES (pnId_pet, pnId_follow_up, pnId_photo_type, TRIM(pcPhoto_url));

    SET pnId_photo = LAST_INSERT_ID();
    COMMIT;
END //

-- Getter de fotos filtrado por sus entidades asociadas (pet o follow_up)
CREATE PROCEDURE pr_get_photos_filtered (
    IN pnId_pet INT,
    IN pnId_follow_up INT
)
BEGIN
    SELECT p.id AS photoId,
           p.photoURL,
           p.idPet AS petId,
           p.idFollowUp AS followUpId,
           pt.id AS photoTypeId,
           pt.name AS photoTypeName
    FROM Photo p
             INNER JOIN PhotoType pt ON pt.id = p.idPhotoType
    WHERE (pnId_pet IS NULL OR p.idPet = pnId_pet)
      AND (pnId_follow_up IS NULL OR p.idFollowUp = pnId_follow_up)
    ORDER BY p.id DESC;
END //

-- ---------------------------------------------------------------------------------
-- ---------------------------------- Seguimientos ---------------------------------
-- ---------------------------------------------------------------------------------

-- Procedimiento para registrar un follow_up (delegando el registro de la foto directamente)
CREATE PROCEDURE pr_register_follow_up (
    IN pnId_adoption INT,
    IN pdFollow_up_date DATE,
    IN pcNotes VARCHAR(4000),
    IN pnId_photo_type INT,
    IN pcPhoto_url VARCHAR(255),
    OUT pnId_follow_up INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_pet INT DEFAULT NULL;
    DECLARE vnId_photo INT;
    DECLARE vnPhoto_result INT;

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    -- 1. Registro del seguimiento
    INSERT INTO FollowUp (idAdoption, followUpDate, comments)
    VALUES (pnId_adoption, COALESCE(pdFollow_up_date, CURDATE()), TRIM(pcNotes));

    SET pnId_follow_up = LAST_INSERT_ID();

    -- 2. Si se recibe la URL, se obtiene la mascota de la adopción y se registra la foto modularmente
    SELECT idPet INTO vnId_pet
    FROM Adoption
    WHERE id = pnId_adoption LIMIT 1;

    IF vnId_pet IS NULL THEN
        SET pnResult = 1100; -- c_referencia_no_existe
        ROLLBACK;
    ELSE
        CALL pr_register_photo(vnId_pet, pnId_follow_up, pnId_photo_type, pcPhoto_url, vnId_photo, vnPhoto_result);

        IF vnPhoto_result <> 0 THEN
            ROLLBACK;
            SET pnResult = vnPhoto_result;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

-- Procedimiento para mostrar todos los seguimientos
CREATE PROCEDURE pr_get_follow_ups (
    IN pnId_adoption INT
)
BEGIN
    SELECT f.id,
           f.followUpDate,
           f.comments,
           ph.id AS photoId,
           pht.name AS photoTypeName,
           ph.photoURL
    FROM FollowUp f
             LEFT JOIN Photo ph ON ph.idFollowUp = f.id
             LEFT JOIN PhotoType pht ON pht.id = ph.idPhotoType
    WHERE (pnId_adoption IS NULL OR f.idAdoption = pnId_adoption)
    ORDER BY f.followUpDate DESC, f.id DESC;
END //

-- ---------------------------------------------------------------------------------
-- --------------------------------- Calificaciones --------------------------------
-- ---------------------------------------------------------------------------------

-- Procedimiento para registrar una calificación (petOwnerRating)
CREATE PROCEDURE pr_register_rating (
    IN pnId_adoption INT,
    IN pnRating INT,
    IN pcNotes VARCHAR(4000),
    OUT pnId_rating INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO PetOwnerRating (idAdoption, rating, notes)
    VALUES (pnId_adoption, pnRating, TRIM(pcNotes));

    SET pnId_rating = LAST_INSERT_ID();
    COMMIT;
END //

-- Procedimiento para mostrar todas las calificaciones de una adopción
CREATE PROCEDURE pr_get_adoption_rating (
    IN pnId_adoption INT
)
BEGIN
    SELECT r.id,
           r.rating,
           r.notes,
           a.adoptionDate,
           a.idAdopter AS adopterId,
           TRIM(CONCAT(pad.firstName, ' ', pad.firstLastName, ' ', COALESCE(pad.secondLastName, ''))) AS adopterName
    FROM PetOwnerRating r
             INNER JOIN Adoption a ON a.id = r.idAdoption
             INNER JOIN Person pad ON pad.id = a.idAdopter
    WHERE (pnId_adoption IS NULL OR r.idAdoption = pnId_adoption);
END //

DELIMITER ;