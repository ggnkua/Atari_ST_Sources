export vbl_rout1			;vbl-interrupt routine (menu-scr)
export vbl_rout2			;vbl-interrupt routine (greetings-scr)
export vbl_rout3			;vbl-interrupt routine (process-alert)
export vbl_rout4			;vbl-interrupt routine (escape-logo)
export vbl_wait				;vsync
export memcopy				;copies memory longwordwise
export memclear				;clears memory longwordwise
export evenadr				;calculates next even adress
export make_palette			;generate falcon palette
export set_palette			;set falcon palette via registers
export setclipping			;set clippingarea
export gettrp				;cuts trp-image from screen
export drawtrp				;draws a trp-image
export drawtext
export drawstring
export copytrp				;copy area from trp-images to another
export drawshadow			;draws a shadowed box
export clrshadow			;removes shadow (window moving)
export drawinfocont			;draws infowin contents
export drawbox				;draw filled box
export darker_color			;get darker value of a color
export blendout2			;blends the screen to black
export blend

export init_replay			;init modreplay
export deinit_replay		;deinit modreplay
export play_mod				;start playing modfile
export stop_mod				;stop playing
export balance
export volume
export make_surround		;set surround-values
export set_interpolation	;switches interpolation on/off
export speaker_off
export speaker_on
import player				;DSP-replay by Bitmaster/TCE

export mousedriver			;mouseinterrupt routine
export mposx,mposy,mb		;mousestates
export show_mouse			;mousecursor on
export hide_mouse			;mousecursor off
import mcursor				;mousecursordata

import scradr				;phys.screenadress
import bufadr				;second screen (screenbuffer)
import plasmapic
import plasmapicoffset		
import map
import mapx,mapy

import font_gfx
import range_gfx
import process_gfx

export drawdist
import distwav1_dat
import distwav2_dat
import distwav3_dat
import dist_dat
import distmove

export basntekk_txt
export hardatta_txt
export heros_txt
export never_txt
export newsafe_txt
export nobrain_txt
export normal_txt
export paradise_txt
export paretyon_txt
export sleeples_txt
export smile_txt
export sunmon2_txt
export where_txt

*** VBL-ROUTS ***
	
vbl_rout1:
	movem.l D0-A6,-(SP)

	clr.w	vbl_zero

;handle mousecursor
	tst.w	mstate
	beq		vbl1_no_mcursor
	bsr		clear_mcursor	;clear old mousecursor
	bsr		draw_mcursor	;draw mousecursor
vbl1_no_mcursor:

	bsr		player+44		;DSP-replayer
	
	sub.l	#320,vbl_cnt
	bge		no_plasma_vbl
	move.l	#320,vbl_cnt
no_plasma_vbl:

	move.l	vbl_cnt,d0
	bsr		drawplasma

	movem.l (SP)+,D0-A6
rte

vbl_cnt:	dc.l 0


vbl_rout2:
	movem.l D0-A6,-(SP)

	clr.w	vbl_zero
;handle mousecursor
	tst.w	mstate
	beq		vbl2_no_mcursor
	bsr		clear_mcursor	;clear old mousecursor
	bsr		draw_mcursor	;draw mousecursor
vbl2_no_mcursor:

	bsr		player+44		;DSP-replayer
	
	movem.l (SP)+,D0-A6
rte


vbl_rout3:
	movem.l D0-A6,-(SP)

	clr.w	vbl_zero


	bsr		player+44		;DSP-replayer

	sub.l	#320,vbl_cnt
	bge		no_plasma_vbl3
	move.l	#320,vbl_cnt
no_plasma_vbl3:
	move.l	vbl_cnt,d0
	bsr		drawplasma
	bsr		drawprocess
	
	movem.l (SP)+,D0-A6
rte



vbl_rout4:
	movem.l D0-A6,-(SP)
	clr.w	vbl_zero
	bsr		player+44		;DSP-replayer
	movem.l (SP)+,D0-A6
rte


vbl_zero: dc.w 0


vbl_wait:
	move.w	#1,vbl_zero
vbl_wait_loop:
	tst.w	vbl_zero
	bne		vbl_wait_loop
rts


*** MEMORY ROUTINES ***
memcopy:
	;d0:	anz. longs
	;a0:	src
	;a1:	dst
	
	subq	#1,d0
mc_loop:
	move.l	(a0)+,(a1)+
	dbf		d0,mc_loop
rts

memclear:
	;d0:	anz. longs
	;a0:	adr.
	
	subq	#1,d0
mclr_loop:
	clr.l	(a0)+
	dbf		d0,mclr_loop
rts

evenadr: 
	;a0:	adr.
	move.l	a0,d0
	andi.b	#%11111100,d0
	addq	#4,d0	
	movea.l	d0,a0
rts


setclipping:
	;d0:	x1
	;d1:	y1
	;d2:	x2
	;4(sp):	y2
	move.l	#0,clipx1
	tst.l	d0
	ble		clipx_le_zero	
	move.l	d0,clipx1
clipx_le_zero:
	move.l	#0,clipy1
	tst.l	d1
	ble		clipy_le_zero
	move.l	d1,clipy1
clipy_le_zero:
	move.l	#320-64,clipx2
	cmpi.l	#320-64,d2
	bge		clipx_ge_max
	move.l	d2,clipx2
clipx_ge_max:
	move.l	#240,clipy2
	cmpi.l	#240,4(sp)
	bge		clipy_ge_max
	move.l	4(sp),clipy2
clipy_ge_max:
rts

clipx1:	dc.l 0
clipy1:	dc.l 0
clipx2:	dc.l 320-1
clipy2:	dc.l 240-1


*** TRP-IMAGE ROUTINES ***
gettrp:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;d2:	w
	;4+60(sp):	h
	;a0:	scradr
	;a1:	destination adr.
	move.l	4+60(sp),d3
	
	move.l	#"TRUP",(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	
	mulu.l	#320,d1
	add.l	d1,d0
	lsl.l	d0
	adda.l	d0,a0
	
	move.w	#320,d5
	sub.w	d2,d5
	lsl.w	d5
	
	subq.l	#1,d2
	subq.l	#1,d3
gettrp_yloop:

	move.w	d2,d4
gettrp_xloop:

	move.w	(a0)+,(a1)+

	dbf		d4,gettrp_xloop

	adda.w	d5,a0

	dbf		d3,gettrp_yloop

	movem.l	(sp)+,d0-a6
rts


drawtrp:
	movem.l	d0-a6,-(sp)
	;d0:	x1
	;d1:	y1
	;a0:	trp-daten
	;a1:	scradr

	;Nullzeiger -> nicht zeichnen 
	tst.l	a0
	beq		dtrp_end
	
	addq	#4,a0		;trp-id "TRUP"
	move.w	(a0)+,d2	;trp-width
	ext.l	d2
	move.w	(a0)+,d3	;trp-height
	ext.l	d3

	;ist trp Åberhaupt sichtbar?
	move.l	d2,d4		;x2
	add.l	d0,d4
	move.l	d3,d5		;y2
	add.l	d1,d5
	
	;x2<clipx1? ->cancel
	cmp.l	clipx1,d4
	ble		dtrp_end
	;x1>clipx2?
	cmp.l	clipx2,d0
	bge		dtrp_end
	;y2<clipy1?
	cmp.l	clipy1,d5
	ble		dtrp_end
	;y1>clipy2?
	cmp.l	clipy2,d1
	bge		dtrp_end

	;calculate screen startadress
	move.l	d1,d7
	mulu.l	#320,d7
	add.l	d0,d7
	lsl.l	d7
	adda.l	d7,a1
	;a1:	destination startadress

	moveq.l	#0,d6		;trp-lineoffset
	move.l	d2,a2		;trp-width after clipping

	;clipping
	move.l	clipx1,d7
	sub.l	d0,d7
	ble		dtrp_no_clipx1
	;d7:	width of left cut
	suba.l	d7,a2		;reduce trp-width
	add.l	d7,d6		;increment trp-lineoffset
	lsl.l	d7
	adda.l	d7,a0		;increment trp-startoffset
	adda.l	d7,a1		;increment scr-startoffset
dtrp_no_clipx1:
	move.l	clipy1,d7
	sub.l	d1,d7
	ble		dtrp_no_clipy1
	;d7:	height of upper cut
	sub.l	d7,d3		;reduce trp-height
	move.l	d7,d0
	mulu.l	d2,d0
	lsl.l	d0
	adda.l	d0,a0		;increment trp-startoffset
	mulu.l	#640,d7
	adda.l	d7,a1		;increment scr-startoffset
dtrp_no_clipy1:
	sub.l	clipx2,d4
	blt		dtrp_no_clipx2
	;d4:	width of right cut
	suba.l	d4,a2		;reduce trp-width
	add.l	d4,d6		;increment trp-lineoffset	
dtrp_no_clipx2:
	sub.l	clipy2,d5
	blt		dtrp_no_clipy2
	sub.l	d5,d3
dtrp_no_clipy2:

	;calculate screen lineoffset
	move.l	#320,d7
	sub.l	a2,d7
	lsl.l	d7
	;d7:	screen lineoffset

	lsl.l	d6
	subq.l	#1,a2		;xcnt
	subq.l	#1,d3		;ycnt
dtrp_yloop:
	move.l	a2,d0
dtrp_xloop:
	move.w	(a0)+,(a1)+
	dbf		d0,dtrp_xloop
	adda.l	d6,a0
	adda.l	d7,a1
	dbf		d3,dtrp_yloop
	
dtrp_end:
	movem.l	(sp)+,d0-a6
rts



copytrp:
	movem.l	d0-a6,-(sp)
	move.l	4+60(sp),d3
	move.l	8+60(sp),d4
	move.l	12+60(sp),d5
	;d0:	x trp1
	;d1:	y trp1
	;d2:	x trp2
	;d3:	y trp2
	;d4:	areawidth
	;d5:	areaheight
	;a0:	trp1
	;a1:	trp2

	addq	#4,a0		;id-field "TRUP"
	;get width of trp1
	move.w	(a0),d6
	addq	#4,a0		;height of trp not needed
	
	;calculate offset to the area on trp1
	mulu.w	d6,d1
	add.w	d0,d1
	lsl.w	d1
	adda.w	d1,a0
	;a0:	startpoint of area
	
	;calculate lineoffset for trp1
	sub.w	d4,d6
	lsl.w	d6
	;d6:	lineoffset trp1
	
	addq	#4,a1		;id-field "TRUP"
	move.w	(a1),d7		;width trp2
	addq	#4,a1
	
	;calculate offset to the area on trp2
	mulu.w	d7,d3
	add.w	d2,d3
	lsl.w	d3
	adda.w	d3,a1
	;a1:	startpoint of area
	
	;calculate lineoffset for trp2
	sub.w	d4,d7
	lsl.w	d7
	;d6:	lineoffset trp2
	
	subq.w	#1,d4		;xcounter
	subq.w	#1,d5		;ycounter
fliptrp_yloop:

	move.w	d4,d0
fliptrp_xloop:

	move.w	(a0)+,(a1)+

	dbf		d0,fliptrp_xloop

	adda.w	d6,a0
	adda.w	d7,a1

	dbf		d5,fliptrp_yloop
	

	movem.l	(sp)+,d0-a6
rts




drawinfocont:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;d2:	ypos
	;a0:	trp-daten
	;a1:	scradr

	move.l	d2,d4

	addq	#4,a0		;trp-id "TRUP"
	move.w	(a0),d2		;trp-width
	ext.l	d2
	move.w	#37,d3		;trp-height
	ext.l	d3
	addq	#4,a0
	
	;add y-offset of windowcontents
	mulu.l	d2,d4
	lsl.l	d4
	adda.l	d4,a0

	;ist trp Åberhaupt sichtbar?
	move.l	d2,d4		;x2
	add.l	d0,d4
	move.l	d3,d5		;y2
	add.l	d1,d5
	
	;x2<clipx1? ->cancel
	cmp.l	clipx1,d4
	ble		ditrp_end
	;x1>clipx2?
	cmp.l	clipx2,d0
	bge		ditrp_end
	;y2<clipy1?
	cmp.l	clipy1,d5
	ble		ditrp_end
	;y1>clipy2?
	cmp.l	clipy2,d1
	bge		ditrp_end

	;calculate screen startadress
	move.l	d1,d7
	mulu.l	#320,d7
	add.l	d0,d7
	lsl.l	d7
	adda.l	d7,a1
	;a1:	destination startadress

	moveq.l	#0,d6		;trp-lineoffset
	move.l	d2,a2		;trp-width after clipping
	lea		plasmapic,a3

	;clipping
	move.l	clipx1,d7
	sub.l	d0,d7
	ble		ditrp_no_clipx1
	;d7:	width of left cut
	suba.l	d7,a2		;reduce trp-width
	add.l	d7,d6		;increment trp-lineoffset
	lsl.l	d7
	adda.l	d7,a0		;increment trp-startoffset
	adda.l	d7,a1		;increment scr-startoffset
	adda.l	d7,a3		;increment plasmapic-startoffset
ditrp_no_clipx1:
	move.l	clipy1,d7
	sub.l	d1,d7
	ble		ditrp_no_clipy1
	;d7:	height of upper cut
	sub.l	d7,d3		;reduce trp-height
	move.l	d7,d0
	mulu.l	d2,d0
	lsl.l	d0
	adda.l	d0,a0		;increment trp-startoffset
	mulu.l	#640,d7
	adda.l	d7,a1		;increment scr-startoffset
	adda.l	d7,a3		;increment plasmapic-startoffset
ditrp_no_clipy1:
	sub.l	clipx2,d4
	blt		ditrp_no_clipx2
	;d4:	width of right cut
	suba.l	d4,a2		;reduce trp-width
	add.l	d4,d6		;increment trp-lineoffset	
ditrp_no_clipx2:
	sub.l	clipy2,d5
	blt		ditrp_no_clipy2
	sub.l	d5,d3
ditrp_no_clipy2:

	;calculate screen lineoffset
	move.l	#320,d7
	sub.l	a2,d7
	lsl.l	d7
	;d7:	screen lineoffset

	;adda.l	#640*310+100,a3
	;adda.l	#640*420+260,a3
	adda.l	#640*450+220,a3

	lsl.l	d6
	subq.l	#1,a2		;xcnt
	subq.l	#1,d3		;ycnt
ditrp_yloop:
	move.l	a2,d0
ditrp_xloop:


***

	move.w	(a0)+,d5
	beq.b	ditrp_foreground
	
	move.w	d5,(a1)+
	addq	#2,a3
	
	dbf		d0,ditrp_xloop
	bra.b	ditrp_xloop_end	

ditrp_foreground:
	move.w	(a3)+,(a1)+

	dbf		d0,ditrp_xloop
ditrp_xloop_end:
	adda.l	d6,a0
	adda.l	d7,a1
	adda.l	d7,a3
	dbf		d3,ditrp_yloop
	
ditrp_end:
	movem.l	(sp)+,d0-a6
rts


**
*	move.l	(a0)+,d4
*	tst.w	d4
*	bne.w	ditrp_background1
*	move.w	2(a2),d4
*ditrp_background1:
*
*	swap	d4
*	tst.w	d4
*	bne.w	ditrp_background2
*	move.w	(a2),d4
*ditrp_background2:
*
*	swap	d4
*	move.l	d4,(a1)+
*	addq	#4,a2
**


*** WINDOW-MOVE ROUTINES ***
drawshadow:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;d2:	x2
	;4+60(sp):	y2
	;a0:	bufadr (original picture data)
	;a1:	scradr (destination (screen))
	move.l	4+60(sp),d3
	
	;clipping
	cmp.l	clipx1,d2
	bgt		clrs_x2_ge
	movem.l	(sp)+,d0-a6
	rts
clrs_x2_ge:
	cmp.l	clipy1,d3
	bgt		clrs_y2_ge
	movem.l	(sp)+,d0-a6
	rts
clrs_y2_ge:
	cmp.l	clipx2,d0
	blt		clrs_x1_le
	movem.l	(sp)+,d0-a6
	rts
clrs_x1_le:
	cmp.l	clipy2,d1
	blt		clrs_y1_le
	movem.l	(sp)+,d0-a6
	rts
clrs_y1_le:
		
	;kappen
	cmp.l	clipx1,d0
	bge		clrs_x1_ge
	move.l	clipx1,d0
clrs_x1_ge:
	cmp.l	clipy1,d1
	bge		clrs_y1_ge
	move.l	clipy1,d1
clrs_y1_ge:
	cmp.l	clipx2,d2
	blt		clrs_x2_lt
	move.l	clipx2,d2
clrs_x2_lt:
	cmp.l	clipy2,d3
	blt		clrs_y2_lt
	move.l	clipy2,d3
clrs_y2_lt:
	
	sub.l	d1,d3
	sub.l	d0,d2

	mulu.l	#320,d1
	add.l	d1,d0
	lsl.l	d0
	adda.l	d0,a0
	;a0:	first adress on buffer
	adda.l	d0,a1
	;a1:	first adress on screen
	
	move.w	#320,d0
	sub.w	d2,d0
	lsl.w	d0
	;d0:	lineoffset on screen


	;d5 = pc-offset vor xloop
	moveq.l	#2+8,d5					;standartmÑûig Åberspringen
	btst	#0,d2					;wenn ungerade, dann nich
	beq		ds_jump
	moveq.l	#2,d5
ds_jump:

	lsr.l	#1,d2
	subq.l	#1,d2

	subq	#1,d3
ds_yloop:


	;einzelnes Pixel setzen, wenn Breite ungerade
	jmp		d5(pc)				;bîse, bîse...
	move.w	(a0)+,d4			;wird nur eventuell ausgefÅhrt.
	andi.w	#%11111,d4
	move.w	d4,(a1)+

	;x-counter
	move.w	d2,d1
	blt		ds_xloop_end		;wenn nur 1 pixel breit -> keine xloop

ds_xloop:
	move.l	(a0)+,d4
	andi.l	#%111110000000000011111,d4
	move.l	d4,(a1)+
	dbf		d1,ds_xloop
ds_xloop_end:
	
	adda.w	d0,a0
	adda.w	d0,a1
	dbf		d3,ds_yloop
	movem.l	(sp)+,d0-a6
rts

clrshadow:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;d2:	x2
	;4+60(sp):	y2
	;a0:	bufadr (original picture data)
	;a1:	scradr (destination (screen))
	move.l	4+60(sp),d3

	;clipping
	cmp.l	clipx1,d2
	bgt		ds_x2_ge
	movem.l	(sp)+,d0-a6
	rts
ds_x2_ge:
	cmp.l	clipy1,d3
	bgt		ds_y2_ge
	movem.l	(sp)+,d0-a6
	rts
ds_y2_ge:
	cmp.l	clipx2,d0
	blt		ds_x1_le
	movem.l	(sp)+,d0-a6
	rts
ds_x1_le:
	cmp.l	clipy2,d1
	blt		ds_y1_le
	movem.l	(sp)+,d0-a6
	rts
ds_y1_le:
		
	;kappen
	cmp.l	clipx1,d0
	bge		ds_x1_ge
	move.l	clipx1,d0
ds_x1_ge:
	cmp.l	clipy1,d1
	bge		ds_y1_ge
	move.l	clipy1,d1
ds_y1_ge:
	cmp.l	clipx2,d2
	blt		ds_x2_lt
	move.l	clipx2,d2
ds_x2_lt:
	cmp.l	clipy2,d3
	blt		ds_y2_lt
	move.l	clipy2,d3
ds_y2_lt:

	sub.l	d1,d3
	sub.l	d0,d2

	mulu.l	#320,d1
	add.l	d1,d0
	lsl.l	d0
	adda.l	d0,a0
	;a0:	first adress on buffer
	adda.l	d0,a1
	;a1:	first adress on screen
	
	move.w	#320,d0
	sub.w	d2,d0
	lsl.w	d0
	;d0:	lineoffset

	subq	#1,d2
	subq	#1,d3
clrs_yloop:
	move.w	d2,d1
clrs_xloop:
	move.w	(a0)+,(a1)+
	dbf		d1,clrs_xloop
	adda.w	d0,a0
	adda.w	d0,a1
	dbf		d3,clrs_yloop
	movem.l	(sp)+,d0-a6
rts


*** PLASMA ROUTINE ***
drawplasma:

	;d0:	offset

	add.l	#2*321,mapy
	cmpi.l	#2*240*321,mapy
	blt		dp_no_mapy_overflow
	sub.l	#2*240*320,mapy
dp_no_mapy_overflow:

	lea		plasmapic,a0
	adda.l	#640*200,a0
	adda.l	plasmapicoffset,a0
	movea.l	scradr,a1
	lea		map,a2
	
	adda.l	d0,a2
	lsl.l	d0
	adda.l	d0,a0
	adda.l	d0,a1
	
	adda.l 	mapy,a2
	;d0:	mapoffset
	;a0:	picture
	;a1:	scradr
	;a2:	mapadr
	
	adda.l	#60*640+20,a0

	adda.l	#640-128,a1

	move.w	#120-1,d0
dp_yloop:

	REPT 4

	movem.w	(a2)+,d2-d7/a3-a4
	move.l	(a0,d2),(a1)+
	addq	#4,a0
	move.l	(a0,d3),(a1)+
	addq	#4,a0
	move.l	(a0,d4),(a1)+
	addq	#4,a0
	move.l	(a0,d5),(a1)+
	addq	#4,a0
	move.l	(a0,d6),(a1)+
	addq	#4,a0
	move.l	(a0,d7),(a1)+
	addq	#4,a0
	move.l	(a0,a3),(a1)+
	addq	#4,a0
	move.l	(a0,a4),(a1)+
	addq	#4,a0

	ENDM

	adda.l	#640-128+640,a0
	adda.l	#640-128+640,a1
	adda.l	#320+320-64+320,a2

	dbf		d0,dp_yloop
rts



drawbox:
	movem.l	d0-a6,-(sp)
	move.l	4+60(sp),d3
	move.l	8+60(sp),d4
	;d0: x
	;d1: y
	;d2: w
	;d3: h
	;d4: color

	sub.l	d0,d2
	sub.l	d1,d3

	move.l	#320,d5
	sub.l	d2,d5
	lsl.l	d5

	subq.l	#1,d2
	subq.l	#1,d3
	
	mulu.l	#320,d1
	add.l	d0,d1
	lsl.l	d1
	movea.l	scradr,a0
	adda.l	d1,a0
	
	
db_yloop:

	move.l	d2,d0
db_xloop:
	move.w	d4,(a0)+
	dbf		d0,db_xloop

	adda.l	d5,a0
	dbf		d3,db_yloop

	movem.l	(sp)+,d0-a6
rts	


*** AUSBLENDER ***

darker_color:
	movem.l	d3-d4,-(sp)
	;d0:	color
	move.w	d0,d2
	move.w	d2,d3
	andi.w	#%11111,d2
	move.w	d3,d4
	andi.w	#%11111000000,d3
	andi.w	#%1111100000000000,d4
	move.w	#0,d5
	subi.w	#%1,d2
	bls		no_blue_overflow
	add.w	d2,d5
no_blue_overflow:
	subi.w	#%100000,d3
	bls		no_green_overflow
	add.w	d3,d5
no_green_overflow:
	subi.w	#%100000000000,d4
	bls		no_red_overflow
	add.w	d4,d5
no_red_overflow:
	move.w	d5,d0
	movem.l	(sp)+,d3-d4
rts


darker_color2:
	
rts


blendout2:
	;a0:	scradr
	;a1:	colortable
	;d0:	y-startoffset
	movem.l	d0-a6,-(sp)
	
	mulu.l	#640,d0
	adda.l	d0,a0
	
	move.w	#160-32-1,d0
bo2_clrline:
	clr.l	(a0)+
	dbf		d0,bo2_clrline
	adda.w	#64*2,a0
	
	moveq.l	#0,d0
	
	move.w	#10-1,d7
bo2_yloop:

	move.w	#320-64-1,d6
bo2_xloop:

	move.w	(a0),d2
	move.w	d2,d3
	move.w	d3,d4
	andi.w	#%11111,d2
	andi.w	#%11111000000,d3
	andi.w	#%1111100000000000,d4
	moveq	#0,d0
	subi.w	#2*%1,d2
	bls		bo_no_blue_overflow
	add.w	d2,d0
bo_no_blue_overflow:
	subi.w	#2*%1000000,d3
	bls		bo_no_green_overflow
	add.w	d3,d0
bo_no_green_overflow:
	subi.w	#2*%100000000000,d4
	bls		bo_no_red_overflow
	add.w	d4,d0
bo_no_red_overflow:
	move.w	d0,(a0)+

	dbf		d6,bo2_xloop

	adda.w	#64*2,a0

	dbf		d7,bo2_yloop
	movem.l	(sp)+,d0-a6

rts


blend:
	movem.l	d0-a6,-(sp)
	move.l	60+4(sp),a2
	;d0:	blender-step (y-pos.,wavepositions...)
	;a0:	source1
	;a1:	source2
	;a2:	destination
	
	lea		distwav1_dat,a3
	lea		distwav2_dat,a4
	lea		distwav3_dat,a5
	
	move.l	#640,d1
	mulu.l	d0,d1
	move.l	d1,d5
	sub.l	#640*10,d5

	move.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	add.l	d0,d1
	move.l	#300,d2
;	sub.l	d0,d2
	move.l	#15,d3
	add.l	d0,d3
	add.l	d0,d3
	add.l	d0,d3
	add.l	d0,d3
	add.l	d0,d3
	add.l	d0,d3
blend1_loop:
	sub.l	#314,d1
	bgt		blend1_loop
	add.l	#314,d1

blend3_loop:
	sub.l	#188,d3
	bgt		blend3_loop
	add.l	#188,d3

	move.w	#3,d6

	move.w	#320-64-1,d7
blend_loop:

	move.l	(a3,d1.l*4),d4
	add.l	(a4,d2.l*4),d4
	add.l	(a5,d3.l*4),d4
	asr.l	#4,d4
	
	add.l	#12,d1
	cmpi.l	#314,d1
	ble		blend1_ok
	sub.l	#314,d1
blend1_ok:

	sub.l	#73,d2
	bge		blend2_ok
	add.l	#565,d2
blend2_ok:

	add.l	#3,d3
	cmpi.l	#188,d3
	ble		blend3_ok
	sub.l	#188,d3
blend3_ok:

	subq	#1,d6
	bge		blendy_ok
	sub.l	#640,d5
	addq	#4,d6
blendy_ok:

	mulu.l	#640,d4
	add.l	d5,d4
	blt		blend_ok
	cmpi.l	#640*240,d4
	bge		blend_ok
	move.w	(-1*640,a1,d4.l),(-1*640,a2,d4.l)
	move.w	(0*640,a1,d4.l),(0*640,a2,d4.l)
	move.w	(1*640,a1,d4.l),(1*640,a2,d4.l)
	move.w	(2*640,a0,d4.l),(2*640,a2,d4.l)
	move.w	(3*640,a0,d4.l),(3*640,a2,d4.l)
blend_ok:
	addq.w	#2,a0
	addq.w	#2,a1
	addq.w	#2,a2

	dbf		d7,blend_loop


	movem.l	(sp)+,d0-a6
rts


*** MOD PLAYER ***
init_replay:
	movem.l	d0-a6,-(sp)
	bsr		player+28
	movem.l	(sp)+,d0-a6
	rts
	
deinit_replay:
	movem.l	d0-a6,-(sp)
	bsr		player+32	
	movem.l	(sp)+,d0-a6
rts

play_mod:
	movem.l	d0-a6,-(sp)
	;a0:	adr. of MOD-file
	lea		voltab,a1
	;a1:	volumetab
	bsr		player+36

	movem.l	(sp)+,d0-a6
rts	

stop_mod:
	movem.l	d0-a6,-(sp)
	bsr		player+40
	movem.l	(sp)+,d0-a6
rts	

balance:
	;d0:	channel
	;d1:	value -63(left)....63(right)

	mulu.l	#28,d0			;sampleset offset
	movea.l	player+70,a0	;get pointer to first sampleset
	adda.l	d0,a0
	move.w	d1,26(a0)		;set balance
rts

volume:
	;d0:	channel
	;d1:	value 0....$7fff
	
	lea	voltab,a0
	adda.w	d0,a0
	adda.w	d0,a0
	move.w	d1,(a0)
	
	mulu.l	#28,d0			;sampleset offset
	movea.l	player+70,a0	;get pointer to first sampleset
	adda.l	d0,a0
	move.w	d1,24(a0)		;set balance
rts

make_surround:
	;d0:	delay
	tst.l	d0
	bne		surround_on
	bclr	#0,player+61		;switch surround off
	rts	
surround_on:
	bset	#0,player+61		;switch surround on
	move.w	d0,player+62		;set surround delay
rts

set_interpolation:
	;d0:	1..on
	;		0..off
	tst.l 	d0
	beq		interpolation_off
	bset	#1,player+61
	rts
interpolation_off:
	bclr	#1,player+61
rts
	
voltab:
	dc.w $7fff,$7fff,$7fff,$7fff
	dc.w 0,0,0,0


speaker_on:
;	bclr	#6,$FFFF8802
rts

speaker_off:
;	bset	#6,$FFFF8802
rts



*** MOUSEDRIVER ROUTINES ***

mousedriver:
	;a0:	Adresse des Datenblockes
	;lea		output, a1
	;move.b	1(a0), (a1)+
	;move.b	2(a0), (a1)+
	
	;test, if data block = relative data block
	cmpi.b	#$FB, (a0)
	bgt		no_rel_mouse
	cmpi.b	#$F8, (a0)
	blt		no_rel_mouse
	
	;mousebuttons
	clr.w	d0
	move.b	(a0), d1
	btst	#0, d1
	beq		mb_no_left
	bset	#1, d0
mb_no_left:
	btst	#1, d1
	beq		mb_no_right
	bset	#0, d0
mb_no_right:
	move.w	d0, mb
	
	move.w	#1, d2
		
	;x-koordinate
	move.b	1(a0), d0
	ext.w	d0
	add.w	d0, rx				;rx..relative
	move.w	rx, d1
	move.w	#1, d3				;koord.-addition-value
	tst.w	d1					;clear and test sign.
	bgt		rx_greater_0
	move.w	#-1, d3				;koord.-addition-value
	neg.w	d1					;d1 must be positive
rx_greater_0:
	
	;repeat until rx<speed (rx=rx-speed)
rx_loop:
	;rx > speedborder ?
	cmp.w	d2, d1				;speed>rx ?
	blt		rx_too_low			;if speed>rx -> loopend
	sub.w	d2, d1				;rx=rx-speed
	add.w	d3, mposx			;in/decrement mousekoordinates
	bra		rx_loop
	
rx_too_low:

	mulu.w	d3, d1				;loopend-value = next startvalue
	move.w	d1, rx

	;y-koordinate
	move.b	2(a0), d0
	ext.w	d0
	add.w	d0, ry				;ry..relative
	
	move.w	ry, d1
	move.w	#1, d3				;koord.-addition-value
	tst.w	d1					;clear and test sign.
	bgt		ry_greater_0
	move.w	#-1, d3				;koord.-addition-value
	neg.w	d1					;d1 must be positive
ry_greater_0:
	
	;repeat until ry<speed (ry=ry-speed)
ry_loop:
	;ry > speedborder ?
	cmp.w	d2, d1				;speed>ry ?
	blt		ry_too_low			;if speed>ry -> loopend
	sub.w	d2, d1				;ry=ry-speed
	add.w	d3, mposy			;in/decrement mousekoordinates
	bra		ry_loop
	
ry_too_low:

	mulu.w	d3, d1				;loopend-value = next startvalue
	move.w	d1, ry
	
	;intervall boarders
	move.w	mposx, d0
	cmpi.w	#0, d0			;mx<minx ?
	bge		mx_ge_minx
	move.w	#0, mposx		;-> mx=minx
mx_ge_minx:
	move.w	mposy, d0
	cmpi.w	#0, d0			;my<0 ?
	bge		my_ge_miny
	move.w	#0, mposy		;-> my=0
my_ge_miny:
	move.w	mposx, d0		;mx>x_border ?
	cmpi.w	#320-64, d0
	blt		mx_lt_maxx
	move.w	#320-64, mposx		;-> mx=x_border
	subq.w	#1, mposx
mx_lt_maxx:
	move.w	mposy, d0		;my>y_border ?
	cmpi.w	#240, d0
	blt		my_lt_maxy
	move.w	#240, mposy		;-> my=y_border
	subq.w	#1, mposy
my_lt_maxy:

;	cmpi.l	#0, stat
;	beq		md_no_draw
;	bsr		move_cursor
;md_no_draw:

no_rel_mouse:
rts


draw_mcursor:
	lea		mcursor,a0
	movea.l	scradr,a1

	moveq.l	#0,d0			;calculate new mouseposition-offset
	move.w	mposy,d0
	mulu.l	#320,d0
	add.w	mposx,d0
	lsl.l	d0
	;d0:	new mouseposition-offset (on screen)
	
	move.l	d0,mcpos		;save mouseposition offset for
							;next clearing
	adda.l	d0,a1

	move.w	#320-64,d0		;horizontal clipping
	sub.w	mposx,d0
	cmpi.w	#16,d0
	blt		mc_xclipping
	move.w	#16,d0
mc_xclipping:
	move.w	d0,mwidth

	move.w	mwidth,d0
	subq.w	#1,d0
mc_draw_xloop:

	move.l	a0,a2
	move.l	a1,a3
	move.w	#16-1,d1
mc_draw_yloop:

	move.w	(a2),d2					;black = transparent
	beq		mc_black
	move.w	d2,(a3)
mc_black:
	adda.l	#32,a2
	adda.l	#640,a3
	dbf		d1,mc_draw_yloop
	addq.l	#2,a0
	addq.l	#2,a1
	dbf		d0,mc_draw_xloop
rts


clear_mcursor:
	movea.l	bufadr,a0
	movea.l	scradr,a1
	adda.l	mcpos,a0
	adda.l	mcpos,a1
	move.w	mwidth,d0
	subq.w	#1,d0
mc_clear_loop:
	move.w	1*640(a0),1*640(a1)
	move.w	2*640(a0),2*640(a1)
	move.w	3*640(a0),3*640(a1)
	move.w	4*640(a0),4*640(a1)
	move.w	5*640(a0),5*640(a1)
	move.w	6*640(a0),6*640(a1)
	move.w	7*640(a0),7*640(a1)
	move.w	8*640(a0),8*640(a1)
	move.w	9*640(a0),9*640(a1)
	move.w	10*640(a0),10*640(a1)
	move.w	11*640(a0),11*640(a1)
	move.w	12*640(a0),12*640(a1)
	move.w	13*640(a0),13*640(a1)
	move.w	14*640(a0),14*640(a1)
	move.w	15*640(a0),15*640(a1)
	move.w	(a0)+,(a1)+
	dbf		d0,mc_clear_loop
rts


show_mouse:
	move.w	#1,mstate
rts

hide_mouse:
	tst		mstate
	beq		no_mousekill
	move.w	#0,mstate
	bsr		clear_mcursor
no_mousekill:
rts

mcpos:	dc.l	120*640+320
mwidth:	dc.w	16
rx: 	dc.w	0
ry:		dc.w	0
mstate:	dc.w	1
mposx:	dc.w	160
mposy:	dc.w	120
mb:		dc.w	0


*** DIST-ROUTINE ***

drawdist:
	movem.l	d0-a6,-(sp)
	move.l	4+60(sp),d3
	;d0:	offset wave 1
	;d1:	offset wave 2
	;d2:	offset wave 3
	;d3:	lightmovetab offset
	;a0:	screen
	adda.l	#640-128,a0

	;get waveadresses
	lea		distwav1_dat,a1
	lsl.l	#2,d0
	adda.l	d0,a1
	lea		distwav2_dat,a2
	lsl.l	#2,d1
	adda.l	d1,a2
	lea		distwav3_dat,a3
	lsl.l	#2,d2
	adda.l	d2,a3
	;a1,a2,a3:	waveadresses

	lea		plasmapic,a5
	lea		distmove,a4
	adda.l	(a4,d3.l*4),a5
	adda.l	#640*200+100,a5
	adda.l	plasmapicoffset,a5
	
	;y-loop
	move.w	#240-1,d0
dts_yloop:

	;calc. gfx-offset (wave1+wave2+wave3)
	move.l	(a1)+,d2
	add.l	(a2)+,d2
	add.l	(a3)+,d2
	
	;test overflow
dts_overflow:
	cmpi.l	#62,d2
	blt		dts_no_overflow
	subi.l	#62,d2
	bra		dts_overflow
dts_no_overflow:

	lsl.l	#8,d2

	;get gfx-data-adr.
	lea		dist_dat,a4
	adda.l	d2,a4

	;x-loop (copy gfx-data to screen)
	move.w	#64-1,d1
dts_xloop:
;REPT 64
	move.l	(a4)+,d3
	move.w	(a5,d3.l),(a0)+
	dbf		d1,dts_xloop
;ENDM


	;add lineoffsets
	adda.l	#640-128,a0		;screen
	adda.l	#640,a5		;lightsource

	dbf		d0,dts_yloop
	movem.l	(sp)+,d0-a6
rts


*** PROCESSING-ALERT ***

drawprocess:
	movem.l	d0-a6,-(sp)
	lea		plasmapic,a0
	lea		distmove,a1
	move.l	pcnt,d0
	adda.l	(a1,d0.l*4),a0
	adda.l	#640*360+80,a0
	;a0:	backgroundadr
;movea.l scradr,a0
	
	add.l	#3,pcnt
	cmpi.l	#628,pcnt
	blt		dproc_no_overflow
	sub.l	#628,pcnt
dproc_no_overflow:
	
	movea.l	scradr,a1
	adda.l	#640*100+200,a1
	;a1:	destination adress
	
	lea		process_gfx,a2
	addq.l	#4,a2
	;a2:	trp-adr.
	
	move.w	(a2)+,d0	;trp-width
	move.w	(a2)+,d1	;trp-height
	
	move.w	#320,d4
	sub.w	d0,d4
	lsl.w	d4
	;d4:	lineoffset
	
	subq.w	#1,d0
	subq.w	#1,d1
dproc_yloop:

	move.w	d0,d2
dproc_xloop:

	move.w	(a0)+,d5
	move.w	(a2)+,d7
	beq		dproc_background
	move.w	d7,d5
dproc_background:

	move.w	d5,(a1)+
	
	dbf		d2,dproc_xloop

	adda.w	d4,a0
	adda.w	d4,a1

	dbf		d1,dproc_yloop

	movem.l	(sp)+,d0-a6
rts

pcnt: dc.l 0


*** TEXT FUNCTIONS ***

TLINELEN EQU 2*88

drawtext:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;a0:	trp-adress
	;a1:	textadr.

	mulu.l	#TLINELEN,d1
	lsl.l	d0
	add.l	d0,d1
	adda.l	d1,a0
	addq	#8,a0
	;a0:	destinationadress

	lea		asciitab,a2
	lea		font_gfx,a3
	addq.w	#8,a3				;trp header

drawtext_loop:

	movea.l	a0,a5				;scradr

drawstring_loop:

	;get ascii
	move.b	(a1)+,d0
	beq		drawstring_end
	extb.l	d0
	
	;get char gfxdata
	movea.l	a3,a4
	adda.w	(a2,d0.l*2),a4
	
	;draw char
	move.w	#6-1,d1
drawchar_yloop:
	move.w	#6-1,d0
drawchar_xloop:

	move.w	(a4)+,d2
	beq		drawchar_trans
	clr.w	(a5)
drawchar_trans:
	addq.w	#2,a5

	dbf		d0,drawchar_xloop
	adda.w	#640-12,a4
	adda.w	#TLINELEN-12,a5
	dbf		d1,drawchar_yloop

	adda.w	#12-TLINELEN*6,a5

	bra		drawstring_loop

drawstring_end:

	adda.w	#6*TLINELEN,a0

	tst.b	(a1)
	bne		drawtext_loop

	movem.l	(sp)+,d0-a6
rts



drawstring:
	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;a0:	scradr
	;a1:	string

	move.l	d1,d4
	lsr.l	#2,d4
	lsl.l	d4

	mulu.l	#640,d1
	lsl.l	d0
	add.l	d0,d1
	move.l	d1,d2
	moveq.l	#0,d3
	addq	#8,d2
	;a0:	destinationadress

	lea		asciitab,a2
	lea		font_gfx,a3
	lea.l	range_gfx,a5
	addq.w	#8,a3				;trp header
	addq.w	#8,a5				;trp header
	adda.l	d4,a5

drawstrstring_loop:

	;get ascii
	move.b	(a1)+,d0
	beq		drawstrstring_end
	extb.l	d0
	
	;get char gfxdata
	movea.l	a3,a4
	adda.w	(a2,d0.l*2),a4
	
	;draw char
	move.w	#6-1,d1
drawstrchar_yloop:
	move.w	#6-1,d0
drawstrchar_xloop:
	tst.w	(a4)+
	beq		drawstr_nodraw
	move.w	(a5,d3.l),(a0,d2.l)
drawstr_nodraw:
	addq	#2,d2
	addq	#2,d3
	dbf		d0,drawstrchar_xloop
	add.l	#640-12,a4
	add.l	#640-12,d2
	add.l	#640-12,d3
	dbf		d1,drawstrchar_yloop

	add.l	#12-640*6,d2
	add.l	#12-640*6,d3

	bra		drawstrstring_loop
drawstrstring_end:

	movem.l	(sp)+,d0-a6
rts



asciitab:	ds.w	32
			dc.w	26*12									;space
			dc.w	36*12									;!
			ds.w	5
			dc.w	42*12										;'
			dc.w	43*12									;(
			dc.w	44*12									;)
			ds.w	2
			dc.w	39*12									;,
			dc.w	40*12									;-
			dc.w	38*12									;.
			dc.w	52*12									;/
			dc.w	14*12									;0..
			dc.w	27*12,28*12,29*12,30*12,31*12,32*12
			dc.w	33*12,34*12,35*12						;..9
			dc.w	45*12									;:
			ds.w	4
			
			dc.w	37*12									;?
			ds.w	1
			dc.w	0*12,1*12,2*12,3*12,4*12,5*12,6*12,7*12 ;A..
			dc.w	8*12,9*12,10*12,11*12,12*12,13*12,14*12
			dc.w	15*12,16*12,17*12,18*12,19*12,20*12
			dc.w	21*12,22*12,23*12,24*12,25*12
			ds.w	4
			dc.w	41*12									;_
			ds.w	1
			dc.w	46*12,47*12,48*12,49*12,50*12,51*12		;a..f
			ds.w	100


basntekk_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e  BASNTEKK  e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    02:46",0
			dc.b	"SIZE:    244KB",0
			dc.b	"DATE: 08.08.97 ",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"   ICH LEGE   ",0 
			dc.b	"      DEN     ",0
			dc.b	"HOERER AUF DEN",0
			dc.b	"   TISCH UND  ",0
			dc.b	" RENNE RUEBER ",0
			dc.b	"      INS     ",0
			dc.b	" SEKRETARIAT. ",0
			dc.b	0

hardatta_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e HARD       e",0
			dc.b	"e     ATTACK e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    01:51",0
			dc.b	"SIZE:    144KB",0
			dc.b	"DATE: 14.07.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	0

heros_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e    HEROS   e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    02:33",0
			dc.b	"SIZE:    126KB",0
			dc.b	"DATE: 14.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	0

never_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e NEVER      e",0
			dc.b	"e      CHILL e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    02:10",0
			dc.b	"SIZE:    266KB",0
			dc.b	"DATE: 27.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	0

newsafe_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e VIRTUAL    e",0
			dc.b	"e     TERROR e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    02:46",0
			dc.b	"SIZE:    223KB",0
			dc.b	"DATE: 14.09.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"  THE TERROR  ",0
			dc.b	"     SEEMS    ",0
			dc.b	"     TO BE    ",0
			dc.b	" CONTROLABLE. ",0
			dc.b	"              ",0
			dc.b	"PROBABLY IT IS",0
			dc.b	"      ...     ",0
			dc.b	"              ",0
			dc.b	"BUT BY WHOM ??",0
			dc.b	"              ",0
			dc.b	" ENJOY        ",0
			dc.b	"   THE        ",0
			dc.b	"     VIRTUAL  ",0
			dc.b	"       TERROR!",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"        505/CP",0
			dc.b	0

nobrain_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e  NO BRAIN  e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    01:47",0
			dc.b	"SIZE:    134KB",0
			dc.b	"DATE: 08.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"  HAUPTSACHE  ",0
			dc.b	"     EGAL.    ",0
			dc.b	"              ",0
			dc.b	"   JOE COOL/CP",0
			dc.b	0

normal_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e HIGHSPEED  e",0
			dc.b	"e       KILL e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    02:17",0
			dc.b	"SIZE:    112KB",0
			dc.b	"DATE: 29.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	0

paradise_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e  PARADISE  e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    03:12",0
			dc.b	"SIZE:    250KB",0
			dc.b	"DATE: 27.04.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	" ES GIBT ZWEI ",0 
			dc.b	"UNGLUECKE FUER",0
			dc.b	" DIE MENSCHEN:",0
			dc.b	"   WENN SIE   ",0
			dc.b	"  ETWAS NICHT ",0
			dc.b	"   BEKOMMEN.. ",0
			dc.b	"              ",0
			dc.b	"      UND...  ",0
			dc.b	"              ",0
			dc.b    "   WENN SIE   ",0
			dc.b	" ES BEKOMMEN. ",0
			dc.b	"              ",0
			dc.b	"          O.W.",0
			dc.b	0

paretyon_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e BEAUTIFUL  e",0
			dc.b	"e       PAST e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    02:33",0
			dc.b	"SIZE:    231KB",0
			dc.b	"DATE: 28.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	" GREAT THINGS ",0
			dc.b	"   HAPPENED,  ",0
			dc.b	" MAYBE  GREAT ",0
			dc.b	" THINGS  WILL ",0
			dc.b	"     COME...  ",0
			dc.b	"BUT WHAT STAYS",0
			dc.b	"      IS      ",0
			dc.b	"THE THOUGHT OF",0
			dc.b	"  -THE PAST-  ",0
			dc.b	"THE  BEAUTYFUL",0
			dc.b	"    -PAST-    ",0
			dc.b	"   WHICH IS   ",0
			dc.b	"    -LOST-    ",0
			dc.b	"   LIKE  THE  ",0
			dc.b	"   -PRESENT-  ",0
			dc.b	"WHEN WE THINK ",0
			dc.b	"OF THE FUTURE.",0
			dc.b	"              ",0
			dc.b	"        505/CP",0
			dc.b	0

sleeples_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e  SLEEPLESS e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    02:40",0
			dc.b	"SIZE:    159KB",0
			dc.b	"DATE: 12.08.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	" ZUKUNFT WIRD ",0
			dc.b	" DAS, WAS DIE ",0
			dc.b	"ANGST AUS DER ",0
			dc.b	"VERGANGENHEIT ",0
			dc.b	"    IN DER    ",0
			dc.b	"   GEGENWART  ",0
			dc.b	"    BEWIRKT.  ",0
			dc.b	"              ",0
			dc.b	"   JOE COOL/CP",0
			dc.b	0

smile_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e    SMILE   e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    02:03",0
			dc.b	"SIZE:    179KB",0
			dc.b	"DATE: 04.04.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"    SMEILE,   ",0
			dc.b	"   DU SACK!   ",0
			dc.b	"              ",0
			dc.b	"        505/CP",0
			dc.b	0

sunmon2_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e SUN  DAY   e",0
			dc.b	"e    MON DAY e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"TIME:    02:45",0
			dc.b	"SIZE:    145KB",0
			dc.b	"DATE: 15.09.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"     GREAT    ",0
			dc.b	"   FEELINGS,  ",0
			dc.b	" WHEN THE SUN ",0
			dc.b	"  IS SHINING, ",0
			dc.b	"AND EVERYTHING",0
			dc.b	"  WORKS FINE. ",0
			dc.b	"              ",0
			dc.b	"  THIS DAY IS ",0
			dc.b	"    FOR ME.   ",0
			dc.b	"              ",0
			dc.b	"TOGETHER  WITH",0
			dc.b	"   THE  SUN.  ",0
			dc.b	"              ",0
			dc.b	"        505/CP",0
			dc.b	"              ",0
			dc.b	0

where_txt:
			dc.b	"              ",0
			dc.b	"affffffffffffb",0
			dc.b	"e    WHERE   e",0
			dc.b	"cffffffffffffd",0
			dc.b	"              ",0
			dc.b	"              ",0
			dc.b	"TIME:    02:12",0
			dc.b	"SIZE:    254KB",0
			dc.b	"DATE: 25.03.97",0
			dc.b	"              ",0
			dc.b	"ffffffffffffff",0
			dc.b	"              ",0
			dc.b	"     KEINEN   ",0
			dc.b	"   VERDERBEN  ",0
			dc.b	"    LASSEN,   ",0
			dc.b	"  AUCH NICHT  ",0 
			dc.b	" SICH SELBER, ",0
			dc.b	"   JEDEN MIT  ",0
			dc.b	"    GLUECK    ",0
			dc.b	"  ERFUELLEN,  ",0
			dc.b	"  AUCH SICH.  ",0
			dc.b	" DAS IST GUT. ",0
			dc.b	"              ",0
			dc.b	"        BRECHT",0
			dc.b	0


			