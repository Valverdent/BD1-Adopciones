-- CORRIDO DESDE ADOPCION_AUDIT
-- ALTER TABLE ChangeLog DROP CONSTRAINT CHANGELOG_FIELDNAME_NN;

CREATE OR REPLACE PROCEDURE createLog (pcScheme IN VARCHAR2, pcTableName IN VARCHAR2, pcFieldName IN VARCHAR2, pcOldValue IN VARCHAR2, pcNewValue IN VARCHAR2, pcRecordId IN VARCHAR2, pcChangeDescription IN VARCHAR2, pcCreatedBy IN VARCHAR2) IS
    BEGIN
        INSERT INTO ChangeLog (id, schemeName, tableName, fieldName, changeDate, oldValue, newValue, recordId, changeDescription, createdBy)
        VALUES (s_changeLog.nextval, pcScheme, pcTableName, pcFieldName, SYSDATE, pcOldValue, pcNewValue, pcRecordId, pcChangeDescription, pcCreatedBy);
END createLog;
/

-- DROP TRIGGER beforeInsertChangeLog;
-- DROP TRIGGER beforeUpdateChangeLog; --Elimina los trigger creados en el LAB para tener una mejor consistencia de datos 

CREATE OR REPLACE TRIGGER beforeSaveChangeLog 
BEFORE INSERT OR UPDATE ON ChangeLog
FOR EACH ROW
BEGIN 
    IF INSERTING THEN
        :new.creationDate:=SYSDATE;
        :new.createdBy:=NVL(:new.createdBy, USER);  -- En caso de que el procedimiento de crearBitácora no haya enviado el usuario que crea la tupla
    END IF;

    IF UPDATING THEN
        :new.updatedDate:=SYSDATE;
        :new.updatedBy:=NVL(:new.updatedBy, USER); -- En caso de que el procedimiento de crearBitácora no haya enviado el usuario que actualiza la tupla
    END IF;
END beforeSaveChangeLog;
/
GRANT EXECUTE ON createLog to ADOPCION_APP;


COMMIT;