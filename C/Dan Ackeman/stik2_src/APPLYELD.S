.export _appl_yield

_appl_yield:
	move.w #$c9,d0
	trap #2
	rts
	
.end