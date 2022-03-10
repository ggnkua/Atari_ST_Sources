*-----------------------------------------------------------------------*
        .globl  laext,linea0,lafont,linea9,lineaa
linea0:
        movem.l  a1-a2,-(sp)
        .dc.w   $a000
        bra	return
linea9:
        movem.l  a1-a2,-(sp)
        .dc.w   $a009
        bra	return
lineaa:
        movem.l  a1-a2,-(sp)
        .dc.w   $a00a
        bra	return
laext:
        movem.l  a1-a2,-(sp)
        .dc.w   $a000
        sub.l   #46,a0
        bra	return
lafont:
        movem.l  a1-a2,-(sp)
        .dc.w   $a000
        move.l	a1,a0
return:	movem.l  (sp)+,a1-a2
        rts
        .end        
