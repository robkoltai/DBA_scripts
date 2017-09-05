CREATE OR REPLACE PROCEDURE SEND_MAIL(p_db_env in varchar2, p_env in varchar2) AS
  l_mail_conn UTL_SMTP.connection;
  l_subj varchar2(100);
  l_message varchar2(1000);
  l_schema varchar2(1000);
  l_port number:=25;
  l_smtp_server varchar2(100):='10.xxx.xx.x';
  l_from varchar2(500):='PRD.ELEMZOI.PROD';
  cursor c_recipients is select recipients from dbadmin.mail_recipients where mail_type='FINAL';
  l_rcp varchar2(2000);
BEGIN
  SELECT LISTAGG(schema, ', ') WITHIN GROUP (ORDER BY schema) into l_schema from dbadmin.schema_export where env=p_env;
  l_subj:='A '||p_env||' mentes a '||p_db_env||' kornyezetrol elkeszult.';
  l_message:='A '||l_schema||' semak mentese a '||p_db_env||' kornyezetrol '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'-ra lefutott.';

  l_mail_conn := UTL_SMTP.open_connection(l_smtp_server, l_port);
  UTL_SMTP.helo(l_mail_conn, l_smtp_server);
  UTL_SMTP.mail(l_mail_conn, l_from);
FOR rcp IN c_recipients
  LOOP
    UTL_SMTP.rcpt(l_mail_conn, rcp.recipients);
  END LOOP;
  UTL_SMTP.open_data(l_mail_conn);
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || l_rcp || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || l_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || l_subj || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || l_from || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, l_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.close_data(l_mail_conn);
  UTL_SMTP.quit(l_mail_conn);
  EXCEPTION
  WHEN UTL_SMTP.INVALID_OPERATION THEN
    dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
    dbms_output.put_line(' Temporary e-mail issue - try again');
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
    dbms_output.put_line(' Permanent Error Encountered.'); 
END;
/

