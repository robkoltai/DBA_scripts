/**********************************************************************
 * File:        awr_parm_changes.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        23Nov09
 *
 * Description:
 *      SQL*Plus script to display parameter changes as recorded by AWR.
 *
 * Modifications:
 *      TGorman 23Nov09 adapted from older "sp_parm_changes.sql" script
 *********************************************************************/
set echo off feedback off timing off pagesize 100 linesize 130 trimout on trimspool on
col snap_time format a20 heading "Snap Time"
col instance_number format 990 heading "SID"
col snap_id heading "Snap ID"
col name format a30 heading "Name"
col old_value format a15 heading "Old Value"
col new_value format a15 heading "New Value"
col diff format a15 heading "Numeric|Difference"

col instance_name new_value V_INSTANCE noprint
select instance_name from v$instance;
accept V_NBR_DAYS prompt "Please enter the number of days to report upon: "

spool awr_parm_changes_&&V_INSTANCE
select  to_char(s.begin_interval_time, 'DD-MON-YYYY HH24:MI:SS') snap_time,
        p.instance_number,
        p.snap_id,
        p.name,
        p.old_value,
        p.new_value,
	decode(trim(translate(p.new_value,'0123456789','          ')),'',
		trim(to_char(to_number(p.new_value)-to_number(p.old_value),'999999999999990')),'') diff
from    (select dbid,
                instance_number,
                snap_id,
                parameter_name name,
                lag(trim(lower(value)))
                        over (partition by dbid,
                                           instance_number,
                                           parameter_name
                              order by snap_id) old_value,
                trim(lower(value)) new_value,
                decode(nvl(lag(trim(lower(value))) over
                                (partition by   dbid,
                                                instance_number,
                                                parameter_name
                                 order by snap_id), trim(lower(value))),
                        trim(lower(value)),  '~NO~CHANGE~',
                                trim(lower(value))) diff
         from   dba_hist_parameter)             p,
        dba_hist_snapshot                       s
where   s.begin_interval_time between trunc(sysdate - &&V_NBR_DAYS) and sysdate
and     p.dbid = s.dbid
and     p.instance_number = s.instance_number
and     p.snap_id = s.snap_id
and     p.diff <> '~NO~CHANGE~'
order by snap_time, instance_number;
spool off
