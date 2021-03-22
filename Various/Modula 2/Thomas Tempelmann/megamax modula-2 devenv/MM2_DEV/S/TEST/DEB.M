MODULE Deb;

FROM SYSTEM IMPORT ASSEMBLER;
IMPORT Strings,TOSDebug;

VAR a,b: Strings.String;

(*$D+*)

PROCEDURE f (a,b: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    IF f (a,b) THEN
      RETURN FALSE
    END
  END f;

BEGIN
  a:= '12';
  b:= 'asdasda';
  IF f (a,b) THEN
    a:= a
  END;
END Deb.
