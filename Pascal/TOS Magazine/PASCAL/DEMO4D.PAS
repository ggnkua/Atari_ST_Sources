(* Verzeichnislesen unter DOS *)

PROGRAM Demo4D;

USES DOS;

VAR Eintrag:SearchRec;

BEGIN
WRITELN('Dateien des aktuellen Verzeichnisses:');
WRITELN;
FindFirst('*.*',AnyFile,Eintrag);
WHILE DosError = 0 DO
	BEGIN
	WRITELN(Eintrag.Name);
	FindNext(Eintrag);
	END;
END.
