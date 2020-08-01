MODULE Supervisor;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |8.3.93   |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, GEMDOS, Stack;

VAR IsOn : BOOLEAN;
    Prev : Stack.elem;
    OldStack : LONGINT;

PROCEDURE On*;
  (* switches into supervisor mode if not already done *)
 BEGIN
  Stack.Push(Prev,S.VAL(SHORTINT,IsOn));
  IF NOT IsOn THEN OldStack := GEMDOS.Super(0); IsOn := TRUE END;
 END On;

PROCEDURE Off*;
  (* returns to the mode that was active before the last call of On *)
 BEGIN
  IsOn := S.VAL(BOOLEAN,SHORT(Stack.Pop(Prev)));
  IF NOT IsOn THEN OldStack := GEMDOS.Super(OldStack) END;
 END Off;

END Supervisor.