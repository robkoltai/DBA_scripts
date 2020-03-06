-- DROP SQLSET

select d.name
FROM wri$_sqlset_definitions d, wri$_sqlset_references r
WHERE d.name = 'THE_FOUR_COMMANDS_SQLSET'
AND r.sqlset_id = d.id;    
   
delete from wri$_sqlset_references
where sqlset_id in (select id
                  from wri$_sqlset_definitions
                  where name ='THE_FOUR_COMMANDS_SQLSET'
                  );   
commit;
		
-- DROP schema
drop user rat cascade;

-- DROP tablespace
-- drop tablespace RAT including contents and datafiles;

-- INIT params back to orig
alter system set cursor_sharing=exact;
alter system set optimizer_index_cost_adj=100;
alter system set statistics_level=all;

@/home/oracle/RAT/config/setup_pre_change_init_parameters.sql