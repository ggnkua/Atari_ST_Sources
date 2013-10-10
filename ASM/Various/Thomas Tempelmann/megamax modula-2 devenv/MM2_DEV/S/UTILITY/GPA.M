MODULE GPA;

(*
 * Dieses Hilfsprogramm erlaubt es, Adressen von in der Shell resi-
 * denten Prozeduren zu ermitteln. Dies ist v.A. hilfreich, wenn man
 * mit TEMPLEMON Breakpoints auf einzelne Prozeduren setzen m”chte.
 * Dazu wird das Modul, das man untersuchen m”chte, in der Shell
 * resident geladen. Dann kann dieses Programm gestartet werden und
 * der Modul- und Prozedurname, getrennt durch einen Punkt, eingegeben
 * werden, worauf die Adresse der Prozedur ausgegeben wird.
 *
 * N„heres im Def-Text von 'ModCtrl' zu der Funktion 'GetProcAddr'.
 *)

FROM ModCtrl IMPORT GetProcAddr;

FROM SYSTEM IMPORT ADDRESS;

IMPORT InOut;

VAR s: ARRAY [0..50] OF CHAR; loc: ADDRESS;

BEGIN
  LOOP
    InOut.ReadString (s);
    IF s[0]=0C THEN EXIT END;
    GetProcAddr (s, loc);
    InOut.WriteLHex (loc, 7);
    InOut.WriteLn;
  END
END GPA.
