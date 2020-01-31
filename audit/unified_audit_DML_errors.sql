-- ******************************
-- MINDEN DML (plus truncate) HIBA AUDITALASA, ha akarunk ilyet
-- Jobb mint a servererror trigger, mert konnyebben testreszabhato, minden fontos info megvan benne
-- Es lightweight-ebb (szerintem:)
-- ******************************
create audit policy DML_errs actions select, insert, delete, update, merge, truncate table; 
audit policy DML_errs whenever not successful;

select * from auditable_system_actions order by component, name;
select * from auditable_object_actions order by name;

