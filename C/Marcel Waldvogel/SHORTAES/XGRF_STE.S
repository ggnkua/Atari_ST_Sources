                EXPORT  xgrf_stepcalc
                IMPORT  aes, intin

xgrf_stepcalc:	move.l	A1,-(A7)
		move.l	A0,-(A7)	;8 Bytes mehr auf dem Stack
		lea	intin,A0
		move.w	D0,(A0)+	;orgw
		move.w	D1,(A0)+	;orgh
		move.w  D2,(A0)+	;xc
		move.l	8+4(A7),(A0)+	;yc, w
		move.w	8+8(A7),(A0)+	;h
		move.l	#$82060600,D0
		bsr	aes
		move.l	(A7)+,A1	;cx (Zeiger war in A0)
		move.w	(A0)+,(A1)
		move.l	(A7)+,A1	;cy (Zeiger war in A1)
		move.w	(A0)+,(A1)
		move.l	10(A7),A1	;cnt (Zeiger war auf Stack)
		move.w	(A0)+,(A1)
		move.l	14(A7),A1	;xstep (Zeiger war auf Stack)
		move.w	(A0)+,(A1)
		move.l	18(A7),A1	;ystep (Zeiger war auf Stack)
		move.w	(A0)+,(A1)
		rts
