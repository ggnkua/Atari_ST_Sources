;	Switch on Powerup.
 
		section	text

		output	c:\auto\poweron.prg
		pea	go(pc)
		move.w	#$26,-(sp)
		trap 	#14
		addq.l	#6,sp
		pea	text(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		clr	-(sp)
		trap	#1
go		move.b	#$d6,$fffffc00.w
		rts
		section	data
text		dc.b	10,13,"PowerUP 32mhz ACTIVITATED!",10,13,0
		even
