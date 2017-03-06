--First, compare the number of cached cursors (session cursor cache count) with the value-
--of the initialization parameter session_cached_cursors.
--IF session cursor cache count < session_cached_cursors, akkor nincs ertelme javitani

set lines 1111
column name format a30
SELECT ss.sid, sn.name, ss.value
 FROM v$statname sn, v$sesstat ss
 WHERE sn.statistic# = ss.statistic#
 AND sn.name IN ('session cursor cache hits',
 'session cursor cache count',
 'parse count (total)')
 --AND ss.sid = 42
 order by 1,2
 ;
 
 
-- Second, using the additional figures, it is possible to check how many parse calls were
-- optimized because of cached cursors (session cursor cache hits) relative to the total number
-- of parses (parse count (total)).


--Ezen tul:
--http://www.orafaq.com/node/758