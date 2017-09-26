;
; Pixel collision detection. Uses the mask of a 16x sprite to see
; if it covers any pixels on the screen.
;
; 	collide=C:pixel_collide(frame,x,y,height,gfx,l:screen)
;	

pixel_collide
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d2
	move	62(a7),d0
	move	64(a7),d1
	move	66(a7),d3
	move.l	68(a7),a1
	move.l	72(a7),a0
	bsr.s	hit_pix
	moveq	#0,d0
	tst	d3
	beq.s	.nohit
	moveq	#-1,d0
.nohit	movem.l	(a7)+,d1-7/a0-6
	rts
	
hit_pix	move	d3,d7
	subq	#1,d7
	subq	#8,d0
	move	d3,d4
	add	d4,d4
	lsl	#3,d3
	add	d4,d3		; height*10
	mulu	d2,d3
	add.l	d3,a1		; mask address
	
	move	d0,d4
	lsr	#1,d4
	and.l	#$fff8,d4
	add	d4,a0
	move	d1,d4
	lsl	#2,d4
	add	d1,d4
	lsl.l	#5,d4
	add.l	d4,a0		; screen address
	moveq	#0,d3		; clear flag
	and	#$f,d0
	cmp	#8,d0
	bge.s	rol		; choose quickest routine

ror	lea	8(a0),a2	; right side of sprite
.lp	moveq	#0,d1
	move	(a1)+,d1
	ror.l	d0,d1
	rept	4		; do all 4 bitplanes
	move	(a0)+,d2
	and	d1,d2
	or	d2,d3		; merge left side with flag
	swap	d1
	move	(a2)+,d2
	and	d1,d2
	swap	d1
	or	d2,d3		; merge right side with flag
	bne.s	.hit		; jump to hit if flag <> 0
	endr
	addq	#8,a1		; next sprite line
	lea	152(a0),a0	; next screen line, left side
	lea	152(a2),a2	; next screen line, right side
	dbf	d7,.lp
.hit	rts

rol	subq	#8,d0
	neg	d0
	addq	#8,d0
	lea	8(a0),a2
.lp	moveq	#0,d1
	move	(a1)+,d1
	rol.l	d0,d1
	rept	4
	move	(a2)+,d2
	and	d1,d2
	or	d2,d3
	swap	d1
	move	(a0)+,d2
	and	d1,d2
	swap	d1
	or	d2,d3
	bne.s	.hit
	endr
	addq	#8,a1
	lea	152(a0),a0
	lea	152(a2),a2
	dbf	d7,.lp
.hit	rts
