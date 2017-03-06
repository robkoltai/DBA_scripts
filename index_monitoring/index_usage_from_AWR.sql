/* ---------------------------------------------------------------------------
 CR/TR#  :
 Purpose : Shows index usage by execution (find problematic indexes)
 
 Date    : 22.01.2008.
 Author  : Damir Vadas, damir.vadas@gmail.com
 
 Remarks : run as privileged user
           Must have AWR run because sql joins data from there
           works on 10g >         
            
           @index_usage SCHEMA MIN_INDEX_SIZE
            
 Changes (DD.MM.YYYY, Name, CR/TR#):           
          25.11.2010, Damir Vadas
                      added index size as parameter
          30.11.2010, Damir Vadas
                      fixed bug in query
                                 
--------------------------------------------------------------------------- */
set linesize 140
set pagesize 160
 
clear breaks
clear computes
 
break on TABLE_NAME skip 2 ON INDEX_NAME ON INDEX_TYPE ON MB 
compute sum of NR_EXEC on TABLE_NAME SKIP 2
compute sum of MB on TABLE_NAME SKIP 2
 
 
SET TIMI OFF
set linesize 140
set pagesize 10000
col OWNER noprint
col TABLE_NAME for a30 heading 'Table name'
col INDEX_NAME for a25 heading 'Index name'
col INDEX_TYPE for a10 heading 'Index type'
col INDEX_OPERATION for a21 Heading 'Index operation'
col NR_EXEC for 9G999G990 heading 'Executions'
col MB for 999G990D90 Heading 'Index|Size MB' justify  right
 
        WITH Q AS (
                SELECT
                       S.OWNER                  A_OWNER, 
                       TABLE_NAME               A_TABLE_NAME, 
                       INDEX_NAME               A_INDEX_NAME, 
                       INDEX_TYPE               A_INDEX_TYPE,
                       SUM(S.bytes) / 1048576   A_MB 
                  FROM DBA_SEGMENTS S, 
                       DBA_INDEXES  I 
                 WHERE S.OWNER =  '&&1'
                   AND I.OWNER =  '&&1'
                   AND INDEX_NAME = SEGMENT_NAME
                 GROUP BY S.OWNER, TABLE_NAME, INDEX_NAME, INDEX_TYPE
                HAVING SUM(S.BYTES) > 1048576 * &&2
        )
        SELECT /*+ NO_QUERY_TRANSFORMATION(S) */
               A_OWNER                                    OWNER,
               A_TABLE_NAME                               TABLE_NAME,
               A_INDEX_NAME                               INDEX_NAME, 
               A_INDEX_TYPE                               INDEX_TYPE,
               A_MB                                       MB, 
               DECODE (OPTIONS, null, '       -',OPTIONS) INDEX_OPERATION,
               COUNT(OPERATION)                           NR_EXEC
         FROM  Q,
               DBA_HIST_SQL_PLAN d
         WHERE
               D.OBJECT_OWNER(+)= q.A_OWNER AND
               D.OBJECT_NAME(+) = q.A_INDEX_NAME 
        GROUP BY
               A_OWNER, 
               A_TABLE_NAME, 
               A_INDEX_NAME, 
               A_INDEX_TYPE, 
               A_MB, 
               DECODE (OPTIONS, null, '       -',OPTIONS)
        ORDER BY
               A_OWNER, 
               A_TABLE_NAME, 
               A_INDEX_NAME, 
               A_INDEX_TYPE, 
               A_MB DESC, 
               NR_EXEC DESC
;
 
PROMPT Showed only indexes in &&1 schema whose size > &&2 MB in period:
SET HEAD OFF;
select to_char (min(BEGIN_INTERVAL_TIME), 'DD.MM.YYYY')
       || '-' ||
       to_char (max(END_INTERVAL_TIME), 'DD.MM.YYYY')
from dba_hist_snapshot;
 
SET HEAD ON
SET TIMI ON
Script is run against "SOME_SCHEMA" and query indexes bigger then 100 MB: 
?
SQL> @index_usage SOME_SCHEMA 100