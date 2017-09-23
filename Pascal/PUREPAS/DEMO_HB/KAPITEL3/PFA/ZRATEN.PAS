PROGRAM Zahlenraten;

CONST	Maximum	= 100;
		Schluss	= 0;

TYPE		RateBereich	= 1..Maximum;

VAR		Zahl			: Schluss..Maximum;
		GedachteZahl	: RateBereich;
		AnzahlVersuche	: 1..MAXINT;
		BereitsGenannt	: SET OF RateBereich;

	PROCEDURE Init;
	BEGIN
		RANDOMIZE;
		GedachteZahl	:= RANDOM(Maximum) + 1;
		WRITELN('Ich habe mir eine Zahl zwischen 1 und ', Maximum,
				' gedacht!');
		WRITELN('Errate Sie!');
		AnzahlVersuche	:= 1;
		BereitsGenannt	:= [];
		WRITELN
	END;

	PROCEDURE Spiel;
	BEGIN
		WRITE('***** Erster Versuch; welche Zahl: ');
		READLN(Zahl);
		WHILE NOT(Zahl in [GedachteZahl, Schluss]) DO
		BEGIN
			WRITELN;
			IF Zahl IN BereitsGenannt THEN
				WRITELN('Hoppsala, die Zahl ', Zahl,
						' hast Du schon genannt!')
			ELSE
			BEGIN
				WRITE(Zahl, ' ist ');
				IF Zahl > GedachteZahl THEN
					WRITE('grîûer')
				ELSE
					WRITE('kleiner');
				WRITELN(' als die gedachte Zahl.');
				WRITELN;
				BereitsGenannt	:= BereitsGenannt + [Zahl];
				AnzahlVersuche	:= AnzahlVersuche + 1
			END;
			WRITELN('***** Der ', AnzahlVersuche, '. Versuch.');
			WRITE('Welche Zahl: ');
			READLN(Zahl)
		END;
		WRITELN 
	END;

	PROCEDURE Auswertung;
	BEGIN
		IF Zahl = GedachteZahl THEN
			WRITELN('>>> Geschafft! Die Zahl hast Du in ', AnzahlVersuche,
					' Versuchen erraten!')
		ELSE
			WRITELN('Vorbei! Die Zahl ', GedachteZahl, ' wÑre es gewesen.') 
	END;

BEGIN
	Init;
	Spiel;
	Auswertung;
	WRITELN;
	WRITELN('DrÅcke Taste...');
	REPEAT UNTIL KEYPRESSED
END.
