
-- Show one plan of one baseline
select * from table( dbms_xplan.display_sql_plan_baseline(SQL_96357be8272d0db2,SQL_PLAN_9cdbvx0mku3dkcd48b145));

-- Shall all plans for one SQL
select x.*
from dba_sql_plan_baselines basel,
table( dbms_xplan.display_sql_plan_baseline(basel.sql_handle,basel.plan_name) ) x
where basel.handle='&handle';
--SQL_96357be8272d0db2

