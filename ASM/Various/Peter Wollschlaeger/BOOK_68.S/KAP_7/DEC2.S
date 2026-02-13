        move    #12345,d2     ;Testzahl

        move    #10000,d1     ;10000er wandeln
        bsr     out2          ;und ausgeben

        move    #1000,d1      ;nun die 1000er Stelle
        bsr     out1
 
        move    #100,d1       ;die 100er
        bsr     out1
  
        move    #10,d1        ;die 10er  
        bsr     out1

        move    #1,d1         ;die 1er
        bsr     out1

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
       
