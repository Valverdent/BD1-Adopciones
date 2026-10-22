/* Package:     pkg_parameter
 * Descripción: Lectura de los valores de la tabla Parameter (de texto y numéricos), para que ningún paquete tenga datos de configuración escritos en el código.
*/
------------------------------------------------------------------------------
---------------------------- ESPECIFICACIÓN ----------------------------------
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_parameter AS

-- Ambas lanzan NO_DATA_FOUND si el parámetro no existe.
FUNCTION fn_get_text   (pcName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION fn_get_number (pcName IN VARCHAR2) RETURN NUMBER;

END pkg_parameter;
/

---------------------------------------------------------------------------------
------------------------------- CUERPO ------------------------------------------
---------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_parameter AS

FUNCTION fn_get_text (pcName IN VARCHAR2)
RETURN VARCHAR2
IS
   vcValue parameter.textValue%TYPE;
BEGIN
   SELECT textValue INTO vcValue
   FROM parameter
   WHERE name = pcName;
   RETURN vcValue;
END fn_get_text;


FUNCTION fn_get_number (pcName IN VARCHAR2)
RETURN NUMBER
IS
   vnValue parameter.numberValue%TYPE;
BEGIN
   SELECT numberValue INTO vnValue
   FROM parameter
   WHERE name = pcName;
   RETURN vnValue;
END fn_get_number;

END pkg_parameter;
/