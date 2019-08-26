-- Call Syntax  : @cbo_fix_control (phrase | all) (version | all)

SET VERIFY OFF
SET LINESIZE 300

COLUMN sql_feature FORMAT A35
COLUMN optimizer_feature_enable FORMAT A9

SELECT *
FROM   v$system_fix_control
WHERE  LOWER(description) LIKE DECODE('&1', 'all', '%', '%&1%')
AND    optimizer_feature_enable = DECODE('&2', 'all', optimizer_feature_enable, '&2');

/*



select * from v$system_fix_control
where bugno = 25575369;

alter system Set "_fix_control"= '25575369:1';
alter system Set "_fix_control"= '25575369:ON';


*/