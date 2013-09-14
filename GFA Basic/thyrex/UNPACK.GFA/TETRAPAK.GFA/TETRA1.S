* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *
*          Depack source code for Tetrapack 1.0 (AXEL/HMD 1994)	          *
*                A0 = Start of packed data		          *
*                A1 = Address where to put depacked data	          *
*				          *
* Warning: the routine uses quite an important work area on stack so make *
*                 sure that stack size is at least 5kb.	          *
* ûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûû *

Work_Space	=	18+4084+98+74			; workspace

	movea.l	4(a7),a0
	movea.l	8(a7),a1
	jsr	Depack
	rts

Depack	movem.l	d0-a5,-(a7)

	cmp.l	#'TP10',(a0)+
	bne	Exit

	link	a6,#-Work_Space
	move.l	a7,a6

	add.l	(a0)+,a1
	move.l	(a0)+,d0
	lea	(a0,d0.l),a2
	move.b	-(a2),d7

	moveq	#18,d2
	bsr	Testbit
	bcc.s	.skip
	moveq	#8,d4
	bsr	Readtree

.skip	move.w	d2,(a6)
	lea	Table1(pc),a4

Block	move.w	#18,2(a6)
	move.w	(a6),d2
	bsr	Testbit
	bcs.s	.next
	moveq	#8,d4
	bsr	Readtree
	move.w	d3,2(a6)

.next	moveq	#3,d4
	bsr	Readtree
	move.w	d3,4(a6)
	bsr	Readtree
	move.w	d3,6(a6)
	
	clr.b	8(a6)
	
	bsr	Testbit
	bcc.s	.length
	
	not.b	8(a6)
	moveq	#0,d0
	bsr	Readbits
	move.b	d1,9(a6)
	moveq	#2,d0
	bsr	Readbits
	move.b	9(a6),d0
	add.b	d1,d1
	add.b	d0,d1
	moveq	#0,d2
	moveq	#14,d3
	add.b	d0,d3

.make	cmp.b	d0,d1
	bne.s	.norm
	move.b	d3,10(a6,d2.w)
	bra.s	.cont

.norm	move.b	d0,10(a6,d2.w)

.cont	addq.b	#2,d0
	addq.b	#1,d2
	cmp.b	#7,d2
	bne.s	.make
	move.b	d1,17(a6)
	bchg	#0,9(a6)

.length	moveq	#14,d0
	bsr	Readbits
	move.l	a1,a3
	sub.w	d1,a3

Decrunch	move.w	2(a6),d1
	bsr	Readcode
	btst	#8,d0
	bne.s	String
	move.b	d0,-(a1)

Test	cmp.l	a1,a3
	bne.s	Decrunch
	cmp.l	a0,a2
	beq	Done
	bra	Block

String	move.w	4(a6),d1
	bsr	Readcode
	move.w	d0,d2
	add.w	d2,d2
	move.w	(a4,d2.w),d2
	subq.w	#1,d0
	bpl.s	.bigger
	bsr	Testbit
	bcc.s	.offset
	subq.w	#1,d2
	bra.s	.offset

.bigger	bsr.s	Readbits
	add.w	d1,d2

.offset	move.w	6(a6),d1
	bsr.s	Readcode
	move.w	d0,d3
	add.w	d3,d3
	move.w	Table2-Table1(a4,d3.w),d3
	
	tst.b	8(a6)
	beq.s	.normal
	
	moveq	#0,d4
	subq.w	#1,d0
	bmi.s	.skip
	bsr.s	Readbits
	lsl.w	#4,d1
	move.w	d1,d4

.skip	moveq	#2,d0
	bsr.s	Readbits
	cmp.b	#7,d1
	beq.s	.special
	move.b	10(a6,d1.w),d1
	bra.s	.add

.special	bsr.s	Testbit
	bcs.s	.more
	move.b	17(a6),d1
	bra.s	.add

.more	moveq	#2,d0
	bsr.s	Readbits
	add.b	d1,d1
	add.b	9(a6),d1

.add	add.w	d4,d1
	bra.s	.string

.normal	addq.w	#3,d0
	bsr.s	Readbits

.string	add.w	d3,d1
	lea	1(a1,d1.w),a5

.copy	move.b	-(a5),-(a1)
	dbra	d2,.copy
	bra	Test

Done	lea	Work_Space(a6),a6
	unlk	a6

Exit	movem.l	(a7)+,d0-a5

	rts

Readbits	moveq	#0,d1

.read	add.b	d7,d7
	bne.s	.skip
	move.b	-(a2),d7
	addx.b	d7,d7

.skip	addx.w	d1,d1
	dbra	d0,.read

	rts
	
Testbit	add.b	d7,d7
	bne.s	ret
	move.b	-(a2),d7
	addx.b	d7,d7

ret	rts	

Readcode	move.w	(a6,d1.w),d0
	bpl.s	ret
	bsr.s	Testbit
	bcs.s	.right
	move.w	2(a6,d1.w),d1
	bra.s	Readcode

.right	move.w	4(a6,d1.w),d1
	bra.s	Readcode
	
Readtree	bsr.s	Testbit
	bcs.s	.node
	move.w	d4,d0
	bsr.s	Readbits
	move.w	d2,d3
	addq.w	#2,d2
	move.w	d1,(a6,d3.w)
	rts

.node	move.w	d2,d3
	addq.w	#6,d2
	move.w	#-1,(a6,d3.w)
	move.w	d3,-(sp)
	bsr.s	Readtree
	move.w	(sp),d0
	move.w	d3,2(a6,d0.w)
	bsr.s	Readtree
	move.w	(sp)+,d0
	move.w	d3,4(a6,d0.w)
	move.w	d0,d3
	rts

Table1	dc.w	2,2+1,2+1+2,2+1+2+4,2+1+2+4+8,2+1+2+4+8+16,2+1+2+4+8+16+32
	dc.w	2+1+2+4+8+16+32+64,2+1+2+4+8+16+32+64+128,2+1+2+4+8+16+32+64+128+256
	dc.w	2+1+2+4+8+16+32+64+128+256+512,2+1+2+4+8+16+32+64+128+256+512+1024
	dc.w	2+1+2+4+8+16+32+64+128+256+512+1024+2048

Table2	dc.w	0,16,16+32,16+32+64,16+32+64+128,16+32+64+128+256
	dc.w	16+32+64+128+256+512,16+32+64+128+256+512+1024
	dc.w	16+32+64+128+256+512+1024+2048
	dc.w	16+32+64+128+256+512+1024+2048+4096
	EVEN
End_Unpacker





