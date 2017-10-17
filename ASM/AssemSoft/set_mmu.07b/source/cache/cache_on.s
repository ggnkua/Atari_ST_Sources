		comment HEAD=1
		opt p=68040

mc060:	= 0	;Set to 0 to assemble for 040, 1 to assemble for 060

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

	IFNE	mc060
		move.l	#$B0C08000,d0
	ELSEIF	;mc060
		move.l	#(1<<31)|(1<<15),d0
	ENDC	;mc060
		movec	d0,cacr

	IFNE	mc060
		moveq	#1,d0
		dc.w	$4e7b,$808
	ENDC	;mc060


	;	move.l	#$8000c040,d0
	;	movec	d0,itt0
	;	movec	d0,dtt0
	;	move.l	#$803fc040,d0
	;	movec	d0,itt1
	;	movec	d0,dtt1


		trap	#1
		addq.l	#6,a7
		clr	-(a7)
		trap	#1
