
		opt	xdebug
		
		include	releasem.s
		include	getpar.s
		move.l	a0,paradr
		bra	main
		include	shrtones.s
		include	gem.s


main


**************************************
******		DATA AREA	******		
**************************************



*		include	vdilib.s	only needed if you use vdi
*		include	aeslib.s	only needed if you use aes
**************************************
******		BSS AREA	******
**************************************
		section	bss
		
paradr		ds.l	1


