PROGRAM WorteRaten;

USES Lesen;

VAR	RateWort		: WortTyp;
	KeineLustMehr	: BOOLEAN;

	(* Das Spiel *)
	PROCEDURE Spiele(RateWort : WortTyp);
	VAR	WortMaske,
		Eingabe		: WortTyp;
		Beenden		: BOOLEAN;
		i			: 1..WortLaenge;

		(* Initialisierung *)
		PROCEDURE Init(VAR Maske : WortTyp; Wort : WortTyp);
		VAR	i	: 1..WortLaenge;
		BEGIN
			WRITELN('Rate das Wort! (*=Ende)');
			Beenden	:= FALSE;
			Maske	:= '';
			FOR i:=1 TO LENGTH(Wort) DO
				Maske	:= Maske + '.'
		END;

	BEGIN
		Init(WortMaske, RateWort);
	
		(* Bis ein Ende kommt... *)
		WHILE NOT(Beenden) DO
		BEGIN
			(* Maske ausgeben *)
			WRITELN('Bisher erraten: ', WortMaske);
			(* Neue Eingabe *)
			READLN(Eingabe);
			(* Ende gewÅnscht? *)
			IF Eingabe = '*' THEN
			BEGIN
				KeineLustMehr	:= TRUE;
				Beenden			:= TRUE
			END
			ELSE
			BEGIN
				(* Nur ein Zeichen eingegeben? *)
				IF LENGTH(Eingabe) = 1 THEN
				BEGIN
					(* Buchstabe in der Maske ersetzen *)
					FOR i:=1 TO LENGTH(RateWort) DO
						IF Eingabe[1] = RateWort[i] THEN
							WortMaske[i]	:= Eingabe[1];
					(* Wort komplett? *)
					IF WortMaske = RateWort THEN
					BEGIN
						WRITELN('Das mÅûte es nun sein!');
						Beenden	:= TRUE
					END
				END
				ELSE
				BEGIN
					(* Wort richtig erraten? *)
					IF Eingabe = RateWort THEN
					BEGIN
						WRITELN('Richtig!');
						Beenden	:= TRUE
					END
					ELSE
						WRITELN('Leider falsch.')
				END
			END
		END
	END;

BEGIN
	KeineLustMehr	:= FALSE;
	(* Worte aus dem Datenbestand holen, bis keines mehr da ist! *)
	RateWort		:= HoleNaechstes;
	WHILE (RateWort <> '') AND NOT(KeineLustMehr) DO
	BEGIN
		Spiele(RateWort);
		RateWort	:= HoleNaechstes
	END
END.