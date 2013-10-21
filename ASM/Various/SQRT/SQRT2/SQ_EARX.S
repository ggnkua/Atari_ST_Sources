EXPORT sqrt_earx

sqrt_earx:
    movem.l     d2-d3,-(sp)
    move.l d0,d1
    moveq #1,d2
    ror.l #2,d2
    moveq #$F,d3
.loop1:
    cmp.l d2,d1
    bgt.s .endloop1
    add.l d1,d1
    lsr.l #1,d2
    dbf d3,.loop1
    moveq #0,d0
    bra.s .is_null
.endloop1:
    
    sub.l d2,d1
    move.l d2,d0
    lsr.l #1,d2
.loop2:
    lsr.l #1,d2
    add.l d2,d0
    cmp.l d0,d1
    bgt.s .endloop2
    sub.l d2,d0
    add.l d1,d1
    dbf d3,.loop2
    bra.s .end
.endloop2:
    
    sub.l d0,d1
    add.l d2,d0
    add.l d1,d1
    dbf d3,.loop2
    
.end:
    add.l d0,d0
    addi.l #$00008000,d0
.is_null: 
    clr.w d0
    swap d0
	movem.l     (sp)+,d2-d3
	rts

