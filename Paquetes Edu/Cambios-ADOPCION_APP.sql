-- Creación de la tabla Parameter
CREATE TABLE Parameter (
    id              NUMBER(7)       CONSTRAINT parameter_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_APP_IDX,
    name            VARCHAR2(50)    CONSTRAINT parameter_name_NN NOT NULL
                                    CONSTRAINT parameter_name_uk UNIQUE USING INDEX TABLESPACE ADOPCION_APP_IDX,
    description     VARCHAR2(255),
    textValue       VARCHAR2(255),
    numberValue     NUMBER(9,2),
 
    CONSTRAINT parameter_value_chk CHECK ( 
        (textValue IS NOT NULL AND numberValue IS NULL) OR
        (textValue IS NULL AND numberValue IS NOT NULL))
) TABLESPACE ADOPCION_APP_DATA;


-- Indices únicos 
CREATE UNIQUE INDEX uq_contactEmail_email ON ContactEmail (LOWER(email)) TABLESPACE ADOPCION_APP_IDX;
 
CREATE UNIQUE INDEX uq_contactNumber_phone ON ContactNumber (phoneNumber) TABLESPACE ADOPCION_APP_IDX;
 
CREATE UNIQUE INDEX uq_user_username ON "User" (LOWER(username)) TABLESPACE ADOPCION_APP_IDX;
 