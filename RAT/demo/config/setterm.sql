-- for a big long clob or HTML report

SET TRIMSPOOL ON
SET TRIMOUT ON
set heading off
set lines 32767
set feedback off
set echo off
set long 9900000
set longchunksize 9900000
set pages 0
set serveroutput on;