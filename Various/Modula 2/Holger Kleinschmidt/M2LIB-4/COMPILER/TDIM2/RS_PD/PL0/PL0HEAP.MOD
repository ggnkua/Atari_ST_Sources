IMPLEMENTATION MODULE PL0Heap;
(* ½ 1995 by ROLF SCHRADER.                                      * 18.4.95 *)
(*$S-,$T-,$Q+*)

FROM   SYSTEM   IMPORT ADR, ADDRESS, LONGWORD;
IMPORT Storage;

TYPE   AlPtr = POINTER TO  RECORD a: ADDRESS; n: LONGINT END;
VAR    pLast:  AlPtr;

PROCEDURE ALLOCATE (VAR a: ADDRESS; n: LONGWORD);
   VAR N:  LONGINT;  p: AlPtr;
 BEGIN N:= LONGINT (n);
   IF (N < 0) THEN a := NIL; RETURN ELSE INC (N, 8) END;
   Storage.ALLOCATE (a, N);
   IF (LONGINT (a) > 0) THEN
       p := a; p^.n := N; p^.a := pLast; pLast := a;
       INC (a, 8); END; END ALLOCATE;

PROCEDURE ResetHeap (a: ADDRESS);
   VAR b: AlPtr;
 BEGIN DEC (a, 8);
   REPEAT      IF (pLast  = pLast^.a) THEN RETURN END;
       b := pLast; pLast := pLast^.a; Storage.DEALLOCATE (b, b^.n);
   UNTIL (b = a); END ResetHeap;

BEGIN pLast := ADR(pLast) END PL0Heap .
