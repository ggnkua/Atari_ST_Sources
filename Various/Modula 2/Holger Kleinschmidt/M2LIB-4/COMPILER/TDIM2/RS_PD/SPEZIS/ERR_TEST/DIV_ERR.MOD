MODULE ErrTest;
(* ½ 1995 RS.   * 24.9.95 *)
(*$S-,$T-,$Q+*)

IMPORT Mini;

VAR   i: INTEGER;
BEGIN i := 0; i := 1 DIV i;
      Mini.wt (33c); Mini.wt ('H'); Mini.wT (" TheEnd of ZeroDivide ");
  END ErrTest .
