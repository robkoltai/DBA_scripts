-- Hard parse-ot indit
-- Nem fut le az utasítás
 begin
 dbms_sqldiag.dump_trace(p_sql_id=>'b086mzzp82x7w',
                          p_component=>'Optimizer',
                          p_file_id=>'OPT_TRACE_b086mzzp82x7w');
 end;
/


/*

http://structureddata.org/2011/08/18/creating-optimizer-trace-files/

-- $ORACLE_HOME/rdbms/admin/dbmsdiag.sql
-------------------------------- dump_trace ---------------------------------
-- NAME: 
--     dump_trace - Dump Optimizer Trace
--
-- DESCRIPTION:
--     This procedure dumps the optimizer or compiler trace for a give SQL 
--     statement identified by a SQL ID and an optional child number. 
--
-- PARAMETERS:
--     p_sql_id          (IN)  -  identifier of the statement in the cursor 
--                                cache
--     p_child_number    (IN)  -  child number
--     p_component       (IN)  -  component name
--                                Valid values are Optimizer and Compiler
--                                The default is Optimizer
--     p_file_id         (IN)  -  file identifier
------------------------------------------------------------------------------
PROCEDURE dump_trace(
              p_sql_id         IN varchar2,
              p_child_number   IN number   DEFAULT 0,
              p_component      IN varchar2 DEFAULT 'Optimizer',
              p_file_id        IN varchar2 DEFAULT null);
As you can see, you can specify either Optimizer or Compiler as the component name which is the equivalent of the SQL_Compiler or SQL_Optimizer events. Conveniently you can use P_FILE_ID to add a trace file identifier to your trace file. The four commands used above can be simplified to just a single call. For example:

SQL> begin
  2    dbms_sqldiag.dump_trace(p_sql_id=>'6yf5xywktqsa7',
  3                            p_child_number=>0,
  4                            p_component=>'Compiler',
  5                            p_file_id=>'MY_TRACE_DUMP');
  6  end;
  7  /

PL/SQL procedure successfully completed.
*/