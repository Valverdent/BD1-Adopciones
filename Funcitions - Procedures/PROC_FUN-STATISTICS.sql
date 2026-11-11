USE ADOPCION_APP;
-- ------------------------------------------------
-- Cantidad total de mascotas por tipo y estado --
-- ------------------------------------------------

DELIMITER //
CREATE PROCEDURE pr_stat_pets_status (
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SELECT
        pt.name AS typeName,
        ps.name AS statusName,
        COUNT(p.id) AS total,
        ROUND(COUNT(p.id) *100 / SUM(COUNT(p.id)) OVER () *100, 2) AS percentage,
        SUM(COUNT(p.id)) OVER () AS totalRecords
    FROM Pet p
    JOIN PetBreed pb    ON p.idPetBreed = pb.id
    JOIN PetType pt     ON pb.idPetType = pt.id
    JOIN PetStatus ps   ON p.idPetStatus = ps.id
    WHERE p.creationDate >= IFNULL(pdDate_from, DATE_FORMAT(CURRENT_DATE, '%Y-01-01'))
        AND p.creationDate < DATE_ADD(DATE(IFNULL(pdDate_to, CURRENT_DATE)), INTERVAL 1 DAY)
    GROUP BY pt.name, ps.name
    ORDER BY pt.name, ps.name;
END //

-- ------------------------------------------------------------------
-- Total donaciones por asociacion beneficiada por rango de fecha --
-- ------------------------------------------------------------------
CREATE PROCEDURE pr_stat_donations_by_association (
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    OUT pnResult INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SELECT
        a.name AS associationName,
        c.name AS currencyName,
        SUM(dd.amount) AS total,
        ROUND(SUM(dd.amount) * 100.0 / SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType), 2) AS percentage,
        SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) AS totalCurrencyAmount
    FROM Donation d
    JOIN DonationDetail dd ON dd.idDonation = d.id
    JOIN AnimalWelfareAssociation a ON a.id = dd.idAnimalWelfareAssociation
    JOIN CurrencyType c ON c.id = d.idCurrencyType

    WHERE d.donationDate >= IFNULL(pdDate_from, DATE_FORMAT(CURRENT_DATE, '%Y-01-01'))
        AND d.donationDate < DATE_ADD(DATE(IFNULL(pdDate_to, CURRENT_DATE)), INTERVAL 1 DAY)
    GROUP BY a.id, a.name, d.idCurrencyType, c.name
    ORDER BY c.name, total DESC;
END //

-- ------------------------------------------------------
-- Total donaciones por rescatista por rango de fecha --
-- ------------------------------------------------------
CREATE PROCEDURE pr_stat_donations_by_rescuer (
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SELECT
        IFNULL(res.id, 0) AS rescuerId,
        IFNULL(NULLIF(TRIM(CONCAT_WS(' ', res.firstName, res.firstLastName, res.secondLastName)),''), 'Donación Voluntaria / Sin Rescatista') AS rescuerName,
        c.name AS currencyName,
        SUM(dd.amount) AS total,
        ROUND(SUM(dd.amount) * 100.0 / SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType), 2) AS percentage,
            SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) AS totalCurrencyAmount
    FROM Donation d
    JOIN DonationDetail dd ON dd.idDonation = d.id
    -- LEFT JOIN no descartaría las donaciones voluntarias donde idReward es NULL
    INNER JOIN Reward r ON r.id = d.idReward
    LEFT JOIN Pet pt ON pt.id = r.idPet
    LEFT JOIN Person res ON res.id = pt.idPerson
    INNER JOIN CurrencyType c ON c.id = d.idCurrencyType

    WHERE d.donationDate >= IFNULL(pdDate_from, DATE_FORMAT(CURRENT_DATE, '%Y-01-01'))
      AND d.donationDate < DATE_ADD(DATE(IFNULL(pdDate_to, CURRENT_DATE)), INTERVAL 1 DAY)
    GROUP BY res.id, res.firstName, res.firstLastName, res.secondLastName, d.idCurrencyType, c.name
    ORDER BY c.name, total DESC;
END //

-- -----------------------------------------------
-- Porcentaje adopciones exitosas vs en espera --
-- -----------------------------------------------
CREATE PROCEDURE pr_stat_adoption_rate(
    IN p_idPetType INT,
    IN p_idPetBreed INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vcStatus_adopted VARCHAR(255);
    DECLARE vcStatus_in_adoption VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SET vcStatus_adopted = fn_get_text('PET_STATUS_ADOPTED');
    SET vcStatus_in_adoption = fn_get_text('PET_STATUS_IN_ADOPTION');

    IF vcStatus_adopted IS NULL OR vcStatus_in_adoption IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
    ELSE
        SELECT
            ps.name AS statusName,
            COUNT(p.id) AS total,
            ROUND(COUNT(p.id) * 100.0 / SUM(COUNT(p.id)) OVER (), 3) AS percentage,
            SUM(COUNT(p.id)) OVER () AS totalRecords
        FROM Pet p
        JOIN PetBreed pb ON p.idPetBreed = pb.id
        JOIN PetStatus ps ON p.idPetStatus = ps.id

        WHERE ps.name IN (vcStatus_adopted, vcStatus_in_adoption)
            AND pb.idPetType = NVL(p_idPetType, pb.idPetType)
            AND p.idPetbreed = NVL(p_idPetBreed, p.idPetBreed)
        GROUP BY ps.name
        ORDER BY ps.name;
    END IF;
END //

-- --------------------------------------------------------------
-- Total y porcentaje de mascotas no adoptadas por rango edad --
-- --------------------------------------------------------------
CREATE PROCEDURE pr_stat_unadopted_age (
   OUT pnResult INT)
BEGIN
    DECLARE vcStatus_adopted   VARCHAR(255);
    DECLARE vnLimit1           INT;
    DECLARE vnLimit2           INT;
    DECLARE vnLimit3           INT;
    DECLARE vnLimit4           INT;
    DECLARE vnLimit5           INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SET vcStatus_adopted = fn_get_text('PET_STATUS_ADOPTED');
    SET vnLimit1 = fn_get_number('AGE_LIMIT_1');
    SET vnLimit2 = fn_get_number('AGE_LIMIT_2');
    SET vnLimit3 = fn_get_number('AGE_LIMIT_3');
    SET vnLimit4 = fn_get_number('AGE_LIMIT_4');
    SET vnLimit5 = fn_get_number('AGE_LIMIT_5');

    IF vcStatus_adopted IS NULL OR vnLimit1 IS NULL OR vnLimit5 IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
    ELSE
        SELECT 
            r.ageRange,
            COUNT(1) AS total,
            ROUND(COUNT(1) *100.0 / SUM(COUNT(1)) OVER (), 2) AS percentage,
            SUM(COUNT(1)) OVER () AS totalRecords
        FROM (
            SELECT 
                CASE
                    WHEN p.estimatedAge <= vnLimit1 THEN CONCAT('0 - ', vnLimit1)
                    WHEN p.estimatedAge <= vnLimit2 THEN CONCAT(vnLimit1, ' - ', vnLimit2)
                    WHEN p.estimatedAge <= vnLimit3 THEN CONCAT(vnLimit2, ' - ', vnLimit3)
                    WHEN p.estimatedAge <= vnLimit4 THEN CONCAT(vnLimit3, ' - ', vnLimit4)
                    WHEN p.estimatedAge <= vnLimit5 THEN CONCAT(vnLimit4, ' - ', vnLimit5)
                    ELSE CONCAT(vnLimit5, ' +')
                END AS ageRange,
                CASE
                    WHEN p.estimatedAge <= vnLimit1 THEN 1
                    WHEN p.estimatedAge <= vnLimit2 THEN 2
                    WHEN p.estimatedAge <= vnLimit3 THEN 3
                    WHEN p.estimatedAge <= vnLimit4 THEN 4
                    WHEN p.estimatedAge <= vnLimit5 THEN 5
                    ELSE 6
                END AS rangeOrder
            FROM Pet p
            JOIN PetStatus ps ON p.idPetStatus = ps.id
            WHERE ps.name != vcStatus_adopted
                AND p.estimatedAge IS NOT NULL
        ) r
        GROUP BY r.ageRange, r.rangeOrder
        ORDER BY r.rangeOrder;
    END IF;
END //


-- ----------------------------------------------
-- Mascotas perdidas y encontradas por canton --
-- ----------------------------------------------

CREATE PROCEDURE pr_stat_pets_by_canton (
    IN pdDate_from DATE,
    IN pdDate_to DATE,
    OUT pnResult INT
)
BEGIN
    DECLARE vcStatus_lost   VARCHAR(255);
    DECLARE vcStatus_found  VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; END;
    SET pnResult = 0;

    SET vcStatus_lost = fn_get_text('PET_STATUS_LOST');
    SET vcStatus_found = fn_get_text('PET_STATUS_FOUND');

    IF vcStatus_lost IS NULL OR vcStatus_found IS NULL THEN
        SET pnResult = 1020; -- c_parametro_faltante
    ELSE
        SELECT
            c.name AS cantonName,
            ps.name AS statusType,
            COUNT(p.id) AS totalIncidents,
            ROUND(COUNT(p.id) * 100.0 / SUM(COUNT(p.id)) OVER (), 2) AS percentage,
            SUM(COUNT(p.id)) OVER () AS totalRecords
        FROM Pet p
        JOIN PetStatus ps   ON p.idPetStatus = ps.id
        JOIN Location l     ON p.idLocation = l.id
        JOIN District d     ON l.idDistrict = d.id
        JOIN Canton c       ON d.idCanton = c.id
        WHERE ps.name IN (vcStatus_lost, vcStatus_found)
            AND p.eventDate >= IFNULL(pdDate_from, DATE_FORMAT(CURRENT_DATE, '%Y-01-01'))
            AND p.eventDate < DATE_ADD(DATE(IFNULL(pdDate_to, CURRENT_DATE)), INTERVAL 1 DAY)
        GROUP BY c.name, ps.name
        ORDER BY totalIncidents DESC;
    END IF;
END //
DELIMITER ;
