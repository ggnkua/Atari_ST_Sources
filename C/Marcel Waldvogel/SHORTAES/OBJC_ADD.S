                EXPORT  objc_add, objc_order
                IMPORT  aes, intin, addrin

objc_add:	move.l	#$28020101,D2
		bra.b	objc_2ii1ai
objc_order:	move.l	#$2D020101,D2
objc_2ii1ai:	movem.w	D0/D1,intin
		move.l	A0,addrin
		move.l	D2,D0
		bra	aes

