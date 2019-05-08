select 
  to_char(snap_time,'YYYY-MM-DD HH24:MI') snap_time,u.snap_id,  
  plan_hash_value, sql_id, old_hash_value ,startup_time, u.*
from perfstat.STATS$SQL_PLAN_USAGE u, perfstat.STATS$SNAPSHOT sn
where sn.snap_id=u.snap_id and
      --sql_id = '6fv9dwc2g0b6g'
	  old_hash_value = 1231231231
order by 1;

/*
        SNAP_TIME       SNAP_ID PLAN_HASH_VALUE SQL_ID  STARTUP_TIME    SNAP_ID DBID    INSTANCE_NUMBER OLD_HASH_VALUE  TEXT_SUBSET     PLAN_HASH_VALUE HASH_VALUE      SQL_ID  COST    ADDRESS OPTIMIZER       LAST_ACTIVE_TIME
1       2017-06-20 13:00        113656  3334512399      6fv9dwc2g0b6g   18.05.2017 22:31:40     113656  1284939360      1       3311557237      select * from (select rownum rn 3334512399      82848975        6fv9dwc2g0b6g   48102   00000006DA9152D0        ALL_ROWS        20.06.2017 13:00:26
2       2017-06-20 14:00        113664  3334512399      6fv9dwc2g0b6g   18.05.2017 22:31:40     113664  1284939360      1       3311557237      select * from (select rownum rn 3334512399      82848975        6fv9dwc2g0b6g   48102   00000006DA9152D0        ALL_ROWS        20.06.2017 14:00:12
3       2017-06-20 14:42        113665  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113665  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   26398   00000006DA9152D0        ALL_ROWS        20.06.2017 14:42:15
4       2017-06-20 14:42        113665  3334512399      6fv9dwc2g0b6g   18.05.2017 22:31:40     113665  1284939360      1       3311557237      select * from (select rownum rn 3334512399      82848975        6fv9dwc2g0b6g   48102   00000006DA9152D0        ALL_ROWS        20.06.2017 14:41:37
5       2017-06-20 14:52        113666  3334512399      6fv9dwc2g0b6g   18.05.2017 22:31:40     113666  1284939360      1       3311557237      select * from (select rownum rn 3334512399      82848975        6fv9dwc2g0b6g   -9      00000006DA9152D0        ALL_ROWS        20.06.2017 14:41:37
6       2017-06-20 14:52        113666  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113666  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   26398   00000006DA9152D0        ALL_ROWS        20.06.2017 14:52:19
7       2017-06-20 14:52        113666  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113666  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   27167   00000006DA9152D0        ALL_ROWS        20.06.2017 14:48:24
8       2017-06-20 15:00        113674  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113674  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   27167   00000006DA9152D0        ALL_ROWS        20.06.2017 14:48:24
9       2017-06-20 15:00        113674  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113674  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   26398   00000006DA9152D0        ALL_ROWS        20.06.2017 14:52:19
10      2017-06-20 15:00        113674  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113674  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   28801   00000006DA9152D0        ALL_ROWS        20.06.2017 15:00:09
11      2017-06-20 15:00        113674  3334512399      6fv9dwc2g0b6g   18.05.2017 22:31:40     113674  1284939360      1       3311557237      select * from (select rownum rn 3334512399      82848975        6fv9dwc2g0b6g   -9      00000006DA9152D0        ALL_ROWS        20.06.2017 14:41:37
12      2017-06-20 16:00        113675  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113675  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   28801   00000006DA9152D0        ALL_ROWS        20.06.2017 16:00:15
13      2017-06-20 16:00        113675  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113675  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   -9      00000006DA9152D0        ALL_ROWS        20.06.2017 15:09:48
14      2017-06-20 17:00        113676  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113676  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   -9      00000006DA9152D0        ALL_ROWS        20.06.2017 15:09:48
15      2017-06-20 17:00        113676  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113676  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   28801   00000006DA9152D0        ALL_ROWS        20.06.2017 17:00:18
16      2017-06-20 18:00        113677  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113677  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   28801   00000006DA9152D0        ALL_ROWS        20.06.2017 18:00:04
17      2017-06-20 18:00        113677  1782583579      6fv9dwc2g0b6g   18.05.2017 22:31:40     113677  1284939360      1       3311557237      select * from (select rownum rn 1782583579      82848975        6fv9dwc2g0b6g   -9      00000006DA9152D0        ALL_ROWS        20.06.2017 15:09:48

*/