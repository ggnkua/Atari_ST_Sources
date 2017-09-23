PROGRAM Zahlentafel;

CONST	ErsteZahl		= 0;
		LetzteZahl		= 63;
		MaxZweierPotenz	= 32;

TYPE	ZahlBereich	= ErsteZahl..LetzteZahl;

VAR		Zahl			: ZahlBereich;
		Antwort			: CHAR;
		ZweierPotenz	: 1..MAXINT;

	PROCEDURE Init;
	BEGIN
		WRITELN('*** Zahltafel ***');
		WRITELN;
		WRITELN('Denke Die eine Zahl zwischen ', ErsteZahl,
				' und ', LetzteZahl, ' aus!');
		WRITELN('Ich werde sie erraten!');
		WRITELN('Du mužt lediglich sagen, auf welchen Zahlentafeln');
		WRITELN('Deine Zahl verzeichnet ist.');
		WRITELN;
		WRITELN('Und hier die Zahlentafeln!');
		WRITELN
	END;

	PROCEDURE EineTafel(Anfang : ZahlBereich);
	CONST	ZahlenProZeile	= 8;
	VAR		Lauf, Anzahl	: ZahlBereich;
	BEGIN
		WRITELN;
		Anzahl	:= 0;
		FOR Lauf:=Anfang TO LetzteZahl DO
		BEGIN
			IF (Lauf MOD (2 * Anfang)) >= Anfang THEN
			BEGIN
				WRITE(Lauf:5);
				INC(Anzahl);
				IF (Anzahl MOD ZahlenProZeile) = 0 THEN
					WRITELN
			END;
		END;
		WRITELN
	END;

BEGIN
	Init;
	Zahl			:= 0;
	ZweierPotenz	:= 1;
	WHILE ZweierPotenz <= MaxZweierPotenz DO
	BEGIN
		EineTafel(ZweierPotenz);
		WRITE('Ist Deine Zahl dabei (J/N): ');
		REPEAT
			READLN(Antwort);
			Antwort	:= UPCASE(Antwort)
		UNTIL Antwort IN ['J', 'N'];
		IF Antwort = 'J' THEN
			INC(Zahl, ZweierPotenz);
		ZweierPotenz	:= 2 * ZweierPotenz
	END;
	WRITELN;
	WRITELN('*** Deine Zahl lautet ', Zahl);
	WRITELN;
	WRITELN('Drcke Taste...');
	REPEAT UNTIL KEYPRESSED
END.