                EXPORT  xgrf_2box
                IMPORT  aes, intin

xgrf_2box:	lea	intin,A1
		move.w	D0,(A1)+	;cnt
		move.w	D1,(A1)+	;xstep
		move.w  D2,(A1)+	;ystep
		lea	4(A7),A0
		move.l	(A0)+,(A1)+	;doubled, corners
		move.l	(A0)+,(A1)+	;xc, yc
		move.l	(A0)+,(A1)+	;w, h
		move.l	#$83090100,D0
		bra	aes
