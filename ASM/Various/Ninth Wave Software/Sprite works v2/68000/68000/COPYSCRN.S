;
; Copy screens the fast way.
;
; 	~C:copy_screen(L:source,L:destination)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

copy	movem.l	d0-d7/a0-a6,-(a7)
	move.l	64(a7),a0		; source
	move.l	68(a7),a1		; destination
	move	#199,d7			; 200 lines
.lp	movem.l	(a0)+,d0-d6/a2-a4	; get 40 bytes
	movem.l	d0-d6/a2-a4,(a1)	; put 40 bytes
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,40(a1)
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,80(a1)
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,120(a1)
	lea	160(a1),a1		; next line down
	dbf	d7,.lp
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	