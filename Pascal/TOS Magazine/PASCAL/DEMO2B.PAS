(* Demo fr lokale Prozeduren unter Pure Pascal *)

PROGRAM LokaleProzeduren;

PROCEDURE WerteEingabe;
VAR Eingabewert:INTEGER;

  PROCEDURE LiesEin; (* Lokale Prozedur *)
  BEGIN
  WRITE('Bitte Wert zwischen 1 und 4 eingeben: ');
  READLN(Eingabewert);
  END;

BEGIN (* von WerteEingabe *)
REPEAT
  LiesEin;
UNTIL (Eingabewert>=1) AND (Eingabewert<=4);
END;

BEGIN
WerteEingabe;
END.