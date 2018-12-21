column Thing format a30
column Path format a100
column Leaf format 99999
select
   --CONNECT_BY_ISLEAF "Leaf" , 
  miez,
  --username, 
  --lpad(' ', 2*level) || granted_role "Thing",
  SYS_CONNECT_BY_PATH(granted_role||' (' || miez||')', '=>') "Path"
from
  (
  /* THE USERS */
    select 
	  'user' miez,
	  username,
      null     grantee, 
      username granted_role
    from 
      dba_users
    where
      username like upper('%&enter_username%')
  /* THE ROLES TO ROLES RELATIONS */ 
  union
    select 
	  'rolepriv', 
	  null,
      grantee,
      granted_role
    from
      dba_role_privs
  /* THE ROLES TO PRIVILEGE RELATIONS */ 
  union
    select
	  'syspriv',
	  null,
      grantee,
      privilege
    from
      dba_sys_privs
  )
where  CONNECT_BY_ISLEAF =1
start with grantee is null
connect by grantee = prior granted_role
;