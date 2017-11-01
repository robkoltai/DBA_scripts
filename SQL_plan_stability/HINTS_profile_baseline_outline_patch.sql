rem     https://jonathanlewis.wordpress.com/2017/06/12/dbms_sqldiag/
rem     sql_profile_baseline_11g.sql
rem     J.P.Lewis
rem     July 2010
rem
 
set pagesize 60
set linesize 132
set trimspool on
 
column hint format a70 wrap word
column signature format 999,999,999,999,999,999,999
 
break on signature skip 1 on opt_type skip 1 on plan_id skip 1
 
spool sql_profile_baseline_11g
 
select
        prf.signature,
        decode(
                obj_type,
                1,'Profile',
                2,'Baseline',
                3,'Patch',
                'Other'
        )       opt_type,
        prf.plan_id,
        extractvalue(value(tab),'.')    hint
from
        (
        select
                /*+ no_eliminate_oby */
                *
        from
                sqlobj$data
        where
                comp_data is not null
        order by
                signature, obj_type, plan_id
        )       prf,
        table(
                xmlsequence(
                        extract(xmltype(prf.comp_data),'/outline_data/hint')
                )
        )       tab
;

/*

                   SIGNATURE OPT_TYPE    PLAN_ID HINT
---------------------------- -------- ---------- ----------------------------------------------------------------------
   6,474,234,632,354,066,941 Patch             0 no_index(t i_t)

*/