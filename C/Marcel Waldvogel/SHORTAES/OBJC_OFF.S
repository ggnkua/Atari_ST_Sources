                EXPORT  objc_offset
                IMPORT  aes, intin, addrin

objc_offset:	move.l	A1,-(A7)
		move.w	D0,intin
		move.l	A0,addrin
		move.l	#$2C010301,D0
		bsr	aes
		move.l	(A7)+,A1
		move.w	(A0)+,(A1)
		move.l	4(A7),A1
		move.w	(A0)+,(A1)
		rts
