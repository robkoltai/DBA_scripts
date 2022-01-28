
-- Generate sql trace starter for existing sessions
select 'execute dbms_monitor.session_trace_enable(' || sid ||','|| serial# ||', true);' 
from gv$session
where username in ('AM2_FRAMEWORK_APPL','AM2_APAM_APPL','APAM','FRAMEWORK','','');

-- Generate sql trace stopper for existing sessions
select 'execute dbms_monitor.session_trace_disable(' || sid ||','|| serial# ||');' 
from gv$session
where username in ('AM2_FRAMEWORK_APPL','AM2_APAM_APPL','APAM','FRAMEWORK','','');
