		EXPORT	wind_set
		IMPORT	aes, intin

; ACHTUNG, Prototyp: int wind_set(int handle, int field, ...);
wind_set:	lea	intin,A0
		move.w	D0,(A0)+	;handle
		move.w	D1,(A0)+	;field
		move.l	4(A7),(A0)+	;w1, w2
		move.l	8(A7),(A0)+	;w3, w4
		move.l	#$69060100,D0
		bra	aes

