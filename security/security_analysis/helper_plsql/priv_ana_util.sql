create type t_privs is table of varchar2(128);
/


create or replace package priv_ana_util as
function get_sysprivs return t_privs;
function get_unused_sysprivs return t_privs;
function get_path_info (p_grant_path sys.grant_path, p_what number) return varchar2;
end priv_ana_util;
/


create or replace package body priv_ana_util as
function get_sysprivs return t_privs is
  c number;
  i number;
  v_privs t_privs :=t_privs();
begin
  for c_paths in (select * from sys.dba_used_sysprivs_PATH where username<>used_role) loop
      --dbms_output.put_line('Row fetched...');
      FOR i IN c_paths.path.FIRST .. c_paths.path.LAST LOOP
         null;
         --dbms_output.put_line('...property fetched: '|| c_paths.path(i));
         -- It is the second in the path that we care about
         -- The first one is always the user itself
         if i = 2 then
           v_privs.extend;
           v_privs(v_privs.last) :='Revoke ' || c_paths.path(i) ||  ' from ' || c_paths.username || ';';
           --dbms_output.put_line ('Revoke ' || c_paths.path(i) ||  ' from ' || c_paths.username || ';') ;
         end if;
      END LOOP;
  end loop;
  return v_privs;
end get_sysprivs;

function get_unused_sysprivs return t_privs as
  c number;
  i number;
  v_privs t_privs :=t_privs();
begin
  for c_paths in (select * from sys.dba_UNUSED_SYSprivs_PATH where username is not null) loop
      --dbms_output.put_line('Row fetched...');
      FOR i IN c_paths.path.FIRST .. c_paths.path.LAST LOOP
         null;
         --dbms_output.put_line('...property fetched: '|| c_paths.path(i));
         -- It is the second in the path that we care about
         -- The first one is always the user itself
         if i = 2 then
           v_privs.extend;
           v_privs(v_privs.last) :='Revoke ' || c_paths.path(i) ||  ' from ' || c_paths.username || ';';
           --dbms_output.put_line ('Revoke ' || c_paths.path(i) ||  ' from ' || c_paths.username || ';') ;
         end if;
      END LOOP;
  end loop;
  return v_privs;
end get_unused_sysprivs;

function get_path_info (p_grant_path sys.grant_path, p_what number) return varchar2 as
  i number;
begin
 if p_what=0 then return p_grant_path.last; end if;
 if p_what=1 then return p_grant_path(1);  end if;
 if p_what=2 and p_grant_path.last >1 then return p_grant_path(2); end if;
 if p_what=-1 then return p_grant_path(p_grant_path.last); end if;

return null;
end get_path_info;
end priv_ana_util;
/



