	XDEF call_aes

call_aes:	MOVE.L	A0,D1		; call_aes(GEMPARBLK *);
			MOVE.W	#200,D0
			TRAP	#2
			RTS


