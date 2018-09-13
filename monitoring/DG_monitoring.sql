-- Apply lemaradasanak monitorozasa 
-- 11.2.0.2 és magasabb verziokon
-- Apply lag-et figyeli, azonban
-- sajnos az ertek 0 es 1 perc között inog 3 masodperces lepesekkel még sync transport es real time apply eseten is.
-- Ugyanis 
--          scn_to_timestamp(current_scn): 3 masodperccel lepked
--          scn_to_timestamp(applied_scn): percenkent frissul
-- Primary oldalon futtatando
column  archive_lag format a12
select curr-app apply_lag, sysdate, curr, app , 
       (select value from v$parameter where name='archive_lag_target') archive_lag
from (
  select scn_to_timestamp(current_scn) curr,
         scn_to_timestamp(applied_scn) app
  from v$archive_dest, v$database where dest_id=2)
;

-- Synch redo transport
SELECT FREQUENCY, DURATION FROM 
 V$REDO_DEST_RESP_HISTOGRAM WHERE DEST_ID=2 AND FREQUENCY>1;

SELECT max(DURATION) FROM V$REDO_DEST_RESP_HISTOGRAM -
 WHERE DEST_ID=2 AND FREQUENCY>1;

 Perform the following query on a redo source database to display the fastest response time for destination 2:

SELECT min( DURATION) FROM V$REDO_DEST_RESP_HISTOGRAM -
WHERE DEST_ID=2 AND FREQUENCY>1;