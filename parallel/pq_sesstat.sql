column statistic format a25

select * from V$PQ_SESSTAT
order by 1;

/*
STATISTIC                 LAST_QUERY SESSION_TOTAL     CON_ID
------------------------- ---------- ------------- ----------
Allocation Height                  0             0          0
Allocation Width                   0             0          0
DDL Parallelized                   0             0          0
DFO Trees                          0             0          0
DML Parallelized                   0             0          0
DOP                                0             0          0
Distr Msgs Recv'd                  0             0          0
Distr Msgs Sent                    0             0          0
Local Msgs Recv'd                  0             0          0
Local Msgs Sent                    0             0          0
Queries Parallelized               0             0          0
Server Threads                     0             0          0
Slave Sets                         0             0          0


*/