DEFINITION MODULE Debug;

VAR Active   : BOOLEAN;  (* TRUE: Ausgabe der Zeilen / Daten *)
    Step     : LONGCARD; (* >0L: DEC (Step), =0L: Active:= TRUE *)
    Hex      : BOOLEAN;  (* TRUE: Ausgabe der Werte hexadezimal *)
    LineAddr : BOOLEAN;  (* TRUE: Ausgabe der abs./rel. Adr. der Zeile *)
    Continuous: BOOLEAN; (* FALSE: Stop nach jeder Zeile *)
    
END Debug.
