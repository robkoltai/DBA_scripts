/**********************************************************************
 * File:        sphistory.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        15-Jul-2003
 *
 * Description:
 *	SQL*Plus script to query the "history" of a specified SQL
 *	statement, using its "hash value", in one (or more) specified
 *	database instances.  This report is useful for obtaining an
 *	hourly perspective on SQL statements seen in more aggregated
 *	reports.
 *
 * Modifications:
 *	TGorman	10aug05	added information from STATS$SQL_PLAN_USAGE
 *			to display execution plan history as well...
 *********************************************************************/
set echo off
set feedback off timing off verify off pagesize 100 linesize 130 recsep off
set serveroutput on size 1000000 format wrapped trimout on trimspool on
col snap_time format a12 truncate heading "Snapshot|Time"
col execs format 999,990 heading "Execs"
col lio_per_exec format 999,999,999,990.00 heading "Avg LIO|Per Exec"
col pio_per_exec format 999,999,999,990.00 heading "Avg PIO|Per Exec"
col cpu_per_exec format 999,999,999,990.00 heading "Avg|CPU (secs)|Per Exec"
col ela_per_exec format 999,999,999,990.00 heading "Avg|Elapsed (secs)|Per Exec"
col sql_text format a64 heading "Text of SQL statement"
clear breaks computes
ttitle off
btitle off

accept V_HASH_VALUE prompt "Enter the SQL statement hash value: "
accept V_ORACLE_SID prompt "Enter the SID of the Oracle instance (wildcard chars permitted): "

spool sphistory_&&V_HASH_VALUE

select	sql_text
from	stats$sqltext
where	hash_value = &&V_HASH_VALUE
order by text_subset, piece;

set pagesize 0 heading off
select	decode(count(*),0,'CSTATS$PLAN_TABLE DOES NOT EXIST -- PLEASE RUN SCRIPT "top_stmt4_9i.sql" TO CREATE IT', '') message
from	user_tables
where	table_name = 'CSTATS$PLAN_TABLE';
set pagesize 100 heading on

declare
	cursor get_plan_hash_value(in_hash_value in number)
	is
	select	pu.plan_hash_value,
		ss.snap_time,
		ss.snap_id
	from	stats$sql_plan_usage	pu,
		stats$snapshot		ss
	where	pu.dbid = ss.dbid
	and	pu.instance_number = ss.instance_number
	and	pu.snap_id = ss.snap_id
	and	pu.hash_value = in_hash_value
	order by ss.snap_time;
        --
	cursor get_xplan(in_plan_hv in number)
	is
	select	plan_table_output
	from	table(dbms_xplan.display('CSTATS$PLAN_TABLE', trim(to_char(in_plan_hv)), 'ALL'));
	--
	v_prev_plan_hash_value	number := -1;
	v_text_lines		number := 0;
	v_errcontext		varchar2(100);
	v_errmsg		varchar2(100);
begin
	--
	v_errcontext := 'open/fetch get_plan_hash_value';
	for phv in get_plan_hash_value(&&V_HASH_VALUE) loop
		--
		if v_prev_plan_hash_value <> phv.plan_hash_value then
			--
			v_prev_plan_hash_value := phv.plan_hash_value;
			--
			v_errcontext := 'insert into cstats$plan_table';
			insert into cstats$plan_table
			(	STATEMENT_ID,
				TIMESTAMP,
				REMARKS,
				OPERATION,
				OPTIONS,
				OBJECT_NODE,
				OBJECT_OWNER,
				OBJECT_NAME,
				OBJECT_INSTANCE,
				OBJECT_TYPE,
				OPTIMIZER,
				SEARCH_COLUMNS,
				ID,
				PARENT_ID,
				POSITION,
				COST,
				CARDINALITY,
				BYTES,
				OTHER_TAG,
				PARTITION_START,
				PARTITION_STOP,
				PARTITION_ID,
				OTHER,
				DISTRIBUTION,
				CPU_COST,
				IO_COST,
				TEMP_SPACE,
				ACCESS_PREDICATES,
				FILTER_PREDICATES)
			select	trim(to_char(p.PLAN_HASH_VALUE)),
				SYSDATE,
				'hash_value = '''||p.PLAN_HASH_VALUE||''' from STATS$SQL_PLAN',
				p.OPERATION,
				p.OPTIONS,
				p.OBJECT_NODE,
				p.OBJECT_OWNER,
				p.OBJECT_NAME,
				p.OBJECT#,
				o.OBJECT_TYPE,
				p.OPTIMIZER,
				p.SEARCH_COLUMNS,
				p.ID,
				p.PARENT_ID,
				p.POSITION,
				p.COST,
				p.CARDINALITY,
				p.BYTES,
				p.OTHER_TAG,
				p.PARTITION_START,
				p.PARTITION_STOP,
				p.PARTITION_ID,
				p.OTHER,
				p.DISTRIBUTION,
				p.CPU_COST,
				p.IO_COST,
				p.TEMP_SPACE,
				p.ACCESS_PREDICATES,
				p.FILTER_PREDICATES
			from	stats$sql_plan		p,
				stats$seg_stat_obj	o
			where	p.plan_hash_value = phv.plan_hash_value
			and	o.obj# (+) = p.object#;
			--
			v_text_lines := 0;
			v_errcontext := 'open/fetch get_xplan';
			for s in get_xplan(phv.plan_hash_value) loop
				--
				if s.plan_table_output like 'Predicate Information %' then
					exit;
				end if;
				--
				if v_text_lines = 0 then
					dbms_output.put_line('.');
					dbms_output.put_line('.  SQL execution plan from "'||
						to_char(phv.snap_time,'MM/DD/YY HH24:MI:SS') ||
						'" (snap #'||phv.snap_id||')');
				end if;
				--
				dbms_output.put_line(s.plan_table_output);
				v_text_lines := v_text_lines + 1;
				--
			end loop;
			--
			v_errcontext := 'delete from cstats$plan_table';
			delete
			from	cstats$plan_table
			where	statement_id = trim(to_char(phv.plan_hash_value));
			--
		end if;
		--
	end loop;
	--
exception
	when others then
		v_errmsg := sqlerrm;
		raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end;
/

select	to_char(s.snap_time, 'DD-MON HH24:MI') snap_time,
	ss.executions_inc execs,
	ss.buffer_gets_inc/decode(ss.executions_inc,0,1,ss.executions_inc) lio_per_exec,
	ss.disk_reads_inc/decode(ss.executions_inc,0,1,ss.executions_inc) pio_per_exec,
	ss.cpu_time_inc/decode(ss.executions_inc,0,1,ss.executions_inc) cpu_per_exec,
	ss.elapsed_time_inc/decode(ss.executions_inc,0,1,ss.executions_inc) ela_per_exec
from 	stats$snapshot						s,
	(select	ss2.dbid,
		ss2.snap_id,
		ss2.instance_number,
		nvl(decode(greatest(ss2.executions, lag(ss2.executions,1,0) over (order by ss2.snap_id)),
			   ss2.executions, ss2.executions - lag(ss2.executions,1,0) over (order by ss2.snap_id),
				ss2.executions), 0) executions_inc,
		nvl(decode(greatest(ss2.buffer_gets, lag(ss2.buffer_gets,1,0) over (order by ss2.snap_id)),
			   ss2.buffer_gets, ss2.buffer_gets - lag(ss2.buffer_gets,1,0) over (order by ss2.snap_id),
				ss2.buffer_gets), 0) buffer_gets_inc,
		nvl(decode(greatest(ss2.disk_reads, lag(ss2.disk_reads,1,0) over (order by ss2.snap_id)),
			   ss2.disk_reads, ss2.disk_reads - lag(ss2.disk_reads,1,0) over (order by ss2.snap_id),
				ss2.disk_reads), 0) disk_reads_inc,
		nvl(decode(greatest(ss2.cpu_time, lag(ss2.cpu_time,1,0) over (order by ss2.snap_id)),
			   ss2.cpu_time, ss2.cpu_time - lag(ss2.cpu_time,1,0) over (order by ss2.snap_id),
				ss2.cpu_time), 0)/1000000 cpu_time_inc,
		nvl(decode(greatest(ss2.elapsed_time, lag(ss2.elapsed_time,1,0) over (order by ss2.snap_id)),
			   ss2.elapsed_time, ss2.elapsed_time - lag(ss2.elapsed_time,1,0) over (order by ss2.snap_id),
				ss2.elapsed_time), 0)/1000000 elapsed_time_inc
	 from	stats$sql_summary				ss2,
		(select distinct	dbid,
					instance_number
		 from	stats$database_instance
		 where	instance_name like '&&V_ORACLE_SID')	i
	 where	ss2.hash_value = &&V_HASH_VALUE
	 and	ss2.dbid = i.dbid
	 and	ss2.instance_number = i.instance_number)	ss
where	s.snap_id = ss.snap_id
and	s.dbid = ss.dbid
and	s.instance_number = ss.instance_number
order by s.snap_time asc;

spool off
set verify on echo on feedback on
