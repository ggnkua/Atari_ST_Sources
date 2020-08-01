MODULE Wind;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
S. Junker  |31.8.93  |DCL and other improvements
S. Junker  |1.11.93  |back to the roots
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, AES, Appl, Error, Task;

CONST (* element bits *)
  TITLE* = 0; CLOSER* = 1; FULLER* = 2; MOVER* = 3; INFOLINE* = 4;
  SIZER* = 5; UPARROW* = 6; DNARROW* = 7; VSLIDER* = 8; LFARROW* = 9;
  RTARROW* = 10; HSLIDER* = 11;
  (* AES 4.1: Iconifier *)          (* CF *)
  SMALLER* = 14;

  (* get/set types *)
  ELEMENTS* = 1; NAME* = 2; INFO* = 3; WORK* = 4; CURR* = 5; PREV* = 6;
  FULL* = 7; HSLIDE* = 8; VSLIDE* = 9; TOP* = 10; FIRST* = 11; NEXT* = 12;
  NEWDESK* = 14; HSLSIZE* = 15; VSLSIZE* = 16; SCREEN* = 17;
  (* AES 4.1 *)               (* CF *)
  COLOR*    = 18; DCOLOR*   = 19; OWNER*     = 20; BEVENT* = 24;
  BOTTOM*   = 25; ICONIFY*  = 26; UNICONIFY* = 27; UNICONIFYXYWH* = 28;
  TOOLBAR*  = 30; FTOOLBAR* = 31; NTOOLBAR*  = 32;

  (* update type *)
  ENDUPD* = 0; BEGUPD* = 1; ENDMCTRL* = 2; BEGMCTRL* = 3;

  (* calc type *)
  WHOLE* = 0; WORKSP* = 1;


VAR
  Updat,Mouse : BOOLEAN;


PROCEDURE Create*(Elements : SET; X,Y,W,H : INTEGER; VAR Handle : INTEGER) : BOOLEAN;
 (* tells AES to create a new window. If it has no windows left, an error
    message is shown and FALSE returned. The AES handle is returned in Handle *)
 BEGIN
  AES.IntIn[0] := SHORT(S.VAL(LONGINT,Elements));
  AES.IntIn[1] := X; AES.IntIn[2] := Y;
  AES.IntIn[3] := W; AES.IntIn[4] := H;
  AES.Call(64050100H); Handle := AES.IntOut[0];
  IF Handle >= 0 THEN RETURN TRUE
  ELSE
    Error.StrOut("no more windows"); RETURN FALSE
  END;
 END Create;

PROCEDURE Open*(Handle,X,Y,W,H : INTEGER);
  (* opens the window with handle Handle *)
 BEGIN
  AES.IntIn[0] := Handle;
  AES.IntIn[1] := X; AES.IntIn[2] := Y;
  AES.IntIn[3] := W; AES.IntIn[4] := H;
  AES.Call(65050100H);
 END Open;

PROCEDURE Close*(Handle : INTEGER);
  (* closes the window with handle Handle *)
 BEGIN
  AES.IntIn[0] := Handle; AES.Call(66010100H);
 END Close;

PROCEDURE Delete*(Handle : INTEGER);
  (* deletes the window with handle Handle *)
 BEGIN
  AES.IntIn[0] := Handle; AES.Call(67010100H);
 END Delete;

(* The Get?/Set? procedures are derived from the AES wind_get/wind_set
   procedures *)

PROCEDURE GetXYWH*(Handle,Type : INTEGER; VAR x,y,w,h : INTEGER);
 (* Type can be WORK, CURR, PREV, FULL, FIRST or NEXT *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := Type;
  AES.Call(68020500H);
  x := AES.IntOut[1]; y := AES.IntOut[2];
  w := AES.IntOut[3]; h := AES.IntOut[4];
 END GetXYWH;

PROCEDURE GetVal*(Handle,Type : INTEGER) : INTEGER;
 (* Type can be HSLIDE, VSLIDE, HSLSIZE or VSLSIZE. Returns position or size *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := Type;
  AES.Call(68020500H); RETURN AES.IntOut[1];
 END GetVal;

PROCEDURE GetTop*(VAR Handle : INTEGER) : BOOLEAN;
 (* returns the top window. FALSE means no window open *)
 BEGIN
  AES.IntIn[0] := 0; AES.IntIn[1] := TOP;
  AES.Call(68020500H); Handle := AES.IntOut[1];
  RETURN Handle > 0
 END GetTop;

PROCEDURE SetElements*(Handle : INTEGER; Elements : SET);
 (* set the elements of a window *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := ELEMENTS;
  AES.IntIn[2] := SHORT(S.VAL(LONGINT,Elements));
  AES.Call(69060100H);
 END SetElements;

PROCEDURE SetAddress*(Handle,Type : INTEGER; Address : S.PTR);
 (* Type can be NAME,INFO or NEWDESK *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := Type;
  AES.IntIn[2] := SHORT(S.VAL(LONGINT, Address) DIV 10000H);
  AES.IntIn[3] := SHORT( S.VAL(LONGINT, Address));
  AES.Call(69060100H);
 END SetAddress;

PROCEDURE SetCurr*(Handle,x,y,w,h : INTEGER);
 (* set current size of a window *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := CURR;
  AES.IntIn[2] := x; AES.IntIn[3] := y;
  AES.IntIn[4] := w; AES.IntIn[5] := h;
  AES.Call(69060100H);
 END SetCurr;

PROCEDURE SetVal*(Handle,Type,Val : INTEGER);
 (* Type can be HSLIDE,VSLIDE,HSLSIZE or VSLSIZE *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := Type;
  AES.IntIn[2] := Val; AES.Call(69060100H);
 END SetVal;

PROCEDURE SetTop*(Handle : INTEGER);
 (* Type can be HSLIDE,VSLIDE,HSLSIZE or VSLSIZE *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := TOP;
  AES.Call(69060100H);
 END SetTop;

PROCEDURE Find*(X,Y : INTEGER; VAR Handle : INTEGER) : BOOLEAN;
 (* finds window under the position X,Y. Returns FALSE if no window there *)
 BEGIN
  AES.IntIn[0] := X; AES.IntIn[1] := Y;
  AES.Call(6A020100H); Handle := AES.IntOut[0];
  RETURN Handle > 0
 END Find;

PROCEDURE Update*(Type : INTEGER);
 BEGIN
  CASE Type OF
    BEGUPD : Updat := TRUE |
    ENDUPD : Updat := FALSE |
    BEGMCTRL : Mouse := TRUE |
    ENDMCTRL : Mouse := FALSE |
  END(*CASE*);
  AES.IntIn[0] := Type; AES.Call(6B010100H);
 END Update;

PROCEDURE Calc*(Type : INTEGER; Elements : SET; InX,InY,InW,InH : INTEGER;
                VAR OutX,OutY,OutW,OutH : INTEGER);
  (* calculates the whole or work space of a window *)
 BEGIN
  AES.IntIn[0] := Type; AES.IntIn[1] := SHORT(S.VAL(LONGINT,Elements));
  AES.IntIn[2] := InX; AES.IntIn[3] := InY;
  AES.IntIn[4] := InW; AES.IntIn[5] := InH;
  AES.Call(6C060500H);
  OutX := AES.IntOut[1]; OutY := AES.IntOut[2];
  OutW := AES.IntOut[3]; OutH := AES.IntOut[4];
 END Calc;

PROCEDURE EndUpdate*;
 BEGIN
  IF Updat THEN Update(ENDUPD) END;
  IF Mouse THEN Update(ENDMCTRL) END;
 END EndUpdate;


PROCEDURE UnTop*(Handle: INTEGER);                    (* CF *)
 (* AES 4.1: untop a window *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := BOTTOM;
  AES.Call(69060100H);
 END UnTop;


PROCEDURE Iconify*(Handle, x, y, w, h : INTEGER);     (* CF *)
 (* AES 4.1: iconify a window *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := ICONIFY;
  AES.IntIn[2] := x; AES.IntIn[3] := y;
  AES.IntIn[4] := w; AES.IntIn[5] := h;
  AES.Call(69060100H);
 END Iconify;


PROCEDURE UnIconify*(Handle, x, y, w, h : INTEGER);   (* CF *)
 (* AES 4.1: iconify a window *)
 BEGIN
  AES.IntIn[0] := Handle; AES.IntIn[1] := UNICONIFY;
  AES.IntIn[2] := x; AES.IntIn[3] := y;
  AES.IntIn[4] := w; AES.IntIn[5] := h;
  AES.Call(69060100H);
 END UnIconify;


BEGIN
  Task.StoreExit( EndUpdate);
END Wind.
