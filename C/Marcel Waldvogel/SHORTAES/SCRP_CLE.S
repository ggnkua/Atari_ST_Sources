                EXPORT  scrp_clear
                IMPORT  aes

scrp_clear:	move.l	#$52000100,D0
		bra	aes
