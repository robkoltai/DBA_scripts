 
-- 1931944.1 How to Create a SQL Patch to add Hints to Application SQL Statements 
 
DECLARE
   patch_name varchar2(100);
BEGIN
   patch_name := sys.dbms_sqldiag.create_sql_patch(
                 sql_text=>'select WO.ticket_id, WO.work_order_number, WO.work_order_status_code from fr_work_order WO, rt_ticket T where WO.work_order_url like 'ICCM_SURVEY~33.%' and WO.work_order_number=0 and T.ticket_id=WO.ticket_id+0 and T.close_date is null;',                  
				 hint_text=>'INDEX(FR_WORK_ORDER UK_FR_WORK_ORDER__URL)', 
                 name=>'TEST_PATCH');
END;
/
 
 


DECLARE
  l_sql_text        CLOB         :=q'[select WO.ticket_id, WO.work_order_number, WO.work_order_status_code from fr_work_order WO, rt_ticket T where WO.work_order_url like 'ICCM_SURVEY~33.%' and WO.work_order_number=0 and T.ticket_id=WO.ticket_id+0 and T.close_date is null]';
  l_sql_id          VARCHAR2(30) :='';
  l_sql_patch_hints VARCHAR2(500):=q'[INDEX(FR_WORK_ORDER UK_FR_WORK_ORDER__URL)]';
  l_sql_patch_name  VARCHAR2(30) :='CORRECT_INDEX';
  l_sql_patch_desc  VARCHAR2(500):=l_sql_patch_name || 'Corrent wrong index selection';
  l_output          varchar2(100);
BEGIN
  IF (l_sql_text IS NULL) THEN
    SELECT sql_fulltext INTO l_sql_text FROM v$sqlarea WHERE sql_id = l_sql_id AND ROWNUM < 2;
  END IF;
  l_output:= SYS.DBMS_SQLDIAG_INTERNAL.i_create_patch(
      sql_text    => l_sql_text
    , hint_text   => l_sql_patch_hints
    , name        => l_sql_patch_name
    , description => l_sql_patch_desc
  );
END;
/


set serveroutput on

DECLARE
  l_output          varchar2(100);
BEGIN
  l_output:= SYS.DBMS_SQLDIAG_INTERNAL.i_create_patch(
      sql_text    => q'[select WO.ticket_id, WO.work_order_number, WO.work_order_status_code from fr_work_order WO, rt_ticket T where WO.work_order_url like 'ICCM_SURVEY~33.%' and WO.work_order_number=0 and T.ticket_id=WO.ticket_id+0 and T.close_date is null]'
    , hint_text   => q'[INDEX(FR_WORK_ORDER UK_FR_WORK_ORDER__URL)]'
    , name        => 'CORRECT_INDEX'
  );
  dbms_output.put_line (l_output);
END;
/

-- SQL PATCH with force matching
SET SERVEROUTPUT ON
DECLARE
  l_sql_text        CLOB         :='select /*+ NO_index(emp pk_emp) */ * from EMP where empno=7839';
  l_sql_id          VARCHAR2(30) :='7a1dd4z42gw7t';
  l_sql_patch_hints VARCHAR2(500):=q'[INDEX(@"SEL$1" "EMP"@"SEL$1") OPT_PARAM('optimizer_dynamic_sampling' 0)]';
  l_sqlpro_attr SYS.SQLPROF_ATTR :=SYS.SQLPROF_ATTR(l_sql_patch_hints);
  l_sql_patch_name  VARCHAR2(30) :='my_sql_patch';
  l_sql_patch_desc  VARCHAR2(500):=l_sql_patch_name || 'my_sql_patch_description';
  l_output   varchar2(100);
BEGIN
  IF (l_sql_text IS NULL) THEN
    SELECT sql_fulltext INTO l_sql_text FROM v$sqlarea WHERE sql_id = l_sql_id AND ROWNUM < 2;
  END IF;
  l_output := SYS.DBMS_SQLTUNE_INTERNAL.I_CREATE_SQL_PROFILE(
    SQL_TEXT    => l_sql_text,
    PROFILE_XML => DBMS_SMB_INTERNAL.VARR_TO_HINTS_XML(l_sqlpro_attr),
    NAME        => l_sql_patch_name,
    DESCRIPTION => l_sql_patch_desc,
    CATEGORY    => 'DEFAULT',
    CREATOR     => 'SYS',
    VALIDATE    => TRUE,
    TYPE        => 'PATCH',
    FORCE_MATCH => TRUE,
    IS_PATCH    => TRUE);
    DBMS_OUTPUT.PUT_LINE(l_output);
END;
/

--12.2 greatly simplify process

DECLARE
  l_patch_name  VARCHAR2(32767);
BEGIN
  l_patch_name := SYS.DBMS_SQLDIAG.create_sql_patch(
    sql_id    => '19v5guvsgcd1v',
    hint_text => 'PARALLEL(big_table,10)',
    name      => '19v5guvsgcd1v_PARALLEL(big_table,10)');
END;
/