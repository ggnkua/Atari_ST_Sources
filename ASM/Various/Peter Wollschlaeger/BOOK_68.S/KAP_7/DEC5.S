        move     #1001,d2      ;Testzahl
     
        move     #10000,d1     ;erster Divisor
        move     #4,d3         ;Schleifenzaehler
        clr      d4            ;Flag Nullunterdrueckung
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
       
out4    move     d2,-(sp)
        move.w   #2,-(sp)      ;Funktion CONOUT
        trap     #1            ;aufrufen
        addq.l   #4,sp         ;Stack korrigieren
        dbra     d3,loop       

        move.w   #1,-(sp)      ;mit Funktion CONIN
        trap     #1            ;auf Taste warten
        addq.l   #2,sp         ;Stack korrigieren
        clr      -(sp)         ;Mit TERM
        trap     #1            ;zum Desktop
       
