	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	PEA	DEMO(PC)
	MOVE.W	#38,-(SP)
	TRAP	#14
	LEA	6(SP),SP
	CLR.W	-(SP)
	TRAP	#1


DEMO
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_colors

	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	Routine_Conversion

LOOPI	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	move.l	log,a0
	move.w	#99,d1
suce1	move.w	#8,d0
suce2	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra	d0,suce2
	lea	160-9*8(a0),a0
	dbra	d1,suce1

	bsr	rotation

	move.l	log,a1
	move.l	phys,a0
	exg.l	a0,a1
	move.l	a1,log
	move.l	a0,phys
	BSR	SET_SCREEN


loopi2	cmpi.b	#$39,$fffffc02.w
	bne	loopi

_end	movem.l	save_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w

	RTS

SET_SCREEN
	move.l	a0,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	RTS

log	dc.l	$1f0000
phys	dc.l	$1f8000
nbr_pts	set	96

angle	dc.w	-4
Rotation
	move.w	angle,d4
	addq.w	#4,d4
	cmp.w	#90*2,d4		114*2
	blt.s	sodomize
;	lea	4(sp),sp
;	bra	_end
	moveq	#0,d4
sodomize
	move.w	d4,angle
	lea	buffer,a3
	lea	Cos_tab(pc),a5
	lea	Sin_tab(pc),a6
	lea	points,a4
	move.w	#nbr_pts-1,d7
pts	move.w	(a4)+,d0		xe
	move.w	(a4)+,d1		ze
	muls	(a5,d4.w),d0
	muls	(a6,d4.w),d1
	add.l	d1,d0
	moveq	#9,d2
	lsr.l	d2,d0
	add.w	#72,d0
	move.w	d0,d1
	lsr.w	#1,d0
	and.w	#$f8,d0
	move.l	log,a0
	not.w	d1
	and.w	#15,d1
	moveq	#0,d2
	bset	d1,d2
	move.w	#99,d6
ln	move.b	(a3)+,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	list_pixels(pc),a2
	move.l	(a2,d5.w),a2
	jsr	(a2)
	lea	160(a0),a0
	dbra	d6,ln
	dbra	d7,pts
	lea	buffer,a3
	move.w	#nbr_pts-1,d7
pts2	move.w	(a4)+,d0		xe
	move.w	(a4)+,d1		ze
	muls	(a5,d4.w),d0
	muls	(a6,d4.w),d1
	add.l	d1,d0
	moveq	#9,d2
	lsr.l	d2,d0
	add.w	#72,d0
	move.w	d0,d1
	lsr.w	#1,d0
	and.w	#$f8,d0
	move.l	log,a0
	not.w	d1
	and.w	#15,d1
	moveq	#0,d2
	bset	d1,d2
	move.w	#99,d6
ln2	move.b	(a3)+,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	list_pixels(pc),a2
	move.l	(a2,d5.w),a2
	jsr	(a2)
	lea	160(a0),a0
	dbra	d6,ln2
	dbra	d7,pts2

	rts

list_pixels
	dc.l	coul0
	dc.l	coul1
	dc.l	coul2
	dc.l	coul3
	dc.l	coul4
	dc.l	coul5
	dc.l	coul6
	dc.l	coul7
	dc.l	coul8
	dc.l	coul9
	dc.l	coul10
	dc.l	coul11
	dc.l	coul12
	dc.l	coul13
	dc.l	coul14
	dc.l	coul15

coul0	not.w	d2
	and.w	d2,(a0,d0.w)
	and.w	d2,2(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul1	or.w	d2,(a0,d0.w)
	not.w	d2
	and.w	d2,2(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul2	or.w	d2,2(a0,d0.w)
	not.w	d2
	and.w	d2,(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul3	or.w	d2,(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	not.w	d2
	and.w	d2,4(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul4	or.w	d2,4(a0,d0.w)
	not.w	d2
	and.w	d2,0(a0,d0.w)
	and.w	d2,2(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul5	or.w	d2,4(a0,d0.w)
	or.w	d2,0(a0,d0.w)
	not.w	d2
	and.w	d2,2(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul6	or.w	d2,4(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	not.w	d2
	and.w	d2,0(a0,d0.w)
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul7	or.w	d2,4(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	or.w	d2,(a0,d0.w)
	not.w	d2
	and.w	d2,6(a0,d0.w)
	not.w	d2
	rts
coul8	or.w	d2,6(a0,d0.w)
	not.w	d2
	and.w	d2,(a0,d0.w)
	and.w	d2,2(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	not.w	d2
	rts
coul9	or.w	d2,6(a0,d0.w)
	or.w	d2,(a0,d0.w)
	not.w	d2
	and.w	d2,2(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	not.w	d2
	rts
coul10	or.w	d2,6(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	not.w	d2
	and.w	d2,0(a0,d0.w)
	and.w	d2,4(a0,d0.w)
	not.w	d2
	rts
coul11	or.w	d2,6(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	or.w	d2,(a0,d0.w)
	not.w	d2
	and.w	d2,4(a0,d0.w)
	not.w	d2
	rts
coul12	or.w	d2,6(a0,d0.w)
	or.w	d2,4(a0,d0.w)
	not.w	d2
	and.w	d2,(a0,d0.w)
	and.w	d2,2(a0,d0.w)
	not.w	d2
	rts
coul13	or.w	d2,6(a0,d0.w)
	or.w	d2,(a0,d0.w)
	or.w	d2,4(a0,d0.w)
	not.w	d2
	and.w	d2,4(a0,d0.w)
	not.w	d2
	rts
coul14	or.w	d2,6(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	or.w	d2,4(a0,d0.w)
	not.w	d2
	and.w	d2,(a0,d0.w)
	not.w	d2
	rts
coul15	or.w	d2,6(a0,d0.w)
	or.w	d2,2(a0,d0.w)
	or.w	d2,4(a0,d0.w)
	or.w	d2,0(a0,d0.w)
	rts


affiche_pts
	lea	buffer,a0
	lea	$1f8000,a1

	move.w	#100-1,d7
boucle4
	move.l	a0,a2
	lea	1(a0),a0

	move.w	#6-1,d6
boucle3
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
a	set	0
	rept	16
 	moveq	#0,d0
	moveq	#0,d5
	move.b	a*100(a2),d0
	move.b	(a6,d0.w),d5
	lsr	d5
	addx	d1,d1
	lsr	d5
	addx	d2,d2
	lsr	d5
	addx	d3,d3
	lsr	d5
	addx	d4,d4
a	set	a+1
	endr
	lea	16*100(a2),a2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	dbra	d6,boucle3
	lea	160-6*8(a1),a1
	dbra	d7,boucle4
	rts

COS_TAB	INCBIN	B:COSIN.DAT
SIN_TAB	EQU	COS_TAB+720

save_colors	ds.l	8

points
z	set	-(nbr_pts/2)
	rept	nbr_pts
	dc.w	-(nbr_pts/2),z
z	set	z+1
	endr
x	set	-(nbr_pts/2)
	rept	nbr_pts
	dc.w	x,nbr_pts/2
x	set	x+1
	endr

Routine_Conversion

	lea	buffer,a6
	lea	picture+34+48+160*20,a1

	move.w	#100-1,d0
Boucle1
	move.l	a6,a5
	lea	1(a6),a6
	move.w	#6-1,d7
boucle2	
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6

	move.w	(a1)+,d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	(a1)+,d4

b	set	0
	rept	16
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d1,d1
	addx.w	d6,d6
	and.w	#$f,d6
	move.b	d6,b*100(a5)
b	set	b+1
	endr
	lea	16*100(a5),a5
	dbra	d7,boucle2
	lea	160-6*8(a1),a1
	dbra	d0,boucle1

	rts

picture	incbin	b:kity.pi1

buffer	ds.b	96*200
rubber_anim
	end
