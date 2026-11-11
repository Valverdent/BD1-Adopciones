-- Es importante destacar que en MySql no hay paquetes como tal, si no que las funciones se cran a nivel general dentro de la BD, por tanto, se preocede a la creacion de las funciones y procedimientos a usar,
--  para hacer la equivalencia al paquete CATALOG

USE ADOPCION_APP;
-- -------------------------------------------------------------
-- ----------------------- HELPERS -----------------------------
-- -------------------------------------------------------------

DELIMITER //
-- Función que indica si el nombre de catálogo recibido es uno de los permitidos (1 = sí, 0 = no)
CREATE FUNCTION fn_is_catalog (pcCatalog VARCHAR(255)) 
RETURNS INT READS SQL DATA
BEGIN
    IF UPPER(TRIM(pcCatalog)) IN (
        'PROVINCE', 'CANTON', 'DISTRICT', 'ROLE', 'USER_STATUS', 'DONATION_TYPE', 'CURRENCY_TYPE',
        'PET_TYPE', 'PET_BREED', 'PET_SIZE', 'PET_COLOR', 'PET_SEVERITY', 'PET_ENERGY',
        'PET_TRAINABILITY', 'PET_STATUS', 'PHOTO_TYPE', 'DISEASE', 'HOUSE_TYPE',
        'EXERCISE_TIME', 'FOSTER_HOME_STATUS', 'COUNTRY', 'TREATMENT', 'MEDICATION'
    ) THEN
        RETURN 1;
    END IF;
    RETURN 0;
END //

-- Función que retorna el nombre actual de un valor del catálogo
CREATE FUNCTION fn_get_name (pcCatalog VARCHAR(255), pnId INT) 
RETURNS VARCHAR(255) READS SQL DATA
BEGIN
    DECLARE vcName VARCHAR(255);
    CASE UPPER(TRIM(pcCatalog))
        WHEN 'PROVINCE' THEN SELECT name INTO vcName FROM Province WHERE id = pnId;
        WHEN 'CANTON' THEN SELECT name INTO vcName FROM Canton WHERE id = pnId;
        WHEN 'DISTRICT' THEN SELECT name INTO vcName FROM District WHERE id = pnId;
        WHEN 'ROLE' THEN SELECT name INTO vcName FROM `Role` WHERE id = pnId;
        WHEN 'USER_STATUS' THEN SELECT name INTO vcName FROM UserStatus WHERE id = pnId;
        WHEN 'DONATION_TYPE' THEN SELECT name INTO vcName FROM DonationType WHERE id = pnId;
        WHEN 'CURRENCY_TYPE' THEN SELECT name INTO vcName FROM CurrencyType WHERE id = pnId;
        WHEN 'PET_TYPE' THEN SELECT name INTO vcName FROM PetType WHERE id = pnId;
        WHEN 'PET_BREED' THEN SELECT name INTO vcName FROM PetBreed WHERE id = pnId;
        WHEN 'PET_SIZE' THEN SELECT name INTO vcName FROM PetSize WHERE id = pnId;
        WHEN 'PET_COLOR' THEN SELECT name INTO vcName FROM PetColor WHERE id = pnId;
        WHEN 'PET_SEVERITY' THEN SELECT name INTO vcName FROM PetSeverity WHERE id = pnId;
        WHEN 'PET_ENERGY' THEN SELECT name INTO vcName FROM PetEnergy WHERE id = pnId;
        WHEN 'PET_TRAINABILITY' THEN SELECT name INTO vcName FROM PetTrainability WHERE id = pnId;
        WHEN 'PET_STATUS' THEN SELECT name INTO vcName FROM PetStatus WHERE id = pnId;
        WHEN 'PHOTO_TYPE' THEN SELECT name INTO vcName FROM PhotoType WHERE id = pnId;
        WHEN 'DISEASE' THEN SELECT name INTO vcName FROM Disease WHERE id = pnId;
        WHEN 'HOUSE_TYPE' THEN SELECT name INTO vcName FROM HouseType WHERE id = pnId;
        WHEN 'EXERCISE_TIME' THEN SELECT value INTO vcName FROM ExerciseTime WHERE id = pnId;
        WHEN 'FOSTER_HOME_STATUS' THEN SELECT name INTO vcName FROM FosterHomeStatus WHERE id = pnId;
        WHEN 'COUNTRY' THEN SELECT name INTO vcName FROM Country WHERE id = pnId;
        WHEN 'TREATMENT' THEN SELECT name INTO vcName FROM Treatment WHERE id = pnId;
        WHEN 'MEDICATION' THEN SELECT name INTO vcName FROM Medication WHERE id = pnId;
    END CASE;
    RETURN vcName;
END //

-- Función que indica si un valor es usado por algún parámetro del sistema (ej. PET_STATUS_ADOPTED = 'Adoptado').
-- Si se renombra o elimina ese valor, la lógica que lee el parámetro dejaría de encontrarlo.
CREATE FUNCTION fn_used_by_parameter (pcValue VARCHAR(255)) 
RETURNS INT READS SQL DATA
BEGIN
    DECLARE vnCount INT DEFAULT 0;
    SELECT COUNT(1) INTO vnCount FROM Parameter WHERE textValue = TRIM(pcValue);
    RETURN IF(vnCount > 0, 1, 0);
END //

DELIMITER ;

-- -------------------------------------------------------------
-- ----------------------- GETTERS -----------------------------
-- -------------------------------------------------------------

DELIMITER //


-- -------------------------------- Ubicación --------------------------------------

-- Todas las provincias
CREATE PROCEDURE pr_get_provinces() BEGIN SELECT id, name FROM Province ORDER BY name; END //

-- Cantones de una provincia (nulo = todos)
CREATE PROCEDURE pr_get_cantons(IN pnId_province INT) BEGIN SELECT id, name, idProvince FROM Canton WHERE idProvince = IFNULL(pnId_province, idProvince) ORDER BY name; END //

-- Distritos de un cantón (nulo = todos)
CREATE PROCEDURE pr_get_districts(IN pnId_canton INT) BEGIN SELECT id, name, idCanton FROM District WHERE idCanton = IFNULL(pnId_canton, idCanton) ORDER BY name; END //

-- Todos los países
CREATE PROCEDURE pr_get_countries() BEGIN SELECT id, name FROM Country ORDER BY name; END //

-- Provincias de un país (nulo = todas)
CREATE PROCEDURE pr_get_provinces_by_country(IN pnId_country INT) BEGIN SELECT id, name, idCountry FROM Province WHERE idCountry = IFNULL(pnId_country, idCountry) ORDER BY name; END //


-- --------------------------------- Usuarios --------------------------------------

-- Catálogo de roles
CREATE PROCEDURE pr_get_roles() BEGIN SELECT id, name FROM `Role` ORDER BY name; END //

-- Catálogo de estados de usuario
CREATE PROCEDURE pr_get_user_statuses() BEGIN SELECT id, name FROM UserStatus ORDER BY name; END //

-- -------------------------------- Donaciones -------------------------------------

-- Tipos de donación (voluntaria, por porcentaje, etc.)
CREATE PROCEDURE pr_get_donation_types() BEGIN SELECT id, name FROM DonationType ORDER BY name; END //

-- Monedas (colones, dólares)
CREATE PROCEDURE pr_get_currency_types() BEGIN SELECT id, name FROM CurrencyType ORDER BY name; END //

-- --------------------------------- Mascotas --------------------------------------

-- Tipos de mascota
CREATE PROCEDURE pr_get_pet_types() BEGIN SELECT id, name FROM PetType ORDER BY name; END //

-- Razas de un tipo de mascota (nulo = todas)
CREATE PROCEDURE pr_get_pet_breeds(IN pnId_pet_type INT) BEGIN SELECT id, name, idPetType FROM PetBreed WHERE idPetType = IFNULL(pnId_pet_type, idPetType) ORDER BY name; END //

-- Tamaños
CREATE PROCEDURE pr_get_pet_sizes() BEGIN SELECT id, name FROM PetSize ORDER BY id; END //

-- Colores
CREATE PROCEDURE pr_get_pet_colors() BEGIN SELECT id, name FROM PetColor ORDER BY name; END //

-- Severidad (crítico, mal estado, buen estado)
CREATE PROCEDURE pr_get_pet_severities() BEGIN SELECT id, name FROM PetSeverity ORDER BY id; END //

-- Niveles de energía
CREATE PROCEDURE pr_get_pet_energies() BEGIN SELECT id, name FROM PetEnergy ORDER BY id; END //

-- Facilidad de entrenamiento
CREATE PROCEDURE pr_get_pet_trainabilities() BEGIN SELECT id, name FROM PetTrainability ORDER BY id; END //

-- Estados de mascota (perdido, encontrado, en adopción, adoptado, etc.)
CREATE PROCEDURE pr_get_pet_statuses() BEGIN SELECT id, name FROM PetStatus ORDER BY name; END //

-- Tipos de foto (antes, después, adoptante con mascota, etc.)
CREATE PROCEDURE pr_get_photo_types() BEGIN SELECT id, name FROM PhotoType ORDER BY name; END //

-- Enfermedades
CREATE PROCEDURE pr_get_diseases() BEGIN SELECT id, name FROM Disease ORDER BY name; END //

-- Tratamientos
CREATE PROCEDURE pr_get_treatments() BEGIN SELECT id, name FROM Treatment ORDER BY name; END //

-- Medicamentos
CREATE PROCEDURE pr_get_medications() BEGIN SELECT id, name FROM Medication ORDER BY name; END //

-- ----------------------- Personas, adoptantes y casas cuna -----------------------

-- Tipos de vivienda
CREATE PROCEDURE pr_get_house_types() BEGIN SELECT id, name FROM HouseType ORDER BY name; END //

-- Tiempos de ejercicio
CREATE PROCEDURE pr_get_exercise_times() BEGIN SELECT id, value FROM ExerciseTime ORDER BY id; END //

-- Estados de casa cuna
CREATE PROCEDURE pr_get_foster_home_statuses() BEGIN SELECT id, name FROM FosterHomeStatus ORDER BY name; END //

DELIMITER ;


-- ---------------------------------------------------------------------------------
-- ----------------------- Administración de catálogos -----------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //

-- Obtener un catálogo
CREATE PROCEDURE pr_get_catalog (
   IN pcCatalog VARCHAR(255),
   IN pnId_parent INT,
   OUT pnResult INT
)
BEGIN
    SET pnResult = 0;

    IF fn_is_catalog(pcCatalog) = 0 THEN
        SET pnResult = 1030; -- c_dato_invalido
    ELSE
        CASE UPPER(TRIM(pcCatalog))
            WHEN 'CANTON' THEN SELECT id, name, idProvince AS idParent FROM Canton WHERE idProvince = IFNULL(pnId_parent, idProvince) ORDER BY id;
            WHEN 'DISTRICT' THEN SELECT id, name, idCanton AS idParent FROM District WHERE idCanton = IFNULL(pnId_parent, idCanton) ORDER BY id;
            WHEN 'PET_BREED' THEN SELECT id, name, idPetType AS idParent FROM PetBreed WHERE idPetType = IFNULL(pnId_parent, idPetType) ORDER BY id;
            WHEN 'PROVINCE' THEN SELECT id, name, idCountry AS idParent FROM Province WHERE idCountry = IFNULL(pnId_parent, idCountry) ORDER BY id;
            WHEN 'ROLE' THEN SELECT id, name, NULL AS idParent FROM `Role` ORDER BY id;
            WHEN 'USER_STATUS' THEN SELECT id, name, NULL AS idParent FROM UserStatus ORDER BY id;
            WHEN 'DONATION_TYPE' THEN SELECT id, name, NULL AS idParent FROM DonationType ORDER BY id;
            WHEN 'CURRENCY_TYPE' THEN SELECT id, name, NULL AS idParent FROM CurrencyType ORDER BY id;
            WHEN 'PET_TYPE' THEN SELECT id, name, NULL AS idParent FROM PetType ORDER BY id;
            WHEN 'PET_SIZE' THEN SELECT id, name, NULL AS idParent FROM PetSize ORDER BY id;
            WHEN 'PET_COLOR' THEN SELECT id, name, NULL AS idParent FROM PetColor ORDER BY id;
            WHEN 'PET_SEVERITY' THEN SELECT id, name, NULL AS idParent FROM PetSeverity ORDER BY id;
            WHEN 'PET_ENERGY' THEN SELECT id, name, NULL AS idParent FROM PetEnergy ORDER BY id;
            WHEN 'PET_TRAINABILITY' THEN SELECT id, name, NULL AS idParent FROM PetTrainability ORDER BY id;
            WHEN 'PET_STATUS' THEN SELECT id, name, NULL AS idParent FROM PetStatus ORDER BY id;
            WHEN 'PHOTO_TYPE' THEN SELECT id, name, NULL AS idParent FROM PhotoType ORDER BY id;
            WHEN 'DISEASE' THEN SELECT id, name, NULL AS idParent FROM Disease ORDER BY id;
            WHEN 'HOUSE_TYPE' THEN SELECT id, name, NULL AS idParent FROM HouseType ORDER BY id;
            WHEN 'EXERCISE_TIME' THEN SELECT id, value AS name, NULL AS idParent FROM ExerciseTime ORDER BY id;
            WHEN 'FOSTER_HOME_STATUS' THEN SELECT id, name, NULL AS idParent FROM FosterHomeStatus ORDER BY id;
            WHEN 'COUNTRY' THEN SELECT id, name, NULL AS idParent FROM Country ORDER BY id;
            WHEN 'TREATMENT' THEN SELECT id, name, NULL AS idParent FROM Treatment ORDER BY id;
            WHEN 'MEDICATION' THEN SELECT id, name, NULL AS idParent FROM Medication ORDER BY id;
        END CASE;
    END IF;
END //

-- Insertar un catálogo
CREATE PROCEDURE pr_insert_catalog (
   IN pcCatalog VARCHAR(255),
   IN pcName VARCHAR(255),
   IN pnId_parent INT,
   OUT pnId_catalog INT,
   OUT pnResult INT
)
BEGIN
    DECLARE vcName VARCHAR(255) DEFAULT TRIM(pcName);

    -- Manejo de excepciones equivalentes a Oracle
    DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END; -- DUP_VAL_ON_INDEX
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END; -- eFkNoExiste
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END; -- eDatoNulo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END; -- OTHERS

    SET pnResult = 0; -- c_exito

    IF fn_is_catalog(pcCatalog) = 0 OR vcName IS NULL OR vcName = '' THEN
        SET pnResult = 1030;
    ELSE
        START TRANSACTION;
        CASE UPPER(TRIM(pcCatalog))
            WHEN 'CANTON' THEN INSERT INTO Canton (name, idProvince) VALUES (vcName, pnId_parent);
            WHEN 'DISTRICT' THEN INSERT INTO District (name, idCanton) VALUES (vcName, pnId_parent);
            WHEN 'PET_BREED' THEN INSERT INTO PetBreed (name, idPetType) VALUES (vcName, pnId_parent);
            WHEN 'PROVINCE' THEN INSERT INTO Province (name, idCountry) VALUES (vcName, pnId_parent);
            WHEN 'ROLE' THEN INSERT INTO `Role` (name) VALUES (vcName);
            WHEN 'USER_STATUS' THEN INSERT INTO UserStatus (name) VALUES (vcName);
            WHEN 'DONATION_TYPE' THEN INSERT INTO DonationType (name) VALUES (vcName);
            WHEN 'CURRENCY_TYPE' THEN INSERT INTO CurrencyType (name) VALUES (vcName);
            WHEN 'PET_TYPE' THEN INSERT INTO PetType (name) VALUES (vcName);
            WHEN 'PET_SIZE' THEN INSERT INTO PetSize (name) VALUES (vcName);
            WHEN 'PET_COLOR' THEN INSERT INTO PetColor (name) VALUES (vcName);
            WHEN 'PET_SEVERITY' THEN INSERT INTO PetSeverity (name) VALUES (vcName);
            WHEN 'PET_ENERGY' THEN INSERT INTO PetEnergy (name) VALUES (vcName);
            WHEN 'PET_TRAINABILITY' THEN INSERT INTO PetTrainability (name) VALUES (vcName);
            WHEN 'PET_STATUS' THEN INSERT INTO PetStatus (name) VALUES (vcName);
            WHEN 'PHOTO_TYPE' THEN INSERT INTO PhotoType (name) VALUES (vcName);
            WHEN 'DISEASE' THEN INSERT INTO Disease (name) VALUES (vcName);
            WHEN 'HOUSE_TYPE' THEN INSERT INTO HouseType (name) VALUES (vcName);
            WHEN 'EXERCISE_TIME' THEN INSERT INTO ExerciseTime (value) VALUES (vcName);
            WHEN 'FOSTER_HOME_STATUS' THEN INSERT INTO FosterHomeStatus (name) VALUES (vcName);
            WHEN 'COUNTRY' THEN INSERT INTO Country (name) VALUES (vcName);
            WHEN 'TREATMENT' THEN INSERT INTO Treatment (name) VALUES (vcName);
            WHEN 'MEDICATION' THEN INSERT INTO Medication (name) VALUES (vcName);
        END CASE;
        
        SET pnId_catalog = LAST_INSERT_ID(); -- Reemplaza los sequences .NEXTVAL
        COMMIT;
    END IF;
END //

-- Actualizar un catálogo
CREATE PROCEDURE pr_update_catalog (
   IN pcCatalog VARCHAR(255),
   IN pnId_catalog INT,
   IN pcName VARCHAR(255),
   IN pnId_parent INT,
   OUT pnResult INT
)
BEGIN
    DECLARE vcName VARCHAR(255) DEFAULT TRIM(pcName);
    DECLARE vcOld_name VARCHAR(255);

    -- Manejo de excepciones equivalentes a Oracle
    DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END; 
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END; 
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END; 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END; 

    SET pnResult = 0; 

    IF fn_is_catalog(pcCatalog) = 0 OR vcName IS NULL OR vcName = '' THEN
        SET pnResult = 1030;
    ELSE
        SET vcOld_name = fn_get_name(pcCatalog, pnId_catalog);
        
        IF vcOld_name IS NULL THEN
            SET pnResult = 1100;
        ELSEIF vcOld_name != vcName AND fn_used_by_parameter(vcOld_name) = 1 THEN
            SET pnResult = 1103;
        ELSE
            START TRANSACTION;
            CASE UPPER(TRIM(pcCatalog))
                WHEN 'CANTON' THEN UPDATE Canton SET name = vcName, idProvince = IFNULL(pnId_parent, idProvince) WHERE id = pnId_catalog;
                WHEN 'DISTRICT' THEN UPDATE District SET name = vcName, idCanton = IFNULL(pnId_parent, idCanton) WHERE id = pnId_catalog;
                WHEN 'PET_BREED' THEN UPDATE PetBreed SET name = vcName, idPetType = IFNULL(pnId_parent, idPetType) WHERE id = pnId_catalog;
                WHEN 'PROVINCE' THEN UPDATE Province SET name = vcName, idCountry = IFNULL(pnId_parent, idCountry) WHERE id = pnId_catalog;
                WHEN 'ROLE' THEN UPDATE `Role` SET name = vcName WHERE id = pnId_catalog;
                WHEN 'USER_STATUS' THEN UPDATE UserStatus SET name = vcName WHERE id = pnId_catalog;
                WHEN 'DONATION_TYPE' THEN UPDATE DonationType SET name = vcName WHERE id = pnId_catalog;
                WHEN 'CURRENCY_TYPE' THEN UPDATE CurrencyType SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_TYPE' THEN UPDATE PetType SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_SIZE' THEN UPDATE PetSize SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_COLOR' THEN UPDATE PetColor SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_SEVERITY' THEN UPDATE PetSeverity SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_ENERGY' THEN UPDATE PetEnergy SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_TRAINABILITY' THEN UPDATE PetTrainability SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PET_STATUS' THEN UPDATE PetStatus SET name = vcName WHERE id = pnId_catalog;
                WHEN 'PHOTO_TYPE' THEN UPDATE PhotoType SET name = vcName WHERE id = pnId_catalog;
                WHEN 'DISEASE' THEN UPDATE Disease SET name = vcName WHERE id = pnId_catalog;
                WHEN 'HOUSE_TYPE' THEN UPDATE HouseType SET name = vcName WHERE id = pnId_catalog;
                WHEN 'EXERCISE_TIME' THEN UPDATE ExerciseTime SET value = vcName WHERE id = pnId_catalog;
                WHEN 'FOSTER_HOME_STATUS' THEN UPDATE FosterHomeStatus SET name = vcName WHERE id = pnId_catalog;
                WHEN 'COUNTRY' THEN UPDATE Country SET name = vcName WHERE id = pnId_catalog;
                WHEN 'TREATMENT' THEN UPDATE Treatment SET name = vcName WHERE id = pnId_catalog;
                WHEN 'MEDICATION' THEN UPDATE Medication SET name = vcName WHERE id = pnId_catalog;
            END CASE;
            COMMIT;
        END IF;
    END IF;
END //

-- Eliminar un catálogo
CREATE PROCEDURE pr_delete_catalog (
   IN pcCatalog VARCHAR(255),
   IN pnId_catalog INT,
   OUT pnResult INT
)
BEGIN
    DECLARE vcOld_name VARCHAR(255);

    -- 1451 es el código de MySQL cuando intentas borrar un registro que tiene referencias (eHijoExiste en Oracle)
    DECLARE EXIT HANDLER FOR 1451 BEGIN SET pnResult = 1102; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END;

    SET pnResult = 0;

    IF fn_is_catalog(pcCatalog) = 0 THEN
        SET pnResult = 1030;
    ELSE
        SET vcOld_name = fn_get_name(pcCatalog, pnId_catalog);

        IF vcOld_name IS NULL THEN
            SET pnResult = 1100;
        ELSEIF fn_used_by_parameter(vcOld_name) = 1 THEN
            SET pnResult = 1103;
        ELSE
            START TRANSACTION;
            CASE UPPER(TRIM(pcCatalog))
                WHEN 'PROVINCE' THEN DELETE FROM Province WHERE id = pnId_catalog;
                WHEN 'CANTON' THEN DELETE FROM Canton WHERE id = pnId_catalog;
                WHEN 'DISTRICT' THEN DELETE FROM District WHERE id = pnId_catalog;
                WHEN 'ROLE' THEN DELETE FROM `Role` WHERE id = pnId_catalog;
                WHEN 'USER_STATUS' THEN DELETE FROM UserStatus WHERE id = pnId_catalog;
                WHEN 'DONATION_TYPE' THEN DELETE FROM DonationType WHERE id = pnId_catalog;
                WHEN 'CURRENCY_TYPE' THEN DELETE FROM CurrencyType WHERE id = pnId_catalog;
                WHEN 'PET_TYPE' THEN DELETE FROM PetType WHERE id = pnId_catalog;
                WHEN 'PET_BREED' THEN DELETE FROM PetBreed WHERE id = pnId_catalog;
                WHEN 'PET_SIZE' THEN DELETE FROM PetSize WHERE id = pnId_catalog;
                WHEN 'PET_COLOR' THEN DELETE FROM PetColor WHERE id = pnId_catalog;
                WHEN 'PET_SEVERITY' THEN DELETE FROM PetSeverity WHERE id = pnId_catalog;
                WHEN 'PET_ENERGY' THEN DELETE FROM PetEnergy WHERE id = pnId_catalog;
                WHEN 'PET_TRAINABILITY' THEN DELETE FROM PetTrainability WHERE id = pnId_catalog;
                WHEN 'PET_STATUS' THEN DELETE FROM PetStatus WHERE id = pnId_catalog;
                WHEN 'PHOTO_TYPE' THEN DELETE FROM PhotoType WHERE id = pnId_catalog;
                WHEN 'DISEASE' THEN DELETE FROM Disease WHERE id = pnId_catalog;
                WHEN 'HOUSE_TYPE' THEN DELETE FROM HouseType WHERE id = pnId_catalog;
                WHEN 'EXERCISE_TIME' THEN DELETE FROM ExerciseTime WHERE id = pnId_catalog;
                WHEN 'FOSTER_HOME_STATUS' THEN DELETE FROM FosterHomeStatus WHERE id = pnId_catalog;
                WHEN 'COUNTRY' THEN DELETE FROM Country WHERE id = pnId_catalog;
                WHEN 'TREATMENT' THEN DELETE FROM Treatment WHERE id = pnId_catalog;
                WHEN 'MEDICATION' THEN DELETE FROM Medication WHERE id = pnId_catalog;
            END CASE;
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;

-- --------------------------------------------------------------------------------------
-- ----------------------- Asociaciones intermedias (N - N) -----------------------------
-- --------------------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE pr_add_treatment_to_disease (
   IN pnId_disease INT,
   IN pnId_treatment INT,
   IN pcTime_length VARCHAR(255),
   OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END;

    SET pnResult = 0;
    
    START TRANSACTION;
    INSERT INTO Treatment_x_disease (idDisease, idTreatment, timeLength)
    VALUES (pnId_disease, pnId_treatment, TRIM(pcTime_length));
    COMMIT;
END //

CREATE PROCEDURE pr_add_medication_to_treatment (
   IN pnId_treatment INT,
   IN pnId_medication INT,
   IN pcDosage VARCHAR(255),
   OUT pnResult INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END;

    SET pnResult = 0;
    
    START TRANSACTION;
    INSERT INTO Medication_x_treatment (idMedication, idTreatment, dosage)
    VALUES (pnId_medication, pnId_treatment, TRIM(pcDosage));
    COMMIT;
END //

DELIMITER ;