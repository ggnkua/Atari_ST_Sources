* STOS spritesystem
* pass
* 	a0 = logbase
* 	a1 = pointer to sprite struct
* 	a6 = pointer to y-table
* internal
*	a2 = scr add of sprite
*	a3 = sprite/mask data

	move.l	(a1),d0		;get x-coord
	move.l	d0,d1
	move.l	8(a1),a3	;get sprite data pointer

	andi.w	#$0f,d0		;work out offset into spr data
	add.w	d0,d0
	lsl.w	#8,d0
	lea	0(a3,d0.w),a3	;set a3 to source

	andi.w	#$fff0,d1
	lsr.w	#1,d1
	lea	0(a0,d1.w),a2	;set a2 to destination scr add (no y)

	move.l	4(a1),d0	;get y-coord
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a6,d0.w),d1	;look up y-coord in bytes
	lea	0(a2,d1.w),a2	;set a2 to final destination scr add

	REPT 16
	movem.l	(a2),d0-d3
	movem.l (a3)+,d4-d7
	and.l	d4,d0
	and.l	d5,d1
	and.l	d6,d2
	and.l	d7,d3
	movem.l	(a3)+,d4-d7
	or.l	d4,d0
	or.l	d5,d1
	or.l	d6,d2
	or.l	d7,d3
	movem.l	d0-d3,(a2)

	lea	160(a2),a2
	ENDR

	rts