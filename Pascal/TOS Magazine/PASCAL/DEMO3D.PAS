PROGRAM DEMO3D; (* Arbeit mit Textdateien *)

{$I-} (* IO-Tests ausschalten *)

CONST Dateiname = 'TESTFILE.ASC';

VAR Datei:TEXT;

PROCEDURE Ausgabe(Name:STRING);
VAR txt:STRING;
	EinDatei:TEXT;
BEGIN
ASSIGN(EinDatei,Name);
RESET(EinDatei);
IF IOResult<>0 THEN
	BEGIN
	WRITELN('Kann Datei nicht ”ffnen.');
	HALT;
	END;
WHILE NOT EOF(EinDatei) DO
	BEGIN
	READLN(EinDatei,txt);
	WRITELN(txt);
	END;
CLOSE(EinDatei);
END;

PROCEDURE EinzelAusgabe(Name:STRING);
VAR txt:CHAR;
	EinDatei:TEXT;
BEGIN
ASSIGN(EinDatei,Name);
RESET(EinDatei);
IF IOResult<>0 THEN
	BEGIN
	WRITELN('Kann Datei nicht ”ffnen.');
	HALT;
	END;
WHILE NOT EOF(EinDatei) DO
	BEGIN
	READ(EinDatei,txt);
	WRITE(txt);
	IF EOLN(EinDatei) THEN
		BEGIN
		WRITELN;
		WRITE('*Zeilenende*');
		END;
	END;
CLOSE(EinDatei);
END;

BEGIN
(* Zun„chst eine Textdatei erzeugen *)
ASSIGN(Datei,Dateiname);
REWRITE(Datei);
IF IOResult<>0 THEN
	BEGIN
	WRITELN('Kann Datei nicht erzeugen.');
	HALT(1);
	END;

WRITELN(Datei,'Zeile 1.');
FLUSH(Datei);
WRITE(Datei,'Zeile 2. ');
WRITELN(Datei,'Immer noch Zeile 2.');
CLOSE(Datei);

WRITELN('1. Ausgabe der Datei:');
WRITELN;
Ausgabe(Dateiname);

APPEND(Datei);
IF IOResult<>0 THEN
	BEGIN
	WRITELN('Kann nicht an Datei anh„ngen.');
	HALT(2);
	END;
WRITELN(Datei,'Angeh„ngte Zeile 3.');
CLOSE(Datei);

WRITELN;
WRITELN('2. Ausgabe der Datei:');
WRITELN;
Ausgabe(Dateiname);

WRITELN;
WRITELN('Einzelausgabe der Datei:');
WRITELN;
EinzelAusgabe(Dateiname);
WRITELN;
WRITELN;

ERASE(Datei);
IF IOResult=0 THEN WRITELN('Datei wieder gel”scht.')
ELSE WRITELN('Konnte Datei nicht l”schen.');
END.
