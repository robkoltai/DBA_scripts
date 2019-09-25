/*
https://oracle-base.com/articles/12c/fine-grained-access-to-network-services-enhancements-12cr1
https://oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1
https://oracle-base.com/articles/misc/utl_http-and-ssl#get-site-certificates
*/


SET LINESIZE 150
column acl format a55
COLUMN host FORMAT A20
COLUMN acl_owner FORMAT A10
COLUMN host FORMAT A20
COLUMN start_date FORMAT A11
COLUMN end_date FORMAT A11
column principal format a18
column privilege format a12


SELECT HOST,LOWER_PORT,UPPER_PORT,
  ACL, ACLID, ACL_OWNER
FROM   dba_host_acls
ORDER BY host;

SELECT host,
       lower_port, upper_port,
       ace_order,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date,
       grant_type, inverted_principal,
       principal, principal_type, privilege
FROM   dba_host_aces
ORDER BY host, ace_order;


/*

SQL> @ace

HOST                 LOWER_PORT UPPER_PORT ACL                                                     ACLID            ACL_OWNER
-------------------- ---------- ---------- ------------------------------------------------------- ---------------- ----------
*                                          NETWORK_ACL_86B64B66DF95012EE053F706E80A06B7            0000000080002724 SYS
localhost                                  /sys/acls/oracle-sysman-ocm-Resolve-Access.xml          0000000080002760 SYS
www.httpvshttps.com          80         80 NETWORK_ACL_9348B74D63893E9FE055000000000001            0000000080002774 SYS


HOST                 LOWER_PORT UPPER_PORT  ACE_ORDER START_DATE  END_DATE    GRANT INV PRINCIPAL          PRINCIPAL_T PRIVILEGE
-------------------- ---------- ---------- ---------- ----------- ----------- ----- --- ------------------ ----------- ------------
*                                                   1                         GRANT NO  GSMADMIN_INTERNAL  DATABASE    RESOLVE
*                                                   2                         GRANT NO  GGSYS              DATABASE    RESOLVE
localhost                                           1                         GRANT NO  ORACLE_OCM         DATABASE    RESOLVE
www.httpvshttps.com          80         80          1                         GRANT NO  P                  DATABASE    HTTP

*/


-- Check
SELECT DECODE(
         DBMS_NETWORK_ACL_ADMIN.check_privilege('NETWORK_ACL_9348B74D63893E9FE055000000000001', 'P', 'http'),
         1, 'GRANTED', 0, 'DENIED', 'DENIED') privilege 
FROM dual;


PRIVILEGE
------------
GRANTED


COLUMN acl FORMAT A50
COLUMN host FORMAT A30

SELECT acl,
       host,
       DECODE(
         DBMS_NETWORK_ACL_ADMIN.check_privilege_aclid(aclid, 'P', 'http'),
         1, 'GRANTED', 0, 'DENIED', 'DENIED') privilege 
FROM   dba_network_acls;

-- TEST OK
-- if there is no error then OK.
DECLARE
  l_url            VARCHAR2(50) := 'www.httpvshttps.com';
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(l_url);
  l_http_response := UTL_HTTP.get_response(l_http_request);
  UTL_HTTP.end_response(l_http_response);
END;
/


PL/SQL procedure successfully completed. -- This means OK.

-- TEST NOT OK
DECLARE
  l_url            VARCHAR2(50) := 'https://www.httpvshttps.com';
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(l_url);
  l_http_response := UTL_HTTP.get_response(l_http_request);
  UTL_HTTP.end_response(l_http_response);
END;
/


*
ERROR at line 1:
ORA-29273: HTTP request failed
ORA-24247: network access denied by access control list (ACL)
ORA-06512: at "SYS.UTL_HTTP", line 380
ORA-06512: at "SYS.UTL_HTTP", line 1148
ORA-06512: at line 7


