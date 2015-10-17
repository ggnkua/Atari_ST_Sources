;
; Multi-directional preshifted graphics map printer
;
; ~c:mapper%(x,y,width,height,l:map%,l:gfx%,l:screen%)
;
; The smoothness of the scrolling is defined within the map data.
;
mapper	movem.l	d1-a6,-(a7)
	move	60(a7),d0		; X
	move	62(a7),d1		; Y
	move.l	68(a7),a1		; map	
	move.l	72(a7),d6		; gfx
	move.l	76(a7),a0		; screen
	move	(a1)+,d5		; width
	move	(a1)+,d4		; height
	tst	d0
	bge.s	.xplus
	clr	d0
	bra.s	.noxclp
.xplus	move	64(a7),d2
	lsl	#4,d2		; screen width in pixels
	move	d5,d3
	lsl	#4,d3
	sub	d2,d3		; map width-screen width
	cmp	d3,d0
	ble.s	.noxclp
	move	d3,d0
.noxclp	tst	d1
	bge.s	.yplus
	clr	d1
	bra.s	.noyclp
.yplus	move	66(a7),d2
	lsl	#4,d2		; screen height in pixels
	move	d4,d3
	lsl	#4,d3
	sub	d2,d3		; map height-screen height
	cmp	d3,d1
	ble.s	.noyclp
	move	d3,d1
.noyclp	lsl	#2,d5		; map width*4
	move	(a1)+,d7
	move.l	(a1)+,d3	; gfx size
	move	d0,d2
	and	#$fff0,d2
	lsr	#2,d2		; X div 16
	add	d2,a1		; add x to map
	move	d1,d2
	and	#$000f,d1	; leave y 0-15
	and	#$fff0,d2	; leave y with no offset
	lsr	#4,d2		; divide by 16
	mulu	d5,d2		; * map memory width
	add.l	d2,a1		; add y to map
		
	and	#$f,d0		; X offset 0-15
	rol	#2,d7
	and	#3,d7

	add	d7,d7
	move	jumptab(pc,d7),d4
	jmp	hor1(pc,d4)

jumptab	dc.w	hor4-hor1	; 0 = four pixel scrolling (default)
	dc.w	0		; 1 = single pixel scrolling
	dc.w	hor2-hor1	; 2 = two pixel scrolling
	dc.w	hor8-hor1	; 3 = eight pixel scrolling
		
hor1	move.l	d3,d4		
	lsl.l	#4,d4		; *16
	sub.l	d3,d4		; *15
	bra.s	cont
 
hor2	lsr	#1,d0		; /2
	move.l	d3,d4
	lsl.l	#3,d4		; *8
	sub.l	d3,d4		; *7
	bra.s	cont
	
hor4	lsr	#2,d0		; /4
	move.l	d3,d4
	add.l	d4,d4		; *2
	add.l	d3,d4		; *3
	bra.s	cont

hor8	lsr	#3,d0		; /8
	move.l	d3,d4

cont	mulu	d0,d3
	add.l	d3,d4		; add gfx
	add.l	d6,d3
	add.l	d6,d4
	move.l	d3,a4
	move.l	d4,a5
	move	64(a7),d4	; width
	move	66(a7),d6	; height
	subq	#1,d4
	subq	#1,d6
	tst	d0		; is offset zero
	beq	int		; yes, do integer map draw

	tst	d1		; Y offset zero ?
	beq.s	ni_int		; yes, no top clipping
	subq	#1,d6		; decrese height by one
	move	d4,d7
	movem.l	a0-1,-(a7)
	move	d1,d3
	lsl	#3,d3
.xlpt	move.l	a0,a6
	move.l	(a1)+,a2	; left side gfx
	move.l	(a1),a3		; right side gfx
	add.l	a4,a2		; add graphics offsets
	add.l	a5,a3
	add	d3,a2
	add	d3,a3
	moveq	#15,d2
	sub	d1,d2
.yt	move.l	(a2)+,d0	; get left side
	or.l	(a3)+,d0	; merge right side
	move.l	d0,(a6)+	; put it on screen
	move.l	(a2)+,d0
	or.l	(a3)+,d0
	move.l	d0,(a6)
	lea	156(a6),a6	; next line down
	dbf	d2,.yt
	addq.l	#8,a0
	dbf	d7,.xlpt
	movem.l	(a7)+,a0-1
	moveq	#16,d2
	sub	d1,d2
	move	d2,d7
	add	d7,d7
	add	d7,d7
	add	d2,d7		; *5
	asl	#5,d7		; *160
	add	d7,a0
	add	d5,a1
		
ni_int	movem.l	a0-1/d1/d4-5,-(a7)
	move	d4,d7
.xlp	move.l	(a1)+,a2		
	move.l	(a1),a3			
	add.l	a4,a2
	add.l	a5,a3
	rept	5
	movem.l	(a2)+,d0-5	; get left side gfx the fast way
	or.l	(a3)+,d0	; merge right side gfx
	or.l	(a3)+,d1
	or.l	(a3)+,d2
	or.l	(a3)+,d3
	or.l	(a3)+,d4
	or.l	(a3)+,d5
	movem.l	d0-1,(a0)	; print line 1
	movem.l	d2-3,160(a0)	; print line 2
	movem.l	d4-5,320(a0)	; print line 3
	lea	480(a0),a0	; move 3 lines down
	endr
	move.l	(a2)+,d0	; do last line
	or.l	(a3)+,d0
	move.l	d0,(a0)+
	move.l	(a2)+,d0
	or.l	(a3)+,d0
	move.l	d0,(a0)
	lea	-2404+8(a0),a0
	dbf	d7,.xlp
	movem.l	(a7)+,a0-1/d1/d4-5
	lea	2560(a0),a0
	add	d5,a1
	dbf	d6,ni_int
	
	tst	d1		; was top clipping used ?
	beq.s	.end		; no, must be finished

	move	d4,d7		; now clip bottom gfx
	move	d1,d2
	subq	#1,d2
.xlpb	move.l	a0,a6
	move.l	(a1)+,a2
	move.l	(a1),a3	
	add.l	a4,a2
	add.l	a5,a3
	move	d2,d3
.yb	move.l	(a2)+,d0
	or.l	(a3)+,d0
	move.l	d0,(a6)+
	move.l	(a2)+,d0
	or.l	(a3)+,d0
	move.l	d0,(a6)
	lea	156(a6),a6
	dbf	d3,.yb
	addq.l	#8,a0
	dbf	d7,.xlpb
.end	movem.l	(a7)+,d1-a6
	rts

int	tst	d1		
	beq.s	i_inti
	subq	#1,d6
	move	d4,d7
	movem.l	a0-1,-(a7)	; clip top gfx
	move	d1,d3
	lsl	#3,d3
.xlpt	move.l	a0,a6
	move.l	(a1)+,a2	
	add.l	a4,a2
	moveq	#15,d2
	sub	d1,d2
	add	d3,a2
.yt	move.l	(a2)+,(a6)+	; integer copy,
	move.l	(a2)+,(a6)	; direct copy to screen
	lea	156(a6),a6
	dbf	d2,.yt
	addq.l	#8,a0
	dbf	d7,.xlpt
	movem.l	(a7)+,a0-1
	moveq	#16,d3
	sub	d1,d3
	move	d3,d7
	add	d7,d7
	add	d7,d7
	add	d3,d7
	lsl	#5,d7
	add	d7,a0
	add	d5,a1
i_inti	movem.l	a0-1,-(a7)	; print middle of map
	move	d4,d7
.xlp	move.l	(a1)+,a2
	add.l	a4,a2
	rept	16		; direct copy of all 16 lines
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	endr
	lea	-2560+8(a0),a0
	dbf	d7,.xlp
	movem.l	(a7)+,a0-1
	lea	2560(a0),a0
	add	d5,a1
	dbf	d6,i_inti

	tst	d1
	beq.s	.end
	move	d4,d7		; clip bottom of map
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

