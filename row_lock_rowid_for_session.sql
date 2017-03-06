--session alapjan row lock eseten objektumot es row id-t ad a select.

select
    owner||'.'||object_name||':'||nvl(subobject_name,'-') obj_name,
    dbms_rowid.rowid_create (
        1,
        o.data_object_id,
        row_wait_file#,
        row_wait_block#,
        row_wait_row#
    ) row_id
from v$session s, dba_objects o
where sid = &sid
and o.data_object_id = s.row_wait_obj#


/*
OBJ_NAME              ROW_ID
----------------------------------------
CM.CALL_SESSIONS:-    AAAOhMAAPAAAv0QAAN




*/