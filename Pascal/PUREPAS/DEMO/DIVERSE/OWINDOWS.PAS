(*************************************************************************
  FreeMem/Sweetie/Uhr
  ===================

  Copyright (c) 1992 by Application Systems Heidelberg.
  Alle Rechte vorbehalten.

  Autor:				Dietmar Rabich
  Unit:					WINDOWS.PAS
  Entwicklungssystem:	PurePascal

  Diese Unit Åbernimmt das Windowhandling.

*************************************************************************)

UNIT OWindows;


(* Die Schnittstelle zu den anderen Moduln *)
INTERFACE


(* Unit GEM wird benîtigt *)
USES	Gem;


(* Typen *)
TYPE	(* Rechteck *)
		Rectangle	=	RECORD
							x, y, w, h	:	INTEGER
						END;

		(* Object Rechnerfenster *)
		ObjWindow	=	OBJECT

							(* Objektgrîûe *)
							ObjSize		:	Rectangle;

							(* Handle des Fensters *)
							w_handle	:	INTEGER;

							(* Zentrierflag *)
							IsCentered,

							(* Fehlerflag *)
							IsError		:	BOOLEAN;

							(* String fÅr Titel und Infozeile *)
							WinTitleStr,
							WinInfoStr	:	STRING;

							(* Fensterstatus *)
							WindowState	:	(No, Created, Opened);

							(* Zeiger auf Objektbaum *)
							ObjTree		:	AESTreePtr;

							(* Fensterelemente *)
							Elements	:	INTEGER;

							(* Initialisierung *)
							CONSTRUCTOR Init;

							(* Fenster anlegen *)
							PROCEDURE Create(kind, wx, wy, ww, wh : INTEGER;
												titlestr, infostr : STRING);

							(* Fenster îffnen *)
							PROCEDURE Open(wx, wy, ww, wh : INTEGER);

							(* Fenster schlieûen *)
							PROCEDURE Close;

							(* Fenster lîschen *)
							PROCEDURE Destroy;

							(* Fenster bewegen *)
							PROCEDURE Move(newx, newy : INTEGER);

							(* Fenster nach oben bringen *)
							PROCEDURE Top;

							(* Fensterinhalt ausgeben *)
							PROCEDURE Draw(cx, cy, cw, ch : INTEGER);

							(* Ausschnitt ausgeben *)
							PROCEDURE DrawObj(cx, cy, cw, ch : INTEGER);

							(* Objektbaum setzen *)
							PROCEDURE SetTree(Tree : AESTreePtr);

							(* Elemente setzen *)
							PROCEDURE SetElements(Elem : INTEGER);

							(* Rechnerfenster schlieûen *)
							PROCEDURE CloseWindow(ReallyClose : BOOLEAN);

							(* Rechnerfenster îffnen *)
							FUNCTION OpenWindow(Title : STRING) : BOOLEAN;

							(* Elemente abfragen *)
							FUNCTION GetElements : INTEGER;

							(* Fehler abfragen *)
							FUNCTION Error : BOOLEAN;

							(* Handle prÅfen *)
							FUNCTION IsHandle(handle : INTEGER) : BOOLEAN;
						END;

(* Schnittrechteck bestimmen *)
FUNCTION RectIntersect(xa, ya, wa, ha, xb, yb, wb, hb : INTEGER;
						VAR xi, yi, wi, hi : INTEGER) : BOOLEAN;

(* Kurze (Negativ-)Meldung ausgeben *)
FUNCTION BadAlert(s : STRING) : STRING;


(* Implementation *)
IMPLEMENTATION


(* Konstanten *)
CONST	(* fÅr Alertbox *)
		BadAlertIcon	=	'[3][';
		BadAlertButton	=	'][ Abbruch ]';
		NoWindow		=	'Das Fenster lÑût sich|nicht îffnen!|' +
							'Versuchen Sie es erneut,|wenn Sie ' +
							'ein anderes|geschlossen haben.';

		(* Kennzeichen fÅr kein Fenster *)
		NoWindowId		=	-1;


(* Negativalert-Text *)
FUNCTION BadAlert(s : STRING) : STRING;
BEGIN
	BadAlert	:=	BadAlertIcon + s + BadAlertButton
END;


(* Initialisierung *)
CONSTRUCTOR ObjWindow.Init;

BEGIN

	(* Zentrierflag vorbesetzen *)
	IsCentered	:=	FALSE

END;


(* Fenster anlegen *)
PROCEDURE ObjWindow.Create(kind, wx, wy, ww, wh	:	INTEGER;
								titlestr, infostr	:	STRING);
BEGIN

	(* Fehlerflag vorbesetzen *)
	IsError		:=	FALSE;

	(* Fenster anlegen *)
	w_handle	:=	wind_create(kind, wx, wy, ww, wh);

	(* Handle ungÅltig? Dann Fehlers setzen. *)
	IF w_handle < 0 THEN
		IsError	:=	TRUE
	ELSE
	BEGIN

		(* Fenstertitel setzen? *)
		IF ((kind AND NAME) <> 0) AND (LENGTH(titlestr) > 0) THEN
			WindSetTitle(w_handle, titlestr, WinTitleStr);

		(* Informationszeile setzen? *)
		IF ((kind AND INFO) <> 0) AND (LENGTH(infostr) > 0) THEN
			WindSetInfo(w_handle, infostr, WinInfoStr)
	END
END;


(* Fenster îffnen *)
PROCEDURE ObjWindow.Open(wx, wy, ww, wh : INTEGER);
BEGIN
	IF wind_open(w_handle, wx, wy, ww, wh) < 0 THEN
		IsError	:=	TRUE
END;


(* Fenster schlieûen *)
{$X+}
PROCEDURE ObjWindow.Close;
BEGIN
	wind_close(w_handle)
END;
{$X-}


(* Fenster lîschen *)
{$X+}
PROCEDURE ObjWindow.Destroy;
BEGIN
	wind_delete(w_handle);
	w_handle	:=	NoWindowId
END;
{$X-}


(* Fenster bewegen *)
{$X+}
PROCEDURE ObjWindow.Move(newx, newy : INTEGER);

(* Variablen *)
VAR	x, y, w, h	:	INTEGER;

BEGIN

	(* aktuelle Koordinaten ermitteln *)
	wind_get(w_handle, WF_CURRXYWH, x, y, w, h);

	(* neue Koordinaten setzen *)
	wind_set(w_handle, WF_CURRXYWH, newx, newy, w, h);

	(* neue Koordinaten der Arbeitsbereichs ermitteln *)
	wind_get(w_handle, WF_WORKXYWH, x, y, w, h);

	(* Objektbaum anpassen *)
	ObjSize.x			:=	x + ObjSize.x - ObjTree^[0].ob_x;
	ObjTree^[0].ob_x	:=	x;

	ObjSize.y			:=	y + ObjSize.y - ObjTree^[0].ob_y;
	ObjTree^[0].ob_y	:=	y

END;
{$X-}


(* Fenster nach oben bringen *)
{$X+}
PROCEDURE ObjWindow.Top;
BEGIN
	wind_set(w_handle, WF_TOP, 0, 0, 0, 0)
END;
{$X-}


(* Fensterinhalt ausgeben *)
{$X+}
PROCEDURE ObjWindow.Draw(cx, cy, cw, ch : INTEGER);
VAR	fx, fy, fw, fh,
	rx, ry, rw, rh,
	ix, iy, iw, ih	: INTEGER;
BEGIN

	(* Ausgaben andere sperren *)
	wind_update(BEG_UPDATE);

	(* Desktop-Arbeitsbereich ermitteln *)
	wind_get(0, WF_WORKXYWH, fx, fy, fw, fh);

	(* erstes Rechteck der Liste holen *)
	wind_get(w_handle, WF_FIRSTXYWH, rx, ry, rw, rh);

	(* zeichnen, so lange Breite und Hîhe ungleich 0 *)
	WHILE (rw > 0) AND (rh > 0) DO
	BEGIN

		(* Clipping erstes Rechteck mit Wunschrechteck *)
		IF RectIntersect(rx, ry, rw, rh, cx, cy, cw, ch, ix, iy, iw, ih) THEN

			(* Clipping des vorigen Ergebnis mit Desktop-Arbeitsbereich *)
			IF RectIntersect(fx, fy, fw, fh, ix, iy, iw, ih, ix, iy, iw, ih) THEN

				(* Teil des Arbeitsbereichs neu zeichnen *)
				DrawObj(ix, iy, iw, ih);

		(* nÑchstes Rechteck der Liste *)
		wind_get(w_handle, WF_NEXTXYWH, rx, ry, rw, rh);
	END;

	(* Ausgabe andere wieder ermîglichen *)
	wind_update(END_UPDATE)
END;
{$X-}


(* Fehler abfragen *)
FUNCTION ObjWindow.Error : BOOLEAN;
BEGIN
	Error	:=	IsError;
	IsError	:=	FALSE
END;


(* Handle prÅfen *)
FUNCTION ObjWindow.IsHandle(handle : INTEGER) : BOOLEAN;
BEGIN
	IsHandle	:=	(handle = w_handle)
END;


(* Objektbaum setzen *)
PROCEDURE ObjWindow.SetTree(Tree : AESTreePtr);
BEGIN
	ObjTree	:=	Tree
END;


(* Fensterelemente setzen *)
PROCEDURE ObjWindow.SetElements(Elem : INTEGER);
BEGIN
	Elements	:=	Elem
END;


(* Fensterelemente ermitteln *)
FUNCTION ObjWindow.GetElements : INTEGER;
BEGIN
	GetElements	:=	Elements
END;


(* Rechnerfenster îffnen *)
FUNCTION ObjWindow.OpenWindow(Title : STRING) : BOOLEAN;

(* Variablen *)
VAR	WindowSize		:	Rectangle;

BEGIN

	(* Geîffnet? Dann nur nach oben bringen. Sonst îffnen. *)
	IF WindowState = Opened THEN
	BEGIN
		Top;
		OpenWindow	:=	TRUE
	END
	ELSE
	BEGIN

{$X+}
		(* Objektbaum zentrieren *)
		IF NOT(IsCentered) THEN
		BEGIN
			form_center(ObjTree,
						ObjSize.x, ObjSize.y, ObjSize.w, ObjSize.h);
			IsCentered	:=	TRUE
		END;

		(* Fenstergrîûe berechnen *)
		wind_calc(0, Elements,
					ObjSize.x, ObjSize.y, ObjSize.w, ObjSize.h,
					WindowSize.x, WindowSize.y, WindowSize.w, WindowSize.h);

		(* Fenster îffnen *)
		Create(Elements,
				WindowSize.x, WindowSize.y, WindowSize.w, WindowSize.h,
				Title, '');

		(* Fehler? Dann Schluû. *)
		IF Error THEN
		BEGIN
			form_alert(1, BadAlert(NoWindow));
			OpenWindow	:=	FALSE;
			EXIT
		END
		ELSE
		BEGIN

			(* Fenster angelegt! *)
			WindowState	:=	Created;

			(* Fenster îffnen *)
			Open(WindowSize.x, WindowSize.y, WindowSize.w, WindowSize.h);

			(* Fehler? Dann Schluû. *)
			IF Error THEN
			BEGIN
				form_alert(1, BadAlert(NoWindow));
				OpenWindow	:=	FALSE;
				EXIT
			END
			ELSE

				(* Fenster geîffnet! *)
				WindowState	:=	Opened
		END;
{$X-}
		OpenWindow	:=	TRUE
	END
END;


(* Rechnerfenster schlieûen *)
PROCEDURE ObjWindow.CloseWindow(ReallyClose : BOOLEAN);
BEGIN

	(* Ganz und gar schlieûen? *)
	IF ReallyClose THEN
	BEGIN

		(* Geîffnet? Dann schlieûen und lîschen! *)
		IF WindowState = Opened THEN
		BEGIN
			Close;
			Destroy
		END;

		(* Nicht geîffnet, aber angelegt? Dann lîschen! *)
		IF WindowState = Created THEN
			Destroy
	END
	ELSE

		(* Nur lîschen, da Fenster mit Sicherheit geschlossen. *)
		IF (WindowState = Created) OR (WindowState = Opened) THEN
			Destroy;

	(* Kein Fenster mehr! *)
	WindowState	:=	No
END;


(* Teilbereich neu zeichnen *)
{$X+}
PROCEDURE ObjWindow.DrawObj(cx, cy, cw, ch : INTEGER);
BEGIN

	(* Ausgabe *)
	objc_draw(ObjTree, ROOT, MAX_DEPTH, cx, cy, cw, ch)

END;
{$X-}


(* Schnittrechteck berechnen *)
FUNCTION RectIntersect(xa, ya, wa, ha, xb, yb, wb, hb : INTEGER;
					   VAR xi, yi, wi, hi : INTEGER) : BOOLEAN;

	(* Maximum *)
	FUNCTION Max(x, y : INTEGER) : INTEGER;
	BEGIN
		IF x > y THEN
			Max	:=	x
		ELSE
			Max	:=	y
	END;

	(* Minimum *)
	FUNCTION Min(x, y : INTEGER) : INTEGER;
	BEGIN
		IF x < y THEN
			Min	:=	x
		ELSE
			Min	:=	y
	END;

BEGIN

	(* maximale X-Koordinate *)
	xi	:=	Max(xa, xb);

	(* maximale Y-Koordinate *)
	yi	:=	Max(ya, yb);

	(* minimale Breite *)
	wi	:=	Min(xa + wa, xb + wb);
	DEC(wi, xi);

	(* minimale Hîhe *)
	hi	:=	Min(ya + ha, yb + hb);
	DEC(hi, yi);

	(* Rechteck ermittelt? *)
	RectIntersect	:=	(wi > 0) AND (hi > 0)

END;

END.