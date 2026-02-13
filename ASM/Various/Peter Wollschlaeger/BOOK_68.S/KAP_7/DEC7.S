        move     #1001,-(sp)   ;Testzahl
        pea      buffer        ;Ergebnis-Puffer
        bsr      bindec        ;Routine aufrufen
 
        pea      buffer        ;String ausgeben
        move     #9,-(sp)      ;mittels PTTLIN-Funktion
        trap     #1
        addq.l   #6,sp     

        move.w   #1,-(sp)      ;mit Funktion CONIN
        trap     #1            ;auf Taste warten
        addq.l   #2,sp         ;Stack korrigieren
        clr      -(sp)         ;Mit TERM
        trap     #1            ;zum Desktop
;-----------------------------------------------------------------
bindec  move.l   4(sp),a0      ;Pufferadresse holen
        move     8(sp),d2      ;und die zu wandelnde Zahl  
        move     #10000,d1     ;erster Divisor
        move     #4,d3         ;Schleifenzaehler
        clr      d4            ;Flag Nullunterdrueckung
        lea      buffer,a0     ;Ergebnispuffer
        bra      out2          ;10000er wandeln
loop    divs     #10,d1        ;und nun die 1000er bis 1er
out1    swap     d2            ;Divisionsrest nach d2.w
out2    ext.l    d2            ;wieder auf Langwort bringen
        divs     d1,d2         ;naechste Stelle
        add.b    #'0',d2       ;wandle in ASCII

        cmpi.b   #'0',d2       ;ist es eine Null?
        bne      out3          ;wenn nicht ausgeben
        tst      d4            ;Blank erlaubt?
        bne      out3          ;nein, gebe die Null aus
        move     #' ',d2       ;setze Blank ein
        bra      out4          ;und gebe aus
out3    move     #1,d4         ;Flag keine Blanks mehr
       
out4    move.b   d2,(a0)+      ;Zeichen -> Puffer
        dbra     d3,loop  
        move.b   #0,(a0)       ;Abschlusszeichen
        
        move.l   (sp)+,a0      ;hole Return-Adresse
        addq.l   #6,sp         ;Parameter vom Stack
        jmp      (a0)          ;und return
        

       
        bss
buffer  ds.b     6             ;Puffer fuer Ergebnis
        end