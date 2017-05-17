-- As recommended in Metalink Note:560331.1
--
-- This is necessary since the setting for use_stored_outlines
-- does not persist across instance bounces.
create or replace trigger enable_outlines
after startup on database
begin
execute immediate('alter system set use_stored_outlines=true');
end;
/
show errors

