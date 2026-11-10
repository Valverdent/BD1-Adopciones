-- ============================================
-- == Creacion tablas esquema ADOPCION_AUDIT ==
-- ============================================


-- Correr desde ROOT o ADOPCION_AUDIT

-- Selecciono esquema de destino
USE ADOPCION_AUDIT;


-- Dado que hay datos provenientes desde ADOPCION_APP como el id_User en la tabla de ChangeLog, se deben correr los siguientes comandos en ROOT
-- GRANT SELECT, REFERENCES ON ADOPCION_APP.`User` TO 'ADOPCION_AUDIT'@'%';
-- FLUSH PRIVILEGES;

CREATE TABLE ChangeLog (
    id                  INT(7) AUTO_INCREMENT PRIMARY KEY,
    idUser              INT(7) NOT NULL,
    changeDescription   VARCHAR(255),
    fieldName           VARCHAR(50) NOT NULL,
    oldValue            VARCHAR(255),
    newValue            VARCHAR(255),
    changeDate          DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    recordId            VARCHAR(100) NOT NULL,
    
    CONSTRAINT changelog_user_fk FOREIGN KEY (idUser) REFERENCES ADOPCION_APP.`User` (id)
);

-- Para que los TRIGGER puedan escribir en esta tabla, se debe correr el siguiente comando en ROOT
-- GRANT INSERT ON ADOPCION_AUDIT.ChangeLog TO 'ADOPCION_APP'@'%';
-- FLUSH PRIVILEGES;