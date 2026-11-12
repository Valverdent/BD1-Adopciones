USE ADOPCION_APP;

DELIMITER //

-- ---------------------------------------------------------------------------------
-- -------------------------------- Asociaciones -----------------------------------
-- ---------------------------------------------------------------------------------

-- Función que verifica si ya existe una asociación con ese nombre
CREATE FUNCTION fn_association_exists (pcName VARCHAR(255)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE vnTest INT DEFAULT 0;
    SELECT 1 INTO vnTest
    FROM AnimalWelfareAssociation
    WHERE name = LOWER(TRIM(pcName)) LIMIT 1;
    RETURN vnTest;
END //

-- Procedimiento para el registro de una asociación a la BD
CREATE PROCEDURE pr_register_association (
    IN pcName VARCHAR(255),
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    OUT pnId_association INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT;

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END; -- DUP_VAL_ON_INDEX
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END; -- eFkNoExiste
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    -- Inserta la locación delegando al procedimiento de person_administration
    CALL pr_insert_location(pnId_district, pcAddress, vnId_location);

    -- Inserta la asociación de bienestar animal
    INSERT INTO AnimalWelfareAssociation (idLocation, name)
    VALUES (vnId_location, TRIM(pcName));

    SET pnId_association = LAST_INSERT_ID();
    COMMIT;
END //

-- Procedimiento para la actualización de datos de una asociación existente
CREATE PROCEDURE pr_update_association (
    IN pnId_association INT,
    IN pcName VARCHAR(255),
    IN pnId_district INT,
    IN pcAddress VARCHAR(255),
    OUT pnResult INT
)
BEGIN
    DECLARE vnId_location INT DEFAULT NULL;
    DECLARE vnUpdate_result INT;

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    -- Obtiene el idLocation de la asociación
    SELECT idLocation INTO vnId_location
    FROM AnimalWelfareAssociation
    WHERE id = pnId_association LIMIT 1;

    IF vnId_location IS NULL THEN
        SET pnResult = 1100;
        ROLLBACK;
    ELSE
        -- Delega la actualización al procedimiento especializado
        CALL pr_update_location(vnId_location, pnId_district, pcAddress, vnUpdate_result);

        IF vnUpdate_result <> 0 THEN
            SET pnResult = vnUpdate_result;
            ROLLBACK;
        ELSE
            -- Actualiza el nombre de la asociación
            UPDATE AnimalWelfareAssociation
            SET name = TRIM(pcName)
            WHERE id = pnId_association;

            COMMIT;
        END IF;
    END IF;
END //

-- Procedimiento getter universal para asociaciones con atributos calculados
CREATE PROCEDURE pr_get_associations_filtered (
    IN pnId_association INT,
    IN pnId_province INT,
    IN pnId_canton INT,
    IN pnId_district INT
)
BEGIN
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
           COALESCE((SELECT COUNT(1) FROM DonationDetail dd WHERE dd.idAnimalWelfareAssociation = a.id), 0) AS donationCount,
           COALESCE((SELECT SUM(dd.amount) FROM DonationDetail dd WHERE dd.idAnimalWelfareAssociation = a.id), 0) AS totalAmount
    FROM AnimalWelfareAssociation a
             INNER JOIN Location lo ON lo.id = a.idLocation
             INNER JOIN District di ON di.id = lo.idDistrict
             INNER JOIN Canton ca ON ca.id = di.idCanton
             INNER JOIN Province pv ON pv.id = ca.idProvince
    WHERE (pnId_association IS NULL OR a.id = pnId_association)
      AND (pnId_province IS NULL OR pv.id = pnId_province)
      AND (pnId_canton IS NULL OR ca.id = pnId_canton)
      AND (pnId_district IS NULL OR di.id = pnId_district)
    ORDER BY a.name;
END //


-- ---------------------------------------------------------------------------------
-- ---------------------------------- Donaciones -----------------------------------
-- ---------------------------------------------------------------------------------

-- Registro de una donación (soporta recompensas a múltiples asociaciones con porcentajes)
CREATE PROCEDURE pr_register_donation (
    IN pnId_person INT,
    IN pnId_donation_type INT,
    IN pnId_currency_type INT,
    IN pnAmount DECIMAL(12,2),
    IN pnId_reward INT,
    IN pdDonation_date DATE,
    IN pcDistribution VARCHAR(4000),
    OUT pnId_donation INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnAmount DECIMAL(12,2);
    DECLARE vnId_currency INT;
    DECLARE vnId_association INT;
    DECLARE vnPercentage DECIMAL(5,2);
    DECLARE vnDetail_amount DECIMAL(12,2);

    -- Variables para recorrer la lista delimitada por comas
    DECLARE v_count INT DEFAULT 1;
    DECLARE v_total INT;
    DECLARE v_pair VARCHAR(50);

    DECLARE EXIT HANDLER FOR 1062 BEGIN ROLLBACK; SET pnResult = 1004; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN ROLLBACK; SET pnResult = 1100; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    -- Si se dona una recompensa, el monto y la moneda salen de la recompensa (usando subconsultas con COALESCE)
    SELECT COALESCE((SELECT r.amount FROM Reward r WHERE r.id = pnId_reward LIMIT 1), pnAmount),
           COALESCE((SELECT r.idCurrencyType FROM Reward r WHERE r.id = pnId_reward LIMIT 1), pnId_currency_type)
    INTO vnAmount, vnId_currency;

    -- Encabezado de la donación
    INSERT INTO Donation (idPerson, idDonationType, idCurrencyType, idReward, donationDate)
    VALUES (pnId_person, pnId_donation_type, vnId_currency, pnId_reward, COALESCE(pdDonation_date, CURDATE()));

    SET pnId_donation = LAST_INSERT_ID();

    -- Detalle: procesa cada par 'idAsociacion:porcentaje'
    IF pcDistribution IS NOT NULL AND pcDistribution != '' THEN
        SET v_total = CHAR_LENGTH(pcDistribution) - CHAR_LENGTH(REPLACE(pcDistribution, ',', '')) + 1;
        WHILE v_count <= v_total DO
                -- Extrae un par "ID:PORCENTAJE", ej: "2:50"
                SET v_pair = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pcDistribution, ',', v_count), ',', -1));

                -- Separa el ID y el PORCENTAJE basado en los dos puntos (:)
                SET vnId_association = CAST(SUBSTRING_INDEX(v_pair, ':', 1) AS UNSIGNED);
                SET vnPercentage = CAST(SUBSTRING_INDEX(v_pair, ':', -1) AS DECIMAL(5,2));

                -- Calcula el monto trunncado a 2 decimales para este porcentaje
                SET vnDetail_amount = TRUNCATE((vnAmount * vnPercentage) / 100, 2);

                INSERT INTO DonationDetail (idAnimalWelfareAssociation, idDonation, amount, percentage)
                VALUES (vnId_association, pnId_donation, vnDetail_amount, vnPercentage);

                SET v_count = v_count + 1;
            END WHILE;
    END IF;

    COMMIT;
END //

-- Consulta de donaciones con filtros por rango de fecha, donador y asociación
CREATE PROCEDURE pr_get_donation_history (
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    IN pnId_person INT,
    IN pnId_association INT
)
BEGIN
    SELECT d.id AS donationId,
           d.donationDate,
           dt.name AS donationTypeName,
           p.id AS donorId,
           TRIM(CONCAT(p.firstName, ' ', p.firstLastName, ' ', COALESCE(p.secondLastName, ''))) AS donorName,
           a.id AS associationId,
           a.name AS associationName,
           c.name AS currencyName,
           dd.amount,
           dd.percentage
    FROM Donation d
             INNER JOIN DonationDetail dd ON dd.idDonation = d.id
             INNER JOIN AnimalWelfareAssociation a ON a.id = dd.idAnimalWelfareAssociation
             INNER JOIN Person p ON p.id = d.idPerson
             INNER JOIN CurrencyType c ON c.id = d.idCurrencyType
             INNER JOIN DonationType dt ON dt.id = d.idDonationType
    WHERE (pnId_person IS NULL OR p.id = pnId_person)
      AND (pnId_association IS NULL OR a.id = pnId_association)
      AND (pdDate_from IS NULL OR d.donationDate >= pdDate_from)
      AND (pdDate_to IS NULL OR d.donationDate < DATE_ADD(pdDate_to, INTERVAL 1 DAY))
    ORDER BY d.donationDate DESC, d.id DESC, a.name;
END //


-- ---------------------------------------------------------------------------------
-- ------------------------ Cambio de monto de donación ----------------------------
-- ---------------------------------------------------------------------------------

-- Cambia el monto total de una donación recalculando el monto de cada asociación
CREATE PROCEDURE pr_update_donation_amount (
    IN pnId_donation INT,
    IN pnAmount DECIMAL(12,2),
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET pnResult = 9000; END;

    SET pnResult = 0;
    START TRANSACTION;

    IF pnAmount IS NULL OR pnAmount <= 0 THEN
        SET pnResult = 1030; -- c_dato_invalido
        ROLLBACK;
    ELSE
        UPDATE DonationDetail
        SET amount = TRUNCATE((pnAmount * percentage) / 100, 2)
        WHERE idDonation = pnId_donation;

        IF ROW_COUNT() = 0 THEN
            SET pnResult = 1100; -- La donación no existe o no tiene detalle
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;