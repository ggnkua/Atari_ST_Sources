MODULE Main;

(* Achtung:
     Removal wird nicht korrekt durchgefhrt!
     Erst wird A, dann C, dann B removed. Richtig w„re A, B, C (oder B, A, C)!
     Fehlermeldung von Michael Seyfried
     
     >> 5.11.89: Fehler im Loader behoben
*)

IMPORT A;

IMPORT B;

BEGIN
  A.a;
  B.b;
END Main.
