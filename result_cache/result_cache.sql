SELECT dbms_result_cache.status() FROM dual;
------------
ENABLED


-- SQLs that use result cache hint from DASH
select
  sum(10) secs,
  sum(sum(10)) over () as totalsec,  
  round((sum(10)/ sum(sum(10)) over ()) *100,2) percento, 
  dash.SQL_ID, 
  event,
  case when lower(sql_text) like '%result%cache%' THEN 'RC' else null end rc_used,
  to_char(substr(sql_text,1,400)) sql_text
from dba_hist_active_sess_history dash, dba_hist_sqltext st
where dash.sql_id = st.sql_id (+) and 
  sample_time  between to_date('20180618 08:00','YYYYMMDD HH24:MI') and to_date('20180618 09:00','YYYYMMDD HH24:MI') 
group by dash.sql_id, event,   to_char(substr(sql_text,1,400)),
  case when lower(sql_text) like '%result%cache%' THEN 'RC' else null end
order by 1 desc
;

/*

2590	35490	7,3		3gy7vrp5v02f4	db file sequential read		UPDATE DWH2.FACT_SAP_RMCA_DUNNING T SET T.STATUS = 'STORNO' WHERE EXISTS (SELECT S.RMCA_DOCUMENT_NO, S.DUNNING_LEVEL FROM DWH2.FACT_SAP_RMCA_DUNNING S WHERE S.STORNO_FLAG = 'Y' AND S.LOADING_MONTH = :B1 AND T.RMCA_DOCUMENT_NO=S.RMCA_DOCUMENT_NO AND T.DUNNING_LEVEL=S.DUNNING_LEVEL) AND T.STATUS != 'STORNO'
1220	35490	3,44	744dgfgdcsrt7	SQL*Net message from dblink		select ...
920		35490	2,59					Backup: MML write backup piece		
870		35490	2,45	fkc803rs19shg	direct path read temp		INSERT INTO CHARGES_MAST WITH CHARGES_TO_DEAL AS ( SELECT ROWNUM RN, T.*, F.MASTER_ADMIN_SYSTEM FROM CHARGES T, FEE_CODES F WHERE T.SVID_MEID IS NOT NULL AND T.SVID_MEID = F.CHARGE_ID(+) AND NVL(T.VALID_TO, DATE '9999-12-31') > DATE '2011-07-01' - 1 ), CHARGE_MASTERED AS ( SELECT MIN(RN) OVER (PARTITION BY MASTER_CUSTOMER_NUMBER, SVID_MEID) MASTER_CHARGE_ID, RANK() OVER (PARTITION BY MASTER_CUSTOM
750		35490	2,11	5uvfbvrzvqaah	db file sequential read		insert into DWH2.FACT_SAP_RMCA_DUNNING partition( P_201806)
600		35490	1,69	b2d53zwcv077h			insert /*+APPEND into ETL_MHC.L_1INST_SOPF00 (SOCPNR, SOSONR, SODPSO, SOSVID, SOMEID, SOSVQT, SOOCC, SOFOCC, SODOID, SOBLNO, SOBLNA, SOFLIX, SOFLPO, SOSOST, SOSODT, SOSSDT, SOSTDT, SOSFDT, SOFNDT, SOFNRS, SOBIST, SOBIDT, SOSLID, SOSLME, SOSCID, SOMEDA, SOSTRA, SOSTRN, SOMNTA, SOMNTN, SOTRMA, SOTRMN, SOCRCY, SOCRMM, SOCRDD, SOCRTM, SOCRUS, SOUPCY, SOUPMM, SOUPDD, SOUPTM, SOUPUS, SOLOCK, SOSTS, SO


*/


-- Not bound SQLs 
-- Check if they wait for "latch free" event. 
-- That may be result cache related if much sleep is encountered on "Result Cache: RC Latch"
select
  sum(10) secs,
  sum(sum(10)) over () as totalsec,  
  round((sum(10)/ sum(sum(10)) over ()) *100,2) percento, 
  force_matching_signature, 
  count(distinct sql_id) cnt_sql_id,
  max(sql_id) max_sql_id,
  event
from dba_hist_active_sess_history
where sample_time  between to_date('20180618 08:00','YYYYMMDD HH24:MI') and to_date('20180618 09:00','YYYYMMDD HH24:MI') 
group by force_matching_signature, event
order by 1 desc
;

-- I dont' know yet how to use this info

SET SERVEROUTPUT ON
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
COLUMN name FORMAT a20
SELECT name, value
FROM V$RESULT_CACHE_STATISTICS;


/*

-- FROM NOT ACTIVE PERIOD

EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 482368K bytes (482368 blocks)
Maximum Result Size = 24118K bytes (24118 blocks)
[Memory]
Total Memory = 495178784 bytes [4.854% of the Shared Pool]
... Fixed Memory = 22480 bytes [0.000% of the Shared Pool]
... Dynamic Memory = 495156304 bytes [4.854% of the Shared Pool]
....... Overhead = 1211472 bytes
....... Cache Memory = 482368K bytes (482368 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 482368 blocks
............... Dependencies = 109 blocks (109 count)
............... Results = 482259 blocks
................... SQL     = 7 blocks (7 count)
................... PLSQL   = 482252 blocks (482252 count)

SELECT name, value FROM V$RESULT_CACHE_STATISTICS;
Block Size (Bytes) 		1024
Block Count Maximum   482368
Block Count Current   482368
Result Size Maximum (Blocks)      24118
Create Count Success      4836881
Create Count Failure      63
Find Count 654947113
Invalidation Count 1429985
Delete Count Invalid      1432561
Delete Count Valid 2922061
Hash Chain Length  106-128
Find Copy Count    655031820
Latch (Share)      0




-- FROM ACTIVE PERIOD
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;

R e s u l t   C a c h e   M e m o r y   R e p o r t
[Parameters]
Block Size          = 1K bytes
Maximum Cache Size  = 482368K bytes (482368 blocks)
Maximum Result Size = 24118K bytes (24118 blocks)
[Memory]
Total Memory = 495178784 bytes [4.854% of the Shared Pool]
... Fixed Memory = 22480 bytes [0.000% of the Shared Pool]
... Dynamic Memory = 495156304 bytes [4.854% of the Shared Pool]
....... Overhead = 1211472 bytes
....... Cache Memory = 482368K bytes (482368 blocks)
........... Unused Memory = 0 blocks
........... Used Memory = 482368 blocks
............... Dependencies = 109 blocks (109 count)
............... Results = 482259 blocks
................... SQL     = 1 blocks (1 count)
................... PLSQL   = 482258 blocks (482258 count)


SELECT name, value FROM V$RESULT_CACHE_STATISTICS;

Block Size (Bytes)            1024
Block Count Maximum  482368
Block Count Current       482368
Result Size Maximum (Blocks)   24118
Create Count Success    5153557
Create Count Failure      63
Find Count          684243946
Invalidation Count          1506350
Delete Count Invalid       1508946
Delete Count Valid          3162352
Hash Chain Length          106-128
Find Copy Count              684331346
Latch (Share)     0

A következőket szűrtem le a mai és a tegnap délutáni adatok összehasonlításával.
-	A számok szinte semmit nem változtak
-	A cache tele van
-	A cache tartalma szinte 100%-ban PL/SQL result cache (és nem sima SQL result)


*/