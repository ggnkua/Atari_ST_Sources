MODULE StringTest;
(*$E MOS *)

IMPORT TOSIO;
FROM InOut IMPORT WriteString, Write, WriteLn, ReadString;
FROM Strings IMPORT Compare, StrEqual, Relation;

VAR s0: ARRAY [0..0] OF CHAR;
    s1: ARRAY [0..1] OF CHAR;
    s2: ARRAY [0..2] OF CHAR;
    s3: ARRAY [0..3] OF CHAR;
    r1, r2: Relation;

BEGIN
  LOOP
    ReadString (s0);
    IF s0[0] = '%' THEN EXIT END;
    ReadString (s1);
    IF s1[0] = '%' THEN EXIT END;
    r1:= Compare (s0,s1);
    r2:= Compare (s1,s0);
    IF r1 = equal THEN
      IF r2 # equal THEN HALT END;
      IF NOT StrEqual (s0,s1) THEN HALT END;
      IF NOT StrEqual (s1,s0) THEN HALT END;
    ELSE
      IF r2 = equal THEN HALT END;
      IF r1 = r2 THEN HALT END;
      IF StrEqual (s0,s1) THEN HALT END;
      IF StrEqual (s1,s0) THEN HALT END;
    END;
    CASE r1 OF
      less: WriteString ('<'); WriteLn|
      equal: WriteString ('='); WriteLn|
      greater: WriteString ('>'); WriteLn|
    END
  END;
END StringTest.
