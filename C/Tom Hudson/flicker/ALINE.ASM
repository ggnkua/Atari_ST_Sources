

	public _aline


	public _ainit
_ainit:
	move.l A2,-(A7)
	dc.w $a000
	move.l (A7)+,A2
	move.l A0,D0
	rts

	public _aput
_aput:
	dc.w $a001
	rts

	public _aget
_aget:
	dc.w $a002
	rts


	public _aaline
_aaline:
	move.l A2,-(A7)
	dc.w $a003
	move.l (A7)+,A2
	rts


	public _ahline
_ahline:
	move.l A2,-(A7)
	dc.w $a004
	move.l (A7)+,A2
	rts


	public _acblock
_acblock:
	move.l A2,-(A7)
	dc.w $a005
	move.l (A7)+,A2
	rts


	public _apoly
_apoly:
	move.l A2,-(A7)
	dc.w $a006
	move.l (A7)+,A2
	rts


	public _ablit
_ablit:
	movem.l A2/A6,-(A7)
	move.l 12(A7),A6
	dc.w $a007
	movem.l (A7)+,A2/A6
	rts




	public _atextblt
_atextblt:
	move.l A2,-(A7)
	dc.w $a008
	movem.l (A7)+,A2
	rts


	public _ashow_mouse
_ashow_mouse:
	move.l A2,-(A7)
	dc.w $a009
	movem.l (A7)+,A2
	rts


	public _ahide_mouse
_ahide_mouse:
	move.l A2,-(A7)
	dc.w $a00a
	movem.l (A7)+,A2
	rts

	public _atmouse
_atmouse:
	move.l A2,-(A7)
	dc.w $a00b
	movem.l (A7)+,A2
	rts


	; polyline(points, count)
	public _polyline
_polyline
	movem.l	a2/a3/a4/d7,-(sp)
	move.l	20(sp),a3
	move.w	24(sp),d7
	move.l	_aline,a4
	adda	#38,a4	;	point at line coordinate bits of aline
	subq.w	#1,d7	;	one less line than # of vertices ... 
	bra plinez
plineloop	move.l	(a3)+,(a4)
	move.l	(a3),4(a4)
	dc.w $a003
plinez dbra	d7,plineloop
	movem.l	(sp)+,a2/a3/a4/d7
	rts
