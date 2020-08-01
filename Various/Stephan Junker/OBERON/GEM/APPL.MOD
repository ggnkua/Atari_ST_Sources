MODULE Appl;

(* Appl.Init and Appl.Exit is done automatically if Appl is imported.
   All AES modules import Appl *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,AES,Task;

PROCEDURE Init();
 BEGIN
  IF Task.Current = 0 THEN AES.Call(0A000100H) END;
 END Init;

PROCEDURE Read* (ApId,Length : INTEGER; Buffer : LONGINT);
 BEGIN
  AES.IntIn[0] := ApId; AES.IntIn[1] := Length;
  AES.AddrIn[0] := Buffer; AES.Call(0B020101H);
 END Read;

PROCEDURE Write* (ApId,Length : INTEGER; Buffer : LONGINT);
 BEGIN
  AES.IntIn[0] := ApId; AES.IntIn[1] := Length;
  AES.AddrIn[0] := Buffer; AES.Call(0C020101H);
 END Write;

PROCEDURE Tplay* (Memory : LONGINT; Number,Scale : INTEGER);
 BEGIN
  AES.IntIn[0] := Number; AES.IntIn[1] := Scale;
  AES.AddrIn[0] := Memory; AES.Call(0E020101H);
 END Tplay;

PROCEDURE Trecord* (Memory : LONGINT; Number : INTEGER) : INTEGER;
 BEGIN
  AES.IntIn[0] := Number; AES.AddrIn[0] := Memory;
  AES.Call(0F010101H); RETURN AES.IntOut[0]
 END Trecord;

PROCEDURE Find* (Name : ARRAY OF CHAR) : INTEGER;
 BEGIN
  AES.AddrIn[0] := S.ADR(Name); AES.Call(0D000101H);
  RETURN AES.IntOut[0]
 END Find;

PROCEDURE* Exit;
 BEGIN
  IF Task.Current = 0 THEN AES.Call(13000100H) END;
 END Exit;

BEGIN Init; Task.StoreExit(Exit);
END Appl.
