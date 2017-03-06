-- szepen kiirja plan_hash_value-t is
set lines 300
set pages 500
select * from table(dbms_xplan.DISPLAY_SQL_PLAN_BASELINE('&SQL_handle', null, 'ADVANCED'));


/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
SQL handle: SQL_5cd6d0b61a2dabdd
SQL text: with "ttfra" as (   select /*+ materialize */   --a
          ttf.TASK_TYPE_NODE_ID, ttf.ABILITY_NODE_ID, ttf.TASK_STATUS_CODE_LIST,
          ttf.function_number,     ttf.function_id,ttf.command_code,ttf.name,
          ttf.task_type_function_id,ttf.autoplay_flag, ttf.use_schedule_flag,
          ttf.use_cache_flag,     role_ability.structure_id,role_ability.parent_no
          de_number   from fd_task_type_function ttf,        nh_node_relation
          role_ability   where       task_type_node_id               = :A004
          AND role_ability.node_relation_type_code=:"SYS_B_00"   AND
          ttf.ability_node_id                 =role_ability.node_id   AND
          task_status_code_list LIKE :"SYS_B_01"     || :A005     ||:"SYS_B_02"
          ) SELECT   DISTINCT :"SYS_B_03"   ||"ttfra".task_type_function_id
          ||:"SYS_B_04"   ||use_schedule_flag "id",   :"SYS_B_05" "parent",
          "ttfra".name "ml_name",   "ttfra".function_number,
          "ttfra".task_type_function_id,   "adf".function_code function_code,
          use_schedule_flag,   use_cache_flag,   ability_node_id,
          "adf".function_id,   "ttfra".command_code "command_code",
          "ttfra".name "label",   "ttfra".autoplay_flag "autoplay_flag",
          (SELECT property_value   FROM fd_task_type_function_property   WHERE
          task_type_function_id="ttfra".task_type_function_id   AND property_id
                   = :A001   ) "conditional_ttf_expression" FROM nh_node_relation
          "role_zone",   nh_node_relation "role",   "ttfra",   ad_function "adf"
          WHERE "role_zone".node_id IN   (SELECT node_id   FROM nh_node_relation
          "zone"     START WITH node_id         = :A002   AND
          node_relation_type_code IN (:"SYS_B_06",:"SYS_B_07")     CONNECT BY
          structure_id    =prior structure_id   AND node_number
          =prior parent_node_number   AND node_relation_type_code IN
          (:"SYS_B_08",:"SYS_B_09")   ) AND "role_zone".node_relation_type_code=:"
          SYS_B_10" AND "role".structure_id
          ="role_zone".structure_id     +:"SYS_B_11" AND "role".node_number
                    ="role_zone".parent_node_number +:"SYS_B_12" AND
          "adf".function_id                  ="ttfra".function_id
          +:"SYS_B_13" AND EXISTS   (SELECT node_id   FROM nh_node_relation
          "role_group"   WHERE EXISTS     (SELECT :"SYS_B_14"     FROM
          nh_node_relation "employee_role"     WHERE "employee_role".node_id
                                                  ="role_group".node_id     AND
          "employee_role".node_relation_type_code
          =:"SYS_B_15"     AND ("employee_role".structure_id+:"SYS_B_16","employee
          _role".parent_node_number+:"SYS_B_17") IN       (SELECT
          "employee".structure_id,         "employee".node_number       FROM
          nh_node_relation "employee"       WHERE "employee".node_id  = :A003
            AND "employee".create_flag=:"SYS_B_18"       )     )     START WITH
          node_id         ="role".node_id   AND node_relation_type_code
          =:"SYS_B_19"     CONNECT BY structure_id    =prior structure_id   AND
          node_number              =prior parent_node_number   AND
          node_relation_type_code IN (:"SYS_B_20",:"SYS_B_21")   ) AND
          "ttfra".structure_id           ="role".structure_id AND
          "ttfra".parent_node_number     ="role".node_number ORDER BY
          "ttfra".function_number
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
Plan name: SQL_PLAN_5tpqhqsd2vayx285400e8         Plan id: 676593896
Enabled: YES     Fixed: NO      Accepted: NO      Origin: AUTO-CAPTURE
--------------------------------------------------------------------------------

Plan hash value: 2024149275

------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                                |     1 |   146 |    16  (19)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID                | FD_TASK_TYPE_FUNCTION_PROPERTY |     1 |    27 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN                         | PK_FD_TASK_TYPE_FUNCTION_PROP  |     1 |       |     1   (0)| 00:00:01 |
|   3 |  TEMP TABLE TRANSFORMATION                  |                                |       |       |            |          |
|   4 |   LOAD AS SELECT                            | SYS_TEMP_0FD9D66C3_411684B9    |       |       |            |          |
|   5 |    NESTED LOOPS                             |                                |     1 |    95 |     2   (0)| 00:00:01 |
|   6 |     TABLE ACCESS BY INDEX ROWID             | FD_TASK_TYPE_FUNCTION          |     1 |    56 |     1   (0)| 00:00:01 |
|*  7 |      INDEX RANGE SCAN                       | I_TUNE_TOP1_TTF_SUPER          |     1 |       |     1   (0)| 00:00:01 |
|*  8 |     INDEX RANGE SCAN                        | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|   9 |   SORT ORDER BY                             |                                |     1 |   146 |    14  (22)| 00:00:01 |
|  10 |    HASH UNIQUE                              |                                |     1 |   146 |    13  (16)| 00:00:01 |
|* 11 |     FILTER                                  |                                |       |       |            |          |
|  12 |      NESTED LOOPS                           |                                |     1 |   146 |     9  (12)| 00:00:01 |
|  13 |       MERGE JOIN CARTESIAN                  |                                |     2 |   214 |     8  (13)| 00:00:01 |
|  14 |        NESTED LOOPS                         |                                |     1 |   102 |     4   (0)| 00:00:01 |
|  15 |         NESTED LOOPS                        |                                |     1 |    89 |     3   (0)| 00:00:01 |
|  16 |          VIEW                               |                                |     1 |    65 |     2   (0)| 00:00:01 |
|  17 |           TABLE ACCESS FULL                 | SYS_TEMP_0FD9D66C3_411684B9    |     1 |    64 |     2   (0)| 00:00:01 |
|  18 |          TABLE ACCESS BY INDEX ROWID        | AD_FUNCTION                    |     1 |    24 |     1   (0)| 00:00:01 |
|* 19 |           INDEX UNIQUE SCAN                 | PK_AD_FUNCTION                 |     1 |       |     1   (0)| 00:00:01 |
|  20 |         TABLE ACCESS BY INDEX ROWID         | NH_NODE_RELATION               |     1 |    13 |     1   (0)| 00:00:01 |
|* 21 |          INDEX UNIQUE SCAN                  | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|  22 |        BUFFER SORT                          |                                |     2 |    10 |     7  (15)| 00:00:01 |
|  23 |         VIEW                                | VW_NSO_1                       |     2 |    10 |     4  (25)| 00:00:01 |
|  24 |          HASH UNIQUE                        |                                |     2 |   124 |     4  (25)| 00:00:01 |
|* 25 |           CONNECT BY WITH FILTERING (UNIQUE)|                                |       |       |            |          |
|* 26 |            INDEX RANGE SCAN                 | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    44 |     1   (0)| 00:00:01 |
|  27 |            NESTED LOOPS                     |                                |     1 |    70 |     2   (0)| 00:00:01 |
|  28 |             CONNECT BY PUMP                 |                                |       |       |            |          |
|* 29 |             TABLE ACCESS BY INDEX ROWID     | NH_NODE_RELATION               |     1 |    44 |     1   (0)| 00:00:01 |
|* 30 |              INDEX UNIQUE SCAN              | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|* 31 |       INDEX RANGE SCAN                      | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|* 32 |      FILTER                                 |                                |       |       |            |          |
|* 33 |       CONNECT BY WITH FILTERING (UNIQUE)    |                                |       |       |            |          |
|* 34 |        INDEX RANGE SCAN                     | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    44 |     1   (0)| 00:00:01 |
|  35 |        NESTED LOOPS                         |                                |     1 |    70 |     2   (0)| 00:00:01 |
|  36 |         CONNECT BY PUMP                     |                                |       |       |            |          |
|* 37 |         TABLE ACCESS BY INDEX ROWID         | NH_NODE_RELATION               |     1 |    44 |     1   (0)| 00:00:01 |
|* 38 |          INDEX UNIQUE SCAN                  | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|  39 |       NESTED LOOPS                          |                                |     1 |    55 |     2   (0)| 00:00:01 |
|  40 |        NESTED LOOPS                         |                                |     1 |    55 |     2   (0)| 00:00:01 |
|* 41 |         INDEX RANGE SCAN                    | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|* 42 |         INDEX UNIQUE SCAN                   | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|* 43 |        TABLE ACCESS BY INDEX ROWID          | NH_NODE_RELATION               |     1 |    16 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("TASK_TYPE_FUNCTION_ID"=:B1 AND "PROPERTY_ID"=TO_NUMBER(:A001))
   7 - access("TASK_TYPE_NODE_ID"=TO_NUMBER(:A004) AND "TASK_STATUS_CODE_LIST" LIKE :SYS_B_01||:A005||:SYS_B_02)
       filter("TASK_STATUS_CODE_LIST" LIKE :SYS_B_01||:A005||:SYS_B_02)
   8 - access("TTF"."ABILITY_NODE_ID"="ROLE_ABILITY"."NODE_ID" AND "ROLE_ABILITY"."NODE_RELATION_TYPE_CODE"=:SYS_B_00)
  11 - filter( EXISTS (SELECT /*+ CONNECT_BY_ELIM_DUPS CONNECT_BY_FILTERING CONNECT_BY_ELIM_DUPS */ 0 FROM
              "NH_NODE_RELATION" "role_group" WHERE  EXISTS (SELECT /*+ LEADING ("employee_role" "employee") INDEX ("employee_role"
              "I_TUNE_TOP1_SUPER_NODE_REL_V1") INDEX ("employee" "PK_NH_NODE_RELATION") USE_NL ("employee") */ 0 FROM
              "NH_NODE_RELATION" "employee_role","NH_NODE_RELATION" "employee" WHERE
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17) AND
              "employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND
              "employee"."NODE_ID"=TO_NUMBER(:A003) AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18) AND
              "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15 AND "employee_role"."NODE_ID"=:B1) START WITH "NODE_ID"=:B2 AND
              "NODE_RELATION_TYPE_CODE"=:SYS_B_19 CONNECT BY "STRUCTURE_ID"=PRIOR "STRUCTURE_ID" AND "NODE_NUMBER"=PRIOR
              "PARENT_NODE_NUMBER" AND ("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)))
  19 - access("adf"."FUNCTION_ID"="ttfra"."FUNCTION_ID"+TO_NUMBER(:SYS_B_13))
  21 - access("ttfra"."STRUCTURE_ID"="role"."STRUCTURE_ID" AND "ttfra"."PARENT_NODE_NUMBER"="role"."NODE_NUMBER")
  25 - access("STRUCTURE_ID"=PRIOR NULL AND "NODE_NUMBER"=PRIOR NULL)
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_08 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_09)
  26 - access("NODE_ID"=TO_NUMBER(:A002))
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_06 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_07)
  29 - filter("NODE_RELATION_TYPE_CODE"=:SYS_B_08 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_09)
  30 - access("STRUCTURE_ID"="connect$_by$_pump$_009"."prior structure_id   " AND
              "NODE_NUMBER"="connect$_by$_pump$_009"."prior parent_node_number   ")
  31 - access("role_zone"."NODE_ID"="NODE_ID" AND "role_zone"."NODE_RELATION_TYPE_CODE"=:SYS_B_10)
       filter("role"."STRUCTURE_ID"="role_zone"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_11) AND
              "role"."NODE_NUMBER"="role_zone"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_12))
  32 - filter( EXISTS (SELECT /*+ LEADING ("employee_role" "employee") INDEX ("employee_role"
              "I_TUNE_TOP1_SUPER_NODE_REL_V1") INDEX ("employee" "PK_NH_NODE_RELATION") USE_NL ("employee") */ 0 FROM
              "NH_NODE_RELATION" "employee_role","NH_NODE_RELATION" "employee" WHERE
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17) AND
              "employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND
              "employee"."NODE_ID"=TO_NUMBER(:A003) AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18) AND
              "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15 AND "employee_role"."NODE_ID"=:B1))
  33 - access("STRUCTURE_ID"=PRIOR NULL AND "NODE_NUMBER"=PRIOR NULL)
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)
  34 - access("NODE_ID"=:B1 AND "NODE_RELATION_TYPE_CODE"=:SYS_B_19)
  37 - filter("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)
  38 - access("STRUCTURE_ID"="connect$_by$_pump$_019"."prior structure_id   " AND
              "NODE_NUMBER"="connect$_by$_pump$_019"."prior parent_node_number   ")
  41 - access("employee_role"."NODE_ID"=:B1 AND "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15)
  42 - access("employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17))
  43 - filter("employee"."NODE_ID"=TO_NUMBER(:A003) AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18))

--------------------------------------------------------------------------------
Plan name: SQL_PLAN_5tpqhqsd2vayx7c0cb143         Plan id: 2081206595
Enabled: YES     Fixed: NO      Accepted: YES     Origin: MANUAL-LOAD
--------------------------------------------------------------------------------

Plan hash value: 2529555654

--------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                     | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                              |                                |     1 |   146 |    16  (19)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID                  | FD_TASK_TYPE_FUNCTION_PROPERTY |     1 |    27 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN                           | PK_FD_TASK_TYPE_FUNCTION_PROP  |     1 |       |     1   (0)| 00:00:01 |
|   3 |  TEMP TABLE TRANSFORMATION                    |                                |       |       |            |          |
|   4 |   LOAD AS SELECT                              | SYS_TEMP_0FD9D66C4_411684B9    |       |       |            |          |
|   5 |    NESTED LOOPS                               |                                |     1 |    95 |     2   (0)| 00:00:01 |
|   6 |     TABLE ACCESS BY INDEX ROWID               | FD_TASK_TYPE_FUNCTION          |     1 |    56 |     1   (0)| 00:00:01 |
|*  7 |      INDEX RANGE SCAN                         | I_TUNE_TOP1_TTF_SUPER          |     1 |       |     1   (0)| 00:00:01 |
|*  8 |     INDEX RANGE SCAN                          | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|   9 |   SORT ORDER BY                               |                                |     1 |   146 |    14  (22)| 00:00:01 |
|  10 |    HASH UNIQUE                                |                                |     1 |   146 |    13  (16)| 00:00:01 |
|* 11 |     FILTER                                    |                                |       |       |            |          |
|  12 |      NESTED LOOPS                             |                                |     1 |   146 |     9  (12)| 00:00:01 |
|* 13 |       HASH JOIN                               |                                |     1 |   122 |     8  (13)| 00:00:01 |
|  14 |        NESTED LOOPS                           |                                |     1 |    57 |     6  (17)| 00:00:01 |
|  15 |         NESTED LOOPS                          |                                |     1 |    57 |     6  (17)| 00:00:01 |
|  16 |          NESTED LOOPS                         |                                |     1 |    44 |     5  (20)| 00:00:01 |
|  17 |           VIEW                                | VW_NSO_1                       |     2 |    10 |     4  (25)| 00:00:01 |
|  18 |            HASH UNIQUE                        |                                |     2 |   124 |     4  (25)| 00:00:01 |
|* 19 |             CONNECT BY WITH FILTERING (UNIQUE)|                                |       |       |            |          |
|* 20 |              INDEX RANGE SCAN                 | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    44 |     1   (0)| 00:00:01 |
|  21 |              NESTED LOOPS                     |                                |     1 |    70 |     2   (0)| 00:00:01 |
|  22 |               CONNECT BY PUMP                 |                                |       |       |            |          |
|* 23 |               TABLE ACCESS BY INDEX ROWID     | NH_NODE_RELATION               |     1 |    44 |     1   (0)| 00:00:01 |
|* 24 |                INDEX UNIQUE SCAN              | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|* 25 |           INDEX RANGE SCAN                    | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|* 26 |          INDEX UNIQUE SCAN                    | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|  27 |         TABLE ACCESS BY INDEX ROWID           | NH_NODE_RELATION               |     1 |    13 |     1   (0)| 00:00:01 |
|  28 |        VIEW                                   |                                |     1 |    65 |     2   (0)| 00:00:01 |
|  29 |         TABLE ACCESS FULL                     | SYS_TEMP_0FD9D66C4_411684B9    |     1 |    64 |     2   (0)| 00:00:01 |
|  30 |       TABLE ACCESS BY INDEX ROWID             | AD_FUNCTION                    |     1 |    24 |     1   (0)| 00:00:01 |
|* 31 |        INDEX UNIQUE SCAN                      | PK_AD_FUNCTION                 |     1 |       |     1   (0)| 00:00:01 |
|* 32 |      FILTER                                   |                                |       |       |            |          |
|* 33 |       CONNECT BY WITH FILTERING (UNIQUE)      |                                |       |       |            |          |
|* 34 |        INDEX RANGE SCAN                       | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    44 |     1   (0)| 00:00:01 |
|  35 |        NESTED LOOPS                           |                                |     1 |    70 |     2   (0)| 00:00:01 |
|  36 |         CONNECT BY PUMP                       |                                |       |       |            |          |
|* 37 |         TABLE ACCESS BY INDEX ROWID           | NH_NODE_RELATION               |     1 |    44 |     1   (0)| 00:00:01 |
|* 38 |          INDEX UNIQUE SCAN                    | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|  39 |       NESTED LOOPS                            |                                |     1 |    55 |     2   (0)| 00:00:01 |
|  40 |        NESTED LOOPS                           |                                |     1 |    55 |     2   (0)| 00:00:01 |
|* 41 |         INDEX RANGE SCAN                      | I_TUNE_TOP1_SUPER_NODE_REL_V1  |     1 |    39 |     1   (0)| 00:00:01 |
|* 42 |         INDEX UNIQUE SCAN                     | PK_NH_NODE_RELATION            |     1 |       |     1   (0)| 00:00:01 |
|* 43 |        TABLE ACCESS BY INDEX ROWID            | NH_NODE_RELATION               |     1 |    16 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("TASK_TYPE_FUNCTION_ID"=:B1 AND "PROPERTY_ID"=TO_NUMBER(:A001))
   7 - access("TASK_TYPE_NODE_ID"=TO_NUMBER(:A004) AND "TASK_STATUS_CODE_LIST" LIKE :SYS_B_01||:A005||:SYS_B_02)
       filter("TASK_STATUS_CODE_LIST" LIKE :SYS_B_01||:A005||:SYS_B_02)
   8 - access("TTF"."ABILITY_NODE_ID"="ROLE_ABILITY"."NODE_ID" AND "ROLE_ABILITY"."NODE_RELATION_TYPE_CODE"=:SYS_B_00)
  11 - filter( EXISTS (SELECT /*+ CONNECT_BY_FILTERING CONNECT_BY_ELIM_DUPS CONNECT_BY_ELIM_DUPS */ 0 FROM
              "NH_NODE_RELATION" "role_group" WHERE  EXISTS (SELECT /*+ LEADING ("employee_role" "employee") INDEX ("employee_role"
              "I_TUNE_TOP1_SUPER_NODE_REL_V1") USE_NL ("employee") INDEX ("employee" "PK_NH_NODE_RELATION") */ 0 FROM
              "NH_NODE_RELATION" "employee_role","NH_NODE_RELATION" "employee" WHERE
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17) AND
              "employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND "employee"."NODE_ID"=TO_NUMBER(:A003)
              AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18) AND "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15 AND
              "employee_role"."NODE_ID"=:B1) START WITH "NODE_ID"=:B2 AND "NODE_RELATION_TYPE_CODE"=:SYS_B_19 CONNECT BY
              "STRUCTURE_ID"=PRIOR "STRUCTURE_ID" AND "NODE_NUMBER"=PRIOR "PARENT_NODE_NUMBER" AND
              ("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)))
  13 - access("ttfra"."STRUCTURE_ID"="role"."STRUCTURE_ID" AND "ttfra"."PARENT_NODE_NUMBER"="role"."NODE_NUMBER")
  19 - access("STRUCTURE_ID"=PRIOR NULL AND "NODE_NUMBER"=PRIOR NULL)
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_08 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_09)
  20 - access("NODE_ID"=TO_NUMBER(:A002))
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_06 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_07)
  23 - filter("NODE_RELATION_TYPE_CODE"=:SYS_B_08 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_09)
  24 - access("STRUCTURE_ID"="connect$_by$_pump$_009"."prior structure_id   " AND
              "NODE_NUMBER"="connect$_by$_pump$_009"."prior parent_node_number   ")
  25 - access("role_zone"."NODE_ID"="NODE_ID" AND "role_zone"."NODE_RELATION_TYPE_CODE"=:SYS_B_10)
  26 - access("role"."STRUCTURE_ID"="role_zone"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_11) AND
              "role"."NODE_NUMBER"="role_zone"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_12))
  31 - access("adf"."FUNCTION_ID"="ttfra"."FUNCTION_ID"+TO_NUMBER(:SYS_B_13))
  32 - filter( EXISTS (SELECT /*+ LEADING ("employee_role" "employee") INDEX ("employee_role"
              "I_TUNE_TOP1_SUPER_NODE_REL_V1") USE_NL ("employee") INDEX ("employee" "PK_NH_NODE_RELATION") */ 0 FROM
              "NH_NODE_RELATION" "employee_role","NH_NODE_RELATION" "employee" WHERE
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17) AND
              "employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND "employee"."NODE_ID"=TO_NUMBER(:A003)
              AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18) AND "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15 AND
              "employee_role"."NODE_ID"=:B1))
  33 - access("STRUCTURE_ID"=PRIOR NULL AND "NODE_NUMBER"=PRIOR NULL)
       filter("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)
  34 - access("NODE_ID"=:B1 AND "NODE_RELATION_TYPE_CODE"=:SYS_B_19)
  37 - filter("NODE_RELATION_TYPE_CODE"=:SYS_B_20 OR "NODE_RELATION_TYPE_CODE"=:SYS_B_21)
  38 - access("STRUCTURE_ID"="connect$_by$_pump$_019"."prior structure_id   " AND
              "NODE_NUMBER"="connect$_by$_pump$_019"."prior parent_node_number   ")
  41 - access("employee_role"."NODE_ID"=:B1 AND "employee_role"."NODE_RELATION_TYPE_CODE"=:SYS_B_15)
  42 - access("employee"."STRUCTURE_ID"="employee_role"."STRUCTURE_ID"+TO_NUMBER(:SYS_B_16) AND
              "employee"."NODE_NUMBER"="employee_role"."PARENT_NODE_NUMBER"+TO_NUMBER(:SYS_B_17))
  43 - filter("employee"."NODE_ID"=TO_NUMBER(:A003) AND "employee"."CREATE_FLAG"=TO_NUMBER(:SYS_B_18))

258 sor kijelolve.
*/