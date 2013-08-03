; lame twister, maybe with some colliding particles.
;
; 30-01-2008:
;
; made a simple particle bounce rout
;
; 02-02-2008:
;
; did a 4 bpl sprite rout + extracting/preshifting from degas data.
; made a movem version, a bit faster, that.
; 18:00: trying to add some clipping (vertical, first).
; 19:10: works (clipping and culling on all sides)..
; 19:15: used to represent a particle..
;
; 08-02-2008:
;
; added sprite rout (clipped), multiple particles, for instance exploding
; words. can load degas font from file at run time.
;
; 12-02-2008:
;
; added centered twister with spinning words.
;
; 16-02-2008:
;
; todo: introduce it in two separate bitplanes.
;

; load from disk at init (1) or incbin (0)
	ifd	DEMO_SYSTEM
Twist.DYNAMIC_PI1:=	0
	else
Twist.DYNAMIC_PI1:=	0 1
	endc

Twist.MEASURE_CPU:=	0
Twist.NR_VBLS:=		1

Twist.SPAN_SIZE:=	64			; 128 pixels = 64 bytes
Twist.NUM_SPANS:=	256
Twist.ANIM_BUF_SIZE:=	(Twist.SPAN_SIZE*Twist.NUM_SPANS)

Twist.NUM_PARTICLES:=	10

			rsreset
Twist.PART_STATE:	rs.w	1
Twist.PART_OMEGA:	rs.w	1
Twist.PART_XPOS:	rs.w	1
Twist.PART_YPOS:	rs.w	1
Twist.PART_ZPOS:	rs.w	1
Twist.PART_XSPEED:	rs.w	1
Twist.PART_YSPEED:	rs.w	1
Twist.PART_CHAR:	rs.w	1
Twist.PART_SIZE:	rs.w	0

Twist.SPRITE_SCANS:=		16
Twist.SPRITESCAN_CHUNKS:=	1
Twist.SHIFTSCAN_SIZE:=		((Twist.SPRITESCAN_CHUNKS+1)*8)
Twist.SHIFTSPRITE_SIZE:=	(Twist.SHIFTSCAN_SIZE*Twist.SPRITE_SCANS)

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	mat.s
	include	common.s
	include	sprite.s
	include	lib_3d.s
	text
end_libs:
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Twist.mainloop
	dc.l	Twist.init
	dc.l	Twist.rt_init			; 2
	dc.l	Twist.deinit
	dc.l	Twist.spawn_meikever_string	; 4
	dc.l	Twist.spawn_by_string		; 5
	dc.l	Twist.spawn_particle		; 6
	dc.l	Twist.set_left			; 7
	dc.l	Twist.set_center		; 8
	dc.l	Twist.spawn_thankyou_string	; 9
	dc.l	Twist.spawn_forwatching_string	;10
	dc.l	Twist.spawn_staycool_string	;11
	dc.l	Twist.spawn_stayatari_string	;12
	dc.l	Twist.trigger_wipe_in		;13
	dc.l	Twist.trigger_wipe_out		;14
	dc.l	Twist.trigger_fadeout		;15
	dc.l	0

;- plugin routines ---------------------------------------------------------

Twist.init:
;	bsr	Twist.set_left
	bsr	Twist.set_center
	rts

Twist.rt_init:
	ifne	Twist.DYNAMIC_PI1

; fopen
	clr.w	-(sp)
	pea	Twist.pic_name
	move.w	#$3D,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	OUT
	move.w	d0,.handle

	pea	Twist.pic
	move.l	#32034,-(sp)
	move.w	d0,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp
	cmpi.l	#32034,d0
	bne	OUT

; fclose
	move.w	.handle(pc),-(sp)
	move.w	#$3E,-(sp)
	trap	#1
	addq	#4,sp

	endc

	jsr	Lib3D.calc_offsetmask_tables
	bsr	Twist.clear_span_anim
	bsr	Twist.precalc_span_anim

	lea	Twist.pic+34,a1
	lea	Twist.shifted_sprite,a0
	move.w	#Twist.SHIFTSPRITE_SIZE,d4
	moveq	#16,d7
	bsr	Sprite.preshift_16pix

	lea	Twist.shifted_sprite,a1
	lea	Twist.shifted_mask,a0
	moveq	#16,d7
	bsr	Sprite.extract_16pix_mask

	bsr	Twist.extract_font

	bsr	Twist.calc_fadepals

	move.l	frmcnt,Twist.start_frmcnt
	move.w	$0468.w,Twist.old_468

	bsr	Twist.set_left
	rts

.handle:dc.w	0

Twist.deinit:
	rts

Twist.mainloop:
	ifne	Twist.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	Twist.start_frmcnt,d0
	subq.l	#2,d0
	bge.s	.clear_slabs
	movea.l	scr,a0
	jsr	CLEAR_STSCREEN
	;bsr	Twist.clear_right
	bra.s	.end_clear
.clear_slabs:
	bsr	Twist.clear_slabs
.end_clear:

	ifne	Twist.MEASURE_CPU
	ifeq	testmode
	move.w	#$0600,$FFFF8240.w
	endc
	endc

; wipe, when necessary..
	movea.l	Twist.wipe_rout,a0
	jsr	(a0)

; todo: separate twist movement..
	bsr	Twist.update
	movea.l	Twist.part_update_rout,a0
	jsr	(a0)

	ifne	Twist.MEASURE_CPU
	ifeq	testmode
	move.w	#$0050,$FFFF8240.w
	endc
	endc

	movea.l	Twist.paint_rout,a0
	jsr	(a0)

; test shit.. up for demolition..
	ifne	0
	move.w	#-10,d0
	move.w	#-10,d1
	movea.l	scr,a0
	lea	Twist.scan_table,a1
	movea.l	Twist.char_adr_table+'C'*4,a3
	lea	Twist.SHIFTSPRITE_SIZE*16(a3),a2
	lea	Twist.shifted_sprite,a3
	lea	Twist.shifted_mask,a2
	bsr	Sprite.paint
	endc

	lea	Twist.slab_table_adr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifne	Twist.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#Twist.init_pal,palirq
.end_pal:

; wait for vbl..
	move.w	Twist.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Twist.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Twist.old_468
	move.w	d1,Twist.measured_vbls

	rts

Twist.measured_vbls:
	ds.w	1
Twist.old_468:
	ds.w	1

;- event routines ----------------------------------------------------------

Twist.spawn_particle:
	bsr	getTime
	move.w	d0,Twist.spawn_start_time

	lea	Twist.part_table,a0
	move.w	#1,Twist.PART_STATE(a0)
	move.w	#160<<4,Twist.PART_XPOS(a0)
	move.w	#100<<4,Twist.PART_YPOS(a0)
	move.w	#-2<<2,Twist.PART_XSPEED(a0)
	move.w	#-5<<2,Twist.PART_YSPEED(a0)
	move.w	#'P',Twist.PART_CHAR(a0)
	rts

Twist.set_left:
	move.w	#0,Twist.screen_offset
	move.l	#Twist.update_bouncing_particles,Twist.part_update_rout
	move.l	#Twist.paint_left,Twist.paint_rout
	move.l	frmcnt,Twist.start_frmcnt
	move.w	#100<<4,Twist.y_start
	bsr	Twist.trigger_wipe_in
	rts

Twist.set_center:
	move.w	#96/2,Twist.screen_offset
	move.l	#Twist.update_spinning_particles,Twist.part_update_rout
	move.l	#Twist.paint_center,Twist.paint_rout
	move.l	frmcnt,Twist.start_frmcnt
	move.w	#0,Twist.spin_time
	move.w	#-32<<4,Twist.y_start
	bsr	Twist.trigger_wipe_in
	rts

Twist.spawn_meikever_string:
	lea	Twist.meikever_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.spawn_by_string:
	lea	Twist.by_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.spawn_thankyou_string:
	lea	Twist.thankyou_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.spawn_forwatching_string:
	lea	Twist.forwatching_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.spawn_staycool_string:
	lea	Twist.staycool_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.spawn_stayatari_string:
	lea	Twist.stayatari_string(pc),a1
	bra.s	Twist.spawn_particle_string

Twist.meikever_string:
	dc.w	.end-.start
.start:	dc.b	"MEIKEVER"
.end:
	even

Twist.by_string:
	dc.w	.end-.start
.start:	dc.b	"BY RG + LNO"
.end:
	even

Twist.thankyou_string:
	dc.w	.end-.start
.start:	dc.b	"THANKYOU"
.end:
	even

Twist.forwatching_string:
	dc.w	.end-.start
.start:	dc.b	"FOR WATCHIN"
.end:
	even

Twist.staycool_string:
	dc.w	.end-.start
.start:	dc.b	"STAY COOL"
.end:
	even

Twist.stayatari_string:
	dc.w	.end-.start
.start:	dc.b	"STAY ATARI"
.end:
	even

; input:
; a1: string (size.w, char1.b, char2.b, ...)
Twist.spawn_particle_string:
	bsr	getTime
	move.w	d0,Twist.spawn_start_time

	lea	sine_tbl,a2
	lea	Twist.part_table,a0
	move.w	(a1)+,d0
	move.w	d0,d7
	subq.w	#1,d7
	lsl.w	#4+4-1,d0			; 16 pix wide, 4 bit subpix /halved
	neg.w	d0
	move.w	d0,d6
	asr.w	#2,d6				; d6.w=omega[0]
	addi.w	#220<<4,d0
	move.w	Twist.y_start,d1
	move.l	.rnd(pc),d2

.loop:	tst.w	Twist.PART_STATE(a0)
	bne.s	.next				; occupado?

	moveq	#0,d3
	move.b	(a1)+,d3
	cmpi.w	#" ",d3
	beq.s	.skip
	move.w	d3,Twist.PART_CHAR(a0)

	move.w	#1,Twist.PART_STATE(a0)
	move.w	d0,Twist.PART_XPOS(a0)

; nasty check for spinning mode..
	move.w	d1,Twist.PART_YPOS(a0)
	bpl.s	.just_bouncing
	move.w	d7,d4
	lsl.w	#5,d4
	sub.w	d4,Twist.PART_YPOS(a0)
.just_bouncing:

	move.l	d2,d3

	andi.w	#(SINTABLE_LEN-1)*4,d3		; angle*4
	move.l	d2,d5
	swap	d5
	ext.w	d5
	asr.w	#2,d5
	addi.w	#$0080,d5			; amp
	move.w	(a2,d3.w),d4			; sin(angle)
	muls.w	d5,d4
	swap	d4
	move.w	d4,Twist.PART_XSPEED(a0)
	move.w	2(a2,d3.w),d4			; cos(angle)
	muls.w	d5,d4
	swap	d4
	move.w	d4,Twist.PART_YSPEED(a0)
;	ext.w	d3
;	asr.w	#2,d3
;	move.w	d3,Twist.PART_XSPEED(a0)
;	swap	d3
;	ext.w	d3
;	asr.w	#2,d3
;	move.w	d3,Twist.PART_YSPEED(a0)

;	move.w	#100<<4,d4
;	move.w	d6,d5
;	bpl.s	.pos_offset
;	neg.w	d4
;.pos_offset:
;	add.w	d5,d4
;	move.w	d4,Twist.PART_OMEGA(a0)	
	move.w	d6,Twist.PART_OMEGA(a0)	

.next:	lea	Twist.PART_SIZE(a0),a0
.skip:	addi.w	#64,d6				; d6.w=omega[n+1]
	addq.l	#7,d2
	rol.l	d2,d2				; d2.l=next rnd
	addi.w	#16<<4,d0			; d0.w=next x
	dbf	d7,.loop

	move.l	d2,.rnd
	rts

.rnd:	dc.l	$A1721B28

Twist.trigger_wipe_in:
	move.l	#Twist.wipe_in,Twist.wipe_rout
	rts

Twist.trigger_wipe_out:
	move.l	#Twist.wipe_out,Twist.wipe_rout
	rts

Twist.wipe_in:
	move.w	Twist.num_rows,d0
	addq.w	#2,d0
	cmpi.w	#200,d0
	bgt.s	.stop
	move.w	d0,Twist.num_rows
	rts
.stop:	move.l	#dummy,Twist.wipe_rout
	rts

Twist.wipe_out:
	move.w	Twist.num_rows,d0
	subq.w	#2,d0
	bmi.s	.stop
	move.w	d0,Twist.num_rows
	rts
.stop:	move.l	#dummy,Twist.wipe_rout
	rts

Twist.trigger_fadeout:
	jsr	getTime
	move.l	d0,Twist.fade_start_time
	move.w	#+63,Twist.fade_steps_left
	move.l	#Twist.bluefade_table,Twist.fade_table_addr
	move.l	#Twist.perform_fade_step,palirq
	rts

;- sub routines ------------------------------------------------------------

Twist.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	Twist.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#64,d1
.fade_index_ok:
	lsl.w	#3,d1
	andi.w	#$FFE0,d1
	movea.l	Twist.fade_table_addr,a0
	;adda.w	d1,a0

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
.pal_is_set:

	move.l	Twist.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,Twist.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

Twist.calc_fadepals:
; split palette up into 24bit
	lea	Twist.pic+2,a1
	lea	Twist.tmp_pal(pc),a0
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
	lea	Twist.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	Twist.tmp_pal(pc),a1
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
	lea	Twist.blackfade_table,a0
	moveq	#16-1,d7
.lowloop:
	lea	Twist.tmp_pal(pc),a1
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
	lea	Twist.bluefade_table,a0
	moveq	#16-1,d7
	movea.w	#15,a3			; a3= dst red level
	movea.w	#15,a4			; a4= dst green level
	movea.w	#15,a5			; a5= dst blue level

.bloop:	lea	Twist.tmp_pal(pc),a1
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

Twist.tmp_pal:
	ds.b	3*16



Twist.clear_slabs:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	movea.l	Twist.slab_table_adr,a1
	moveq	#Twist.NUM_PARTICLES-1,d7
.loop:	tst.w	Sprite.SLAB_STATE(a1)
	beq.s	.next
	move.l	Sprite.SLAB_ADR(a1),d0
	beq.s	.next
	move.w	Sprite.SLAB_HEIGHT(a1),d6
	add.w	d6,d6				; 2
	move.w	d6,d5				; 
	add.w	d6,d6				; 4
	add.w	d5,d6				; 6=4+2
	neg.w	d6
	
	movea.l	d0,a0
off	set	15*160
	rept	16
	movem.l	d1-d4,off(a0)
off	set	off-160
	endr

.next:	lea	Sprite.SLAB_SIZE(a1),a1
.end:	dbf	d7,.loop

	rts

; render current right edge shape..
; todo: also store anim frame offset/address?
Twist.update:
	jsr	getTime
	move.w	d0,d1
	add.w	d0,d0
	lea	Twist.offsets,a3
	lea	sine_tbl,a2
	lea	Twist.right_table,a1
	lea	Twist.edge_table,a0
	lea	Twist.cos_table,a4
	move.w	#SINTABLE_LEN-1,d6
	move.w	#200-1,d7

.loop:	and.w	d6,d0			; d0.w=angle[n]
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	moveq	#0,d2
	move.b	(a2,d1.w),d2
	move.b	(a1,d2.w),(a0)+		; store right edge position.
	move.b	2(a1,d2.w),(a4)+	; store cosine (used for normal vector).
	move.w	(a2,d1.w),d2
	sub.b	d2,d2
	lsr.w	#2,d2			; d2.w=%00iiiii.ii000000
	move.w	d2,(a3)+		; store offset.	
	addq.w	#1,d0
	dbf	d7,.loop
	rts

Twist.update_spinning_particles:
; todo: write this, with z stuff and all.. spiralling..

	lea	Twist.part_table,a0
	lea	sine_tbl,a1
	move.w	Twist.spin_time,d6
	moveq	#Twist.NUM_PARTICLES-1,d7

.loop:	tst.w	Twist.PART_STATE(a0)
	beq.s	.next
	move.w	d6,d5

	;muls.w	Twist.PART_OMEGA(a0),d5
	muls.w	#$0A00,d5

	asr.l	#7,d5
	add.w	Twist.PART_OMEGA(a0),d5
	andi.w	#SINTABLE_LEN-1,d5
	add.w	d5,d5
	add.w	d5,d5
	movem.w	(a1,d5.w),d0-d1
	asr.w	#8-4,d0
	addi.w	#160<<4,d0
	move.w	d0,Twist.PART_XPOS(a0)
	move.w	d1,Twist.PART_ZPOS(a0)

; calc y position..
	add.w	#$0A00>>7,Twist.PART_YPOS(a0)
	cmpi.w	#200<<4,Twist.PART_YPOS(a0)
	blt.s	.next
.kill:	move.w	#0,Twist.PART_STATE(a0)

.next:	lea	Twist.PART_SIZE(a0),a0
	dbf	d7,.loop

	addq.w	#1,d6
	move.w	d6,Twist.spin_time
	rts

Twist.update_bouncing_particles:
	bsr	getTime
	sub.w	Twist.spawn_start_time,d0
	cmpi.w	#120,d0
	bge.s	.do
	rts

.do:	lea	Twist.part_table,a0
	lea	Twist.edge_table,a1
	moveq	#Twist.NUM_PARTICLES-1,d7

.loop:	tst.w	Twist.PART_STATE(a0)
	beq.s	.next
	move.w	Twist.PART_XPOS(a0),d0
	move.w	Twist.PART_YPOS(a0),d1
	add.w	Twist.PART_XSPEED(a0),d0
	add.w	Twist.PART_YSPEED(a0),d1

; culling = killing
	move.w	d0,d2
	move.w	d1,d3
	asr.w	#4,d2
	asr.w	#4,d3
	cmpi.w	#-16,d2
	ble.s	.kill
	cmpi.w	#320,d2
	bge.s	.kill
	cmpi.w	#-16,d3
	ble.s	.kill
	cmpi.w	#200,d3
	bge.s	.kill

	tst.w	Twist.PART_STATE(a0)
	bmi.s	.end_collision

; collision detection and handling..
	move.w	d0,d2
	asr.w	#4,d2
	move.w	d1,d3
	asr.w	#4,d3
	move.b	(a1,d3.w),d3
	ext.w	d3
	cmp.w	d3,d2
	bge.s	.end_collision
	neg.w	Twist.PART_XSPEED(a0)
	move.w	#-1,Twist.PART_STATE(a0)	; -1: bounced
; todo: (x,y) position could also be affected.. dampening could be taken
; into account.. and also slope and speed of the twister..
.end_collision:

	move.w	d0,Twist.PART_XPOS(a0)
	move.w	d1,Twist.PART_YPOS(a0)
.next:	lea	Twist.PART_SIZE(a0),a0
	dbf	d7,.loop
	rts

.kill:	move.w	#0,Twist.PART_STATE(a0)
	bra.s	.next

Twist.paint_particles:
	moveq	#Twist.NUM_PARTICLES-1,d7
	movea.l	Twist.slab_table_adr,a6
	lea	Twist.part_table,a5
	lea	Twist.putpix_masks,a2
	movea.l	scr,a0
	lea	Twist.scan_table,a1

.loop:	tst.w	Twist.PART_STATE(a5)
	bne.s	.do_it
	move.w	#0,Sprite.SLAB_STATE(a6)
	bra.s	.next

.do_it:
;	tst.w	Twist.PART_ZPOS(a5)
;	bmi.s	.next

	move.w	Twist.PART_XPOS(a5),d0
	move.w	Twist.PART_YPOS(a5),d1
	asr.w	#4,d0
	asr.w	#4,d1

	ifne	1

	move.w	#1,Sprite.SLAB_STATE(a6)
;	subq.w	#8,d0
;	subi.w	#16,d1
;	lea	Twist.shifted_sprite,a3
;	lea	Twist.shifted_mask,a2
	move.w	Twist.PART_CHAR(a5),d2
	add.w	d2,d2
	add.w	d2,d2
	lea	Twist.char_adr_table,a3
	movea.l	(a3,d2.w),a3
	lea	Twist.SHIFTSPRITE_SIZE*16(a3),a2
	move.l	a6,-(sp)
	bsr	Sprite.paint
	movea.l	(sp)+,a6

	else

	mulu.w	#160,d1
	move.w	d0,d2
	andi.w	#$000F,d2
	sub.w	d2,d0
	lsr.w	d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a2,d2.w),d2
	or.w	d2,(a0,d1.w)

	endc

.next:	lea	Twist.PART_SIZE(a5),a5
	lea	Sprite.SLAB_SIZE(a6),a6
	dbf	d7,.loop
	rts

Twist.paint_front_particles:
	moveq	#Twist.NUM_PARTICLES-1,d7
	movea.l	Twist.slab_table_adr,a6
	lea	Twist.part_table,a5
	lea	Twist.putpix_masks,a2
	movea.l	scr,a0
	lea	Twist.scan_table,a1

.loop:	tst.w	Twist.PART_STATE(a5)
	bne.s	.do_it
	move.w	#0,Sprite.SLAB_STATE(a6)
	bra.s	.next

.do_it:	tst.w	Twist.PART_ZPOS(a5)
	bmi.s	.next

	move.w	Twist.PART_XPOS(a5),d0
	move.w	Twist.PART_YPOS(a5),d1
	asr.w	#4,d0
	asr.w	#4,d1

	ifne	1

	move.w	#1,Sprite.SLAB_STATE(a6)
;	subq.w	#8,d0
;	subi.w	#16,d1
;	lea	Twist.shifted_sprite,a3
;	lea	Twist.shifted_mask,a2
	move.w	Twist.PART_CHAR(a5),d2
	add.w	d2,d2
	add.w	d2,d2
	lea	Twist.char_adr_table,a3
	movea.l	(a3,d2.w),a3
	lea	Twist.SHIFTSPRITE_SIZE*16(a3),a2
	move.l	a6,-(sp)
	bsr	Sprite.paint
	movea.l	(sp)+,a6

	else

	mulu.w	#160,d1
	move.w	d0,d2
	andi.w	#$000F,d2
	sub.w	d2,d0
	lsr.w	d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a2,d2.w),d2
	or.w	d2,(a0,d1.w)

	endc

.next:	lea	Twist.PART_SIZE(a5),a5
	lea	Sprite.SLAB_SIZE(a6),a6
	dbf	d7,.loop
	rts

Twist.paint_back_particles:
	moveq	#Twist.NUM_PARTICLES-1,d7
	movea.l	Twist.slab_table_adr,a6
	lea	Twist.part_table,a5
	lea	Twist.putpix_masks,a2
	movea.l	scr,a0
	lea	Twist.scan_table,a1

.loop:	tst.w	Twist.PART_STATE(a5)
	bne.s	.do_it
	move.w	#0,Sprite.SLAB_STATE(a6)
	bra.s	.next

.do_it:	tst.w	Twist.PART_ZPOS(a5)
	bpl.s	.next

	move.w	Twist.PART_XPOS(a5),d0
	move.w	Twist.PART_YPOS(a5),d1
	asr.w	#4,d0
	asr.w	#4,d1

	ifne	1

	move.w	#1,Sprite.SLAB_STATE(a6)
;	subq.w	#8,d0
;	subi.w	#16,d1
;	lea	Twist.shifted_sprite,a3
;	lea	Twist.shifted_mask,a2
	move.w	Twist.PART_CHAR(a5),d2
	add.w	d2,d2
	add.w	d2,d2
	lea	Twist.char_adr_table,a3
	movea.l	(a3,d2.w),a3
	lea	Twist.SHIFTSPRITE_SIZE*16(a3),a2
	move.l	a6,-(sp)
	bsr	Sprite.paint
	movea.l	(sp)+,a6

	else

	mulu.w	#160,d1
	move.w	d0,d2
	andi.w	#$000F,d2
	sub.w	d2,d0
	lsr.w	d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a2,d2.w),d2
	or.w	d2,(a0,d1.w)

	endc

.next:	lea	Twist.PART_SIZE(a5),a5
	lea	Sprite.SLAB_SIZE(a6),a6
	dbf	d7,.loop
	rts


Twist.putpix_masks:
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

Twist.init_pal:
;	move.w	#$0222,$FFFF8240.w		;00
;	move.w	#$0257,$FFFF8242.w		;01
;	move.w	#$0636,$FFFF8244.w		;10
;	move.w	#$0636,$FFFF8246.w
	movem.l	Twist.pic+2,d0-d7
	movem.l	d0-d7,$FFFF8240.w
	move.w	#$0101,$FFFF8240.w
	rts

Twist.clear_span_anim:
	lea	Twist.anim_buf+Twist.ANIM_BUF_SIZE,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	moveq	#Twist.ANIM_BUF_SIZE/128-1,d7
.loop:	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	dbf	d7,.loop
	rts

Twist.precalc_span_anim:
	lea	Twist.anim_buf,a0
	lea	Lib3D.left_offsetmask_table,a1
	lea	sine_tbl,a2
	lea	Lib3D.right_offsetmask_table,a3
	lea	Twist.right_table,a4
	moveq	#$FFFFFFFF,d4
	moveq	#0,d7
.loop:
; calculate first corner..
	move.w	d7,d0
	subi.w	#(SINTABLE_LEN*5)/8,d0
	andi.w	#SINTABLE_LEN-1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	addi.w	#$8000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0

; calculate second corner..
	move.w	d7,d1
	subi.w	#(SINTABLE_LEN*3)/8,d1
	andi.w	#SINTABLE_LEN-1,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	(a2,d1.w),d1
	addi.w	#$8000,d1
	lsr.w	#8,d1
	lsr.w	#1,d1

; calculate third corner..
	move.w	d7,d2
	subi.w	#SINTABLE_LEN/8,d2
	andi.w	#SINTABLE_LEN-1,d2
	add.w	d2,d2
	add.w	d2,d2
	move.w	(a2,d2.w),d2
	addi.w	#$8000,d2
	lsr.w	#8,d2
	lsr.w	#1,d2

; calculate fourth corner..
	move.w	d7,d3
	addi.w	#SINTABLE_LEN/8,d3
	andi.w	#SINTABLE_LEN-1,d3
	add.w	d3,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d3
	addi.w	#$8000,d3
	lsr.w	#8,d3
	lsr.w	#1,d3

; calculate and paint visible segments..
	move.w	d0,d5
	move.w	d1,d6
	bsr.s	Twist.hline

	addq	#2,a0
	move.w	d1,d5
	move.w	d2,d6
	bsr.s	Twist.hline

	subq	#2,a0
	move.w	d2,d5
	move.w	d3,d6
	bsr.s	Twist.hline

	addq	#2,a0
	move.w	d3,d5
	move.w	d0,d6
	bsr.s	Twist.hline

; find rightmost vertex..
	cmp.w	d0,d1
	bge.s	.swap1done
	exg	d0,d1
.swap1done:
	cmp.w	d1,d2
	bge.s	.swap2done
	exg	d1,d2
.swap2done:
	cmp.w	d2,d3
	bge.s	.swap3done
	exg	d2,d3
.swap3done:
	move.b	d3,(a4)+			; store rightmost position!

	lea	Twist.SPAN_SIZE-2(a0),a0
	addi.w	#(SINTABLE_LEN)/Twist.NUM_SPANS,d7
	cmpi.w	#(SINTABLE_LEN),d7
	blt	.loop
	rts

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d4.w=$FFFF
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left offset and mask table
; a1: right offset and mask table
Twist.hline:
	cmp.w	d5,d6
	ble.s	.end
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a1,d5.w),d5		; d5.l=(lmask<<16)|l_off
	add.w	d6,d6
	add.w	d6,d6
	move.l	(a3,d6.w),d6		; d6.l=(rmask<<16)|r_off
	sub.w	d5,d6			; d6.w=r_off-l_off
	bne.s	.multi_chunk

.single_chunk:
	and.l	d5,d6			; d6.l=((lmask&rmask)<<16) | garbage.w
	swap	d6			; d6.l=(garbage.w<<16) | (lmask&rmask)
	or.w	d6,(a0,d5.w)		; write it.
.end:	rts

.multi_chunk:
	lea	(a0,d5.w),a6		; a6: start of scan + l_off
	swap	d5			; d5.w=l_mask
	or.w	d5,(a6)			; write l_mask.
	move.w	d6,d5			; d5.w=r_off-l_off
	swap	d6			; d6.w=r_mask
	or.w	d6,(a6,d5.w)		; write r_mask. a6+d5.w=a0+r_off-l_off_r_off=a0+r_off
	neg.w	d5
	asr.w	#1,d5
	jmp	.jump_end+4(pc,d5.w)
offset	set	160
	rept	20
	move.w	d4,offset(a6)
offset	set	offset-8
	endr
.jump_end:
	rts

Twist.extract_font:
	lea	Twist.font_index_table,a1
	lea	Twist.char_adr_table,a0
	lea	Twist.sprite_buf,a2
	moveq	#128-1,d7
	
.loop:	move.w	(a1)+,d0
	bpl.s	.ok
	move.l	#0,(a0)+
	bra.s	.next

.ok:	move.l	a2,(a0)+

	movem.l	d7-a2,-(sp)

	lea	Twist.pic+160*32+34,a1
	adda.w	d0,a1
	movea.l	a2,a0
	move.l	a0,-(sp)
	moveq	#16,d7
	move.w	#Twist.SHIFTSPRITE_SIZE,d4
	bsr	Sprite.preshift_16pix
	movea.l	(sp),a1
	lea	Twist.SHIFTSPRITE_SIZE*16(a1),a0
	moveq	#16,d7
; take a0 from previous subroutine (end of sprite = start of mask)
	bsr	Sprite.extract_16pix_mask
	move.l	(sp)+,d0
	addi.l	#(Twist.SHIFTSPRITE_SIZE*16*3)/2,d0
; d0.l=end of mask = start of next sprite

	movem.l	(sp)+,d7-a2
	movea.l	d0,a2
; a2: start of next sprite

.next:	dbf	d7,.loop
	rts

Twist.paint_left:
	bsr	Twist.paint
	bsr	Twist.paint_particles
	rts

Twist.paint_center:
	bsr	Twist.paint_back_particles
	bsr	Twist.paint
	bsr	Twist.paint_front_particles
	rts

Twist.paint:
	movea.l	scr,a0
	adda.w	Twist.screen_offset,a0
	lea	Twist.anim_buf,a1
	lea	Twist.offsets,a2

	move.w	Twist.num_rows,d7
	ble.s	.end_filling
	subq.w	#1,d7
;	move.w	#200-1,d7

.yloop:	move.w	(a2)+,d1		; d1.w=offset to anim frame
	lea	(a1,d1.w),a3		; a3: anim frame
; copy span to screen..
	movem.l	(a3),d1-d6/a4-a5
	movem.l	d1-d6/a4-a5,(a0)
	movem.l	32(a3),d1-d6/a4-a5
	movem.l	d1-d6/a4-a5,32(a0)
	lea	160(a0),a0		; a0: scanline[n+1]
	dbf	d7,.yloop
.end_filling:
.start_killing:
; kill last rows when wiping out..
	cmpi.w	#200,Twist.num_rows
	beq.s	.end
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)

	cmpi.w	#198,Twist.num_rows
	beq.s	.end
	movem.l	d0-d7,320(a0)
	movem.l	d0-d7,320+32(a0)
	movem.l	d0-d7,480(a0)
	movem.l	d0-d7,480+32(a0)

.end:	rts

Twist.clear_right:
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
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	movea.l	scr,a0
off	set	64
	rept	200
	movem.l	d0-d6/a1-a6,off(a0)
	movem.l	d0-d6/a1-a4,off+13*4(a0)
off	set	off+160
	endr
	rts

;- data section ------------------------------------------------------------

	data

off	set	-160*16
	rept	16
	dc.w	off
off	set	off+160
	endr
Twist.scan_table:
	rept	200
	dc.w	off
off	set	off+160
	endr

	ifeq	Twist.DYNAMIC_PI1
Twist.pic:
;	incbin	dessert.pi1
;	incbin	gfx/font.pi1
;	incbin	twist4.pi1
	incbin	twist5.pi1
;	incbin	twist3.pi1
;	incbin	twist.pi1
	endc

Twist.pic_name:
;	dc.b	"gfx/font.pi1",0
;	dc.b	"twist.pi1",0
;	dc.b	"twist3.pi1",0
;	dc.b	"twist4.pi1",0
	dc.b	"twist5.pi1",0
	even

Twist.font_index_table:
; low ascii bs..

;	dcb.w	48,-1
	dcb.w	43,-1
	dc.w	160*16+152			; '+'
	dcb.w	4,-1	

; numerals..
off	set	160*16+6*8
	rept	10
	dc.w	off
off	set	off+8
	endr
	dcb.w	6,-1
; @
	dc.w	160*32
; upper case..
off	set	0
	rept	20
	dc.w	off
off	set	off+8
	endr
off	set	160*16
	rept	6
	dc.w	off
off	set	off+8
	endr
	dcb.w	6,-1
; lower case..
off	set	0
	rept	20
	dc.w	off
off	set	off+8
	endr
off	set	160*16
	rept	6
	dc.w	off
off	set	off+8
	endr
	dcb.w	5,-1

Twist.slab_table_adr:
	dc.l	Twist.slab_table,Twist.slab_table2

Twist.part_update_rout:
	dc.l	Twist.update_bouncing_particles

Twist.paint_rout:
	dc.l	Twist.paint_left

Twist.wipe_rout:
	dc.l	dummy

;- bss section -------------------------------------------------------------

	bss

Twist.anim_buf:=	Lib3D.end_of_bss
;	ds.b	Twist.ANIM_BUF_SIZE
Twist.right_table:=	(Twist.anim_buf+Twist.ANIM_BUF_SIZE)
;	ds.b	Twist.NUM_SPANS
Twist.sprite_buf:=	(Twist.right_table+Twist.NUM_SPANS)
;	ds.b	64*((Twist.SHIFTSPRITE_SIZE*16)*3)/2

Twist.part_table:
	ds.b	Twist.PART_SIZE*Twist.NUM_PARTICLES

Twist.edge_table:
	ds.b	200
Twist.offsets:
	ds.w	200
Twist.cos_table:
	ds.b	200

Twist.shifted_sprite:
	ds.b	Twist.SHIFTSPRITE_SIZE*16

Twist.shifted_mask:
	ds.b	Twist.SHIFTSPRITE_SIZE*16/2

Twist.char_adr_table:
	ds.l	128

Twist.slab_table:
	ds.b	Twist.NUM_PARTICLES*Sprite.SLAB_SIZE
Twist.slab_table2:
	ds.b	Twist.NUM_PARTICLES*Sprite.SLAB_SIZE

	ifne	Twist.DYNAMIC_PI1
Twist.pic:
	ds.b	32034
	endc

Twist.screen_offset:
	ds.w	1

Twist.start_frmcnt:
	ds.l	1

Twist.spin_time:
	ds.w	1

Twist.y_start:
	ds.w	1

Twist.spawn_start_time:
	ds.w	1

Twist.num_rows:
	ds.w	1

Twist.whitefade_table:
	ds.w	16*16
Twist.blackfade_table:
	ds.w	16*16
Twist.bluefade_table:
	ds.w	16*16

Twist.fade_start_time:
	ds.l	1
Twist.fade_steps_left:
	ds.w	1
Twist.fade_table_addr:
	ds.l	1

