select 
  min(snap_time), min(u.snap_id), 
  max(snap_time),   max(u.snap_id), 
  count(1) count#, plan_hash_value, sql_id, startup_time
from perfstat.STATS$SQL_PLAN_USAGE u, perfstat.STATS$SNAPSHOT sn
where sn.snap_id=u.snap_id and
      sql_id = 'bfmdnsc2ryz2s'
group by  plan_hash_value, sql_id, startup_time
order by 1;

/*                                                                      count  plan hash value sql_id
1       06.06.2017 17:00:03     113036  16.06.2017 16:00:01     113485  101     3449984569      bfmdnsc2ryz2s   18.05.2017 22:31:40
2       06.06.2017 17:00:03     113036  06.06.2017 22:00:03     113041  7       2828538599      bfmdnsc2ryz2s   18.05.2017 22:31:40
3       06.06.2017 17:00:03     113036  14.06.2017 15:00:01     113364  7       3417736905      bfmdnsc2ryz2s   18.05.2017 22:31:40
4       06.06.2017 17:00:03     113036  06.06.2017 22:00:03     113041  25      3297001016      bfmdnsc2ryz2s   18.05.2017 22:31:40
5       10.06.2017 16:00:03     113205  10.06.2017 19:00:03     113208  4       1169437417      bfmdnsc2ryz2s   18.05.2017 22:31:40
*/