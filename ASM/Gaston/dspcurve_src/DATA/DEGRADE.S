st	set	   %1111100000000000
	rept	31
	dc.w	st
st	set	st+%0000000001000000
	endr
	rept	31
	dc.w	st
st	set	st-%0000100000000000
	endr
	rept	31
	dc.w	st
st	set	st+%0000000000000001
	endr
	rept	31
	dc.w	st
st	set	st-%0000000001000000
	endr
	rept	31
	dc.w	st
st	set	st+%0000100000000000
	endr
	rept	31
	dc.w	st
st	set	st+%0000000001000000
	endr