
DEFINITION MODULE RandomGen;

(* Zufallszahlengenerator mit Periode 2^32 und guten Spektraleigenschaften.
   jm 15.6.87
*)

PROCEDURE Randomize (seed: LONGCARD);
  (* definiert Startpunkt des Generators.
     Randomize (0L) initialisiert den Generator mit einem Zufallswert. *)
  
PROCEDURE RandomCard (min, max: CARDINAL): CARDINAL;
  (* liefert Pseudo-Zufallszahl  min <= RandomCard () <= max *)
  
PROCEDURE Random (): LONGREAL;
  (* Liefert Pseudo-Zufallszahl  0.0 <= Random01 () < 1.0  *)

PROCEDURE Rnd (): LONGCARD;
  (* Liefert Pseudo-Zufallszahl  zw. 0 und MAX (LONGCARD)  *)

END RandomGen.
