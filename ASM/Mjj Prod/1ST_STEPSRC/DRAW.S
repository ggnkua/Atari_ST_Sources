;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; DRAW.S : soooooooo sloooooooow primitive drawing :)
;  need	MATH.S
;		TABLES.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; copy_plan : copy bitplan from screen
;	arg :	d0 = count
;			d1 = height
;			d2 = dst padding
;			a0 = src (screen buffer)
;			a1 = dst
;-----------------------------------------------------------------------------

copy_plan:
	movem.l		d0-d4/a0-a2,	-(sp)
	move.l		d2,				d4
	subq.l		#2,				d4
copy_plan_0:
	move.l		a0,				a2			; a2 = src
	move.l		d0,				d3			; d3 = count
copy_plan_1:
	move.w		(a2),			(a1)+
	addq.l		#8,				a2
	dbra		d3,copy_plan_1
	lea			160(a0),		a0
	adda.l		d4,				a1
	dbra		d1,copy_plan_0
	movem.l		(sp)+,			d0-d4/a0-a2
	rts

;-----------------------------------------------------------------------------
; store_plan : move bitplan from screen
;	arg :	d0 = count
;			d1 = height
;			d2 = dst padding
;			a0 = src (screen buffer)
;			a1 = dst
;-----------------------------------------------------------------------------

store_plan:
	movem.l		d0-d4/a0-a2,	-(sp)
	move.l		d2,				d4
	subq.l		#2,				d4
store_plan_0:
	move.l		a0,				a2			; a2 = src
	move.l		d0,				d3			; d3 = count
store_plan_1:
	move.w		(a2),			(a1)+
	clr.w		(a2)
	addq.l		#8,				a2
	dbra		d3,store_plan_1
	lea			160(a0),		a0
	adda.l		d4,				a1
	dbra		d1,store_plan_0
	movem.l		(sp)+,			d0-d4/a0-a2
	rts

;-----------------------------------------------------------------------------
; draw_disk : draw a disk
;	arg :	d0 = width/2
;			d1 = height/2
;			a0 = dest (screen buffer)
;-----------------------------------------------------------------------------

draw_disk:
	movem.l		d2-d7/a0-a6,	-(sp)
	lea			$FFFF8A20.W,	a6
	moveq		#8,				d2
	moveq		#-1,			d3
	move.w		d2,				$00(a6)		; source X increment
	move.w		d2,				$02(a6)		; source Y increment
	move.l		a0,				$04(a6)		; source address
	move.w		d3,				$0A(a6)		; mask 2
	move.w		d2,				$0E(a6)		; destination X increment
	move.w		d2,				$10(a6)		; destination Y increment
	move.w		#$020F,			$1A(a6)		; mode
	lea			disk_table,		a1
	lea			xoff8_table,	a2
	lea			xlmsk_table,	a3
	lea			xrmsk_table,	a4
	move.w		d1,				d6
	add.w		d1,				d6
	subq.w		#1,				d6
	mulu.w		#160,			d6
	move.l		d1,				d2			; d2 = y
	subq.w		#1,				d2
	move.l		d2,				d7
	lsl.w		#8,				d7
draw_disk_0:
	move.l		d7,				d3
	divu.w		d1,				d3
	add.w		d3,				d3
	move.w		0(a1,d3.w),		d5
	mulu.w		d0,				d5
	swap		d5							; d5 = x
	btst		#31,			d5
	beq.s		draw_disk_1
	addq.w		#1,				d5
draw_disk_1:
	move.w		d0,				d4
	sub.w		d5,				d4			; d4 = x1
	add.w		d0,				d5			; d5 = x2
	add.w		d4,				d4
	add.w		d5,				d5
	move.w		0(a3,d4.w),		$08(a6)		; start mask
	move.w		0(a4,d5.w),		$0C(a6)		; end mask
	move.w		0(a2,d4.w),		d3			; d3 = start off
	move.w		0(a2,d5.w),		d4			; d4 = end off
	sub.w		d3,				d4
	bne.s		draw_disk_2
	move.w		$0C(a6),		d5			; mix masks
	and.w		d5,				$08(a6)
draw_disk_2:
	lsr.w		#3,				d4
	addq.w		#1,				d4			; d4 = size
	lea			0(a0,d3.w),		a5			; a5 = start ptr
	move.l		a5,				$12(a6)		; destination address
	move.w		d4,				$16(a6)		; surface width
	move.w		#1,				$18(a6)		; surface height
	move.w		#$C000,			$1C(a6)		; start
	adda.l		d6,				a5
	move.l		a5,				$12(a6)		; destination address
	move.w		d4,				$16(a6)		; surface width
	move.w		#1,				$18(a6)		; surface height
	move.w		#$C000,			$1C(a6)		; start
	lea			160(a0),		a0			; next line
	subi.w		#320,			d6
	subi.w		#256,			d7
	dbra		d2,draw_disk_0
	movem.l		(sp)+,			d2-d7/a0-a6
	rts


;=============================================================================
;				END OF FILE
;=============================================================================

