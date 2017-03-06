-- Wait event to object ASH
-- Expert Oracle RAC 12
col owner format a30
col object_name format a30
set lines 160
WITH ash_gc AS
(SELECT inst_id, event, current_obj#, COUNT(*) cnt
FROM gv$active_session_history
WHERE event=lower('&event')
GROUP BY inst_id, event, current_obj#
HAVING COUNT (*) > &threshold )
SELECT * FROM
(SELECT inst_id, nvl( owner,'Non-existent') owner ,
nvl ( object_name,'Non-existent') object_name,
nvl ( object_type, 'Non-existent') object_type,
cnt
FROM ash_gc a, dba_objects o
WHERE (a.current_obj#=o.object_id (+))
AND a.current_obj# >=1
UNION
SELECT inst_id, '', '', 'Undo Header/Undo block', cnt
FROM ash_gc a WHERE a.current_obj#=0
UNION
SELECT inst_id, '', '', 'Undo Block', cnt
Chapter 10 ¦ RAC Database Optimization
294
FROM ash_gc a
WHERE a.current_obj#=-1
)
ORDER BY cnt DESC
/

Enter value for event: gc current block 2-way
Enter value for threshold: 30
INST_ID OWNER OBJECT_NAME OBJECT_TYPE CNT
------- -------------------- -------------------------------- ------------- ----------
3 PO RCV_SHIPMENT_LINES TABLE 2228
2 PO RCV_SHIPMENT_LINES TABLE 2199
1 PO RCV_SHIPMENT_LINES TABLE 2197
3 PO PO_REQUISITION_LINES_ALL TABLE 2061
2 PO PO_REQUISITION_LINES_ALL TABLE 1985
3 Undo Block 120