

-- 10.1.1.180 hoszton
. /home/oracle/uni.env

-- RUN the setup scripts
cd /home/oracle/RAT/setup
sqlplus / as sysdba
 @setup_RAT_demo.sql

-- Run the load
chmod u+x /home/oracle/RAT/run/*sh
cd /home/oracle/RAT/run/

./runit_now.sh


-- SPA create 	SQL TUNING SET
--     load 	SQL TUNING SET
SPA_create_and_load_SQLSET.sql



-- SPA 	run tests
--		and report
SPA_run_tests_and_report.sql

------------------------------------ DB REPLAY
CAPTURE
20200305 13:11:00	20200305 13:23:12		3031 3033

Replay client 1 started (14:53:27)	3036
Replay client 1 finished (15:07:07) 3038
