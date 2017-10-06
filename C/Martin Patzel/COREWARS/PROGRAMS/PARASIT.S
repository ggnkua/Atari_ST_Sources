;
;       parasit.s
;       versucht innerhalb des restlichen Memorys
;       Instruktionen zu finden und diese anzuspringen
;
        step = 1                        ; Raster-Weite durchs Memory
        JMP     start
ptr     DAT     0                       ; -> aktuelle Memory-Position
first   DAT     0                       ; der Anfang einer Nicht-DAT 0-Flaeche
comp    DAT     0
;
start:
init:
        MOV     #progend-ptr,ptr
search:
        CMP     #0,@ptr                 ; DAT 0's uebergehen
        JMP     l1
        JMP     found
l1:                                     ; weitersuchen
        ADD     #step,ptr
        JMP     search
found:                                  ; etwas ungleich DAT 0 gefunden
        MOV     ptr>,first
        CMP     first,@ptr              ; gleichbleibende Daten?
        JMP     l1                      ; sind wohl keine Instruktionen!
        CMP     #0,@ptr                 ; wieder DAT 0?
        JMP     l1                      ; ist auch uninteressant!
        MOV     @ptr,comp               ; naehere Untersuchung:
        SUB     #90,comp                ; Argumente > 90 sind wohl Zeiger!
        JMG     l1,comp
        JMP     @ptr                    ; wir riskieren es...
progend:
