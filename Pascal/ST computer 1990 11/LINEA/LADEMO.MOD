MODULE LADemo;

FROM LowLevelLineA IMPORT LineAVars, PutPixel, ArbitraryLine,
  FilledRectangle, FilledPolygon;

FROM SYSTEM IMPORT ADR;

CONST videowidth = 640;  (* fuer hohe Aufloesung *)
      videoheigth = 400;

PROCEDURE Rectangle;
VAR Pattern : ARRAY[0..0] OF CARDINAL;
BEGIN
  Pattern[0] := 0;
  LineAVars^.X1 := 0;             (*gesamter Bildschirm*)
  LineAVars^.Y1 := 0;
  LineAVars^.X2 := videowidth-1;
  LineAVars^.Y2 := videoheigth-1;
  LineAVars^.COLBIT0 := 1;        (*alle Planes*)
  LineAVars^.COLBIT1 := 1;
  LineAVars^.COLBIT2 := 1;
  LineAVars^.COLBIT3 := 1;
  LineAVars^.WMODE := 0;          (*Replace*)
  LineAVars^.PATPTR := ADR(Pattern[0]);
  LineAVars^.PATMSK := 0;         (*1 Linienmuster*)
  LineAVars^.MFILL := 0;          (*nur erste Ebene*)
  LineAVars^.CLIP := 0;           (*Clipping aus*)
  FilledRectangle;
END Rectangle;

PROCEDURE Points;
VAR x,y,i : INTEGER;
BEGIN
  LineAVars^.INTIN^[0] := 1;  (* Farbe setzen *)
  FOR i := 1 TO 32767 DO
    x := ((i MOD 211) * 7) MOD videowidth + i MOD 7;
    y := ((i MOD 83) * 5) MOD videoheigth + i MOD 5;
    LineAVars^.PTSIN^[0] := x;
    LineAVars^.PTSIN^[1] := y;
    PutPixel;
  END(*FOR*);
END Points;

PROCEDURE Lines;
VAR i : INTEGER;
BEGIN
  LineAVars^.COLBIT0 := 1;
  LineAVars^.COLBIT1 := 1;
  LineAVars^.COLBIT2 := 1;
  LineAVars^.COLBIT3 := 1;
  LineAVars^.LNMASK  := 0FFFFH;
  LineAVars^.WMODE   := 0; (* Replace *)
  LineAVars^.LSTLIN  := 1; (* letzten Punkt zeichen *)
  FOR i := 0 TO videowidth-1 BY 8 DO
    LineAVars^.X1 := videowidth-i-1;
    LineAVars^.Y1 := 0;
    LineAVars^.X2 := 0;
    LineAVars^.Y2 := i DIV 2;
    ArbitraryLine;
  END(*FOR*);
END Lines;

PROCEDURE Polygon;
VAR Pattern : ARRAY[0..15] OF CARDINAL;
    y : INTEGER;
BEGIN
  Pattern[0] := 0FFFFH; (*Muster*)
  Pattern[1] := 0EEEEH;
  Pattern[2] := 0DDDDH;
  Pattern[3] := 0CCCCH;
  Pattern[4] := 0BBBBH;
  Pattern[5] := 0AAAAH;
  Pattern[6] := 09999H;
  Pattern[7] := 08888H;
  Pattern[8] := 07777H;
  Pattern[9] := 06666H;
  Pattern[10]:= 05555H;
  Pattern[11]:= 04444H;
  Pattern[12]:= 03333H;
  Pattern[13]:= 02222H;
  Pattern[14]:= 01111H;
  Pattern[15]:= 0H;
  LineAVars^.PTSIN^[0] := 10;
  LineAVars^.PTSIN^[1] := 10;
  LineAVars^.PTSIN^[2] := 160;
  LineAVars^.PTSIN^[3] := 40;
  LineAVars^.PTSIN^[4] := 170;
  LineAVars^.PTSIN^[5] := 90;
  LineAVars^.PTSIN^[6] := 310;
  LineAVars^.PTSIN^[7] := 120;
  LineAVars^.PTSIN^[8] := 180;
  LineAVars^.PTSIN^[9] := 190;
  LineAVars^.PTSIN^[10] := 10;
  LineAVars^.PTSIN^[11] := 10;
  LineAVars^.CONTRL^[1] := 6;
  LineAVars^.COLBIT0 := 1;
  LineAVars^.COLBIT1 := 1;
  LineAVars^.COLBIT2 := 1;
  LineAVars^.COLBIT3 := 1;
  LineAVars^.WMODE   := 0; (* Replace *)
  LineAVars^.PATPTR  := ADR(Pattern);
  LineAVars^.PATMSK  := 15;(* 16 Linienmuster *)
  LineAVars^.MFILL   := 0; (* nur erste Ebene *)
  LineAVars^.CLIP    := 0; (* Clipping aus *)
  FOR y := 10 TO 190 DO
    LineAVars^.Y1 := y;
    FilledPolygon
  END(*FOR*);
END Polygon;

BEGIN
  Rectangle;
  Points;
  Lines;
  Polygon;
END LADemo.
