-- CORRER SCRIPT DESDE ADOPCION_APP


--===============================================================
--==== Insercion parametro frecuencia en tabla parametrizada ====
--===============================================================
-- INSERT INTO Parameter (id, name, description)

-- INSERT INTO Parameter (id, name, description, numberValue) 
-- VALUES (s_parameter.NEXTVAL,'MATCH_JOB_INTERVAL_HOURS', 
--    'Intervalo horas job matching mascotas perdidas y encontradas', 4);

-- COMMIT;

-- Antes de si quiera hacer el job, el job se ha planteado para que pueda mandar correos, por tanto, para que esto sea posible
-- se debe configurar el servicio de correos desde SYSDBA (Archivo Jobs-Config-Correos.sql)

--============================================
--==== Creacion Job de match automatizado ====
--============================================
DECLARE
    v_hours VARCHAR2(10);
BEGIN
    SELECT TO_CHAR(numberValue)
    INTO v_hours
    FROM Parameter
    WHERE name = 'MATCH_JOB_INTERVAL_HOURS';

    v_hours := NVL(v_hours, '4');

    -- En caso de existir, borra el job anterior
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_MATCH_PETS', force => TRUE);
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_MATCH_PETS',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'pkg_pet_administration.pr_job_match_exec',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=HOURLY; INTERVAL=' || v_hours,
        enabled         => TRUE,
        comments        => 'Job automatizado de matching usando paquete PKG_PET_ADMINISTRATION'
    );
END;