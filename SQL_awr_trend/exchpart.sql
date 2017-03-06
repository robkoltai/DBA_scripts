/*****************************************************************************
 * File:	exchpart.sql
 * Date:	18may04
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Description:
 *
 *	PL/SQL package to manage the manipulation of partitions that occur
 *	during a typical ETL process using EXCHANGE PARTITION.
 *
 *
 * Usage: PREPARE procedure
 *
 *	exchpart.prepare( -
 *		in_owner=>'{owner-name}', -
 *		in_table=>'{table-name}', -
 *		in_prefix=>'{phrase}', -
 *		in_day=>{date-value}, -
 *		in_degree=>1, -
 *		in_debug=>{TRUE|FALSE})
 *
 * where:
 *
 *	in_owner	name of the schema which owns the partitioned table
 *	in_table	name of the table from which a partition will be "shuffled
 *			out" to create a temporary table
 *	in_prefix	a free-format string to be used in naming the temporary table
 *	in_day		date value of partitions to be shuffled
 *	in_degree	degree of parallelism for CREATE TABLE AS SELECT
 *			command
 *	in_debug	defaults to FALSE; when TRUE causes the procedure to
 *			only generate and display the DDL commands, but not
 *			execute them...
 *
 * Usage: FINISH procedure
 *
 *	exchpart.finish( -
 *		in_owner=>'{owner-name}', -
 *		in_table=>'{table-name}', -
 *		in_prefix=>'{phrase}', -
 *		in_day=>{date-value}, -
 *		in_degree=>1, -
 *		in_debug=>{TRUE|FALSE})
 *
 * where:
 *
 *	in_owner	name of the schema which owns the partitioned table
 *	in_table	name of the table for which a set of
 *			partitions will be "shuffled out" to a temporary table...
 *	in_prefix	xxx
 *	in_day		date value of partitions to be shuffled
 *	in_degree	degree of parallelism for CREATE INDEX command
 *	in_debug	defaults to FALSE; when TRUE causes the procedure to
 *			only generate and display the DDL commands, but not
 *			execute them...
 *
 * Usage: ADD_NEWER_THAN procedure
 *
 *	exchpart.add_newer_than( -
 *		in_owner=>'{owner-name}', -
 *		in_table=>'{table-name}', -
 *		in_days=>{number-of-days-from-today}, -
 *		in_debug=>{TRUE|FALSE})
 *
 * where:
 *
 *	in_owner	name of the schema which owns the partitioned table
 *	in_table	name of the table to add partitions to
 *	in_days		number of days from today to add partitions for
 *	in_debug	defaults to FALSE; when TRUE causes the procedure to
 *			only generate and display the DDL commands, but not
 *			execute them...
 *
 * Usage: DROP_OLDER_THAN procedure
 *
 *	exchpart.drop_older_than( -
 *		in_owner=>'{owner-name}', -
 *		in_table=>'{table-name}', -
 *		in_days=>{number-of-days-from-today}, -
 *		in_debug=>{TRUE|FALSE})
 *
 * where:
 *
 *	in_owner	name of the schema which owns the partitioned table
 *	in_table	name of the table to add partitions to
 *	in_days		number of days from today to keep partitions for;
 *			all partitions older than that will be dropped...
 *	in_debug	defaults to FALSE; when TRUE causes the procedure to
 *			only generate and display the DDL commands, but not
 *			execute them...
 *              
 * Usage: VERSION function
 *              
 *	select exchpart.version from dual;
 *
 *	Displays current version of the package.
 *
 *
 * Modifications:
 *
 ****************************************************************************/
set echo on feedback on timing on

spool exchpart

show user
show release

set termout off
create or replace package exchpart
as
	--
	procedure prepare
		(in_owner in varchar2,
		 in_table in varchar2,
		 in_prefix in varchar2,
		 in_day in date,
		 in_degree in integer default 1,
		 in_debug in boolean default FALSE);
	--
	procedure finish
		(in_owner in varchar2,
		 in_table in varchar2,
		 in_prefix in varchar2,
		 in_day in date,
		 in_degree in integer default 1,
		 in_debug in boolean default FALSE);
	--
	procedure add_newer_than
		(in_owner in varchar2,
		 in_table in varchar2,
		 in_days in number,
		 in_debug in boolean default FALSE);
	--
	procedure drop_older_than
		(in_owner in varchar2,
		 in_table in varchar2,
		 in_days in number,
		 in_debug in boolean default FALSE);
	--
	function version return varchar2;
	--
end exchpart;
/
set termout on
show errors

set termout off
create or replace package body exchpart
as
--
/*************************************************************
 * Public procedure PREPARE
 ************************************************************/
procedure prepare
	(in_owner in varchar2,
	 in_table in varchar2,
	 in_prefix in varchar2,
	 in_day in date,
	 in_degree in integer default 1,
	 in_debug in boolean default FALSE)
is
	--
	cursor get_partition_info(in_own in varchar2, in_tbl in varchar2)
	is
	select		high_value,
			high_value_length,
			partition_name,
			tablespace_name,
			partition_position
	from		all_tab_partitions
	where		table_owner = in_own
	and		table_name = in_tbl
	order by	partition_position asc;
        --
        cursor get_part_columns(in_own in varchar2, in_tbl in varchar2)
        is
        select          column_name
        from            all_part_key_columns
        where		owner = in_own
        and		name = in_tbl
        and             object_type = 'TABLE'
        order by        column_position asc;
        --
        cursor get_subpart_columns(in_own in varchar2, in_tbl in varchar2)
        is
        select          column_name
        from            all_subpart_key_columns
        where           owner = in_own
        and             name = in_tbl
        and             object_type = 'TABLE'
        order by        column_position asc;
	--
	v_subpartitioning_type		all_part_tables.subpartitioning_type%type;
	v_def_subpartition_count	all_part_tables.def_subpartition_count%type;
	v_tablespace_name		all_tab_partitions.tablespace_name%type;
	v_partition_name		all_tab_partitions.partition_name%type;
        v_part_col_list                 varchar2(200) := '';
        v_subpart_col_list              varchar2(200) := '';
	v_high_value			varchar2(200);
	v_day				date;
	type cType			is ref cursor;
	c				cType;
	--
	v_errcontext			varchar2(300);
	v_errmsg			varchar2(600);
	v_save_module			varchar2(48);
	v_save_action			varchar2(32);
	--
begin
--
/*
 * Register the program's MODULE and ACTION using the DBMS_APPLICATION_INFO package
 * and, if requested, enable PL/SQL profiling using the DBMS_PROFILER package...
 */
v_errcontext := 'register the procedure with DBMS_APPLICATION_INFO';
dbms_application_info.read_module(v_save_module, v_save_action);
dbms_application_info.set_module('EXCHPART.PREPARE', 'Starting');
--
/*
 * Retrieve table subpartitioning information from USER_PART_TABLES...
 */
v_errcontext := 'query all_part_tables';
dbms_application_info.set_action(v_errcontext);
select	subpartitioning_type,
	def_subpartition_count
into	v_subpartitioning_type,
	v_def_subpartition_count
from	all_part_tables
where	owner = in_owner
and	table_name = in_table;
--
/*
 * Retrieve the name of the range partition-key column...
 */
v_errcontext := 'open/fetch get_part_columns';
dbms_application_info.set_action(v_errcontext);
for x in get_part_columns(in_owner, in_table) loop
        --
        if v_part_col_list is null then
                v_part_col_list := x.column_name;
        else
                v_part_col_list := v_part_col_list || ',' || x.column_name;
        end if;
        --
        v_errcontext := 'fetch/close get_part_columns';
        --
end loop;
--
/*
 * If the source table is subpartitioned, then retrieve
 * the name of the hash/list subpartition-key column...
 */
if v_subpartitioning_type in ('HASH','LIST') then
        --
        v_errcontext := 'open/fetch get_subpart_columns';
        dbms_application_info.set_action(v_errcontext);
        for x in get_subpart_columns(in_owner, in_table) loop
                --
                if v_subpart_col_list is null then
                        v_subpart_col_list := x.column_name;
                else
                        v_subpart_col_list := v_subpart_col_list || ',' || x.column_name;
                end if;
                --
                v_errcontext := 'fetch/close get_subpart_columns';
                --
        end loop;
        --
end if;
--
/*
 * Retrieve the date value associated with the partition with the
 * highest date-value...
 */
v_errcontext := 'open/fetch get_partition_info';
dbms_application_info.set_action(v_errcontext);
for p in get_partition_info(in_owner, in_table) loop
	--
	v_errcontext := 'preparing HIGH_VALUE string';
	v_high_value := substr(p.high_value, 1, p.high_value_length);
	v_errcontext := 'select ' || v_high_value || ' from dual';
	open c for v_errcontext;
	fetch c into v_day;
	close c;
	--
	/*
	 * Create a copy of the partition in the "target" table as a standalone
	 * "temporary" table...
	 */
	if v_day <= trunc(in_day+1) then
		--
		v_tablespace_name := p.tablespace_name;
		v_partition_name := p.partition_name;
		--
	end if;
	--
	v_errcontext := 'fetch/close get_partition_info';
	--
end loop;
--
/*
 * Validate that we successfully identified the relevant partition
 * using the specified date as criteria...
 */
if v_partition_name is null then
	--
	raise_application_error(-20000, to_char(in_day,'DD-MON-YYYY')||
		' does not correspond to a partition in '||in_table);
	--
end if;
--
/*
 * First, make sure that the "temporary" table does not
 * exist...
 */
v_errcontext := 'drop table '||in_prefix||in_table;
dbms_application_info.set_action(v_errcontext);
dbms_output.put_line('SQL: '||v_errcontext);
if in_debug = FALSE then
	begin
		execute immediate v_errcontext;
	exception when others then null;
	end;
end if;
--
/*
 * Then, create the "temporary" table as an exact duplicate
 * of the relevant partition in the "target" table...
 *
 * If the "target" table is composite-partitioned, then each
 * partition within is itself either a hash-partitioned or
 * list-partitioned object.  Therefore, to match the relevant
 * partition, the "temporary" table that is created must
 * also be a hash- or list-partitioned object...
 *
 * If the "target" table is simply a range-, hash-, or list-
 * partitioned table (with no subpartitioning), then each
 * partition within is simply a non-partitioned object, so
 * the "temporary" table must also be created as a non-partitioned
 * object...
 */
if v_subpartitioning_type = 'HASH' then
	--
	v_errcontext :=
		'create table '||in_prefix||in_table||
		' tablespace '||v_tablespace_name||' parallel '||in_degree||
		' partition by '||v_subpartitioning_type||'('||v_subpart_col_list||')'||
		' partitions '||v_def_subpartition_count||
		' as select /*+ full(x) parallel(x,'||in_degree||') */ * from '||
			in_table||' partition ('||v_partition_name||') x';
	--
elsif v_subpartitioning_type = 'LIST' then
	--
	v_errcontext :=
		'create table '||in_prefix||in_table||
		' tablespace '||v_tablespace_name||' parallel '||in_degree||
		' partition by '||v_subpartitioning_type||'('||v_subpart_col_list||')'||
		' as select /*+ full(x) parallel(x,'||in_degree||') */ * from '||
			in_table||' partition ('||v_partition_name||') x';
	--
else /* "temporary" table should not be partitioned */
	--
	v_errcontext :=
		'create table '||in_prefix||in_table||
		' tablespace '||v_tablespace_name||' parallel '||in_degree||
		' as select /*+ full(x) parallel(x,'||in_degree||') */ * from '||
			in_table||' partition ('||v_partition_name||') x';
	--
end if;
--
dbms_application_info.set_action(v_errcontext);
dbms_output.put_line('SQL: '||v_errcontext);
if in_debug = FALSE then
	execute immediate v_errcontext;
end if;
--
/*
 * Last, if the "calling user" is not the "owning user", then
 * make sure that the calling user has SELECT, INSERT, UPDATE,
 * and DELETE permissions on the "temporary" table...
 */
if in_owner <> user then
	--
	v_errcontext := 'grant select,insert,update,delete on '||
			in_prefix||in_table||' to '||user;
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('SQL: '||v_errcontext);
	if in_debug = FALSE then
		execute immediate v_errcontext;
	end if;
	--
end if;
--
v_errcontext := 'restore previous MODULE and ACTION values';
dbms_application_info.set_module(v_save_module, v_save_action);
--
exception
	when others then
		v_errmsg := substr(sqlerrm,1,500);
		dbms_application_info.set_module(v_save_module, v_save_action);
		raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end prepare;
--
/*************************************************************
 * Public procedure FINISH
 ************************************************************/
procedure finish
	(in_owner in varchar2,
	 in_table in varchar2,
	 in_prefix in varchar2,
	 in_day in date,
	 in_degree in integer default 1,
	 in_debug in boolean default FALSE)
is
	--
	cursor get_partition_info(in_own in varchar2, in_tbl in varchar2)
	is
	select		high_value,
			high_value_length,
			partition_name,
			partition_position
	from		all_tab_partitions
	where		table_owner = in_own
	and		table_name = in_tbl
	order by	partition_position asc;
	--
	cursor get_local_indexes(in_own in varchar2, in_tbl in varchar2, in_part_pos in number)
	is
	select		p.index_name,
			p.tablespace_name
	from		all_ind_partitions	p,
			all_part_indexes	i
	where		i.owner = in_own
	and		i.table_name = in_tbl
	and		i.locality = 'LOCAL'
	and		p.index_name = i.index_name
	and		p.partition_position = in_part_pos
	order by	i.index_name;
	--
	cursor get_local_index_columns(in_own in varchar2, in_tbl in varchar2, in_idx in varchar2)
	is
	select		column_name
	from		all_ind_columns
	where		table_owner = in_own
	and		table_name = in_tbl
	and		index_name = in_idx
	order by	column_position asc;
	--
	cursor get_pk_uk(in_own in varchar2, in_tbl in varchar2)
	is
	select	decode(constraint_type, 'P', 'primary', 'unique') constraint_type,
		constraint_name,
		decode(constraint_type, 'P', 'pk_', 'uk'||trim(to_char(rownum))||'_') pre_prefix
	from	all_constraints
	where	owner = in_own
	and	table_name = in_tbl
	and	constraint_type in ('P', 'U')
	order by decode(constraint_type, 'P', 0, 100), constraint_name;
	--
	cursor get_fk(in_own in varchar2, in_tbl in varchar2)
	is
	select	constraint_name
	from	all_constraints
	where	owner = in_own
	and	table_name = in_tbl
	and	constraint_type = 'R'
	order by constraint_name;
	--
	cursor get_cons_columns(in_own in varchar2, in_tbl in varchar2, in_cons in varchar2)
	is
	select	column_name
	from	all_cons_columns
	where	owner = in_own
	and	table_name = in_tbl
	and	constraint_name = in_cons
	order by position;
	--
	v_partition_name		all_tab_partitions.partition_name%type;
	v_partition_position		all_tab_partitions.partition_position%type;
	v_high_value			varchar2(500);
	v_col_list			varchar2(512);
	v_day				date;
	type cType			is ref cursor;
	c				cType;
	--
	v_errcontext			varchar2(300);
	v_errmsg			varchar2(600);
	v_save_module			varchar2(48);
	v_save_action			varchar2(32);
	--
begin
--
/*
 * Register the program's MODULE and ACTION using the DBMS_APPLICATION_INFO package
 * and, if requested, enable PL/SQL profiling using the DBMS_PROFILER package...
 */
v_errcontext := 'register the procedure with DBMS_APPLICATION_INFO';
dbms_application_info.read_module(v_save_module, v_save_action);
dbms_application_info.set_module('EXCHPART.FINISH', 'Starting');
--
/*
 * Retrieve the date value associated with the partition with the
 * highest date-value...
 */
v_errcontext := 'open/fetch get_partition_info';
dbms_application_info.set_action(v_errcontext);
for p in get_partition_info(in_owner, in_table) loop
	--
	v_errcontext := 'preparing HIGH_VALUE string';
	v_high_value := substr(p.high_value, 1, p.high_value_length);
	v_errcontext := 'select ' || v_high_value || ' from dual';
	open c for v_errcontext;
	fetch c into v_day;
	close c;
	--
	if v_day <= trunc(in_day+1) then
		--
		v_partition_name := p.partition_name;
		v_partition_position := p.partition_position;
		--
	end if;
	--
	v_errcontext := 'fetch/close get_partition_info';
	--
end loop; /* end of "get_partition_info" cursor loop */
--
/*
 * Validate that we know what partition we are exchanging...
 */
if v_partition_name is null then
	--
	raise_application_error(-20000, to_char(in_day,'DD-MON-YYYY')||
		' does not correspond to a partition in '||in_table);
	--
end if;
--
/*
 * Create indexes on the "temporary" table for all LOCAL indexes
 * on the "target" table...
 */
v_errcontext := 'open/fetch get_local_indexes';
for i in get_local_indexes(in_owner, in_table, v_partition_position) loop
	--
	v_errcontext := 'open/fetch get_index_columns';
	v_col_list := null;
	for c in get_local_index_columns(in_owner, in_table, i.index_name) loop
		--
		if v_col_list is null then
			v_col_list := c.column_name;
		else
			v_col_list := v_col_list||','||c.column_name;
		end if;
		--
		v_errcontext := 'fetch/close get_index_columns';
		--
	end loop; /* end of "get_local_index_columns" cursor loop */
	--
	v_errcontext :=
		'create index '||substr(i.index_name||'_'||to_char(sysdate,'DDD'),1,30)||
		' on '||substr(in_prefix||in_table,1,30)||
			'('||v_col_list||')'||
		' tablespace '||i.tablespace_name||
		' parallel '||in_degree||
		' compute statistics';
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('SQL: '||v_errcontext);
	if in_debug = FALSE then
		execute immediate v_errcontext;
	end if;
	--
	v_errcontext := 'fetch/close get_local_indexes';
	--
end loop; /* end of "get_local_indexes" cursor loop */
--
/* 
 * If the "base" table has PRIMARY/UNIQUE constraints, then create the same
 * on the "temporary" table, but use DISABLE VALIDATE to specify that these
 * constraints are not supported by an index...
 */
v_errcontext := 'open/fetch get_pk_uk';
for k in get_pk_uk(in_owner, in_table) loop
	--
	v_col_list := null;
	v_errcontext := 'open/fetch get_cons_columns';
	for c in get_cons_columns(in_owner, in_table, k.constraint_name) loop
		--
		if v_col_list is null then
			v_col_list := c.column_name;
		else
			v_col_list := v_col_list || ',' || c.column_name;
		end if;
		--
		v_errcontext := 'fetch/close get_cons_columns';
		--
	end loop; /* end of "get_cons_columns" cursor loop */
	--
	v_errcontext := 'alter table ' || in_owner || '.' || substr(in_prefix || in_table,1,30) ||
			' add constraint ' || substr(k.pre_prefix || in_prefix || in_table, 1, 30) ||
			' ' || k.constraint_type || ' key (' || v_col_list || ') disable validate';
	--
	v_errcontext := 'fetch/close get_pk_uk';
	--
end loop; /* end of "get_pk_uk" cursor loop */
--
/* 
 * If the "base" table has any FOREIGN KEY constraints associated with it's
 * primary key, then disable them, later to be re-enabled...
 */
v_errcontext := 'open/fetch get_fk';
for k in get_fk(in_owner, in_table) loop
	--
	v_errcontext := 'alter table ' || in_owner || '.' || in_table ||
			' modify constraint ' || k.constraint_name ||
			' disable novalidate';
	--
	v_errcontext := 'fetch/close get_fk';
	--
end loop; /* end of "get_fk" cursor loop */
--
/*
 * Gather table and column statistics on the standalone "temporary" table...
 */
v_errcontext := 'begin dbms_stats.gather_table_stats('||
		' ownname=>'''||in_owner||''','||
		' tabname=>'''||in_prefix||in_table||''','||
		' estimate_percent=>NULL,'||
		' cascade=>FALSE,'||
		' method_opt=>''FOR ALL INDEXED COLUMNS SIZE SKEWONLY''); end;';
dbms_application_info.set_action(v_errcontext);
dbms_output.put_line('SQL: '||v_errcontext);
if in_debug = FALSE then
	execute immediate v_errcontext;
end if;
--
v_errcontext := 'alter table '||in_table||
		' exchange partition ' || v_partition_name ||
		' with table '||in_prefix||in_table||
		' including indexes without validation'||
		' update global indexes';
dbms_application_info.set_action(v_errcontext);
dbms_output.put_line('SQL: '||v_errcontext);
if in_debug = FALSE then
	execute immediate v_errcontext;
end if;
--
/* 
 * If the "base" table has any FOREIGN KEY constraints associated with it's
 * primary key that were disabled a few steps ago, then re-enable them...
 */
v_errcontext := 'open/fetch get_fk';
for k in get_fk(in_owner, in_table) loop
	--
	v_errcontext := 'alter table ' || in_owner || '.' || in_table ||
			' modify constraint ' || k.constraint_name ||
			' enable novalidate';
	--
	v_errcontext := 'fetch/close get_fk';
	--
end loop; /* end of "get_fk" cursor loop */
--
v_errcontext := 'restore previous MODULE and ACTION values';
dbms_application_info.set_module(v_save_module, v_save_action);
--
exception
	when others then
		v_errmsg := substr(sqlerrm,1,500);
		dbms_application_info.set_module(v_save_module, v_save_action);
		raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end finish;
--
/*************************************************************
 * Public procedure ADD_NEWER_THAN
 ************************************************************/
procedure add_newer_than(in_owner in varchar2,
			 in_table in varchar2,
			 in_days in number,
			 in_debug in boolean default FALSE)
is
        --
        cursor get_partition_info(in_own in varchar2, in_tab in varchar2)
        is
	select	high_value,
		high_value_length,
                partition_name
        from    all_tab_partitions
        where	table_owner = in_own
        and	table_name = in_tab
        order by partition_position asc;
        --
	type cType	is ref cursor;
	c		cType;
        v_add_until	date;
        v_day		date;
        v_high_day	date;
	v_high_value	varchar2(200);
        --
	v_errcontext	varchar2(300);
	v_errmsg	varchar2(600);
	v_save_module	varchar2(48);
	v_save_action	varchar2(32);
        --
begin
--
/*
 * Register the program's MODULE and ACTION using the DBMS_APPLICATION_INFO package
 * and, if requested, enable PL/SQL profiling using the DBMS_PROFILER package...
 */
v_errcontext := 'register the procedure with DBMS_APPLICATION_INFO';
dbms_application_info.read_module(v_save_module, v_save_action);
dbms_application_info.set_module('EXCHPART.ADD_NEWER_THAN', 'Starting');
--
v_add_until := trunc(sysdate + in_days);
v_high_day := to_date('01-JAN-1600','DD-MON-YYYY');
--
v_errcontext := 'open/fetch get_partition_info(' || in_table || ')';
for p in get_partition_info(in_owner, in_table) loop
        --
	v_errcontext := 'preparing HIGH_VALUE string';
	v_high_value := substr(p.high_value, 1, p.high_value_length);
	v_errcontext := 'select ' || v_high_value || ' from dual';
	open c for v_errcontext;
        fetch c into v_day;
        close c;
        --
        if v_day > v_high_day then
                --
                v_high_day := v_day;
                --
        end if;
	--
	v_errcontext := 'fetch/close get_partition_info(' || in_table || ')';
        --
end loop;
--
v_errcontext := 'initialize V_DAY for looping';
v_day := trunc(v_high_day+1);
while v_day <= v_add_until loop
	--
	declare
		v_dummy	number;
	begin
		v_errcontext := 'check to be sure that the tablespace exists';
		select	1
		into	v_dummy
		from	user_tablespaces
		where	tablespace_name = 'TA_DM_' || to_char(v_day, 'YYYYMM');
	exception
		when no_data_found then
			raise_application_error(-20000, 'Tablespace "TA_DM_' ||
				to_char(v_day, 'YYYYMM') || ' does not exist');
	end;
	--
	v_errcontext := 'alter table ' || in_table ||
		' add partition p' || ltrim(to_char(v_day,'YYYYMMDD')) ||
		' values less than (to_date(''' ||
			ltrim(to_char(v_day+1, 'YYYYMMDD')) ||
				''',''YYYYMMDD'')) tablespace ta_dm_' ||
			ltrim(to_char(v_day, 'YYYYMM'));
	dbms_application_info.set_action(v_errcontext);
	dbms_output.put_line('SQL: '||v_errcontext);
	if in_debug = FALSE then
		execute immediate v_errcontext;
	end if;
	--
	v_errcontext := 'increment V_DAY to loop again';
	v_day := trunc(v_day+1);
	--
end loop;
--
v_errcontext := 'restore previous MODULE and ACTION values';
dbms_application_info.set_module(v_save_module, v_save_action);
--
exception
        when others then
                v_errmsg := sqlerrm;
                raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end add_newer_than;
--
/*************************************************************
 * Public procedure DROP_OLDER_THAN
 ************************************************************/
procedure drop_older_than(in_owner in varchar2,
			  in_table in varchar2,
			  in_days in number,
			  in_debug in boolean default FALSE)
is
        --
        cursor get_partition_info(in_own in varchar2, in_tab in varchar2)
        is
	select	high_value,
		high_value_length,
                partition_name
        from    all_tab_partitions
        where	table_owner = in_own
        and	table_name = in_tab
        order by partition_position asc;
        --
	type cType	is ref cursor;
	c		cType;
        v_day		date;
	v_high_value	varchar2(200);
        --
	v_errcontext	varchar2(300);
	v_errmsg	varchar2(600);
	v_save_module	varchar2(48);
	v_save_action	varchar2(32);
        --
begin
--
/*
 * Register the program's MODULE and ACTION using the DBMS_APPLICATION_INFO package
 * and, if requested, enable PL/SQL profiling using the DBMS_PROFILER package...
 */
v_errcontext := 'register the procedure with DBMS_APPLICATION_INFO';
dbms_application_info.read_module(v_save_module, v_save_action);
dbms_application_info.set_module('EXCHPART.DROP_OLDER_THAN', 'Starting');
--
v_errcontext := 'open/fetch get_partition_info(' || in_table || ')';
for p in get_partition_info(in_owner, in_table) loop
        --
	v_errcontext := 'preparing HIGH_VALUE string';
	v_high_value := substr(p.high_value, 1, p.high_value_length);
	v_errcontext := 'select ' || v_high_value || ' from dual';
	open c for v_errcontext;
        fetch c into v_day;
        close c;
        --
        if v_day < (sysdate - in_days) then
                --
		v_errcontext := 'alter table ' || in_table ||
			' drop partition '|| p.partition_name;
		dbms_application_info.set_action(v_errcontext);
		dbms_output.put_line('SQL: '||v_errcontext);
		if in_debug = FALSE then
			execute immediate v_errcontext;
		end if;
                --
        end if;
	--
	v_errcontext := 'fetch/close get_partition_info(' || in_table || ')';
        --
end loop;
--
v_errcontext := 'restore previous MODULE and ACTION values';
dbms_application_info.set_module(v_save_module, v_save_action);
--
exception
        when others then
                v_errmsg := sqlerrm;
                raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end drop_older_than;
--
/*************************************************************
 * Public function VERSION
 ************************************************************/
function version return varchar2
is
begin
	return '$Header: 1.1 - 19-Mar-2007 - Tim Gorman (Evergreen Database Technologies, Inc.)';
end version;
--
end exchpart;
/
set termout on
show errors
spool off
