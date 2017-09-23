PROGRAM InOut;

VAR	datei : TEXT;

PROCEDURE WriteFile(VAR f : TEXT);
BEGIN
	REWRITE(f);
	IF IORESULT <> 0 THEN
		WRITELN('Auweia, ein Fehler!')
	ELSE
	BEGIN
		WRITELN(f, 'Dieses ist die erste Zeile,');	(* mal mit Zeilenumbruch *)
		WRITE(f, 'doch die zweite folgt sogleich.');	(* mal ohne Zeilenumbruch *)
		WRITELN(f);						(* mal nur Zeilenumbruch *)
		CLOSE(f)
	END
END;

PROCEDURE AppendFile(VAR f : TEXT);
BEGIN
	APPEND(f);
	IF IORESULT <> 0 THEN
		WRITELN('Auweia, ein Fehler!')
	ELSE
	BEGIN
		WRITELN(f, 'Dieses ist die dritte Zeile,');	(* mal mit Zeilenumbruch *)
		WRITE(f, 'doch die vierte folgt sogleich.');	(* mal ohne Zeilenumbruch *)
		WRITELN(f);						(* mal nur Zeilenumbruch *)
		CLOSE(f)
	END
END; 

PROCEDURE ReadFile(VAR f : TEXT);
VAR	s : STRING;
BEGIN
	RESET(f);
	IF IORESULT <> 0 THEN
		WRITELN('Auweia, ein Fehler!')
	ELSE
	BEGIN
		WHILE NOT(EOF(f)) DO
		BEGIN
			READLN(f, s);
			WRITELN(s)
		END;
		CLOSE(f)
	END
END;

BEGIN
	ASSIGN(datei, 'MYFILE.TXT');
	WriteFile(datei);
	ReadFile(datei);
	AppendFile(datei);
	ReadFile(datei)
END.
