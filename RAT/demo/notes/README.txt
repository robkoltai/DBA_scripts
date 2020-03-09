

-----------------------------------
-- Előadás előtt
-----------------------------------	
-- 10.1.1.180 hoszton
uni.env be van futtatva

chmod u+x /home/oracle/RAT/run/*sh
mv /oradata/RAT_CAPDIR /oradata/RAT_CAPDIR_back0309_CAPTURE01
mkdir /oradata/RAT_CAPDIR

ABLAKOK:
- alert
- SYS
- RAT
- os

-----------------------------------
-- SPA STEPS
-----------------------------------	

-- RUN THE SETUP SCRIPTS
cd /home/oracle/RAT/setup
sqlplus / as sysdba
@setup_RAT_demo.sql

-- PRE CHANGE PARAMETERS
@/home/oracle/RAT/config_SPA_pre_change_init_parameters.sql

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

-----------------------------------
-- DB REPLAY STEPS
-----------------------------------	
-- RUN THE SETUP SCRIPTS
cd /home/oracle/RAT/setup
sqlplus / as sysdba
@setup_RAT_demo.sql

-- SET UP PARAMETERS
@/home/oracle/RAT/config/config_DBREP_pre_change_init_parameters.sql

-- FOLLOW THE STEPS OF CAPTURE:
-- 






CAPTURE
20200305 13:11:00	20200305 13:23:12		3031 3033
Replay client 1 started (14:53:27)	3036
Replay client 1 finished (15:07:07) 3038


-- 