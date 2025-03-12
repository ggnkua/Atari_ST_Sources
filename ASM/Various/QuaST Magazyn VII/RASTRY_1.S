***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Rastry - ruchome rastry. W sumie nic nowego               *
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
		move.l	#ZK,UJ
		move.w	#0,KL

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
WAIT:
		move.b	$ff8209,d0
		beq.s	WAIT
		not.b	d0
		lsl.b	d0,d0

		rept 45
		nop
		endr
		move.w	KL,d0
OL:		dbf		d0,OL		

		move.w	#250,d1
MN:
		move.w	#$000,$fff8240
		move.w	#$888,$fff8240
		move.w	#$111,$fff8240
		move.w	#$999,$fff8240
		move.w	#$222,$fff8240
		move.w	#$aaa,$fff8240
		move.w	#$333,$fff8240
		move.w	#$bbb,$fff8240
		move.w	#$444,$fff8240
		move.w	#$ccc,$fff8240
		move.w	#$555,$fff8240
		move.w	#$ddd,$fff8240
		move.w	#$666,$fff8240
		move.w	#$ddd,$fff8240
		move.w	#$555,$fff8240
		move.w	#$ccc,$fff8240
		move.w	#$444,$fff8240
		move.w	#$bbb,$fff8240
		move.w	#$333,$fff8240
		move.w	#$aaa,$fff8240
		move.w	#$222,$fff8240
		move.w	#$999,$fff8240
		move.w	#$111,$fff8240
		move.w	#$888,$fff8240
		move.w	#$000,$fff8240
		nop		
		dbf		d1,MN

		cmp.b	#57,$fffc02
		beq		END

		move.l	UJ,a0
		cmp.w	#999,2(a0)
		bne		POL1
		move.l	#ZK,UJ
		move.l	UJ,a0
POL1:	move.w	(a0)+,KL
		move.l	a0,UJ
HJ:		rte

*-------------------------------------------------------------------------*

OLDVBL:	dc.l	0
KL:		dc.w	1
ZK:		dc.w	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
		dc.w	29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,999
UJ:		dc.l	1
