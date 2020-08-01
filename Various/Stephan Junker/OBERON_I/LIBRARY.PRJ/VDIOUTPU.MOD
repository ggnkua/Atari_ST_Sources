MODULE VDIOutput;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,VDI;

PROCEDURE VArc*(Handle,X,Y,Radius,BegAng,EndAng : INTEGER);
 BEGIN
  VDI.Intin[0] := BegAng; VDI.Intin[1] := EndAng;
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y; VDI.Ptsin[6] := Radius;
  VDI.Call(11,2,Handle,04000200H);
 END VArc;

PROCEDURE VBar*(Handle,x1,y1,x2,y2 : INTEGER);
 BEGIN
  VDI.Ptsin[0] := x1; VDI.Ptsin[1] := y1;
  VDI.Ptsin[2] := x2; VDI.Ptsin[3] := y2;
  VDI.Call(11,1,Handle,02000000H);
 END VBar;

PROCEDURE VCircle*(Handle,X,Y,Radius : INTEGER);
 BEGIN
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y; VDI.Ptsin[2] := 0;
  VDI.Ptsin[3] := 0; VDI.Ptsin[4] := Radius; VDI.Ptsin[5] := 0;
  VDI.Call(11,4,Handle,03000000H);
 END VCircle;

PROCEDURE VContourfill*(Handle,X,Y,BorderColor : INTEGER);
 BEGIN
  VDI.Intin[0] := BorderColor; VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Call(103,0,Handle,01000100H);
 END VContourfill;

PROCEDURE VEllarc*(Handle,X,Y,Xrad,Yrad,BegAng,EndAng : INTEGER);
 BEGIN
  VDI.Intin[0] := BegAng; VDI.Intin[1] := EndAng;
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Ptsin[2] := Xrad; VDI.Ptsin[3] := Yrad;
  VDI.Call(11,6,Handle,02000200H);
 END VEllarc;

PROCEDURE VEllipse*(Handle,X,Y,Xrad,Yrad : INTEGER);
 BEGIN
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Ptsin[2] := Xrad; VDI.Ptsin[3] := Yrad;
  VDI.Call(11,5,Handle,02000000H);
 END VEllipse;

PROCEDURE VEllpie*(Handle,X,Y,Xrad,Yrad,BegAng,EndAng : INTEGER);
 BEGIN
  VDI.Intin[0] := BegAng; VDI.Intin[1] := EndAng;
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Ptsin[2] := Xrad; VDI.Ptsin[3] := Yrad;
  VDI.Call(11,7,Handle,02000200H);
 END VEllpie;

PROCEDURE VFillarea*(Handle,Count : INTEGER; VAR PxyArray : ARRAY OF INTEGER);
 BEGIN
  VDI.ParmBlk.Ptsin := S.ADR(PxyArray);
  VDI.Call(9,0,Handle,Count * 1000000H);
  VDI.ParmBlk.Ptsin := S.ADR(VDI.Ptsin);
 END VFillarea;

PROCEDURE VGtext*(Handle,X,Y : INTEGER; String : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Ptsin[3] := 0; i := 0;
  WHILE String[i] # 0X DO VDI.Intin[i] := ORD(String[i]); INC(i) END;
  VDI.Ptsin[2] := i; VDI.Call(8,0,Handle,01000000H + i*256);
 END VGtext;

PROCEDURE VJustified*(Handle,X,Y : INTEGER; String : ARRAY OF CHAR;
                      Length,WordSpace,CharSpace : INTEGER);
  VAR i : INTEGER;
 BEGIN
  VDI.Intin[0] := WordSpace; VDI.Intin[1] := CharSpace;
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y;
  VDI.Ptsin[2] := Length; VDI.Ptsin[3] := 0; i := 0;
  WHILE String[i] # 0X DO VDI.Intin[i+2] := ORD(String[i]); INC(i) END;
  VDI.Call(11,10,Handle,02000200H + i*256);
 END VJustified;

PROCEDURE VPieslice*(Handle,X,Y,Radius,BegAng,EndAng : INTEGER);
 BEGIN
  VDI.Intin[0] := BegAng; VDI.Intin[1] := EndAng;
  VDI.Ptsin[0] := X; VDI.Ptsin[1] := Y; VDI.Ptsin[6] := Radius;
  VDI.Call(11,3,Handle,04000200H);
 END VPieslice;

PROCEDURE VPline*(Handle,Count : INTEGER; VAR PxyArray : ARRAY OF INTEGER);
 BEGIN
  VDI.ParmBlk.Ptsin := S.ADR(PxyArray);
  VDI.Call(6,0,Handle,Count * 1000000H);
  VDI.ParmBlk.Ptsin := S.ADR(VDI.Ptsin);
 END VPline;

PROCEDURE VPmarker*(Handle,Count : INTEGER; VAR PxyArray : ARRAY OF INTEGER);
 BEGIN
  VDI.ParmBlk.Ptsin := S.ADR(PxyArray);
  VDI.Call(7,0,Handle,Count * 1000000H);
  VDI.ParmBlk.Ptsin := S.ADR(VDI.Ptsin);
 END VPmarker;

PROCEDURE VRbox*(Handle,x1,y1,x2,y2 : INTEGER);
 BEGIN
  VDI.Ptsin[0] := x1; VDI.Ptsin[1] := y1;
  VDI.Ptsin[2] := x2; VDI.Ptsin[3] := y2;
  VDI.Call(11,8,Handle,02000000H);
 END VRbox;

PROCEDURE VRfbox*(Handle,x1,y1,x2,y2 : INTEGER);
 BEGIN
  VDI.Ptsin[0] := x1; VDI.Ptsin[1] := y1;
  VDI.Ptsin[2] := x2; VDI.Ptsin[3] := y2;
  VDI.Call(11,9,Handle,02000000H);
 END VRfbox;

PROCEDURE VrRecfl*(Handle,x1,y1,x2,y2 : INTEGER);
 BEGIN
  VDI.Ptsin[0] := x1; VDI.Ptsin[1] := y1;
  VDI.Ptsin[2] := x2; VDI.Ptsin[3] := y2;
  VDI.Call(114,0,Handle,02000000H);
 END VrRecfl;

END VDIOutput.
