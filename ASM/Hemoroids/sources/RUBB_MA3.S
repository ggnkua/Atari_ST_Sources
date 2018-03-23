;
;Mapped Jelly Vector!
;
;Coded by Jace/Hemoroids!
;
buffer_anim	equ	$1f0000-45*72*100-256*5
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

	move.l	phys,a0
	move.l	log,a1
	move.w	#32000/4-1,d0
bite	move.l	#0,(a0)+
	move.l	#0,(a1)+	
	dbra	d0,bite

	bsr	Routine_Conversion

LOOPI	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	bsr	efface_nana
	bsr	rotation

	move.l	log,a0
	move.l	pt_buffer,a2
	add.l	#72,pt_buffer
rec	set	0
lg	set	0
	rept	100
	movem.l	lg(a0),d0-d7/a1
	movem.l	d0-d7/a1,(a2)
	movem.l	lg+36(a0),d0-d7/a1
	movem.l	d0-d7/a1,36(a2)
	lea	72*45(a2),a2
lg	set	lg+160
	endr
	
	move.l	log,a1
	move.l	phys,a0
	exg.l	a0,a1
	move.l	a1,log
	move.l	a0,phys
	BSR	SET_SCREEN

	
loopi2	cmpi.b	#$39,$fffffc02.w
	bne	loopi

Exit_precalc
	move.l	#0,pt_buffer
	move.w	#180,cmpt

tourne	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	bsr	efface_jelly

;	move.w	#$5,$ffff8240.w
	move.l	pt_jelly,a5
	move.l	log,a4
	move.l	pt_buffer,d0
	lea	buffer_anim,a0
rec	set	0
lg	set	0
	rept	100
	move.w	(a5)+,d1
	movem.l	(a0,d0.w),d2-d7/a1-a3
	movem.l	d2-d7/a1-a3,(a4,d1.w)
	movem.l	36(a0,d0.w),d2-d7/a1-a3
	movem.l	d2-d7/a1-a3,36(a4,d1.w)
	lea	72*45(a0),a0
;	add.l	#72,d0
	cmp.l	#72*45,d0
	blt.s	*+8
	move.l	#0,d0
;jump
	endr
	move.l	pt_buffer,d0
	add.l	#72,d0
	cmp.l	#72*45,d0
	blt.s	notb
	move.l	#0,d0
notb	move.l	d0,pt_buffer

	cmp.l	#end_jelly,a5
	blt.s	nj
	lea	jelly,a5
nj	move.l	a5,pt_jelly
;	move.w	#0,$ffff8240.w

	move.l	log,a1
	move.l	phys,a0
	exg.l	a0,a1
	move.l	a1,log
	move.l	a0,phys
	BSR	SET_SCREEN

	subq	#1,cmpt
	bne	tourne

	move.w	#180*3,cmpt
	move.l	pt_buffer,d0
	divu	#72,d0
	add.w	d0,d0
	move.l	pt_tnk,d1
	add.w	d0,d1
	
rubber	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	bsr	efface_jelly

;	move.w	#$700,$ffff8240.w
	bsr	calcul_distort

;	move.w	#$5,$ffff8240.w
	lea	distort,a6
	move.l	pt_jelly,a5
	move.l	log,a4
	move.l	pt_buffer,d0
	lea	buffer_anim,a0
rec	set	0
lg	set	0
	rept	100
	move.w	(a6)+,d0
	move.w	(a5)+,d1
	movem.l	(a0,d0.w),d2-d7/a1-a3
	movem.l	d2-d7/a1-a3,(a4,d1.w)
	movem.l	36(a0,d0.w),d2-d7/a1-a3
	movem.l	d2-d7/a1-a3,36(a4,d1.w)
	lea	72*45(a0),a0
	endr

	move.l	pt_buffer,d0
	add.l	#72,d0
	cmp.l	#72*45,d0
	blt.s	notb2
	move.l	#0,d0
notb2	move.l	d0,pt_buffer

	cmp.l	#end_jelly,a5
	blt.s	nj2
	lea	jelly,a5
nj2	move.l	a5,pt_jelly


;	move.w	#0,$ffff8240.w

	move.l	log,a1
	move.l	phys,a0
	exg.l	a0,a1
	move.l	a1,log
	move.l	a0,phys
	BSR	SET_SCREEN


	cmpi.b	#$39,$fffffc02.w
	beq	_end
	subq	#1,cmpt
	bne	rubber


_end	movem.l	save_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$777,$ffff8240.w
	move.w	#$0,$ffff8246.w
	RTS

SET_SCREEN
	move.l	a0,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	RTS

log	dc.l	$1f0000
phys	dc.l	$1f8000

calcul_distort
	lea	distort,a4
	lea	sin_tab,a6
	move.l	pt_tnk,a5
	move.w	(a5)+,d5
	cmp.l	#end_tnk,a5
	blt.s	tnk2
	lea	tourniket,a5
tnk2	move.l	a5,pt_tnk
	move.w	angle2,d1
	move.w	#9,d6
	move.w	#99,d7
a_line	move.w	d5,d2
	muls	(a6,d1.w),d2
	bpl.s	pos2
	neg.l	d2
pos2	lsr.l	d6,d2
	cmp.w	#45,d2
	blt.s	fock
	sub.w	#45,d2
fock	mulu	#72,d2
	move.w	d2,(a4)+	
	addq	#4,d1
	cmp.w	#720,d1
	blt.s	prout2
	sub.w	#720,d1
prout2	dbra	d7,a_line

 	move.w	angle2,d1
inc	add.w	#4,d1
	cmp.w	#720,d1
	blt.s	prout1
	sub.w	#720,d1
;	addq	#2,inc+2
prout1	move.w	d1,angle2

	rts
pt_tnk	dc.l	tourniket
tourniket
tnk	set	0
	dcb.w	5,tnk
	rept	90
	dc.w	tnk
tnk	set	tnk+1
	endr
	dcb.w	5,tnk
	rept	90
	dc.w	tnk
tnk	set	tnk-1
	endr
end_tnk

angle1	dc.w	0
angle2	dc.w	90*2
distort	dcb.w	110,0
efface_jelly
	move.l	log,a0
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a1
	move.l	d1,a2
lgn	set	0
	rept	200
	movem.l	d1-d7/a1/a2,lgn(a0)
	movem.l	d1-d7/a1/a2,lgn+36(a0)
lgn	set	lgn+160
	endr
	rts

efface_nana
	move.l	log,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a1
en	set	0
	rept	100
	movem.l	d0-d7/a1,en(a0)
	movem.l	d0-d7/a1,en+36(a0)
en	set	en+160
	endr
	rts

deformation
defm	set	0
	rept	45
	dc.l	buffer_anim+defm
defm	set	defm+72
	endr
defm	set	0
	rept	45
	dc.l	buffer_anim+defm
defm	set	defm+72
	endr
defm	set	0
	rept	45
	dc.l	buffer_anim+defm
defm	set	defm+72
	endr
defm	set	0
	rept	45
	dc.l	buffer_anim+defm
defm	set	defm+72
	endr



nbr_pts	set	96
cmpt	dc.w	90
pt_buffer	dc.l	buffer_anim
angle	dc.w	-4
Rotation
	move.w	angle,d4
	addq.w	#4,d4
	cmp.w	#90*2,d4		114*2
	blt.s	sodomize
	lea	4(sp),sp
	bra	Exit_precalc
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
pt_jelly	dc.l	jelly
jelly	incbin	b:trajell2.dat
	even
end_jelly

picture	incbin	b:kity.pi1

buffer	ds.b	96*200
	end
	move.l	pt_eff+4,a0
	move.l	pt_eff,pt_eff+4
	move.l	a0,pt_eff
