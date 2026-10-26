-- ============================================================
-- actualizar_pkg_catalog.sql
-- Actualiza PKG_CATALOG (codigo tomado de la base el 22/10/2026).
-- Cambios:
--   Corrige pr_insert_catalog('PROVINCE'): ahora guarda el pais (pnId_parent).
--   PROVINCE pasa a tener padre (pais) en pr_get_catalog y pr_update_catalog.
--   Agrega COUNTRY, TREATMENT y MEDICATION a los catalogos administrables.
--   Agrega pr_get_countries, pr_get_provinces_by_country, pr_get_treatments y pr_get_medications.
--   Agrega pr_add_treatment_to_disease y pr_add_medication_to_treatment.
-- No cambia la firma de ningun procedimiento existente.
--
-- ESCRIBE EN LA BASE. Ejecutar con F5 (Run Script), conectado como ADOPCION_APP.
-- 1) Primero revisa que nadie haya modificado el paquete desde la revision;
--    si cambio, se detiene SIN tocar nada.
-- 2) Reemplaza la especificacion y el cuerpo.
-- 3) Recompila lo que haya quedado invalido y muestra el estado (todo debe decir VALID).
-- Para deshacer: ejecutar la seccion de este paquete en respaldo_paquetes_originales.sql.
-- ============================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
   vnLineas NUMBER;
   vnChars  NUMBER;
BEGIN
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_CATALOG' AND type = 'PACKAGE';
   IF vnLineas <> 73 OR vnChars <> 3030 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE PKG_CATALOG cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 73). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   SELECT COUNT(*), NVL(SUM(LENGTH(RTRIM(text, CHR(10) || CHR(13) || ' '))), 0)
   INTO vnLineas, vnChars
   FROM user_source
   WHERE name = 'PKG_CATALOG' AND type = 'PACKAGE BODY';
   IF vnLineas <> 827 OR vnChars <> 25377 THEN
      RAISE_APPLICATION_ERROR(-20010, 'PACKAGE BODY PKG_CATALOG cambio despues de la revision del 22/10 '
         || '(lineas ' || vnLineas || ', esperado 827). No se ejecuta para no borrar ese cambio: '
         || 'vuelva a exportar con extraer_especificaciones.sql y extraer_cuerpos.sql y pida el script de nuevo.');
   END IF;
   DBMS_OUTPUT.PUT_LINE('OK  PKG_CATALOG sin cambios desde la revision.');
END;
/

WHENEVER SQLERROR CONTINUE

CREATE OR REPLACE PACKAGE pkg_catalog AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_catalogo_en_uso      CONSTANT NUMBER := 1102;   -- el valor está siendo usado por otros registros
c_catalogo_protegido   CONSTANT NUMBER := 1103;   -- el valor está referenciado por un parámetro del sistema
c_error_bd             CONSTANT NUMBER := 9000;

-- Getters para las listas desplegables de la interfaz

PROCEDURE pr_get_provinces          (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_cantons            (pnId_province IN NUMBER, p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_districts          (pnId_canton   IN NUMBER, p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_countries           (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_provinces_by_country (pnId_country IN NUMBER, p_cursor OUT SYS_REFCURSOR);


PROCEDURE pr_get_roles              (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_user_statuses      (p_cursor OUT SYS_REFCURSOR);


PROCEDURE pr_get_donation_types     (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_currency_types     (p_cursor OUT SYS_REFCURSOR);


PROCEDURE pr_get_pet_types          (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_breeds         (pnId_pet_type IN NUMBER, p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_sizes          (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_colors         (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_severities     (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_energies       (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_trainabilities (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_pet_statuses       (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_photo_types        (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_diseases           (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_treatments         (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_medications        (p_cursor OUT SYS_REFCURSOR);


PROCEDURE pr_get_house_types          (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_exercise_times       (p_cursor OUT SYS_REFCURSOR);
PROCEDURE pr_get_foster_home_statuses (p_cursor OUT SYS_REFCURSOR);

-- Administración de catálogos (pantalla del administrador)
-- pcCatalog: PROVINCE, CANTON, DISTRICT, ROLE, USER_STATUS, DONATION_TYPE, CURRENCY_TYPE, PET_TYPE, PET_BREED, PET_SIZE,
--            PET_COLOR, PET_SEVERITY, PET_ENERGY, PET_TRAINABILITY, PET_STATUS, PHOTO_TYPE, DISEASE, HOUSE_TYPE,
--            EXERCISE_TIME, FOSTER_HOME_STATUS, COUNTRY, TREATMENT, MEDICATION
-- pnId_parent: solo para PROVINCE (país), CANTON (provincia), DISTRICT (cantón) y PET_BREED (tipo de mascota);
--              en los demás se envía NULL
PROCEDURE pr_get_catalog (
   pcCatalog    IN  VARCHAR2,
   pnId_parent  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR,
   pnResult     OUT NUMBER);

PROCEDURE pr_insert_catalog (
   pcCatalog       IN  VARCHAR2,
   pcName          IN  VARCHAR2,
   pnId_parent     IN  NUMBER,
   pnId_catalog    OUT NUMBER,
   pnResult        OUT NUMBER);

PROCEDURE pr_update_catalog (
   pcCatalog       IN  VARCHAR2,
   pnId_catalog    IN  NUMBER,
   pcName          IN  VARCHAR2,
   pnId_parent     IN  NUMBER,
   pnResult        OUT NUMBER);

PROCEDURE pr_delete_catalog (
   pcCatalog       IN  VARCHAR2,
   pnId_catalog    IN  NUMBER,
   pnResult        OUT NUMBER);

-- Asociaciones de enfermedades, tratamientos y medicamentos
-- Asocia un tratamiento a una enfermedad, con su duración (ej. "4 semanas")
PROCEDURE pr_add_treatment_to_disease (
   pnId_disease    IN  NUMBER,
   pnId_treatment  IN  NUMBER,
   pcTime_length   IN  VARCHAR2,
   pnResult        OUT NUMBER);

-- Agrega un medicamento a un tratamiento, con su dosis (ej. "1 tableta cada 12 horas")
PROCEDURE pr_add_medication_to_treatment (
   pnId_treatment   IN  NUMBER,
   pnId_medication  IN  NUMBER,
   pcDosage         IN  VARCHAR2,
   pnResult         OUT NUMBER);

END pkg_catalog;
/

CREATE OR REPLACE PACKAGE BODY pkg_catalog AS

-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo     EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,     -1400);    -- NULL en columna NOT NULL (INSERT)
eDatoNuloUpd  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNuloUpd,  -1407);    -- NULL en columna NOT NULL (UPDATE)
eDatoLargo    EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,    -12899);   -- texto mas largo que la columna
eNumeroGrande EXCEPTION;
PRAGMA EXCEPTION_INIT(eNumeroGrande, -1438);    -- numero con mas digitos de los permitidos
eCheckViolado EXCEPTION;
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);    -- CHECK violado
eFkNoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste,   -2291);    -- FK: el registro padre no existe
eHijoExiste   EXCEPTION;
PRAGMA EXCEPTION_INIT(eHijoExiste,   -2292);    -- FK: existen registros hijos que usan el valor

-------------------------------------------------------------------------
------------- Funciones privadas (solo las usa este paquete) ------------
-------------------------------------------------------------------------

-- Función que indica si el nombre de catálogo recibido es uno de los permitidos (1 = sí, 0 = no)
FUNCTION fn_is_catalog (pcCatalog IN VARCHAR2)
RETURN NUMBER
IS
BEGIN
   IF UPPER(TRIM(pcCatalog)) IN ('PROVINCE', 'CANTON', 'DISTRICT', 'ROLE', 'USER_STATUS', 'DONATION_TYPE', 'CURRENCY_TYPE',
                                 'PET_TYPE', 'PET_BREED', 'PET_SIZE', 'PET_COLOR', 'PET_SEVERITY', 'PET_ENERGY',
                                 'PET_TRAINABILITY', 'PET_STATUS', 'PHOTO_TYPE', 'DISEASE', 'HOUSE_TYPE',
                                 'EXERCISE_TIME', 'FOSTER_HOME_STATUS', 'COUNTRY', 'TREATMENT', 'MEDICATION') THEN
      RETURN 1;
   END IF;
   RETURN 0;
END fn_is_catalog;


-- Función que retorna el nombre actual de un valor del catálogo (si no existe, se produce NO_DATA_FOUND)
FUNCTION fn_get_name (pcCatalog IN VARCHAR2, pnId IN NUMBER)
RETURN VARCHAR2
IS
   vcName VARCHAR2(200);
BEGIN
   CASE UPPER(TRIM(pcCatalog))
      WHEN 'PROVINCE' THEN
         SELECT name  INTO vcName
         FROM province
         WHERE id = pnId;
      WHEN 'CANTON' THEN
         SELECT name  INTO vcName
         FROM canton
         WHERE id = pnId;
      WHEN 'DISTRICT' THEN
         SELECT name  INTO vcName
         FROM district
         WHERE id = pnId;
      WHEN 'ROLE' THEN
         SELECT name  INTO vcName
         FROM "Role"
         WHERE id = pnId;
      WHEN 'USER_STATUS' THEN
         SELECT name  INTO vcName
         FROM userStatus
         WHERE id = pnId;
      WHEN 'DONATION_TYPE' THEN
         SELECT name  INTO vcName
         FROM donationType
         WHERE id = pnId;
      WHEN 'CURRENCY_TYPE' THEN
         SELECT name  INTO vcName
         FROM currencyType
         WHERE id = pnId;
      WHEN 'PET_TYPE' THEN
         SELECT name  INTO vcName
         FROM petType
         WHERE id = pnId;
      WHEN 'PET_BREED' THEN
         SELECT name  INTO vcName
         FROM petBreed
         WHERE id = pnId;
      WHEN 'PET_SIZE' THEN
         SELECT name  INTO vcName
         FROM petSize
         WHERE id = pnId;
      WHEN 'PET_COLOR' THEN
         SELECT name  INTO vcName
         FROM petColor
         WHERE id = pnId;
      WHEN 'PET_SEVERITY' THEN
         SELECT name  INTO vcName
         FROM petSeverity
         WHERE id = pnId;
      WHEN 'PET_ENERGY' THEN
         SELECT name  INTO vcName
         FROM petEnergy
         WHERE id = pnId;
      WHEN 'PET_TRAINABILITY' THEN
         SELECT name  INTO vcName
         FROM petTrainability
         WHERE id = pnId;
      WHEN 'PET_STATUS' THEN
         SELECT name  INTO vcName
         FROM petStatus
         WHERE id = pnId;
      WHEN 'PHOTO_TYPE' THEN
         SELECT name  INTO vcName
         FROM photoType
         WHERE id = pnId;
      WHEN 'DISEASE' THEN
         SELECT name  INTO vcName
         FROM disease
         WHERE id = pnId;
      WHEN 'HOUSE_TYPE' THEN
         SELECT name  INTO vcName
         FROM houseType
         WHERE id = pnId;
      WHEN 'EXERCISE_TIME' THEN
         SELECT value INTO vcName
         FROM exerciseTime
         WHERE id = pnId;   -- Esta tabla usa la columna value
      WHEN 'FOSTER_HOME_STATUS' THEN
         SELECT name  INTO vcName
         FROM fosterHomeStatus
         WHERE id = pnId;
      WHEN 'COUNTRY' THEN
         SELECT name  INTO vcName
         FROM country
         WHERE id = pnId;
      WHEN 'TREATMENT' THEN
         SELECT name  INTO vcName
         FROM treatment
         WHERE id = pnId;
      WHEN 'MEDICATION' THEN
         SELECT name  INTO vcName
         FROM medication
         WHERE id = pnId;
   END CASE;

   RETURN vcName;
END fn_get_name;


-- Función que indica si un valor es usado por algún parámetro del sistema (ej. PET_STATUS_ADOPTED = 'Adoptado').
-- Si se renombra o elimina ese valor, la lógica que lee el parámetro dejaría de encontrarlo.
FUNCTION fn_used_by_parameter (pcValue IN VARCHAR2)
RETURN NUMBER
IS
   vnCount NUMBER;
BEGIN
   SELECT COUNT(1) INTO vnCount
   FROM parameter
   WHERE textValue = TRIM(pcValue);
   RETURN CASE
             WHEN vnCount > 0 THEN 1
             ELSE 0
          END;
END fn_used_by_parameter;

-----------------------------------------------------------------------------------
---------------------------------- Ubicación --------------------------------------
-----------------------------------------------------------------------------------

-- Todas las provincias
PROCEDURE pr_get_provinces (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM province
      ORDER BY name;
END pr_get_provinces;

-- Cantones de una provincia (nulo = todos)
PROCEDURE pr_get_cantons (pnId_province IN NUMBER, p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name, idProvince
      FROM canton
      WHERE idProvince = NVL(pnId_province, idProvince)
      ORDER BY name;
END pr_get_cantons;

-- Distritos de un cantón (nulo = todos)
PROCEDURE pr_get_districts (pnId_canton IN NUMBER, p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name, idCanton
      FROM district
      WHERE idCanton = NVL(pnId_canton, idCanton)
      ORDER BY name;
END pr_get_districts;

-- Todos los países
PROCEDURE pr_get_countries (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM country
      ORDER BY name;
END pr_get_countries;

-- Provincias de un país (nulo = todas)
PROCEDURE pr_get_provinces_by_country (pnId_country IN NUMBER, p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name, idCountry
      FROM province
      WHERE idCountry = NVL(pnId_country, idCountry)
      ORDER BY name;
END pr_get_provinces_by_country;

-----------------------------------------------------------------------------------
----------------------------------- Usuarios --------------------------------------
-----------------------------------------------------------------------------------

-- Catálogo de roles
PROCEDURE pr_get_roles (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM "Role"
      ORDER BY name;
END pr_get_roles;

-- Catálogo de estados de usuario
PROCEDURE pr_get_user_statuses (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM userStatus
      ORDER BY name;
END pr_get_user_statuses;

-----------------------------------------------------------------------------------
---------------------------------- Donaciones -------------------------------------
-----------------------------------------------------------------------------------

-- Tipos de donación (voluntaria, por porcentaje, etc.)
PROCEDURE pr_get_donation_types (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM donationType
      ORDER BY name;
END pr_get_donation_types;

-- Monedas (colones, dólares)
PROCEDURE pr_get_currency_types (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM currencyType
      ORDER BY name;
END pr_get_currency_types;

-----------------------------------------------------------------------------------
----------------------------------- Mascotas --------------------------------------
-----------------------------------------------------------------------------------

-- Tipos de mascota
PROCEDURE pr_get_pet_types (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petType
      ORDER BY name;
END pr_get_pet_types;

-- Razas de un tipo de mascota (nulo = todas)
PROCEDURE pr_get_pet_breeds (pnId_pet_type IN NUMBER, p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name, idPetType
      FROM petBreed
      WHERE idPetType = NVL(pnId_pet_type, idPetType)
      ORDER BY name;
END pr_get_pet_breeds;

-- Tamaños
PROCEDURE pr_get_pet_sizes (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petSize
      ORDER BY id;
END pr_get_pet_sizes;

-- Colores
PROCEDURE pr_get_pet_colors (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petColor
      ORDER BY name;
END pr_get_pet_colors;

-- Severidad (crítico, mal estado, buen estado)
PROCEDURE pr_get_pet_severities (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petSeverity
      ORDER BY id;
END pr_get_pet_severities;

-- Niveles de energía
PROCEDURE pr_get_pet_energies (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petEnergy
      ORDER BY id;
END pr_get_pet_energies;

-- Facilidad de entrenamiento
PROCEDURE pr_get_pet_trainabilities (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petTrainability
      ORDER BY id;
END pr_get_pet_trainabilities;

-- Estados de mascota (perdido, encontrado, en adopción, adoptado, etc.)
PROCEDURE pr_get_pet_statuses (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM petStatus
      ORDER BY name;
END pr_get_pet_statuses;

-- Tipos de foto (antes, después, adoptante con mascota, etc.)
PROCEDURE pr_get_photo_types (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM photoType
      ORDER BY name;
END pr_get_photo_types;

-- Enfermedades
PROCEDURE pr_get_diseases (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM disease
      ORDER BY name;
END pr_get_diseases;

-- Tratamientos
PROCEDURE pr_get_treatments (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM treatment
      ORDER BY name;
END pr_get_treatments;

-- Medicamentos
PROCEDURE pr_get_medications (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM medication
      ORDER BY name;
END pr_get_medications;

-----------------------------------------------------------------------------------
------------------------- Personas, adoptantes y casas cuna -----------------------
-----------------------------------------------------------------------------------

-- Tipos de vivienda
PROCEDURE pr_get_house_types (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM houseType
      ORDER BY name;
END pr_get_house_types;

-- Tiempos de ejercicio
PROCEDURE pr_get_exercise_times (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, value
      FROM exerciseTime
      ORDER BY id;
END pr_get_exercise_times;

-- Estados de casa cuna
PROCEDURE pr_get_foster_home_statuses (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id, name
      FROM fosterHomeStatus
      ORDER BY name;
END pr_get_foster_home_statuses;

-----------------------------------------------------------------------------------
------------------------- Administración de catálogos -----------------------------
-----------------------------------------------------------------------------------

-- Procedimiento que retorna los valores de un catálogo para la pantalla de administración.
-- Siempre retorna las columnas id, name e idParent (idParent es NULL en los catálogos sin padre).
PROCEDURE pr_get_catalog (
   pcCatalog    IN  VARCHAR2,
   pnId_parent  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR,
   pnResult     OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   IF fn_is_catalog(pcCatalog) = 0 THEN           -- Catálogo desconocido: se retorna un cursor vacío
      pnResult := c_dato_invalido;
      OPEN p_cursor FOR
         SELECT NULL AS id, NULL AS name, NULL AS idParent
         FROM dual
         WHERE 1 = 0;
      RETURN;
   END IF;

   CASE UPPER(TRIM(pcCatalog))
      -- Catálogos con padre (con pnId_parent nulo se retornan todos)
      WHEN 'CANTON' THEN
         OPEN p_cursor FOR
            SELECT id, name, idProvince AS idParent FROM canton
            WHERE idProvince = NVL(pnId_parent, idProvince) ORDER BY id;
      WHEN 'DISTRICT' THEN
         OPEN p_cursor FOR
            SELECT id, name, idCanton AS idParent FROM district
            WHERE idCanton = NVL(pnId_parent, idCanton) ORDER BY id;
      WHEN 'PET_BREED' THEN
         OPEN p_cursor FOR
            SELECT id, name, idPetType AS idParent FROM petBreed
            WHERE idPetType = NVL(pnId_parent, idPetType) ORDER BY id;
      WHEN 'PROVINCE' THEN
         OPEN p_cursor FOR
            SELECT id, name, idCountry AS idParent FROM province
            WHERE idCountry = NVL(pnId_parent, idCountry) ORDER BY id;

      -- Catálogos sin padre
      WHEN 'ROLE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM "Role"
         ORDER BY id;
      WHEN 'USER_STATUS' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM userStatus
         ORDER BY id;
      WHEN 'DONATION_TYPE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM donationType
         ORDER BY id;
      WHEN 'CURRENCY_TYPE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM currencyType
         ORDER BY id;
      WHEN 'PET_TYPE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petType
         ORDER BY id;
      WHEN 'PET_SIZE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petSize
         ORDER BY id;
      WHEN 'PET_COLOR' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petColor
         ORDER BY id;
      WHEN 'PET_SEVERITY' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petSeverity
         ORDER BY id;
      WHEN 'PET_ENERGY' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petEnergy
         ORDER BY id;
      WHEN 'PET_TRAINABILITY' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petTrainability
         ORDER BY id;
      WHEN 'PET_STATUS' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM petStatus
         ORDER BY id;
      WHEN 'PHOTO_TYPE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM photoType
         ORDER BY id;
      WHEN 'DISEASE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM disease
         ORDER BY id;
      WHEN 'HOUSE_TYPE' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM houseType
         ORDER BY id;
      WHEN 'EXERCISE_TIME' THEN OPEN p_cursor FOR
         SELECT id, value AS name, NULL AS idParent
         FROM exerciseTime
         ORDER BY id;   -- Esta tabla usa la columna value
      WHEN 'FOSTER_HOME_STATUS' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM fosterHomeStatus
         ORDER BY id;
      WHEN 'COUNTRY' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM country
         ORDER BY id;
      WHEN 'TREATMENT' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM treatment
         ORDER BY id;
      WHEN 'MEDICATION' THEN OPEN p_cursor FOR
         SELECT id, name,  NULL AS idParent
         FROM medication
         ORDER BY id;
   END CASE;

EXCEPTION                                 -- Manejo de excepciones
   WHEN OTHERS THEN
      pnResult := c_error_bd;
END pr_get_catalog;


-- Procedimiento para registrar un nuevo valor en un catálogo
PROCEDURE pr_insert_catalog (
   pcCatalog       IN  VARCHAR2,
   pcName          IN  VARCHAR2,
   pnId_parent     IN  NUMBER,
   pnId_catalog    OUT NUMBER,
   pnResult        OUT NUMBER)
AS
   vcName       VARCHAR2(200);
   vnId_catalog NUMBER;
BEGIN
   pnResult := c_exito;
   vcName   := TRIM(pcName);

   IF fn_is_catalog(pcCatalog) = 0 OR vcName IS NULL THEN   -- Catálogo desconocido o nombre vacío
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   -- Inserta el valor generando su ID por medio de la secuencia del catálogo
   CASE UPPER(TRIM(pcCatalog))
      -- Catálogos con padre
      WHEN 'CANTON' THEN
         INSERT INTO canton (id, name, idProvince) VALUES (s_canton.NEXTVAL, vcName, pnId_parent) RETURNING id INTO vnId_catalog;
      WHEN 'DISTRICT' THEN
         INSERT INTO district (id, name, idCanton) VALUES (s_district.NEXTVAL, vcName, pnId_parent) RETURNING id INTO vnId_catalog;
      WHEN 'PET_BREED' THEN
         INSERT INTO petBreed (id, name, idPetType) VALUES (s_petBreed.NEXTVAL, vcName, pnId_parent) RETURNING id INTO vnId_catalog;

      WHEN 'PROVINCE' THEN                        -- Corregido: guarda el país (idCountry es obligatorio)
         INSERT INTO province (id, name, idCountry) VALUES (s_province.NEXTVAL, vcName, pnId_parent) RETURNING id INTO vnId_catalog;

      -- Catálogos sin padre
      WHEN 'ROLE' THEN
         INSERT INTO "Role" (id, name) VALUES (s_role.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'USER_STATUS' THEN
         INSERT INTO userStatus (id, name) VALUES (s_userStatus.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'DONATION_TYPE' THEN
         INSERT INTO donationType (id, name) VALUES (s_donationType.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'CURRENCY_TYPE' THEN
         INSERT INTO currencyType (id, name) VALUES (s_currencyType.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_TYPE' THEN
         INSERT INTO petType (id, name) VALUES (s_petType.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_SIZE' THEN
         INSERT INTO petSize (id, name) VALUES (s_petSize.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_COLOR' THEN
         INSERT INTO petColor (id, name) VALUES (s_petColor.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_SEVERITY' THEN
         INSERT INTO petSeverity (id, name) VALUES (s_petSeverity.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_ENERGY' THEN
         INSERT INTO petEnergy (id, name) VALUES (s_petEnergy.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_TRAINABILITY' THEN
         INSERT INTO petTrainability (id, name) VALUES (s_petTrainability.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PET_STATUS' THEN
         INSERT INTO petStatus (id, name) VALUES (s_petStatus.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'PHOTO_TYPE' THEN
         INSERT INTO photoType (id, name) VALUES (s_photoType.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'DISEASE' THEN
         INSERT INTO disease (id, name) VALUES (s_disease.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'HOUSE_TYPE' THEN
         INSERT INTO houseType (id, name) VALUES (s_houseType.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'EXERCISE_TIME' THEN                   -- Esta tabla usa la columna value
         INSERT INTO exerciseTime (id, value) VALUES (s_exerciseTime.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'FOSTER_HOME_STATUS' THEN
         INSERT INTO fosterHomeStatus (id, name) VALUES (s_fosterHomeStatus.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'COUNTRY' THEN
         INSERT INTO country (id, name) VALUES (s_country.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'TREATMENT' THEN
         INSERT INTO treatment (id, name) VALUES (s_treatment.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
      WHEN 'MEDICATION' THEN
         INSERT INTO medication (id, name) VALUES (s_medication.NEXTVAL, vcName) RETURNING id INTO vnId_catalog;
   END CASE;

   COMMIT;
   pnId_catalog := vnId_catalog;

EXCEPTION                                           -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_insert_catalog;


-- Procedimiento para modificar un valor de un catálogo (y su padre, si el catálogo tiene)
PROCEDURE pr_update_catalog (
   pcCatalog       IN  VARCHAR2,
   pnId_catalog    IN  NUMBER,
   pcName          IN  VARCHAR2,
   pnId_parent     IN  NUMBER,
   pnResult        OUT NUMBER)
AS
   vcName      VARCHAR2(200);
   vcOld_name  VARCHAR2(200);
BEGIN
   pnResult := c_exito;
   vcName   := TRIM(pcName);

   IF fn_is_catalog(pcCatalog) = 0 OR vcName IS NULL THEN   -- Catálogo desconocido o nombre vacío
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   -- Nombre actual del valor (si no existe, se produce NO_DATA_FOUND)
   vcOld_name := fn_get_name(pcCatalog, pnId_catalog);

   -- No se renombra un valor que usa un parámetro; primero se debe cambiar el parámetro
   IF TRIM(vcOld_name) <> vcName AND fn_used_by_parameter(vcOld_name) = 1 THEN
      pnResult := c_catalogo_protegido;
      RETURN;
   END IF;

   CASE UPPER(TRIM(pcCatalog))
      -- Catálogos con padre (con pnId_parent nulo se conserva el padre actual)
      WHEN 'CANTON' THEN
         UPDATE canton
         SET name = vcName, idProvince = NVL(pnId_parent, idProvince)
         WHERE id = pnId_catalog;
      WHEN 'DISTRICT' THEN
         UPDATE district
         SET name = vcName, idCanton = NVL(pnId_parent, idCanton)
         WHERE id = pnId_catalog;
      WHEN 'PET_BREED' THEN
         UPDATE petBreed
         SET name = vcName, idPetType = NVL(pnId_parent, idPetType)
         WHERE id = pnId_catalog;

      WHEN 'PROVINCE' THEN
         UPDATE province
         SET name = vcName, idCountry = NVL(pnId_parent, idCountry)
         WHERE id = pnId_catalog;

      -- Catálogos sin padre
      WHEN 'ROLE' THEN
         UPDATE "Role"
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'USER_STATUS' THEN
         UPDATE userStatus
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'DONATION_TYPE' THEN
         UPDATE donationType
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'CURRENCY_TYPE' THEN
         UPDATE currencyType
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_TYPE' THEN
         UPDATE petType
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_SIZE' THEN
         UPDATE petSize
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_COLOR' THEN
         UPDATE petColor
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_SEVERITY' THEN
         UPDATE petSeverity
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_ENERGY' THEN
         UPDATE petEnergy
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_TRAINABILITY' THEN
         UPDATE petTrainability
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PET_STATUS' THEN
         UPDATE petStatus
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'PHOTO_TYPE' THEN
         UPDATE photoType
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'DISEASE' THEN
         UPDATE disease
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'HOUSE_TYPE' THEN
         UPDATE houseType
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'EXERCISE_TIME' THEN
         UPDATE exerciseTime
         SET value = vcName
         WHERE id = pnId_catalog;   -- Esta tabla usa la columna value
      WHEN 'FOSTER_HOME_STATUS' THEN
         UPDATE fosterHomeStatus
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'COUNTRY' THEN
         UPDATE country
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'TREATMENT' THEN
         UPDATE treatment
         SET name  = vcName
         WHERE id = pnId_catalog;
      WHEN 'MEDICATION' THEN
         UPDATE medication
         SET name  = vcName
         WHERE id = pnId_catalog;
   END CASE;

   COMMIT;

EXCEPTION                                 -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoNuloUpd OR eDatoLargo OR eNumeroGrande OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_catalog;


-- Procedimiento para eliminar un valor de un catálogo
PROCEDURE pr_delete_catalog (
   pcCatalog       IN  VARCHAR2,
   pnId_catalog    IN  NUMBER,
   pnResult        OUT NUMBER)
AS
   vcOld_name VARCHAR2(200);
BEGIN
   pnResult := c_exito;

   IF fn_is_catalog(pcCatalog) = 0 THEN           -- Catálogo desconocido
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   -- Nombre actual del valor (si no existe, se produce NO_DATA_FOUND)
   vcOld_name := fn_get_name(pcCatalog, pnId_catalog);

   -- No se elimina un valor que usa un parámetro
   IF fn_used_by_parameter(vcOld_name) = 1 THEN
      pnResult := c_catalogo_protegido;
      RETURN;
   END IF;

   CASE UPPER(TRIM(pcCatalog))
      WHEN 'PROVINCE' THEN
         DELETE
         FROM province
         WHERE id = pnId_catalog;
      WHEN 'CANTON' THEN
         DELETE
         FROM canton
         WHERE id = pnId_catalog;
      WHEN 'DISTRICT' THEN
         DELETE
         FROM district
         WHERE id = pnId_catalog;
      WHEN 'ROLE' THEN
         DELETE
         FROM "Role"
         WHERE id = pnId_catalog;
      WHEN 'USER_STATUS' THEN
         DELETE
         FROM userStatus
         WHERE id = pnId_catalog;
      WHEN 'DONATION_TYPE' THEN
         DELETE
         FROM donationType
         WHERE id = pnId_catalog;
      WHEN 'CURRENCY_TYPE' THEN
         DELETE
         FROM currencyType
         WHERE id = pnId_catalog;
      WHEN 'PET_TYPE' THEN
         DELETE
         FROM petType
         WHERE id = pnId_catalog;
      WHEN 'PET_BREED' THEN
         DELETE
         FROM petBreed
         WHERE id = pnId_catalog;
      WHEN 'PET_SIZE' THEN
         DELETE
         FROM petSize
         WHERE id = pnId_catalog;
      WHEN 'PET_COLOR' THEN
         DELETE
         FROM petColor
         WHERE id = pnId_catalog;
      WHEN 'PET_SEVERITY' THEN
         DELETE
         FROM petSeverity
         WHERE id = pnId_catalog;
      WHEN 'PET_ENERGY' THEN
         DELETE
         FROM petEnergy
         WHERE id = pnId_catalog;
      WHEN 'PET_TRAINABILITY' THEN
         DELETE
         FROM petTrainability
         WHERE id = pnId_catalog;
      WHEN 'PET_STATUS' THEN
         DELETE
         FROM petStatus
         WHERE id = pnId_catalog;
      WHEN 'PHOTO_TYPE' THEN
         DELETE
         FROM photoType
         WHERE id = pnId_catalog;
      WHEN 'DISEASE' THEN
         DELETE
         FROM disease
         WHERE id = pnId_catalog;
      WHEN 'HOUSE_TYPE' THEN
         DELETE
         FROM houseType
         WHERE id = pnId_catalog;
      WHEN 'EXERCISE_TIME' THEN
         DELETE
         FROM exerciseTime
         WHERE id = pnId_catalog;
      WHEN 'FOSTER_HOME_STATUS' THEN
         DELETE
         FROM fosterHomeStatus
         WHERE id = pnId_catalog;
      WHEN 'COUNTRY' THEN
         DELETE
         FROM country
         WHERE id = pnId_catalog;
      WHEN 'TREATMENT' THEN
         DELETE
         FROM treatment
         WHERE id = pnId_catalog;
      WHEN 'MEDICATION' THEN
         DELETE
         FROM medication
         WHERE id = pnId_catalog;
   END CASE;

   COMMIT;

EXCEPTION                                   -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eHijoExiste THEN
      ROLLBACK;
      pnResult := c_catalogo_en_uso;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_catalog;

-----------------------------------------------------------------------------------
-------------- Asociaciones de enfermedades, tratamientos y medicamentos ----------
-----------------------------------------------------------------------------------

-- Procedimiento que asocia un tratamiento a una enfermedad, con su duración
PROCEDURE pr_add_treatment_to_disease (
   pnId_disease    IN  NUMBER,
   pnId_treatment  IN  NUMBER,
   pcTime_length   IN  VARCHAR2,
   pnResult        OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO treatment_x_disease (idDisease, idTreatment, timeLength)
   VALUES (pnId_disease, pnId_treatment, TRIM(pcTime_length));

   COMMIT;

EXCEPTION                                   -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_treatment_to_disease;

-- Procedimiento que agrega un medicamento a un tratamiento, con su dosis
PROCEDURE pr_add_medication_to_treatment (
   pnId_treatment   IN  NUMBER,
   pnId_medication  IN  NUMBER,
   pcDosage         IN  VARCHAR2,
   pnResult         OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   INSERT INTO medication_x_treatment (idMedication, idTreatment, dosage)
   VALUES (pnId_medication, pnId_treatment, TRIM(pcDosage));

   COMMIT;

EXCEPTION                                   -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo OR eDatoLargo OR eCheckViolado THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_medication_to_treatment;

END pkg_catalog;
/

-- Recompila los objetos que dependian del paquete (solo los invalidos)
BEGIN
   DBMS_UTILITY.COMPILE_SCHEMA(schema => USER, compile_all => FALSE);
END;
/

-- Comprobacion: todo debe decir VALID
SHOW ERRORS PACKAGE PKG_CATALOG
SHOW ERRORS PACKAGE BODY PKG_CATALOG
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'PROCEDURE', 'FUNCTION')
AND (status <> 'VALID' OR object_name = 'PKG_CATALOG')
ORDER BY object_name, object_type;
