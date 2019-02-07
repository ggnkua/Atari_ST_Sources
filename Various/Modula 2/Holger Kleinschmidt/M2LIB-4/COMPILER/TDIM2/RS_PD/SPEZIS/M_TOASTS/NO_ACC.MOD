MODULE NoAcc;
(* ½ 1996 by DON RODOLFO. * 22.2.96 *)
(*$S-,$T-,$Q+*)

IMPORT AEB, SX;

CONST A0 = "[1][|  I'm definitly NOT an Acc !! |";
      A1 =      "  What happens, at The END ?? ][   OK   ]";

VAR   AlStr:   SX.STR;
      ApId, b: INTEGER;

BEGIN ApId := AEB.ApplInit ();
      SX.Add (A0,A1, AlStr);
      b := AEB.FormAlert (1, AlStr);
      AEB.ApplExit;
      END NoAcc .
