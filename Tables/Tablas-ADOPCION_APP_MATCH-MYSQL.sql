-- =====================================
-- == Creacion tabla dedicada a match ==
-- =====================================
-- Correr desde ROOT o ADOPCION_APP

-- Selecciono esquema de destino
USE ADOPCION_APP;


CREATE TABLE IF NOT EXISTS PetMatch (
    id                INT(7) AUTO_INCREMENT PRIMARY KEY,
    idLostPet         INT(7) NOT NULL,
    idFoundPet        INT(7) NOT NULL,
    matchDate         DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    matchScore        INT(3) NOT NULL, -- Puntaje correspondiente a a la coincidencia
    notified          TINYINT(1) DEFAULT 0 CHECK (notified IN (0, 1)),
    
    CONSTRAINT petmatch_lost_fk FOREIGN KEY (idLostPet) REFERENCES Pet(id),
    CONSTRAINT petmatch_found_fk FOREIGN KEY (idFoundPet) REFERENCES Pet(id)
);

COMMIT;