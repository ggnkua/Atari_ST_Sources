;
; Copy screen lines the fast way.
;
; 	~C:copy_lines(lines,L:source,L:destination)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

copyln	movem.l	d1-d7/a0-a6,-(a7)
	move	60(a7),d7		; lines
	movem.l	62(a7),a0-1		; source/destination
	subq	#1,d7
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
	movem.l	(a7)+,d1-d7/a0-a6
	rts
	