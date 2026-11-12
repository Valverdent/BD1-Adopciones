USE ADOPCION_APP;

DELIMITER //

-- -------------------------------------------------------------------------
-- ------------------- Verificacion de duplicados --------------------------
-- -------------------------------------------------------------------------

-- Función que verifica la existencia de una mascota con un chip de identificación
CREATE FUNCTION fn_chipId_exists (pcChip_id VARCHAR(255)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE vnTest INT DEFAULT 0;
    SELECT 1 INTO vnTest
    FROM Pet
    WHERE chipId = TRIM(pcChip_id) LIMIT 1;
    RETURN vnTest;
END //


-- ---------------------------------------------------------------------------------
-- ------------------------- Registro y edicion Basica de Pet ----------------------
-- ---------------------------------------------------------------------------------

CREATE PROCEDURE pr_register_pet (
    IN pnId_person INT,
    IN pnId_pet_breed INT,
    IN pnId_pet_size INT,
    IN pnId_pet_color INT,
    IN pnId_pet_severity INT,
    IN pnId_pet_energy INT,
    IN pnId_pet_trainability INT,
    IN pnId_pet_status INT,
    IN pnId_veterinarian INT,
    IN pnId_foster_home INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    IN pcChip_id VARCHAR(255),
    IN pcName VARCHAR(255),
    IN pnRequires_space TINYINT,
    IN pcNotes_description VARCHAR(4000),
    IN pcAbandonment_notes VARCHAR(4000),
    IN pnEstimated_age INT,
    IN pdEvent_date DATE,
    OUT pnId_pet INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1101; END; -- c_chip_existe
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END; -- c_referencia_no_existe
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    -- Si se proporciona un distrito, se registra la ubicación delegando a person_administration
    IF pnId_district IS NOT NULL THEN
        CALL pr_insert_location(pnId_district, pcAddress, vnId_location);
    END IF;

    INSERT INTO Pet (idLocation, idPerson, idPetBreed, idPetSize, idPetColor, idPetSeverity,
                     idPetEnergy, idPetTrainability, idPetStatus, idVeterinarian, idFosterHome, chipId, name,
                     requiresSpace, notesDescription, abandonmentNotesDescription, estimatedAge, eventDate)
    VALUES (vnId_location, pnId_person, pnId_pet_breed, pnId_pet_size, pnId_pet_color,
            pnId_pet_severity, pnId_pet_energy, pnId_pet_trainability, pnId_pet_status, pnId_veterinarian,
            pnId_foster_home, TRIM(pcChip_id), TRIM(pcName), pnRequires_space, TRIM(pcNotes_description), TRIM(pcAbandonment_notes),
            pnEstimated_age, pdEvent_date);

    SET pnId_pet = LAST_INSERT_ID();

    COMMIT;
END //

CREATE PROCEDURE pr_update_pet (
    IN pnId_pet INT,
    IN pnId_pet_breed INT,
    IN pnId_pet_size INT,
    IN pnId_pet_color INT,
    IN pnId_pet_severity INT,
    IN pnId_pet_energy INT,
    IN pnId_pet_trainability INT,
    IN pnId_pet_status INT,
    IN pnId_veterinarian INT,
    IN pnId_foster_home INT,
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    IN pcChip_id VARCHAR(255),
    IN pcName VARCHAR(255),
    IN pnRequires_space TINYINT,
    IN pcNotes_description VARCHAR(4000),
    IN pcAbandonment_notes VARCHAR(4000),
    IN pnEstimated_age INT,
    IN pdEvent_date DATE,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT DEFAULT NULL;
    DECLARE vnUpdate_result INT;

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1101; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    SELECT idLocation INTO vnId_location FROM Pet WHERE id = pnId_pet LIMIT 1;

    IF pnId_district IS NOT NULL THEN
        IF vnId_location IS NOT NULL THEN
            CALL pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);
            IF vnUpdate_result <> 0 THEN
                SET pnResult = vnUpdate_result;
                ROLLBACK;
            END IF;
        ELSE
            CALL pr_insert_location(pnId_district, pcAddress, vnId_location);
        END IF;
    ELSE
        SET vnId_location = NULL;
    END IF;

    IF pnResult = 0 THEN
        UPDATE Pet
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

        IF ROW_COUNT() = 0 THEN
            SET pnResult = 1100;
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //


-- ---------------------------------------------------------------------------------
-- --------------------------------- Reward ----------------------------------------
-- ---------------------------------------------------------------------------------

CREATE PROCEDURE pr_insert_reward (
    IN pnId_pet INT,
    IN pnId_currency_type INT,
    IN pnReward_amount DECIMAL(12,2),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO Reward (idPet, idCurrencyType, amount)
    VALUES (pnId_pet, pnId_currency_type, pnReward_amount);

    COMMIT;
END //


-- ---------------------------------------------------------------------------------
-- ----------------------------- Operaciones Disease -------------------------------
-- ---------------------------------------------------------------------------------

CREATE PROCEDURE pr_insert_disease (
    IN pnId_pet INT,
    IN pnId_disease INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    INSERT INTO Disease_x_pet (idDisease, idPet) VALUES (pnId_disease, pnId_pet);

    COMMIT;
END //

CREATE PROCEDURE pr_delete_disease (
    IN pnId_disease_remove INT,
    IN pnId_pet INT,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    DELETE FROM Disease_x_pet WHERE idPet = pnId_pet AND idDisease = pnId_disease_remove;

    COMMIT;
END //


-- ---------------------------------------------------------------------------------
-- ------------------------------- Consultas ---------------------------------------
-- ---------------------------------------------------------------------------------

CREATE PROCEDURE pr_query_pets (
    IN pnId_pet INT,
    IN pcName VARCHAR(255),
    IN pcChip_id VARCHAR(255),
    IN pnId_pet_status INT,
    IN pnId_pet_type INT,
    IN pnId_pet_breed INT,
    IN pnId_pet_size INT,
    IN pnId_pet_color INT,
    IN pnId_province INT,
    IN pnId_canton INT,
    IN pnId_district INT,
    IN pnId_foster_home INT,
    IN pnId_pet_severity INT,
    IN pnId_pet_energy INT,
    IN pnId_pet_trainability INT,
    IN pnId_disease INT,
    IN pnId_person INT,
    IN pdDate_from DATE,
    IN pdDate_to DATE
)
BEGIN
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
           TRIM(CONCAT(pf.firstName, ' ', pf.firstLastName)) AS fosterHomeName,
           p.idPerson         AS reporterId,
           TRIM(CONCAT(pe.firstName, ' ', pe.firstLastName)) AS reporterName,
           cu.name            AS currencyName,
           rw.amount          AS rewardAmount,
           p.notesDescription,
           p.abandonmentNotesDescription,
           -- Ids para editar
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
           TRIM(CONCAT(pvt.firstName, ' ', pvt.firstLastName, ' ', COALESCE(pvt.secondLastName, ''))) AS veterinarianName,
           rw.id              AS rewardId,
           rw.idCurrencyType  AS currencyId
    FROM Pet p
             INNER JOIN PetStatus st ON st.id = p.idPetStatus
             INNER JOIN PetBreed pb ON pb.id = p.idPetBreed
             INNER JOIN PetType pt ON pt.id = pb.idPetType
             INNER JOIN PetSize sz ON sz.id = p.idPetSize
             INNER JOIN PetColor co ON co.id = p.idPetColor
             INNER JOIN PetEnergy en ON en.id = p.idPetEnergy
             INNER JOIN PetSeverity sv ON sv.id = p.idPetSeverity
             INNER JOIN PetTrainability tr ON tr.id = p.idPetTrainability
             INNER JOIN Person pe ON pe.id = p.idPerson
             LEFT JOIN Location lo ON lo.id = p.idLocation
             LEFT JOIN District di ON di.id = lo.idDistrict
             LEFT JOIN Canton ca ON ca.id = di.idCanton
             LEFT JOIN Province pv ON pv.id = ca.idProvince
             LEFT JOIN Country cn ON cn.id = pv.idCountry
             LEFT JOIN Person pf ON pf.id = p.idFosterHome
             LEFT JOIN Veterinarian vt ON vt.id = p.idVeterinarian
             LEFT JOIN Person pvt ON pvt.id = vt.idPerson
             LEFT JOIN Reward rw ON rw.id = (SELECT MAX(r2.id) FROM Reward r2 WHERE r2.idPet = p.id)
             LEFT JOIN CurrencyType cu ON cu.id = rw.idCurrencyType
    WHERE (pnId_pet IS NULL OR p.id = pnId_pet)
      AND (TRIM(pcName) IS NULL OR LOWER(p.name) LIKE CONCAT('%', LOWER(TRIM(pcName)), '%'))
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
      AND (pnId_disease IS NULL OR EXISTS (SELECT 1 FROM Disease_x_pet dp WHERE dp.idPet = p.id AND dp.idDisease = pnId_disease))
      AND (pnId_person IS NULL OR p.idPerson = pnId_person)
      AND (pdDate_from IS NULL OR p.eventDate >= pdDate_from)
      AND (pdDate_to IS NULL OR p.eventDate < DATE_ADD(pdDate_to, INTERVAL 1 DAY))
    ORDER BY (p.eventDate IS NULL) ASC, p.eventDate DESC, p.id DESC;
END //

CREATE PROCEDURE pr_get_pet_diseases (IN pnId_pet INT)
BEGIN
    SELECT d.id, d.name
    FROM Disease d
             JOIN Disease_x_pet dp ON dp.idDisease = d.id
    WHERE dp.idPet = pnId_pet
    ORDER BY d.name;
END //

CREATE PROCEDURE pr_get_pet_contacts (IN pnId_pet INT)
BEGIN
    DECLARE vnId_person INT DEFAULT NULL;

    SELECT idPerson INTO vnId_person FROM Pet WHERE id = pnId_pet LIMIT 1;

    IF vnId_person IS NOT NULL THEN
        -- Se invoca el procedimiento. MySQL devolverá el Result Set implícitamente al cliente.
        CALL pr_get_person_contacts(vnId_person);
    END IF;
END //

CREATE PROCEDURE pr_get_disease_treatments (IN pnId_disease INT)
BEGIN
    SELECT t.id          AS treatmentId,
           t.name        AS treatmentName,
           td.timeLength,
           m.id          AS medicationId,
           m.name        AS medicationName,
           mt.dosage
    FROM Treatment_x_disease td
             INNER JOIN Treatment t ON t.id = td.idTreatment
             LEFT JOIN Medication_x_treatment mt ON mt.idTreatment = t.id
             LEFT JOIN Medication m ON m.id = mt.idMedication
    WHERE td.idDisease = pnId_disease
    ORDER BY t.name, m.name;
END //


-- ---------------------------------------------------------------------------------
-- ---------------- Mascotas sin adoptar y match perdidas/encontradas --------------
-- ---------------------------------------------------------------------------------

CREATE PROCEDURE pr_unadopted_pets (OUT pnResult INT)
BEGIN
    DECLARE vcStatus_in_adoption VARCHAR(30);
    DECLARE vnMonths INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;

    SET pnResult = 0;

    -- Asumiendo que fn_get_text y fn_get_number existen globalmente en MySQL
    SET vcStatus_in_adoption = fn_get_text('PET_STATUS_IN_ADOPTION');
    SET vnMonths = fn_get_number('UNADOPTED_ALERT_MONTHS');

    IF vcStatus_in_adoption IS NULL OR vnMonths IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
    ELSE
        SELECT p.id,
               p.name,
               pt.name AS typeName,
               pb.name AS breedName,
               p.estimatedAge,
               p.eventDate,
               TIMESTAMPDIFF(MONTH, p.eventDate, CURDATE()) AS monthsWaiting
        FROM Pet p
                 JOIN PetBreed pb ON pb.id = p.idPetBreed
                 JOIN PetType pt ON pt.id = pb.idPetType
                 JOIN PetStatus st ON st.id = p.idPetStatus
                 LEFT JOIN Adoption a ON a.idPet = p.id
        WHERE st.name = vcStatus_in_adoption
          AND p.eventDate <= DATE_SUB(CURDATE(), INTERVAL vnMonths MONTH)
          AND a.id IS NULL
        ORDER BY p.eventDate;
    END IF;
END //

CREATE PROCEDURE pr_match_lost_found (OUT pnResult INT)
BEGIN
    DECLARE vnStatus_lost INT;
    DECLARE vnStatus_found INT;
    DECLARE vnW_breed INT;
    DECLARE vnW_color INT;
    DECLARE vnW_size INT;
    DECLARE vnW_canton INT;
    DECLARE vnW_chip INT;
    DECLARE vnMin_score INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SELECT id INTO vnStatus_lost FROM PetStatus WHERE name = fn_get_text('PET_STATUS_LOST') LIMIT 1;
    SELECT id INTO vnStatus_found FROM PetStatus WHERE name = fn_get_text('PET_STATUS_FOUND') LIMIT 1;

    SET vnW_breed   = fn_get_number('MATCH_WEIGHT_BREED');
    SET vnW_color   = fn_get_number('MATCH_WEIGHT_COLOR');
    SET vnW_size    = fn_get_number('MATCH_WEIGHT_SIZE');
    SET vnW_canton  = fn_get_number('MATCH_WEIGHT_CANTON');
    SET vnW_chip    = fn_get_number('MATCH_WEIGHT_CHIP');
    SET vnMin_score = fn_get_number('MATCH_MIN_SCORE');

    IF vnStatus_lost IS NULL OR vnStatus_found IS NULL OR vnMin_score IS NULL THEN
        SET pnResult = 1020;
    ELSE
        SELECT m.*
        FROM (
                 SELECT l.id           AS lostPetId,
                        l.name         AS lostPetName,
                        lb.name        AS lostBreedName,
                        lc.name        AS lostColorName,
                        ls.name        AS lostSizeName,
                        l.eventDate    AS lostDate,
                        lca.name       AS lostCantonName,
                        TRIM(CONCAT(lpe.firstName, ' ', lpe.firstLastName)) AS lostReporterName,
                        f.id           AS foundPetId,
                        f.name         AS foundPetName,
                        fb.name        AS foundBreedName,
                        fc.name        AS foundColorName,
                        fs.name        AS foundSizeName,
                        f.eventDate    AS foundDate,
                        fca.name       AS foundCantonName,
                        TRIM(CONCAT(fpe.firstName, ' ', fpe.firstLastName)) AS foundReporterName,
                        (CASE WHEN l.idPetBreed = f.idPetBreed THEN vnW_breed ELSE 0 END
                            + CASE WHEN l.idPetColor = f.idPetColor THEN vnW_color ELSE 0 END
                            + CASE WHEN l.idPetSize = f.idPetSize THEN vnW_size ELSE 0 END
                            + CASE WHEN dl.idCanton = df.idCanton THEN vnW_canton ELSE 0 END
                            + CASE WHEN l.chipId = f.chipId THEN vnW_chip ELSE 0 END) AS matchScore
                 FROM Pet l
                          JOIN PetBreed lb ON lb.id = l.idPetBreed
                          JOIN PetColor lc ON lc.id = l.idPetColor
                          JOIN PetSize ls ON ls.id = l.idPetSize
                          JOIN Location ll ON ll.id = l.idLocation
                          JOIN District dl ON dl.id = ll.idDistrict
                          JOIN Canton lca ON lca.id = dl.idCanton
                          JOIN Person lpe ON lpe.id = l.idPerson
                          JOIN Pet f ON f.idPetStatus = vnStatus_found
                          JOIN PetBreed fb ON fb.id = f.idPetBreed
                          JOIN PetColor fc ON fc.id = f.idPetColor
                          JOIN PetSize fs ON fs.id = f.idPetSize
                          JOIN Location fl ON fl.id = f.idLocation
                          JOIN District df ON df.id = fl.idDistrict
                          JOIN Canton fca ON fca.id = df.idCanton
                          JOIN Person fpe ON fpe.id = f.idPerson
                 WHERE l.idPetStatus = vnStatus_lost
                   AND fb.idPetType = lb.idPetType
                   AND (l.eventDate IS NULL OR f.eventDate IS NULL OR f.eventDate >= l.eventDate)
             ) m
        WHERE m.matchScore >= vnMin_score
        ORDER BY m.matchScore DESC, m.foundDate DESC;
    END IF;
END //

    -- -----------------------------------------------------------------------------------------
    -- NOTA DE TRANSCRIPCIÓN MYSQL:
    -- En MySQL no existe UTL_MAIL nativamente. La lógica de envíos (cuerpo HTML y SMTP)
    -- deberá ejecutarse en la capa de la aplicación.
    -- Aquí se transcribe la lógica interna del Job que detecta el cruce e inserta en PetMatch.
    -- -----------------------------------------------------------------------------------------
CREATE PROCEDURE pr_job_match_exec ()
BEGIN

    DECLARE v_done INT DEFAULT 0;
    DECLARE v_lostPetId INT;
    DECLARE v_foundPetId INT;
    DECLARE v_matchScore INT;

    DECLARE cur_match CURSOR FOR
        SELECT l.id AS lostPetId, f.id AS foundPetId,
               (CASE WHEN l.idPetBreed = f.idPetBreed THEN fn_get_number('MATCH_WEIGHT_BREED') ELSE 0 END
                   + CASE WHEN l.idPetColor = f.idPetColor THEN fn_get_number('MATCH_WEIGHT_COLOR') ELSE 0 END
                   + CASE WHEN l.idPetSize = f.idPetSize THEN fn_get_number('MATCH_WEIGHT_SIZE') ELSE 0 END
                   + CASE WHEN dl.idCanton = df.idCanton THEN fn_get_number('MATCH_WEIGHT_CANTON') ELSE 0 END
                   + CASE WHEN l.chipId = f.chipId THEN fn_get_number('MATCH_WEIGHT_CHIP') ELSE 0 END) AS matchScore
        FROM Pet l
                 JOIN PetBreed lb ON lb.id = l.idPetBreed
                 JOIN Location ll ON ll.id = l.idLocation
                 JOIN District dl ON dl.id = ll.idDistrict
                 JOIN Pet f ON f.idPetStatus = (SELECT id FROM PetStatus WHERE name = fn_get_text('PET_STATUS_FOUND') LIMIT 1)
                 JOIN PetBreed fb ON fb.id = f.idPetBreed
                 JOIN Location fl ON fl.id = f.idLocation
                 JOIN District df ON df.id = fl.idDistrict
        WHERE l.idPetStatus = (SELECT id FROM PetStatus WHERE name = fn_get_text('PET_STATUS_LOST') LIMIT 1)
          AND fb.idPetType = lb.idPetType
          AND (l.eventDate IS NULL OR f.eventDate IS NULL OR f.eventDate >= l.eventDate)
        HAVING matchScore >= fn_get_number('MATCH_MIN_SCORE');

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur_match;
    match_loop: LOOP
        FETCH cur_match INTO v_lostPetId, v_foundPetId, v_matchScore;
        IF v_done = 1 THEN LEAVE match_loop; END IF;

        IF NOT EXISTS (SELECT 1 FROM PetMatch WHERE idLostPet = v_lostPetId AND idFoundPet = v_foundPetId) THEN
            INSERT INTO PetMatch (idLostPet, idFoundPet, matchDate, matchScore, notified)
            VALUES (v_lostPetId, v_foundPetId, CURDATE(), v_matchScore, 0);
        END IF;
    END LOOP;
    CLOSE cur_match;

    -- Al ser MySQL, el UPDATE que marca 'notified = 1' deberá llamarse luego
    -- de que el orquestador backend / Node / Python despache efectivamente los correos:
    -- UPDATE PetMatch SET notified = 1 WHERE notified = 0;

    COMMIT;
END //

DELIMITER ;