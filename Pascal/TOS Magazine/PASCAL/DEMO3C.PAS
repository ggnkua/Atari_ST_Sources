(* Demoprogramm: Prozeduren zum Beenden des Programmes *)

PROGRAM Demo3C;

VAR wahl:INTEGER;

PROCEDURE ExitFromProc;
BEGIN
WRITELN('EXIT aus Prozedur.');
EXIT;
WRITELN('Ihr Pascal-Compiler ist kaputt!');
WRITELN('Er darf nicht in diese Zeile gelangen!');
END;

BEGIN
RANDOMIZE;
REPEAT
	WRITELN('Was wollen Sie:');
	WRITELN;
	WRITELN('1) EXIT aus Hauptprogramm.');
	WRITELN('2) HALT aus Hauptprogramm.');
	WRITELN('3) RUNERROR aus HAUPTPROGRAMM.');
	WRITELN('4) EXIT aus Prozedur.');
	READLN(wahl);
UNTIL (wahl>=1) AND (wahl<=4);
CASE wahl OF
	1:	BEGIN
		WRITELN('EXIT aus Hauptprogramm.');
		EXIT;
		END;
	2:	BEGIN
		WRITELN('HALT aus Hauptprogramm.');
		HALT;
		END;
	3:	BEGIN
		WRITELN('RUNERROR aus HAUPTPROGRAMM.');
		RUNERROR(RANDOM(256));
		END;
	4:	BEGIN
		WRITELN('Rufe Unterprogramm auf.');
		ExitFromProc;
		END;
	END;
WRITELN('Verlasse Hauptprogramm auf normalem Wege.');
END.
