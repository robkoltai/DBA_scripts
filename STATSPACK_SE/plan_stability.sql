select max(snap_id),min(snap_id), count(1) db, plan_hash_value, sql_id
from perfstat.STATS$SQL_PLAN_USAGE where sql_id = '43srdqz43dgu8'
group by  plan_hash_value, sql_id;

