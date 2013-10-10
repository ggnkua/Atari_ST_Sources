MODULE StorTest; (*$E MOS *)

FROM StorBase IMPORT FullStorBaseAccess;
FROM Console IMPORT WriteString, WriteLn, Read;

VAR c: CHAR;

BEGIN
  IF FullStorBaseAccess () THEN
    WriteString ('Malloc OK')
  ELSE
    WriteString ('Malloc nicht m”glich')
  END;
  WriteLn;
  Read (c);
END StorTest.
