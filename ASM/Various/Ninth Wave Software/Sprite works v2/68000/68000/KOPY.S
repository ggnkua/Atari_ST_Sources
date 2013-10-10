;
; KOPY is a general purpose copy routine. Selectable planes, print
; mode and clipping.
;
;
; 	~C:kopy(frame,x,y,width,height,planes,mode,l:gfx,l:screen)
; 	~C:kopy_store(frame,x,y,width,height,planes,l:buffer,l:screen)
;	~C:kopy_clip(x1,y1,x2,y2)

	bra	kopy
	bra	kopy_store		
	bra	kopy_clip

kopy	movem.l	d1-7/a0-4,-(a7)
	move	52(a7),d6		; frame
	move	54(a7),d0		; X
	and	#$fff0,d0
	movem	56(a7),d1/d3		; Y/Width
	and	#$fff0,d3
	move	60(a7),d2		; height
	move	62(a7),d5		; planes
	move.l	66(a7),a3		; gfx
	move.l	70(a7),a2		; screen
	
	move	d3,d4		
	mulu	d5,d4			; width*planes
	move	d4,a4
	mulu	d2,d4			; width*planes*height
	lsr	#3,d4
	mulu	d4,d6			; *frame
	add.l	d6,a3			; -> gfx

	move	d2,d7
	subq	#1,d7
	
	lea	clipping(pc),a0
.cminy	move	2(a0),d4
	cmp	d4,d1
	bge.s	.cmaxy
	move	d4,d6			; top clipping
	sub	d2,d6
	cmp	d6,d1
	ble	.error
	sub	d4,d1
	add	d1,d7
	neg	d1
	move	a4,d6
	lsr	#3,d6
	mulu	d1,d6
	add	d6,a3
	move	d4,d1
	bra.s	.cminx

.cmaxy	move	6(a0),d4
	cmp	d4,d1
	bge	.error
	sub	d2,d4			; bottom clipping
	cmp	d4,d1
	ble.s	.cminx
	sub	d1,d4
	add	d4,d7
.cminx	moveq	#0,d6
	move	(a0),d4
	cmp	d4,d0
	bge.s	.cmaxx
	move	d4,d6			; left clipping
	sub	d3,d6
	cmp	d6,d0
	ble.s	.error
	move	d4,d6
	sub	d0,d6
	sub	d6,d3			; decrease width
	lsr	#4,d6
	mulu	d5,d6			; * planes
	add	d6,d6
	add	d6,a3
	move	d4,d0
	bra.s	.calc	
.cmaxx	move	4(a0),d4
	cmp	d4,d0
	bge.s	.error
	move	d4,d2			; right clipping
	sub	d3,d2
	cmp	d0,d2
	bge.s	.calc
	sub	d0,d2
	add	d2,d3
	neg	d2
	lsr	#4,d2
	mulu	d5,d2
	add	d2,d2
	move	d2,d6

.calc	and.l	#$fff0,d0
	lsr	#1,d0
	add	d0,a2
	move	d1,d0
	lsl	#2,d1
	add	d1,d0
	lsl.l	#5,d0			; d1*160 the fast way
	add.l	d0,a2
	lsr	#4,d3
	subq	#1,d3
	
	tst	64(a7)			; solid or x-ray mode
	bne.s	or_it			; branch to x-ray
	subq	#1,d5
.ylp	move.l	a2,a1			; Y loop
	move	d3,d1
.xlp	move.l	a1,a0			; X loop
	move	d5,d0
.bpln	move	(a3)+,(a0)+		; bitplanes loop
	dbf	d0,.bpln
	addq	#8,a1
	dbf	d1,.xlp
	add	d6,a3
	lea	160(a2),a2
	dbf	d7,.ylp
.error	movem.l	(a7)+,d1-7/a0-4
	rts

or_it	subq	#1,d5
.ylpo	move.l	a2,a1
	move	d3,d1
.xlpo	move.l	a1,a0
	move	d5,d0
	move.l	a3,a4
	moveq	#0,d4
.bpln1	or	(a4)+,d4		; create mask from all bitplanes
	dbf	d0,.bpln1
	not	d4
	move	d5,d0
.bpln2	and	d4,(a0)			; AND mask
	move	(a3)+,d2
	or	d2,(a0)+		; OR data
	dbf	d0,.bpln2
	addq	#8,a1
	dbf	d1,.xlpo
	add	d6,a3
	lea	160(a2),a2
	dbf	d7,.ylpo
	movem.l	(a7)+,d1-7/a0-4
	rts
kopy_store
	movem.l	d1-7/a0-4,-(a7)
	move	52(a7),d6		; frame
	move	54(a7),d0		; X
	and	#$fff0,d0
	move	56(a7),d1		; Y
	move	58(a7),d3		; width
	and	#$fff0,d3
	move	60(a7),d2		; height
	move	62(a7),d5		; planes
	move.l	64(a7),a3		; buffer
	move.l	68(a7),a2		; screen
	
	move	d3,d4		
	mulu	d5,d4			; width*planes
	mulu	d2,d4			; width*planes*height
	lsr	#3,d4
	mulu	d4,d6			; *frame
	add.l	d6,a3			; -> buffer

	and	#$fff0,d0
	lsr	#1,d0
	add	d0,a2
	move	d1,d0
	lsl	#2,d0
	add	d0,d1
	ext.l	d1
	lsl.l	#5,d1		
	add.l	d1,a2
	lsr	#4,d3
	subq	#1,d3
	subq	#1,d5
	
.ylp	move.l	a2,a1
	move	d3,d1
.xlp	move.l	a1,a0		
	move	d5,d0
.bitpl	move	(a0)+,(a3)+
	dbf	d0,.bitpl
	addq	#8,a1
	dbf	d1,.xlp
	lea	160(a2),a2
	dbf	d2,.ylp
	movem.l	(a7)+,d1-7/a0-4
	rts

kopy_clip
	movem.l	d1-3/a0,-(a7)
	movem	20(a7),d0-3
	lea	clipping(pc),a0
	and	#$fff0,d0
	addq	#1,d2
	addq	#1,d3
	and	#$fff0,d2
	movem	d0-3,(a0)
	movem.l	(a7)+,d1-3/a0
	rts	

clipping dc.w	0,0,320,200
