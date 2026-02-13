* Programm f1

start
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp 
        swap    d0              ;Scan-Code nach d0.w
        cmpi    #$44,d0         ;Taste F10
        beq     fini            ;wenn ja, fertig

        subi    #$3B,d0         ;wandle in 0..9
        add     #49,d0          ;und nun in '1'  bis 
        
        move    d0,-(sp)        ;wollen wir ausgeben
        move    #2,-(sp)        ;Funktion CONOUT
        trap    #1
        addq.l  #4,sp

        bra     start

fini    clr     -(sp)
        trap    #1
        
	end
