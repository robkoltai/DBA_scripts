BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'appserver-69-k.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA1',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'appserver-69-k.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'DB_OPER_PFCLONE',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'appserver-69-k.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'BM_FELADAS',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'appserver-69-k.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA2',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'appserver-69-k.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA3',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/


--------------
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'erzsi.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA1',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'erzsi.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'DB_OPER_PFCLONE',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'erzsi.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'BM_FELADAS',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'erzsi.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA2',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.remove_host_ace (
    host             => 'erzsi.domain.hu', 
    lower_port       => 25,
    upper_port       => 25,
    ace              => xs$ace_type(privilege_list => xs$name_list('SMTP'),
                                    principal_name => 'SCHEMA3',
                                    principal_type => xs_acl.ptype_db),
    remove_empty_acl => TRUE); 
END;
/
