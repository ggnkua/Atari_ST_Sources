                EXPORT  evnt_timer
                IMPORT  aes, intin

evnt_timer:	movem.w	D0/D1,intin
		move.l	#$18020100,D0
		bra	aes

