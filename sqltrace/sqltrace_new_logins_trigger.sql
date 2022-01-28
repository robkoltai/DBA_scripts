drop trigger my_USER_TRACE_TRG;


-- This trigger works also on RAC environments
-- as session and tracing is done always locally
CREATE OR REPLACE TRIGGER my_USER_TRACE_TRG
AFTER LOGON ON DATABASE
declare
  mysid number;
  myserial number;
BEGIN
  IF USER in ( 'CONNTEST','BIABCP_REPOS', 'BIABCP_APPL')
  THEN
    -- Get sid
    select min(sid) 
    into mysid 
    from v$mystat;

    -- Get serial
    SELECT min(SERIAL#)
    into myserial
    FROM V$SESSION
    WHERE AUDSID = Sys_Context('USERENV', 'SESSIONID') 
	  and sid=mysid;

  -- Start traceing
  dbms_monitor.session_trace_enable(mysid,myserial, true);
   
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;
/
