--lsinventory listazza a patcheket:

/*
oracle@dwhtest:/oracle/app/oracle/product/12.1.0/dbhome_1/OPatch 2020.03.25 21:46:44$ ./opatch lsinventory
Oracle Interim Patch Installer version 12.2.0.1.19
Copyright (c) 2020, Oracle Corporation.  All rights reserved.


Oracle Home       : /oracle/app/oracle/product/12.1.0/dbhome_1
Central Inventory : /oracle/app/oraInventory
   from           : /oracle/app/oracle/product/12.1.0/dbhome_1/oraInst.loc
OPatch version    : 12.2.0.1.19
OUI version       : 12.1.0.2.0
Log file location : /oracle/app/oracle/product/12.1.0/dbhome_1/cfgtoollogs/opatch/opatch2020-03-25_21-46-53PM_1.log

Lsinventory Output file location : /oracle/app/oracle/product/12.1.0/dbhome_1/cfgtoollogs/opatch/lsinv/lsinventory2020-03-25_21-46-53PM.txt
--------------------------------------------------------------------------------
Local Machine Information::
Hostname: dwhtest
ARU platform id: 212
ARU platform description:: IBM_AIX

Installed Top-level Products (1):

Oracle Database 12c                                                  12.1.0.2.0
There are 1 products installed in this Oracle Home.

Interim patches (2) :

Patch  20920911     : applied on Tue Nov 05 09:39:20 CET 2019
Unique Patch ID:  18959940
   Created on 24 Jul 2015, 11:45:30 hrs PST8PDT
   Bugs fixed:
     20920911

Patch  20345554     : applied on Fri Oct 25 15:59:18 CEST 2019
Unique Patch ID:  19765745
   Created on 6 May 2016, 16:47:44 hrs PST8PDT
   Bugs fixed:
     20345554

--------------------------------------------------------------------------------
*/

--SQLPATCH 
SQL> select * from dba_registry_sqlpatch;
/*
  PATCH_ID  PATCH_UID VERSION              FLAGS      ACTION          STATUS          ACTION_TIME                                                                 DESCRIPTION                                                                                          BUNDLE_SERIES                   BUNDLE_ID
---------- ---------- -------------------- ---------- --------------- --------------- --------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------- ------------------------------ ----------
BUNDLE_DATA
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LOGFILE
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  20345554   19765745 12.1.0.2             N          APPLY           SUCCESS         25-OCT-19 04.00.08.870675 PM

/oracle/app/oracle/cfgtoollogs/sqlpatch/20345554/19765745/20345554_apply_AIXDW_2019Oct25_15_59_57.log
*/

--or even better
set serveroutput on;
exec dbms_qopatch.get_sqlpatch_status;
/*
Patch Id : 20345554
        Action : APPLY
        Action Time : 25-OCT-2019 16:00:08
        Description :
        Logfile : /oracle/app/oracle/cfgtoollogs/sqlpatch/20345554/19765745/20345554_apply_AIXDW_2019Oct25_15_59_57.log
        Status : SUCCESS

PL/SQL procedure successfully completed.
*/


--Queryable patch interface
/*
Document 1585814.1 Queryable Patch Inventory -- SQL Interface to view, compare, validate database patches
Document 1530108.1 Oracle Database 12.1 : FAQ on Queryable Patch Inventory
Database PL/SQL Packages and Types Reference - DBMS_QOPATCH
*/
-- ***************************

set long 2000000
set longch 2000000
select * from opatch_xml_inv;

/*
1. Select against the opatch_xml_inv (external table) 
2. Execution of opatch lsinventory -xml (pre-processor program) 
3. Load inventory data into table(s) 
*/


-- Directories 


SQL>  select directory_name , directory_path from dba_directories where directory_name like '%PATCH%';
/*

DIRECTORY_NAME
--------------------------------------------------------------------------------------------------------------------------------
DIRECTORY_PATH
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
OPATCH_SCRIPT_DIR
/oracle/app/oracle/product/12.1.0/dbhome_1/QOpatch

OPATCH_LOG_DIR
/oracle/app/oracle/product/12.1.0/dbhome_1/QOpatch

OPATCH_INST_DIR
/oracle/app/oracle/product/12.1.0/dbhome_1/OPatch


-- OS level
/oracle/app/oracle/product/12.1.0/dbhome_1/QOpatch
oracle@dwhtest:/oracle/app/oracle/product/12.1.0/dbhome_1/QOpatch 2020.03.27 10:06:10$ ls -l
total 6152
-rw-r--r--    1 oracle   dba           63355 Mar 27 10:00 qopatch_log.log
-r-xr-xr--    1 oracle   dba            1377 Mar 26 16:35 qopiprep.bat
-r-xr-xr--    1 oracle   dba            1372 Mar 26 16:32 qopiprep.bat_ORIG
-rw-r--r--    1 oracle   dba         3074700 Mar 27 10:00 xml_file.xml_bak		-- xml is just a temporary file created by the query: 
																				-- I made a manual snapshot by running: cp  xml_file.xml xml_file.xml_bak
oracle@dwhtest:/oracle/app/oracle/product/12.1.0/dbhome_1/QOpatch 2020.03.27

*/

-- List everything also binaries
set long 20000000
set longch 20000000
-- minden bakker
-- WITH FILES AS WELL
select xmltransform(dbms_qopatch.GET_OPATCH_LIST(),dbms_qopatch.get_opatch_xslt()) from dual;

-- Only bugs
select xmltransform(dbms_qopatch.GET_OPATCH_BUGS(),dbms_qopatch.get_opatch_xslt()) from dual;

-- Lsinventory with files touched as well
select xmltransform(DBMS_QOPATCH.GET_OPATCH_LSINVENTORY, DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

-- install info
select xmltransform(DBMS_QOPATCH.GET_OPATCH_INSTALL_INFO, DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;
/*
SQL> select xmltransform(DBMS_QOPATCH.GET_OPATCH_INSTALL_INFO, DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

XMLTRANSFORM(DBMS_QOPATCH.GET_OPATCH_INSTALL_INFO,DBMS_QOPATCH.GET_OPATCH_XSLT)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Oracle Home       : /oracle/app/oracle/product/12.1.0/dbhome_1
Inventory         : /oracle/app/oraInventory


*/

-- olays ???
select xmltransform(DBMS_QOPATCH.GET_OPATCH_OLAYS, DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

-- What is pending??
select xmltransform(DBMS_QOPATCH.GET_PENDING_ACTIVITY, DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

/*
XMLTRANSFORM(DBMS_QOPATCH.GET_PENDING_ACTIVITY,DBMS_QOPATCH.GET_OPATCH_XSLT)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Oracle Querayable Patch Interface 1.0
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Installed Top-level Products (1):

Installed Products ( 0)




*/ 
 
-- Does not exist in 12.1.0.2
select xmltransform(DBMS_QOPATCH.GET_SQLPATCH_STATUS , DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;


-- Is patch installed ??

--NOT INSTALLED
select xmltransform(DBMS_QOPATCH.IS_PATCH_INSTALLED(30046819) , DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

XMLTRANSFORM(DBMS_QOPATCH.IS_PATCH_INSTALLED(30046819),DBMS_QOPATCH.GET_OPATCH_X
--------------------------------------------------------------------------------


-- INSTALLED
select xmltransform(DBMS_QOPATCH.IS_PATCH_INSTALLED(30502041) , DBMS_QOPATCH.GET_OPATCH_XSLT) from dual;

XMLTRANSFORM(DBMS_QOPATCH.IS_PATCH_INSTALLED(30502041),DBMS_QOPATCH.GET_OPATCH_X
--------------------------------------------------------------------------------

Patch Information:
         30502041:   applied on 2020-03-27T12:06:35+01:00

select xmltransform(DBMS_QOPATCH.IS_PATCH_INSTALLED(&patch_id) , DBMS_QOPATCH.GET_OPATCH_XSLT) from dual; 


-- PATCH_CONFLICT_DETECTION Function


-- Ez a tutko PSU
https://blog.pythian.com/oracle-database-12c-patching-dbms_qopatch-opatch_xml_inv-and-datapatch/
with a as (select dbms_qopatch.get_opatch_lsinventory patch_output from dual)
   select x.*
     from a,
          xmltable('InventoryInstance/patches/*'
             passing a.patch_output
             columns
                patch_id number path 'patchID',
                patch_uid number path 'uniquePatchID',
                description varchar2(80) path 'patchDescription',
                applied_date varchar2(30) path 'appliedDate',
                sql_patch varchar2(8) path 'sqlPatch',
                rollbackable varchar2(8) path 'rollbackable'
          ) x;

/*


  PATCH_ID  PATCH_UID DESCRIPTION                                                                      APPLIED_DATE                   SQL_PATC ROLLBACK
---------- ---------- -------------------------------------------------------------------------------- ------------------------------ -------- --------
  22113854   22587591                                                                                  2020-03-28T23:31:28+01:00      true     true
  23321926   23335871                                                                                  2020-03-28T23:28:48+01:00      false    true
  18167823   23315232                                                                                  2020-03-28T23:26:24+01:00      true     true
  23003919   23403442                                                                                  2020-03-28T23:17:57+01:00      false    true
  30751917   23335938                                                                                  2020-03-28T23:14:36+01:00      false    true
  31040209   23459392                                                                                  2020-03-28T22:57:19+01:00      true     true
  30502041   23261069 Database PSU 12.1.0.2.200114, Oracle JavaVM Component (JAN2020)                  2020-03-27T12:06:35+01:00      true     true
  30364137   23326086 Database Bundle Patch : 12.1.0.2.200114 (30364137)                               2020-03-26T15:47:36+01:00      true     true
  29972716   23135664 Database Bundle Patch : 12.1.0.2.191015 (29972716)                               2020-03-26T15:47:27+01:00      true     true
  29496791   23005129 Database Bundle Patch : 12.1.0.2.190716 (29496791)                               2020-03-26T15:47:14+01:00      true     true
  29141038   22814142 Database Bundle Patch : 12.1.0.2.190416 (29141038)                               2020-03-26T15:46:53+01:00      true     true

  PATCH_ID  PATCH_UID DESCRIPTION                                                                      APPLIED_DATE                   SQL_PATC ROLLBACK
---------- ---------- -------------------------------------------------------------------------------- ------------------------------ -------- --------
  28731800   22657087 Database Bundle Patch : 12.1.0.2.190115 (28731800)                               2020-03-26T15:46:41+01:00      true     true
  28259867   22500605 Database Bundle Patch : 12.1.0.2.181016 (28259867)                               2020-03-26T15:46:34+01:00      true     true
  27547374   22339070 Database Bundle Patch : 12.1.0.2.180717 (27547374)                               2020-03-26T15:46:26+01:00      true     true
  27338029   22064709 Database Bundle Patch : 12.1.0.2.180417 (27338029)                               2020-03-26T15:46:13+01:00      true     true
  26925263   21857594 Database Bundle Patch : 12.1.0.2.180116 (26925263)                               2020-03-26T15:46:03+01:00      true     true
  26717470   21618016 Database Bundle Patch : 12.1.0.2.171017 (26717470)                               2020-03-26T15:45:55+01:00      true     true
  26609798   21489850 DATABASE BUNDLE PATCH: 12.1.0.2.170814 (26609798)                                2020-03-26T15:45:39+01:00      true     true
  25869760   21420970 DATABASE BUNDLE PATCH: 12.1.0.2.170718 (25869760)                                2020-03-26T15:45:37+01:00      true     true
  25397136   21156307 DATABASE BUNDLE PATCH: 12.1.0.2.170418 (25397136)                                2020-03-26T15:45:27+01:00      true     true
  24732088   20932549 DATABASE BUNDLE PATCH: 12.1.0.2.170117 (24732088)                                2020-03-26T15:45:16+01:00      true     true
  24340679   20713280 DATABASE BUNDLE PATCH: 12.1.0.2.161018 (24340679)                                2020-03-26T15:44:59+01:00      true     true

  PATCH_ID  PATCH_UID DESCRIPTION                                                                      APPLIED_DATE                   SQL_PATC ROLLBACK
---------- ---------- -------------------------------------------------------------------------------- ------------------------------ -------- --------
  23144544   20355564 DATABASE BUNDLE PATCH: 12.1.0.2.160719 (23144544)                                2020-03-26T15:44:51+01:00      true     true
  22806133   20099908 DATABASE BUNDLE PATCH: 12.1.0.2.160419 (22806133)                                2020-03-26T15:44:42+01:00      true     true
  21949015   19651699 DATABASE BUNDLE PATCH: 12.1.0.2.160119 (21949015)                                2020-03-26T15:44:25+01:00      true     true
  21694919   19417500 DATABASE BUNDLE PATCH: 12.1.0.2.13 (21694919)                                    2020-03-26T15:44:16+01:00      true     true
  21125181   19063656 DATABASE BUNDLE PATCH: 12.1.0.2.10 (21125181)                                    2020-03-26T15:44:08+01:00      true     true
  20594149   18729034 DATABASE BUNDLE PATCH: 12.1.0.2.7 (20594149)                                     2020-03-26T15:44:03+01:00      true     true
  20075921   18370066 DATABASE BUNDLE PATCH: 12.1.0.2.4 (20075921)                                     2020-03-26T15:43:43+01:00      true     true

29 rows selected.

*/
