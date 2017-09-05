select * from dba_network_acls;

select * from dba_network_acl_privileges;


exec DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('mail.xml','Mail service','DBADMIN',true,'connect');
exec DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('mail.xml','mrelay2',25);
exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('mail.xml','DBADMIN', TRUE, 'resolve');

exec DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE('mail.xml','DBADMIN');
exec DBMS_NETWORK_ACL_ADMIN.DROP_ACL('mail.xml');


exec DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('mail.xml','Mail service','DBADMIN',true,'connect');
exec DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('mail.xml','10.xxx.x.xx',25);
exec DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE('mail.xml','DBADMIN', TRUE, 'resolve');