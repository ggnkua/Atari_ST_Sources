;
; Copies screen lines in reverse to provide mirror image
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; ~C:reverse_lines%(L:source,L:destination,lines)

revln	movem.l	d1-d7/a0-a6,-(a7)
	move.l	60(a7),a0		; source
	move.l	64(a7),a1		; destination
	move	68(a7),d7
	move	d7,d6
	add	d6,d6
	add	d6,d6
	add	d7,d6
	asl	#5,d6
	add	d6,a1
	subq	#1,d7
.lp	movem.l	(a0)+,d0-d6/a2-a4	; get 40 bytes
	movem.l	d0-d6/a2-a4,(a1)	; put 40 bytes
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,40(a1)
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,80(a1)
	movem.l	(a0)+,d0-d6/a2-a4	; and again
	movem.l	d0-d6/a2-a4,120(a1)
	lea	-160(a1),a1		; next line up
	dbf	d7,.lp
	movem.l	(a7)+,d1-d7/a0-a6
	rts
	