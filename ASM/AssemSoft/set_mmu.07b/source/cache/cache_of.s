		comment HEAD=1
		opt p=68040

		text

		clr.l	-(a7)
		move 	#$20,-(a7)
		trap	#1
		addq.l	#6,a7
		move.l	d0,-(a7)
		move 	#$20,-(a7)
		
		cpusha	bc
		nop
		pflusha
		nop
		moveq	#0,d0
		movec	d0,cacr
		cpusha	bc
		nop
		

		trap	#1
		addq.l	#6,a7
		clr	-(a7)
		trap	#1
				
