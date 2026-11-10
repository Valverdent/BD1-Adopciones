-- CORRIDO DESDE ADOPCION_AUDIT
USE ADOPCION_AUDIT;

-- ALTER TABLE ChangeLog MODIFY idUser INT(7) NULL;
-- ALTER TABLE ChangeLog MODIFY fieldName VARCHAR(50) NULL;
-- ALTER TABLE ChangeLog MODIFY changeDescription VARCHAR(255) NOT NULL;

-- ALTER TABLE ChangeLog ADD (creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL);
-- ALTER TABLE ChangeLog ADD (createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL);
-- ALTER TABLE ChangeLog ADD (updatedDate DATETIME);
-- ALTER TABLE ChangeLog ADD (updatedBy VARCHAR(30));

-- ALTER TABLE ChangeLog ADD (schemeName VARCHAR(30));
-- ALTER TABLE ChangeLog ADD (tableName VARCHAR(30));

DELIMITER //CreateLog
-- CREATE PROCEDURE CreateLog (IN pcScheme VARCHAR(255), IN pcTableName VARCHAR(255), IN pcFieldName VARCHAR(255), IN pcOldValue VARCHAR(255), IN pcNewValue VARCHAR(255), IN pcRecordId VARCHAR(255), IN pcChangeDescription VARCHAR(255), IN pcCreatedBy VARCHAR(255))
--    BEGIN
--        INSERT INTO ChangeLog (schemeName, tableName, fieldName, changeDate, oldValue, newValue, recordId, changeDescription, createdBy)
--        VALUES (pcScheme, pcTableName, pcFieldName, CURRENT_TIMESTAMP, pcOldValue, pcNewValue, pcRecordId, pcChangeDescription, pcCreatedBy);
--    END;//
DELIMITER ;

DELIMITER /
-- CREATE TRIGGER beforeInsertChangeLog 
-- BEFORE INSERT ON ChangeLog
-- FOR EACH ROW
-- BEGIN 
--    SET NEW.changeDate = CURRENT_TIMESTAMP, NEW.createdBy = IFNULL(NEW.createdBy, CURRENT_USER());
-- END;//
DELIMITER ;

DELIMITER /
CREATE TRIGGER beforeUpdateChangeLog 
BEFORE UPDATE ON ChangeLog
FOR EACH ROW
BEGIN 
    SET NEW.changeDate = CURRENT_TIMESTAMP, NEW.updatedBy = IFNULL(NEW.updatedBy, CURRENT_USER());
END;//
DELIMITER ;

GRANT EXECUTE ON PROCEDURE CreateLog TO 'ADOPCION_APP'@'%';

COMMIT;