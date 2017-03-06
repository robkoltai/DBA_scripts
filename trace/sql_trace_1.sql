alter system set events 'sql_trace[sql:gpdmdntvzjgcr]';

alter system set events 'sql_trace[sql:gpdmdntvzjgcr] off';

/*
sql_trace wait=true | false, bind=true | false,planstat=never | first_execution | all_executions|level = 12

 I am sure all familiar with ( waits, binds, level ) .Also included are plan statistics and executions .

so this will trace specific sql_id with waits binds and statistiscs for first execution at level 12:

alter session set events 'sql_trace [sql:52k2t5z1anrac] wait=true, bind=true,plan_stat=first_execution,level=12';

alter session set events 'sql_trace [sql:a5ks9fhw2v9s1|56bs32ukywdsq]';

http://oraclue.com/2009/03/24/oracle-event-sql_trace-in-11g/



alter session set tracefile_identifier='perftest';
alter session set events 'sql_trace [sql:4tnc7zpq8b749] wait=true, bind=true,plan_stat=first_execution';
alter session set events 'sql_trace [sql:4tnc7zpq8b749] off';

*/

alter system set events 'sql_trace[sql:0crhjk0w8h0g0] wait=true, bind=true,plan_stat=all_executions';
alter system set events 'sql_trace[sql:0crhjk0w8h0g0] off';