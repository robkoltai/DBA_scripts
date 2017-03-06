
-- instance cache transfer
-- melyik tartott sokaig.
-- Ucso sor
SELECT instance ||'->' || inst_id transfer,
class,
cr_block cr_blk,
TRUNC(cr_block_time /cr_block/1000,2) avg_Cr,
current_block cur_blk,
TRUNC(current_block_time/current_block/1000,2) avg_cur
FROM gv$instance_cache_transfer
WHERE cr_block >0 AND current_block>0
ORDER BY instance, inst_id, class
/


-- Itt pl. instance 3
TRANS CLASS CR_BLK AVG_CR CUR_BLK AVG_CUR
----- ------------------ ---------- ---------- ---------- ----------
1->2 data block 87934887 1.23 9834152 1.8
2->1 data block 28392332 1.30 1764932 2.1
...
3->1 data block 12519985 11.57 2231921 	21.6
...
3->2 undo block 4676398 8.85 320 	27.82