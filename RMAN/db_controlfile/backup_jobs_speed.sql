column INPUT_BYTES_PER_SEC_DISPLAY format a12
column OUTPUT_BYTES_PER_SEC_DISPLAY format a12

select session_key, 
       --SESSION_RECID, 
	   START_TIME, END_TIME, round(INPUT_BYTES/1e9,2) input_GB, round(OUTPUT_BYTES/1e9,2) output_gb,
       STATUS, input_type, elapsed_seconds, round(INPUT_BYTES_PER_SEC) as INPUT_BYTES_PER_SEC, INPUT_BYTES_PER_SEC_DISPLAY, OUTPUT_BYTES_PER_SEC_DISPLAY 
from v$RMAN_BACKUP_JOB_DETAILS 
     where input_type <>'ARCHIVELOG' 
	 --and round(INPUT_BYTES/1e9,2)> 50
order by start_time;


/*

SESSION_KEY START_TIM END_TIME    INPUT_GB  OUTPUT_GB STATUS     INPUT_TYPE       SECONDS INPUT_BYTES_PER_SEC INPUT_BYTES_ OUTPUT_BYTES
----------- --------- --------- ---------- ---------- ---------- ------------- ---------- ------------------- ------------ ------------
     177612 17-MAR-25 17-MAR-25      35,01       2,13 COMPLETED  DB INCR              715            48959177    46.69M        2.84M
     177507 17-MAR-26 17-MAR-26    3781,57    3681,75 COMPLETED  DB INCR            58323            64838478    61.83M       60.20M
     177700 17-MAR-26 17-MAR-26      22,05         ,2 COMPLETED  DB INCR              571            38620801    36.83M      334.96K
     177786 17-MAR-27 17-MAR-27      132,8      25,14 COMPLETED  DB INCR             3362            39500640    37.67M        7.13M
     177869 17-MAR-28 17-MAR-28      55,64       3,44 COMPLETED  DB INCR             1259            44190903    42.14M        2.61M
     177952 17-MAR-29 17-MAR-29      44,77       2,11 COMPLETED  DB INCR              929            48192020    45.96M        2.16M
     178035 17-MAR-30 17-MAR-30      97,11      23,63 COMPLETED  DB INCR             2353            41271083    39.36M        9.58M
     178088 17-MAR-31 17-APR-04    7719,72    4603,91 COMPLETED  DB INCR           295934            26085945    24.88M       14.84M
     178193 17-APR-01 17-APR-01     113,69      18,87 COMPLETED  DB INCR             3324            34202604    32.62M        5.41M
     178276 17-APR-02 17-APR-02      19,96        ,77 COMPLETED  DB INCR              755            26433156    25.21M      990.83K
     178364 17-APR-03 17-APR-03      148,7       28,9 COMPLETED  DB INCR             3682            40385839    38.51M        7.48M
     178450 17-APR-04 17-APR-04     131,52      28,48 COMPLETED  DB INCR             2785            47223674    45.04M        9.75M
     178533 17-APR-05 17-APR-05     153,71      31,88 COMPLETED  DB INCR             3150            48796368    46.54M        9.65M
     178616 17-APR-06 17-APR-06     203,29      55,86 COMPLETED  DB INCR             4401            46190748    44.05M       12.10M
     178663 17-APR-07 17-APR-09    8094,93    4848,97 COMPLETED  DB INCR           165528            48903699    46.64M       27.94M
     178760 17-APR-08 17-APR-08     164,67      68,62 COMPLETED  DB INCR             6666            24703513    23.56M        9.82M
     178834 17-APR-09 17-APR-09      71,52       9,57 COMPLETED  DB INCR             2412            29653575    28.28M        3.78M
     178916 17-APR-10 17-APR-10     225,16      64,37 COMPLETED  DB INCR             4630            48630373    46.38M       13.26M
     179035 17-APR-11 17-APR-11     110,63      13,74 COMPLETED  DB INCR             2618            42256437    40.30M        5.00M
     179118 17-APR-12 17-APR-12     259,76     112,71 COMPLETED  DB INCR             5412            47996958    45.77M       19.86M
     179201 17-APR-13 17-APR-13     252,25      95,71 COMPLETED  DB INCR             4620            54600623    52.07M       19.76M
     179254 17-APR-14 17-APR-16    8049,86    4822,68 FAILED     DB INCR           131792            61080062    58.25M       34.90M
     179362 17-APR-15 17-APR-15      21,29        ,44 COMPLETED  DB INCR              595            35786040    34.13M      718.63K
     179448 17-APR-16 17-APR-16      22,72        ,41 COMPLETED  DB INCR              586            38766064    36.97M      688.23K
     179521 17-APR-17 17-APR-17      33,29        ,69 COMPLETED  DB INCR              658            50600223    48.26M        1.00M
     179618 17-APR-18 17-APR-18     162,17       17,5 COMPLETED  DB INCR             2356            68833465    65.64M        7.08M

	 
	 */