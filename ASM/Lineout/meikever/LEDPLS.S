; plasma / led scroller combination
; todo: special kind of fader.. (black->brown, low colours first)

; load from disk at init (1) or incbin (0)
	ifnd	DEMO_SYSTEM
Led.DYNAMIC_PI1:=	0 1
	else
; always 0 when included in demo system
Led.DYNAMIC_PI1:=	0
	endc

Led.NR_VBLS:=		3			; minimum amount of VBLs to take
Led.MEASURE_CPU:=	0			; raster cpu measurement
Led.MAX_Y:=		200			; amount of physical scanlines read by the video chip

Led.SPRITE_SCANS:=	32
Led.SPRITESCAN_CHUNKS:=	2
Led.SHIFTSCAN_SIZE:=	((Led.SPRITESCAN_CHUNKS+1)*8)
Led.SHIFTSPRITE_SIZE:=	(Led.SHIFTSCAN_SIZE*Led.SPRITE_SCANS)

Led.CENTER:=		1			; start with the bee in the center y/n (1/0)

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	bra	end_libs
	include	common.s
	include	sprite.s
	text
end_libs:
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Led.mainloop			; 0
	dc.l	Led.init			; 1
	dc.l	Led.rt_init			; 2
	dc.l	Led.deinit			; 3
	dc.l	Led.trigger_fade_in		; 4
	dc.l	Led.trigger_fade_out		; 5
	dc.l	Led.switch_overlay		; 6
	dc.l	Led.switch_rot_direction	; 7
	dc.l	Led.inc_rot_speed		; 8
	dc.l	Led.dec_rot_speed		; 9
	dc.l	Led.trigger_movement		;10
	dc.l	Led.trigger_downward_spiral	;11
	dc.l	Led.switch_overlay_back		;12
	dc.l	Led.trigger_upward_spiral	;13
	dc.l	0

;- plugin routines ---------------------------------------------------------

Led.init:
	;move.w	#$0FFF,$FFFF8240.w

	ifne	Led.DYNAMIC_PI1

; fopen
	clr.w	-(sp)
	pea	Led.pic_name
	move.w	#$3D,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bpl.s	.not_out
	jmp	OUT
.not_out:
	move.w	d0,.handle

	pea	Led.pic
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
Led.rt_init:
	ifne	0

; extract sprite data..
	lea	Led.sprite,a0
	lea	Led.pic+34,a1
	moveq	#32-1,d7
.sprloop:
	rept	4
	move.l	(a1)+,(a0)+
	endr
	lea	160-16(a1),a1
	dbf	d7,.sprloop

	endc

	ifne	0

	lea	Led.pic+34,a1
	lea	12*160+144(a1),a1
	lea	Led.meikever_gfx,a0
	move.w	#144-1,d7
.meiloop:
	rept	4
	move.l	(a1)+,(a0)+
	endr
	lea	160-16(a1),a1
	dbf	d7,.meiloop

	endc

	ifne	0

	lea	Led.pic+34,a1
	lea	Led.junebug_gfx,a0
	lea	170*160+64(a1),a1
	moveq	#30-1,d7
.juneloop:
	rept	24
	move.l	(a1)+,(a0)+
	endr
	lea	160-96(a1),a1
	dbf	d7,.juneloop

	endc

	bsr	Led.calc_fadepals

	bsr	Led.init_wave_table

	lea	Led.sprite,a0
	moveq	#32,d7
	move.w	#Led.SHIFTSPRITE_SIZE,d4

	ifne	Led.DYNAMIC_PI1
	lea	Led.pic+34,a1
	jsr	Sprite.preshift_32pix
	else
	lea	Led.bigbee_gfx,a1
	moveq	#0,d2
	jsr	Sprite.preshift_32pix_stride
	endc

	lea	Led.mask,a0
	lea	Led.sprite,a1
	moveq	#32,d7
	jsr	Sprite.extract_32pix_mask

	clr.w	Led.measured_vbls
	move.w	$0468.w,Led.old_468
	rts

Led.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Led.mainloop:

	ifne	1

	ifne	Led.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	;bge.s	.end_clear
	;bsr	Led.clear_banner
.end_clear:

	ifne	Led.MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	;movea.l	scr,a0
	;bsr	CLEAR_STSCREEN
	;bsr	Led.paint_test

	movea.l	Led.geom_rout,a0
	jsr	(a0)

	movea.l	Led.paint_rout,a0
	jsr	(a0)

	tst.w	Led.text_enabled
	beq.s	.end_overlay
	bsr	Led.paint_overlay
.end_overlay:

; paint sprite
	tst.w	Led.bug_enabled
	beq	.end_bug

	tst.w	Led.spiral_enabled
	beq.s	.end_spiral
	bpl.s	.upward_spiral
	move.w	Led.bug_circle_amp,d0
	subq.w	#2,d0
	bmi.s	.end_spiral
	move.w	d0,Led.bug_circle_amp
	bra.s	.end_spiral
.upward_spiral:
	move.w	Led.bug_circle_amp,d0
	addq.w	#2,d0
	cmpi.w	#64,d0
	bgt.s	.end_spiral
	move.w	d0,Led.bug_circle_amp
.end_spiral:

	jsr	getTime
	tst.w	Led.bug_pos_speed
	beq.s	.dont_move
	sub.l	Led.movement_start_time,d0
	divu.w	#12,d0
	move.w	d0,Led.bug_pos_progress

.dont_move:
	moveq	#0,d0
	move.w	Led.bug_rot_progress,d0
	moveq	#0,d3
	move.w	Led.bug_pos_progress,d3
	lsl.l	#6,d0
	andi.w	#SINTABLE_LEN-1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d2
	lea	sine_tbl,a0

	ifne	1
	movem.w	(a0,d2.w),d0-d1
	muls.w	Led.bug_circle_amp,d0
	muls.w	Led.bug_circle_amp,d1
	swap	d0
	swap	d1
	else
	move.b	(a0,d2.w),d0
	ext.w	d0
	move.b	2(a0,d2.w),d1
	ext.w	d1
	asr.w	#2,d0
	asr.w	#2,d1
	endc

	ifne	Led.CENTER
	addi.w	#160-16,d0
	addi.w	#100-16,d1
	else
	addi.w	#67,d0
	addi.w	#34,d1
	add.w	d3,d3
	endc

	move.w	d3,d4
	mulu.w	#3,d4
	asr.l	#2,d4
	mulu.w	#5,d3
	asr.l	#2,d3

	add.w	d3,d0
	add.w	d4,d1
	movea.l	scr,a0
	lea	Led.scan_table,a1
	lea	Led.mask,a2
	lea	Led.sprite,a3
	lea	.trash(pc),a6
	jsr	Sprite.paint_3232

	move.w	Led.bug_rot_speed,d0
	add.w	d0,Led.bug_rot_progress
;	move.w	Led.bug_pos_speed,d0
;	add.w	d0,Led.bug_pos_progress
.end_bug:

	ifne	Led.MEASURE_CPU
	movea.l	scr,a0
	move.w	Led.measured_vbls,d0
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

	ifne	Led.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#Led.init_pal,palirq
.end_pal:

	endc

; wait for vbl..
	move.w	Led.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Led.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Led.old_468
	move.w	d1,Led.measured_vbls

	rts

.trash:	ds.b	Sprite.SLAB_SIZE

Led.measured_vbls:
	ds.w	1

Led.old4ba:
	ds.l	1
Led.old_468:
	ds.w	1


;--------------------------------------------------------------------------

Led.trigger_fade_in:
	jsr	getTime
	move.w	#0,Led.fade_inout_direction
	move.l	d0,Led.fade_start_time
	move.w	#+255,Led.fade_steps_left
	move.l	#Led.blackfade_table,Led.fade_table_addr
	move.l	#Led.perform_fade_step,palirq
	rts

Led.trigger_fade_out:
	jsr	getTime
	move.w	#1,Led.fade_inout_direction
	move.l	d0,Led.fade_start_time
	move.w	#+255,Led.fade_steps_left
	move.l	#Led.bluefade_table,Led.fade_table_addr
	move.l	#Led.perform_fade_step,palirq
	rts

Led.switch_overlay:
	not.w	Led.text_enabled
	clr.w	Led.bug_enabled
	move.l	#Led.flash,palirq
	rts

Led.switch_overlay_back:
	not.w	Led.text_enabled
	clr.w	Led.bug_enabled
	move.l	#Led.flash_back,palirq
	rts

Led.switch_rot_direction:
	neg.w	Led.bug_rot_speed
	rts

Led.inc_rot_speed:
	addq.w	#1,Led.bug_rot_speed
	rts

Led.dec_rot_speed:
	subq.w	#1,Led.bug_rot_speed
	rts

Led.trigger_movement:
	jsr	getTime

; not required in this case, i think..
; save current position.
;	move.l	d0,d1
;	sub.l	Led.movement_start_time,d1
;	move.w	d1,Led.bug_pos_progress

	move.l	d0,Led.movement_start_time

	move.w	Led.bug_pos_speed,d0
	beq.s	.set
	moveq	#0,d0
	bra.s	.end
.set:	moveq	#1,d0
.end:	move.w	d0,Led.bug_pos_speed
	rts

Led.trigger_downward_spiral
	move.w	#-1,Led.spiral_enabled
	rts

Led.trigger_upward_spiral
	move.w	#+1,Led.spiral_enabled
	rts

;--------------------------------------------------------------------------

Led.flash:
	lea	$FFFF8240.w,a0
	rept	8
	not.l	(a0)+
	endr
	move.w	#5,Led.flash_count
	move.w	#3,Led.frames_to_wait
	move.l	#Led.wait_frames,palirq
	rts

Led.flash_back:
	lea	$FFFF8240.w,a0
	rept	8
	not.l	(a0)+
	endr
	move.w	#6,Led.flash_count
	move.w	#3,Led.frames_to_wait
	move.l	#Led.wait_frames,palirq
	rts

Led.init_wave_table:
	lea	Led.wave_table,a0
	moveq	#4-1,d7

.period_loop:
	lea	sine_tbl,a1
	move.w	#SINTABLE_LEN-1,d6

.sample_loop:
	move.w	(a1),d0
	asr.w	#8,d0
	addi.b	#128,d0
	;mulu.w	#$000F,d0
	;lsr.l	#4,d0
	move.b	d0,(a0)+
	addq	#4,a1
	dbf	d6,.sample_loop

	dbf	d7,.period_loop
	rts

Led.init_pal:
	lea	$FFFF8240.w,a0

	moveq	#0,d0
	rept	8
	move.l	d0,(a0)+
	endr
	rts

Led.wait_frames:
	subq.w	#1,Led.frames_to_wait
	bgt.s	.end
;	move.l	#Led.init_pal2,palirq

	lea	$FFFF8240.w,a0
	rept	8
	not.l	(a0)+
	endr

	move.w	#3,Led.frames_to_wait
	subq.w	#1,Led.flash_count
	bgt.s	.end
	move.l	#dummy,palirq
.end:	rts

Led.frames_to_wait:
	ds.w	1

Led.init_pal2:
	lea	$FFFF8240.w,a0
	movem.l	Led.pic+2,d0-d7
	movem.l	d0-d7,(a0)
	move.l	#dummy,palirq
	rts

Led.perform_fade_step:
	moveq	#-1,d2			; d2.w=increment
	move.w	Led.fade_steps_left,d1
	move.w	d1,d4			; d4.w=backup fade steps
	beq.s	.stop
	bpl.s	.fade_index_ok
	neg.w	d2
	addi.w	#256,d1
.fade_index_ok:
	lsl.w	#1,d1
	andi.w	#$FFE0,d1
	movea.l	Led.fade_table_addr,a0

.all:	movem.l	(a0,d1.w),d0-d1/d3/d5-d7/a2-a3
; all
	movem.l	d0-d1/d3/d5-d7/a2-a3,$FFFF8240.w
	tst.w	Led.fade_inout_direction
	bne.s	.pal_is_set

; all but 0 and 15
	move.w	Led.pic+4,$FFFF8242.w
	move.w	Led.pic+32,$FFFF825E.w
.pal_is_set:

	move.l	Led.fade_start_time,d0
	add.w	d2,d4
	move.w	d4,Led.fade_steps_left
	rts
.stop:	move.l	#dummy,palirq
	rts

Led.calc_fadepals:
; split palette up into 24bit
	lea	Led.org_palette,a1
	lea	Led.tmp_pal(pc),a0
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
	lea	Led.whitefade_table,a0
	moveq	#16-1,d7

.loop:
; calc greylevel (faded white)
	moveq	#16,d5
	sub.w	d7,d5
	lsl.w	#4,d5
	subq.w	#1,d5

	lea	Led.tmp_pal(pc),a1
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
	lea	Led.blackfade_table,a0
	moveq	#16-1,d7
.lowloop:
	lea	Led.tmp_pal(pc),a1
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
	lea	Led.bluefade_table,a0
	moveq	#16-1,d7
	movea.w	#11,a3			; a3= dst red level
	movea.w	#13,a4			; a4= dst green level
	movea.w	#15,a5			; a5= dst blue level

.bloop:	lea	Led.tmp_pal(pc),a1
	moveq	#16-1,d6

.bentryloop:
	clr.l	d3
	clr.l	d4
	clr.l	d5
	move.b	(a1)+,d3		; d3.w=r
	move.b	(a1)+,d4		; d4.w=g
	move.b	(a1)+,d5		; d5.w=b

; ...not!
	not.b	d3
	not.b	d4
	not.b	d5
	andi.w	#$F,d3
	andi.w	#$F,d4
	andi.w	#$F,d5

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

Led.tmp_pal:
	ds.b	3*16

Led.make_blockcircles:
	movea.l	scr,a1
	movea.l	a1,a0
	moveq	#200/8-1,d7

.octiply_loop:
	move.l	Led.circle+4,d6
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

	move.l	Led.circle+8,d6
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

	move.l	Led.circle+12,d6
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

	move.l	Led.circle,d6
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

Led.render_plasma:
	lea	Led.wave_table+SINTABLE_LEN,a1
	lea	Led.chunky_buf,a0
	lea	sine_tbl,a5
	move.w	frmcnt+2,d0
	lsl.w	#4,d0
	andi.w	#SINTABLE_LEN-1,d0
	add.w	d0,d0
	add.w	d0,d0
	movem.w	(a5,d0.w),d3-d4
	asr.w	#5,d3
	asr.w	#5,d4
	move.w	#SINTABLE_LEN-1,d0
	moveq	#Led.MAX_Y/8-1,d7
	moveq	#0,d1
	moveq	#0,d2

.yloop:	andi.w	#SINTABLE_LEN-1,d3
	move.w	d3,d5
	add.w	d5,d5
	add.w	d5,d5
	move.w	(a5,d5.w),d5
	addi.w	#$8000,d5
	lsr.w	#5,d5
	lea	(a1,d5.w),a2

	andi.w	#SINTABLE_LEN-1,d4
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	move.w	2(a5,d5.w),d5
	addi.w	#$8000,d5
	lsr.w	#5,d5
	lea	(a1,d5.w),a4

	moveq	#$F<<2,d5
	moveq	#320/8-1,d6

; uses range of 14 instead of 16 to allow for fading back/foreground
; separately
; todo: optimise this with a small lut..
.xloop:	move.b	(a2),d1
	move.b	(a4),d2
	add.w	d1,d2
	lsr.w	#3,d2

	subq.w	#8,d2
	bpl.s	.ok
	moveq	#0,d2
.ok:	addq.w	#4,d2

	and.w	d5,d2
	move.b	d2,(a0)+
	lea	21(a2),a2
	lea	27(a4),a4
	dbf	d6,.xloop

	addi.w	#17,d3
	addi.w	#15,d4
	dbf	d7,.yloop
	rts

Led.paint:
	moveq	#0,d6
	movea.l	scr,a0
	lea	Led.chunky_buf,a1
	lea	Led.chunky_table,a2
	move.w	#Led.MAX_Y/8-1,d7
	move.l	Led.circle+00,d2
	move.l	Led.circle+04,d3
; todo: cam be optimised, cos these two masks are the same..
	move.l	Led.circle+08,d4
	move.l	Led.circle+12,d5

.yloop:

offset	set	0

	rept	20

	move.b	(a1)+,d6
	move.l	(a2,d6.w),d0

	move.l	d0,d1
	and.l	d2,d1
	movep.l	d1,0*160+offset(a0)
	movep.l	d1,7*160+offset(a0)

	move.l	d0,d1
	and.l	d3,d1
	movep.l	d1,1*160+offset(a0)
	movep.l	d1,6*160+offset(a0)

	move.l	d0,d1
	and.l	d4,d1
	movep.l	d1,2*160+offset(a0)
	movep.l	d1,5*160+offset(a0)

	and.l	d5,d0
	movep.l	d0,3*160+offset(a0)
	movep.l	d0,4*160+offset(a0)

	move.b	(a1)+,d6
	move.l	(a2,d6.w),d0

offset	set 	offset+1

	move.l	d0,d1
	and.l	d2,d1
	movep.l	d1,0*160+offset(a0)
	movep.l	d1,7*160+offset(a0)

	move.l	d0,d1
	and.l	d3,d1
	movep.l	d1,1*160+offset(a0)
	movep.l	d1,6*160+offset(a0)

	move.l	d0,d1
	and.l	d4,d1
	movep.l	d1,2*160+offset(a0)
	movep.l	d1,5*160+offset(a0)

	and.l	d5,d0
	movep.l	d0,3*160+offset(a0)
	movep.l	d0,4*160+offset(a0)

offset	set 	offset+7

	endr

	lea	160*8(a0),a0

	dbf	d7,.yloop
	rts

	ifne	Led.DYNAMIC_PI1

Led.paint_overlay:
	ifne	1

	movea.l	scr,a0
	lea	Led.pic+34,a1
	lea	12*160+144(a0),a0
	lea	12*160+144(a1),a1

; meikever part
	move.w	#144-1,d7
.meiloop:
	rept	2
	movem.l	(a1)+,d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0)+,d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,-8(a0)
	endr

	lea	160-16(a1),a1
	lea	160-16(a0),a0
	dbf	d7,.meiloop

	else

	movea.l	scr,a0
	lea	Led.pic+34,a1
	lea	20*160+152(a0),a0
	lea	20*160+152(a1),a1

; meikever part
	move.w	#140-1,d7
.meiloop:
	movem.l	(a1),d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0),d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,(a0)

	lea	160(a1),a1
	lea	160(a0),a0
	dbf	d7,.meiloop

	endc

	ifne	1

; june part
	movea.l	scr,a0
	lea	Led.pic+34,a1
	lea	170*160+64(a0),a0
	lea	170*160+64(a1),a1
	move.w	#30-1,d7
.juneloop:

	rept	12
	movem.l	(a1)+,d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0)+,d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,-8(a0)
	endr

	lea	160-96(a1),a1
	lea	160-96(a0),a0
	dbf	d7,.juneloop

	else

; june part
	movea.l	scr,a0
	lea	Led.pic+34,a1
	lea	170*160+80(a0),a0
	lea	170*160+80(a1),a1
	move.w	#30-1,d7
.juneloop:

	rept	10
	movem.l	(a1)+,d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0)+,d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,-8(a0)
	endr

	lea	160-80(a1),a1
	lea	160-80(a0),a0
	dbf	d7,.juneloop

	endc

	rts

	else

Led.paint_overlay:
	movea.l	scr,a0
	lea	Led.meikever_gfx,a1
	lea	12*160+144(a0),a0

; meikever part
	move.w	#144-1,d7
.meiloop:
	rept	2
	movem.l	(a1)+,d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0)+,d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,-8(a0)
	endr

	lea	160-16(a0),a0
	dbf	d7,.meiloop

; june part
	movea.l	scr,a0
	lea	Led.junebug_gfx,a1
	lea	170*160+64(a0),a0
	moveq	#30-1,d7

.juneloop:

	rept	12
	movem.l	(a1)+,d0-d1

; mask shit out
	move.l	d0,d2
	or.l	d1,d2
	move.w	d2,d3
	swap	d2
	or.w	d3,d2
	not.w	d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3

	movem.l	(a0)+,d4-d5
	and.l	d3,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4-d5,-8(a0)
	endr

	lea	160-96(a0),a0
	dbf	d7,.juneloop

	rts

	endc

Led.chunky_table:
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

;--------------------------------------------------------------------------

	data

Led.texture_pal:
	ifne	1
	dc.w	$0532,$0310,$0410,$0420,$0421,$0521,$0531,$0532
	dc.w	$0632,$0642,$0742,$0752,$0763,$0773,$0775,$0777
	endc
	ifne	0
	dc.w	$000,$888,$111,$999,$222,$AAA,$333,$BBB
	dc.w	$444,$CCC,$555,$DDD,$666,$EEE,$777,$FFF
	endc
	ifne	0
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	endc
	ifne	0
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111,$000
	endc
	even

Led.org_palette:=	Led.texture_pal

Led.geom_rout:
	dc.l	Led.render_plasma

Led.paint_rout:
	dc.l	Led.paint

Led.circle:
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

Led.pic_name:
	dc.b	"ledpls4.pi1",0
	even

	ifeq	Led.DYNAMIC_PI1
Led.pic:;incbin	ledpls3.pi1
	;incbin	ledpls4.pi1
	ds.w	1
	dc.w	$0421,$0100,$0200,$0300,$0310,$0410,$0420,$0520
	dc.w	$0630,$0640,$0740,$0751,$0762,$0773,$0775,$0777
	endc

off	set	-160*16
	rept	16
	dc.w	off
off	set	off+160
	endr
Led.scan_table:
	rept	200
	dc.w	off
off	set	off+160
	endr

Led.bug_rot_speed:
	dc.w	0 +1
Led.bug_enabled:
	dc.w	1
Led.bug_circle_amp:
	dc.w	0 64

Led.junebug_gfx:
	incbin	junebug.dat
Led.meikever_gfx:
	incbin	meikever.dat
Led.bigbee_gfx:
	incbin	bigbee.dat

;--------------------------------------------------------------------------

	bss

	ifne	Led.DYNAMIC_PI1
Led.pic:ds.b	32034
	endc

Led.whitefade_table:
	ds.w	16*16
Led.blackfade_table:
	ds.w	16*16
Led.bluefade_table:
	ds.w	16*16

Led.fade_start_time:
	ds.l	1
Led.fade_steps_left:
	ds.w	1
Led.fade_table_addr:
	ds.l	1

Led.text_enabled:
	ds.w	1

Led.chunky_buf:=		Common.block
;	ds.b	(320/8)*(Led.MAX_Y/8)
Led.wave_table:=		(Led.chunky_buf+(320/8)*12)
;	ds.b	SINTABLE_LEN*4
Led.mask:=	(Led.wave_table+SINTABLE_LEN*4)
;	ds.b	16*Led.SHIFTSPRITE_SIZE/2
Led.sprite:=	(Led.mask+16*Led.SHIFTSPRITE_SIZE/2)
;	ds.b	16*Led.SHIFTSPRITE_SIZE

; used to extract degas data.
; should be incbin data eventually..
;Led.junebug_gfx:
;	ds.w	48*30
;Led.meikever_gfx:
;	ds.w	8*144

Led.bug_rot_progress:
	ds.w	1
Led.bug_pos_progress:
	ds.w	1
Led.bug_pos_speed:
	ds.w	1
Led.spiral_enabled:
	ds.w	1

Led.flash_count:
	ds.w	1

Led.fade_inout_direction:
	ds.w	1

Led.movement_start_time:
	ds.l	1
