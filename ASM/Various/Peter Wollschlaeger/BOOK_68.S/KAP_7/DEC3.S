        move    #12345,d2     ;Testzahl
     
        move    #10000,d1     ;erster Divisor
        bsr     out2          ;und ausgeben
        move    #3,d3
loop    divs    #10,d1
        bsr     out1
        dbra    d3,loop

        move.w  #1,-(sp)      ;mit Funktion CONIN
        trap    #1            ;auf Taste warten
        addq.l  #2,sp         ;Stack korrigieren
        clr     -(sp)         ;Mit TERM
        trap    #1            ;zum Desktop


out1    swap    d2            ;Divisionsrest nach d2.w
out2    ext.l   d2            ;wieder auf Langwort bringen
        divs    d1,d2
        add.b   #'0',d2       ;wandle in ASCII
        move    d2,-(sp)      ;und gebe aus
        move.w  #2,-(sp)      ;Funktion CONOUT
        trap    #1            ;aufrufen
        addq.l  #4,sp         ;Stack korrigieren
        rts
       
