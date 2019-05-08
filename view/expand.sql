-- SQL view kibontasa
SET SERVEROUTPUT ON 
DECLARE
  l_clob CLOB;
BEGIN
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => 'select  count(*) into :l_row_count from  IA_STAGE_AREA.REMEDIOS_IA_MOBILNET_CUST_ACTIVE_V2_V where rownum <= 1',
    output_sql_text => l_clob
  );

  DBMS_OUTPUT.put_line(l_clob);
END;
/
