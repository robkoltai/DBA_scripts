
select NAME, VALUE 
from GV$SYSSTAT  
  where upper(NAME) like '%PARALLEL OPERATIONS%'
     or upper(NAME) like '%PARALLELIZED%' or upper(NAME) like '%PX%';
     
     
/*


NAME                                                                  VALUE
---------------------------------------------------------------- ----------
queries parallelized                                                      0
DML statements parallelized                                               0
DDL statements parallelized                                               0
DFO trees parallelized                                                    0
Parallel operations not downgraded                                        0
Parallel operations downgraded to serial                                  0
Parallel operations downgraded 75 to 99 pct                               0
Parallel operations downgraded 50 to 75 pct                               0
Parallel operations downgraded 25 to 50 pct                               0
Parallel operations downgraded 1 to 25 pct                                0
PX local messages sent                                                    0
PX local messages recv'd                                                  0
PX remote messages sent                                                   0
PX remote messages recv'd                                                 0

14 rows selected.


*/