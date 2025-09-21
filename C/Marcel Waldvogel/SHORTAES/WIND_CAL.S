                EXPORT  wind_calc
                IMPORT  aes, intin

wind_calc:	move.l	A1,-(A7)
		move.l	A0,-(A7)	;8 Bytes mehr auf dem Stack
		lea	intin,A0
		move.w	D0,(A0)+	;kind
		move.w	D1,(A0)+	;type
		move.w  D2,(A0)+	;inx
		move.l	8+4(A7),(A0)+	;iny, inw
		move.w	8+8(A7),(A0)+	;inh
		move.l	#$6C060500,D0
		bsr	aes
		move.l	(A7)+,A1	;outx (Zeiger war in A0)
		move.w	(A0)+,(A1)
		move.l	(A7)+,A1	;outy (Zeiger war in A1)
		move.w	(A0)+,(A1)
		move.l	10(A7),A1	;outw (Zeiger war auf Stack)
		move.w	(A0)+,(A1)
		move.l	14(A7),A1	;outh (Zeiger war auf Stack)
		move.w	(A0)+,(A1)
		rts
