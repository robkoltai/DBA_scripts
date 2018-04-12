SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: display_statspack.sql
REM Author......: Christian Antognini
REM Date........: August 2014
REM Description.: This script shows how to query the Statspack repository
REM               through the dbms_xplan package.
REM Notes.......: As of 12c the dbms_xplan package requires that the plan table 
REM               has a column named "timestamp". To workaround this issue I
REM               advise to create an invisible virtual column with the 
REM               following SQL statement:
REM
REM               ALTER TABLE perfstat.stats$sql_plan 
REM               ADD timestamp INVISIBLE AS (cast(NULL AS DATE))
REM
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 05.01.2016 Added note in the header about 12c issue
REM ***************************************************************************

SET LINESIZE 120
SET PAGESIZE 1000
SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

COLUMN sql_test FORMAT A64
COLUMN snap_id FORMAT 9999999999999
COLUMN plan_hash_value FORMAT 9999999999999
COLUMN plan_table_output FORMAT A120 TRUNCATE

UNDEFINE sql_id

PROMPT

SELECT sql_text
FROM perfstat.stats$sqltext
WHERE sql_id = '&&sql_id'
ORDER BY piece;

PROMPT

SELECT snap_id, plan_hash_value 
FROM perfstat.stats$sql_plan_usage 
WHERE sql_id = '&sql_id' 
ORDER BY snap_id;

PROMPT
PROMPT

SELECT * 
FROM table(
  dbms_xplan.display(
    table_name   => 'perfstat.stats$sql_plan',
    format       => 'typical -predicate -note',
    filter_preds => 'snap_id=&snap_id AND plan_hash_value=&hash_value'
  )
);

UNDEFINE sql_id