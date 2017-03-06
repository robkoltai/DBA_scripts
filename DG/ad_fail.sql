set time on
set lines 200
column error format a25
column destination format a25
column id format 999
column target format a7
column seq# format 9999
column proc format a4
column fail_date format a9
column log_sequence heading "LOG|SEQ" format 99999
column reopen_secs heading "REOP|SECS"  format 9999
column net_timeout heading "NET|T.OUT" format 9999
column FAIL_SEQUENCE heading "FAIL|SEQ" format 9999
column MAX_FAILURE heading "MAX|FAIL" format 9999
column FAILURE_COUNT heading "FAIL#" format 9999
column fail_block heading "FAIL|BLOCK"
column fail_DATE heading "FAIL|DATE"
select dest_id as id, status, log_sequence as seq#, reopen_secs, net_timeout,
 to_char(FAIL_DATE,'HH24:MI:SS') as fail_date,
 FAIL_SEQUENCE,
 FAIL_BLOCK,
 FAILURE_COUNT,
 MAX_FAILURE,
 ERROR, transmit_mode, 
 --affirm,
applied_scn
from v$archive_dest where dest_id<3;

