; There can b only one..
;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;				..lazy enaff..
; explo DSP.. bit optimised version, limited dsp/cpu use
; Halo DSP..
;  n. 40 haloa/2fps


explo.run	=	1

slidenumbers	=	5
explomaara	=	3

halocolors	=	7
halod		=	250
	IFNE	explo.run

memory	=	500*1024

Overdose_Beyond_Braindamage
	include	freeintx.s
	even

DEMO:
	move.w	activepoint,d0
	move.l	(activelist,pc,d0.w*4),a0
	jsr	(a0)
	rts

viimeinen
	st 	Space_Pressed
	rts

activepoint	dc.w	0	
activelist	
;	DC.L	explo.DSP_LOAD
;	DC.L	initexplo
;	DC.L	runexplo

	dc.l	halo.dsp_load
	dc.l	inithalo
	dc.l	runhalo

	dc.l	viimeinen
	ENDC
;------------
exploTV:
.HHT	SET 	$fe	*fe	; Horizontal Hold Timer
.HBB	SET 	$a2-4	 $cb	*cb	; Horizontal Border Begin
.HBE	SET 	$1+32-4	 $27-$27	*27	; Horizontal Border End
.HDB	SET 	$1+32-4	 $2e-40	*1c	; Horizontal Display Begin
.HDE	SET 	$a2-4	 $8f+40	*7d	; Horizontal Display End
.HSS	SET 	$d8	*d8	; Horizontal Synchro Start

.VFT	SET	$271	*271	; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$247	*265	; V BORDER BLANK
.VBE	SET 	$47	*2f	; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$47	*57	; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$247	*237	; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b	*26b	; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$183	*181	; Video Clock
.VCO	SET	$001		; Video Control
.WIDE	set	384		;screen wide (words)
.modulo	set	0		;screen modulo
.VMODE	set	$100		;screen mode (true)
; Video Control TV Bits				3 2 1 0
;	Horizontal Resolution-------------------+-+ + +
;		00: LORES (320 Pixels)		    | |
;		01: HIRES (640 Pixels)		    | |
;		10: SUPER HIRES (1280 Pixels)	    | |
;		    (shires seems to work with	    | |
;		     16 colors only (???))	    | |
;	Interlace-----------------------------------' |
;		To enable interlacing, set VFT	      |
;		bit 0 to logic 0.		      |
;	Vertical Resolution---------------------------'
;		0: 200 lines
;		1: 100 lines
	dc.w	.HHT&$1ff,.HBB&$1ff,.HBE&$1ff,.HDB&$1ff,.HDE&$1ff,.HSS&$1ff
	dc.w	.VFT&$3ff,.VBB&$3ff,.VBE&$3ff,.VDB&$3ff,.VDE&$3ff,.VSS&$3ff
	dc.w	.VCLK&$1ff,.VCO&$00f
	dc.l	.wide,.modulo,.vmode

*********************************************************************************
*
*********************************************************************************
explo_scr_cls
	move.l	d0,a0
	moveq	#0,d1
	move.w	#192*14,d7
.ww	rept	10
	move.l	d1,(a0)+
	endr
	dbf	d7,.ww
	rts

initexplo:
	move.l	#explotv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	move.l	address.freemem,d0
	add.l	#explo.ruutu+256,d0
	clr.b	d0
	move.l	d0,explorenderscreen
	move.l	d0,adr_screen1
	bsr	explo_scr_cls	
	add.l	#384*140*2+256,d0
	clr.b	d0
	move.l	d0,explovisionscreen
	bsr	explo_scr_cls	

	bsr	explo_feedtexture
	rept	1
	bsr	blurDSP			
	endr	
	bsr	explo_preinit
	bsr	explomain
	
	move.l	#omavbl,own_vbl
	addq.w	#1,activepoint

	rts
;----------------------------------------------------
omavbl:
	move.l	#$0,$ffff9800.w
	rts
;---------------------------------------------
; exploDSP by  WizTom of AGGRESSION
; kaskyt:
; 0 - get screen from DSP (192*70)
; 1 - render list (n,[x,y,size,heat,col])
; 2 - feed 2 DSP (32*32 shadegfx,32*32 X prescale,Y prescale)
;                (n,256 colslide)
; 3 - motion blur DSP screen

runexplo:
	bsr	exp.render2screen		;piirra vanha ruutuun dsp:lta
	bsr	blurDSP			
	sub.w	#1,exp.fadeout
	tst.w	exp.fadeout
	bmi.s	.skip
	bsr	feedfake
.skip
	bsr	explo_frame		;tee uusi screeni dsp:lle
	bsr	exp.doublescreen		;tuplaa vanha dsp ruutu, nayta se..
	bsr	swap_screens	
	rts

swap_screens
	lea	explorenderscreen,a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	move.l	d0,adr_screen1
	rts

explorenderscreen	dc.l	0	;piirretaan aina
explovisionscreen	dc.l	0	;naytetaan  aina
exp.fadeout	dc.w	0
;-------------------
exp.render2screen

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#0,-2(a0)		;get 15 bit gfx from DSP

	move.l	explorenderscreen(pc),a2

.sync	btst	#0,(a1)
	beq.s	.sync
	move.w	#(192*70*2/10)-1,d7
.xl:
	rept	10
	move.w	(a0),(a2)
	addq.l	#4,a2	
	endr
	dbf	d7,.xl

	rts

;---------------------------------------------
blurDSP
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#3,-2(a0)		;blur DSP 21 bit screen
	rts
;---------------------------------------------
feedfake
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

	move.w	explonumber,d7
	beq.s	.exitoi

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#1,-2(a0)		; feed fake render list

	lea	explolist,a2
.lp2	btst	#1,(a1)		
	beq.s	.lp2
	move.w	d7,(a0)

	mulu.w	#5,d7
	subq.w	#1,d7

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.w	(a2)+,(a0)
	dbf	d7,.lp1
.exitoi	rts

;---------------------------------------------
explo_feedtexture
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#2,-2(a0)		; feed gfx

	lea	shadegfx,a2
	move.w	#(32*32)-1,d7
.loop
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	(a2)+,(a0)		;shadepallo
	dbf	d7,.loop


	move.l	#1,d5
	moveq	#32-1,d7
.precalcx
	move.l	#$2000,d1		;orig size (32)
	divu.w	d5,d1
	move.l	d1,d0
*	lsr.l	#1,d0			;base = half step
	moveq	#32-1,d6
.prexb
	move.l	d0,d2
	lsr.w	#8,d2
.lp3	btst	#1,(a1)		
	beq.s	.lp3
	move.w	d2,(a0)			;absolut x position
	add.l	d1,d0
	dbf	d6,.prexb
	add.l	#1,d5
	dbf	d7,.precalcx	


	move.l	#1,d5
	moveq	#32-1,d7
.precalcy
	move.l	#$2000,d1		;orig size (32)
	divu.w	d5,d1
	move.l	d1,d0
*	lsr.l	#1,d0			;base = half step
	moveq	#32-1,d6
.preyb
	move.l	d0,d2
	lsr.w	#8,d2
	lsl.w	#5,d2
.lp4	btst	#1,(a1)		
	beq.s	.lp4
	move.w	d2,(a0)			;absolut x position
	add.l	d1,d0
	dbf	d6,.preyb
	add.l	#1,d5
	dbf	d7,.precalcy	


.lp5	btst	#1,(a1)		
	beq.s	.lp5		
	move.l	#slidenumbers,-2(a0)			;number of colorslides

	lea	colorslides,a2
	rept	slidenumbers
	bsr	.writeslide
	endr
	rts

.writeslide
	clr.l	d1
	clr.l	d2
	clr.l	d3
	move.l	(a2)+,d0			;slide $0 - d0
	move.b	d0,d1
	lsr.l	#8,d0
	move.b	d0,d2	
	lsr.l	#8,d0
	move.b	d0,d3		;RGB (3,2,1)	
	clr.l	d4
	clr.l	d5
	clr.l	d6
	move.w	#128-1,d7
.colloop
	add.l	d1,d4
	add.l	d2,d5
	add.l	d3,d6

	move.w	d6,d0
	lsl.l	#8,d0
	move.w	d5,d0
	lsl.l	#8,d0
	move.w	d4,d0
	lsr.l	#8,d0

.lp6	btst	#1,(a1)		
	beq.s	.lp6	
	move.l	d0,-2(a0)
	dbf	d7,.colloop
	rts
;---------------------------------------------
exp.doublescreen
	move.l	explorenderscreen,a0
	lea	2(a0),a1

	move.l	a0,$ffff8a24.w	;source
	move.l	a1,$ffff8a32.w	;dest
	move.l	#$00040000,$ffff8a20.w	;inc
	move.l	#$00040000,$ffff8a2e.w	;inc
	move.l	#$69000001,$ffff8a36.w	;size
	move.l	#-1,$ffff8a28.w		;mask
	move.w	#-1,$ffff8a2c.w		;mask
	move.w	#$0203,$ffff8a3a.w	;raw copy
	move.w	#$c000,$ffff8a3c.w	;blit
	
	rts
;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
explo.DSP_LOAD:
	move.w	#$2300,sr
	MOVE.W	#1,-(SP)
	move.l	#(explo.dsp_end-explo.dsp_boot)/3,-(sp)
	move.l	#explo.dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi	reset			;dsp melted beyond braindamage..

	addq.w	#1,activepoint
	rts

explo.dsp_boot
	incbin	"dsp\explo3.p56",0
	even
explo.dsp_end
	even
;----------------------------------------
*************************************************************************
*									*
* Main loop of program. Calculates specified amount (d0) of explosions.	*
* reading data from specified address (a0).				*
*									*
*************************************************************************
	
explo_preinit
	move.w	#$2300,sr
	MOVE.l	#explomaara,d0		; number of explosions to render
	LEA	explo_data,a0
	MOVE.l	a0,explosion	;address of first explosion
	SUBQ	#1,d0
	MOVE.w	d0,explocount
	rts
;-----------------
explomain
	move.w	explocount,d0
explo_main_loop:
	move.w	d0,explocount
	BSR	init_explo_asm

	MOVE.w	#0,fr_calc

	MOVE.l	explosion,a0
	MOVE.w	12(a0),d0
	MOVE.w	fr_calc,d1

explo_frame:

	BSR	do_explo_asm

	MOVE.l	explosion,a0
	MOVE.w	12(a0),d0
	MOVE.w	fr_calc,d1
	ADDQ	#1,d1
	MOVE.w	d1,fr_calc
	CMP.w	d1,d0
	BEQ	explo_done
	rts
;---------------------
explo_done:
	MOVE.l	explosion,a0
	LEA	44(a0),a0
	MOVE.l	a0,explosion
	MOVE.w	explocount,d0

	dbf	d0,explo_main_loop

	addq.w	#1,activepoint
	RTS

*************************************************************************
*									*
* Initializes explosion using given data and pseudo-random algorithm.	*
* This has to be done once before every explosion.			*
*									*
*************************************************************************

init_explo_asm:

;	particle_data:
;	x, y
;	xspeed, yspeed
;	size, sizechange
;	temp, tempchange
;	colour

	LEA	particles,a0
	LEA	sinustable,a1
	MOVE.l	explosion,a2
	MOVEQ	#0,d0
	MOVE.w	8(a2),d0	;seed in d0
	MOVE.w	10(a2),d7	;particle_amount
init_explo_loop:
	MOVEQ	#0,d2		;xpos
	MOVE.w	18(a2),d2
	SWAP	d2
	MOVE.l	d2,(a0)+
	MOVEQ	#0,d2		;ypos
	MOVE.w	20(a2),d2
	SWAP	d2
	MOVE.l	d2,(a0)+
	BSR	random		;speed
	MOVEQ	#0,d2
	MOVE.w	14(a2),d2
	MOVE.w	16(a2),d3
	SUB.w	d2,d3
	MULU	d1,d3
	move.w	#0,d3
	swap	d3
	ADD.l	d3,d2
	lsl.l	#8,d2
	BSR	random		;angle
	AND.w	#$3fc,d1
	MOVE.l	0(a1,d1.w),d4	;xspeed
	MULS.l	d2,d5:d4
	SWAP	d5
	SWAP	d4
	MOVE.w	d4,d5
	MOVEQ	#0,d4
	MOVE.w	22(a2),d4
	SWAP	d4
	ADD.l	d5,d4
	MOVE.l	d4,(a0)+
	ADD.w	#$100,d1
	AND.w	#$3fc,d1
	MOVE.l	0(a1,d1.w),d4	;yspeed
	MULS.l	d2,d5:d4
	SWAP	d5
	SWAP	d4
	MOVE.w	d4,d5
	MOVEQ	#0,d4
	MOVE.w	24(a2),d4
	SWAP	d4
	ADD.l	d5,d4
	MOVE.l	d4,(a0)+
	MOVEQ	#0,d2		;size
	MOVE.w	26(a2),d2
	SWAP	d2
	MOVE.l	d2,(a0)+
	BSR	random		;sizechange
	AND.w	#$7fff,d1
	MOVEQ	#0,d2
	MOVE.w	28(a2),d2
	MOVE.w	30(a2),d3
	SUB.w	d2,d3
	MULS	d1,d3
	ASR.l	#8,d3
	ASR.l	#3,d3
	EXT.l	d2
	ASL.l	#4,d2
	ADD.l	d3,d2
	MOVE.l	d2,(a0)+
	MOVEQ	#0,d2		;temp
	MOVE.w	32(a2),d2
	SWAP	d2
	MOVE.l	d2,(a0)+
	BSR	random		;sizechange
	AND.w	#$7fff,d1
	MOVEQ	#0,d2
	MOVE.w	34(a2),d2
	MOVE.w	36(a2),d3
	SUB.w	d2,d3
	MULS	d1,d3
	ASR.l	#8,d3
	ASR.l	#3,d3
	EXT.l	d2
	ASL.l	#4,d2
	ADD.l	d3,d2
	MOVE.l	d2,(a0)+
	BSR	random		;colour
	MOVE.w	38(a2),d2
	MOVE.w	40(a2),d3
	SUB.w	d2,d3
	MULU	d1,d3
	SWAP	d3
	ADD.w	d3,d2
	MOVE.w	d2,(a0)+
	LEA	2(a0),a0
	move.w	42(a2),exp.fadeout		;settaa rendausmaara
	DBRA	d7,init_explo_loop
	rts

*****************************************************************
*								*
* Pseudo random generator. Don't change d0 between calls!	*
*								*
*****************************************************************

random:
	MULU.l	#$41c64e6d,d0
	ADD.l	#12345,d0
	MOVE.l	d0,d1
	SWAP	d1
	RTS

*****************************************************************
*								*
* Calculates next frame of explosion: new positions, sizes and	*
* temperatures of particles and draws them onto the screen.	*
*								*
*****************************************************************

do_explo_asm:
	LEA	particles,a0
	lea	explolist,a1
	clr.w	explonumber
	move.l	explosion,a2
	MOVE.w	10(a2),d7
do_explo_loop:
;	particle_data:
;	x		0	0
;	y		1	4
;	xspeed		2	8
;	yspeed		3	12
;	size		4	16
;	sizechange	5	20
;	temp		6	24
;	tempchange	7	28
;	colour		8	32
;				36	sizeof

	MOVE.l	16(a0),d0
	MOVE.l	20(a0),d2
	ADD.l	d2,d0
	MOVE.l	d0,16(a0)	;size+sizechange
	swap	d0
	tst.w	d0
	ble	next_part

	MOVE.l	24(a0),d1
	MOVE.l	28(a0),d2
	ADD.l	d2,d1
	Ble	next_part
	MOVE.l	d1,24(a0)	;temp+tempchange

	CMP.w	#31,d0
	BLT	not_too_big
	MOVE.w	#31,d0
not_too_big:
	SWAP	d1
	CMP.w	#$ff,d1
	BLT	not_too_hot
	MOVE.w	#$ff,d1
not_too_hot:
	move.w	d0,4(a1)	;size talteen
	move.w	d1,d6
	lsl.w	#8,d6
	move.w	d6,6(a1)	;temp talteen

	MOVE.w	d0,d6		;d6 - size

	MOVE.l	(a0),d2		;d2 - ball_x
	MOVE.l	8(a0),d3	;d3 - xspeed
	MOVE.l	d3,d4

	ADD.l	d4,d2		;x+xspeed
	MOVE.l	d2,(a0)		;store new x

;explo_data:
;	air_res		0
;	bas_air_res	2
;	gravity		4
;	bas_gravity	6

	MOVE.w	(a2),d4		;air_res
	MULU	d6,d4		;*size
	MOVEQ	#0,d5
	MOVE.w	2(a2),d5	;bas_air_res
	ADD.l	d5,d4
	MOVE.l	#$10000,d5
	SUB.l	d4,d5
	MOVE.l	d5,a3
	MULS.l	d3,d4:d5
	SWAP	d4
	SWAP	d5
	MOVE.w	d5,d4
	MOVE.l	d4,8(a0)	;store new xspeed

;a3 - res.q=1-(air_res*particles(4,n)+bas_air_res)

	MOVE.l	4(a0),d3	;d3 - ball_y
	MOVE.l	12(a0),d4	;d4 - yspeed
	MOVE.l	d4,d5

	ADD.l	d5,d3		;y+yspeed
	MOVE.l	d3,4(a0)	;store new y

	MOVE.w	4(a2),d5	;gravity
	MULU	d5,d1		;*temp
	MOVEQ	#0,d5
	MOVE.w	6(a2),d5
	ADD.l	d5,d1		;bas_gravity
	ADD.l	d1,d4

;d4 - particles(3,n)+gravity*particles(6,n)+bas_gravity

	MOVE.l	a3,d1
	MULS.l	d4,d5:d1
	SWAP	d5
	SWAP	d1
	MOVE.w	d1,d5
	MOVE.l	d5,12(a0)	;store new yspeed

;	particles(3,n)*res

	move.w	#190,d0
	sub.w	d6,d0
	move.w	#139,d4
	sub.w	d6,d4
	lsr	#1,d6

	swap	d2
	SUB.w	d6,d2
	bge	not_neg_x
	moveq	#0,d2
not_neg_x:
	cmp.w	d0,d2
	ble	not_big_x
	move.w	d0,d2
not_big_x:
	move.w	d2,(a1)

	swap	d3
	SUB.w	d6,d3
	bge	not_neg_y
	moveq	#0,d3
not_neg_y:
	cmp.w	d4,d3
	ble	not_big_y
	move.w	d4,d3
not_big_y:
	move.w	d3,2(a1)

	move.w	32(a0),8(a1)

;	SUBQ	#2,d2
;	AND.w	#$ff,d2		;d2 - ball_x

;registers:
;	d0 - ballnum
; 	d2 - ball_x
;	d3 - ball_y
;	a4 - balladdr.l
;	a5 - flowtable.l
;	a6 - &drawscreen(0,0)

	add.w	#1,explonumber
	lea	10(a1),a1
next_part:
	LEA	36(a0),a0
	DBRA	d7,do_explo_loop

	RTS

;*************************************************************
;* 
;* Halopallot kolmedeessa.
;*
;*************************************************************
inithalo:
	move.l	#explotv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	move.l	address.freemem,d0
	add.l	#explo.ruutu+256,d0
	clr.b	d0
	move.l	d0,explorenderscreen
	move.l	d0,adr_screen1
	bsr	.halo_scr_cls	
	add.l	#384*140*2+256,d0
	clr.b	d0
	move.l	d0,explovisionscreen
	bsr	.halo_scr_cls	

	bsr	halo_feedtexture
	rept	1
	bsr	blurDSP			
	endr	
	move.l	#omavbl,own_vbl
	addq.w	#1,activepoint

	rts

.halo_scr_cls
	move.l	d0,a0
	moveq	#0,d1
	move.w	#192*14,d7
.ww	rept	10
	move.l	d1,(a0)+
	endr
	dbf	d7,.ww
	rts
;----------------------------------------------------
; HALO_DSP by  WizTom of AGGRESSION
; kaskyt:
; 0 - get screen from DSP (192*70)
; 1 - render list (n,[x,y,size,heat,col])
; 2 - feed 2 DSP (32*32 shadegfx,32*32 X prescale,Y prescale)
;                (n,256 colslide)
; 3 - motion blur DSP screen
;
;

runhalo:
	bsr	exp.render2screen		;piirra vanha ruutuun dsp:lta
	bsr	blurDSP			
	bsr	calchalo
	; viela vapaata cpu aikaa 70 scanlinea..
	bsr	feedhalo			;syota kordinaatiti dsp:lle
	bsr	exp.doublescreen		;tuplaa vanha dsp ruutu, nayta se..
	bsr	swap_screens	
	rts

;------------------------
feedhalo
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

	lea	halolist,a2
	move.w	(a2)+,d7			;objectin halomaara
	beq	.exitoi

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#1,-2(a0)		; feed fake render list

.lp2	btst	#1,(a1)		
	beq.s	.lp2
	move.w	d7,(a0)

	mulu.w	#5,d7
	subq.w	#1,d7

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.w	(a2)+,(a0)
	dbf	d7,.lp1
.exitoi	rts

;---------------------------------------------
halo_feedtexture
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#2,-2(a0)		; feed gfx

	lea	halogfx,a2
	move.w	#(32*32)-1,d7
.loop
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	(a2)+,(a0)		;shadepallo
	dbf	d7,.loop


	move.l	#1,d5
	moveq	#32-1,d7
.precalcx
	move.l	#$2000,d1		;orig size (32)
	divu.w	d5,d1
	move.l	d1,d0
*	lsr.l	#1,d0			;base = half step
	moveq	#32-1,d6
.prexb
	move.l	d0,d2
	lsr.w	#8,d2
.lp3	btst	#1,(a1)		
	beq.s	.lp3
	move.w	d2,(a0)			;absolut x position
	add.l	d1,d0
	dbf	d6,.prexb
	add.l	#1,d5
	dbf	d7,.precalcx	


	move.l	#1,d5
	moveq	#32-1,d7
.precalcy
	move.l	#$2000,d1		;orig size (32)
	divu.w	d5,d1
	move.l	d1,d0
*	lsr.l	#1,d0			;base = half step
	moveq	#32-1,d6
.preyb
	move.l	d0,d2
	lsr.w	#8,d2
	lsl.w	#5,d2
.lp4	btst	#1,(a1)		
	beq.s	.lp4
	move.w	d2,(a0)			;absolut x position
	add.l	d1,d0
	dbf	d6,.preyb
	add.l	#1,d5
	dbf	d7,.precalcy	


.lp5	btst	#1,(a1)		
	beq.s	.lp5		
	move.l	#halocolors,-2(a0)			;number of colorslides

	lea	halocolor,a2
	rept	halocolors
	bsr	.writeslide
	endr
	rts

.writeslide
	clr.l	d1
	clr.l	d2
	clr.l	d3
	move.l	(a2)+,d0			;slide $0 - d0
	move.b	d0,d1
	lsr.l	#8,d0
	move.b	d0,d2	
	lsr.l	#8,d0
	move.b	d0,d3		;RGB (3,2,1)	
	clr.l	d4
	clr.l	d5
	clr.l	d6
	move.w	#128-1,d7
.colloop
	add.l	d1,d4
	add.l	d2,d5
	add.l	d3,d6

	move.w	d6,d0
	lsl.l	#8,d0
	move.w	d5,d0
	lsl.l	#8,d0
	move.w	d4,d0
	lsr.l	#8,d0

.lp6	btst	#1,(a1)		
	beq.s	.lp6	
	move.l	d0,-2(a0)
	dbf	d7,.colloop
	rts
;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
halo.DSP_LOAD:
	move.w	#$2300,sr
	MOVE.W	#1,-(SP)
	move.l	#(halo.dsp_end-halo.dsp_boot)/3,-(sp)
	move.l	#halo.dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi	reset			;dsp melted beyond braindamage..

	addq.w	#1,activepoint
	rts

halo.dsp_boot
	incbin	"dsp\halo.p56",0
	even
halo.dsp_end
	even
;----------------------------------------
calchalo
	bsr	halocontrol
	bsr	halorotate
	rts
;---------------------------------
halocontrol

; control object -> haloobject
	IFNE	explo.run
	move.w	.gamma,d0
	lsl.w	#3,d0
	jsr	xsin
	add.w	#$7fff,d1
	move.w	d1,halo1+8
	ELSE
	tst.w	musasync
	beq.s	.noflash
	clr.w	musasync
	move.w	#$f000,halo1+8
.noflash
	move.w	halo1+8,d0
	sub.l	#$300,d0
	bpl.s	.noflash2
	move.w	#0,d0
.noflash2
	move.w	d0,halo1+8
	ENDC

	move.w	.alfa,d7
	add.w	#110,d7
	move.w	d7,.alfa
	move.w	d7,d0
	jsr	xsin
	move.l	d1,halo.sinalfa	
	move.w	d7,d0
	jsr	xcos
	move.l	d1,halo.cosalfa	

	move.w	.beta,d7
	add.w	#270,d7
	move.w	d7,.beta
	move.w	d7,d0
	jsr	xsin
	move.l	d1,halo.sinbeta
	move.w	d7,d0
	jsr	xcos
	move.l	d1,halo.cosbeta	

	move.w	.gamma,d7
	add.w	#321,d7
	move.w	d7,.gamma
	move.w	d7,d0
	jsr	xsin
	move.l	d1,halo.singamma	
	move.w	d7,d0
	jsr	xcos
	move.l	d1,halo.cosgamma

	rts

.alfa	dc.w	0
.beta	dc.w	0
.gamma	dc.w	0
;---------------------------------
halorotate

.sxk	EQUR	d0
.cxk	EQUR	d1
.syk	EQUR	d2
.cyk	EQUR	d3
.szk	EQUR	d4
.czk	EQUR	d5

	lea	halo.sinalfa,a0
	movem.l	(a0)+,a1-a6

	move.l	a1,.sxk
	move.l	a2,.cxk
	move.l	a3,.syk
	move.l	a4,.cyk
	move.l	a5,.szk
	move.l	a6,.czk

	asr.l	#7,.sxk
	asr.l	#7,.cxk
	asr.l	#7,.syk
	asr.l	#7,.cyk
	asr.l	#7,.szk
	asr.l	#7,.czk

	move.w	.cyk,d6
	muls.w	.czk,d6
	asr.l	#8,d6
	move.w	.sxk,d7
	muls	.syk,d7
	asr.l	#8,d7
	muls	.szk,d7
	asr.l	#8,d7
	sub.w	d7,d6
	move.w	d6,.matrix0

	move.w	.cyk,d6
	muls.w	.szk,d6
	asr.l	#8,d6
	move.w	.sxk,d7
	muls	.syk,d7
	asr.l	#8,d7
	muls	.czk,d7
	asr.l	#8,d7
	add.w	d7,d6
	move.w	d6,.matrix1

	move.w	.cxk,d6
	muls	.syk,d6
	asr.l	#8,d6
	neg.w	d6
	move.w	d6,.matrix2

	move.w	.cxk,d6
	muls	.szk,d6
	asr.l	#8,d6
	neg.w	d6
	move.w	d6,.matrix3

	move.w	.cxk,d6
	muls	.czk,d6
	asr.l	#8,d6
	move.w	d6,.matrix4

	move.w	.sxk,.matrix5

	move.w	.syk,d6
	muls.w	.czk,d6
	asr.l	#8,d6
	move.w	.sxk,d7
	muls	.cyk,d7
	asr.l	#8,d7
	muls	.szk,d7
	asr.l	#8,d7
	add.w	d7,d6
	move.w	d6,.matrix6

	move.w	.syk,d6
	muls.w	.szk,d6
	asr.l	#8,d6
	move.w	.sxk,d7
	muls	.cyk,d7
	asr.l	#8,d7
	muls	.czk,d7
	asr.l	#8,d7
	sub.w	d7,d6
	move.w	d6,.matrix7

	move.w	.cxk,d6
	muls	.cyk,d6
	asr.l	#8,d6
	move.w	d6,.matrix8

	movec	cacr,d0
	or.w	#$808,d0
	movec	d0,cacr

;------------------------------------ rotatoi matriisissa objecti

	move.l	haloobject,a0		;halo xyz source
	lea	halolist,a1		;halo xy destination

	move.w	(a0)+,d6		;halomaara
	ble	.noobject
	move.w	d6,(a1)+
	subq.w	#1,d6

.loop	movem.w	(a0)+,d0/d1/d2

	move.w	d0,d3
.matrix0	= *+2
	muls.w	#$1234,d3
	move.w	d1,d4
.matrix1	= *+2
	muls.w	#$1234,d4
	add.l	d4,d3
	move.w	d2,d4
.matrix2	= *+2
	muls.w	#$1234,d4
	add.l	d4,d3

	move.w	d0,d4
.matrix3	= *+2
	muls.w	#$1234,d4
	move.w	d1,d5
.matrix4	= *+2
	muls.w	#$1234,d5
	add.l	d5,d4
	move.w	d2,d5
.matrix5	= *+2
	muls.w	#$1234,d5
	add.l	d5,d4

.matrix6	= *+2
	muls.w	#$1234,d0
.matrix7	= *+2
	muls.w	#$1234,d1
	add.l	d1,d0
.matrix8	= *+2
	muls.w	#$1234,d2
	add.l	d2,d0

	add.l	halo.xpos,d3
	add.l	halo.ypos,d4
	asr.l	#8,d3			
	asr.l	#8,d4			
	asr.l	#7,d0			

	muls.w	#halod,d3
	muls.w	#halod,d4

	add.l	halo.zpos,d0
	bne	.nozero
	not.l	$ffff9800.w
	move.w	#1,d0
.nozero	

	divs.w	d0,d3		;perspektiivi
	divs.w	d0,d4			

	add.w	#160/2,d3
	move.w	d3,(a1)+
	add.w	#100/2,d4
	move.w	d4,(a1)+

	sub.w	#halod,d0
	asr.w	#4,d0
	bpl.s	.eiali
	moveq	#0,d0
.eiali
	cmp.w	#30,d0
	ble.s	.eiyli
	moveq	#30,d0
.eiyli
	move.w	#31,d7
	sub.w	d0,d7

	move.w	d7,(a1)+	;size
	move.w	(a0)+,(a1)+	;heat
	move.w	(a0)+,(a1)+	;col

	dbf	d6,.loop
.noobject
	rts

;-------------------------
halo.sinalfa	dc.l	0
halo.cosalfa	dc.l	0
halo.sinbeta	dc.l	0
halo.cosbeta	dc.l	0
halo.singamma	dc.l	0
halo.cosgamma	dc.l	0
halo.xpos	dc.l	0	;ñ511
halo.ypos	dc.l	0	;
halo.zpos	dc.l	(110+halod)	;

haloobject	dc.l	halo1

halocolor
	dc.l	$7f7f7f ;0 white
	dc.l	$00003f ;1 blue
	dc.l	$003f00 ;2 green
	dc.l	$3f0000 ;3 red
	dc.l	$3f003f ;4 purple
	dc.l	$3f3f00 ;5 yellow
	dc.l	$003f3f	;6 cyan

;	dc.l	$00007f
;	dc.l	$00003f
;	dc.l	$3f003f
;	dc.l	$7f003f
;	dc.l	$3f007f
;	dc.l	$003f00
;	dc.l	$003f7f

halogfx
	incbin	d:\motion\revenge\ball32.bin
	even

halo1	
	dc.w	23	; number of halos

;		x,y,size,heat,col number

	dc.w	0,0,60,$8000,3
	dc.w	0,0,70,$4000,5

	dc.w	0,0,-70,$4000,3
	dc.w	0,0,-60,$3000,1
	dc.w	0,0,-50,$4000,1
	dc.w	0,5,-40,$6000,1
	dc.w	5,0,-30,$4000,1
	dc.w	0,-5,-20,$6000,1
	dc.w	10,0,-10,$8000,1
	dc.w	0,10,0,$6000,1
	dc.w	10,0,10,$4000,1
	dc.w	-10,-10,20,$6000,1
	dc.w	-10,0,30,$8000,1
	dc.w	0,5,40,$6000,1
	dc.w	5,0,50,$4000,1

	dc.w	30,30,30,$8000,2
	dc.w	-30,30,30,$8000,3
	dc.w	-30,-30,30,$8000,4
	dc.w	30,-30,30,$8000,5

	dc.w	20,20,-30,$4000,3
	dc.w	-20,20,-30,$4000,4
	dc.w	-20,-20,-30,$4000,5
	dc.w	20,-20,-30,$4000,6


halolist
	dc.w	1	;piirrettavat halot
	ds.w	5*200	;x,y,size,heat,col

;---------------------------------------------------------------------
*********************************
*				*
* various data for explosion	*
*				*
*********************************

explo_data:
;kolmas
	Dc.w	$150	;air_res
	Dc.w	$20	;bas_air_res
	Dc.w	$80	;gravity
	Dc.w	$120	;bas_gravity
	Dc.w	43244	;seed
	Dc.w	100	;particle_amount
	Dc.w	110	;frame_amount
	Dc.w	10	;min_radius
	Dc.w	50	;max_radius
	Dc.w	40	;xpos
	Dc.w	70	;ypos
	Dc.w	2	;x_basespeed
	Dc.w	-3	;y_basespeed
	Dc.w	2	;size
	Dc.w	$100	;min_sizechange	(/16)
	Dc.w	$700	;max_sizechange	(/16)
	Dc.w	50	;temp
	Dc.w	-$300*4	;min_tempchange	(/16)
	Dc.w	-$100*4	;max_tempchange	(/16)
	Dc.w	0	;min_colour
	Dc.w	5	;max_colour
	dc.w	100	;rendatut framet ennen fadeouttia
;eka
	Dc.w	$280	;air_res
	Dc.w	$500	;bas_air_res
	Dc.w	$50	;gravity
	Dc.w	$100	;bas_gravity
	Dc.w	43244	;seed
	Dc.w	100	;particle_amount
	Dc.w	80	;frame_amount
	Dc.w	200	;min_radius
	Dc.w	550	;max_radius
	Dc.w	96	;xpos
	Dc.w	70	;ypos
	Dc.w	0	;x_basespeed
	Dc.w	-2	;y_basespeed
	Dc.w	1	;size
	Dc.w	$80	;min_sizechange	(/16)
	Dc.w	$1000	;max_sizechange	(/16)
	Dc.w	40	;temp
	Dc.w	-$366*4	;min_tempchange	(/16)
	Dc.w	-$100*4	;max_tempchange	(/16)
	Dc.w	0	;min_colour
	Dc.w	4	;max_colour
	dc.w	70	;rendatut framet ennen fadeouttia
;toka
	Dc.w	$280	;air_res
	Dc.w	$500	;bas_air_res
	Dc.w	$50	;gravity
	Dc.w	$100	;bas_gravity
	Dc.w	43244	;seed
	Dc.w	50	;particle_amount
	Dc.w	90	;frame_amount
	Dc.w	100	;min_radius
	Dc.w	550	;max_radius
	Dc.w	96	;xpos
	Dc.w	70	;ypos
	Dc.w	1	;x_basespeed
	Dc.w	-1	;y_basespeed
	Dc.w	3	;size
	Dc.w	$80	;min_sizechange	(/16)
	Dc.w	$1000	;max_sizechange	(/16)
	Dc.w	60	;temp
	Dc.w	-$366*4	;min_tempchange	(/16)
	Dc.w	-$100*4	;max_tempchange	(/16)
	Dc.w	2	;min_colour
	Dc.w	5	;max_colour
	dc.w	80	;rendatut framet ennen fadeouttia

colorslides
	dc.l	$ffffff
	dc.l	$ffff00
	dc.l	$ff8000
	dc.l	$00ffff
	dc.l	$0000ff

fr_calc:
	Dc.w	0
explosion:
	Dc.l	0	;address of current explosion data
explocount:
	Dc.w	0

sinustable:
	IncBin	"sinus.bin"
	even
;---------------------------
particles:
	Ds.l	9*160

fadedata:
	Ds.w	40

explonumber
	ds.w	1
explolist
	ds.w	5*200
;----------------------------------------
shadegfx:
	incbin	ball32.bin
	even

	RSRESET
explo.ruutu:	RS.w	384*140*2
;



