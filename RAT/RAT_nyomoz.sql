 
 -- capture file-okban való keresés
 cd capture dir
 cd /opt/oradump/pfup/grb_pf_live_capture_0502_bck
 grep 'get_package_status'  ./*/*/*/*rec
 strings ./capfiles/inst1/aa/wcr_cnxzuh000000v.rec |less
*/
 
-- FULL reszletes divergencia
-- *****************************
select 
DBMS_WORKLOAD_REPLAY.GET_DIVERGING_STATEMENT (replay_id, stream_id, call_counter) as detail,
div.* from dba_workload_replay_divergence div;  
 
 
-- Reszletes, de csak 1 hibankent
select DBMS_WORKLOAD_REPLAY.GET_DIVERGING_STATEMENT (replay_id, stream_id, call_counter) as detail,
div.* from dba_workload_replay_divergence div
where 1=1
and observed_error#<>0
-- max problematic call
and call_counter in (
  select max_call_counter from (
    select max(call_counter) max_call_counter, observed_error#
    from dba_workload_replay_divergence
    where observed_error#<>0
    group by observed_error#)
  )
-- problematic streams
and stream_id in (
    select stream_id from(
      select distinct observed_error#, stream_id
      from  dba_workload_replay_divergence 
      where observed_error#<>0
    )
)
;



 
 -- DIVERGENCIÁK listája, SQL_ID-ra szűrve:
SELECT    *  
FROM    dba_workload_replay_divergence
    where sql_id ='gasrx18gy4c41';

-- DIVERGENCIÁK részletei (paraméterek a fenti tábla alapján kitölthetőek)
SELECT 
DBMS_WORKLOAD_REPLAY.GET_DIVERGING_STATEMENT (
   replay_id    => 1,
   stream_id    => 14591089397366522784,
   call_counter => 40528)
FROM DUAL;

-- EGY példa kimenet
<replay_divergence_info>
  <sql_id>gasrx18gy4c41</sql_id>
  <sql_text>BEGIN         :rc := adatlap.send_email_linkkel( :0,:1,:2,:3,:4); END;</sql_text>
  <full_sql_text>BEGIN         :rc := adatlap.send_email_linkkel( :0,:1,:2,:3,:4); END;</full_sql_text>
  <binds>
    <iteration value="1">
      <bind>
        <BIND_POS>1</BIND_POS>
        <BIND_VARNAME>RC</BIND_VARNAME>
        <BIND_VALUE>0</BIND_VALUE>
      </bind>
      <bind>
        <BIND_POS>2</BIND_POS>
        <BIND_VARNAME>0</BIND_VARNAME>
        <BIND_VALUE>Ajánlatértesítő lap - UHF_R_2019_005885 - szerződésszám: 882121742 - szerződő: Kéry Krisztián - üzletkötő: NETRISK KFT ELSŐ ONLINE BIZT.  ALKUSZ KFT</BIND_VALUE>
      </bind>
      <bind>
        <BIND_POS>3</BIND_POS>
        <BIND_VARNAME>1</BIND_VARNAME>
        <BIND_VALUE>Tisztelt Cím!

Ajánlat értesítő adatlap érkezett. További információért nyissa meg a következő linket:

\\10.0.128.4\Portal-hibajav\Ajanlat_pdf\2019\2019_05\AR\\UHF_R_2019_005885.pdf

</BIND_VALUE>
      </bind>
      <bind>
        <BIND_POS>4</BIND_POS>
        <BIND_VARNAME>2</BIND_VARNAME>
        <BIND_VALUE>zsolt.kade@groupama.hu</BIND_VALUE>
      </bind>
      <bind>
        <BIND_POS>5</BIND_POS>
        <BIND_VARNAME>3</BIND_VARNAME>
        <BIND_VALUE>alkusz@groupama.hu</BIND_VALUE>
      </bind>
      <bind>
        <BIND_POS>6</BIND_POS>
        <BIND_VARNAME>4</BIND_VARNAME>
        <BIND_VALUE>UHF_R_2019_005885.pdf</BIND_VALUE>
      </bind>
    </iteration>
  </binds>
</replay_divergence_info>
