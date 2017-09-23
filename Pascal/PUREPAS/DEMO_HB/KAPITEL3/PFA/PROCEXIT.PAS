PROGRAM ProcExit;

	PROCEDURE Proc;
	BEGIN
		WRITELN('Dieser Text erscheint.');
		EXIT;
		WRITELN('Dieser nicht!')
	END;

BEGIN
	WRITELN('Nun folgt der Aufruf der Prozedur!');
	Proc;
	WRITELN('Hier geht es weiter.')
END.
