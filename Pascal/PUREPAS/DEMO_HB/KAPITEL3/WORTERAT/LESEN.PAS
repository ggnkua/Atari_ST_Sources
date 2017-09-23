UNIT Lesen;

(* îffentlicher Teil *)
INTERFACE

	CONST	WortLaenge	= 80;

	TYPE	WortTyp	= STRING[WortLaenge];

	FUNCTION HoleNaechstes : WortTyp;

(* nicht-îffentlicher Teil *)
IMPLEMENTATION

	CONST	DateiName	=	'WORTE.TXT';
			MaxSpruenge	=	10;
	TYPE	WortZeiger	=	^WortListe;
			WortListe	=	RECORD
								Wort		: WortTyp;
								Naechstes	: WortZeiger
							END;
	VAR		NaechstesWort	: WortZeiger;
			OldProc			: POINTER;

	(* ein Wort aus der Liste ermitteln *)
	FUNCTION HoleNaechstes : WortTyp;
	VAR	Spruenge, i	: 0..MaxSpruenge;
		Vorgaenger	: WortZeiger;
	BEGIN
		(* Kein Wort in der Liste? *)
		IF NaechstesWort = NIL THEN
			HoleNaechstes	:= ''
		ELSE
		(* Noch Worte in der Liste! *)
		BEGIN
			(* Anzahl der Felder, die Åbersprungen werden *)
			Spruenge	:= RANDOM(MaxSpruenge);
			(* Felder Åberspringen *)
			FOR i:=1 TO Spruenge DO
				NaechstesWort	:= NaechstesWort^.Naechstes;
			(* Wort ermitteln *)
			HoleNaechstes	:= NaechstesWort^.Wort;
			(* War es das letzte Wort? *)
			IF NaechstesWort = NaechstesWort^.Naechstes THEN
				NaechstesWort	:= NIL
			ELSE
			BEGIN
				(* VorgÑnger ermitteln *)
				Vorgaenger	:= NaechstesWort;
				WHILE Vorgaenger^.Naechstes <> NaechstesWort DO
					Vorgaenger	:= Vorgaenger^.Naechstes;
				
				Vorgaenger^.Naechstes	:= NaechstesWort^.Naechstes;
				DISPOSE(NaechstesWort);
				NaechstesWort	:= Vorgaenger^.Naechstes
			END
		END
	END;

	(* Worte aus Datei lesen und Liste aufbauen *)
	PROCEDURE WorteLesen;
	VAR	Datei		: Text;
		Wort		: STRING;
		NeuesWort	: WortZeiger;
	BEGIN
		ASSIGN(Datei, DateiName);
		RESET(Datei);
		(* Lesen, bis Datei leer ist *)
		IF IORESULT = 0 THEN
		BEGIN
			WHILE NOT(EOF(Datei)) DO
			BEGIN
				READLN(Datei, Wort);
				(* Wort nicht Åber 80 Zeichen? *)
				IF (LENGTH(Wort) <= WortLaenge) AND
				   (LENGTH(Wort) >= 1) THEN
				BEGIN
					NEW(NeuesWort);
					NeuesWort^.Wort	:= Wort;
					(* Wort in der Liste anhÑngen *)
					(* Das letzte Feld zeigt immer auf das erste! *)
					IF NaechstesWort = NIL THEN
					BEGIN
						NaechstesWort				:= NeuesWort;
						NaechstesWort^.Naechstes	:= NeuesWort
					END
					ELSE
					BEGIN
						NeuesWort^.Naechstes		:= NaechstesWort^.Naechstes;
						NaechstesWort^.Naechstes	:= NeuesWort;
						NaechstesWort				:= NeuesWort
					END
				END
			END;
			CLOSE(Datei)
		END
	END;

	(* Ggf. reservierter Speicher muû freigegeben werden! *)
	PROCEDURE ExitHandler;
	VAR	AktWort, StartWort	: WortZeiger;
	BEGIN
		IF NaechstesWort <> NIL THEN
		BEGIN
			StartWort	:= NaechstesWort;
			REPEAT
				AktWort			:= NaechstesWort;
				NaechstesWort	:= NaechstesWort^.Naechstes;
				DISPOSE(AktWort)
			UNTIL NaechstesWort = StartWort;
		END;
		EXITPROC	:= OldProc
	END;

(* Initialisierung der Unit *)
BEGIN
	NaechstesWort	:= NIL;
	RANDOMIZE;
	OldProc			:= EXITPROC;
	EXITPROC		:= @ExitHandler;
	WorteLesen
END.