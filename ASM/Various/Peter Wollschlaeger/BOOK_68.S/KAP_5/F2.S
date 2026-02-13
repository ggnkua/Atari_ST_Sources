* Programm f1

start
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp 
        swap    d0              ;Scan-Code nach d0.w
       
        cmpi    #$3B,d0         ;Taste F1?
        beq     f1              ;Wenn ja
        cmpi    #$3C,d0         ;Taste F2?
        beq     f2              ;wenn ja
        cmpi    #$3D,d0         ;Taste F3?
        beq     fini            ;wenn ja
        bra     start           ;andere sind nicht erlaubt
      

       
f1      move    #'1',-(sp)      ;wollen wir ausgeben
        move    #2,-(sp)        ;Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        bra     start

f2      move    #'2',-(sp)      ;wollen wir ausgeben
        move    #2,-(sp)        ;Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        bra     start

fini    clr     -(sp)
        trap    #1
        
	end
