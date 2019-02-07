
	public _sign8	; convert spl file to signed...
_sign8
	move.l	4(sp),a0
	move.b	#$80,d1
	move.l	8(sp),d0
	bra	zs8
s8	add.b	d1,(a0)+
	sub.l	#1,d0
zs8	bne	s8
	rts

