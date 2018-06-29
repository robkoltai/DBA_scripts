-- put this under a user who has read acces to v$ views
CREATE OR REPLACE PROCEDURE show_frc_dependencies ( 
   name_like_in   IN VARCHAR2 
 ,  action_in      IN VARCHAR2 DEFAULT NULL) 
IS 
BEGIN 
   DBMS_OUTPUT.put_line (RPAD ('-', 80, '-')); 
 
   DBMS_OUTPUT.put_line ( 
         CASE 
            WHEN action_in IS NOT NULL THEN action_in || ': ' 
            ELSE NULL 
         END 
      || 'Dependencies for "' 
      || name_like_in 
      || '"'); 
 
   FOR rec 
      IN (SELECT d.result_id 
               ,  TRANSLATE ( 
                     SUBSTR (res.name, 1, INSTR (res.name, ':') - 1) 
                   ,  'A"' 
                   ,  'A') 
                     function_name 
               ,  dep.name depends_on 
            FROM v$result_cache_dependency d 
               ,  v$result_cache_objects res 
               ,  v$result_cache_objects dep 
           WHERE     res.id = d.result_id 
                 AND dep.id = d.depend_id 
                 --AND res.name LIKE name_like_in
				 ) 
   LOOP 
      /* Do not include dependency on self */ 
      IF rec.function_name <> rec.depends_on 
      THEN 
         DBMS_OUTPUT.put_line ( 
            rec.function_name || ' depends on ' || rec.depends_on); 
      END IF; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (RPAD ('-', 80, '-')); 
END;
/


-- query existing VALID dependencies
exec show_frc_dependencies ('%%');
