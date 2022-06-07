set lines 180
set pages 30
column name format a5
column pid format a8
column client_pid format 99999999
column block_count heading "Block|Count"
column block_count format 999999
select 
 NAME,               
 PID  ,              
-- TYPE  ,             
 ROLE   ,            
-- PROC_TIME,          
-- TASK_TIME ,         
 TASK_DONE  ,        
 ACTION      ,       
 CLIENT_PID   ,      
 CLIENT_ROLE   ,     
-- GROUP#         ,    
-- RESETLOG_ID     ,   
-- THREAD#          ,  
-- SEQUENCE#         , 
-- BLOCK#             ,
 BLOCK_COUNT        ,
 DELAY_MINS         ,
 DEST_ID            ,
 DEST_MASK          ,
-- DBID               ,
-- DGID               ,
-- INSTANCE           ,
 STOP_STATE         
-- CON_ID            
from v$dataguard_process
order by 1;

