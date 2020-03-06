https://sqlmaria.com/2020/02/25/how-to-use-a-sql-plan-baseline-or-a-sql-patch-to-add-optimizer-hints/

--Adding a hint via a SQL Plan Baseline

-- Setup the test case 
DROP TABLE t purge;
 
TABLE dropped.
 
CREATE TABLE t(n NOT NULL) 
AS 
SELECT object_id 
FROM   all_objects;
 
TABLE created.
 
CREATE INDEX ind_t_n1 ON t(n);
 
INDEX created.
 
-- Check the default plan
 
SELECT * 
FROM   t 
WHERE  n > 0;
 
        N
----------
        18
        32
         :
     74921
 
68822 ROWS selected.
 
 
 SELECT * FROM TABLE(dbms_xplan.display_cursor());
 
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------
SQL_ID  fgumtf1strwxa, child NUMBER 0
-------------------------------------
SELECT * FROM t WHERE n > 0
 
Plan hash VALUE: 2498539100
--------------------------------------------------------------------------
| Id  | Operation         | Name | ROWS  | Bytes | Cost (%CPU)| TIME     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |       |       |    42 (100)|          |
|*  1 |  TABLE ACCESS FULL| T    | 68822 |   336K|    42  (29)| 00:00:01 |
--------------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
   1 - FILTER("N">0)
 
-- The default plan is a full tables scan But we wanted 
-- an index range scan instead of the full tables scan
-- In order to get the plan we want we need to start by
-- creating a SQL plan baselines for original non-hinted SQL
-- statement and we will need the SQL_ID for that.
 
 SELECT sql_id, sql_fulltext
 FROM   v$sql
 WHERE  sql_text LIKE 'SELECT * FROM t WHERE %';
 
SQL_ID        SQL_FULLTEXT
------------- -------------------------------
fgumtf1strwxa SELECT * FROM t WHERE n > 0
 
 
 DECLARE
    cnt NUMBER;
 BEGIN
    cnt := sys.dbms_spm.load_plans_from_cursor_cache(sql_id=>'fgumtf1strwxa');
 END;
 /
 
PL/SQL PROCEDURE successfully completed.
 
-- Quick check in dba_sql_plan_baseline to confirm the baseline exists
 
 
 SELECT b.sql_handle, b.sql_text, b.plan_name, b.enabled
 FROM   dba_sql_plan_baselines b, v$sql s
 WHERE  s.sql_id='fgumtf1strwxa'
 AND    s.exact_matching_signature = b.signature;
 
SQL_HANDLE           SQL_TEXT                       PLAN_NAME                      ENA
-------------------- ------------------------------ ------------------------------ ---
SQL_79c1d14a660634eb SELECT * FROM t WHERE n > 0    SQL_PLAN_7mhfj99m0cd7b94ecae5c YES
 
 
 -- The full table scan plan is not the plan we want, so lets disable this plan
 
DECLARE
  cnt NUMBER;
BEGIN
  cnt := sys.dbms_spm.alter_sql_plan_baseline(
               sql_handle=>'SQL_79c1d14a660634eb', 
               plan_name=>'SQL_PLAN_7mhfj99m0cd7b94ecae5c', 
               attribute_name=>'enabled', attribute_value=>'NO');
END;
/
 
PL/SQL PROCEDURE successfully completed.
 
 SELECT b.sql_handle, b.sql_text, b.plan_name, b.enabled
 FROM   dba_sql_plan_baselines b, v$sql s
 WHERE  s.sql_id='fgumtf1strwxa'
 AND    s.exact_matching_signature = b.signature;
 
SQL_HANDLE           SQL_TEXT                       PLAN_NAME                      ENA
-------------------- ------------------------------ ------------------------------ ---
SQL_79c1d14a660634eb SELECT * FROM t WHERE n > 0    SQL_PLAN_7mhfj99m0cd7b94ecae5c NO
 
 
 -- At this point even though the full table scan plan is disabled it's still going to be used
 -- because we haven't given the optimizer an alternative yet
 
 -- Now we need to run the original SQL text with an INDEX hint to force the plan we want
 
 SELECT /*+ INDEX(t) */ * 
FROM    t 
WHERE   n > 0;
 
         N
----------
         2
         3
         4
         5
         :
     75047
 
68822 ROWS selected.
 
 
 SELECT * FROM TABLE(dbms_xplan.display_cursor());
 
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------
SQL_ID  7n3uxkxg626tj, child NUMBER 0
-------------------------------------
SELECT /*+ INDEX(t) */ * FROM t WHERE n > 0
 
Plan hash VALUE: 3190934474
-----------------------------------------------------------------------------
| Id  | Operation        | Name     | ROWS  | Bytes | Cost (%CPU)| TIME     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |          |       |       |   165 (100)|          |
|*  1 |  INDEX RANGE SCAN| IND_T_N1 | 68822 |   336K|   165   (8)| 00:00:01 |
-----------------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
   1 - access("N">0)
 
 
-- Great, we now have the plan we want but we don't want a hint in the SQL
-- We need to find the SQL_ID &amp; PLAN_HASH_VALUE for hinted SQL stmt in V$SQL
 
SELECT sql_id, plan_hash_value, sql_fulltext
FROM   v$sql
WHERE  sql_text LIKE 'SELECT /*+ INDEX(t) */ * FROM t WHERE %';
 
SQL_ID        PLAN_HASH_VALUE SQL_FULLTEXT
------------- --------------- -----------------------------------------------
7n3uxkxg626tj      3190934474 SELECT /*+ INDEX(t) */ * FROM t WHERE n > 0
 
-- Now lets add the hinted plan to the non-hinted SQL stmts SQL plan baseline
-- Using the SQL_ID and PLAN_HASH_VALUE of the hinted SQL stmt we can add
-- the hinted plan to the SQL plan baseline of the non-hinted stmt using its
-- SQL_HANDLE
 
DECLARE
 cnt NUMBER;
BEGIN
 cnt := sys.dbms_spm.load_plans_from_cursor_cache(
               sql_id=>'7n3uxkxg626tj', 
               plan_hash_value=>'3190934474', 
               sql_handle=>'SQL_79c1d14a660634eb');
END;
/
 
PL/SQL PROCEDURE successfully completed.
 
-- if we check DBA_SQL_PLAN_BASELINES we now see two plans for our non-hinted 
-- SQL stmt, the full table scan, which is disabled and the new hinted plan
 
 SELECT b.sql_handle, b.sql_text, b.plan_name, b.enabled
  2  FROM   dba_sql_plan_baselines b, v$sql s
  3  WHERE  s.sql_id='fgumtf1strwxa'
  4  AND    s.exact_matching_signature = b.signature;
 
SQL_HANDLE           SQL_TEXT                       PLAN_NAME                      ENA
-------------------- ------------------------------ ------------------------------ ---
SQL_79c1d14a660634eb SELECT * FROM t WHERE n > 0    SQL_PLAN_7mhfj99m0cd7b94ecae5c NO
SQL_79c1d14a660634eb SELECT * FROM t WHERE n > 0    SQL_PLAN_7mhfj99m0cd7bbe31cbca YES
 
 
 -- Lets now check the index plan is actually used
 
EXPLAIN PLAN FOR
SELECT *
FROM   t
WHERE  n > 0;
 
Explained.
 
 SELECT * FROM TABLE(dbms_xplan.display());
 
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------
Plan hash VALUE: 3190934474
-----------------------------------------------------------------------------
| Id  | Operation        | Name     | ROWS  | Bytes | Cost (%CPU)| TIME     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |          | 68822 |   336K|   165   (8)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IND_T_N1 | 68822 |   336K|   165   (8)| 00:00:01 |
-----------------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
   1 - access("N">0)
Note
-----
   - SQL plan baseline "SQL_PLAN_7mhfj99m0cd7bbe31cbca" used FOR this statement
 
-- So, there you have it. The SQL plan baseline is used and it is using the ENABLED
-- index range scan plan. 
-- Over time if a new plan is found for this statement, it will be added to the baseline
-- and it can be adopted if it proves to be better than the existing hinted plan.
Adding a hint via a SQL Patch

An alternative approach to adding a SQL plan baseline, would be to add a hint via a SQL Patch. A SQL patch is a SQL manageability object that can be generated by the SQL Repair Advisor, in order to circumvent a plan which causes a failure.  In essence, a SQL patch tells the optimizer to change the plan in some way or other, so that the failure does not occur.

-- Setup the test case 
 
DROP TABLE t purge;
 
TABLE dropped.
 
CREATE TABLE t(n NOT NULL) 
AS 
SELECT object_id 
FROM   all_objects;
 
TABLE created.
 
CREATE INDEX ind_t_n1 ON t(n);
 
INDEX created.
 
-- Check the default plan
 
EXPLAIN PLAN FOR
SELECT * 
FROM   t 
WHERE  n > 0;
 
Explained.
 
SELECT * FROM TABLE(dbms_xplan.display());
 
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------
 
-----------------------------------------------------------------------
| Id | Operation        | Name | ROWS | Bytes | Cost (%CPU)| TIME     |
-----------------------------------------------------------------------
| 0 | SELECT STATEMENT  |      | 70187 | 891K|     42 (29) | 00:00:01 |
|* 1 | TABLE ACCESS FULL|   T  | 70187 | 891K|     42 (29) | 00:00:01 |
-----------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
1 - FILTER("N">0)
 
-- But we wanted an index range scan instead of the full tables scan
-- Lets create a SQL Patch containing our index hint to force the plan we want
 
DECLARE
   patch_name varchar2(100);
BEGIN
   patch_name := sys.dbms_sqldiag.create_sql_patch(
                 sql_text=>'select * from t where n > 0', 
                 hint_text=>'INDEX(@"SEL$1" "T")', 
                 name=>'TEST_PATCH');
END;
/
 
PL/SQL PROCEDURE successfully completed.
 
-- Now that the SQL Patch exists lets check the execution plan again to see if 
-- our index hint is being used and the plans has changed
 
EXPLAIN PLAN FOR 
SELECT * 
FROM   t 
WHERE  n > 0;
 
Explained.
 
SELECT * FROM TABLE(dbms_xplan.display());
 
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------
Plan hash VALUE: 3190934474
 
---------------------------------------------------------------------------
| Id | Operation       | Name     |  ROWS | Bytes | Cost (%CPU)| TIME     |
---------------------------------------------------------------------------
| 0 | SELECT STATEMENT |          | 70187 |  891K |    166 (8) | 00:00:01 |
|* 1 | INDEX RANGE SCAN| IND_T_N1 | 70187 |  891K |    166 (8) | 00:00:01 |
---------------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
1 - access("N".0)
 
Note
-----
- SQL patch "TEST_PATCH" used FOR this statement
 
-- So now we have the plan we want the note section under the plan shows 
-- we are using a SQL Patch.
So now you have two different methods for getting the plan you want without adding hints directly into the application!

