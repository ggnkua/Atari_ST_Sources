                EXPORT  wind_find
                IMPORT  aes, intin

wind_find:	movem.w	D0/D1,intin	;mx, my
		move.l	#$6A020100,D0
		bra	aes
