
-- Set topnsql back to default
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (null,null,'DEFAULT',null);
select dbid, topnsql from dba_hist_wr_control;
exec dbms_workload_repository.create_snapshot();
