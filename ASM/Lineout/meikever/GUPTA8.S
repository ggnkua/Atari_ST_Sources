; Gupta-Sproull anti-aliased line, sub-pixel accurate.
; Uses modified coverage function
;
; 14-10-2007:
; first version, non-functional (no plot)
;
; 16-10-2007:
; 22:50: seems to draw the center pixel.. the rest will be done tomorrow.
; 
; 17-10-2007:
; attempt to get other pixels to work..
; 21:15: well, that works (slowly).. and the colours are completely wrong
; of course.. guess it's offsets or scaling or so..
; 22:35: fixed to last 3 bitplanes instead of first 3.. that's better..
; dunno why atm.. mind is clouded.. also got the colours -more or less- ok.
;
; 18-10-2007:
;
; yesterday i managed to get the colours completely ok, man it looks good!
; 21:00: background restoral line rout, quite sub-optimal but better than
; clearscreen. + various optimisations to the colour lookup scaling.
; 23:50: further colour lookup optimisations.
;
; todo: pre-multiply all discriminators, saves a muls per loop (50 cycles)
; keep the range down and manage to avoid nasty add.l. also try to get rid
; of the asr.l #8 in there.. this is 24 cycles as well!
; separate hor and ver cases might speed it up as well, seeing some 
; look-ups will be become obsolete (just use direct register adds).
; that's for tomorrow..
;
; 19-10-2007:
;
; let's do it.
;
; 20-10-2007:
;
; yesterday the whole thing messed up. i tried to remove the in-loop
; multiply. that worked in the original c source, but of course here i was
; too lazy to check the scaling ;)
; 12:00: scaling is better now, but still not accurate.. it seems faster
; 13:00: tried moving the 1/sqrt calc, but this messed some stuff up..
; which is a shame cos less words have to be put on the stack..
; 13:30: 1/sqrt now fixed.. only 84 cycles speed-up, but wtf..
; 14:00: seems like the pre-mult is nasty.. 16 bit range is not enough..
; there is a trade-off between shading and midpoint algo accuracy. that 
; really sucks ass.
; 14:20: okay, the last remark was not completely right, as i bugged some
; registers.. it's better now, but one thing is sure.. background restoral
; is going to be tricky..
; 14:26: okay, seems background restoral is ok afteral (prolly only when
; the line movement is not so fast..)
; 14:30: with a different background colour is seems that some crap is 
; left behind but it's -very- hard to spot. there are indeed minute 
; differences between normal (exact) and scaled midpoint but not enough for
; the eye to spot! excellent. also, the clear routine is slightly optimised.
; and i can keep 16 bit range for the midpoint operations *phew*
; 14:55: i was just thinking.. i guess background restoral won't be
; necessary for the final screen.. since it has only small frames.. a blit
; will be fine. that will take at most 20% of a VBL or so, which is much
; less than restoral (at least with the current implementation). i also 
; think i'd better replace that beautiful inverse square root with a table.
; i've lost alot of accuracy already.. for a zoomed version i can still
; it, of course. there the cost will be in the 4x4 or 8x8 pixel painting.
; but i mean.. 3 rasterlines x 12 lines (cube) = 36 and that's more than 
; 10% of a VBL! only for damn square roots.
; going for a bit of bicycle action!
;
; 21-10-2007:
;
; yesterday i optimised the loop counter to dbf and killed a branch in the
; diagonal case. this speeded things up a little.
; i reckon that keeping the mask data in a register will speed things up
; a little more.. after that i have to distinquish between |dx|>|dy| and
; |dx|<|dy|.
; 22:15: succeeded with the mask/plot crap.. definitely faster.. 72 cycles
; per iteration, to be precise..
; tables are now way too big.. i think it needs to be reduced to only
; doing lookup for horizontal increments.. i mean, 512K, this is just
; silly.. this of course co-incides with the dx/dy cases. that's up for
; tomorrow then..
;
; 24-10-2007:
;
; back behind the keys, let's do it..
; the .draw rout now always avoids the in-loop multiply. seems like the
; best way to keep it clean.
; 00:08 (25-10-2007):
; yeah! optimised the |dx|>|dy| case.. it's damn fast now. no more stack.
; no more huge table shit (only first line = 320x8 bytes) is used. no more
; table add/subb or even screen add/sub. it's -loads- faster. only the
; offset and mask should be swapped to make it a little faster.. and the
; init is a little slow, of course.
; up for tomorrow is the |dy|>|dx| case which i don't know too well about.
; i guess will be slightly slower.. although it could be possible to store
; masks for subsequent scanlines.. 
; and after that i gotta see about the damn sqrt.. and then it's testing
; the thing with some decent shape..
; nap time!
;
; 25-10-2007:
;
; optimised the big dx case to the fullest. honesty don't know what would
; speed it up except maybe storing entire segments as sprites, and i
; honestly don't know how that would look..
; the big dy case also got optimised but it needs alot more work than its
; dx counterpart. i already have 3 cases. the best case is comparable with
; the dx.. the worst case will be slightly slower. distinguishing between
; cases is something i still need to think about. the smc also shouldn't
; get out of hand..
; that's shit for tomorrow, night..
;
; 26-10-2007:
;
; time to do something.. get all the cases in there..
; 3:15: got all the cases and some distinguishing going on..
; still buggy, though.. and the conditional branches are also shit.
; 3:30: works! but still pessimised and the sub/add inversion needs to
; be taken care of (loads of smc!), and with a smart branch 'prediction'
; you can save some time (optimise for the nominal case!).
; but that's up for tomorrow.. technically, it's tomorrow.. aw gawd.
; better get some sleep!
;
; 27-10-2007:
;
; time to get hacking on all of the 'border' cases. done.. easy.
; next up is the branch optimisation.
;
; 28-10-2007:
;
; fixed a bug in the x/y direction in the |dy|>|dx| case
; making a rotating square. done.
; also avoiding background restore.. wiping a rectangle is just way faster
; with multiple lines.
; now got a nice shape with unconnected lines.
; 22:00:
; massive simplification of line init.. that really cleans up and also 
; speeds up a little, but most importantly, we only need a very small 
; offset-mask table now.
;
; 29-10-2007:
;
; actually, it's 30 oct.. nocturnal activities again..
; made a standard aliased line, to fit in with the 'incremental' approach,
; i.e. my addition to msg's idea about the frames. seems to work these
; alias things.. let's go to bed. 0:30 is good enough..
;
; 01-11-2007:
;
; main party.. party (crap) coding time.. i can make the frame clearing 
; shit now..
; 19:15: frame clear routs done..
; 20:00: ugly frame borders, aa toggle option done.. 
; 21:30: frame change routs done.. now try to fix the centers.
;
; 02-11-2007:
;
; 2:00: centers fixed, and drawing outside of screen allowed
; 2:40: fake clipping done (using 1 bpl mask, limiting colours to 8!)
;
; 04-11-2007:
; 
; 17:30: attempt to include bitzoom routine in a frame.
; 23:50: bitzoom done.. might be possible to use some grimeyness.
;
; 13-11-2007:
;
; attempt to enable full object and 3D..
; 23:50: included full 3d rot and perspective (need to enable it)
; it still needs some rout to dereference the edge vertices.
;
; 15-11-2007:
;
; 20:00: perspective enabled
; 22:20: 3D transform working on the NS logo.
; 23:20: optimised shape..
;

AALine.NR_VBLS:=	2				; minimum amount of VBLs to take
AALine.MEASURE_CPU:=	0				; raster cpu measurement
AALine.MAX_Y:=		200				; amount of physical scanlines read by the video chip
AALine.PERSPECTIVE:=	1
AALine.MAX_NUM_DOTS:=	100				; limit for dot buffers!
AALine.SPRITE_SCANS:=	24

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	sprite.s
	include	mat.s
	include	common.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc

AALine.SHIFTSPRITE_SIZE:=	(Sprite.SHIFTSCAN_SIZE*AALine.SPRITE_SCANS)

;- plugin table ------------------------------------------------------------

	dc.l	AALine.mainloop			; 0
	dc.l	AALine.init			; 1
	dc.l	AALine.rt_init			; 2
	dc.l	AALine.deinit			; 3
	dc.l	AALine.toggle_aa		; 4
	dc.l	AALine.toggle_fix_glass		; 5
	dc.l	AALine.trigger_start_transition	; 6
	dc.l	AALine.trigger_fade_in_front	; 7
	dc.l	AALine.trigger_fade_out		; 8
	dc.l	0

;- plugin routines ---------------------------------------------------------

AALine.init:
	;move.w	#$0FFF,$FFFF8240.w


	;move.w	#$0000,$FFFF8240.w
	rts

; todo: in case of memory shortage, let all this stuff use temporary 
; buffers..
AALine.rt_init:
	clr.w	AALine.measured_vbls
	jsr	AALine.init_offsetsmasks
	jsr	AAline.init_intensity_table
	jsr	calc_inv_table
	jsr	Lib3D.precalc_mul_table

	lea	AALine.train+34+64,a1
	lea	AALine.shifted_sprite,a0
	move.w	#AALine.SHIFTSPRITE_SIZE,d4
	moveq	#24,d7
	jsr	Sprite.preshift_16pix

	lea	AALine.shifted_sprite,a1
	lea	AALine.shifted_mask,a0
	moveq	#24,d7
	jsr	Sprite.extract_16pix_mask

	bsr	AALine.calc_fadepals

	move.w	#$FFFF,AALine.morph_enable
	move.w	$0468.w,AALine.old_468
	rts

AALine.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

AALine.mainloop:

	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	ifne	1
	movea.l	scr,a0
	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.partial_clear
	bsr	CLEAR_STSCREEN
	bsr	AALine.paint_big_glass
.partial_clear:

	cmpi.w	#-2,AALine.transition_count
	beq	.animate

;	bra	AALine.perform_transition
	bsr	AALine.perform_arrow_wipe

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal0
	move.l	#AALine.init_pal,palirq
.end_pal0:

; wait for vbl..
	move.w	$0468.w,d0
.wvbl:	cmp.w	$0468.w,d0
	beq.s	.wvbl
	move.w	d0,AALine.old_468
	rts

.animate:

	;bsr	CLEAR_STSCREEN
	;ifne	AALine.MEASURE_CPU
	;ifeq	testmode
	;move.w	#$0433,$FFFF8240.w
	;endc
	;endc

; clear the old line(s)..
	movea.l	scr,a0

	ifne	0

	movea.l	AALine.oldline_addrs,a1
	movem.w	(a1)+,d0-d3
	moveq	#0,d4
	bsr	AAline.clear

	else

	movea.l	AALine.clear_rout,a1
	jsr	(a1)

	endc
.end_clear:
	endc

	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0455,$FFFF8240.w
	endc
	endc

;	ifne	AALine.MEASURE_CPU
;	ifeq	testmode
;.wait:	tst.b	$FFFF8209.w
;	beq.s	.wait
;	move.w	#$00F0,$FFFF8240.w
;	endc
;	endc

	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	ifne	1

; 3D stuff..
	bsr	getTime
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
	;ext.w	d1
	asr.w	#7,d1
	ext.w	d2
	add.w	#1024,d0 +100
	add.w	#0,d1 +100
	add.w	#-512,d2 +200
	moveq	#0,d3
	jsr	Lib3D.generate_matrix

	moveq	#0,d0
	moveq	#0,d1
	moveq	#100,d2
	jsr	Lib3D.translate_matrix

	lea	AALine.2d_dot_table,a0
	lea	Lib3D.temp_matrix,a1
	lea	AALine.ns_vertices,a2
	bsr	AALine.transform

	else

	lea	AALine.2d_dot_table+2,a0
	move.l	#$00A00032,d0
	moveq	#0,d1
	rept	10
	move.l	d0,(a0)+
	move.w	d1,(a0)+
	endr

	endc

	lea	AALine.ns_edges,a1
	lea	AALine.2d_dot_table+2,a2
	bsr	AALine.paint_object

	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0F00,$FFFF8240.w
	endc
	endc

; zooming shit..
	bsr	AALine.calc_glass_pos
	bsr	AALine.bitzoom
	bsr	AALine.paint_glass
	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

.next_frame:
	ifne	AALine.MEASURE_CPU
	movea.l	scr,a0
	move.w	AALine.measured_vbls,d0
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

	ifne	AALine.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#AALine.init_pal,palirq
.end_pal:

; wait for vbl..
	move.w	AALine.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#AALine.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,AALine.old_468
	move.w	d1,AALine.measured_vbls

	rts

AALine.measured_vbls:
	ds.w	1

AALine.old4ba:
	ds.l	1
AALine.old_468:
	ds.w	1

;--------------------------------------------------------------------------

AALine.toggle_aa:
	not.w	AALine.aa_enable
	rts

AALine.toggle_fix_glass:
	not.w	AALine.glass_fixed
	bsr	getTime
	move.l	d0,AALine.glass_start_time	
	rts

AALine.trigger_start_transition:
	move.w	#224,AALine.transition_count
	rts

AALine.trigger_end_transition:
	move.w	#200,AALine.transition_count
	rts

AALine.set_left_frame:
	move.l	#AALine.clear_left_frame,AALine.clear_rout
	move.w	#$0300,AALine.shape_xcenter
	rts

AALine.set_mid_frame:
	move.l	#AALine.clear_mid_frame,AALine.clear_rout
	move.w	#$0A00,AALine.shape_xcenter
	rts

AALine.set_right_frame:
	move.l	#AALine.clear_right_frame,AALine.clear_rout
	move.w	#$1100,AALine.shape_xcenter
	rts

AALine.trigger_arrow_wipe:
	rts

;--------------------------------------------------------------------------

AALine.ARROW_HEIGHT:=	24

AALine.perform_arrow_wipe:
	lea	.tb(pc),a6
	move.l	a6,d4
	moveq	#3,d7
	moveq	#$FFFFFFFF,d3

	move.w	AALine.transition_count,d0
	subq.w	#2,d0
	move.w	d0,AALine.transition_count

	subi.w	#224,d0
	neg.w	d0

	andi.w	#$00FF,d0
;	moveq	#0,d0
	subi.w	#AALine.ARROW_HEIGHT,d0
	move.w	d0,.ypos

.yloop:	move.w	.ypos(pc),d1
	sub.w	d7,d1
	move.w	d1,d0
	bpl.s	.y_ok
	moveq	#0,d0
.y_ok:	move.w	d0,.ver_offset

.check_north:
	tst.w	d1
	bpl.s	.check_south

; north clipper calcs..
; d1.w= y position (negative)
	moveq	#AALine.ARROW_HEIGHT,d6
	add.w	d1,d6
	ble	.next_y
	move.w	d6,.height
	move.w	.height(pc),d6
	lea	.sizes(pc),a6
	neg.w	d1
	move.w	d1,d2
	andi.w	#$FFF8,d2
	move.w	d2,.hor_offset
	andi.w	#7,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1				; d1.w=-8y
	move.w	d6,d0
	andi.w	#$0007,d0

	subq.w	#1,d6
	lsr.w	#3,d6
	move.w	d6,d2
	move.w	d2,.num_chunks

	tst.w	d0
	bne.s	.n_wrap
	moveq	#8,d0
.n_wrap:
; partial chunk..
	move.w	d1,(a6)+
	move.w	d0,(a6)+

	subq.w	#1,d2
	bmi.s	.n_skip_calc
.n_calc_size_loop:
	move.w	#0,(a6)+
	move.w	#8,(a6)+
	dbf	d2,.n_calc_size_loop
.n_skip_calc:
	bra.s	.render

.check_south:
	cmpi.w	#200-AALine.ARROW_HEIGHT,d1
	blt	.gen_normal_sizes

; south clipper calcs..
; d1.w= y (>200-24)
	subi.w	#200-AALine.ARROW_HEIGHT,d1
	moveq	#AALine.ARROW_HEIGHT,d6
	sub.w	d1,d6
	ble	.next_y
	move.w	#0,.hor_offset
	move.w	d6,.height
	lea	.sizes(pc),a6
	move.w	d6,d0
	andi.w	#$0007,d0
	lsr.w	#3,d6
	move.w	d6,.num_chunks
	move.w	d6,d1
	subq.w	#1,d1
	bmi.s	.s_skip_calc
.s_calc_size_loop:
	move.l	#$00000008,(a6)+
	dbf	d1,.s_calc_size_loop
.s_skip_calc:
	move.w	#$0000,(a6)+
	move.w	d0,(a6)+

.render:move.w	.hor_offset(pc),d1
	movea.l	scr,a0
	move.w	.ver_offset(pc),d0
	mulu.w	#160,d0
	adda.w	d0,a0
	lea	40(a0),a3
	adda.w	d1,a0
	suba.w	d1,a3

	lea	AALine.train+34,a1
	adda.w	d0,a1
	lea	40(a1),a4
	adda.w	d1,a1
	suba.w	d1,a4

	lea	.sizes(pc),a6
	move.w	.num_chunks(pc),d6

.chunk_loop:
	movea.l	d4,a2
	adda.w	(a6)+,a2
	move.w	(a6)+,d5
	subq.w	#1,d5
	bmi.s	.next_chunk

.loop:	movem.l	(a1),d0-d1
	move.w	d3,d1
	move.l	(a2)+,d2
	and.l	d2,d0
	and.l	d2,d0
	or.l	d0,(a0)
	and.l	d2,d1
	and.l	d2,d1
	or.l	d1,4(a0)
	movem.l	(a4),d0-d1
	move.w	d3,d1
	move.l	(a2)+,d2
	and.l	d2,d0
	and.l	d2,d0
	or.l	d0,(a3)
	and.l	d2,d1
	and.l	d2,d1
	or.l	d1,4(a3)
	lea	160(a0),a0
	lea	160(a1),a1
	lea	160(a3),a3
	lea	160(a4),a4
	dbf	d5,.loop

.next_chunk:
	addq	#8,a0
	addq	#8,a1
	subq	#8,a3
	subq	#8,a4
	dbf	d6,.chunk_loop

.next_y:dbf	d7,.yloop

	rts

.gen_normal_sizes:
	lea	.sizes(pc),a6
	move.l	#$00000008,d0
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.w	#AALine.ARROW_HEIGHT/8-1,.num_chunks
	move.w	#0,.hor_offset
	bra	.render

.ypos:	dc.w	0
.height:dc.w	0
.num_chunks:
	dc.w	0
.hor_offset:
	dc.w	0
.ver_offset:
	dc.w	0

.tb:	dc.l	$C000C000,$00030003
	dc.l	$30003000,$000C000C
	dc.l	$0C000C00,$00300030
	dc.l	$03000300,$00C000C0
	dc.l	$00C000C0,$03000300
	dc.l	$00300030,$0C000C00
	dc.l	$000C000C,$30003000
	dc.l	$00030003,$C000C000

.sizes:	ds.w	8

AALine.perform_transition:
	move.w	AALine.transition_count,d7
	bmi	.stopped

	moveq	#1,d5
.wipe_loop:
	move.w	d7,d6
	subi.w	#100,d6
	add.w	d6,d6
	bpl.s	.t_ok
	move.w	d7,d6
	add.w	d6,d6
	addq.w	#1,d6
.t_ok:	mulu.w	#160,d6
	movea.l	scr,a0
	adda.w	d6,a0
	moveq	#0,d0
	rept	40
	move.l	d0,-(a0)
	endr
	subq.w	#1,d7
	bmi.s	.t_done
	dbf	d5,.wipe_loop

.t_done:move.w	d7,AALine.transition_count
; swap screens..
	ifeq	testmode
	move.l	scr,d0
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc
; wait for vbl..
	move.w	AALine.old_468(pc),d0
.vbl:	cmp.w	$0468.w,d0
	beq.s	.vbl
	move.w	$0468.w,AALine.old_468
	rts

.stopped:
	movea.l	AALine.haze_adr,a0
	move.w	(a0)+,$FFFF8240.w
	cmpa.l	#AALine.end_haze,a0
	bhs.s	.dont_store
	move.l	a0,AALine.haze_adr
.dont_store:
	move.w	AALine.old_468(pc),d0
._vbl:	cmp.w	$0468.w,d0
	beq.s	._vbl
	move.w	$0468.w,AALine.old_468
	rts

AALine.paint_train:
	movea.l	scr,a0
	lea	AALine.train+34,a1
	moveq	#$FFFFFFFF,d4
	move.w	#200-1,d7
.loop:
;	movem.l	(a1),d0-d6/a2-a6
;	movem.l	d0-d6/a2-a6,(a0)
;	lea	160(a0),a0
;	lea	160(a1),a1

	movem.l	(a1)+,d0-d3
	move.w	d4,d1
	move.w	d4,d3
	movem.l	d0-d3,(a0)
	movem.l	(a1)+,d0-d3
	move.w	d4,d1
	move.w	d4,d3
	movem.l	d0-d3,16(a0)
	movem.l	(a1)+,d0-d3
	move.w	d4,d1
	move.w	d4,d3
	movem.l	d0-d3,32(a0)
	lea	160(a0),a0
	lea	160-48(a1),a1
	dbf	d7,.loop
	rts

AALine.clear_rest:
	movea.l	scr,a0
	lea	48(a0),a0
	move.l	#$00000000,d0
	;move.l	#$0000FFFF,d1
	move.l	#$00000000,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,a1
	movea.l	d0,a2
	movea.l	d1,a3
	movea.l	d0,a4
	movea.l	d1,a5
	move.w	#200-1,d7

.loop:	movem.l	d0-d6/a1-a5,(a0)
	movem.l	d0-d6/a1-a5,48(a0)
	movem.l	d0-d3,96(a0)
	lea	160(a0),a0
	dbf	d7,.loop
	rts

AALine.trigger_fade_out_:
	bsr	getTime
	move.l	d0,AALine.fade_start_time
	move.w	#+63,AALine.fade_steps_left
	;move.l	#AALine.blackfade_table,AALine.fade_table_addr
	move.l	#AALine.purplefade_table,AALine.fade_table_addr
	move.l	#AALine.perform_fade_step,palirq
	rts

AALine.trigger_fade_out:
	move.w	#0,AALine.fade_mode
	bsr	getTime
	move.l	d0,AALine.fade_start_time
	move.w	#+63,AALine.fade_steps_left
	move.l	#AALine.purplefade_table,AALine.fade_table_addr
	move.l	#AALine.perform_fade_step,palirq
	rts

AALine.trigger_fade_out_front:
	move.w	#+1,AALine.fade_mode
	bra	AALine.trigger_fade_out_

AALine.trigger_fade_out_back:
	move.w	#-1,AALine.fade_mode
	bra	AALine.trigger_fade_out_

AALine.trigger_fade_in_:
	bsr	getTime
	move.l	d0,AALine.fade_start_time
	move.w	#-63,AALine.fade_steps_left
	;move.l	#AALine.blackfade_table,AALine.fade_table_addr
	move.l	#AALine.yellowfade_table,AALine.fade_table_addr
	move.l	#AALine.perform_fade_step,palirq
	rts

AALine.trigger_fade_in:
	move.w	#0,AALine.fade_mode
	bsr	getTime
	move.l	d0,AALine.fade_start_time
	move.w	#-63,AALine.fade_steps_left
	move.l	#AALine.yellowfade_table,AALine.fade_table_addr
	move.l	#AALine.perform_fade_step,palirq
	rts

AALine.trigger_fade_in_front:
	move.w	#+1,AALine.fade_mode
	bra	AALine.trigger_fade_in_

AALine.trigger_fade_in_back:
	move.w	#-1,AALine.fade_mode
	bra	AALine.trigger_fade_in_

AALine.init_pal:
	movem.l	AALine.train+2,d0-d7
;	movem.l	AALine.pal,d0-d7

	lea	$FFFF8240.w,a0
	move.l	#dummy,palirq
	rept	8
	move.w	d0,(a0)+
	endr
	movem.l	d4-d7,(a0)
	rts

AALine.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	AALine.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#64,d1
.fade_index_ok:
	lsl.w	#3,d1
	andi.w	#$FFE0,d1
	movea.l	AALine.fade_table_addr,a0
	;adda.w	d1,a0

	tst.w	AALine.fade_mode
	beq.s	.all
	bgt.s	.front

.back:	move.l	2(a0,d1.w),$FFFF8242.w
	movem.l	4*2(a0,d1.w),d0-d1/d3/d5
	movem.l	d0-d1/d3/d5,$FFFF8248.w
	bra.s	.pal_is_set

.front:	movem.l	(a0,d1.w),d0-d1/d3/d5
	movem.l	d0-d1/d3/d5,$FFFF8240.w
	bra.s	.pal_is_set

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
.pal_is_set:

	move.l	AALine.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,AALine.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

AALine.calc_fadepals:
; split palette up into 24bit
	lea	AALine.org_palette,a1
	lea	AALine.tmp_pal(pc),a0
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
	lea	AALine.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	AALine.tmp_pal(pc),a1
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
	lea	AALine.blackfade_table,a0
	moveq	#16-1,d7
.lowloop:
	lea	AALine.tmp_pal(pc),a1
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
	lea	AALine.purplefade_table,a0
	moveq	#16-1,d7
	movea.w	#4,a3			; a3= dst red level
	movea.w	#0,a4			; a4= dst green level
	movea.w	#2,a5			; a5= dst blue level

.bloop:	lea	AALine.tmp_pal(pc),a1
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
	lea	AALine.yellowfade_table,a0
	moveq	#16-1,d7
	movea.w	#12,a3			; a3= dst red level
	movea.w	#12,a4			; a4= dst green level
	movea.w	#0,a5			; a5= dst blue level

.yloop:	lea	AALine.tmp_pal(pc),a1
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

AALine.tmp_pal:
	ds.b	3*16

;--------------------------------------------------------------------------

; todo: use previously generated abs offsets.. don't do double calcs!
; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
AALine.transform:
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

	ifne	AALine.PERSPECTIVE

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
	move.w	#160-16,d4
	add.w	d6,d4
	move.w	#100,d5
	add.w	a3,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

.persp_loop:

	ifne	AALine.PERSPECTIVE

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
; a1: edges 
; a2: vertices
AALine.paint_object:
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi	.end

.loop:	move.w	(a1)+,d0			; d0.w=v_index1
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0				; d0.w=6*v_index1
	movem.w	(a2,d0.w),d0-d1			; d0.w=v1.x, d1.w=v1.y
	move.w	(a1)+,d2			; d2.w=v_index1
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

	movem.l	d7/a1-a2,-(sp)
	tst.w	AALine.aa_enable
	beq.s	.aliased
	bsr	AAline.draw
	bra.s	.next
.aliased:
	bsr	AAline.draw_aliased
.next:	movem.l	(sp)+,d7/a1-a2

	dbf	d7,.loop

.end	rts

; input:
; a0: screen: (interleaved 4 bpl), pointing to intended plane
AALine.clear_left_frame:
	bra	AALine.clear_frame
; input:
; a0: screen: (interleaved 4 bpl), pointing to intended plane
AALine.clear_mid_frame:
	lea	48(a0),a0
	bra	AALine.clear_frame
; input:
; a0: screen: (interleaved 4 bpl), pointing to intended plane
AALine.clear_right_frame:
	lea	112(a0),a0
	bra	AALine.clear_frame

; input:
; a0: screen: (interleaved 4 bpl), pointing to intended plane
AALine.clear_frame:
	lea	160*180+48(a0),a0

	move.l	#$00000000,d0
	;move.l	#$0000FFFF,d1
	move.l	#$00000000,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,a1
	movea.l	d0,a2
	movea.l	d1,a3
	movea.l	d0,a4
	movea.l	d1,a5

	rept	160
;	moveq	#100-1,d7
;.loop:

;	movem.l	d0-d6/a1-a3,-(a0)
;	movem.l	d0-d6/a1-a3,-(a0)
;	lea	-80(a0),a0
	movem.l	d0-d6/a1-a5,-(a0)
	lea	-(160-48)(a0),a0

	endr
;	dbf	d7,.loop

	rts

AALine.init_offsetsmasks:
	lea	AALine.offsetmask_table-32*8,a0
	lea	AALine.masks,a1
	lea	AALine.vbody_indices,a2
	moveq	#0,d7

.yloop:	moveq	#-32,d6

.xloop:	;move.w	d6,d0
	;addi.w	#160,d0				; center x on screen.
	;cmpi.w	#320,d0
	;bcc.s	.clip

	;move.w	d7,d2
	;addi.w	#100,d2				; center y on screen.
	;cmpi.w	#200,d2
	;bcc.s	.clip

	move.w	d7,d0
	mulu.w	#160,d0
	move.w	d6,d1
	andi.w	#$FFF0,d1

.on_screen:
	move.w	d6,d2
	sub.w	d1,d2
	asr.w	#1,d1
	add.w	d1,d0
	add.w	d2,d2
	addq.w	#2,d0
	move.w	d0,(a0)+			; store offset.
	move.w	(a2,d2.w),(a0)+			; store vbody index.
	move.w	(a1,d2.w),(a0)+			; store mask.
	move.w	(a1,d2.w),(a0)+			; store mask.
	
.next:	addq.w	#1,d6
	cmpi.w	#320+32,d6
	blt.s	.xloop

;	addq.w	#1,d7
;	cmpi.w	#200,d7
;	blt.s	.yloop
	rts

.clip:	moveq	#0,d0
	move.w	d0,(a0)+
	move.w	d0,(a1)+
	bra.s	.next

AALine.masks:
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
AALine.vbody_indices:
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007
	dc.w	$0008,$0009,$000A,$000B,$000C,$000D,$000E,$FFFF

; (1. - d /(2.*r))^2;
AAline.init_intensity_table:
	lea	AALine.intensity_table,a0
	move.w	#$A000,d6			; d7.w=-.75 (16bit signed)
	move.w	#384-1,d7

.loop:	move.w	d6,d0
	bpl.s	.abs
	neg.w	d0
.abs:	ext.l	d0
	lsr.w	#1,d0
	divu.w	#$0031,d0
	not.b	d0
	mulu.w	d0,d0
; store byte index..
;	lsr.l	#8,d0
;	move.b	d0,(a0)+
; but decompose into planes and store..
	addq	#8,a0
	rept	4
	add.w	d0,d0
	scs	d1
	ext.w	d1
	move.w	d1,-(a0)
	endr
; adjust for crazy movem.l stuff in plot rout..
	move.w	4(a0),6(a0)
	addq	#8,a0
	addi.w	#$C000/384,d6
	dbf	d7,.loop
	rts

AAline.clip:
	rts

; inverse square root computation:
;
; y = 1/sqrt(x)
;
; by specifying a different threshold 'T' you may change the position of
; the point in the input:
; - a big T gives a very small input range but will produce good output
; accuracy.
; - a small T gives large input range but bad accuracy for low output.
;
; the routine could be optimised to check for the highest input bit and
; of course it can be easily unrolled.
;
; input:
; d0.l=k (24.8 bit unsigned fixed point) (depends on T!)
; output:
; d1.w=q = 2/sqrt(k) (unsigned fractional)
AALine.inv_sqrt:
	moveq	#0,d1			; d1.l=q[0] = 0.0

;	moveq	#-1,d2
;	sub.w	d2,d2			; d2.l=kq2[0]-T = -T (-$10000, for 16.16 input)
	move.l	#-$100,d2		; for 24.8 input.

	moveq	#0,d3			; d3.l=kq[0] = 0.0
	moveq	#16-1,d7		; d7.w=i=1 (16-1 for dbf ;))
	lsr.l	#2,d0			; d0.l=k*.5^(2i)
	moveq	#1,d6
	swap	d6			; d6.l=2*.5^i (intended for lower word 'bit stamping')

.loop:	lsr.l	#2,d0			; d0.l=k*.5^(2i+2)

	move.l	d3,d4			; d4.l= kq[i]
	add.l	d0,d4			; d4.l= kq2+kq*.5^i

	lsr.l	#1,d3			; d3.l= kq[i]*.5
	lsr.l	#1,d6			; d6.l= .5^(i+1)

	add.l	d2,d4			; d4.l = t[i]-T = kq2-T + kq*0.5^i + k*0.5^(2i+2)
	bpl.s	.skip			; if t[i]-T < 0

	or.w	d6,d1			; d1.l= q[i+1] = q[i] | 2*.5^(i+1)
        move.l	d4,d2			; d2.l= kq2[i+1] = t[i]-T
	add.l	d0,d3			; d3.l= kq[i+1] = kq[i]*.5 + k*.5^(i+1)

.skip:	dbf	d7,.loop

	rts

; input:
; d0.w=x0 (12.4)
; d1.w=y0 (12.4)
; d2.w=x1 (12.4)
; d3.w=y1 (12.4)
AAline.draw:
	move.w	d2,d4				; d4.w=x1
	move.w	d3,d5				; d5.w=y1
	sub.w	d0,d2				; d2.w=dx
	sub.w	d1,d3				; d3.w=dy

; calculate nasty distance and shit for gupta
	movem.w d0-d5,-(sp)
	muls.w	d2,d2				; d3.l=dx^2
	muls.w	d3,d3				; d4.l=dy^2
	move.l	d2,d0
	add.l	d3,d0				; d0.l=dx^2+dy^2 (24.8)
	bsr.s	AALine.inv_sqrt			; d1.w=1/sqrt(dx^2+dy^2) (12.4)
	lsr.w	#1,d1				; d1.w=1/sqrt(du^2+dv^2) (16 bit signed fraction)
	movea.w	d1,a1
	movem.w	(sp)+,d0-d5

	lsr.w	#4,d1
	asr.w	#4,d0
	movea.l	scr,a0
	subq	#2,a0
	lea	AALine.offsetmask_table,a3
	mulu.w	#160,d1
	adda.l	d1,a0
	lsl.w	#3,d0
	adda.w	d0,a3

	move.w	d2,d6				; d6.w=dx
	bpl.s	.dx_abs
	neg.w	d6
.dx_abs:					; d6.w=|dx|
	move.w	d3,d7				; d7.w=dy
	bpl.s	.dy_abs
	neg.w	d7
.dy_abs:					; d7.w=|dy|

; prepare variables for octant mirroring
	cmp.w	d6,d7
	sgt	Aaline.dy_greater
	ble.s	.no_swap
	exg.l	d4,d5				; d4.w=u=y1, d5.w=v=x1
	exg.l	d6,d7				; d6.w=du=|dy|, d7.w=dv=|dx|
.no_swap:
	tst.w	d3
	bpl.s	.ystep_pos
	move.w	#-160,a2			; a2=ystep (screen)
	bra.s	.ystep_done
.ystep_pos:
	move.w	#+160,a2			; a2=ystep (screen)
.ystep_done:
	tst.w	d2
	bpl.s	.xstep_pos
	moveq	#-8,d3				; d3.l=xstep (table)
	bra.s	.select_done
.xstep_pos:
	moveq	#+8,d3				; d3.l=xstep (table)
.select_done:
; d3.l=xstep, a2=ystep
; d4.w=u, d5.w=v
; d6.w=|du|, d7.w=|dv|

; prepare bresenham's midpoint algorithm discriminant + steps and
; gupta-sproull invariants..
	move.l	a1,d2
	move.w	d6,d5				; d5.w=du
	muls.w	d2,d5				; d5.l=du/sqrt(du^2+dv^2) (16.16)
	asr.l	#8,d5				; 
	asr.l	#3,d5				; d5.w=du/sqrt(du^2+dv^2) (8.8)

; prepare midpoint algo stuff..
	move.w	d6,a4				; a4.w=du (12.4)
	move.w	d7,d1
	add.w	d1,d1				; d1.w=2dv (12.4)
	sub.w	d6,d1				; d1.w=2dv-du (12.4)
	asr.w	#4,d1				; d1.w=discr[0]=(2dv-du) (integer)
	sub.w	d7,d6				; d6.w=du-dv (12.4)
	neg.w	d6				; d6.w=dv-du (12.4)
	asr.w	#3,d6				; d6.w=diag_step=2(dv-du) (integer)
	asr.w	#3,d7				; d7.w=straight_step=2dv (integer)

	move.w	a4,d4
	lsr.w	#4,d4
	bgt.s	.ok
	rts
.ok	subq.w	#1,d4

	muls.w	d2,d1				; d1=invdist*d
	asr.l	#8,d1
	muls.w	d2,d6				; d6=invdist*diag_step
	asr.l	#8,d6
	muls.w	d2,d7				; d7=invdist*straight_step
	asr.l	#8,d7
	movea.w	d6,a5				; a5=invdist*diag_step
	movea.w	d7,a6				; a6=invdist*straight_step
	move.w	a4,d6
	muls.w	d2,d6
	asr.l	#8,d6
	asr.l	#4,d6				; d6.w=invdist*du ('int')
	move.w	d6,a4				; a4=invdist*du 

	lea	AALine.intensity_table+192*8,a1

	add.l	d5,d5
	swap	d5
	sub.w	d5,d5				; d5.l= (du/dist)<<16 | 2vdu

	tst.b	Aaline.dy_greater
	beq	.draw_dx_big

; .
; .
;  .
;  .
;   .
;   .
	tst.w	d3
	bpl.s	.dx_pos
	andi.w	#$BFFF,.add_dy_big_norm
	ori.w	#$4000,.sub_dy_big_norm
	andi.w	#$BFFF,.add_dy_big_left
	ori.w	#$4000,.sub_dy_big_left
	andi.w	#$BFFF,.add_dy_big_right
	ori.w	#$4000,.sub_dy_big_right
	bra.s	.bigdy_addsub_bit_done
.dx_pos:ori.w	#$4000,.add_dy_big_norm
	andi.w	#$BFFF,.sub_dy_big_norm
	ori.w	#$4000,.add_dy_big_left
	andi.w	#$BFFF,.sub_dy_big_left
	ori.w	#$4000,.add_dy_big_right
	andi.w	#$BFFF,.sub_dy_big_right
.bigdy_addsub_bit_done:

;
; optimised for nominal case: all 3 pixels in the same chunk
;
.loop_dy_big_norm:
	tst.w	2(a3)
	bgt.s	.do_loop_dy_big_norm		; should be faster on average
	bmi	.do_loop_dy_big_left
	beq	.do_loop_dy_big_right
.do_loop_dy_big_norm:
	adda.w	(a3),a0				; 12

; center
	moveq	#$FFFFFFF8,d6			;  4
	and.w	d5,d6				;  4
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	4(a3),d6			; 16
	and.w	4(a3),d7			; 12
; left
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.add_dy_big_norm:
	add.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d0/d2			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	-8+4(a3),d0			; 16
	and.w	-8+4(a3),d2			; 12
	or.l	d0,d6				;  8
	or.w	d2,d7				;  4
; right
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.sub_dy_big_norm:
	sub.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d0/d2			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	8+4(a3),d0			; 16
	and.w	8+4(a3),d2			; 12
	or.l	d0,d6				;  8
	or.w	d2,d7				;  4
; output to screen.		
	or.l	d6,(a0)				; 20
	or.w	d7,4(a0)			; 16
	suba.w	(a3),a0				; 12
						; -- +
						; 
	tst.w	d1				; check d[i] for diagional or straight step.
	bpl.s	.diag_dy_big_norm
	move.w	d1,d5
	add.w	a4,d5				; d5.w=2vdu=d+du
	add.w	a6,d1				; d1.w=d[i+1]=d[i]+straight_step
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_norm
	rts
.diag_dy_big_norm:
	move.w	d1,d5
	sub.w	a4,d5				; d5.w=2vdu=d-du
	add.w	a5,d1				; d1.w=d[i+1]=d[i]+diag_step
	add.l	d3,a3				; d0.w=pos[i+1]=pos[i]+vstep
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_norm
	rts

;
; left edge case: 2 pixels in left chunk, 1 in right
;
.loop_dy_big_left:
	tst.w	2(a3)
	beq	.do_loop_dy_big_right
	bgt.s	.do_loop_dy_big_norm
.do_loop_dy_big_left:
	adda.w	(a3),a0				; 12

; center
	moveq	#$FFFFFFF8,d6			;  4
	and.w	d5,d6				;  4
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	4(a3),d6			; 16
	and.w	4(a3),d7			; 12
; left
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.add_dy_big_left:
	add.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d0/d2			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	-8+4(a3),d0			; 16
	and.w	-8+4(a3),d2			; 12
	or.l	d0,d6				;  8
	or.w	d2,d7				;  4
; output to screen.		
	or.l	d6,(a0)				; 20
	or.w	d7,4(a0)			; 16
; right
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.sub_dy_big_left:
	sub.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d0/d2			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	8+4(a3),d0			; 16
	and.w	8+4(a3),d2			; 12
; output to screen.		
	or.l	d0,8(a0)			; 24
	or.w	d2,8+4(a0)			; 16
	suba.w	(a3),a0				; 12
						; -- +
						; 
	tst.w	d1				; check d[i] for diagional or straight step.
	bpl.s	.diag_dy_big_left
	move.w	d1,d5
	add.w	a4,d5				; d5.w=2vdu=d+du
	add.w	a6,d1				; d1.w=d[i+1]=d[i]+straight_step
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_left
	rts
.diag_dy_big_left:
	move.w	d1,d5
	sub.w	a4,d5				; d5.w=2vdu=d-du
	add.w	a5,d1				; d1.w=d[i+1]=d[i]+diag_step
	add.l	d3,a3				; d0.w=pos[i+1]=pos[i]+vstep
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_left
	rts

;
; right edge case: 1 pixels in left chunk, 2 in right
;
.loop_dy_big_right:
	tst.w	2(a3)
	bmi.s	.do_loop_dy_big_left
	bgt	.do_loop_dy_big_norm
.do_loop_dy_big_right:
	adda.w	(a3),a0				; 12

; center
	moveq	#$FFFFFFF8,d6			;  4
	and.w	d5,d6				;  4
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	4(a3),d6			; 16
	and.w	4(a3),d7			; 12
; right
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.sub_dy_big_right:
	sub.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d0/d2			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	8+4(a3),d0			; 16
	and.w	8+4(a3),d2			; 12
	or.l	d0,d6				;  8
	or.w	d2,d7				;  4
; output to screen.		
	or.l	d6,(a0)				; 20
	or.w	d7,4(a0)			; 16
; left
	move.l	d5,d0				;  4
	swap	d0				;  4 d6.w=du/dist
.add_dy_big_right:
	add.w	d5,d0				;  4
	andi.w	#$FFF8,d0			;  8
	movem.l	(a1,d0.w),d6/d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	-8+4(a3),d6			; 16
	and.w	-8+4(a3),d7			; 12
; output to screen.		
	or.l	d6,-8(a0)			; 24
	or.w	d7,-8+4(a0)			; 16
	suba.w	(a3),a0				; 12
						; -- +
						; 
	tst.w	d1				; check d[i] for diagional or straight step.
	bpl.s	.diag_dy_big_right
	move.w	d1,d5
	add.w	a4,d5				; d5.w=2vdu=d+du
	add.w	a6,d1				; d1.w=d[i+1]=d[i]+straight_step
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_right
	rts
.diag_dy_big_right:
	move.w	d1,d5
	sub.w	a4,d5				; d5.w=2vdu=d-du
	add.w	a5,d1				; d1.w=d[i+1]=d[i]+diag_step
	add.l	d3,a3				; d0.w=pos[i+1]=pos[i]+vstep
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dy_big_right
	rts

; ..
;   ..
;     ..
.draw_dx_big:
	move.l	a2,d0
	bpl.s	.dy_pos
	ori.w	#$4000,.add_dx_big
	andi.w	#$BFFF,.sub_dx_big
	bra.s	.bigdx_addsub_bit_done
.dy_pos:andi.w	#$BFFF,.add_dx_big
	ori.w	#$4000,.sub_dx_big
.bigdx_addsub_bit_done:
	moveq	#$FFFFFFF8,d2

.loop_dx_big:
	adda.w	(a3),a0				; 12

; draw center pixel..
	moveq	#$FFFFFFF8,d6
	and.w	d5,d6
	move.l	4(a3),d0			; 12

; center pixel
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	d0,d6				;  8
	and.w	d0,d7				;  4
	or.l	d6,(a0)				; 20
	or.w	d7,4(a0)			; 16

; +v neighbour pixel
	move.l	d5,d6
	swap	d6				; d6.w=du/dist
.add_dx_big:
	add.w	d5,d6				; d6.w=right_offset=right_diff_offset + mid_offset
	and.w	d2,d6
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	d0,d6				;  8
	and.w	d0,d7				;  4
	or.l	d6,160(a0)			; 24
	or.w	d7,164(a0)			; 16

; -v neighbour pixel
	move.l	d5,d6
	swap	d6				; d6.w=du/dist
.sub_dx_big:
	sub.w	d5,d6			; d6.w=-left_offset=left_diff_offset - mid_offset
	and.w	d2,d6
	movem.l	(a1,d6.w),d6-d7			; d6.l=plane0mask,plane1mask,d7.l=plane2mask,-
	and.l	d0,d6				;  8
	and.w	d0,d7				;  4
	or.l	d6,-160(a0)			; 20
	or.w	d7,-156(a0)			; 16

	suba.w	(a3),a0				; 12

	tst.w	d1				; check d[i] for diagional or straight step.
	bpl.s	.diag_dx_big
	move.w	d1,d5
	add.w	a4,d5				; d5.w=2vdu=d+du
	add.w	a6,d1				; d1.w=d[i+1]=d[i]+straight_step
	add.l	d3,a3				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dx_big
	rts
.diag_dx_big:
	move.w	d1,d5
	sub.w	a4,d5				; d5.w=2vdu=d-du
	add.w	a5,d1				; d1.w=d[i+1]=d[i]+diag_step
	add.l	a2,a0				; d0.w=pos[i+1]=pos[i]+vstep
	add.l	d3,a3				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	dbf	d4,.loop_dx_big
	rts

Aaline.dy_greater:
	dc.w	0

; input:
; d0.w=x0 (12.4)
; d1.w=y0 (12.4)
; d2.w=x1 (12.4)
; d3.w=y1 (12.4)
; d4.l=color
AAline.clear:
	move.l	d4,.color

	move.w	d2,d4				; d4.w=x1
	move.w	d3,d5				; d5.w=y1
	sub.w	d0,d2				; d2.w=dx
	sub.w	d1,d3				; d3.w=dy
	lsr.w	#4,d1
	lsr.w	#4,d0
	mulu.w	#320,d1				; d1.w=y0*WIDTH
	ext.l	d0
	add.l	d1,d0				; d0.w=x0+y0*WIDTH
	move.w	d2,d6				; d6.w=dx
	bpl.s	.dx_abs
	neg.w	d6
.dx_abs:					; d6.w=|dx|
	move.w	d3,d7				; d7.w=dy
	bpl.s	.dy_abs
	neg.w	d7
.dy_abs:					; d7.w=|dy|

; prepare variables for octant mirroring
	cmp.w	d6,d7
	bgt.s	.abs_dy_greater

	tst.w	d2
	bpl.s	.bigdx_ustep_pos
	move.w	#-1,a2				; a2.w=ustep
	bra.s	.bigdx_ustep_done
.bigdx_ustep_pos:
	move.w	#+1,a2				; a2.w=ustep
.bigdx_ustep_done:
	tst.w	d3
	bpl.s	.bigdx_vstep_pos
	move.l	#-320,d3			; d3.w=vstep
	bra.s	.select_done
.bigdx_vstep_pos:
	move.l	#+320,d3			; d3.w=vstep
; d4.w=u=x1, d5.w=v=y1
; d6.w=du=|dx|, d7.w=dv=|dy|
	bra.s	.select_done

.abs_dy_greater:
	exg.l	d4,d5				; d4.w=u=y1, d5.w=v=x1
	exg.l	d6,d7				; d6.w=du=|dy|, d7.w=dv=|dx|
	tst.w	d3
	bpl.s	.bigdy_ustep_pos
	move.w	#-320,a2			; a2.w=ustep
	bra.s	.bigdy_ustep_done
.bigdy_ustep_pos:
	move.w	#+320,a2			; a2.w=ustep
.bigdy_ustep_done:
	tst.w	d2
	bpl.s	.bigdy_vstep_pos
	moveq	#-1,d3				; d3.w=vstep
	bra.s	.select_done
.bigdy_vstep_pos:
	moveq	#+1,d3				; d3.w=vstep

; prepare bresenham's midpoint algorithm discriminant + steps and
; gupta-sproull invariants..
; d4.w=u, d5.w=v
; d6.w=du, d7.w=dv
.select_done:
; prepare midpoint algo stuff..
	move.w	d6,a4				; a4.w=du (12.4)
	move.w	d7,d1
	add.w	d1,d1				; d1.w=2dv (12.4)
	sub.w	d6,d1				; d1.w=2dv-du (12.4)
	asr.w	#4,d1				; d1.w=discr[0]=(2dv-du) (integer)
	sub.w	d7,d6				; d6.w=du-dv (12.4)
	neg.w	d6				; d6.w=dv-du (12.4)
	asr.w	#3,d6				; d6.w=diag_step=2(dv-du) (integer)
	asr.w	#3,d7				; d7.w=straight_step=2dv (integer)
	movea.w	d6,a5
	movea.w	d7,a6
	move.w	a4,d6
	move.w	a4,d4
	asr.w	#4,d6				; d6.w=du (int)
	move.w	d6,a4				; a4=du (int)

	movea.l	scr,a0
	lea	AALine.offsetmask_table,a3

	lsl.l	#3,d0
	adda.l	a2,a2
	adda.l	a2,a2
	adda.l	a2,a2
	lsl.l	#3,d3

	move.l	.color(pc),d6

; todo: separate cases for horizontal chunks in v dir
;                      and vertical chunks in v dir

.loop:	adda.l	d0,a3
	move.w	(a3),d7
	move.l	d6,0(a0,d7.w)
	move.w	d6,4(a0,d7.w)

; +v neighbour pixel
	adda.l	d3,a3				; move to +v neighbour
	move.w	(a3),d7
	move.l	d6,0(a0,d7.w)
	move.w	d6,4(a0,d7.w)

; -v neighbour pixel
	suba.l	d3,a3
	suba.l	d3,a3				; a3: -v neighbour mask,offset
	move.w	(a3),d7
	move.l	d6,0(a0,d7.w)
	move.w	d6,4(a0,d7.w)

; restore table start
	adda.l	d3,a3
	suba.l	d0,a3

	tst.w	d1				; check d[i] for diagional or straight step.
	bpl.s	.diag

	add.w	a6,d1				; d1.w=d[i+1]=d[i]+straight_step
	add.l	a2,d0				; d0.w=pos[i+1]=pos[i]+ustep
	subi.w	#16,d4
	bpl.s	.loop
	rts

.diag:	add.w	a5,d1				; d1.w=d[i+1]=d[i]+diag_step
	add.l	d3,d0				; d0.w=pos[i+1]=pos[i]+vstep

.next:	add.l	a2,d0				; d0.w=pos[i+1]=pos[i]+ustep(+vstep)
	subi.w	#16,d4
	bpl.s	.loop

	rts

.color:	dc.l	0

; input:
; d0.w=x0 (12.4)
; d1.w=y0 (12.4)
; d2.w=x1 (12.4)
; d3.w=y1 (12.4)
AAline.draw_aliased:
	lsr.w	#4,d0
	lsr.w	#4,d1
	lsr.w	#4,d2
	lsr.w	#4,d3
	moveq	#$F,d4
	movea.l	scr,a0
	addq	#4,a0
	lea	Lib3D.scan_table,a1
	lea	Lib3D.putpix_table,a2
	jmp	Line.paint

AALine.calc_glass_pos:
	bsr	getTime
	move.l	d0,.time

.sine:	lea	sine_tbl,a0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d0,d1
	lsr.w	#1,d1
	andi.w	#SINTABLE_LEN-1,d0
	andi.w	#SINTABLE_LEN-1,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	add.w	d1,d1
	move.b	(a0,d0.w),d0
	move.b	(a0,d1.w),d1
	ext.w	d0
	ext.w	d1
	asr.w	#2,d0
	asr.w	#2,d1
	addi.w	#160-8-16,d0
	addi.w	#100-8,d1
	movem.w	d0-d1,AALine.glass_pos

	tst.w	AALine.glass_fixed
	beq	.end

	move.l	.time(pc),d0
	sub.l	AALine.glass_start_time,d0
	move.l	d0,d1
	lsr.l	#6,d1
	andi.w	#$FFFC,d1
	cmpi.w	#9*4,d1
	blt.s	.edge_idx_ok
	move.w	#$00FF,d0
	moveq	#8*4,d1
.edge_idx_ok:
	lea	AALine.2d_dot_table+2,a2
	lea	AALine.ns_edges+2,a3
	movem.w	(a3,d1.w),d2/d4
	add.w	d2,d2				; d2.w=2i
	move.w	d2,d3				; d3.w=2i
	add.w	d3,d3				; d3.w=4i
	add.w	d3,d2				; d2.w=6i
	movem.w	(a2,d2.w),d2-d3
	add.w	d4,d4				; d2.w=2j
	move.w	d4,d5				; d3.w=2j
	add.w	d5,d5				; d3.w=4j
	add.w	d5,d4				; d2.w=6j
	movem.w	(a2,d4.w),d4-d5
	andi.w	#$00FF,d0
	move.w	d0,d1
	not.b	d0
	mulu.w	d0,d2
	mulu.w	d0,d3
	mulu.w	d1,d4
	mulu.w	d1,d5
	add.l	d4,d2
	add.l	d5,d3
	move.l	d2,d0
	move.l	d3,d1
	lsr.l	#8,d0
	lsr.l	#8,d1
	subq.w	#6,d0
	subq.w	#6,d1

	movem.w	AALine.glass_pos,d2-d3
	move.l	.time(pc),d4
	sub.l	AALine.glass_start_time,d4
	cmpi.w	#$00FF,d4
	blt.s	.time_clipped
	move.w	#$00FF,d4
.time_clipped:
	move.w	d4,d5
	not.b	d5
	muls.w	d5,d2
	muls.w	d5,d3
	muls.w	d4,d0
	muls.w	d4,d1
	add.l	d2,d0
	add.l	d3,d1
	moveq	#0,d4
	asr.l	#8,d0
	addx.w	d4,d0
	asr.l	#8,d1
	addx.w	d4,d1
	movem.w	d0-d1,AALine.glass_pos

.end	rts

.time:	dc.l	0

AALine.paint_glass:

	movem.w	AALine.glass_pos,d0-d1
	movea.l	scr,a0
	lea	Lib3D.scan_table,a1
	lea	AALine.shifted_sprite,a3
	lea	AALine.shifted_mask,a2
	lea	.dummy(pc),a6
	jmp	Sprite.paint_24

.dummy:	ds.b	Sprite.SLAB_SIZE
	even

; old shit
	movea.l	scr,a0
	lea	88+160*40(a0),a0
	lea	AALine.train+34+64,a1
	moveq	#AALine.SPRITE_SCANS-1,d7

.loop:
	movem.w	(a1)+,d0-d3
	move.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	not.w	d4
	and.w	d4,(a0)
	or.w	d0,(a0)+
	and.w	d4,(a0)
	or.w	d1,(a0)+
	and.w	d4,(a0)
	or.w	d2,(a0)+
	and.w	d4,(a0)
	or.w	d3,(a0)+
	lea	160-8(a1),a1
	lea	160-8(a0),a0
;	rept	4
;	move.l	(a1)+,(a0)+
;	endr
;	lea	160-16(a1),a1
;	lea	160-16(a0),a0

	dbf	d7,.loop
	rts

AALine.paint_big_glass:
	movea.l	scr,a0
	lea	AALine.train+34,a1
	lea	88+160*32(a0),a0
	lea	88+160*32(a1),a1
	move.w	#168-1,d7

.yloop:	movem.l	(a1),d0-d6/a2-a4
	movem.l	d0-d6/a2-a4,(a0)
	movem.l	40(a1),d0-d6/a2
	movem.l	d0-d6/a2,40(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d7,.yloop
	rts

AALine.bitzoom:
AALine.bitzoom_round:
	movem.w	AALine.glass_pos,d0-d1
	move.w	d0,d4
	andi.w	#$000F,d4			; d4.w=x&$000F = shift
	sub.w	d4,d0				; d0.w=x&$FFF0
	lsr.w	#1,d0				; d0.w= x offset
	moveq	#16,d5
	sub.w	d4,d5				; d5.w=W-shift

	movea.l	scr,a0
	addq	#2,a0
	movea.l	a0,a1

	;lea	160*46+8(a1),a1
	;lea	160*46+8+80(a1),a1
	mulu.w	#160,d1
	add.w	d1,d0				; d0.w= x offset + y offset
	adda.w	d0,a1				; a1: screen address to zoom in on (top left)

	lea	((192+32)/2)+160*52(a0),a0

;--------
	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

	lsl.w	#4,d0
	lsl.w	#4,d1
	lsl.w	#4,d2
	lea	16(a0),a0

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 10
	rept	2				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-32(a0),a0
	lea	160-6(a1),a1
;--------

	moveq	#2-1,d7
.pre_yloop:
	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

	lsl.w	#2,d0
	lsl.w	#2,d1
	lsl.w	#2,d2
	lea	8(a0),a0

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 10
	rept	4				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-40(a0),a0
	lea	160-6(a1),a1
	dbf	d7,.pre_yloop
;--------

	moveq	#6-1,d7

.yloop:	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 12
	rept	6				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-48(a0),a0
	lea	160-6(a1),a1
	dbf	d7,.yloop

;--------
	moveq	#2-1,d7
.post_yloop:
	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

	lsl.w	#2,d0
	lsl.w	#2,d1
	lsl.w	#2,d2
	lea	8(a0),a0

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 10
	rept	4				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-40(a0),a0
	lea	160-6(a1),a1
	dbf	d7,.post_yloop

;--------
	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

	lsl.w	#4,d0
	lsl.w	#4,d1
	lsl.w	#4,d2
	lea	16(a0),a0

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 10
	rept	2				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-32(a0),a0
	lea	160-6(a1),a1
;--------

; octiply..
	movea.l	scr,a0
	lea	112+160*52+2(a0),a1
	lea	160(a1),a0

offset	set	0
	movem.l	(a1),d0-d6/a2-a6
	rept	7
	movem.l	d4-d6,offset+16(a0)
offset	set	offset+160
	endr
	lea	8*160(a0),a0
	lea	8*160(a1),a1

	moveq	#2-1,d7

.pre_oct_loop:
offset	set	0
	movem.l	(a1),d0-d6/a2-a6
	rept	7
	movem.l	d2-d6/a2-a3,offset+8(a0)
offset	set	offset+160
	endr
	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.pre_oct_loop

	moveq	#6-1,d7
.octiply_loop:

offset	set	0
	movem.l	(a1),d0-d6/a2-a5
	rept	7
	movem.l	d0-d6/a2-a5,offset(a0)
offset	set	offset+160
	endr

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop

	moveq	#2-1,d7

.post_oct_loop:
offset	set	0
	movem.l	(a1),d0-d6/a2-a6
	rept	7
	movem.l	d2-d6/a2-a3,offset+8(a0)
offset	set	offset+160
	endr
	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.post_oct_loop

offset	set	0
	movem.l	(a1),d0-d6/a2-a6
	rept	7
	movem.l	d4-d6,offset+16(a0)
offset	set	offset+160
	endr

	rts

AALine.bitzoom_square:
	movem.w	AALine.glass_pos,d0-d1
	move.w	d0,d4
	andi.w	#$000F,d4			; d4.w=x&$000F = shift
	sub.w	d4,d0				; d0.w=x&$FFF0
	lsr.w	#1,d0				; d0.w= x offset
	moveq	#16,d5
	sub.w	d4,d5				; d5.w=W-shift

	movea.l	scr,a0
	addq	#2,a0
	movea.l	a0,a1

	;lea	160*46+8(a1),a1
	;lea	160*46+8+80(a1),a1
	mulu.w	#160,d1
	add.w	d1,d0				; d0.w= x offset + y offset
	adda.w	d0,a1				; a1: screen address to zoom in on (top left)

	lea	((192+32)/2)+160*52(a0),a0

;--------
	ifne	0
	moveq	#12-1,d7
	else
	moveq	#11-1,d7

	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

	lsl.w	#4,d0
	lsl.w	#4,d1
	lsl.w	#4,d2
	lea	16(a0),a0

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 10
	rept	2				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-32(a0),a0
	lea	160-6(a1),a1
	endc
;--------

.yloop:	move.w	8(a1),d1
	lsr.w	d5,d1
	move.w	(a1)+,d0
	lsl.w	d4,d0
	or.w	d1,d0			; d0.w= y0

	move.w	8(a1),d2
	lsr.w	d5,d2
	move.w	(a1)+,d1
	lsl.w	d4,d1
	or.w	d2,d1			; d1.w= y1

	move.w	8(a1),d3
	lsr.w	d5,d3
	move.w	(a1)+,d2
	lsl.w	d4,d2
	or.w	d3,d2			; d2.w= y2

; y = (x_hi << shift) | [ x_lo >> (W-shift) ]
; W = 16 (word size in bits)

; frame width / nr of chunks = 12
	rept	6				; must be <=16
	add.w	d0,d0
	scs	(a0)+
	add.w	d0,d0
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d1,d1
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	add.w	d2,d2
	scs	(a0)+
	addq	#2,a0
	endr

	lea	160*8-48(a0),a0
	lea	160-6(a1),a1
	dbf	d7,.yloop

; octiply..
	movea.l	scr,a0
	lea	((192+32)/2)+160*52+2(a0),a1
	lea	160(a1),a0
	moveq	#12-1,d7

.octiply_loop:

offset	set	0
	movem.l	(a1),d0-d6/a2-a6
	rept	7
	movem.l	d0-d6/a2-a6,offset(a0)
offset	set	offset+160
	endr

	lea	8*160(a0),a0
	lea	8*160(a1),a1
	dbf	d7,.octiply_loop

	rts

;--------------------------------------------------------------------------

	data

AALine.train:
;	incbin	benelux.pi1
;	incbin	treinmag.pi1
;	incbin	treinma2.pi1
;	incbin	treinma3.pi1
;	incbin	treinma4.pi1
	incbin	treinma5.pi1

AALine.haze_adr:
	dc.l	AALine.purple_haze

AALine.purple_haze:
	;dc.w	$0001,$0801,$0801,$0101,$0101,$0A01,$0A01,$0201
	dc.w	$0660,$0DD8,$0551,$0CC1,$0441,$0BB1,$0331,$0AA1
	dc.w	$0221,$0291,$0211,$0281,$0201
AALine.end_haze:

; just some grey scale test palette..
AALine.pal:
	; 3D palette
	dc.w	$0660,$0661,$0552,$0443,$0334,$0225,$0226,$0226
	; side pic palette
	dc.w	$0001,$0012,$0322,$0522,$0544,$0654,$0766,$0751

AALine.org_palette:=	AALine.train+2 AALine.pal

AALine.shape_xcenter:
	dc.w	$0A00
	;dc.w	$0400
AALine.shape_ycenter:
	dc.w	$0640

AALine.clear_rout:
	dc.l	AALine.clear_mid_frame

AALine.ns_vertices:
	dc.w	(.end-.start)/6
.start:	dc.w	-50,+00,0			; 0
	dc.w	-30,-20,0			; 1
	dc.w	-00,-20,0			; 2
	dc.w	+20,+00,0			; 3
	dc.w	+30,-20,0			; 4
	dc.w	+50,+00,0			; 5
	dc.w	+30,+20,0			; 6
	dc.w	+00,+20,0			; 7
	dc.w	-20,+00,0			; 8
	dc.w	-30,+20,0			; 9
.end:

AALine.ns_edges:
	dc.w	(.end-.start)/4
.start:	dc.w	0,1
	dc.w	1,2
	dc.w	2,3
	dc.w	3,5
	dc.w	5,6
	dc.w	6,7
	dc.w	7,8
	dc.w	8,0
	dc.w	0,9
	dc.w	5,4
.end:

AALine.transition_count:
	dc.w	-2

;--------------------------------------------------------------------------

	bss

AALine.bla_on:
	ds.w	1
AALine.center:
	ds.w	2
AALine.paint_rout:
	ds.l	1
AALine.geom_rout:
	ds.l	1
AALine.event_start_time:
	ds.l	1
AALine.morph_enable:
	ds.w	1
AALine.morph_start_frame:
	ds.w	1
AALine.wipe_countdown:
	ds.w	1
AALine.banner_src_offset:
	ds.w	1
AALine.banner_dst_offset:
	ds.w	1
AALine.old_banner_src_offset:
	ds.w	1
AALine.old_banner_dst_offset:
	ds.w	1
AALine.end_obj_adr:
	ds.l	1
AALine.start_obj_adr:
	ds.l	1
AALine.aa_enable:
	ds.w	1

	ifne	1

;	ds.l	2*32				; left overspill
AALine.offsetmask_table:=	(Lib3D.end_of_bss+2*32)
;	ds.l	2*320
;	ds.l	2*32				; right overspill
;	ds.w	256*4
AALine.intensity_table:=	(AALine.offsetmask_table+8*(320+32+256))
;	ds.w	384*4
;	ds.w	256*4
AALine.2d_dot_table:=		(AALine.intensity_table+8*(320+256))
;	ds.b	2*AALine.MAX_NUM_DOTS
AALine.shifted_sprite:=		(AALine.2d_dot_table+2*AALine.MAX_NUM_DOTS)
;	ds.b	AALine.SHIFTSPRITE_SIZE*16
AALine.shifted_mask:=		(AALine.shifted_sprite+AALine.SHIFTSPRITE_SIZE*16)
;	ds.b	AALine.SHIFTSPRITE_SIZE*16/2

	else

	ds.l	2*32				; left overspill
AALine.offsetmask_table:
	ds.l	2*320
	ds.l	2*32				; right overspill
	ds.w	256*4
AALine.intensity_table:
	ds.w	384*4
	ds.w	256*4
AALine.2d_dot_table:
	ds.b	2*AALine.MAX_NUM_DOTS
AALine.shifted_sprite:
	ds.b	AALine.SHIFTSPRITE_SIZE*16
AALine.shifted_mask:
	ds.b	AALine.SHIFTSPRITE_SIZE*16/2

	endc

AALine.glass_pos:
	ds.w	2
AALine.glass_fixed:
	ds.w	1
AALine.glass_start_time:
	ds.l	1

AALine.whitefade_table:
	ds.w	16*16
AALine.blackfade_table:
	ds.w	16*16
AALine.purplefade_table:
	ds.w	16*16
AALine.yellowfade_table:
	ds.w	16*16

AALine.fade_mode:
	ds.w	1
AALine.fade_steps_left:
	ds.w	1
AALine.fade_table_addr:
	ds.l	1
AALine.fade_start_time:
	ds.l	1
