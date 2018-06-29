

-- Most sleeps on latch
SELECT n.name, l.sleeps
  FROM v$latch l, v$latchname n 
  WHERE n.latch#=l.latch# and l.sleeps > 0 order by l.sleeps
;

-- no diagnostic pack, pre oracle 10
-- To see latches that are currently a problem on the database run:
SELECT n.name, SUM(w.p3) Sleeps
  FROM V$SESSION_WAIT w, V$LATCHNAME n
 WHERE w.event = `latch free'
   AND w.p2 = n.latch#
 GROUP BY n.name;
 
 
 
  
 
 
 -- scalability 11gr1, 11gr2
 http://afatkulin.blogspot.com/2010/06/11gr2-result-cache-scalability.html
 
 http://afatkulin.blogspot.com/2012/05/result-cache-latch-in-11gr2-shared-mode.html
 
 https://logicalread.com/oracle-latch-free-wait-dr01/#.Wyi5_qczaiw
 