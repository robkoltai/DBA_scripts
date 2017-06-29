select to_char(ORIGINATING_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') || ' ' || message_text 
 from X$DBGALERTEXT 
 where ORIGINATING_TIMESTAMP>sysdate-301/(24*60*60) 
 and message_text like '%ORA-%' 
 and message_text not like '%result of ORA-609%' 
 and message_text not like '%result of ORA-28%' 
 and message_text not like '%(ORA-3136)%' 
 and message_text not like '%ORA-01013:%'
 ;
