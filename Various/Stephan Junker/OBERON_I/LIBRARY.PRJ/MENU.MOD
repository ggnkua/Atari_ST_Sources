MODULE Menu;

(* if the program is started as a program, Menu.Register won't work. If
   started as accessory, only Menu.Register will work *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,AES,Appl,Sys;

VAR Enable : BOOLEAN;

PROCEDURE Show*(Tree : LONGINT);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := 1; AES.AddrIn[0] := Tree; AES.Call(1E010101H);
  END(*IF*);
 END Show;

PROCEDURE Hide*(Tree : LONGINT);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := 0; AES.AddrIn[0] := Tree; AES.Call(1E010101H);
  END(*IF*);
 END Hide;

PROCEDURE Check*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 1;
    AES.AddrIn[0] := Tree; AES.Call(1F020101H);
  END(*IF*);
 END Check;

PROCEDURE Uncheck*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 0;
    AES.AddrIn[0] := Tree; AES.Call(1F020101H);
  END(*IF*);
 END Uncheck;

PROCEDURE Ienable*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 1;
    AES.AddrIn[0] := Tree; AES.Call(20020101H);
  END(*IF*);
 END Ienable;

PROCEDURE Idisable*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 0;
    AES.AddrIn[0] := Tree; AES.Call(20020101H);
  END(*IF*);
 END Idisable;

PROCEDURE Tnormal*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 1;
    AES.AddrIn[0] := Tree; AES.Call(21020101H);
  END(*IF*);
 END Tnormal;

PROCEDURE Tinverted*(Tree : LONGINT; Object : INTEGER);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.IntIn[1] := 0;
    AES.AddrIn[0] := Tree; AES.Call(21020101H);
  END(*IF*);
 END Tinverted;

PROCEDURE Text*(Tree : LONGINT; Object : INTEGER; Entry : LONGINT);
 BEGIN
  IF Enable THEN
    AES.IntIn[0] := Object; AES.AddrIn[0] := Tree;
    AES.AddrIn[1] := Entry; AES.Call(22010102H);
  END(*IF*);
 END Text;

PROCEDURE Register*(Entry : LONGINT) : INTEGER;
 BEGIN
  IF NOT Enable THEN
    AES.IntIn[0] := AES.Global.ApId; AES.AddrIn[0] := Entry;
    AES.Call(23010101H); RETURN AES.IntOut[0]
  END(*IF*);
  RETURN -1
 END Register;

BEGIN
  Enable := Sys.Basepage.Parent # 0;
END Menu.
