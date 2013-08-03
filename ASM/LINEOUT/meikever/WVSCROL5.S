; wavey dot scroller.. with national flags..
;
; 22-09-2007:
;
; 8x16 dot spacing version.. with wave..
; pause done.. wobble added when paused.
;
; 23-09-2007:
;
; attempt at 4 bitplane version..
;
; 25-09-2007:
;
; 4 (3 actually) bitplane version working with a test flag.. 
; needs:
; a) optimisation (clear dots instead of whole screen)
; b) horizontal clipping (seems like case coding, the lut can't help, since it's
;    relative, i guess..)
; c) flags need to be characters.. make a modified version of the flags picture
;    with the font in there..
; i'm too tired now. daily life is just a fucking hole.
;
; 27-09-2007:
;
; ditched paint_small, paint_dist can do everything now (hor and ver dist)
; scroll extended to 3 plane action..
;
; 28-09-2007:
;
; clearing of dots done
; todo: fix 3rd plane bug?? why isn't it properly cleared?
;
; 30-09-2007:
;
; crap.. i need to save positions of all sprites, not just the ones in the 
; first plane.. i'm now converting the bitbuffers to chunky format.
; converted.. making a decent pre-shifted sprite rout now. done..
; adjusting the clear code.. this can be really fast and is a little lame
; right now..
; 14:30: fuck, this is too slow, actually! trying to optimise but preparing
; for >1 vbl nastiness..
; 17:30: optimised the hell out of it. now vertical displacements will be
; per chunk (16 pixels) but i think that's ok.
; 22:00: the scroller is running, and can handle flag characters..
; 23:00: the chunk wave is in there.. but there is crap left on every odd
; frame?
; 24:00: fixed.. off to bed.
;
; 07-10-2007:
;
; changed font colour, included more flags..
;
; 12-01-2008:
;
; big clean up..
;
; 20-01-2008:
;
; introduced morphing of waves, a funny stop-and-go event for the flags,
; and incorporated these into a big event list. 
;
; 26-01-2008:
;
; added 'reservoir clogs' at the bottom ;)
; trying to preshift it.. dunno if it can fit within the still available
; cpu time.
; left-to-right movemement is done.. but it's, well, costly. need to get
; rid of that lame byte-by-byte copy.
; failed!! now just precalcing the whole buffer. lame, but it will work as
; a long init is possible (it's in a separate cracktro, no sync issues).
; alright! did it! nice and lame :) (and fast)
;

Scroll.NR_VBLS:=	1				; minimum amount of VBLs to take
Scroll.MEASURE_CPU:=	0				; raster cpu measurement
Scroll.MAX_Y:=		200				; amount of physical scanlines read by the video chip
Scroll.FRAME_HEIGHT:=	92				; in double scans
Scroll.NUM_DOTS:=	176 192 352 284			; number of dots before extrusion!
Scroll.EXTRUDE_FACTOR:=	5
Scroll.PERSPECTIVE:=	0
Scroll.MAX_NUM_DOTS:=	1000				; limit for dot buffers!
Scroll.MULTAB_MORPH:=	1				; alot faster..
Scroll.NEW_MULTAB:=	1				; [-176,+175] instead of [-128,+127] x range, a must for multable morph
Scroll.CHUNKY:=		1
Scroll.NUM_PLANES:=	3
Scroll.LLLLRRRR:=	1

Scroll.SPEED:=		7

Scroll.LOGO_SCANS:=	16
Scroll.LOGOSCAN_CHUNKS:=11
Scroll.SHIFTSCAN_SIZE:=	((Scroll.LOGOSCAN_CHUNKS+1)*8)
Scroll.SHIFTLOGO_SIZE:=	(Scroll.SHIFTSCAN_SIZE*Scroll.LOGO_SCANS)

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Scroll.mainloop			; 0
	dc.l	Scroll.init			; 1
	dc.l	Scroll.rt_init			; 2
	dc.l	Scroll.deinit			; 3
Scroll.event_rout_table:
	dc.l	Scroll.toggle_pause		; 4
	dc.l	Scroll.start_morph0		; 5
	dc.l	Scroll.start_morph1		; 6
	dc.l	Scroll.start_morph2		; 7
	dc.l	0

;- plugin routines ---------------------------------------------------------

Scroll.init:
	rts

; todo: in case of memory shortage, let all this stuff use temporary 
; buffers..
Scroll.rt_init:
	bsr	Scroll.precalc_scan_table
	bsr	Scroll.precalc_mix_table

	move.l	#Scroll.text,Scroll.text_adr
	move.l	#Scroll.event_list,Scroll.event_adr
	move.l	#Scroll.ver_offset_table_dummy,Scroll.end_verofftab_adr
	bsr	Scroll.init_wave0
	bsr	Scroll.init_wave1
	bsr	Scroll.init_wave2
	bsr	Scroll.init_plot_offsets
	bsr	Scroll.convert_to_chunky
	bsr	Scroll.preshift
	bsr	Scroll.preshift_logo

	bsr	Scroll.fill_chunkybuf

	move.l	#Scroll.dummy_hor_offset_table,Scroll.hor_offset_table_adr

	move.w	$0468.w,Scroll.old_468
	move.l	#Scroll.install_raster,palirq
	rts

Scroll.deinit:
	move.l	#dummy,palirq
	rts

;--------------------------------------------------------------------------

Scroll.mainloop:

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0420,$FFFF8240.w
	endc
	endc

	move.w	Scroll.countdown,d0
	subq.w	#1,d0
	bmi.s	.dont_store_countdown
	move.w	d0,Scroll.countdown
	bra.s	.end_countdown
.dont_store_countdown:
	clr.w	Scroll.pause
.end_countdown:

	move.w	Scroll.morph_countdown,d0
	subq.w	#1,d0
	ble.s	.dont_store_morph_countdown
	move.w	d0,Scroll.morph_countdown
	bsr	Scroll.morph_wave
.dont_store_morph_countdown:

	ifne	1
	movea.l	scr,a0
	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.bpl_clear
	jsr	CLEAR_STSCREEN
	bra.s	.end_clear
.bpl_clear:
	movea.l	Scroll.dot_offsets_adrs,a1
	jsr	Scroll.clear_dots
.end_clear:
	endc

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0042,$FFFF8240.w
	endc
	endc

	bsr	Scroll.paint_shiftlogo

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0455,$FFFF8240.w
	endc
	endc

;	ifne	Scroll.MEASURE_CPU
;	ifeq	testmode
;.wait:	tst.b	$FFFF8209.w
;	beq.s	.wait
;	move.w	#$00F0,$FFFF8240.w
;	endc
;	endc

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0F40,$FFFF8240.w
	endc
	endc

; we don't do this anymore..
;	move.w	frmcnt+2,d0
;	lsl.w	#7,d0
;	bsr	Scroll.calc_hor_wave

	tst.w	Scroll.pause
	bne.s	.freeze
	bsr	Scroll.scroll_chunky
	bra.s	.paint
; todo: just for testing
.freeze:
	addi.w	#27,Scroll.pause_counter
.paint:

	move.w	Scroll.sub_frame,d0
	movea.l	Scroll.dot_offsets_adrs,a6

	ifne	Scroll.LLLLRRRR

	move.w	Scroll.pause_counter,d1
	andi.w	#SINTABLE_LEN-1,d1
	lea	sine_tbl,a1
	add.w	d1,d1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	asr.w	#8,d1
	asr.w	#1,d1
	tst.w	Scroll.pause
	beq.s	.just_paint
	add.w	d1,d0
	move.w	d0,d1
	not.w	d0
	andi.w	#7,d0
.just_paint:
	asr.w	#3,d1
	bsr	Scroll.paint_chunky_buf_new

	else

	fail	"don't use old trash!"

	endc

.end_paint:

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	ifne	Scroll.MEASURE_CPU
	movea.l	scr,a0
	move.w	Scroll.measured_vbls,d0
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
	lea	Scroll.dot_offsets_adrs,a0
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

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

;	move.l	frmcnt,d0
;	cmp.l	lastfrmcnt,d0
;	bne.s	.end_pal
;	move.l	#Scroll.init_pal,palirq
;.end_pal:

; wait for vbl..
	move.w	Scroll.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#Scroll.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,Scroll.old_468
	move.w	d1,Scroll.measured_vbls

	rts

Scroll.measured_vbls:
	ds.w	1

Scroll.old4ba:
	ds.l	1
Scroll.old_468:
	ds.w	1

;--------------------------------------------------------------------------

Scroll.toggle_pause:
	move.w	#100,Scroll.countdown
	not.w	Scroll.pause
	beq.s	.set_dummy_wave
	move.l	#Scroll.hor_offset_table,Scroll.hor_offset_table_adr
;	clr.w	Scroll.pause_counter
	rts
.set_dummy_wave:
	move.l	#Scroll.dummy_hor_offset_table,Scroll.hor_offset_table_adr
;	clr.w	Scroll.pause_counter
	rts

Scroll.start_morph:
	move.w	#64,Scroll.morph_countdown
	move.l	Scroll.end_verofftab_adr,Scroll.start_verofftab_adr
	rts

Scroll.start_morph0:
	bsr.s	Scroll.start_morph
	move.l	#Scroll.ver_offset_table0,Scroll.end_verofftab_adr
	rts

Scroll.start_morph1:
	bsr.s	Scroll.start_morph
	move.l	#Scroll.ver_offset_table1,Scroll.end_verofftab_adr
	rts

Scroll.start_morph2:
	bsr.s	Scroll.start_morph
	move.l	#Scroll.ver_offset_table2,Scroll.end_verofftab_adr
	rts

;--------------------------------------------------------------------------

Scroll.install_raster:
	movem.l	Scroll.logos+2,d0-d7
	movem.l	d0-d7,$FFFF8240.w

	ifeq	Scroll.MEASURE_CPU
	move	#$2700,sr
	clr.b	$fffffa1b.w
	move.b	#184,$fffffa21.w
	move.l	#Scroll.tib_rout,$0120.w
	move.b	#8,$fffffa1b.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move	#$2300,sr
	endc
	rts

Scroll.tib_rout
	movem.l	a0/a1,-(sp)
	lea	$FFFF8240.w,a0
	lea	Scroll.clogs+2,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	movem.l	(sp)+,a0/a1
	move	#$2700,sr
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	rte

Scroll.fill_chunkybuf:
	lea	Scroll.huge_scroll_buffer,a0
	lea	Scroll.chunky_font,a2
	lea	Scroll.font_chunkyidx_table,a4
	movea.l	Scroll.text_adr,a1

.loop:	moveq	#0,d1
	move.b	(a1)+,d1
	beq	.end
	add.w	d1,d1
	move.w	(a4,d1.w),d1
	lea	(a2,d1.w),a3

soff	set	0
	rept	8
	move.l	soff(a3),(a0)
	move.l	soff+4(a3),4(a0)
	lea	1024*8(a0),a0
soff	set	soff+320
	endr

	adda.l	#8-1024*64,a0
	bra	.loop

.end:	rts

;--------------------------------------------------------------------------

Scroll.paint_shiftlogo:
	move.w	frmcnt+2,d2
	lsl.w	#4,d2
	andi.w	#SINTABLE_LEN-1,d2
	lea	sine_tbl,a2
	add.w	d2,d2
	add.w	d2,d2
	move.w	(a2,d2.w),d0
	asr.w	#8,d0
	asr.w	#1,d0
	addi.w	#64,d0
	move.w	d0,d1
	andi.w	#$000F,d0
	sub.w	d0,d1
	lsr.w	d1
	mulu.w	#Scroll.SHIFTLOGO_SIZE,d0

	movea.l	scr,a0
	lea	160*184(a0),a0
	adda.w	d1,a0
	lea	Scroll.shifted_logo,a1
	adda.l	d0,a1

	tst.w	2(a2,d2.w)
	bmi	.to_left
	
.to_right:
off	set	0
	rept	16

; clear edges
	moveq	#0,d0
	moveq	#0,d1
	movem.l	d0-d1,off-8(a0)

; copy shifted scan
	movem.l	(a1)+,d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,off(a0)
	movem.l	(a1)+,d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,off+48(a0)

off	set	off+160
	endr
	rts

.to_left:
off	set	0
	rept	16

; clear edges
	moveq	#0,d0
	moveq	#0,d1
	movem.l	d0-d1,off+96(a0)

; copy shifted scan
	movem.l	(a1)+,d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,off(a0)
	movem.l	(a1)+,d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,off+48(a0)

off	set	off+160
	endr
	rts

Scroll.precalc_scan_table:
	lea	Scroll.scan_table,a0
	movea.l	a0,a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	#200/2-1,d7
.loop:	subi.w	#160,d1
	move.w	d0,(a0)+
	move.w	d1,-(a1)
	move.w	d0,(a0)+
	move.w	d1,-(a1)
	addi.w	#160,d0
	dbf	d7,.loop
	rts

; f(%00SS.SSSS.WWWW.WWW0) = round[(s/64.)*(w/64.)*64.]*160
Scroll.precalc_mix_table:
	lea	Scroll.mix_table,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d7

.sloop:	moveq	#0,d6

.wloop:	ext.w	d6
	move.w	d7,d0
	muls.w	d6,d0
	asr.l	#8,d0
	asr.l	#1,d0
	muls.w	#160,d0
	move.w	d0,(a0)+
	addq.b	#2,d6
	bcc.s	.wloop

	addq.b	#1,d7
	cmpi.b	#64,d7
	blt.s	.sloop
	rts

Scroll.init_pal:
	lea	$FFFF8240.w,a0
	movem.l	Scroll.logos+2,d0-d7
	move.l	#dummy,palirq
	movem.l	d0-d7,(a0)
	rts

;--------------------------------------------------------------------------

Scroll.init_plot_offsets:
	lea	Scroll.plot_offset_left-16*2,a0
	lea	Scroll.plot_offset_right-16*2,a1
	lea	Scroll.plot_offset_both-16*4,a2
	moveq	#-16,d0

.loop:
	rept	8
	move.w	d0,d1
	andi.w	#$FFF0,d1
	asr.w	#1,d1
	move.w	d1,(a0)+
	move.w	d1,2(a2)
	addq.w	#1,d1
	move.w	d1,(a1)+
	move.w	d1,(a2)
	addq.w	#1,d0
	addq	#4,a2
	endr
	rept	8
	move.w	d0,d1
	andi.w	#$FFF0,d1
	asr.w	#1,d1
	addq.w	#1,d1
	move.w	d1,(a0)+
	move.w	d1,2(a2)
	addq.w	#7,d1
	move.w	d1,(a1)+
	move.w	d1,(a2)
	addq.w	#1,d0
	addq	#4,a2
	endr

	cmpi.w	#320+16,d0
	blt	.loop
	rts

Scroll.init_wave0:
	lea	Scroll.ver_offset_table0,a0
	lea	sine_tbl,a1
	moveq	#0,d0
	move.w	#320/8-1,d7
.loop:	andi.w	#SINTABLE_LEN-1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d1
	andi.b	#$FE,d1
	move.b	d1,(a0)+
	addi.w	#10*4,d0
	dbf	d7,.loop
	rts

Scroll.init_wave1:
	lea	Scroll.ver_offset_table1,a0
	lea	sine_tbl,a1
	move.w	#SINTABLE_LEN/3,d0
	move.w	#320/8-1,d7
.loop:	andi.w	#SINTABLE_LEN-1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d1
	andi.b	#$FE,d1
	move.b	d1,(a0)+
	addi.w	#12*4,d0
	dbf	d7,.loop
	rts

Scroll.init_wave2:
	lea	Scroll.ver_offset_table2,a0
	lea	sine_tbl,a1
	move.w	#(SINTABLE_LEN*2)/3,d0
	move.w	#320/8-1,d7
.loop:	andi.w	#SINTABLE_LEN-1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d1
	andi.b	#$FE,d1
	move.b	d1,(a0)+
	addi.w	#8*4,d0
	dbf	d7,.loop
	rts

; input:
; d0.w= [1..256] mix factor
Scroll.morph_wave:
	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	$FFFF8240.w,d6
	move.w	#$0FFF,$FFFF8240.w
	endc
	endc

	lea	Scroll.ver_offset_table,a0
	move.l	Scroll.start_verofftab_adr,a1
	move.l	Scroll.end_verofftab_adr,a2
	lea	Scroll.scan_table,a3
	lea	Scroll.mix_table,a4

; [1..256]
;	move.w	d0,d1
;	neg.b	d1
; [1..64]
	moveq	#64,d1
	sub.w	d0,d1
	lsl.w	#8,d0
	lsl.w	#8,d1

;	moveq	#320/8-1,d7
;.loop:
	rept	320/8
	ifne	1
	move.w	d0,d2
	move.w	d1,d3
	move.b	(a1)+,d2
	move.b	(a2)+,d3
	move.w	(a4,d2.w),d2
	add.w	(a4,d3.w),d2
	move.w	d2,(a0)+
	else

	move.w	(a1)+,d2
	move.w	(a2)+,d3
	muls.w	d0,d2
	muls.w	d1,d3
	add.l	d2,d3
	swap	d3

	ifne	1
	add.w	d3,d3
	move.w	(a3,d3.w),(a0)+
	else
	asr.w	#1,d3
	muls.w	#160,d3
	move.w	d3,(a0)+
	endc

	endc

	endr
;	dbf	d7,.loop

	ifne	Scroll.MEASURE_CPU
	ifeq	testmode
	move.w	d6,$FFFF8240.w
	endc
	endc
	rts

Scroll.preshift:
	lea	Scroll.shifted_sprite,a0
	lea	Scroll.sprite,a1
	moveq	#2-1,d7				; 2 lines = 2 source words

.word_loop:
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#16-1,d6

.shift_loop:
	move.l	d0,d1
	swap	d1
	moveq	#0,d5

.color_loop:
	move.l	d5,d2
	moveq	#4-1,d4

	ifne	Scroll.LLLLRRRR

	lea	8(a0),a2
.plane_loop:
	lsr.b	#1,d2
	bcs.s	.set
.clr:	clr.w	(a0)+
	clr.w	(a2)+
	bra.s	.next_plane
.set:	move.w	d0,(a0)+
	move.w	d1,(a2)+
.next_plane:
	dbf	d4,.plane_loop
	movea.l	a2,a0

	else

.plane_loop:
	lsr.b	#1,d2
	bcs.s	.set
.clr:	clr.l	(a0)+
	bra.s	.next_plane
.set:	move.w	d0,(a0)+
	move.w	d1,(a0)+
.next_plane:
	dbf	d4,.plane_loop

	endc

	addq.w	#1,d5
	cmpi.w	#16,d5
	blt.s	.color_loop

	ror.l	#1,d0
	dbf	d6,.shift_loop

	dbf	d7,.word_loop
	rts

Scroll.preshift_logo:
	lea	Scroll.shifted_logo,a0
	lea	Scroll.clogs+34,a1
	moveq	#Scroll.LOGO_SCANS-1,d7		; 16 scans

.yloop:	moveq	#4*Scroll.LOGOSCAN_CHUNKS-1,d6	; 11 chunks of 4 planes

.word_loop:
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#16-1,d5

.shift_loop:
	move.l	d0,d1
	swap	d1
	or.w	d0,(a0)
	move.w	d1,8(a0)
	ror.l	#1,d0
	lea	Scroll.SHIFTLOGO_SIZE(a0),a0	; a0: current word in next shifted logo
	dbf	d5,.shift_loop

	lea	2-Scroll.SHIFTLOGO_SIZE*16(a0),a0
						; a0: next word in first shifted logo
	dbf	d6,.word_loop

	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+			; a0: next scan in first shifted logo
	lea	(20-Scroll.LOGOSCAN_CHUNKS)*8(a1),a1
						; a1: next degas scanline
	dbf	d7,.yloop
	rts

Scroll.convert_to_chunky:
	lea	Scroll.font+34,a1
	lea	Scroll.chunky_font,a0

	moveq	#$40,d2
	moveq	#32-1,d7
.font_yloop:
	moveq	#20-1,d6

.font_xloop:
	move.w	(a1)+,d0
	rept	16
	add.w	d0,d0
	scs	d1
	and.w	d2,d1
	move.b	d1,(a0)+
	endr
	dbf	d6,.font_xloop

	lea	40(a1),a1			; a1: next line of pi3
	dbf	d7,.font_yloop

	lea	Scroll.logos+34,a1
	moveq	#80-1,d7
.flag_yloop:

; plane 0
	moveq	#20-1,d6
	moveq	#$10,d2
.flag_xloop0:
	move.w	(a1),d0
	addq	#8,a1
	rept	16
	add.w	d0,d0
	scs	d1
	and.w	d2,d1
	move.b	d1,(a0)+
	endr
	dbf	d6,.flag_xloop0
	lea	-320(a0),a0
	lea	-160+2(a1),a1
	
; plane 1
	moveq	#20-1,d6
	moveq	#$20,d2
.flag_xloop1:
	move.w	(a1),d0
	addq	#8,a1
	rept	16
	add.w	d0,d0
	scs	d1
	and.w	d2,d1
	or.b	d1,(a0)+
	endr
	dbf	d6,.flag_xloop1
	lea	-320(a0),a0
	lea	-160+2(a1),a1

; plane 2
	moveq	#20-1,d6
	moveq	#$40,d2
.flag_xloop2:
	move.w	(a1),d0
	addq	#8,a1
	rept	16
	add.w	d0,d0
	scs	d1
	and.w	d2,d1
	or.b	d1,(a0)+
	endr
	dbf	d6,.flag_xloop2
	lea	-320(a0),a0
	lea	-160+2(a1),a1

; plane 3
	moveq	#20-1,d6
	moveq	#-$80,d2
.flag_xloop3:
	move.w	(a1),d0
	addq	#8,a1
	rept	16
	add.w	d0,d0
	scs	d1
	and.w	d2,d1
	or.b	d1,(a0)+
	endr
	dbf	d6,.flag_xloop3
	subq	#6,a1

	dbf	d7,.flag_yloop

	rts

; input:
; d0.w=shift [0..7]
; d1.w=8 pixel shifts [-8..+8]
; a6: dot buffer
Scroll.paint_chunky_buf_new:
	move.l	a6,.store_adr
	addq	#2,a6

	movea.l	Scroll.hugebuf_adr,a1
	addq	#8,a1

	adda.w	d1,a1
	movea.l	scr,a0
	lea	160*32(a0),a0
	move.l	#Scroll.shifted_sprite,d4
	ext.l	d0
	lsl.l	#8,d0
	add.l	d0,d4				; a3: sprite at shift offset
	moveq	#8-1,d7

.yloop:	moveq	#19-1,d6
	lea	Scroll.ver_offset_table,a3

.xloop:
	adda.w	(a3),a0

	move.l	a0,(a6)+			; store dst address.

	moveq	#0,d0
	move.b	(a1)+,d0			; d0.w=color
	add.l	d4,d0
	movea.l	d0,a2
	moveq	#0,d0
	move.b	(a1)+,d0			; d0.w=color
	addi.w	#8*16*4*4,d0			; shifted by 8 to the right.
	add.l	d4,d0
	movea.l	d0,a5

	movem.l	4096(a2),d2-d3			; mid
	or.l	4096(a5),d2
	swap	d3
	or.w	4096+4(a5),d3
	movem.l	(a2)+,d0-d1			; top/btm
	or.l	(a5)+,d0
	or.l	(a5)+,d1
	swap	d1
	or.l	d0,3*160(a0)
	or.w	d1,3*160+4(a0)
	or.l	d2,2*160(a0)
	or.w	d3,2*160+4(a0)
	or.l	d2,1*160(a0)
	or.w	d3,1*160+4(a0)
	or.l	d0,(a0)+
	or.w	d1,(a0)+
	addq	#2,a0
	movem.l	4096(a2),d2-d3			; mid
	or.l	4096(a5),d2
	swap	d3
	or.w	4096+4(a5),d3
	movem.l	(a2)+,d0-d1			; top/btm
	or.l	(a5)+,d0
	or.l	(a5)+,d1
	swap	d1
	or.l	d0,3*160(a0)
	or.w	d1,3*160+4(a0)
	or.l	d2,2*160(a0)
	or.w	d3,2*160+4(a0)
	or.l	d2,1*160(a0)
	or.w	d3,1*160+4(a0)
	or.l	d0,(a0)+
	or.w	d1,(a0)+
	subq	#6,a0

	suba.w	(a3)+,a0

	dbf	d6,.xloop

	adda.w	(a3),a0

; right-most one.. without overspill
	move.l	a0,(a6)+			; store dst address.

	moveq	#0,d0
	move.b	(a1)+,d0			; d0.w=color
	add.l	d4,d0
	movea.l	d0,a2
	moveq	#0,d0
	move.b	(a1)+,d0			; d0.w=color
	addi.w	#8*16*4*4,d0			; shifted by 8 to the right.
	add.l	d4,d0
	movea.l	d0,a5

	movem.l	4096(a2),d2-d3			; mid
	or.l	4096(a5),d2
	swap	d3
	or.w	4096+4(a5),d3
	movem.l	(a2)+,d0-d1			; top/btm
	or.l	(a5)+,d0
	or.l	(a5)+,d1
	swap	d1
	or.l	d0,3*160(a0)
	or.w	d1,3*160+4(a0)
	or.l	d2,2*160(a0)
	or.w	d3,2*160+4(a0)
	or.l	d2,1*160(a0)
	or.w	d3,1*160+4(a0)
	or.l	d0,(a0)+
	or.w	d1,(a0)+
	addq	#2,a0

	suba.w	(a3)+,a0

; increment to next row..
	lea	1024*8-40(a1),a1
	lea	160*15(a0),a0
	lea	160*15(a4),a4
	dbf	d7,.yloop

	movea.l	.store_adr(pc),a0		; a0: dot storage
	suba.l	a0,a6
	subq	#2,a6				; a6: store end - start = offset
	move.l	a6,d0				; d0.l=offset
	lsr.w	#2,d0				; d0.w=#dots=offset/4
	move.w	d0,(a0)				; store #dots.
	rts

.store_adr:
	dc.l	0

; todo: use apx buffer as font/flags source?
Scroll.scroll_chunky:
	;move.w	Scroll.frame,d0
	;andi.w	#7,d0
	;cmpi.w	#4,d0
	;bne	.end_scroll
	move.w	Scroll.sub_frame,d0
	subq.w	#Scroll.SPEED,d0
	bpl	.end_scroll
	addq.w	#8,d0
	addq.l	#1,Scroll.hugebuf_adr
.end_scroll:
	move.w	d0,Scroll.sub_frame

; new character..
	move.w	Scroll.frame,d0
	subq.w	#Scroll.SPEED,d0
	bpl	.char_init_done
	addi.w	#64,d0

	lea	Scroll.chunky_font,a2
	lea	Scroll.font_chunkyidx_table,a4
	movea.l	Scroll.text_adr,a3

	moveq	#0,d1
	move.b	(a3)+,d1
	bne.s	.char_ok
; wrap!
	move.l	#Scroll.huge_scroll_buffer,Scroll.hugebuf_adr
	move.l	#Scroll.event_list,Scroll.event_adr
	lea	Scroll.text,a3
	move.b	(a3)+,d1
.char_ok:
	move.l	a3,Scroll.text_adr

	movea.l	Scroll.event_adr,a5
	cmpa.l	(a5)+,a3
	blt.s	.event_done
	move.l	(a5)+,d2
	move.l	a5,Scroll.event_adr
	add.w	d2,d2
	add.w	d2,d2
	lea	Scroll.event_rout_table,a6
	adda.w	d2,a6
	movea.l	(a6),a6
	movem.l	d0/d1/a2/a4,-(sp)
	jsr	(a6)
	movem.l	(sp)+,d0/d1/a2/a4
.event_done:

.char_init_done:

.end:	move.w	d0,Scroll.frame
	rts

Scroll.sub_frame:
	dc.w	4
Scroll.frame:
	dc.w	63
Scroll.swap_pending:
	dc.w	0

; input:
; d0.w=phase
Scroll.calc_hor_wave:
	lea	Scroll.hor_offset_table,a0
	lea	sine_tbl,a1
	moveq	#8-1,d7
.loop:	andi.w	#SINTABLE_LEN-1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	asr.w	#8,d1
	asr.w	#4,d1
	move.w	d1,(a0)+
	addi.w	#450,d0
	dbf	d7,.loop

	rts

; input:
; a0: screen + bitplane offset
; a1: dot offsets (old)
Scroll.clear_dots:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a1)+,d7
	lsr.w	#3,d7
	ble	.end
	subq.w	#1,d7

.loop
	rept	8
	movea.l	(a1)+,a2
	movem.l	d0-d3,(a2)
	movem.l	d0-d3,160(a2)
	movem.l	d0-d3,320(a2)
	movem.l	d0-d3,480(a2)
	endr
	dbf	d7,.loop
	
.end:	rts

;--------------------------------------------------------------------------

	data

Scroll.num_dots:
	dc.w	1

Scroll.dot_offsets_adrs:
	dc.l	Scroll.dot_offsets1,Scroll.dot_offsets2

Scroll.logos:
;	incbin	FLAGS.PI1
	incbin	FLAGS2c.PI1

Scroll.clogs:
;	incbin	clog4.pi1
	incbin	clog4c.pi1

Scroll.font:
	incbin	font256c.pi3

Scroll.font_index_table:
offset	set	0
	rept	32
	dc.w	offset
offset	set	offset+1
	endr

offset	set	(640/8)*8
	rept	32
	dc.w	offset
offset	set	offset+1
	endr

offset	set	(640/8)*8*2
	rept	32
	dc.w	offset
offset	set	offset+1
	endr
	
offset	set	(640/8)*8*3
	rept	32
	dc.w	offset
offset	set	offset+1
	endr

Scroll.font_chunkyidx_table:
offset	set	0
	rept	32
	dc.w	offset
offset	set	offset+8
	endr

offset	set	320*8
	rept	32
	dc.w	offset
offset	set	offset+8
	endr

offset	set	320*16
	rept	32
	dc.w	offset
offset	set	offset+8
	endr
	
offset	set	320*24
	rept	32
	dc.w	offset
offset	set	offset+8
	endr
	
offset	set	320*(32+24)
	rept	40
	dc.w	offset
offset	set	offset+8
	endr
	
offset	set	320*(32+40)
	rept	40
	dc.w	offset
offset	set	offset+8
	endr

Scroll.WIGGLE:=	0
Scroll.WAVE0:=	1
Scroll.WAVE1:=	2
Scroll.WAVE2:=	3

Scroll.event_list:
	dc.l	Scroll.clog_text,Scroll.WAVE1
	dc.l	Scroll.greet_text,Scroll.WAVE0
	dc.l	Scroll.nl_text-1,Scroll.WIGGLE
	dc.l	Scroll.gr_text-1,Scroll.WIGGLE
	dc.l	Scroll.de_text-1,Scroll.WIGGLE
	dc.l	Scroll.de_text,Scroll.WAVE2
	dc.l	Scroll.no_text-1,Scroll.WIGGLE
	dc.l	Scroll.fi_text-1,Scroll.WIGGLE
	dc.l	Scroll.fi_text,Scroll.WAVE1
	dc.l	Scroll.scotland_text-1,Scroll.WIGGLE
	dc.l	Scroll.pl_text-1,Scroll.WIGGLE
	dc.l	Scroll.fr_text-1,Scroll.WIGGLE
	dc.l	Scroll.se_text-1,Scroll.WIGGLE
	dc.l	Scroll.se_text,Scroll.WAVE0
	dc.l	Scroll.wales_text-1,Scroll.WIGGLE
	dc.l	Scroll.at_text-1,Scroll.WIGGLE
	dc.l	Scroll.estonia_text-1,Scroll.WIGGLE
	dc.l	Scroll.hungary_text-1,Scroll.WIGGLE
	dc.l	Scroll.hungary_text,Scroll.WAVE2
	dc.l	Scroll.latvia_text-1,Scroll.WIGGLE
	dc.l	Scroll.lithouania_text-1,Scroll.WIGGLE
	dc.l	Scroll.czech_text-1,Scroll.WIGGLE
	dc.l	Scroll.sk_text-1,Scroll.WIGGLE
	dc.l	Scroll.sk_text,Scroll.WAVE1
	dc.l	Scroll.si_text-1,Scroll.WIGGLE
	dc.l	Scroll.england_text-1,Scroll.WIGGLE
	dc.l	Scroll.england_text,Scroll.WAVE0
	dc.l	Scroll.wrap_text-1,Scroll.WIGGLE
; will never reach this (required!)
	dc.l	Scroll.end_text,Scroll.WIGGLE

Scroll.text:
	dc.b	"           "
	dc.b	$80,$81,$82,' '		; nl
	dc.b	"!!!!! HA HA HA !!!!! "
	dc.b	$80,$81,$82,' '		; nl
	dc.b	"Another crack from the gutter!! "
	dc.b	$80,$81,$82,' '		; nl
Scroll.clog_text:
	dc.b	"By the clogs from the reservoir! "
	dc.b	"reservoir clogs - HOHOHO!! "
	dc.b	"Creds.. gfx: pea, kod: p-man, msx: madmalc "
Scroll.greet_text:
	dc.b	"Waiting for greets? "
	dc.b	"Let's take it country by country: "
Scroll.nl_text:
	dc.b	$80,$81,$82,' '
	dc.b	'tos crew, limp ninja, guideline, inque '
; dk
;	dc.b	$83,$84,$85,' '
;	dc.b	'is there an atari here? '
Scroll.gr_text:
	dc.b	$86,$87,$88,' '
	dc.b	'kua (ggn), christos, invent '
Scroll.de_text:
	dc.b	$89,$8A,$8B,' '
	dc.b	'checkpoint, escape, paradox, paranoia, tscc, thothy, paradize '
Scroll.no_text:
	dc.b	$8C,$8D,$8E,' '
	dc.b	'ephidrena '
Scroll.fi_text:
	dc.b	$8F,$90,$91,' '
	dc.b	'aggression, pwp, wamma '
Scroll.scotland_text:
	dc.b	$92,$93,$94,' '
	dc.b	'senior dads, cynix (lol), cj '
Scroll.pl_text:
	dc.b	$95,$96,$97,' '
	dc.b	'mystic bytes, taquart '
Scroll.fr_text:
	dc.b	$98,$99,$9A,' '
	dc.b	'dune, equinox, oxygene, sector1, mjj, defence force, paradize '
; es(pania)
;	dc.b	$9B,$9C,$9D,' '
;	dc.b	'anybody? '
Scroll.se_text:
	dc.b	$9E,$9F,$A0,' '
	dc.b	'dhs, nocrew, marcer '
Scroll.wales_text:
	dc.b	$A1,$A2,$A3,' '
	dc.b	'mrpink *lol* '
Scroll.at_text:
	dc.b	$A8,$A9,$AA,' '
	dc.b	'lazer '
Scroll.estonia_text:
	dc.b	$AB,$AC,$AD,' '
	dc.b	'what? '
Scroll.hungary_text:
	dc.b	$AE,$AF,$B0,' '
	dc.b	'who? '
Scroll.latvia_text:
	dc.b	$B1,$B2,$B3,' '
	dc.b	'where? '
Scroll.lithouania_text:
	dc.b	$B4,$B5,$B6,' '
	dc.b	"isn't it cold there? "
Scroll.czech_text:
	dc.b	$B7,$B8,$B9,' '
	dc.b	'hhhmm, suma soft? '
; slovakia
Scroll.sk_text:
	dc.b	$BA,$BB,$BC,' '
	dc.b	'satantronic '
; slovenia
Scroll.si_text:
	dc.b	$BD,$BE,$BF,' '
	dc.b	'yescrew '
Scroll.england_text:
	dc.b	'england: phf (gwem, grazey), dbug, etc? '
Scroll.wrap_text:
	dc.b	" ...Let's wrap... ",0
Scroll.end_text:
	even

Scroll.TEXT_SIZE:=	(Scroll.end_text-Scroll.text)

Scroll.sprite:
	dc.w	%0110000000000000
	dc.w	%1111000000000000

Scroll.hugebuf_adr:
	dc.l	Scroll.huge_scroll_buffer

;--------------------------------------------------------------------------

	bss
	
Scroll.hor_offset_table_adr:
	ds.l	1
Scroll.text_adr:
	ds.l	1
Scroll.event_adr:
	ds.l	1
Scroll.pause:
	ds.w	1
Scroll.pause_counter:
	ds.w	1
Scroll.old_8pix_offset:
	ds.w	1
Scroll.countdown:
	ds.w	1
Scroll.morph_countdown:
	ds.w	1
Scroll.end_verofftab_adr:
	ds.l	1
Scroll.start_verofftab_adr:
	ds.l	1

Scroll.huge_scroll_buffer:
	;ds.b	64*Scroll.TEXT_SIZE		; 8x8 x text_size
	ds.b	64*1024				; 8x8 x text_size (fixed to 1024)
Scroll.chunky_font:
	ds.b	320*200
Scroll.chunky_scroll_buf:
Scroll.chunky_scroll_buf1:
	ds.b	64*8
Scroll.chunky_scroll_buf2:
	ds.b	64*8
Scroll.shifted_sprite:
	ds.w	2*16*16*4*2		; 2 lines x 16 shifts x 16 colour types x 4 planes x 2 words (for overspill)
Scroll.dot_offsets1:
	ds.l	Scroll.MAX_NUM_DOTS
Scroll.dot_offsets2:
	ds.l	Scroll.MAX_NUM_DOTS

	ds.w	16
Scroll.plot_offset_left:
	ds.w	320
	ds.w	16

	ds.w	16
Scroll.plot_offset_right:
	ds.w	320
	ds.w	16

	ds.w	16*2
Scroll.plot_offset_both:
	ds.w	320*2
	ds.w	16*2

Scroll.hor_offset_table:
	ds.w	16
Scroll.dummy_hor_offset_table:
	ds.w	16

Scroll.ver_offset_table0:
	ds.w	320
Scroll.ver_offset_table1:
	ds.w	320
Scroll.ver_offset_table2:
	ds.w	320
Scroll.ver_offset_table_dummy:
	ds.w	320
Scroll.ver_offset_table:
	ds.w	320

Scroll.bitbuf:
	ds.l	2*8			; plane 0
	ds.l	2*8			; plane 1
	ds.l	2*8			; ..
	ds.l	2*8

	ds.w	200
Scroll.scan_table:
	ds.w	200

Scroll.mix_table:
	ds.w	64*256

Scroll.shifted_logo:
	ds.b	16*Scroll.SHIFTLOGO_SIZE	; planes*2*chunks*scans*shifts
