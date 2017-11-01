select name, hint from dba_outline_hints
where name like nvl('&name',name);


/*

NAME                           HINT
------------------------------ ----------------------------------------------------------------------
OUTLINE_TEST_2                 FULL(@"SEL$1" "T"@"SEL$1")
OUTLINE_TEST_2                 OUTLINE_LEAF(@"SEL$1")
OUTLINE_TEST_2                 ALL_ROWS
OUTLINE_TEST_2                 DB_VERSION('11.2.0.3')
OUTLINE_TEST_2                 OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
OUTLINE_TEST_2                 IGNORE_OPTIM_EMBEDDED_HINTS
PUBLIC_TEST2_OK                OUTLINE_LEAF(@"SEL$1")
PUBLIC_TEST2_OK                IGNORE_OPTIM_EMBEDDED_HINTS
PUBLIC_TEST2_OK                OPTIMIZER_FEATURES_ENABLE('11.2.0.3')
PUBLIC_TEST2_OK                DB_VERSION('11.2.0.3')
PUBLIC_TEST2_OK                ALL_ROWS
PUBLIC_TEST2_OK                INDEX_RS_ASC(@"SEL$1" "T"@"SEL$1" ("T"."ID"))

12 rows selected.

*/

