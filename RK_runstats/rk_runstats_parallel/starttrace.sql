alter session set tracefile_identifier='&1._&2.SQLTRACE';

begin
   DBMS_MONITOR.serv_mod_act_trace_enable (
   service_name=>'SYS$USERS',
   module_name=>'RK_RUNSTAT',
   action_name=>'&1',
   waits=>TRUE, binds=>FALSE
);
end; 
/
