IMPLEMENTATION MODULE PathEnv;
(*$R-*)
(*$Y- wichtig, damit jeder Prozež seine eigenen Vars hat! *)

FROM SYSTEM IMPORT ADDRESS;
FROM MOSGlobals IMPORT PathStr, FileStr;
IMPORT Strings;

VAR ok: BOOLEAN;

PROCEDURE ReplaceHome ( VAR name: ARRAY OF CHAR );
  VAR idx: CARDINAL;
  BEGIN
    Strings.Upper (name);
    idx:= ORD (name[0] = '?') (* FSelSymbol *);
    IF Strings.Chr (name, idx) = HomeSymbol THEN
      Strings.Delete (name, idx, 1, ok);
      IF Strings.Chr (name, idx) = '\' THEN
        (* um aus "*\DAT" nicht "D:\\DAT" zu machen *)
        Strings.Delete (name, idx, 1, ok);
      END;
      Strings.Insert (HomePath, idx, name, ok)
    END;
  END ReplaceHome;

PROCEDURE HomeReplaced ( REF pathOrName: ARRAY OF CHAR ): FileStr;
  VAR s: FileStr;
  BEGIN
    Strings.Assign (pathOrName, s, ok);
    ReplaceHome (s);
    RETURN s
  END HomeReplaced;


PROCEDURE NoSelect (REF d:ARRAY OF CHAR; VAR a,b:ARRAY OF CHAR; VAR c:BOOLEAN);
  BEGIN
    c:= FALSE
  END NoSelect;

BEGIN
  IF ADDRESS (SelectFile) = NIL THEN
    (* wenn nicht NIL, wurde Wert von GEMEnv-EnvelopeProc schon gesetzt *)
    SelectFile:= NoSelect
  END;
  HomePath:= ''
END PathEnv.

