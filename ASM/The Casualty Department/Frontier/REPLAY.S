*********************************	
*				*
*	Frontier (Elite II)	*
*				*
*	   In Game Music	*
*				*
*	  Rip and Rout by	*
*				*
*	     Dr Dynac		*
*				*
*            10/12/93		*
*				*
*********************************
;	Tunes are as follows:

; 0 - Lowe    -	Frontier Main Theme		 
; 1 - Greig   - In The Hall Of The Mountain King (Hyperspace music)
; 2 - Strauss -	Blue Danube			 (Docking music)
; 3 - Wagner  - Ride Of The Valkyries		 (Battle music)

tune	= 0			<------- put tune number in here
	
super	pea	0			;must be in supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.l	#tune,d0		;tune to play
	bsr	play			;err???

waitkey	move.w	#7,-(a7)		;press a key to stop
	trap	#1
	addq.l	#2,a7
	
	bsr	stop			;err???

exit	clr.w	-(a7)			;quit
	trap	#1

play	bchg	#0,$484			;click off
	bsr	music			;initialize the music
	move.l	#music+4,$4d2		;play music through interrupt
	rts

stop	clr.l	$4d2			;clear interrupt
	bchg	#0,$484			;click on
	move.l	#$8000000,$ffff8800	;clear sound channels
      	move.l  #$9000000,$ffff8800 	;
      	move.l  #$a000000,$ffff8800 	;
	rts

	data

music	incbin	"FRONTIER.MUS"

