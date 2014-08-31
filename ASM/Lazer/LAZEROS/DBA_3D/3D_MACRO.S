; --------------------------------------------------------------------
generate_object_list MACRO
	lea	object_list(PC),a0
	lea	object_center+2(PC),a1
	moveq	#-1,d7
	lea	world(PC),a6
.loop   tst.l	(a6)
	bmi.s	.end
	move.l	a6,(a0)+
	movem.w	8(a6),d0-d2
	movem.w	d0-d2,(a1)
	addq	#8,a1
	addq	#1,d7
	lea	20(a6),a6
	bra.s	.loop
.end	lea	object_center(PC),a1
	move.w	d7,(a1)
	moveq	#-1,d7
	move.l	d7,(a0)+
	ENDM
; --------------------------------------------------------------------
clrscr	MACRO
	move.w	#15*64*32+15*64+15,d6
	swap	d6
	move.w	#15*64*32+15*64+15,d6
	
		
	move.l	scr1(PC),a6
	moveq	#0,d7
	move.w	ysize(PC),d1
	lsr.w	#1,d1
.y\@	move.w	#80-1,d0
.x\@
*	move.l	(a6),d7
*	lsr.l	#1,d7
*	and.l	d6,d7
	move.l	d7,SCRW*2(a6)
	move.l	d7,(a6)+
	move.l	d7,SCRW*2(a6)
	move.l	d7,(a6)+
	dbf	d0,.x\@
	lea	SCRW*2+(SCRW-320)*2(a6),a6
	dbf	d1,.y\@
*	rts
	ENDM
; --------------------------------------------------------------------
clrscr2	MACRO
	move.w	#15*64*32+15*64+15,d6
	swap	d6
	move.w	#15*64*32+15*64+15,d6
	
		
	move.l	scr1(PC),a6
	moveq	#0,d7
	move.w	ysize(PC),d1
	lsr.w	#1,d1
.y\@	move.w	#80-1,d0
.x\@
	move.l	(a6),d7
	lsr.l	#1,d7
	and.l	d6,d7
	move.l	d7,SCRW*2(a6)
	move.l	d7,(a6)+
	move.l	d7,SCRW*2(a6)
	move.l	d7,(a6)+
	dbf	d0,.x\@
	lea	SCRW*2+(SCRW-320)*2(a6),a6
	dbf	d1,.y\@
*	rts
	ENDM
; --------------------------------------------------------------------
create_invers_tab MACRO
	lea	invers_tab(PC),a0
	lea	384*2*2(a0),a0
	move.w	#384*2-1,d7
.l\@:	move.l	#$7fff,d1
	divu	d7,d1
	move.w	d1,-(a0)
	dbf	d7,.l\@
*	rts
	ENDM
; --------------------------------------------------------------------
; -> a0 : colortab
;    d0,d1,d2: rgb
generate_colortab:
	pusha
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#31,d7
.l0:	movem.l	d3-d5,-(sp)
	lsr.w	#5,d3
	lsr.w	#5,d4
	lsr.w	#5,d5
	lsl.w	#5,d3
	or.w	d4,d3
	lsl.w	#6,d3
	or.w	d5,d3
	move.w	d3,(a0)+
	movem.l	(sp)+,d3-d5
	add.w	d0,d3
	add.w	d1,d4
	add.w	d2,d5
	dbf	d7,.l0
	popa
	rts
; --------------------------------------------------------------------
; d5 RND-Startwert
; d6 x-size-1
; d7 y-size-2
; a0 Zielbereich
; a1 Farbtabelle
marmor:	pusha
	move.l	a0,a2
	move.w	d6,d0
	move.w	d5,d1
	and.w	#15,d1
.l0:	rnd	d5
	move.w	d5,d2
	and.w	#15,d2
	btst	#3,d2
	beq.s	.w1
	and.w	#7,d2
	neg.w	d2
.w1:	add.w	d2,d1
	bpl.s	.w3
	moveq	#0,d1
.w3:	cmp.w	#15,d1
	ble.s	.w2
	moveq	#15,d1
.w2: 	add.w	#15,d1
	move.b	d1,(a2)+
	dbra	d0,.l0

	subq.w	#1,a0
.l1:	move.w	d6,d0
.l2:	rnd	d5
	move.w	d5,d1
	and.w	#15,d1
	btst	#3,d1
	beq.s	.w0
	and.w	#7,d1
	neg.w	d1
.w0:	add.b	(a0)+,d1
	add.b	(a0),d1
	asr.b	#1,d1
	tst.b	d1
	bpl.s	.w4
	moveq	#0,d1
.w4:	cmp.b	#31,d1
	ble.s	.w5
	moveq	#31,d1
.w5:	move.b	d1,(a2)+
	dbra	d0,.l2
	dbra	d7,.l1
	movem.l	(sp),d0-a6
	addq.w	#1,d6
	addq.w	#2,d7
	mulu.w	d6,d7
	lea	(a0,d7.w*2),a2
	add.l	d7,a0
	moveq	#0,d1
	subq.w	#1,d7
.l3:	move.b	-(a0),d1
	and.w	#31,d1
	move.w	(a1,d1.w*2),-(a2)
	dbra	d7,.l3
	popa
	rts
; --------------------------------------------------------------------
z_sorting:
	generate_object_list
	movem.w	world_alpha(PC),d0-d2
	lea	rotate_offset_x,a0
	clr.l	(a0)+
	clr.w	(a0)
	lea	object_center(PC),a3
	move.l	a3,a4
	bsr	rotate_points

	lea	object_list(PC),a0
	lea	object_center(PC),a1
	bsr	do_sorting
	rts

; --------------------------------------------------------------------
; Tiefensortierung
do_sorting:
	move.w	(a1),d0
	ble.s	.no
	move.l	a0,a2
	move.l	a1,a3
	addq.w	#2+4,a3
.outer_loop
	move.l	a2,a0
	move.l	a3,a1
	moveq	#0,d7
.inner_loop
	tst.l	4(a0)
	bmi.s	.ok
	move.w	(a1),d0
	move.w	8(a1),d1
	cmp.w	d1,d0
	ble.s	.no_swap
	move.l	(a0),d2
	move.l	4(a0),(a0)
	move.l	d2,4(a0)
	move.w	d0,8(a1)
	move.w	d1,(a1)
	moveq	#-1,d7
.no_swap
	addq	#4,a0
	addq	#8,a1
	bra.s	.inner_loop
.ok	tst.w	d7
	bne	.outer_loop
.no     rts

colors:	dc.w	31,31,31
	dc.w	31,24,8
; --------------------------------------------------------------------

; a0 Zielspiecher fr die Spline-Werte
; a1 Spline-Sttzpunkte
; d0 Counter (0-$7fff)
; d6 dimension der Spline-1 (normal 2-1)
	IFNE 1
spline:
	moveq	#15,D7
.l0:	lea	tbuff(PC),A2
	move.l	D0,D1
	eori.w	#$7FFF,D0 ; t2%   d1
	move.w	D0,D2
	move.w	D1,D3
	mulu	D0,D2
	lsr.l	D7,D2   ; t_2
	move.w	D2,D4
	mulu	D0,D4
	lsr.l	D7,D4   ; t_3  >>1
	move.w	D4,(A2)+
	move.w	D1,D4
	mulu	D2,D4
	lsr.l	D7,D4   ; 3*t_2_m_t2 >>2
	move.w	D4,(A2)+
	mulu	D1,D3
	lsr.l	D7,D3
	move.w	D3,D4
	mulu	D0,D4
	lsr.l	D7,D4   ; 3*t_m_t2_2 >>3
	move.w	D4,(A2)+
	mulu	D1,D3
	lsr.l	D7,D3   ; t2_3 >>4
	move.w	D3,(A2)+
.l1:	lea	tbuff(PC),A2
	move.w	(A2)+,D1
	muls	(A1)+,D1
	REPT	2
	move.w	(A2)+,D2
	muls	(A1)+,D2
	muls.l	#3,D2
	add.l	D2,D1
	ENDR
	move.w	(A2)+,D2
	muls	(A1)+,D2
	add.l	D2,D1
	add.l	D1,D1
	swap	D1
	move.w	D1,(A0)+
	dbra	D6,.l1
	rts
	ENDC

splines: dc.l d_spline,b_spline,a_spline,world_spline
splineposcnt: dc.w  4

cls2ok:	dc.w	0

ofs	EQU	250

d_spline:
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	100+3*ofs,100+1*ofs,100,100
	dc.w	1380,1100,870,640
	dc.w	0,0,0,0
	dc.w	0,0,0,0
; 2. Spline...
	dc.w	0,0,0,-115
	dc.w	0,0,0,0
	dc.w	200-100,200-100,100-100,0-100
	dc.w	640,420,210,0
	dc.w	0,0,0,128
	dc.w	0,0,0,0
; 3. Spline
	dc.w	-115,-115,-115,-115
	dc.w	0,0,0,0
	dc.w	-100,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

	dc.w	-115,-115,-115,-115
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0
; 4. Spline
	dc.w	-115,-115,-115,-115
	dc.w	0,0,0,0
	dc.w	0,0,200,500
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

b_spline:
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	-100+3*ofs,-100+1*ofs,-100,-100
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
; 2. Spline
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0-100,0-100,0-100,0-100
	dc.w	0,0,0,0
	dc.w	0,0,0,128
	dc.w	0,0,0,0
; 3. Spline
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	-100,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0
; 4. Spline
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,200,500
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

a_spline:
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	-300+3*ofs,-300+1*ofs,-300,-300
	dc.w	-1380,-1100,-870,-640
	dc.w	0,0,0,0
	dc.w	0,0,0,0
; 2. Spline
	dc.w	0,0,0,130
	dc.w	0,0,0,0
	dc.w	-200-100,-200-100,-100-100,0-100
	dc.w	-640,-420,-210,0
	dc.w	0,0,0,128
	dc.w	0,0,0,0
; 3. Spline
	dc.w	130,130,130,130
	dc.w	0,0,0,0
	dc.w	-100,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

	dc.w	130,130,130,130
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

; 4. Spline
	dc.w	130,130,130,130
	dc.w	0,0,0,0
	dc.w	0,0,200,500
	dc.w	0,0,0,0
	dc.w	128,128,128,128
	dc.w	0,0,0,0

world_spline:
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0

	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0

	dc.w	0,20,50,90
	dc.w	0,0,0,0
	dc.w	0,20,50,90

	dc.w	90,140,200,256
	dc.w	0,0,0,0
	dc.w	90,140,200,256
	
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
