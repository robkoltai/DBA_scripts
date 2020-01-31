select sql_text from v$sqltext where sql_id='&sql' order by piece
/



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


SET SERVEROUTPUT ON 
DECLARE
  v_out_clob CLOB;
  v_in_clob CLOB;   
   
BEGIN
  
  select sql_fulltext
  into v_in_clob
  from v$sqlarea
  where sql_id = '18nkbwcz1c9vh';  --SQL_ID
 
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => v_in_clob,
    output_sql_text => v_out_clob
  );

  DBMS_OUTPUT.put_line(v_out_clob);
END;
/


/*

SELECT COUNT(*) "COUNT(*)" FROM  (SELECT TRUNC(SYSDATE) "LOADING_DAY" 
FROM
	"IA_STAGE_AREA"."IA_MOBILNET" "A19","IA_STAGE_AREA"."IA_PRODUCT"
	"A18","IA_STAGE_AREA"."IA_CONTRACT_ALL_H"
	"A17","IA_STAGE_AREA"."IA_CONTRACT_START_END"
	"A16","IA_STAGE_AREA"."IA_CONTRACT" "A15","IA_STAGE_AREA"."IA_CUSTOMER"
	"A14","IA_STAGE_AREA"."IA_CONTRACT" "A13","IA_STAGE_AREA"."IA_CUSTOMER"
	"A12","IA_STAGE_AREA"."IA_CONTRACTSTATE" "A11","IA_STAGE_AREA"."IA_SALESPACKAGE"
	"A10","IA_STAGE_AREA"."IA_CONTRACTSTATE"
	"A9","IA_STAGE_AREA"."IA_CONTRACT_ALL_H" "A8","IA_STAGE_AREA"."IA_SALESPACKAGE"
	"A7","IA_STAGE_AREA"."IA_CONTRACT" "A6","IA_STAGE_AREA"."IA_CONTRACTSTATE"
	"A5","IA_STAGE_AREA"."IA_CONTRACT_ALL_H" "A4","IA_STAGE_AREA"."IA_SALESPACKAGE"
	"A3", (SELECT "A20"."CONTRACT_ID" "CONTRACT_ID","A21"."PRODUCT_ID"
	"PRODUCT_ID",'36'||"A21"."PRIMER"||"A21"."TELEPHONENUMBER" "VNET_PHONE_NUMBER"
FROM "IA_STAGE_AREA"."IA_ADSLINTERNET" "A21","IA_STAGE_AREA"."IA_PRODUCT" "A20"
WHERE "A21"."PRODUCT_ID"="A20"."PRODUCT_ID" AND "A21"."PRIMER" IS NOT NULL AND
	"A21"."PRIMER"<>'00') "A2" WHERE "A19"."PRODUCT_ID"="A18"."PRODUCT_ID" AND
	"A18"."CONTRACT_ID"="A17"."CONTRACT_ID" AND "A17"."SOS" IS NOT NULL AND
	"A17"."TENDOFSERVICE" IS NULL AND
	"A19"."VNETSZERZODES_ID"="A16"."CONTRACT_ID"(+) AND
	"A18"."CONTRACT_ID"="A15"."CONTRACT_ID" AND
	"A15"."CUSTOMER_ID"="A14"."CUSTOMER_ID" AND
	"A16"."LAST_ADSL"="A13"."CONTRACT_ID"(+) AND
	"A13"."CUSTOMER_ID"="A12"."CUSTOMER_ID"(+) AND
	"A15"."CONTRACTSTATE_ID"="A11"."CONTRACTSTATE_ID" AND
	"A17"."BASEPACKAGE_ID"="A10"."SALESPACKAGE_ID" AND
	"A13"."CONTRACTSTATE_ID"="A9"."CONTRACTSTATE_ID"(+) AND
	"A13"."CONTRACT_ID"="A8"."CONTRACT_ID"(+) AND
	"A8"."BASEPACKAGE_ID"="A7"."SALESPACKAGE_ID"(+) AND
	"A19"."VNETSZERZODES_ID"="A6"."CONTRACT_ID"(+) AND
	"A6"."CONTRACTSTATE_ID"="A5"."CONTRACTSTATE_ID"(+) AND
	"A6"."CONTRACT_ID"="A4"."CONTRACT_ID"(+) AND
	"A4"."BASEPACKAGE_ID"="A3"."SALESPACKAGE_ID"(+) AND
	"A8"."CONTRACT_ID"="A2"."CONTRACT_ID"(+)) "A1" 
	WHERE ROWNUM<=1



*/


SET SERVEROUTPUT ON 
DECLARE
  v_out_clob CLOB;
  v_in_clob CLOB;   
  v_just_select clob;
  v_first number;
  
BEGIN
  
  select sql_fulltext
  into v_in_clob
  from v$sqlarea
  where sql_id = '18nkbwcz1c9vh';  --SQL_ID
  
  v_first_select_pos :=dbms_clob.instr(v_in_clob,'SELECT',1,1);
  
  v_just_select:= 
    dbms_lob.substr(
	  v_in_clob,
      dbms_lob.getlength(v_in_clob) - v_first_select_pos,
      v_first_select_pos);
 

 
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => v_just_select,
    output_sql_text => v_out_clob
  );

  DBMS_OUTPUT.put_line(v_out_clob);
END;
/
