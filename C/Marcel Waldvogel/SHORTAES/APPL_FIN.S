		EXPORT	appl_find
		IMPORT	aes, addrin

appl_find:	move.l	A0,addrin
		move.l	#$0D000101,D0
		bra	aes
