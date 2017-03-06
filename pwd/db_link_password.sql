
Starting with Oracle 11.2.0.2, Oracle salts the password hashes, therefore you will need to crack the password and cannot just query it. However, if the database link was created pre-11.2.0.2, the password is saved in an “old” format without the salt. To check if there are any database links with this old format, query SYS.LINK$ like so:

SQL> select name, userid from sys.link$ where length(passwordx)=50;

NAME                                USERID
----------------------------------- ------------------------------
MYDBLINKNAME                        SIMON
So now we’ve found a database link with a password in the old format, get the encrypted password from the same table:

SQL> select passwordx from sys.link$ where name='MYDBLINKNAME';

PASSWORDX
--------------------------------------------------
0560A31A6EFEC902B9286FFC981F4C9A92F8470D406ADEA670
With this information, we can use the following PL/SQL block (found in the blog of Satyanarayana Murty Munukutla) to calculate the plain password:

set serveroutput on
declare
 db_link_password varchar2(100);
begin
 db_link_password := '0560A31A6EFEC902B9286FFC981F4C9A92F8470D406ADEA670';
 
 dbms_output.put_line ('Plain password: ' || utl_raw.cast_to_varchar2 ( dbms_crypto.decrypt ( substr (db_link_password, 19) , dbms_crypto.DES_CBC_PKCS5 , substr (db_link_password, 3, 16) ) ) );
end;
/