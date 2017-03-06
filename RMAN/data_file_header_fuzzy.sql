
https://www.pythian.com/blog/recovering-an-oracle-database-with-missing-redo/

select fuzzy, status, checkpoint_change#,
        to_char(checkpoint_time, 'DD-MON-YYYY HH24:MI:SS') as checkpoint_time,
        count(*)
    from v$datafile_header
    group by fuzzy, status, checkpoint_change#, checkpoint_time
    order by fuzzy, status, checkpoint_change#, checkpoint_time;

FUZZY STATUS  CHECKPOINT_CHANGE# CHECKPOINT_TIME        COUNT(*)
----- ------- ------------------ -------------------- ----------
NO    ONLINE              647929 26-FEB-2015 16:58:14          1
YES   ONLINE              551709 26-FEB-2015 15:59:43          4


The fact that there are two rows returned and that not all files have FUZZY=NO indicates that we have a problem and that more redo is required before the database can be opened with the RESETLOGS option.
But our problem is that we don’t have that redo and we’re desperate to open our database anyway


fuzzy file

A data file that contains at least one block with an SCN greater than or equal to the checkpoint SCN in the data file header. 
Fuzzy files are possible because database writer does not update the SCN in the file header with each file block write. 
For example, this situation occurs when Oracle updates a data file that is in backup mode. A fuzzy file that is restored always requires media recovery.

