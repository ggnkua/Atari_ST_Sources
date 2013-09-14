	xdef _ToColor
	xdef _FColor

	text

_ToColor:   move.l  4(a7),a0
	   move.w  8(a7),d0
	   move.w  d0,(a0)
	   rts

_FColor:  move.l 4(a7),a0
	 move.l 8(a7),a1
	 move.w (a0),(a1)
	 rts

	end
