USE ADOPCION_AUDIT;

ALTER TABLE ChangeLog
    MODIFY id INT AUTO_INCREMENT COMMENT 'Identificador único del registro de auditoría',
    MODIFY idUser INT COMMENT 'FK o ID del usuario que realizó el cambio (si aplica)',
    MODIFY changeDescription VARCHAR(255) COMMENT 'Descripción general del cambio realizado (Ej: Changed pet name, Tuple deletion)',
    MODIFY fieldName VARCHAR(50) COMMENT 'Nombre de la columna o campo que fue modificado',
    MODIFY oldValue VARCHAR(255) COMMENT 'Valor que tenía el campo antes del cambio',
    MODIFY newValue VARCHAR(255) COMMENT 'Valor nuevo que se asignó al campo',
    MODIFY changeDate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora exacta en la que ocurrió el cambio',
    MODIFY recordId VARCHAR(100) COMMENT 'ID del registro afectado en la tabla original (guardado como texto por si es una PK compuesta)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro de auditoría (normalmente igual a changeDate)',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' COMMENT 'Usuario de base de datos que generó el log',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización del registro de auditoría (rara vez se usa en logs)',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que actualizó el registro de auditoría (rara vez se usa)',
    MODIFY schemeName VARCHAR(30) COMMENT 'Nombre del esquema/base de datos donde ocurrió el cambio (Ej: ADOPCION_APP)',
    MODIFY tableName VARCHAR(30) COMMENT 'Nombre de la tabla que sufrió la modificación (Ej: Pet, User, Canton)';