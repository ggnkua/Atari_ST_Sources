(* Programm, welches einen Testtext mit Hilfe der Unit Demo5FUnit *)
(* in die Datei TEST.TXT schreibt.                                *)

PROGRAM Demo5F;

USES Demo5FUnit;

VAR Datei:PTextoutfile;

BEGIN
NEW(Datei,Init('TEST.TXT')); (* Datei erzeugen *)
IF Datei^.Error=0 THEN
	BEGIN
	Datei^.WriteLine('Dies ist Textzeile 1.');
	Datei^.WriteLine('Dies ist Textzeile 2.');
	Datei^.WriteLine('Dies ist Textzeile 3.');
	END
ELSE WRITELN('Fehler beim Erzeugen der Datei!');
DISPOSE(Datei,Done);
END.
