 --https://www.red-gate.com/simple-talk/sql/oracle/spm-plan-non-reproducibility-circumstances-and-cbo-interaction/
 
 SELECT
               p.sql_id
              ,p.plan_hash_value
              ,p.child_number
              ,t.phv2
        FROM   v$sql_plan p
              ,xmltable('for $i in /other_xml/info
                        where $i/@type eq "plan_hash_2"
                        return $i'
                        passing xmltype(p.other_xml)
                        columns phv2 number path '/') t
          WHERE p.sql_id = '&1'
          and   p.other_xml is not null;
		  

/*

@phv2 ahufs9gr5x2pm

SQL_ID        PLAN_HASH_VALUE CHILD_NUMBER       PHV2
------------- --------------- ------------ ----------
ahufs9gr5x2pm      2219242098            0 2943285262


*/		  