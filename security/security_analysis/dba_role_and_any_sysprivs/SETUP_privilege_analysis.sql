-- SETUP
-- NON SYS user gets stupid error
--ORA-47951: invalid input value or length for parameter 'condition'
--ORA-06512: at "SYS.DBMS_PRIVILEGE_CAPTURE", line 3
--ORA-06512: at line 2
conn / as sysdba

begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'CAPTURE_EVERYBODY',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') > ''A'''  );
end;
/
-- vagy
begin
DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE (
   name            => 'RATREPLAY04_PRIV',
   type            => dbms_privilege_capture.g_context,
   condition       => 'SYS_CONTEXT(''USERENV'', ''TERMINAL'') = ''GB61797''');
end;
/



begin
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE (
  'CAPTURE_EVERYBODY',
  'RUN01');
end;
/


-- FINISH, END
-- SYS
begin
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE (
  'CAPTURE_EVERYBODY');
end;
/

begin
DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT (
   name        => 'CAPTURE_EVERYBODY',
   run_name    => 'RUN01',
   DEPENDENCY  => false);
end;
/