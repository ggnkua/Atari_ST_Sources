
;
; ~C:v_mapper%(x,y,width,height,L:map,L:gfx,L:screen)
;

v_mapper
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0		; X
	move	62(a7),d1		; Y
	move.l	68(a7),a1		; map	
	move.l	72(a7),a4		; gfx
	move.l	76(a7),a0		; screen
	move	(a1)+,d5		; width
	add	d5,d5
	add	d5,d5			; map width*4
	move	(a1)+,d3		; map height
	tst	d1
	bge.s	.yplus
	clr	d1
	bra.s	.noyclp
.yplus	move	66(a7),d2
	lsl	#4,d2			; screen height in pixels
	lsl	#4,d3
	sub	d2,d3			; map height-screen height
	cmp	d3,d1
	ble.s	.noyclp
	move	d3,d1
.noyclp	addq	#2,a1
	move.l	(a1)+,d3		; gfx size
	move	d1,d2
	and	#$000f,d1
	and	#$fff0,d2
	lsr	#4,d2
	mulu	d5,d2			; Y offset
	and	#$fff0,d0
	lsr	#2,d0
	add	d0,d2			; X offset
	add.l	d2,a1			; add x/y to map
		
	move	64(a7),d4		; width
	move	66(a7),d6		; height
	subq	#1,d4
	subq	#1,d6

	tst	d1			; top clipping needed ?
	beq.s	.ylp			; no, do middle of map
	subq	#1,d6			; decrease height by one
	move	d4,d7			; print top with clipping
	move.l	a0,a3
	move.l	a1,a5
	move	d1,d3
	asl	#3,d3
.xlpt	move.l	a0,a6
	move.l	(a1)+,a2
	add.l	a4,a2
	moveq	#15,d2
	sub	d1,d2
	add	d3,a2
.yt	move.l	(a2)+,(a6)+		; direct copy to screen
	move.l	(a2)+,(a6)
	lea	156(a6),a6
	dbf	d2,.yt
	addq.l	#8,a0
	dbf	d7,.xlpt
	move.l	a3,a0
	move.l	a5,a1
	moveq	#16,d3
	sub	d1,d3
	move	d3,d7
	add	d7,d7
	add	d7,d7
	add	d3,d7
	lsl	#5,d7
	add	d7,a0
	add	d5,a1
.ylp	move.l	a0,a5			; print middle of map
	move.l	a1,a6
	move	d4,d7
.xlp	move.l	(a1)+,a2
	add.l	a4,a2
	rept	16
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	endr
	lea	-2560+8(a0),a0
	dbf	d7,.xlp
	move.l	a5,a0
	move.l	a6,a1
	lea	2560(a0),a0
	add	d5,a1
	dbf	d6,.ylp

	tst	d1			; bottom clipping needed ?
	beq.s	.end			; nope, finsihed
	move	d4,d7			; print bottom of map with clipping
.xlpb	move.l	a0,a6
	move.l	(a1)+,a2
	add.l	a4,a2
	move	d1,d2
	subq	#1,d2
.yb	move.l	(a2)+,(a6)+
	move.l	(a2)+,(a6)
	lea	156(a6),a6
	dbf	d2,.yb
	addq.l	#8,a0
	dbf	d7,.xlpb
.end	movem.l	(a7)+,d1-7/a0-6
	rts
