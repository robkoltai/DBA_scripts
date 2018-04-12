column statistic format a25

select * 
from V$PX_PROCESS_SYSSTAT 
--where STATISTIC like 'Servers%'
order by 1;

/*

STATISTIC                      VALUE     CON_ID
------------------------- ---------- ----------
TATISTIC                      VALUE     CON_ID
------------------------- ---------- ----------
Buffers Allocated                  0          0
Buffers Current                    0          0
Buffers Freed                      0          0
Buffers HWM                        0          0
Memory Chunks Allocated            4          0
Memory Chunks Current              4          0
Memory Chunks Freed                0          0
Memory Chunks HWM                  4          0
Server Sessions                    0          0
Servers Available                  8          0
Servers Cleaned Up                 0          0
Servers Highwater                  0          0
Servers In Use                     0          0
Servers Shutdown                   0          0
Servers Started                    8          0
*/

