(* UNIT Turtles zur Erzeugung von Turtlegraphik                   *)
(* Copyright 1992 by Application Systems Heidelberg Software GmbH *)
UNIT Turtles;

(* îffentlicher Teil *)
INTERFACE

(* Konstanten *)
CONST	MaxX		=	1000;		(* maximale X-Koordinate *)
		MaxY		=	1000;		(* maximale Y-Koordinate *)
		MinPhi		=	0;			(* minimaler Winkel *)
		MaxPhi		=	359;		(* maximaler Winkel *)
		MaxWidth	=	2 * MaxX;	(* maximale Breite (-1) *)
		MaxHeight	=	2 * MaxY;	(* maximale Hîhe (-1) *)

TYPE	CoordX		=	-MaxX..MaxX;		(* Wertebereich horizontal *)
		CoordY		=	-MaxY..MaxY;		(* Wertebereich vertikal *)
		Angel		=	MinPhi..MaxPhi;		(* Wertebereich Winkel *)
		AngelRange	=	-MaxPhi..MaxPhi;	(* erlaubte WinkelverÑnderung *)
		TurtleBase	=	OBJECT				(* Basisobjekt Turtle *)
							X			: CoordX;	(* x-Koordinate *)
							Y			: CoordY;	(* y-Koordinate *)
							Phi			: Angel;	(* Winkel *)
							v_handle,				(* VDI-Handle *)
							ScreenX,				(* max. x-Koordinate *)
							ScreenY,				(* max. y-Koordinate *)
							ColorBackground,		(* Farbe Hintergrund *)
							ColorLine,				(* Farbe Linie *)
							ColorTurtle	: INTEGER;	(* Farbe Turtle *)
							Visible,				(* Turtle sichtbar? *)
							Paint,					(* Turtle zeichnet? *)
							ErrorFlag,				(* Fehler? *)
							WithDraw,				(* Mit Draw? *)
							Shown		: BOOLEAN;	(* Turtle gezeichnet? *)


							(* Initialisieren *)
							CONSTRUCTOR Init;

							(* Abmelden *)
							DESTRUCTOR Done;

							(* Fehlerabfrage *)
							FUNCTION Error : BOOLEAN;

							(* Bildschirm lîschen *)
							PROCEDURE Clear;

							(* Position und Ausrichtung setzen *)
							PROCEDURE Default(nx : CoordX; ny : CoordY; nw : Angel);

							(* Linienfarbe setzen *)
							PROCEDURE LineColor(c : INTEGER);

							(* Hintergrundfarbe setzen *)
							PROCEDURE BackgroundColor(c : INTEGER);

							(* Turtlefarbe setzen *)
							PROCEDURE TurtleColor(c : INTEGER);

							(* Linienfarbe ermitteln *)
							FUNCTION GetLineColor : INTEGER;

							(* Hintergrundfarbe ermitteln *)
							FUNCTION GetBackgroundColor : INTEGER;

							(* Turtlefarbe ermitteln *)
							FUNCTION GetTurtleColor : INTEGER;

							(* Turtle im positiven Sinne drehen *)
							PROCEDURE Turn(nw : AngelRange);

							(* Turtle bewegen *)
							PROCEDURE Go(amount : INTEGER);

							(* Stift anheben *)
							PROCEDURE PenUp;

							(* Stift senken *)
							PROCEDURE PenDown;

							(* Turtle zeigen *)
							PROCEDURE Show;

							(* Turtle verstecken *)
							PROCEDURE Hide;

							(* Turtle zeichnen *)
							PROCEDURE Draw(showit : BOOLEAN);
						END;
		Turtle		=	OBJECT(TurtleBase)	(* normale Turtle *)

							(* Drehung nach links *)
							PROCEDURE Left(w : Angel);

							(* Drehung nach rechts *)
							PROCEDURE Right(w : Angel);

							(* Bewegung vorwÑrts *)
							PROCEDURE Forward(amount : INTEGER);

							(* Bewegung rÅckwÑrts *)
							PROCEDURE Backward(amount : INTEGER);
						END;
		TurtleGeom	=	OBJECT(Turtle)		(* erweiterte Turtle *)

							(* Rechteck ausgeben *)
							PROCEDURE Rectangle(w, h : INTEGER);
						END;

(* Implementation *)
IMPLEMENTATION

(* UNITs GEM und TOS importieren *)
USES Gem, Tos;
VAR Dummy : INTEGER;
(* *** Methoden von TurtleBase *** *)
CONSTRUCTOR TurtleBase.Init;
VAR	i	: INTEGER;
	WorkIn		: workin_array;
	WorkOut		: workout_array;
BEGIN

	(* Variablen vorbesetzen *)
	ErrorFlag		:= FALSE;
	ColorBackground	:= White;
	ColorLine		:= Black;
	ColorTurtle		:= Blue;
	Visible			:= TRUE;
	Paint			:= TRUE;
	Shown			:= FALSE;
	WithDraw		:= TRUE;

	(* virtuelle VDI-Workstation îffnen *)
	v_handle		:= graf_handle(Dummy, Dummy, Dummy, Dummy);
	FOR i:=1 TO 9 DO
		WorkIn[i]	:= 1;
	WorkIn[0]	:= 2 + Getrez;
	WorkIn[10]	:= 2;
	v_opnvwk(WorkIn, v_handle, WorkOut);
	IF v_handle = 0 THEN
	BEGIN
		ErrorFlag	:= TRUE;
		EXIT
	END;

	(* Bildschirmgrîûe ermitteln *)
	ScreenX	:= WorkOut[0];
	ScreenY	:= WorkOut[1];

	(* Vorbereitung des Bildschirms *)
	Draw(TRUE);
	Clear;
	Default(0, 0, 90)
END;

DESTRUCTOR TurtleBase.Done;
BEGIN
	Draw(FALSE);
	IF v_handle <> 0 THEN
		v_clsvwk(v_handle)
END;

PROCEDURE TurtleBase.Clear;
VAR	xy		: ARRAY_4;
BEGIN
	Draw(FALSE);
	v_clrwk(v_handle);
	Dummy	:= vswr_mode(v_handle, MD_REPLACE);
	Dummy	:= vsf_color(v_handle, ColorBackground);
	xy[0]	:= 0;
	xy[1]	:= 0;
	xy[2]	:= ScreenX;
	xy[3]	:= ScreenY;
	v_bar(v_handle, xy);
	Draw(TRUE)
END;

PROCEDURE TurtleBase.Default(nx : CoordX; ny : CoordY; nw : Angel);
BEGIN
	Draw(FALSE);
	X	:= nx;
	Y	:= ny;
	Phi	:= nw;
	Draw(TRUE)
END;

PROCEDURE TurtleBase.LineColor(c : INTEGER);
BEGIN
	ColorLine	:= c
END;

PROCEDURE TurtleBase.BackgroundColor(c : INTEGER);
BEGIN
	ColorBackground	:= c
END;

PROCEDURE TurtleBase.TurtleColor(c : INTEGER);
BEGIN
	ColorTurtle	:= c
END;

FUNCTION TurtleBase.GetLineColor : INTEGER;
BEGIN
	GetLineColor	:= ColorLine
END;

FUNCTION TurtleBase.GetBackgroundColor : INTEGER;
BEGIN
	GetBackgroundColor	:= ColorBackground
END;

FUNCTION TurtleBase.GetTurtleColor : INTEGER;
BEGIN
	GetTurtleColor	:= ColorTurtle
END;

PROCEDURE TurtleBase.Turn(nw : AngelRange);
BEGIN
	IF WithDraw THEN
		Draw(FALSE);
	Phi	:= (MaxPhi + 1 + Phi + nw) MOD (MaxPhi + 1);
	IF WithDraw THEN
		Draw(TRUE)
END;

PROCEDURE TurtleBase.Go(amount : INTEGER);
VAR	OldX		: CoordX;
	OldY		: CoordY;
	xy			: ptsin_ARRAY;
	XNeu, YNeu	: INTEGER;
	Argument	: REAL;
BEGIN
	IF WithDraw THEN
		Draw(FALSE);
	
	OldX	:= X;
	OldY	:= Y;

	(* neue Koordinaten in der richtigen Richtung *)
	Argument	:= (PI * Phi) / 180.0;
	XNeu		:= X + ROUND(amount * COS(Argument));
	YNeu		:= Y + ROUND(amount * SIN(Argument));

	(* Bildschirmgrenzen berÅcksichtigen *)
	IF ABS(XNeu) > MaxX THEN
	BEGIN
		IF XNeu < 0 THEN
			X	:= -MaxX
		ELSE
			X	:= MaxX
	END
	ELSE
		X	:= XNeu;
	IF ABS(YNeu) > MaxY THEN
	BEGIN
		IF YNeu < 0 THEN
			Y	:= -MaxY
		ELSE
			Y	:= MaxY
	END
	ELSE
		Y	:= YNeu;

	(* Ausgabe, wenn Flag gesetzt ist *)
	IF Paint THEN
	BEGIN
		Dummy	:= vsl_color(v_handle, GetLineColor);

		(* Die Koordinaten mÅssen umgerechnet werden! *)
		xy[0]	:= ROUND((LONGINT(OldX + MaxX) * LONGINT(ScreenX)) /
							LONGINT(MaxWidth));
		xy[1]	:= ROUND((LONGINT(MaxHeight - OldY - MaxY) *
							LONGINT(ScreenY)) / LONGINT(MaxHeight));
		xy[2]	:= ROUND((LONGINT(X + MaxX) * LONGINT(ScreenX)) /
							LONGINT(MaxWidth));
		xy[3]	:= ROUND((LONGINT(MaxHeight - Y - MaxY) *
							LONGINT(ScreenY)) / LONGINT(MaxHeight));
		v_pline(v_handle, 2, xy)
	END;
	IF WithDraw THEN
		Draw(TRUE)
END;

PROCEDURE TurtleBase.PenUp;
BEGIN
	Paint	:= FALSE
END;

PROCEDURE TurtleBase.PenDown;
BEGIN
	Paint	:= TRUE
END;

PROCEDURE TurtleBase.Show;
BEGIN
	Visible	:= TRUE;
	Draw(TRUE)
END;

PROCEDURE TurtleBase.Hide;
BEGIN
	Draw(FALSE);
	Visible	:= FALSE
END;

PROCEDURE TurtleBase.Draw(showit : BOOLEAN);
CONST	TurtleSize	= 40;
VAR		OldColor	: INTEGER;
		OldPaint		: BOOLEAN;
BEGIN
	IF Visible THEN
	BEGIN
		IF (NOT(Shown) AND showit) OR
		   (Shown AND NOT(showit)) THEN
		BEGIN
			WithDraw	:= FALSE;
			OldPaint	:= Paint;
			Paint		:= TRUE;
			Shown		:= NOT(Shown);
			Dummy		:= vswr_mode(v_handle, MD_XOR);
			OldColor	:= GetLineColor;
			LineColor(ColorTurtle);
			Turn(150);
			Go(TurtleSize);
			Turn(120);
			Go(TurtleSize);
			Turn(120);
			Go(TurtleSize);
			Turn(-30);
			LineColor(OldColor);
			Dummy		:= vswr_mode(v_handle, MD_REPLACE);
			Paint		:= OldPaint;
			WithDraw	:= TRUE
		END
	END
END;

FUNCTION TurtleBase.Error : BOOLEAN;
BEGIN
	Error		:= ErrorFlag;
	ErrorFlag	:= FALSE
END;

(* *** Methoden von Turtle *** *)
PROCEDURE Turtle.Left(w : Angel);
BEGIN
	Turn(w)
END;

PROCEDURE Turtle.Right(w : Angel);
BEGIN
	Turn(-w)
END;

PROCEDURE Turtle.Forward(amount : INTEGER);
BEGIN
	Go(amount)
END;

PROCEDURE Turtle.Backward(amount : INTEGER);
BEGIN
	Go(-amount)
END;

(* *** Methoden von TurtleGeom *** *)
PROCEDURE TurtleGeom.Rectangle(w, h : INTEGER);
VAR	HalfW, HalfH	: INTEGER;
BEGIN
	w		:= w - w MOD 2;
	h		:= h - h MOD 2;
	HalfW	:= w DIV 2;
	HalfH	:= h DIV 2;
	PenUp;
	Backward(HalfH);
	PenDown;
	Right(90);
	Forward(HalfW);
	Left(90);
	Forward(h);
	Left(90);
	Forward(w);
	Left(90);
	Forward(h);
	Left(90);
	Forward(HalfW);
	Left(90);
	PenUp;
	Forward(HalfH);
	PenDown
END;

END.