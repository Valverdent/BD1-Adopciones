--------------------------------------------------------------
-- Creacion tuplas relacionadas a ubicaciones en Costa Rica --
--------------------------------------------------------------

-- Creacion tupla de pais
--INSERT INTO COUNTRY (id, name)
--VALUES (s_country.NEXTVAL, 'Costa Rica');

-- Insercion tuplas de provincias
INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'San José');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Alajuela');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Cartago');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Heredia');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Guanacaste');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Puntarenas');

INSERT INTO PROVINCE (id, idCountry, name)
VALUES (s_province.NEXTVAL, 1, 'Limón');




