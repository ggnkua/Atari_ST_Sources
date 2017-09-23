PROGRAM DynObj;

(* Definition des Objekts LogDatei *)
TYPE	Status		=	(geoeffnet, geschlossen);
		LogDatei	=	OBJECT
							FileName	: STRING;
							Datei		: TEXT;
							DateiStatus	: Status;
							CONSTRUCTOR Init;
							DESTRUCTOR Done;
							PROCEDURE Log(s : STRING);
							PROCEDURE Auf(s : STRING);
							PROCEDURE Zu;
						END;

(* Konstruktor *)
CONSTRUCTOR LogDatei.Init;
BEGIN
	DateiStatus	:= geschlossen;
	FileName	:= ''
END;

(* Destruktor *)
DESTRUCTOR LogDatei.Done;
BEGIN
	IF DateiStatus = geoeffnet THEN
		CLOSE(Datei)
END;

(* Datensatz schreiben *)
PROCEDURE LogDatei.Log(s : STRING);
BEGIN
	IF DateiStatus = geoeffnet THEN
		WRITELN(Datei, s)
END;

(* Protokolldatei ”ffnen *)
PROCEDURE LogDatei.Auf(s : STRING);
BEGIN
	ASSIGN(Datei, s);
	REWRITE(Datei);
	DateiStatus	:= geoeffnet;
	WRITELN(Datei, 'Log-Datei');
	WRITELN(Datei, '=========');
	WRITELN(Datei)
END;

(* Protokolldatei schliežen *)
PROCEDURE LogDatei.Zu;
BEGIN
	IF DateiStatus = geoeffnet THEN
	BEGIN
		CLOSE(Datei);
		DateiStatus := geschlossen;
	END;
END;

(* Das eigentliche Programm *)
VAR	Log1, Log2	: ^LogDatei;

BEGIN
	NEW(Log1, Init);
	NEW(Log2, Init);

	(* Protokoll mit Objekt 1 *)
	Log1^.Auf('LOGFILE1.TXT');
	Log1^.Log('Hello World!');
	Log1^.Zu;

	(* Protokoll mit Objekt 2 *)
	(* Datei wird erst mit Destruktor geschlossen *)
	Log2^.Auf('LOGFILE2.TXT');
	Log2^.Log('Hello World!');
	
	DISPOSE(Log2, Done);
	DISPOSE(Log1, Done)
END.
