; :ts=10

	dseg
	public _aline



	cseg

	public _ainit
_ainit:
	move.l A2,-(A7)
	dc.w $a000
	move.l (A7)+,A2
	move.l A0,D0
	rts


	public _ablit
_ablit:
	movem.l A2/A6,-(A7)
	move.l 12(A7),A6
	dc.w $a007
	movem.l (A7)+,A2/A6
	rts



	public _atmouse
_atmouse:
	move.l A2,-(A7)
	dc.w $a00b
	movem.l (A7)+,A2
	rts

