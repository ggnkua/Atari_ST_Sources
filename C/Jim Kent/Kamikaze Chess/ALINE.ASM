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

	cseg
	public _vdi

	public _v_regf
_v_regf
firstp	set	4+4*4
handle	set	firstp
fontheader set	firstp+2
buffer	set	firstp+6
halfsize	set	firstp+10
vrfregs	reg	a2/a3/d2/d3
	movem.l	vrfregs,-(sp)
	move.l	#_contrl,a2
	move.w	halfsize(sp),18(a2)
	move.l	buffer(sp),14(a2)
	move.l	fontheader(sp),20(a2)
	move.w	handle(sp),12(a2)
	move.w	#0,2(a2)	;number of vertices
	move.w	#1,6(a2)	;length of intin array
	move.w	#119,0(a2) ;VDI function opcode
	move.l	#_intin,a2
	move.w	#0,(a2)	;reserved (always 0)
	jsr	_vdi
endi
	movem.l	(sp)+,vrfregs
	rts

	dseg
	public _contrl
	public _intin



