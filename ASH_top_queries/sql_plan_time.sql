select
  COUNT(1),
 SQL_PLAN_HASH_VALUE ,
SQL_PLAN_LINE_ID,
 SQL_PLAN_OPERATION,
 SQL_PLAN_OPTIONS  ,
      SQL_ID
from v$active_session_history
where sql_id = '&sql_id'
group by
 SQL_PLAN_HASH_VALUE ,
SQL_PLAN_LINE_ID,
 SQL_PLAN_OPERATION,
 SQL_PLAN_OPTIONS  ,
             SQL_ID
order by SQL_PLAN_LINE_ID
/


Enter value for sql_id: 04znkpg8vqmks

  COUNT(1) SQL_PLAN_HASH_VALUE SQL_PLAN_LINE_ID SQL_PLAN_OPERATION             SQL_PLAN_OPTIONS               SQL_ID
---------- ------------------- ---------------- ------------------------------ ------------------------------ -------------
         3          4177104827                7 TABLE ACCESS                   BY INDEX ROWID                 04znkpg8vqmks
         2          4177104827               10 SORT                           UNIQUE                         04znkpg8vqmks
         3          4177104827               11 UNION ALL PUSHED PREDICATE                                    04znkpg8vqmks
         1          4177104827               12 NESTED LOOPS                                                  04znkpg8vqmks
         1          4177104827               14 TABLE ACCESS                   BY INDEX ROWID                 04znkpg8vqmks
         1          4177104827               15 INDEX                          UNIQUE SCAN                    04znkpg8vqmks
         1          4177104827               16 TABLE ACCESS                   BY INDEX ROWID                 04znkpg8vqmks
         1          4177104827               19 INDEX                          RANGE SCAN                     04znkpg8vqmks
         3          4177104827               26 VIEW                                                          04znkpg8vqmks
         1          4177104827               27 SORT                           UNIQUE                         04znkpg8vqmks
        62          4177104827               28 BITMAP AND                                                    04znkpg8vqmks
       293          4177104827               29 BITMAP CONVERSION              FROM ROWIDS                    04znkpg8vqmks
       567          4177104827               30 SORT                           ORDER BY                       04znkpg8vqmks
       209          4177104827               31 INDEX                          RANGE SCAN                     04znkpg8vqmks
       914          4177104827               32 BITMAP CONVERSION              FROM ROWIDS                    04znkpg8vqmks
       451          4177104827               33 INDEX                          RANGE SCAN                     04znkpg8vqmks
      1454          4177104827               34 BITMAP CONVERSION              FROM ROWIDS                    04znkpg8vqmks
       594          4177104827               35 INDEX                          RANGE SCAN                     04znkpg8vqmks
