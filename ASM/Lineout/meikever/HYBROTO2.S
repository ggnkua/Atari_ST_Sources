; x it's a rotozoomer... 
;
; y argh! not again! please let me die in peace!!!
;
; x ..but it's on st, which has not been done too often, right
;
; y *jumps off cliff*
;
;
;
; 07-08-2007:
;
; fixed hang in VBL wait routine
;
; 09-08-2007: (00:50)
;
; fixed vector computations
;
; 10-08-2007:
;
; replaced c2p scheme.. (fixed c2p table generation, shifted palette 1 
; entry, fixed small paint rout bugs).
; added scan doubler..
;
; 11-08-2007:
;
; reduced frame height, added VBL measurement
; update (19:30): corrected center of rotation
;
; 13-08-2007:
;
; pre-stepped version: twice as fast, c2p and texture look-up still wrong
;
; 14-08-2007:
;
; 02:49: partially correction c2p/txt look-ups, the longword texture is 
; hell to get right..
; 13:34: decided to skip the horizontal texture wrap to reduce offset
; range. this will fix the longword texture right..
; 22:28: slight unrolling optimisations, fixed mapping mirror image stuff.
;
; 16-08-2007:
; added fade rout..
; hybrid of 8x8 and 2x2 rotozoomer to re-use code (faderouts, texture,
; geometry)
;
; 18-08-2007:
; added linear zoom trajectory, rotation 'boosts'
;
; 16-09-2007:
;
; wallace&gromit texture.. discovered bug on falcon in 2x2 mode? looks like
; bitplane offset mishaps? fixed: set d0 to 0 in code generator.
;
; 01-11-2007:
;
; rottenness revisited. trying to get the 8x8 mode more stylish 
;
; 27-01-2008:
;
; loads of changes: better texture, fixed festering edges, fixed
; trajectory.
;
; 16-02-2008:
;
; half/half palette fade.. (from current palette (!))
; first fade the blue (logo), then the reds (background)
; keep it blocky
; when res is changed to 2x2, fade in the reds (!)
;

Rot.DISPLAY_MAPPING:=	1				; actually render the mapping (1/0)?
Rot.NR_VBLS:=		3				; minimum amount of VBLs to take
Rot.MEASURE_CPU:=	0				; raster cpu measurement
Rot.DOUBLE_SCAN:=	1				; double scans or leave black scans inbetween?

Rot.TGA:=		1
Rot.MAX_Y:=		200				; amount of physical scanlines read by the video chip
Rot.FRAME_HEIGHT:=	88 ;92 with optimised music?	; in double scans

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Rot.mainloop			; 0
	dc.l	Rot.init			; 1
	dc.l	Rot.rt_init			; 2
	dc.l	Rot.deinit			; 3
	dc.l	dummy				; 4
	dc.l	Rot.toggle_blocky		; 5
	dc.l	Rot.trigger_fade_out		; 6
	dc.l	Rot.trigger_fade_in		; 7
	dc.l	Rot.set_linear_zoom		; 8
	dc.l	Rot.set_rotozoom		; 9
	dc.l	Rot.trigger_fastrot_right	; A
	dc.l	Rot.trigger_fastrot_left	; B
	dc.l	Rot.set_blockcircle		; C
	dc.l	Rot.set_pointycircle		; D
	dc.l	Rot.set_squares			; E
	dc.l	Rot.set_smallsquares		; F
	dc.l	Rot.set_rings			;10
	dc.l	Rot.trigger_fade_out_front	;11
	dc.l	Rot.trigger_fade_out_back	;12
;	dc.l	Rot.trigger_fade_in_front	;13
;	dc.l	Rot.trigger_fade_in_back	;14
	dc.l	0

;- plugin routines ---------------------------------------------------------

Rot.init:
	;move.w	#$0FFF,$FFFF8240.w

; note: only needed for tga.
	ifne	Rot.TGA
	lea	Rot.apx_texture,a0
	move.w	#Rot.TGA_SIZE-1,d7
.loop:	move.b	(a0),d0
	;lsr.b	#4,d0
	move.b	d0,(a0)+
	dbf	d7,.loop
	endc

	;move.w	#$0000,$FFFF8240.w
	rts

Rot.rt_init:
; align c2p table on 64k boundary
	move.l	#Rot.c2p_table,d1
	sub.w	d1,d1
	move.l	d1,Rot.c2p_address

	bsr	Rot.gen_c2p_table

	bsr	Rot.init_texture_wordmode
	bsr	Rot.init_texture_nibble0
	bsr	Rot.init_mapping_code
	bsr	Rot.calc_fadepals

	bsr	Rot.set_linear_zoom
	bsr	Rot.set_8x8

	;bsr	Rot.set_smallsquares
	;bsr	Rot.set_rings
	bsr	Rot.set_squares

	clr.w	Rot.measured_vbls
	move.w	$0468.w,Rot.old_468
	rts

Rot.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Rot.mainloop:

	movea.l	scr,a1
	lea	(100-Rot.FRAME_HEIGHT)*160(a1),a1
	move.l	a1,Rot.screen

	ifne	1

	ifne	Rot.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.end_clear
	movea.l	scr,a6
	lea	32000(a6),a6
	bsr	Rot.clear_banner
	movea.l	scr,a6
	lea	(100-Rot.FRAME_HEIGHT)*160(a6),a6
	bsr	Rot.clear_banner
.end_clear:

	ifne	Rot.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	;movea.l	scr,a0
	;bsr	CLEAR_STSCREEN
	;bsr	Rot.paint_test

	movea.l	Rot.geom_rout,a0
	jsr	(a0)
; (d2.w,d3.w) = vector a (8.8)
; (d4.w,d5.w) = vector b (8.8)
; d6.w = zoom (8.8)

	movea.l	Rot.paint_rout,a0
	jsr	(a0)

	ifne	Rot.MEASURE_CPU
	movea.l	scr,a0
	move.w	Rot.measured_vbls,d0
	cmpi.w	#20,d0
	blo.s	.range_ok
	moveq	#20,d0
.range_ok:
	moveq	#-1,d1
	subq.w	#1,d0
	bmi.s	.end_paint_vbls
.paint_vbls_loop:
	movep.l	d1,(a0)
	addq	#8,a0
	dbf	d0,.paint_vbls_loop
.end_paint_vbls:
	clr.l	(a0)+
	clr.l	(a0)+
	endc

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifne	Rot.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#Rot.init_pal,palirq
.end_pal:

	endc

; wait for vbl..
	move.w	Rot.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Rot.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Rot.old_468
	move.w	d1,Rot.measured_vbls

	rts

Rot.measured_vbls:
	ds.w	1

Rot.old4ba:
	ds.l	1
Rot.old_468:
	ds.w	1

;--------------------------------------------------------------------------

Rot.toggle_blocky:
	cmpi.l	#Rot.paint_2x2,Rot.paint_rout
	beq.s	Rot.set_8x8
Rot.set_2x2:
	move.l	#Rot.paint_2x2,Rot.paint_rout
	rts
Rot.set_8x8:
	move.l	#Rot.paint_8x8,Rot.paint_rout
	rts

Rot.trigger_fade_in_:
	bsr	getTime
	move.l	d0,Rot.fade_start_time
	move.w	#+63,Rot.fade_steps_left
	;move.l	#Rot.blackfade_table,Rot.fade_table_addr
	move.l	#Rot.bluefade_table,Rot.fade_table_addr
	move.l	#Rot.perform_fade_step,palirq
	rts

Rot.trigger_fade_in:
	move.w	#0,Rot.fade_mode
	bsr	getTime
	move.l	d0,Rot.fade_start_time
	move.w	#+63,Rot.fade_steps_left
	move.l	#Rot.yellowfade_table,Rot.fade_table_addr
	move.l	#Rot.perform_fade_step,palirq
	rts
;	move.w	#0,Rot.fade_mode
;	bra	Rot.trigger_fade_in_

Rot.trigger_fade_in_front:
	move.w	#+1,Rot.fade_mode
	bra	Rot.trigger_fade_in_

Rot.trigger_fade_in_back:
	move.w	#-1,Rot.fade_mode
	bra	Rot.trigger_fade_in_

Rot.trigger_fade_out_:
	bsr	getTime
	move.l	d0,Rot.fade_start_time
	move.w	#-63,Rot.fade_steps_left
	;move.l	#Rot.blackfade_table,Rot.fade_table_addr
	move.l	#Rot.bluefade_table,Rot.fade_table_addr
	move.l	#Rot.perform_fade_step,palirq
	rts

Rot.trigger_fade_out:
	move.w	#0,Rot.fade_mode
	bsr	getTime
	move.l	d0,Rot.fade_start_time
	move.w	#-63,Rot.fade_steps_left
	move.l	#Rot.yellowfade_table,Rot.fade_table_addr
	move.l	#Rot.perform_fade_step,palirq
	rts

Rot.trigger_fade_out_front:
	move.w	#+1,Rot.fade_mode
	bra	Rot.trigger_fade_out_

Rot.trigger_fade_out_back:
	move.w	#-1,Rot.fade_mode
	bra	Rot.trigger_fade_out_

Rot.set_linear_zoom:
	bsr	getTime
	move.l	d0,Rot.event_start_time
	move.l	#Rot.calc_linear_zoom,Rot.geom_rout
	rts

Rot.set_rotozoom:
	bsr	getTime
	move.l	d0,Rot.event_start_time
	move.l	#Rot.calc_rotozoom,Rot.geom_rout
	move.l	d0,Rot.normalrot_start_time
	rts

Rot.trigger_fastrot_right:
	bsr	getTime
	move.l	d0,Rot.fastrot_start_time
	move.w	#+1,Rot.fastrot_enable
	rts

Rot.trigger_fastrot_left:
	bsr	getTime
	move.l	d0,Rot.fastrot_start_time
	move.w	#-1,Rot.fastrot_enable
	rts

Rot.set_blockcircle:
	move.l	#Rot.make_blockcircles,Rot.mask_rout
	rts

Rot.set_pointycircle:
	move.l	#Rot.make_pointycircles,Rot.mask_rout
	rts

Rot.set_squares:
	move.l	#Rot.make_squares,Rot.mask_rout
	rts

Rot.set_smallsquares:
	move.l	#Rot.make_smallsquares,Rot.mask_rout
	rts

Rot.set_rings
	move.l	#Rot.make_rings,Rot.mask_rout
	rts

;--------------------------------------------------------------------------

Rot.init_pal:
	lea	$FFFF8240.w,a0
	rept	8
	move.l	#$0DEF0DEF,(a0)+
	endr
	rts

	movem.l	Rot.texture_pal,d0-d7
	ifne	0
	not.l	d0
	not.l	d1
	not.l	d2
	not.l	d3
	else
	move.l	#dummy,palirq
	endc
	movem.l	d0-d7,(a0)
	move.w	#12,Rot.frames_to_wait
	move.l	#Rot.wait_frames,palirq
	rts

Rot.wait_frames:
	subq.w	#1,Rot.frames_to_wait
	bgt.s	.end
	move.l	#Rot.init_pal2,palirq
.end:	rts

Rot.frames_to_wait:
	ds.w	1

Rot.init_pal2:
	lea	$FFFF8240.w,a0
	movem.l	Rot.texture_pal,d0-d7
	movem.l	d0-d7,(a0)
	move.l	#dummy,palirq
	rts

Rot.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	Rot.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#64,d1
.fade_index_ok:
	lsl.w	#3,d1
	andi.w	#$FFE0,d1
	movea.l	Rot.fade_table_addr,a0
	;adda.w	d1,a0

	tst.w	Rot.fade_mode
	beq.s	.all
	bgt.s	.front

.back:	move.l	2(a0,d1.w),$FFFF8242.w
	movem.l	4*2(a0,d1.w),d0-d1/d3/d5
	movem.l	d0-d1/d3/d5,$FFFF8248.w
	bra.s	.pal_is_set

.front:	move.w	0(a0,d1.w),$FFFF8240.w
	move.w	6(a0,d1.w),$FFFF8246.w
	movem.l	12*2(a0,d1.w),d0-d1
	movem.l	d0-d1,$FFFF8258.w
	bra.s	.pal_is_set

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
.pal_is_set:

	move.l	Rot.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,Rot.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

Rot.calc_fadepals:
; split palette up into 24bit
	lea	Rot.org_palette,a1
	lea	Rot.tmp_pal(pc),a0
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

; fade to white... (for 4th bitplane)
	lea	Rot.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	Rot.tmp_pal(pc),a1
	moveq	#16-1,d6

.entryloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

; mix color with white.
	move.b	(a1)+,d0
	mulu.w	d7,d0
	move.b	(a1)+,d1
	mulu.w	d7,d1
	move.b	(a1)+,d2
	mulu.w	d7,d2

	add.w	d5,d0
	add.w	d5,d1
	add.w	d5,d2

	ror.w	#5,d0
	ror.b	#5,d1
	ror.b	#5,d2
; ste
	move.w	d0,d3
	andi.w	#$8000,d3
	lsr.w	#4,d3
	move.w	d3,d4
	move.b	d1,d3
	andi.b	#$80,d3
	or.b	d3,d4
	move.b	d2,d3
	andi.b	#$80,d3
	lsr.b	#4,d3
	or.b	d3,d4
;st
	andi.w	#$0007,d0
	andi.w	#$0007,d1
	andi.w	#$0007,d2
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	move.w	d4,(a0)+
	dbf	d6,.entryloop

	dbf	d7,.loop

; fade-to-black
	lea	Rot.blackfade_table,a0
	moveq	#16-1,d7
.lowloop:
	lea	Rot.tmp_pal(pc),a1
	moveq	#16-1,d6

.lowentryloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

	addq.w	#1,d7
	move.b	(a1)+,d0
	mulu.w	d7,d0
	move.b	(a1)+,d1
	mulu.w	d7,d1
	move.b	(a1)+,d2
	mulu.w	d7,d2
	subq.w	#1,d7

	ror.w	#5,d0
	ror.b	#5,d1
	ror.b	#5,d2

	move.w	d0,d3
	andi.w	#$8000,d3
	lsr.w	#4,d3
	move.w	d3,d4
	move.b	d1,d3
	andi.b	#$80,d3
	or.b	d3,d4
	move.b	d2,d3
	andi.b	#$80,d3
	lsr.b	#4,d3
	or.b	d3,d4

	andi.w	#$0007,d0
	andi.w	#$0007,d1
	andi.w	#$0007,d2
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	move.w	d4,(a0)+
	dbf	d6,.lowentryloop

	dbf	d7,.lowloop

; fade to blue (or any colour you like)
	lea	Rot.bluefade_table,a0
	moveq	#16-1,d7
	movea.w	#11,a3			; a3= dst red level
	movea.w	#13,a4			; a4= dst green level
	movea.w	#15,a5			; a5= dst blue level

.bloop:	lea	Rot.tmp_pal(pc),a1
	moveq	#16-1,d6

.bentryloop:
	clr.l	d3
	clr.l	d4
	clr.l	d5
	move.b	(a1)+,d3		; d3.w=r
	move.b	(a1)+,d4		; d4.w=g
	move.b	(a1)+,d5		; d5.w=b

	cmp.w	d3,a3
	blt.s	.rdown
.rup:	add.w	d7,d3
	cmp.w	a3,d3
	ble.s	.rok
	move.w	a3,d3
	bra.s	.rok
.rdown:	sub.w	d7,d3
	cmp.w	a3,d3
	bgt.s	.rok
	move.w	a3,d3
.rok:
	cmp.w	d4,a4
	blt.s	.gdown
.gup:	add.w	d7,d4
	cmp.w	a4,d4
	ble.s	.gok
	move.w	a4,d4
	bra.s	.gok
.gdown:	sub.w	d7,d4
	cmp.w	a4,d4
	bgt.s	.gok
	move.w	a4,d4
.gok:
	cmp.w	d5,a5
	blt.s	.bdown
.bup:	add.w	d7,d5
	cmp.w	a5,d5
	ble.s	.bok
	move.w	a5,d5
	bra.s	.bok
.bdown:	sub.w	d7,d5
	cmp.w	a5,d5
	bgt.s	.bok
	move.w	a5,d5
.bok:

; r,g,b -> STe palette format
	ror.w	d3
	ror.b	d4
	ror.b	d5
; ste
	move.w	d3,d0
	andi.w	#$8000,d0
	lsr.w	#4,d0
	move.w	d0,d1		; d1.w=r0<<11
	move.b	d4,d0
	andi.b	#$80,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7
	move.b	d5,d0
	andi.b	#$80,d0
	lsr.b	#4,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7+b0<<3
; st
	andi.w	#$0007,d3
	andi.w	#$0007,d4
	andi.w	#$0007,d5
	lsl.w	#8,d3
	lsl.w	#4,d4
	or.w	d3,d5
	or.w	d4,d5		; d5.w=%0RRR0GGG0BBB
	or.w	d1,d5		; d5.w=%rRRRgGGGbBBB
	move.w	d5,(a0)+
	dbf	d6,.bentryloop

	dbf	d7,.bloop

; fade to yellow (or any colour you like)
	lea	Rot.yellowfade_table,a0
	moveq	#16-1,d7
	movea.w	#12,a3			; a3= dst red level
	movea.w	#12,a4			; a4= dst green level
	movea.w	#0,a5			; a5= dst blue level

.yloop:	lea	Rot.tmp_pal(pc),a1
	moveq	#16-1,d6

.yentryloop:
	clr.l	d3
	clr.l	d4
	clr.l	d5
	move.b	(a1)+,d3		; d3.w=r
	move.b	(a1)+,d4		; d4.w=g
	move.b	(a1)+,d5		; d5.w=b

	cmp.w	d3,a3
	blt.s	.y_rdown
.y_rup:	add.w	d7,d3
	cmp.w	a3,d3
	ble.s	.y_rok
	move.w	a3,d3
	bra.s	.y_rok
.y_rdown:
	sub.w	d7,d3
	cmp.w	a3,d3
	bgt.s	.y_rok
	move.w	a3,d3
.y_rok:
	cmp.w	d4,a4
	blt.s	.y_gdown
.y_gup:	add.w	d7,d4
	cmp.w	a4,d4
	ble.s	.y_gok
	move.w	a4,d4
	bra.s	.y_gok
.y_gdown:
	sub.w	d7,d4
	cmp.w	a4,d4
	bgt.s	.y_gok
	move.w	a4,d4
.y_gok:
	cmp.w	d5,a5
	blt.s	.y_bdown
.y_bup:	add.w	d7,d5
	cmp.w	a5,d5
	ble.s	.y_bok
	move.w	a5,d5
	bra.s	.y_bok
.y_bdown:
	sub.w	d7,d5
	cmp.w	a5,d5
	bgt.s	.y_bok
	move.w	a5,d5
.y_bok:

; r,g,b -> STe palette format
	ror.w	d3
	ror.b	d4
	ror.b	d5
; ste
	move.w	d3,d0
	andi.w	#$8000,d0
	lsr.w	#4,d0
	move.w	d0,d1		; d1.w=r0<<11
	move.b	d4,d0
	andi.b	#$80,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7
	move.b	d5,d0
	andi.b	#$80,d0
	lsr.b	#4,d0
	or.b	d0,d1		; d1.w=r0<<11+g0<<7+b0<<3
; st
	andi.w	#$0007,d3
	andi.w	#$0007,d4
	andi.w	#$0007,d5
	lsl.w	#8,d3
	lsl.w	#4,d4
	or.w	d3,d5
	or.w	d4,d5		; d5.w=%0RRR0GGG0BBB
	or.w	d1,d5		; d5.w=%rRRRgGGGbBBB
	move.w	d5,(a0)+
	dbf	d6,.yentryloop

	dbf	d7,.yloop

	rts

Rot.tmp_pal:
	ds.b	3*16

;--------------------------------------------------------------------------

Rot.clear_banner:
	ifgt	100-Rot.FRAME_HEIGHT

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d0,a0
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5


; clear the main part..
	rept	((100-Rot.FRAME_HEIGHT)*160)/56
	movem.l	d0-a5,-(a6)				; 14*4=56
	endr

; clear the left-overs too..
LONGS_TO_CLEAR	set	((100-Rot.FRAME_HEIGHT)*40)
LONGS_DONE	set	(LONGS_TO_CLEAR/14)*14
	rept	LONGS_TO_CLEAR-LONGS_DONE
	move.l	d0,-(a6)
	endr

	endc
	rts

; calculate all 128x128 word textures..
; pre: Rot.c2p_address is valid and on 64k boundary
Rot.init_texture_wordmode:
	lea	Rot.apx_texture+788,a0
	lea	Rot.nibble_long_texture,a1
	lea	Rot.nibble_word_texture,a2
	moveq	#128-1,d7

.word_yloop:
	moveq	#128-1,d6
	move.l	Rot.c2p_address,d1

.word_xloop:
	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0				; adjust for c2p LUT usage (longword entries).
	lsl.w	#4,d0				; d0.w=$0p<<6
	move.w	d0,2(a2)			; store $0p<<6
	lsl.w	#4,d0				; d0.w=$0p<<10
	move.w	d0,(a2)				; store $0p<<10.
	addq	#4,a2
	lsl.l	#4,d0				; d0.l= $0p<<14
	add.l	d1,d0				; d0.l= $0p<<14 + c2p table start.
	move.l	d0,(a1)+			; store.
	dbf	d6,.word_xloop

	dbf	d7,.word_yloop

; tile it for y wrap.
	lea	Rot.nibble_long_texture,a1
	lea	Rot.nibble_long_texture+128*128*4,a0	; ysize*xsize*pixsize
	move.w	#273-1,d7
.vtile_nib3_loop:
offset	set	0
	rept	5
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,offset(a0)
offset	set	offset+48
	endr
	lea	48*5(a0),a0
	dbf	d7,.vtile_nib3_loop
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,(a0)

	lea	Rot.nibble_word_texture,a1
	lea	Rot.nibble_word_texture+128*128*4,a0	; ysize*xsize*pixsize
	move.w	#273-1,d7
.vtile_nib2_loop:
offset	set	0
	rept	5
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,offset(a0)
offset	set	offset+48
	endr
	lea	48*5(a0),a0
	dbf	d7,.vtile_nib2_loop
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,(a0)

	rts

; calculate all 128x128 word textures..
Rot.init_texture_nibble0:
	lea	Rot.apx_texture+788,a0
	lea	Rot.nibble0_word_texture,a4
	moveq	#128-1,d7

.word_yloop:
	moveq	#128-1,d6

.word_xloop:
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a4)+			; store $000p.
	dbf	d6,.word_xloop

	dbf	d7,.word_yloop

	rts

Rot.gen_c2p_table:
	movea.l	Rot.c2p_address,a6
	lea	.TAB1(pc),A0
	MOVEQ	#0,D3

.loop1:	LEA	.TAB2(pc),A1
	MOVEQ	#0,D4

.loop2:	MOVEQ	#0,D5
	LEA	.TAB3(pc),A2

.loop3:	MOVEQ	#$10-1,D6
	LEA	.TAB4(pc),A3
	MOVE.L  (A0),D2
	OR.L	(A1),D2
	OR.L	(A2),D2

.loop4:	MOVE.L	D2,D0
	OR.L	(A3)+,D0
	MOVE.L  D0,(A6)+
	DBF	D6,.loop4

	ADDQ	#4,A2
	ADDQ.W  #4,D5
	CMP.B   #$40,D5
	BNE.S   .loop3

	ADDQ	#4,A1
	ADDQ.W  #4,D4
	CMP.B   #$40,D4
	BNE.S   .loop2

	ADDQ	#4,A0
	ADDQ.W  #4,D3
	CMP.B   #$40,D3
	BNE.S   .loop1
	RTS

.TAB1:	DC.B $00,$00,$00,$00
	DC.B $C0,$00,$00,$00
	DC.B $00,$C0,$00,$00
	DC.B $C0,$C0,$00,$00
	DC.B $00,$00,$C0,$00
	DC.B $C0,$00,$C0,$00
	DC.B $00,$C0,$C0,$00
	DC.B $C0,$C0,$C0,$00
	DC.B $00,$00,$00,$C0
	DC.B $C0,$00,$00,$C0
	DC.B $00,$C0,$00,$C0
	DC.B $C0,$C0,$00,$C0
	DC.B $00,$00,$C0,$C0
	DC.B $C0,$00,$C0,$C0
	DC.B $00,$C0,$C0,$C0
	DC.B $C0,$C0,$C0,$C0
.TAB2:	DC.B $00,$00,$00,$00
	DC.B $30,$00,$00,$00
	DC.B $00,$30,$00,$00
	DC.B $30,$30,$00,$00
	DC.B $00,$00,$30,$00
	DC.B $30,$00,$30,$00
	DC.B $00,$30,$30,$00
	DC.B $30,$30,$30,$00
	DC.B $00,$00,$00,$30
	DC.B $30,$00,$00,$30
	DC.B $00,$30,$00,$30
	DC.B $30,$30,$00,$30
	DC.B $00,$00,$30,$30
	DC.B $30,$00,$30,$30
	DC.B $00,$30,$30,$30
	DC.B $30,$30,$30,$30
.TAB3:	DC.B $00,$00,$00,$00
	DC.B $0C,$00,$00,$00
	DC.B $00,$0C,$00,$00
	DC.B $0C,$0C,$00,$00
	DC.B $00,$00,$0C,$00
	DC.B $0C,$00,$0C,$00
	DC.B $00,$0C,$0C,$00
	DC.B $0C,$0C,$0C,$00
	DC.B $00,$00,$00,$0C
	DC.B $0C,$00,$00,$0C
	DC.B $00,$0C,$00,$0C
	DC.B $0C,$0C,$00,$0C
	DC.B $00,$00,$0C,$0C
	DC.B $0C,$00,$0C,$0C
	DC.B $00,$0C,$0C,$0C
	DC.B $0C,$0C,$0C,$0C
.TAB4:	DC.B $00,$00,$00,$00
	DC.B $03,$00,$00,$00
	DC.B $00,$03,$00,$00
	DC.B $03,$03,$00,$00
	DC.B $00,$00,$03,$00
	DC.B $03,$00,$03,$00
	DC.B $00,$03,$03,$00
	DC.B $03,$03,$03,$00
	DC.B $00,$00,$00,$03
	DC.B $03,$00,$00,$03
	DC.B $00,$03,$00,$03
	DC.B $03,$03,$00,$03
	DC.B $00,$00,$03,$03
	DC.B $03,$00,$03,$03
	DC.B $00,$03,$03,$03
	DC.B $03,$03,$03,$03

Rot.calc_linear_zoom:

; First we calculate the current time.
	bsr	getTime
	sub.l	Rot.event_start_time,d0
	lsr.l	#2,d0
	;moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d6
	lea	sine_tbl,a0

; Now we calculate our center position.
	move.w	d1,d3
	mulu.w	#13,d1
	lsr.l	#1,d1
	mulu.w	#17,d3
	lsr.l	#1,d3
	andi.w	#SINTABLE_LEN-1,d1
	andi.w	#SINTABLE_LEN-1,d3
	add.w	d1,d1
	add.w	d1,d1
	move.w	(a0,d1.w),d2
	add.w	d3,d3
	add.w	d3,d3
	move.w	(a0,d3.w),d3
	asr.w	#2,d2
	asr.w	#1,d3

	;addi.w	#$4000,d2
	;addi.w	#$6B00,d3
	addi.w	#$8000,d2
	addi.w	#$B000,d3

	movem.w	d2/d3,Rot.center

; And now we calculate the rotation..
	mulu.w	#23,d0
	lsr.l	#2,d0
	;subi.w	#$100,d0
	andi.w	#SINTABLE_LEN-1,d0
	add.w	d0,d0
	add.w	d0,d0
	moveq	#0,d0
	movem.w	(a0,d0.w),d0-d1
; d0.w: +sin(fi)
; d1.w: +cos(fi)

; a'.x = +cos(fi)
; a'.y = -sin(fi)
	move.w	d1,d2
	move.w	d0,d3
	neg.w	d3
; d2.w: a'.x, d3.w: a'.y
; b'.x = +sin(fi)
; b'.y = +cos(fi)
	move.w	d0,d4
	move.w	d1,d5
; d4.w: b'.x, d5.w: b'.y

; And we calculate the amount of zoom...
	mulu.w	#7,d6
	lsr.l	#1,d6
	andi.w	#SINTABLE_LEN-1,d6
	move.w	d6,Rot.zoom_angle
	add.w	d6,d6
	add.w	d6,d6
	move.w	2(a0,d6.w),d6
	asr.w	#7,d6
	addi.w	#$0280,d6
	;move.w	#$0800,d6
	rts

Rot.calc_rotozoom:

; First we calculate the current time.
	bsr	getTime
	move.l	d0,.time
	sub.l	Rot.event_start_time,d0
	lsr.l	#2,d0
	;moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d6
	lea	sine_tbl,a0

; Now we calculate our center position.
	move.w	d1,d3
	mulu.w	#13,d1
	lsr.l	#1,d1
	mulu.w	#17,d3
	lsr.l	#1,d3
	andi.w	#SINTABLE_LEN-1,d1
	andi.w	#SINTABLE_LEN-1,d3
	add.w	d1,d1
	add.w	d1,d1
	move.w	(a0,d1.w),d2
	add.w	d3,d3
	add.w	d3,d3
	move.w	(a0,d3.w),d3
	asr.w	#2,d2
	asr.w	#1,d3
	;addi.w	#$4000,d2
	;addi.w	#$6B00,d3
	addi.w	#$8000,d2
	addi.w	#$B000,d3
	movem.w	d2/d3,Rot.center

; And now we calculate the rotation..
	move.l	.time(pc),d1
	sub.l	Rot.fastrot_start_time,d1
	tst.w	Rot.fastrot_enable
	beq.s	.noboost
	cmpi.l	#$00000100,d1
	blt.s	.boost
; boost expired, store stop time..
	move.l	.time(pc),Rot.normalrot_start_time
	bra.s	.noboost

; boost it (4x speed).. use new time and saved angle..
.boost:	tst.w	Rot.fastrot_enable
	bpl.s	.boost_direction_ok
	neg.l	d1
.boost_direction_ok:

	lsr.l	#2,d1
	mulu.w	#23,d1
	add.w	Rot.roto_angle,d1
	move.w	d1,d0
	move.w	d0,Rot.boost_roto_angle
	bra.s	.calc_xy_rot

.noboost:
	clr.w	Rot.fastrot_enable
	move.l	.time(pc),d0
	sub.l	Rot.normalrot_start_time,d0
	lsr.l	#2,d0
	mulu.w	#23,d0
	lsr.l	#2,d0
	add.w	Rot.boost_roto_angle,d0
	move.w	d0,Rot.roto_angle

.calc_xy_rot:
	;subi.w	#$100,d0
	andi.w	#SINTABLE_LEN-1,d0
	add.w	d0,d0
	add.w	d0,d0
	;moveq	#0,d0
	movem.w	(a0,d0.w),d0-d1
; d0.w: +sin(fi)
; d1.w: +cos(fi)

; a'.x = +cos(fi)
; a'.y = -sin(fi)
	move.w	d1,d2
	move.w	d0,d3
	neg.w	d3
; d2.w: a'.x, d3.w: a'.y
; b'.x = +sin(fi)
; b'.y = +cos(fi)
	move.w	d0,d4
	move.w	d1,d5
; d4.w: b'.x, d5.w: b'.y

; And we calculate the amount of zoom...
	mulu.w	#7,d6
	lsr.l	#1,d6
	add.w	Rot.zoom_angle,d6
	andi.w	#SINTABLE_LEN-1,d6
	add.w	d6,d6
	add.w	d6,d6
	move.w	2(a0,d6.w),d6
	asr.w	#7,d6
	addi.w	#$0280,d6
	;move.w	#$0800,d6
	rts

.time:	ds.l	1

Rot.MAPITER_START:
Rot.MAPLONG:=	*+2-Rot.MAPITER_START
	move.l	$1234(a1),d5			;  16
Rot.MAPWORD1:=	*+2-Rot.MAPITER_START
	or.w	$1234(a2),d5			;  12
Rot.MAPWORD2:=	*+2-Rot.MAPITER_START
	or.w	$1234(a2),d5			;  12
Rot.MAPBYTE:=	*+2-Rot.MAPITER_START
	or.b	$1234(a2),d5			;  12
	movea.l	d5,a5				;   4
	move.l	(a5),d5				;  12
Rot.MOVEP:=	*+2-Rot.MAPITER_START
	movep.l	d5,$1234(a0)			;  24
						; --- +
						;  96
Rot.MAPITER_END:
Rot.MAPITER_SIZE:=	(Rot.MAPITER_END-Rot.MAPITER_START)

Rot.init_mapping_code:
	lea	Rot.map_code_buf,a0
	moveq	#0,d0
	moveq	#20-1,d7

.loop:	movea.l	a0,a2
	lea	Rot.MAPITER_START,a1
	rept	Rot.MAPITER_SIZE/2
	move.w	(a1)+,(a0)+
	endr
	move.w	d0,Rot.MOVEP(a2)
	addq.w	#1,d0

	movea.l	a0,a2
	lea	Rot.MAPITER_START,a1
	rept	Rot.MAPITER_SIZE/2
	move.w	(a1)+,(a0)+
	endr
	move.w	d0,Rot.MOVEP(a2)
	addq.w	#7,d0
	dbf	d7,.loop
	rts

; 2x2 paint rout, pre-stepped.
Rot.paint_2x2:
; And zoom the damn thing!
	neg.w	d2
	neg.w	d3
	muls.w	d6,d2
	muls.w	d6,d3
	muls.w	d6,d4
	muls.w	d6,d5
;	add.l	d2,d2		; was halved with old paint loop..
	add.l	d3,d3
;	add.l	d4,d4		; was halved with old paint loop..
	add.l	d5,d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5

; straight vectors, for testing..
	;move.l	#$0100,d2
	;move.l	#$0000,d3
	;move.l	#$0000,d4
	;move.l	#$0100,d5

	movem.w	Rot.center,d6/d7
;	lsl.l	#3,d6
;	lsl.l	#3,d7
	asr.l	d6		; halve U pos (for old paint loop, obsolete)

	;move.l	#$8000,d6
	;move.l	#$8000,d7
	
; compute top left corner position..
; note: d2-d5 are 16 bit signed fractional
	movea.l	d2,a2
	movea.l	d3,a3
	movea.l	d4,a4
	movea.l	d5,a5

	muls.w	#Rot.FRAME_HEIGHT/2,d2
	muls.w	#Rot.FRAME_HEIGHT/2,d3
	add.l	d2,d6
	add.l	d3,d7
	muls.w	#80,d4
	muls.w	#80,d5
	sub.l	d4,d6				; d6.l=topleft_u (8.8)
	sub.l	d5,d7				; d7.l=topleft_v (8.8)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

; prepare vectors for combined add, addx loop..

; top-left
	andi.l	#$0000FFFF,d7
	ror.l	#8,d7				; d7.l=     $vv----VV
	move.w	d7,Rot.v_int_pos		; v_int_pos=$------VV
	move.w	d6,d7				; d7.l=     $vv--UUuu
	move.l	d7,Rot.uv_pos			; uv_pos=   $vv--UUuu
; a (vector on the vertical screen axis)
	andi.l	#$0000FFFF,d3
	ror.l	#8,d3				; d3.l=     $ay----AY
	move.w	d3,Rot.v_int_inc		; v_int_inc=    $--AY
	move.w	d2,d3				; d3.l=     $ay--AXax
	move.l	d3,Rot.uv_inc			; uv_inc=   $ay--AXax
; b (vector on the horizontal screen axis)
	andi.l	#$0000FFFF,d5
	ror.l	#8,d5				; d5.l=     $by----BY
	move.w	d5,d0				; d0.w=         $--BY
	move.w	d4,d5				; d5.l=     $by--AXax
	move.l	d5,d3				; d3.l=     $by--AXax
	move.w	d0,d4				; d4.w=         $--BY

	move.w	#$7FFE,d6
	moveq	#Rot.FRAME_HEIGHT-1,d7
	move.l	Rot.uv_pos(pc),d0
	move.w	Rot.v_int_pos(pc),d1

; store original top-left offset
	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	move.w	d2,Rot.org_offset

; pre-step the thing.. you gotta love it. stay away from high zoom!
	lea	Rot.map_code_buf,a0

offset	set	0
	rept	40				; 160/4

	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	add.w	d2,d2				; %UUUUUUUVVVVVVV00
	move.w	d2,offset+Rot.MAPLONG(a0)
	add.l	d3,d0				;
	addx.b	d4,d1				;

	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	add.w	d2,d2				; %UUUUUUUVVVVVVV00
	move.w	d2,offset+Rot.MAPWORD1(a0)
	add.l	d3,d0				;
	addx.b	d4,d1				;

	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	add.w	d2,d2				; %UUUUUUUVVVVVVV00
	addq.w	#2,d2
	move.w	d2,offset+Rot.MAPWORD2(a0)
	add.l	d3,d0				;
	addx.b	d4,d1				;

	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	add.w	d2,d2				; %UUUUUUUVVVVVVV00
	move.w	d2,offset+Rot.MAPBYTE(a0)
	add.l	d3,d0				;
	addx.b	d4,d1				;

offset	set	offset+Rot.MAPITER_SIZE
	endr

; the actual rendering code..
	move.l	Rot.screen,a0
	lea	Rot.nibble_long_texture+128*256*2,a1
	lea	Rot.nibble_word_texture+128*256*2,a2
	moveq	#Rot.FRAME_HEIGHT-1,d7

Rot.map_code_buf:
	ds.b	Rot.MAPITER_SIZE*40

	lea	160*2(a0),a0
	move.l	Rot.uv_pos(pc),d0
	move.w	Rot.v_int_pos(pc),d1
	add.l	Rot.uv_inc(pc),d0
	move.w	Rot.v_int_inc(pc),d5
	addx.b	d5,d1
	move.l	d0,Rot.uv_pos
	move.w	d1,Rot.v_int_pos
	
	move.w	d0,d2				;
	move.b	d1,d2				; %UUUUUUUUVVVVVVVV
	and.w	d6,d2				; %0UUUUUUUVVVVVVV0
	move.w	Rot.org_offset(pc),d5
	sub.w	d2,d5				; d5.w=offset from org offset ;)
	add.w	d5,d5
	lea	Rot.nibble_long_texture+128*256*2,a1
	adda.w	d5,a1
	lea	Rot.nibble_word_texture+128*256*2,a2
	adda.w	d5,a2
	dbf	d7,Rot.map_code_buf

; double the scan lines..
	ifne	Rot.DOUBLE_SCAN

	ifne	Rot.MEASURE_CPU
	ifeq	testmode
	move.w	#$0F00,$FFFF8240.w
	endc
	endc

	move.l	Rot.screen,a1
	lea	160(a1),a0
offset	set	0
	rept	Rot.FRAME_HEIGHT
	movem.l	(a1)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,offset(a0)
	movem.l	(a1)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,offset+52(a0)
	movem.l	(a1)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,offset+104(a0)
	move.l	(a1)+,offset+156(a0)
offset	set	offset+320
	lea	160(a1),a1
	endr
	endc

	rts

; 8x8 paint rout, direct offset computation (not pre-stepped!).
Rot.paint_8x8:
; And zoom the damn thing!
	muls.w	d6,d2
	muls.w	d6,d3
	muls.w	d6,d4
	muls.w	d6,d5
;	add.l	d2,d2		; halve U step (for paint loop)
	add.l	d3,d3
;	add.l	d4,d4		; halve U step (for paint loop)
	add.l	d5,d5
	swap	d2
	swap	d3
	swap	d4
	swap	d5

; scale for blockiness.. this blocky version should overlap well with the
; fine precision version..
; todo: put this in a subroutine..
	lsl.l	#2,d2
	lsl.l	#2,d3
	lsl.l	#2,d4
	lsl.l	#2,d5

; straight vectors, for testing..
	;move.l	#$0100,d2
	;move.l	#$0000,d3
	;move.l	#$0000,d4
	;move.l	#$0100,d5

	movem.w	Rot.center,d6/d7
	asr.l	d6		; halve U pos (for paint loop)

	;move.l	#$8000,d6
	;move.l	#$8000,d7
	
; compute top left corner position..
; note: d2-d5 are 16 bit signed fractional
	movea.l	d2,a2
	movea.l	d3,a3
	movea.l	d4,a4
	movea.l	d5,a5

	muls.w	#Rot.FRAME_HEIGHT/8,d2
	muls.w	#Rot.FRAME_HEIGHT/8,d3
	sub.l	d2,d6
	sub.l	d3,d7
	muls.w	#160/8,d4
	muls.w	#160/8,d5
	sub.l	d4,d6				; d6.l=topleft_u (16.16)
	sub.l	d5,d7				; d7.l=topleft_v (16.16)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

; prepare vectors for combined add, addx loop..

; top-left
	andi.l	#$0000FFFF,d7
	ror.l	#8,d7				; d7.l=     $vv----VV
	move.w	d7,Rot.v_int_pos			; v_int_pos=$------VV
	move.w	d6,d7				; d7.l=     $vv--UUuu
	move.l	d7,Rot.uv_pos			; uv_pos=   $vv--UUuu
; a (vector on the vertical screen axis)
	andi.l	#$0000FFFF,d3
	ror.l	#8,d3				; d3.l=     $ay----AY
	move.w	d3,Rot.v_int_inc			; v_int_inc=    $--AY
	move.w	d2,d3				; d3.l=     $ay--AXax
	move.l	d3,Rot.uv_inc			; uv_inc=   $ay--AXax
; b (vector on the horizontal screen axis)
	andi.l	#$0000FFFF,d5
	ror.l	#8,d5				; d5.l=     $by----BY
	move.w	d5,d0				; d0.w=         $--BY
	move.w	d4,d5				; d5.l=     $by--AXax
	move.l	d5,d3				; d3.l=     $by--AXax
	move.w	d0,d4				; d4.w=         $--BY

	movea.l	Rot.screen,a0
	lea	Rot.nibble0_word_texture,a1
	lea	Rot.block_table,a5
	move.l	#$7FFE,d6
	moveq	#Rot.FRAME_HEIGHT/4-1,d7
	moveq	#0,d2
	move.l	Rot.uv_pos(pc),d0
	move.w	Rot.v_int_pos(pc),d1

.yloop:

offset	set	0

	REPT	20

	move.w	d0,d2				;  4
	move.b	d1,d2				;  4, %UUUUUUUUVVVVVVVV
	and.w	d6,d2				;  4, %0UUUUUUUVVVVVVV0
	move.w	(a1,d2.w),d5			; 14 (16)
	add.w	d5,d5				;  4
	add.w	d5,d5				;  4
	move.l	(a5,d5.w),d5			; 18 (20)
	movep.l	d5,offset(a0)			; 24
	add.l	d3,d0				;  4
	addx.b	d4,d1				;  4
						; -- +
						; 88

	move.w	d0,d2				;  4
	move.b	d1,d2				;  4, %UUUUUUUUVVVVVVVV
	and.w	d6,d2				;  4, %0UUUUUUUVVVVVVV0
	move.w	(a1,d2.w),d5			; 14 (16)
	add.w	d5,d5				;  4
	add.w	d5,d5				;  4
	move.l	(a5,d5.w),d5			; 18 (20)
	movep.l	d5,offset+1(a0)			; 24
	add.l	d3,d0				;  4
	addx.b	d4,d1				;  4
						; -- +
						; 88


offset	set	offset+8

	ENDR

	lea	160*8(a0),a0
	move.l	Rot.uv_pos(pc),d0
	move.w	Rot.v_int_pos(pc),d1
	add.l	Rot.uv_inc(pc),d0
	move.w	Rot.v_int_inc(pc),d5
	addx.b	d5,d1
	move.l	d0,Rot.uv_pos
	move.w	d1,Rot.v_int_pos
	dbf	d7,.yloop

; double the scan lines..
	ifne	Rot.DOUBLE_SCAN

	movea.l	Rot.mask_rout,a0
	jsr	(a0)

	endc

	rts

Rot.uv_pos:dc.l	0
Rot.v_int_pos:
	dc.w	0
Rot.uv_inc:dc.l	0
Rot.v_int_inc:
	dc.w	0
Rot.org_offset:
	dc.w	0

Rot.block_table:
	dc.l	$00000000
	dc.l	$FF000000
	dc.l	$00FF0000
	dc.l	$FFFF0000
	dc.l	$0000FF00
	dc.l	$FF00FF00
	dc.l	$00FFFF00
	dc.l	$FFFFFF00
	dc.l	$000000FF
	dc.l	$FF0000FF
	dc.l	$00FF00FF
	dc.l	$FFFF00FF
	dc.l	$0000FFFF
	dc.l	$FF00FFFF
	dc.l	$00FFFFFF
	dc.l	$FFFFFFFF
     
Rot.make_squares:
	movea.l	Rot.screen,a1
	lea	160(a1),a0
	moveq	#Rot.FRAME_HEIGHT/4-1,d7

.octiply_loop:

offset	set	0
	rept	7
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,offset(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,offset+48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,offset+96(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,offset+144(a0)
	lea	-160(a1),a1
offset	set	offset+160
	endr

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop
	rts

Rot.make_pointycircles:
	movea.l	Rot.screen,a1
	movea.l	a1,a0
	moveq	#Rot.FRAME_HEIGHT/4-1,d7
	moveq	#0,d4
	moveq	#0,d5
	movea.l	d4,a2
	movea.l	d4,a3
 
.octiply_loop:

	move.l	Rot.circle2+4,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*1+offset(a0)
	movem.l	d0-d3,160*5+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle2+8,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*2+offset(a0)
	movem.l	d0-d3,160*4+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle2+12,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*3+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle2,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*0+offset(a0)
	movem.l	d0-d3,160*6+offset(a0)
	movem.l	d4/d5/a2/a3,160*7+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop

	rts

Rot.make_blockcircles:
	movea.l	Rot.screen,a1
	movea.l	a1,a0
	moveq	#Rot.FRAME_HEIGHT/4-1,d7

.octiply_loop:
	move.l	Rot.circle+4,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*1+offset(a0)
	movem.l	d0-d3,160*6+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle+8,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*2+offset(a0)
	movem.l	d0-d3,160*5+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle+12,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*3+offset(a0)
	movem.l	d0-d3,160*4+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.circle,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*0+offset(a0)
	movem.l	d0-d3,160*7+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop

	rts

Rot.make_smallsquares:
	movea.l	Rot.screen,a1
	movea.l	a1,a0
	moveq	#Rot.FRAME_HEIGHT/4-1,d7
	moveq	#0,d4
	moveq	#0,d5
	movea.l	d4,a2
	movea.l	d4,a3
 
.octiply_loop:

	move.l	Rot.small_square+4,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*0+offset(a0)
	movem.l	d0-d3,160*1+offset(a0)
	movem.l	d0-d3,160*2+offset(a0)
	movem.l	d0-d3,160*3+offset(a0)
	movem.l	d0-d3,160*4+offset(a0)
	movem.l	d0-d3,160*5+offset(a0)
	movem.l	d0-d3,160*6+offset(a0)
	movem.l	d4/d5/a2/a3,160*7+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop
	rts

Rot.make_rings:
	movea.l	Rot.screen,a1
	movea.l	a1,a0
	moveq	#Rot.FRAME_HEIGHT/4-1,d7
	moveq	#0,d4
	moveq	#0,d5
	movea.l	d4,a2
	movea.l	d4,a3
 
.octiply_loop:

	move.l	Rot.ring+4,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*1+offset(a0)
	movem.l	d0-d3,160*5+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.ring+8,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*2+offset(a0)
	movem.l	d0-d3,160*4+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.ring+12,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*3+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	move.l	Rot.ring,d6
offset	set	0
	rept	10
	movem.l	(a1)+,d0-d3
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	movem.l	d0-d3,160*0+offset(a0)
	movem.l	d0-d3,160*6+offset(a0)
	movem.l	d4/d5/a2/a3,160*7+offset(a0)
offset	set	offset+16
	endr
	lea	-160(a1),a1

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop

	rts

;--------------------------------------------------------------------------

	data

Rot.apx_texture:
Rot.tga:
	ifeq	Rot.TGA

	;incbin	text1.apx
	incbin	now_the2.apx

	else

	;dc.b	460
	;incbin	now_the3.tga

	;ds.b	788-18 
	;incbin	nowthenk.tga

	dcb.b	2,$03
	;incbin	gfx\test4bpl.tga
	incbin	gfx\test4bp2.tga

Rot.end_tga:
	endc
	even

Rot.TGA_SIZE:=	Rot.end_tga-Rot.tga

Rot.texture_pal:
	;incbin	textpal.dat
	ifne	Rot.TGA

; W&G greyscale
;	dc.w	$000,$888,$111,$999,$222,$AAA,$333,$BBB
;	dc.w	$444,$CCC,$555,$DDD,$666,$EEE,$777,$FFF
; kev's test.tga (conved to 4bpl)
;	dc.w	$DEF,$C13,$E23,$000,$FC3,$FE3,$FFC,$FFD
;	dc.w	$3CD,$CDE,$23C,$001,$000,$000,$000,$000
; kev's 128x128.tga (conved to 4bpl)
        dc.w    $0DEF			; 0 blue (11,13,15)
        dc.w    $0FC3
        dc.w    $0FD3
        dc.w    $0000
        dc.w    $0FF3
        dc.w    $0FFC
        dc.w    $0FE3
        dc.w    $0F33
        dc.w    $0E23
        dc.w    $0D23
        dc.w    $0C13
        dc.w    $0312
        dc.w    $0FFD
        dc.w    $03DF			; D blue
        dc.w    $033E			; E blue
        dc.w    $032D			; F blue

	else
	dc.w	$777,$777,$666,$666,$555,$555,$444,$444
	dc.w	$333,$333,$222,$222,$111,$111,$000,$000
	endc
	even

Rot.org_palette:=	Rot.texture_pal

Rot.circle:
	rept	4
	dc.b	%00000000
	endr
	rept	4
	dc.b	%00111100
	endr
	rept	4
	dc.b	%01111110
	endr
	rept	4
	dc.b	%01111110
	endr

Rot.circle2:
	rept	4
	dc.b	%00010000
	endr
	rept	4
	dc.b	%01111100
	endr
	rept	4
	dc.b	%01111100
	endr
	rept	4
	dc.b	%11111110
	endr

Rot.small_square:
	rept	4
	dc.b	%00000000
	endr
	rept	4
	dc.b	%11111110
	endr
	rept	4
	dc.b	%11111110
	endr
	rept	4
	dc.b	%11111110
	endr

Rot.ring:
	ifne	1
	rept	4
	dc.b	%01111100
	endr
	rept	4
	dc.b	%11111110
	endr
	rept	4
	dc.b	%11000110
	endr
	rept	4
	dc.b	%11000110
	endr
	else
	rept	4
	dc.b	%11111110
	endr
	rept	4
	dc.b	%11111110
	endr
	rept	4
	dc.b	%11000110
	endr
	rept	4
	dc.b	%11000110
	endr
	endc

Rot.mask_rout:
	dc.l	Rot.make_blockcircles
	;dc.l	Rot.make_pointycircles

;--------------------------------------------------------------------------

	bss

Rot.bla_on:
	ds.w	1
Rot.blocky_mode:
	ds.w	1

Rot.center:
	ds.w	2
Rot.zoom_angle:
	ds.w	1
Rot.roto_angle
	ds.w	1
Rot.boost_roto_angle:
	ds.w	1

Rot.c2p_address:
	ds.l	1

Rot.whitefade_table:
	ds.w	16*16
Rot.blackfade_table:
	ds.w	16*16
Rot.bluefade_table:
	ds.w	16*16
Rot.yellowfade_table:
	ds.w	16*16

Rot.paint_rout:
	ds.l	1
Rot.geom_rout:
	ds.l	1

Rot.event_start_time:
	ds.l	1
Rot.fade_start_time:
	ds.l	1
Rot.fastrot_start_time:
	ds.l	1
Rot.normalrot_start_time:
	ds.l	1

Rot.fastrot_enable:
	ds.w	1

Rot.fade_steps_left:
	ds.w	1
Rot.fade_table_addr:
	ds.l	1

Rot.fade_mode:
	ds.w	1

Rot.screen:
	ds.l	1

;----
	ifnd	DEMO_SYSTEM
	include common.s
	endc

; textures: pre-shifted (for c2p) and tiled (for vertical wrapping)
Rot.nibble_long_texture:=	Common.block
;	ds.l	128*128
;	ds.l	128*128
Rot.nibble_word_texture:=	(Common.block+128*128*4*2)
;	ds.w	128*128*2
;	ds.w	128*128*2
Rot.nibble0_word_texture:=	(Rot.nibble_word_texture+128*128*4*2)
;	ds.w	128*128

;	ds.b	65536				; for 64K alignment (speed optimisation reasons)
Rot.c2p_table:=			(Rot.nibble0_word_texture+128*128*2+65536)
;	ds.l	65536

