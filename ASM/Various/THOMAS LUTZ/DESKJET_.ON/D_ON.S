;Es muss Bit 5 im Soundregister gesetzt werden

MOVE.W #$20,-(a7)     ; also 32 auf den Stack
MOVE.W #$001e,-(a7)   ; 30 (fÅr die Funktionsnummer) auf den Stack
TRAP #14              ; XBIOS aufrufen
ADDQ.L #4,a7          ; Stack aufrÑumen
CLR.W -(a7)           ; Stackpointer lîschen
TRAP #1               ; und PRG beenden