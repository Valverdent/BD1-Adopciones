-- ============================================
-- == Creacion tablas esquema ADOPCION_AUDIT ==
-- ============================================


-- CORRER EN ESQUEMA ADOPCION_AUDIT


-- Dado que hay datos provenientes desde ADOPCION_APP como el id_User en la tabla de ChangeLog, se deben correr los siguientes comandos en SYSTEM
-- GRANT SELECT ON ADOPCION_APP."USER" TO ADOPCION_AUDIT;
-- GRANT REFERENCES ON ADOPCION_APP."User" TO ADOPCION_AUDIT;


CREATE TABLE ChangeLog (
    id                  NUMBER(7),
    idUser              NUMBER(7) CONSTRAINT changeLog_idUser_NN NOT NULL,
    changeDescription   VARCHAR2(255),
    fieldName           VARCHAR2(50) CONSTRAINT changeLog_fieldName_NN NOT NULL,
    oldValue            VARCHAR2(255),
    newValue            VARCHAR2(255),
    changeDate          DATE DEFAULT SYSDATE CONSTRAINT changeLog_changeDate_NN NOT NULL,
    recordId            VARCHAR2(100) CONSTRAINT changeLog_recordId_NN NOT NULL,
    
    CONSTRAINT changelog_pk PRIMARY KEY (id) 
        USING INDEX TABLESPACE ADOPCION_AUDIT_IDX,
    CONSTRAINT changelog_user_fk FOREIGN KEY (idUser) 
        REFERENCES ADOPCION_APP."User" (id)
) TABLESPACE ADOPCION_AUDIT_DATA;

-- Para que los TRIGGER puedan escribir en esta tabla, se debe correr el siguiente comando en SYSTEM
-- GRANT INSERT ON ADOPCION_AUDIT.CHANGELOG TO ADOPCION_APP;