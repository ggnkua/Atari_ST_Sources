(*************************************************************************
  FreeMem	Copyright (c) 1992 by Application Systems Heidelberg.
  =======	Alle Rechte vorbehalten.

  Autor:				Dietmar Rabich
  Programm:				FREEMEM.PAS
  Entwicklungssystem:	PurePascal

  Die Speicheranzeige ist ein kleines Beispielprogramm, welches mit
  PurePascal entwickelt wurde. Es ist sowohl als Programm als auch als
  Accessory lauffÑhig.

  Wichtig!

  Vor der öbersetzung des Programms mÅssen die Resourcen mit BINOBJ
  Åbersetzt werden. Aufruf:

  BINOBJ fmrsc.rsc fmrsc FmRsc

*************************************************************************)

PROGRAM MeineSpeicheranzeige;


(* Importierte Units *)
(* Gem:			Standard-Unit von PurePascal *)
(* Resources:	Unit zur Verwaltung von eingebundenen Resourcen *)
(* OWindows:	Unit zur Verwaltung des Objekt-Fensters *)
USES Gem, OWindows, Resources;


(* Konstanten *)
CONST	(* Name des Programms *)
		AppName		=	'FreeMem';
		WinName		=	' ' + AppName + ' ';
		AccName		=	'  ' + AppName + '...';


(* Konstanten fÅr die Resourcen *)
{$I FMRSC.I}


(* Typen *)
TYPE	Anzeige	=	RECORD
						MemAvail		:	BOOLEAN;
						CurrentValue	:	LONGINT
					END;


(* Variablen *)
VAR	appl_id,								(* Applikation-Identifikation *)
	menu_id			:	INTEGER;			(* MenÅidentifikation (ACC) *)
	MyWindow		:	ObjWindow;			(* Fenster-Objekt *)
	MemObjTree,								(* Objektbaum Anzeige *)
	AboutObjTree	:	AESTreePtr;			(* Objektbaum About-Dialog *)
	OldProc			:	POINTER;			(* fÅr EXIT-Prozedur *)
	MyResource		:	TResourcePoolPtr;	(* Resourcepointer *)
	Show, Old		:	Anzeige;			(* Anzeigeform *)


(* Resourcen *)
PROCEDURE FmRsc;
EXTERNAL;
{$L FMRSC}


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

(* Variablen *)
VAR		dummy, CellH	:	INTEGER;

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
	MyResource		:=	InitResourcePool(@FmRsc);
	MemObjTree		:=	GetResource(MyResource, FREEMEM);
	AboutObjTree	:=	GetResource(MyResource, COPYRGHT);
	SetPtext(MemObjTree, TMEM, '');
	{$X+}
	graf_handle(dummy, dummy, dummy, CellH);
	{$X-}
	MemObjTree^[ROOT].ob_height	:=	CellH;
	MemObjTree^[TMEM].ob_height	:=	CellH;

	(* Instanz MyWindow vorbereiten *)
	MyWindow.SetTree(MemObjTree);
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

	(* Anzeige von MemAvail *)
	Show.MemAvail		:=	TRUE;
	Show.CurrentValue	:=	0;
	Old					:=	Show;

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

					(* Anzeige des Speicherplatzes *)
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

	(* Variablen *)
	VAR	anzstr		:	STRING[32];
		NeueAnzeige	:	Anzeige;

		(* Ausgabe eines Strings in eine Dialogbox *)
		PROCEDURE OutString(obj : INTEGER; astr : STRING);

		(* Variablen *)
		VAR	x, y	:	INTEGER;

		BEGIN

			(* Anzeige neu setzen *)
			SetPtext(MemObjTree, obj, astr);

			(* Offset bestimmen *)
			{$X+}
			objc_offset(MemObjTree, obj, x, y);
			{$X-}

			(* Anzeige aktualisieren *)
			MyWindow.Draw(x, y, MemObjTree^[obj].ob_width,
								MemObjTree^[obj].ob_height)
		END;

	BEGIN

		(* Speicheranzeige setzen *)
		IF Show.MemAvail THEN
			Show.CurrentValue	:=	MEMAVAIL
		ELSE	
			Show.CurrentValue	:=	MAXAVAIL;

		(* Anzeige nur, wenn sich die Werte geÑndert haben *)
		IF (Show.CurrentValue <> Old.CurrentValue) OR
			(Show.MemAvail <> Old.MemAvail) THEN
		BEGIN

			STR(Show.CurrentValue, anzstr);

			IF Show.MemAvail THEN
				anzstr	:=	'+' + anzstr;

			anzstr	:=	anzstr + ' ' + 'Byte';
			OutString(TMEM, anzstr);

			Old	:= Show
		END

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
			DoInfo;

		IF LO(MKey) = 32 THEN
			Show.MemAvail	:=	NOT(Show.MemAvail)

	END;

	(* Reaktion auf Maustasten-Ereignis *)
	PROCEDURE DoButton(Mx, My, MButton : INTEGER);

	BEGIN

		(* Doppelklick auf TMEM? *)
		IF (MButton = 2) AND
			(objc_find(MemObjTree, ROOT, MAX_DEPTH, Mx, My) = TMEM) THEN
			Show.MemAvail	:=	NOT(Show.MemAvail)

	END;

BEGIN

	(* Auf diese Events wird reagiert *)
	IF AppFlag THEN
		REvent	:=	MU_MESAG OR MU_KEYBD OR MU_BUTTON OR MU_TIMER
	ELSE
		REvent	:=	MU_MESAG OR MU_KEYBD OR MU_BUTTON;

	(* Endlosschleife *)
	WHILE TRUE DO
	BEGIN

		(* Ereignis (Message, Maus, Tastatur oder Timer) abwarten *)
		Evnt	:=	evnt_multi(REvent,
								2, 1, 1,
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
			DoKeybd(Mkreturn);

		(* Mausklick? *)
		IF (Evnt AND MU_BUTTON) = MU_BUTTON THEN
			DoButton(Mmox, Mmoy, Mbreturn)
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
