-- =====================================
-- == Creacion tabla dedicada a match ==
-- =====================================

CREATE TABLE PetMatch (
    id                NUMBER(7) CONSTRAINT petmatch_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idLostPet         NUMBER(7) NOT NULL,
    idFoundPet        NUMBER(7) NOT NULL,
    matchDate         DATE DEFAULT SYSDATE NOT NULL,
    matchScore        NUMBER(3) NOT NULL, -- Puntaje correspondiente a a la coincidencia
    notified          NUMBER(1) DEFAULT 0 CHECK (notified IN (0, 1)),
    
    CONSTRAINT petmatch_lost_fk FOREIGN KEY (idLostPet) REFERENCES Pet(id),
    CONSTRAINT petmatch_found_fk FOREIGN KEY (idFoundPet) REFERENCES Pet(id)
) TABLESPACE ADOPCION_DATA;

COMMIT;