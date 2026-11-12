USE ADOPCION_APP;

-- -----------------------------------------------------------------------
-- ----------------- Verificaciones de existencia ------------------------
-- -----------------------------------------------------------------------
DELIMITER //
CREATE FUNCTION fn_person_exists (pnId_person INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE vnTest INT DEFAULT 0;
    SELECT 1 INTO vnTest FROM Person WHERE id = pnId_person LIMIT 1;
    RETURN vnTest;
END//

CREATE FUNCTION fn_email_exists (pcEmail VARCHAR(255))
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE vnTest INT DEFAULT 0;
    SELECT 1 INTO vnTest FROM ContactEmail WHERE LOWER(email) = LOWER(TRIM(pcEmail)) LIMIT 1;
    RETURN vnTest;
END //

CREATE FUNCTION fn_phone_exists (pcPhone VARCHAR(20))
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE vnTest INT DEFAULT 0;
    SELECT 1 INTO vnTest FROM ContactNumber WHERE phoneNumber = TRIM(pcPhone) LIMIT 1;
    RETURN vnTest;
END //

DELIMITER ;
-- -----------------------------------------------------------------------
-- ------------------ Ubicación y contactos de la persona ----------------
-- -----------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_insert_contacts (
   IN pnId_person INT,
   IN pcEmail VARCHAR(255),
   IN pcPhone VARCHAR(20)
)
BEGIN
   INSERT INTO ContactEmail (idPerson, email)
   VALUES (pnId_person, TRIM(pcEmail));

   INSERT INTO ContactNumber (idPerson, phoneNumber)
   VALUES (pnId_person, TRIM(pcPhone));
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ------------------- Insertar y actualizar locación ------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_insert_location (
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    OUT pnId_location INT
)
BEGIN
   INSERT INTO Location (idDistrict, address)
   VALUES (pnId_district, TRIM(pcAddress));
   SET pnId_location = LAST_INSERT_ID();
END //
DELIMITER //
CREATE PROCEDURE pr_update_location (
    IN pnId_location INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1011; END; -- eFkNoExiste
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;
    UPDATE Location SET idDistrict = pnId_district, address = TRIM(pcAddress) WHERE id = pnId_location;
    COMMIT;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ---------------------- Insertar y eliminar email --------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_add_email (
    IN pnId_person INT,
    IN pcEmail VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END; -- DUP_VAL_ON_INDEX
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1010; END; -- eFkNoExiste
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;
    INSERT INTO ContactEmail (idPerson, email)
    VALUES (pnId_person, TRIM(pcEmail));
    COMMIT;
END //

CREATE PROCEDURE pr_delete_email (
    IN pnId_person INT,
    IN pnId_email INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnEmailCount INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;

    START TRANSACTION;

    SELECT COUNT(1)
    INTO vnEmailCount
    FROM ContactEmail
    WHERE idPerson = pnId_person;

    IF vnEmailCount <= 1 THEN
        SET pnResult = 1012; -- c_ultimo_contacto
        ROLLBACK;
    ELSE
        DELETE FROM ContactEmail
        WHERE id = pnId_email
        AND idPerson = pnId_person;

        IF ROW_COUNT() = 0 THEN
            SET pnResult = 1100; -- c_referencia_no_existe
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- -------------------- Insertar y eliminar un teléfono ----------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_add_phone (
    IN pnId_person INT,
    IN pcPhone VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END; -- DUP_VAL_ON_INDEX
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1010; END; -- eFkNoExiste
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;
    INSERT INTO ContactNumber (idPerson, phoneNumber)
    VALUES (pnId_person, TRIM(pcPhone));
    COMMIT;
END //

CREATE PROCEDURE pr_delete_phone (
    IN pnId_person INT,
    IN pnId_phone INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnPhoneCount INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;

    START TRANSACTION;

    SELECT COUNT(1)
    INTO vnPhoneCount
    FROM ContactNumber
    WHERE idPerson = pnId_person;

    IF vnPhoneCount <= 1 THEN
        SET pnResult = 1012; -- c_ultimo_contacto
        ROLLBACK;
    ELSE
        DELETE FROM ContactNumber
        WHERE id = pnId_phone
          AND idPerson = pnId_person;

        IF ROW_COUNT() = 0 THEN
            SET pnResult = 1100; -- c_referencia_no_existe
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

CREATE PROCEDURE pr_get_person_contacts (IN pnId_person INT)
BEGIN
    SELECT 'EMAIL' AS contactType, id AS contactId, email AS contactValue
        FROM ContactEmail
        WHERE idPerson = pnId_person
    UNION ALL
    SELECT 'PHONE' AS contactType, id AS contactId, phoneNumber AS contactValue
        FROM ContactNumber WHERE idPerson = pnId_person
    ORDER BY contactType, contactValue;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- -------------------------------- Personas ---------------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE pr_register_person (
    IN pcFirst_name VARCHAR(30),
    IN pcMiddle_name VARCHAR(30),
    IN pcFirst_lastName VARCHAR(30),
    IN pcSecond_lastName VARCHAR(30),
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    IN pcPhone VARCHAR(20),
    IN pcEmail VARCHAR(255),
    OUT pnId_person INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT;
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1011; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    CALL pr_insert_location(pnId_district, pcAddress, vnId_location);

    INSERT INTO Person (idLocation, firstName, middleName, firstLastName, secondLastName)
    VALUES (vnId_location, TRIM(pcFirst_name), TRIM(pcMiddle_name), TRIM(pcFirst_lastName), TRIM(pcSecond_lastName));

    SET pnId_person = LAST_INSERT_ID();
    CALL pr_insert_contacts(pnId_person, pcEmail, pcPhone);

    COMMIT;
END //

CREATE PROCEDURE pr_update_person_location (
    IN pnId_person INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT;
    DECLARE vnUpdate_result  INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    SELECT idLocation
    INTO vnId_location
    FROM Person
    WHERE id = pnId_person
    LIMIT 1;

    IF vnId_location IS NULL THEN
        ROLLBACK;
        SET pnResult = 1010; -- c_persona_no_existe
    ELSE
        CALL pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);

        IF vnUpdate_result <> 0 THEN
            SET pnResult = vnUpdate_result;
            ROLLBACK;
        ELSE
           COMMIT;
        END IF;
    END IF;
END //

CREATE PROCEDURE pr_get_persons (
    IN pnId_person INT,
    IN pnId_province INT,
    IN pnId_canton INT,
    IN pnId_district INT
)
BEGIN
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
    FROM Person p
    INNER JOIN Location lo ON lo.id = p.idLocation
    INNER JOIN District di ON di.id = lo.idDistrict
    INNER JOIN Canton ca ON ca.id = di.idCanton
    INNER JOIN Province pv ON pv.id = ca.idProvince
    WHERE (pnId_person IS NULL OR p.id = pnId_person)
      AND (pnId_province IS NULL OR pv.id = pnId_province)
      AND (pnId_canton IS NULL OR ca.id = pnId_canton)
      AND (pnId_district IS NULL OR di.id = pnId_district)
    ORDER BY p.firstLastName, p.firstName;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ------------------------- Adoptantes (hijo de Person) ---------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_register_adopter (
    IN pnId_person INT,
    IN pnId_house_type INT,
    IN pnHas_yard TINYINT,
    IN pnId_exercise_time INT,
    IN pcOther_pet_breeds VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_house INT;
    DECLARE v_count INT DEFAULT 1;
    DECLARE v_total INT;
    DECLARE v_val VARCHAR(10);

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO House (idHouseType, hasYard) VALUES (pnId_house_type, pnHas_yard);
    SET vnId_house = LAST_INSERT_ID();

    INSERT INTO Adopter (idAdopter, idHouse, idExerciseTime) VALUES (pnId_person, vnId_house, pnId_exercise_time);

    -- MySQL String Split (Sustituye a REGEXP_COUNT / REGEXP_SUBSTR)
    IF pcOther_pet_breeds IS NOT NULL AND pcOther_pet_breeds != '' THEN
        SET v_total = CHAR_LENGTH(pcOther_pet_breeds) - CHAR_LENGTH(REPLACE(pcOther_pet_breeds, ',', '')) + 1;
        WHILE v_count <= v_total DO
            SET v_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcOther_pet_breeds, ',', v_count), ',', -1));
            INSERT INTO OtherPet (idPetBreed, idAdopter) VALUES (CAST(v_val AS UNSIGNED), pnId_person);
            SET v_count = v_count + 1;
        END WHILE;
    END IF;

    COMMIT;
END //

CREATE PROCEDURE pr_get_adopter (IN pnId_adopter INT)
BEGIN
    SELECT ad.idAdopter,
           ho.idHouseType,
           ht.name AS houseTypeName,
           ho.hasYard,
           ad.idExerciseTime,
           ex.value AS exerciseTimeValue
    FROM Adopter ad
             INNER JOIN House ho ON ho.id = ad.idHouse
             INNER JOIN HouseType ht ON ht.id = ho.idHouseType
             INNER JOIN ExerciseTime ex ON ex.id = ad.idExerciseTime
    WHERE ad.idAdopter = pnId_adopter;
END //

CREATE PROCEDURE pr_get_other_pets (IN pnId_adopter INT)
BEGIN
    SELECT op.id,
           pt.name AS typeName,
           pb.name AS breedName
    FROM OtherPet op
             INNER JOIN PetBreed pb ON pb.id = op.idPetBreed
             INNER JOIN PetType pt ON pt.id = pb.idPetType
    WHERE op.idAdopter = pnId_adopter
    ORDER BY pt.name, pb.name;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ----------------------- Casas cuna (hijo de Person) -----------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_register_foster_home (
    IN pnId_person INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    IN pnId_foster_home_status INT,
    IN pnMax_capacity INT,
    IN pnRequires_food_donation TINYINT,
    IN pcPet_types VARCHAR(255),
    IN pcPet_sizes VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT;
    DECLARE v_count INT DEFAULT 1;
    DECLARE v_total INT;
    DECLARE v_val VARCHAR(10);

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    CALL pr_insert_location(pnId_district, pcAddress, vnId_location);

    INSERT INTO FosterHome (idFosterHome, idLocation, idFosterHomeStatus, maxCapacity, requiresFoodDonation, petCount)
    VALUES (pnId_person, vnId_location, pnId_foster_home_status, pnMax_capacity, pnRequires_food_donation, 0);

    IF pcPet_types IS NOT NULL AND pcPet_types != '' THEN
        SET v_total = CHAR_LENGTH(pcPet_types) - CHAR_LENGTH(REPLACE(pcPet_types, ',', '')) + 1;
        WHILE v_count <= v_total DO
                SET v_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcPet_types, ',', v_count), ',', -1));
                INSERT INTO FosterHome_x_petType (idFosterHome, idPetType) VALUES (pnId_person, CAST(v_val AS UNSIGNED));
                SET v_count = v_count + 1;
            END WHILE;
    END IF;

    IF pcPet_sizes IS NOT NULL AND pcPet_sizes != '' THEN
        SET v_count = 1;
        SET v_total = CHAR_LENGTH(pcPet_sizes) - CHAR_LENGTH(REPLACE(pcPet_sizes, ',', '')) + 1;
        WHILE v_count <= v_total DO
                SET v_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcPet_sizes, ',', v_count), ',', -1));
                INSERT INTO FosterHome_x_petSize (idFosterHome, idPetSize) VALUES (pnId_person, CAST(v_val AS UNSIGNED));
                SET v_count = v_count + 1;
            END WHILE;
    END IF;

    COMMIT;
END //

CREATE PROCEDURE pr_get_foster_homes (
    IN pnId_foster_home INT,
    IN pnId_province INT,
    IN pnId_canton INT,
    IN pnId_district INT,
    IN pnId_pet_type INT,
    IN pnId_pet_size INT,
    IN pnOnly_available TINYINT
)
BEGIN
    SELECT DISTINCT
        fh.idFosterHome AS id,
        TRIM(CONCAT(pe.firstName, ' ', pe.firstLastName, ' ', COALESCE(pe.secondLastName, ''))) AS ownerName,
        pv.id   AS provinceId,
        pv.name AS provinceName,
        ca.id   AS cantonId,
        ca.name AS cantonName,
        di.id   AS districtId,
        di.name AS districtName,
        lo.address,
        fh.idFosterHomeStatus,
        fs.name AS statusName,
        fh.maxCapacity,
        (SELECT COUNT(1) FROM Pet pt WHERE pt.idFosterHome = fh.idFosterHome) AS currentPets,
        fh.maxCapacity - (SELECT COUNT(1) FROM Pet pt WHERE pt.idFosterHome = fh.idFosterHome) AS availableSpots,
        fh.requiresFoodDonation
    FROM FosterHome fh
             INNER JOIN Person pe ON pe.id = fh.idFosterHome
             INNER JOIN Location lo ON lo.id = fh.idLocation
             INNER JOIN District di ON di.id = lo.idDistrict
             INNER JOIN Canton ca ON ca.id = di.idCanton
             INNER JOIN Province pv ON pv.id = ca.idProvince
             INNER JOIN FosterHomeStatus fs ON fs.id = fh.idFosterHomeStatus
             LEFT JOIN FosterHome_x_petType ft ON ft.idFosterHome = fh.idFosterHome
             LEFT JOIN FosterHome_x_petSize fz ON fz.idFosterHome = fh.idFosterHome
    WHERE (pnId_foster_home IS NULL OR fh.idFosterHome = pnId_foster_home)
      AND (pnId_province IS NULL OR pv.id = pnId_province)
      AND (pnId_canton IS NULL OR ca.id = pnId_canton)
      AND (pnId_district IS NULL OR di.id = pnId_district)
      AND (pnId_pet_type IS NULL OR ft.idPetType = pnId_pet_type)
      AND (pnId_pet_size IS NULL OR fz.idPetSize = pnId_pet_size)
      AND (COALESCE(pnOnly_available, 0) = 0 OR fh.maxCapacity > (SELECT COUNT(1) FROM Pet pt WHERE pt.idFosterHome = fh.idFosterHome))
    ORDER BY pv.name, ca.name, di.name, fh.idFosterHome;
END //

CREATE PROCEDURE pr_get_foster_home_accepts (IN pnId_foster_home INT)
BEGIN
    SELECT 'TYPE' AS acceptType, pt.id AS acceptId, pt.name AS acceptName
    FROM FosterHome_x_petType ft
             JOIN PetType pt ON pt.id = ft.idPetType
    WHERE ft.idFosterHome = pnId_foster_home
    UNION ALL
    SELECT 'SIZE' AS acceptType, sz.id AS acceptId, sz.name AS acceptName
    FROM FosterHome_x_petSize fz
             JOIN PetSize sz ON sz.id = fz.idPetSize
    WHERE fz.idFosterHome = pnId_foster_home
    ORDER BY acceptType, acceptName;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- --------------------------------- Veterinarios ----------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE pr_register_veterinarian (
    IN pnId_person INT,
    OUT pnId_veterinarian INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1010; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO Veterinarian (idPerson) VALUES (pnId_person);
    SET pnId_veterinarian = LAST_INSERT_ID();

    COMMIT;
END //

CREATE PROCEDURE pr_query_veterinarians ()
BEGIN
    SELECT v.id,
           p.id AS personId,
           TRIM(CONCAT(p.firstName, ' ', p.firstLastName, ' ', COALESCE(p.secondLastName, ''))) AS fullName
    FROM Veterinarian v
             JOIN Person p ON p.id = v.idPerson
    ORDER BY p.firstLastName, p.firstName, v.id;
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ---------------------------- Lista negra y reputacion ---------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE pr_add_blacklist (
    IN pnId_person INT,
    IN pcReason VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1010; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO BlackList (idPerson, blackListReason) VALUES (pnId_person, TRIM(pcReason));

    COMMIT;
END //

CREATE PROCEDURE pr_report_blacklist (IN pnOnly_adopters TINYINT)
BEGIN
    SELECT bl.id AS blacklistId,
           p.id  AS personId,
           TRIM(CONCAT(p.firstName, ' ', p.firstLastName, ' ', COALESCE(p.secondLastName, ''))) AS fullName,
           bl.blackListDate,
           bl.blackListReason,
           CASE WHEN ad.idAdopter IS NOT NULL THEN 1 ELSE 0 END AS isAdopter
    FROM BlackList bl
             INNER JOIN Person p ON p.id = bl.idPerson
             LEFT JOIN Adopter ad ON ad.idAdopter = p.id
    WHERE (COALESCE(pnOnly_adopters, 0) = 0 OR ad.idAdopter IS NOT NULL)
    ORDER BY bl.blackListDate DESC, p.id;
END //

CREATE PROCEDURE pr_get_person_ratings (IN pnId_person INT)
BEGIN
    SELECT p.id AS personId,
           TRIM(CONCAT(p.firstName, ' ', p.firstLastName, ' ', COALESCE(p.secondLastName, ''))) AS fullName,
           r.id AS ratingId,
           r.rating,
           r.notes,
           a.adoptionDate,
           pt.name AS petName,
           TRIM(CONCAT(g.firstName, ' ', g.firstLastName, ' ', COALESCE(g.secondLastName, ''))) AS givenByName,
           CASE WHEN bl.idPerson IS NOT NULL THEN 1 ELSE 0 END AS isBlacklisted,
           bl.blackListReason,
           bl.blackListDate
    FROM Person p
             LEFT JOIN Adoption a ON a.idAdopter = p.id
             LEFT JOIN PetOwnerRating r ON r.idAdoption = a.id
             LEFT JOIN Pet pt ON pt.id = a.idPet
             LEFT JOIN Person g ON g.id = a.idPerson
             LEFT JOIN BlackList bl ON bl.idPerson = p.id
    WHERE p.id = pnId_person
    ORDER BY a.adoptionDate DESC, r.id DESC;
END //
DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ------------------------- Ediciones (personas y casas cuna) ---------------------
-- ---------------------------------------------------------------------------------
DELIMITER //
-- Procedimiento que actualiza los nombres de una persona
CREATE PROCEDURE pr_update_person_names (
    IN pnId_person INT,
    IN pcFirst_name VARCHAR(30),
    IN pcMiddle_name VARCHAR(30),
    IN pcFirst_lastName VARCHAR(30),
    IN pcSecond_lastName VARCHAR(30),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    UPDATE Person
    SET firstName      = TRIM(pcFirst_name),
        middleName     = TRIM(pcMiddle_name),
        firstLastName  = TRIM(pcFirst_lastName),
        secondLastName = TRIM(pcSecond_lastName)
    WHERE id = pnId_person;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SET pnResult = 1010; -- c_persona_no_existe
    ELSE
        COMMIT;
    END IF;
END //

CREATE PROCEDURE pr_update_foster_home (
    IN pnId_foster_home INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    IN pnId_foster_home_status INT,
    IN pnMax_capacity INT,
    IN pnRequires_food_donation TINYINT,
    IN pcPet_types VARCHAR(255),
    IN pcPet_sizes VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT DEFAULT NULL;
    DECLARE vnPets INT;
    DECLARE vnUpdate_result INT;
    DECLARE v_count INT DEFAULT 1;
    DECLARE v_total INT;
    DECLARE v_val VARCHAR(10);

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    SELECT idLocation INTO vnId_location FROM FosterHome WHERE idFosterHome = pnId_foster_home LIMIT 1;
    IF vnId_location IS NULL THEN
        SET pnResult = 1100;
        ROLLBACK;
    ELSE
        SELECT COUNT(1) INTO vnPets FROM Pet WHERE idFosterHome = pnId_foster_home;
        IF pnMax_capacity IS NULL OR pnMax_capacity < vnPets THEN
            SET pnResult = 1030; -- c_dato_invalido
            ROLLBACK;
        ELSE
            CALL pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);
            IF vnUpdate_result <> 0 THEN
                SET pnResult = vnUpdate_result;
                ROLLBACK;
            ELSE
                UPDATE FosterHome
                SET idFosterHomeStatus = pnId_foster_home_status,
                    maxCapacity = pnMax_capacity,
                    requiresFoodDonation = pnRequires_food_donation
                WHERE idFosterHome = pnId_foster_home;

                -- Reemplazar tipos aceptados
                DELETE FROM FosterHome_x_petType WHERE idFosterHome = pnId_foster_home;
                IF pcPet_types IS NOT NULL AND pcPet_types != '' THEN
                    SET v_count = 1;
                    SET v_total = CHAR_LENGTH(pcPet_types) - CHAR_LENGTH(REPLACE(pcPet_types, ',', '')) + 1;
                    WHILE v_count <= v_total DO
                            SET v_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcPet_types, ',', v_count), ',', -1));
                            INSERT INTO FosterHome_x_petType (idFosterHome, idPetType) VALUES (pnId_foster_home, CAST(v_val AS UNSIGNED));
                            SET v_count = v_count + 1;
                        END WHILE;
                END IF;

                -- Reemplazar tamaños aceptados
                DELETE FROM FosterHome_x_petSize WHERE idFosterHome = pnId_foster_home;
                IF pcPet_sizes IS NOT NULL AND pcPet_sizes != '' THEN
                    SET v_count = 1;
                    SET v_total = CHAR_LENGTH(pcPet_sizes) - CHAR_LENGTH(REPLACE(pcPet_sizes, ',', '')) + 1;
                    WHILE v_count <= v_total DO
                            SET v_val = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcPet_sizes, ',', v_count), ',', -1));
                            INSERT INTO FosterHome_x_petSize (idFosterHome, idPetSize) VALUES (pnId_foster_home, CAST(v_val AS UNSIGNED));
                            SET v_count = v_count + 1;
                        END WHILE;
                END IF;

                COMMIT;
            END IF;
        END IF;
    END IF;
END //

CREATE PROCEDURE pr_delete_blacklist (
    IN pnId_blacklist INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    DELETE FROM BlackList WHERE id = pnId_blacklist;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SET pnResult = 1100; -- c_referencia_no_existe
    ELSE
        COMMIT;
    END IF;
END //

DELIMITER ;