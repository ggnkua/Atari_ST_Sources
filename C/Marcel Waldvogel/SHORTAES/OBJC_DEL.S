                EXPORT  objc_delete
                IMPORT  aes, intin, addrin

objc_delete:	move.w	D0,intin
		move.l	A0,addrin
		move.l	#$29010101,D0
		bra	aes

