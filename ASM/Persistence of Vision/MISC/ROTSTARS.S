; CRAP 'n' UGLY rotating starfield.
; Coded this in about 5 mins. as a sort of challenge at college!!!
; Thought some beginners out there might want it!!!!
; Pooer code by Tony B of the Untouchables
; DevPac v2.25, tabs set to 10



diskversion	=	-1


numstars		=	200


	opt	o+

	IIF	diskversion	opt	x+



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp
	
	move.l	sp,oldstk+2
	lea	mystack(pc),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	movem.l	starpal(pc),d0-d3
	movem.l	d0-d3,$ffff8240.w
	
	moveq	#$12,d1
	bsr	ikbdsend
	
	clr.b	$484.w
	
	move.b	$ffff8260.w,oldres+3
	bsr	vsync
	clr.b	$ffff8260.w	
	move.b	#2,$ffff820a.w	
	
	move.l	#screen+256,d0
	clr.b	d0
	move.l	d0,scr1
	move.l	d0,a0
	add.l	#32768,d0
	move.l	d0,scr2
	bsr	cls_scr
	move.l	scr2,a0
	bsr	cls_scr
	lsr	#8,d0
	move.l	d0,$ffff8200.w

*------------------- init stars

	move	#numstars-1,d7
	move	d7,d6
	move	d7,d5
	
	lea	r,a0		;radius
	moveq	#90,d1
gen_r
	bsr	random
	move	d0,(a0)+
	dbf	d7,gen_r

	lea	a,a0		;angle
	move	#360,d1
gen_a
	bsr	random
	move	d0,(a0)+
	dbf	d6,gen_a
	
	lea	s,a0		;speed
	moveq	#4,d1
gen_s
	bsr	random
	tst	d0
	bne.s	.ok
	addq	#1,d0
.ok	move	d0,(a0)+
	dbf	d5,gen_s


*------------------- mainloop
scan
	bsr	vsync
	
	lea	oldstars1,a0
	bsr	wipestars
	
	lea	oldstars1,a5
	move.l	scr1,scr+2
	bsr	plotstar
	
	move.l	scr1,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	bsr	vsync
	
	lea	oldstars2,a0
	bsr	wipestars
	
	lea	oldstars2,a5
	move.l	scr2,scr+2
	bsr	plotstar

	move.l	scr2,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	cmp.b	#57,$fffffc02.w
	bne.s	scan


*-------------------
	moveq	#8,d1
	bsr	ikbdsend
	
	move.b	#-1,$484.w
	
	clr.b	$ffff820a.w
	bsr.s	vsync
oldres	move.b	#0,$ffff8260.w
	move.b	$44f.w,$ffff8201.w
	move.b	$450.w,$ffff8203.w
	move.b	#2,$ffff820a.w

	movem.l	gempal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

oldstk	lea	0.l,sp

	ifne	diskversion
	clr	-(sp)
	move	#11,-(sp)
	trap	#13		;ALT-X cure!
	addq.l	#4,sp
	endc

	clr	-(sp)
	trap	#1


*------------------- random number generator!
; d1 .. upper limit
random
	moveq	#0,d0
	move	seed(pc),d0
	mulu	#9377,d0
	add	#9439,d0
	bclr	#15,d0
	move	d0,seed
	ext.l	d0
	divu	d1,d0
	swap	d0
	rts

seed	ds.w	1


*-------------------
vsync
	move	$468.w,d0
.vsync
	cmp	$468.w,d0
	beq.s	.vsync
	rts


*------------------- screen in a0
cls_scr
	move	#7999,d3
	moveq	#0,d2
.cls_scr
	move.l	d2,(a0)+
	dbf	d3,.cls_scr
	rts


*-------------------
black_out
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w
	rts


*------------------- byte to send in d1
ikbdsend
	lea	$fffffc00.w,a0
kwait
	move.b	(a0),d2
	btst	#1,d2
	beq.s	kwait
	move.b	d1,2(a0)
	rts


*-------------------
; a0 .. old star buff
wipestars
	move	#numstars-1,d7
	moveq	#0,d0
cls_stars
	move.l	(a0)+,a1
	move	d0,(a1)
	dbf	d7,cls_stars
	rts


*-------------------
; a5 .. old stars buff
; scr+2 .. scr addr
plotstar
	lea	r,a0		;radius
	lea	a,a1		;angle
	lea	s,a2		;speed
	lea	sintab,a3
	lea	sintab+180,a4
	
	moveq	#0,d7		;I
sloop
	move	d7,d3		;I
	add	d3,d3
	moveq	#0,d2
	move	(a0,d3.w),d1	;R
	move	(a1,d3.w),d2	;A
	add	d7,d2		;A+I
	add	t,d2		;A+T
	divu	#360,d2		;A mod 360 degrees
	swap	d2		;A
	
	move	d2,d4		;A
	add	d4,d4
	moveq	#0,d5
	move	(a3,d4.w),d5	;Sine A
	muls	d1,d5		;R*A
	asl.l	#2,d5		;/16384
	swap	d5
	add	#160,d5

	move	d2,d4		;A
	add	d4,d4
	moveq	#0,d6
	move	(a4,d4.w),d6	;Cosine A
	muls	d1,d6		;R*A
	asl.l	#2,d6		;/16384
	swap	d6
	add	#100,d6
	
	tst	d5
	blt.s	nok_xy
	tst	d6
	blt.s	nok_xy
	cmp	#319,d5
	bgt.s	nok_xy
	cmp	#199,d6
	bgt.s	nok_xy
	bra.s	ok_xy
nok_xy

	move	d1,-(sp)		;R
		
	move	d7,d3		;I
	add	d3,d3
	move	#8,(a0,d3.w)	;R(I)

	move	d7,d3		;I
	add	d3,d3
	move	#360,d1
	bsr	random
	move	d0,(a1,d3.w)	;A(I)
	
	move	d7,d3		;I
	add	d3,d3
	moveq	#4,d1
	bsr	random
	tst	d0
	bne.s	okt
	addq	#1,d0
okt	move	d0,(a2,d3.w)	;S(I)

	move	(sp)+,d1		;R
	
	bra.s	cunt

ok_xy

scr	lea	0.l,a6
	move	d5,d4		;X
	and	#$fff0,d5
	lsr	d5
	add	d5,a6		;add X
	add	d6,d6
	add	mulu160(pc,d6.w),a6
	
	lsr	#4,d1		;depth (HAHA!!)
	and	#15,d1
	add	d1,d1
	add	piss(pc,d1.w),a6
	
	move.l	a6,(a5)+
	
	not	d4
	and	#$f,d4		;get BIT
	clr	d3
	bset	d4,d3
	or	d3,(a6)
	
	move	d7,d3		;I
	add	d3,d3
	move	(a2,d3.w),d5	;S(I)
	add	d5,(a0,d3.w)	;R(I)=R(I)+S(I)
cunt
	addq	#1,d7
	cmp	#numstars,d7
	bne	sloop
	
	addq	#2,t		;rotate factor
	rts

piss	dc.w	0,0
	dc.w	2,2
	dc.w	4,4
	dc.w	4,4
	dc.w	4,4
	dc.w	4,4
	dc.w	4,4
	dc.w	4,4
mulu160
i	set	0
	rept	200
	dc.w	i
i	set	i+160
	endr

*------------------- shell data
gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

starpal	dc.w	$000,$222,$444,$444,$666,$666,$666,$666

*------------------- bss
scr1	ds.l	1
scr2	ds.l	1

*------------------- sin of 0-360 degrees *16384
; additional 90 degrees of data for cos
sintab	dc.w	0,286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382,16383
	dc.w	16382,16374,16362,16344,16322,16294,16262,16225
	dc.w	16182
	dc.w	16135,16083,16026,15964,15897,15826,15749,15668
	dc.w	15582,15491,15396,15296,15191,15082,14962,14849
	dc.w	14726,14598,14466,14330,14189,14044,13894,13741
	dc.w	13583,13421,13255,13085,12911,12733,12551,12365
	dc.w	12176,11982,11786,11585,11381,11174,10963,10749
	dc.w	10531,10311,10087,9860,9630,9397,9162,8923
	dc.w	8682,8438,8192,7943,7692,7438,7182,6924
	dc.w	6664,6402,6138,5872,5604,5334,5063,4790
	dc.w	4516,4240,3964,3686,3406,3126,2845,2563
	dc.w	2280,1997,1713,1428,1143,857,572,286,0
	dc.w	-286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w	-2563,-2845,-3126,-3406,-3686,-3694,-4240,-4516
	dc.w	-4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w	-6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
	dc.w	-8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w	-10749,-10963,-11174,-11381,-11585,-11786,-11982
	dc.w	-12176
	dc.w	-12365,-12551,-12733,-12911,-13085,-13255,-13421
	dc.w	-13583
	dc.w	-13741,-13894,-14044,-14189,-14330,-14466,-14598
	dc.w	-14726
	dc.w	-14849,-14962,-15082,-15191,-15296,-15396,-15491
	dc.w	-15582
	dc.w	-15668,-15749,-15826,-15897,-15964,-16026,-16083
	dc.w	-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362
	dc.w	-16374,-16382,-16383
	dc.w	-16382,-16374,-16362,-16344,-16322,-16294,-16262
	dc.w	-16225,-16182
	dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749
	dc.w	-15668
	dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14962
	dc.w	-14849
	dc.w	-14726,-14598,-14466,-14330,-14189,-14044,-13894
	dc.w	-13741
	dc.w	-13583,-13421,-13255,-13085,-12911,-12733,-12551
	dc.w	-12365
	dc.w	-12176,-11982,-11786,-11585,-11381,-11174,-10963
	dc.w	-10749
	dc.w	-10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w	-8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w	-6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w	-4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w	-2280,-1997,-1713,-1428,-1143,-857,-572,-286
	dc.w	0,286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382


	ds.l	256
mystack

t	ds.w	1

r	ds.w	numstars
a	ds.w	numstars
s	ds.w	numstars

oldstars1	dcb.l	numstars,$f8000
oldstars2	dcb.l	numstars,$f8000

screen
