column statistic format a25


select * from V$PQ_SYSSTAT
--where STATISTIC like 'Servers%'
order by 1;

/*
STATISTIC                      VALUE     CON_ID
------------------------- ---------- ----------
Servers Busy                       0          0
Servers Idle                       8          0
Servers Highwater                  0          0
Server Sessions                    0          0
Servers Started                    8          0
Servers Shutdown                   0          0
Servers Cleaned Up                 0          0
Queries Queued                     0          0
Queries Initiated                  0          0
Queries Initiated (IPQ)            0          0
DML Initiated                      0          0
DML Initiated (IPQ)                0          0
DDL Initiated                      0          0
DDL Initiated (IPQ)                0          0
DFO Trees                          0          0
Sessions Active                    0          0
Local Msgs Sent                    0          0
Distr Msgs Sent                    0          0
Local Msgs Recv'd                  0          0
Distr Msgs Recv'd                  0          0

*/

