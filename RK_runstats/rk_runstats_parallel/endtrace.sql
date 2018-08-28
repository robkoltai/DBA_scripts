begin
   DBMS_MONITOR.serv_mod_act_trace_disable (
   service_name=>'SYS$USERS',
   module_name=>'RK_RUNSTAT',
   action_name=>'&1'
   );
end;
/
