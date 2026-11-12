USE ADOPCION_APP;
-- -----------------------------------------------------------------------
-- ----------------- Verificaciones de duplicados ------------------------
-- -----------------------------------------------------------------------

-- HELPERS
DELIMITER //
-- Función que verifica la existencia de un usuario en la BD
CREATE FUNCTION fn_username_exists (pcUsername VARCHAR(255))
RETURNS INT READS SQL DATA
BEGIN
    DECLARE vnCount INT DEFAULT 0;
    SELECT COUNT(1)
    INTO vnCount
    FROM `User`
    WHERE LOWER(username) = LOWER(TRIM(pcUsername));
    RETURN IF(vnCount > 0, 1, 0);
END //

-- Función que verifica la existencia de un correo en la BD
CREATE FUNCTION fn_email_exists (pcEmail VARCHAR(255))
RETURNS INT READS SQL DATA
BEGIN
    DECLARE vnCount INT DEFAULT 0;
    SELECT COUNT(1)
    INTO vnCount
    FROM ContactEmail
    WHERE LOWER(email) = LOWER(TRIM(pcEmail));
    RETURN IF(vnCount > 0, 1, 0);
END //

DELIMITER //
-- Función que verifica la existencia de un teléfono en la BD
CREATE FUNCTION fn_phone_exists (pcPhone VARCHAR(255))
RETURNS INT READS SQL DATA
BEGIN
    DECLARE vnCount INT DEFAULT 0;
    SELECT COUNT(1)
    INTO vnCount
    FROM ContactNumber
    WHERE phoneNumber = TRIM(pcPhone);
    RETURN IF(vnCount > 0, 1, 0);
END //

-- Función que retorna el nombre del estado "activo" (parametrizado)
CREATE FUNCTION fn_active_status_name ()
RETURNS VARCHAR(255) READS SQL DATA
BEGIN
    RETURN fn_get_text('ACTIVE_USER_STATUS');
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ----------------- Registrar datos e iniciar sesión ------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //
-- Procedimiento encargado del registro de un usuario en la BD
CREATE PROCEDURE pr_register_user (
    IN pcFirst_name VARCHAR(255),
    IN pcMiddle_name VARCHAR(255),
    IN pcFirst_lastName VARCHAR(255),
    IN pcSecond_lastName VARCHAR(255),

    IN pnId_district INT,
    IN pcAddress VARCHAR(255),

    IN pcPhone VARCHAR(255),
    IN pcEmail VARCHAR(255),
    IN pcUsername VARCHAR(255),
    IN pcPassword_hash VARCHAR(255), -- Recibe el Hash de 64 caracteres generado por el BackEnd

    OUT pnResult INT
)
BEGIN
   DECLARE vnId_person  INT;
   DECLARE vnId_role    INT;
   DECLARE vnId_status  INT;
   DECLARE vnResult     INT;

   -- Manejo de excepciones
   DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END; -- Dato duplicado
   DECLARE EXIT HANDLER FOR 1048, 1406 BEGIN SET pnResult = 1030; ROLLBACK; END; -- Nulo o largo
   DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END; -- Error general

   SET pnResult = 0;

   -- Valida que la contraseña hash no venga vacía y tenga la longitud de SHA-256 (64 caracteres)
    IF TRIM(pcPassword_hash) IS NULL OR TRIM(pcPassword_hash) = '' OR CHAR_LENGTH(TRIM(pcPassword_hash)) <> 64 THEN
      SET pnResult = 1030; -- c_dato_invalido
    ELSE
        -- Rol y estado por defecto (parametrizados)
        SELECT id INTO vnId_role
        FROM `Role`
        WHERE name = fn_get_text('DEFAULT_ROLE_NAME');

        SELECT id INTO vnId_status
        FROM UserStatus
        WHERE name = fn_get_text('DEFAULT_USER_STATUS');

        IF vnId_role IS NULL OR vnId_status IS NULL THEN
            SET pnResult = 1020; -- c_parametro_faltante
        ELSE
            START TRANSACTION;
            -- Registra la persona (incluyendo locación, teléfono y correo)
            CALL pr_register_person(
                TRIM(pcFirst_name), TRIM(pcMiddle_name), TRIM(pcFirst_lastName), TRIM(pcSecond_lastName),
                pnId_district, pcAddress, pcPhone, pcEmail,
                vnId_person, vnResult
            );

            -- Verifica si la inserción de la persona fue correcta
            IF vnResult <> 0 THEN
                SET pnResult = vnResult;
                ROLLBACK;
            ELSE
                -- Inserta las credenciales del usuario con el Hash enviado en mayúsculas
                INSERT INTO `User` (idPerson, idRole, idUserStatus, username, password)
                VALUES (vnId_person, vnId_role, vnId_status, TRIM(pcUsername),
                        UPPER(TRIM(pcPassword_hash)));
                COMMIT;
            END IF;
        END IF;
    END IF;
END //

-- Procedimiento para inicio de sesión
CREATE PROCEDURE pr_login_user (
    IN pcUsername VARCHAR(255),
    IN pcPassword_hash VARCHAR(255) -- Recibe el Hash generado por el Backend
)
BEGIN

    SELECT u.id,
        u.idPerson,
        u.username,
        NULLIF(TRIM(CONCAT_WS(' ', p.firstName, p.firstLastName, p.secondLastName)), '') AS fullName,
        r.name AS roleName,
        s.name AS statusName

    FROM `User` u
    INNER JOIN Person p
    ON p.id = u.idPerson

    INNER JOIN `Role` r
        ON r.id = u.idRole

    INNER JOIN UserStatus s
      ON s.id = u.idUserStatus

    WHERE LOWER(u.username) = LOWER(TRIM(pcUsername))
        AND u.password = UPPER(TRIM(pcPassword_hash));
END //

DELIMITER ;
-- ---------------------------------------------------------------------------------
-- ----------------- Administración de usuarios ------------------------------------
-- ---------------------------------------------------------------------------------
DELIMITER //
-- Consulta de usuarios para el administrador (filtros por rol y estado opcionales; nulos = todos)
CREATE PROCEDURE pr_get_users (
    IN pnId_role INT,
    IN pnId_status INT
)
BEGIN
    SELECT u.id,
           u.idPerson,
           u.username,
           NULLIF(TRIM(CONCAT_WS(' ', p.firstName, p.firstLastName, p.secondLastName)), '') AS fullName,
           r.id   AS roleId,
           r.name AS roleName,
           s.id   AS statusId,
           s.name AS statusName
    FROM `User` u
             INNER JOIN Person p ON p.id = u.idPerson
             INNER JOIN `Role` r ON r.id = u.idRole
             INNER JOIN UserStatus s ON s.id = u.idUserStatus
    WHERE r.id = IFNULL(pnId_role, r.id)
      AND s.id = IFNULL(pnId_status, s.id)
    ORDER BY u.username;
END //


-- Cambia el estado de un usuario (activar, bloquear, etc.)
CREATE PROCEDURE pr_update_user_status (
    IN pnId_user INT,
    IN pnId_status INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnTest INT;

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END; -- FK inexistente
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END; -- Nulo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END;

    SET pnResult = 0;

    -- Validamos si el usuario existe
    SELECT 1 INTO vnTest FROM `User` WHERE id = pnId_user;

    IF vnTest IS NULL THEN
        SET pnResult = 1100;
    ELSE
        START TRANSACTION;
        UPDATE `User`
        SET idUserStatus = pnId_status
        WHERE id = pnId_user;
        COMMIT;
    END IF;
END //

-- Cambia el rol de un usuario
CREATE PROCEDURE pr_update_user_role (
    IN pnId_user INT,
    IN pnId_role INT,
    OUT pnResult INT
)
BEGIN
    DECLARE vnTest INT;

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR 1452 BEGIN SET pnResult = 1100; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR 1048 BEGIN SET pnResult = 1030; ROLLBACK; END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END;

    SET pnResult = 0;

    -- Validamos si el usuario existe
    SELECT 1 INTO vnTest FROM `User` WHERE id = pnId_user;

    IF vnTest IS NULL THEN
        SET pnResult = 1100;
    ELSE
        START TRANSACTION;
        UPDATE `User`
        SET idRole = pnId_role
        WHERE id = pnId_user;
        COMMIT;
    END IF;
END //

DELIMITER ;
