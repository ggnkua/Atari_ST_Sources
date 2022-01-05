;	SECTION CSECT

	xdef	rlsp_display_fast_sprite
	xdef	rlsp_set_screen_width

;	SECTION TEXT
	TEXT

rlsp_set_screen_width:
	move.l	d0,-(a7)
	move.l	8(a7),d0
	move.w	d0,rlsp_poke1+2
	add.w	d0,d0
	move.w	d0,rlsp_poke2+2
	move.l	(a7)+,d0
	rts	


rlsp_display_fast_sprite:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	16*4(a7),a0
	move.l	(a0)+,d0		;x
	move.l	(a0)+,d1		;y
	move.l	(a0)+,a1

	lea	(a1,d0.w*2),a1
rlsp_poke2:
	mulu.w	#640,d1
	add.l	d1,a1

	move.l	(a0)+,d1		;frame
	move.l	(a0)+,d2		;line
	add.w	#13,d2
	move.l	(a0)+,a0		;sprite

rlsp_poke1:
	move.l	#320,d0
	sub.w	2(a0),d0
	add.w	d0,d0
	
	move.l	6(a0,d1.w*4),a0		;get to frame
	bsr.s	show_fast_sprite
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

show_fast_sprite:
	move.l	(a0,d2.w*4),-(a7)
	movem.l	(a0),d1-d7/a0/a2-a6
	rts

	END