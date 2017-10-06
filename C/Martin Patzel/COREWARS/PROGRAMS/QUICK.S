;
;       quick.s
;       ist fuer schnelle Verteidigung gegen Angreifer, die in
;       einer Richtung angreifen;
;       wird vorwaerts angegriffen, so sollte progdist negativ sein,
;       andernfalls positiv
;
        progdist = -313
;
;       schnelles Startprogramm,
;       das 2 weitere Kopien (Richtung progdist) anlegt
;
        proglen = progend-prog1
copy:
        MOV     #prog1-ptr1,ptr1
        MOV     #prog1+progdist-ptr2,ptr2
        MOV     #prog1+2*progdist-ptr3,ptr3
        MOV     #proglen,i
cloop:
        MOV     @ptr1,ptr2>
        MOV     ptr1>,ptr3>
        DJN     cloop,i
;
;       hier beginnt das eigentliche Programm
;       (und auch nur dieser Teil wird kopiert)
;       ptr1 --> unser laufendes Programm
;       ptr2 --> 1. Kopie (wird nie angesprungen - dient nur Schutzzwecken)
;       ptr3 --> 2. Kopie (wird angesprungen, falls 1. Kopie beschaedigt)
;
prog1:
        MOV     #prog1-ptr1,ptr1
        MOV     #prog1+progdist-ptr2,ptr2
        MOV     #prog1+2*progdist-ptr3,ptr3
        MOV     #proglen,i
check:
        CMP     @ptr1,@ptr2             ; solange Schutzkopie nicht
        JMP     ok                      ; beschaedigt ist: weitermachen
        CMP     @ptr1,@ptr3             ; die 3. Kopie springen wir erst
        JMP     prog1+2*progdist        ; an, wenn sie fertig ist!
ok:
        MOV     @ptr1,ptr2>             ; Kopien erstellen/reparieren
        MOV     ptr1>,ptr3>
        DJN     check,i
        JMP     prog1
progend:

ptr1    DAT     0                       ; --> laufendes Programm
ptr2    DAT     0                       ; --> 1. Kopie
ptr3    DAT     0                       ; --> 2. Kopie
i       DAT     0                       ; Schleifenzaehler

