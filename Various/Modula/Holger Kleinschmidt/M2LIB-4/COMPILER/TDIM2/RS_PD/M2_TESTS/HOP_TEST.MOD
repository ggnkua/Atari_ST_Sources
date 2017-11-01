MODULE HopTest;
(* ½ 1996 by ROLF SCHRADER. * 1.3.96 *)

IMPORT Mini;

MODULE HOP0; EXPORT QUALIFIED i,K; VAR i,K: INTEGER; END HOP0;
MODULE Hop1; EXPORT QUALIFIED i,K; VAR i,K: INTEGER; END Hop1;

VAR i,K: INTEGER;

PROCEDURE Haja;
 BEGIN
   HOP0.i := 1;
   Hop1.i := 1;
   Mini.Pause;
   END Haja;

(*$H+*)

VAR j: INTEGER;

PROCEDURE Hajo;
 BEGIN
   Mini.wT ("sodele");
   j := 1;
   J := 1;
   HOP0.K := 1;
   Hop0.k := 1;
   i := 0;
   I := 0;
   K := 1;
   Hop0.i := 0;
   HOP0.i := 0;
   Hop1.i := 0;
   MINI.Pause;
   END Hajo;

BEGIN Hajo END HopTest .
