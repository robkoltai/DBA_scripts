create or replace package      rk_grant_string_ana as

function expand_sql (p_sql clob) return clob;
function ana_one_sql (p_sql clob, p_expandit number) return clob;
procedure do_the_work;
procedure do_the_work_dist;

end rk_grant_string_ana;
/

create or replace package body rk_grant_string_ana as
function expand_sql (p_sql clob) return clob is
  v_sql clob;
begin
    DBMS_UTILITY.expand_sql_text (
        input_sql_text  => p_sql,
        output_sql_text => v_sql
    );
    return v_sql;
exception
    when others then return to_clob(sqlerrm);
end expand_sql;

function ana_one_sql (p_sql clob, p_expandit number) return clob is
  v_sql clob;
  i number;
  v_output clob;
  v_position number;
begin
    
    if p_expandit=1 then
        v_sql:=lower(expand_sql(p_sql));
    else
        v_sql:=lower(p_sql);
    end if;
    
    v_output:= null;
    v_position:= instr(v_sql,'from',1,1);
    i:=1;
    while v_position>0 loop
      v_output := v_output || substr(v_sql,v_position,80) || ' ||| ';  
      i:=i+1;
      v_position:= instr(v_sql,'from',1,i);
    end loop;

    return upper(v_output);
end ana_one_sql;




procedure do_the_work is

  cursor c_record is
    select * from RK_UNI_AUD_GROUP_RUN1
    where action_name in ('INSERT','SELECT','UPDATE','DELETE')
    --lower(substr(sql_text,1,10)) like '%select%'
    --fetch first 50 rows only
    for update of sql_from_clause, sql_from_clause_exp;

  r_record RK_UNI_AUD_GROUP_RUN1%rowtype;
  v_temp clob;
begin

  open c_record;
  loop
    fetch c_record into r_record;
    exit when c_record%notfound;
    execute immediate 'alter session set current_schema = '|| r_record.current_user;

    update RK_UNI_AUD_GROUP_RUN1
    set sql_from_clause     = ana_one_sql (r_record.sql_text,0),
        sql_from_clause_exp = ana_one_sql (r_record.sql_text_exp,0)
    where current of c_record;
 
  end loop;
 commit;
end do_the_work;






procedure do_the_work_dist is

  cursor c_record is
    select * from RK_UNI_AUD_GROUP_DIST_RUN1
    where lower(substr(min_sql_text,1,10)) like '%select%'
    --fetch first 50 rows only
    for update of min_sql_froms, max_sql_froms;

  r_record RK_UNI_AUD_GROUP_DIST_RUN1%rowtype;
  v_temp clob;
begin

  open c_record;
  loop
    fetch c_record into r_record;
    exit when c_record%notfound;
    execute immediate 'alter session set current_schema = '|| r_record.current_user;

    update RK_UNI_AUD_GROUP_DIST_RUN1
    set min_sql_froms = ana_one_sql (r_record.min_sql_text,1),
        max_sql_froms = ana_one_sql (r_record.max_sql_text,1),
        min_sql_froms_noexp = ana_one_sql (r_record.min_sql_text,0),
        max_sql_froms_noexp = ana_one_sql (r_record.max_sql_text,0)
    where current of c_record;
 
  end loop;
 commit;
end do_the_work_dist;

end;
/