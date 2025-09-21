		EXPORT	shel_rdef, shel_wdef
		IMPORT	aes, addrin

shel_rdef:	move.l	#$7E000102,D0
		bra.b	shel_2ai
shel_wdef:	move.l	#$7F000102,D0
shel_2ai:	movem.l	A0/A1,addrin
		bra	aes
