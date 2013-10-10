;
; Clear screen lines the fast way.
;
; 	~C:clr_lines(lines,L:screen)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

clr_lines
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0		; number of lines to clear
	move.l	62(a7),a0		; screen address
	moveq	#0,d1
	move	d0,d1
	lsl	#2,d1
	add	d0,d1
	lsl.l	#5,d1
	add.l	d1,a0			; goto last line
	subq	#1,d0
	movem.l	values(pc),d1-7/a1-6	; set registers d0-d7 and a1-6
.loop	movem.l	d1-7/a1-6,-(a0)		; PUSH registers onto screen
	movem.l	d1-7/a1-6,-(a0)		; and again
	movem.l	d1-7/a1-6,-(a0)		; and again
	move.l	d1,-(a0)		; and one more
	dbf	d0,.loop		; loop for number of lines
	movem.l	(a7)+,d1-7/a0-6
	rts
values	dcb.l	14,0
