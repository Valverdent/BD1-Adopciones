-- ------------------------------------------------------------
-- Creacion tuplas relacionadas a ubicaciones en Costa Rica --
-- ------------------------------------------------------------
USE ADOPCION_APP;
-- Creacion tupla de pais
INSERT INTO Country (name)
VALUES ('Costa Rica');

-- Insercion tuplas de provincias
INSERT INTO Province (idCountry, name)
VALUES (1, 'San José');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Alajuela');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Cartago');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Heredia');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Guanacaste');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Puntarenas');

INSERT INTO Province (idCountry, name)
VALUES (1, 'Limón');




