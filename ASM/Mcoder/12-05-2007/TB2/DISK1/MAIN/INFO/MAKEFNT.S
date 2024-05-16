
	lea	pic+34,a0
	lea	dest,a1


	move.w	#(320/16)-1,d1

loop2:
st	set	0
	rept	8
	move.b	st(a0),(a1)+
	move.b	st+2(a0),(a1)+
	move.b	st+4(a0),(a1)+
	move.b	st+6(a0),(a1)+
st	set	st+160
	endr

st	set	1
	rept	8
	move.b	st(a0),(a1)+
	move.b	st+2(a0),(a1)+
	move.b	st+4(a0),(a1)+
	move.b	st+6(a0),(a1)+
st	set	st+160
	endr

	addq.l	#8,a0
	dbf	d1,loop2

	lea	(7*160)(a0),a0

	move.w	#6-1,d1

loop1:
st	set	0
	rept	8
	move.b	st(a0),(a1)+
	move.b	st+2(a0),(a1)+
	move.b	st+4(a0),(a1)+
	move.b	st+6(a0),(a1)+
st	set	st+160
	endr

st	set	1
	rept	8
	move.b	st(a0),(a1)+
	move.b	st+2(a0),(a1)+
	move.b	st+4(a0),(a1)+
	move.b	st+6(a0),(a1)+
st	set	st+160
	endr

	addq.l	#8,a0
	dbf	d1,loop1



	illegal

	section	data

pic:	incbin	"infofont.pi1"
	even

	section	bss

dest:	ds.b	50000