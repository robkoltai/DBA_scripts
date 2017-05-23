-- Apply lemaradasanak monitorozasa
-- 11.2.0.2 és magasabb verziokon
-- Apply lag-et figyeli, azonban
-- sajnos az ertek 0 es 1 perc között inog 3 masodperces lepesekkel még sync transport es real time apply eseten is.
-- Ugyanis
--          scn_to_timestamp(current_scn): 3 masodperccel lepked
--          scn_to_timestamp(applied_scn): percenkent frissul
-- Primary oldalon futtatando

alter session set nls_timestamp_format='YYYYMMDD HH24:MI:SS';

column  apply_lag format a35
column  curr format a35
column  app format a35
column  archive_lag format a12
select curr-app apply_lag, sysdate, curr, app ,
       (select value from v$parameter where name='archive_lag_target') archive_lag
from (
  select scn_to_timestamp(current_scn) curr,
         scn_to_timestamp(applied_scn) app
  from v$archive_dest, v$database where dest_id=2)
; 

APPLY_LAG                           SYSDATE           CURR                                APP                                 ARCHIVE_LAG
----------------------------------- ----------------- ----------------------------------- ----------------------------------- ------------
+000000000 04:55:11.000000000       20170523 14:33:48 20170523 14:33:48                   20170523 09:38:37                   0


