-- With this method you may read histogram high and low values that
-- are present in user_tab_columns in RAW
-- https://jonathanlewis.wordpress.com/2006/11/29/low_value-high_value/

create or replace function raw_to_num(i_raw raw)
return number
as
    m_n number;
begin
    dbms_stats.convert_raw_value(i_raw,m_n);
    return m_n;
end;
/  
 
create or replace function raw_to_date(i_raw raw)
return date
as
    m_n date;
begin
    dbms_stats.convert_raw_value(i_raw,m_n);
    return m_n;
end;
/  
 
create or replace function raw_to_varchar2(i_raw raw)
return varchar2
as
    m_n varchar2(20);
begin
    dbms_stats.convert_raw_value(i_raw,m_n);
    return m_n;
end;
/ 
 
 
 
set timing off
create or replace function hist_chartonum(p_vc varchar2
                                         ,p_trunc varchar2 :='Y') return number
is
m_vc varchar2(15) := substr(rpad(p_vc,15,chr(0)),1,15);
m_n number := 0;
begin
  for i in 1..15 loop
/*  dbms_output.put(ascii(substr(m_vc,i,1)));
    dbms_output.put(chr(9));
    dbms_output.put_Line(to_char( power(256,15-i) * ascii(substr(m_vc,i,1)),
                                '999,999,999,999,999,999,999,999,999,999,999,999'
                                 )
                        ); */
    m_n := m_n + power(256,15-i) * ascii(substr(m_vc,i,1));
  end loop;
-- this converts it from a 36 digit number to the 15-digit number used
-- in the ENDPOINT_VALUE Column.
  If p_trunc = 'Y' then
    m_n := round(m_n, -21);
  end if;
-- dbms_output.put_line(to_char(m_n,'999,999,999,999,999,999,999,999,999,999,999,999'));
return m_n;
end;
/
 
create or replace function hist_numtochar(p_num number
                                         ,p_trunc varchar2 :='Y') return varchar2
is
  m_vc varchar2(15);
  m_n number :=0;
  m_n1 number;
  m_loop number :=7;
begin
m_n :=p_num;
if length(to_char(m_n)) < 36 then
--dbms_output.put_line ('input too short');
  m_vc:='num format err';
else
  if p_trunc !='Y' then
    m_loop :=15;
  end if;
--dbms_output.put_line(to_char(m_N,'999,999,999,999,999,999,999,999,999,999,999,999'));
  for i in 1..m_loop loop
    m_n1:=trunc(m_n/(power(256,15-i)));
--    dbms_output.put_line(to_char(m_n1));
    if m_n1!=0 then m_vc:=m_vc||chr(m_n1);
    end if;
    dbms_output.put_line(m_vc);
    m_n:=m_n-(m_n1*power(256,15-i));  
  end loop;
end if;
return m_vc;
end;
/
create or replace function hist_numtochar2(p_num number
                                         ,p_trunc varchar2 :='Y') return varchar2
is
  m_vc varchar2(15);
  m_n number :=0;
  m_n1 number;
  m_loop number :=7;
begin
m_n :=p_num;
if length(to_char(m_n)) < 36 then
--dbms_output.put_line ('input too short');
  m_vc:='num format err';
else
  if p_trunc !='Y' then
    m_loop :=15;
  else
   m_n:=m_n+power(256,9);
  end if;
--dbms_output.put_line(to_char(m_N,'999,999,999,999,999,999,999,999,999,999,999,999'));
  for i in 1..m_loop loop
    m_n1:=trunc(m_n/(power(256,15-i)));
--    dbms_output.put_line(to_char(m_n1));
    if m_n1!=0 then m_vc:=m_vc||chr(m_n1);
    end if;
    dbms_output.put_line(m_vc);
    m_n:=m_n-(m_n1*power(256,15-i));  
  end loop;
end if;
return m_vc;
end;
/ 
 
column  column_name format a20
column  low_value format a20
column  high_value format a20
select 
        column_name,
        decode(data_type,
                'VARCHAR2',to_char(raw_to_varchar2(low_value)),
                'DATE',to_char(raw_to_date(low_value)),
                'NUMBER',to_char(raw_to_num(low_value))
        ) low_value,
        decode(data_type,
                'VARCHAR2',to_char(raw_to_varchar2(high_value)),
                'DATE',to_char(raw_to_date(high_value)),
                'NUMBER',to_char(raw_to_num(high_value))
        ) high_value
from user_tab_columns 
where table_name='T';
/*
colname              LOW_VALUE            HIGH_VALUE
-------------------- -------------------- --------------------
N                    0                    2
V                    A                    C
D                    18-SEP-19            20-SEP-19
*/


https://mwidlake.wordpress.com/2009/09/03/
-- Without those functions high and low value 
-- This is not ok for dates
select
 column_name
,num_distinct num_dist
,decode(data_type,'NUMBER',to_char(utl_raw.cast_to_number(low_value))
                 ,'VARCHAR2',to_char(utl_raw.cast_to_varchar2(low_value))
                 ,          low_value
       ) low_value
,decode(data_type,'NUMBER',to_char(utl_raw.cast_to_number(high_value))
                 ,'VARCHAR2',to_char(utl_raw.cast_to_varchar2(high_value))
                 ,          high_value
       ) high_value
,num_nulls    n_nulls
,num_buckets  n_buck
,avg_col_len  avg_l
from dba_tab_columns
where table_name ='T'
and owner=USER
order by owner,column_id
;
/*
colname   NUM_DIST LOW_VALUE            HIGH_VALUE              N_NULLS     N_BUCK      AVG_L
------- ---------- -------------------- -------------------- ---------- ---------- ----------
N                3 0                    2                             0          3          3
V                3 A                    C                             0          3          2
D                3 78770912010101       78770914010101                0          3          8
*/

set lines 180
column  column_name format a20
column  low_value format a20
column  high_value format a20
column  endpoint_number format a20
column  endpoint_value format 999999999999999999999999999999999999
column  act_val format a20
column  act_val_raw format a20
column  endpoint_repeat_count format a20
column column_name form a7 head colname
column rowcount form 99,999
column real_val form a17
column end_val form 999999999999999999999999999999999999
column end_string form a10
column endpoint_actual_value form a40
column mod_real form a17
column table_name form a10
select 
  dth.table_name
 ,dth.column_name
 ,dth.endpoint_value  end_val
 ,dth.endpoint_number rowcount
 ,decode(dtc.data_type,'NUMBER',to_char(dth.endpoint_value)
                     ,'VARCHAR2',hist_numtochar(dth.endpoint_value+1)
                     ,dth.endpoint_value
 ) real_val
 ,decode(dtc.data_type,'NUMBER',to_char(dth.endpoint_value)
                     ,'VARCHAR2',hist_numtochar2(dth.endpoint_value+1)
                     ,dth.endpoint_value
 ) mod_real
 ,endpoint_actual_value
from dba_tab_histograms dth
    ,dba_tab_columns dtc
where dth.table_name ='T'
  and  dth.owner=USER
  and dth.owner=dtc.owner
  and dth.table_name=dtc.table_name
  and dth.column_name=dtc.column_name
order by dth.table_name,dth.column_name,dth.endpoint_number
;
/*
TABLE_NAME colname                               END_VAL ROWCOUNT REAL_VAL          MOD_REAL          ENDPOINT_ACTUAL_VALUE
---------- ------- ------------------------------------- -------- ----------------- ----------------- ----------------------------------------
T          D                                     2458745      333 2458745           2458745
T          D                                     2458746      666 2458746           2458746
T          D                                     2458747      999 2458747           2458747
T          N                                           0      333 0                 0                 0
T          N                                           1      666 1                 1                 1
T          N                                           2      999 2                 2                 2
T          V        337499295804764000000000000000000000      333 A                A
T          V        342691592663299000000000000000000000      666 B                B
T          V        347883889521833000000000000000000000      999 B                 C

*/

----------------
-- TEST table
----------------
create table t (n number, v varchar2(10), d date);

insert into t  
select 
 mod(level,3),
 chr(65+mod(level,3)),
 trunc(sysdate)+ mod(level,3)
from dual
connect by level<1000
;

exec dbms_stats.gather_table_stats(USER,'T', method_opt=>'FOR COLUMNS SIZE 5 N V D' );


