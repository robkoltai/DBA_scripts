
-- Shows fk columns and the correspoding pk columns
select 
fkcol.owner fk_owner, fkcol.table_name fk_table_name, fkcol.column_name fk_column_name, fkcol.position fk_position, fkcol.constraint_name fk_constraint_name,
pkcol.owner pk_owner, pkcol.table_name pk_table_name, pkcol.column_name pk_column_name, pkcol.constraint_name pk_constraint_name   --  pkcol.position,
--fk.constraint_type, fk.constraint_name, fk.owner, fk.table_name, 
--fk.r_owner, fk.r_constraint_name,
--pk.owner pkowner, pk.table_name pktable_name, pk.constraint_type pkconstraint_type
from dba_constraints fk,
     dba_constraints pk,
     dba_cons_columns pkcol,
     dba_cons_columns fkcol
where fk.r_constraint_name = pk.constraint_name and
    fk.constraint_type = 'R' and 
    pk.constraint_type = 'P' and
    pkcol.owner = pk.owner and
    pkcol.constraint_name = pk.constraint_name and
    fkcol.owner = fk.owner and
    fkcol.constraint_name = fk.constraint_name and
    pkcol.position  = fkcol.position and
    --fk.r_constraint_name = 'REGISTRY_PK'
order by fkcol.owner, fkcol.table_name, fkcol.constraint_name, fkcol.position, fkcol.column_name;    

/*
SYS     REGISTRY$               NAMESPACE       1       REGISTRY_PARENT_FK      SYS             REGISTRY$       NAMESPACE       REGISTRY_PK
SYS     REGISTRY$               PID             2       REGISTRY_PARENT_FK      SYS             REGISTRY$       CID             REGISTRY_PK
SYS     REGISTRY$DEPENDENCIES   NAMESPACE       1       DEPENDENCIES_FK         SYS             REGISTRY$       NAMESPACE       REGISTRY_PK
SYS     REGISTRY$DEPENDENCIES   CID             2       DEPENDENCIES_FK         SYS             REGISTRY$       CID             REGISTRY_PK
SYS     REGISTRY$DEPENDENCIES   REQ_NAMESPACE   1       DEPENDENCIES_REQ_FK     SYS             REGISTRY$       NAMESPACE       REGISTRY_PK
SYS     REGISTRY$DEPENDENCIES   REQ_CID         2       DEPENDENCIES_REQ_FK     SYS             REGISTRY$       CID             REGISTRY_PK
SYS     REGISTRY$PROGRESS       NAMESPACE       1       REGISTRY_PROGRESS_FK    SYS             REGISTRY$       NAMESPACE       REGISTRY_PK
SYS     REGISTRY$PROGRESS       CID             2       REGISTRY_PROGRESS_FK    SYS             REGISTRY$       CID             REGISTRY_PK
SYS     REGISTRY$SCHEMAS        NAMESPACE       1       REGISTRY_SCHEMA_FK      SYS             REGISTRY$       NAMESPACE       REGISTRY_PK
SYS     REGISTRY$SCHEMAS        CID             2       REGISTRY_SCHEMA_FK      SYS             REGISTRY$       CID             REGISTRY_PK
*/