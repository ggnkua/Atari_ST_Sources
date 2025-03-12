***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Rastry 2 - Atar ST ma niby mala palete kolorow (??!)      *
* autor      :  Van Eijk                                                  *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************
 
SUPERVISOR:
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

SCREEN:
		move.w	#0,-(sp)
		pea		$78000
		pea		$78000
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

USTAL:
		bclr.b	#5,$fffa09
		move.w	#0,MK

PRZERWANIE:
		move.l	$70,OLDVBL
		move.l	#VBL,$70

PETLA:	bra		PETLA

*-------------------------------------------------------------------------*

END:
		move.l	OLDVBL,$70
		bset.b	#5,$fffa09
		move.w	#$fff,$fff8240
		move.w	#$000,$fff8246
		clr.l	-(sp)
		trap	#1

*-------------------------------------------------------------------------*


VBL:
WAIT:	move.b	$ff8209,d0
		beq.s	WAIT
		not.b	d0
		lsl.b	d0,d0

		move.w	#10,d0
L:		nop	
		dbf		d0,L
		move.w	#0,MK
		move.w	#2180,d0
F:		move.w	MK,$fff8240
		addq	#1,MK
		nop
		dbf		d0,F

		move.w	#$000,$fff8240
		cmp.b	#57,$fffc02
		beq		END

		rte

*-------------------------------------------------------------------------*

OLDVBL:	dc.l	0
MK:		dc.w	1
