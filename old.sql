



COL creation NEW_V creation FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&1.'), 1, 1)), '?') creation FROM DUAL;

BEGIN
  IF NOT '&&creation.' IN ('Y', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid choise "&&creation.". Valid values are Y and N.');
  END IF;
END;
/


WHENEVER SQLERROR EXIT;
DECLARE
 is_grant_ok NUMBER;
 is_quota_ok NUMBER;
BEGIN
WITH list_grant AS
  (SELECT LPAD(' ', 5*LEVEL) || granted_role "GR"
   FROM
     ( SELECT NULL grantee,
                   username granted_role
      FROM dba_users
      WHERE username LIKE UPPER('&schema_name')
      UNION SELECT grantee,
                   granted_role
      FROM dba_role_privs
      UNION SELECT grantee,
                   privilege
      FROM dba_sys_privs) START WITH grantee IS NULL CONNECT BY grantee =
   PRIOR granted_role)
SELECT count(*) INTO is_grant_ok
FROM list_grant lg
WHERE lg.GR LIKE '%CREATE SESSION%'
  OR lg.GR LIKE '%CREATE TABLE%';
  IF is_grant_ok < 2 THEN
    RAISE_APPLICATION_ERROR(-20100, 'Grant required: CONNECT RESOURCE');
  END IF;

SELECT count(*) into is_quota_ok FROM(
select tablespace_name "Tablespace_Name", 
        username "Username",
        bytes/1024/1024 "Megabytes", 
        (case when max_bytes = -1 then null 
              else max_bytes/1024/1024 end) "Max_Megabytes",
        (case when max_bytes = -1 then 'UNLIMITED' 
              else null end) "Quota"
   from sys.dba_ts_quotas
  where (TABLESPACE_NAME is null or 
         instr(lower(tablespace_name),lower(TABLESPACE_NAME)) > 0)
  and username like '&schema_name'
  and tablespace_name like (select DEFAULT_TABLESPACE from dba_users where username like '&schema_name')
  );
  IF is_quota_ok < 1 THEN
    RAISE_APPLICATION_ERROR(-20100, 'Quota required on default tablespace of user &schema_name');
  END IF;
END;
/



CREATE USER sorintmon IDENTIFIED BY Password QUOTA UNLIMITED ON USERS;
grant connect, resource to sorintmon;

DROP TABLE sorintmon.sql_monitor;

CREATE TABLE sorintmon.sql_monitor (
  sql_id             VARCHAR2(13),
  key                NUMBER,
  sql_exec_start     DATE,
  sql_exec_id        NUMBER,
  status             VARCHAR2(19),
  first_refresh_time DATE,
  last_refresh_time  DATE,
  username           VARCHAR2(30),
  capture_date       DATE,
  report_date        DATE,
  sql_text           VARCHAR2(2000),
  ELAPSED_TIME       NUMBER,
  mon_report         CLOB,
PRIMARY KEY (sql_id, key));
