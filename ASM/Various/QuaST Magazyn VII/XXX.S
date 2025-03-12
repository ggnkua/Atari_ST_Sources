***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  XXX - nie wiedzialem jak to nazwac (???!)                 *
* autor      :  Van Eijk                                                  *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************
 
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#0,-(sp)
	pea	$78000
	pea	$78000
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#0,ZUJ
	move.w	#0,ZH
	bclr.b	#5,$fffa09
	move.l	#RYS,a0
	move.l	$70,old70
	move.l	#vbl,$70

P:	bra	P

*-------------------------------------------------------------------------*

END	
	move.l	old70,$70
	bset.b	#5,$fffa09
	move.w	#$fff,$fff8240
	clr.l	-(sp)
	trap	#1

*-------------------------------------------------------------------------*

VBL:
WAIT:	move.b	$ff8209,d0
		beq.s	WAIT
		not.b	d0
		lsl.b	d0,d0

		rept 74
		nop
		endr

		move.l	#$fff8240,a1
		move.w	#24,d0
JK:		move.w	#9,d1
MN:		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		move.w	(a0)+,(a1)
		sub.w	#64,a0
		rept	26
		nop
		endr
		dbf		d1,MN
		move.w	#0,(a1)
		add.w	#64,a0
		rept	116
		nop
		endr
		dbf		d0,JK

		move.l	#RYS,a0
		add.w	ZUJ,a0

		add.w	#1,ZH
		cmp.w	#7,ZH
		bne		BN
		move.w	#0,ZH
		add.w	#1600,ZUJ
		cmp.w	#1600*18,ZUJ
		bne		BN
		move.w	#0,ZUJ
BN:

		move.w	#0,$fff8240
		cmp.b	#57,$fffc02
		beq		END
		rte

*-------------------------------------------------------------------------*
ZH:		dc.w	1
		even
ZUJ:	dc.w	1
		even
RYS:	incbin	"A:ASEMBLER.S\DANE.DAT\ANIM.DAT"
		even
old70	dc.l	0
		even
