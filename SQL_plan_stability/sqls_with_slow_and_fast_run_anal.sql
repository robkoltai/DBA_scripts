-- Find quieries that are sometimes slow and sometimes fast
-- Order: the first slow day

-- lassan futok
drop table lassan_futok_RK_TMP purge;
create table lassan_futok_RK_TMP as 
select sql_id, to_char(sqlstart,'YYYYMMDD') sqlstartday, sec, sql_child_number from(
    select sql_id, session_id, session_serial#,sql_exec_id, min(sample_time) sqlstart, max(sample_time) sqlend, sum(10) sec, user_id, sql_plan_hash_value, sql_child_number 
    from dba_hist_active_sess_history 
    where sql_id is not null --and ql_id in ('0324bk53p962f xxx','bssqz82qrgszv')
    group by sql_id, session_id, session_serial#, user_id, sql_plan_hash_value, sql_child_number, sql_exec_id
    having sum(10) > 3600
);

-- gyorsan futok
drop table gyorsan_futok_RK_TMP purge;
create table gyorsan_futok_RK_TMP as 
select sql_id, to_char(sqlstart,'YYYYMMDD') sqlstartday, sec, sql_child_number from(
select sql_id, session_id, session_serial#,sql_exec_id, min(sample_time) sqlstart, max(sample_time) sqlend, sum(10) sec, user_id, sql_plan_hash_value, sql_child_number 
from dba_hist_active_sess_history 
where sql_id is not null --and ql_id in ('0324bk53p962f xxx','bssqz82qrgszv')
group by sql_id, session_id, session_serial#, user_id, sql_plan_hash_value, sql_child_number, sql_exec_id
having sum(10) < 600
);

select gy.sql_id, gy.firstrunday gy_first, gy.lastrunday gy_last, gy.maxsec gy_maxsec, gy.cnt gy_cnt,
                   l.firstrunday  l_first,  l.lastrunday  l_last,  l.maxsec  l_maxsec,  l.cnt  l_cnt, l.sql_child_number, to_char(substr(sql_text,1,200)) t
from 
  (select sql_id, min(sqlstartday) firstrunday, max(sqlstartday) lastrunday, max(sec) maxsec, count(1) cnt                   from  gyorsan_futok_RK_TMP group by sql_id) gy,
  (select sql_id, min(sqlstartday) firstrunday, max(sqlstartday) lastrunday, max(sec) maxsec, count(1) cnt,  sql_child_number from   lassan_futok_RK_TMP group by sql_id, sql_child_number) l,
  dba_hist_sqltext s
where l.sql_id=gy.sql_id and (l.lastrunday>'20180000')
  and s.sql_id (+) = gy.sql_id
order by l.firstrunday desc, sql_id;

/*
6aquwkqtkw9n9	20180520	20180531	570	11	20180601	20180601	4690	1	0		"INSERT INTO CHARGES_BASE WITH LSZ AS ( SELECT  materialize T.PRIMER_ID, T.VONAL_ID, TRUNC(NVL (T.V_RDATUM, T.V_RRDATUM),'DD') VALID_TO, T.V_RROGZITETTE FROM NMT_VALTOZAS T WHERE T.VALTKERES = 'LSZ"
b200kds2nrc5m	20180420	20180531	60	39	20180601	20180601	15980	1	0		INSERT INTO HUSEG_LEM_MASTER_IA_V2 SELECT DISTINCT /*+ ordered  'MOBIL_SZOLGALTATASAZONOSITO   ' TALALAT, A.ID,A.SESSION_ID,A.IA_SOURCE_TRANS_ID,A.NMT_SOURCE_TRANS_ID,A.NMTC_SOURCE_TRANS_ID,A.TYPE,A
gx3b2qu71483d	20180420	20180528	60	38	20180601	20180601	14250	1	0		INSERT INTO HUSEG_LEM_MASTER_IA_V2 SELECT DISTINCT /*+ ordered  'IPTV_SUBSCRIBER_ID            ' TALALAT, A.ID,A.SESSION_ID,A.IA_SOURCE_TRANS_ID,A.NMT_SOURCE_TRANS_ID,A.NMTC_SOURCE_TRANS_ID,A.TYPE,A
dqb1akba16q7q	20180420	20180601	440	45	20180531	20180531	6400	2	0		insert /*+append nologging into JUT_TETELES select * from JUT_TETELES_V
21jhux17g0cmp	20180601	20180601	10	1	20180529	20180601	6320	4	0		insert /*+APPEND into VITRIN_STAGE_AREA.TODWH_V_MUNKALAP (ADSL_ADATLAP_ID, ADSL_ADATLAP_ID_IPTV, ADSL_ALV_KESZREJELENTES, ADSL_ALV_KESZREJELENTES_IDEJE, ADSL_CSOMAG, ADSL_MUSZAKI_AKADALY, ADSL_MUSZA
831m2z9dpbuzx	20180420	20180601	410	40	20180529	20180530	9200	2	0		insert /*+APPEND into SALES_TOOLS.FIA_DETAILED_COSTS (FIA_ID, FELMERESERVENYES, FELMERESERVENYESSEGE, SZOLGALTATAS_ID, UGYFEL_NEV, UGYFELKOD, IGENYAZONOSITO, CM_AZONOSITO, SZIA_ID, FIA_STATUSZ, STAT







*/