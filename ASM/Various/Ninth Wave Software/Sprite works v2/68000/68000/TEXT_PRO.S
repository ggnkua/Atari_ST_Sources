;
; ~C:text_pro%(x,y,length,l:text,l:font,l:screen,mode)

text_pro
	movem.l	d1-d7/a0-a6,-(a7)
	movem	60(a7),d0/d1/d4		; x/y/length
	move.l	66(a7),a5		; text
	subq	#1,d4
	move.l	70(a7),a0		; font
	move.l	74(a7),a3		; screen
	tst	78(a7)
	beq.s	.solid
	lea	xray(pc),a6
	bra.s	.lp
.solid	lea	solid(pc),a6
.lp	moveq	#0,d2
	move.b	(a5)+,d2		; get character
	swap	d4
	bsr.s	print_letter		; print it
	swap	d4
	dbf	d4,.lp
	movem.l (a7)+,d1-d7/a0-a6
	rts

print_letter
	move.l	a3,a1			; calculate screen address
	move	d0,d3
	move	d0,d4
	move	d1,d5
	move	d1,d6
	add	d5,d5
	add	d5,d5
	add	d6,d5
	ext.l	d5
	lsl.l	#5,d5
	lsr	#1,d3
	and	#$fff8,d3
	ext.l	d3
	add.l	d3,d5
	add.l	d5,a1			; screen address
	and	#$f,d4
	cmp	#8,d4
	blt.s	even
odd	subq	#8,d4
	lea	8(a1),a2
	addq	#1,a1
	bra.s	ok
even	lea	1(a1),a2
ok	sub	#32,d2
	lea	32(a0,d2),a4		; table
	move.b	(a4),d7			; increase x by width
	ext	d7
	add	d7,d0
	lsl	#5,d2
	lea	127(a0,d2),a4		; char graphics
	jmp	(a6)
	
solid	move.b	widths(pc,d7),d6	; mask
	ror	d4,d6
	not	d6
	move	d6,d5
	lsr	#8,d5
	moveq	#7,d7
.ylp	clr	d2
	move.b	(a4)+,d2
	ror	d4,d2
	and.b	d6,(a1)
	or.b	d2,(a1)
	lsr	#8,d2
	and.b	d5,(a2)
	or.b	d2,(a2)
	clr	d2
	move.b	(a4)+,d2
	ror	d4,d2
	and.b	d6,2(a1)
	or.b	d2,2(a1)
	lsr	#8,d2
	and.b	d5,2(a2)
	or.b	d2,2(a2)
	clr	d2
	move.b	(a4)+,d2
	ror	d4,d2
	and.b	d6,4(a1)
	or.b	d2,4(a1)
	lsr	#8,d2
	and.b	d5,4(a2)
	or.b	d2,4(a2)
	clr	d2
	move.b	(a4)+,d2
	ror	d4,d2
	and.b	d6,6(a1)
	or.b	d2,6(a1)
	lsr	#8,d2
	and.b	d5,6(a2)
	or.b	d2,6(a2)
	lea	160(a1),a1
	lea	160(a2),a2
	dbf	d7,.ylp
	rts

widths	dc.b	%00000000
	dc.b	%10000000
	dc.b	%11000000
	dc.b	%11100000
	dc.b	%11110000
	dc.b	%11111000
	dc.b	%11111100
	dc.b	%11111110
	dc.b	%11111111

xray	swap	d0
	swap	d1
	moveq	#7,d7
.ylp	clr	d0
	clr	d1
	clr	d2
	clr	d3
	move.b	(a4)+,d0
	ror	d4,d0
	move.b	(a4)+,d1
	ror	d4,d1
	move.b	(a4)+,d2
	ror	d4,d2
	move.b	(a4)+,d3
	ror	d4,d3
	move	d0,d6
	or	d1,d6
	or	d2,d6
	or	d3,d6
	not	d6
	and.b	d6,(a1)
	or.b	d0,(a1)
	and.b	d6,2(a1)
	or.b	d1,2(a1)
	and.b	d6,4(a1)
	or.b	d2,4(a1)
	and.b	d6,6(a1)
	or.b	d3,6(a1)
	lsr	#8,d0
	lsr	#8,d1
	lsr	#8,d2
	lsr	#8,d3
	lsr	#8,d6
	and.b	d6,(a2)
	or.b	d0,(a2)
	and.b	d6,2(a2)
	or.b	d1,2(a2)
	and.b	d6,4(a2)
	or.b	d2,4(a2)
	and.b	d6,6(a2)
	or.b	d3,6(a2)
	lea	160(a1),a1
	lea	160(a2),a2
	dbf	d7,.ylp
	swap	d0
	swap	d1
	rts
