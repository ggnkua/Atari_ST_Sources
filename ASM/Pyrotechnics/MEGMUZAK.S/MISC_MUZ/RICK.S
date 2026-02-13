*********************************
* Musix FROM RICK DANGEROUS	*
* Crap program by Pyrotechnics  *
* Ripped by Xerud		*
*********************************

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	move.l	#MUS,a0
	move.l	#$428a2,a1
	move.w	#17000,d0
l	move.b	(a0)+,(a1)+
	dbf	d0,l
	MOVE.L	#PLAY,$4d6
	jsr	$42c9a
	moveq	#1,d0	;change tune 1-8
	jsr	$42962
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D6.W
	JSR	$428A2
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	jsr	$42aa0
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\misc_muz\rick.muz