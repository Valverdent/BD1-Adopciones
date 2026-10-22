-- 1. CREACIÓN DE TABLESPACES (Estructura Física)
-- ------------------------------------------------

-- -------------- ESQUEMA PRINCIPAL ---------------- 
-- Datos Principales
CREATE TABLESPACE Adopcion_Data
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionData01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;
CREATE TABLESPACE Adopcion_Idx
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionIdx01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;

-- Documentos / Fotos
CREATE TABLESPACE Adopcion_Docs_Data
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionDocsData01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;
CREATE TABLESPACE Adopcion_Docs_Idx
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionDocsIdx01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;

---------------- ESQUEMA HISTÓRICO ----------------
-- Histórico
CREATE TABLESPACE Adopcion_Hist_Data
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionHistData01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;
CREATE TABLESPACE Adopcion_Hist_Idx
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionHistIdx01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;

---------------- ESQUEMA AUDITORÍA ----------------
-- Auditoría
CREATE TABLESPACE Adopcion_Audit_Data
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionAuditData01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;
CREATE TABLESPACE Adopcion_Audit_Idx
   DATAFILE '/home/viernes/Documents/oradata/BASESVRNS/basesvrnspdb3/AdopcionAuditIdx01.dbf'
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;


-- 2. CREACIÓN DE ESQUEMAS
-- -----------------------------------------------------

-- 2.1. Esquema Principal 
CREATE USER ADOPCION_APP 
    IDENTIFIED BY AppAdopciones4455 
    DEFAULT TABLESPACE Adopcion_Data 
    QUOTA UNLIMITED ON Adopcion_Data
    QUOTA UNLIMITED ON Adopcion_Idx
    QUOTA UNLIMITED ON Adopcion_Docs_Data
    QUOTA UNLIMITED ON Adopcion_Docs_Idx
    TEMPORARY TABLESPACE temp;
    --PROFILE app_user 
    --PASSWORD EXPIRE;

GRANT connect TO ADOPCION_APP;
GRANT create session to ADOPCION_APP;
GRANT create table to ADOPCION_APP;
GRANT create view to ADOPCION_APP;

-- 2.2. Esquema Histórico 
CREATE USER ADOPCION_HIST 
    IDENTIFIED BY HistAdopciones4455 
    DEFAULT TABLESPACE Adopcion_Hist_Data 
    QUOTA UNLIMITED ON Adopcion_Hist_Data
    QUOTA UNLIMITED ON Adopcion_Hist_Idx
    TEMPORARY TABLESPACE temp;
    --PROFILE app_user 
    --PASSWORD EXPIRE;

GRANT connect TO ADOPCION_HIST;
GRANT create session to ADOPCION_HIST;
GRANT create table to ADOPCION_HIST;
GRANT create view to ADOPCION_HIST;

-- 2.2. Esquema Auditoría 
CREATE USER ADOPCION_AUDIT 
    IDENTIFIED BY AuditAdopciones4455 
    DEFAULT TABLESPACE Adopcion_Audit_Data 
    QUOTA UNLIMITED ON Adopcion_Audit_Data
    QUOTA UNLIMITED ON Adopcion_Audit_Idx
    TEMPORARY TABLESPACE temp;
    --PROFILE app_user 
    --PASSWORD EXPIRE;

GRANT connect TO ADOPCION_AUDIT;
GRANT create session to ADOPCION_AUDIT;
GRANT create table to ADOPCION_AUDIT;
GRANT create view to ADOPCION_AUDIT;