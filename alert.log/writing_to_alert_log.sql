exec dbms_system.ksdwrt(1, 'This message goes to trace file in the udump location');
exec dbms_system.ksdwrt(2, 'This message goes to the alert log');
exec dbms_system.ksdwrt(3, 'This message goes to the alert log and trace file in the udump location');



To test whether your monitoring tool captures error messages such as an ORA-00600, try executing the below:
        
exec dbms_system.ksdwrt(2, 'ORA-00666: Testing monitoring tool');


--- alert.log writes new timestamp every 10 seconds for every session
-- This is the testcase
declare
 i number;
begin

for i in 1..500 loop
  dbms_lock.sleep (1/20);
  dbms_system.ksdwrt(2, 'ORA-11111: Testing');
end loop;
end;
/

 
