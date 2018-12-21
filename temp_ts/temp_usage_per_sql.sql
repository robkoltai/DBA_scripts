 SELECT sysdate "TIME_STAMP", vsu.username, vs.sid, vp.spid, vs.sql_id, vst.sql_text, vsu.tablespace,
        sum_blocks*dt.block_size/1024/1024 usage_mb
    FROM
    (
            SELECT username, sqladdr, sqlhash, sql_id, tablespace, session_addr,
 -- sum(blocks)*8192/1024/1024 "USAGE_MB",
                 sum(blocks) sum_blocks
            FROM v$sort_usage
            HAVING SUM(blocks)> 1000
            GROUP BY username, sqladdr, sqlhash, sql_id, tablespace, session_addr
    ) "VSU",
    v$sqltext vst,
    v$session vs,
    v$process vp,
    dba_tablespaces dt
 WHERE vs.sql_id = vst.sql_id
 -- AND vsu.sqladdr = vst.address
 -- AND vsu.sqlhash = vst.hash_value
    AND vsu.session_addr = vs.saddr
    AND vs.paddr = vp.addr
    AND vst.piece = 0
    AND dt.tablespace_name = vsu.tablespace
 order by usage_mb   ;      
 
 /*
 
TIME_STAM USERNAME                              SID SPID                     SQL_ID        SQL_TEXT                                                         TABLESPACE                        USAGE_MB
--------- ------------------------------ ---------- ------------------------ ------------- ---------------------------------------------------------------- ------------------------------- ----------
17-MAY-25 VESZE_AG                             1400 14466                    bzsd9y04su23y SELECT SZAFAZ,SZASAZ,V_NEV,FOGYDATTOL,FOGYDATIG,FOSZAZ,KOMPAZ,ME TEMPU                                    2
17-MAY-25 HORDOS_NI                             722 27511                    fhkbt68d8gur9 SELECT NEV,SZERVEGY   FROM DOLGOZO  WHERE DBRTDOLGKOD = :b1      TEMP                                     3
17-MAY-25 KOVER_EV                              379 24130                    bzsd9y04su23y SELECT SZAFAZ,SZASAZ,V_NEV,FOGYDATTOL,FOGYDATIG,FOSZAZ,KOMPAZ,ME TEMP                                     3
17-MAY-25 BUDAI_SU_ZS                           143 10708                    cch37sbt5v7jw SELECT ROGZ_NEV,KINEL,KOVNEV,VISSZNEV,JELNEV,ESNEV,TEHOAZ,ESKOD, TEMP                                     4
17-MAY-25 VIRAG_MO2                            1515 24466                    0qn04kmuwcarj SELECT /DISTINCT U.UGYFKOD FOGYTIPKOD,U.DUNEV FONEV,S TEMP                                                4
17-MAY-25 EGRINE_PA_KR                         1180 15739                    cch37sbt5v7jw SELECT ROGZ_NEV,KINEL,KOVNEV,VISSZNEV,JELNEV,ESNEV,TEHOAZ,ESKOD, TEMP                                     4


*/