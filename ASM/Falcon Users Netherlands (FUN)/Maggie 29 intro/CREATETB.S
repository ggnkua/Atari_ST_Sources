	COMMENT	HEAD=%111

	bra	START

	INCLUDE	INCLOAD.I
	TEXT

START:

	lea	atan2_tbl,a0
	bsr	CALC_ATAN2TABLE

	lea	atan2name_txt,a0
	lea	atan2_tbl,a1
	move.l	#1<<17,d0
	bsr	save

	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* INPUT: a0: tableaddress
CALC_CIRCLETABLE:
	moveq	#-95,d7
	fmove.s	#0.5,fp2

.yloop:	moveq	#-95,d6	

.xloop:	fmove.w	d6,fp0
	fadd	fp2,fp0
	fmove.w	d7,fp1
	fadd	fp2,fp1
	fdiv	fp1,fp0
	fatan	fp0
	fmul.s	#20860.07567,fp0
	fmove.l	fp0,d0
	asr.l	#3,d0
	move.w	d0,(a0)+
	addq.w	#1,d6
	cmpi.w	#95,d6
	bne.s	.xloop

	addq.w	#1,d7
	cmpi.w	#95,d7
	bne.s	.yloop
	rts

* INPUT: a0: tableaddress
CALC_LENGTHTABLE:
	move.w	#1200,d2			* Radius of tunnel.

	moveq	#-128,d7

.yloop:	moveq	#-128,d6
	
.xloop:	move.w	d6,d0
	move.w	d7,d1
	muls.w	d6,d0
	muls.w	d7,d1
	add.w	d0,d1
	subq.w	#1,d1
	fmove.w	d1,fp0
	fsqrt	fp0
	fmove.w	d2,fp1
	fdiv	fp0,fp1
	fmove.w	fp1,d0
	move.b	d0,(a0)+
	addq.w	#1,d6
	cmpi.w	#128,d6
	bne.s	.xloop

	addq.w	#1,d7
	cmpi.w	#128,d7
	bne.s	.yloop

	rts

* Very fast and accurate squareroot algorithm.
* Quite lengthy, though: 64 bytes.
* INPUT: d1.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.l: squareroot of value (16.16 fixed point)
CALC_ATARISQRT:
	moveq	#1,d2
	ror.l	#2,d2
	moveq	#$F,d3
.loop1:	cmp.l	d2,d1
	bgt.s	.endloop1
	add.l	d1,d1
	lsr.l	#1,d2
	dbf	d3,.loop1
	bra.s	.end
.endloop1:

	sub.l	d2,d1
	move.l	d2,d0
	lsr.l	#1,d2
.loop2:	lsr.l	#1,d2
	add.l	d2,d0
	cmp.l	d0,d1
	bgt.s	.endloop2
	sub.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2
	bra.s	.end
.endloop2:

	sub.l	d0,d1
	add.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2

.end:	add.l	d0,d0
	addi.l	#$00008000,d0
	rts

* INPUT: a0: tableaddress
CALC_CPULENGTHTABLE:
	move.l	#1200<<16,d5			* Radius of tunnel.

	moveq	#-128,d7

.yloop:	moveq	#-128,d6
	move.w	d7,d0
	muls.w	d7,d0
	movea.l	d0,a6
	
.xloop:	move.w	d6,d1
	muls.w	d6,d1
	add.l	a6,d1
	subq.l	#1,d1
	bsr	CALC_ATARISQRT
	move.l	d5,d2
	divs.l	d0,d2
	move.b	d2,(a0)+
	addq.w	#1,d6
	cmpi.w	#128,d6
	bne.s	.xloop

	addq.w	#1,d7
	cmpi.w	#128,d7
	bne.s	.yloop

	rts

******** DATA AND INCLUDES ********

	DATA

atan2name_txt:
	DC.B	"ATAN2TBL.DAT",0
lengthname_txt:
	DC.B	"LENGTTBL.DAT",0

	EVEN

******** RESERVES ********

	BSS

length_tbl:
	DS.B	1<<16
atan2_tbl:
	DS.W	1<<16