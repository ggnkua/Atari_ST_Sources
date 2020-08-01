MODULE Graf;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT AES,Appl,Error,Task;

CONST (* mouse types *)
  ARROW* = 0; CURSOR* = 1; BEE* = 2; POINTHAND* = 3; FLATHAND* = 4;
  LIGHTCROSS* = 5; FATCROSS* = 6; FRAMEDCROSS* = 7;

VAR MouseOff : INTEGER;

PROCEDURE Rubberbox* (X,Y,MinW,MinH : INTEGER; VAR EndW,EndH : INTEGER);
 BEGIN
  AES.IntIn[0] := X; AES.IntIn[1] := Y;
  AES.IntIn[2] := MinW; AES.IntIn[3] := MinH;
  AES.Call(46040300H);
  EndW := AES.IntOut[1]; EndH := AES.IntOut[2];
 END Rubberbox;

PROCEDURE Dragbox* (W,H,Sx,Sy,Bx,By,Bw,Bh : INTEGER; VAR EndX,EndY : INTEGER);
 BEGIN
  AES.IntIn[0] := W; AES.IntIn[1] := H;
  AES.IntIn[2] := Sx; AES.IntIn[3] := Sy;
  AES.IntIn[4] := Bx; AES.IntIn[5] := By;
  AES.IntIn[6] := Bw; AES.IntIn[7] := Bh;
  AES.Call(47080300H);
  EndX := AES.IntOut[1]; EndY := AES.IntOut[2];
 END Dragbox;

PROCEDURE Movebox* (W,H,Sx,Sy,Dx,Dy : INTEGER);
 BEGIN
  AES.IntIn[0] := W; AES.IntIn[1] := H;
  AES.IntIn[2] := Sx; AES.IntIn[3] := Sy;
  AES.IntIn[4] := Dx; AES.IntIn[5] := Dy;
  AES.Call(48060100H);
 END Movebox;

PROCEDURE Growbox* (Sx,Sy,Sw,Sh,Ex,Ey,Ew,Eh : INTEGER);
 BEGIN
  AES.IntIn[0] := Sx; AES.IntIn[1] := Sy;
  AES.IntIn[2] := Sw; AES.IntIn[3] := Sh;
  AES.IntIn[4] := Ex; AES.IntIn[5] := Ey;
  AES.IntIn[6] := Ew; AES.IntIn[7] := Eh;
  AES.Call(49080100H);
 END Growbox;

PROCEDURE Shrinkbox* (Sx,Sy,Sw,Sh,Ex,Ey,Ew,Eh : INTEGER);
 BEGIN
  AES.IntIn[0] := Ex; AES.IntIn[1] := Ey;
  AES.IntIn[2] := Ew; AES.IntIn[3] := Eh;
  AES.IntIn[4] := Sx; AES.IntIn[5] := Sy;
  AES.IntIn[6] := Sw; AES.IntIn[7] := Sh;
  AES.Call(4A080100H);
 END Shrinkbox;

PROCEDURE Handle* (VAR Wchar,Hchar,Wbox,Hbox : INTEGER) : INTEGER;
 (* always returns 1 *)
 BEGIN
  AES.Call(4D000500H);
  Wchar := AES.IntOut[1]; Hchar := AES.IntOut[2];
  Wbox := AES.IntOut[3]; Hbox := AES.IntOut[4];
  RETURN AES.IntOut[0]
 END Handle;

PROCEDURE ShowMouse* ;
 BEGIN
  IF MouseOff = 0 THEN Error.NumOut(-100)
  ELSE DEC(MouseOff);
    IF MouseOff = 0 THEN
      AES.IntIn[0] := 257; AES.Call(4E010101H);
    END(*IF*);
  END(*IF*);
 END ShowMouse;

PROCEDURE HideMouse* ;
 BEGIN
  IF MouseOff = 0 THEN
    AES.IntIn[0] := 256; AES.Call(4E010101H);
  END(*IF*);
  INC(MouseOff);
 END HideMouse;

PROCEDURE ChangeMouse* (Mtype : INTEGER);
 BEGIN
  AES.IntIn[0] := Mtype; AES.Call(4E010101H);
 END ChangeMouse;

PROCEDURE SetMouse* (Faddr : LONGINT);
 BEGIN
  AES.IntIn[0] := 255; AES.AddrIn[0] := Faddr;
  AES.Call(4E010101H);
 END SetMouse;

PROCEDURE* NormalMouse;
 BEGIN
  ChangeMouse(ARROW);
  IF MouseOff # 0 THEN MouseOff := 1; ShowMouse END;
 END NormalMouse;

BEGIN
  Task.StoreExit(NormalMouse);
END Graf.
