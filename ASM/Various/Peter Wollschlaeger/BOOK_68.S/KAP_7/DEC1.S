        move     #12345,d2    ;Testzahl

        ext.l    d2           ;Erweitere in Langwort
        divs     #10000,d2    ;10000er Stelle
        bsr      out          ;ausgeben

        swap     d2           ;Divisionsrest nach d2.w
        ext.l    d2           ;wieder auf Langwort bringen
        divs     #1000,d2     ;nun die 1000er Stelle
        bsr      out

        swap     d2           ;wie vor, die 100er
        ext.l    d2
        divs     #100,d2
        bsr      out

        swap     d2           ;nun die 10er           
        ext.l    d2
        divs     #10,d2
        bsr      out

        swap     d2           ;und die 1er
        bsr      out

        move.w  #1,-(sp)      ;mit Funktion CONIN
        trap    #1            ;auf Taste warten
        addq.l  #2,sp         ;Stack korrigieren
        clr     -(sp)         ;Mit TERM
        trap    #1            ;zum Desktop

out     add.b   #'0',d2       ;wandle in ASCII
        move    d2,-(sp)      ;und gebe aus
        move.w  #2,-(sp)      ;Funktion CONOUT
        trap    #1            ;aufrufen
        addq.l  #4,sp         ;Stack korrigieren
        rts
       
	
