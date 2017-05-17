
set lines 500
set trimspool on
set heading off
set feedback off
set termout off

spool create_datafile_image_copies.rcv

select 'run {' ||chr(10)||chr(13)||
       '     allocate channel c1 device type disk format ''&target_directory' || regexp_replace(name,'.*\/(.*)','\1') ||'.iub'';' ||chr(10)||chr(13)||
       '     backup incremental level 1 for recover of copy with tag ''IUB_' || file# ||''' datafile '||file#||';' ||chr(10)||chr(13)||
       '     release channel c1;' ||chr(10)||chr(13)||
       '}'
  from v$datafile
;

spool off


-- generating incremental backup scripts:

spool datafiles_incremental_update.rcv

select 'run {' ||chr(10)||chr(13)||
       '     backup incremental level 1 for recover of copy with tag ''IUB_' || file# ||''' datafile '||file#||';' ||chr(10)||chr(13)||
       '     recover copy of datafile '||file#||' with tag ''IUB_' || file# ||''';' ||chr(10)||chr(13)||
       '}'
  from v$datafile
;

spool off