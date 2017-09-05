--exec DBADMIN.SEND_MAIL_ATT('PROD','CORE','REPORT','ELEMZOI_BACKUP_DIR','bck_REPORT_2017-08-08_15-54-37_expdp.log');

CREATE OR REPLACE PROCEDURE DBADMIN.SEND_MAIL_ATT(p_db_env in varchar2, p_env in varchar2, p_schema in varchar2, p_directory in varchar2, p_filename in varchar2) AS
  l_mail_conn UTL_SMTP.connection;
  l_subj varchar2(100);
  l_message varchar2(1000);
  l_fhandle utl_file.file_type;
  l_buffer  VARCHAR2(4096);
  l_port number:=25;
  l_smtp_server varchar2(100):='10.xxx.x.xx';
  l_from varchar2(500):='PRD.ELEMZOI.PROD';
  cursor c_recipients is select recipients from dbadmin.mail_recipients where mail_type='LOG';
  l_rcp varchar2(2000);
BEGIN
  l_subj:='A(z) '||p_schema||' mentes logja '||p_db_env||' kornyezetrol.';
  l_message:='A '||p_schema||' sema mentes a '||p_env||'/'||p_db_env||' kornyezetrol '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'-ra lefutott, logja:';

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
  l_fhandle := utl_file.fopen(p_directory,
                              p_filename,
                              'R');
  LOOP
    BEGIN
      utl_file.get_line(L_FHANDLE, l_buffer);
      UTL_SMTP.write_data(l_mail_conn, l_buffer || UTL_TCP.crlf);
    EXCEPTION
      WHEN no_data_found THEN
           EXIT;
    END;
  END LOOP;
  UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
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
