http://kerryosborne.oracle-guy.com/2008/12/oracle-outlines-aka-plan-stability/

check_use_outlines.sql – This scripts uses oradebug to see if USE_STORED_OUTLINES has been set.
outlines.sql – This script lists all outlines and shows whether they are enabled and if they have been used.
outlines2.sql – The same as above but it also joins to the v$sqlarea view to get the sql_id for the statement (if it is currently in the shared pool). Note that this is will only return the exact match on sql_text and that outlines have a “relaxed” sql_text matching so there may be additional statements that use the outline. Note that this script uses a function called outline_signature that you’ll need to create as well.
find_sql_using_outline.sql – This script lists all statements in the shared pool that are using an outline.

create_outline.sql – This script uses the DBMS_OUTLINE.CREATE_OUTLINE procedure to create an outline for an existing cursor. 
It prompts for a sql_id, child_no, and name. 
Since the create_outline procedure uses hash_value instead of sql_id, this script has to get the hash_value first. 
Also, since the create_outline procedure doesn’t allow a name to be specified for the outline, this script renames the outline after it is created. 
Note that this script will not work in 9i because sql_id was not introduced until 10g.

outline_hints.sql – This script lists the hints associated with a given outline.
outline_startup_trigger.sql – This scripts creates an after startup database trigger that enables outline usage as per Metalink Note:560331.1.