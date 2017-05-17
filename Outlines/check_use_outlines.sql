--If 2nd & 3rd set of (8) numbers are != 0, then use_stored_outlines=true.
--
--        (Eg. qolprm sgauso_ [700000010020F58, 700000010020F7C) = 00000001
-- 00074445 4641554C 54000000 00000000 00000000 00000000 00000000 00000000)
--
-- -If both 2nd & 3rd sets are all 0sâ?¦ use_stored_outlines=false.
--
--        (Eg. qolprm sgauso_ [700000010020F58, 700000010020F7C) = 00000000
-- 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000)
--
-- >But the best way is just to "alter system set use_stored_outlines = true;"
-- anyway.  Altering the system again if you are expecting it to be on should not
-- cause an issue.
--
oradebug setmypid
oradebug dumpvar sga sgauso 100
