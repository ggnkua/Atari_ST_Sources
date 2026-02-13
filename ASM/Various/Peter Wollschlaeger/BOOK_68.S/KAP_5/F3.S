* Programm f3
start
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp 
        swap    d0              ;Scan-Code nach d0.w

        subi    #$3B,d0         ;in 0..10 wandeln
        asl     #2,d0           ;mal 4
        lea     table,a0        ;Zeiger auf Tabelle
        move.l  0(a0,d0),a0
        jsr     (a0)
        bra     start
    
f1      move    #'1',-(sp)      ;wollen wir ausgeben
        move    #2,-(sp)        ;Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        rts

f2      move    #'2',-(sp)      ;wollen wir ausgeben
        move    #2,-(sp)        ;Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        rts

fini    move.l   (sp)+,d0        ;kill return address
        clr      -(sp)
        trap     #1

table                            ;Adress-Tabelle
        dc.l    f1
        dc.l    f2
        dc.l    fini


