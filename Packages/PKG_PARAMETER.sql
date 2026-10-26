create or replace PACKAGE pkg_parameter AS

-- Códigos de resultado
c_exito                CONSTANT NUMBER := 0;
c_dato_duplicado       CONSTANT NUMBER := 1004;
c_parametro_faltante   CONSTANT NUMBER := 1020;
c_dato_invalido        CONSTANT NUMBER := 1030;
c_referencia_no_existe CONSTANT NUMBER := 1100;
c_error_bd             CONSTANT NUMBER := 9000;

FUNCTION fn_get_text (pcName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION fn_get_number (pcName IN VARCHAR2) RETURN NUMBER;

PROCEDURE pr_get_parameters (
   pcName    IN  VARCHAR2, 
   p_cursor  OUT SYS_REFCURSOR);

PROCEDURE pr_insert_parameter (
   pcName         IN  VARCHAR2,
   pcDescription  IN  VARCHAR2,
   pcText_value   IN  VARCHAR2,
   pnNumber_value IN  NUMBER,
   pnResult       OUT NUMBER);

PROCEDURE pr_update_parameter (
   pnId_parameter  IN  NUMBER,
   pcText_value    IN  VARCHAR2,
   pnNumber_value  IN  NUMBER,
   pnResult        OUT NUMBER);

PROCEDURE pr_delete_parameter (
   pnId_parameter  IN  NUMBER,
   pnResult        OUT NUMBER);

END pkg_parameter;


create or replace PACKAGE BODY pkg_parameter AS

-- Errores con nombre propio (para atraparlos en el EXCEPTION)
eDatoNulo     EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoNulo,     -1400);    -- NULL en columna NOT NULL
eDatoLargo    EXCEPTION;
PRAGMA EXCEPTION_INIT(eDatoLargo,    -12899);   -- texto mas largo que la columna
eNumeroGrande EXCEPTION;
PRAGMA EXCEPTION_INIT(eNumeroGrande, -1438);    -- numero con mas digitos de los permitidos
eCheckViolado EXCEPTION;
PRAGMA EXCEPTION_INIT(eCheckViolado, -2290);    -- CHECK: el parametro debe tener exactamente un valor

-------------------------------------------------------------------------
------------------------- Getters de valores ----------------------------
-------------------------------------------------------------------------

-- Función que retorna el valor del atributo textValue VARCHAR2 por medio del nombre del parametro
FUNCTION fn_get_text (pcName IN VARCHAR2)
RETURN VARCHAR2
IS
   vcValue parameter.textValue%TYPE;
BEGIN
   -- Busca el valor VARCHAR2 por medio de un filtro del nombre del parametro 
   SELECT textValue INTO vcValue
   FROM parameter
   WHERE name = pcName;
   RETURN vcValue;
EXCEPTION                                 -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                                                 
      RETURN NULL;
END fn_get_text;


-- Función que retorna el valor del atributo numberValue NUMBER por medio del nombre del parametro
FUNCTION fn_get_number (pcName IN VARCHAR2)
RETURN NUMBER
IS
   vnValue parameter.numberValue%TYPE;
BEGIN
   -- Busca el valor NUMBER por medio de un filtro del nombre del parametro
   SELECT numberValue INTO vnValue
   FROM parameter
   WHERE name = pcName;
   RETURN vnValue;
EXCEPTION                                  -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                                                
      RETURN NULL;
END fn_get_number;


-- Procedimiento que retorna un cursor con los parámetros filtrados por nombre para la pantalla de administración
PROCEDURE pr_get_parameters (
   pcName    IN  VARCHAR2,
   p_cursor  OUT SYS_REFCURSOR)
AS
BEGIN
   OPEN p_cursor FOR
      SELECT id,
             name,
             description,
             textValue,
             numberValue
      FROM parameter
      WHERE LOWER(name) = NVL(LOWER(TRIM(pcName)), LOWER(name))            -- Si pcName es nulo, devuelve todos los parámetros
      ORDER BY name;
END pr_get_parameters;

-------------------------------------------------------------------------
-----------------Inserción, modificación, eliminación -------------------
-------------------------------------------------------------------------

-- Procedimiento para registrar un nuevo parámetro en la base de datos
PROCEDURE pr_insert_parameter (
   pcName         IN  VARCHAR2,
   pcDescription  IN  VARCHAR2,
   pcText_value   IN  VARCHAR2,
   pnNumber_value IN  NUMBER,
   pnResult       OUT NUMBER)
AS
BEGIN
   pnResult := c_exito;

   -- Inserta el nuevo parámetro en la BD 
   INSERT INTO parameter (id, name, description, textValue, numberValue)
   VALUES (s_parameter.NEXTVAL, TRIM(pcName), TRIM(pcDescription), TRIM(pcText_value), pnNumber_value);

   COMMIT;

EXCEPTION                                   -- Manejo de excepciones
   WHEN DUP_VAL_ON_INDEX THEN                                            
      ROLLBACK;
      pnResult := c_dato_duplicado;
   WHEN eCheckViolado OR eDatoNulo OR eDatoLargo OR eNumeroGrande THEN   
      ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN                                                       
      ROLLBACK;
      pnResult := c_error_bd;
END pr_insert_parameter;


-- Procedimiento para actualizar los valores (texto o numérico) de un parámetro existente
PROCEDURE pr_update_parameter (
   pnId_parameter  IN  NUMBER,
   pcText_value    IN  VARCHAR2,
   pnNumber_value  IN  NUMBER,
   pnResult        OUT NUMBER)
AS
   vnTest NUMBER;
BEGIN
   pnResult := c_exito;

   -- Valida que existe el parametro en el sistema
   SELECT 1
   INTO vnTest
   FROM parameter
   WHERE id = pnId_parameter;

   -- Modifica únicamente el tipo de dato activo que ya tenía el parámetro (texto o número)
   UPDATE parameter
   SET textValue   = CASE 
                        WHEN textValue IS NOT NULL OR numberValue IS NULL THEN TRIM(pcText_value) 
                        ELSE NULL 
                     END,
       numberValue = CASE
                        WHEN numberValue IS NOT NULL THEN pnNumber_value
                        ELSE NULL 
                     END
   WHERE id = pnId_parameter;

   COMMIT;

EXCEPTION                                                   -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                                                
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN eCheckViolado OR eDatoNulo OR eDatoLargo OR eNumeroGrande THEN     
   ROLLBACK;
      pnResult := c_dato_invalido;
   WHEN OTHERS THEN                                                       
      ROLLBACK;  
      pnResult := c_error_bd;
END pr_update_parameter;


-- Procedimiento para eliminar un parámetro del sistema por su ID
PROCEDURE pr_delete_parameter (
   pnId_parameter  IN  NUMBER,
   pnResult        OUT NUMBER)
AS
   vnTest NUMBER;
BEGIN
   pnResult := c_exito;

   -- Valida que existe el parametro en el sistema
   SELECT 1
   INTO vnTest
   FROM parameter
   WHERE id = pnId_parameter;

   -- Elimina el parámetro correspondiente al ID enviado
   DELETE FROM parameter
   WHERE id = pnId_parameter;

   COMMIT;

EXCEPTION                                           -- Manejo de excepciones
   WHEN NO_DATA_FOUND THEN                                          
      ROLLBACK;
      pnResult := c_referencia_no_existe;
   WHEN OTHERS THEN                                                 
      ROLLBACK;
      pnResult := c_error_bd;
END pr_delete_parameter;

END pkg_parameter;
