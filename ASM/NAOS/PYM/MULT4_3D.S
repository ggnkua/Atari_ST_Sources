	text
	
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,sv_stack
	
	move.l	$466,d0
vsync	cmp.l	$466,d0
	beq	vsync
	move.b	#0,$ffff8260.w
	
	move.b	#$0,$484

	clr.w	ox
	clr.w	oy
	clr.w	oz
	move.w	#0,vx
	move.w	#0,vy
	move.w	#0,vz
		
	move.l	#$00000222,$ffff8240.w
	move.w	#$333,$ffff8244.w
	move.w	#$555,$ffff8248.w
	move.w	#$777,$ffff8250.w
	
	lea	er_buf,a0
	move.w	#199,d0
clbuf	clr.w	(a0)+
	dbra	d0,clbuf
		
	move.l	#video,d0
	and.l	#$ffffff00,d0
	add.l	#$100,d0
	move.l	d0,act_sc1
	move.l	d0,ad_ecran
	add.l	#32000,d0
	move.l	d0,act_sc2
	
	move.l	ad_ecran,a0
	move.w	#15999,d0
cls	clr.l	(a0)+
	dbra	d0,cls	

	moveq	#$1,d0
	jsr	zic
	
	move.l	ad_ecran,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w
		
	move.l	$70.w,sv_vbl
	move.l	#vbl,$70.w
	
wait	stop	#$2300
	move.b	$fffffc02.w,d0
	cmp.b	#$0f,d0
	bne	tst1
	move.w	#$007,$ffff8240.w
tst1	cmp.b	#$4b,d0
	bne	tst2
	sub.w	#1,vx	
tst2	cmp.b	#$4d,d0
	bne	tst3
	add.w	#1,vx	
tst3	cmp.b	#$48,d0
	bne	tst4
	add.w	#1,vy	
tst4	cmp.b	#$50,d0
	bne	tst5
	sub.w	#1,vy	
tst5	cmp.b	#$4a,d0
	bne	tst6
	add.w	#1,vz		
tst6	cmp.b	#$4e,d0
	bne	spc
	sub.w	#1,vz		
spc	cmp.b	#$39,d0
	bne	wait	

	move.l	sv_vbl,$70.w
	
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	
	move.b	#$ff,$484
	
	move.l	#$07770700,$ffff8240.w
	
	move.l	sv_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	clr.w	-(sp)
	trap	#1

vbl	movem.l	d0-d7/a0-a6,-(sp)
	
	clr.w	$ffff8240.w
	
	jsr	zic+8
	
	move.l	ad_ecran,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w
	
	bsr	erase
	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.l	ad_ecran,a6
	lea	stars,a0
	lea	er_b1,a3
	move.w	ox,d3
	move.w	oy,d4
	move.w	oz,d5
	move.w	vx,d0
	move.w	vy,d1
	move.w	vz,d2
	asr.w	#2,d0
	asr.w	#2,d1
	add.w	d0,d3
	add.w	d1,d4
	add.w	d2,d5
	cmp.w	#-160,d3
	bgt	out1
	add.w	#320,d3
out1	cmp.w	#-100,d4
	bgt	out2
	add.w	#200,d4
out2	cmp.w	#-880,d5
	bgt	out3	
	add.w	#1280,d5
out3	cmp.w	#160,d3
	bmi	out4
	sub.w	#320,d3
out4	cmp.w	#100,d4
	bmi	out5
	sub.w	#200,d4
out5	cmp.w	#400,d5
	bmi	out6	
	sub.w	#1280,d5
out6	move.w	d3,ox
	move.w	d4,oy
	move.w	d5,oz
	move.w	#99,d7
stbcl	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	cmp.w	#-160,d0
	bgt	ou1
	add.w	#320,d0
ou1	cmp.w	#-100,d1
	bgt	ou2
	add.w	#200,d1
ou2	cmp.w	#-880,d2
	bgt	ou3	
	add.w	#1280,d2
ou3	cmp.w	#160,d0
	bmi	ou4
	sub.w	#320,d0
ou4	cmp.w	#100,d1
	bmi	ou5
	sub.w	#200,d1
ou5	cmp.w	#400,d2
	bmi	ou6	
	sub.w	#1280,d2
ou6	bsr	plane
	dbra	d7,stbcl

	move.l	act_sc1,d0
	move.l	act_sc2,d1
	move.l	d1,act_sc1
	move.l	d0,act_sc2
	move.l	act_sc1,ad_ecran
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	
erase	lea	er_buf,a0
	move.l	ad_ecran,a1
	moveq	#0,d0
	moveq	#0,d1
	rept	100
	move.w	(a0)+,d0
	move.w	d1,0(a1,d0.w)
	endr
	lea	er_b1,a1
	lea	er_buf,a0
	rept	100
	move.w	(a1)+,(a0)+
	endr
	rts
		
plane	move.l	d7,-(sp)

	ext.l	d0
	ext.l	d1
	ext.l	d2
	
	*	asr.l	#2,d2	; '*512' '/2048' = '/4'
	* -> par ex: si pt_fuite=256, '*512' '/256' = '*2'
	*			-> asl.l	#1,d2 ;10 cycles 
	asr.l	#1,d2
	move.w	#512,d6
	sub.w	d2,d6
	moveq	#9,d7
	asl.l	d7,d0
	asl.l	d7,d1
	
	divs	d6,d0	; xp
	divs	d6,d1	; yp
	add.w	#160,d0
	add.w	#100,d1

	cmp.w	#320,d0
	bgt	nopoint
	tst.w	d0
	bmi	nopoint
	cmp.w	#200,d1
	bgt	nopoint
	tst.w	d1
	bmi	nopoint
	
	move.w	d0,d6
	
	mulu	#160,d1
	lsr.w	#1,d0
	and.w	#$fff8,d0
	add.w	d0,d1
	
	and.w	#15,d6
	neg	d6
	add.w	#15,d6
	
	cmp.w	#-560,d2
	bmi	not2
	add.w	#2,d1
not2	cmp.w	#-240,d2
	bmi	not3
	add.w	#2,d1
not3	cmp.w	#80,d2
	bmi	not4
	add.w	#2,d1	
not4
	move.w	(a6,d1.w),d7
	bset	d6,d7
	move.w	d7,(a6,d1.w)
		
	move.w	d1,(a3)+
	
nopoint	move.l	(sp)+,d7 
	rts

	data
	
stars	incbin	.\stars2.dat	
zic	incbin	.\ovr4.mus

	bss

ox	ds.w	1
oy	ds.w	1
oz	ds.w	1
vx	ds.w	1
vy	ds.w	1
vz	ds.w	1
ad_ecran	ds.l	1	
act_sc1	ds.l	1
act_sc2	ds.l	1
sv_stack	ds.l	1
sv_vbl	ds.l	1
er_buf	ds.w	100
er_b1	ds.w	100
video	ds.b	64256

	end
		
