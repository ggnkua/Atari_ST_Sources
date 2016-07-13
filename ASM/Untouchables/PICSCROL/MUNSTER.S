
; Strange piccy draw routine(s) by Tony -B- 1990
; Main idea from The Munsters!!



	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstk
	
	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	#pic+2,$45a.w
	bsr	munster_draw

scan:	stop	#$2300
	cmp.b	#57,$fffffc02.w
	bne.s	scan

	move.l	#gempal,$45a.w
	
	move.l	oldstk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1


*---------
munster_draw:
	lea	pic+34(pc),a0
	move.l	$44e.w,a1
	move	#32000,d3

again:	moveq	#1,d1
	lea	(a0,d3.w),a3
	lea	(a1,d3.w),a4
move:	move	d1,d2

repeat	rept	40		;try 20 (needs fixing!)
	move.l	-(a3),-(a4)
	endr
	
	cmpa.l	a4,a1
	beq.s	vsync
	
	subq	#1,d2		; try 2 here...
	beq.s	nope
	lea	160(a3),a3	; try a -160 here & 19 above
	bra.s	repeat
	
nope:	addq	#1,d1		; speed (try 2..!!)
	bra.s	move

vsync:	move	$468.w,d0
.vs:	cmp	$468.w,d0
	beq.s	.vs
	
	sub	#160,d3		; next line (zoom...try 320!)
	bne.s	again
	rts


*---------
	data

oldstk:	dc.l	0
gempal:	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000
	
pic:	incbin	a:\picture\*.pi1
