host clear

pro ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
pro ~  $$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$\ $$\   $$\ $$$$$$$$\ $$\      $$\  $$$$$$\  $$\   $$\  ~
pro ~ $$  __$$\ $$  __$$\ $$  __$$\ \_$$  _|$$$\  $$ |\__$$  __|$$$\    $$$ |$$  __$$\ $$$\  $$ | ~
pro ~ $$ /  \__|$$ /  $$ |$$ |  $$ |  $$ |  $$$$\ $$ |   $$ |   $$$$\  $$$$ |$$ /  $$ |$$$$\ $$ | ~
pro ~ \$$$$$$\  $$ |  $$ |$$$$$$$  |  $$ |  $$ $$\$$ |   $$ |   $$\$$\$$ $$ |$$ |  $$ |$$ $$\$$ | ~
pro ~  \____$$\ $$ |  $$ |$$  __$$<   $$ |  $$ \$$$$ |   $$ |   $$ \$$$  $$ |$$ |  $$ |$$ \$$$$ | ~
pro ~ $$\   $$ |$$ |  $$ |$$ |  $$ |  $$ |  $$ |\$$$ |   $$ |   $$ |\$  /$$ |$$ |  $$ |$$ |\$$$ | ~
pro ~ \$$$$$$  | $$$$$$  |$$ |  $$ |$$$$$$\ $$ | \$$ |   $$ |   $$ | \_/ $$ | $$$$$$  |$$ | \$$ | ~
pro ~  \______/  \______/ \__|  \__|\______|\__|  \__|   \__|   \__|     \__| \______/ \__|  \__| ~
pro ~                                                                                             ~
pro ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

pro Welcome in setup of SORINTMON, you need to fill the schema where you want initialize this application.
pro If schema does not exist it will be create, if it exist the SORINTMON check that all grantes are ok.
pro
pro SORINTMON need following grants:
pro  - Create table
pro  - Create session 
pro  - Quota on default tablespace
pro

ACCEPT schema_name CHAR FORMAT 'A30' -
PROMPT 'Enter schema name:  '

pro

set serverout on ver off feed on

WHENEVER SQLERROR EXIT SQL.SQLCODE;

DECLARE
 is_user_exist NUMBER;
BEGIN
SELECT count(*) into is_user_exist 
from dba_users where username like '&schema_name';
 IF is_user_exist > 0 THEN
    DBMS_OUTPUT.PUT_LINE('~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ');
    DBMS_OUTPUT.PUT_LINE('INFO: User &schema_name exist, assignin grants..');
    DBMS_OUTPUT.PUT_LINE('~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ');
    EXECUTE IMMEDIATE 'grant connect, create table to &schema_name';
    EXECUTE IMMEDIATE 'alter user &schema_name QUOTA UNLIMITED ON USERS';
 else
    DBMS_OUTPUT.PUT_LINE('~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ');
    DBMS_OUTPUT.PUT_LINE('ATTENTION: "&schema_name" does not exist, it will be create');
    DBMS_OUTPUT.PUT_LINE('~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ');
    EXECUTE IMMEDIATE 'CREATE USER &schema_name IDENTIFIED BY P4pp1n14ll0 QUOTA UNLIMITED ON USERS';
    EXECUTE IMMEDIATE 'grant connect, create table to &schema_name';
  END IF;
END;
/

WHENEVER SQLERROR CONTINUE

pro Creating table "&schema_name"."SQL_MONITOR"

CREATE TABLE "&schema_name".sql_monitor (
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

pro ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
pro Setup complete
pro ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~