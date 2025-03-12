
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	col,a0
	lea	$f8000,a1

st	set	0
	rept	16*3
	move.w	(a0)+,st(a1)
	move.w	(a0)+,st+8(a1)
	move.w	(a0)+,st+16(a1)
st	set	st+160
	endr

	illegal

col:	incbin	"a:\sprvsspr.ter"
	end	