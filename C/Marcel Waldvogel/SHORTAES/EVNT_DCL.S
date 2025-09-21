                EXPORT  evnt_dclick
                IMPORT  aes, intin

evnt_dclick:	movem.w	D0/D1,intin
		move.l	#$1A020100,D0
		bra	aes

