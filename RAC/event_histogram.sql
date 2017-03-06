-- EVENT HISTOGRAM
SELECT inst_id, event, wait_time_milli, wait_count,
TRUNC(100*(wait_count/tot),2) per
FROM
(SELECT inst_id, event, wait_time_milli, wait_count,
SUM (wait_count) over(partition BY inst_id, event
order by inst_id
rows BETWEEN unbounded preceding AND unbounded following
) tot
FROM
(SELECT * FROM gv$event_histogram
WHERE event LIKE '%&event_name%'
ORDER BY inst_id, event#, WAIT_TIME_MILLI
)
)
ORDER BY inst_id, event, WAIT_TIME_MILLI ;

Enter value for event_name: gc cr block 2-way
INST_ID EVENT WAIT_TIME_MILLI WAIT_COUNT PER
---------- ------------------------------ --------------- ---------- ----------
1 gc cr block 2-way 1 105310 2.03
1 gc cr block 2-way 2 3461802 66.87
1 gc cr block 2-way 4 1593929 30.79
1 gc cr block 2-way 8 15163 .29
1 gc cr block 2-way 16 340 0
1 gc cr block 2-way 32 26 0