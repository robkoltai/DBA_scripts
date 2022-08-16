-- Get the directory grants in nice readable format

spool directory_grants.out

-- Exclude oracle schemas before 11g
define oracle_schemas1='ANONYMOUS'',''APPQOSSYS'',''AUDSYS'',''CTXSYS'',''DBSFWUSER'',''DBSNMP'',''DIP'',''DVF'',''DVSYS'',''GGSYS'',''GSMADMIN_INTERNAL'',''GSMCATUSER'',''GSMROOTUSER'',''GSMUSER'',''LBACSYS'',''MDDATA'',''MDSYS'',''OJVMSYS'',''PUBLIC'
define oracle_schemas2='OLAPSYS'',''ORACLE_OCM'',''ORDDATA'',''ORDPLUGINS'',''ORDSYS'',''OUTLN'',''REMOTE_SCHEDULER_AGENT'',''SI_INFORMTN_SCHEMA'',''SYS'',''SYS$UMF'',''SYSBACKUP'',''SYSDG'',''SYSKM'',''SYSRAC'',''SYSTEM'',''WMSYS'',''XDB'',''XS$NULL'

set lines 999
set pages 800
col privilege format a22
set trimspool on
col directory_name format a30
col grantee format a30
col directory_path format a65
select 
  pr.grantee, 
  --owner, 
  pr.table_name as directory_name,
  dd.directory_path,
  listagg(privilege, ',') within group (order by privilege) as privilege
from dba_tab_privs pr, dba_directories dd
where pr.table_name = dd.directory_name 
     and  grantee not in ('&oracle_schemas1')
  and  grantee not in ('&oracle_schemas2')  
  and type = 'DIRECTORY'
group by pr.grantee, pr.table_name, dd.directory_path
order by 1,2,3;  

GRANTEE                        DIRECTORY_NAME                 DIRECTORY_PATH                                                    PRIVILEGE
------------------------------ ------------------------------ ----------------------------------------------------------------- ----------------------
LOLOLO_ACCOUNT_KIMOS           LOLOLO_ACCOUNT_DWH_OUT         /opt/oracle/EDU/farka/lololo/dwh_out/account                      READ,WRITE
LOLOLO_APS_CART_KIMOS          LOLOLO_APS_CART_OUT            /opt/oracle/TTRAN/farka/lololo/aps_cart_out                       READ,WRITE
LOLOLO_CRM_KIMOS               LOLOLO_CRM_DWH_OUT             /opt/oracle/EDU/farka/lololo/dwh_out/crm/                         READ,WRITE
LOLOLO_CRR_KIMOS               LOLOLO_CRR_DWH_OUT             /opt/oracle/farka/lololo/dwh_out                                  READ,READ,WRITE,WRITE

