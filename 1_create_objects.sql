CREATE USER sorintmon IDENTIFIED BY Password;
grant connect, resource to sorint;

DROP TABLE sorint.sql_monitor;

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
  ELAPSED_TIME       NUMBER
  mon_report         CLOB,
PRIMARY KEY (sql_id, key));

-- Query test:

set serveroutput on 
set timing on
declare
x number :=0 ;
y number :=0 ;
r number :=0 ;
 
begin
while  y < 10000 loop
   y := y+1;
   while  x < 10000  loop
   x := x+1;
   r := x*y;
   end loop;
   /*sorintmon|0,1|*/
x := 0;
end loop;
dbms_output.put_line('result = '||r);
end;
/