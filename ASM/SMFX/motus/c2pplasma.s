

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1
PLASMA_EFFECT_VBL	EQU 7*25
DO_SOLID			EQU 1
VERTICAL_MOVEMENT_SPEED EQU 3
SHARE_COLOUR		EQU 1
SHOW_CPU			equ	0
USE_MYM_DUMP		equ 0
PLASMA_UNDERLINE_WAIT	EQU 200
PLASMA_PANEL_IN_WAIT_VBL	EQU 150
PLASMA_PANEL_OUT_SHORTEN_VBL	EQU 0
CHECK_VBL_OVERFLOW	EQU 0
	ENDC


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT
;    opt o-

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init

PREPBUFFER	equ 1
	IFEQ	STANDALONE
		IFEQ	PREPBUFFER
			jsr		prepPanel
		ENDC
	ENDC
	jsr		init_effect
	jsr		init_plasma

.x
	
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts


init_effect
	move.w	#$0,$ffff8240
	move.l	#memBase+65536,d0			;2
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0					;3
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts

underline	incbin	"gfx/c2p/underline.neo"

	ENDC


VIEWPORT_Y	equ	96
VIEWPORT_X	equ	12
SOURCE_Y	equ 256
SOURCE_X	equ	256


c2poffset1				dc.w	0
c2poffset2				dc.w	0
c2poffset3				dc.w	0

offset1					dc.w 	0
offset2					dc.w 	40
offset3					dc.w 	0



init_plasma
	move.l	screen1,d0
;		move.l	d0,d1
;		add.l	#32000,d1
;		move.l	d1,
	move.l	screen2,d0
		move.l	d0,d1
		add.l	#$9000,d1
		add.l	#50*160,d1
		move.l	d1,generatedC2P_copy
		add.l	#2404,d1
		move.l	d1,generatedC2PVertical
		add.l	#19586,d1
	add.l   #$10000,d0					;4
	move.l  d0,ball1pointer
	add.l	#$10000,d0					;7		56450			--> 		8*64kb = 524288		
	move.l  d0,tab2px_1p
	add.l   #$10000,d0					;5
	move.l  d0,tab2px_2p	
	add.l   #$10000,d0					;6
	move.l	d0,vertBlock0Pointer
	add.l	#19330,d0
;	IFEQ	STANDALONE
;		move.l	d0,vertBlock12Pointer
;		add.l	#19010,d0
;		move.l	d0,vertBlock8Pointer
;		add.l	#18690,d0
;		move.l	d0,vertBlock4Pointer
;		add.l	#18370,d0
;	ENDC
	move.l	d0,clearLines1Pointer
	add.l	#802,d0
	move.l	d0,clearLines2Pointer
	add.l	#802,d0
	move.l	d0,ul2ptr
	add.l	#3360,d0


	move.l	d0,panel2Pointer


	move.w	#$111,timer_b_open_curtain_stable_col+2


	IFEQ	STANDALONE
	move.l	#.wvbl,$70
	move.w	#0,$466.w
.ll
	tst.w	$466.w
	beq		.ll
	ENDC

	; do precalc
	move.w	#0,$466.w
	lea		plasma1,a0
	move.l	screen2,a1
	add.w	#32000,a1
	jsr		cranker

	lea		panel2crk,a0
	move.l	panel2Pointer,a1
	jsr		cranker


   	lea		ul2,a0
   	move.l	ul2ptr,a1
   	jsr		cranker

;	lea		plasma1,a0
	move.l	screen2,a0
	add.w	#32000,a0
	move.l	ball1pointer,a1
	jsr		genBall
	jsr		generate2pxTabsMeta					; generate the 64kb lookup tabs for 2:4 conversion
	jsr		generateC2PVertical
	jsr		generateC2PCopyMetaBall
	jsr		generateVertBlock0
	jsr		generateClearLines

;	moveq	#0,d0
;	move.w	$466.w,d0

	IFEQ	STANDALONE
		movem.l	pal+4,d0-d7
		movem.l	d0-d7,$ffff8240+4
		move.w	pal+2,$ffff8242
	ENDC

	move.w	#$2700,sr
	move.l	#plasma_vbl,$70
	move.w	#$2300,sr

	move.w	#34+16,c2poffset1
	move.w	#22,c2poffset2
	move.w	#52+54,c2poffset3

	move.w	#PLASMA_UNDERLINE_WAIT,tbwait
	move.w	#PLASMA_PANEL_IN_WAIT_VBL,drawPictureWaiter
	move.w	#2,botTimes
	nop
	nop

	move.w	#0,$466.w

.ml1	
;;;;;;;;;;;;;; META INNER
	cmp.w	#2,$466.w
	blt		.ml1
	IFEQ	CHECK_VBL_OVERFLOW
	beq		.ok
		move.b	#0,$ffffc123
		lea		$ffff8240,a0
		REPT 16
			move.w	#$700,(a0)+
		ENDR
.ok
	ENDC
		move.w	#0,$466.w
		tst.w	linesGone
		beq		.donormal
			jsr		c2p_1to2_bars
			jsr		clearLinesVertical
			jsr		copy_c2p_lines			; all
			jsr		moveStillBuffer
			jmp		.cont
.donormal
		jsr		c2p_1to2_per2			; all
		jsr		clearLinesHorizontalPlasma
		jsr		copy_c2p_lines			; all
.cont
		jsr		doc2pOffset			
		move.l	screenpointer2,$ffff8200
				swapscreens

		IFEQ	SHOW_CPU
			move.w	#$700,$ffff8240
		ENDC

		addq.w	#1,effectCounter
		cmp.w	#$4e75,savePlasmaBars
		beq		.endpart
		jmp		.ml1
.endpart
	rts
.wvbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	IFEQ	USE_MYM_DUMP
	ELSE
		jsr		musicPlayer+8
	ENDC
	rte

	IFEQ	STANDALONE
frameCounter	dc.w	0
effectCounter	dc.w	0
botTimes	dc.w	1

	ENDC

tboc2
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#open_lower_border3,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte


open_lower_border3
		move.w	#$2700,sr
		movem.l	d0/a0/a1,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	tboc2

.wait:		dcb.w	132,$4e71 

    move.b  #0,$FFFF820A.w  
    REPT 16
		nop			; 12 nops		;64
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz
    move.w	#$0,$ffff8240
	lea		.tab,a0
	add.w	.off,a0
	lea		.tabFull,a1
	add.w	(a0),a1
	lea		$ffff8240+1*2,a0
	REPT 7
	move.l	(a1)+,(a0)+
	ENDR
	move.w	(a1)+,(a0)+

	cmp.w	#30*2,.off
	beq		.testwait
		jmp		.subber
.testwait
	subq.w	#1,tboc2framewait
	bge		.kk
.subber
		sub.w	#2,.off
		bge		.kk
			move.w	#32000,tbwait
			move.w	#65*2,.off
.kk
	movem.l	(sp)+,d0/a0/a1
    rte
.off	dc.w	65*2
;--------------
;DEMOPAL - palette for underline
;--------------		
.tabFull		
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;0
	dc.w	$100,$111,$100,$100,$100,$111,$111,$111,$111,$110,$110,$110,$110,$100,$000		;30
	dc.w	$100,$111,$110,$200,$210,$221,$222,$222,$222,$221,$221,$220,$110,$100,$000		;60
	dc.w	$100,$211,$210,$310,$310,$321,$333,$333,$332,$332,$331,$220,$220,$100,$100		;90
	dc.w	$200,$211,$311,$411,$420,$421,$443,$433,$444,$442,$441,$330,$220,$111,$100		;120
	dc.w	$201,$311,$321,$421,$520,$531,$542,$544,$555,$553,$442,$330,$320,$211,$100		;150
	dc.w	$201,$311,$421,$521,$620,$632,$653,$655,$666,$653,$542,$430,$320,$211,$100		;180
	dc.w	$201,$312,$422,$522,$631,$643,$654,$765,$777,$653,$543,$430,$320,$211,$100		;210
.tab
	dc.w	0
	dc.w	30			;1
	dc.w	30			;2
	dc.w	30			;3
	dc.w	60			;4
	dc.w	60			;5
	dc.w	90			;6
	dc.w	120			;7
	dc.w	120			;8
	dc.w	150			;9
	dc.w	150			;10
	dc.w	150
	dc.w	150
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	210
	dc.w	210			;20
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210
	dc.w	210			;30		;---> first color high
	dc.w	210
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	180
	dc.w	150
	dc.w	150
	dc.w	150
	dc.w	150			;40
	dc.w	120
	dc.w	120
	dc.w	90
	dc.w	60
	dc.w	60
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	0
	dc.w	0			;50
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0	
	dc.w	0		
	dc.w	0			;60
	dc.w	0			;61
	dc.w	0			;62
	dc.w	0			;63
	dc.w	0			;64
	dc.w	0			;65
	dc.w	0
	dc.w	0
	dc.w	0





tboc2framewait	dc.w	140


timer_b_horbars
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#66,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_horbars2,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		flashPalTop+2,a0
		add.w	.palOff,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	subq.w	#1,.palWait
	bge		.skip
		move.w	#4,.palWait
		sub.w	#32,.palOff
		bge		.skip
			move.w	#0,.palOff
.skip
	rte
.palWait	dc.w	4
.palOff		dc.w	7*32

timer_b_horbars2
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#68,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_horbars3,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		flashPalMid+2,a0
		add.w	.palOff,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	subq.w	#1,.palWait
	bge		.skip
		move.w	#4,.palWait
		sub.w	#32,.palOff
		bge		.skip
			move.w	#0,.palOff
.skip
	rte
.palWait	dc.w	4
.palOff		dc.w	7*32

timer_b_horbars3
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#65-1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		flashPalBot+2,a0
		add.w	.palOff,a0
		lea		$ffff8242,a1
		move.w	(a0)+,(a1)+
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	subq.w	#1,.palWait
	bge		.skip
		move.w	#4,.palWait
		sub.w	#32,.palOff
		bge		.skip
			move.w	#0,.palOff
.skip
	rte
.palWait	dc.w	4
.palOff		dc.w	7*32
;--------------
;DEMOPAL - palette fades from white to target palettes before ROTOZOOMER transition
;--------------		
; - top bar, fade from white to target color
flashPalTop
	dc.w	$000,$201,$301,$401,$511,$611,$621,$741,$765,$741,$641,$531,$521,$411,$401,$001
	dc.w	$111,$211,$311,$411,$511,$611,$621,$741,$765,$741,$641,$532,$521,$411,$411,$111		;1
	dc.w	$222,$222,$322,$422,$522,$622,$622,$742,$765,$742,$642,$532,$522,$422,$422,$222		;2
	dc.w	$333,$333,$333,$433,$533,$633,$633,$743,$765,$743,$643,$533,$533,$433,$433,$333		;3
	dc.w	$444,$444,$444,$444,$544,$644,$644,$744,$765,$744,$644,$544,$544,$444,$444,$444		;4
	dc.w	$555,$555,$555,$555,$555,$655,$655,$755,$765,$755,$655,$555,$555,$555,$555,$555		;5
	dc.w	$666,$666,$666,$666,$666,$666,$666,$766,$766,$766,$666,$666,$666,$666,$666,$666		;6
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7

;--------------
;DEMOPAL - palette fades from white to target palettes before ROTOZOOMER transition
;--------------		
; - middle bar, fade from white to target color
flashPalMid
	dc.w	$000,$300,$310,$410,$520,$620,$630,$750,$764,$750,$650,$540,$530,$420,$410,$000
	dc.w	$111,$311,$311,$411,$521,$621,$631,$751,$764,$751,$651,$541,$531,$421,$411,$111		;1
	dc.w	$222,$322,$322,$422,$522,$622,$632,$752,$764,$752,$652,$542,$532,$422,$422,$222		;2
	dc.w	$333,$333,$333,$433,$533,$633,$633,$753,$764,$753,$653,$543,$533,$433,$433,$333		;3
	dc.w	$444,$444,$444,$444,$544,$644,$644,$754,$764,$754,$654,$544,$544,$444,$444,$444		;4
	dc.w	$555,$555,$555,$555,$555,$655,$655,$755,$765,$755,$655,$555,$555,$555,$555,$555		;5
	dc.w	$666,$666,$666,$666,$666,$666,$666,$766,$766,$766,$666,$666,$666,$666,$666,$666		;6
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7

;--------------
;DEMOPAL - palette fades from white to target palettes before ROTOZOOMER transition
;--------------		
; - bottom bar, fade from white to target color
flashPalBot
	dc.w	$000,$110,$220,$431,$541,$551,$661,$671,$676,$661,$561,$441,$441,$331,$221,$111
	dc.w	$111,$111,$221,$431,$541,$551,$661,$671,$676,$661,$561,$441,$441,$331,$221,$111		;1
	dc.w	$222,$222,$222,$432,$542,$552,$662,$672,$676,$662,$562,$442,$442,$332,$222,$222		;2
	dc.w	$333,$333,$333,$433,$543,$553,$663,$673,$676,$663,$563,$443,$443,$333,$333,$333		;3
	dc.w	$444,$444,$444,$444,$544,$554,$664,$674,$676,$664,$564,$444,$444,$444,$444,$444		;4
	dc.w	$555,$555,$555,$555,$555,$555,$665,$675,$676,$665,$565,$555,$555,$555,$555,$555		;5
	dc.w	$666,$666,$666,$666,$666,$666,$666,$676,$676,$666,$666,$666,$666,$666,$666,$666		;6
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7






plasma_vbl
	addq.w 	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblCounter

	cmp.w	#400,voxel_raster_list_off
	bge		.normal
.raster	
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_open_curtain_raster,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
		jmp		.lala
.normal
	tst.w	horizontalBarsDone
	bne		.noHorbars
.horbars
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_horbars,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
		jmp		.lala
.noHorbars
		subq.w	#1,tbwait
		blt		.doOpen
			clr.b	$fffffa1b.w			;Timer B control (stop)
			bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
			bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
			move.l	#timer_b_open_curtain_stable,$120.w
			move.b	#191,$fffffa21.w		;Timer B data
			move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
			bclr	#3,$fffffa17.w			;Automatic end of interrupt
			jmp		.lala
.doOpen
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#tboc2,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
.lala
	move.w	#0,$ffff8240

	pushall
		lea		voxel_raster_list_values,a0
		add.w	voxel_raster_list_off,a0
		move.w	(a0)+,voxel_raster_off_real


	jsr		doFlash

	movem.l	pal+2,d0-d7
	movem.l	d0-d6,$ffff8240+2
	swap	d7
	move.w	d7,$ffff8240+15*2
;	move.w	pal+2,$ffff8240+2


;		tst.w	linesGone
;		bne		.skip
			jsr		scrubMemory
			jsr		drawPicturePlasma	

		jsr		removePanelLamelsPlasma
	tst.w	horizontalBarsDone
	bne		.nosave
		jsr		savePlasmaBars
.nosave

	IFNE	STANDALONE
		IFEQ	USE_MYM_DUMP
			jsr		replayMymDump
		ELSE
			jsr		musicPlayer+8
		ENDC
	ENDC

	popall
	rte
.scrubWaiter	dc.w	150

savePlasmaBars
	move.l	screenpointer,a0
	add.w	#5*160,a0

	move.l	screen1,d0
	add.l	#32000,d0
	move.l	d0,a1
;	lea		sb1,a1
	move.w	#96-1,d7
.l1

		movem.l	(a0)+,d0-d6/a2-a6		;12 blocks = 6*16 
		movem.l	d0-d6/a2-a6,(a1)
		movem.l	(a0)+,d0-d6/a2-a6		;12 blocks = 6*16 
		movem.l	d0-d6/a2-a6,48(a1)
		lea		96(a1),a1				; next line
		lea		320-96(a0),a0			; skip line, since doubled
	dbra	d7,.l1

	move.w	#$4e75,savePlasmaBars
	rts




doFlash
	tst.w	bar1flash
	bne		.ok1
		subq.w	#1,.waiter1
		bge		.ok1
			move.w	#1,.waiter1
			lea		flash1pal,a0
			add.w	flashOff,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,pal
			sub.w	#32,flashOff
			bge		.ok1
				move.w	#0,flashOff
				move.w	#32000,.waiter1
				move.w	#32*7,flashOff
.ok1


	tst.w	bar2flash
	bne		.ok2
		subq.w	#1,.waiter2
		bge		.ok2
			move.w	#1,.waiter2
			lea		flash2pal,a0
			add.w	flashOff,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,pal
			sub.w	#32,flashOff
			bge		.ok2
				move.w	#0,flashOff
				move.w	#32000,.waiter2
				move.w	#32*7,flashOff
.ok2

	
	tst.w	bar3flash
	bne		.ok3
		subq.w	#1,.waiter3
		bge		.ok3
			move.w	#1,.waiter3
			lea		flash3pal,a0
			add.w	flashOff,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,pal
			sub.w	#32,flashOff
			bge		.ok3
				move.w	#0,flashOff
				move.w	#32000,.waiter3
				move.w	#32*7,flashOff			
.ok3	

	tst.w	horizontalBarsDone
	bne		.ok4
		subq.w	#1,.waiter4
		bge		.ok4
			move.w	#4,.waiter4
			lea		flash3pal,a0
			add.w	flashOff,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,pal
			sub.w	#32,flashOff
			bge		.ok4
				move.w	#0,flashOff
.ok4

	rts
.done1	dc.w	-1
.done2	dc.w	-1
.done3	dc.w	-1
.waiter4	dc.w	0
.waiter3	dc.w	0
.waiter2	dc.w	0
.waiter1	dc.w	0


;--------------
;DEMOPAL - start of the plasma, when the bars from voxel go down, and plasma bars come in from above
;--------------		
; - for each bar that hits the ground, a flash from white occurs and the whole plasma effect takes the end color
; - first flash / color
flash1pal	
	dc.w	$000,$111,$400,$310,$410,$510,$610,$520,$720,$630,$730,$740,$750,$760,$770,$771		;0		
	dc.w	$000,$222,$511,$421,$521,$621,$721,$631,$731,$741,$741,$751,$761,$771,$771,$772		;1
	dc.w	$000,$333,$622,$532,$632,$732,$732,$642,$742,$752,$752,$762,$772,$772,$772,$773		;2
	dc.w	$000,$444,$733,$643,$743,$743,$743,$743,$753,$763,$763,$773,$773,$773,$773,$774		;3
	dc.w	$000,$555,$744,$754,$754,$754,$754,$754,$764,$774,$774,$774,$774,$774,$774,$775		;4
	dc.w	$000,$666,$755,$765,$765,$765,$765,$765,$775,$775,$775,$775,$775,$775,$775,$776		;5
	dc.w	$000,$777,$766,$776,$776,$776,$776,$776,$776,$776,$776,$776,$776,$776,$776,$777		;6
	dc.w	$666,$777,$766,$776,$776,$776,$776,$776,$776,$776,$766,$776,$776,$776,$776,$777 	; 
;	dc.w	$000,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7
flashOff	dc.w	7*32

;--------------
;DEMOPAL - start of the plasma, when the bars from voxel go down, and plasma bars come in from above
;--------------		
; - for each bar that hits the ground, a flash from white occurs and the whole plasma effect takes the end color
; - second flash / color
flash2pal
	dc.w	$000,$201,$312,$422,$532,$653,$763,$771,$777,$763,$750,$640,$530,$420,$411,$301	;	total
	dc.w	$111,$211,$312,$422,$532,$653,$763,$772,$777,$763,$751,$641,$531,$421,$411,$311 ;   -1
	dc.w	$222,$222,$322,$422,$532,$653,$763,$772,$777,$763,$752,$642,$532,$422,$422,$322 ;   -2
	dc.w	$333,$333,$333,$433,$533,$653,$763,$773,$777,$763,$753,$643,$533,$433,$433,$333 ;   -3
	dc.w	$444,$444,$444,$444,$544,$654,$764,$774,$777,$764,$754,$644,$544,$444,$444,$444 ;   -4
	dc.w	$555,$555,$555,$555,$555,$655,$765,$775,$777,$765,$755,$655,$555,$555,$555,$555 ;   -5
	dc.w	$666,$666,$666,$666,$666,$666,$766,$776,$777,$766,$766,$666,$666,$666,$666,$666 ;   -6
	dc.w	$666,$666,$666,$666,$666,$666,$766,$776,$777,$766,$766,$666,$666,$666,$666,$666 ; 
;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777 ;   -7

;--------------
;DEMOPAL - start of the plasma, when the bars from voxel go down, and plasma bars come in from above
;--------------		
; - for each bar that hits the ground, a flash from white occurs and the whole plasma effect takes the end color
; - last flash / color
; - this last flash is the final color of the effect
flash3pal
	dc.w	$000,$212,$312,$422,$622,$732,$752,$772,$677,$466,$355,$254,$143,$033,$022,$001
	dc.w	$111,$212,$312,$422,$622,$732,$752,$772,$667,$466,$355,$254,$143,$133,$122,$111	;-1
	dc.w	$222,$222,$322,$422,$622,$732,$752,$772,$667,$466,$355,$254,$243,$233,$222,$222	;-2
	dc.w	$333,$333,$333,$433,$633,$733,$753,$773,$667,$466,$355,$354,$343,$333,$333,$333	;-3
	dc.w	$444,$444,$444,$444,$644,$744,$754,$774,$667,$466,$455,$454,$444,$444,$444,$444	;-4
	dc.w	$555,$555,$555,$555,$655,$755,$755,$775,$667,$566,$555,$555,$555,$555,$555,$555	;-5
	dc.w	$666,$666,$666,$666,$666,$766,$766,$776,$667,$666,$666,$666,$666,$666,$666,$666	;-6
	dc.w	$666,$666,$666,$666,$666,$766,$766,$776,$667,$666,$666,$666,$666,$666,$666,$666
;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777 ;-7


; new:


c2pBarsBGcol	dc.w	$111

	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	c2pBarsBGcol,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
;	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
;	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte
	ENDC

timer_b_open_curtain_raster
	move.w	c2pBarsBGcol,$ffff8240
	move.b	#0,$fffffa1b.w	
	pushd0
	move.b	voxel_raster_off_real,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	popd0
	move.l	#timer_b_voxelpal,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_voxelpal
	move.b	#0,$fffffa1b.w	
	move.b	voxel_raster_off_real+1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	pusha0
	pusha1
		lea		voxelPal+2,a0
		lea		$ffff8242,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	popa1
	popa0
	rte

;--------------
;DEMOPAL - timer b palette for the VOXEL palette for the plasma effect colors when moving down
;--------------		
voxelPal		dc.w	$000,$111,$000,$112,$212,$123,$323,$233,$432,$632,$344,$445,$742,$555,$752,$774	;$771		;0		
	


copy_c2p_lines

	move.l	screenpointer2,a6
	move.l	generatedC2P_copy,a4
	add.w	#160,a6
	jmp		(a4)

;x 	SET 0
;	REPT VIEWPORT_Y
;		movem.l	x(a6),d0-d7/a0-a5			; 56	-> 14*4								;124								;	4CEE 3FFF xxxx
;		movem.l	d0-d7/a0-a5,x+160(a6)												;124								;	48EE 3FFF xxxx+160
;		movem.l	x+56(a6),d0-d7/a0-a1		; 10*4 = 96										;128								;	4CEE 3FFF yyyy+56
;		movem.l	d0-d7/a0-a1,x+160+56(a6)	; 112		--> 48 left					;128								;	48EE 3FFF yyyy+56+160
;x	SET x+320
;	ENDR
;	rts


bar1off	dc.w	0
bar2off	dc.w	0
bar3off	dc.w	0



doc2pOffset
	add.w	#4,offset1
	cmp.w	#144*2,offset1
	bne		.done1
		move.w	#0,offset1
.done1
	add.w	#4,offset2
	cmp.w	#160*2,offset2
	bne		.done2
		move.w	#0,offset2
.done2
	add.w	#4,offset3
	cmp.w	#104*2,offset3
	bne		.done3
		move.w	#0,offset3
.done3
	rts


;doc2pOffset
;	add.w	#4,offset1
;	cmp.w	#120*2,offset1
;	bne		.done1
;		move.w	#0,offset1
;.done1
;	add.w	#4,offset2
;	cmp.w	#100*2,offset2
;	bne		.done2
;		move.w	#0,offset2
;.done2
;	add.w	#4,offset3
;	cmp.w	#150*2,offset3
;	bne		.done3
;		move.w	#0,offset3
;.done3
;	rts


c2p_1to2_bars
	subq.w	#1,.waiter
	bge		.end
	lea		c2ppath1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	move.l	ball1pointer,a0
	add.w	c2poffset1,d0
	and.w	#%1,d1
	beq		.whole1
	and.w	#-2,d0
.whole1
	add.w	d0,a0

	lea		c2ppath2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	add.w	c2poffset2,d0
	move.w	d0,d1
	move.l	ball1pointer,a1
	and.w	#%1,d1
	beq		.whole2
	and.w	#-2,d0
.whole2
	add.w	d0,a1


	lea		c2ppath3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	add.w	c2poffset3,d0
	move.l	ball1pointer,a2
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	and.w	#-2,d0
.whole3
	add.w	d0,a2

	move.l	tab2px_1p,d0
	move.l	d0,d7
	move.l	tab2px_2p,d1
	move.l	d1,d6
	move.l	screenpointer2,a6





	movem.l	a0-a2/a6,savedShit

	; use bar1off as lines shown, when bars shown > 96, then skip lines
	;	per line 204
	; offset to be adjusted per line:
	;	256 per line

	move.l	generatedC2PVertical,a5
	move.w	bar1off,d4
	neg.w	d4
	add.w	#96,d4
	bge		.ok1
		moveq	#0,d2
		lea		160(a6),a4
		lea		320(a4),a3
		REPT 4	
			move.l	d2,(a4)+
			move.l	d2,(a4)+
			move.l	d2,(a3)+
			move.l	d2,(a3)+
		ENDR

		move.w	d4,d5
		muls	#320,d5
		sub.w	d5,a6
		moveq	#0,d4
		jmp		.go1
.ok1
	add.w	d4,d4		;d
	add.w	d4,d4		;4
	move.w	d4,d2		;		d2 = 4
	add.w	d4,d4		;8
	add.w	d4,d2		;		d2 = 8 + 4
	add.w	d4,d4		;16
	add.w	d4,d4		;32
	add.w	d4,d4		;64
	add.w	d4,d2		;		d2 = 64 + 8 + 4
	move.w	d4,d5		;		d5 = 64
	add.w	d4,d4		;128
	add.w	d4,d2		;		d2 = 128 + 64 + 8 + 4
	add.w	d4,d4		;256
	add.w	d4,d5		;		d5 = 256 + 64


	add.w	d4,a0		;+*256
	add.w	d4,a1		;+*256
	add.w	d4,a2		;+*256

	sub.w	d5,a6		;-*320


;	sub.w	#10*2*160,a6				;256 + 64
;	add.w	#10*256,a0
;	add.w	#10*256,a1
;	add.w	#10*256,a2
.go1
	jsr		(a5,d2.w)
;o set 0
;	REPT VIEWPORT_Y
;		REPT VIEWPORT_X/3
;			move.w	(a0)+,d0			;8							;2							move.l	(a0)+,d0		;12
;			add.w	(a1)+,d0			;8							;2							add.l	(a1)+,d0		;16
;			add.w	(a2)+,d0			;8							;2							add.l	(a2)+,d0		;16
;			move.l	d0,a3				;4							;2							move.w	d0,d2			;4	
;			move.l	(a3),d5				;12							;2							move.l	d2,a3			;4
;			move.w	(a0)+,d1			;8							;2							move.l	(a3),d5			;12
;			add.w	(a1)+,d1			;8							;2							swap	d0				;4
;			add.w	(a2)+,d1			;8							;2							move.w	d0,d3			;4
;			move.l	d1,a3				;4							;2							move.l	d3,a3			;4
;			or.l	(a3),d5				;16		-->		84			;2							or.l	(a3),d5			;16	
;			movep.l	d5,o(a6)										;4	24						movep.l	d5,o(a6)
;o SET o+1
;			move.w	(a0)+,d0			;8
;			add.w	(a1)+,d0			;8
;			add.w	(a2)+,d0			;8
;			move.l	d0,a3				;4
;			move.l	(a3),d5				;12
;			move.w	(a0)+,d1			;8
;			add.w	(a1)+,d1			;8
;			add.w	(a2)+,d1			;8
;			move.l	d1,a3				;4
;			or.l	(a3),d5				;16							;48	* 4 + 6 = 198				
;			movep.l	d5,o(a6)
;o	SET o+7
;		ENDR
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a0
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a1
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a2							24
;o 	SET o+160+160-8*VIEWPORT_X/3
;	ENDR															;576 + 12 = 588 * 96 = 56448


	movem.l	savedShit,a0-a2/a6		; restore shit
	lea		4*4*2(a0),a0
	lea		4*4*2(a1),a1
	lea		4*4*2(a2),a2
	lea		32(a6),a6
	movem.l	a0-a2/a6,savedShit
	move.l	generatedC2PVertical,a5
	move.w	bar2off,d4

	neg.w	d4
	add.w	#96,d4
	bge		.ok2
		moveq	#0,d2
		lea		160(a6),a4
		lea		320(a4),a3
		REPT 4	
			move.l	d2,(a4)+
			move.l	d2,(a4)+
			move.l	d2,(a3)+
			move.l	d2,(a3)+
		ENDR

		move.w	d4,d5
		muls	#320,d5
		sub.w	d5,a6
		moveq	#0,d4
		jmp		.go2
.ok2
	add.w	d4,d4		;d
	add.w	d4,d4		;4
	move.w	d4,d2		;		d2 = 4
	add.w	d4,d4		;8
	add.w	d4,d2		;		d2 = 8 + 4
	add.w	d4,d4		;16
	add.w	d4,d4		;32
	add.w	d4,d4		;64
	add.w	d4,d2		;		d2 = 64 + 8 + 4
	move.w	d4,d5		;		d5 = 64
	add.w	d4,d4		;128
	add.w	d4,d2		;		d2 = 128 + 64 + 8 + 4
	add.w	d4,d4		;256
	add.w	d4,d5		;		d5 = 256 + 64


	add.w	d4,a0		;+*256
	add.w	d4,a1		;+*256
	add.w	d4,a2		;+*256

	sub.w	d5,a6		;-*320
.go2
	jsr		(a5,d2.w)

;o set 0
;	REPT VIEWPORT_Y
;		REPT VIEWPORT_X/3
;			move.w	(a0)+,d0			;8							;2							move.l	(a0)+,d0		;12
;			add.w	(a1)+,d0			;8							;2							add.l	(a1)+,d0		;16
;			add.w	(a2)+,d0			;8							;2							add.l	(a2)+,d0		;16
;			move.l	d0,a3				;4							;2							move.w	d0,d2			;4	
;			move.l	(a3),d5				;12							;2							move.l	d2,a3			;4
;			move.w	(a0)+,d1			;8							;2							move.l	(a3),d5			;12
;			add.w	(a1)+,d1			;8							;2							swap	d0				;4
;			add.w	(a2)+,d1			;8							;2							move.w	d0,d3			;4
;			move.l	d1,a3				;4							;2							move.l	d3,a3			;4
;			or.l	(a3),d5				;16		-->		84			;2							or.l	(a3),d5			;16		
;			movep.l	d5,o(a6)										;4	24						movep.l	d5,o(a6)
;o SET o+1
;			move.w	(a0)+,d0			;8
;			add.w	(a1)+,d0			;8
;			add.w	(a2)+,d0			;8
;			move.l	d0,a3				;4
;			move.l	(a3),d5				;12
;			move.w	(a0)+,d1			;8
;			add.w	(a1)+,d1			;8
;			add.w	(a2)+,d1			;8
;			move.l	d1,a3				;4
;			or.l	(a3),d5				;16							;48	* VIEWPORT_X (12)= 576		
;			movep.l	d5,o(a6)
;o	SET o+7
;		ENDR
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a0
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a1
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a2
;o 	SET o+160+160-8*VIEWPORT_X/3
;	ENDR	



	movem.l	savedShit,a0-a2/a6		; restore shit
	lea		4*4*2(a0),a0
	lea		4*4*2(a1),a1
	lea		4*4*2(a2),a2
	lea		32(a6),a6

	move.l	generatedC2PVertical,a5
	move.w	bar3off,d4

	neg.w	d4
	add.w	#96,d4
	bge		.ok3
		moveq	#0,d2
		lea		160(a6),a4
		lea		320(a4),a3
		REPT 4	
			move.l	d2,(a4)+
			move.l	d2,(a4)+
			move.l	d2,(a3)+
			move.l	d2,(a3)+
		ENDR
		move.w	d4,d5
		muls	#320,d5
		sub.w	d5,a6
		moveq	#0,d4
		jmp		.go3
.ok3
	add.w	d4,d4		;4		d									
	add.w	d4,d4		;4		4
	move.w	d4,d2		;4				d2 = 4
	add.w	d4,d4		;4		8
	add.w	d4,d2		;4				d2 = 8 + 4
	add.w	d4,d4		;4		16
	add.w	d4,d4		;4		32
	add.w	d4,d4		;4		64
	add.w	d4,d2		;4				d2 = 64 + 8 + 4
	move.w	d4,d5		;4				d5 = 64
	add.w	d4,d4		;4		128
	add.w	d4,d2		;4				d2 = 128 + 64 + 8 + 4
	add.w	d4,d4		;4		256
	add.w	d4,d5		;4				d5 = 256 + 64					--> 14 * 4 = 56
	add.w	d4,a0		;8		+*256
	add.w	d4,a1		;8		+*256
	add.w	d4,a2		;8		+*256
	sub.w	d5,a6		;8		-*320
.go3
	jsr		(a5,d2.w)


;o set 0
;	REPT VIEWPORT_Y
;		REPT VIEWPORT_X/3
;			move.w	(a0)+,d0			;8							;2							move.l	(a0)+,d0		;12
;			add.w	(a1)+,d0			;8							;2							add.l	(a1)+,d0		;16
;			add.w	(a2)+,d0			;8							;2							add.l	(a2)+,d0		;16
;			move.l	d0,a3				;4							;2							move.w	d0,d2			;4	
;			move.l	(a3),d5				;12							;2							move.l	d2,a3			;4
;			move.w	(a0)+,d1			;8							;2							move.l	(a3),d5			;12
;			add.w	(a1)+,d1			;8							;2							swap	d0				;4
;			add.w	(a2)+,d1			;8							;2							move.w	d0,d3			;4
;			move.l	d1,a3				;4							;2							move.l	d3,a3			;4
;			or.l	(a3),d5				;16		-->		84			;2							or.l	(a3),d5			;16		
;			movep.l	d5,o(a6)										;4	24						movep.l	d5,o(a6)			
;o SET o+1
;			move.w	(a0)+,d0			;8
;			add.w	(a1)+,d0			;8
;			add.w	(a2)+,d0			;8
;			move.l	d0,a3				;4
;			move.l	(a3),d5				;12
;			move.w	(a0)+,d1			;8
;			add.w	(a1)+,d1			;8
;			add.w	(a2)+,d1			;8
;			move.l	d1,a3				;4
;			or.l	(a3),d5				;16							;48	* VIEWPORT_X (12)= 576		
;			movep.l	d5,o(a6)
;o	SET o+7
;		ENDR
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a0
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a1
;		add.w	#SOURCE_X-VIEWPORT_X*8/3,a2
;o 	SET o+160+160-8*VIEWPORT_X/3
;	ENDR	

	subq.w	#1,.wait1
	bge		.skip1
		addq.w	#VERTICAL_MOVEMENT_SPEED,bar1off
		cmp.w	#98,bar1off
		ble		.skip1
			move.w	#98,bar1off
			subq.w	#1,.time1
			bge		.skip1
				move.w	#0,bar1flash
.skip1

	subq.w	#1,.wait2
	bge		.skip2
		addq.w	#VERTICAL_MOVEMENT_SPEED,bar2off
		cmp.w	#98,bar2off
		ble		.skip2
			move.w	#98,bar2off
			subq.w	#1,.time2
			bge		.skip2
				move.w	#0,bar2flash
.skip2

	subq.w	#1,.wait3
	bge		.skip3
		addq.w	#VERTICAL_MOVEMENT_SPEED,bar3off
		cmp.w	#98,bar3off
		ble		.skip3
			move.w	#98,bar3off
			subq.w	#1,.time3
			bge		.skip3
				move.w	#0,bar3flash
.skip3
.end
	rts
.time1	dc.w	1
.time2	dc.w	1
.time3	dc.w	1
.wait1	dc.w	0
.wait2	dc.w	8
.wait3	dc.w	16
	IFEQ	SHARE_COLOUR
.waiter	dc.w	10
	ELSE
.waiter	dc.w	16
	ENDC
bar1flash		dc.w	-1
bar2flash		dc.w	-1
bar3flash		dc.w	-1

savedShit	ds.l	4



c2p_1to2_per2
	lea		c2ppath1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	move.l	ball1pointer,a0
	add.w	c2poffset1,d0
	and.w	#%1,d1
	beq		.whole1
	and.w	#-2,d0
.whole1
	add.w	d0,a0

	lea		c2ppath2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	add.w	c2poffset2,d0
	move.w	d0,d1
	move.l	ball1pointer,a1
	and.w	#%1,d1
	beq		.whole2
	and.w	#-2,d0
.whole2
	add.w	d0,a1

	lea		c2ppath3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	add.w	c2poffset3,d0
	move.l	ball1pointer,a2
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	and.w	#-2,d0
.whole3
	add.w	d0,a2
	move.l	tab2px_1p,d0
	move.l	tab2px_2p,d1
	move.l	screenpointer2,a6
	add.w	#5*160,a6

	moveq	#0,d4
	move.l	d4,d6
	move.l	d4,d7
	move.l	d4,a4

	move.l	plasmaRoutList,a5
	jsr		(a5)
	add.w	#64*160,a6
	jsr		(a5)
	add.w	#64*160,a6
	jsr		(a5)
														;576 + 12 = 588 * 96 = 56448
	rts

plasmaRoutList		dc.l	0

generateVertBlock0
	move.l	vertBlock0Pointer,a6
	lea		vertBlockTemplate,a5

	move.l	(a5)+,a3			;	move.w	(a0)+,d0,	add.w	(a1)+,d0
	move.l	(a5)+,a4			;	add.w	(a2)+,d0,	move.l	d0,a3
	move.l	(a5)+,d0			;	move.l	(a3),d5		move.w	(a0)+,d1
	move.l	(a5)+,d1			;	add.w	(a1)+,d1	add.w	(a2)+,d1
	IFNE	USE_MYM_DUMP
		move.l	#$4e714e71,d1
	ENDC	
	move.l	(a5)+,d2			;	move.l	d1,a3		or.l	(a3),d5
	move.l	(a5)+,d3			;	movep.l	d5,x(a6)

	move.l	(a5)+,d5			;	lea		160(a0),a0
	move.l	(a5)+,d6			;	lea		160(a1),a1
	move.l	(a5)+,a5			;	lea		160(a1),a1

	sub.w	d3,d3				; o set 0
	move.w	#32-1,d7
.ol										; rept 32
		swap	d7
		move.w	#12-1,d7
.il
			move.l	a3,(a6)+
			move.l	a4,(a6)+
			move.l	d0,(a6)+
			move.l	d1,(a6)+
			move.l	d2,(a6)+
			move.l	d3,(a6)+			
			addq.w	#1,d3
			move.l	a3,(a6)+
			move.l	a4,(a6)+
			move.l	d0,(a6)+
			move.l	d1,(a6)+
			move.l	d2,(a6)+
			move.l	d3,(a6)+			
			addq.w	#7,d3
		dbra	d7,.il
		swap	d7
		move.l	d5,(a6)+
		move.l	d6,(a6)+
		move.l	a5,(a6)+
		add.w	#320-8*12,d3
	dbra	d7,.ol
	move.w	#$4e75,(a6)+
	sub.l	vertBlock0Pointer,a6
	move.l	vertBlock0Pointer,plasmaRoutList
;	move.b	#0,$ffffc123
	rts

vertBlockTemplate
	move.w	(a0)+,d0				;2	
	add.w	(a1)+,d0				;2		1
	add.w	(a2)+,d0				;2
	move.l	d0,a3					;2		2
	move.l	(a3),d5					;2
	move.w	(a0)+,d1				;2		3
	add.w	(a1)+,d1				;2
	add.w	(a2)+,d1				;2		4
	move.l	d1,a3					;2	
	or.l	(a3),d5					;2		5
	movep.l	d5,1234(a6)				;4		6

	add.w	#256-12*8,a0			;4
	add.w	#256-12*8,a1			;4
	add.w	#256-12*8,a2			;4



;; width = 16, then we have adding a0,a1,a2
;do32Block
;o set 0
;	REPT 32
;		REPT 12
;			move.w	(a0)+,d0			;8							;2							move.l	(a0)+,d0		;12
;			add.w	(a1)+,d0			;8							;2							add.l	(a1)+,d0		;16
;			add.w	(a2)+,d0			;8							;2							add.l	(a2)+,d0		;16
;			move.l	d0,a3				;4							;2							move.w	d0,d2			;4	
;			move.l	(a3),d5				;12							;2							move.l	d2,a3			;4
;			move.w	(a0)+,d1			;8							;2							move.l	(a3),d5			;12
;			add.w	(a1)+,d1			;8							;2							swap	d0				;4
;			add.w	(a2)+,d1			;8							;2							move.w	d0,d3			;4
;			move.l	d1,a3				;4							;2							move.l	d3,a3			;4
;			or.l	(a3),d5				;16		-->		84			;2							or.l	(a3),d5			;16		
;			movep.l	d5,o(a6)										;4	24						movep.l	d5,o(a6)
;o SET o+1
;			move.w	(a0)+,d0			;8
;			add.w	(a1)+,d0			;8
;			add.w	(a2)+,d0			;8
;			move.l	d0,a3				;4
;			move.l	(a3),d5				;12
;			move.w	(a0)+,d1			;8
;			add.w	(a1)+,d1			;8
;			add.w	(a2)+,d1			;8
;			move.l	d1,a3				;4
;			or.l	(a3),d5				;16							;48	* VIEWPORT_X (12)= 576		
;			movep.l	d5,o(a6)
;o	SET o+7
;		ENDR
;		add.w	#256-12*8,a0
;		add.w	#256-12*8,a1
;		add.w	#256-12*8,a2
;o 	SET o+160+160-8*12
;	ENDR
;	rts



generateClearLines
	move.l	clearLines1Pointer,a0			;802
	move.l	.code,d0
	move.w	#160,d0
	move.w	#320-4,d1
	move.w	#100-1,d7
.l1
		move.l	d0,(a0)+
		addq.w	#4,d0
		move.l	d0,(a0)+
		add.w	d1,d0
	dbra	d7,.l1
	move.w	#$4e75,(a0)+

	move.l	clearLines2Pointer,a0			;802
	move.w	#100*320+160,d0
	move.w	#100-1,d7
	addq.w	#4,d1
.l2
		sub.w	d1,d0
		move.l	d0,(a0)+
		addq.w	#4,d0
		move.l	d0,(a0)+
		subq.w	#4,d0
	dbra	d7,.l2
	move.w	#$4e75,(a0)+

	rts
.code
	and.l	d0,1234(a0)



clearLinesVertical
	move.l	screenpointer2,a0
	move.l	#%11111111111100001111111111110000,d0
	add.w	#3*8,a0
	move.w	.clearCounter,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	clearLines1Pointer,a1
	jsr		(a1,d2)
;.y set 160
;	REPT 100
;		and.l	d0,.y(a0)
;		and.l	d0,.y+4(a0)
;.y set .y+320
;	ENDR


	move.l	#%00001111111111110000111111111111,d0
	add.w	#5*8,a0

	move.l	clearLines2Pointer,a1
	jsr		(a1,d2)
;.y set 100*320+160
;	REPT 100
;.y set .y-320
;		and.l	d0,.y(a0)
;		and.l	d0,.y+4(a0)
;	ENDR	

	subq.w	#1,.waiter
	bge		.ok
	add.w	#2,.clearCounter
	cmp.w	#100,.clearCounter
	bne		.ok
		move.w	#$4e75,clearLinesVertical
		move.w	#0,linesGone
.ok
	rts
.waiter	dc.w	80
.clearCounter	dc.w	0
linesGone	dc.w	-1


clearLinesHorizontalPlasma
	subq.w	#1,plasmaHorizontalWaiter
	bge		.end

	move.l	screenpointer2,a0
	add.w	#(64+1)*160,a0
	lea		320(a0),a1
	lea		66*160+96(a1),a2
	lea		320(a2),a3
	moveq	#0,d0

	lea		.table,a4
	move.w	.skipNumber,d1
	cmp.w	#12,d1
	ble		.okkk
		move.w	#12,d1
.okkk
	lsl.w	#4,d1
	neg.w	d1
	jmp		(a4,d1.w)

	REPT 12
		move.l	d0,(a0)+	;
		move.l	d0,(a0)+	;
		move.l	d0,(a1)+	;
		move.l	d0,(a1)+	;
		move.l	d0,-(a2)	;
		move.l	d0,-(a2)	;
		move.l	d0,-(a3)	;
		move.l	d0,-(a3)	;	16s
	ENDR
.table

	cmp.w	#12,.skipNumber
	beq		.finish
	lea		.masks,a4
	add.w	.maskOffset,a4
	move.l	(a4)+,d0
	move.l	(a4)+,d1

	and.l	d0,(a0)+
	and.l	d0,(a0)+
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	and.l	d1,-(a2)
	and.l	d1,-(a2)
	and.l	d1,-(a3)
	and.l	d1,-(a3)

	add.w	#8,.maskOffset
	cmp.w	#4*8,.maskOffset
	bne		.ok
		move.w	#0,.maskOffset
		add.w	#1,.skipNumber
		cmp.w	#13,.skipNumber
		blt		.ok
			move.w	#13,.skipNumber
			move.w	#0,horizontalBarsDone
			move.w	#$4e75,doc2pOffset
.ok
.end
	rts
.finish
	move.w	#0,horizontalBarsDone	
	move.w	#$4e75,doc2pOffset
	rts
.maskOffset	dc.w	0
.skipNumber	dc.w	0
.masks
	dc.l	-1
	dc.l	-1
	dc.l	%00001111111111110000111111111111
	dc.l	%11111111111100001111111111110000
	dc.l	%00000000111111110000000011111111
	dc.l	%11111111000000001111111100000000
	dc.l	%00000000000011110000000000001111
	dc.l	%11110000000000001111000000000000
horizontalBarsDone	dc.w	-1
plasmaHorizontalWaiter		dc.w	PLASMA_EFFECT_VBL


scrubMemory
	subq.w	#1,.waiter
	bge		.skipscrub
	subq.w	#1,.scrubtimes
	blt		.skipscrub
;	lea		panel2+128,a0
	move.l	panel2Pointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	moveq	#0,d0
	move.w	drawOffPlasma,d0

; here we scrub some memory
		subq.w	#1,.copystuff
		blt		.skipCopy
;			lea		underline+128+23*160,a6
			move.l	ul2ptr,a6
			move.l	a1,a3
			move.l	a2,a4
			add.l	#200*160,a3
			add.l	#200*160,a4
			move.w	#21-1,d7
			moveq	#0,d1
			REPT 40
				move.l	d1,(a3)+
				move.l	d1,(a4)+
			ENDR
.ccp
				movem.l	(a6)+,d0-d6/a5
				movem.l	d0-d6/a5,(a3)
				movem.l	d0-d6/a5,(a4)
				movem.l	(a6)+,d0-d6/a5
				movem.l	d0-d6/a5,32(a3)
				movem.l	d0-d6/a5,32(a4)
				movem.l	(a6)+,d0-d6/a5
				movem.l	d0-d6/a5,64(a3)
				movem.l	d0-d6/a5,64(a4)
				movem.l	(a6)+,d0-d6/a5
				movem.l	d0-d6/a5,96(a3)
				movem.l	d0-d6/a5,96(a4)
				movem.l	(a6)+,d0-d6/a5
				movem.l	d0-d6/a5,128(a3)
				movem.l	d0-d6/a5,128(a4)
				lea		160(a3),a3
				lea		160(a4),a4
			dbra	d7,.ccp
			add.w	#22*160,.scrubber
			jmp		.skipscrub
.skipCopy
	move.l	a1,a3
	move.l	a2,a4
	move.w	.scrubber,d0
	add.w	#8*160,.scrubber
	add.w	d0,a3
	add.w	d0,a4
	add.l	#200*160,a3
	add.l	#200*160,a4
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a5
.y set 0
	REPT 8
	movem.l	d1-d7/a5,.y(a3)		;1-7
	movem.l	d1-d7/a5,.y(a4)
	movem.l	d1-d7/a5,.y+32(a3)
	movem.l	d1-d7/a5,.y+32(a4)
	movem.l	d1-d7/a5,.y+64(a3)
	movem.l	d1-d7/a5,.y+64(a4)
	movem.l	d1-d7/a5,.y+96(a3)
	movem.l	d1-d7/a5,.y+96(a4)
	movem.l	d1-d7/a5,.y+128(a3)
	movem.l	d1-d7/a5,.y+128(a4)
.y set .y+160	
	ENDR
.skipscrub
	rts
.waiter	dc.w	300
.scrubtimes	dc.w	5
.copystuff	dc.w	1
.scrubber	dc.w	0


drawPicturePlasma	
	subq.w	#1,drawPictureWaiter
	bge		.end
	move.l	panel2Pointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	moveq	#0,d0
	move.w	drawOffPlasma,d0
	tst.w	.even
	blt		.uneven
;		muls	#160,d0
		add.w	d0,a1
		add.w	d0,a2
		sub.w	#8,a1
		sub.w	#8,a2
		divs	#160,d0
		asl.w	#6,d0
		add.w	d0,a0	

		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104(a1)
		movem.l	d0-d7,104(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+160(a1)
		movem.l	d0-d7,104+160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+160(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+160(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+320(a1)
		movem.l	d0-d7,104+320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+320(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+320(a2)


;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+480(a1)
		movem.l	d0-d7,104+480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+480(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+480(a2)



		add.w	#160*8,drawOffPlasma
		cmp.w	#160*200,drawOffPlasma
		bne		.end
			neg.w	.even
			move.w	#160*196,drawOffPlasma
;			sub.w	#160,drawOffPlasma
		rts
.uneven
;		muls	#160,d0
		add.w	d0,a1
		add.w	d0,a2
		divs	#160,d0
		lsl.w	#6,d0

		add.w	d0,a0	


		sub.w	#8,a1
		sub.w	#8,a2
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104(a1)
		movem.l	d0-d7,104(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32(a1)
		movem.l	d0-d7,104+32(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+160(a1)
		movem.l	d0-d7,104+160(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+160(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+160(a2)

;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+320(a1)
		movem.l	d0-d7,104+320(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+320(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+320(a2)


;		lea		160-8*8(a0),a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+480(a1)
		movem.l	d0-d7,104+480(a2)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,104+32+480(a1)	;8+6=14=7 7*8=56
		movem.l	d0-d7,104+32+480(a2)

		sub.w	#160*8,drawOffPlasma
		bge		.end
			move.w	#$4e75,drawPicturePlasma
.end
	rts
.even	dc.w	1
drawOffPlasma	dc.w	0
drawPictureWaiter	dc.w	PLASMA_PANEL_IN_WAIT_VBL


removePanelLamelsPlasma
	cmp.w	#2+PLASMA_PANEL_OUT_SHORTEN_VBL,plasmaHorizontalWaiter
	bge		.end
	move.l	screenpointer2,a0
	add.w	#4*160+96,a0
	move.l	a0,a6
	; 192 per 8 => 24 steps
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	lea		.routList,a3
	lea		.routListTab,a4
	tst.w	.flip
	blt		.back

xx2 macro
		move.w	(a4)+,a2
		move.l	(a3,a2),a5
		move.l	a6,a0
		jsr		(a5)
		add.w	#160*14,a6
	endm
	REPT 14
			xx2
	ENDR
	neg.w	.flip
.end
	rts

.back

xx macro
		subq.w	#4,(a4)
;		bge		.ok\@
;			move.w	#0,(a4)
;.ok\@
		move.w	(a4)+,a2
		move.l	(a3,a2),a5
		move.l	a6,a0
		jsr		(a5)
		add.w	#160*14,a6
	endm
	REPT 14
			xx
	ENDR
	neg.w	.flip
	rts
.flip dc.w	1


.routListTab
.l set 10
.inc set 1
	REPT 18
	dc.w	.l*4		;0
.l set .l+.inc
	ENDR


	dc.l	.noClear2	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
	dc.l	.noClear	;0
.routList
	dc.l	.noClear	;0
	dc.l	.clear4
	dc.l	.clear3
	dc.l	.clear2
	dc.l	.clear1
	REPT 19
		dc.l	.noClear
	ENDR
;		dc.l	noClear2

.clear1
	movem.l	d0-d7,6*160(a0)
	movem.l	d0-d7,6*160+32(a0)
	movem.l	d0-d7,7*160(a0)
	movem.l	d0-d7,7*160+32(a0)
	rts
.clear2
	movem.l	d0-d7,4*160(a0)
	movem.l	d0-d7,4*160+32(a0)
	movem.l	d0-d7,5*160(a0)
	movem.l	d0-d7,5*160+32(a0)

	movem.l	d0-d7,8*160(a0)
	movem.l	d0-d7,8*160+32(a0)
	movem.l	d0-d7,9*160(a0)
	movem.l	d0-d7,9*160+32(a0)
	rts

.clear3
	movem.l	d0-d7,2*160(a0)
	movem.l	d0-d7,2*160+32(a0)
	movem.l	d0-d7,3*160(a0)
	movem.l	d0-d7,3*160+32(a0)

	movem.l	d0-d7,10*160(a0)
	movem.l	d0-d7,10*160+32(a0)
	movem.l	d0-d7,11*160(a0)
	movem.l	d0-d7,11*160+32(a0)
	rts

.clear4
	movem.l	d0-d7,0*160(a0)
	movem.l	d0-d7,0*160+32(a0)
	movem.l	d0-d7,1*160(a0)
	movem.l	d0-d7,1*160+32(a0)

	movem.l	d0-d7,12*160(a0)
	movem.l	d0-d7,12*160+32(a0)
	movem.l	d0-d7,13*160(a0)
	movem.l	d0-d7,13*160+32(a0)
	rts

.noClear2
	move.w	#$4e75,removePanelLamelsPlasma
.noClear
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; PRECALC ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; PRECALC ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; PRECALC ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generate2pxTabsMeta
	move.l	tab2px_1p,a0
	lea		TAB1P,a1
	lea		TAB2P,a2
;	jsr		calcTab
	jsr		calcTabMeta
;	jsr		calcTabMeta2

	move.l	tab2px_2p,a0
	lea		TAB3P,a1
	lea		TAB4P,a2
;	jsr		calcTab
	jsr		calcTabMeta
;	jsr		calcTabMeta2
	rts

calcTabMeta2
	move.l	#16*4-1,d7
	moveq	#0,d1
.outer
	move.l	#16*4*4-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
			cmp.w	#64,d0
			bne		.noresetin
				moveq	#0,d0
.noresetin
		dbra	d6,.inner
		addq.w	#4,d1
		cmp.w	#64,d1
		bne		.noresetout
			 moveq	#0,d1
.noresetout
	dbra	d7,.outer
	rts

calcTab
	moveq	#16-1,d7
	moveq	#0,d1
.outer
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
		dbra	d6,.inner

		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer
	rts



calcTabMeta
	move.l	#16*4-1,d7
	moveq	#0,d1
.outer
	move.l	#16*4*4-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			tst.w	.flipperinner
			bge		.up
.down		
			subq.w	#4,d0
			bge		.innerok
				neg.w	.flipperinner
				move.w	#0,d0
				jmp		.innerok
.up
			addq.w	#4,d0
			cmp.w	#64,d0
			bne		.innerok
				move.w	#60,d0
				neg.w	.flipperinner
.innerok
.noresetin
		dbra	d6,.inner

		tst.w	.flipperouter
		bge		.upouter
.downouter
		subq.w	#4,d1
		bge		.outerok
			neg.w	.flipperouter
			move.w	#0,d1
			jmp		.outerok

.upouter
		addq.w	#4,d1
		cmp.w	#64,d1
		bne		.outerok
			neg.w	.flipperouter
			move.w	#60,d1
.outerok
	dbra	d7,.outer
	rts
.flipperinner	dc.w	1
.flipperouter	dc.w	1

;$3018D059		a1
;(D059)
;$905A2640		a2
;(2640)
;$2A133218		a3
;(3218)
;$D259925A		a4
;(925A)
;$26418A93		a5
;(8A93)
;0BCE xxxx		d0
;0BCE yyyy		d1

;41E8 0060	lea x,a0
;43E9 0060	lea x,a1
;45EA 0060	lea x,a2

codeTemplateA
	move.w	(a0)+,d0
	or.w	(a1)+,d0				;a1
	or.w	(a2)+,d0
	move.l	d0,a3					;a2
	move.l	(a3),d5
	move.w	(a0)+,d1				;a3
	or.w	(a1)+,d1
	or.w	(a2)+,d1				;a4
	move.l	d1,a3
	or.l	(a3),d5					;a5
codeTemplateB
	movep.l	d5,0(a6)				;d0
	lea		160(a1),a1				;d2
	lea		160(a2),a2				;d3

	lea		160(a0),a0				;a6


;generateC2PMeta
;	move.l	generatedC2P,a0
;	movem.l	generateMBTemplate,d0/d3/a1-a5
;;	move.l	#$3018D059,a1			; 3018 = move.w (a0)+,d0	D059 = add.w	(a1)+,d0
;;	move.l	#$D05A2640,a2			; D05A = add.w	(a2)+,d0	2640 = move.l	d0,a3
;;	move.l	#$2A133218,a3			; 2A13 = move.l	(a3),d5		3218 = move.w	(a0)+,d1
;;	move.l	#$D259D25A,a4			; D259 = add.w	(a1)+,d1	D25A = add.w	(a2)+,d1
;;	move.l	#$26418A93,a5			; 2641 = move.l	d1,a3		8A93 = or.l		(a3),d5
;;	move.l	#$0BCE0000,d0			; 08CE 0000 movep.l	d5,x(a6)
;;	move.l	#$41E80060,d3			; lea +160(a0),a0
;
;
;	move.w	#SOURCE_X-12*8,d3
;	move.l	d3,a6
;	move.l	#$43E90060,d2			; lea +160(a1),a1
;	move.w	#SOURCE_X-12*8,d2
;	move.l	#$45EA0060,d3			; lea +160(a2),a2
;	move.w	#SOURCE_X-12*8,d3
;	move.w	#160,d0
;	add.w	#160,d1
;	move.w	#320-12*8,d4
;
;	move.l	#VIEWPORT_Y-1,d7
;	move.l	#12-1,d5
;
;.ol
;	move.l	d5,d6
;.il
;		move.l	a1,(a0)+
;		move.l	a2,(a0)+
;		move.l	a3,(a0)+
;		move.l	a4,(a0)+
;		move.l	a5,(a0)+
;		move.l	d0,(a0)+
;		addq.w	#1,d0
;		move.l	a1,(a0)+
;		move.l	a2,(a0)+
;		move.l	a3,(a0)+
;		move.l	a4,(a0)+
;		move.l	a5,(a0)+
;		move.l	d0,(a0)+
;		addq.w	#7,d0
;		dbra	d6,.il
;	move.l	a6,(a0)+
;	move.l	d2,(a0)+
;	move.l	d3,(a0)+
;	add.w	d4,d0
;	dbra	d7,.ol
;
;	move.w	#$4e75,(a0)+
;;	sub.l	generatedC2P,a0					;	56450
;;	move.b	#0,$ffffc123
;	rts
generateMBTemplate
	movep.l	d5,160(a6)
	lea		160(a0),a0

	move.w	(a0)+,d0
	add.w	(a1)+,d0
	add.w	(a2)+,d0
	move.l	d0,a3
	move.l	(a3),d5
	move.w	(a0)+,d1
	add.w	(a1)+,d1
	add.w	(a2)+,d1
	move.l	d1,a3
	or.l	(a3),d5

generateC2PVertical
	move.l	generatedC2PVertical,a0
	movem.l	generateMBTemplate,d0/d3/a1-a5
;	move.l	#$3018D059,a1			; 3018 = move.w (a0)+,d0	D059 = add.w	(a1)+,d0		d0
;	move.l	#$D05A2640,a2			; D05A = add.w	(a2)+,d0	2640 = move.l	d0,a3			d3
;	move.l	#$2A133218,a3			; 2A13 = move.l	(a3),d5		3218 = move.w	(a0)+,d1		a1
;	move.l	#$D259D25A,a4			; D259 = add.w	(a1)+,d1	D25A = add.w	(a2)+,d1		a2
;	move.l	#$26418A93,a5			; 2641 = move.l	d1,a3		8A93 = or.l		(a3),d5			a3
;	move.l	#$0BCE0000,d0			; 08CE 0000 movep.l	d5,x(a6)								a4
;	move.l	#$41E80060,d3			; lea +160(a0),a0											a5

	IFNE	USE_MYM_DUMP
		move.l	#$4e714e71,a2
	ENDC

	move.w	#160,d0
	move.w	#SOURCE_X-4*8,d3
	move.l	d3,a6
	move.l	#$43E90060,d2			; lea +160(a1),a1
	move.w	#SOURCE_X-4*8,d2
	move.l	#$45EA0060,d3			; lea +160(a2),a2
	move.w	#SOURCE_X-4*8,d3

	add.w	#160,d1
	move.w	#320-4*8,d4

	move.l	#VIEWPORT_Y-1,d7
	move.l	#4-1,d5

.ol
	move.l	d5,d6
.il
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#1,d0
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#7,d0
		dbra	d6,.il
	move.l	a6,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.w	d4,d0
	dbra	d7,.ol

	move.w	#$4e75,(a0)+
	sub.l	generatedC2PVertical,a0					;	19586
;	move.b	#0,$ffffc123
	rts


generateC2PCopyMetaBall
	move.l	generatedC2P_copy,a0
	move.l	.movem1regs,a1		;movem.l	x(a6),d0-d7/a0-a5
	move.l	.movem1screen,a2		;movem.l	d0-d7/a0-a5,x(a6)
	move.l	.movem2regs,a3		;movem.l	x(a6),d0-d7/a0-a1
	move.l	.movem2screen,a4		;movem.l	d0-d7/a0-a,x(a6)

	move.l	#97,d7
	moveq	#0,d0
	move.w	#160,d1

	move.w	#56,d2
	move.w	#160*2-56,d3

.loop
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x

	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160

	add.w	d2,d0				;	x+56+56
	move.l	a3,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56+56

	add.w	d2,d1				;	x+160+56+56
	move.l	a4,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56+56

	add.w	d3,d0				;	pad to next 
	add.w	d3,d1				;	pad to next

	dbra	d7,.loop

	move.w	#$4e75,(a0)+
	sub.l	generatedC2P_copy,a0			;2402
;	move.b	#0,$ffffc123
	rts
.movem1regs
	movem.l	1234(a6),d0-d7/a0-a5
.movem1screen
	movem.l	d0-d7/a0-a5,1234(a6)
.movem2regs
	movem.l	1234(a6),d0-d7/a0-a1
.movem2screen
	movem.l	d0-d7/a0-a1,1234(a6)



genBall
	move.l	a1,a2
	add.l	#255*256,a2
	move.w	#0,d6
	move.w	#128-1,d7
	move.w	#0,d0	; clear
	move.w	#0,d2
	; i dont need to inverse the bits, I need to inverse the bytes
.ol
	; first copy first 128 bytes
	REPT 32
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	ENDR
	; then inverse the following 128 bytes
	sub.w	#128,a0
	add.w	#128,a1
	add.w	#128,a2
	move.w	#32-1,d6
.il	
	REPT 128/32
		move.b	(a0)+,d0
		move.b	d0,-(a1)
		move.b	d0,-(a2)
	ENDR
	dbra	d6,.il
	add.w	#128,a1
	sub.w	#128+256,a2

	dbra	d7,.ol
	rts




	section DATA

calcTabMeta2A
	move.l	#64-1,d7
	moveq	#0,d1
.outer
	move.l	#256-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			tst.w	.flipperinner
			bge		.up
.down		
			subq.w	#4,d0
			bge		.innerok
				neg.w	.flipperinner
				move.w	#0,d0
				jmp		.innerok
.up
			addq.w	#4,d0
			cmp.w	#62*2,d0
			bne		.innerok
				move.w	#60*2,d0
				neg.w	.flipperinner
.innerok
.noresetin
		dbra	d6,.inner

		tst.w	.flipperouter
		bge		.upouter
.downouter
		subq.w	#4,d1
		bge		.outerok
			neg.w	.flipperouter
			move.w	#0,d1
			jmp		.outerok

.upouter
		addq.w	#4,d1
		cmp.w	#62*2,d1
		bne		.outerok
			neg.w	.flipperouter
			move.w	#60*2,d1
.outerok
	dbra	d7,.outer
	rts
.flipperinner	dc.w	1
.flipperouter	dc.w	1

;generate2pxTabsMeta2
;	move.l	tab2px_1p,a0
;	lea		TAB1A,a1
;	lea		TAB2A,a2
;	jsr		calcTabMeta2A
;
;	move.l	tab2px_2p,a0
;	lea		TAB3A,a1
;	lea		TAB4A,a2
;	jsr		calcTabMeta2A
;	rts






;;;;;;;;;;;;;;;;;;;; TRANSITION CODE ;;;;;;;;;;;;;;;;;;;
moveStillBuffer
		tst.w	.first
		beq		.notfirst
			subq.w	#1,.derpwaiter
			bge		.notfirst
			move.w	#0,.first
			move.l	screenpointer,a0
			move.l	screenpointer2,a1
			add.w	#64,a0
			add.w	#64,a1
			moveq	#0,d0
			move.w	#100/2-1,d7
.ddd
.x set 160
				REPT 12
					move.w	d0,.x(a0)
					move.w	d0,.x(a1)
					move.w	d0,.x+320(a0)
					move.w	d0,.x+320(a1)
.x set .x+8
				ENDR
				lea	640(a0),a0
				lea	640(a1),a1

				dbra	d7,.ddd
;				jmp		.ok3
.notfirst
		move.l	stillBuffer1,a0
		move.l	stillBuffer2,a1
		move.l	stillBuffer3,a2
		move.l	screenpointer2,a3
		add.w	#4*160+64,a3
		lea		32(a3),a4
		lea		32(a4),a5

		move.w	vert_off_left,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk1
			moveq	#0,d1
.kk1
		muls	#320,d0
		add.l	d0,a3

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a3)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip1
.cp1
		movem.l	(a0)+,d0-d6/a6
		movem.l	d0-d6/a6,(a3)
		lea		320(a3),a3
		dbra	d7,.cp1
.sskip1

		move.w	vert_off_mid,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk2
			moveq	#0,d1
.kk2
		muls	#320,d0
		add.l	d0,a4

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a4)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip2
.cp2
		movem.l	(a1)+,d0-d6/a6
		movem.l	d0-d6/a6,(a4)
		lea		320(a4),a4
		dbra	d7,.cp2
.sskip2



		move.w	vert_off_right,d0
		move.w	d0,d1
		subq.w	#2,d1
		bge		.kk3
			moveq	#0,d1
.kk3
		muls	#320,d0
		add.l	d0,a5

		moveq	#0,d0
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		move.l	d0,a6
.y set 0
		REPT 9
			movem.l	d0/d2-d7/a6,.y(a5)
.y set .y-320
		ENDR

		move.w	#96-1,d7
		sub.w	d1,d7
		blt		.sskip3
.cp3
		movem.l	(a2)+,d0-d6/a6
		movem.l	d0-d6/a6,(a5)
		lea		320(a5),a5
		dbra	d7,.cp3
.sskip3

	subq.w	#1,.waiter_left
	bge		.ok1
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_left
		cmp.w	#103,vert_off_left
		blt		.ok1
			move.w	#103,vert_off_left
.ok1

	subq.w	#1,.waiter_mid
	bge		.ok2
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_mid
		cmp.w	#103,vert_off_mid
		blt		.ok2
			move.w	#103,vert_off_mid
.ok2


	subq.w	#1,.waiter_right
	bge		.ok3
		add.w	#VERTICAL_MOVEMENT_SPEED,vert_off_right
		add.w	#12,voxel_raster_list_off

		cmp.w	#103,vert_off_right
		blt		.ok3
			move.w	#103,vert_off_right
			move.w	#$4e75,moveStillBuffer
.ok3
	rts
.derpwaiter				dc.w	1
.first					dc.w	-1
.waiter_left			dc.w	0
.waiter_mid				dc.w	8
.waiter_right			dc.w	16
.waiter					dc.w	2
vert_off_left			dc.w	0
vert_off_mid			dc.w	0
vert_off_right			dc.w	0
voxel_raster_off_real	dc.b	1,1

voxel_raster_list_off	dc.w	0

; todo we can generate or calc this realtime....
voxel_raster_list_values
.start set 1
.end   set 200-.start

		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
	REPT 195
		dc.b	.start,.end-.start
.start set .start+1
	ENDR
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start
		dc.b	.start,.end-.start

		IFEQ	STANDALONE
stillBuffer1	dc.l	sb1
stillBuffer2	dc.l	sb2
stillBuffer3	dc.l	sb3
sb1	incbin	data/c2pbars/stillbuffer1.bin		;3072
sb2	incbin	data/c2pbars/stillbuffer2.bin		;3072
sb3	incbin	data/c2pbars/stillbuffer3.bin		;3072
		ENDC



	IFEQ    STANDALONE
	    include     lib/lib.s
	    include		lib/cranker.s
	ENDC

tab2px_1p					ds.l	1
tab2px_2p					ds.l	1
ball1pointer				ds.l	1
ball2pointer				ds.l	1
ball3pointer				ds.l	1
generatedC2P				ds.l	1
generatedC2PVertical		ds.l	1
generatedC2P_copy			ds.l	1
clearLines1Pointer			ds.l	1
clearLines2Pointer			ds.l	1
vertBlock0Pointer			ds.l	1

TAB1P:
	DC.B $C0,$00,$00,$00		;0			;0000
	DC.B $C0,$00,$00,$00		;4			;1100
	DC.B $00,$C0,$00,$00		;8			
	DC.B $C0,$C0,$00,$00		;12
	DC.B $00,$00,$C0,$00		;16
	DC.B $C0,$00,$C0,$00		;20
	DC.B $00,$C0,$C0,$00		;24
	DC.B $C0,$C0,$C0,$00		;28
	DC.B $00,$00,$00,$C0		;32
	DC.B $C0,$00,$00,$C0		;36
	DC.B $00,$C0,$00,$C0		;40
	DC.B $C0,$C0,$00,$C0		;44
	DC.B $00,$00,$C0,$C0		;48
	DC.B $C0,$00,$C0,$C0		;52
	DC.B $00,$C0,$C0,$C0		;56
	DC.B $C0,$C0,$C0,$C0		;60
TAB2P:
	DC.B $30,$00,$00,$00		;0
	DC.B $30,$00,$00,$00		;4
	DC.B $00,$30,$00,$00		;8
	DC.B $30,$30,$00,$00		;12
	DC.B $00,$00,$30,$00		;16
	DC.B $30,$00,$30,$00		;20
	DC.B $00,$30,$30,$00		;24
	DC.B $30,$30,$30,$00		;28
	DC.B $00,$00,$00,$30		;32
	DC.B $30,$00,$00,$30		;36
	DC.B $00,$30,$00,$30		;40
	DC.B $30,$30,$00,$30		;44
	DC.B $00,$00,$30,$30		;48
	DC.B $30,$00,$30,$30		;52
	DC.B $00,$30,$30,$30		;56
	DC.B $30,$30,$30,$30		;60
TAB3P:
	DC.B $0C,$00,$00,$00		;0
	DC.B $0C,$00,$00,$00		;4
	DC.B $00,$0C,$00,$00		;8
	DC.B $0C,$0C,$00,$00		;12
	DC.B $00,$00,$0C,$00		;16
	DC.B $0C,$00,$0C,$00		;20
	DC.B $00,$0C,$0C,$00		;24
	DC.B $0C,$0C,$0C,$00		;28
	DC.B $00,$00,$00,$0C		;32
	DC.B $0C,$00,$00,$0C		;36
	DC.B $00,$0C,$00,$0C		;40
	DC.B $0C,$0C,$00,$0C		;44
	DC.B $00,$00,$0C,$0C		;48
	DC.B $0C,$00,$0C,$0C		;52
	DC.B $00,$0C,$0C,$0C		;56
	DC.B $0C,$0C,$0C,$0C		;60
TAB4P:
	DC.B $03,$00,$00,$00		;0
	DC.B $03,$00,$00,$00		;4
	DC.B $00,$03,$00,$00		;8
	DC.B $03,$03,$00,$00		;12
	DC.B $00,$00,$03,$00		;16
	DC.B $03,$00,$03,$00		;20
	DC.B $00,$03,$03,$00		;24
	DC.B $03,$03,$03,$00		;28
	DC.B $00,$00,$00,$03		;32
	DC.B $03,$00,$00,$03		;36
	DC.B $00,$03,$00,$03		;40
	DC.B $03,$03,$00,$03		;44
	DC.B $00,$00,$03,$03		;48
	DC.B $03,$00,$03,$03		;52
	DC.B $00,$03,$03,$03		;56
	DC.B $03,$03,$03,$03		;60




plasma1pointer	dc.l	plasma1


pal
	dc.w	$000,$102,$112,$112,$222,$322,$422,$332,$532,$442,$542,$552,$562,$663,$664,$665

	dc.w	$0222
	dc.w	$0112
	dc.w	$0222
	dc.w	$0321
	dc.w	$0331 
	dc.w	$0441 
	dc.w	$0541 
	dc.w	$0650
	dc.w	$0760 
	dc.w	$0671 
	dc.w	$0672 
	dc.w	$0673 
	dc.w	$0774 
	dc.w	$0775 
	dc.w	$0776 
	dc.w	$0777

plasma1	
	incbin	"data/c2pbars/plasma1.crk"
	even

panel2Pointer	ds.l	1
panel2crk	
;	incbin	"data/c2pbars/panel2.crk"			;	12800	/	2338
	incbin	"data/c2pbars/panel2e.crk"			;	12800	/ 	4698
	even

	include 	"data/c2pbars/c2ppath3.txt"


	IFEQ	STANDALONE
		IFEQ	PREPBUFFER
panelBuffer	ds.b	200*8*8		;12800
panel2	
	incbin		"gfx/panel2e.neo"


prepPanel
	lea		panel2+128,a0
	lea		panelBuffer,a1
.y set 0
	REPT 200
.x set .y
		REPT 8
			move.l .x(a0),(a1)+
			move.l .x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	lea		panelBuffer,a0
	move.b	#0,$ffffc123
	rts
		ENDC
	ENDC





    IFEQ    STANDALONE
	section BSS
memBase             ds.b    9*65536
screenpointer		ds.l	1
screenpointer2      ds.l    1
screen1             ds.l    1
screen2             ds.l    1
vblCounter			ds.w	1
musicInit			ds.w	1
tbwait				ds.w	1
cummulativeCount	ds.w	1
    ENDC