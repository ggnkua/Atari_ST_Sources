

fontheight		equ 35
fontwidth		equ 2
letterswidth	equ 20/fontwidth
lettersheight	equ 3

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
OUTTRO_FRAMES_UNTIL_NORMAL_SND	equ 50
OUTTRO_FRAMES_UNTIL_SCROLLER	equ 261
OUTTRO_SCROLLER_SPEED	equ 3
OUTTRO_HEART_SPEED		equ $9600
OUTTRO_HIGHLIGHT_OFFSET_VBL	equ 34
OUTTRO_HEART_FADE_SPEED	equ 1		; 0 fastest
OUTTRO_CINEMASCOPE		equ 0
	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	include macro.s

	IFEQ	STANDALONE
			initAndRun	init_effect

init_effect
	jsr		init_demo
	move.w	#500,effect_vbl_counter
;	jsr		prepHeart
;	jsr		prepHaxHeart
;	jsr		prepPlacHeart
;	jsr		prepCredits
	jsr		init_outtro

	rts
.demostart	
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts


init_demo
	move.w	#$777,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts
	ENDC

init_outtro_pointers
	move.l	screen2,d0
	add.l	#$20000,d0
	move.l	d0,heartBufferPointer
	add.l	#17*80*80,d0


	add.l	#1280,d0			; pointer is used also with negative offset
	move.l	d0,pixelToPreshiftOffsetTablePointer
	add.l	#1280,d0

	add.l	#160,d0
	move.l	d0,pixelToBlockOfffsetTablePointer

	add.l	#$8000,d0
	move.l	d0,preshiftFontPointer
	add.l	#$20000,d0
	move.l	d0,endHeartBufferPointer
	add.l	#14400,d0
	move.l	d0,haxHeartPointer
	add.l	#2720,d0
	move.l	d0,placHeartPointer
	add.l	#2720,d0
	move.l	d0,creditsPointer



	move.w	#$111,timer_b_open_curtain_stable_col+2
	move.w	#$111,timer_b_open_curtain+2

	lea		outtrotext,a0
	move.l	a0,_scrollerTextSourcePointer

	move.w	#$4e75,init_outtro_pointers
	rts

init_outtro
	jsr		init_outtro_pointers

	lea		haxHeartcrk,a0
	move.l	haxHeartPointer,a1
	jsr		cranker

	lea		placHeartcrk,a0
	move.l	placHeartPointer,a1
	jsr		cranker
	; here we start doing out stuff
	; first we need to get the heart in, and clear the rest

;	move.l	screen2,screenpointer
;	move.l	screen1,screenpointer2
	move.l	#heartFade_vbl,$70
	move.w	#0,$466.w
	; then we need to fade that heart in

	; then we need to copy the pixel perfect thing

	; then we need to precalc

	; we fade it inm
	; now we move the thing out
	jsr		prepHeartSprite
	jsr		preShiftHeart


	jsr		generatepixelToPreshiftOffsetTable
	jsr		generatepixelToBlockOffsetTable


	lea		endHeartcrk,a0		
	move.l	endHeartBufferPointer,a1
	jsr		cranker	

;	jsr		prepHeart


	lea		creditscrk,a0
	move.l	creditsPointer,a1
	jsr		cranker



	lea		endHeartPalette,a0
	lea		endHeartFade,a2		; dest pal
	jsr		calcFadez



.retry
	tst.w	heartDone
	beq		.retry
	IFNE	STANDALONE
	jsr		clearMem
	ENDC


	move.w	#$2700,sr
	move.l	#outtro_vbl,$70
	move.w	#$2300,sr
	move.w	#0,$466.w

	move.l	preshiftFontPointer,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	add.l	#$20000,a0

	move.w	#504-1,d7
.l
	rept 5
		movem.l	d0-d6/a1-a6,-(a0)
	endr
	dbra	d7,.l
	jsr		preShiftFontInit
	jsr		preShiftFont		

    rts

haxHeartPointer	ds.l	1
haxHeartcrk	incbin	"data/outtro/haxheart3.crk"
	even

;haxHeartBuffer	ds.b	5*8*68		;
;
;prepHaxHeart
;	lea		haxHeart+128+24+65*160,a0
;	lea		haxHeartBuffer,a1
;	move.w	#68-1,d7
;.cp
;	REPT 5
;		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a1)+
;	ENDR
;	lea		15*8(a0),a0
;	dbra	d7,.cp
;	; 5*8*68	; 2720
;	lea		haxHeartBuffer,a0
;	move.b	#0,$ffffc123
;
;	rts
;haxHeart
;	incbin	"gfx/endheart/hax1.neo"

	IFEQ	STANDALONE
timer_b_open_curtain_stable
		movem.l	d1-d2/a0,-(sp)

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		dcb.w	59-6,$4e71
timer_b_open_curtain_stable_col
		move.w	#$111,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_close_curtain_stable:	
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_stable

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte
		ENDC
	

heartFade_vbl	
	addq.w	#1,$466.w
	addq.w	#1,cummulativeCount
	move.l	screenpointer2,$ffff8200

	IFEQ	OUTTRO_CINEMASCOPE
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	ENDC


	pushall
	subq.w	#1,.first
	bge		.kk
	lea		heartFade1,a0
	add.w	heartFade1Off,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240
	subq.w	#1,.heartFadeWaiter
	bge		.kk
		move.w	#OUTTRO_HEART_FADE_SPEED,.heartFadeWaiter
		addq.w	#1,.heartFadeWaiter
		sub.w	#32,heartFade1Off
		bge		.kk
			cmp.w	#-8*32,heartFade1Off
			bge		.okk
				move.w	#-8*32,heartFade1Off
				move.l	#heartMove_vbl,$70

.okk
			lea		heartFade1,a0
			add.w	heartFade1Off,a0
			movem.l	(a0),d0-d7
			movem.l	d0-d7,$ffff8240
			IFEQ	OUTTRO_CINEMASCOPE
				move.w	#0,$ffff8240
			ENDC
			jsr		copyHaxHeart
.kk
	IFEQ	OUTTRO_CINEMASCOPE
		move.w	#0,$ffff8240
	ENDC
	jsr		copyHeartFade

    IFNE	STANDALONE
    subq.w	#1,musicSwitchWaiter
    bge		.dumper
.normal
		jsr		initloop
		jsr		replayMymDumpLoop
.dumper
		jsr		replayMymDump
.mdone
    ENDC
	    swapscreens
	popall
	rte
.first	dc.w	1
.heartFadeWaiter	dc.w	0

heartFade1Off	dc.w	7*32
	IFEQ	OUTTRO_CINEMASCOPE
	dc.w	$111,$666,$743,$632,$610,$500,$400,$300,$200,$777,$632,$610,$500,$400,$300,$200	;-14
	dc.w	$111,$555,$743,$632,$610,$500,$400,$300,$200,$666,$632,$610,$500,$400,$300,$200	;-13
;	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$666,$632,$610,$500,$400,$300,$200	;-12
	dc.w	$111,$555,$743,$632,$610,$500,$400,$300,$200,$555,$632,$610,$500,$400,$300,$200	;-11
;	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$555,$632,$610,$500,$400,$300,$200	;-10
	dc.w	$111,$544,$743,$632,$610,$500,$400,$300,$200,$544,$632,$610,$500,$400,$300,$200	;-9
;	dc.w	$000,$544,$743,$632,$610,$500,$400,$300,$200,$544,$632,$610,$500,$400,$300,$200	;-8
	dc.w	$111,$533,$732,$632,$610,$500,$400,$300,$300,$433,$632,$610,$500,$400,$300,$300	;-7
;	dc.w	$000,$533,$732,$632,$610,$500,$400,$300,$300,$433,$632,$610,$500,$400,$300,$300	;-6
	dc.w	$111,$422,$621,$621,$610,$500,$400,$300,$300,$422,$621,$610,$500,$400,$300,$300	;-5
;	dc.w	$000,$422,$621,$621,$610,$500,$400,$300,$300,$422,$621,$610,$500,$400,$300,$300	;-4
	dc.w	$111,$411,$511,$410,$510,$500,$400,$300,$300,$411,$610,$610,$500,$410,$400,$400	;-3
;	dc.w	$000,$411,$511,$410,$510,$500,$400,$300,$300,$411,$610,$610,$500,$410,$400,$400	;-2
	dc.w	$111,$400,$400,$400,$400,$400,$400,$400,$400,$400,$510,$510,$510,$510,$510,$510	;-1
heartFade1	
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$111,$111,$000,$000,$000,$400,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$111,$111,$000,$000,$000,$300,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$111,$111,$000,$000,$000,$300,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$110,$111,$000,$000,$000,$200,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$210,$111,$000,$000,$000,$200,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$310,$200,$000,$000,$000,$100,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$410,$300,$000,$000,$000,$100,$510
	dc.w	$111,$770,$000,$000,$400,$000,$000,$000,$000,$510,$400,$000,$000,$000,$000,$510
	ELSE
	dc.w	$000,$666,$743,$632,$610,$500,$400,$300,$200,$777,$632,$610,$500,$400,$300,$200	;-14
	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$666,$632,$610,$500,$400,$300,$200	;-13
;	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$666,$632,$610,$500,$400,$300,$200	;-12
	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$555,$632,$610,$500,$400,$300,$200	;-11
;	dc.w	$000,$555,$743,$632,$610,$500,$400,$300,$200,$555,$632,$610,$500,$400,$300,$200	;-10
	dc.w	$000,$544,$743,$632,$610,$500,$400,$300,$200,$544,$632,$610,$500,$400,$300,$200	;-9
;	dc.w	$000,$544,$743,$632,$610,$500,$400,$300,$200,$544,$632,$610,$500,$400,$300,$200	;-8
	dc.w	$000,$533,$732,$632,$610,$500,$400,$300,$300,$433,$632,$610,$500,$400,$300,$300	;-7
;	dc.w	$000,$533,$732,$632,$610,$500,$400,$300,$300,$433,$632,$610,$500,$400,$300,$300	;-6
	dc.w	$000,$422,$621,$621,$610,$500,$400,$300,$300,$422,$621,$610,$500,$400,$300,$300	;-5
;	dc.w	$000,$422,$621,$621,$610,$500,$400,$300,$300,$422,$621,$610,$500,$400,$300,$300	;-4
	dc.w	$000,$411,$511,$410,$510,$500,$400,$300,$300,$411,$610,$610,$500,$410,$400,$400	;-3
;	dc.w	$000,$411,$511,$410,$510,$500,$400,$300,$300,$411,$610,$610,$500,$410,$400,$400	;-2
	dc.w	$000,$400,$400,$400,$400,$400,$400,$400,$400,$400,$510,$510,$510,$510,$510,$510	;-1
heartFade1	
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$400,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$300,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$300,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$100,$000,$000,$000,$000,$200,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$200,$100,$000,$000,$000,$200,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$300,$200,$000,$000,$000,$100,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$400,$300,$000,$000,$000,$100,$510
	dc.w	$000,$770,$000,$000,$400,$000,$000,$000,$000,$510,$400,$000,$000,$000,$000,$510
	ENDC

copyHaxHeart
;	lea		haxHeart+128+24+64*160,a0
;	lea		haxHeartBuffer,a0
	move.l	haxHeartPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#24+65*160,a1
	add.w	#24+65*160,a2
	move.w	#68-1,d7
.cp
	REPT 5
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	ENDR
;	lea		15*8(a0),a0
	lea		15*8(a1),a1
	lea		15*8(a2),a2
	dbra	d7,.cp
	move.w	#$4e75,copyHaxHeart
	rts


placHeartPointer	ds.l	1
placHeartcrk		incbin	"data/outtro/placheart2.crk"
	even

;placHeart
;	incbin	"gfx/endheart/heart1.neo"
;
;
;placHeartBuffer	ds.b	5*8*68		;2720
;
;prepPlacHeart
;	lea		placHeart+128+64*160+24,a0
;	lea		placHeartBuffer,a1
;
;	move.w	#68-1,d7
;.cp
;	REPT 5
;		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a1)+
;	ENDR
;	lea		160-40(a0),a0
;	dbra	d7,.cp
;
;	; 5*8*65
;	lea		placHeartBuffer,a0			;2720
;	move.b	#0,$ffffc123
;	rts



copyHeartFade
	; first clear screen, then copy heart
	move.l	screenpointer2,a6
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	add.w	#32000,a6
	;d0-d7/a0-a5	=	14*4 = 56
	REPT 571
		movem.l	d0-d7/a0-a5,-(a6)
	ENDR
	; 24 left
	movem.l	d0-d5,-(a6)

;	lea		placHeartBuffer,a5
	move.l	placHeartPointer,a5

;	lea		placHeart+128+65*160+24,a5
	move.l	screenpointer2,a6
	add.w	#64*160+24,a6
	move.w	#68-1,d7
.cp
	REPT 5
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
	ENDR
;	lea		160-40(a5),a5
	lea		160-40(a6),a6
	dbra	d7,.cp


	subq.w	#1,.times2
	bge		.k2
		move.w	#$4e75,copyHeartFade
.k2
	rts
.times2	dc.w	1




heartBufferPointer		dc.l	0


heartPositionList
.off set 0
	REPT 16
		dc.l	-8,.off
.off set .off+80*80
	ENDR
.off set 0
	REPT 16
		dc.l	0,.off
.off set .off+80*80
	ENDR


prepHeartSprite
;	lea		haxHeart+128,a0
;	lea		haxHeartBuffer,a0
;	add.w	#64*160,a0
	move.l	haxHeartPointer,a0
	move.l	heartBufferPointer,a1
	move.w	#68-1,d7
	moveq	#0,d0
.cp
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	REPT 10-5
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	REPT 2
		move.l	d0,(A1)+
		move.l	d0,(A1)+
	ENDR	

	dbra	d7,.cp
	move.w	#16-1,d7
.cp2
	REPT 10
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cp2

	rts

heartPositionY 		dc.l	64<<16
heartDone			dc.w	0
movedir				dc.w	1
heartXPosition		dc.w	16


drawHeartSprite
	move.l	heartBufferPointer,a0
	move.l	screenpointer2,a1
	lea		heartPositionList,a2

	lea		.move1,a5
	lea		.move2,a6
	add.w	.moveStep1,a5
	add.w	.moveStep2,a6
	add.w	#2,.moveStep1
	cmp.w	#50*2,.moveStep1
	bne		.k1
		move.w	#0,.moveStep1
.k1
	add.w	#2,.moveStep2
	cmp.w	#30*2,.moveStep2
	bne		.k2
		move.w	#0,.moveStep2
.k2
	move.w	(a5),d0
	add.w	(a6),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a2



;	move.w	heartXPosition,d0
;	add.w	d0,d0
;	add.w	d0,d0
;	add.w	d0,d0
;	add.w	d0,a2
	add.l	(a2)+,a1
	add.l	(a2)+,a0



;	tst.w	movedir
;	blt		.left
;.right
;		add.w	#1,heartXPosition
;		cmp.w	#30,heartXPosition
;		ble		.donem
;			neg.w	movedir
;			jmp		.donem
;.left
;		sub.w	#1,heartXPosition
;		bgt		.donem
;			neg.w	movedir
;
;.donem
	
	move.w	heartPositionY,d0			; this is 64, normal offset
	bge		.wegood
		; now we are less
		neg.w	d0
		move.w	d0,d1
		muls	#80,d1
		add.w	d1,a0
		move.w	#80-1,d7
		sub.w	d0,d7
		bge		.go
			move.w	#-1,heartDone

.wegood
	muls	#160,d0
	add.w	d0,a1

	move.w	#80-1,d7					; this is 80, normal times

.go

.cp
	REPT 10
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	lea		80(a1),a1

	dbra	d7,.cp

	IFEQ	OUTTRO_CINEMASCOPE
		move.l	screenpointer2,a0
		moveq	#0,d0
		REPT 40
			move.l	d0,(a0)+
		ENDR
	ENDC


	rts
.moveStep1	dc.w	0
.moveStep2	dc.w	0
.move1	
	include	"data/outtro/step1.s"
.move2	
	include	"data/outtro/step2.s"



preShiftHeart
	move.l	heartBufferPointer,a0
	lea		80*80(a0),a1
	move.w	#15-1,d7			;15 more shifts
.doShift
		move.w	#80-1,d6
.doLine
		move.l	a0,a2
		move.l	a1,a3
.doPlane
	REPT 4
		moveq	#0,d0
		roxr.w	d0

		move.w	(a0),d0
		move.w	8(a0),d1
		move.w	16(a0),d2
		move.w	24(a0),d3
		move.w	32(a0),d4

		roxr.w	d0
		roxr.w	d1
		roxr.w	d2
		roxr.w	d3
		roxr.w	d4

		move.w	d0,(a1)
		move.w	d1,8(a1)
		move.w	d2,16(a1)
		move.w	d3,24(a1)
		move.w	d4,32(a1)

		move.w	40(a0),d0
		move.w	48(a0),d1
		move.w	56(a0),d2
		move.w	64(a0),d3
		move.w	72(a0),d4

		roxr.w	d0
		roxr.w	d1
		roxr.w	d2
		roxr.w	d3
		roxr.w	d4

		move.w	d0,40(a1)
		move.w	d1,48(a1)
		move.w	d2,56(a1)
		move.w	d3,64(a1)
		move.w	d4,72(a1)
		lea	2(a0),a0
		lea	2(a1),a1
	ENDR
	lea		80(a2),a0
	lea		80(a3),a1
	dbra	d6,.doLine
	dbra	d7,.doShift
	rts



heartMove_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	move.l	screenpointer2,$ffff8200
	IFEQ	OUTTRO_CINEMASCOPE
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	ENDC


	pushall

	jsr		drawHeartSprite

	sub.l	#OUTTRO_HEART_SPEED,heartPositionY


    IFNE	STANDALONE
    subq.w	#1,musicSwitchWaiter
    bge		.dumper
.normal
		jsr		initloop
		jsr		replayMymDumpLoop
.dumper
		jsr		replayMymDump
.mdone
    ENDC
	    swapscreens

	popall
	rte

	IFNE	STANDALONE
initloop
	move.l	musicpointer,musicPointerStart
	move.w	#192*2-1,mymFrames
	move.w	#$4e75,initloop
	rts

timer_b_open_curtain
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte

	ENDC




outtro_vbl
    addq.w  #1,$466.w
    	move.l	screenpointer2,$ffff8200
    pushall

    tst.w	.heartFadeOff
    bne		.done
    	cmp.w	#$4e75,doCreditsFades
    	beq		.highlights
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	IFEQ	OUTTRO_CINEMASCOPE
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkrc,$120.w
	ELSE
	move.b	#61,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkr,$120.w
	ENDC
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		jmp		.tbdone
.highlights
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	IFEQ	OUTTRO_CINEMASCOPE
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkr_highc,$120.w
	ELSE
	move.b	#61,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkr_high,$120.w
	ENDC
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		jsr		doCreditHighLight
		jmp		.tbdone
.done

	IFEQ	OUTTRO_CINEMASCOPE
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	ENDC


.tbdone


    subq.w	#1,.firstFrame
    blt		.fadeIn
    IFEQ	OUTTRO_CINEMASCOPE
    move.w	#$111,d0
    ELSE
    move.w	#$000,d0
    ENDC
    lea		$ffff8240,a0
    rept 16
    	move.w	d0,(a0)+
    endr	
	    move.w	#0,$ffff8240
    jsr		copyEndHeart
    jsr		copyCredits
    jmp		.paldone
.fadeIn
		lea		endHeartFade,a0
		add.w	.heartFadeOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
	    move.w	#0,$ffff8240
		subq.w	#1,.fadeWaiter
		bge		.paldone
			move.w	#3,.fadeWaiter
			sub.w	#32,.heartFadeOff
			bge		.paldone
				move.w	#0,.heartFadeOff
				move.w	#-1,.firstFrame
.paldone
	tst.w	.heartFadeOff
	bne		.nofad
	jsr		doCreditsFades
.nofad

	subq.w	#1,.scrollerWait
	bge		.skipscroll
		move.w	#$245,d0
		lea		$ffff8240+8*2,a0
		REPT 8
			move.w	d0,(a0)+
		ENDR
	    move.w	#0,$ffff8240
	jsr		clearFontLine
	jsr		drawStringAtPixel
	jsr		advancePixelPosition
	move.w	#-1,.scrollerWait
.skipscroll

    IFNE	STANDALONE
    subq.w	#1,musicSwitchWaiter
    bge		.dumper
.normal
		move.w	#-1,musicSwitchWaiter
		jsr		initloop
		jsr		replayMymDumpLoop
    	jmp		.mdone
.dumper
		jsr		replayMymDump
.mdone
    ENDC
	    swapscreens
    popall
    rte
.firstFrame			dc.w	2
.fadeWaiter			dc.w	3
.heartFadeOff		dc.w	7*32
.scrollerWait		dc.w	OUTTRO_FRAMES_UNTIL_SCROLLER
musicSwitchWaiter	dc.w	OUTTRO_FRAMES_UNTIL_NORMAL_SND


killMusic2
	move.l	#$08000000,$ffff8800.w		;Silence!
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w
	move.w	#$4e75,killMusic2
	rts


	IFNE	STANDALONE
replayMymDumpLoop
	subq.w	#1,mymFrames
	bge		.ok
		move.l	musicPointerStart,musicpointer
		move.w	#192*2-1,mymFrames
.ok
    move.l  musicpointer,a0
    IFEQ	DUMP_DELTA

    lea     $ffff8800.w,a4
    lea     $ffff8802.w,a1
    moveq   #0,d0
    move.b  (a0)+,d0
    ble		.skip						; crash prevention 1
    and.w	#%1111111110,d0				; crash prevention 2
    cmp.b	#56,d0						; crash prevention 3
    ble		.kk
    	move.b	#56,d0
.kk
    jmp     .loop(pc,d0.w)
.loop
        REPT 14
            move.b  (a0)+,(a4)          ;     2
            move.b  (a0)+,(a1)          ;     2 -> 4            ;48
        ENDR
.skip

    ELSE
    lea		$ffff8800,a1
    lea		$ffff8802,a2
    moveq	#0,d7
    	REPT 8
    	pr
    	ENDR
    	REPT 6
    	prs
    	ENDR
    ENDC
    move.l  a0,musicpointer
	rts
	ENDC
musicPointerStart	dc.l	0

	IFEQ	STANDALONE
CREDITS_FADE_SPEED_VBL	equ 3
CREDITS_SPKR_WAITER	equ	50
CREDITS_MOD_WAITER	equ 100
CREDITS_505_WAITER	equ 150
CREDITS_XIA_WAITER	equ 200
	ENDC

doCreditsFades
	subq.w	#1,.spkr
	bge		.skipspkr
		move.w	#CREDITS_FADE_SPEED_VBL,.spkr
		sub.w	#14,creditsFadeOffSpkr
		bge		.skipspkr
			move.w	#32000,.spkr
			move.w	#0,creditsFadeOffSpkr
.skipspkr

	subq.w	#1,.mod
	bge		.skipmod
		move.w	#CREDITS_FADE_SPEED_VBL,.mod
		sub.w	#14,creditsFadeOffModmate
		bge		.skipmod
			move.w	#32000,.mod
			move.w	#0,creditsFadeOffModmate

.skipmod
	
	subq.w	#1,.five
	bge		.skipfive
		move.w	#CREDITS_FADE_SPEED_VBL,.five
		sub.w	#14,creditsFadeOff505
		bge		.skipfive
			move.w	#32000,.five
			move.w	#0,creditsFadeOff505
.skipfive
	
	subq.w	#1,.xia
	bge		.skipxia
		move.w	#CREDITS_FADE_SPEED_VBL,.xia
		sub.w	#14,creditsFadeOffXia
		bge		.skipxia
			move.w	#32000,.xia
			move.w	#0,creditsFadeOffXia	
.skipxia

	move.w	creditsFadeOffXia,d0
	add.w	creditsFadeOff505,d0
	add.w	creditsFadeOffModmate,d0
	add.w	creditsFadeOffSpkr,d0
	bne		.notDone
		jsr		copyCreditsFinal
		subq.w	#1,.times
		beq		.notDone
		move.w	#$4e75,doCreditsFades
.notDone
	rts
.times	dc.w	1
.spkr	dc.w	CREDITS_SPKR_WAITER
.mod	dc.w	CREDITS_MOD_WAITER
.five	dc.w	CREDITS_505_WAITER
.xia	dc.w	CREDITS_XIA_WAITER


fadeMacro	macro
	subq.w	#1,\1
	bge		.herp\@
		move.w	#2,\1
		lea		.list,a0
		add.w	\1Off,a0
		move.l	(a6)+,a5
		move.w	(a0),(a5)
		subq.w	#2,\1Off
		bge		.herp\@
			move.w	#12,\1Off
			move.w	#2*48-20,\1
.herp\@
	endm


WIGGLE	equ 16

doCreditHighLight
	lea		.tbList,a6

	subq.w	#1,.spkrx
	bge		.spkrdone
		move.w	#2,.spkrx
		lea		.list,a0
		add.w	.spkrxOff,a0
		move.w	(a0),credits_timer_b_spkr_high+2
		subq.w	#2,.spkrxOff
		bge		.spkrdone
			move.w	#10,.spkrxOff
			move.w	#8*48-WIGGLE,.spkrx
.spkrdone

	subq.w	#1,.modx
	bge		.moddone
		move.w	#2,.modx
		lea		.list,a0
		add.w	.modxOff,a0
		move.w	(a0),credits_timer_b_modmate_high+2
		subq.w	#2,.modxOff
		bge		.moddone
			move.w	#10,.modxOff
			move.w	#8*48-WIGGLE,.modx
.moddone

	subq.w	#1,.fivex
	bge		.fivexd
		move.w	#2,.fivex
		lea		.list,a0
		add.w	.fivexOff,a0
		move.w	(a0),credits_timer_b_505_high+2
		subq.w	#2,.fivexOff
		bge		.fivexd
			move.w	#10,.fivexOff
			move.w	#8*48-WIGGLE,.fivex
.fivexd


	subq.w	#1,.xiax
	bge		.xiaxd
		move.w	#2,.xiax
		lea		.list,a0
		add.w	.xiaxOff,a0
		move.w	(a0),credits_timer_b_xia_high+2
		subq.w	#2,.xiaxOff
		bge		.xiaxd
			move.w	#10,.xiaxOff
			move.w	#8*48-WIGGLE,.xiax
.xiaxd
	rts

.tbList
	dc.l	credits_timer_b_spkr_high+2
	dc.l	credits_timer_b_modmate_high+2
	dc.l	credits_timer_b_505_high+2
	dc.l	credits_timer_b_xia_high+2
.list	
	dc.w	$557
	dc.w	$667
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$667


.spkrx	dc.w	2*48+OUTTRO_HIGHLIGHT_OFFSET_VBL
.spkrxOff	dc.w	10
.modx	dc.w	4*48+OUTTRO_HIGHLIGHT_OFFSET_VBL
.modxOff		dc.w	10
.fivex	dc.w	6*48+OUTTRO_HIGHLIGHT_OFFSET_VBL
.fivexOff	dc.w	10
.xiax	dc.w	8*48+OUTTRO_HIGHLIGHT_OFFSET_VBL
.xiaxOff	dc.w	10


creditsFade	
	dc.w	$557,$557,$557,$557,$557,$557,$557		;0
	dc.w	$556,$556,$556,$556,$557,$667,$557		;1
	dc.w	$555,$555,$555,$555,$556,$667,$667		;2
	dc.w	$444,$544,$544,$544,$555,$667,$667		;3
	dc.w	$333,$433,$533,$533,$554,$666,$777		;4
	dc.w	$222,$322,$422,$522,$643,$665,$777		;5
	dc.w	$111,$211,$311,$511,$632,$654,$777		;6
	IFEQ	OUTTRO_CINEMASCOPE
	dc.w	$111,$100,$200,$400,$621,$643,$777		;7
	ELSE
	dc.w	$000,$100,$200,$400,$621,$643,$777		;7
	ENDC
creditsFadeOffSpkr		dc.w	7*14
creditsFadeOffModmate	dc.w	7*14
creditsFadeOff505		dc.w	7*14
creditsFadeOffXia		dc.w	7*14

	IFEQ	OUTTRO_CINEMASCOPE
credits_timer_b_spkr_highc
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#60,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkr_high,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

	ENDC

credits_timer_b_spkr_high
	move.w	#$557,$ffff8240+7*2
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_modmate_high,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

credits_timer_b_modmate_high
	move.w	#$557,$ffff8240+7*2
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_505_high,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

credits_timer_b_505_high
	move.w	#$557,$ffff8240+7*2
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_xia_high,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte	

credits_timer_b_xia_high
	move.w	#$557,$ffff8240+7*2
	clr.b	$fffffa1b.w			;Timer B control (stop)
	IFEQ	OUTTRO_CINEMASCOPE
	move.b	#76,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	ENDC
	rte	

	IFEQ	OUTTRO_CINEMASCOPE
credits_timer_b_spkrc
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#60,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_spkr,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte
	ENDC

credits_timer_b_spkr
	pusha0
	pusha1
		lea		creditsFade,a0
		add.w	creditsFadeOffSpkr,a0
		lea		$ffff8240+2*8,a1
		REPT 3
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_modmate,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte


credits_timer_b_modmate
	pusha0
	pusha1
		lea		creditsFade,a0
		add.w	creditsFadeOffModmate,a0
		lea		$ffff8240+2*8,a1
		REPT 3
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_505,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte

credits_timer_b_505
	pusha0
	pusha1
		lea		creditsFade,a0
		add.w	creditsFadeOff505,a0
		lea		$ffff8240+2*8,a1
		REPT 3
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#21,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#credits_timer_b_xia,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte

credits_timer_b_xia
	pusha0
	pusha1
		lea		creditsFade,a0
		add.w	creditsFadeOffXia,a0
		lea		$ffff8240+2*8,a1
		REPT 3
			move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)+
	clr.b	$fffffa1b.w			;Timer B control (stop)
	IFEQ	OUTTRO_CINEMASCOPE
	move.b	#76,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))		
	ENDC
	popa1
	popa0
	rte

; fill screen with 8x8 blocks, this is 40x25
; so basically we draw diagonals, so we should use unrolled loops, or not

;heartBuffer	ds.b	14400

;prepHeart
;	lea		endHeart+128,a0
;	move.l		endHeartBufferPointer,a1
;	move.w	#150-1,d7
;.dl
;		REPT 12
;			move.l	(a0)+,(a1)+
;			move.l	(a0)+,(a1)+
;		ENDR
;		lea		160-96(a0),a0
;	dbra	d7,.dl
;	move.l		endHeartBufferPointer,a0
;	move.b	#0,$ffffc123
;	rts

endHeartBufferPointer	dc.l	0

copyEndHeart
;	lea		endHeart+128,a0
	move.l	endHeartBufferPointer,a0
;	lea		heartBuffer,a0
	move.l	screenpointer2,a1
	add.w	#28*160,a1
	move.w	#150-1,d7
	moveq	#0,d0
.cp
		REPT 4
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
		REPT 12
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
		lea		160-128(a1),a1

	dbra	d7,.cp
	rts

;creditsBuffer	ds.b	7*2*80
;credits	
;	incbin	"gfx/endheart/greetings.neo"
;
;
;prepCredits
;	lea		credits+128,a0
;	lea		creditsBuffer,a1
;	move.w	#80-1,d7
;.cc
;.x set 0
;		REPT 7
;			move.w	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;		lea		160(a0),a0
;	dbra	d7,.cc
;	lea		creditsBuffer,a0				;1120
;	move.b	#0,$ffffc123
;	rts

copyCredits
;	lea		credits+128,a0
;	lea		creditsBuffer,a0
	move.l	creditsPointer,a0
	move.l	screenpointer2,a1


	add.w	#56+63*160,a1
	move.w	#80-1,d7
.ll
.x set 0
	REPT 7
		move.w	(a0)+,.x+6(a1)
.x set .x+8
	ENDR
	lea		160(a1),a1
	dbra	d7,.ll
	rts

copyCreditsFinal
;	lea		credits+128,a0
;	lea		creditsBuffer,a0
	move.l	creditsPointer,a0
	move.l	screenpointer2,a1

	add.w	#56+63*160,a1
	move.w	#80-1,d7
.ll
.x set 0
	REPT 7
		move.w	(a0)+,d0
		move.w	d0,d1
		swap	d1
		move.w	d0,d1
		move.l	d1,d0
		move.l	d0,d2
		sub.w	d2,d2
		not.l	d0
		and.l	d0,(a1)
		or.l	d1,(a1)+
		and.l	d0,(a1)
		or.l	d2,(a1)+
.x set .x+8
	ENDR

;	lea		160(a0),a0
	lea		160-56(a1),a1
	dbra	d7,.ll
	rts


endHeartPalette
	IFEQ	OUTTRO_CINEMASCOPE
	dc.w	$111,$000,$200,$400,$621,$643,$777,$557,$111,$100,$200,$400,$621,$643,$777,$557
	ELSE
	dc.w	$000,$100,$200,$400,$621,$643,$777,$557,$000,$100,$200,$400,$621,$643,$777,$557
	ENDC
;endHeart
;	incbin	"gfx/endheart/endheart05.neo"

creditsPointer	dc.l	0

endHeartcrk
	incbin	"data/outtro/heart2.crk"
	even

creditscrk
	incbin	"data/outtro/credits2.crk"
	even




	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte
	ENDC


outtro_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	subq.w	#1,effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts



endHeartFade
	ds.w	9*16


calcFadez
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a2)
	move.l	a2,a0
	lea		32(a2),a2
	move.w	#8-1,d7

.loop
		lea		bp,a1		; end pal
		move.w	#16,d0			; 16 colors
		jsr		fadePalzzz
		lea		32(a0),a0
		lea		32(a2),a2
	dbra	d7,.loop
	rts
bp
	rept 16
		IFEQ	OUTTRO_CINEMASCOPE
		dc.w	$111
		ELSE
		dc.w	0
		ENDC
	endr


;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines

;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
;out:	start palette overwritten one step closer to end palette
fadePalzzz:		
		movem.l	d0-d6/a0-a2,-(sp)

		move.w	d0,d6
		subq.w	#1,d6
.loop:
		move.w	(a0)+,d0			;source
		move.w	(a1)+,d3			;dest
		move.w	d0,d1
		move.w	d0,d2
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0700,d0
		and.w	#$0700,d3
		and.w	#$0070,d1
		and.w	#$0070,d4
		and.w	#$0007,d2
		and.w	#$0007,d5

.red:		cmp.w	d0,d3
		beq.s	.green
		blt.s	.redsub
		add.w	#$0100,d0
		bra.s	.green
.redsub:	sub.w	#$0100,d0


.green:		cmp.w	d1,d4
		beq.s	.blue
		blt.s	.greensub
		add.w	#$0010,d1
		bra.s	.blue
.greensub:	sub.w	#$0010,d1


.blue:		cmp.w	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.w	#$1,d2
		bra.s	.store
.bluesub:	subq.w	#$1,d2

.store:		or.w	d1,d0
		or.w	d2,d0
		move.w	d0,(a2)+

		dbra	d6,.loop

		movem.l	(sp)+,d0-d6/a0-a2
		rts


pixelToPreshiftOffsetTablePointer	ds.l	1
pixelToBlockOfffsetTablePointer		ds.l	1
preshiftFontPointer					ds.l	1
stringOff							ds.w	1
_pixelPosition						ds.w	1
pixelPosition						ds.w	1
sppointer							ds.l	1
_scrollerTextSourcePointer			ds.l	1
_scrollTextOffset					ds.w	1


; generate shit
generatepixelToPreshiftOffsetTable
	move.l	pixelToPreshiftOffsetTablePointer,a1
	lea		-16*20*2(a1),a0
	move.w	#(fontwidth+1)*2*fontheight,d1
	moveq	#0,d0
	move.w	#20-1,d7
.ol
		moveq	#0,d0
		move.w	#16-1,d6
.il
			move.w	d0,(a0)+
			move.w	d0,(a1)+
			add.w	d1,d0
		dbra	d6,.il
	dbra	d7,.ol
	rts

generatepixelToBlockOffsetTable
	move.l	pixelToBlockOfffsetTablePointer,a1
	lea		-5*16*2(a1),a0
	move.w	#-40,d0
	move.w	#35-1,d7
.ol
		move.w	#16-1,d6
.il
			move.w	d0,(a0)+
			dbra	d6,.il
		add.w	#8,d0
	dbra	d7,.ol
	rts




preShiftFontInit
	lea		scrollerfont,a3
	move.l	preshiftFontPointer,a4
;	lea		preshifted,a4

	move.l	#lettersheight-1,d6
	moveq	#0,d2
.copyRow
		move.l	#letterswidth-1,d7	
.copyLetter
;			move.l	a3,a0
			move.l	a4,a1
o 			set 	0
			REPT fontheight
				move.w	(a3)+,(a1)+
				move.w	(a3)+,(a1)+
				move.w	d2,(a1)+
o 				set 	o+160
			ENDR
;			add.w	#fontwidth*8,a3
			add.w	#2*(fontwidth+1)*fontheight*16,a4
		dbra	d7,.copyLetter
;	add.w	#(fontheight-1)*160,a3
	dbra	d6,.copyRow
	rts




preShiftFontInitx
	lea		scrollerfont,a3
	move.l	preshiftFontPointer,a4
	moveq	#0,d6

	moveq	#0,d2
.copyRow
		move.l	#letterswidth-1,d7	
.copyLetter
			move.l	a4,a1
			move.w	#fontheight-1,d6
.xxx
				move.w	(a3)+,(a1)+
				move.w	(a3)+,(a1)+
				move.w	d2,(a1)+
			dbra	d6,.xxx
			add.w	#2*(fontwidth+1)*fontheight*16,a4
		dbra	d7,.copyLetter
	rts

preShiftFont
;	lea		preshifted,a4
	move.l	preshiftFontPointer,a4

	move.l	#letterswidth*lettersheight-1,d7
.shiftChar
	move.l	a4,a0
	move.l	a4,a1
	add.l	#2*(fontwidth+1)*fontheight,a1
	move.w	#15-1,d6

.ol1
	REPT fontheight
		movem.w	(a0)+,d0-d2
		roxr.w	d0
		roxr.w	d1
		roxr.w	d2
		move.w	d0,(a1)+
		move.w	d1,(a1)+
		move.w	d2,(a1)+
	ENDR
	dbra	d6,.ol1

	add.l	#(fontwidth+1)*2*fontheight*16,a4
	dbra	d7,.shiftChar
	rts




clearFontLine
	move.l	screenpointer2,a0
	add.w	#(82)*160,a0
	add.w	#6,a0
	add.w	scroller_ypositionOff2,a0
	move.l	scroller_ypositionOff,scroller_ypositionOff2
	move.l	#fontheight-1,d7
	move.w	#0,d0
.ol
o set 0
	REPT 20
		move.w	d0,o(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.ol

	move.w	#86*160,stringOff
	rts
scroller_yoff	dc.w	0


; idea is to do: draw char at pixel
; d0,d1,d2,d3,d4,d5
drawStringAtPixel
	move.w	pixelPosition,_pixelPosition
	move.l	screenpointer2,a2
	add.w	#(82)*160,a2
	lea		scroller_yposition,a3
	add.w	scroller_yoff,a3
	add.w	#2,scroller_yoff
	move.w	scroller_yoff,d0
	cmp.w	#48*2,scroller_yoff
	bne		.ok
		move.w	#0,scroller_yoff
.ok
	move.w	(a3),d0
	add.w	d0,a2
	move.w	d0,scroller_ypositionOff
	add.w	#6,a2
	move.l	a2,sppointer
	move.l	_scrollerTextSourcePointer,a2
	add.w	_scrollTextOffset,a2
	lea		characterWidthTable,a3
	move.l	pixelToBlockOfffsetTablePointer,a4
	move.l	pixelToPreshiftOffsetTablePointer,a5
	move.l	preshiftFontPointer,a6
	move.w	#20*8,d3
	move.w	#-3*8,d5
	move.b	#65,d6
.doChar
	move.w	_pixelPosition,d0
	add.w	d0,d0
	move.w	(a4,d0.w),d1						; d1 block offset into screen
	move.w	(a5,d0.w),d2						; d2 offset into preshift

	cmp.w	d3,d1
	bge		.end

	move.l	a6,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	sub.b	d6,d0			;4		; align to offset font
	bge		.nospace
		; if we are here, we've encountered a space
		add.w	#10,_pixelPosition
		cmp.w	d5,d1
		beq		.special2
		jmp		.doChar
.nospace
	add.w	d0,d0
	move.w	(a3,d0.w),d4
	lsr.w	#2,d4
	add.w	d4,_pixelPosition
	muls	#(fontwidth+1)*2*fontheight*16/2,d0
	; then d0 is offset into the preshifted
	add.l	d0,a0
	add.w	d2,a0						; pixel offset

	move.l	sppointer,a1
	add.w	d1,a1						; blockoffset added

	cmp.w	#19*8,d1
	beq		.lastblock
	cmp.w	#18*8,d1
	beq		.lasttwo
	cmp.w	#-1*8,d1
	beq		.firsttwo
	cmp.w	#-2*8,d1
	beq		.firstone
	cmp.w	#-3*8,d1
	beq		.special

.normal
	moveq	#0,d7
	move.w	#fontheight-1,d7
.height
o set 0
		REPT fontwidth+1
			move.w	(a0)+,d0
			or.w	d0,o(a1)
o set o+8
		ENDR
		add.w	#160,a1
	dbra	d7,.height
	jmp		.doChar
.end
	rts

.lastblock
	moveq	#0,d7
	move.w	#fontheight-1,d7
.height2
o set 0
		REPT fontwidth-1	
			move.w	(a0)+,d0			;2
			or.w	d0,o(a1)			;4	--> 35*1*8 = 280
o set o+8
		ENDR
		add.w	#4,a0				; skip last block
		add.w	#160,a1
		dbra	d7,.height2
	jmp		.doChar

.lasttwo
	moveq	#0,d7
	move.w	#fontheight-1,d7

.height3
o set 0
		REPT fontwidth
			move.w	(a0)+,d0			;2
			or.w	d0,o(a1)			;4	-> 35*(2*6+4) = 560
o set o+8
		ENDR
		add.w	#2,a0				; skip last block
		add.w	#160,a1
	dbra	d7,.height3
	jmp		.doChar

.firsttwo
	moveq	#0,d7
	move.w	#fontheight-1,d7
.height4
o set 8
		add.w	#2,a0
		REPT fontwidth
			move.w	(a0)+,d0			;2
			or.w	d0,o(a1)			;4	-> 35*(2*6+4) = 560
o set o+8
		ENDR
	add.w	#160,a1
	dbra	d7,.height4
	jmp		.doChar

.firstone
o set 16
	moveq	#0,d7
	move.w	#fontheight-1,d7

.height5
o set 16
		add.w	#4,a0
		REPT fontwidth-1
			move.w	(a0)+,d0
			or.w	d0,o(a1)
o set o+8
		ENDR
		add.w	#160,a1
	dbra	d7,.height5
	jmp		.doChar

.special2
	move.w	#10,d4
.special
	add.w	#1,_scrollTextOffset
	cmp.w	#225+80,_scrollTextOffset
	bge		.resetshit
	add.w	d4,pixelPosition
	jmp		.doChar

.resetshit
;	move.b	#0,$ffffc123
	move.w	#226,_scrollTextOffset
	move.w	#1,pixelPosition
	jmp		.doChar

advancePixelPosition
	sub.w	#OUTTRO_SCROLLER_SPEED,pixelPosition
	rts








spacebardist equ 10*4 
space	equ 3*4
stdoff	equ 19*4
characterWidthTable
	dc.w	23*4+space		;a
	dc.w	18*4+space		;b
	dc.w	18*4+space		;c
	dc.w	22*4+space		;d
	dc.w	14*4+space		;e
	dc.w	14*4+space		;f
	dc.w	20*4+space		;g
	dc.w	22*4+space		;h
	dc.w	6*4+space		;i
	dc.w	12*4+space		;j
	dc.w	21*4+space		;k
	dc.w	14*4+space		;l
	dc.w	26*4+space		;m
	dc.w	20*4+space		;n
	dc.w	29*4+space		;o
	dc.w	17*4+space		;p
	dc.w	29*4+space		;q
	dc.w	19*4+space		;r
	dc.w	16*4+space		;s
	dc.w	16*4+space		;t
	dc.w	20*4+space		;u
	dc.w	23*4+space		;v
	dc.w	29*4+space		;w
	dc.w	22*4+space		;x
	dc.w	21*4+space		;y
	dc.w	17*4+space		;z
	dc.w	7*4+space		;.		[
	dc.w	7*4+space		;:		\
	dc.w	8*4+space		;!		]
	dc.w	15*4+space		;-		^
	dc.w	stdoff+space	;0		_
	dc.w	12*4+space		;1		'
	dc.w	17*4+space		;2		a
	dc.w	20*4+space		;3		b
	dc.w	stdoff+space	;4		c
	dc.w	20*4+space		;5		d
	dc.w	7*4+space		;,		e

scroller_ypositionOff	dc.w	0
scroller_ypositionOff2	dc.w	0
scroller_yposition		
		include	"data/outtro/yposition2.s"
;		include	"data/outtro/yposition2.s"


outtrotext

;	dc.b	"                                   AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON"

;	dc.b	"                                   LET LOVE RULEe  JOIN THE SCENEe AND MAKE A DEMO ABOUT ITe AND LET LOVE RULEe  JOIN THE SCENEe AND MAKE A DEMO ABOUT ITe AND LET LOVE RULEe  JOIN THE SCENEe AND MAKE A DEMO ABOUT ITe AND "




	dc.b	"                                   HEJ SOMMARSCENERS]  THANK YOU ALL SO MUCH FOR THE PAST YEARS]  THIS BROUGHT US ALL TOGETHER] AND REMEMBER[[[[[[   SUPPORT THE SCENE AND BE INVOLVED AND FEEL THE LOVE AND CRAFT CONTRIBUTIONS "
	dc.b	"AND SUPPORT THE SCENE AND BE INVOLVED AND FEEL THE LOVE AND CRAFT CONTRIBUTIONS AND SUPPORT THE SCENE AND BE INVOLVED AND FEEL THE LOVE AND CRAFT CONTRIBUTIONS AND"
		even
	;support the scene and be involved and craft contributions and support the scene and be involved and craft contributions and"


;	dc.b	"                                   FINALLYe WE ARE UNITED AGAIN[[[ AT SOMMARHACK] THE PARTY WE HAVE COME TO LOOK FORWA"
;	dc.b	"RD TO FOR THE BETTER PART EACH YEAR[[[ WE STARTED THIS TRIPTYCH d YEARS AGO WITH A SMALL SIGN OF LIFELINE[ THAT EVENTUALLY GREW TO MORE INVOLVEMENT[[[[[[ "
;
;	dc.b	"AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON AND THE BEAT GOES ON AND ON"


; concept ideas:
;	- motus
;		-> movement
;		-> change
;		-> initiative
;		-> motivation
;
; a). love the scene
; b). make demos
; c). join the movement / iniative
;
; `make a demo about it'
; `contribute to the scene'
; `let love rule, always'
; join the movement, change the ....
; break limits, not ethics
; love the scene
; make demos

; hej sommarhack, one once more we could not be passive observers and had this drive to .....
;
; feel the impulse / movement
;
; unity in sweden / united in sweden / united at sommarhack
;
; contribute to the flow
;
; demoscene				subculture
; creative people		limits
; break limits			creatitivty
; community
;  love
; ethids
; olschool 
; sweden
; triptych
; start/finish
; cyclic cycles

; loop:
; feel th epulse and make demos and join the movement
; feel the love, and commit to deadlines, and make demos
; 
; core idea;
; a).	create/support your scene/the movement
; b).	craft/make	productions/contributions
; c).	

; dc.b		"hej sommarsceners! thank you so much for the past 5 years; it all brought us all together! and remember; support the scene and be involved and craft contributions and support the scene and be involved and craft contributions and support the scene and be involved and craft contributions and"
;	
	even

scrollerfont
	incbin	"data/outtro/font.bin"




	section DATA

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC


	section BSS

    rsreset


    IFEQ	STANDALONE
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC
