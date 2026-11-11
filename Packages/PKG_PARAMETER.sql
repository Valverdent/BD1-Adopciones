
-------------------------------------------------------------------------
------------------------- Getters de valores ----------------------------
-------------------------------------------------------------------------
DELIMITER //
-- Función que retorna el valor del atributo textValue VARCHAR2 por medio del nombre del parametro
CREATE FUNCTION fn_get_text (pcName VARCHAR(255))
RETURNS VARCHAR(255) READS SQL DATA
BEGIN
   vcValue vcValue VARCHAR(255);
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET vcValue = NULL; -- Manejo de excepciones para cuando no se encuentra el parámetro

   -- Busca el valor VARCHAR2 por medio de un filtro del nombre del parametro 
   SELECT textValue INTO vcValue
   FROM parameter
   WHERE name = pcName;
   
   RETURN vcValue;
END //


-- Función que retorna el valor del atributo numberValue NUMBER por medio del nombre del parametro
CREATE FUNCTION fn_get_number (pcName VARCHAR(255))
RETURNS DECIMAL(9,2) READS SQL DATA
BEGIN
   DECLARE vnValue DECIMAL(9,2);
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET vnValue = NULL; -- Manejo de excepciones para cuando no se encuentra el parámetro
   
   -- Busca el valor NUMBER por medio de un filtro del nombre del parametro
   SELECT numberValue INTO vnValue
   FROM parameter
   WHERE name = pcName;
   
   RETURN vnValue;
END //
DELIMITER ;

DELIMITER //
-- Procedimiento que retorna un cursor con los parámetros filtrados por nombre para la pantalla de administración
CREATE PROCEDURE pr_get_parameters (
   IN pcname VARCHAR(255))
AS
BEGIN
    SELECT id,
        name,
        description,
        textValue,
        numberValue
    FROM Parameter
    WHERE LOWER(name) = IFNULL(LOWER(TRIM(pcName)), LOWER(name))            -- Si pcName es nulo, devuelve todos los parámetros
    ORDER BY name;
END //

DELIMITER ;

-------------------------------------------------------------------------
-----------------Inserción, modificación, eliminación -------------------
-------------------------------------------------------------------------

-- Procedimiento para registrar un nuevo parámetro en la base de datos
PROCEDURE pr_insert_parameter (
   IN pcName VARCHAR(255),
   IN pcDescription VARCHAR(255),
   IN pcText_value VARCHAR(255),
   IN pnNumber_value DECIMAL(9,2),
   OUT pnResult INT
)
BEGIN
   -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR 1062 BEGIN SET pnResult = 1004; ROLLBACK; END; -- Dato duplicado
    DECLARE EXIT HANDLER FOR 1048, 1406, 3819 BEGIN SET pnResult = 1030; ROLLBACK; END; -- Nulo, largo o check violado (en MySQL el check violation es 3819)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END; -- Error general

    SET pnResult = 0;

    START TRANSACTION;

    -- Inserta el nuevo parámetro en la BD
    INSERT INTO parameter (name, description, textValue, numberValue)
    VALUES (TRIM(pcName), TRIM(pcDescription), TRIM(pcText_value), pnNumber_value);
    COMMIT;
END //

-- Procedimiento para actualizar los valores (texto o numérico) de un parámetro existente
CREATE PROCEDURE pr_update_parameter (
    IN pnId_parameter INT,
    IN pcText_value VARCHAR(255),
    IN pnNumber_value DECIMAL(9,2),
    OUT pnResult INT
)
BEGIN
    DECLARE vnTest INT;

    -- Manejo de excepciones
    DECLARE EXIT HANDLER FOR 1048, 1406, 3819 BEGIN SET pnResult = 1030; ROLLBACK; END; -- Nulo, largo o check violado (en MySQL el check violation es 3819)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN SET pnResult = 9000; ROLLBACK; END; -- Error general

    SET pnResult = 0;

    -- Valida que existe el parametro en el sistema
    SELECT 1
    INTO vnTest
    FROM parameter
    WHERE id = pnId_parameter;

    IF vnTest IS NULL THEN
       SET pnResult = 1100; --Referencia no existente
    ELSE
        START TRANSACTION
        -- Modifica únicamente el tipo de dato activo que ya tenía el parámetro (texto o número)
        UPDATE parameter
        SET textValue = CASE
                            WHEN textValue IS NOT NULL OR numberValue IS NULL THEN TRIM(pcText_value)
                            ELSE NULL
                        END,
            numberValue = CASE
                            WHEN numberValue IS NOT NULL THEN pnNumber_value
                            ELSE NULL
                        END
        WHERE id = pnId_parameter;
        COMMIT;
    END IF;
END //


-- Procedimiento para eliminar un parámetro del sistema por su ID
PROCEDURE pr_delete_parameter (
   pnId_parameter  IN  NUMBER,
   pnResult        OUT NUMBER)
AS
   vnTest NUMBER;
BEGIN
   pnResult := c_exito;

   -- Valida que existe el parametro en el sistema
   SELECT 1
   INTO vnTest
   FROM parameter
   WHERE id = pnId_parameter;

   -- Elimina el parámetro correspondiente al ID enviado
   DELETE FROM parameter
   WHERE id = pnId_parameter;

   COMMIT;

EXCEPTION                                           -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                                          
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN OTHERS THEN                                                 
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_parameter;

END pkg_parameter;
