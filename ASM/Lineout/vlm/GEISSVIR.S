;===========================================================================
; Atari Coldfire Project - Virtual Light Machine : Plugin
;===========================================================================

;---------------------------------------------------------------------------
; 'Geiss'-esque effect as dizzy vlm: virtual 8bpp version.
;
; 320x200 feedback blur effect, based on windows 'geiss' dll.
; meant for accelerated falcons.
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
; plugin assembly options
;---------------------------------------------------------------------------

	comment	HEAD=%111


STANDALONE:=	1				; 1: run stand-alone, 0: run as plugin

	ifne	STANDALONE

	ifne	1
	incbin	test.bin
	include	plugineq.s
	else
TEST_MODE:=	1
	include	test.s
	endc

	else

	opt	d-
	output	.vlm
	include	plugineq.s

	endc

;---------------------------------------------------------------------------
; plugin table
;---------------------------------------------------------------------------

; must be first in object!
table:	dc.l	"DZY1"				; header
	dc.l	info				; info text, parameters
	dc.l	Display.TRIPLE_BUFFER		; type of buffering
	dc.l	Res.320X240_8BPP		; resolution
	dc.l	0				; layering support
	dc.l	main_loop			; main loop subroutine
	dc.l	init				; initialisation subroutine
	dc.l	deinit				; de-initialisation subroutine
	dc.l	0

	include	math.i
	text

info:	dc.l	"exam","ple ","modu","le  ",0
	dc.l	0

;---------------------------------------------------------------------------
; plugin initialisation subroutine
;---------------------------------------------------------------------------

; input:
; a0: vlm system routine table
; output:
; d0.l= (0: success, -1: error)
init:	move.l	a0,service_adr

	lea	flow_table_green,a1
	lea	green_pal,a0
	bsr	Pal.makeGradientTc
	lea	flow_table_orange,a1
	lea	orange_pal,a0
	bsr	Pal.makeGradientTc
	lea	flow_table_purple,a1
	lea	purple_pal,a0
	bsr	Pal.makeGradientTc
	lea	flow_table_blue,a1
	lea	blue_pal,a0
	bsr	Pal.makeGradientTc
	lea	flow_table_bluegrey,a1
	lea	bluegrey_pal,a0
	bsr	Pal.makeGradientTc

	bsr	init_8bpp

	bsr	precalc_twirl_in_map

	lea	muls_table,a0
	clr.w	d7

.scalarloop:
	clr.b	d6

.numloop:
	move.b	d6,d0
	ext.w	d0
	muls.w	d7,d0
	lsr.w	#8,d0
	move.b	d0,(a0)+
	addq.b	#1,d6
	bne.s	.numloop

	addq.b	#1,d7
	bne.s	.scalarloop

	movea.l	service_adr,a0
	move.l	#200,d0
	jsr	ServiceTable.SET_BORDERS(a0)

	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

;---------------------------------------------------------------------------
; plugin de-initialisation subroutine
;---------------------------------------------------------------------------

; output:
; d0.l= (0: success, -1: error)
deinit:
; ...
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

init_screen:
	bsr	init_screen_8bpp

	movea.l	screen,a0
	move.w	#(320*20)/16-1,d7
	clr.l	d0
.tloop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.tloop
	adda.l	#320*200,a0
	move.w	#(320*20)/16-1,d7
	clr.l	d0
.bloop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.bloop
	rts

;---------------------------------------------------------------------------
; plugin main loop subroutine
;---------------------------------------------------------------------------

; input:
; a0: screen
main_loop:
	move.l	a0,screen

	tst.l	frame_count
	bne.s	.end_screeninit
	bsr	init_screen
.end_screeninit:

	add.l	#320*20,screen

;- controls ----------------------------------------------------------------

	movea.l	service_adr,a0
	jsr	ServiceTable.GET_HOLD(a0)
	bne	.no_change

	move.l	time,old_time

	movea.l	service_adr,a0
	jsr	ServiceTable.GET_TIME_RUNNING(a0)
	move.l	d0,time

	moveq	#11,d2
	move.l	time,d0
	lsr.l	d2,d0
	move.l	old_time,d1
	lsr.l	d2,d1
	cmp.l	d1,d0
	beq.s	.no_change

	Calc_NextRandom
	move.l	d0,d2
	clr.l	d1
	move.w	d0,d1
	divu.w	num_pals,d1				; random() mod NUM_PALS
	swap	d1
	move.l	(pal_table,d1.w*4),pal_adr

	clr.l	d1
	swap	d2
	move.w	d2,d1
	divu.w	num_combis,d1				; random() mod NUM_COMBIS
	swap	d1
	mulu.w	#3*4,d1
	lea	(combi_table,d1.l),a1
	move.l	(a1)+,plot_rout_adr
	move.l	(a1)+,zoom_rout_adr
	move.l	(a1)+,blur_rout_adr
.no_change:

;	lea	combi_table_end-12,a1
;	move.l	(a1)+,plot_rout_adr
;	move.l	(a1)+,zoom_rout_adr
;	move.l	(a1)+,blur_rout_adr

;- zooming -----------------------------------------------------------------

	movea.l	screen,a1
	movea.l	scr_adr,a0
	movea.l	zoom_rout_adr,a2
	jsr	(a2)

;- blurring ----------------------------------------------------------------

	movea.l	scr_adr,a1
	movea.l	screen,a0
	movea.l	blur_rout_adr,a2
	jsr	(a2)

;- plots -------------------------------------------------------------------

	movea.l	plot_rout_adr,a2
	jsr	(a2)

;- display stuff -----------------------------------------------------------

	movea.l	pal_adr,a0
	move.l	service_adr,a1
	jsr	ServiceTable.SET_PAL(a1)

	addq.l	#1,frame_count
	rts

;---------------------------------------------------------------------------
; plugin subroutines
;---------------------------------------------------------------------------

; INPUT:
; a0: dst truecolor palette (24b)
; a1: colorflow instruction table 
Pal.makeGradientTc:
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	subq.w	#1,d6
	move.w	d6,d5
	subq.w	#1,d7

.biglop	move.l	(a1)+,d1
	move.l	(a1),d2
	moveq.l	#0,d3
	move.l	d3,d4
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
	move.l	a0,a6
.lop1	swap	d3
	move.w	d3,2(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop1
	move.w	d5,d6
	move.l	a6,a0
	moveq	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop2	swap	d3
	move.b	d3,1(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop2
	move.l	a6,a0
	move.w	d5,d6
	moveq.l	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	rol.l	#8,d1
	rol.l	#8,d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop3	swap	d3
	move.b	d3,(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop3
	move.w	d5,d6
	dbra	d7,.biglop
	rts

init_screen_8bpp:
;	movea.l	screen,a0
;	bsr	clear_screen
	rts

init_8bpp:
	andi.l	#$FFFFFFFC,buf_adr
	andi.l	#$FFFFFFFC,scr_adr

	lea	sine_tbl,a0
	bsr	calc_sin_table
	clr.l	frame_count
	rts

plot_polar_scope_l:
; polar scope
	movea.l	service_adr,a0
	jsr	ServiceTable.GET_LEFT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	moveq	#$7F,d5
	bsr	plot_polar_scope
	rts

plot_circle_scope_l:
; polar scope
	movea.l	service_adr,a0
	jsr	ServiceTable.GET_LEFT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	moveq	#$7F,d5
	moveq	#20,d3
	move.w	#$0600,d4				; d4.w=radius
	bsr	plot_circle_scope
	rts

plot_circle_scope_big:
; polar scope
	movea.l	service_adr,a0
	jsr	ServiceTable.GET_LEFT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	moveq	#$7F,d5
	moveq	#19,d3
	move.w	#$0400,d4				; d4.w=radius
	bsr	plot_circle_scope
	rts

plot_hor_scopes:
; horizontal scope..
	movea.l	service_adr,a0
	jsr	ServiceTable.GET_LEFT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	moveq	#68,d0
	moveq	#$7F,d5
	bsr	plot_scope_h_l

	movea.l	service_adr,a0
	jsr	ServiceTable.GET_RIGHT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	move.w	#132,d0
	moveq	#$7F,d5
	bsr	plot_scope_h_l
	rts

plot_hor_scope:
; horizontal scope..
	movea.l	service_adr,a0
	jsr	ServiceTable.GET_LEFT_OSC(a0)
	movea.l	a0,a1
	movea.l	screen,a0
	moveq	#100,d0
	moveq	#$7F,d5
	bsr	plot_scope_h_5
	rts

calc_sin_table:
	Init_SineTable
	rts

; input:
; a0: screen
clear_screen:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*200,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

;- scope plotters ----------------------------------------------------------

; input:
; d0.w=y offset
; d5.b=color
; a0: screen
; a1: scope (256 words)
plot_scope_h:
	mulu.w	#320,d0
	adda.l	d0,a0
	adda.w	#(320-256)/2,a0
	move.w	#256-1,d7
	move.w	(a1),d0

	asr.w	#6,d0

.yloop:	move.w	d0,d4
	move.w	(a1)+,d0
	asr.w	#6,d0
	move.w	d0,d1
	cmp.w	d1,d4
	bge.s	.oki
	exg	d1,d4
.oki:	sub.w	d1,d4
	muls.w	#320,d1
	lea	(a0,d1.l),a2
.loop:	move.b	d5,(a2)
	adda.w	#320,a2
	dbf	d4,.loop

	addq	#1,a0
	dbf	d7,.yloop

	rts

; input:
; d0.w=y offset
; d5.b=color
; a0: screen
; a1: scope (256 words)
plot_scope_h_l:
	mulu.w	#320,d0
	adda.l	d0,a0
	adda.w	#(320-256)/2,a0
	move.w	#256-1,d7

.yloop:	move.w	(a1)+,d0
	asr.w	#5,d0
	muls.w	#320,d0
	move.b	d5,(a0,d0.l)

	addq	#1,a0
	dbf	d7,.yloop
	rts

; input:
; d0.w=y offset
; d5.b=color
; a0: screen
; a1: scope (256 words)
plot_scope_h_5:
	mulu.w	#320,d0
	adda.l	d0,a0
	adda.w	#(320-256)/2,a0
	move.w	#256-1,d7

.yloop:	move.w	(a1)+,d0
	asr.w	#5,d0
	muls.w	#320,d0
	move.b	d5,(a0,d0.l)

	addq	#1,a0
	dbf	d7,.yloop
	rts

; input:
; d5.b=color
; a0: screen
; a1: scope (256 words)
plot_polar_scope:
	adda.l	#320*100+160,a0
	lea	sine_tbl,a2
	moveq	#19,d3
	clr.l	d7

.loop:	move.l	d7,d0
	lsl.l	#3,d0
	Get_SinCos	a2,d0,d0,d1
	move.w	(a1)+,d2

	bpl.s	.abs
	neg.w	d2
.abs:

	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	d3,d0
	asr.l	d3,d1
	muls.w	#320,d1
	ext.l	d0
	add.l	d0,d1
	move.b	d5,(a0,d1.l)
	addq.b	#1,d7
	bne.s	.loop
	rts

; input:
; d5.b=color
; a0: screen
; a1: scope (256 words)
plot_circle_scope:
	adda.l	#320*100+160,a0
	lea	sine_tbl,a2
	clr.l	d7

.loop:	move.l	d7,d0
	lsl.l	#3,d0
	addq.w	#4,d0
	Do_SinModulo	d0
	Get_SinCos	a2,d0,d0,d1
	move.w	(a1)+,d2
	add.w	d4,d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	d3,d0
	asr.l	d3,d1
	cmpi.w	#-100,d1
	ble.s	.next
	cmpi.w	#+100,d1
	bge.s	.next

	muls.w	#320,d1
	ext.l	d0
	add.l	d0,d1
	move.b	d5,(a0,d1.l)

.next:	addq.b	#1,d7
	bne.s	.loop
	rts

;- blurrers ----------------------------------------------------------------

; dst and scr must not be the same!
; input:
; a0: dst screen
; a1: src screen
blur_acc:
; clear top scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.tloop:	move.l	d0,(a0)+
	dbf	d7,.tloop

	adda.w	#320,a1
	move.l	#$FF7F7F7F,d1
	move.l	#$FF3F3F3F,d3
	move.w	#200-2-1,d7
	lea	-321(a1),a2	; top
	lea	+319(a1),a3	; btm
	lea	-319(a1),a4	; left
	lea	+321(a1),a5	; right

.yloop:	moveq	#16-1,d6

.xloop:
	rept	5
	move.l	(a2)+,d0
	add.l	(a3)+,d0
	move.l	(a4)+,d2
	add.l	(a5)+,d2
	lsr.l	d0
	lsr.l	d2
	and.l	d1,d0
	and.l	d1,d2
	add.l	d2,d0
	lsr.l	#2,d0
	and.l	d3,d0
	add.l	(a1)+,d0
	lsr.l	d0
	and.l	d1,d0
	move.l	d0,d2
	lsr.l	#2,d2
	and.l	d3,d2
	add.l	d2,d0
	move.l	d0,(a0)+
	endr
	dbf	d6,.xloop

	dbf	d7,.yloop

; clear bottom scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.bloop:	move.l	d0,(a0)+
	dbf	d7,.bloop
	rts

; input:
; a0: dst screen
; a1: src screen
blur_no:
; needed in case when the blur doesn't fade enough...
	clr.l	320*99+158(a1)
	clr.l	320*100+158(a1)

; clear top scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.tloop:	move.l	d0,(a0)+
	dbf	d7,.tloop

	adda.w	#320,a0
	adda.w	#320,a1
	move.l	#$FF7F7F7F,d1
	move.w	#200-2-1,d7
	move.l	frame_count,d0
	andi.w	#1,d0
	beq.s	.right
	lea	320*1-1(a1),a2	; left
	bra.s	.yloop
.right:	lea	320*1+1(a1),a2	; right

.yloop:	moveq	#8-1,d6

.xloop:
	rept	10
	move.l	(a2)+,d0
	add.l	(a1)+,d0
	lsr.l	d0
	and.l	d1,d0
	move.l	d0,(a0)+
	endr
	dbf	d6,.xloop

	dbf	d7,.yloop

; clear bottom scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.bloop:	move.l	d0,(a0)+
	dbf	d7,.bloop
	rts

; input:
; a0: dst screen
; a1: src screen
blur_crap:
; needed in case when the blur doesn't fade enough...
	clr.l	320*99+158(a1)
	clr.l	320*100+158(a1)

; clear top scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.tloop:	move.l	d0,(a0)+
	dbf	d7,.tloop

	adda.w	#320,a1
	move.l	#$FF7F7F7F,d1
	move.w	#200-2-1,d7
	move.l	frame_count,d0
	andi.w	#3,d0
	jsr	.table(pc,d0.w*4)

.yloop:	moveq	#8-1,d6

.xloop:
	rept	10
	move.l	(a2)+,d0
	add.l	(a1)+,d0
	lsr.l	d0
	and.l	d1,d0
	move.l	d0,(a0)+
	endr
	dbf	d6,.xloop

	dbf	d7,.yloop

; clear bottom scan line.
	clr.l	d0
	moveq	#320/4-1,d7
.bloop:	move.l	d0,(a0)+
	dbf	d7,.bloop
	rts

.table:	bra.w	.ne
	bra.w	.nw
	bra.w	.se
	bra.w	.sw

.ne:	lea	-320*1-1(a1),a2
	rts
.nw:	lea	-320*1+1(a1),a2
	rts
.se:	lea	+320*1-1(a1),a2
	rts
.sw:	lea	+320*1+1(a1),a2
	rts

blur_dont:
; needed in case when the blur doesn't fade enough...
	clr.l	320*99+158(a1)
	clr.l	320*100+158(a1)

	move.w	#320*200/8-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop
	rts

;- mappers -----------------------------------------------------------------

; dst and scr must not be the same!
; input:
; a0: dst screen
; a1: src screen
zoom_twirl:
	lea	twirl_map,a3
	adda.l	#320*100+160,a1
	lea	sine_tbl,a2
	clr.l	d3
	move.w	#200-1,d7

.yloop:	move.w	#320/16-1,d6

.xloop:
	rept	16
	move.l	(a3)+,d3
	move.b	(a1,d3.l),(a0)+
	endr
	dbf	d6,.xloop

	dbf	d7,.yloop
	rts

	ifne	0
precalc_twirl_map:
	lea	twirl_map,a0
	lea	sine_tbl,a2
	move.w	#-199,d7

.yloop:	move.w	#-319,d6

.xloop:	move.w	d6,d0
	move.w	d7,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1				; d1.l=x*x+y*y
	bsr	Math.sqrt
	move.l	#$0FFFFFFF,d1
	divu.l	d0,d1				; g= r^-2 =1/(x*x+y*y)
	Do_SinModulo	d1
	Get_SinCos	a2,d1,d0,d1		; d0.w=sin(g), d1.w=cos(g)
	move.w	d0,d3
	move.w	d1,d2
	neg.w	d3
	muls.w	d7,d0
	muls.w	d6,d1
	muls.w	d7,d2
	muls.w	d6,d3
	
	add.l	d0,d1
	add.l	d2,d3
	add.l	d1,d1
	add.l	d3,d3
	swap	d1				; d1.w=+cos(g)*p.x+sin(g)*p.y
	swap	d3				; d3.w=-sin(g)*p.x+cos(g)*p.y

; scale down a litte to move into the vortex..
	muls.w	#$88,d1
	asr.l	#8,d1				; d1.w=p'.x
	muls.w	#$88,d3
	asr.l	#8,d3				; d3.w=p'.y

	muls.w	#320,d3
	ext.l	d1
	add.l	d1,d3
	move.l	d3,(a0)+

	addq.w	#2,d6
	cmpi.w	#319,d6
	ble.s	.xloop

	addq.w	#2,d7
	cmpi.w	#199,d7
	ble.s	.yloop
	
	rts
	endc

precalc_twirl_in_map:
	lea	twirl_in_map,a0
	lea	twirl_map,a3
	lea	sine_tbl,a2
	move.w	#-199,d7

.yloop:	move.w	#-319,d6

.xloop:	move.w	d6,d0
	move.w	d7,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1				; d1.l=x*x+y*y
	bsr	Math.sqrt
	move.l	#$0FFFFFFF,d1
	divu.l	d0,d1				; g= r^-2 =1/(x*x+y*y)
	Do_SinModulo	d1
	Get_SinCos	a2,d1,d0,d1		; d0.w=sin(g), d1.w=cos(g)
	move.w	d0,d3
	move.w	d1,d2
	neg.w	d3
	muls.w	d7,d0
	muls.w	d6,d1
	muls.w	d7,d2
	muls.w	d6,d3
	
	add.l	d0,d1
	add.l	d2,d3
	add.l	d1,d1
	add.l	d3,d3
	swap	d1				; d1.w=+cos(g)*p.x+sin(g)*p.y
	swap	d3				; d3.w=-sin(g)*p.x+cos(g)*p.y

; scale down a litte to move into the vortex..
	move.w	d1,d4
	move.w	d3,d5
	muls.w	#$7A,d1
	muls.w	#$7A,d3
	muls.w	#$88,d4
	muls.w	#$88,d5
	asr.l	#8,d1				; d1.w=p'.x
	asr.l	#8,d3				; d3.w=p'.y
	asr.l	#8,d4				; d4.w=p'.x
	asr.l	#8,d5				; d5.w=p'.y

	muls.w	#320,d3
	ext.l	d1
	add.l	d1,d3
	move.l	d3,(a0)+
	muls.w	#320,d5
	ext.l	d4
	add.l	d4,d5
	move.l	d5,(a3)+

	addq.w	#2,d6
	cmpi.w	#319,d6
	ble.s	.xloop

	addq.w	#2,d7
	cmpi.w	#199,d7
	ble.s	.yloop
	
	rts

; dst and scr must not be the same!
; input:
; a0: dst screen
; a1: src screen
zoom_twirl_in:
	lea	twirl_in_map,a3
	adda.l	#320*100+160,a1
	lea	sine_tbl,a2
	clr.l	d3
	move.w	#200-1,d7

.yloop:	move.w	#320/16-1,d6

.xloop:
	rept	16
	move.l	(a3)+,d3
	move.b	(a1,d3.l),(a0)+
	endr
	dbf	d6,.xloop

	dbf	d7,.yloop
	rts

; input:
; a0: dst screen
; a1: src screen
zoom_hv:movem.l	a0/a1,-(sp)
	movea.l	service_adr,a2
	jsr	ServiceTable.GET_TIME_RUNNING(a2)
	movem.l	(sp)+,a0/a1

	adda.w	#16+320*10,a1
	movea.l	a1,a2
	move.w	#200-1,d7
	move.l	#(9<<16)/10,d4				; d4.l= step (16:16)
	clr.l	d5
	move.w	d0,d5
	divu.w	#10,d5
	clr.w	d5
	swap	d5					; d5.l= t mod 10
	mulu.w	#(1<<16)/10,d5				; 

;	adda.w	#16+320*10,a1
;	movea.l	a1,a2
;	move.w	#200-1,d7
;	move.l	#(9<<16)/10,d4
;	clr.l	d5

.yloop:	moveq	#32-1,d6

.xloop:	move.l	(a1)+,d0
	move.l	d0,(a0)+
	move.b	d0,(a0)+
	move.l	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbf	d6,.xloop

	add.l	d4,d5
	move.l	d5,d3
	swap	d3
	mulu.w	#320,d3
	lea	(a2,d3.l),a1
	dbf	d7,.yloop
	rts

; input:
; a0: dst screen
; a1: src screen
zoom_hv_slow:
	movem.l	a0/a1,-(sp)
	movea.l	service_adr,a2
	jsr	ServiceTable.GET_TIME_RUNNING(a2)
	movem.l	(sp)+,a0/a1

	adda.w	#8+320*5,a1
	movea.l	a1,a2
	move.w	#200-1,d7
	move.l	#(19<<16)/20,d4
	clr.l	d5
	move.w	d0,d5
	divu.w	#20,d5
	clr.w	d5
	swap	d5
	mulu.w	#(1<<16)/20,d5

.yloop:	moveq	#16-1,d6

.xloop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,d0
	move.l	d0,(a0)+
	move.b	d0,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbf	d6,.xloop

	add.l	d4,d5
	move.l	d5,d3
	swap	d3
	mulu.w	#320,d3
	lea	(a2,d3.l),a1
	dbf	d7,.yloop
	rts

; input:
; a0: dst screen
; a1: src screen
zoom_bil_slow:
	adda.w	#8+320*5,a1
	lea	muls_table,a3
	move.w	#200-1,d7
	move.l	#(19<<16)/20,a6			; a6=v_step

; randomize (u,v) start fractions to shake around the bilinear interpolation
; a bit. this helps reduce rough-looking 'cuts' along the axes.
	Calc_NextRandom
	clr.l	d6
	move.w	d0,d6
	divu.w	#20,d6
	clr.w	d6
	swap	d6
	mulu.w	#(1<<16)/20,d6
	subi.w	#$8000,d6
	bcc.s	.oki_y
	suba.w	#320,a1
.oki_y:
; d6.w=v_frac[0] [0..$FFFF]
	clr.l	d5
	move.w	d0,d5
	divu.w	#20,d5
	clr.w	d5
	swap	d5
	mulu.w	#(1<<16)/20,d5
	subi.w	#$8000,d5
	bcc.s	.oki_x
	subq.w	#1,a1
.oki_x:	movea.w	d5,a4
; a4.w=u_frac[0] [0..$FFFF]

	movea.l	a1,a5
	clr.l	d2
	clr.l	d5

.yloop:	swap	d7
	movea.l	a5,a1
	lea	320(a1),a2
	move.w	#320-1,d7
	move.w	a4,d3				; d3.w=u_frac[0] [0..$FFFF]
	move.w	d6,d0
	not.w	d0				; d0.w=1-v_frac[n] [0..$FFFF]
	move.w	d6,d2				; d2.w=vv--

.xloop:

	ifne	1

	move.w	d3,d5				; d5.w=uu--

; Interpolate columns..
	move.b	(a1),d1				; d1.b=hne=h[V,U]
	move.b	(a2),d2				; d2.b=hse=h[V+1,U]
	sub.b	d1,d2				; d2.b=hse-hne
	add.b	(a3,d2.l),d1			; d1.b=he=v(hse-hne)+hne
	move.b	1(a2),d2			; d2.b=hsw=h[V+1,U+1]
	move.b	1(a1),d5			; d5.b=hnw=h[V,U+1]
	sub.b	d5,d2				; d2.b=hsw-hnw
	add.b	(a3,d2.l),d5			; d5.b=hw=v(hsw-hnw)+hnw
; Interpolate row..
	sub.b	d1,d5				; d5.b=hr-hl
	add.b	(a3,d5.l),d1			; d1.b=u(hr-hl)+hl

	move.b	d1,(a0)+			; store.

	else

	move.w	d3,d4
	not.w	d4				; d4.w=1-u_frac[n] [0..$FFFF]

; d0.w=x_int
; d3.w=x_frac [0..$FFFF]
; d4.w=1-x_frac [0..$FFFF]
; d6.w=y_frac [0..$FFFF]
; a1: north east pixel
; a2: south east pixel

; interpolate top.
	clr.w	d1
	clr.w	d2
	move.b	(a1),d1
	move.b	1(a1),d2
	mulu.w	d4,d1
	mulu.w	d3,d2
	add.l	d1,d2				; d2.l=top interpolation
	swap	d2				; d2.b=btm interpolation

; interpolate bottom.
	clr.w	d1
	clr.w	d5
	move.b	(a2),d1
	move.b	1(a2),d5
	mulu.w	d4,d1
	mulu.w	d3,d5
	add.l	d1,d5				; d5.l=btm interpolation
	swap	d5				; d5.b=btm interpolation

; interpolate top and bottom results.
	mulu.w	d6,d5
	mulu.w	d0,d2
	add.l	d2,d5
	swap	d5

; store interpolation.
	move.b	d5,(a0)+

	endc

; add x_step.
	add.w	a6,d3				; d3.w=u_frac[n+1] [0..$FFFF]
	bcc.s	.skip_x
	addq	#1,a1
	addq	#1,a2
.skip_x:dbf	d7,.xloop

	add.w	a6,d6
	bcc.s	.skip
	adda.w	#320,a5
.skip:	swap	d7
	dbf	d7,.yloop
	rts

; input:
; a0: dst screen
; a1: src screen
zoom_hv_fast:
	adda.w	#32+320*20,a1
	movea.l	a1,a2
	move.w	#200-1,d7
	move.l	#(4<<16)/5,d4
	clr.l	d5
	move.l	frame_count,d0
	andi.w	#1,d0
	beq.s	.case1

.yloop:	moveq	#64-1,d6

.xloop:	move.l	(a1)+,d0
	move.l	d0,(a0)+
	move.b	d0,(a0)+
	dbf	d6,.xloop

	add.l	d4,d5
	move.l	d5,d3
	swap	d3
	mulu.w	#320,d3
	lea	(a2,d3.l),a1
	dbf	d7,.yloop
	rts

.case1:	move.l	#(2<<16)/5,d5
.yloop2:moveq	#64-1,d6

.xloop2:move.w	(a1)+,d0
	move.w	d0,(a0)+
	move.b	d0,(a0)+
	move.w	(a1)+,(a0)+
	dbf	d6,.xloop2

	add.l	d4,d5
	move.l	d5,d3
	swap	d3
	mulu.w	#320,d3
	lea	(a2,d3.l),a1
	dbf	d7,.yloop2
	rts

rts:	rts

;======= OBJECT DATA =======================================================

	data

flow_table_green:
	dc.w	4	(.end-.start)/4
	dc.w	6
.start:	dc.l	$00000000
	dc.l	$007F0000
	dc.l	$FFFF007F
	dc.l	$FFFF007F
	dc.l	$FFFF007F
.end:

flow_table_orange:
	dc.w	4	(.end-.start)/4
	dc.w	6
.start:	dc.l	$00000000
	dc.l	$AF000000
	dc.l	$FFFF007F
	dc.l	$FFFF007F
	dc.l	$FFFF007F
.end:

flow_table_purple:
	dc.w	4	(.end-.start)/4
	dc.w	6
.start:	dc.l	$00000000
	dc.l	$7F00007F
	dc.l	$FF7F00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
.end:

flow_table_blue:
	dc.w	8	(.end-.start)/4
	dc.w	5
.start:	dc.l	$00000000
	dc.l	$003F00FF
	dc.l	$7FCF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
.end:

flow_table_bluegrey:
	dc.w	8	(.end-.start)/4
	dc.w	5
.start:	dc.l	$00000000
	dc.l	$3F3F00FF
	dc.l	$CFCF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
	dc.l	$FFFF00FF
.end:

num_pals:
	dc.w	(pal_table_end-pal_table)/4

pal_table:
	dc.l	green_pal,blue_pal,purple_pal,orange_pal,bluegrey_pal
pal_table_end:

scr_adr:dc.l	screen1
buf_adr:dc.l	screen2

zoom_rout_adr:
	dc.l	zoom_bil_slow	zoom_hv
blur_rout_adr:
	dc.l	blur_dont
plot_rout_adr:
;	dc.l	plot_circle_scope_l
	dc.l	plot_hor_scopes
pal_adr:dc.l	green_pal

num_combis:
	dc.w	(combi_table_end-combi_table)/12

combi_table:
; horizontal scope works fine, but not all blur/zoom combinations are okay.
	dc.l	plot_hor_scopes,zoom_hv_slow,blur_acc
	dc.l	plot_hor_scopes,zoom_hv,blur_acc
	dc.l	plot_hor_scopes,zoom_hv,blur_crap
	dc.l	plot_hor_scopes,zoom_hv_fast,blur_crap
; polar scope only works fine with accurate blur.
	dc.l	plot_polar_scope_l,zoom_hv_slow,blur_acc
	dc.l	plot_polar_scope_l,zoom_hv,blur_acc
	dc.l	plot_polar_scope_l,zoom_hv_fast,blur_acc
; circular scope works fine with most zoom and blur settings.
	dc.l	plot_circle_scope_l,zoom_hv_slow,blur_crap
	dc.l	plot_circle_scope_l,zoom_hv,blur_crap
	dc.l	plot_circle_scope_l,zoom_hv_fast,blur_crap
	dc.l	plot_circle_scope_l,zoom_hv_slow,blur_acc
	dc.l	plot_circle_scope_l,zoom_hv,blur_acc
	dc.l	plot_circle_scope_l,zoom_hv_fast,blur_acc
; special bilinear zoom.
	dc.l	plot_circle_scope_l,zoom_bil_slow,blur_dont
	dc.l	plot_hor_scopes,zoom_bil_slow,blur_dont
; inward vortex; only looks nice with the sloppy blur.
	dc.l	plot_circle_scope_big,zoom_twirl,blur_crap
	dc.l	plot_hor_scopes,zoom_twirl,blur_crap
; outward vortex, pretty good with circle and horizontal scopes.
	dc.l	plot_circle_scope_big,zoom_twirl_in,blur_crap
	dc.l	plot_hor_scopes,zoom_twirl_in,blur_crap
	dc.l	plot_circle_scope_big,zoom_twirl_in,blur_acc
	dc.l	plot_hor_scopes,zoom_twirl_in,blur_acc
combi_table_end:

;---------------------------------------------------------------------------
; plugin reserves section
;---------------------------------------------------------------------------

	bss

service_adr:
	ds.l	1
screen:	ds.l	1

time:	ds.l	1
old_time:
	ds.l	1
frame_count:
	ds.l	1

muls_table:
	ds.b	256*256

sine_tbl:
	ds.l	sintbllen
	ds.l	1
screen1:ds.b	320*200
screen2:ds.b	320*200

green_pal:
	ds.l	256
orange_pal:
	ds.l	256
purple_pal:
	ds.l	256
blue_pal:
	ds.l	256
bluegrey_pal:
	ds.l	256

twirl_map:
	ds.l	320*200
twirl_in_map:
	ds.l	320*200
