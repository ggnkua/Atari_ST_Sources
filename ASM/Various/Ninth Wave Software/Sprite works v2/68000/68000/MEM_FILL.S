;
; Memory filler.
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; Fill an area of memory with a byte value.
;
; ~C:mem_fill%(l:address,l:length,value)

memfill	movem.l	d0-1/a0,-(a7)
	move.l	16(a7),a0	; start
	move.l	20(a7),d0	; length
	move	24(a7),d1	; number
	subq.l	#1,d0		; decrease by one for dbf
.flp	move.b	d1,(a0)+	; store number
	dbf	d0,.flp		; loop
	movem.l	(a7)+,d0-1/a0
	rts
