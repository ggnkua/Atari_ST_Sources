; Realtime sprite scaler.
;
; Doesn't actually print the sprite, merely copies from source to 
; destination and reduces in size as it copies. Sprites shrink
; horizontally inwards towards their center and vertically upwards
; so that the top of the sprite stays where it is. The new height of
; the sprite is returned by the command.
;
; For 16x sprites the scale size is 0-7,
; for 32x sprites the scale size is 0-15 where each size reduces the
; sprite by two pixels horizontally, 0 is 1:1 sizing.
;
; new_height=C:scale%(size,width,height,L:source,L:destination)

scale	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d0-2
	move.l	66(a7),a0
	move.l	70(a7),a1
	cmp	#32,d1
	beq.s	.set32
	lea	here16(pc),a6
	and	#$7,d0		; 16x has 8 sizes
	moveq	#4,d1
	move.l	#10*65536,d7	; 10 in high word
	bra.s	.setok
.set32	lea	here32(pc),a6
	and	#$f,d0		; 32x has 16 sizes
	moveq	#5,d1
	move.l	#20*65536,d7	; 20 in high word
.setok	move.l	a6,a5
	add	d0,d0
	add	d0,d0
	add	d0,a6
	add	2(a6),a5	
	moveq	#0,d5
	move	d2,d5		; old height
	move.l	d5,d4
	mulu	(a6),d4
	lsr	d1,d4		; new height
	move	d5,d6
	move	d5,d7
	lsr	#1,d6
	subq	#1,d7
.lp	add	d4,d6
	cmp	d5,d6
	blt.s	.skip
	jsr	(a5)		; shrink this line
	sub	d5,d6
	dbf	d7,.lp
	moveq	#0,d0
	move	d4,d0
	movem.l	(a7)+,d1-7/a0-6
	rts
.skip	swap	d7
	add	d7,a0		; add increment of 10 or 20
	swap	d7
	dbf	d7,.lp
	moveq	#0,d0
	move	d4,d0		; return new height
	movem.l	(a7)+,d1-7/a0-6
	rts
	
here16	dc.w	16,ashrnk0-here16	; look up table routines
	dc.w	14,ashrnk2-here16	; for 16x sprites
	dc.w	12,ashrnk4-here16
	dc.w	10,ashrnk6-here16
	dc.w	8,ashrnk8-here16
	dc.w	6,ashrnk10-here16
	dc.w	4,ashrnk12-here16
	dc.w	2,ashrnk14-here16

here32	dc.w	32,bshrnk0-here32	; look up table routines
	dc.w	30,bshrnk2-here32	; for 32x sprites
	dc.w	28,bshrnk4-here32
	dc.w	26,bshrnk6-here32
	dc.w	24,bshrnk8-here32
	dc.w	22,bshrnk10-here32
	dc.w	20,bshrnk12-here32
	dc.w	18,bshrnk14-here32
	dc.w	16,bshrnk16-here32
	dc.w	14,bshrnk18-here32
	dc.w	12,bshrnk20-here32
	dc.w	10,bshrnk22-here32
	dc.w	8,bshrnk24-here32
	dc.w	6,bshrnk26-here32
	dc.w	4,bshrnk28-here32
	dc.w	2,bshrnk30-here32

ashrnk0	move.l	(a0)+,(a1)+	; 1:1 size, direct copy
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	rts
ashrnk2	rept	5		; shrink by 2 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%00000011,d2
	and.b	#%11111000,d0
	lsr.b	#1,d0
	or.b	d2,d0
	move.b	d1,d2
	and.b	#%11000000,d2
	and.b	#%00011111,d1
	add.b	d1,d1
	or.b	d2,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts
ashrnk4	rept	5		; shrink by 4 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%11100000,d2
	lsr.b	#1,d2
	move.b	d0,d3
	and.b	#%00001100,d3
	or.b	d3,d2
	lsr.b	#1,d2
	and.b	#%00000001,d0
	or.b	d2,d0
	move.b	d1,d2
	and.b	#%00000111,d2
	add.b	d2,d2
	move.b	d1,d3
	and.b	#%00110000,d3
	or.b	d3,d2
	add.b	d2,d2
	and.b	#%10000000,d1
	or.b	d2,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts
ashrnk6	rept	5		; shrink by 6 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%01100000,d2
	lsr.b	#1,d2
	move.b	d0,d3
	and.b	#%00001100,d3
	or.b	d3,d2
	lsr.b	#1,d2
	and.b	#%00000001,d0
	or.b	d2,d0
	move.b	d1,d2
	and.b	#%00000110,d2
	add.b	d2,d2
	move.b	d1,d3
	and.b	#%00110000,d3
	or.b	d3,d2
	add.b	d2,d2
	and.b	#%10000000,d1
	or.b	d2,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts
ashrnk8	rept	5		; shrink by 8 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%01000000,d2
	lsr.b	#1,d2
	move.b	d0,d3
	and.b	#%00010000,d3
	or.b	d3,d2
	lsr.b	#1,d2
	move.b	d0,d3
	and.b	#%00000100,d3
	or.b	d3,d2
	lsr.b	#1,d2
	and.b	#%00000001,d0
	or.b	d2,d0
	move.b	d1,d2
	and.b	#%00000010,d2
	add.b	d2,d2
	move.b	d1,d3
	and.b	#%00001000,d3
	or.b	d3,d2
	add.b	d2,d2
	move.b	d1,d3
	and.b	#%00100000,d3
	or.b	d3,d2
	add.b	d2,d2
	and.b	#%10000000,d1
	or.b	d2,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts
ashrnk10 rept	5		; shrink by 10 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%00100000,d2
	lsr.b	#1,d2
	move.b	d0,d3
	and.b	#%00001000,d3
	or.b	d3,d2
	lsr.b	#1,d2
	and.b	#%00000010,d0
	or.b	d2,d0
	lsr.b	#1,d0
	
	move.b	d1,d2
	and.b	#%00000100,d2
	add.b	d2,d2
	move.b	d1,d3
	and.b	#%00010000,d3
	or.b	d3,d2
	add.b	d2,d2
	and.b	#%01000000,d1
	or.b	d2,d1
	add.b	d1,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts
	
ashrnk12 rept	5		; shrink by 12 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	d0,d2
	and.b	#%00010000,d2
	lsr.b	#2,d2
	and.b	#%00000010,d0
	or.b	d2,d0
	lsr.b	#1,d0
	move.b	d1,d2
	and.b	#%00001000,d2
	add.b	d2,d2
	add.b	d2,d2
	and.b	#%01000000,d1
	or.b	d2,d1
	add.b	d1,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts

ashrnk14 rept	5		; shrink by 14 pixels horizontally
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	and.b	#%00000100,d0
	lsr.b	#2,d0
	and.b	#%00100000,d1
	add.b	d1,d1
	add.b	d1,d1
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	endr
	rts

bshrnk0	move.l	(a0)+,(a1)+	; 1:1 sizing, direct copy
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts
bshrnk2	rept	5		; shrink by 2 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000011111111,d1
	add	d1,d1
	and	#%1111111000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1111111100000000,d1
	lsr	#1,d1
	and	#%0000000001111111,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts	
bshrnk4	rept	5		; shrink by 4 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000011111,d1
	add	d1,d1
	move	d0,d2
	and	#%0000001111000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1111100000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1111100000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000001111000000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000011111,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts
bshrnk6	rept	5		; shrink by 6 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000001111,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000011100000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000111000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1110000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1111000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000011100000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000001110000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000111,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk8	rept	5		; shrink by 8 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000111,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000110000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000110000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1110000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1110000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000110000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000110000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000111,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk10 rept	5		; shrink by 10 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000011,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000011000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000011000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0001100000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1100000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1100000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0001100000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000001100000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000011000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000011,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk12 rept	5		; shrink by 12 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000011,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1100000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%1100000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000011,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk14 rept	5		; shrink by 14 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000010,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1100000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%0100000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000110000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000011,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk16 rept	5		; shrink by 16 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000010,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000010000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000100000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0010000000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%1000000000000000,d0
	or	d1,d0
	swap	d0
	move	d0,d1
	and	#%0100000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000100000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000010000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000000100,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000000001,d0
	or	d1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk18 rept	5		; shrink by 18 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000100,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000010000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000100000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0001000000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%0100000000000000,d0
	or	d1,d0
	add	d0,d0
	swap	d0
	move	d0,d1
	and	#%0010000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000100000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000010000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000001000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000010,d0
	or	d1,d0
	lsr	#1,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk20 rept	5		; shrink by 20 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000100,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000010000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	add	d1,d1
	add	d1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000100000000000,d2
	or	d2,d1
	add	d1,d1
	and	#%0010000000000000,d0
	or	d1,d0
	add	d0,d0
	add	d0,d0
	swap	d0
	move	d0,d1
	and	#%0010000000000000,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000100000000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	lsr	#2,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000010000,d2
	or	d2,d1
	lsr	#1,d1
	and	#%0000000000000100,d0
	or	d1,d0
	lsr	#2,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk22 rept	5		; shrink by 22 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000000100,d1
	add	d1,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	add	d1,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000100000000,d2
	or	d2,d1
	add	d1,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	add	d1,d1
	add	d1,d1
	and	#%0010000000000000,d0
	or	d1,d0
	add	d0,d0
	add	d0,d0
	swap	d0
	move	d0,d1
	and	#%0010000000000000,d1
	lsr	#2,d1
	move	d0,d2
	and	#%0000010000000000,d2
	or	d2,d1
	lsr	#2,d1
	move	d0,d2
	and	#%0000000010000000,d2
	or	d2,d1
	lsr	#1,d1
	move	d0,d2
	and	#%0000000000100000,d2
	or	d2,d1
	lsr	#2,d1
	and	#%0000000000000100,d0
	or	d1,d0
	lsr	#2,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk24 rept	5		; shrink by 24 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000001000,d1
	add	d1,d1
	add	d1,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	add	d1,d1
	add	d1,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	add	d1,d1
	add	d1,d1
	and	#%0001000000000000,d0
	or	d1,d0
	lsl	#3,d0
	swap	d0
	move	d0,d1
	and	#%0001000000000000,d1
	lsr	#2,d1
	move	d0,d2
	and	#%0000001000000000,d2
	or	d2,d1
	lsr	#2,d1
	move	d0,d2
	and	#%0000000001000000,d2
	or	d2,d1
	lsr	#2,d1
	and	#%0000000000001000,d0
	or	d1,d0
	lsr	#3,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk26 rept	5		; shrink by 26 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000010000,d1
	lsl	#3,d1
	move	d0,d2
	and	#%0000000100000000,d2
	or	d2,d1
	lsl	#3,d1
	and	#%0001000000000000,d0
	or	d1,d0
	lsl	#3,d0
	swap	d0
	move	d0,d1
	and	#%0000100000000000,d1
	lsr	#3,d1
	move	d0,d2
	and	#%0000000010000000,d2
	or	d2,d1
	lsr	#3,d1
	and	#%0000000000001000,d0
	or	d1,d0
	lsr	#3,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk28 rept	5		; shrink by 28 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	move	d0,d1
	and	#%0000000000100000,d1
	lsl	#4,d1
	and	#%0000010000000000,d0
	or	d1,d0
	lsl	#5,d0
	swap	d0
	move	d0,d1
	and	#%0000010000000000,d1
	lsr	#4,d1
	and	#%0000000000100000,d0
	or	d1,d0
	lsr	#5,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts

bshrnk30 rept	5		; shrink by 30 pixels horizontally
	move.l	(a0)+,d0
	ror.l	#8,d0
	and	#%0000000100000000,d0
	lsl	#7,d0
	swap	d0
	and	#%0000000010000000,d0
	lsr	#7,d0
	swap	d0
	rol.l	#8,d0
	move.l	d0,(a1)+
	endr
	rts
