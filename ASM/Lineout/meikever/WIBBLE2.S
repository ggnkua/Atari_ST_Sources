; wobbling vectors
;
; 17-11-2007:
;
; did an adaptation of ns logo stuff, with wibbling edges.
;
; 19-11-2007:
;
; attempt to add some filled vectors..
; 00:02: bah.. only added the first pieces of code from the glenz..
; fuck the rest, better done tomorrow..
;
; 23-11-2007:
;
; coding in the night sorta rules and sucks at the same time. i gotta get
; some stuff done.. now included all data and coded required for the poly
; rout.
;
; 24-11-2007:
;
; the poly rout is hacked to use visible edge flags. created an edge based
; cube object... prepared calls to the routs. the edge painter still has
; to use the visibility table. that's for tomorrow erm.. today (it's 
; 1:20AM)
;
;
; 29-11-2007:
;
; 01:00AM: seems to work a bit.. backface culling seems to have turned into
; front-face culling..
; ah shit.. realised i have to carefully order the edges in the polygons
; if i want this to work.. also, the poly rout doesn't seem to do anything,
; yay..
; 01:39AM: poly routs working again (needed table init)..
; but the polys need reordering, defo..
;
; 28-12-2007:
;
; seems one poly influences the other when painting.. odd.. let squash this
; bug..
; 18:50: reordering edges, (extra reverse order edges are required).
; but it still seems polys are influencing eachother.. bork! olfactory 
; senses suspect culling offset doodoo.
; 19:40: reordered edges, they are 100% ok now, offset crap todo
; 20:45: wow, too simple. it was an overwritten address register used for
; marking edges and slope look-ups (invtable), respectively..
; 20:50: time to optimise the background clearing..
; 21:20: shit, i have to take care of double edges.. either thru indirect
; lut or with mirror/bank type of thing..
; and in what planes is the stuff written?
; 22:00? got it all working
;
; 01-01-2008:
;
; when integrating this effect into the demo it fucked up the polys again..
; fuck..
; update: squashed it! thanks to this log (was the invtable)
;
; 12-01-2008:
;
; big clean-up. and using the line rout from the lib (aliased) it is also
; alot faster!
;
; xx-03-2008:
;
; optimised random rout (write long to mem, and fetch bytes, instead of
; shifts)..
;

; load from disk at init (1) or incbin (0)
	ifnd	DEMO_SYSTEM
Wibble.DYNAMIC_PI1:=	0 1
	else
; always 0 when included in demo system
Wibble.DYNAMIC_PI1:=	0
	endc

Wibble.NR_VBLS:=	1				; minimum amount of VBLs to take
Wibble.MEASURE_CPU:=	0				; raster cpu measurement
Wibble.MAX_Y:=		200				; amount of physical scanlines read by the video chip
Wibble.PERSPECTIVE:=	1
Wibble.MAX_NUM_DOTS:=	2000				; limit for dot buffers!
Wibble.MULTAB_MORPH:=	1				; alot faster..
Wibble.FAKECLIP:=	1				; fake clipping (using side mask) 1: on, 0: off

Wibble.MASK_OVERLAP:=	0

Wibble.BOX_HEIGHT:=	20
Wibble.BOX_WIDTH:=	70

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

	dc.l	Wibble.mainloop			; 0
	dc.l	Wibble.init			; 1
	dc.l	Wibble.rt_init			; 2
	dc.l	Wibble.deinit			; 3
	dc.l	Wibble.start_bouncing		; 4
	dc.l	Wibble.trigger_morph		; 5
	dc.l	Wibble.trigger_rotfix		; 6
	dc.l	Wibble.trigger_zoomout		; 7
	dc.l	Wibble.trigger_fadeout		; 8
	dc.l	0

;- plugin routines ---------------------------------------------------------

Wibble.init:
	;move.w	#$0FFF,$FFFF8240.w

	ifne	Wibble.DYNAMIC_PI1

; fopen
	clr.w	-(sp)
	pea	Wibble.pic_name
	move.w	#$3D,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bpl.s	.not_out
	jmp	OUT
.not_out:
	move.w	d0,.handle

	pea	Wibble.pic
	move.l	#32034,-(sp)
	move.w	d0,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp
	cmpi.l	#32034,d0
	beq.s	.not_out2
	jmp	OUT
.not_out2:

; fclose
	move.w	.handle(pc),-(sp)
	move.w	#$3E,-(sp)
	trap	#1
	addq	#4,sp

	endc

	;move.w	#$0000,$FFFF8240.w
	rts

.handle:dc.w	0

; todo: in case of memory shortage, let all this stuff use temporary 
; buffers..
Wibble.rt_init:
	ifne	0
; mangle the piccy to leave out the two unused bit planes.
	lea	Wibble.pic+34,a1
	movea.l	a1,a0
	addq	#4,a1
	move.w	#320*200/16-1,d7
.mangle_pic_loop:
	move.l	(a1)+,(a0)+
	addq	#4,a1
	dbf	d7,.mangle_pic_loop

	endc

	clr.w	Wibble.measured_vbls
	jsr	Lib3D.precalc_mul_table
	jsr	Lib3D.calc_offsetmask_tables
	jsr	calc_inv_table

	lea	Wibble.pal,a1
	movea.l	a1,a0
	movem.l	Wibble.pic+2,d0-d7
	move.w	2(a1),d0
	move.l	4(a1),d1
	move.w	8+2(a1),d2
	move.l	8+4(a1),d3
	move.w	16+2(a1),d4
	move.l	16+4(a1),d5
	move.w	24+2(a1),d6
	move.l	24+4(a1),d7
	movem.l	d0-d7,(a0)

	bsr	Wibble.calc_fadepals

	move.w	$0468.w,Wibble.old_468
	rts

Wibble.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Wibble.mainloop:

	ifne	Wibble.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	ifne	1
	movea.l	scr,a0
	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge	.partial_clear

	ifne	1

	ifne	Wibble.DYNAMIC_PI1
; kev's background picture
	lea	Wibble.pic+34,a1
	movea.l	scr,a0
	jsr	copy_stscreen
	else

	endc

	bsr	Wibble.copy_mangled

	else

	jsr	CLEAR_STSCREEN

	movea.l	scr,a0
	addq	#4,a0
	move.l	a0,Lib3D.screenadr
	lea	paint_flatfragment_fat_opt,a4
	lea	inv_table,a5

	lea	Wibble.temp_poly(pc),a0
	move.w	#4,(a0)+
	move.l	#$00300040,(a0)+
	move.l	#$01100040,(a0)+
	move.l	#$013F0000,(a0)+
	move.l	#$00000000,(a0)+
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly
	lea	Wibble.temp_poly(pc),a0
	move.w	#4,(a0)+
	move.l	#$000000C7,(a0)+
	move.l	#$013F00C7,(a0)+
	move.l	#$01100088,(a0)+
	move.l	#$00300088,(a0)+
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly
	addq.l	#2,Lib3D.screenadr
	lea	Wibble.temp_poly(pc),a0
	move.w	#4,(a0)+
	move.l	#$013F0000,(a0)+
	move.l	#$01100040,(a0)+
	move.l	#$01100088,(a0)+
	move.l	#$013F00C7,(a0)+
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly
	lea	Wibble.temp_poly(pc),a0
	move.w	#4,(a0)+
	move.l	#$000000C7,(a0)+
	move.l	#$00400088,(a0)+
	move.l	#$00400040,(a0)+
	move.l	#$00000000,(a0)+
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly

	;movea.l	scr,a0
	;bsr	Wibble.paint_frames
	;bsr	Wibble.set_mask

	endc

	bra.s	.end_clear
.partial_clear:

	;ifne	Wibble.MEASURE_CPU
	;ifeq	testmode
	;move.w	#$0433,$FFFF8240.w
	;endc
	;endc

;	ifne	Wibble.MEASURE_CPU
;	ifeq	testmode
;.wait:	tst.b	$FFFF8209.w
;	beq.s	.wait
;	endc
;	endc

; clear the old stuff..
	movea.l	scr,a0
	;bsr	CLEAR_STSCREEN
	movea.l	Wibble.clear_rout,a1
	jsr	(a1)
.end_clear:
	endc

;	ifne	Wibble.MEASURE_CPU
;	ifeq	testmode
;.wait:	tst.b	$FFFF8209.w
;	beq.s	.wait
;	endc
;	endc

	ifne	Wibble.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

;---- 3D stuff ----

;-- control shape, rotation, and movement

; cube movement (bouncing and shit)..
	movem.w	Wibble.cube_pos,d0-d2
;	tst.l	Wibble.rotfix_time
;	bne	.end_calc_displacement
	
	movem.w	Wibble.cube_speed,d3-d5
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	cmpi.w	#-Wibble.BOX_WIDTH<<4,d0
	bgt.s	.not_west
	neg.w	d3
.not_west:
	cmpi.w	#+Wibble.BOX_WIDTH<<4,d0
	blt.s	.not_east
	neg.w	d3
.not_east:
	cmpi.w	#-Wibble.BOX_HEIGHT<<4,d1
	bgt.s	.not_north
	neg.w	d4
.not_north:
	cmpi.w	#+Wibble.BOX_HEIGHT<<4,d1
	blt.s	.not_south
	neg.w	d4
.not_south:
	movem.w	d0-d2,Wibble.cube_pos
	movem.w	d3-d5,Wibble.cube_speed
.end_calc_displacement:

	move.w	Wibble.morph_count,d0
	subq.w	#1,d0
	bmi.s	.end_morph
	addq.w	#6,Wibble.distance
	move.w	d0,Wibble.morph_count
	bsr	Wibble.morph
.end_morph:

	move.l	Wibble.rotfix_time,d0
	beq	.end_object_wave
	lea	sine_tbl,a2
	lea	Wibble.cube_vertices+2,a0
	lea	Wibble.unfold_vertices+2,a1
	jsr	getTime

	tst.l	Wibble.zoomout_time
	beq.s	.skip_zoomout
	addi.w	#12,Wibble.distance
.skip_zoomout:

	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0

	move.w	d0,d7
	andi.w	#SINTABLE_LEN-1,d7
	add.w	d7,d7
	add.w	d7,d7
	move.b	(a2,d7.w),d1
	ext.w	d1
	asr.w	#1,d1
	add.w	0*6+2(a1),d1
	move.w	d1,0*6+2(a0)
	move.w	d1,4*6+2(a0)
	addi.w	#300,d0

	move.w	d0,d7
	andi.w	#SINTABLE_LEN-1,d7
	add.w	d7,d7
	add.w	d7,d7
	move.b	(a2,d7.w),d1
	ext.w	d1
	asr.w	#1,d1
	add.w	0*6+2(a1),d1
	move.w	d1,1*6+2(a0)
	move.w	d1,5*6+2(a0)
	addi.w	#300,d0

	move.w	d0,d7
	andi.w	#SINTABLE_LEN-1,d7
	add.w	d7,d7
	add.w	d7,d7
	move.b	(a2,d7.w),d1
	ext.w	d1
	asr.w	#1,d1
	add.w	0*6+2(a1),d1
	move.w	d1,3*6+2(a0)
	move.w	d1,7*6+2(a0)
	addi.w	#300,d0

	move.w	d0,d7
	andi.w	#SINTABLE_LEN-1,d7
	add.w	d7,d7
	add.w	d7,d7
	move.b	(a2,d7.w),d1
	ext.w	d1
	asr.w	#1,d1
	add.w	0*6+2(a1),d1
	move.w	d1,2*6+2(a0)
	move.w	d1,6*6+2(a0)

.end_object_wave:

	move.l	Wibble.rotfix_time,d0
	bne.s	.got_time
	jsr	getTime
.got_time:
	move.l	d0,d1
	move.l	d0,d2
	mulu.w	#5,d1
	lsr.l	#1,d1
	mulu.w	#3,d2
	mulu.w	#7,d0
	lsr.l	#1,d0
	moveq	#0,d3
	jsr	Lib3D.generate_matrix

;	moveq	#0,d0
;	moveq	#0,d1
	movem.w	Wibble.cube_pos,d0-d1
	asr.l	#4,d0
	asr.l	#4,d1
	move.w	Wibble.distance,d2		; 335+200,d2
	jsr	Lib3D.translate_matrix
;--


; filled cubes with wibbly edges..
	lea	Wibble.2d_dot_table,a0
	lea	Lib3D.temp_matrix,a1
	lea	Wibble.cube_vertices,a2
	bsr	Wibble.transform

	ifne	Wibble.MEASURE_CPU
	ifeq	testmode
	move.w	#$0050,$FFFF8240.w
	endc
	endc

; paint polygons (and perform backface culling -> also for edge visibility)
	tst.l	Wibble.rotfix_time
	beq.s	.paint_spaz_cube
	bsr	Wibble.paint_ribbon_polys
	lea	Wibble.ribbon_edge_table,a1
	lea	Wibble.2d_dot_table+2,a2
	bsr	Wibble.paint_ribbon_edges
	bra.s	.end_paint
.paint_spaz_cube:
	bsr	Wibble.paint_polys
	lea	Wibble.cube_edges,a1
	lea	Wibble.2d_dot_table+2,a2
	bsr	Wibble.paint_edges
.end_paint:

	ifne	Wibble.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc


	ifne	Wibble.MEASURE_CPU
	movea.l	scr,a0
	move.w	Wibble.measured_vbls,d0
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

	ifne	Wibble.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#Wibble.flash_up,palirq
.end_pal:

; wait for vbl..
	move.w	Wibble.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Wibble.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Wibble.old_468
	move.w	d1,Wibble.measured_vbls

;...
	move.l	Wibble.old_cube_pos,Wibble.oldest_cube_pos
	movem.w	Wibble.cube_pos,d0-d1
;	move.w	#435+$100,d2
;	lsl.l	#8,d0
;	lsl.l	#8,d1
;	divs.w	d2,d0
;	divs.w	d2,d1
;	add.w	d4,d0
;	add.w	d5,d1
	movem.w	d0-d1,Wibble.old_cube_pos
	rts

Wibble.measured_vbls:
	ds.w	1

Wibble.old4ba:
	ds.l	1
Wibble.old_468:
	ds.w	1

Wibble.scan_table:
.offset	set	0
	rept	Wibble.MAX_Y
	dc.w	.offset
.offset	set	.offset+160
	endr

;--------------------------------------------------------------------------

Wibble.start_bouncing:
	not.w	Wibble.bouncing_enabled
	move.w	#-1<<4,d0
	move.w	#+1<<4,d1
	movem.w	d0-d1,Wibble.cube_speed
	move.l	#Wibble.flash_up,palirq
	rts

Wibble.flash_up:
	moveq	#$FFFFFFFF,d0
	lea	$FFFF8240.w,a0
	rept	8
	move.l	d0,(a0)+
	endr
	move.l	#Wibble.wait_2vbl,palirq
	rts

Wibble.wait_2vbl:
	move.l	#Wibble.wait_1vbl,palirq
	rts

Wibble.wait_1vbl:
	move.l	#Wibble.init_pal,palirq
	rts

Wibble.trigger_morph:
	move.w	#80,Wibble.morph_count
	rts

Wibble.trigger_rotfix:
	jsr	getTime
	move.l	d0,Wibble.rotfix_time
	move.l	#Wibble.ribbon_polys,Wibble.polys_adr
	move.l	#Wibble.flash_up,palirq
	rts

Wibble.trigger_zoomout:
	jsr	getTime
	move.l	d0,Wibble.zoomout_time
;	move.l	#Wibble.ribbon_polys,Wibble.polys_adr
	rts

Wibble.trigger_fadeout:
	jsr	getTime
	move.l	d0,Wibble.fade_start_time
	move.w	#+63,Wibble.fade_steps_left
	move.l	#Wibble.bluefade_table,Wibble.fade_table_addr
	move.l	#Wibble.perform_fade_step,palirq
	rts

;--------------------------------------------------------------------------

Wibble.copy_mangled:
	lea	Wibble.pic+34,a1
	suba.l	a3,a3
	movea.l	scr,a0
	addq	#4,a0
	move.w	#320*200/128-1,d7
.loop:	movem.l	(a1)+,d0-d6/a2
	move.l	d0,(a0)+
	move.l	a3,(a0)+
	move.l	d1,(a0)+
	move.l	a3,(a0)+
	move.l	d2,(a0)+
	move.l	a3,(a0)+
	move.l	d3,(a0)+
	move.l	a3,(a0)+
	move.l	d4,(a0)+
	move.l	a3,(a0)+
	move.l	d5,(a0)+
	move.l	a3,(a0)+
	move.l	d6,(a0)+
	move.l	a3,(a0)+
	move.l	a2,(a0)+
	move.l	a3,(a0)+
	dbf	d7,.loop
	rts

Wibble.init_pal:
	lea	$FFFF8240.w,a0
	movem.l	Wibble.pal,d0-d7
	movem.l	d0-d7,(a0)
	move.l	#dummy,palirq
	rts

Wibble.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	Wibble.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#64,d1
.fade_index_ok:
	lsl.w	#3,d1
	andi.w	#$FFE0,d1
	movea.l	Wibble.fade_table_addr,a0
	;adda.w	d1,a0

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
.pal_is_set:

	move.l	Wibble.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,Wibble.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

Wibble.calc_fadepals:
; split palette up into 24bit
	lea	Wibble.pal,a1
	lea	Wibble.tmp_pal(pc),a0
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
	lea	Wibble.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	Wibble.tmp_pal(pc),a1
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
	lea	Wibble.blackfade_table,a0
	moveq	#16-1,d7
.lowloop:
	lea	Wibble.tmp_pal(pc),a1
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
	lea	Wibble.bluefade_table,a0
	moveq	#16-1,d7
	movea.w	#10,a3			; a3= dst red level
	movea.w	#0,a4			; a4= dst green level
	movea.w	#2,a5			; a5= dst blue level

.bloop:	lea	Wibble.tmp_pal(pc),a1
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

	rts

Wibble.tmp_pal:
	ds.b	3*16



;--------------------------------------------------------------------------

Wibble.morph:
	lea	Wibble.cube_vertices+2,a0
;	lea	Wibble.unfold_steps,a2
;	move.w	4(a2),d0

;	moveq	#80-1,d7
;.loop:

	add.w	#-1,6*0+4(a0)
	add.w	#+1,6*1+4(a0)
	add.w	#-1,6*2+2(a0)
	add.w	#-1,6*3+2(a0)
	add.w	#-1,6*4+4(a0)
	add.w	#+1,6*5+4(a0)
	add.w	#-1,6*6+2(a0)
	add.w	#-1,6*7+2(a0)

;	dbf	d7,.loop

;	lea	Wibble.unfold_vertices+2,a1
;	moveq	#8*3-1,d7
;.cmploop:
;	move.w	(a0),d0
;	sub.w	(a1)+,d0
;	move.w	d0,(a0)+
;	dbf	d7,.cmploop

	rts

; todo: use previously generated abs offsets.. don't do double calcs!
; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Wibble.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	Lib3D.mul_table+128*256*2,a4

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	Wibble.PERSPECTIVE

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst(pc),a0			; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	move.w	#160,d4
	add.w	d6,d4
	move.w	#100,d5
	add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	Wibble.PERSPECTIVE

	movem.w	(a0),d0-d2
	add.w	d3,d2

	ifne	0
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#7,d0
	asr.l	#7,d1
	else
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs.w	d2,d0
	divs.w	d2,d1
	endc

	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0

	else

	move.w	(a0),d0
	asr.w	#1,d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	#1,d1
	add.w	d5,d1
	move.w	d1,(a0)+
	addq	#2,a0

	endc

	dbf	d7,.persp_loop

	rts

.dst:	dc.l	0

;--------------------------------------------------------------------------

; input:
; a0: screen: (interleaved 4 bpl), pointing to intended plane
Wibble.clear_quarter:
	movem.w	Wibble.oldest_cube_pos,d0-d1
	asr.l	#5,d0
	addq.w	#4,d0
	andi.w	#$FFF8,d0
	asr.l	#4,d1
	muls.w	#160,d1
	add.w	d0,d1

	;lea	160*164+112(a0),a0
	lea	160*170+112(a0),a0

	adda.w	d1,a0

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3

off	set	0
	rept	144
;	moveq	#100-1,d7
;.loop:

;	movem.l	d0-d6/a1-a3,-(a0)
;	movem.l	d0-d6/a1-a3,-(a0)
;	lea	-80(a0),a0

;	movem.l	d0-d6/a1,-(a0)
;	movem.l	d0-d6/a1,-(a0)
;	lea	-96(a0),a0

	move.l	d0,off(a0)
	move.l	d0,off-8(a0)
	move.l	d0,off-16(a0)
	move.l	d0,off-24(a0)
	move.l	d0,off-32(a0)
	move.l	d0,off-40(a0)
	move.l	d0,off-48(a0)
	move.l	d0,off-56(a0)
	move.l	d0,off-64(a0)
	move.l	d0,off-72(a0)
;	move.l	d0,off-80(a0)
;	move.l	d0,off-88(a0)
;	move.l	d0,off-96(a0)
;	move.l	d0,off-104(a0)
;	move.l	d0,off-112(a0)

;	lea	-160(a0),a0
off	set	off-160

	endr
;	dbf	d7,.loop

	rts

;--------------------------------------------------------------------------

Wibble.paint_ribbon_polys:
	lea	Wibble.ribbon_vpolys,a1
	lea	paint_flatfragment_fat_opt,a4
	lea	inv_table,a5
	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	Wibble.2d_dot_table+2,a3
	lea	Wibble.temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0			; d0.w=index of edge
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a3,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	Wibble.temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

.skippy_the_bush_kangaroo:
.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

Wibble.paint_polys:
	;lea	Wibble.cube_polys,a1
	movea.l	Wibble.polys_adr,a1

; clear vertex visible marks
	lea	mark_table(pc),a5
	moveq	#0,d0
	rept	6
	move.l	d0,(a5)+
	endr

	;lea	rts(pc),a4
	lea	paint_flatfragment_fat_opt,a4
	lea	inv_table,a5
	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Lib3D.screenadr

	lea	Wibble.2d_dot_table+2,a3
	lea	Wibble.cube_edges+2,a2
	lea	Wibble.temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0			; d0.w=index of edge
	add.w	d0,d0
	add.w	d0,d0
	move.w	(a2,d0.w),d0			; d0.w=index of 1st edge vertex

	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a3,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	Wibble.temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	Wibble.temp_poly(pc),a0
	jsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

; vis flags only needed when patterns mapped on polys..
; todo: flexible poly size? (sigh)
	subq	#8,a1
	lea	mark_table(pc),a6
	lea	Wibble.cube_edge_map,a3
	rept	4
	move.w	(a1)+,d0
	move.b	(a3,d0.w),d0
	st	(a6,d0.w)
	endr

.skippy_the_bush_kangaroo:
.next_poly:
	dbf	d7,.loop
.end_loop:
	rts

mark_table:
	ds.b	100
Wibble.temp_poly:
	ds.w	100

;--------------------------------------------------------------------------

; input:
; a1: edges 
; a2: vertices
Wibble.paint_edges:

	ifne	0
	tst.l	Wibble.rotfix_time
	beq.s	.no_fixed_edges
	lea	mark_table,a0
	moveq	#0,d0
	rept	6
	move.l	d0,(a0)+
	endr
	lea	mark_table,a0
	lea	Wibble.ribbon_edges,a3
	rept	3+3+4
	move.w	(a3)+,d0
	st	(a0,d0.w)
	endr
.no_fixed_edges
	endc

	lea	mark_table(pc),a3
	move.w	(a1)+,d7
	subq.w	#1,d7

.loop:	move.w	(a1)+,d0			; d0.w=v_index1
	move.w	(a1)+,d2			; d2.w=v_index1

	tst.b	(a3)+
	beq.s	.next_

	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0				; d0.w=6*v_index1
	movem.w	(a2,d0.w),d0-d1			; d0.w=v1.x, d1.w=v1.y
	add.w	d2,d2
	move.w	d2,d3
	add.w	d2,d2
	add.w	d3,d2				; d2.w=6*v_index1
	movem.w	(a2,d2.w),d2-d3			; d2.w=v1.x, d3.w=v1.y
	lsl.w	#4,d0
	lsl.w	#4,d1
	lsl.w	#4,d2
	lsl.w	#4,d3
	movea.l	scr,a0

	movem.l	d7/a1-a3,-(sp)
	bsr.s	Wibble.draw_wobbly_edge draw_aliased
.next:	movem.l	(sp)+,d7/a1-a3

.next_:	dbf	d7,.loop

	rts

; input:
; a1: edges 
; a2: vertices
Wibble.paint_ribbon_edges:

	move.w	(a1)+,d7
	subq.w	#1,d7

.loop:	move.w	(a1)+,d0			; d0.w=v_index1
	move.w	(a1)+,d2			; d2.w=v_index1

	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0				; d0.w=6*v_index1
	movem.w	(a2,d0.w),d0-d1			; d0.w=v1.x, d1.w=v1.y
	add.w	d2,d2
	move.w	d2,d3
	add.w	d2,d2
	add.w	d3,d2				; d2.w=6*v_index1
	movem.w	(a2,d2.w),d2-d3			; d2.w=v1.x, d3.w=v1.y
	lsl.w	#4,d0
	lsl.w	#4,d1
	lsl.w	#4,d2
	lsl.w	#4,d3
	movea.l	scr,a0

	movem.l	d7/a1-a3,-(sp)
.aliased:
	bsr.s	Wibble.draw_wobbly_edge
.next:	movem.l	(sp)+,d7/a1-a3

.next_:	dbf	d7,.loop

	rts

Wibble.rnd:
	dc.l	$12345678

Wibble.draw_wobbly_edge:
	lea	Wibble.rnd(pc),a1
	moveq	#0,d7
	tst.w	Wibble.bouncing_enabled
	beq.s	.no_rnd
	move.l	(a1),d7
	addq.l	#7,d7
	rol.l	d7,d7
.no_rnd:move.l	d7,(a1)

	move.b	(a1)+,d4
	ext.w	d4
	asr.w	d4
	add.w	d4,d0

	move.b	(a1)+,d4
	ext.w	d4
	asr.w	d4
	add.w	d4,d1

	move.b	(a1)+,d4
	ext.w	d4
	asr.w	d4
	add.w	d4,d2

	move.b	(a1)+,d4
	ext.w	d4
	asr.w	d4
	add.w	d4,d3

;	bra.s	Wibble.draw_aliased

; input:
; d0.w=x0 (12.4)
; d1.w=y0 (12.4)
; d2.w=x1 (12.4)
; d3.w=y1 (12.4)
; a0: scr
Wibble.draw_aliased:
	lsr.w	#4,d0
	lsr.w	#4,d1
	lsr.w	#4,d2
	lsr.w	#4,d3
	moveq	#$F,d4
;	movea.l	scr,a0
	addq	#2,a0
	lea	Wibble.scan_table(pc),a1
	lea	Lib3D.putpix_table,a2
	jmp	Line.paint

;--------------------------------------------------------------------------

	data

; just some grey scale test palette..
Wibble.pal:
	ifne	1
	dc.w	$0222,$0424,$0636,$0636
	dc.w	$0333,$0424,$0636,$0636
	dc.w	$0444,$0424,$0636,$0636
	dc.w	$0444,$0424,$0636,$0636
	else
	dc.w	%0000000000000000
	dc.w	%0000100010001000
	dc.w	%0000000100010001
	dc.w	%0000100110011001
	dc.w	%0000001000100010
	dc.w	%0000101010101010
	dc.w	%0000001100110011
	dc.w	%0000101110111011
	dc.w	%0000010001000100
	dc.w	%0000110011001100
	dc.w	%0000010101010101
	dc.w	%0000110111011101
	dc.w	%0000011001100110
	dc.w	%0000111011101110
	dc.w	%0000011101110111
	dc.w	%0000111111111111
	endc

Wibble.org_palette:=	Wibble.pal

Wibble.shape_xcenter:
	dc.w	$0A00
	;dc.w	$0400
Wibble.shape_ycenter:
	dc.w	$0640

Wibble.clear_rout:
	dc.l	Wibble.clear_quarter

Wibble.cube_vertices:
.DIM:=	40
	dc.w	(.end-.start)/6
; left square
.start:	dc.w	-.DIM,-.DIM,-.DIM		; 0
	dc.w	-.DIM,-.DIM,+.DIM		; 1
	dc.w	-.DIM,+.DIM,-.DIM		; 2
	dc.w	-.DIM,+.DIM,+.DIM		; 3
; right square
	dc.w	+.DIM,-.DIM,-.DIM		; 4
	dc.w	+.DIM,-.DIM,+.DIM		; 5
	dc.w	+.DIM,+.DIM,-.DIM		; 6
	dc.w	+.DIM,+.DIM,+.DIM		; 7
.end:

Wibble.unfold_vertices:
	dc.w	(.end-.start)/6
; left square
.start:	dc.w	-.DIM,-.DIM,-3*.DIM		; 0
	dc.w	-.DIM,-.DIM,+3*.DIM		; 1
	dc.w	-.DIM,-.DIM,-.DIM		; 2
	dc.w	-.DIM,-.DIM,+.DIM		; 3
; right square
	dc.w	+.DIM,-.DIM,-3*.DIM		; 4
	dc.w	+.DIM,-.DIM,+3*.DIM		; 5
	dc.w	+.DIM,-.DIM,-.DIM		; 6
	dc.w	+.DIM,-.DIM,+.DIM		; 7
.end:

; 0,2,6,4

Wibble.unfold_steps:
	dc.w	+000,+000,-001			; 0
	dc.w	+000,+000,+001			; 1
	dc.w	+000,+001,-000			; 2
	dc.w	+000,+001,-000			; 3

	dc.w	+000,+000,-001			; 4
	dc.w	+000,+000,+001			; 5
	dc.w	+000,+001,-000			; 6
	dc.w	+000,+001,-000			; 7

; table that maps reverse edges back to forward edges.
; needed to optimise edge culling and painting.
Wibble.cube_edge_map:
	dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B
	dc.b	$04,$08,$0E,$0B,$05,$09,$03,$02,$0A
	even

Wibble.cube_edges:
	dc.w	(.end-.start)/4
.start:	dc.w	0,1				; $0 f
	dc.w	1,3				; $1 f
	dc.w	3,2				; $2 f
	dc.w	2,0				; $3 f
	dc.w	4,5				; $4 f
	dc.w	5,7				; $5 f
	dc.w	7,6				; $6 f
	dc.w	6,4				; $7 f
	dc.w	4,0				; $8 f
	dc.w	1,5				; $9 f
	dc.w	2,6				; $A f
	dc.w	3,7				; $B f

	dc.w	5,4				; $C r
	dc.w	4,0				; $D r
	dc.w	6,3				; $E f
	dc.w	3,7				; $F r
	dc.w	7,5				;$10 r
	dc.w	5,1				;$11 r
	dc.w	0,2				;$12 r
	dc.w	2,3				;$13 r
	dc.w	6,2				;$14 r
.end:

;--------------------------------------------------------------------------
; vertices and edges in ribbon..
;
;  0  8   4
;   +----+
;  0|    |4
;   | 9  |
;  1+----+5
;  1|    |5
;   | B  |
;  3+----+7
;  2|    |6
;   | A  |
;  2+----+6
;   |    |
;   .    .
;   +....+
;  0      4

Wibble.ribbon_edges:
;		0,1;1,3;3,2
	dc.w	0,1,2
;		4,5;5,7;7,6
	dc.w	4,5,6
;		0,4;1,5;3,7;2,6
	dc.w	8,9,$B,$A

;--- vertex based ribbon shit..

Wibble.ribbon_edge_table:
	dc.w	(.end-.start)/4
.start:
; top
	dc.w	0,2			; v
	dc.w	2,6			; >
	dc.w	6,4			; ^
	dc.w	4,0			; <
; mid
	dc.w	2,3
	dc.w	3,7
	dc.w	7,6
;	dc.w	6,2
; btm
	dc.w	3,1
	dc.w	1,5
	dc.w	5,7
;	dc.w	7,3
.end:

Wibble.ribbon_vpolys
	dc.w	6
	dc.w	0,4,+0,2,6,4
	dc.w	0,4,+2,3,7,6
	dc.w	0,4,+3,1,5,7
	dc.w	0,4,+4,6,2,0
	dc.w	0,4,+6,7,3,2
	dc.w	0,4,+7,5,1,3

;---

Wibble.cube_polys:
	dc.w	6

; these are okay..
	dc.w	0,4,+$0,$1,$2,$3		; left
	dc.w	0,4,+$7,$6,$5,$4		; right
	dc.w	0,4,+$D,$C,$9,$0		; top

; vertices 2,3,7,6, seems ok
	dc.w	0,4,+$13,$B,$6,$14		; bottom

; vertices 0,2,6,4, seems ok
	dc.w	0,4,+$12,$A,$7,$8		; front

; vertices 5,7,3,1, seems ok
	dc.w	0,4,+$11,$10,$B,$1		; back

Wibble.ribbon_polys:
	dc.w	3
; front
	dc.w	0,4,+$8,$0,$9,$C		; top
	dc.w	0,4,+$1,$9,$5,$B		; mid
	dc.w	0,4,+$2,$B,$6,$A		; btm
; back
	dc.w	0,4,+$0,$9,$4,$8		; top
	dc.w	0,4,+$1,$B,$5,$9		; mid
	dc.w	0,4,+$2,$A,$6,$B		; btm

Wibble.pic_name:
	dc.b	"spaz-ht.pi1",0
	even

	ifeq	Wibble.DYNAMIC_PI1
Wibble.pic:
	;incbin	spaz-ht.pi1
	incbin	spazback.dat
	endc

Wibble.distance:
	dc.w	335

Wibble.polys_adr:
	dc.l	Wibble.cube_polys

;--------------------------------------------------------------------------

	bss

Wibble.cube_pos:
	ds.w	3
Wibble.old_cube_pos:
	ds.w	2
Wibble.oldest_cube_pos:
	ds.w	2

Wibble.cube_speed:
	ds.w	3
Wibble.morph_count:
	ds.w	1

	ifne	Wibble.DYNAMIC_PI1
Wibble.pic:
	ds.b	32034
	endc

Wibble.bouncing_enabled
	ds.w	1
Wibble.center:
	ds.w	2
Wibble.paint_rout:
	ds.l	1
Wibble.geom_rout:
	ds.l	1
Wibble.event_start_time:
	ds.l	1
Wibble.rotfix_time:
	ds.l	1
Wibble.zoomout_time:
	ds.l	1

Wibble.whitefade_table:
	ds.w	16*16
Wibble.blackfade_table:
	ds.w	16*16
Wibble.bluefade_table:
	ds.w	16*16

Wibble.fade_start_time:
	ds.l	1
Wibble.fade_steps_left:
	ds.w	1
Wibble.fade_table_addr:
	ds.l	1

	ds.l	1

	ifne	1

Wibble.offsetmask_table:=	Lib3D.end_of_bss
Wibble.intensity_table:=	(Wibble.offsetmask_table+8*(320+32+256))
Wibble.2d_dot_table:=		(Wibble.intensity_table+8*(256+384))

	else

	ds.l	2*32				; left overspill
Wibble.offsetmask_table:
	ds.l	2*320
	ds.l	2*32				; right overspill
	ds.w	256*4
Wibble.intensity_table:
	ds.w	384*4
	ds.w	256*4
Wibble.2d_dot_table:
	ds.b	2*Wibble.MAX_NUM_DOTS

	endc
