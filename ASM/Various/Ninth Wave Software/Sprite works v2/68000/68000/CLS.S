;
; Clear screen the fast way.
;
; 	~C:cls(L:screen)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

cls	movem.l	d0-7/a0-6,-(a7)
	move.l	64(a7),a0		; screen address
	lea	32000(a0),a0		; goto end of screen
	movem.l	values(pc),d0-7/a1-6	; set registers d0-d7 and a1-6
.loop	movem.l	d1-7/a1-6,-(a0)		; PUSH registers onto screen
	movem.l	d1-7/a1-6,-(a0)		; and again
	movem.l	d1-7/a1-6,-(a0)		; and again
	move.l	d1,-(a0)		; and one more
	dbf	d0,.loop		; loop for 200 lines
	movem.l	(a7)+,d0-7/a0-6
	rts
values	dc.l	199
	ds.l	14
