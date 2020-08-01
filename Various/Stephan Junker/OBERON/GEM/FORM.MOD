MODULE Form;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S := SYSTEM,AES;

CONST START* = 0; GROW* = 1; SHRINK* = 2; FINISH* = 3;

PROCEDURE Do* (Tree : LONGINT; Startob : INTEGER) : INTEGER;
 BEGIN
  AES.AddrIn[0] := Tree;
  AES.IntIn[0] := Startob;
  AES.Call(32010101H);
  RETURN AES.IntOut[0]
 END Do;

PROCEDURE Dial* (Type,Sx,Sy,Sw,Sh,Bx,By,Bw,Bh : INTEGER);
 BEGIN
  AES.IntIn[0] := Type;
  AES.IntIn[1] := Sx;
  AES.IntIn[2] := Sy;
  AES.IntIn[3] := Sw;
  AES.IntIn[4] := Sh;
  AES.IntIn[5] := Bx;
  AES.IntIn[6] := By;
  AES.IntIn[7] := Bw;
  AES.IntIn[8] := Bh;
  AES.Call(33090100H);
 END Dial;

PROCEDURE Alert* (Defbut : INTEGER; Text : ARRAY OF CHAR) : INTEGER;
 BEGIN
  AES.IntIn[0] := Defbut;
  AES.AddrIn[0] := S.ADR(Text);
  AES.Call(34010101H);
  RETURN AES.IntOut[0]
 END Alert;

PROCEDURE Center* (Tree : LONGINT; VAR X,Y,W,H : INTEGER);
 BEGIN
  AES.AddrIn[0] := Tree;
  AES.Call(36000501H);
  X := AES.IntOut[1];
  Y := AES.IntOut[2];
  W := AES.IntOut[3];
  H := AES.IntOut[4];
 END Center;

END Form.
