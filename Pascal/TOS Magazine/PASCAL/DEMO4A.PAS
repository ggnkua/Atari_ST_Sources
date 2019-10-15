(* Demo fÅr die Verwendung von TOS-Funktionen *)

PROGRAM Demo4A;

USES TOS;

VAR Disk:DISKINFO;
	i:INTEGER;

BEGIN
IF Dfree(Disk,0)=0 THEN
	WITH Disk DO
		BEGIN
		WRITELN('Aktuelles Laufwerk:');
		WRITELN('GesamtkapazitÑt:  ',b_total);
		WRITELN('Davon frei:       ',b_free);
		WRITELN('Bytes/Sektor:     ',b_secsiz);
		WRITELN('Sektoren/Cluster: ',b_clsiz);
		END
ELSE WRITELN('Fehler bei Dfree');

FOR i:=1 TO 10 DO WRITELN(TOS.Random);

WRITELN('Bildschirmspeicher bei Adresse: ',LONGINT(Logbase));
END.
