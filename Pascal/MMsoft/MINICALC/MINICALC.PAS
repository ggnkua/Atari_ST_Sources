PROGRAM MiniCalc;

{ MiniCalc ist das letzte Programm von MMsoft (schnÅff!). Sie dÅrfen damit
  machen, was Sie wollen, nur nicht durch Verkauf sich damit bereichern. }

USES GL,GEM;

{ Das Programm MiniCalc benutzt Routinen aus der GEM-Library fÅr Pure
  Pascal (GL). ErhÑltlich bei KonTrast. }

{$I MINICALC.I}	{ Resource-Informationen einbinden }

CONST closebox = -1;						{ Schlieûfeld-Nummer }
VAR	actual,								{ Die aktuelle Zahl }
		memory,								{ Die Zahl im Speicher }
		switch,								{ Zahl fÅr Tauschoperationen }
		new				: REAL;			{ Die neu eingetippte Zahl }
		strg				: STRING[18];	{ Zahl in String gewandelt }
		calc				: AESTreePtr;	{ Dialogbox-Adresse }

		tad,									{ Addieren, Subtahieren, Dividieren }
		tsu,									{ und Multiplizieren }
		tdi,
		tmu,
		tho,									{ und Potenzieren, speichern, lesen }
		tsm,
		trm,
		all,
		numberus,
		ende,									{ Programmende }
		bool,
		strclr			: BOOLEAN;		{ Boolean-Dummy }
		dummy				: INTEGER;		{ Integer-Dummy }


PROCEDURE number(key : Char; but : INTEGER);
BEGIN
	IF strclr = TRUE THEN	{ Zahl lîschen? }
	BEGIN
		strclr := FALSE;
		SetPText(Calc, TSHOW, '');
		DrawObj(Calc, TSHOW, 0);
 		strg := '';
	END;
	IF key = '#' THEN			{ Zahl lesen? }
		BEGIN
			Str(memory:1:2,strg);
			key := ' ';			{ es soll nichts weiter passieren. }
		END;
	IF key = '<' THEN			{ Einen zurÅck? }
		BEGIN
			Delete(strg,Length(strg),1);	{ kein Problem! }
			key := ' ';			{ es soll nichts weiter passieren. }
		END;
	IF (Length(strg) < 13) AND (key <> ' ') THEN	{ Wenn LÑnge nicht Åber-
		schritten und Key kein Leerzeichen ist, Zahl einfÅgen! }
		strg := strg + key;
	SetPText(Calc, TSHOW, strg);
	DrawObj(Calc, TSHOW, 0);
	DrawObj(Calc, but, Selected);
	numberus := TRUE;
END;

PROCEDURE falsing;		{ Bitte alles auf FALSE setzen }
BEGIN
	strclr := TRUE;
	tad := FALSE;
	tsu := FALSE;
	tdi := FALSE;
	tmu := FALSE;
	tho := FALSE;
	tsm := FALSE;
	trm := FALSE;
	all := FALSE;
END;

PROCEDURE Readn(but : INTEGER);
VAR	i,
		j : INTEGER;
BEGIN
	IF numberus = TRUE THEN
	BEGIN
		VAL(strg, new, dummy);
		VAL(strg, j, dummy);
		switch := actual;
		IF tad = TRUE THEN
			actual := actual + new;		{ Erst die vier Grundrechenarten! }
		IF tsu = TRUE THEN
			actual := actual - new;
		IF tdi = TRUE THEN
			actual := actual / new;
		IF tmu = TRUE THEN
			actual := actual * new;
		IF tho = TRUE THEN				{ Nun wird Potenziert! }
			FOR i := 2 TO j DO actual := actual * switch;
		IF tsm = TRUE THEN
			memory := new;					{ abspeichern! }
		IF all = FALSE THEN				{ ausgerechnete Zahl merken }
			BEGIN
				VAL(strg, new, dummy);
				actual := new;
			END;
		STR(actual:1:2, strg);
		IF length(strg) > 17 THEN	{ Wenn Zahl lÑnger als Display, dann... }
		BEGIN
			actual := 0;		{...Zahl lîschen! }
			new	 := 0;
			strg	 := '';
		END;
		SetPtext(Calc, TSHOW, strg);
		DrawObj(Calc, TSHOW, 0);
		falsing;
	END;
	DrawObj(Calc, but, Selected);
	numberus := FALSE;
END;

FUNCTION HandleCalc(msg: DialAction; button : INTEGER) : INTEGER;
BEGIN
	HandleCalc := 2;
	CASE msg OF
		DIAL_START : ;
		DIAL_END :
		BEGIN
			CASE button OF
				closebox :
					BEGIN
						HandleCalc := 0;
						IF AppFlag = TRUE THEN
							ende := TRUE;
					END;
				T1 : number('1',T1);		{ Zahlentaste angeklickt? }
				T2 : number('2',T2);
				T3 : number('3',T3);
				T4 : number('4',T4);
				T5 : number('5',T5);
				T6 : number('6',T6);
				T7 : number('7',T7);
				T8 : number('8',T8);
				T9 : number('9',T9);
				T0 : number('0',T0);
				T_ : number('.',T_);
				TADD : 	{ Plus? }
				BEGIN
					Readn(TADD);
					tad := TRUE;
					all := TRUE;
				END;
				TSUB : { Minus? }
				BEGIN
					Readn(TSUB);
					tsu := TRUE;
					all := TRUE;
				END;
				TDIV : { Geteilt? }
				BEGIN
					Readn(TDIV);
					tdi := TRUE;
					all := TRUE;
				END;
				TMUL : { Mal? }
				BEGIN
					Readn(TMUL);
					tmu := TRUE;
					all := TRUE;
				END;
				THOCH :	{ Potenzieren? }
				BEGIN
					Readn(THOCH);
					tho := TRUE;
					all := TRUE;
				END;
				TMMSOFT :	{ Hallo MMsoft! }
				BEGIN
					dummy := Alert(1,'[4][   %DMiniCalc   ||%F1993 by MMsoft||  written by|Martin Markett][    [OK    ]');
					DrawObj(Calc, button, Selected);
				END;
				TSAVE :	{ bitte speichern! }
				BEGIN
					tsm := TRUE;
					all := FALSE;
					numberus := TRUE;
					Readn(TSAVE);
				END;
				TREAD : number('#',TREAD);		{ Einmal Zahl bitte! }
				TENTER :
				BEGIN
					Readn(TENTER);					{ Und was kommt raus? }
				END;
				TCLEAR :
				BEGIN
					falsing;
					number(' ',TCLEAR);			{ Weg damit! }
				END;
				TDEL : number('<',TDEL);		{ Einmal Backspace! }
			END;
		END;
	END;
END;

PROCEDURE main;
BEGIN
	ende := FALSE;
	DialPosXY(TRUE);	{ Dialog an Mausposition }
	{ Taschenrechner anzeigen }
	bool := WindowDialog(' MiniCalc ', TRUE, FALSE, Calc, 0, HandleCalc);

	REPEAT
		HandleEvents;
	UNTIL ende;		{ Wenn's Programm verlassen wird... }
END;

PROCEDURE acc_end;
BEGIN
	DialClose(Calc);	{ Das Accessory wird geschlossen }
END;

BEGIN
	IF Init_GEM THEN						{ Wenn Anmeldung beim GEM erfolgreich }
		BEGIN
			IF LoadRsc('MINICALC.RSC') THEN	{ Resource laden }
				BEGIN
					Calc	:= RscAdr(R_TREE, RECHNER);	{ Adresse holen }

					bool	:= NewDialog(Calc);				{ Dialog anmelden }
					SetPText(Calc, TSHOW, '');
					IF NOT AppFlag THEN	{ Als Accessory? }
						BEGIN		{ Dann anmelden als Acc! }
							dummy := menu_register(appl_handle, '  MiniCalc');
							SetAccProgs(main,acc_end);
							Repeat	{ Solange hinten bleiben, bis Acc... }
								handleevents;		{ ...aufgerufen wird. }
							Until ende = TRUE;
						END;
					main;											{ Hauptprozedur }
				END;
			Exit_GEM;	{ Auf Wiedersehen! }
		END;
END.