*********************************
* Musix by TANGEN!!!!!!!!!!!!!!!*
* Crap program by Pyrotechnics  *
* Ripped by Xerud 		*
*********************************

*main.tan	length 11481	run at 2176c
*devil.tan	length 8657	run at 2a56a
*paral.tan	length 8289	run at 210b4
*balls.tan	length 9281	run at 20c12
*scroll.tan	length		run at 22de2
*game.tan	length 6000	run at 2b78c sfx only
*hidden.tan	length 34001	run at 29444

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	move.l	#MUS,a0
	move.l	#$2a56a,a1	;change to suit muzak
	move.l	#8657,d0	;ditto
l	move.b	(a0)+,(a1)+
	dbf	d0,l
	MOVE.B	#2,$484.w
;	move.b	#$10,$2bf90	;seems to alter sfx on game
	MOVE.L	#PLAY,$4d2.w
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D2.W
	bsr	MUS
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	jsr	$2a56a		;change to suit muzak
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\tangen.muz\devil.tan