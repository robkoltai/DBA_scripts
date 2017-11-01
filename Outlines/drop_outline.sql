-- Vicces a sys nem tudja eldobni az outline-t amit nem o keszitett
-- 11.2.0.3

USER is "SYS"
SYS@a11203st>drop outline PUBLIC_TEST2_OK;
drop outline PUBLIC_TEST2_OK
*
ERROR at line 1:
ORA-18006: DROP ANY OUTLINE privilege is required for this operation


-- P nek sikerul
P@a11203st>drop outline PUBLIC_TEST2_OK;

Outline dropped.
