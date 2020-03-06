create table t_source as select * from dba_objects;
insert into t_source select * from t_source;
insert into t_source select * from t_source;
commit;

create table t2 as select * from t_source where 1=2;


INSERT /*+APPEND PARALLEL(i,2)*/ into T2 i SELECT * FROM t_source s;




SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
/




SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
  3  /
Enter value for sql:
old   2:    DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
new   2:    DBMS_XPLAN.DISPLAY_CURSOR('', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
SQL_ID  b6au4dv9rk9n7, child number 0
-------------------------------------
INSERT /*+APPEND PARALLEL(i,2)*/ into T2 i SELECT * FROM t_source s

Plan hash value: 1919908316

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                        | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Reads  | Writes |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                 |          |      1 |        |       |   399 (100)|          |      0 |00:00:04.44 |   41724 |      4 |   5710 |       |       |          |
|   1 |  LOAD AS SELECT                  | T2       |      1 |        |       |            |          |      0 |00:00:04.44 |   41724 |      4 |   5710 |  2070K|  2070K| 2070K (0)|
|   2 |   OPTIMIZER STATISTICS GATHERING |          |      1 |  73465 |  9470K|   399   (1)| 00:00:01 |    293K|00:00:00.41 |    8078 |      4 |      0 |   256K|   256K|          |
|   3 |    TABLE ACCESS FULL             | T_SOURCE |      1 |  73465 |  9470K|   399   (1)| 00:00:01 |    293K|00:00:00.07 |    5783 |      0 |      0 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / S@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"INS$1")
      FULL(@"INS$1" "I"@"INS$1")
      FULL(@"SEL$1" "S"@"SEL$1")
      END_OUTLINE_DATA
  */

Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 1 (U - Unused (1))
---------------------------------------------------------------------------

   0 -  INS$1 / I@INS$1
         U -  PARALLEL(i,2)

Note
-----
   - dynamic statistics used: statistics for conventional DML

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[INS$1]]></n><f><h><t><![CDATA[I]]></t><s><![CDATA[INS$1]]></s></h></f></q>
  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[S]]></t><s><![CDATA[SEL$1]]></s></h></f></q>


commit;
create table t5 as select * from t_source where 1=2;
INSERT /*+APPEND PARALLEL(i,2) NO_GATHER_OPTIMIZER_STATISTICS */ into T5 i SELECT * FROM t_source s;

SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
/


SQL_ID  8bq29qrnjfcs0, child number 0
-------------------------------------
INSERT /*+APPEND PARALLEL(i,2) NO_GATHER_OPTIMIZER_STATISTICS */ into
T5 i SELECT * FROM t_source s

Plan hash value: 1919908316

-------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Writes |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT   |          |      1 |        |       |   399 (100)|          |      0 |00:00:03.86 |   39493 |   5710 |       |       |          |
|   1 |  LOAD AS SELECT    | T5       |      1 |        |       |            |          |      0 |00:00:03.86 |   39493 |   5710 |  2070K|  2070K| 2070K (0)|
|   2 |   TABLE ACCESS FULL| T_SOURCE |      1 |  73465 |  9470K|   399   (1)| 00:00:01 |    293K|00:00:00.06 |    5738 |      0 |       |       |          |
-------------------------------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / S@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      OUTLINE_LEAF(@"INS$1")
      FULL(@"INS$1" "I"@"INS$1")
      FULL(@"SEL$1" "S"@"SEL$1")
      END_OUTLINE_DATA
  */

Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 1 (U - Unused (1))
---------------------------------------------------------------------------

   0 -  INS$1 / I@INS$1
         U -  PARALLEL(i,2)

Note
-----
   - dynamic statistics used: statistics for conventional DML

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[INS$1]]></n><f><h><t><![CDATA[I]]></t><s><![CDATA[INS$1]]></s></h></f></q>
  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[S]]></t><s><![CDATA[SEL$1]]></s></h></f></q>



55 rows selected.

SQL>





truncate table t2;
INSERT /*+APPEND PARALLEL(i,2) NO_GATHER_OPTIMIZER_STATISTICS */ into T2 i SELECT * FROM t_source s;
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
/


SQL>   2    3  Enter value for sql: old   2:    DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
new   2:    DBMS_XPLAN.DISPLAY_CURSOR('', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
SQL_ID  am4hfxhwcn6jt, child number 0
-------------------------------------
INSERT /*+APPEND PARALLEL(i,2) NO_GATHER_OPTIMIZER_STATISTICS */ into
T2 i SELECT * FROM t_source s

Plan hash value: 1919908316

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name     | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Reads  | Writes |  OMem |  1Mem | Used-Mem |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT   |          |      1 |        |       |  1584 (100)|          |      0 |00:00:01.42 |   13422 |      2 |   5710 |       |       |          |
|   1 |  LOAD AS SELECT    | T2       |      1 |        |       |            |          |      0 |00:00:01.42 |   13422 |      2 |   5710 |  2070K|  2070K| 2070K (0)|
|   2 |   TABLE ACCESS FULL| T_SOURCE |      1 |    293K|    36M|  1584   (1)| 00:00:01 |    293K|00:00:00.06 |    5738 |      0 |      0 |       |       |          |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------


truncate table t2;
commit;

INSERT /*+APPEND PARALLEL(i,2)*/ into T2 i SELECT * FROM t_source s;
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
/
truncate table t2;

INSERT /*+APPEND PARALLEL(i,2) NO_GATHER_OPTIMIZER_STATISTICS */ into T2 i SELECT * FROM t_source s;
SELECT * FROM table (
   DBMS_XPLAN.DISPLAY_CURSOR('&sql', NULL, 'ADVANCED ALLSTATS LAST -PROJECTION -ADAPTIVE'))
/
