 
 --http://www.orafaq.com/node/854
 select s1.username || '@' || s1.machine
    || ' ( SID=' || s1.sid || ' )  is blocking '
    || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
    from v$lock l1, v$session s1, v$lock l2, v$session s2
    where s1.sid=l1.sid and s2.sid=l2.sid
    and l1.BLOCK=1 and l2.request > 0
    and l1.id1 = l2.id1
    and l2.id2 = l2.id2 ;
    
/*
BLOCKING_STATUS
------------------------------------------------------------------------------------------------------------------------
A@WORKGROUP\EDU001 ( SID=263 )  is blocking A@WORKGROUP\EDU001 ( SID=275 )

*/
    
select s1.username || '@' || s1.machine
       || ' ( SID,SERIAL#=' || s1.sid || ',' || s1.serial# || ' )  is blocking '
       || s2.username || '@' || s2.machine || ' ( SID,SERIAL#=' || s2.sid || ',' || s2.serial#  || ' ) ' AS blocking_status,
       l1.type, l1.id1,l1.id2,l1.lmode, l1.request,
       l2.type, l2.id1,l2.id2,l2.lmode, l2.request
       from v$lock l1, v$session s1, v$lock l2, v$session s2
       where s1.sid=l1.sid and s2.sid=l2.sid
       and l1.BLOCK=1 and l2.request > 0
       and l1.id1 = l2.id1
       and l2.id2 = l2.id2 ;
       
/*
BLOCKING_STATUS
------------------------------------------------------------------------------------------------------------------------
TY        ID1        ID2      LMODE    REQUEST TY        ID1        ID2      LMODE    REQUEST
-- ---------- ---------- ---------- ---------- -- ---------- ---------- ---------- ----------
A@WORKGROUP\EDU001 ( SID,SERIAL#=263,61501 )  is blocking A@WORKGROUP\EDU001 ( SID,SERIAL#=275,61356 )
TX     524316       1242          6          0 TX     524316       1242          0          4
*/