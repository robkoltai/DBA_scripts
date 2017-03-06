-- TOP SQL without cursor_sharing
-- https://savvinov.com/2012/05/29/where-awr-cant-help-identifying-top-sql-in-absence-of-cursor-sharing/
/*
sql_id — in this case, it won’t uniquely identify the SQL statement, because the reports shows performance statistics by force_matching_signature (i.e. aggregating over different sql_id’s)
num_versions — the number of distinct sql_id’s
sql_text — truncated text of the SQL statement
cpu_seconds — number of CPU seconds
cpus_taken — number of CPU seconds per elapsed time (i.e. how many CPUs were kept busy by this query on the average — for serial queries this number won’t be greater than 1)

The report groups statements by force_matching_signature, but if force_matching_signature=0 (as e.g. for PL/SQL calls) it uses sql_text instead.
*/

set linesize 180
set pagesize 9999
column sql_id format a15
column num_versions format 999999
column sql_text format a70
column cpu_seconds format 999999999.99
column cpus_taken format 999.99
column pct_db_cpu alias "% DB CPU" format 99.99
column executions format 999999
 
with btime as (select begin_interval_time time from dba_hist_snapshot where snap_id = &&bsnap),
 etime as (select end_interval_time time from dba_hist_snapshot where snap_id = &&esnap),
 diff as (select (select time from etime) - (select time from btime) diff from dual),
 elapsed as (select 24*60*60*extract(day from diff) + 60*60*extract(hour from diff)+60*extract(minute from diff)+extract(second from diff) seconds from diff),
 osstat as (select value num_cpus from DBA_HIST_OSSTAT where snap_id = &&esnap and stat_name= 'NUM_CPUS')
select i2.*
from
(
    select inline.sql_id,
             num_versions,
             inline.cpu/1e6 cpu_seconds,
             (100*(case total.cpu when 0 then null else inline.cpu/total.cpu end)) pct_db_cpu,
             executions,
             inline.cpu/1e6/elapsed.seconds cpus_taken,
             dbms_lob.substr(replace(replace(sql_text, chr(10), ' '), chr(13)), 200) sql_text
    from
        elapsed,
        osstat,
    (
            select decode(force_matching_signature, 0, dbms_lob.substr(replace(replace(sql_text, chr(10), ' '), chr(13)), 100), force_matching_signature) signature, min(st.sql_id) sql_id, sum(cpu_time_delta) cpu, count(distinct st.sql_id) num_versions, sum(executions_delta) executions
            from dba_hist_sqlstat st,
                    dba_hist_sqltext txt
            where st.sql_id = txt.sql_id
            and snap_id between &&bsnap and &&esnap
            group by decode(force_matching_signature, 0, dbms_lob.substr(replace(replace(sql_text, chr(10), ' '), chr(13)), 100), force_matching_signature)
    ) inline,
    (select sum(cpu) cpu from (select snap_id, (value-lag(value) over (partition by stat_name order by snap_id)) cpu from dba_hist_SYS_TIME_MODEL where stat_name = 'DB CPU' ) where snap_id between &&bsnap and &&esnap) total,
    dba_hist_sqltext txt
    where inline.sql_id = txt.sql_id
) i2
order by cpu_seconds desc;