		comment HEAD=1
		opt p=68040
		text

mc060:	= 0
		clr.l	-(a7)
		move 	#$0020,-(a7)
		trap	#1
		addq.l	#6,a7
		move.l	d0,-(a7)
		move 	#$0020,-(a7)

		moveq	#0,d0
		movec	d0,cacr
		cpusha	bc
		nop
		movec	d0,itt0
		movec	d0,itt1
		movec	d0,dtt0
		movec	d0,dtt1
		pflusha
		nop
		movec	d0,urp
		movec	d0,srp

	IFNE	mc060
		move.l	#$210,d0
	ELSEIF	;mc060
		moveq	#0,d0
	ENDC	;mc060
		movec	d0,tc
		move.l	#$007FC020,d0
		movec	d0,itt0
		movec	d0,dtt0
		move.l	#$807FC040,d0
		movec	d0,itt1
		movec	d0,dtt1

	IFNE	mc060
		moveq	#$01,d0
		dc.w	$4E7B,$0808
		move.l	#$A0C08000,d0
	ELSEIF	;mc060
		move.l	#(1<<31)|(1<<15),d0
	ENDC	;mc060
		movec	d0,cacr
		trap	#1
		addq.l	#6,a7
		clr	-(a7)
		trap	#1
