explain plan for 
select (
        SELECT SZ_CIM.QCIM
          FROM SZ_CIM
         WHERE trunc(sysdate) BETWEEN SZ_CIM.KEZD_DATE AND NVL(SZ_CIM.VEGE_DATE, trunc(sysdate))
           and rownum < 2
           AND SZ_CIM.SZ_GRID =
               (select szemely_grid
                  from s_szerep
                 where szerzodes_unid = szerzodes.unid
                   and szerep = '1'
                   and trunc(sysdate) between nvl(kezd_date, trunc(sysdate)) and nvl(vege_date, trunc(sysdate)))
           and trunc(sysdate) between nvl(kezd_date, trunc(sysdate)) and nvl(vege_date, trunc(sysdate))
       )
  from szerzodes where unid = 878805512
;

set pages 0
set lines 300

SELECT * FROM table (
   DBMS_XPLAN.display('&sql'))
/


SQL> SQL> SQL> SQL>   2    3  Enter value for sql:
old   2:    DBMS_XPLAN.display('&sql'))
new   2:    DBMS_XPLAN.display(''))

-------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name               | Rows  | Bytes | Cost (%CPU)|
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                    |     1 |     7 |    20   (0)|
|   1 |  COUNT STOPKEY                        |                    |       |       |            |
|   2 |   FILTER                              |                    |       |       |            |
|   3 |    NESTED LOOPS                       |                    |     2 |   176 |    13   (0)|
|   4 |     NESTED LOOPS                      |                    |     3 |   176 |    13   (0)|
|   5 |      NESTED LOOPS                     |                    |     3 |   222 |     5   (0)|
|   6 |       TABLE ACCESS FULL               | KUT_SZ_CIM_HIST    |    13M|   775M|     2   (0)|
|   7 |       INDEX RANGE SCAN                | AK_KUT_SZ_CIM_UNID |     2 |    30 |     3   (0)|
|   8 |      INDEX UNIQUE SCAN                | PK_KUT_SZ_CIM_GRID |     1 |       |     2   (0)|
|   9 |     TABLE ACCESS BY INDEX ROWID       | KUT_SZ_CIM_GRID    |     1 |    14 |     3   (0)|
|  10 |    TABLE ACCESS BY INDEX ROWID BATCHED| S_SZEREP           |     1 |    33 |     5   (0)|
|  11 |     INDEX RANGE SCAN                  | S_SZEREP_SZERZUNID |     1 |       |     4   (0)|
|  12 |  INDEX UNIQUE SCAN                    | PK_SZERODES        |     1 |     7 |     2   (0)|
-------------------------------------------------------------------------------------------------


Note
-----
   - 'PLAN_TABLE' is old version

OLD PLAN TABLE problem solutions
---------------------------------
1)
-- Check who has old plan table
select * from dba_objects
where object_name like 'PLAN_TA%';

-- drop table port.plan_table   
   
2)
explain plan into SYS.PLAN_TABLE$ for <your_stmt>
select * from table(dbms_xplan.display(‘SYS.PLAN_TABLE$’));



------------------- EXPLAIN WITH STATEMENT ID


explain plan 
  SET STATEMENT_ID = 'MIVAN'
for 
insert /*+ APPEND PARALLEL MONITOR */ into DM.AG_DEAL_BALANCE
(
    LOAD_ID,
    UPDATE_ID,
    CALENDAR_DATE,
	...
;

SELECT * FROM table (
  DBMS_XPLAN.DISPLAY(
    statement_id  => 'MIVAN',
    format        => 'ALL'));
