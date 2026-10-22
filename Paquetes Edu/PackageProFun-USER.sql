/* Package:     pkg_user_administration
 * Descripción: Registro, inicio de sesión, agregar correo/teléfono y verificación de datos duplicados.
 * Requiere:    pkg_parameter (debe compilarse antes que este paquete)
 */
------------------------------------------------------------------------------
---------------------------- ESPECIFICACIÓN ----------------------------------
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_user_administration AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_username_existe      CONSTANT NUMBER := 1001;
c_correo_existe        CONSTANT NUMBER := 1002;
c_telefono_existe      CONSTANT NUMBER := 1003;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_persona_no_existe    CONSTANT NUMBER := 1010;
c_ubicacion_no_existe  CONSTANT NUMBER := 1011;
c_parametro_faltante   CONSTANT NUMBER := 1020;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_error_bd             CONSTANT NUMBER := 9000;

  
FUNCTION fn_username_exists (pcUsername IN VARCHAR2) RETURN NUMBER;
FUNCTION fn_email_exists    (pcEmail    IN VARCHAR2) RETURN NUMBER;
FUNCTION fn_phone_exists    (pcPhone    IN VARCHAR2) RETURN NUMBER;

PROCEDURE pr_register_user (
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnId_district      IN  NUMBER,
   pcAddress          IN  VARCHAR2,
   pcPhone            IN  VARCHAR2,
   pcEmail            IN  VARCHAR2,
   pcUsername         IN  VARCHAR2,
   pcPassword         IN  VARCHAR2,
   pnResult           OUT  NUMBER);

PROCEDURE pr_login_user (
   pcUsername IN  VARCHAR2,
   p_cursor   OUT SYS_REFCURSOR );

FUNCTION fn_active_status_name RETURN VARCHAR2;

PROCEDURE pr_add_email (
   pnId_person IN  NUMBER,
   pcEmail     IN  VARCHAR2,
   pnResult    OUT NUMBER );

PROCEDURE pr_add_phone (
   pnId_person IN  NUMBER,
   pcPhone     IN  VARCHAR2,
   pnResult    OUT NUMBER );

END pkg_user_administration;
/

---------------------------------------------------------------------------------
------------------------------- CUERPO ------------------------------------------
---------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_user_administration AS

-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo   EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,   -1400);    -- NULL en columna NOT NULL
eDatoLargo  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,  -12899);   -- valor mas largo que la columna
eFkNoExiste EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste, -2291);    -- FK: el registro padre no existe (persona, distrito)

-------------------------------------------------------------------------
------------------- Verificaciones de duplicados ------------------------
-------------------------------------------------------------------------
FUNCTION fn_username_exists (pcUsername IN VARCHAR2) 
RETURN NUMBER 
IS
   vnCount NUMBER;
BEGIN
   SELECT COUNT(1) INTO vnCount 
   FROM "User"
   WHERE LOWER(username) = LOWER(TRIM(pcUsername));
   RETURN CASE WHEN vnCount > 0 THEN 1 ELSE 0 END;
END fn_username_exists;


FUNCTION fn_email_exists (pcEmail IN VARCHAR2)
RETURN NUMBER 
IS
   vnCount NUMBER;
BEGIN
   SELECT COUNT(1) INTO vnCount 
   FROM contactEmail
   WHERE LOWER(email) = LOWER(TRIM(pcEmail));
   RETURN CASE WHEN vnCount > 0 THEN 1 ELSE 0 END;
END fn_email_exists;

FUNCTION fn_phone_exists (pcPhone IN VARCHAR2) 
RETURN NUMBER 
IS
   vnCount NUMBER;
BEGIN
   SELECT COUNT(1) INTO vnCount 
   FROM contactNumber
   WHERE phoneNumber = TRIM(pcPhone);
   RETURN CASE WHEN vnCount > 0 THEN 1 ELSE 0 END;
END fn_phone_exists;

-----------------------------------------------------------------------------------
------------------- Registrar datos e iniciar sesión ------------------------------
-----------------------------------------------------------------------------------
PROCEDURE pr_register_user (
   pcFirst_name       IN  VARCHAR2,
   pcMiddle_name      IN  VARCHAR2,
   pcFirst_lastName   IN  VARCHAR2,
   pcSecond_lastName  IN  VARCHAR2,
   pnId_district      IN  NUMBER,
   pcAddress          IN  VARCHAR2,
   pcPhone            IN  VARCHAR2,
   pcEmail            IN  VARCHAR2,
   pcUsername         IN  VARCHAR2,
   pcPassword         IN  VARCHAR2,
   pnResult           OUT  NUMBER) 
AS
   vnId_location      NUMBER;
   vnId_person        NUMBER;
   vnId_role          NUMBER;
   vnId_status        NUMBER;
BEGIN
   pnResult := c_exito;

   -- 1. Rol y estado por defecto 
   SELECT id INTO vnId_role 
   FROM "Role"
   WHERE name = pkg_parameter.fn_get_text('DEFAULT_ROLE_NAME');
   
   SELECT id INTO vnId_status
   FROM userStatus
   WHERE name = pkg_parameter.fn_get_text('DEFAULT_USER_STATUS');

   -- 2. Insercion a las tablas Location, Person y "User"
   INSERT INTO location (id, idDistrict, address)
   VALUES (s_location.NEXTVAL, pnId_district, TRIM(pcAddress))
   RETURNING id INTO vnId_location;

   INSERT INTO person (id, idLocation, first_Name, middle_Name, first_LastName, second_LastName)
   VALUES (s_person.NEXTVAL, vnId_location, TRIM(pcFirst_name), TRIM(pcMiddle_name), TRIM(pcFirst_lastName), TRIM(pcSecond_lastName))
   RETURNING id INTO vnId_person;

   INSERT INTO "User" (id, idPerson, idRole, idUserStatus, username, password)
   VALUES (s_user.NEXTVAL, vnId_person, vnId_Role, vnId_Status, TRIM(pcUsername), pcPassword);

   INSERT INTO contactEmail (id, idPerson, email)
   VALUES (s_contactEmail.NEXTVAL, vnId_person, TRIM(pcEmail));
   
   INSERT INTO contactNumber (id, idPerson, phoneNumber)
   VALUES (s_contactNumber.NEXTVAL, vnId_person, TRIM(pcPhone));
      
   COMMIT;
   
EXCEPTION
   WHEN NO_DATA_FOUND THEN 
      ROLLBACK;
      pnResult := c_parametro_faltante;
   WHEN DUP_VAL_ON_INDEX THEN
      -- Otro usuario registro el username, correo o telefono justo despues de la validacion
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eFkNoExiste THEN
      -- El distrito indicado no existe
      ROLLBACK;
      pnResult := c_ubicacion_no_existe;
   WHEN eDatoNulo OR eDatoLargo THEN 
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_user;
      

PROCEDURE pr_login_user (
   pcUsername IN  VARCHAR2,
   p_cursor   OUT SYS_REFCURSOR) 
AS
BEGIN
   OPEN p_cursor FOR
      SELECT u.id,
      u.idPerson,
      u.username,
      u.password,
      r.name AS roleName,
      s.name AS statusName
   FROM "User" u
   JOIN "Role" r 
   ON r.id = u.idRole
   JOIN userStatus s
   ON s.id = u.idUserStatus
   WHERE LOWER(u.username) = LOWER(TRIM(pcUsername));
END pr_login_user;


FUNCTION fn_active_status_name 
RETURN VARCHAR2
IS
BEGIN 
   RETURN pkg_parameter.fn_get_text('ACTIVE_USER_STATUS');
END fn_active_status_name;


PROCEDURE pr_add_email (
   pnId_person IN  NUMBER,
   pcEmail     IN  VARCHAR2,
   pnResult    OUT NUMBER) 
AS
BEGIN 
   pnResult := c_exito;
   
   INSERT INTO contactEmail (id, idPerson, email)
   VALUES (s_contactEmail.NEXTVAL, pnId_person, TRIM(pcEmail));
   
   COMMIT;
   
EXCEPTION 
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_correo_existe;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoLargo THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_email;
   
   
PROCEDURE pr_add_phone (
   pnId_person IN  NUMBER,
   pcPhone     IN  VARCHAR2,
   pnResult    OUT NUMBER) 
AS
BEGIN 
   pnResult := c_exito;
   
   INSERT INTO contactNumber (id, idPerson, phoneNumber)
   VALUES (s_contactNumber.NEXTVAL, pnId_person, TRIM(pcPhone));
   
   COMMIT;
   
EXCEPTION 
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      pnResult := c_telefono_existe;
   WHEN eFkNoExiste THEN
      ROLLBACK;
      pnResult := c_persona_no_existe;
   WHEN eDatoNulo OR eDatoLargo THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_add_phone;

END pkg_user_administration;
/