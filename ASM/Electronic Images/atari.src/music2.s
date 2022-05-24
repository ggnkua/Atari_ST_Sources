		output d:\techtron.prg

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l 	#6,sp
		bsr	music
		
forever		move.w	#37,-(sp)
		trap 	#14
		addq.l	#2,sp
		bsr	music+8
		bra	forever

		clr	-(sp)
		trap	#1

music		incbin d:\coding.s\dsppaula\st_play\techtron.mus