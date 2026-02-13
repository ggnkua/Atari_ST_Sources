conin   macro
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp           ;Stack korrigieren
        endm

conout  macro
        move.w  \1,-(sp)        ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        endm

reads   macro
        move.b  \1,\2           ;Pufferl„nge -> Puffer
        pea     \2              ;Pufferadresse
        move.w  #10,-(sp)       ;Funktion Zeile lesen
        trap    #1              ;aufrufen
        addq.l  #6,sp           ;
        endm

writes  macro
        pea     \1
        move.w  #9,-(sp)        ;Funk. PRINTLINE
        trap    #1
        addq.l  #6,sp
        endm


outhex  macro
        movem.l d1-d3,-(sp)     ; save used regs    
        move.l  #7,d1           ; loop 8 nibbles
1$      rol.l   #4,\1           ; get nibble
        move.l  \1,d3
        andi.b  #$0f,d3         ; mask it
        addi.b  #48,d3          ; '0'..'9' anyway
        cmpi.b  #58,d3          ; >9?
        bcs     2$              ; no
        addi.b  #7,d3           ; 'A'..'F'
2$      move.l  d0,-(sp)        ; save d0
        conout  d3              ; print via GEMDOS
        move.l  (sp)+,d0        ; restore d0
        dbra    d1,1$
        movem.l (sp)+,d1-d3     ;restore regs
        endm

hexbin  macro
        movem.l a0/d1-d2,-(sp)
        clr.l   d1
        clr.l   d2
        clr.l   \2
        lea     \1,a0
        move.b  1(a0),d1
        sub.b   #1,d1   
        addq.l  #2,a0   
3$      move.b  (a0)+,d2 
        subi.b  #$30,d2  
        cmpi.b  #9,d2    
        bls     4$
        bclr    #5,d2  
        subi.b  #$7,d2 
4$      lsl.l    #4,\2  
        add.l   d2,\2  
        dbra    d1,3$ 
        movem.l (sp)+,a0/d1-d2
        endm

decbin  macro
        movem.l a0/d1-d2,-(sp)
        clr.l   d1
        clr.l   d2
        clr.l   \2
        lea     \1,a0
        move.b  1(a0),d1
        sub.b   #1,d1   
        addq.l  #2,a0   
30$     move.b  (a0)+,d2 
        subi.b  #$30,d2 
        mulu     #10,\2  
        add.l   d2,\2  
        dbra    d1,30$ 
        movem.l (sp)+,a0/d1-d2
        endm
