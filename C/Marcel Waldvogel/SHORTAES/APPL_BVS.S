                EXPORT  appl_bvset
                IMPORT  aes, intin

appl_bvset:	movem.w	D0-D1,intin
		move.l	#$10020100,D0
		bra	aes


