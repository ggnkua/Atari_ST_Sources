MODULE Sieve;

(*
 * Dies ist ein aus der C-Welt Åbliches Geschwindigkeits-Demo-Programm.
 *
 * Achtung: Vor dem Start muû der Stack (fÅr Loadtime-Linking, in den
 * Umgebungsinformationen) auf mind. 20000 gesetzt werden! Wird das
 * vergessen, stÅrzt das System ab, weil die Stack-Platz-PrÅfung
 * hier extra abgeschaltet ist.
 *)

(*$S-,R-*)

IMPORT TOSIO; (*$E MOS *)

FROM InOut  IMPORT  Read, Write, WriteString, WriteCard, WriteLn;

CONST Size = 8190;
      Iter = 100;  (* Anzahl der DurchlÑufe *)

PROCEDURE oneSieve;

  VAR         flag: ARRAY [0..Size] OF BOOLEAN;
              j,
    (*$Reg*)  k,
    (*$Reg*)  count,
    (*$Reg*)  prime: CARDINAL;
  
  BEGIN
    count := 0;
    FOR j := 0 TO Size DO
      flag[j] := TRUE;
    END;
    FOR j := 0 TO Size DO
      IF flag[j] THEN
        prime := j+j+3;
        k := j+prime;
        WHILE k <= Size DO
          flag[k] := FALSE;
          INC (k, prime);
        END;
        INC (count);
      END;
    END;
  END oneSieve;

VAR ch: CHAR;
    i: CARDINAL;

BEGIN
  WriteString ("Taste zum Starten...");
  Read (ch);
  WriteLn;
  FOR i:= 1 TO Iter DO
    oneSieve
  END;
  Write (7C);
  WriteString ("Fertig.")
END Sieve.
