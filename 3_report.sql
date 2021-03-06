SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NUM 20 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF SERVEROUT ON SIZE UNL;

SPO create_report.sql;
PRO SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NUM 20 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF SERVEROUT ON SIZE UNL;;
BEGIN
  FOR i IN (SELECT t.sql_id, t.key, t.ROWID row_id FROM sorintmon.sql_monitor t WHERE t.report_date IS NULL)
  LOOP
    DBMS_OUTPUT.PUT_LINE('SPO sql_id_'||i.sql_id||'_key_'||i.key||'.html;');
    DBMS_OUTPUT.PUT_LINE('SELECT mon_report FROM sorintmon.sql_monitor WHERE sql_id = '''||i.sql_id||''' AND key = '||i.key||';');
    DBMS_OUTPUT.PUT_LINE('SPO OFF;');
    DBMS_OUTPUT.PUT_LINE('UPDATE sorintmon.sql_monitor SET report_date = SYSDATE WHERE ROWID = '''||i.row_id||''';');
  END LOOP;
END;
/
PRO COMMIT;;
PRO SET TERM ON ECHO OFF FEED 6 VER ON SHOW OFF HEA ON LIN 80 NUM 10 NEWP 1 PAGES 14 LONG 80 LONGC 80 SQLC MIX TAB ON TRIMS OFF TI OFF TIMI OFF  NUMF "" SQLP SQL> SUF sql BLO . RECSEP WR APPI OFF SERVEROUT OFF AUTOT OFF;;
SPO OFF;

@create_report.sql