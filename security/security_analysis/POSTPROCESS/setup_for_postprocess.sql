-- RAT REPLAY FUTASA UTAN a POSTPROCESSING-hez setup


-- As a very fist step priv ana needs to be finished
-- AS SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'RATREPLAY05_PRIV');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'RATREPLAY05_PRIV',
   run_name    => 'RUN1',
   DEPENDENCY  => false);
end;
/




-- BEFORE POSTPROCESSING DO RUN SETUP STEPS
-- make sure PA user is set up properly
-- and TESTRUNS/PA_setup_preprocess.sql had already been executed.


-- create compute_sql_id function as sys user
@create_compute_sql_id_as_sys.sql


conn pa/pa

@helper_plsql/priv_ana_util.sql

--@helper_plsql/string_ana.sql