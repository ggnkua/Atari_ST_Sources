 	OUTPUT	h:\dba\3d.PRG

	jmp	main
	bra	init_rout
	bra	exit_rout
	bra	do_once
	bra	do_vbl

LS = 0
;-----------------------------------------------------------
	include startup.s
	include	demo.s
;-----------------------------------------------------------
BLITTER = $ffff8a00

HALFTONE	= 0
SRC_XINC	= 32
SRC_YINC	= 34
SRC_ADDR	= 36
ENDMASK1	= 40
ENDMASK2	= 42
ENDMASK3	= 44
DST_XINC	= 46
DST_YINC	= 48
DST_ADDR	= 50
X_COUNT		= 54
Y_COUNT		= 56
HOP		= 58
OP		= 59
LINE_NUM	= 60
SKEW		= 61

FHOP_SOURCE	= 1
FHOP_HALFTONE	= 0
FSKEWFXSR	= 7
FSKEWNFSR	= 6
FLINEBUSY	= 7
FLINEHOG	= 6
FLINESMUDGE	= 5

MHOP_SOURCE	= $02
MHOP_HALFTONE	= $01
MSKEWFXSR	= $80
MSKEWNFSR 	= $40
MLINEBUSY	= $80
MLINEHOG	= $40
MLINESMUDGE	= $20


;-----------------------------------------------------------
rnd	MACRO
	rol.l	#5,\1
        eori.l  #$C5A175C5,\1
	addq.l	#1,\1
	ENDM

SCRW 	equ 	320+256

	include	3d_macro.s
;-----------------------------------------------------------
main
	shrink_memory

	bsr	init
	save_stack
	bsr	phoenix_init

	save_interrupts
	set_interrupts

	move.w	#256,$ffff820e

*	bsr	init_stars		; Sterne berechnen
	bsr	sin_gen
	create_invers_tab
	bsr	setup_texture

.main_loop
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	scr3,scr2
	move.l	d0,scr3
	setscreen
*	vsync
	
	bsr	do_dba

	tst.w	exit_flag
	beq.s	.exit

	move.b	key,old_key
	move.b	$fffffc02.w,key
	cmp.b	#$39,key
	bne	.main_loop

.exit

	restore_interrupts
	bsr	phoenix_exit
	restore_stack
	bsr	exit
	terminate
;-----------------------------------------------------------
init_rout
	move.l	a0,parameters

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2

	rts
;-----------------------------------------------------------
exit_rout
	rts
;-----------------------------------------------------------
do_once
	move.l	parameters,a0
	move.w	#2,SCREEN_COUNT(a0)
	move.w	#TRUE,SCREEN_SWAP(a0)

	move.l	parameters,a0
	move.w	#FALSE,PALETTE_UPDATE(a0)
	*move.l	#coltab1,PALETTE(a0)
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2
	bsr	clrscr

	move.w	#256,$ffff820e

	move.l	parameters,a0
	lea	rgb_320x240x256_cin,a1
	move.l	a1,SCRMODE(a0)
	move.w	#TRUE,SCRMODE_UPDATE(a0)

ll	bra.s	ll

;-----------------------------------------------------------
do_vbl
	move.l	parameters,a0
	lea	rgb_320x200xtrue,a1
	move.l	a1,SCRMODE(a0)
	move.w	#TRUE,SCRMODE_UPDATE(a0)

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2

	move.w	#TRUE,PALETTE_UPDATE(a0)
	move.l	#colors,PALETTE(a0)
	
	
	demo_swapscreens

	rts
;-----------------------------------------------------------
;-> a0...palette
set_palette

	lea	coltab3,a1
	move.w	#155,d0
.1	move.l	(a1)+,(a0)+
	dbf	d0,.1

	rts
;-----------------------------------------------------------
do_dba

	lea	scr1(PC),a0
	movem.l	(a0),d0-d2		; Bildschirme vertauschen
	exg	d0,d1
	exg	d1,d2
	movem.l	d0-d2,(a0)
	move.b	d2,d1
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)
	move.b	d1,12(a0)

*	lea	oldysize(PC),a0
*	cmp.w	#99,(a0)		; Doublescan bearbeiten...
*	beq.s	.double
*	bclr	#0,$ffff82c3.w
	bra.s	.no_double
.double
	bset	#0,$ffff82c3.w
.no_double
	move.w	ysize(PC),(a0)


	cmp.w	#2,splineposcnt
	ble.s	.docls2
.docls:
	clrscr				; Bildschirm l”schen
	bra.s	.nocls2
.docls2:subq.w	#1,cls2ok
	cmp.w	#-2,cls2ok
	bge.s	.docls
	clrscr2
.nocls2:

; a0 Zielspiecher fr die Spline-Werte
; a1 Spline-Sttzpunkte
; d0 Counter (0-$7fff)
; d6 dimension der Spline-1 (normal 2-1)
;~
	lea	splines,a6

	lea	pos_d,a0
	move.l	(a6)+,a1
	move.w	splinecnt,d0
	moveq	#6-1,d6
	bsr	spline

	lea	pos_b,a0
	move.l	(a6)+,a1
	move.w	splinecnt,d0
	moveq	#6-1,d6
	bsr	spline

	lea	pos_a,a0
	move.l	(a6)+,a1
	move.w	splinecnt,d0
	moveq	#6-1,d6
	bsr	spline

	lea	world_alpha,a0
	move.l	(a6)+,a1
	move.w	splinecnt,d0
	moveq	#3-1,d6
	bsr	spline

	add.w	#$350,splinecnt
	tst.w	splinecnt
	bpl.s	.splok
	lea	splines,a0
	REPT	3
	add.l	#8*6,(a0)+
	ENDR
	add.l	#8*3,(a0)+
	subq.w	#1,splineposcnt
	tst.w	splineposcnt
	bpl.s	.splok
	move.w	#4,splineposcnt
	sub.l	#8*3*5,-(a0)
	REPT	3
	sub.l	#8*6*5,-(a0)
	ENDR
	clr.w	cls2ok
.splok:
	and.w	#$7fff,splinecnt


	IFNE 1
	bsr	z_sorting			; Objekte
	lea	object_list(PC),a5
.object_loop:
	tst.l	(a5)
	bmi.s	.object_end

	move.l	(a5)+,a6
; -----------------------------	rotate points
	movem.w	8(a6),d0-d2		; rotate offset
	lea	rotate_offset_x(PC),a3
	movem.w	d0-d2,(a3)
	movem.w	14(a6),d0-d2		; angle
	move.l	(a6),a3			; points
	lea	temppoints,a4
	bsr	rotate_points
	movem.w	world_alpha(PC),d0-d2
	lea	rotate_offset_x(PC),a3
	clr.l	(a3)+			; x,y
	clr.w	(a3)			; z
	lea	temppoints,a3
	lea	newpoints,a4
	bsr	rotate_points

	lea	newpoints,a0
	bsr	perspective

	move.l	4(a6),a0		; polys
	pusha
	bsr	do_poly
	popa

	lea	20(a6),a6		; next object
	bra	.object_loop
.object_end:
	ENDC
	
	eor.w	#-1,hochflag	

	rts
;-----------------------------------------------------------
setup_texture

	lea	colors(PC),a6
	lea	texture,a5
	moveq	#2-1,d4
gentextures_l0:
	lea	colortab(PC),a0		; Texturen berechnen
	move.w	(a6)+,d0
	move.w	(a6)+,d1
	move.w	(a6)+,d2
	bsr	generate_colortab
	move.l	#$123678,d5
	move.w	#32-1,d6
	move.w	#32-2,d7
	lea	block(PC),a0
	lea	colortab(PC),a1
	bsr	marmor
	move.l	a5,a0
	bsr	init_texture
	add.l	#4*32*256*2,a5
	dbra	d4,gentextures_l0

	rts
;-----------------------------------------------------------
generate_object_list
	lea	object_list(PC),a0
	lea	object_center+2(PC),a1

	moveq	#-1,d7
	lea	world(PC),a6
.loop
	tst.l	(a6)
	bmi.s	.end

	move.l	a6,(a0)+

	movem.w	8(a6),d0-d2
	movem.w	d0-d2,(a1)
	addq	#8,a1

	addq	#1,d7
	lea	20(a6),a6
	bra.s	.loop
.end
	lea	object_center(PC),a0
	move.w	d7,(a0)

	move.l	#-1,(a0)+
	rts
; --------------------------------------------------------------------
init_texture
	pusha
	lea	pic+8,a1
	moveq	#31,d7
.y	moveq	#31,d6
.x	
	move.l	a0,a2
	moveq	#0,d5

	moveq	#3,d4
.coly
	moveq	#7,d3
.colx
	move.w	(a1),d2
	move.w	d2,d1
	lsr.w	#6,d1
	move.w	d1,d0
	lsr.w	#5,d0
	and.w	#$1f,d0
	and.w	#$1f,d1
	and.w	#$1f,d2
	mulu	d5,d0
	mulu	d5,d1
	mulu	d5,d2
	lsr.w	#5,d0
	lsr.w	#5,d1
	lsr.w	#5,d2
	lsl.w	#5,d0
	or.w	d1,d0
	lsl.w	#6,d0
	or.w	d2,d0

	move.w	d0,(a2)
	lea	32*2(a2),a2

	addq	#1,d5

	dbf	d3,.colx
	lea	31*256*2(a2),a2
	dbf	d4,.coly

	addq	#2,a0
	addq	#2,a1
	
	dbf	d6,.x
	lea	(256-32)*2(a0),a0
	dbf	d7,.y
	popa
	rts
; --------------------------------------------------------------------
; -> a0 : Poly Daten
do_poly
	pusha
	move.l	a0,a6
	bsr	face_z_sorting
	popa

	lea	newpoints,a1
	addq	#2,a1

	lea	face_list,a6
.poly_loop
	tst.l	(a6)
	bmi	.end
	move.l	(a6)+,a0

	moveq	#0,d0	
	move.b	(a0)+,d0
	lea	intensity(PC),a4
	move.w	d0,(a4)

	moveq	#0,d7
	move.b	1(a0),d7
	movem.w	(a1,d7.w*8),d0-d1
	move.b	1+2(a0),d7
	movem.w	(a1,d7*8),d2-d3
	move.b	1+1(a0),d7
	sub.w	(a1,d7.w*8),d0
	sub.w	(a1,d7.w*8),d2
	sub.w	2(a1,d7.w*8),d1
	sub.w	2(a1,d7.w*8),d3
	muls	d3,d0
	muls	d2,d1
	sub.l	d1,d0
	tst.l	d0
	bmi.s	.clipping
	moveq	#0,d7
	move.b	(a0)+,d7
	lea	2(a0,d7.w),a0
	bra	.not_visible

; -----------------------------	check clipping
.clipping
	lea	brightness(PC),a4
	move.w	d0,(a4)

	move.l	a0,-(sp)
	moveq	#-1,d3
	moveq	#0,d7
	move.b	(a0)+,d7
.check
	moveq	#0,d6
	move.b	(a0)+,d6
	movem.w	(a1,d6.w*8),d0-d2
	add.w	#160,d0
	add.w	#100,d1
	tst.w	d0
	bmi.s	.not_inside
	tst.w	d1
	bmi.s	.not_inside
;~
*	tst.w	d2
	sub.w	#256,d2
	bpl.s	.not_inside

	cmp.w	#319,d0
	bgt.s	.not_inside
	cmp.w	#199,d1
	bgt.s	.not_inside
	moveq	#0,d3
.not_inside
	dbf	d7,.check
	move.l	(sp)+,a0

	tst.w	d3
	beq.s	.visible

	IFNE 0
	not.l	$ffff9800.w
	ENDC

	moveq	#0,d7
	move.b	(a0)+,d7
	lea	2(a0,d7.w),a0
	bra	.not_visible

.visible
	move.w	brightness(PC),d0
	neg	d0
	lsr.w	#3+2,d0
	cmp 	#31,d0
	ble.s	.w1
	moveq	#31,d0
.w1	
	move.w	intensity(PC),d1
	lsl.w	#5,d1
	add.w	d1,d0

 IIF LS	MOVEQ	#31,d0
	moveq	#0,d1
	move.w	d0,d1
	and.w	#7,d0
	lsl.w	#6,d0
	lsr.w	#3,d1
	lsl.l	#6,d1
	lsl.l	#8,d1
	add.w	d0,d1
	lea	intensity(PC),a2
	move.l	d1,(a2)

	lea	min_y(PC),a2
	move.w	#200,(a2)+		; miny
	move.w	#0,(a2)			; maxy

	lea	coords,a2

	moveq	#0,d7
	move.b	(a0)+,d7
	move.l	(a2,d7.w*4),a2
.line_loop
	move.l	d7,-(sp)

	moveq	#0,d6
	move.b	(a0)+,d6
	movem.w	(a1,d6.w*8),d0-d1
	move.w	(a2)+,d4
	move.w	(a2)+,d5
	move.b	(a0),d6
	movem.w	(a1,d6.w*8),d2-d3
	move.w	(a2),d6
	move.w	2(a2),d7

	movem.l	d0/a0-a2,-(sp)
	bsr	calc_line
	movem.l	(sp)+,d0/a0-a2

	move.l	(sp)+,d7

	dbf	d7,.line_loop
	addq	#1,a0

	movem.l	d0/a0-a2,-(sp)
	bsr	show_poly
	movem.l	(sp)+,d0/a0-a2

.not_visible
	bra	.poly_loop
.end
	rts

coords	equ	*-8
	dc.l	eckpts3,eckpts4,eckpts5,eckpts6,eckpts7,eckpts8
	dc.l	eckpts9,eckpts10,eckpts11

	include	old\eckpts.s

;-----------------------------------------------------------
; -> a3 : source points
;    a4 : dest points
rotate_points:
	and.w	#$ff,d0
	and.w	#$ff,d1
	and.w	#$ff,d2
	lea	sinus(PC),a0
	move.l	a0,a1
	move.l	a0,a2

	lea	(a0,d0.w*2),a0
	lea	(a1,d1.w*2),a1
	lea	(a2,d2.w*2),a2

	moveq	#15,d6
	move.w	(a3)+,d7
	move.w	d7,(a4)+
.loop
	movem.w	(a3)+,d0-d3
	move.w	d0,d3
	move.w	d1,d4
	muls	(a0),d3		; sinus*x
	muls	64*2(a0),d4	; cosinus*y
	muls	(a0),d1		; sinus*y
	muls	64*2(a0),d0	; cosinus*x
	sub.l	d1,d0
	add.l	d3,d4
	move.l	d4,d1
	asr.l	d6,d0
	asr.l	d6,d1

	move.w	d1,d3
	move.w	d2,d4
	muls	(a1),d3		; sinus*x
	muls	64*2(a1),d4	; cosinus*y
	muls	(a1),d2		; sinus*y
	muls	64*2(a1),d1	; cosinus*x
	sub.l	d2,d1
	add.l	d3,d4
	move.l	d4,d2
	asr.l	d6,d1
	asr.l	d6,d2

	move.w	d2,d3
	move.w	d0,d4
	muls	(a2),d3		; sinus*x
	muls	64*2(a2),d4	; cosinus*y
	muls	(a2),d0		; sinus*y
	muls	64*2(a2),d2	; cosinus*x
	sub.l	d0,d2
	add.l	d3,d4
	move.l	d4,d0
	asr.l	d6,d0
	asr.l	d6,d2

	add.w	rotate_offset_x(PC),d0
	add.w	rotate_offset_y(PC),d1
	add.w	rotate_offset_z(PC),d2

	movem.w	d0-d2,(a4)
	lea	8(a4),a4

	dbf	d7,.loop
	rts

rotate_offset_x:	dc.w	0
rotate_offset_y:	dc.w	0
rotate_offset_z:	dc.w	0
; --------------------------------------------------------------------
; -> a0 : source points
perspective:

	move.w	#-300,d6		; proz_z

	move.w	(a0)+,d7
.loop
	movem.w	(a0),d0-d2
	neg.w	d2

	move.w	d6,d5			; proz_z - z
	sub.w	d2,d5

	move.w	d0,d3			; x*z
	muls	d2,d3
	divs	d5,d3			; x*z/(proz_z-z1)
	add.w	d3,d0			; x*z/(proz_z-z1)+x

	move.w	d1,d3			; x*z
	muls	d2,d3
	divs	d5,d3			; x*z/(proz_z-z1)
	add.w	d3,d1			; x*z/(proz_z-z1)+x

	move.w	d6,d5
	asr.w	#6,d5    ;****
	tst.s	hochflag
	beq.s	.w0
	neg.w	d5
.w0:
*	add.w	d5,d1	 ;****

	movem.w	d0-d1,(a0)
	lea	8(a0),a0
	dbf	d7,.loop
	rts
hochflag: dc.w 0
; --------------------------------------------------------------------
; -> d0,d1 : start x, start y
;    d2,d3 : end x, end y
calc_line:
	lea	line_buffer+300*32*2,a0

	move.w	ysize(PC),a2
	cmp.w	#99,a2
	bne.s	.a
	asr.w	#1,d1
	asr.w	#1,d3
.a:
	exg	a2,d7
	lsr.w	#1,d7
	add.w	d7,d1
	add.w	d7,d3
	exg	a2,d7

	cmp	d1,d3
	bgt.s	.ok
	exg	d0,d2
	exg	d1,d3
	exg	d4,d6
	exg	d5,d7
	addq	#8,a0
.ok
	lea	min_y(PC),a3
	cmp.w	(a3),d1
	bgt.s	.1
	move.w	d1,(a3)
.1
	lea	max_y(PC),a3
	cmp.w	(a3),d3
	blt.s	.2
	move.w	d3,(a3)
.2

	sub.w	d0,d2
	sub.w	d1,d3
	sub.w	d4,d6
	sub.w	d5,d7
	add.w	#160,d0

	asl.w	#6,d1
	lea	(a0,d1.w),a0
	move.l	a0,a1

	lea	invers_tab(PC),a2
	muls	(a2,d3.w*2),d2
	add.l	d2,d2
	muls	(a2,d3.w*2),d6
	add.l	d6,d6
	muls	(a2,d3.w*2),d7
	add.l	d7,d7

	ext.l	d0
	ext.l	d4
	ext.l	d5
	
	move.w	d7,a1
	move.w	d2,d7
	move.w	d6,d2
	move.w	a1,d6
	swap	d2
	swap	d6
	swap	d7
	
	subq	#1,d3
	bmi.s	.no
.yloop
	move.w	d0,(a0)
	move.w	d4,2(a0)
	move.w	d5,4(a0)
	addx.l	d2,d0
	addx.l	d6,d4
	addx.l	d7,d5
	lea	32*2(a0),a0
	dbf	d3,.yloop
.no
	rts
min_y	dc.w	0
max_y	dc.w	0
; --------------------------------------------------------------------
show_poly:
	lea	line_buffer+300*32*2,a0
	move.l	scr1(PC),a2

	move.w	min_y(PC),d0
	tst.w	d0
	bpl.s	.0
	moveq	#0,d0
.0
	move.w	max_y(PC),d7
	cmp.w	ysize(PC),d7
	blt.s	.1
	move.w	ysize(PC),d7
.1
	sub	d0,d7
	subq	#1,d7
	bmi	.no_poly
	move.w	d0,d1
	muls	#SCRW*2,d1
	add.l	d1,a2
	asl.w	#6,d0
	add.w	d0,a0

	lea	texture,a5
	add.l	intensity(PC),a5
	
.yloop
	move.w	(a0),d0
	move.w	8(a0),d1
	move.w	2(a0),d2
	move.w	4(a0),d3
	move.w	10(a0),d4
	move.w	12(a0),d5

	cmp	d0,d1
	bgt.s	.ok
	exg	d0,d1
	exg	d2,d4
	exg	d3,d5
.ok	
	sub.w	d0,d1
	sub.w	d2,d4
	sub.w	d3,d5

	asr.w	#1,d3

	lea	invers_tab(PC),a3
	muls	(a3,d1.w*2),d4
	asl.l	#1,d4
	muls	(a3,d1.w*2),d5
	asl.l	#1,d5

	asl.l	#7,d2

	asr.l	#8,d4
	swap	d4
	move.w	d5,d4	
	swap	d4

	swap 	d5
	
; d2 xpos xv|xv
; d3 ypos yv|yv
; d4 xoff xv|xv|xn|xn
; d5 yoff yv|yv|yn|yn
; d0 xpos  yn|00|xv|xn  d2
; d1 ypos  00|00|00|yv	d3
; d2 xofs  yn|00|xv|xn  d4
; d3 yofs  00|00|00|yv  d5

	lea	(a2,d0.w*2),a4
	lsr.w	#1,d1
	bcc.s	.next
	move.w	d2,d0
	move.b	d3,d0
	move.w	0(a5,d0.w*4),(a4)+
.next
	subq	#1,d1
	bmi.s	.no
.hline	
	move.w  D2,D0
	move.b  D3,D0
	move.l  0(A5,D0.w*4),(a4)+
	add.l   D4,D2
	addx.b  D5,D3

	dbf	d1,.hline
.no
	lea	32*2(a0),a0
	lea	SCRW*2(a2),a2
	dbf	d7,.yloop
.no_poly
	rts
; --------------------------------------------------------------------
do_points
	lea	newpoints,a0
	move.l	scr1(PC),a1

	move.w	#15*32*64+15*64+15,d6

	lea	ysize(PC),a2
	moveq	#0,d5
	cmp.w	#99,(a2)
	bne.s	.0
	moveq	#1,d5
.0

	move.w	(a0)+,d7
.1	
	move.l	(a0)+,d0
	tst.w	(a0)
	bpl.s	.no
	move.w	d0,d1
	swap	d0
	add.w	#160,d0
	add.w	#100,d1
	tst.w	d0
	bmi.s	.no
	tst.w	d1
	bmi.s	.no
	cmp.w	#319,d0
	bgt.s	.no
	cmp.w	#199,d1
	bgt.s	.no
	lsr.w	d5,d1
	muls	#SCRW*2,d1
	lea	(a1,d1.l),a2
	lea	(a2,d0.w*2),a2
	move.w	d6,(a2)
.no
	addq	#4,a0
	dbf	d7,.1
	rts
; --------------------------------------------------------------------
	IFNE 1
;512 Werte im Padded-24-Format (fr den DSP geeignet !)
;d.h. 0 ... $007fffff ... 0 ... $00800001 ...

size	EQU	512 ;nicht „ndern !

sin_gen:
	lea	sin(PC),A0
	moveq	#0,D6
	lea	size*2+4(A0),A1
	movea.l	A0,A2
	moveq	#size/4-1,D7
.l1:	lea	sin_fakdiv+16(PC),A3
	move.l	D6,D5
	moveq	#7,D2
.l2:	move.w	D2,D1
	move.l	D6,D3
.l3:	mulu.l	D6,D4:D3
	rol.l	#8,D3
	rol.l	#8,D4
	move.b	D3,D4
	move.l	D4,D3
	dbra	D1,.l3
	divs.l	-(A3),D3
	add.l	D3,D5
	subq.w	#2,D2
	bcc.s	.l2
	asr.l	#1,D5
	move.l	D5,(A0)+
	move.l	D5,-(A1)
	add.l	#$06487ED5/size,D6     ;2*pi*(2^24)
	dbra	D7,.l1
	move.l	#$007FFFFF,-(A1)
	lea	size(A1),A1
	move.w	#size/2+size/4-1,D1
.l6:	move.l	(A2)+,(A1)
	neg.l	(A1)+
	dbra	D1,.l6
                   
	lea	sin(PC),a0
	lea	sinus(PC),a1
	move.w	#256-1,d0
.l0:	move.l	(a0)+,d1
*	add.l	d1,d1
	lsr.l	#8,d1
*	swap	d1
	move.w	d1,512(a1)
	move.w	d1,(a1)+
	addq.w	#4,a0
	dbra	d0,.l0
	rts		
	ENDC
; --------------------------------------------------------------------
; -> a6: poly
face_z_sorting:
	bsr	generate_face_z_list
	lea	face_list(PC),a0
	lea	face_z(PC),a1
	bsr	do_sorting
	rts
; --------------------------------------------------------------------
; -> a6: poly
generate_face_z_list:
	lea	face_list(PC),a0
	lea	face_z(PC),a1
	lea	newpoints+2,a2

	move.w	(a6)+,d7
	move.w	d7,(a1)+
.loop
	move.l	a6,(a0)+

	addq	#1,a6
	moveq	#0,d6
	move.b	(a6)+,d6
	move.w	d6,d5
	moveq.l	#0,d1
.pl	moveq.l	#0,d0
	move.b	(a6)+,d0
	move.w	4(a2,d0.w*8),d0
	ext.l	d0
	add.l	d0,d1
	dbf	d6,.pl
	addq	#1,a6
	addq	#1,d5
	divs	d5,d1
	move.w	d1,4(a1)
	addq	#8,a1

	dbf	d7,.loop
	move.l	#-1,(a0)+
	rts
;-----------------------------------------------------------
;-----------------------------------------------------------



;-----------------------------------------------------------
clrscr
	move.l	scr1,a5
	move.l	scr2,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2

	move.w	#489,d7
.1	
	rept	10
	movem.l	d0-d6/a0-a2,(a5)
	movem.l	d0-d6/a0-a2,(a6)
	lea	40(a5),a5
	lea	40(a6),a6
	endr
	dbf	d7,.1
	rts
;-----------------------------------------------------------
vbl

old_vbl	jmp	$12345678
	rte
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

	cache_on

        move.l  $44e.w,old_screen
	save_resolution

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2
	add.l	#384*240*2,d0
	move.l	d0,scr3

	move.l	scr1,d0
	setscreen

	*lea	rgb_384x240x256,a0
	lea	rgb_320x200xtrue,a0
	set_resolution

	move.l	#0,$ffff9800.w
        rts
;-----------------------------------------------------------
exit
	
	move.l	old_screen,d0
	setscreen
	restore_resolution

	mouse_on
	super_off
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
scr1		dc.l	0
scr2		dc.l	0
scr3		dc.l	0

exit_flag	dc.w	-1

;-----------------------------------------------------------
world:
	dc.l	points_d
	dc.l	polys_d
pos_d	dc.w	0,0,0
	dc.w	0,0,0

	dc.l	points_b
	dc.l	polys_b
pos_b	dc.w	0,0,0
	dc.w	0,0,0

	dc.l	points_a
	dc.l	polys_a
pos_a	dc.w	0,0,0
	dc.w	0,0,0
	dc.l	-1

	include	old\d.s
	even
	include old\b.s
	even
	include	old\a.s
	even

intensity	ds.l	1
world_alpha	ds.w	1
world_beta	ds.w	1
world_gamma	ds.w	1

; --------------------------------------------------------------------
ysize:	dc.w	199

sin_fakdiv:             
	DC.L -6,120,-5040,362880 ;-3!, 5!, -7!, 9!
coltab3	REPT 256
	dc.l	0
	ENDR

pic	incbin	daten\test.tru
; --------------------------------------------------------------------

;-----------------------------------------------------------
;-----------------------------------------------------------

	even

	section bss

	ds.l	1000
mystack		ds.l	0

start_bss
block		ds.w	32*32
brightness	ds.w	1
tbuff		ds.w	4
spline_point	ds.w	10
sin		ds.l	1024
sinus		ds.l	1024
oldysize	ds.w	1

colortab	ds.w	32

invers_tab	ds.w	384*2

object_list	ds.l	200
object_center	ds.l	200

face_list	ds.l	200
face_z		ds.l	200

		ds.l	10000
line_buffer	ds.w	32*800
		ds.l	10000

temppoints	ds.w	8*500
newpoints	ds.w	8*500
tempnormals	ds.w	8*500
newnormals	ds.w	8*500

	ds.l	1000

screens		ds.w	3*SCRW*240+256
texture		ds.w	256*512
stars		ds.w	1024*3+1
splinecnt	ds.w	1

end_bss
