
cleanup  			-- truncate tables
create_t1 			-- create testdata
ipar.sql 			-- create index in parallel
create_user_ts		-- tablespace
env.sql				--
manual_kicsi, manual_nagy 		-- workarea_size
measure				-- needs to run in parallel with the test itself
postprocess			-- inserts the missing lines with 0s
QUERIES				-- use it in TOAD, SQLDEVELOPER
runtest.sh			-- THIS IS THE SHELL SCRIPT TO RUN
set_module			-- helper to be able to identify the database sesssions working on the test
test_par			-- THIS IS THE MAIN TEST SQL SCRIPT FOR PARALLEL TESTING
