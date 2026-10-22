-- CORRER DESDE CONSOLA NATIVA DE LINUX EN EL ORAENV CORRESPONDIENTE USANDO sqlplus / as sysdba
ALTER SESSION SET CONTAINER = BASESVRNSPDB2;

@?/rdbms/admin/utlmail.sql
@?/rdbms/admin/prvtmail.plb

GRANT EXECUTE ON UTL_MAIL TO ADOPCION_APP;
GRANT EXECUTE ON UTL_SMTP TO ADOPCION_APP;

ALTER SYSTEM SET smtp_out_server = '127.0.0.1:25' SCOPE=BOTH;

BEGIN
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(
        host       => '127.0.0.1',
        lower_port => 25,
        upper_port => 25,
        ace        => xs$ace_type(
                        privilege_list => xs$name_list('connect'),
                        principal_name => 'ADOPCION_APP',
                        principal_type => xs_acl.ptype_db
                      )
    );
END;
/