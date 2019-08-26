

alter system set fixed_date = '20110203 14:00';

select to_char(sysdate,'YYYYMMDD HH24:MI:SS') from dual;

create or replace procedure advance_sysdate_by_sec as 
  d_date date;
  d_v2 varchar2(50);
  d_fixed_date_set number;
begin
 -- aktualis date megnovelve
 select sysdate+5/24/60/60, to_char(sysdate+5/24/60/60,'YYYYMMDD HH24:MI:SS') 
 into d_date, d_v2
 from dual;
  
 -- be van allitva a parameter?
 select count(1) 
 into d_fixed_date_set
 from v$parameter where name = 'fixed_date' and value is not null;
 
 -- Ha be van allitva noveljuk
 if d_fixed_date_set =1 
 then 
   execute immediate 'alter system set fixed_date =''' || d_v2 || '''';
 end if;
end; 
/


select to_char(sysdate,'YYYYMMDD HH24:MI:SS') from dual;


BEGIN
  DBMS_SCHEDULER.create_job (
     job_name        => 'ADVANCE_SYSDATE_JOB',
     job_type => 'STORED_PROCEDURE',
     job_action => 'ADVANCE_SYSDATE_BY_SEC',	 
     repeat_interval => 'FREQ=SECONDLY;INTERVAL=5',
     enabled       => TRUE,
     comments      => 'Fixed date advancer');
END;
/

exec DBMS_SCHEDULER.drop_job ('ADVANCE_SYSDATE_JOB');

