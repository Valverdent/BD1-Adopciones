/* Package:     pkg_statistics
 * Descripción: Manejo de y procesamiento de datos para estadísticas disponibles en capa de presentación  
 */
------------------------------------------------------------------------------
---------------------------- ESPECIFICACIÓN ----------------------------------
------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_statistics AS

-- Códigos de resultado
    c_exito                CONSTANT NUMBER := 0;
    c_dato_duplicado       CONSTANT NUMBER := 1004;
    c_parametro_faltante   CONSTANT NUMBER := 1020;
    c_dato_invalido        CONSTANT NUMBER := 1030;
    c_referencia_no_existe CONSTANT NUMBER := 1100;
    c_chip_existe          CONSTANT NUMBER := 1101;
    c_error_bd             CONSTANT NUMBER := 9000;

    PROCEDURE pr_stat_pets_status (
        pdDate_from  IN  DATE DEFAULT NULL,
        pdDate_to    IN  DATE DEFAULT NULL,
        p_cursor     OUT SYS_REFCURSOR,
        pnResult     OUT NUMBER);

    PROCEDURE pr_stat_donations_by_association (
        pdDate_from IN  DATE DEFAULT NULL,
        pdDate_to   IN  DATE DEFAULT NULL,
        p_cursor    OUT SYS_REFCURSOR,
        pnResult    OUT NUMBER);

    PROCEDURE pr_stat_donations_by_rescuer (
        pdDate_from IN  DATE DEFAULT NULL,
        pdDate_to   IN  DATE DEFAULT NULL,
        p_cursor    OUT SYS_REFCURSOR,
        pnResult    OUT NUMBER);

    PROCEDURE pr_stat_adoption_rate (
        p_idPetType   IN  NUMBER DEFAULT NULL,
        p_idPetBreed  IN  NUMBER DEFAULT NULL,
        p_cursor        OUT SYS_REFCURSOR,
        pnResult        OUT NUMBER);

    PROCEDURE pr_stat_unadopted_age (
        p_cursor  OUT SYS_REFCURSOR,
        pnResult  OUT NUMBER);

    PROCEDURE pr_stat_pets_by_canton (
        pdDate_from IN DATE DEFAULT NULL,
        pdDate_to   IN DATE DEFAULT NULL,
        p_cursor    OUT SYS_REFCURSOR,
        pnResult    OUT NUMBER);
END pkg_statistics;
/

---------------------------------------------------------------------------------
------------------------------- CUERPO ------------------------------------------
---------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_statistics AS
--------------------------------------------------
-- Cantidad total de mascotas por tipo y estado --
--------------------------------------------------

PROCEDURE pr_stat_pets_status (
    pdDate_from IN DATE DEFAULT NULL,
    pdDate_to   IN DATE DEFAULT NULL,
    p_cursor    OUT SYS_REFCURSOR,
    pnResult    OUT NUMBER) 
AS
BEGIN
    pnResult := c_exito;

    OPEN p_cursor FOR
        SELECT 
            pt.name AS typeName,
            ps.name AS statusName, 
            COUNT(p.id) AS total,
            ROUND(RATIO_TO_REPORT(COUNT(p.id)) OVER () *100, 2) AS percentage,
            SUM(COUNT(p.id)) OVER () AS totalRecords
        FROM Pet p
        JOIN PetBreed pb    ON p.idPetBreed = pb.id
        JOIN PetType pt     ON pb.idPetType = pt.id
        JOIN PetStatus ps   ON p.idPetStatus = ps.id
        WHERE p.creationDate >= NVL(pdDate_from, TRUNC(SYSDATE, 'YYYY'))
            AND p.creationDate < TRUNC(NVL(pdDate_to, SYSDATE)) + 1
        GROUP BY pt.name, ps.name
        ORDER BY pt.name, ps.name;

EXCEPTION
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_pets_status;

--------------------------------------------------------------------
-- Total donaciones por asociacion beneficiada por rango de fecha --
--------------------------------------------------------------------
PROCEDURE pr_stat_donations_by_association (
    pdDate_from   IN  DATE DEFAULT NULL,
    pdDate_to     IN  DATE DEFAULT NULL,
    p_cursor      OUT SYS_REFCURSOR,
    pnResult      OUT NUMBER)   
AS
BEGIN
    pnResult := c_exito;
    OPEN p_cursor FOR
        SELECT 
            a.name AS associationName,
            c.name AS currencyName,
            SUM(dd.amount) AS total,
            ROUND(RATIO_TO_REPORT(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) * 100, 2) AS percentage,
            SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) AS totalCurrencyAmount
        FROM donation d
        JOIN donationDetail dd ON dd.idDonation = d.id
        JOIN animalWelfareAssociation a ON a.id = dd.idAnimalWelfareAssociation
        JOIN currencyType c ON c.id = d.idCurrencyType

        WHERE d.donationDate >= NVL(pdDate_from, TRUNC(SYSDATE, 'YYYY'))
            AND d.donationDate < TRUNC(NVL(pdDate_to, SYSDATE)) + 1
        GROUP BY a.id, a.name, d.idCurrencyType, c.name
        ORDER BY c.name, total DESC;

EXCEPTION
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_donations_by_association;

--------------------------------------------------------
-- Total donaciones por rescatista por rango de fecha --
--------------------------------------------------------
PROCEDURE pr_stat_donations_by_rescuer (
    pdDate_from   IN  DATE DEFAULT NULL,
    pdDate_to     IN  DATE DEFAULT NULL,
    p_cursor      OUT SYS_REFCURSOR,
    pnResult      OUT NUMBER)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT NVL(res.id, 0) AS rescuerId,
                NVL(TRIM(res.firstName || ' ' || res.firstLastName || ' ' || res.secondLastName), 'Donación Voluntaria / Sin Rescatista') AS rescuerName,
                c.name AS currencyName,
                SUM(dd.amount) AS total,
                ROUND(RATIO_TO_REPORT(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) * 100, 2) AS percentage,
                SUM(SUM(dd.amount)) OVER (PARTITION BY d.idCurrencyType) AS totalCurrencyAmount
        FROM donation d
        JOIN donationDetail dd ON dd.idDonation = d.id
        -- LEFT JOIN no descartaría las donaciones voluntarias donde idReward es NULL
        INNER JOIN reward r ON r.id = d.idReward
        LEFT JOIN pet pt ON pt.id = r.idPet
        LEFT JOIN person res ON res.id = pt.idPerson
        INNER JOIN currencyType c ON c.id = d.idCurrencyType

        WHERE d.donationDate >= NVL(pdDate_from, TRUNC(SYSDATE, 'YYYY'))
            AND d.donationDate < TRUNC(NVL(pdDate_to, SYSDATE)) + 1
        GROUP BY res.id, res.firstName, res.firstLastName, res.secondLastName, d.idCurrencyType, c.name
        ORDER BY c.name, total DESC;

EXCEPTION
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_donations_by_rescuer;

-------------------------------------------------
-- Porcentaje adopciones exitosas vs en espera --
-------------------------------------------------
PROCEDURE pr_stat_adoption_rate(
    p_idPetType IN NUMBER DEFAULT NULL,
    p_idPetBreed    IN NUMBER DEFAULT NULL,
    p_cursor    OUT SYS_REFCURSOR,
    pnResult    OUT NUMBER)
AS
    vcStatus_adopted        VARCHAR2(30);
    vcStatus_in_adoption    VARCHAR2(30);
BEGIN 
    pnResult := c_exito;

    vcStatus_adopted        := pkg_parameter.fn_get_text('PET_STATUS_ADOPTED');
    vcStatus_in_adoption    := pkg_parameter.fn_get_text('PET_STATUS_IN_ADOPTION');

    OPEN p_cursor FOR
        SELECT
            ps.name AS statusName,
            COUNT(p.id) AS total,
            ROUND(RATIO_TO_REPORT(COUNT(p.id)) OVER () *100, 3) AS percentage,
            SUM(COUNT(p.id)) OVER () AS totalRecords
        FROM Pet p
        JOIN PetBreed pb ON p.idPetBreed = pb.id
        JOIN PetStatus ps ON p.idPetStatus = ps.id

        WHERE ps.name IN (vcStatus_adopted, vcStatus_in_adoption)
            AND pb.idPetType = NVL(p_idPetType, pb.idPetType)
            AND p.idPetbreed = NVL(p_idPetBreed, p.idPetBreed)
        GROUP BY ps.name
        ORDER BY ps.name;

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        pnResult := c_parametro_faltante;
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_adoption_rate;

----------------------------------------------------------------
-- Total y porcentaje de mascotas no adoptadas por rango edad --
----------------------------------------------------------------
PROCEDURE pr_stat_unadopted_age (
   p_cursor  OUT SYS_REFCURSOR,
   pnResult  OUT NUMBER)
AS
   vcStatus_adopted  VARCHAR2(30);
   vnLimit1           NUMBER;
   vnLimit2           NUMBER;
   vnLimit3           NUMBER;
   vnLimit4           NUMBER;
   vnLimit5           NUMBER;
BEGIN 
    pnResult := c_exito;

    vcStatus_adopted := pkg_parameter.fn_get_text('PET_STATUS_ADOPTED');
    vnLimit1 := pkg_parameter.fn_get_number('AGE_LIMIT_1');
    vnLimit2 := pkg_parameter.fn_get_number('AGE_LIMIT_2');
    vnLimit3 := pkg_parameter.fn_get_number('AGE_LIMIT_3');
    vnLimit4 := pkg_parameter.fn_get_number('AGE_LIMIT_4');
    vnLimit5 := pkg_parameter.fn_get_number('AGE_LIMIT_5');

    OPEN p_cursor FOR
        SELECT 
            r.ageRange,
            COUNT(1) AS total,
            ROUND(RATIO_TO_REPORT(COUNT(1)) OVER () * 100, 2) AS percentage,
            SUM(COUNT(1)) OVER () AS totalRecords
        FROM (
            SELECT 
                CASE
                    WHEN p.estimatedAge <= vnLimit1 THEN '0 - ' || vnLimit1
                    WHEN p.estimatedAge <= vnLimit2 THEN vnLimit1 || ' - ' || vnLimit2
                    WHEN p.estimatedAge <= vnLimit3 THEN vnLimit2 || ' - ' || vnLimit3
                    WHEN p.estimatedAge <= vnLimit4 THEN vnLimit3 || ' - ' || vnLimit4
                    WHEN p.estimatedAge <= vnLimit5 THEN vnLimit4 || ' - ' || vnLimit5
                    ELSE vnLimit5 || ' +'
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

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        pnResult := c_parametro_faltante;
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_unadopted_age;


------------------------------------------------
-- Mascotas perdidas y encontradas por canton --
------------------------------------------------

PROCEDURE pr_stat_pets_by_canton (
    pdDate_from IN DATE DEFAULT NULL,
    pdDate_to   IN DATE DEFAULT NULL,
    p_cursor    OUT SYS_REFCURSOR,
    pnResult    OUT NUMBER)
AS 
    vcStatus_lost     VARCHAR2(30);
    vcStatus_found    VARCHAR2(30);
BEGIN
    pnResult := c_exito;

    vcStatus_lost := pkg_parameter.fn_get_text('PET_STATUS_LOST');
    vcStatus_found := pkg_parameter.fn_get_text('PET_STATUS_FOUND');

    OPEN p_cursor FOR
        SELECT
            c.name AS cantonName,
            ps.name AS statusType,
            COUNT(p.id) AS totalIncidents,
            ROUND(RATIO_TO_REPORT(COUNT(p.id)) OVER () * 100, 2) AS percentage,
            SUM(COUNT(p.id)) OVER () AS totalRecords
        FROM Pet p
        JOIN PetStatus ps   ON p.idPetStatus = ps.id
        JOIN Location l     ON p.idLocation = l.id
        JOIN District d     ON l.idDistrict = d.id
        JOIN Canton c       ON d.idCanton = c.id
        WHERE ps.name IN (vcStatus_lost, vcStatus_found)
            AND p.eventDate >= NVL(pdDate_from, TRUNC(SYSDATE, 'YYYY'))
            AND p.eventDate < TRUNC(NVL(pdDate_to, SYSDATE)) + 1
        GROUP BY c.name, ps.name
        ORDER BY totalIncidents DESC;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        pnResult := c_parametro_faltante;
    WHEN OTHERS THEN
        pnResult := c_error_bd;
END pr_stat_pets_by_canton;

END pkg_statistics;
/

