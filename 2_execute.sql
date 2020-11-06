DECLARE
  l_mon_report CLOB;
BEGIN
--  LOOP -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
    INSERT INTO sorintmon.sql_monitor (sql_id, key, sql_exec_start, sql_exec_id, status, first_refresh_time, last_refresh_time, sql_text, username,elapsed_time )
    SELECT v.sql_id, v.key, v.sql_exec_start, v.sql_exec_id, v.status, v.first_refresh_time, v.last_refresh_time, v.sql_text, v.username,v.elapsed_time/1000
      FROM v$sql_monitor v
       WHERE v.sql_text like '%sorintmon%'
       AND v.elapsed_time/1000 > TO_NUMBER(REGEXP_SUBSTR(v.sql_text,'[^|]+',1,2))
       AND (v.status LIKE 'DONE%' OR (v.status = 'EXECUTING' AND (v.last_refresh_time - v.first_refresh_time) > 1/24/60 /* 1 min */))
       AND NOT EXISTS (SELECT NULL FROM sorintmon.sql_monitor t WHERE t.sql_id = v.sql_id AND t.key = v.key);

    FOR i IN (SELECT t.*, t.ROWID row_id FROM sorintmon.sql_monitor t WHERE t.capture_date IS NULL)
    LOOP
      l_mon_report := DBMS_SQLTUNE.REPORT_SQL_MONITOR (
        sql_id         => i.sql_id,
        sql_exec_start => i.sql_exec_start,
        sql_exec_id    => i.sql_exec_id,
        report_level   => 'ALL',
        type           => 'ACTIVE' );

      UPDATE sorintmon.sql_monitor
         SET mon_report = l_mon_report,
             capture_date = SYSDATE
       WHERE ROWID = i.row_id;
    END LOOP;

    COMMIT;

--    DBMS_LOCK.SLEEP(60); -- sleep 1 min - -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
--  END LOOP; -- Decommentare nel caso lo sivoglia far eseguire ogni x minuti
END;
/
