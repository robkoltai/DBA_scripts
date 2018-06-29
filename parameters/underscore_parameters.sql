-- Changed underscore

select 
   name, value
from 
   v$parameter 
where 
   substr(name, 0,1) ='_';

   
-- Underscore full details
set echo off lines 199 pages 100 feed off
clear col
clear break
clear compute
ttitle off
btitle off
COLUMN Param FORMAT a42 wrap head 'Underscore Parameter'
COLUMN Descr FORMAT a75 wrap head 'Description'
COLUMN SessionVal FORMAT a8 head 'Value|Session'
COLUMN DefVal FORMAT a8 head 'Default|Value'
COLUMN InstanceVal FORMAT a8 head 'Value|Instnc'
ttitle skip 1 center 'All Underscore Parameters' skip 2


SELECT 
a.ksppinm Param , 
b.ksppstvl SessionVal ,
c.ksppstvl InstanceVal,
b.ksppstdf DefVal, 
a.ksppdesc Descr ,
decode(bitand(a.ksppiflg/256,3),1, 'True', 'False') SESSMOD,
decode(bitand(a.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') SYSMOD
FROM 
x$ksppi a , 
x$ksppcv b , 
x$ksppsv c
WHERE 
a.indx = b.indx AND 
a.indx = c.indx AND 
a.ksppinm LIKE '%&pattern%'
ORDER BY 1
;


/*  DEFAULT NEM TUNIK JONAK

                                           Value    Value    Default
Underscore Parameter                       Session  Instnc   Value    Description                                                                 SESSM SYSMOD
------------------------------------------ -------- -------- -------- --------------------------------------------------------------------------- ----- ---------
_cursor_features_enabled                   2        2        TRUE     Shared cursor features enabled bits.                                        False FALSE
_dbreplay_feature_control                                    TRUE     Database Replay Feature Control                                             False IMMEDIATE
_direct_path_insert_features               0        0        TRUE     disable direct path insert features                                         True  IMMEDIATE
_dmm_auto_max_features                     500      500      TRUE     Auto Max Features                                                           True  IMMEDIATE
_dsc_feature_level                         0        0        TRUE     controls the feature level for deferred segment creation                    True  IMMEDIATE
disable_pdb_feature                        0        0        TRUE     Disable features                                                            False IMMEDIATE
optimizer_features_enable                  12.2.0.1 11.2.0.3 TRUE     optimizer plan compatibility parameter                                      True  IMMEDIATE




*/