-- What is in the cursor cache?
-- OPEN CURSOR a cached cursor-okat mutatja
select c.user_name, c.sid, sql.sql_text
from v$open_cursor c, v$sql sql
where c.sql_id=sql.sql_id  -- for 9i and earlier use: c.address=sql.address
;


--First, compare the number of cached cursors (session cursor cache count) with the value-
--of the initialization parameter session_cached_cursors.
--IF session cursor cache count < session_cached_cursors, akkor nincs ertelme javitani

set lines 1111
column name format a30
select * from (
 SELECT ss.sid, sn.name, ss.value
 FROM v$statname sn, v$sesstat ss
 WHERE sn.statistic# = ss.statistic#
 AND sn.name IN ('session cursor cache hits',
 'session cursor cache count',
 'parse count (total)')
) pivot (sum(value) as cnt for name in ('parse count (total)'as parse,'session cursor cache hits' as hit,'session cursor cache count' as cached_cursors) )
order by parse_cnt desc ;


/*
sid		parse_cnt	hit_cnt	cached_cursors_cnt
1085	100044		235143	50
1128	95185		95794	49
819		92089		123032	2
1037	81906		82220	2
614		77400		78088	1



*/
 

 
-- Second, using the additional figures, it is possible to check how many parse calls were
-- optimized because of cached cursors (session cursor cache hits) relative to the total number
-- of parses (parse count (total)).


--Ezen tul:
--http://www.orafaq.com/node/758



-- BUGOK
https://antognini.ch/2013/08/the-broken-statistics-parse-count-total-and-session-cursor-cache-hits/




-- seesion cached cursors and cursor_sharing force
interaction with cursor_sharing
July 10, 2003 - 12:45 pm UTC

Reviewer: Scott from Chicago, IL USA

We have a vendor whose scripting tools don't allow bind variables. To offset this we've created a logon trigger that alters the session to set cursor_sharing to FORCE for this particular user. Would we also benefit from giving them a non-zero number of session_cached_cursors? The docs for cursor_sharing 

</code> http://download-west.oracle.com/docs/cd/B10501_01/server.920/a96536/ch131.htm#1015593 <code>

state that "FORCE -- Forces statements that may differ in some literals, but are otherwise identical, to share a cursor, unless the literals affect the meaning of the statement." However, this doesn't really tell me whether there are soft parses that we can mitigate with session_cached_cursors. 

Many thanks, 
Scott 

Tom Kyte
Followup  

July 10, 2003 - 2:24 pm UTC 

the two work well together actually -- if you are using one, the other almost demands to be used!  Consider:



ops$tkyte@ORA920> alter session set cursor_sharing=force;

Session altered.

ops$tkyte@ORA920> exec runStats_pkg.rs_start;

PL/SQL procedure successfully completed.

ops$tkyte@ORA920> alter session set session_cached_cursors=0;

Session altered.

ops$tkyte@ORA920> declare
  2          l_cursor sys_refcursor;
  3  begin
  4          for i in 1 .. 10000
  5          loop
  6                  open l_cursor for 'select * from dual where dummy = ''' || i || '''';
  7                  close l_cursor;
  8          end loop;
  9  end;
 10  /

PL/SQL procedure successfully completed.

ops$tkyte@ORA920> exec runStats_pkg.rs_middle;

PL/SQL procedure successfully completed.

ops$tkyte@ORA920> alter session set session_cached_cursors=100;

Session altered.

ops$tkyte@ORA920> declare
  2          l_cursor sys_refcursor;
  3  begin
  4          for i in 1 .. 10000
  5          loop
  6                  open l_cursor for 'select * from dual where dummy = ''' || i || '''';
  7                  close l_cursor;
  8          end loop;
  9  end;
 10  /

PL/SQL procedure successfully completed.

ops$tkyte@ORA920>
ops$tkyte@ORA920> exec runStats_pkg.rs_stop(100)
Run1 ran in 388 hsecs
Run2 ran in 268 hsecs
run 1 ran in 144.78% of the time

Name                                  Run1        Run2        Diff
STAT...Elapsed Time                    398         277        -121
LATCH.SQL memory manager worka         134           0        -134
STAT...redo size                    65,192      64,920        -272
STAT...session cursor cache hi           1       9,999       9,998
LATCH.shared pool                   30,067      10,109     -19,958
LATCH.library cache pin             40,058      20,065     -19,993
LATCH.library cache pin alloca      40,026          22     -40,004
LATCH.library cache                 80,088      30,112     -49,976
STAT...session pga memory                0      65,536      65,536

Run1 latches total versus runs -- difference and pct
Run1        Run2        Diff       Pct
193,684      63,495    -130,189    305.04%

PL/SQL procedure successfully completed. 
