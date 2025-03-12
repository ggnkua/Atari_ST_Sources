; 2 plane version of the screen.. should be loads faster without too much
; loss of detail in the sprites..
;
; trying to get it 2 VBL all the way.. (it is now), remaining stuff:
; - sprite frame specific optimisation. 
; - interleaving arrays (probably just worse ;))

;- plugin equates ----------------------------------------------------------

; test stuffs
SHOW_USAGE:=		0

; sprite/point stuffs
DOT:=			0
SPRITE:=		1
POINT_TYPE:=		SPRITE	DOT
FAST_SPRITES:=		1				; fast sprites y/n, takes more mem
NUM_FRAMES:=		46				; #frames of sprite anim

MASK_SIZE:=		4*16
DATA_SIZE:=		4*16
SPRITE_SIZE:=		(MASK_SIZE+DATA_SIZE)

SHIFT_MASK_SIZE:=	2*MASK_SIZE
SHIFT_DATA_SIZE:=	2*DATA_SIZE
SHIFT_SPRITE_SIZE:=	(SHIFT_MASK_SIZE+SHIFT_DATA_SIZE)

; 3d object animation
FLAP_FRAMES:=		128
FLAP_FRAME_SIZE:=	(1+86*3)*2

; optimisation
CLEAR_SPRITES:=		1

; 3d stuffs
PERSPECTIVE:=		0
Sprites.WIDTH:=		256 512 672
Sprites.HEIGHT:=	256 512	672

		rsreset
Matrix.XX:	rs.w	1
Matrix.XY:	rs.w	1
Matrix.XZ:	rs.w	1
Matrix.YX:	rs.w	1
Matrix.YY:	rs.w	1
Matrix.YZ:	rs.w	1
Matrix.ZX:	rs.w	1
Matrix.ZY:	rs.w	1
Matrix.ZZ:	rs.w	1
Matrix.TX:	rs.l	1
Matrix.TY:	rs.l	1
Matrix.TZ:	rs.l	1
Matrix.SIZE:	rs.b	0

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0				; nifty debug mode
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	main_loop
	dc.l	init
	dc.l	deinit
	dc.l	toggle_flap
	dc.l	toggle_zoom
	dc.l	trigger_fade_down
	dc.l	trigger_fade_up
	dc.l	trigger_flash
	dc.l	set_word_rout
	dc.l	set_word2_rout
	dc.l	set_word3_rout
	dc.l	set_bee_close
	dc.l	0

;- plugin routines ---------------------------------------------------------

init:	lea	point_table,a0
	lea	bee_bytes+788,a1
	bsr	convert_bitmap_to_points

	bsr	extract_bee

	lea	bee_sprite,a1
	moveq	#NUM_FRAMES,d7
	bsr	shift_sprites

	bsr	create_mul_luts
	bsr	init_frames
	bsr	precalc_flap
	bsr	precalc_mul_table

	bsr	calc_fading

	ifeq	objectmode
	bsr	set_bee_close
	bsr	toggle_flap
	endc

	rts

deinit:	rts

main_loop:
	ifne	SHOW_USAGE
	move.w	#$F00,$FFFF8240.w
	endc

	tst.w	flash_frame
	beq.s	.no_flash
	subq.w	#1,flash_frame
;	bsr	clear_screen
	bsr	paint_sprites_background
	bra.s	.scr_done
.no_flash:

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	cmpi.l	#2,d0
	bhs.s	.scr_done
	tst.l	d0
	bne.s	.res_done
	move.w	$0468.w,.old468
	bsr	set_res
	move.w	$0468.w,.first_468
.res_done:
;	bsr	clear_screen
	bsr	paint_sprites_background
.scr_done:

; first, restore screen background..
	ifne	CLEAR_SPRITES
	bsr	clear_sprites
	else
	bsr	clear_2plane_screen
	endc

	ifne	0
	move.w	frame,d0
	mulu.w	#2048/46,d0
;	move.w	$468.w,d0
	move.w	d0,d1
	move.w	d0,d2
;	lsl.w	#3,d1
	move.w	#-256,d0
	move.w	#512,d2

;	move.w	frame,d0
;	mulu.w	#2048/46,d0
;	move.w	d0,d1
;	move.w	d0,d2
;	neg.w	d1
;	clr.w	d0
	else
	move.w	$0468.w,d0
	sub.w	.first_468(pc),d0
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#11,d1
	lsr.l	d1
	mulu.w	#7,d2
	lsr.l	d2
	mulu.w	#3,d0
	endc

;	move.w	#200,d0
;	move.w	#100,d1
;;	clr.w	d0
;;	clr.w	d1
;	clr.w	d2

	move.w	fixed_zoom,d3
	tst.w	zooming_mode
	beq.s	.no_zoom
	move.w	$0468.w,d3
	sub.w	zoom_start_time,d3
.no_zoom:
	cmpi.w	#$00FF,d3
	ble.s	.oki
	move.w	#$00FF,d3
	move.w	d3,fixed_zoom
	clr.w	zooming_mode
.oki:	not.w	d3
	andi.w	#$00FF,d3
	addi.w	#$0100,d3
	bsr	Matrix.generate

	moveq	#-8,d0					; to center sprite in x dir
	moveq	#-8,d1					; to center sprite in y dir
	move.w	#$180,d2
;	move.w	$0468.w,d2
;	lsl.w	#4,d2
;	andi.w	#$7FFF,d2
	bsr	Matrix.translate

	movea.l	trf_point_table_adr,a0
	lea	Matrix.temp,a1

;	lea	point_table,a2
	move.w	$0468.w,d0
	sub.w	start_flap_time,d0
	addi.w	#32,d0
	andi.w	#128-1,d0
	lea	flap_frame_table,a2
	tst.w	flapping_mode
	bne.s	.flap
	moveq	#32,d0
.flap:	mulu.w	#FLAP_FRAME_SIZE,d0
	adda.l	d0,a2

	bsr	Object.transform

	movea.l	paint_rout,a0
	jsr	(a0)

; swap transformed point tables
	lea	trf_point_table_adr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)

; swap clear tables..
	lea	clear_table_adr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)

	bsr	update_frames

; swap screens, set vbase
	ifeq	testmode
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	move.w	$468.w,d0

	ifne	0
	move.w	d0,d1
	sub.w	.old468(pc),d1
	subq.w	#1,d1
	bmi.s	.end_show_vbls
	movea.l	scr+4,a0
.vbl_loop:
	move.w	#$FF00,(a0)
	addq	#8,a0
	dbf	d1,.vbl_loop
.end_show_vbls:
	endc

	ifne	SHOW_USAGE
	clr.w	$FFFF8240.w
	endc

; wait for vbl to occur..
	move.w	d0,.old468
.wait:	cmp.w	$468.w,d0
	beq.s	.wait

	rts

.old468:dc.w	0
.first_468:
	dc.w	0

;- plugin subroutines ------------------------------------------------------

toggle_flap:
	move.w	$0468.w,start_flap_time
	not.w	flapping_mode
	rts

toggle_zoom:
	move.w	$0468.w,zoom_start_time
	not.w	zooming_mode
	rts

trigger_fade_down:
	move.w	#-16,sprite_fading
	move.l	#sprite_vbl_rout,palirq
	rts

trigger_fade_up:
	move.w	#+16,sprite_fading
	move.l	#sprite_vbl_rout,palirq
	rts

trigger_flash:
	move.l	#sprite_flash_rout,palirq
	move.w	#2,flash_frame
	bsr	set_bee_rout
	rts

set_bee_close:
	move.w	#$FF,fixed_zoom
	rts

flash_frame:
	dc.w	0

set_word_rout:
	move.l	#paint_words,paint_rout
	rts

set_word2_rout:
	move.l	#paint_words2,paint_rout
	rts

set_word3_rout:
	move.l	#paint_words3,paint_rout
	rts

set_bee_rout:
	move.l	#plot_sprites,paint_rout
	rts

LEFT:=		6
RIGHT:=		6
BORDERS:=	(LEFT+RIGHT)
CENTER:=	(40-BORDERS)

paint_sprites_background:
	movea.l	scr,a0
	clr.l	(a0)+

	ifne	1

	tst.w	full_sprite_background
	bne.s	.normal

.full:	lea	spr_background1+34,a1
	lea	LEFT*4(a1),a1
	clr.l	d0
	move.w	#200-1,d7

.yloop:
	rept	LEFT
	move.l	d0,(a0)+
	endr
	rept	CENTER
	move.l	(a1)+,(a0)+
	endr
	rept	RIGHT
	move.l	d0,(a0)+
	endr
	lea	BORDERS*4(a1),a1
	dbf	d7,.yloop
	rts

	endc

.normal:lea	spr_background2+34,a1
	move.w	#8000-2,d7
.loop:	move.l	(a1)+,(a0)+
	dbf	d7,.loop
	rts

paint_words:
	movea.l	scr,a0
	clr.l	d0
	move.w	#77*20-1,d7

.clr_loop1:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop1

	lea	words_pi1+34+160*1,a1
	move.w	#38*20-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	move.w	#85*20-1,d7

.clr_loop2:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop2

	rts

paint_words2:
	movea.l	scr,a0
	clr.l	d0
	move.w	#76*20-1,d7

.clr_loop1:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop1

	lea	words_pi1+34+160*50,a1
	move.w	#48*20-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	move.w	#76*20-1,d7

.clr_loop2:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop2
	rts

; paint title pic.
paint_words3:
	st	full_sprite_background

	movea.l	scr,a0
	lea	title_pi1+34,a1
	move.w	#200*20-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop
	rts

paint_words4:
	movea.l	scr,a0
	clr.l	d0
	move.w	#76*20-1,d7

.clr_loop1:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop1

	lea	words_pi1+34+160*(50+48+2),a1
	move.w	#48*20-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	move.w	#76*20-1,d7

.clr_loop2:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.clr_loop2
	rts



set_res:tst.w	sprite_fading
	beq.s	.pal0
	move.l	#sprite_vbl_rout,palirq
	rts
.pal0:	move.l	#set_sprite_pal,palirq
	rts

sprite_flash_rout:
	tst.w	flash_frame
	bne.s	.go_on
	move.l	#set_sprite_pal,palirq
	bra.s	set_sprite_pal
.go_on:	lea	$FFFF8240.w,a0
	moveq	#-1,d0
	rept	8
	move.l	d0,(a0)+
	endr
	rts

set_sprite_pal:
	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	beq.s	.end

	lea	$FFFF8240.w,a0
	movem.w	bee_pi1+2,d0-d3
	cmpi.l	#paint_words3,paint_rout
	movem.w	spr_background2+2,d4-d7
	move.w	d4,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d6,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d7,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+

	move.l	#dummy,palirq
.end:	rts

sprite_vbl_rout:
	move.w	$0468.w,d0
	andi.w	#1,d0
	beq.s	.end

	move.w	sprite_fading,d0
	beq.s	.pal0
	move.w	d0,d1
	bpl.s	.fade_up

.fade_down:
	lea	fade_palette,a1
	addq.w	#1,d1
	not.w	d0				; d0.w=1-f
	bra.s	.set

.fade_up:
	cmpi.l	#paint_words3,paint_rout
	bne.s	.normal_fade_up
	lea	title_fade_palette,a1
	bra.s	.fade_up_pal_set
.normal_fade_up:
	lea	words_fade_palette,a1
.fade_up_pal_set:
	subi.w	#16,d0
	neg.w	d0				; d0.w=16-f
	subq.w	#1,d1

.set:	move.w	d1,sprite_fading
	lea	$FFFF8240.w,a0
	lsl.w	#5,d0
	adda.w	d0,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr

.end:	rts

.pal0:	;bsr	set_sprite_pal
	rts

clear_span:	macro
		move.l	d0,(a0)
		addq	#8,a0
		move.l	d0,(a0)
		adda.w	d1,a0
		endm

clear_sprites:
	movea.l	clear_table_adr,a1
	move.w	(a1)+,d7
	beq	.end
	clr.l	d0
	move.w	#160-8,d1
	subq.w	#1,d7
	ifne	0
; nasty unrolling optimisation..
; all addresses must be valid!!
; beware of that, this isn't currently so!
	rept	86
	movea.l	(a1)+,a0
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	endr
	else
.loop:	movea.l	(a1)+,a0
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	clear_span
	endc
	dbf	d7,.loop
.end:	rts

clear_2plane_screen:
	movea.l	scr,a0
	clr.l	d0
	rept	32000/8
	move.l	d0,(a0)+
	addq	#4,a0
	endr
	rts

clear_screen:
	movea.l	scr,a0
	lea	32000(a0),a0
	clr.l	d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	REPT	(32000)/56
	movem.l	d0-d7/a1-a6,-(a0)	
	ENDR
	REPT	(32000-(32000/56)*56)/4
	move.l	d0,-(a0)
	ENDR
	rts

create_mul_luts:
	lea	scan_table-16*2,a0
	move.w	#160,d0
	move.w	#-16*160,d1
	move.w	#200+16-1,d7
.loop:	move.w	d1,(a0)+
	add.w	d0,d1
	dbf	d7,.loop

	lea	shift_sprite_lut,a0
	move.w	#SHIFT_SPRITE_SIZE,d0
	clr.w	d1
	moveq	#16-1,d7
.loop2:	move.w	d1,(a0)+
	add.w	d0,d1
	dbf	d7,.loop2

	moveq	#NUM_FRAMES-1,d7
	move.l	#SHIFT_SPRITE_SIZE*16,d0
	clr.l	d1
.loop3:	move.l	d1,(a0)+
	add.l	d0,d1
	dbf	d7,.loop3

	rts

;- tridi routines ----------------------------------------------------------

precalc_mul_table:
	lea	mul_table+128*256*2,a0
	clr.w	d1

.yloop:	clr.w	d0

.xloop:	move.w	d0,d2
	move.w	d1,d3
	ext.w	d2
	ext.w	d3
	muls.w	d2,d3

	asr.w	#6,d3

	move.w	d0,d2
	lsl.w	#8,d2
	move.b	d1,d2
	ext.l	d2
	add.l	d2,d2
	move.w	d3,(a0,d2.l)
	addq.b	#1,d0
	bne.s	.xloop

	addq.b	#1,d1
	bne.s	.yloop
	rts

precalc_flap:
	lea	flap_frame_table,a6
	moveq	#FLAP_FRAMES-1,d7
.loop:	movea.l	a6,a0
	move.w	d7,-(sp)
	move.l	a6,-(sp)
	move.w	d7,d0
	bsr	flap_the_bee
	movea.l	(sp)+,a6
	move.w	(sp)+,d7
	lea	FLAP_FRAME_SIZE(a6),a6
	dbf	d7,.loop
	rts

init_frames:
	move.w	num_points,d7
	subq.w	#1,d7
	lea	frames,a0
	move.l	#$561A,d0
.loop:	ror.w	#5,d0
	addq.w	#7,d0
	move.l	d0,d1
	divu.w	#NUM_FRAMES,d1
	swap	d1
	mulu.w	#SHIFT_SPRITE_SIZE*16,d1
	addi.l	#shifted_sprites,d1
	move.l	d1,(a0)+
	dbf	d7,.loop
	rts

update_frames:
	move.w	num_points,d7
	subq.w	#1,d7
	lea	frames,a0
	move.l	#shifted_sprites+NUM_FRAMES*SHIFT_SPRITE_SIZE*16,d1
	move.l	#shifted_sprites,d3
	move.l	#SHIFT_SPRITE_SIZE*16,d2

	ifne	1
; nasty unroll optimisation!
	rept	86
	move.l	(a0),d0
	add.l	d2,d0
	cmp.l	d1,d0
	blt.s	*+4
	move.l	d3,d0
	move.l	d0,(a0)+
	endr
	else
.loop:	move.l	(a0),d0
	add.l	d2,d0
	cmp.l	d1,d0
	blt.s	.okay
	move.l	d3,d0
.okay:	move.l	d0,(a0)+
	dbf	d7,.loop
	endc
	rts

; p[n+1] = p[n] + (l.cos(n.a))
; -        -      (l.sin(n.a))
; input:
; d0.w=frame index
flap_the_bee:
	lsl.w	#4,d0
	andi.w	#2048-1,d0
	lea	sine_tbl,a1
	lsl.w	#2,d0
	move.w	(a1,d0.w),d0
	addi.w	#$8000,d0
	lsr.w	#8,d0
	lsr.w	#2,d0
	move.w	d0,alpha

	move.w	num_points,(a0)+			; store #points.

; first diagonal, this is an exception, i.e. not mirrored and not bent..
; it lies fully along the y axis..
	lea	bee_bytes+788,a1
	move.w	#-Sprites.WIDTH/2,d0
	move.w	#Sprites.WIDTH/16,d1
	clr.w	d2
	moveq	#16-1,d7

	movea.l	a1,a2
.first_loop:
	tst.b	(a1)
	bmi.s	.next
	move.w	d2,(a0)+
	move.w	d0,(a0)+
	move.w	d2,(a0)+
.next:	adda.w	#16+1,a1
	add.w	d1,d0
	dbf	d7,.first_loop

; rest of diagonals, these are symmetrical, so two are output at once..
; these are parallel to the y-axis..
;
;        .
;      | . |
;    | | . | |
;  | | | . | | |
;    | | . | |
;      | . |
;        .
;
	lea	bee_bytes+788+1,a1
	lea	bee_bytes+788+16,a2
	clr.w	d0				; d0.w=angle [0]
	move.w	#-Sprites.WIDTH/2,y_off		; y offset [0]
	clr.l	old_sin
	clr.l	old_cos
	lea	sine_tbl,a5
	moveq	#15-1,d7

.line_loop:
	move.w	d7,d6				; d6.w=line length -1
	movea.l	a1,a3				; a3: hor start
	movea.l	a2,a4				; a4: ver start
	add.w	alpha,d0			; d0.w=alpha[n]
	move.w	d0,d2
	lsl.w	#2,d2
	movem.w	(a5,d2.w),d2-d3			; d2.w=sin(alpha[n]), d3.w=cos(alpha[n])
	muls.w	#(Sprites.WIDTH*2)*7/10,d2
	muls.w	#(Sprites.WIDTH*2)*7/10,d3
	swap	d2
	swap	d3
	ext.l	d2
	ext.l	d3
	add.l	old_sin,d2			; d2.w= sin is in z direction!
	move.l	d2,old_sin
	add.l	old_cos,d3			; d3.w= cos in x direction!
	move.l	d3,old_cos

;	asr.l	#4,d2
;	asr.l	#4,d3
	divs.w	#17,d2
	divs.w	#17,d3

	addi.w	#Sprites.WIDTH/34,y_off		; y_offset[n+1] = y_offset[n]+W/32
	move.w	y_off,d1

.pt_loop:
	tst.b	(a3)
	bmi.s	.end_left
	move.w	d3,(a0)+			; output x.
	move.w	d1,(a0)+			; output y.
	move.w	d2,(a0)+			; output z.
.end_left:
	lea	16+1(a3),a3

	tst.b	(a4)
	bmi.s	.end_right
	neg.w	d3
	move.w	d3,(a0)+			; output x.
	neg.w	d3
	move.w	d1,(a0)+			; output y.
	move.w	d2,(a0)+			; output z.
.end_right:
	lea	16+1(a4),a4

	addi.w	#Sprites.WIDTH/16,d1		; y_offset
	dbf	d6,.pt_loop

	addq	#1,a1				; a1: h start [n+1]
	lea	16(a2),a2			; a2: v start [n+1]
	dbf	d7,.line_loop
	rts

old_sin:dc.l	0
old_cos:dc.l	0
alpha:	dc.w	0
y_off:	dc.w	0

; seems to work ok, since there has been some patching on the overflow
; errors (caused by combination of finite accuracy and use of maximum range).
; input:
; d0.w= x rotation (a)
; d1.w= y rotation (b)
; d2.w= z rotation (c)
; d3.w= z
Matrix.generate:
	move.l	#$007FFFFF,d7
	divu.w	d3,d7
	lea	Matrix.temp,a0
; 1] rotate 3 axis.
	move.w	#2048-1,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	movea.w	d0,a3				; a3=xrot=a
	movea.w	d1,a4				; a4=yrot=b
	movea.w	d2,a5				; a5=zrot=c
	adda.w	a3,a3
	adda.w	a3,a3				; a3=xrot*4=4a (addressing offset)
	adda.w	a4,a4
	adda.w	a4,a4				; a4=yrot*4=4b (addressing offset)
	adda.w	a5,a5
	adda.w	a5,a5				; a5=zrot*4=4c (addressing offset)
	lea	sine_tbl,a2

; x' = + x*cos(b)*cos(c)
;      - y*cos(b)*sin(c)
;      + z*sin(b)
	movem.w	(a2,a4.w),d3/d4
	movem.w	(a2,a5.w),d5/d6
	muls.w	d4,d6				; / cos(b)*sin(c)
	add.l	d6,d6				; |
	swap	d6				; \
	muls.w	d4,d5				; / -cos(b)*sin(c)
	add.l	d5,d5				; |
	swap	d5				; |
	neg.w	d5				; \
	muls.w	d7,d6
	muls.w	d7,d5
	muls.w	d7,d3
	add.l	d6,d6
	add.l	d5,d5
	add.l	d3,d3
	swap	d6
	swap	d5
	swap	d3
	move.w	d6,(a0)+
	move.w	d5,(a0)+
	move.w	d3,(a0)+
	
; y' = + x*(sin(a)*sin(b)*cos(c)+cos(a)*sin(c))
;      + y*(cos(a)*cos(c)-sin(a)*sin(b)*sin(c))
;      - z*sin(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4
	add.w	d4,d5
	bvc.s	.skipyvd5
	addq.w	#1,d5
	neg.w	d5
.skipyvd5:
	move.w	d5,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d5
	add.l	d5,d5
	swap	d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	sub.w	d4,d5
	bvc.s	.skipyv2d5
	addq.w	#1,d5
	neg.w	d5
.skipyv2d5:
	move.w	2(a2,a4.w),d4
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	neg.w	d4
	muls.w	d7,d3
	muls.w	d7,d5
	muls.w	d7,d4
	add.l	d3,d3
	add.l	d5,d5
	add.l	d4,d4
	swap	d3
	swap	d5
	swap	d4
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	ifne	PERSPECTIVE

; z' = + x*(sin(a)*sin(c)-cos(a)*sin(b)*cos(c))
;      + y*(cos(a)*sin(b)*sin(c)+sin(a)*cos(c))
;      + z*cos(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	sub.w	d5,d4
	bvc.s	.skipzvd4
	addq.w	#1,d4
	neg.w	d4
.skipzvd4:
	move.w	d4,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	muls.w	d0,d5
	add.l	d5,d5
	swap	d5
	add.w	d4,d5
	bvc.s	.skipzvd5
	addq.w	#1,d5
	neg.w	d5
.skipzvd5:
	move.w	2(a2,a4.w),d4
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4
	muls.w	d7,d3
	muls.w	d7,d5
	muls.w	d7,d4
	add.l	d3,d3
	add.l	d5,d5
	add.l	d4,d4
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	else

	addq	#6,a0

	endc

; translation vector = (0,0,0)
	clr.l	d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

; translate the matrix translation vector.
; input:
; d0.w: x translation
; d1.w: y translation
; d2.w: z translation
Matrix.translate:
	lea	Matrix.temp,a0
	add.w	d0,Matrix.TX(a0)
	add.w	d1,Matrix.TY(a0)
	add.w	d2,Matrix.TZ(a0)
	rts

OPT_MUL:=	1

; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Object.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	mul_table+128*256*2,a4

	ifne	OPT_MUL
	move.w	(a3),d6
	movea.w	4(a3),a3
	movea.w	8(a3),a6
	else
	movem.l	(a3),d6/a3/a6			; d6.l=tx,a3=ty,a6=tz [16:16]
	endc

.vertexloop:
	movem.w	(a2)+,d0-d2

	ifne	OPT_MUL

; 68000 optimised version! a4: multiply table
; x'
;	clr.l	d3
;	clr.l	d4
;	clr.l	d5
;	move.w	(a1)+,d3
;	move.w	(a1)+,d4
;	move.w	(a1)+,d5
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
;	asr.w	#6,d3
	add.w	d6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
; y'
;	clr.l	d3
;	clr.l	d4
;	clr.l	d5
;	move.w	(a1)+,d3
;	move.w	(a1)+,d4
;	move.w	(a1)+,d5
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
;	asr.w	#6,d3
	add.w	a3,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.

	else

; x'
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	d6,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
; y'
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a3,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
; z'
	endc

	ifne	PERSPECTIVE

	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a6,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst,a0				; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	move.w	#160,d4
	move.w	#100,d5
	move.w	#$0100,d3			; d3.w=z_offset

	ifne	1

; nasty unroll optimisation!
	rept	86
	move.w	(a0),d0
	asr.w	d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	d1
	add.w	d5,d1
	move.w	d1,(a0)+
	addq	#2,a0
	endr

	else

.loop:	movem.w	(a0),d0-d2
	ifne	PERSPECTIVE
	lsl.l	#8,d0
	lsl.l	#8,d1
	add.w	d3,d2
	divs.w	d2,d0
	divs.w	d2,d1
	else
; todo, scale when no perspective?
	asr.w	d0
	asr.w	d1
	endc
	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0
	dbf	d7,.loop

	endc

	rts

.dst:	dc.l	0

;- sprite routines ---------------------------------------------------------

; convert a 16x16 8 bpp map to a 3d point table.
; input:
; a0: point table
; a1: bitmap
convert_bitmap_to_points:
	movea.l	a0,a6
	addq	#2,a0
	clr.w	d5
	move.w	#-Sprites.HEIGHT/2,d1
	moveq	#16-1,d7

.yloop:	move.w	#-Sprites.WIDTH/2,d0
	moveq	#16-1,d6

.xloop:	tst.b	(a1)+
	bmi.s	.next
	move.w	d0,(a0)+				; output x.
	move.w	d1,(a0)+				; output y.
	clr.w	(a0)+					; output z.
	addq.w	#1,d5
.next:	addi.w	#Sprites.WIDTH/16,d0
	dbf	d6,.xloop

	addi.w	#Sprites.HEIGHT/16,d1
	dbf	d7,.yloop

	move.w	d5,(a6)					; store #points.
	move.w	d5,num_points
	rts

extract_bee:
	lea	bee_sprite,a6
	lea	bee_offsets,a3
	moveq	#NUM_FRAMES-1,d6

.sprite_loop:
	movea.l	(a3)+,a1
	movea.l	a6,a0
	lea	SPRITE_SIZE(a6),a6
	moveq	#16-1,d7
.loop:
; extract mask.
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+

; extract sprite.
	move.l	-(a1),(a0)+
	
	lea	160(a1),a1
	dbf	d7,.loop

	dbf	d6,.sprite_loop
	rts

; input:
; d7.w=#sprites
; a1: sprites (16x16 1bpl mask, 2 plane data)
shift_sprites:
	subq.w	#1,d7
	bmi.s	.end
	lea	shifted_sprites,a0
	lea	shift_adr_table,a2

.loop:	move.l	a0,(a2)+
	movem.l	d7/a2,-(sp)
	moveq	#16,d7
	bsr	shift_chunks
	movem.l	(sp)+,d7/a2
	dbf	d7,.loop
.end:	rts

; outputs 16 shifted versions of the chunk data in consecutive order.
; input:
; d7.l=#chunks (chunk=16 pixels, 1 plane)
; a0: output shift bank
; a1: input sprite (mask, data)
; output:
; a1: next input sprite
shift_chunks:
	movea.l	a1,a6
	clr.w	d6

.shift_loop:
	movea.l	a6,a1

; shift mask..
	move.l	d7,d5
	subq.l	#1,d5
	swap	d5

.mask_hchunk_loop:
	swap	d5
.mask_chunk_loop:

; left mask (doubled)
	moveq	#-1,d0
	move.w	(a1),d0
	addq	#4,a1
	ror.l	d6,d0
	move.w	d0,(a0)
	move.w	d0,2(a0)

; left data
; plane 0
	moveq	#0,d1
	move.w	(a1)+,d1
	ror.l	d6,d1
	move.w	d1,4(a0)
; plane 1
	moveq	#0,d2
	move.w	(a1)+,d2
	ror.l	d6,d2
	move.w	d2,6(a0)

; right mask (doubled)
	swap	d0
	move.w	d0,8(a0)
	move.w	d0,10(a0)

; right data
; plane 0
	swap	d1
	move.w	d1,12(a0)
; plane 1
	swap	d2
	move.w	d2,14(a0)

	lea	16(a0),a0

	dbf	d5,.mask_chunk_loop 
	swap	d5
	dbf	d5,.mask_hchunk_loop

	addq.w	#1,d6
	cmpi.w	#16,d6
	blt.s	.shift_loop
	rts

;---------------------------------------------------------------------------
plot_sprites:
	lea	frames,a2
	lea	scan_table,a4
	movea.l	scr,a5
	movea.l	trf_point_table_adr,a6
	clr.l	d2					; for long offset use..

	ifne	CLEAR_SPRITES
	move.l	clear_table_adr,d3
	addq.l	#2,d3
	else
	moveq	#$F,d3
	endc

	move.w	#320-16,d4
	move.w	#200,d5
	moveq	#-16,d6
	move.w	(a6)+,d7
	subq.w	#1,d7

;	lea	85*6(a6),a6
;	moveq	#0,d7					; test!

.loop:
	movea.l	(a2)+,a3				; a3: sprite frame
	lea	shift_sprite_lut(pc),a1

	move.w	(a6)+,d0
	move.w	(a6)+,d1
;	cmp.w	d4,d0
;	bhs	.next
	cmp.w	d6,d1
	ble	.next
	cmp.w	d5,d1
	bge	.next

	add.w	d1,d1
	move.w	(a4,d1.w),d1				; d1.w=y_offset (bytes)
	;muls.w	#160,d1

	move.w	d0,d2

	ifne	CLEAR_SPRITES
	andi.w	#$F,d2					; d2.w=shift
	else
	and.w	d3,d2					; d2.w=shift
	endc

	sub.w	d2,d0					; d0.w=x_offset (pixels)
	lsr.w	d0					; d0.w=x_offset (bytes)
	add.w	d0,d1					; d1.w=offset (bytes)

	lea	(a5,d1.w),a0				; a0: screen position

	add.w	d2,d2
	move.w	(a1,d2.w),d2
;	mulu.w	#SHIFT_SPRITE_SIZE,d2			; d2.l=offset to pre-shifted sprite

; store sprite address..
	ifne	CLEAR_SPRITES
	move.l	d3,a1
	move.l	a0,(a1)+
	move.l	a1,d3
	endc

	lea	(a3,d2.w),a1				; a1: sprite mask/data

	rept	15
	move.l	(a0),d0				; 12
	and.l	(a1)+,d0			; 12
	or.l	(a1)+,d0			; 12
	move.l	d0,(a0)				; 12
	addq	#8,a0				;  4
	move.l	(a0),d0				; 12
	and.l	(a1)+,d0			; 12
	or.l	(a1)+,d0			; 12
	move.l	d0,(a0)				; 12
	lea	160-8(a0),a0			;  8
						; -- +
;						 108 (x15)
	endr
	move.l	(a0),d0
	and.l	(a1)+,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)
	addq	#8,a0
	move.l	(a0),d0
	and.l	(a1)+,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)
;						100
; 108x15+100=1720

.next:	addq	#2,a6
	dbf	d7,.loop

	ifne	CLEAR_SPRITES
	movea.l	clear_table_adr,a0
	sub.l	a0,d3
	lsr.l	#2,d3
	move.w	d3,(a0)
	endc
	rts

shift_sprite_lut:
	ds.w	16
	ds.l	NUM_FRAMES

	ifne	0

; 2 bpl 16x16 pre-shifted sprite routine, won't get any faster, unless we 
; do multiple at once!
; a0: screen
; a1: mask,data
paint_sprite:

	rept	15
	move.l	(a0),d0				; 12
	and.l	(a1)+,d0			; 12
	or.l	(a1)+,d0			; 12
	move.l	d0,(a0)				; 12
	addq	#8,a0				;  4
	move.l	(a0),d0				; 12
	and.l	(a1)+,d0			; 12
	or.l	(a1)+,d0			; 12
	move.l	d0,(a0)				; 12
	lea	160-8(a0),a0			;  8
						; -- +
;						 108 (x15)
	endr
	move.l	(a0),d0
	and.l	(a1)+,d0
	or.l	(a2)+,d0
	move.l	d0,(a0)
	addq	#8,a0
	move.l	(a0),d0
	and.l	(a1)+,d0
	or.l	(a2)+,d0
	move.l	d0,(a0)
;						100
; 108x15+100=1720
	rts

; interleaved! rout for drawing multiples of the same sprite!!
	rept	7
	movem.l	(a1)+,d0-d7			; 8*8+8=72
	and.l	d0,(a0)				; 16
	or.l	d4,(a0)				; 16
	addq	#8,a0				;  4
	and.l	d1,(a0)				; 16
	or.l	d5,(a0)				; 16
	lea	160-8(a0),a0			;  8
	and.l	d2,(a0)				; 16
	or.l	d6,(a0)				; 16
	addq	#8,a0				;  4
	and.l	d3,(a0)				; 16
	or.l	d7,(a0)				; 16
	lea	160-8(a0),a0			;  8
	endr					; -- +
;						 224(x7)
; tail..
	movem.l	(a1)+,d0-d7			; 8*8+8=72
	and.l	d0,(a0)				; 16
	or.l	d4,(a0)				; 16
	addq	#8,a0				;  4
	and.l	d1,(a0)				; 16
	or.l	d5,(a0)				; 16
	lea	160-8(a0),a0			;  8
	and.l	d2,(a0)				; 16
	or.l	d6,(a0)				; 16
	addq	#8,a0				;  4
	and.l	d3,(a0)				; 16
	or.l	d7,(a0)				; 16
						; -- +
;						 216
; 224x7+216=1784

	endc


;- fade routs -------------------------------------------------------------

calc_fading:
	lea	.tmp_pal(pc),a0
	movem.w	bee_pi1+2,d0-d3
	movem.w	spr_background2+2,d4-d7
	move.w	d4,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d6,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d7,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+

	lea	.tmp_pal(pc),a1
	lea	fade_palette,a2
	bsr	calc_faded_palettes

	ifne	0
	lea	.tmp_pal(pc),a0
	movem.w	words_pi1+2,d0-d3
	movem.w	spr_background+2,d4-d7
	move.w	d4,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d6,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d7,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	lea	.tmp_pal(pc),a1
	else
	lea	words_pi1+2,a1
	endc
	lea	words_fade_palette,a2
	bsr	calc_faded_palettes

	lea	title_pi1+2,a1
	lea	title_fade_palette,a2
	bsr	calc_faded_palettes

	rts

.tmp_pal:
	ds.w	16

; calculate some blackfaded versions of the palette..
; input:
; a1: src palette
; a2: dst fade buffer
calc_faded_palettes:

; 1: extract (ste) palette to easy format.
	lea	.pal_tbl(pc),a0
	moveq	#16-1,d7

.preloop:
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	move.w	d0,d4
	move.w	d0,d5

	andi.w	#$0700,d0
	lsr.w	#7,d0
	rol.w	#5,d3
	andi.w	#$0001,d3
	or.w	d3,d0

	andi.w	#$0070,d1
	lsr.w	#3,d1
	rol.b	#1,d4
	andi.w	#$0001,d4
	or.w	d4,d1
	
	andi.w	#$0007,d2
	add.w	d2,d2
	rol.b	#5,d5
	andi.w	#$0001,d5
	or.w	d5,d2

	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d2,(a0)+

	dbf	d7,.preloop

; 2: make faded versions..
	movea.l	a2,a0
	moveq	#16-1,d7

.lowloop:
	lea	.pal_tbl(pc),a1
	moveq	#16-1,d6

.lowentryloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

; do the actual fade..
	move.b	(a1)+,d0
	sub.b	d7,d0
	bpl.s	.r_ok
	moveq	#0,d0
.r_ok:	move.b	(a1)+,d1
	sub.b	d7,d1
	bpl.s	.g_ok
	moveq	#0,d1
.g_ok:	move.b	(a1)+,d2
	sub.b	d7,d2
	bpl.s	.b_ok
	moveq	#0,d2
.b_ok:

; Put in rorred format, weird STe crap..
	lsr.w	d0
	bcc.s	.rok
	ori.w	#%1000,d0
.rok:	lsr.w	d1
	bcc.s	.gok
	ori.w	#%1000,d1
.gok:	lsr.w	d2
	bcc.s	.bok
	ori.w	#%1000,d2
.bok:	

; Pack rgb, and store..
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d0,d2
	or.w	d1,d2
	move.w	d2,(a0)+
	dbf	d6,.lowentryloop

	dbf	d7,.lowloop
	rts

.pal_tbl:
	ds.b	3*16

;- data --------------------------------------------------------------------

	data

bee_bytes:
	incbin	bee.apx

bee_pi1:incbin	xbijen2.pi1

words_pi1:
;	incbin	invite.pi1
	incbin	loafc.pi1
title_pi1:
;	incbin	otl2k5fa.pi1
	incbin	otl2k5lo.pi1

spr_background1:
;	incbin	sidebarb.pi1
	incbin	beeee2.pi1
spr_background2:
	incbin	beeee.pi1

trf_point_table_adr:
	dc.l	trf_point_table,trf_point_table2

bee_offsets:
off:	set	0
	rept	20
	dc.l	bee_pi1+34+off
off:	set	off+8
	endr

off:	set	0
	rept	20
	dc.l	bee_pi1+34+160*16+off
off:	set	off+8
	endr

off:	set	0
	rept	6
	dc.l	bee_pi1+34+160*32+off
off:	set	off+8
	endr

clear_table_adr:
	dc.l	clear_table1,clear_table2

paint_rout:
	dc.l	plot_sprites

;- bss ---------------------------------------------------------------------

	bss

point_table:
	ds.w	1+256*3
trf_point_table:
	ds.w	1+256*3
trf_point_table2:
	ds.w	1+256*3
shifted_sprites:
	ds.b	SHIFT_SPRITE_SIZE*16*NUM_FRAMES
shift_adr_table:
	ds.l	NUM_FRAMES
bee_sprite:
	ds.b	SPRITE_SIZE*NUM_FRAMES

	ds.w	16
scan_table:
	ds.w	200

Matrix.temp:
	ds.b	Matrix.SIZE

frame:	ds.w	1

frames:	ds.l	256

num_points:
	ds.w	1

flap_frame_table:
	ds.b	FLAP_FRAME_SIZE*FLAP_FRAMES

mul_table:
	ds.w	256*256

clear_table1:
	ds.l	100
clear_table2:
	ds.l	100

flapping_mode:
	ds.w	1
start_flap_time:
	ds.w	1

zooming_mode:
	ds.w	1
zoom_start_time:
	ds.w	1
fixed_zoom:
	ds.w	1

fade_palette:
	ds.w	16*16
words_fade_palette:
	ds.w	16*16
title_fade_palette:
	ds.w	16*16
sprite_fading:
	ds.w	1
sprite_flash:
	ds.w	1
full_sprite_background:
	ds.w	1
