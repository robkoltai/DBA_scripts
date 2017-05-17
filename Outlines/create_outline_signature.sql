CREATE OR REPLACE FUNCTION outline_signature(text VARCHAR2)
RETURN RAW
DETERMINISTIC
AS
signature RAW(32);
text2 VARCHAR2(32767);
BEGIN
text2:=text;
IF text2 IS NULL THEN
text2:='1';
END IF;
sys.outln_edit_pkg.generate_signature(text2,signature);
RETURN signature;
END;
/
