create or replace PACKAGE pkg_user_administration AS
 
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
c_referencia_no_existe CONSTANT NUMBER := 1100;
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
   pcPassword_hash    IN  VARCHAR2,
   pnResult           OUT NUMBER);

-- Devuelve una fila solo si el usuario y la contraseña coinciden (cursor vacío si no)
PROCEDURE pr_login_user (
   pcUsername      IN  VARCHAR2,
   pcPassword_hash IN  VARCHAR2,
   p_cursor        OUT SYS_REFCURSOR);

FUNCTION fn_active_status_name RETURN VARCHAR2;

-- Administración de usuarios (pantalla del administrador)
PROCEDURE pr_get_users (
   pnId_role    IN  NUMBER,
   pnId_status  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR);

PROCEDURE pr_update_user_status (
   pnId_user    IN  NUMBER,
   pnId_status  IN  NUMBER,
   pnResult     OUT NUMBER);

PROCEDURE pr_update_user_role (
   pnId_user  IN  NUMBER,
   pnId_role  IN  NUMBER,
   pnResult   OUT NUMBER);

END pkg_user_administration;


create or replace PACKAGE BODY pkg_user_administration AS
 
-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo   EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,   -1400);    -- NULL en columna NOT NULL
eDatoLargo  EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,  -12899);   -- valor mas largo que la columna
eFkNoExiste EXCEPTION;
PRAGMA EXCEPTION_INIT(eFkNoExiste, -2291);    -- FK: rol o estado no existe

-------------------------------------------------------------------------
------------------- Verificaciones de duplicados ------------------------
-------------------------------------------------------------------------

-- Función que verifica la existencia de un usuario en la BD
FUNCTION fn_username_exists (pcUsername IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   -- Intenta seleccionar un 1 si el usuario existe
   SELECT 1
   INTO vnTest
   FROM "User"
   WHERE LOWER(username) = LOWER(TRIM(pcUsername));

   RETURN 1;
EXCEPTION                        -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END fn_username_exists;

-- Función que verifica la existencia de un correo en la BD
FUNCTION fn_email_exists (pcEmail IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   -- Intenta seleccionar un 1 si el correo existe
   SELECT 1
   INTO vnTest
   FROM contactEmail
   WHERE LOWER(email) = LOWER(TRIM(pcEmail));

   RETURN 1; 
EXCEPTION                           -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      RETURN 0; 
END fn_email_exists;

-- Función que verifica la existencia de un teléfono en la BD
FUNCTION fn_phone_exists (pcPhone IN VARCHAR2)
RETURN NUMBER
IS
   vnTest NUMBER;
BEGIN
   -- Intenta seleccionar un 1 si el tléfono existe
   SELECT 1
   INTO vnTest
   FROM contactNumber
   WHERE phoneNumber = TRIM(pcPhone);

   RETURN 1; 
EXCEPTION                            -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN
      RETURN 0; 
END fn_phone_exists;

-----------------------------------------------------------------------------------
------------------- Registrar datos e iniciar sesión ------------------------------
-----------------------------------------------------------------------------------

-- Procedimiento encargado del registro de un usuario en la BD
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
   pcPassword_hash    IN  VARCHAR2, -- Recibe el Hash de 64 caracteres generado por el Backend

   pnResult           OUT NUMBER)
AS
   vnId_person        NUMBER;
   vnId_role          NUMBER;
   vnId_status        NUMBER;
   vnResult           NUMBER;
BEGIN
   pnResult := c_exito;

   -- Valida que la contraseña hash no venga vacía y tenga la longitud de SHA-256 (64 caracteres)
   IF TRIM(pcPassword_hash) IS NULL OR LENGTH(TRIM(pcPassword_hash)) <> 64 THEN
      pnResult := c_dato_invalido;
      RETURN;
   END IF;

   -- Rol y estado por defecto (parametrizados)
   SELECT id INTO vnId_role
   FROM "Role"
   WHERE name = pkg_parameter.fn_get_text('DEFAULT_ROLE_NAME');

   SELECT id INTO vnId_status
   FROM userStatus
   WHERE name = pkg_parameter.fn_get_text('DEFAULT_USER_STATUS');

   -- Registra la persona (incluyendo locación, teléfono y correo)
   pkg_person_administration.pr_register_person(
      TRIM(pcFirst_name), TRIM(pcMiddle_name), TRIM(pcFirst_lastName), TRIM(pcSecond_lastName),
      pnId_district, pcAddress, pcPhone, pcEmail,
      vnId_person, vnResult
   );

   -- Verifica si la inserción de la persona fue correcta
   IF vnResult <> c_exito THEN
      pnResult := vnResult;
      RETURN;
   END IF;

   -- Inserta las credenciales del usuario con el Hash enviado en mayúsculas
   INSERT INTO "User" (id, idPerson, idRole, idUserStatus, username, password)
   VALUES (s_user.NEXTVAL, vnId_person, vnId_role, vnId_status, TRIM(pcUsername),
           UPPER(TRIM(pcPassword_hash)));

   COMMIT;

EXCEPTION                                -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                
      ROLLBACK;
      pnResult := c_parametro_faltante;
   WHEN DUP_VAL_ON_INDEX THEN             
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eDatoNulo OR eDatoLargo THEN      
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN                       
      ROLLBACK;
      pnResult := c_error_bd;
END pr_register_user;


-- Procedimiento para inicio de sesión
PROCEDURE pr_login_user (
   pcUsername      IN  VARCHAR2,
   pcPassword_hash IN  VARCHAR2, -- Recibe el Hash generado por el Backend
   p_cursor        OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT u.id,
             u.idPerson,
             u.username,
             TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS fullName,
             r.name AS roleName,
             s.name AS statusName

      FROM "User" u
      INNER JOIN person p   
      ON p.id = u.idPerson

      INNER JOIN "Role" r
      ON r.id = u.idRole

      INNER JOIN userStatus s
      ON s.id = u.idUserStatus

      WHERE LOWER(u.username) = LOWER(TRIM(pcUsername))
      AND u.password = UPPER(TRIM(pcPassword_hash));
END pr_login_user;

-- Función que retorna el nombre del estado "activo" (parametrizado)
FUNCTION fn_active_status_name
RETURN VARCHAR2
IS
BEGIN
   RETURN pkg_parameter.fn_get_text('ACTIVE_USER_STATUS');
END fn_active_status_name;

-----------------------------------------------------------------------------------
------------------- Administración de usuarios ------------------------------------
-----------------------------------------------------------------------------------

-- Consulta de usuarios para el administrador (filtros por rol y estado opcionales; nulos = todos)
PROCEDURE pr_get_users (
   pnId_role    IN  NUMBER,
   pnId_status  IN  NUMBER,
   p_cursor     OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT u.id,
             u.idPerson,
             u.username,
             TRIM(p.firstName || ' ' || p.firstLastName || ' ' || p.secondLastName) AS fullName,
             r.id   AS roleId,
             r.name AS roleName,
             s.id   AS statusId,
             s.name AS statusName
      FROM "User" u
      INNER JOIN person p    
      ON p.id = u.idPerson

      INNER JOIN "Role" r    
      ON r.id = u.idRole

      INNER JOIN userStatus s 
      ON s.id = u.idUserStatus

      WHERE r.id = NVL(pnId_role, r.id)
      AND s.id = NVL(pnId_status, s.id)

      ORDER BY u.username;
END pr_get_users;


-- Cambia el estado de un usuario (activar, bloquear, etc.)
PROCEDURE pr_update_user_status (
   pnId_user    IN  NUMBER,
   pnId_status  IN  NUMBER,
   pnResult     OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   UPDATE "User"
   SET idUserStatus = pnId_status
   WHERE id = pnId_user;

   COMMIT;

EXCEPTION                                            -- Manejo de excepciones
   WHEN eFkNoExiste THEN                  
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_user_status;


-- Cambia el rol de un usuario
PROCEDURE pr_update_user_role (
   pnId_user  IN  NUMBER,
   pnId_role  IN  NUMBER,
   pnResult   OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   UPDATE "User"
   SET idRole = pnId_role
   WHERE id = pnId_user;

   COMMIT;

EXCEPTION                                             -- Manejo de excepciones
   WHEN eFkNoExiste THEN                 
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eDatoNulo THEN
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN
      ROLLBACK;
      pnResult := c_error_bd;
END pr_update_user_role;


END pkg_user_administration;
