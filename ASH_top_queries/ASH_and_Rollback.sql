
1)
Rollback honnan látszik?
Delete utasítás, ami megelőzi a ROLLBACK-et: ASH.SQL_OPNAME=DELETE
Rollback-je azonos session-ben: ASH.TOP_LEVEL_CALL_NAME=ROLLBACK;  ASH.SQL_OPNAME=<null>            
https://docs.oracle.com/database/121/REFRN/GUID-69CEA3A1-6C5E-43D6-982C-F353CD4B984C.htm#REFRN30299


2)
smon ROLLBACK ASH-ban nem BACKGROUND 
(Ez vajon bug? Szerintem igen.)
Ha background filter benne van akkor no rows returned.

select * from dba_hist_active_sess_history
where sample_time> to_date('20200211 06:40','YYYYMMDD HH24:MI') 
   -- and session_type = 'BACKGROUND'
   and program like '%SMON%'
   and qc_session_id = 2491 and qc_session_serial#=1
order by sample_time asc;
