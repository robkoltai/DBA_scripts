https://mikedietrichde.com/2015/07/30/sql-monitoring-limitation-at-300-lines-per-statement/

SQL> alter system set "_sqlmon_max_planlines"=800 scope=both;
or set in your spfile:
_sqlmon_max_planlines=800

