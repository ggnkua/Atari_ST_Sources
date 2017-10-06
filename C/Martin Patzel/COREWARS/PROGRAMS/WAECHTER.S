;
;       der Waechter baut zwei Schutzfelder auf,
;       ueberprueft sie und rettet sich,
;       falls jemand die Felder beschaedigt
;
        JMP     start
;
;       Datenflaeche
;
ptr1    DAT     0               ; -> 1. Feldwache bzw. neues Programm
i       DAT     0               ; Schleifenzaehler
ptr2    DAT     0               ; -> 2. Feldwache bzw. laufendes Programm
;
        fieldlen = 5            ; Laenge der Schutzfelder
        fielddist = 450         ; Abstand der Felder zum Programm
        fieldcon = 18           ; damit werden die Felder gefuellt
;
start:
;
;       Init: Aufbau der beiden Schutzfelder
;
        MOV     #start-ptr1-fieldlen-fielddist,ptr1
        MOV     #end-ptr2+fieldlen+fielddist,ptr2
        MOV     #fieldlen,i
loop:
        MOV     #fieldcon,>ptr1
        MOV     #fieldcon,>ptr2
        DJN     loop,i
;
;       Ueberpruefung der Schutzfelder
;
check:
        MOV     #start-ptr1-fieldlen-fielddist,ptr1
        MOV     #end-ptr2+fieldlen+fielddist,ptr2
        MOV     #fieldlen,i
loop2:
        CMP     #fieldcon,>ptr1
        JMP     okay1
        JMP     panic1
okay1:
        CMP     #fieldcon,>ptr2
        JMP     okay2
        JMP     panic2
okay2:
        DJN     loop2,i
        JMP     check
;
;       Rettungsversuch
;
panic1:                                         ; vordere Feldwache beschaedigt
        MOV     #start-ptr1-fielddist*2,ptr1
        JMP     copy
panic2:                                         ; hintere Feldwache beschaedigt
        MOV     #end-ptr1+fielddist*2,ptr1
;
;       Kopierprogramm:
;
;       ptr1 -> Anfangsaddresse des neuen Programms
;
copy:
        MOV     #end-1-ptr2,ptr2
cloop:
        MOV     @ptr2,<ptr1
        DJN     cloop,ptr2
;
;       Zum neuen Programm springen
;
        JMP     @ptr1
end:
