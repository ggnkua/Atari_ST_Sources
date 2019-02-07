MODULE Trap0;
(* Ω 1996 by ROLF SCHRADER.      * 6.3.96 *)
(*$S-,$T-,$Q+*)
(*
   Macht nichts weiter, als durch den (normalerweise unbenutzten und darum
   mit RTE belegten) Trap Nr. 0 zu springen. Dabei sorgt dann allerdings der
   normale CEH dafÅr, daû der Sprung seine Spur in der SaveArea auch sogar
   post mortem hinterlÑût - und darum mit LastSigh, Err_Blur o.Ñ. bequem
   abgefragt werden kann.
*)
FROM SYSTEM IMPORT CODE;

CONST TRAP = 4E40H;

BEGIN CODE (TRAP+0) END Trap0.
