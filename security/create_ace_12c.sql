-- ACE OK
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'www.httpvshttps.com', 
    lower_port => 80,
    upper_port => 80,
    ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                              principal_name => 'P',
                              principal_type => xs_acl.ptype_db)); 
END;
/

-- NO SUCH THING
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'www.httpvshttps.com', 
    lower_port => 443,
    upper_port => 443,
    ace        => xs$ace_type(privilege_list => xs$name_list('https'),
                              principal_name => 'PS',
                              principal_type => xs_acl.ptype_db)); 
END;
/

ERROR at line 1:
ORA-24245: invalid network privilege
ORA-06512: at "SYS.DBMS_NETWORK_ACL_ADMIN", line 329
ORA-06512: at "SYS.DBMS_NETWORK_ACL_ADMIN", line 1126
ORA-06512: at line 2
