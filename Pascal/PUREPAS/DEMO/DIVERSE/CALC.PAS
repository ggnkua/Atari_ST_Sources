(*************************************************************************
  Desktoprechner	Copyright (c) 1992 by Application Systems Heidelberg.
  ==============	Alle Rechte vorbehalten.
  
  Autor:				Dietmar Rabich
  Programm:				CALC.PAS
  Entwicklungssystem:	PurePascal

  Der Desktoprechner ist ein kleines Beispielprogramm, welches mit
  PurePascal entwickelt wurde. Es ist sowohl als Programm als auch als
  Accessory lauffÑhig.

  Wichtig!

  Vor der öbersetzung des Programms mÅssen die Resourcen mit BINOBJ
  Åbersetzt werden. Aufruf:

  BINOBJ calcrsc.rsc calcrsc CalcRsc

*************************************************************************)

PROGRAM MeinRechner;

(* Importierte Units *)
(* Gem:			Standard-Unit von PurePascal *)
(* Resources:	Unit zur Verwaltung von eingebundenen Resourcen *)
(* OWindows:	Unit zur Verwaltung des Rechner-Fensters *)
(* Handler:		Unit zur Verwaltung der Eingabe (Rechner) *)
USES Gem, OWindows, Handler, Resources;


(* Konstanten *)
CONST	(* Name des Programms *)
		AppName		=	'Sweetie';
		WinName		=	' ' + AppName + ' ';
		AccName		=	'  ' + AppName + '...';


(* Konstanten fÅr die Resourcen *)
{$I CALCRSC.I}


VAR	appl_id,								(* Applikation-Identifikation *)
	menu_id			:	INTEGER;			(* MenÅidentifikation (ACC) *)
	MyWindow		:	ObjWindow;			(* Fenster-Objekt *)
	RechnerObjTree,							(* Objektbaum Rechner *)
	AboutObjTree	:	AESTreePtr;			(* Objektbaum About-Dialog *)
	OldProc			:	POINTER;			(* fÅr EXIT-Prozedur *)
	MyCalc			:	Calculator;			(* Rechner-Objekt *)
	MyResource		:	TResourcePoolPtr;	(* Resourcepointer *)


(* Resourcen *)
PROCEDURE CalcRsc;
EXTERNAL;
{$L CALCRSC}


(* EXIT-Prozedur *)
PROCEDURE AppExitProc;

VAR	Msg	:	ARRAY_8;

BEGIN

	(* Fenster schlieûen *)
	MyWindow.CloseWindow(TRUE);

	(* Resourcen freigeben *)
	FreeResourcePool(MyResource);

	(* Wenn Accessory, dann hier verharren *)
	{$X+}
	IF NOT(AppFlag) THEN
		WHILE TRUE DO
			evnt_mesag(Msg);

	(* Abmeldung bei den AES *)
	IF appl_id <> -1 THEN
		appl_exit;
	{$X-}

	(* alte EXIT-Prozedur *)
	EXITPROC	:=	OldProc

END;


(* Initialisierungsfunktion *)
FUNCTION InitApp : BOOLEAN;

(* Typisierte Konstanten *)
CONST	(* Fensterelemente *)
		WindowElements	:	INTEGER	=	NAME OR CLOSER OR MOVER;

BEGIN

	(* EXIT-Prozedur anmelden *)
	OldProc		:=	EXITPROC;
	EXITPROC	:=	@AppExitProc;

	(* Anmeldung bei den AES *)
	appl_id	:=	appl_init;
	IF appl_id < 0 THEN
	BEGIN
		appl_id	:=	-1;
		InitApp	:=	FALSE;
		EXIT
	END;

	(* Resourcen initialisieren und vorbereiten *)
	MyResource		:=	InitResourcePool(@CalcRsc);
	RechnerObjTree	:=	GetResource(MyResource, RECHNER);
	AboutObjTree	:=	GetResource(MyResource, COPYRGHT);
	SetPtext(RechnerObjTree, TANZEIGE, '0');

	(* Instanz MyCalc initialisieren *)
	MyCalc.Init;

	(* Instanz MyWindow vorbereiten *)
	MyWindow.SetTree(RechnerObjTree);
	MyWindow.SetElements(WindowElements);

	(* Applikation- bzw. Accessory-spezifische Vorbereitungen *)
	{$X+}
	IF AppFlag THEN
	BEGIN
		(* Fenster îffnen *)
		IF NOT(MyWindow.OpenWindow(WinName)) THEN
		BEGIN
			InitApp	:=	FALSE;
			EXIT
		END;

		(* Mauszeiger als Pfeil *)
		graf_mouse(ARROW, MFORMPtr(0));
	END
	ELSE
	BEGIN

		(* MenÅeintrag *)
		menu_id	:=	menu_register(appl_id, AccName);

		(* Kein Eintrag erfolgt? *)
		IF menu_id < 0 THEN
		BEGIN
			InitApp	:=	FALSE;
			EXIT
		END
	END;
	{$X-}

	(* Initialisierung OK! *)
	InitApp	:=	TRUE

END;


(* Programmverlauf *)
PROCEDURE DoApp;

(* Konstanten *)
CONST	(* Informationstaste *)
		KeyInfo			=	'?';

VAR		Evnt			:	INTEGER;	(* Event *)
		Msg				:	ARRAY_8;	(* Messages *)
		Mmox, Mmoy,						(* fÅr Events *)
		Mmobutton,
		Mmokstate, Mkreturn,
		Mbreturn		:	INTEGER;

	(* Reaktion auf Mausereignis *)
	{$X+}
	PROCEDURE DoButton(VAR Evnt		: INTEGER;
						Mx, My		: INTEGER;
						VAR Mkey	: INTEGER);

	(* Konstanten *)
	CONST	(* TabelleneintrÑge fÅr öbersetzung Objekttyp in Taste *)
			MaxTab		=	21;

	(* Typen *)
	TYPE	ObjRecord	=	RECORD
								obj	:	INTEGER;	(* Objektnummer *)
								key	:	CHAR		(* Taste *)
							END;

	(* Typisierte Konstanten *)
	CONST	(* Tabelle Objekttyp und dazugehîrige Taste *)
			ObjTabelle	:	ARRAY [0..MaxTab] OF ObjRecord =
							(
								(obj	:	TCM;	key	:	KeyClearMemory),
								(obj	:	TM;		key	:	KeyMemory),
								(obj	:	TRM;	key	:	KeyReMemory),
								(obj	:	TSM;	key	:	KeySwitchMemory),
								(obj	:	TCLEAR;	key	:	KeyClear),
								(obj	:	TINFO;	key	:	KeyInfo),
								(obj	:	TDIV;	key	:	KeyDiv),
								(obj	:	TMUL;	key	:	KeyMul),
								(obj	:	TSUB;	key	:	KeySub),
								(obj	:	TADD;	key	:	KeyAdd),
								(obj	:	TENTER;	key	:	KeyEnter),
								(obj	:	TSIGN;	key	:	KeyChangeSign),
								(obj	:	T0;		key	:	Key0),
								(obj	:	T1;		key	:	Key1),
								(obj	:	T2;		key	:	Key2),
								(obj	:	T3;		key	:	Key3),
								(obj	:	T4;		key	:	Key4),
								(obj	:	T5;		key	:	Key5),
								(obj	:	T6;		key	:	Key6),
								(obj	:	T7;		key	:	Key7),
								(obj	:	T8;		key	:	Key8),
								(obj	:	T9;		key	:	Key9)
							);

	(* Variablen *)
	VAR		i, dummy, 
			obj	:	INTEGER;

	BEGIN

		(* Objekt unter Mausposition *)
		obj	:=	objc_find(RechnerObjTree, ROOT, MAX_DEPTH, Mx, My);

		(* Objekt gefunden? *)
		IF obj <> -1 THEN
		BEGIN

			(* Tabelle nach Ñquivalenter Taste untersuchen *)
			FOR i:=0 TO MaxTab DO
			BEGIN

				(* Objekt gefunden? *)
				IF ObjTabelle[i].obj = obj THEN
				BEGIN

					(* Tastaturereignis hinzufÅgen *)
					Evnt	:=	Evnt OR MU_KEYBD;

					(* Taste setzen *)
					Mkey	:=	ORD(ObjTabelle[i].key);
					(* Warten, bis Maustaste losgelasen *)
					Evnt_button(0, $1, $0, dummy, dummy, dummy, dummy)
				END
			END
		END
	END;
	{$X-}

	(* Reaktion auf Message-Ereignis *)
	FUNCTION DoMesag(Msg : ARRAY_8) : BOOLEAN;

	BEGIN

		(* Was fÅr eine Nachricht? *)
		CASE Msg[0] OF

			(* Accessory geîffnet? *)
			AC_OPEN		:
				{$X+}
				MyWindow.OpenWindow(WinName);
				{$X-}

			(* Accessory geschlossen? *)
			AC_CLOSE	:
				MyWindow.CloseWindow(FALSE);

			(* Fenster nach oben? *)
			WM_TOPPED:
				IF MyWindow.IsHandle(Msg[3]) THEN
					MyWindow.Top;

			(* Fenster geschlossen? *)
			WM_CLOSED	:

				(* Wenn Programm, dann verlassen. *)
				(* Sonst nur Fenster schlieûen. *)
				IF AppFlag THEN
				BEGIN
					IF MyWindow.IsHandle(Msg[3]) THEN
					BEGIN
						DoMesag	:=	TRUE;
						EXIT
					END
				END
				ELSE
					MyWindow.CloseWindow(TRUE);

			(* Fenster bewegt? *)
			WM_MOVED	:
				IF MyWindow.IsHandle(Msg[3]) THEN
					MyWindow.Move(Msg[4], Msg[5]);

			(* Fenster(teil)bereich neu zeichnen? *)
			WM_REDRAW	:
				IF MyWindow.IsHandle(Msg[3]) THEN
					MyWindow.Draw(Msg[4], Msg[5], Msg[6], Msg[7])
		END;

		DoMesag	:=	FALSE
	END;

	(* Reaktion auf Tastatur-Ereignis *)
	PROCEDURE DoKeybd(MKey : INTEGER);

	(* Konstanten *)
	CONST	(* Texte fÅr Alertboxen *)
			ErrOverFlow		=	'Der Wertebereich|wurde Åberschritten!';
			ErrDivisionBy0	=	'Durch 0 kann|nicht geteilt|werden!';

	(* Variablen *)
	VAR		c		:	CHAR;		(* fÅr Tastatureingaben *)
			anzstr	:	STRING;		(* Anzeige *)
			x, y	:	INTEGER;	(* zur Anzeigeaktualisierung *)

		(* Informationsdialog ausgeben und verwalten *)
		{$X+}
		PROCEDURE DoInfo;

		(* Variablen *)
		VAR	x, y, w, h	:	INTEGER;

		BEGIN

			(* Eingaben/Aktualisierungen sperren *)
			wind_update(BEG_UPDATE);

			(* Dialogbox zentrieren *)
			form_center(AboutObjTree, x, y, w, h);

			(* Hintergrund reservieren *)
			form_dial(FMD_START, x, y, w, h, x, y, w, h);

			(* Dialogbox ausgeben *)
			objc_draw(AboutObjTree, ROOT, MAX_DEPTH, x, y, w, h);

			(* Dialog verwalten *)
			form_do(AboutObjTree, ROOT);

			(* Status SELECTED zurÅcksetzen *)
			AboutObjTree^[BOK].ob_state	:=	AboutObjTree^[BOK].ob_state
												AND NOT(SELECTED);

			(* Hintergrund freigeben *)
			form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);

			(* Aktualisierungen wieder zulassen *)
			wind_update(END_UPDATE)

		END;
		{$X-}

		(* Tastatureingaben falls nîtig Åbersetzen *)
		FUNCTION Translate(key : INTEGER) : CHAR;

		(* Variablen *)
		VAR	scanKey, asciiKey	:	CHAR;

		BEGIN

			(* Lowbyte = ASCII-Code *)
			asciiKey	:=	CHR(LO(key));

			(* Highbyte = Scan-Code *)
			scanKey		:=	CHR(HI(key));

			(* Erst den Scan-Code untersuchen *)
			CASE ORD(scankey) OF
				71	:	Translate	:=	KeyClear;	(* ClrHome *)
				97	:	Translate	:=	KeyClear;	(* Undo *)
				98	:	Translate	:=	KeyInfo;	(* Help *)
				ELSE

					(* Dann den ASCII-Code untersuchen *)
					CASE ORD(asciikey) OF
						8	:	Translate	:=	KeyClear;	(* Backspace *)
						127	:	Translate	:=	KeyClear;	(* Delete *)
						61	:	Translate	:=	KeyEnter	(* '=' *)

					(* Sonst gibt es nichts zu Ñndern *)
					ELSE
						Translate	:=	asciiKey
				END
			END
		END;

	BEGIN

		(* Eingabe auswerten *)
		c	:=	Translate(Mkey);

		(* Information gewÅnscht? *)
		(* Wenn ja, dann ausgeben. Sonst rechnen! *)
		IF c = KeyInfo THEN
			DoInfo
		ELSE
		BEGIN

			(* Eingabeauswertung *)
			IF MyCalc.Input(c) THEN
			BEGIN

				(* Fehler aufgetreten? *)
				{$X+}
				CASE MyCalc.IsError OF

					(* öberlauf? *)
					Overflow	:	form_alert(1, BadAlert(ErrOverFlow));

					(* Division durch 0? *)
					DivisionBy0	:	form_alert(1, BadAlert(ErrDivisionBy0));
				END;
				{$X-}

				(* Ergebnis in Zeichenkette umwandeln *)
				STR(MyCalc.Result, anzstr);

				(* Anzeige neu setzen *)
				SetPtext(RechnerObjTree, TANZEIGE, anzstr);

				(* Offset bestimmen *)
				{$X+}
				objc_offset(RechnerObjTree, TANZEIGE, x, y);
				{$X-}

				(* Anzeige aktualisieren *)
				MyWindow.Draw(x, y, RechnerObjTree^[TANZEIGE].ob_width,
									RechnerObjTree^[TANZEIGE].ob_height)
			END
		END
	END;

BEGIN

	(* Endlosschleife *)
	WHILE TRUE DO
	BEGIN

		(* Ereignis (Message, Maus oder Tastatur) abwarten *)
		Evnt	:=	evnt_multi(MU_MESAG OR MU_BUTTON OR MU_KEYBD,
								1, 1, 1,
								0, 0, 0, 0, 0,
								0, 0, 0, 0, 0,
								Msg,
								0, 0,
								Mmox, Mmoy, Mmobutton,
								Mmokstate, Mkreturn,
								Mbreturn);

		(* Maustaste gedrÅckt? *)
		IF (Evnt AND MU_BUTTON) = MU_BUTTON THEN
			DoButton(Evnt, Mmox, Mmoy, Mkreturn);

		(* Message angekommen? *)
		IF (Evnt AND MU_MESAG) = MU_MESAG THEN
			IF DoMesag(Msg) THEN
				EXIT;

		(* Taste gedrÅckt? *)
		IF (Evnt AND MU_KEYBD) = MU_KEYBD THEN
			DoKeybd(Mkreturn)
	END
END;


(* Hauptprogramm *)
BEGIN

	(* Wenn Initialisierung nicht in Ordnung, dann Ende. *)
	IF NOT(InitApp) THEN
		EXIT;

	(* Programmablauf *)
	DoApp

END.
