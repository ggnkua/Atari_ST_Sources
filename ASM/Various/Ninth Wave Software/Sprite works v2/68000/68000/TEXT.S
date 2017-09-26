;
; 40 Column text. Single bit plane and colour font in solid
; or x-ray modes.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; ~C:text%(x,y,length,colour,l:text,l:font,l:screen)

text	movem.l	d0-7/a0-6,-(a7)
	movem	64(a7),d0-3		; X/Y/length/colour
	movem.l	72(a7),a0-2		; text/font/screen
	move.l	#$00070001,d5		; screen increase (1/7)
	move	d2,d7
	move	d0,d4			; calculate address
	and	#$fe,d0	
	lsl	#2,d0
	and	#1,d4
	beq.s	.even
	swap	d5			; screen increase (7/1)
.even	add	d4,d0
	move	d1,d4
	add	d4,d4			; *2
	lsl	#3,d1			; *8
	add	d4,d1			; *10
	ext.l	d1
	lsl.l	#7,d1			; *1280
	ext.l	d0
	add.l	d1,d0
	add.l	d0,a2			; a2 -> screen
	subq	#1,d7
	
	btst	#4,d3
	bne	cchar			; colour char
schar	move.l	a1,-(a7)		; single colour char
	moveq	#0,d0
	move.b	(a0)+,d0		; get character
	sub	#32,d0		 	; subtract 32
	lsl	#3,d0			; *8
	add	d0,a1			; Pointer to character graphics
	move.l	a2,a3
	move	d3,d4			; colour
	btst	#7,d3
	bne.s	xray	
	moveq	#3,d6			; 4 bit planes
bitlp	roxr	#1,d4
	bcc.s	clear
	move.b	(a1)+,(a3)		; print character on one bit plane
	move.b	(a1)+,160(a3)
	move.b	(a1)+,320(a3)
	move.b	(a1)+,480(a3)
	move.b	(a1)+,640(a3)
	move.b	(a1)+,800(a3)
	move.b	(a1)+,960(a3)
	move.b	(a1),1120(a3)
	subq	#7,a1
nxtbit	addq	#2,a3			; next bit plane
	dbf	d6,bitlp
	add	d5,a2			; increase screen address
	swap	d5			; swap screen increase (1<->7)
	move.l	(a7)+,a1
	dbf	d7,schar		; next character
	movem.l	(a7)+,d0-7/a0-6
	rts
clear	clr.b	(a3)			; if not printing, then clear on
	clr.b	160(a3)			; one bit plane
	clr.b	320(a3)
	clr.b	480(a3)
	clr.b	640(a3)
	clr.b	800(a3)
	clr.b	960(a3)
	clr.b	1120(a3)
	bra.s	nxtbit

xray	moveq	#3,d6			; four bit planes
.blp	roxr	#1,d4			; get one bit of colour
	bcc.s	.clear			; clear this plane
	move.b	(a1)+,d0		; merge on this plane
	or.b	d0,(a3)
	move.b	(a1)+,d0
	or.b	d0,160(a3)
	move.b	(a1)+,d0
	or.b	d0,320(a3)
	move.b	(a1)+,d0
	or.b	d0,480(a3)
	move.b	(a1)+,d0
	or.b	d0,640(a3)
	move.b	(a1)+,d0
	or.b	d0,800(a3)
	move.b	(a1)+,d0
	or.b	d0,960(a3)
	move.b	(a1),d0
	or.b	d0,1120(a3)
	subq	#7,a1
.nxt	addq	#2,a3			; next bit plane
	dbf	d6,.blp
	add	d5,a2	
	swap	d5	
	move.l	(a7)+,a1
	dbf	d7,schar
	movem.l	(a7)+,d0-7/a0-6
	rts
.clear	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,160(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,320(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,480(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,640(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,800(a3)
	move.b	(a1)+,d0
	not.b	d0
	and.b	d0,960(a3)
	move.b	(a1),d0
	not.b	d0
	and.b	d0,1120(a3)
	subq	#7,a1
	bra.s	.nxt

;
; 16 colour font routines
;
cchar	move.l	a1,-(a7)
	moveq	#0,d0
	move.b	(a0)+,d0	
	sub	#32,d0		
	lsl	#5,d0		
	add	d0,a1		
	move.l	a2,a3
	btst	#7,d3
	bne.s	.cxray	
	moveq	#7,d6
.blp	move.l	(a1)+,d0	; get all 4 bitplanes
	movep.l	d0,(a3)		; use movep.l to print 4 planes in one go !
	lea	160(a3),a3	; next screen line
	dbf	d6,.blp
.nxt	add	d5,a2		; add increase
	swap	d5		; swap increase
	move.l	(a7)+,a1
	dbf	d7,cchar	
	movem.l	(a7)+,d0-7/a0-6
	rts

.cxray	swap	d3			; put d3 out of harms way
	moveq	#7,d6
.clp	move.b	(a1)+,d0
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	move.b	(a1)+,d3
	move.b	d0,d4			; create mask from 4 planes
	or.b	d1,d4
	or.b	d2,d4
	or.b	d3,d4
	not.b	d4			; invert it
	and.b	d4,(a3)			; 'punch' hole in screen
	or.b	d0,(a3)			; 'merge' graphics into hole
	and.b	d4,2(a3)		; bitplane 2
	or.b	d1,2(a3)
	and.b	d4,4(a3)		; bitplane 3
	or.b	d2,4(a3)
	and.b	d4,6(a3)		; bitplane 4
	or.b	d3,6(a3)
	lea	160(a3),a3		; next screen line
	dbf	d6,.clp
	swap	d3			; retrieve d3 from high word
	bra.s	.nxt
	