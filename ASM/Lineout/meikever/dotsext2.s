; 3d dot object morpher..
;
; 21-08-2007:
;
; initial version
; 
; 23-08-2007:
;
; several putpixel routs on the test bench for speed.. result: smc sucks.
; added transformation code
;
; 24-08-2007
;
; bitplane clear and dot clear (faster for anything less than 800 dots)
;
; 26-08-2007:
;
; attempt at massive lut based plot, for extra speed. limited range:
; -128<=x<+128 ! result: 20% faster overall. main clockcycle waste is still
; the 3d transformation.. can transform, display and restore 450 dots/VBL
;
; 31-08-2007:
;
; attempt at extruded version.. should provide -way- more dots for your
; money by ditching the z in the transformation (since z=0) and by using
; dotlines to extrude the thing.
;
; 11-09-2007
;
; extrusion was indeed a great idea. it's really fast. 1000 dots/vbl
; including everything (except sidvoice?) is totally feasible. this is
; because the transformation code is easily optimised.
;
; now trying to optimise it more.. i won't store all extruded points but
; i'll just use multiple offsets with each non-extruded point..
; 
; 13-09-2007:
;
; discovered that storing less offsets is not correct.. the x chunk 
; position can't be computed by a start offset + per-frame fixed offsets.
; these vary per point, cos of sub-chunk precision... there goes another
; hard days work.. a set-back in terms of speed.. may need to drop a few
; dots. although, unrolling the clear loop a bit more might win a few more
; cycles.
;
; fixed a bug in the prestepping code, though.. addq/subq #8 wasn't done!
;
; 15-09-2007:
;
; added morping.. a slow rout but the overshoot spring stuff works..
; modified rotation (to 'floating') to get the 3d logos readable.. 
; added banners and new palette.. 
; added banner mask/unmask logos
;
; 18-09-2007:
;
; using multiply table for morphing.. (still shit, needs decent init)
; source objects in 2d format -> faster. optimised transform (again)
; multable-based morphing is inherent shit, cos of the large differences
; between coords: |dx|>128.. needs a separate table or 512x256 entries
; one for everything..
;
; 19-09-2007:
;
; heavy optimisation on the 3d transform.. weird i didn't see this
; earlier.. init the address registers to offsets in the multable
; corresponding to matrix coefficients. saves 52 cycles per extrude. 
; also using new multable now (higher x range) which is essential for the
; table based morphs.
;
; todo: reduce mult table to 1/4 size. just mirror the required table lines
; when executing the routines in question. could be fast enough?
;
; 12-01-2008:
;
; clean up..
;
;
; todo: smc to generate code tables (speeds up assembly)

Dots.NR_VBLS:=		1				; minimum amount of VBLs to take
Dots.MEASURE_CPU:=	0				; raster cpu measurement
Dots.MAX_Y:=		200				; amount of physical scanlines read by the video chip
Dots.FRAME_HEIGHT:=	92				; in double scans
Dots.NUM_DOTS:=		160 168 176 192 352 284			; number of dots before extrusion!
Dots.EXTRUDE_FACTOR:=	5
Dots.PERSPECTIVE:=	0
Dots.MAX_NUM_DOTS:=	2000				; limit for dot buffers!
Dots.MULTAB_MORPH:=	1				; alot faster..
Dots.NEW_MULTAB:=	1				; [-176,+175] instead of [-128,+127] x range, a must for multable morph

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	mat.s
	include	common.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Dots.mainloop			; 0
	dc.l	Dots.init			; 1
	dc.l	Dots.rt_init			; 2
	dc.l	Dots.deinit			; 3
	dc.l	Dots.trigger_360		; A
	dc.l	Dots.trigger_code_logo		; 5
	dc.l	Dots.trigger_zik_logo		; 6
	dc.l	Dots.trigger_art_logo		; 7
	dc.l	Dots.trigger_square_logo	; 8
	dc.l	Dots.trigger_fuji_logo		; 9
	dc.l	Dots.trigger_360		; A
	dc.l	0

;- plugin routines ---------------------------------------------------------

Dots.init:
	;move.w	#$0FFF,$FFFF8240.w

	;move.w	#$0000,$FFFF8240.w
	rts

; todo: in case of memory shortage, let all this stuff use temporary 
; buffers..
Dots.rt_init:
	move.l	#Dots.fuji_3d_dot_table,Dots.start_obj_adr
	move.l	#Dots.fuji_3d_dot_table,Dots.end_obj_adr

	jsr	Dots.init_plot_table

	ifne	Dots.NEW_MULTAB
	jsr	Lib3D.precalc_mul_table_new
	else
	jsr	Lib3D.precalc_mul_table
	endc

	jsr	Dots.gen_paint_code
	jsr	Dots.gen_clear_code

	clr.w	Dots.measured_vbls
	move.w	$0468.w,Dots.old_468
	rts

Dots.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Dots.mainloop:

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	movea.l	scr,a0
	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.bpl_clear

	jsr	CLEAR_STSCREEN
; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc
	move.l	#Dots.init_pal,palirq
	rts

.bpl_clear:
; when doing 1000+ dots, this should be done with clearing the entire plane
; otherwise wipe the old dots.. 
	movea.l	Dots.dot_offsets_adrs,a1
	jsr	Dots.clear_old_dots
.end_clear:

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0455,$FFFF8240.w
	endc
	endc

;	ifne	Dots.MEASURE_CPU
;	ifeq	testmode
;.wait:	tst.b	$FFFF8209.w
;	beq.s	.wait
;	move.w	#$00F0,$FFFF8240.w
;	endc
;	endc

	move.w	frmcnt+2,d0
	sub.w	Dots.morph_start_frame,d0
	move.w	d0,d1
	cmpi.w	#256,d0
	blt.s	.index_range_ok
	move.w	#256,d0
.index_range_ok:
	movea.l	Dots.start_obj_adr,a1
	movea.l	Dots.end_obj_adr,a2
;	andi.w	#$0080,d1
;	beq.s	.ok
;	exg	a1,a2
.ok	bsr	Dots.twodee_morph

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	jsr	getTime
	move.l	d0,d1
	move.l	d0,d2
	mulu.w	#5,d1
	lsr.l	#1,d1
	mulu.w	#3,d2
	mulu.w	#7,d0
	lsr.l	#1,d0
	andi.w	#SINTABLE_LEN-1,d0
	andi.w	#SINTABLE_LEN-1,d1
	andi.w	#SINTABLE_LEN-1,d2
	lea	sine_tbl,a0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d2
	add.w	d2,d2
	move.b	(a0,d0.w),d0
	move.w	(a0,d1.w),d1
	move.b	(a0,d2.w),d2
	ext.w	d0
	asr.w	#7,d1
	ext.w	d2

	tst.w	Dots.spin_enabled
	beq.s	.spin_done
	move.w	frmcnt+2,d3
	sub.w	Dots.spin_start_frame,d3
	lsl.w	#5,d3
	cmpi.w	#SINTABLE_LEN,d3
	blt.s	.spin_ok
	clr.w	Dots.spin_enabled
.spin_ok:
	add.w	d3,d0
.spin_done:

	add.w	#1024,d0 +100
	add.w	#0,d1 +100
	add.w	#-512,d2 +200
	move.w	#1000,d3
	jsr	Lib3D.generate_matrix

; nasty test shit!
;	lea	Dots.temp_matrix,a1
;	move.w	#$0000,Matrix.XZ(a1)
;	move.w	#$7FFF,Matrix.YZ(a1)

	movea.l	Dots.extr_scr_offsets_adrs,a0
	lea	Lib3D.temp_matrix,a1
	bsr	Dots.calc_extrude_offsets

	lea	Dots.2d_dot_table,a0
	lea	Lib3D.temp_matrix,a1
	lea	Dots.morphed_dot_table,a2
	bsr	Dots.transform

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0F00,$FFFF8240.w
	endc
	endc

	bsr	Dots.paint_old

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	ifne	Dots.MEASURE_CPU
	movea.l	scr,a0
	move.w	Dots.measured_vbls,d0
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

; swap transformed buffers
	lea	Dots.dot_offsets_adrs,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
; swap extrusion screen offset buffers
	lea	Dots.extr_scr_offsets_adrs,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)

; shift old dot counts, increase new dot count when necessary
	lea	Dots.num_active,a0
	move.w	2(a0),4(a0)
	move.w	(a0),2(a0)
	move.w	(a0),d0
	addq.w	#1,d0
	cmpi.w	#Dots.NUM_DOTS,d0
	bgt.s	.sat
	move.w	d0,(a0)
.sat:

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifne	Dots.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

;	move.l	frmcnt,d0
;	cmp.l	lastfrmcnt,d0
;	bne.s	.end_pal
;	move.l	#Dots.init_pal,palirq
;.end_pal:

; wait for vbl..
	move.w	Dots.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Dots.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Dots.old_468
	move.w	d1,Dots.measured_vbls

	rts

Dots.measured_vbls:
	ds.w	1

Dots.old4ba:
	ds.l	1
Dots.old_468:
	ds.w	1

;--------------------------------------------------------------------------

Dots.trigger_code_logo:
	move.w	frmcnt+2,Dots.morph_start_frame
	move.w	Dots.banner_src_offset,Dots.old_banner_src_offset
	move.w	Dots.banner_dst_offset,Dots.old_banner_dst_offset
	move.w	#30,Dots.wipe_countdown
	move.w	#0,Dots.banner_src_offset
	move.w	#0,Dots.banner_dst_offset
	move.l	#Dots.wipe_banner,palirq
	move.l	Dots.end_obj_adr,Dots.start_obj_adr
	move.l	#Dots.earx_3d_dot_table,Dots.end_obj_adr
	rts

Dots.trigger_zik_logo:
	move.w	frmcnt+2,Dots.morph_start_frame
	move.w	Dots.banner_src_offset,Dots.old_banner_src_offset
	move.w	Dots.banner_dst_offset,Dots.old_banner_dst_offset
	move.w	#30,Dots.wipe_countdown
	move.w	#4*8,Dots.banner_src_offset
	move.w	#4*8*4,Dots.banner_dst_offset
	move.l	#Dots.wipe_banner,palirq
	move.l	Dots.end_obj_adr,Dots.start_obj_adr
	move.l	#Dots.msg_3d_dot_table,Dots.end_obj_adr
	rts

Dots.trigger_art_logo:
	move.w	frmcnt+2,Dots.morph_start_frame
	move.w	Dots.banner_src_offset,Dots.old_banner_src_offset
	move.w	Dots.banner_dst_offset,Dots.old_banner_dst_offset
	move.w	#30,Dots.wipe_countdown
	move.w	#4*8*2,Dots.banner_src_offset
	move.w	#160*170,Dots.banner_dst_offset
	move.l	#Dots.wipe_banner,palirq
	move.l	Dots.end_obj_adr,Dots.start_obj_adr
	move.l	#Dots.pea_3d_dot_table,Dots.end_obj_adr
	rts

Dots.trigger_square_logo:
	move.w	frmcnt+2,Dots.morph_start_frame
	move.w	Dots.banner_src_offset,Dots.old_banner_src_offset
	move.w	Dots.banner_dst_offset,Dots.old_banner_dst_offset
	move.w	#30,Dots.wipe_countdown
; copy empty spans..
	move.w	#4*8*3,Dots.banner_src_offset
	move.w	#160*170+4*8*4,Dots.banner_dst_offset
	move.l	#Dots.wipe_banner,palirq
	move.l	Dots.end_obj_adr,Dots.start_obj_adr
	move.l	#Dots.square_3d_dot_table,Dots.end_obj_adr
	rts

Dots.trigger_fuji_logo:
	move.w	frmcnt+2,Dots.morph_start_frame
	move.w	Dots.banner_src_offset,Dots.old_banner_src_offset
	move.w	Dots.banner_dst_offset,Dots.old_banner_dst_offset
	move.w	#30,Dots.wipe_countdown
; copy empty spans..
	move.w	#4*8*3,Dots.banner_src_offset
	move.w	#160*170+4*8*4,Dots.banner_dst_offset
	move.l	#Dots.wipe_banner,palirq
	move.l	Dots.end_obj_adr,Dots.start_obj_adr
	move.l	#Dots.fuji_3d_dot_table,Dots.end_obj_adr
	rts

Dots.trigger_360:
	move.w	frmcnt+2,Dots.spin_start_frame
	move.w	#$FFFF,Dots.spin_enabled
	rts

;--------------------------------------------------------------------------

Dots.init_pal:
	lea	$FFFF8240.w,a0
	movem.l	Dots.logos+2,d0-d7
	move.l	#dummy,palirq
	movem.l	d0-d7,(a0)
	rts

Dots.wipe_banner:
	move.w	Dots.wipe_countdown,d0
.start:	subq.w	#1,d0
	bmi.s	.restart
	move.w	d0,Dots.wipe_countdown

;	lsr.w	#1,d0
	andi.w	#$FFFE,d0
	move.w	.odd(pc),d1
	andi.w	#1,d1
	add.b	d1,d0
	movea.l	scr,a0
	lea	Dots.logos+34,a1
	mulu.w	#160,d0
	adda.w	d0,a0
	add.w	Dots.banner_src_offset,a1

	movea.l	a0,a3
	add.w	Dots.old_banner_dst_offset,a3

	add.w	Dots.banner_dst_offset,a0
	movem.l	(a1,d0.w),d1-d7/a2
	movem.l	d1-d7/a2,(a0)

	cmpa.l	a0,a3
	beq.s	.end			; don't clear if it's the same address!
	moveq	#0,d0
	rept	8
	move.l	d0,(a3)+
	endr

.end:	rts	

.restart:
	move.w	#30,d0
	not.w	.odd
	beq.s	.start

.stop:	move.l	#dummy,palirq
	rts

.odd:	dc.w	$FFFF

;--------------------------------------------------------------------------

; input: 
; d0.w=time [0..255+20]
; a1: start ('0') souce object
; a2: end ('1') source object
Dots.twodee_morph:
; look-up morph function value..
	lea	Dot.morph_function,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d4
	addi.w	#2048,d4			; d4.w=m (morph coefficient)
	;addi.w	#1947,d4			; d4.w=m (morph coefficient)

	lea	Dots.morphed_dot_table,a0

	ifne	Dots.MULTAB_MORPH

	ifne	Dots.NEW_MULTAB
	lea	Lib3D.mul_table+(128*352+176)*2,a3
	lsr.w	#5,d4
	mulu.w	#352*2,d4
	else
	lea	Lib3D.mul_table+128*256*2,a3
	ext.l	d4
	lsl.l	#4,d4
	andi.l	#$FFFFFE00,d4
	endc

	adda.l	d4,a3
	else
	moveq	#11,d6
	endc

	move.w	#Dots.NUM_DOTS-1,d7
.loop:	move.w	(a1)+,d0			; d0.w=x0
	move.w	(a1)+,d1			; d1.w=y0
	move.w	(a2)+,d2			; d2.w=x1
	move.w	(a2)+,d3			; d3.w=y1
	sub.w	d0,d2				; d2.w=dx
	sub.w	d1,d3				; d3.w=dy

	ifne	0
	cmpi.w	#-128,d2
	bge.s	.xok
	illegal
.xok:	cmpi.w	#+128,d2
	blt.s	.xok2
	illegal
.xok2:	cmpi.w	#-128,d3
	bge.s	.yok
	illegal
.yok:	cmpi.w	#+128,d3
	blt.s	.yok2
	illegal
.yok2:
	endc

	ifne	Dots.MULTAB_MORPH
	add.w	d2,d2
	add.w	(a3,d2.w),d0
	add.w	d3,d3
	add.w	(a3,d3.w),d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	else
	muls.w	d4,d2				; d2.l=dx*m
	muls.w	d4,d3				; d3.l=dy*m
	asr.l	d6,d2
	asr.l	d6,d3
	add.w	d0,d2				; d2.l=x0+(dx*m/1024)
	add.w	d1,d3				; d3.l=xy+(dy*m/1024)
	move.w	d2,(a0)+			; store x.
	move.w	d3,(a0)+			; store y.
	endc

	dbf	d7,.loop
	rts

Dots.SMC_PRESTEP:=	1

; input:
; a0: dst screen offsets
; a1: matrix
Dots.calc_extrude_offsets:
	lea	Dots.extr_abs_offsets(pc),a5
	move.w	Matrix.XZ(a1),d6
	move.w	Matrix.YZ(a1),d7
	ext.l	d6
	ext.l	d7
	lsl.l	#4,d6
	lsl.l	#4,d7
	move.l	d6,d0
	move.l	d7,d1
	neg.l	d0
	neg.l	d1
	add.l	d0,d0				; start x
	add.l	d1,d1				; start y
	move.l	d0,d4
	move.l	d1,d5
	swap	d4
	swap	d5
	move.b	d4,Dots.extr_x_start
	move.b	d5,Dots.extr_y_start
	moveq	#0,d0				; kill start offset for now, cos .transform already does that..
	moveq	#0,d1	
	suba.l	a6,a6

.prestep_loop:
	move.l	d0,d4
	move.l	d1,d5
	swap	d4
	swap	d5
	move.b	d4,(a5)+
	move.b	d5,(a5)+

	andi.w	#$FFF0,d5
	asr.w	#1,d5
	muls.w	#160,d4
	add.w	d5,d4
;	move.w	a6,d3
;	andi.w	#3,d3
;	add.w	d3,d3
;	add.w	d3,d4
	move.w	d4,(a0)+
	
	add.l	d6,d0
	add.l	d7,d1

	addq	#1,a6
	cmpa.w	#Dots.EXTRUDE_FACTOR,a6
	blt.s	.prestep_loop
	rts

Dots.extr_abs_offsets:
	ds.b	2*Dots.EXTRUDE_FACTOR

; todo: use previously generated abs offsets.. don't do double calcs!
; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Dots.transform:
; compute projected extrusion axis offsets..

	ifne	Dots.SMC_PRESTEP

	lea	.addq(pc),a5
	lea	Dots.extr_abs_offsets(pc),a4
; first one is different.. addq/subq don't support big enough range!
	addq	#8,a5
	move.b	(a4)+,d2
	move.b	(a4)+,d3
	movea.w	#1,a6

.prestep_loop:
	move.b	(a4)+,d4
	move.b	(a4)+,d5
	sub.b	d2,d4
	sub.b	d3,d5

; addq/subq format: 0101nnns.0100rrrr
; n: number (%001..%111 -> 1..7, %000 -> 8)
; r: register (0..7 -> d0..d7)
; s: sign: 0: add, 1: sub
	moveq	#0,d0
	move.b	d4,d1
	bpl.s	.xsign_ok
	moveq	#1,d0
	neg.b	d1
.xsign_ok:
	bne.s	.no_xnop
	move.w	#$4E71,(a5)+
	bra.s	.end_x
.no_xnop:
	add.b	d1,d1
	or.b	d1,d0
	ori.w	#%01010000,d0
	move.b	d0,(a5)+
	move.b	#%01000010,(a5)+
.end_x:

	moveq	#0,d0
	move.b	d5,d1
	bpl.s	.ysign_ok
	moveq	#1,d0
	neg.b	d1
.ysign_ok:
	bne.s	.no_ynop
	move.w	#$4E71,(a5)+
	bra.s	.end_y
.no_ynop:
	add.b	d1,d1
	or.b	d1,d0
	ori.w	#%01010000,d0
	move.b	d0,(a5)+
	move.b	#%01000011,(a5)+
.end_y:

	addq	#4,a5
	add.b	d4,d2
	add.b	d5,d3
	addq	#1,a6
	cmpa.w	#Dots.EXTRUDE_FACTOR,a6
	blt.s	.prestep_loop

	else

	lea	Dots.extr_axis_offsets(pc),a5
	move.w	Matrix.XZ(a1),d6
	move.w	Matrix.YZ(a1),d7
	ext.l	d6
	ext.l	d7
	lsl.l	#4,d6
	lsl.l	#4,d7
	move.l	d6,d0
	move.l	d7,d1
	neg.l	d0
	neg.l	d1
	add.l	d0,d0				; start x
	add.l	d1,d1				; start y
	moveq	#0,d2				; old x offset
	moveq	#0,d3				; old y offset
	suba.l	a6,a6

.prestep_loop:
	move.l	d0,d4
	move.l	d1,d5
	swap	d4
	swap	d5
	sub.w	d2,d4				; d4=b-a
	sub.w	d3,d5
	move.b	d4,(a5)+
	move.b	d5,(a5)+
	add.w	d4,d2				; d2=a+(b-a)=b
	add.w	d5,d3
	add.l	d6,d0
	add.l	d7,d1

	addq	#1,a6
	cmpa.w	#Dots.EXTRUDE_FACTOR,a6
	blt.s	.prestep_loop

	endc

;------

	move.b	Dots.extr_x_start(pc),d5
	move.b	Dots.extr_y_start(pc),d6
	move.w	#Dots.NUM_DOTS-1,d7		; d7.w=#vertices

	ifne	Dots.NEW_MULTAB

	lea	Lib3D.mul_table+(128*352+176)*2,a4

	move.b	6(a1),d0			; MYX, MYY
	ext.w	d0
	move.b	8(a1),d1			; MYX, MYY
	ext.w	d1
	muls.w	#352*2,d0
	muls.w	#352*2,d1
	lea	(a4,d0.l),a3
	lea	(a4,d1.l),a6
	
	move.b	(a1),d0				; MXX, MXY
	ext.w	d0
	move.b	2(a1),d1			; MXX, MXY
	ext.w	d1
	muls.w	#352*2,d0
	muls.w	#352*2,d1
	lea	(a4,d1.l),a5
	lea	(a4,d0.l),a4

	else

	lea	Lib3D.mul_table+128*256*2,a4

	movem.w	6(a1),d0/d1			; MYX, MYY
	clr.b	d0
	clr.b	d1
	add.w	d0,d0
	add.w	d1,d1
	lea	(a4,d0.l),a3
	lea	(a4,d1.l),a6

	movem.w	(a1),d0/d1			; MXX, MXY
	clr.b	d0
	clr.b	d1
	add.w	d0,d0
	add.w	d1,d1
	lea	(a4,d1.l),a5
	lea	(a4,d0.l),a4

	endc

; 264 cycles total for each extruded dot..
.vertexloop:
	move.w	(a2)+,d0			;  8
	move.w	(a2)+,d1

; x'
;	movem.w	(a1),d2-d3			; 20
;	move.b	d0,d2				;  4
;	move.b	d1,d3				;  4
;	add.w	d2,d2				;  4
;	add.w	d3,d3				;  4
;	move.w	(a4,d2.l),d2			; 16
;	add.w	(a4,d3.l),d2			; 16
; y'
;	move.l	a3,d3				;  4
;	move.l	a6,d4				;  4
;	move.b	d0,d3				;  4
;	move.b	d1,d4				;  4
;	add.w	d3,d3				;  4
;	add.w	d4,d4				;  4
;	move.w	(a4,d3.l),d3			; 16
;	add.w	(a4,d4.l),d3			; 16

	add.w	d0,d0				;  4
	add.w	d1,d1				;  4
	move.w	(a4,d0.w),d2			; 16
	add.w	(a5,d1.w),d2			; 16
	move.w	(a3,d0.w),d3			; 16
	add.w	(a6,d1.w),d3			; 16

; addq/subq smc optimisation?
	ifne	Dots.SMC_PRESTEP
.addq:

	add.b	d5,d2				;  4
	add.b	d6,d3				;  4
	move.b	d2,(a0)+			;  8 store x' coordinate.
	move.b	d3,(a0)+			;  8 store y' coordinate.
	rept	Dots.EXTRUDE_FACTOR-1
	nop					;  4
	nop					;  4
	move.b	d2,(a0)+			;  8 store x' coordinate.
	move.b	d3,(a0)+			;  8 store y' coordinate.
	endr

	else

	lea	-Dots.EXTRUDE_FACTOR*2(a5),a5
	rept	Dots.EXTRUDE_FACTOR
	add.b	(a5)+,d2
	add.b	(a5)+,d3
	move.b	d2,(a0)+			; store x' coordinate.
	move.b	d3,(a0)+			; store y' coordinate.
	endr

	endc

	dbf	d7,.vertexloop

	rts

Dots.extr_axis_offsets:
	ds.b	2*Dots.EXTRUDE_FACTOR

Dots.extr_x_start:
	ds.b	1
Dots.extr_y_start:
	ds.b	1

;--------------------------------------------------------------------------

Dots.paint_iteration:
	movem.w	(a1)+,d0-d4			; 32       xy0,xy1,xy2,..
	add.w	d0,d0				;  4
	add.w	d1,d1
	add.w	d2,d2
	add.w	d3,d3
	add.w	d4,d4
	move.w	(a2,d0.l),d6			; 14 (16!?)
	move.w	d6,(a4)+			;  8
	move.w	(a3,d0.l),d7			; 14 (16!)
	or.w	d7,6(a0,d6.w)			; 18 (20!)
	move.w	(a2,d1.l),d6			; 14 (16!?)
	move.w	d6,(a4)+			;  8
	move.w	(a3,d1.l),d7			; 14 (16!)
	or.w	d7,6(a0,d6.w)			; 18 (20!)
	move.w	(a2,d2.l),d6			; 14 (16!?)
	move.w	d6,(a4)+			;  8
	move.w	(a3,d2.l),d7			; 14 (16!)
	or.w	d7,2(a0,d6.w)			; 18 (20!)
	move.w	(a2,d3.l),d6			; 14 (16!?)
	move.w	d6,(a4)+			;  8
	move.w	(a3,d3.l),d7			; 14 (16!)
	or.w	d7,4(a0,d6.w)			; 18 (20!)
	move.w	(a2,d4.l),d6			; 14 (16!?)
	move.w	d6,(a4)+			;  8
	move.w	(a3,d4.l),d7			; 14 (16!)
	or.w	d7,4(a0,d6.w)			; 18 (20!)
						; -- +
						; 64x5+32=352 (70.4 per pixel)
Dots.end_paint_iteration:

Dots.clear_iteration:
	movem.w	(a1)+,d0-d5/a3-a6		; 52 x0,y0,x1,y1,..
	move.w	d7,6(a0,d0.w)			; 14 (16!)
	move.w	d7,6(a0,d1.w)			; 14 (16!)
	move.w	d7,2(a0,d2.w)			; 14 (16!)
	move.w	d7,4(a0,d3.w)			; 14 (16!)
	move.w	d7,4(a0,d4.w)			; 14 (16!)
	move.w	d7,6(a0,d5.w)			; 14 (16!)
	move.w	d7,6(a0,a3.w)			; 14 (16!)
	move.w	d7,2(a0,a4.w)			; 14 (16!)
	move.w	d7,4(a0,a5.w)			; 14 (16!)
	move.w	d7,4(a0,a6.w)			; 14 (16!)
						; -- +
						; 16x10+52=212 (21.2 per pixel)
Dots.end_clear_iteration:

Dots.gen_paint_code:
	lea	Dots.paint_code_buf,a0
	move.w	#Dots.NUM_DOTS-1,d7
.iter_loop:	
	lea	Dots.paint_iteration(pc),a1
	rept	(Dots.end_paint_iteration-Dots.paint_iteration)/4
	move.l	(a1)+,(a0)+
	endr
	dbf	d7,.iter_loop
	move.w	#$4E75,(a0)+			; rts
	rts

Dots.gen_clear_code:
	lea	Dots.clear_code_buf,a0
	move.w	#Dots.NUM_DOTS/2-1,d7
.iter_loop:	
	lea	Dots.clear_iteration(pc),a1
	rept	(Dots.end_clear_iteration-Dots.clear_iteration)/4
	move.l	(a1)+,(a0)+
	endr
	dbf	d7,.iter_loop
	move.w	#$4E75,(a0)+			; rts
	rts

Dots.paint_old:
	movea.l	scr,a0
	lea	Dots.2d_dot_table,a1
	movea.l	Dots.dot_offsets_adrs,a4
	lea	Dots.dot_offset_lut+(128*256+128)*2,a2
	lea	Dots.dot_bitnum_lut+(128*256+128)*2,a3
	lea	Dots.paint_code_buf+$54*Dots.NUM_DOTS,a5
	move.w	Dots.num_active,d0
	mulu.w	#$54,d0
	neg.l	d0
	jmp	(a5,d0.l)

.end:	rts

; input:
; a0: screen + bitplane offset
; a1: dot offsets (old)
Dots.clear_old_dots:
	moveq	#0,d7
	lea	Dots.clear_code_buf+$2C*Dots.NUM_DOTS/2,a5
	move.w	Dots.oldold_num_active,d0
	lsr.w	#1,d0
	mulu.w	#$2C,d0
	neg.l	d0
	jsr	(a5,d0.l)

	move.w	Dots.oldold_num_active,d0
	andi.w	#1,d0
	beq.s	.end
	movem.w	(a1)+,d0-d4			; .. x0,y0,x1,y1,..
	move.w	d7,6(a0,d0.w)			; 14 (16!)
	move.w	d7,6(a0,d1.w)			; 14 (16!)
	move.w	d7,2(a0,d2.w)			; 14 (16!)
	move.w	d7,4(a0,d3.w)			; 14 (16!)
	move.w	d7,4(a0,d4.w)			; 14 (16!)

.end:	rts

Dots.init_plot_table:
; init x offsets and bit masks
	move.w	#15-1,d7
	lea	.masks+16*4(pc),a0
	moveq	#8,d1

.init_offmask_chunk_loop:
	lea	.masks(pc),a1
	moveq	#16-1,d6

.init_offmask_loop:
	move.l	(a1)+,d0
	add.w	d1,d0
	move.l	d0,(a0)+
	dbf	d6,.init_offmask_loop

	addq	#8,d1
	dbf	d7,.init_offmask_chunk_loop

; now store masks and offsets for all coordinates:
; [-128,-128] .. [+127,+127]
	lea	Dots.dot_offset_lut,a0
	lea	Dots.dot_bitnum_lut,a1
	lea	Lib3D.scan_table,a3
	moveq	#-128,d7

.yloop:	lea	.masks(pc),a2
	move.w	d7,d3
	addi.w	#100,d3				; center y on screen.
	cmpi.w	#200,d3
	bcc.s	.clip_y
	move.w	d3,d2
	add.w	d2,d2
	move.w	(a3,d2.w),d4

	moveq	#128-1,d6
.xloop:
	rept	2
	move.w	(a2)+,(a1)+			; store bit mask.
	move.w	d4,d2
	add.w	(a2)+,d2
	move.w	d2,(a0)+			; store byte offset.
	endr
	dbf	d6,.xloop

.next_y:addq.w	#1,d7
	cmpi.w	#+128,d7
	blt.s	.yloop
	rts

;.clip:	moveq	#0,d0
;	move.w	d0,(a0)+
;	move.w	d0,(a1)+
;	bra.s	.next

.clip_y:moveq	#128-1,d5
	moveq	#0,d0
.cliploop:
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbf	d5,.cliploop
	bra.s	.next_y

.masks:	dc.w	$8000,+16,$4000,+16,$2000,+16,$1000,+16
	dc.w	$0800,+16,$0400,+16,$0200,+16,$0100,+16
	dc.w	$0080,+16,$0040,+16,$0020,+16,$0010,+16
	dc.w	$0008,+16,$0004,+16,$0002,+16,$0001,+16
	ds.l	256-16

;--------------------------------------------------------------------------

	data

Dots.num_dots:
	dc.w	1

Dots.dot_offsets_adrs:
	dc.l	Dots.dot_offsets1,Dots.dot_offsets2

Dots.fuji_3d_dot_table:
	include neon\fuji.s

Dots.msg_3d_dot_table:
	include neon\msgnew.s

Dots.earx_3d_dot_table:
	include neon\earx.s

Dots.pea_3d_dot_table:
	include neon\pea.s

Dots.square_3d_dot_table:
	include neon\square.s
	;include neon\rip.s

Dot.morph_function:
	include	boing.s

Dots.extr_scr_offsets_adrs:
	dc.l	Dots.extr_scr_offsets1,Dots.extr_scr_offsets2

Dots.logos:
	incbin	LOGOS2c.PI1

;--------------------------------------------------------------------------

	bss

Dots.bla_on:
	ds.w	1

Dots.center:
	ds.w	2

Dots.paint_rout:
	ds.l	1
Dots.geom_rout:
	ds.l	1

Dots.extr_scr_offsets1:
	ds.w	Dots.EXTRUDE_FACTOR
Dots.extr_scr_offsets2:
	ds.w	Dots.EXTRUDE_FACTOR

Dots.morph_start_frame:
	ds.w	1

Dots.wipe_countdown:
	ds.w	1
Dots.banner_src_offset:
	ds.w	1
Dots.banner_dst_offset:
	ds.w	1
Dots.old_banner_src_offset:
	ds.w	1
Dots.old_banner_dst_offset:
	ds.w	1

Dots.end_obj_adr:
	ds.l	1
Dots.start_obj_adr:
	ds.l	1

Dots.morph_pos:
	ds.w	1

Dots.spin_start_frame:
	ds.w	1
Dots.spin_enabled:
	ds.w	1

Dots.num_active:
	ds.w	1
Dots.old_num_active:
	ds.w	1
Dots.oldold_num_active:
	ds.w	1

	ds.l	1

Dots.dot_offset_lut:=	(Lib3D.mul_table+352*256*2)
Dots.dot_bitnum_lut:=	(Dots.dot_offset_lut+256*256*2)
Dots.2d_dot_table:=	(Dots.dot_bitnum_lut+256*256*2)
;	ds.b	2*Dots.MAX_NUM_DOTS
Dots.dot_offsets1:=	(Dots.2d_dot_table+2*Dots.MAX_NUM_DOTS)
;	ds.w	Dots.MAX_NUM_DOTS
Dots.dot_offsets2:=	(Dots.dot_offsets1+2*Dots.MAX_NUM_DOTS)
;	ds.w	Dots.MAX_NUM_DOTS
Dots.morphed_dot_table:=(Dots.dot_offsets2+2*Dots.MAX_NUM_DOTS)
;	ds.w	3*Dots.NUM_DOTS
Dots.paint_code_buf:=	(Dots.morphed_dot_table+2*3*Dots.NUM_DOTS)
;	ds.b	16+$54*Dots.NUM_DOTS
Dots.clear_code_buf:=	(Dots.paint_code_buf+16+$54*Dots.NUM_DOTS)
;	ds.b	16+$2C*Dots.NUM_DOTS/2
