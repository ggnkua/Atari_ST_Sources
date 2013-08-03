	bra	Start

	INCLUDE	EXAPLAY.I
	TEXT

Start:
* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	bsr.l	ExaPlay.relocate
	lea	song,a0
	bsr.l	ExaPlay.play

.wait:	cmpi.b	#$39,$fffffc02.w
	beq.s	.wait

	bsr.l	ExaPlay.stop

	clr.w	-(sp)
	trap	#1

	DATA

song:	INCBIN	F:\_D-FORCE\HMM2.MOD
	DC.W	100000
