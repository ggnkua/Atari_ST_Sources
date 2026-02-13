 
;-----------------------------------------------------------------
bindec  movem.l  d1-d4,-(sp)   ;benutzte Register retten
        move.l   20(sp),a0     ;Pufferadresse holen
        move     24(sp),d2     ;und die zu wandelnde Zahl

        move     #10000,d1     ;erster Divisor
        move     #4,d3         ;Schleifenzaehler
        clr      d4            ;Flag Nullunterdrueckung
        lea      buffer,a0     ;Ergebnispuffer
        bra      bd3           ;10000er wandeln
bd1     divs     #10,d1        ;und nun die 1000er bis 1er
bd2     swap     d2            ;Divisionsrest nach d2.w
bd3     ext.l    d2            ;wieder auf Langwort bringen
        divs     d1,d2         ;naechste Stelle
        add.b    #'0',d2       ;wandle in ASCII

        cmpi.b   #'0',d2       ;ist es eine Null?
        bne      bd4           ;wenn nicht ausgeben
        tst      d4            ;Blank erlaubt?
        bne      bd4           ;nein, gebe die Null aus
        move     #' ',d2       ;setze Blank ein
        bra      bd5           ;und gebe aus
bd4     move     #1,d4         ;Flag keine Blanks mehr
       
bd5     move.b   d2,(a0)+      ;Zeichen -> Puffer
        dbra     d3,bd1  
        move.b   #0,(a0)       ;Abschlusszeichen
        movem.l  (sp)+,d1-d4   ;Register zurueck
        move.l   (sp)+,a0      ;hole Return-Adresse
        addq.l   #6,sp         ;Parameter vom Stack
        jmp      (a0)          ;und return
