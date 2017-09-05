CREATE OR REPLACE PROCEDURE DBADMIN.BACKUP_SCHEMAS (p_env in VARCHAR2) AS
    l_datapump_handle    NUMBER;
    l_datapump_dir       VARCHAR2(20) := 'BACKUP_DIR';
    l_job_name		 varchar2(50) := 'BACKUP_JOB';
    l_filesize		 varchar2(30) := '10240M';
    l_status             varchar2(200);
    l_schema_name	 varchar2(30);
    l_filename		 varchar2(1000);
    l_logname		 varchar2(1000);
    cursor sch_to_exp is select schema from dbadmin.schema_export where env=p_env;
    l_db_env             varchar2(100);
    l_hostname           varchar2(100);
BEGIN
  SELECT
    DECODE(lower(SYS_CONTEXT('USERENV','HOST')), 
      'fakt-dataminet', 'TEST',
      'fakt-datamine', 'PROD',
      'Unknown environment') into l_db_env
  FROM dual;
FOR sch IN sch_to_exp
  LOOP
    l_filename:='bck_'||sch.schema||'_'||to_char(SYSDATE,'yyyy-mm-dd_hh24-mi-ss')||'_%U.dmp';
    l_logname:='bck_'||sch.schema||'_'||to_char(SYSDATE,'yyyy-mm-dd_hh24-mi-ss')||'_expdp.log';
    l_schema_name:=''''||sch.schema||'''';
    l_datapump_handle := dbms_datapump.open(operation => 'EXPORT' ,
                                            job_mode =>'SCHEMA' ,
                                            job_name => l_job_name );

    dbms_datapump.add_file(handle    => l_datapump_handle ,
                           filename  => l_filename,
                           directory => l_datapump_dir,
			   filesize => l_filesize);

    dbms_datapump.add_file(handle    => l_datapump_handle,
                           filename  => l_logname,
                           directory => l_datapump_dir,
                           filetype  => DBMS_DATAPUMP.ku$_file_type_log_file);

    dbms_datapump.metadata_filter( handle => l_datapump_handle,
                                   name   => 'SCHEMA_LIST',
                                   value  => l_schema_name);

    dbms_datapump.start_job(handle => l_datapump_handle);
    dbms_datapump.wait_for_job( handle => l_datapump_handle,
                                job_state => l_status );
    dbms_output.put_line( l_status );
    SEND_MAIL_ATT(l_db_env,p_env,sch.schema,l_datapump_dir,l_logname);
  END LOOP;
  SEND_MAIL(l_db_env,p_env);
END;
/
