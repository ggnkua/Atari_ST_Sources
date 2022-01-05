	output	d:\centinel\40\main.inc\test.o


	



DEBUG	MACRO
	bra	.SUITE\@
	dc.l	'CNTL'
.MES\@	dc.b	\1
	even
	dc.w	*-.MES\@
	dc.l	'CNTL'
.SUITE\@
	illegal
	ENDM


	
	
	
	mc68881

prog_a_tester::

etyzeturgsjdfg


.jui

	move.l	#$300000,d0
	move.l	d0,a7	


	fsub	fp0,fp0
	fmove	fp0,fp0


	move.w	d0,sr
	nop
	move.w	#$2700,d0

;
	fmove.x	#1,fp0
	fmove.x	#1.1,fp1

	fdbf	d0,*
	nop
	illegal
	fdbf	d0,.jui
	fbeq	.jui


	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp



	move.l	#$12345678,-(sp)
	move.l	#$12345678,-(sp)
	move.l	#$12345678,-(sp)

.kl
	DEBUG	<'toto est le plus bo'>
	bra	.kl


	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	bra	.jui



	
	illegal

	
	dc.w	%0100111001111010		; movec	buscr,d0
	dc.w	$0008
	
	dc.w	%1111100000000000		; lpstop #$1234
	dc.w	%0000000111000000
	dc.w	$1234

	dc.w	%1111010111001001		; plpar (a1)



	move.l	([$4f2.w],$28.w),a0
	


	dbra	d1,*
	
	rol.l	d3,d1

	moveq	#0,d0
.tyu

	bsr	.toto
	
	
	
	add.l	#1,d0
	add.l	#1,d0
	add.l	#1,d0
	
	
	bra	.tyu
	
	fmove.s	#0.0000125,fp0

	fsub	fp0,fp0

	fmove	fp0,fp0


	fmove.x	#1,fp0
	fmove.x	#1.1,fp1
	fmove.x	#1.2,fp2
	fmove.x	#1.3,fp3
	fmove.x	#1.4,fp4
	fmove.x	#1.5,fp5
	fmove.x	#2,fp6
	fmove.x	#150,fp7



	fmove.x	#1,fp4
	fmove.x	#1,fp0
	fmove.x	#0,fp4
	fmove.x	#0,fp0
	fmove	d0,fp2
	;fneg	fp4
	fmul	fp7,fp2
	
	
	fmove	fpiar,.l
	
	fbne	.l
	

	moveq	#0,d0
.l
	nop
	addq.l	#1,d0
	addq.l	#1,d1
	bra.s	.l
	
	move.l	#.poi,d1
	move.l	#$c8,d0
	trap	#2	


	illegal
	
	
.toto
	rts
	


.poi	dc.l	.tab


.tab
	dc.w	10
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	1
	dc.w	1
	dc.w	0
	dc.w	0
	dc.w	0
.null
	rts