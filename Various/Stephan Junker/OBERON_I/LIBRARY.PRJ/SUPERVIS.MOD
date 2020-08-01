MODULE Supervisor;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |8.3.93   |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, GEMDOS;

VAR OnCount : INTEGER; (* <0 = off *)
    OldStack : LONGINT;

PROCEDURE On*;
  (* switches into supervisor mode if not already done *)
 BEGIN
  INC(OnCount);
  IF OnCount = 1 THEN OldStack := GEMDOS.Super(0) END;
 END On;

PROCEDURE Off*;
  (* returns to the mode that was active before the last call of On *)
 BEGIN
  DEC(OnCount);
  IF OnCount = 0 THEN OldStack := GEMDOS.Super(OldStack) END;
 END Off;

END Supervisor.