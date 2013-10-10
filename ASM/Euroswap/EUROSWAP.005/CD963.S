          *********************************************
          *                                           *
          *              INTRO CD EAGLES              *
          *                                           *
          *                CODED BY JPS               *
          *                                           *
          *********************************************
;POUR LES CREDITS : INTRO BY JPS AND ARD FROM EAGLES           



; SCROLLTEXT A LA LIGNE 3136

min_x	equ	0
max_x	equ	319
min_y	equ	22
max_y	equ	160

center_x	equ	160
center_y	equ	80

	move.l	4(sp),a6
	move.l	12(a6),a5
	add.l	20(a6),a5
	add.l	28(a6),a5
	add.l	#$100+$400,a5
	move.l	a5,d1
	andi.w	#$fffe,d1
	add.l	a6,d1
	move.l	d1,sp
	
	move.l	a5,-(sp)
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	
	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1	
	addq.l	#6,sp
	move.l	d0,stack


	lea	eti0,a0
	lea	fin_eti0,a1
eff0	move.b	#0,(a0)+
	cmpa.l	a1,a0
	bne.s	eff0
	move.l	$44e,screen
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_screen
	bsr	init_star2
	bsr	initstar_1
	move.w	#0,memory1
	move.l	#buffer1,point_buf1
	move.l	#buffer2,point_buf2
	move.l	#buffer3,point_buf4
	move.l	#test_stars0,vanina
	movea.l	#buffer3,a0
	movea.l	#test_stars0,a1
	moveq	#$59,d0
bcl_copy	move.l	screen,(a0)+
	move.l	screen,(a1)+
	dbra	d0,bcl_copy
	jsr	initstar_3	

	jmp	intro_cd



init_star2	move.l	screen,d0
	movea.w	#$8201,a0
	lsr.l	#8,d0
	movep.w	d0,0(a0)
	move.l	point_buf4,d0
	move.l	vanina,point_buf4
	move.l	d0,vanina
	movea.l	jps,a1
	subq.l	#8,a1
	move.l	a1,marsouin
	movea.l	mouette,a1
	subq.l	#8,a1
	move.l	a1,test_star2
	rts	




initstar_1	lea	fin_eti0,a6
	move.w	#$59,d7
bcle_star	move.w	#$11,-(sp)
	trap	#14
	addq.l	#2,sp
	lsr.l	#8,d0
	mulu	#$190,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	subi.w	#$c8,d0
	move.w	d0,(a6)+
	move.w	#$11,-(sp)
	trap	#14
	addq.l	#2,sp
	lsr.l	#8,d0
	mulu	#$190,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	subi.w	#$c8,d0
	move.w	d0,(a6)+
	move.w	#$11,-(sp)
	trap	#14
	addq.l	#2,sp
	lsr.l	#8,d0
	mulu	#$1d4,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	addq.w	#1,d0
	move.w	#0,d1
	sub.w	d0,d1
	move.w	d1,(a6)+
	dbra	d7,bcle_star
	rts	

initstar_3	lea	buffer1,a0
	lea	data_star2,a2
	lea	data_star1,a3
	lea	buffer2,a4
	moveq	#$74,d0
bcle_star2	lea	fin_eti0,a1
	moveq	#$59,d1
bcle_star3	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d7
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	4(a1),d4
	ext.l	d2
	ext.l	d3
	ext.l	d4
	moveq.l	#$fe,d5
	cmpi.w	#$ff17,d4
	ble.s	no_nul
	moveq	#0,d5
no_nul	muls	#$8c,d2
	divs	d4,d2
	addi.w	#center_x,d2
	muls	#$8c,d3
	divs	d4,d3
	addi.w	#center_y,d3
	move.w	d3,d7
	cmpi.w	#min_x,d2
	bge.s	no_nul2
	move.w	#0,d2
	move.w	#0,d7
no_nul2	cmpi.w	#max_x,d2
	ble.s	no_nul3
	move.w	#0,d2
	move.w	#0,d7
no_nul3	cmpi.w	#min_y,d7
	bge.s	no_nul4
	move.w	#0,d2
	move.w	#0,d7
no_nul4	cmpi.w	#max_y,d7
	ble.s	no_nul5
	move.w	#0,d2
	move.w	#0,d7
no_nul5	muls	#$a0,d7
	move.b	(a3,d2.w),d6
	move.b	d6,(a4)+
	lsl.w	#2,d2
	add.l	(a2,d2.w),d7
	add.l	d5,d7
	move.l	d7,(a0)+
	addq.w	#4,d4
	cmpi.w	#$ffff,d4
	ble.s	ok_bcl3
	subi.w	#$1d2,d4
ok_bcl3	move.w	d4,4(a1)
	addq.l	#6,a1
	dbra	d1,bcle_star3
	dbra	d0,bcle_star2
	rts	

stars	movea.l	point_buf4,a0
	moveq	#0,d0
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	(a0)+,a1
	move.b	d0,(a1)
	movea.l	point_buf4,a1
	movea.l	screen,a6
	adda.l	#$820,a6
	movea.l	a6,a5
	movea.l	point_buf1,a0
	movea.l	point_buf2,a4
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.b	(a4)+,d0
	adda.l	(a0)+,a6
	move.l	a6,(a1)+
	bset	d0,(a6)
	movea.l	a5,a6
	move.l	#0,4(a5)
	addq.w	#1,memory1
	cmpi.w	#$75,memory1
	bne.s	fin_stars
	lea	buffer1,a0
	lea	buffer2,a4
	move.w	#0,memory1
fin_stars	move.l	a0,point_buf1
	move.l	a4,point_buf2
	rts	

data_star1	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0,7,6,5,4
	dc.b	3,2,1,0,7,6,5,4,3,2,1,0
	dc.b	7,6,5,4,3,2,1,0
data_star2	dc.b	0,0,0,6,0,0,0,6,0,0,0,6
	dc.b	0,0,0,6,0,0,0,6,0,0,0,6
	dc.b	0,0,0,6,0,0,0,6,0,0,0,7
	dc.b	0,0,0,7,0,0,0,7,0,0,0,7
	dc.b	0,0,0,7,0,0,0,7,0,0,0,7
	dc.b	0,0,0,7,0,0,0,$e,0,0,0,$e
	dc.b	0,0,0,$e,0,0,0,$e,0,0,0,$e
	dc.b	0,0,0,$e,0,0,0,$e,0,0,0,$e
	dc.b	0,0,0,$f,0,0,0,$f,0,0,0,$f
	dc.b	0,0,0,$f,0,0,0,$f,0,0,0,$f
	dc.b	0,0,0,$f,0,0,0,$f,0,0,0,$16
	dc.b	0,0,0,$16,0,0,0,$16,0,0,0,$16
	dc.b	0,0,0,$16,0,0,0,$16,0,0,0,$16
	dc.b	0,0,0,$16,0,0,0,$17,0,0,0,$17
	dc.b	0,0,0,$17,0,0,0,$17,0,0,0,$17
	dc.b	0,0,0,$17,0,0,0,$17,0,0,0,$17
	dc.b	0,0,0,$1e,0,0,0,$1e,0,0,0,$1e
	dc.b	0,0,0,$1e,0,0,0,$1e,0,0,0,$1e
	dc.b	0,0,0,$1e,0,0,0,$1e,0,0,0,$1f
	dc.b	0,0,0,$1f,0,0,0,$1f,0,0,0,$1f
	dc.b	0,0,0,$1f,0,0,0,$1f,0,0,0,$1f
	dc.b	0,0,0,$1f,0,0,0,$26,0,0,0,$26
	dc.b	0,0,0,$26,0,0,0,$26,0,0,0,$26
	dc.b	0,0,0,$26,0,0,0,$26,0,0,0,$26
	dc.b	0,0,0,$27,0,0,0,$27,0,0,0,$27
	dc.b	0,0,0,$27,0,0,0,$27,0,0,0,$27
	dc.b	0,0,0,$27,0,0,0,$27,0,0,0,$2e
	dc.b	0,0,0,$2e,0,0,0,$2e,0,0,0,$2e
	dc.b	0,0,0,$2e,0,0,0,$2e,0,0,0,$2e
	dc.b	0,0,0,$2e,0,0,0,$2f,0,0,0,$2f
	dc.b	0,0,0,$2f,0,0,0,$2f,0,0,0,$2f
	dc.b	0,0,0,$2f,0,0,0,$2f,0,0,0,$2f
	dc.b	0,0,0,$36,0,0,0,$36,0,0,0,$36
	dc.b	0,0,0,$36,0,0,0,$36,0,0,0,$36
	dc.b	0,0,0,$36,0,0,0,$36,0,0,0,$37
	dc.b	0,0,0,$37,0,0,0,$37,0,0,0,$37
	dc.b	0,0,0,$37,0,0,0,$37,0,0,0,$37
	dc.b	0,0,0,$37,0,0,0,$3e,0,0,0,$3e
	dc.b	0,0,0,$3e,0,0,0,$3e,0,0,0,$3e
	dc.b	0,0,0,$3e,0,0,0,$3e,0,0,0,$3e
	dc.b	0,0,0,$3f,0,0,0,$3f,0,0,0,$3f
	dc.b	0,0,0,$3f,0,0,0,$3f,0,0,0,$3f
	dc.b	0,0,0,$3f,0,0,0,$3f,0,0,0,$46
	dc.b	0,0,0,$46,0,0,0,$46,0,0,0,$46
	dc.b	0,0,0,$46,0,0,0,$46,0,0,0,$46
	dc.b	0,0,0,$46,0,0,0,$47,0,0,0,$47
	dc.b	0,0,0,$47,0,0,0,$47,0,0,0,$47
	dc.b	0,0,0,$47,0,0,0,$47,0,0,0,$47
	dc.b	0,0,0,$4e,0,0,0,$4e,0,0,0,$4e
	dc.b	0,0,0,$4e,0,0,0,$4e,0,0,0,$4e
	dc.b	0,0,0,$4e,0,0,0,$4e,0,0,0,$4f
	dc.b	0,0,0,$4f,0,0,0,$4f,0,0,0,$4f
	dc.b	0,0,0,$4f,0,0,0,$4f,0,0,0,$4f
	dc.b	0,0,0,$4f,0,0,0,$56,0,0,0,$56
	dc.b	0,0,0,$56,0,0,0,$56,0,0,0,$56
	dc.b	0,0,0,$56,0,0,0,$56,0,0,0,$56
	dc.b	0,0,0,$57,0,0,0,$57,0,0,0,$57
	dc.b	0,0,0,$57,0,0,0,$57,0,0,0,$57
	dc.b	0,0,0,$57,0,0,0,$57,0,0,0,$5e
	dc.b	0,0,0,$5e,0,0,0,$5e,0,0,0,$5e
	dc.b	0,0,0,$5e,0,0,0,$5e,0,0,0,$5e
	dc.b	0,0,0,$5e,0,0,0,$5f,0,0,0,$5f
	dc.b	0,0,0,$5f,0,0,0,$5f,0,0,0,$5f
	dc.b	0,0,0,$5f,0,0,0,$5f,0,0,0,$5f
	dc.b	0,0,0,$66,0,0,0,$66,0,0,0,$66
	dc.b	0,0,0,$66,0,0,0,$66,0,0,0,$66
	dc.b	0,0,0,$66,0,0,0,$66,0,0,0,$67
	dc.b	0,0,0,$67,0,0,0,$67,0,0,0,$67
	dc.b	0,0,0,$67,0,0,0,$67,0,0,0,$67
	dc.b	0,0,0,$67,0,0,0,$6e,0,0,0,$6e
	dc.b	0,0,0,$6e,0,0,0,$6e,0,0,0,$6e
	dc.b	0,0,0,$6e,0,0,0,$6e,0,0,0,$6e
	dc.b	0,0,0,$6f,0,0,0,$6f,0,0,0,$6f
	dc.b	0,0,0,$6f,0,0,0,$6f,0,0,0,$6f
	dc.b	0,0,0,$6f,0,0,0,$6f,0,0,0,$76
	dc.b	0,0,0,$76,0,0,0,$76,0,0,0,$76
	dc.b	0,0,0,$76,0,0,0,$76,0,0,0,$76
	dc.b	0,0,0,$76,0,0,0,$77,0,0,0,$77
	dc.b	0,0,0,$77,0,0,0,$77,0,0,0,$77
	dc.b	0,0,0,$77,0,0,0,$77,0,0,0,$77
	dc.b	0,0,0,$7e,0,0,0,$7e,0,0,0,$7e
	dc.b	0,0,0,$7e,0,0,0,$7e,0,0,0,$7e
	dc.b	0,0,0,$7e,0,0,0,$7e,0,0,0,$7f
	dc.b	0,0,0,$7f,0,0,0,$7f,0,0,0,$7f
	dc.b	0,0,0,$7f,0,0,0,$7f,0,0,0,$7f
	dc.b	0,0,0,$7f,0,0,0,$86,0,0,0,$86
	dc.b	0,0,0,$86,0,0,0,$86,0,0,0,$86
	dc.b	0,0,0,$86,0,0,0,$86,0,0,0,$86
	dc.b	0,0,0,$87,0,0,0,$87,0,0,0,$87
	dc.b	0,0,0,$87,0,0,0,$87,0,0,0,$87
	dc.b	0,0,0,$87,0,0,0,$87,0,0,0,$8e
	dc.b	0,0,0,$8e,0,0,0,$8e,0,0,0,$8e
	dc.b	0,0,0,$8e,0,0,0,$8e,0,0,0,$8e
	dc.b	0,0,0,$8e,0,0,0,$8f,0,0,0,$8f
	dc.b	0,0,0,$8f,0,0,0,$8f,0,0,0,$8f
	dc.b	0,0,0,$8f,0,0,0,$8f,0,0,0,$8f
	dc.b	0,0,0,$96,0,0,0,$96,0,0,0,$96
	dc.b	0,0,0,$96,0,0,0,$96,0,0,0,$96
	dc.b	0,0,0,$96,0,0,0,$96,0,0,0,$97
	dc.b	0,0,0,$97,0,0,0,$97,0,0,0,$97
	dc.b	0,0,0,$97,0,0,0,$97,0,0,0,$97
	dc.b	0,0,0,$97,0,0,0,$9e,0,0,0,$9e
	dc.b	0,0,0,$9e,0,0,0,$9e,0,0,0,$9e
	dc.b	0,0,0,$9e,0,0,0,$9e,0,0,0,$9e
	dc.b	0,0,0,$9f,0,0,0,$9f,0,0,0,$9f
	dc.b	0,0,0,$9f,0,0,0,$9f,0,0,0,$9f
	dc.b	0,0,0,$9f,0,0,0,$9f

eti0	ds.l	1
old_screen	ds.l	1
old_pal	ds.b	32
screen	ds.l	1
jps	ds.l	1
marsouin	ds.l	1
mouette	ds.l	1
test_star2	ds.l	1
fin_eti0	ds.b	540

point_buf1	ds.l	1
memory1	ds.w	1
buffer3	ds.b	360
test_stars0	ds.b	360

buffer1	ds.b	42120
point_buf2	ds.l	1
buffer2	ds.b	10530
point_buf4	ds.l	1
vanina	ds.b	4
	



;    ------------------------------------------------------
;                         initialisations
;    ------------------------------------------------------

intro_cd	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	colors,a0	* sauve couleurs
	lea	$ffff8240,a1
	move.w	#8,d0
save_colors	move.l	(a1)+,(a0)+
	dbra	d0,save_colors


;    **** installe nouveaux parametres ****

	CLR.W	$FFFF8240.W
	CLR.W	$FFFF8242.W
	CLR.W	$FFFF8244.W
	CLR.W	$FFFF8246.W
	CLR.W	$FFFF8248.W
	CLR.W	$FFFF824A.W
	CLR.W	$FFFF824C.W
	CLR.W	$FFFF824E.W
	CLR.W	$FFFF8250.W
	CLR.W	$FFFF8252.W
	CLR.W	$FFFF8254.W
	CLR.W	$FFFF8256.W
	CLR.W	$FFFF8258.W
	CLR.W	$FFFF825A.W
	CLR.W	$FFFF825C.W
	CLR.W	$FFFF825E.W
	
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	#$12,$fffffc02.w
	move.b	#4,$484
	
	move.l	$44e,adr_scr1
	add.l	#160*182,adr_scr1
	move.l	adr_scr1,a0
	lea	fond+34,a1
	move.w	#((17*160)/4)-1,d0
aff_fond	move.l	(a1)+,(a0)+
	dbra	d0,aff_fond

;    **** initialise demo ****


	jsr	deform_init

	bsr	code_txt1

	lea	code1,a0
	lea	count1,a1
	move.l	a0,(a1)

	LEA	ST_CONNEXION(PC),A0
	LEA	MUSIC,A1
	MOVE.L	A1,12(A0)
	MOVE.W	#0,16(A0)
	MOVE.W	#$25,-(SP)
 	TRAP	#14
	ADDQ.L	#2,SP

	move.w	#$2700,sr
	BSR	ST_CONNEXION
	bclr.b	#5,$fffffa15
	bclr.b	#0,$fffffa13
	bclr.b	#0,$fffffa07
	move.b	#0,$fffffa1b
	move.l	$120,old_tb
	move.l	#timer_b1,$120
	bset.b	#0,$fffffa13
	bset.b	#0,$fffffa07
	move.l	$70,old_vbl
	move.l	#vbl,$70
	move.w	#$2300,sr



	
;    -------------------------------------------------------
;                       BOUCLE PRINCIPALE
;    -------------------------------------------------------

	clr.l	position2
	clr.l	addition_x2
	clr.l	addition_y2
	clr.w	testi2
	move.l	#text1,adr_text2
	move.l	#end_text1,adr_endtxt2

big_bcle	cmp.b	#59,$fffffc02.w
	beq	fn1
	
	cmp.b	#60,$fffffc02.w
	beq	fn2
	
	cmp.b	#61,$fffffc02.w
	beq	fn3

	cmp.b	#62,$fffffc02.w
	beq	fn4
	
	cmp.b	#63,$fffffc02.w
	beq	fn5
	
	cmp.b	#64,$fffffc02.w
	beq	fn6
	
	cmp.b	#65,$fffffc02.w
	beq	fn7
	
	cmp.b	#66,$fffffc02.w
	beq	fn8

	cmp.b	#67,$fffffc02.w
	beq	fn9
	
	cmp.b	#68,$fffffc02.w
	beq	fn10	

	bra	big_bcle

reset_it	move.w	#$2700,sr
	move.b	#0,$fffffa1b
	move.l	old_tb,$120
	bset	#5,$fffffa15
	move.l	old_vbl,$70
	MOVE.W	#$2700,SR
	BSR	ST_CONNEXION+$4
	MOVE.W	#$2300,SR
	move.w	#8000,d0
wait_mfp	dbra	d0,wait_mfp
	move.w	#$2300,sr
	move.b	#$8,$fffffc02.w
	move.b	#15,$484
	move.w	#7999,d0
	move.l	$44e,a0
eff_screen	clr.l	(a0)+
	dbra	d0,eff_screen
	move.w	#$531,$ffff8242
	move.w	#$642,$ffff8244
	move.w	#$753,$ffff8246
	clr.l	position2
	clr.l	addition_x2
	clr.l	addition_y2
	clr.w	testi2
	move.l	#during_load,adr_text2
	move.l	#end_load,adr_endtxt2
	move.w	#50,d0
aff_load	movem.l	d0-a6,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	jsr	aff_txt
	movem.l	(sp)+,d0-a6
	dbra	d0,aff_load

	move.l	stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	rts
	
	
kill_all	lea	colors,a0
	lea	$ffff8240,a1
	move.w	#7,d0
rend_couleurs	move.l	(a0)+,(a1)+
	dbra	d0,rend_couleurs
	rts

fn1	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft1,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn2	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft2,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn3	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft3,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn4	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft4,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn5	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn6	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft6,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn7	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft7,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	

fn8	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft8,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	


fn9	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft9,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	


fn10	jsr	reset_it

	move.l	#env,-(sp)
	move.l	#env,-(sp)
	move.l	#soft10,-(sp)
	move.w	#0,-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	adda.l	#16,sp

	pea	kill_all
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.l	-(sp)
	trap	#1	


;    ---------------------------------------------------------
;                       SOUS PROGRAMMES
;    ---------------------------------------------------------


aff_txt	move.l	adr_text2,a1
	lea	adr_lettre2,a2
	move.l	adr_endtxt2,a3
	add.l	position2,a1
	add.l	#1,position2

	cmp.b	#"A",(a1)
	bne	b2
	move.l	#0,(a2)
	bra	end_code2
b2	cmp.b	#"B",(a1)
	bne	c2
	move.l	#1,(a2)
	bra	end_code2
c2	cmp.b	#"C",(a1)
	bne	d2
	move.l	#8,(a2)
	bra	end_code2
d2	cmp.b	#"D",(a1)
	bne	e2
	move.l	#9,(a2)
	bra	end_code2
e2	cmp.b	#"E",(a1)
	bne	f2
	move.l	#16,(a2)
	bra	end_code2
f2	cmp.b	#"F",(a1)
	bne	g2
	move.l	#17,(a2)
	bra	end_code2
g2	cmp.b	#"G",(a1)
	bne	h2
	move.l	#24,(a2)
	bra	end_code2
h2	cmp.b	#"H",(a1)
	bne	i2
	move.l	#25,(a2)
	bra	end_code2
i2	cmp.b	#"I",(a1)
	bne	j2
	move.l	#32,(a2)
	bra	end_code2
j2	cmp.b	#"J",(a1)
	bne	k2
	move.l	#33,(a2)
	bra	end_code2
k2	cmp.b	#"K",(a1)
	bne	l2
	move.l	#40,(a2)
	bra	end_code2
l2	cmp.b	#"L",(a1)
	bne	m2
	move.l	#41,(a2)
	bra	end_code2
m2	cmp.b	#"M",(a1)
	bne	n2
	move.l	#48,(a2)
	bra	end_code2
n2	cmp.b	#"N",(a1)
	bne	o2
	move.l	#49,(a2)
	bra	end_code2
o2	cmp.b	#"O",(a1)
	bne	p2
	move.l	#56,(a2)
	bra	end_code2
p2	cmp.b	#"P",(a1)
	bne	q2
	move.l	#57,(a2)
	bra	end_code2
q2	cmp.b	#"Q",(a1)
	bne	r2
	move.l	#64,(a2)
	bra	end_code2
r2	cmp.b	#"R",(a1)
	bne	s2
	move.l	#65,(a2)
	bra	end_code2
s2	cmp.b	#"S",(a1)
	bne	t2
	move.l	#72,(a2)
	bra	end_code2
t2	cmp.b	#"T",(a1)
	bne	u2
	move.l	#73,(a2)
	bra	end_code2
u2	cmp.b	#"U",(a1)
	bne	v2
	move.l	#80,(a2)
	bra	end_code2
v2	cmp.b	#"V",(a1)
	bne	w2
	move.l	#81,(a2)
	bra	end_code2
w2	cmp.b	#"W",(a1)
	bne	x2
	move.l	#88,(a2)
	bra	end_code2
x2	cmp.b	#"X",(a1)
	bne	y2
	move.l	#89,(a2)
	bra	end_code2
y2	cmp.b	#"Y",(a1)
	bne	z2
	move.l	#96,(a2)
	bra	end_code2
z2	cmp.b	#"Z",(a1)
	bne	pt_ascii2
	move.l	#97,(a2)
	bra	end_code2
pt_ascii2	cmp.b	#".",(a1)
	bne	virgule2
	move.l	#104,(a2)
	bra	end_code2
virgule2	cmp.b	#",",(a1)
	bne	apos2
	move.l	#105,(a2)
	bra	end_code2
apos2	cmp.b	#"'",(a1)
	bne	open2
	move.l	#112,(a2)
	bra	end_code2
open2	cmp.b	#"(",(a1)
	bne	close2
	move.l	#113,(a2)
	bra	end_code2
close2	cmp.b	#")",(a1)
	bne	excla2
	move.l	#120,(a2)
	bra	end_code2
excla2	cmp.b	#"!",(a1)
	bne	dpts2
	move.l	#121,(a2)
	bra	end_code2
dpts2	cmp.b	#":",(a1)
	bne	curs2
	move.l	#128,(a2)
	bra	end_code2
curs2	cmp.b	#"*",(a1)
	bne	retour2
	move.l	#129,(a2)
	bra	end_code2
	
retour2	cmp.b	#"/",(a1)
	bne	please_wait2
	add.l	#(160*10),addition_y2
	move.l	#-7,addition_x2
	move.w	#-1,testi2
	jmp	ok_add2
	
please_wait2	cmp.b	#"-",(a1)
	bne	esp2
	jmp	ok_add2
	
esp2	move.l	#136,(a2)
end_code2	cmpa.l	a3,a1
	ble.s	text_coded2
	jmp	ok_add2

text_coded2
	move.l	$44e,a0
	add.l	#(160*80),a0
	add.l	addition_x2,a0
	add.l	addition_y2,a0
	lea	wings+34,a1
	add.l	adr_lettre2,a1
	move.w	#7,d0
aff_lettre2	move.b	(a1),(a0)
	move.b	2(a1),2(a0)
	add.l	#160,a1
	add.l	#160,a0
	dbra	d0,aff_lettre2

	cmp.w	#0,testi2
	bne	no_8
	add.l	#1,addition_x2
	move.w	#-1,testi2
	jmp	ok_add2
no_8	cmp.w	#-1,testi2
	bne	ok_add2
	clr.w	testi2
	add.l	#7,addition_x2
ok_add2	rts

deform_init	lea	fin_courbe-50,a6
	lea	tab,a0
	move.w	#24,d1
copi	move.w	(a6)+,(a0)+
	dbra	d1,copi

	move.l	#courbe,count_courbe
	rts


deformation	movem.l	clr_registers,d0-a6
	move.l	count_courbe,a6
	move.l	(a6),d1
	add.l	#2,count_courbe
	cmp.l	#fin_courbe,count_courbe
	bne	suite

	move.l	#courbe,count_courbe

suite	jsr	calcul
	jsr	point
	rts


point	lea	tab,a2
	move.w	#16,d2
	clr.l	d6

aff_line	move.w	(a2)+,d1
	move.w	d1,d3
	asr.w	#1,d3
	and.w	#65528,d3
	move.l	$44e,a0
	add.l	#(40*160)-8,a0
	add.l	d3,a0
	add.l	d4,a0
	and.w	#15,d1
	move.w	#15,d3
	sub.w	d1,d3
	move.w	#1,d1
	asl.w	d3,d1

dec16	cmp.w	#%1,d1
	bne	dec15
	move.l	#(4000*7)+80,d5
dec15	cmp.w	#%10,d1
	bne	dec14
	move.l	#(4000*6)+80,d5
dec14	cmp.w	#%100,d1
	bne	dec13
	move.l	#(4000*5)+80,d5
dec13	cmp.w	#%1000,d1
	bne	dec12
	move.l	#(4000*4)+80,d5
dec12	cmp.w	#%10000,d1
	bne	dec11
	move.l	#(4000*3)+80,d5
dec11	cmp.w	#%100000,d1
	bne	dec10
	move.l	#(4000*2)+80,d5
dec10	cmp.w	#%1000000,d1
	bne	dec9
	move.l	#(4000*1)+80,d5
dec9	cmp.w	#%10000000,d1
	bne	dec8
	move.l	#+80,d5

dec8	cmp.w	#%100000000,d1
	bne	dec7
	move.l	#4000*7,d5
dec7	cmp.w	#%1000000000,d1
	bne	dec6
	move.l	#4000*6,d5
dec6	cmp.w	#%10000000000,d1
	bne	dec5
	move.l	#4000*5,d5
dec5	cmp.w	#%100000000000,d1
	bne	dec4
	move.l	#4000*4,d5
dec4	cmp.w	#%1000000000000,d1
	bne	dec3
	move.l	#4000*3,d5
dec3	cmp.w	#%10000000000000,d1
	bne	dec2
	move.l	#4000*2,d5
dec2	cmp.w	#%100000000000000,d1
	bne	dec1
	move.l	#4000,d5
dec1	cmp.w	#%1000000000000000,d1
	bne	suite2
	move.l	#0,d5
	

suite2	LEA	logo+34,a1
	add.l	d6,a1
	add.l	d5,a1
	add.l	d6,a0

aff_logo	clr.b	-1(a0)
	clr.b	-2(a0)
	clr.b	-3(a0)
	clr.b	-4(a0)
	clr.b	-5(a0)
	clr.b	-6(a0)
	clr.b	-7(a0)
	clr.b	-8(a0)
	rept	7
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	lea	6(a1),a1
	lea	6(a0),a0
	endr
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	add.l	#160,d6
	dbra	d2,aff_line
	rts

calcul	lea	tab,a0
	move.w	2(a0),0(a0)
	move.w	4(a0),2(a0)
	move.w	6(a0),4(a0)
	move.w	8(a0),6(a0)
	move.w	10(a0),8(a0)
	move.w	12(a0),10(a0)
	move.w	14(a0),12(a0)
	move.w	16(a0),14(a0)
	move.w	18(a0),16(a0)
	move.w	20(a0),18(a0)
	move.w	22(a0),20(a0)
	move.w	24(a0),22(a0)
	move.w	26(a0),24(a0)
	move.w	28(a0),26(a0)
	move.w	30(a0),28(a0)
	move.w	32(a0),30(a0)
	move.w	34(a0),32(a0)
	move.w	36(a0),34(a0)
	move.w	38(a0),36(a0)
	move.w	40(a0),38(a0)
	move.w	42(a0),40(a0)
	move.w	44(a0),42(a0)
	move.w	46(a0),44(a0)
	move.w	48(a0),46(a0)
	move.w	d1,48(a0)
	rts


;    ****   scrolling 2 plans ****

scroll
	cmp.w	#0,count2
	bne	no_change

	lea	buf1,a0

	move.l	count1,a1
	lea	fonte1+34,a2

	add.w	(a1),a2
	move.w	#14,d1
aff_lettre	move.w	(a2),(a0)
	move.w	2(a2),2(a0)
	move.w	4(a2),4(a0)
	add.l	#160,a0
	add.l	#160,a2
	dbra	d1,aff_lettre
	add.l	#2,count1
	move.l	adr_endtxt1,a1
	cmp.l	count1,a1
	bne	no_change
	move.l	#code1,count1

no_change	add.w	#1,count2
	cmp.w	#8,count2
	bne	no_change2

	clr.w	count2

no_change2	move.l	adr_scr1,a1
	lea	buf1,a0
	move.w	#14,d1
	lea	6(a1),a1
	
decalle2	rept	2
	move.b	#0,ccr
	roxl.w	(a0)
	roxl.w	152(a1)	
	roxl.w	144(a1)	
	roxl.w	136(a1)	
	roxl.w	128(a1)	
	roxl.w	120(a1)	
	roxl.w	112(a1)	
	roxl.w	104(a1)	
	roxl.w	96(a1)	
	roxl.w	88(a1)	
	roxl.w	80(a1)	
	roxl.w	72(a1)	
	roxl.w	64(a1)	
	roxl.w	56(a1)	
	roxl.w	48(a1)	
	roxl.w	40(a1)	
	roxl.w	32(a1)	
	roxl.w	24(a1)	
	roxl.w	16(a1)	
	roxl.w	8(a1)	
	roxl.w	(a1)	
	endr
	
	add.l	#160,a0
	add.l	#160,a1
	dbra	d1,decalle2

	rts



;    **** Codage du scroll ****

code_txt1	movem.l	a1/a2/a3,-(sp)
	lea	text,a1
	lea	code1,a2
	lea	end_text,a3

bcle_code1
	cmp.b	#"A",(a1)
	bne	b
	move.w	#0,(a2)
	bra	end_code1

b	cmp.b	#"B",(a1)
	bne	c
	move.w	#8,(a2)
	bra	end_code1

c	cmp.b	#"C",(a1)
	bne	d
	move.w	#16,(a2)
	bra	end_code1

d	cmp.b	#"D",(a1)
	bne	e
	move.w	#24,(a2)
	bra	end_code1

e	cmp.b	#"E",(a1)
	bne	f
	move.w	#32,(a2)
	bra	end_code1

f	cmp.b	#"F",(a1)
	bne	g
	move.w	#40,(a2)
	bra	end_code1

g	cmp.b	#"G",(a1)
	bne	h
	move.w	#48,(a2)
	bra	end_code1

h	cmp.b	#"H",(a1)
	bne	i
	move.w	#56,(a2)
	bra	end_code1

i	cmp.b	#"I",(a1)
	bne	j
	move.w	#64,(a2)
	bra	end_code1

j	cmp.b	#"J",(a1)
	bne	k
	move.w	#72,(a2)
	bra	end_code1

k	cmp.b	#"K",(a1)
	bne	l
	move.w	#80,(a2)
	bra	end_code1

l	cmp.b	#"L",(a1)
	bne	m
	move.w	#88,(a2)
	bra	end_code1

m	cmp.b	#"M",(a1)
	bne	n
	move.w	#96,(a2)
	bra	end_code1

n	cmp.b	#"N",(a1)
	bne	o
	move.w	#104,(a2)
	bra	end_code1

o	cmp.b	#"O",(a1)
	bne	p
	move.w	#112,(a2)
	bra	end_code1

p	cmp.b	#"P",(a1)
	bne	q
	move.w	#120,(a2)
	bra	end_code1

q	cmp.b	#"Q",(a1)
	bne	r
	move.w	#128,(a2)
	bra	end_code1

r	cmp.b	#"R",(a1)
	bne	s
	move.w	#136,(a2)
	bra	end_code1

s	cmp.b	#"S",(a1)
	bne	t
	move.w	#144,(a2)
	bra	end_code1

t	cmp.b	#"T",(a1)
	bne	u
	move.w	#152,(a2)
	bra	end_code1

u	cmp.b	#"U",(a1)
	bne	v
	move.w	#2560,(a2)
	bra	end_code1

v	cmp.b	#"V",(a1)
	bne	w
	move.w	#2560+8,(a2)
	bra	end_code1

w	cmp.b	#"W",(a1)
	bne	x
	move.w	#2560+16,(a2)
	bra	end_code1

x	cmp.b	#"X",(a1)
	bne	y
	move.w	#2560+24,(a2)
	bra	end_code1

y	cmp.b	#"Y",(a1)
	bne	z
	move.w	#2560+32,(a2)
	bra	end_code1

z	cmp.b	#"Z",(a1)
	bne	.0
	move.w	#2560+40,(a2)
	bra	end_code1

.0	cmp.b	#"0",(a1)
	bne	.1
	move.w	#2560+48,(a2)
	bra	end_code1

.1	cmp.b	#"1",(a1)
	bne	.2
	move.w	#2560+56,(a2)
	bra	end_code1

.2	cmp.b	#"2",(a1)
	bne	.3
	move.w	#2560+64,(a2)
	bra	end_code1

.3	cmp.b	#"3",(a1)
	bne	.4
	move.w	#2560+72,(a2)
	bra	end_code1

.4	cmp.b	#"4",(a1)
	bne	.5
	move.w	#2560+80,(a2)
	bra	end_code1

.5	cmp.b	#"5",(a1)
	bne	.6
	move.w	#2560+88,(a2)
	bra	end_code1

.6	cmp.b	#"6",(a1)
	bne	.7
	move.w	#2560+96,(a2)
	bra	end_code1

.7	cmp.b	#"7",(a1)
	bne	.8
	move.w	#2560+104,(a2)
	bra	end_code1

.8	cmp.b	#"8",(a1)
	bne	.9
	move.w	#2560+112,(a2)
	bra	end_code1

.9	cmp.b	#"9",(a1)
	bne	open
	move.w	#2560+120,(a2)
	bra	end_code1

open	cmp.b	#"(",(a1)
	bne	close
	move.w	#2560+128,(a2)
	bra	end_code1

close	cmp.b	#")",(a1)
	bne	excla
	move.w	#2560+136,(a2)
	bra	end_code1

excla	cmp.b	#"!",(a1)
	bne	redox
	move.w	#2560+144,(a2)
	bra	end_code1

redox	cmp.b	#"*",(a1)
	bne	interro
	move.w	#5120,(a2)
	bra	end_code1

interro	cmp.b	#"?",(a1)
	bne	virgule
	move.w	#5120+8,(a2)
	bra	end_code1

virgule	cmp.b	#",",(a1)
	bne	pt_ascii
	move.w	#5120+16,(a2)
	bra	end_code1

pt_ascii	cmp.b	#".",(a1)
	bne	apos
	move.w	#5120+24,(a2)
	bra	end_code1


apos	cmp.b	#"'",(a1)
	bne	rien
	move.w	#5120+32,(a2)
	bra	end_code1

rien	move.w	#5120+40,(a2)


end_code1	addq.l	#2,a2
	addq.l	#1,a1

	cmpa.l	a3,a1
	bge.s	text_coded1
	bra	bcle_code1

text_coded1	lea	adr_endtxt1,a1
	move.l	a2,(a1)
	movem.l	(sp)+,a1/a2/a3
	rts

equalizs	movem.l	d0-a6,-(sp)
	clr.l	d0
	tst.w	voice1
	beq	no_sound1
	move.l	#15,d0
	jmp	ok_voice1
no_sound1	sub.l	#1,old_etat1
	cmp.l	#0,old_etat1
	bge	ok_etat1
	clr.l	old_etat1
ok_etat1	move.l	old_etat1,d0
ok_voice1	move.l	d0,old_etat1
	lea	draw+34+(75*160),a0
	move.l	$44e,a1
	mulu	#(160*5),d0
	sub.l	d0,a0
	rept	25
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1
	endr

	clr.l	d0
	tst.w	voice2
	beq	no_sound2
	move.l	#15,d0
	jmp	ok_voice2
no_sound2	sub.l	#1,old_etat2
	cmp.l	#0,old_etat2
	bge	ok_etat2
	clr.l	old_etat2
ok_etat2	move.l	old_etat2,d0
ok_voice2	move.l	d0,old_etat2
	lea	draw+34+(75*160),a0
	move.l	$44e,a1
	add.l	#(5*160),a1
	mulu	#(160*5),d0
	sub.l	d0,a0
	rept	25
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1
	endr

	clr.l	d0
	tst.w	voice3
	beq	no_sound3
	move.l	#15,d0
	jmp	ok_voice3
no_sound3	sub.l	#1,old_etat3
	cmp.l	#0,old_etat3
	bge	ok_etat3
	clr.l	old_etat3
ok_etat3	move.l	old_etat3,d0
ok_voice3	move.l	d0,old_etat3
	lea	draw+34+(75*160),a0
	move.l	$44e,a1
	add.l	#(10*160),a1
	mulu	#(160*5),d0
	sub.l	d0,a0
	rept	25
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1
	endr

	clr.l	d0
	tst.w	voice4
	beq	no_sound4
	move.l	#15,d0
	jmp	ok_voice4
no_sound4	sub.l	#1,old_etat4
	cmp.l	#0,old_etat4
	bge	ok_etat4
	clr.l	old_etat4
ok_etat4	move.l	old_etat4,d0
ok_voice4	move.l	d0,old_etat4
	lea	draw+34+(75*160),a0
	move.l	$44e,a1
	add.l	#(15*160),a1
	mulu	#(160*5),d0
	sub.l	d0,a0
	rept	25
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1
	endr

	movem.l	(sp)+,d0-a6
	rts


;soundtracker playroutine
ST_CONNEXION	BRA	INIT
		BRA	END
		BRA	PLAY
;adresse de la musique
		DC.L	0
;sortie desiree
;0=soundchip
;1=st replay
;2=mv 16
		DC.W	0


INIT	MOVEM.L	D0-A6,-(SP)
;adresse musique
	LEA	ST_CONNEXION(PC),A0
	MOVE.L	12(A0),A0
	LEA	OFFSET,A1
	MOVE.W	#$1D8,POS(A1)
	MOVE.W	#$258,PATT(A1)
	MOVE.W	#$F,NBR(A1)
;module du type 31 instruments ?
	CMP.L	#'M.K.',$438(A0)
	BNE.S	NO_NEW_MODULES
	MOVE.W	#$3B8,POS(A1)
	MOVE.W	#$43C,PATT(A1)
	MOVE.W	#$1F,NBR(A1)
NO_NEW_MODULES
	LEA	ST_CONNEXION(PC),A0
	MOVE.L	12(A0),A0
	LEA	OFFSET,A1
	ADD.W	POS(A1),A0
	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
;nombre de patterns
.LOOP1	MOVE.L	D1,D2
	SUBQ.W	#1,D0
.LOOP2	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	.LOOP1
	DBF	D0,.LOOP2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA	ST_CONNEXION(PC),A0
	MOVE.L	12(A0),A0
	ADD.L	A0,D2
	LEA	$14(A0),A0
	LEA	OFFSET,A1
	MOVE.W	NBR(A1),D7
	ADD.W	PATT(A1),D2
	MOVE.L	D2,A2
	LEA	SAMPLESTARTS,A1
	LEA	(A1),A3
	MOVEQ	#$1E,D6
.LOOP3	CLR.L	(A3)+
	DBRA	D6,.LOOP3
	SUBQ.W	#1,D7
.LOOP4	CLR.L	(A2)
;adresse de debut des samples
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	22(A0),D1
	LSL.L	#1,D1
	MOVE.L	A2,A5
	ADD.L	D1,A2
	MOVE.L	A2,(A1)
	LEA	(A2),A6
	MOVE.W	22(A0),D6
	BEQ.S	.NO_REVERSE
	SUBQ.W	#1,D6
;inverse les samples en memoire
.LOOP5	MOVE.B	(A5),D2
	MOVE.B	-1(A6),D3
;met les samples au format non signes
	EOR.B	#$80,D2
	EOR.B	#$80,D3
	MOVE.B	D3,(A5)+
	MOVE.B	D2,-(A6)
	DBRA	D6,.LOOP5
.NO_REVERSE
	CMP.W	#$0001,28(A0)
	BNE.S	.LOOP6
	CLR.W	28(A0)
.LOOP6	LEA	$1E(A0),A0
	DBRA	D7,.LOOP4
	LEA	CHIP,A0
	LEA	NO_INS,A1
	MOVEQ	#$7,D0
.LOOP7	MOVE.L	A1,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D0,.LOOP7
	LEA	VOICES,A0
	MOVEQ	#$1C-1,D0
.LOOP11	CLR.L	(A0)+
	DBRA	D0,.LOOP11
;initialise quelques datas...
	LEA	OFFSET,A0
	MOVE.B	#$6,SPEED(A0)
	CLR.B	SONGPOS(A0)
	CLR.B	COUNTER(A0)
	CLR.W	PATTPOS(A0)
	LEA	DIGIT_SWAP,A0
	LEA	(DIGIT+1000),A1
	MOVE.L	A1,(A0)
	LEA	DIGIT,A1
	MOVE.L	A1,4(A0)
	MOVE.W	#1000-1,D0
.LOOP8	MOVE.W	#$400,(A1)+
	DBRA	D0,.LOOP8
	LEA	YET,A0
	CMP.L	#'CNX',(A0)
	BEQ.S	.NO_CHANGE
	LEA	SOUND(PC),A0
	MOVE.W	#255,D0
.LOOP9	MOVE.B	5(A0),6(A0)
	MOVE.B	5(A0),7(A0)
	MOVE.B	4(A0),5(A0)
	LEA	8(A0),A0
	DBRA	D0,.LOOP9
	LEA	VOLUME,A0
	MOVE.W	#$3FFF,D0
.LOOP10	MOVE.B	(A0),D1
;transformation de la table de volume
;en donnees 6 bits
	LSR.B	#2,D1
	MOVE.B	D1,(A0)+
	DBRA	D0,.LOOP10
	LEA	YET,A0
	MOVE.L	#'CNX',(A0)
.NO_CHANGE

;yamaha reset
	MOVE.L	#$00000000,$FFFF8800.W
	MOVE.L	#$01010000,$FFFF8800.W
	MOVE.L	#$02020000,$FFFF8800.W
	MOVE.L	#$03030000,$FFFF8800.W
	MOVE.L	#$04040000,$FFFF8800.W
	MOVE.L	#$05050000,$FFFF8800.W
	MOVE.L	#$06060000,$FFFF8800.W
	MOVE.L	#$0707FFFF,$FFFF8800.W
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W
;sauve les interruptions:
	LEA	STORE_INTERRUPTS(PC),A0
;vbl
	MOVE.L	$70.W,$0(A0)
;timer a
	MOVE.L	$134.W,$4(A0)
	LEA	$FFFFFA00.W,A1
;iera et ierb
	MOVEP.W	$7(A1),D0
	MOVE.W	D0,$8(A0)
;imra imrb vr et tacr
	MOVEP.L	$13(A1),D0
	MOVE.L	D0,$A(A0)
	CLR.B	$19(A1)
;tadr
	MOVE.B	$1F(A1),$E(A0)
;mouse off
	MOVE.B	#$12,$FFFFFC02.W
;coupe le mfp
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
;passage en fin automatique des interruptions
	BCLR.B	#$3,$FFFFFA17.W
	CLR.B	$FFFFFA19.W
;positionne le tadr = registre de data du timer a
	MOVE.B	#FRQ_DATA,$FFFFFA1F.W
;le prediviseur divise par 4
	MOVE.B	#1,$FFFFFA19.W
;le timer a est autorise
	OR.B	#32,$FFFFFA07.W
	OR.B	#32,$FFFFFA13.W
;mise en place du timer a
	LEA	SOUNDCHIP(PC),A0
	MOVE.L	A0,$134.W
	LEA	ST_CONNEXION(PC),A1
	LEA	16(A1),A1
	CMP.W	#1,(A1)
	BNE.S	MV16?
	LEA	ST_REPLAY(PC),A0
	MOVE.L	A0,$134.W
MV16?	CMP.W	#2,(A1)
	BNE.S	SOUNDCHIP?
	LEA	MV16(PC),A0
	MOVE.L	A0,$134.W
SOUNDCHIP?
	MOVEM.L	(SP)+,D0-A6
	RTS

;zone de sauvegarde du contexte du st
STORE_INTERRUPTS	DCB.W	8,0


END	MOVEM.L	D0-A6,-(SP)
;restaure les interruptions:
	LEA	STORE_INTERRUPTS(PC),A0
;la vbl
	MOVE.L	$0(A0),$70.W
;le timer a
	MOVE.L	$4(A0),$134.W
;et le mfp
	LEA	$FFFFFA00.W,A1
	MOVE.L	$A(A0),D0
	MOVEP.L	D0,$13(A1)
	CLR.B	$19(A1)
	MOVE.B	$E(A0),$1F(A1)
	MOVE.B	$D(A0),$19(A1)
	MOVE.W	$8(A0),D0
	MOVEP.W	D0,$7(A1)
;mouse on
	MOVE.B	#$8,$FFFFFC02.W
	MOVEM.L	(SP)+,D0-A6
	RTS


PLAY	MOVE.W	#$2700,SR
	MOVEM.L	D0/A0,-(SP)
;permutation des deux buffers
;de digit  de travail
	LEA	DIGIT_SWAP,A0
	MOVE.L	4(A0),D0
	MOVE.L	(A0),4(A0)
	MOVE.L	D0,(A0)
	LEA	GRRR(PC),A0
	MOVE.L	D0,2(A0)
	LEA	GRR(PC),A0
	MOVE.L	D0,2(A0)
	LEA	GR(PC),A0
	MOVE.L	D0,2(A0)
	MOVEM.L	(SP)+,D0/A0
	MOVE.W	#$2300,SR
;lit la partition et produit
;les effets sonores
	BSR	PLAYER
;calcule la digit a jouer
;a la prochaine vbl
	BSR	PRECALC_DIGIT
	RTS

PLAYER	MOVEM.L	D0-A6,-(SP)
	LEA	OFFSET,A4
	ADDQ.B	#$1,COUNTER(A4)
	MOVE.B	COUNTER(A4),D0
;effets sonore ou nouvelle
;lecture de la partition ?
	CMP.B	SPEED(A4),D0
	BLT.S	NONEW
	CLR.B	COUNTER(A4)
	BRA.S	READ_PATTERN

;produit les effets sonores
;sur les 4 voies
;commandes:0,1,2,3,4,A
NONEW	LEA	CHIP1,A5
	LEA	VOICE1,A6
	BSR	CHECK_COMMAND
	LEA	CHIP2,A5
	LEA	VOICE2,A6
	BSR	CHECK_COMMAND
	LEA	CHIP3,A5
	LEA	VOICE3,A6
	BSR	CHECK_COMMAND
	LEA	CHIP4,A5
	LEA	VOICE4,A6
	BSR	CHECK_COMMAND
	BRA	END_OF_PLAYER

;lit la partition pour les 4 voies
READ_PATTERN
	LEA	ST_CONNEXION(PC),A0
	MOVE.L	12(A0),A0
	LEA	$C(A0),A3
	LEA	(A0),A2
	ADD.W	POS(A4),A2
	ADD.W	PATT(A4),A0

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	SONGPOS(A4),D0
	MOVE.B	0(A2,D0.W),D1
	SWAP	D1
	LSR.L	#$6,D1
	ADD.W	PATTPOS(A4),D1

	LEA	CHIP1,A5
	LEA	VOICE1,A6
	BSR.S	PLAYVOICE
	LEA	CHIP2,A5
	LEA	VOICE2,A6
	BSR.S	PLAYVOICE
	LEA	CHIP3,A5
	LEA	VOICE3,A6
	BSR.S	PLAYVOICE
	LEA	CHIP4,A5
	LEA	VOICE4,A6
	BSR.S	PLAYVOICE
	BRA	SET_REPEAT

;routine qui traite une voie
PLAYVOICE
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	$2(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.S	SET_REGS
	MOVEQ	#0,D3
	LEA	SAMPLESTARTS,A1
	MOVE.L	D2,D4
	SUBQ.L	#$1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MULU	#$1E,D4
	MOVE.L	(A1,D2.L),$4(A6)
	MOVE.W	(A3,D4.L),$8(A6)
	MOVE.W	$2(A3,D4.L),$12(A6)
	MOVE.W	$4(A3,D4.L),D3
	BRA.S	NO_LOOP
	MOVE.L	$4(A1,D2.L),$4(A6)
	ADD.W	$6(A3,D4.L),D3
	MOVE.W	D3,$8(A6)
	ADD.W	D3,D3
	SUB.L	D3,$4(A6)
	MOVE.L	$4(A6),$A(A6)
	MOVEQ	#0,D3
	MOVE.W	$6(A3,D4.L),D3
	MOVE.W	D3,$E(A6)
	MOVE.W	$12(A6),$8(A5)
	BRA.S	SET_REGS
NO_LOOP
	MOVE.L	$4(A6),$A(A6)
	MOVE.W	$6(A3,D4.L),$E(A6)
	MOVE.W	$12(A6),$8(A5)
SET_REGS
	MOVE.W	(A6),D0
	AND.W	#$FFF,D0
	BEQ	CHECK_COMMAND_2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$3,D0
	BNE.S	SETPERIOD
	BSR	SET_PORTAMENTO_TONE
	BRA	CHECK_COMMAND_2
SETPERIOD
	MOVE.W	(A6),$10(A6)
	AND.W	#$FFF,$10(A6)
	CLR.B	$1B(A6)

	MOVE.L	$4(A6),(A5)
	MOVEQ	#0,D0
	MOVE.W	$8(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$4(A5)
	MOVE.W	$10(A6),$A(A5)
	BRA	CHECK_COMMAND_2

;active les repeat des 4 voies
SET_REPEAT
	MOVEQ	#0,D0
	LEA	CHIP1,A5
	LEA	VOICE1,A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP2,A5
	LEA	VOICE2,A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP3,A5
	LEA	VOICE3,A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)
	LEA	CHIP4,A5
	LEA	VOICE4,A6
	MOVE.L	$A(A6),$C(A5)
	MOVE.W	$E(A6),D0
	ADD.W	D0,D0
	MOVE.L	D0,$10(A5)

	ADD.W	#$10,PATTPOS(A4)
;nouveau pattern?
	CMP.W	#$400,PATTPOS(A4)
	BNE.S	END_OF_PLAYER
NEXT_PATT
	CLR.W	PATTPOS(A4)
	CLR.B	BREAK(A4)
	ADDQ.B	#1,SONGPOS(A4)
	AND.B	#$7F,SONGPOS(A4)
	MOVE.B	SONGPOS(A4),d1
	LEA	ST_CONNEXION(PC),A0
	MOVE.L	12(A0),A0
	ADD.W	POS(A4),A0
	CMP.B	-2(A0),d1
	BNE.S	END_OF_PLAYER
	CLR.B	SONGPOS(A4)
END_OF_PLAYER
	TST.B	BREAK(A4)
	BNE.S	NEXT_PATT
	MOVEM.L	(SP)+,D0-A6
	RTS

;effets sonores qui se produisent
;lorsqu'il ne faut pas lire la partition
CHECK_COMMAND
	MOVE.W	$2(A6),D0
	AND.W	#$FFF,D0
;pas de commande
	BEQ.S	NO_COMMAND
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	BEQ.S	ARPEGGIO
	CMP.B	#$1,D0
	BEQ	PORTAMENTO_UP
	CMP.B	#$2,D0
	BEQ	PORTAMENTO_DOWN
	CMP.B	#$3,D0
	BEQ	PORTAMENTO_TONE
	CMP.B	#$4,D0
	BEQ	VIBRATO
	MOVE.W	$10(A6),$A(A5)
	CMP.B	#$A,D0
	BEQ	VOLUME_SLIDE
NO_COMMAND
	RTS

;commande 0: arpeggio
ARPEGGIO
	MOVEQ	#0,D0
	MOVE.B	COUNTER(A4),D0
	DIVS	#$3,D0
	SWAP	D0
	CMP.W	#$0,D0
	BEQ.S	ARPEGGIO2
	CMP.W	#$2,D0
	BEQ.S	ARPEGGIO1

	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#$4,D0
	BRA.S	ARPEGGIO3
ARPEGGIO1
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	BRA.S	ARPEGGIO3
ARPEGGIO2
	MOVE.W	$10(A6),D2
	BRA.S	ARPEGGIO4
ARPEGGIO3
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	$10(A6),D1
	LEA	PERIODS(PC),A0
	MOVEQ	#$24,D7
ARPEGGIO_LOOP
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BGE.S	ARPEGGIO4
	LEA	2(A0),A0
	DBRA	D7,ARPEGGIO_LOOP
	RTS
ARPEGGIO4
	MOVE.W	D2,$A(A5)
	RTS

;commande 1: portamento up
PORTAMENTO_UP
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$71,D0
	BPL.S	PORTUP
	MOVE.W	#$71,$10(A6)
PORTUP	MOVE.W	$10(A6),$A(A5)
	RTS

;commande 2: portamento down
PORTAMENTO_DOWN
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$358,D0
	BMI.S	PORTDWN
	MOVE.W	#$358,$10(A6)
PORTDWN	MOVE.W	$10(A6),$A(A5)
	RTS

;met en place le portamento tone
SET_PORTAMENTO_TONE
	MOVE.W	(A6),D2
	AND.W	#$FFF,D2
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.S	CLR_PORTAMENTO_TONE
	BGE.S	OK_RTS
	MOVE.B	#$1,$16(A6)
	RTS
CLR_PORTAMENTO_TONE
	CLR.W	$18(A6)
OK_RTS
	RTS

;commande 3: portamento tone
PORTAMENTO_TONE
	MOVE.B	$3(A6),D0
	BEQ.S	MY_SLIDE
	MOVE.B	D0,$17(A6)
	CLR.B	$3(A6)
MY_SLIDE
	TST.W	$18(A6)
	BEQ.S	OK_RTS
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.S	MY_SUB
	ADD.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	MY_OK
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
MY_OK	MOVE.W	$10(A6),$A(A5)
	RTS
MY_SUB
	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	MY_OK
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	MOVE.W	$10(A6),$A(A5)
	RTS

;commande 4: vibrato
VIBRATO
	MOVE.B	$3(A6),D0
	BEQ.S	VIB
	MOVE.B	D0,$1A(A6)

VIB	MOVE.B	$1B(A6),D0
	LEA	SINUS(PC),A0
	LSR.W	#$2,D0
	AND.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	(A0,D0.W),D2
	MOVE.B	$1A(A6),D0
	AND.W	#$F,D0
	MULU	D0,D2
	LSR.W	#$6,D2
	MOVE.W	$10(A6),D0
	TST.B	$1B(A6)
	BMI.S	VIB_MIN
	ADD.W	D2,D0
	BRA.S	VIB2
VIB_MIN	SUB.W	D2,D0
VIB2	MOVE.W	D0,$A(A5)
	MOVE.B	$1A(A6),D0
	LSR.W	#$2,D0
	AND.W	#$3C,D0
	ADD.B	D0,$1B(A6)
	RTS

;commande $A: volume slide
VOLUME_SLIDE
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	VOLUME_DOWN
	ADD.W	D0,$12(A6)
	CMP.W	#$40,$12(A6)
	BMI.S	VOLUP_OK
	MOVE.W	#$40,$12(A6)
VOLUP_OK
	MOVE.W	$12(A6),$8(A5)
	RTS

VOLUME_DOWN
	MOVEQ	#0,D0
	MOVE.B	$3(A6),D0
	AND.B	#$F,D0
	SUB.W	D0,$12(A6)
	BPL.S	VOLDWN_OK
	CLR.W	$12(A6)
VOLDWN_OK
	MOVE.W	$12(A6),$8(A5)
	RTS

;commandes qui peuvent etre effectuees
;lors de la lecture de la partition
CHECK_COMMAND_2
	MOVE.B	$2(A6),D0
	AND.B	#$F,D0
	CMP.B	#$B,D0
	BEQ.S	POSITION_JUMP
	CMP.B	#$C,D0
	BEQ.S	SET_VOLUME
	CMP.B	#$D,D0
	BEQ.S	PATTERN_BREAK
	CMP.B	#$E,D0
	BEQ.S	SET_FILTER
	CMP.B	#$F,D0
	BEQ.S	SET_SPEED
;pas de commande
	RTS

;commande $B: postion jump
POSITION_JUMP
	MOVE.B	$3(A6),D0
	SUBQ.B	#$1,D0
	MOVE.B	D0,SONGPOS(A4)
	NOT.B	BREAK(A4)
	RTS

;commande $C: set volume
SET_VOLUME
	CMP.B	#$40,$3(A6)
	BLE.S	VOLUME_OK
	MOVE.B	#$40,$3(A6)
VOLUME_OK
	MOVE.B	$3(A6),$9(A5)
	RTS

;commande $D: pattern break
PATTERN_BREAK
	NOT.B	BREAK(A4)
	RTS

;commande $E: filter
;il n'est pas implemente ici
SET_FILTER
	RTS

;commande $F: set speed
SET_SPEED
	MOVE.B	$3(A6),D0
	AND.W	#$1F,D0
	BEQ.S	NO_CHANGE_SPEED
	CLR.B	COUNTER(A4)
	MOVE.B	D0,SPEED(A4)
NO_CHANGE_SPEED
	RTS


;precalcule la digit qui sera jouee
;lors de la prochaine vbl
PRECALC_DIGIT
	MOVEM.L	D0-A6,-(SP)
	LEA	VOLUME,A3
	LEA	FRQ,A4
	LEA	MEGABUFFER,A5
	LEA	CHIP1,A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+500,A5
	LEA	CHIP2,A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+1000,A5
	LEA	CHIP3,A6
	BSR.S	CALC_VOICE
	LEA	MEGABUFFER+1500,A5
	LEA	CHIP4,A6
	BSR.S	CALC_VOICE

	LEA	MEGABUFFER,A0
	LEA	500(A0),A1
	LEA	500(A1),A2
	LEA	500(A2),A3
	LEA	DIGIT_SWAP,A4
	MOVE.L	4(A4),A4
	BSR	MIX_ALL_VOICES
	MOVEM.L	(SP)+,D0-A6
	RTS

;calcul la digit pour une voie
CALC_VOICE
;adresse ins
	MOVE.L	$0(A6),A0
;valeur decimale du pointeur
	MOVEQ	#0,D1
;longueur du sample
	MOVE.L	$4(A6),D3
;volume
	MOVE.W	$8(A6),D4
	BEQ.S	.VOLUME_NUL
	SUBQ.W	#1,D4
.VOLUME_NUL
	LSL.W	#$8,D4
;repeat lenght
	MOVE.L	$10(A6),D6
;periode
	MOVE.W	$A(A6),D7
;*2
	ADD.W	D7,D7
;*2
	ADD.W	D7,D7
;periode.l
	MOVE.L	(A4,D7.W),D7
;.w bas de la periode
	MOVE.W	D7,D0
	SWAP	D7
	MOVEQ	#0,D2
;.w haut de la periode
	MOVE.W	D7,D2
	SWAP	D7
;repeat?
	TST.L	D6
	BNE.S	.0
;pas repeat -> frq=0
	CLR.L	D7
;adresse loop
.0	MOVE.L	$C(A6),A2

	MOVEQ	#FRQ_LOOP,D5
.PAULA
;partie decimale de la frequence
	SUB.W	D0,D1
;partie entiere de la frequence
;+retenue(s'il y a lieu)
	SUBX.W	D2,D3
;fin du sample ?
	BCS.S	.R1
.RR1
;charge le sample
	MOVE.B	0(A0,D3.L),D4
;charge sa correspondance avec le volume
	MOVE.B	0(A3,D4.W),(A5)+
;et on recommence
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R2
.RR2	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
	SUB.W	D0,D1
	SUBX.W	D2,D3
	BCS.S	.R3
.RR3	MOVE.B	0(A0,D3.L),D4
	MOVE.B	0(A3,D4.W),(A5)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
	DBRA	D5,.PAULA
	BRA.S	END_OF_CALC_A_VOICE

.R1	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR1
.R2	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR2
.R3	MOVE.L	D6,D3
	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.L	A2,A0
	BRA.S	.RR3
END_OF_CALC_A_VOICE
;adresse du sample a sauver
	MOVE.L	A0,$0(A6)
;position dans le sample a sauver
	MOVE.L	D3,$4(A6)
	RTS

;mixe les 4 voies
MIX_ALL_VOICES
	MOVEQ	#FRQ_LOOP,D1
.LOOP	MOVEQ	#0,D0
;v1
	MOVE.B	(A0)+,D0
;v1+v2
	ADD.B	(A1)+,D0
;v1+v2+v3
	ADD.B	(A2)+,D0
;v1+v2+v3+v4
	ADD.B	(A3)+,D0
;multiplie par 8
	LSL.W	#3,D0
;sauve le resultat pour etre execute
;la vbl d'apres
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD.B	(A1)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A3)+,D0
	LSL.W	#3,D0
	MOVE.W	D0,(A4)+
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD.B	(A1)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A3)+,D0
	LSL.W	#3,D0
	MOVE.W	D0,(A4)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
	DBRA	D1,.LOOP
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	MOVE.W	D0,(A4)+
	RTS

;gestion cartouche mv16
MV16
	MOVEM.L	D0/A0,-(SP)
GR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GR+4)(PC),A0
;incremente adresse du buffe
	ADD.W	#2,(A0)
	LEA	$FFFA0000,A0
;format octet pour la cartouche
;du type: %1111111111110
;13 bits avec les 12 bits de poids
;forts de significatif
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.B	0(A0,D0.W),D0
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

;gestion cartouche st replay
ST_REPLAY
	MOVEM.L	D0/A0,-(SP)
GRR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GRR+4)(PC),A0
;incremente adresse du buffer
	ADD.W	#2,(A0)
	LEA	$FFFA0000,A0
;format octet pour la cartouche
;du type: %111111110
;9 bits avec les 8 bits de poids
;forts de significatif
	LSR.W	#2,D0
	MOVE.B	0(A0,D0.W),D0
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

;gestion yamaha 2149
SOUNDCHIP
	MOVEM.L	D0/A0,-(SP)
GRRR	LEA	DIGIT,A0
;lit le mot de digit
	MOVE.W	(A0),D0
	LEA	(GRRR+4)(PC),A0
;incremente adresse du buffer
	ADD.W	#2,(A0)
;pointe sur la valeur de la table
;st replay pour le soundchip
	LEA	SOUND(PC,D0.W),A0
	MOVE.L	(A0)+,D0
	MOVE.L	(A0),$FFFF8800.W
	LEA	$FFFF8800.W,A0
	MOVEP.L	D0,(A0)
	MOVE.L	(SP)+,D0
	MOVE.L	(SP)+,A0
	RTE

;table st replay
;copyright 2-bit systems      microdeal
SOUND	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0
	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0
	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0
	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0
	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0
	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0
	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0
	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0
	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0
	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0
	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0
	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0
	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0
;table pour le vibrato
SINUS
 DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
 DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
;table pour l'arpeggio
PERIODS
 dc.w $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
 dc.w $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE
 dc.w $00F0,$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087
 dc.w $007F,$0078,$0071,$0000,$0000


;    ==== interruptions ====

vbl	movem.l	d0-a6,-(sp)
	movem.l	draw+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#0,$fffffa1b
	move.b	#22,$fffffa21
	move.b	#8,$fffffa1b
	move.l	#timer_b1,$120
	move.w	#$2300,sr
	
	clr.w	$ffff8240.w
	BSR	ST_CONNEXION+$8
	jsr	equalizs
	jsr	scroll
	jsr	deformation
	jsr	stars	
	jsr	init_star2	
	jsr	aff_txt

	movem.l	(sp)+,d0-a6

*	move.w	#7,$ffff8240.w
	rte
	
timer_b1	move.b	#0,$fffffa1b
	move.b	#16,$fffffa21
	move.w	#$144,$ffff8248
	move.w	#$377,$ffff8250
	move.l	#timer_ba,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte

timer_ba	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bb,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte

timer_bb	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	2(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bc,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bc	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	4(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bd,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bd	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	6(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_be,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_be	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	8(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bf,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bf	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	10(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bg,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bg	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	12(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bh,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bh	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	14(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bi,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte
timer_bi	move.b	#0,$fffffa1b
	move.b	#2,$fffffa21
	move.l	a0,-(sp)
	lea	rasters,a0
	move.w	16(a0),$ffff8242
	move.l	(sp)+,a0
	move.l	#timer_bj,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte

timer_bj	move.b	#0,$fffffa1b
	move.b	#158-36,$fffffa21
	move.w	#$531,$ffff8242
	move.w	#$642,$ffff8244
	move.w	#$753,$ffff8246
	move.w	#$531,$ffff824a
	move.w	#$642,$ffff824c
	move.w	#$753,$ffff824e
	move.w	#$531,$ffff8252
	move.w	#$642,$ffff8254
	move.w	#$753,$ffff8256

	move.l	#timer_b2,$120
	move.b	#8,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte

timer_b2	move.b	#0,$fffffa1b
	move.w	fond+4,$ffff8242.w
	move.w	fond+6,$ffff8244.w
	move.w	fond+8,$ffff8246.w
	move.w	fond+10,$ffff8248.w
	move.w	fond+12,$ffff824a.w
	move.w	fond+14,$ffff824c.w
	move.w	fond+16,$ffff824e.w
	move.w	#$112,$ffff8250.w
	move.w	fond+20,$ffff8252.w
	move.w	fond+22,$ffff8254.w
	move.w	fond+24,$ffff8256.w
	move.w	fond+26,$ffff8258.w
	move.w	fond+28,$ffff825a.w
	move.w	fond+30,$ffff825c.w
	move.w	fond+32,$ffff825e.w
	move.b	#0,$fffffa1b
	bclr.b	#0,$fffffa0f
	rte


	data


;    **** texte du scrolltext ****

text	dc.b	"YEAAAAH HERE IS LAURENZO FROM PASSWORDS/EUROSWAP...I'M PROUD TO PRESENT YOU THE EUROSWAP CD 963 WITH FIREHAWK, CRACKED BY CYNIX, MANCIOLA, A GOOD SHAREWARE REALISED BY AAZ, DARK PEARL ALSO SHAREWARE, AND DOCS....."
	DC.B	"...THANKS TO EAGLES FOR THIS"
	DC.B	" GOOD INTRO FOR EUROSWAP...EUROSWAP IS PASSWORDS AND EXO 7 UNION.."
	DC.B	".... GREETINGS TO : REPLICANTS, CLIMAX, ULTIMATE, EAGLES (THANKS), THUNDERBIRDS, TBO, POMPEY PIRATES, PULSION, EXTRACT, ABSTRACT, TRIO, ILLUMINATION, ATLANTIS, SUPREMACY, ZUUL, CYBERNETICS,"
	DC.B	"PIRACY SOFTWARE, ANIMAL MINE, HMD, SECTOR ONE, DNT CREW, RED BARONS, VMAX, BAD BOYS BELGIUM, NEXT, DIAMOND DESIGN....."
	DC.B	"...CONTACT US ON 3615 RTEL BAL PASSWORDS OR CLUB NOTARIUS PASS EURO........BYE.....SOON ON AMIGA AND FALCON........LET'S WRAP................"  	
end_text	

;    **** texte du message avec les petites fontes ****

; caracteres speciaux de ma routine :
; /  retour a la ligne
; - attend un peu
; * affiche un curseur

; LONGUEUR D'1 LIGNE :	"----------------------------------------/"

text1	dc.b	"        EUROSWAP CD )(' BY  LAURENZO      /"                                /"
	dc.b	"              -/"           
	dc.b	"                  F.  FIREHAWK     /"
	DC.B	"					/"
        DC.B        "                  F,  MANCIOLA     /"
	DC.B            "                 /" 
	DC.B	"                  F'  DARK PEARL   /"
	DC.B    "	/"
         ;DC.B    "        F: /"
	dc.b	"//////////"
end_text1

;    **** Le nom des progs a charger : ****

soft1	dc.b	"1.",0
soft2	dc.b	"2.",0
soft3           DC.B	"3.",0 
soft4           DC.B	"4.PRG",0 
soft5           DC.B	"5.PRG",0 
soft6           DC.B	"6.PRG",0 
soft7           DC.B	"7.PRG",0 
soft8           DC.B	"8.PRG",0 
soft9           DC.B	"9.PRG",0 
soft10          DC.B	"10.PRG",0 




; *************************************************************
	even

adr_endtxt1	dc.l	0
adr_scr1	dc.l	0
count1	dc.l	0
count2	dc.l	0

fonte1	incbin	a:\INTRO_CD.7\fontes.pi1
fond	incbin	a:\INTRO_CD.7\fond.pi1
old_vbl	dc.l	0
old_tb	dc.l	0
OFFSET	DCB.W	$6,0
SPEED	EQU	$0
SONGPOS	EQU	$1
PATTPOS	EQU	$2
COUNTER	EQU	$4
BREAK	EQU	$5
POS	EQU	$6
PATT	EQU	$8
NBR	EQU	$A
SAMPLESTARTS	DCB.L	$20,0
VOICES	DCB.L	$1C,0
VOICE1	EQU	VOICES
VOICE2	EQU	VOICES+$1C
VOICE3	EQU	VOICES+$38
VOICE4	EQU	VOICES+$54
CHIP	DCB.L	$18
CHIP1	EQU	CHIP
CHIP2	EQU	CHIP+$18
CHIP3	EQU	CHIP+$30
CHIP4	EQU	CHIP+$48
NO_INS	DC.W	$8080
MEGABUFFER	DCB.L	500
DIGIT	DCB.W	500*2
DIGIT_SWAP	DCB.L	2,0
FRQ_LOOP	EQU	49
FRQ_DATA	EQU	82
;Voici les valeurs pour changer de frequence
;Frequences 14Khz  12.3Khz  10.1Khz  8.5Khz  7.5Khz
;Frq_loop   92     81       61       72      49
;Frq_data   44     50       66       56      82
FRQ	DC.L	0
	INCBIN	a:\INTRO_CD.7\14_KHZ.FRQ		;table cr‚‚e par 14_khz.gfa
				;pour les autres fr‚quences
				;changer les valeurs a%(Timer
				;A Control Register) et b%
				;(Timer A Data Register).
YET	DC.L	0
VOLUME	INCBIN	a:\INTRO_CD.7\VOLUME.BIN		;table cr‚‚e par volume.gfa

MUSIC	INCBIN	a:\INTRO_CD.7\HEAVY2.MOD
draw	incbin	a:\INTRO_CD.7\equalizs.pi1
old_etat1	dc.l	0
old_etat2	dc.l	0
old_etat3	dc.l	0
old_etat4	dc.l	0

env	dc.b	0,0
logo	incbin	a:deform1.pi1
courbe	incbin	a:\INTRO_CD.7\courbe2.jps
fin_courbe
	incbin	a:\INTRO_CD.7\courbe2.jps
clr_registers	dcb.l	32,0	
count_courbe	dc.l	courbe
tab	ds.w	25
rasters	dc.w	$5,$6,$7,$107,$207,$307,$407,$507,$607,$707
wings	incbin	a:\INTRO_CD.7\ltlfonte.PI1
adr_text2	dc.l	0
adr_endtxt2	dc.l	0
position2	dc.l	0
adr_lettre2	dc.l	0
addition_x2	dc.l	0
addition_y2	dc.l	0
testi2	dc.w	0

during_load	dc.b	"//"
	dc.b	"         LOADING   PLEASE WAIT       /"
end_load
	bss
	
code1	ds.w	20000
colors	ds.w	16
buf1	ds.w	2*30
stack	ds.l	1
