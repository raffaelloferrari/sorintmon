VAR QUERY_PROBLEM VARCHAR2
VAR STATUS NUMBER

DECLARE
  l_mon_report CLOB;
BEGIN
--  LOOP -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
    INSERT INTO "&SCHEMA_NAME".sql_monitor (sql_id, KEY, sql_exec_start, sql_exec_id, status, first_refresh_time, last_refresh_time, sql_text, username,elapsed_time)
    SELECT v.sql_id,
           v.KEY,
             v.sql_exec_start,
             v.sql_exec_id,
             v.status,
             v.first_refresh_time,
             v.last_refresh_time,
             v.sql_text,
             v.username,
             v.elapsed_time/1000
    FROM v$sql_monitor v
    WHERE v.sql_text LIKE '%sorintmon%'
      AND v.sql_text NOT LIKE '%&SCHEMA_NAME.sql_monitor%'
      AND v.elapsed_time/1000 > TO_NUMBER(REGEXP_SUBSTR(v.sql_text,'[^|]+',1,2))
      AND (v.status LIKE 'DONE%'
           OR (v.status = 'EXECUTING'
               AND (v.last_refresh_time - v.first_refresh_time) > 1/24/60 /* 1 min */))
      AND NOT EXISTS
        (SELECT NULL
         FROM "&SCHEMA_NAME".sql_monitor t
         WHERE t.sql_id = v.sql_id
           AND t.KEY = v.KEY);

    FOR i IN (SELECT t.*, t.ROWID row_id FROM "&SCHEMA_NAME".sql_monitor t WHERE t.capture_date IS NULL)
    LOOP
      l_mon_report := DBMS_SQLTUNE.REPORT_SQL_MONITOR (
        sql_id         => i.sql_id,
        sql_exec_start => i.sql_exec_start,
        sql_exec_id    => i.sql_exec_id,
        report_level   => 'ALL',
        type           => 'ACTIVE' );

      UPDATE "&SCHEMA_NAME".sql_monitor
         SET mon_report = l_mon_report,
             capture_date = SYSDATE
       WHERE ROWID = i.row_id;
    END LOOP;

    COMMIT;
--    DBMS_LOCK.SLEEP(60); -- sleep 1 min - -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
--  END LOOP; -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
-- COL query_problem NEW_V query_problem FOR 9999 noprint;

select count(*) into :QUERY_PROBLEM FROM "&SCHEMA_NAME".sql_monitor;

-- COL status NEW_V status FOR A100 noprint;
SELECT
   CASE WHEN count(*) > 0 THEN '1'
        WHEN COUNT(*) > 50 THEN '2'
   ELSE '0' END into  :STATUS
   FROM "&SCHEMA_NAME".sql_monitor;
END;
/


select 'details: There are '||:QUERY_PROBLEM||'  queries that have exceeded the threshold' from dual;
select 'long: There are '||:QUERY_PROBLEM||'  queries that have exceeded the threshold' from dual;
select 'exit:'||:STATUS from dual;