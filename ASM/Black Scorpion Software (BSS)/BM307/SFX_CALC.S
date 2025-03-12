
clear_samplebuffer:
	move.l	sampos,a1
	move.w	samdiv,d1
	mulu	#4,d1
	add.l	d1,a1	; a1 end of current buffer
	divu	#4*8,d1
	subq.l	#1,d1	; d1 num loops
	moveq.l	#0,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	move.l	d2,a2
	move.l	d2,a3
.loop:
	movem.l	d2-7/a2-3,-(a1)
	dbra	d1,.loop
	rts

calculate_sound:
	move.w	samdiv,d1
	subq.w	#1,d1
	ext.l	d1		; d1 num loops
	move.l	sampos,a1		; a1 sample buffer
	move.w	chanpitch(a0),d2	; d2 pitch
	moveq.l	#-1,d3		; d3 tmp pitch
	lea	voltable,a2	
	add.l	chandist(a0),a2	; a2 volume table
	lea	pantable,a3
	add.l	chandir(a0),a3	; a3 paning table
	move.l	chanpos(a0),a4	; a4 sample pos
	moveq.l	#0,d6		; d6 temp vol

.loop:
	add.w	d2,d3	; pitch add
	bcc.s	.nonew	; overflow?
	move.b	(a4)+,d6	; get new sample
	move.b	(a2,d6),d7	; set volume
	move.l	(a3,d7*4),d7; and paning
.nonew:
	add.l	d7,(a1)+	; add to sample buff
	dbra	d1,.loop	; and loop!

	move.l	a4,chanpos(a0); new sample pos
	rts

calculate_ambient:
	move.w	samdiv,d1
	subq.w	#1,d1
	ext.l	d1		; d1 num loops
	move.l	sampos,a1		; a1 sample buffer
	move.w	chanpitch(a0),d2	; d2 pitch
	moveq.l	#-1,d3		; d3 tmp pitch
	lea	ambtable,a2		; a2 ambient table
	move.l	chanpos(a0),a4	; a4 sample pos
	moveq.l	#0,d6		; d6 temp vol

.loop:
	add.w	d2,d3	; pitch add
	bcc.s	.nonew	; overflow?
	move.b	(a4)+,d6	; get new sample
;	move.l	(a2,d6*4),d7; get ambient value
	asl.w	#8,d6
	move.w	d6,d7
	swap	d7
	move.w	d6,d7
.nonew:
	add.l	d7,(a1)+	; add to sample buf
	dbra	d1,.loop	; loop!

	move.l	a4,chanpos(a0); new sample pos
	rts	