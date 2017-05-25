rem FULL TABLE SCAN
rem Script:     seg_scan.sql
rem Author:     Jonathan Lewis
rem Dated:      Dec 2005
rem Purpose:
rem
rem Last tested
rem     10.2.0.1
rem Not tested
rem     11.2.0.1
rem     11.1.0.6
rem Not relevant
rem      9.2.0.6
rem      8.1.7.4
rem
rem Notes:
rem Identifying objects subject to tablescans
rem or index fast full scans.
rem
rem v$segstat is the more efficient, but less
rem informative - you have to join interesting
rem looking objects to dba_objects etc.
rem
rem v$segment_statistics is more informative,
rem but more expensive to run.
rem
rem Hard-coded for statistic# 17, but this could
rem vary with version - so always check against
rem v$segstat_name (or check the text column)
rem
rem Other stats were available in 9i, the segment
rem scan only appeared in 10 (possibly 10.2)
rem
 
set linesize 156
set trimspool on
set pagesize 60
 
spool seg_scan
 
select
        statistic#,
        name
from
        v$segstat_name
;
 
select
        obj#,
        dataobj#,
        value
from
        v$segstat
where
        statistic# = 17
and     value != 0
order by
    value
;
 
break on owner skip 1
 
select
        owner, object_type, object_name,
        subobject_name, tablespace_name,
        value scans
from
        V$segment_statistics
where
        statistic_name = 'segment scans'
and     value != 0
order by
    owner, value
;
 
spool off