-- This is it:
https://blogs.oracle.com/optimizer/how-to-gather-optimizer-statistics-fast


select dbms_stats.get_prefs ('DEGREE','PORT','PREND') from dual;
exec dbms_stats.set_table_prefs('PORT', 'PREND', 'DEGREE', 4);
