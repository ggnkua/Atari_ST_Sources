***************************************************************************
***									***
***									***
***				LATTICE.S				***
***									***
***									***
***************************************************************************
*
*	08/6/93		C.Gee and Hans Martin Krober
*
		.text

	.globl	__CXM33		; lmul
	.globl	__CXM22		; lmul
	.globl	__CXD33		; ldiv
	.globl	__CXD22		; ldiv


*
*	Lattice style lmul
*

__CXM33:
__CXM22:
	movem.l   d2-d3,-(a7)
	move.l    d0,d2
	move.l    d1,d3
	swap      d2
	ext.l     d2
	beq.b     Cxm1
	mulu.w    d1,d2
Cxm1:	swap      d3
	ext.l     d3
	beq.w     Cxm2
	mulu.w    d0,d3
	add.w     d3,d2
Cxm2:	mulu.w    d1,d0
	swap      d2
	clr.w     d2
	add.l     d2,d0
	movem.l   (a7)+,d2-d3
	rts

*
*	Lattice style ldiv
*

__CXD22:
__CXD33:
	tst.l     d0
	bpl.b     L001a
	neg.l     d0
	tst.l     d1
	bpl.b     L0012
	neg.l     d1
	bsr.b     L0026
	neg.l     d1
	rts
L0012:	bsr.b     L0026
	neg.l     d0
	neg.l     d1
	rts
L001a:	tst.l     d1
	bpl.b     L0026
	neg.l     d1
	bsr.b     L0026
	neg.l     d0
	rts
L0026:	move.l    d2,-(a7)
	swap      d1
	move.w    d1,d2
	bne.b     L004c
	swap      d0
	swap      d1
	swap      d2
	move.w    d0,d2
	beq.b     L003c
	divu.w    d1,d2
	move.w    d2,d0
L003c:	swap      d0
	move.w    d0,d2
	divu.w    d1,d2
	move.w    d2,d0
	swap      d2
	move.w    d2,d1
	move.l    (a7)+,d2
	rts
L004c:	move.l    d3,-(a7)
	moveq     #$10,d3
	cmpi.w    #$0080,d1
	bcc.b     L005a
	rol.l     #8,d1
	subq.w    #8,d3
L005a:	cmpi.w    #$0800,d1
	bcc.b     L0064
	rol.l     #4,d1
	subq.w    #4,d3
L0064:	cmpi.w    #$2000,d1
	bcc.b     L006e
	rol.l     #2,d1
	subq.w    #2,d3
L006e:	tst.w     d1
	bmi.b     L0076
	rol.l     #1,d1
	subq.w    #1,d3
L0076:	move.w    d0,d2
	lsr.l     d3,d0
	swap      d2
	clr.w     d2
	lsr.l     d3,d2
	swap      d3
	divu.w    d1,d0
	move.w    d0,d3
	move.w    d2,d0
	move.w    d3,d2
	swap      d1
	mulu.w    d1,d2
	sub.l     d2,d0
	bcc.b     L0096
	subq.w    #1,d3
	add.l     d1,d0
L0096:	moveq     #$00,d1
	move.w    d3,d1
	swap      d3
	rol.l     d3,d0
	swap      d0
	exg       d0,d1
	move.l    (a7)+,d3
	move.l    (a7)+,d2
	rts

	.end
