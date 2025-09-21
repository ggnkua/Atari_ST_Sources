                EXPORT  evnt_button
                IMPORT  aes, intin

evnt_button:	move.l	A1,-(A7)
		move.l	A0,-(A7)
		movem.w	D0-D2,intin
		move.l	#$15030500,D0
		bsr	aes
		move.l	(A7)+,A1
		move.w	(A0)+,(A1)
		move.l	(A7)+,A1
		move.w	(A0)+,(A1)
		move.l	4(A7),A1
		move.w	(A0)+,(A1)
		rts

