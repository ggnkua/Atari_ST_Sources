(* Demo: Dynamische Speicherverwaltung unter Pure Pascal *)

PROGRAM DynDemo;

TYPE PPerson = ^TPerson; (* Dies ist erlaubt! *)
     TPerson = RECORD Vorname,Zuname:STRING; END;

VAR  EinePerson:PPerson;

BEGIN
NEW(EinePerson);
EinePerson^.Vorname:='Otto';
EinePerson^.Zuname:='Mustermann';
WRITELN(EinePerson^.Vorname,' ',EinePerson^.Zuname);
DISPOSE(EinePerson);
END.
