-- CORRER SCRIPT DESDE ADOPCION_APP
USE ADOPCION_APP;

-- ===============================================================
-- ==== Insercion parametro frecuencia en tabla parametrizada ====
-- ===============================================================

-- En MySQL, si la columna 'id' es AUTO_INCREMENT, simplemente la omitimos
-- o pasamos NULL en su lugar (aquí la omitimos de la lista de columnas).
INSERT INTO Parameter (name, description, numberValue)
VALUES ('MATCH_JOB_INTERVAL_HOURS',
        'Intervalo horas job matching mascotas perdidas y encontradas',
        4);

COMMIT;

-- Antes de si quiera hacer el job, el job se ha planteado para que pueda mandar correos, por tanto, para que esto sea posible
-- se debe configurar el servicio de correos desde SYSDBA (Archivo Jobs-Config-Correos.sql)

-- ============================================
-- ==== Creacion Job de match automatizado ====
-- ============================================


DELIMITER //

CREATE PROCEDURE pr_setup_match_job()
BEGIN
    DECLARE v_hours INT DEFAULT 4;

    -- Manejador de errores como red de seguridad
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_hours = 4;

    -- Obtener el parámetro de horas insertado previamente
    SELECT numberValue INTO v_hours
    FROM Parameter
    WHERE name = 'MATCH_JOB_INTERVAL_HOURS' LIMIT 1;

    IF v_hours IS NULL THEN
        SET v_hours = 4;
    END IF;

    -- Eliminar el Evento (Job) anterior si ya existía
    DROP EVENT IF EXISTS JOB_MATCH_PETS;

    -- Construir el script dinámico para el Evento usando el parámetro leído
    SET @sql_query = CONCAT(
            'CREATE EVENT JOB_MATCH_PETS ',
            'ON SCHEDULE EVERY ', v_hours, ' HOUR ',
            'COMMENT "Job automatizado de matching usando pr_job_match_exec" ',
            'DO CALL pr_job_match_exec();'
                     );

    -- Ejecutar la creación del Evento
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

-- Ejecutar el orquestador temporal para inicializar el Evento
CALL pr_setup_match_job();

-- Limpiar la base de datos eliminando el procedimiento temporal
DROP PROCEDURE pr_setup_match_job;