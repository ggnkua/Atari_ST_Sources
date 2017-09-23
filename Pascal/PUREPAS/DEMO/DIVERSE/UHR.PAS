(*************************************************************************
  Uhr	Copyright (c) 1992 by Application Systems Heidelberg.
  ===	Alle Rechte vorbehalten.

  Autor:				Dietmar Rabich
  Programm:				UHR.PAS
  Entwicklungssystem:	PurePascal

  Die Uhr ist ein kleines Beispielprogramm, welches mit
  PurePascal entwickelt wurde. Es ist sowohl als Programm als auch als
  Accessory lauffÑhig.

  Wichtig!

  Vor der öbersetzung des Programms mÅssen die Resourcen mit BINOBJ
  Åbersetzt werden. Aufruf:

  BINOBJ uhrrsc.rsc uhrrsc UhrRsc

*************************************************************************)

PROGRAM MeineUhr;


(* Importierte Units *)
(* Gem:			Standard-Unit von PurePascal *)
(* Dos:			Standard-Unit von PurePascal *)
(* Resources:	Unit zur Verwaltung von eingebundenen Resourcen *)
(* OWindows:	Unit zur Verwaltung des Objekt-Fensters *)
USES Dos, Gem, OWindows, Resources;


(* Konstanten *)
CONST	(* Name des Programms *)
		AppName		=	'Uhr';
		WinName		=	' ' + AppName + ' ';
		AccName		=	'  ' + AppName + '...';


(* Konstanten fÅr die Resourcen *)
{$I UHRRSC.I}


VAR	appl_id,								(* Applikation-Identifikation *)
	menu_id			:	INTEGER;			(* MenÅidentifikation (ACC) *)
	MyWindow		:	ObjWindow;			(* Fenster-Objekt *)
	UhrObjTree,								(* Objektbaum Uhr *)
	AboutObjTree	:	AESTreePtr;			(* Objektbaum About-Dialog *)
	OldProc			:	POINTER;			(* fÅr EXIT-Prozedur *)
	MyResource		:	TResourcePoolPtr;	(* Resourcepointer *)


(* Resourcen *)
PROCEDURE UhrRsc;
EXTERNAL;
{$L UHRRSC}


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
	MyResource		:=	InitResourcePool(@UhrRsc);
	UhrObjTree		:=	GetResource(MyResource, UHR);
	AboutObjTree	:=	GetResource(MyResource, COPYRGHT);
	SetPtext(UhrObjTree, TZEIT, '');
	SetPtext(UhrObjTree, TDATUM, '');

	(* Instanz MyWindow vorbereiten *)
	MyWindow.Init;
	MyWindow.SetTree(UhrObjTree);
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

VAR		Evnt, REvent	:	INTEGER;	(* Event *)
		Msg				:	ARRAY_8;	(* Messages *)
		Mmox, Mmoy,						(* fÅr Events *)
		Mmobutton,
		Mmokstate, Mkreturn,
		Mbreturn		:	INTEGER;

	(* Reaktion auf Message-Ereignis *)
	FUNCTION DoMesag(Msg : ARRAY_8) : BOOLEAN;

	BEGIN

		(* Was fÅr eine Nachricht? *)
		CASE Msg[0] OF

			(* Accessory geîffnet? *)
			AC_OPEN		:
				BEGIN
					{$X+}
					MyWindow.OpenWindow(WinName);
					{$X-}

					(* Anzeige der Uhrzeit *)
					REvent	:=	REvent OR MU_TIMER
				END;

			(* Accessory geschlossen? *)
			AC_CLOSE	:
				BEGIN
					(* keine Anzeige mehr *)
					REvent	:=	REvent AND NOT(MU_TIMER);

					(* Fenster zu *)
					MyWindow.CloseWindow(FALSE)
				END;

			(* Fenster nach oben? *)
			WM_TOPPED:
				IF MyWindow.IsHandle(Msg[3]) THEN
					MyWindow.Top;

			(* Fenster geschlossen? *)
			WM_CLOSED	:
				BEGIN

					(* keine Anzeige mehr *)
					REvent	:=	REvent AND NOT(MU_TIMER);

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
						MyWindow.CloseWindow(TRUE)
				END;

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

	(* Reaktion auf Timer-Ereignis *)
	PROCEDURE DoTimer;

	(* Konstanten *)
	CONST	TimeSep	=	':';
			DateSep	=	'/';

	(* Variablen *)
	VAR	A, B, C, Dummy	:	WORD;
		anzstr			:	STRING[16];
		tempstr			:	STRING[8];

		(* Ausgabe eines Strings in eine Dialogbox *)
		PROCEDURE OutString(obj : INTEGER; astr : STRING);

		(* Variablen *)
		VAR	x, y	:	INTEGER;

		BEGIN

			(* Anzeige neu setzen *)
			SetPtext(UhrObjTree, obj, astr);

			(* Offset bestimmen *)
			{$X+}
			objc_offset(UhrObjTree, obj, x, y);
			{$X-}

			(* Anzeige aktualisieren *)
			MyWindow.Draw(x, y, UhrObjTree^[obj].ob_width,
								UhrObjTree^[obj].ob_height)
		END;

	BEGIN

		(* Zeit setzen *)
		GetTime(A, B, C, Dummy);
		STR(A:2, anzstr);
		anzstr	:=	anzstr + TimeSep;
		STR(B:2, tempstr);
		anzstr	:=	anzstr + tempstr + TimeSep;
		STR(C:2, tempstr);
		anzstr	:=	anzstr + tempstr;
		OutString(TZEIT, anzstr);

		(* Datum setzen *)
		GetDate(A, B, C, Dummy);
		STR(C:2, anzstr);
		anzstr	:=	anzstr + DateSep;
		STR(B:2, tempstr);
		anzstr	:=	anzstr + tempstr + DateSep;
		STR((A MOD 100):2, tempstr);
		anzstr	:=	anzstr + tempstr;
		OutString(TDATUM, anzstr)

	END;

	(* Reaktion auf Tastatur-Ereignis *)
	PROCEDURE DoKeybd(MKey : INTEGER);

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

	BEGIN

		(* Information gewÅnscht? *)
		(* Wenn ja, dann ausgeben. *)
		IF HI(MKey) = 98 THEN
			DoInfo

	END;

BEGIN

	(* Auf diese Events wird reagiert *)
	IF AppFlag THEN
		REvent	:=	MU_MESAG OR MU_KEYBD OR MU_TIMER
	ELSE
		REvent	:=	MU_MESAG OR MU_KEYBD;

	(* Endlosschleife *)
	WHILE TRUE DO
	BEGIN

		(* Ereignis (Message, Tastatur oder Timer) abwarten *)
		Evnt	:=	evnt_multi(REvent,
								1, 1, 1,
								0, 0, 0, 0, 0,
								0, 0, 0, 0, 0,
								Msg,
								1000, 0,
								Mmox, Mmoy, Mmobutton,
								Mmokstate, Mkreturn,
								Mbreturn);

		(* Message angekommen? *)
		IF (Evnt AND MU_MESAG) = MU_MESAG THEN
			IF DoMesag(Msg) THEN
				EXIT;

		(* Timer? *)
		IF (Evnt AND MU_TIMER) = MU_TIMER THEN
			DoTimer;

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
