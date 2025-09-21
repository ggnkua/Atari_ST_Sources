                EXPORT  evnt_mouse
                IMPORT  aes, intin

evnt_mouse:	move.l	A1,-(A7)
		move.l	A0,-(A7)	;8 Bytes mehr auf dem Stack
		movem.w	D0-D2,intin
		move.l	4+8(A7),intin+6
		move.l	#$16050500,D0
		bsr	aes
		move.l	(A7)+,A1
		move.w	(A0)+,(A1)
		move.l	(A7)+,A1
		move.w	(A0)+,(A1)
		move.l	4(A7),A1
		move.w	(A0)+,(A1)
		rts

