(*
Gruppe: Persînliche
ID  : P23918@AC2
Wg. : Proc FindApplication
Von : Frank Storm @ AC2 (So, 16.01.94 12:36)
An  : Thomas Tempelmann @ M
 
Hallo Thomas!

Auch auf die Gefahr hin, daû dieser Fehler schon seit Jahren behoben ist, oder
daû dieser Fehler ja gar keiner ist: Funktioniert die Prozedur FindApplication
aus dem Modul AESMisc inzwischen? Der Fehler ist mir vor ca. zwei Jahren mal
aufgefallen, und ich habe die Prozedur damals neugeschrieben. Die Prozedur
findet nÑmlich keine Programme. Wenn ich sie mit
*)

MODULE T;

FROM AESMisc IMPORT FindApplication;
FROM SYSTEM IMPORT ASSEMBLER;
FROM InOut IMPORT ReadString, WriteString, WriteLn, WriteCard;

VAR id: CARDINAL;
    success: BOOLEAN;
    s: ARRAY [0..9] OF CHAR;

BEGIN
  LOOP
    ReadString (s);
    IF (CAP(s[0]) = 'Q') AND (s[1] = '') THEN RETURN END;
    (*ASSEMBLER BREAK END;*)
    FindApplication (s, id, success);
    IF success THEN
      WriteString ("found. ID = ");
      WriteCard (id, 0);
    ELSE
      WriteString ("not found.")
    END;
    WriteLn;
  END
END T.

(*
aufrufe, so ist success FALSE, egal ob MM2Shell lÑuft oder nicht.
Die interne Versionsnummer von AESMisc ist bei mir V#0051. Ich frage auch
deswegen, weil wohl die wenigsten diese Prozedur benutzt haben dÅrften.

mfg Frank
*)