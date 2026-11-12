USE ADOPCION_APP;

DELIMITER //

-- ---------------------------------------------------------------------------------
-- ------------------------------ Casas Cuna ---------------------------------------
-- ---------------------------------------------------------------------------------

-- Disponibilidad de casas cuna por provincia, tipo de mascota aceptada y espacios libres mínimos
CREATE PROCEDURE pr_get_foster_home_availability (
    IN pnId_province INT,
    IN pnId_pet_type INT,
    IN pnMin_spots INT
)
BEGIN
    SELECT fh.idFosterHome AS id,
           TRIM(CONCAT(pe.firstName, ' ', pe.firstLastName, ' ', COALESCE(pe.secondLastName, ''))) AS ownerName,
           pv.id   AS provinceId,
           pv.name AS provinceName,
           ca.name AS cantonName,
           di.name AS districtName,
           lo.address,
           fs.name AS statusName,
           pt.id   AS petTypeId,
           pt.name AS petTypeName,
           fh.maxCapacity,
           (SELECT COUNT(1) FROM Pet pe2 WHERE pe2.idFosterHome = fh.idFosterHome) AS currentPets,
           fh.maxCapacity - (SELECT COUNT(1) FROM Pet pe2 WHERE pe2.idFosterHome = fh.idFosterHome) AS availableSpots,
           fh.requiresFoodDonation
    FROM FosterHome fh
             INNER JOIN Person pe ON pe.id = fh.idFosterHome
             INNER JOIN Location lo ON lo.id = fh.idLocation
             INNER JOIN District di ON di.id = lo.idDistrict
             INNER JOIN Canton ca ON ca.id = di.idCanton
             INNER JOIN Province pv ON pv.id = ca.idProvince
             INNER JOIN FosterHomeStatus fs ON fs.id = fh.idFosterHomeStatus
             INNER JOIN FosterHome_x_petType ft ON ft.idFosterHome = fh.idFosterHome
             INNER JOIN PetType pt ON pt.id = ft.idPetType
    WHERE (pnId_province IS NULL OR pv.id = pnId_province)
      AND (pnId_pet_type IS NULL OR pt.id = pnId_pet_type)
      AND (fh.maxCapacity - (SELECT COUNT(1) FROM Pet pe2 WHERE pe2.idFosterHome = fh.idFosterHome) >= COALESCE(pnMin_spots, 1))
    ORDER BY pv.name, availableSpots DESC, ca.name, di.name, fh.idFosterHome, pt.name;
END //


-- ---------------------------------------------------------------------------------
-- ----------------------------- Mascotas Perdidas ---------------------------------
-- ---------------------------------------------------------------------------------

-- Mascotas perdidas por tipo de mascota y provincia, ordenadas por recompensa de mayor a menor
CREATE PROCEDURE pr_get_lost_pets (
    IN pnId_pet_type INT,
    IN pnId_province INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnStatus_lost INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;

    SET pnResult = 0;

    -- Se obtiene el ID del estado "perdida" de forma dinámica
    SELECT id INTO vnStatus_lost
    FROM PetStatus
    WHERE name = fn_get_text('PET_STATUS_LOST') LIMIT 1;

    IF vnStatus_lost IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
    ELSE
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
               TRIM(CONCAT(pe.firstName, ' ', pe.firstLastName)) AS reporterName,
               cu.name            AS currencyName,
               rw.amount          AS rewardAmount,
               p.notesDescription
        FROM Pet p
                 INNER JOIN PetBreed pb ON pb.id = p.idPetBreed
                 INNER JOIN PetType pt ON pt.id = pb.idPetType
                 INNER JOIN PetSize sz ON sz.id = p.idPetSize
                 INNER JOIN PetColor co ON co.id = p.idPetColor
                 INNER JOIN Location lo ON lo.id = p.idLocation
                 INNER JOIN District di ON di.id = lo.idDistrict
                 INNER JOIN Canton ca ON ca.id = di.idCanton
                 INNER JOIN Province pv ON pv.id = ca.idProvince
                 INNER JOIN Person pe ON pe.id = p.idPerson
                 LEFT  JOIN Reward rw ON rw.idPet = p.id
                 LEFT  JOIN CurrencyType cu ON cu.id = rw.idCurrencyType
        WHERE p.idPetStatus = vnStatus_lost
          AND (pnId_pet_type IS NULL OR pb.idPetType = pnId_pet_type)
          AND (pnId_province IS NULL OR pv.id = pnId_province)
        ORDER BY COALESCE(rw.amount, 0) DESC, p.eventDate DESC, p.id DESC;
    END IF;
END //


-- ---------------------------------------------------------------------------------
-- --------------------------------- Bitácora --------------------------------------
-- ---------------------------------------------------------------------------------

-- Consulta de la bitácora (ADOPCION_AUDIT.changeLog). 
CREATE PROCEDURE pr_get_changelog (
    IN pcUsername VARCHAR(255),
    IN pcTable_name VARCHAR(255),
    IN pcField_name VARCHAR(255),
    IN pcRecord_id VARCHAR(255),
    IN pcText VARCHAR(255),
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    OUT pnResult INT
)
BEGIN
    DECLARE vcUsername VARCHAR(255) DEFAULT LOWER(TRIM(pcUsername));
    DECLARE vcTable VARCHAR(255) DEFAULT LOWER(TRIM(pcTable_name));
    DECLARE vcField VARCHAR(255) DEFAULT LOWER(TRIM(pcField_name));
    DECLARE vcRecord VARCHAR(255) DEFAULT TRIM(pcRecord_id);
    DECLARE vcText VARCHAR(255) DEFAULT LOWER(TRIM(pcText));

    -- Captura de error en caso de que falten permisos sobre el esquema de auditoría
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;

    SET pnResult = 0;

    SELECT c.id,
           c.createdBy AS username,
           c.schemeName,
           c.tableName,
           c.fieldName,
           c.recordId,
           c.oldValue,
           c.newValue,
           c.changeDescription,
           c.changeDate
    FROM ADOPCION_AUDIT.ChangeLog c
    WHERE (vcUsername IS NULL OR LOWER(c.createdBy) LIKE CONCAT('%', vcUsername, '%'))
      AND (vcTable IS NULL OR LOWER(c.tableName) LIKE CONCAT('%', vcTable, '%'))
      AND (vcField IS NULL OR LOWER(c.fieldName) LIKE CONCAT('%', vcField, '%'))
      AND (vcRecord IS NULL OR c.recordId = vcRecord)
      AND (vcText IS NULL
        OR LOWER(c.oldValue) LIKE CONCAT('%', vcText, '%')
        OR LOWER(c.newValue) LIKE CONCAT('%', vcText, '%')
        OR LOWER(c.changeDescription) LIKE CONCAT('%', vcText, '%'))
      AND (pdDate_from IS NULL OR c.changeDate >= pdDate_from)
      AND (pdDate_to IS NULL OR c.changeDate < DATE_ADD(pdDate_to, INTERVAL 1 DAY))
    ORDER BY c.changeDate DESC, c.id DESC;
END //

-- Nombres de las tablas que aparecen en la bitácora
CREATE PROCEDURE pr_get_changelog_tables (
    OUT pnResult INT
)
BEGIN
    -- Captura de error en caso de que falten permisos
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;

    SET pnResult = 0;

    SELECT DISTINCT tableName
    FROM ADOPCION_AUDIT.ChangeLog
    WHERE tableName IS NOT NULL
    ORDER BY tableName;
END //

DELIMITER ;