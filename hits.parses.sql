select cach.value cache_hits, prs.value all_parses,
  prs.value-cach.value sess_cur_cache_not_used
  from v$sesstat cach, v$sesstat prs, v$statname nm1, v$statname nm2
  where cach.statistic# = nm1.statistic#
  and nm1.name = 'session cursor cache hits'
  and prs.statistic#=nm2.statistic#
  and nm2.name= 'parse count (total)'
  and cach.sid= &sid and prs.sid= cach.sid
/
