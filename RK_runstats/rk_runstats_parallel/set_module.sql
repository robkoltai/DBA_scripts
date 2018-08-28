BEGIN
  DBMS_APPLICATION_INFO.set_module(module_name => 'RK_RUNSTAT',
                                   action_name => '&1');
  
END;
/
