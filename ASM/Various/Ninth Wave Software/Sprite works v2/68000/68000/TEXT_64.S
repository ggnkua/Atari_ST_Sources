;
; 64 Column colour font.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; This font must have its own palette as the characters are
; anti-aliased to give them a smoother look. See FONTS_8.PC1
;
; ~C:text_64%(x,y,length,l:text,l:font,l:screen)

text_64	movem.l	d0-d7/a0-a3,-(a7)
	movem	52(a7),d0/d1/d3		; x/y/colour
	move.l	58(a7),a2		; text
	subq	#1,d3
	move.l	62(a7),a0		; font
	move.l	66(a7),a3		; screen
.lp	moveq	#0,d2
	move.b	(a2)+,d2		; get character
	movem.l	d0-3/a0,-(a7)
	bsr.s	print_letter		; print it
	movem.l	(a7)+,d0-3/a0
	addq	#5,d0
	dbf	d3,.lp
	movem.l (a7)+,d0-d7/a0-a3
	rts

print_letter
	move.l	a3,a1			; calculate screen address
	move	d0,d4
	mulu	#160,d1
	lsr	#1,d0
	and	#$fff8,d0
	ext.l	d0
	add.l	d0,d1
	add.l	d1,a1			; screen address
	and	#$f,d4
	sub	#32,d2
	lsl	#5,d2
	add	d2,a0			; char graphics
	moveq	#7,d7
.ylp	
x set 0
	rept	4	
	moveq	#0,d0
	move.b	(a0)+,d0		; get char graphics
	move.l	#$FFFF07FF,d3		; mask
	lsl	#8,d0
	ror.l	d4,d0			; rotate character
	ror.l	d4,d3  			; rotate mask
	move	x+8(a1),d1
	swap	d1
	move	x(a1),d1		; got screen data
	and.l	d3,d1			; mask hole for character	
	eor.l	d0,d1			; merge char graphics
	move	d1,x(a1)
	swap	d1
	move	d1,x+8(a1)		; place back on screen
x set x+2
	endr
	lea	160(a1),a1
	dbf	d7,.ylp
	rts
