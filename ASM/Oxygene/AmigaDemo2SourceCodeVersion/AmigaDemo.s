;
; AMIGA Demo 2 by Leonard / OXYGENE
; Ended on July 2008 in Corsica :-)
;
	

	org	$5000
	


MAX_MUSIC			=	64+12
MUSIC_START			=	2	;56
SCROLLER_STEP		=	4
SCROLLER_NBBUFFER	=	(16 / SCROLLER_STEP)
SCROLLWIN_WIDTH		=	232

;screenBuffer		= 	$80000 - 64*1024

MOUSE_SUPPORT		=	0


		tst.b	musicBuffer
		tst.b	screenBuffer
		lea		stack(pc),a7

		bsr		ShuffleList

		move.b	$210.w,d0

		cmpi.b	#2,d0
		bgt.s	.highMachine
		cmpi.b	#$3b,$fffffc02.w
		bne.s	.highMachine
		moveq	#3,d0					; simulate 50Khz on STE with F1 key
.highMachine:


		cmpi.b	#3,d0
		blt.s	.noFalcon
		clr.b	bFullscreen				; NO fullscreen on these machines
.noFalcon:

		cmpi.b	#2,$210.w	; MegaSTE?
		bne.s	.noMSTE
		lea		MegaSTEPatch1+4(pc),a0
		move.w	#$8e21,(a0)
		lea		MegaSTEPatch2+4(pc),a0
		move.w	#$8e21,(a0)
.noMSTE:

		jsr		PaulaEmulator+0
		move.l	a0,pCustomChip
		
waitQvbl:
		tst.l	$4d2.w
		bne.s	waitQvbl
		
		move.l	#screenBuffer+255,d0
		clr.b	d0
		move.l	d0,pScreen
		
		bsr		clearScreen
		bsr		printScreen
		bsr		offsetScreen
		bsr		scrollerInit
		
		move.b	#$12,$fffffc02.w

	IF	MOUSE_SUPPORT
	{
		tst.b	bFullscreen
		bne.s	.ok
		bsr		mouseInit
.ok:
	}
	
		bra		ShuffleNext
;		bra		loadAndRun

		
mainLoop:

		bsr		vSync

;		tst.b	bFullscreen
;		beq.s	.no
		move.b	$fffffc02.w,key
;.no:

		jsr		PaulaEmulator+12			; Paula Tick

		tst.b	bShowVbl
		beq.s	.notab1
		move.w	#$300,$ffff8240.w
.notab1:




		bsr		ArrowUpdate

		move.w	musicCursor,d0

		cmpi.b	#57,key
		beq.s	.mayok
		cmpi.b	#$1c,key
		beq.s	.mayok

		cmpi.b	#$31,key
		beq		ShuffleNext
		
		btst	#1,mouseK
		bne.s	.mayok
	
;		btst	#1,mouseK
;		beq		mainLoop

		; check if music has a time len
		tst.w	iCurrentTiming
		bmi.s	.noTiming

		subq.w	#1,iCurrentTiming
		beq.s	.justFinished
		
.noTiming:
		tst.b	bEndMusicTrigger
		beq		mainLoop

.justFinished:
		; music just finished
;		move.w	currentMusic,musicCursor
;		moveq	#1,d1
;		bsr		SetMusicCursor
;		bra.s	loadAndRun

		bra		ShuffleNext

.mayok:
		cmp.w	currentMusic,d0
		beq		mainLoop

		
loadAndRun:


		st	bLoading

.fLoop:
		move.w	nbLine,d0
		beq.s	.ok
	
		subq.w	#4,d0
		bpl.s	.no
		moveq	#0,d0
.no:	move.w	d0,nbLine
		bsr		vSync
		bra.s	.fLoop
		
.ok:


		move.w	currentMusic,d0
		bmi.s	.first

		add.w	d0,d0
		add.w	d0,d0
		lea		listOffset,a0
		move.l	0(a0,d0.w),a0		
		lea		160*4(a0),a1
		moveq	#-1,d0
		move.w	#$3fff,(a1)		
		move.w	d0,8*1(a1)		
		move.w	d0,8*2(a1)		
		move.w	d0,8*3(a1)		
		move.w	#$fffc,8*4(a1)		
		addq.w	#6,a0
		moveq	#0,d0
		bsr		iDisplay	

.first:

		move.w	musicCursor,currentMusic
		move.w	currentMusic,d0
		add.w	d0,d0
		lea		timeList,a0
		move.w	0(a0,d0.w),iCurrentTiming

		; stop music
		suba.l	a0,a0
		jsr	PaulaEmulator+8				; setUserRout NULL
		move.l	pCurrentDriver(pc),d0
		beq.s	.noDriver
		move.l	d0,a0
		jsr		8(a0)					; end music
.noDriver:

		; load next music
		move.w	currentMusic(pc),d0
		
		addq.w	#2,d0				; +1 for intro and +1 for this demo screen itself

		lea		musicBuffer,a0
		jsr		$1000.w		

		; select the right driver
		move.l	#futureComposerDriver,pCurrentDriver
		lea		musicBuffer,a0
		cmpi.l	#'SMOD',(a0)							; Future Composer 1.3
		beq.s	.driverOk
		cmpi.l	#'FC14',(a0)							; Future Composer 1.4
		beq.s	.driverOk
		move.l	#moduleDriver,pCurrentDriver
		cmpi.l	#'M.K.',$438(a0)						; Standard MODULE (.mod)
		beq.s	.driverOk
		move.l	#soundMonitorDriver,pCurrentDriver		; Sound Monitor (.bp)
		move.l	$1a(a0),d0
		move.b	#'.',d0
		cmpi.l	#'V.2.',d0
		bne		Crash
		
.driverOk:

		sf		bEndMusicTrigger
		
		; run it
		lea		musicBuffer,a0
		move.l	pCustomChip(pc),a1
		move.l	pCurrentDriver(pc),a2
		jsr		(a2)						; music init

		move.l	pCurrentDriver(pc),a0
		addq.w	#4,a0			; Driver+4 = tick
		jsr	PaulaEmulator+8		; setUserRout

		sf	bLoading

; marque la musique comme déjà lue
		move.w	currentMusic(pc),d0
		add.w	d0,d0
		add.w	d0,d0
		lea		listOffset,a0
		move.l	0(a0,d0.w),a0
		addq.w	#6,a0
		moveq	#-1,d0
		bsr		iDisplay
		
		
		clr.w	mouseX
		clr.w	mouseY


		move.l	pScreen,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		bset	#0,$fffffa07.w
		bset	#0,$fffffa13.w
		move.l	#qvblDemo,$4d2.w


.fLoop2:
		move.w	nbLine,d0
		cmpi.w	#24-1,d0
		beq.s	.ok2
	
		addq.w	#4,d0
		cmpi.w	#24-1,d0
		blt.s	.no2
		moveq	#24-1,d0
.no2:	move.w	d0,nbLine
		bsr		vSync
		bra.s	.fLoop2
		
.ok2:



		bra	mainLoop

keyRepeat:		dc.w	25
keyRepeatInit:	dc.w	25
oldKey:		dc.b	-2
key:		dc.b	-1
			even

Crash:		move.w	#$2700,sr
.loop:		not.w	$ffff8240.w
			bra.s	.loop

ArrowUpdate:
		move.b	key,d0
		btst	#7,d0
		beq.s	.keyPressed
		
		move.w	#25,keyRepeatInit
		move.b	d0,oldKey
				
		bra		antiRepeat
.keyPressed:

		cmp.b	oldKey,d0
		bne		newKey
		
		; repeat
		subq.w	#1,keyRepeat
		bne		antiRepeat
		
		move.w	#3,keyRepeatInit
		
newKey:
		move.l	$466.w,d1
		add.l	d1,randSeek		; add some human entropy to the rnd generator :-)

		move.w	keyRepeatInit,keyRepeat		
		
		move.b	d0,oldKey

		cmpi.b	#15,d0
		bne		.noTab
		not.b	bShowVbl
.noTab:

		
		cmpi.b	#$48,d0
		bne		.noUP
		moveq	#-4,d1
		bsr	SetMusicCursor
.noUP:	

		cmpi.b	#$50,d0
		bne		.noDOWN
		moveq	#4,d1
		bsr		SetMusicCursor
.noDOWN:	

		cmpi.b	#$4d,d0
		bne		.noRIGHT
		moveq	#1,d1
		bsr		SetMusicCursor
.noRIGHT:	

		cmpi.b	#$4b,d0
		bne		.noLEFT
		moveq	#-1,d1
		bsr		SetMusicCursor
.noLEFT:	

antiRepeat:

	IF 	MOUSE_SUPPORT
	{

MOUSE_THRESOLD_X		=	64
MOUSE_THRESOLD_Y		=	40

	; handle mouse
		cmpi.w	#MOUSE_THRESOLD_X,mouseX
		blt.s	.noMRight
		clr.w	mouseY
		subi.w	#MOUSE_THRESOLD_X,mouseX
		moveq	#1,d1
		bsr.s	SetMusicCursor
.noMRight:
		cmpi.w	#-MOUSE_THRESOLD_X,mouseX
		bgt.s	.noMLeft
		clr.w	mouseY
		addi.w	#MOUSE_THRESOLD_X,mouseX
		moveq	#-1,d1
		bsr.s	SetMusicCursor
.noMLeft:
		cmpi.w	#MOUSE_THRESOLD_Y,mouseY
		blt.s	.noMDown
		clr.w	mouseX
		subi.w	#MOUSE_THRESOLD_Y,mouseY
		moveq	#4,d1
		bsr.s	SetMusicCursor
.noMDown:
		cmpi.w	#-MOUSE_THRESOLD_Y,mouseY
		bgt.s	.noMUp
		clr.w	mouseX
		addi.w	#MOUSE_THRESOLD_Y,mouseY
		moveq	#-4,d1
		bsr.s	SetMusicCursor
.noMUp:

	}

		rts		
		
SetMusicCursor:
	
		add.w	d1,musicCursor
		bpl.s	.ok
		addi.w	#MAX_MUSIC,musicCursor
.ok:	;and.w	#64-1,musicCursor
		cmpi.w	#MAX_MUSIC,musicCursor
		blt.s	.ok2
		subi.w	#MAX_MUSIC,musicCursor
.ok2:

		rts

ShuffleNext:
		move.w	ShufflePos,d0
		move.w	d0,d1
		add.w	d1,d1
		lea		listRndMusic,a0
		add.w	d1,a0
		move.w	(a0),musicCursor
		
		addq.w	#1,d0
		cmpi.w	#MAX_MUSIC,d0
		bne.s	.ok
		bsr		ShuffleList
		moveq	#0,d0		
.ok:	move.w	d0,ShufflePos
		bra		loadAndRun
		
	
	IF 	MOUSE_SUPPORT
	{

mouseInit
		move.w	#$2700,sr
		move.l	#MouseRout1,$118.w
		move.w	#0,mouseX
		move.w	#0,mouseY
		clr.b	mouseK

		move.b	#$03,$fffffc00.w
		move.b	#$96,$fffffc00.w
.la:		btst	#1,$fffffc00.w
		beq.s	.la
		move.b	#$1a,$fffffc02.w
		bset	#6,$fffffa09.w
		bset	#6,$fffffa15.w
		move.w	#$2300,sr
		rts

MouseRout1
		move.w	#$2500,sr
		move.w	d0,-(a7)
		move.b	$fffffc02.w,d0
		cmpi.b	#$f8,d0
		blo.s	.keyboard
		and.b	#%11,d0
		move.b	d0,mouseK
		move.l	#MouseRout2,$118.w
		move.w	(a7)+,d0
		rte
.keyboard:
		move.b	d0,key
		move.w	(a7)+,d0
		rte

MouseRout2:	move.w	#$2500,sr
		move.w	d0,-(a7)
		move.b	$fffffc02.w,d0
		ext.w	d0
		add.w	d0,mouseX
		move.w	(a7)+,d0
		move.l	#MouseRout3,$118.w
		rte

MouseRout3:	move.w	#$2500,sr
		move.w	d0,-(a7)
		move.b	$fffffc02.w,d0
		ext.w	d0
		add.w	d0,mouseY
		move.w	(a7)+,d0
		move.l	#MouseRout1,$118.w
		rte

	}
		
mouseX:		ds.w	1
mouseY:		ds.w	1
mouseK:		ds.w	1
		
qvblDemo:

		clr.b	$fffffa1b.w
		move.l	#timerB1,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w

		tst.b	bFullscreen
		beq.s	.no
		move.b	#0,$ffff820f.w
.no:

		move.w	#$000,$ffff8240.w
		move.w	#$fff,$ffff8242.w
		move.w	#$122,$ffff8244.w
		move.w	#$fff,$ffff8246.w

		tst.b	bShowVbl
		beq.s	.notab3
		move.w	#$300,$ffff8240.w

.notab3:

		bsr		cursorDisplay
		bsr		scrollerUpdate
		bsr		scrollerHardwareUpdate

		tst.b	bShowVbl
		beq.s	.notab2

		not.w	$ffff8240.w
.notab2:

		rts








cursorDisplay:
; clear old cursor
		move.l	pClearCursor(pc),d0
		beq.s	.noClear
		move.l	d0,a0
		moveq	#0,d0
		bsr.s	iDisplay
.noClear:
		move.w	musicCursor,d0
		lea		listOffset,a0
		add.w	d0,d0
		add.w	d0,d0
		move.l	0(a0,d0.w),a0
		addq.w	#4,a0
		move.l	a0,pClearCursor
		moveq	#-1,d0

iDisplay:		
		moveq	#8-1,d1
.cLoop:	move.w	d0,(a0)
		move.w	d0,8*1(a0)
		move.w	d0,8*2(a0)
		move.w	d0,8*3(a0)
		move.w	d0,8*4(a0)
		lea		160(a0),a0
		dbf		d1,.cLoop
		rts

timerB1:
			move.w	#$fff,$ffff8240.w
			move.l	#timerB2,$120.w
			rte
			
timerB2:
			move.w	#$112,$ffff8240.w
			clr.b	$fffffa1b.w
			move.b	#11,$fffffa21.w
			move.b	#8,$fffffa1b.w
			move.l	#timerB3,$120.w
			rte

timerB3:
			move.w	#$fff,$ffff8240.w
			clr.b	$fffffa1b.w
			move.b	#1,$fffffa21.w
			move.b	#8,$fffffa1b.w
			move.l	#timerB4,$120.w
			rte


COLOR_BACKGROUND	=	$344
COLOR_TEXTE			=	$677
COLOR_SHADOW		=	$233
COLOR_CURSOR		=	$122
COLOR_CURSOR_TEXTE	=	$776
COLOR_CURSOR_SHADOW	=	$011
COLOR_CURRENT		=	$772
COLOR_CURRENT_SHADOW =	$221

COLOR_TEXTE_LOADING	=	$700
COLOR_LOADING_SHADOW = 	$300

timerB4:
			move.w	#COLOR_BACKGROUND,$ffff8240.w

			clr.b	$fffffa1b.w
			move.b	#200-26-27+4-1+9,$fffffa21.w
			move.b	#8,$fffffa1b.w

			move.w	#COLOR_TEXTE,$ffff8242.w
			move.w	#COLOR_SHADOW,$ffff8244.w
			move.w	#COLOR_TEXTE,$ffff8246.w
			move.w	#COLOR_CURSOR,$ffff8248.w
			move.w	#COLOR_CURSOR_TEXTE,$ffff824a.w
			move.w	#COLOR_CURSOR_SHADOW,$ffff824c.w
			move.w	#COLOR_CURSOR_TEXTE,$ffff824e.w

			move.w	#COLOR_BACKGROUND,$ffff8250.w
			move.w	#COLOR_CURRENT,$ffff8252.w
			move.w	#COLOR_CURRENT_SHADOW,$ffff8254.w
			move.w	#COLOR_CURRENT,$ffff8256.w

			move.w	#COLOR_CURSOR,$ffff8258.w
			move.w	#COLOR_CURRENT,$ffff825a.w
			move.w	#COLOR_CURRENT_SHADOW,$ffff825c.w
			move.w	#COLOR_CURRENT,$ffff825e.w

			tst.b	bLoading
			beq.s	.noLoad
			move.w	#COLOR_TEXTE_LOADING,$ffff824a.w
			move.w	#COLOR_LOADING_SHADOW,$ffff824c.w
			move.w	#COLOR_TEXTE_LOADING,$ffff824e.w
.noLoad:

			move.l	#timerBScrollerNormal,$120.w
			tst.b	bFullscreen
			beq.s	.no
			move.l	#timerBScroller,$120.w
.no:
			rte

timerBScrollerNormal:
			move.w	#$fff,$ffff8240.w

			movem.l	d0/a0-a1,-(a7)

			move.b	$fffffa21.w,d0
.sync:		cmp.b	$fffffa21.w,d0
			beq.s	.sync

			move.b	#0,$fffffa1b.w
			clr.w	$ffff8240.w

			move.b	#0,$fffffa1b.w
			move.b	#2,$fffffa21.w
			move.l	#timerB5,$120.w
			move.b	#8,$fffffa1b.w

			move.l	pColors(pc),a0
			move.w	(a0)+,timerB6+2
			move.l	a0,pRaster
			move.w	#18,nRaster

			lea		font25+2,a0
			movea.w	#$8242,a1
			move.w	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+

			movem.l	(a7)+,d0/a0-a1
			rte

timerBScroller:
	move.w	#$fff,$ffff8240.w	
			move.w	#$2700,sr
			
			movem.l	d0/d1/d4/d6/d7/a3/a4/a5/a6,-(a7)

		moveq	#0,d4

		move.b	$fffffa21.w,d0

		lea	$ffff8209.w,a4

MegaSTEPatch1:
;		bclr	#0,$300.w		; 8Mhz MegaSTE
		move.b	#0,$300.w	; 16Mhz MegaSTE
			
.sync:		cmp.b	$fffffa21.w,d0
			beq.s	.sync


			move.b	#0,$fffffa1b.w

			moveq	#2-1,d6
			move.w	d4,$ffff8240.w		; WARNING: DO NOT REMOVE (modifyed code)

			move.w	nbLine(pc),d1		; 3
			beq		eoi

			addq.w	#1,d1
			
			move.b	(a4),d4
.sync2:		cmp.b	(a4),d4
			beq.s	.sync2
			sub.b	(a4),d4
			ext.w	d4
			lsl.w	d4,d4
			
		
		lea		font25+2,a5			; 3
		lea		$ffff8242.w,a6			; 2
		
		move.w	(a5)+,(a6)+				; 3
		move.l	(a5)+,(a6)+				; 5
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
		move.l	(a5)+,(a6)+
		
		lea	$ffff8260.w,a5				; 2
		lea	$ffff820a.w,a6				; 2

;		dbf		d6,*
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


wb8204:		move.l	#$00000000,$ffff8204.w						; 6
wb8209:		move.b	#$00,$ffff8209.w							; 4
			move.b	#((SCROLLWIN_WIDTH*2)-230)/2,$ffff820f.w	; 4

			move.l	pColors(pc),a4			; 4

			
.fullLoop:
		move.w	(a4)+,d7		; 2
		move.w	a5,(a5)					; bord gauche  8 (res)		; line of 230 bytes
		moveq	#4-1,d6
		move.b	d4,(a5)
		move.w	d7,$ffff825c.w
		moveq	#28-1,d0
		dbf		d0,*
		move.b	d4,(a6)					; bord droit  184 (freq)
		move.w	a5,(a6)
		dbf		d6,*
		move.w	a5,(a5)					; 1c4 STABILISATEUR !! :-)
		moveq	#2-1,d6
		move.b	d4,(a5)
		dbf		d6,*
		dbf		d1,.fullLoop

		lea		$ffff8240.w,a4		; 3
		moveq	#0,d0				; 1
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+
		move.l	d0,(a4)+

eoi:

MegaSTEPatch2:
;		bset	#0,$300.w		; 16Mhz MegaSTE
		move.b	#$ff,$300.w	; 16Mhz MegaSTE

			movem.l	(a7)+,d0/d1/d4/d6/d7/a3/a4/a5/a6
			rte


timerB5:	
			move.b	#0,$fffffa1b.w
			move.b	#1,$fffffa21.w
			move.l	#timerB6,$120.w
			move.b	#8,$fffffa1b.w
			rte
			
timerB6:	
			move.w	#$000,$ffff825c.w

			subq.w	#1,nRaster
			beq.s	.over

			move.l	a0,-(a7)
			move.l	pRaster(pc),a0
			move.w	(a0)+,timerB6+2
			move.l	a0,pRaster
			move.l	(a7)+,a0

			rte

.over:
			clr.b	$fffffa1b.w
			rte


bShowVbl:	dc.w	0



clearScreen:
		move.l	pScreen,a0
		move.w	#32000/4-1,d0
.cls:	clr.l	(a0)+
		dbf		d0,.cls
	
		rts

vSync:	move.l	$466.w,d0
.wait:	cmp.l	$466.w,d0
		beq.s	.wait
		rts
	
nbLine	dc.w	24-1
	
printCentered:
		movea.l	a0,a1
		lea	fontSize(pc),a2
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d0
.loop:	move.b	(a1)+,d0
		beq.s	.over
		cmpi.b	#10,d0
		beq.s	.over
		subi.b	#' ',d0
		move.b	0(a2,d0.w),d3
		add.w	d3,d2
		bra.s	.loop
		
.over:	move.w	#320,d0
		sub.w	d2,d0
		bpl.s	.okg
		moveq	#0,d0
.okg:	lsr.w	#1,d0
		

printString:	movem.l	d0-d7/a1-a6,-(a7)
		move.w	d0,d7			; Position X
		mulu.w	#160,d1
		move.l	pScreen(pc),a5
		add.w	d1,a5
		lea	fontSize(pc),a1
;		moveq	#0,d4			; plan
.loopChar:	move.b	(a0)+,d0
;		bpl.s	.ok
;		eor.w	#2,d4
;		bra.s	.loopChar
.ok:		beq.s	.over
		cmpi.b	#10,d0
		beq.s	.over
		subi.b	#' ',d0
		move.w	d7,d6
		moveq	#15,d5
		and.w	d6,d5			; d5=X mod 16
		sub.w	d5,d6			; d6=no de tranche
		lsr.w	#1,d6			; d6=offset
;		add.w	d4,d6			; + plan d'affichage
		movea.l	a5,a6
		add.w	d6,a6			; a6:Adresse ecran.
		moveq	#0,d1
		move.b	0(a1,d0.w),d1		; X suivant.
		add.w	d1,d7
		lea	fontGfx(pc),a2
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d1
		add.w	d1,d0
		add.w	d0,a2			; Adresse font.
		moveq	#6-1,d1			; 6 lignes de haut.
		moveq	#24,d2
		sub.w	d5,d2
.loopDraw:	moveq	#0,d0
		move.b	(a2)+,d0
		lsl.l	d2,d0
		or.w	d0,8(a6)
		swap	d0
		or.w	d0,(a6)
		lea	160(a6),a6
		dbf	d1,.loopDraw
		bra	.loopChar
.over:		movem.l	(a7)+,d0-d7/a1-a6
		rts


screenWidth:		dc.w	80

stringCenter:
		movem.l	d1/a0-a1,-(a7)
		moveq	#0,d1
.cLoop:	move.b	(a0)+,d0
		beq.s	.ok
		cmpi.b	#10,d0
		beq.s	.ok
		addq.w	#1,d1
		bra.s	.cLoop
		
.ok:
		move.w	screenWidth,d0
		sub.w	d1,d0
		lsr.w	#1,d0
		
		movem.l	(a7)+,d1/a0-a1
		rts
		
; a0: string ptr
; a1: screen adress
; d0: x coord
; d1: y coord
stringDisplay:
		mulu.w	#160*8,d1
		add.w	d1,a1	; adresse ecran
		move.w	d0,d3	; curseur x

.loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq	laFin
		cmpi.b	#10,d0
		beq	laFin

		lea	(font48-2),a4
		lsl.w	#3,d0
		add.w	d0,a4

	; Affiche un caractere.
		move.w	d3,d4			; x
		
		lsr.w	#2,d4
		lsl.w	#3,d4
		movea.l	a1,a2		; adresse ecran
		add.w	d4,a2
		btst	#1,d3
		beq.s	.ok1
		addq.w	#1,a2
.ok1:		
		btst	#0,d3
		bne.s	.desor

i		=	0
		repeat	8
		{
		move.b	(a4)+,d0
		lsl.b	#4,d0
		move.b	d0,i(a2)
i		=	i+160
		}
		bra	.next
.desor:
i		=	0
		repeat	8
		{
		move.b	(a4)+,d0
;		lsr.b	#4,d0
		or.b	d0,i(a2)
i		=	i+160
		}

.next:
		addq.w	#1,d3
		cmpi.w	#80,d3
		bne.s	.no
		moveq	#0,d3
		lea	160*8(a1),a1
.no:
		bra	.loop

laFin:
		rts



printScreen:
		lea		txtTitle(pc),a0
		moveq	#0,d1				; y start
		
.tLoop:
		tst.b	(a0)
		beq		.over

		move.l	pScreen,a1
		lea		160*3(a1),a1
		move.w	d1,-(a7)
		
		bsr		stringCenter
		bsr		stringDisplay	

		move.w	(a7)+,d1
		addq.w	#1,d1
		bra.s	.tLoop
		
.over:
		lea		txtSongList(pc),a0

		moveq	#0,d1
		move.w	#20,screenWidth
		lea		timeList(pc),a3
.tLoop2:
		tst.b	(a0)
		beq		.over2

		move.l	pScreen,a1
		lea		160*16(a1),a1
		move.w	d1,-(a7)
		
		bsr		stringCenter
		
		add.w	.xColumn(pc),d0
		bsr		stringDisplay	

		moveq	#-1,d1
		tst.b	(a0)
		bpl.s	.noTiming
		moveq	#0,d0
		moveq	#0,d1
		move.b	1(a0),d1
		mulu.w	#60 * 50,d1
		move.b	2(a0),d0
		mulu.w	#50,d0
		add.w	d0,d1
		addq.w	#3,a0
.noTiming:
		move.w	d1,(a3)+
		
		move.w	(a7)+,d1
		
		add.w	#20,.xColumn
		cmpi.w	#80,.xColumn
		bne.s	.noWrap
		clr.w	.xColumn
		addq.w	#1,d1
.noWrap:

		bra.s	.tLoop2
.over2:

	; build list offset
		lea		listOffset,a0
		move.l	pScreen,a1
		lea		160*16(a1),a1
		moveq	#((MAX_MUSIC+3)/4)-1,d1
.iLoop:	
		move.l	a1,(a0)+
		lea		5*8(a1),a1
		move.l	a1,(a0)+
		lea		5*8(a1),a1
		move.l	a1,(a0)+
		lea		5*8(a1),a1
		move.l	a1,(a0)+
		lea		5*8(a1),a1
		lea		(160*(8-1))(a1),a1
		dbf		d1,.iLoop

		rts

.xColumn:	dc.w	0

offsetScreen:
		move.l	pScreen,a0
		lea		160(a0),a0
		move.w	#(175*20)-1,d1
.cLoop:		
		move.w	-8(a0),d0
		swap	d0
		move.w	(a0),d0
		lsr.l	#1,d0
		move.w	d0,160*2+2(a0)
		addq.w	#8,a0
		dbf		d1,.cLoop		

		
		rts


scrollerTexte:
					incbin	"scroller.txt"
					dc.b	0
					even
					
scrollerFetchNextLetter:

				move.l	scrollerPTexte,a2
				moveq	#0,d1
.wrap:			move.b	(a2)+,d1
				bne.s	.ok2			
				lea		scrollerTexte(pc),a2
				bra.s	.wrap
.ok2:			
				cmpi.b	#$0d,d1
				beq.s	.wrap
				cmpi.b	#$0a,d1
				beq.s	.wrap

				move.l	a2,scrollerPTexte

				moveq	#32,d2
				cmpi.b	#'I',d1
				bne.s	.noI
				moveq	#16,d2
.noI:			cmpi.b	#'.',d1
				bne.s	.noDot
				moveq	#16,d2
.noDot:			cmpi.b	#':',d1
				bne.s	.noDDot
				moveq	#16,d2
.noDDot:			

				subi.b	#' ',d1
				mulu.w	#25*8*2,d1
				lea		font25+32,a0
				add.w	d1,a0		
				rts
				

scrollerUpdate:
				; update bitmap

				tst.b	bFullscreen
				beq.s	.ok
				tst.w	nbLine
				bne.s	.ok
				rts
.ok:

				lea		scrollerBuffer,a5
				add.w	scrollerWinPos(pc),a5
				add.l	scrollerBufferOffset(pc),a5
				move.l	scrollerPTranche1(pc),a0
				move.l	scrollerPTranche2(pc),a1

				moveq	#25-1,d4
				
				lea		scrollerShift(pc),a3
				move.w	(a3),d5
				beq.s	.fastUpdate
	
.slowUpdate:
;				movem.w	(a1)+,d0-d3		; 7
;				swap	d0				; 1
;				swap	d1				; 1
;				swap	d2				; 1
;				swap	d3				; 1
				
				move.l	(a1)+,d0		; 3
				move.w	d0,d1			; 1
				swap	d1				; 1
				move.l	(a1)+,d2		; 3
				move.w	d2,d3			; 1
				swap	d3				; 1

				move.w	(a0)+,d0		; 2
				move.w	(a0)+,d1		; 2
				move.w	(a0)+,d2		; 2
				move.w	(a0)+,d3		; 2
				rol.l	d5,d0			; 8 + 2
				rol.l	d5,d1			; 10
				rol.l	d5,d2			;
				rol.l	d5,d3
										; 60
										; +18
				
				movem.w	d0-d3,SCROLLWIN_WIDTH(a5)		; 7
				movem.w	d0-d3,(a5)						; 6
				lea		(SCROLLWIN_WIDTH*2)(a5),a5		; 2
				dbf		d4,.slowUpdate					; 3
				bra.s		.ok2

.fastUpdate:	movem.l	(a0)+,d0-d1
				movem.l	d0-d1,SCROLLWIN_WIDTH(a5)
				movem.l	d0-d1,(a5)
				lea		(SCROLLWIN_WIDTH*2)(a5),a5
				dbf		d4,.fastUpdate

.ok2:
				addq.w	#SCROLLER_STEP,d5
				cmpi.w	#16,d5
				blt.s	.noChangeLetter
				sub.w	#16,d5

				addq.w	#8,scrollerWinPos
				cmpi.w	#SCROLLWIN_WIDTH,scrollerWinPos
				bne.s	.noBitmap
				clr.w	scrollerWinPos
.noBitmap:
				move.l	scrollerPTranche2,scrollerPTranche1
		
			; ici on change de lettre
				cmpi.w	#16,scrollerLetterSize
				bge.s	.large

				bsr		scrollerFetchNextLetter
				move.l	a0,scrollerPTranche2
				move.w	d2,scrollerLetterSize
				
				bra.s	.endFetch

.large:
				move.l	scrollerPTranche1,a0
				lea		25*8(a0),a0
				move.l	a0,scrollerPTranche2		
.endFetch:				


.noChangeLetter:
				move.w	d5,(a3)
				
				sub.w	#SCROLLER_STEP,scrollerLetterSize					; 6

;				addi.w	#160*25*2,scrollerBufferOffset						; 6
;				cmpi.w	#160*25*2*SCROLLER_NBBUFFER,scrollerBufferOffset	; 5
;				bne.s	.noWrap2											; 3
;				clr.w	scrollerBufferOffset								; 5
;.noWrap2:

				lea		scrollerBufferOffset(pc),a0							; 2
				move.l	(a0),d0												; 2
				addi.l	#SCROLLWIN_WIDTH*25*2,d0										; 2
				cmpi.l	#SCROLLWIN_WIDTH*25*2*SCROLLER_NBBUFFER,d0						; 2
				bne.s	.noWrap2											; 3
				moveq	#0,d0												; 1
.noWrap2:		move.l	d0,(a0)												; 2

						rts
						
						
										
scrollerInit:
					move.l	#scrollerTexte,scrollerPTexte
					lea		font25+32,a0
					move.l	a0,scrollerPTranche1
					move.l	a0,scrollerPTranche2
					clr.w	scrollerShift
					clr.l	scrollerBufferOffset
					clr.w	scrollerWinPos
					move.w	#32,scrollerLetterSize

					lea		font25,a0
					clr.w	(a0)
					move.w	#$fff,14*2(a0)

					lea		scrollerBuffer,a0
					move.w	#(SCROLLWIN_WIDTH*25*2*SCROLLER_NBBUFFER) / 16 - 1,d0
					moveq	#0,d1
.iLoop:				move.l	d1,(a0)+
					move.l	d1,(a0)+
					move.l	d1,(a0)+
					move.l	d1,(a0)+
					dbf		d0,.iLoop

			; pack the color tab
					moveq	#25-1,d0
					move.l	pColors(pc),a0
					movea.l	a0,a1
.iLoop2:			move.w	(a0),(a1)+
					addq.w	#4,a0
					dbf		d0,.iLoop2

					rts

scrollerHardwareUpdate:
	
		tst.b	bFullscreen
		beq		.no			

		lea		scrollerBuffer,a0
		add.w	scrollerWinPos(pc),a0
		add.l	scrollerBufferOffset(pc),a0
		move.l	a0,d0
		
		move.b	d0,wb8209+3
		lsr.w	#8,d0
		move.l	d0,wb8204+2

		bra	.skip

.no:
	
					lea		scrollerBuffer,a0
					add.w	scrollerWinPos(pc),a0
					add.l	scrollerBufferOffset(pc),a0
					move.l	pScreen(pc),a1

i					=	160*175
					repeat	25
					{
					movem.l	(a0)+,d0-d7/a2-a6		; 13*4=52 bytes
					movem.l	d0-d7/a2-a6,i(a1)
					movem.l	(a0)+,d0-d7/a2-a6		; 104
					movem.l	d0-d7/a2-a6,i+52*1(a1)
					movem.l	(a0)+,d0-d7/a2-a6
					movem.l	d0-d7/a2-a6,i+52*2(a1)
					move.l	(a0)+,i+52*3(a1)
;					lea		160(a0),a0

					lea		(SCROLLWIN_WIDTH*2-160)(a0),a0

i					=	i+160
					}
.skip:
					rts

						IF 0
						{
DrawVuMeter:
	
		move.w	d0,d1			; 1
		and.w	n(a0),d1		; 3	sample left + right
		move.l	d1,a1			; 1
		move.w	(a1),d2			; 2 y*pitch

		move.l	d2,a2			; 1 screen
		or.b	d4,n(a2)		; 4
		move.w	d2,n(a3)		; 3 patch cls code
		
		;cls
		move.b	d0,n(a0)		; 3
		; 18


		move.w	n(a0),d0		; 4
		lsr.w	#1,d0			; 3
		add.b	d0,d0			; 1
		move.l	d0,a1			; 1
		move.w	(a1),d0			; 2
		move.l	d0,a1			; 1 adresse ecran
		or.b	d4,n(a1)		; 4
		move.w	d1,n(a2)		; 3 patch cls code
		;cls
		move.b	d0,n(a0)		; 3
		; 22nops
		
		
		
		; table: 16Kb
		
		11111111 22222222
		01111111 12222222
		01111111 22222220


		move.b	d0,(a0)
		move.b	d1,230*1(a0)
		move.b	d1,230*1(a0)
		move.b	d1,230*1(a0)
		
					
}					
					
					
ShuffleList:

			lea		listRndMusic(pc),a0
			moveq	#MAX_MUSIC-1,d0
			moveq	#0,d1
.iLoop:		move.w	d1,(a0)+
			addq.w	#1,d1
			dbf		d0,.iLoop

			move.l	$466.w,d0
			add.l	$4ba.w,d0
			add.b	$ffff8209.w,d0
			add.w	$300.w,d0
			move.l	d0,randSeek
			
			moveq	#MAX_MUSIC-1,d2

			lea		listRndMusic(pc),a0
.iLoop2:	bsr		rand
			andi.w	#127,d0
.While:		cmpi.w	#MAX_MUSIC,d0
			blt.s	.ok
			subi.w	#MAX_MUSIC,d0
			bra.s	.While
.ok:		add.w	d0,d0
			lea		listRndMusic(pc),a1
			add.w	d0,a1
			
			move.w	(a0),d0
			move.w	(a1),(a0)+
			move.w	d0,(a1)
			dbf		d2,.iLoop2

			moveq	#MAX_MUSIC-1-1,d2
			lea		listRndMusic(pc),a0
			move.w	(a0),d1					; store first entry
			move.w	#MUSIC_START,(a0)+
.iLoop3:	cmpi.w	#MUSIC_START,(a0)+
			bne.s	.no3
			move.w	d1,-2(a0)
.no3:		dbf		d2,.iLoop3

			rts

ShufflePos:	dc.w	0
			
rand:		move.l	randSeek,d0
			mulu.w	#12589,d0
			move.l	d0,d1
			lsl.l	#4,d0
			add.l	d1,d0
			add.l	#2531011,d0
			move.l	d0,randSeek
			swap	d0
			rts

randSeek:	dc.l	0
			
scrollerPTexte:			ds.l	1
scrollerPTranche1:		ds.l	1
scrollerPTranche2:		ds.l	1
scrollerShift:			ds.w	1
scrollerBufferOffset:	ds.l	1
scrollerWinPos:			ds.w	1
scrollerLetterSize:		ds.w	1


txtTitle:
		dc.b	'Amiga Demo 2 by Oxygene (Accurate Amiga Paula Emulator)',10
;		dc.b	'Runs on 520 STE, MegaST, TT, Falcon and even CT60!',10
		dc.b	0
		
txtSongList:


;			'01234567890123456789'
	dc.b	'22Stct.Mod',10
	dc.b	'Abscence.Fc4',10
	dc.b	'Alien Breed.Bp',10				,-1,4,12			; 4'12
	dc.b	'Arcane-Theme.Fc',10
	dc.b	'Arsenic.Mod',10
	dc.b	'Astaroth 1.Fc3',10
	dc.b	'Astaroth 2.Fc3',10
	dc.b	'Astaroth 3.Fc3',10
	dc.b	'Astaroth 4.Fc3',10
	dc.b	'Blaizer-Horizon.Fc',10
	dc.b	'Blitz.Mod',10
	dc.b	'Broadcasting.Fc',10
	dc.b	'C.Shaolin 1.Fc',10
	dc.b	'C.Shaolin 2-4.Fc',10
	dc.b	'C.Shaolin 5-6.Fc',10
	dc.b	'C.Shaolin 7.Fc',10
	dc.b	'C.Shaolin Title.Fc',10
	dc.b	'Changes.mod',10
	dc.b	'Commando.bp',10				,-1,	4,5		; 4'05
	dc.b	'Complex-Intro.Fc',10
	dc.b	'Conx.Mod',10
	dc.b	'Crack_It_Up.Mod',10
	dc.b	'Dcn_Brainfood-6.Mod',10
	dc.b	'Delicate0Ooz.Mod',10
	dc.b	'Dextrous 1.Fc',10
	dc.b	'Dextrous 2.Fc',10
	dc.b	'Dizkzor.fc4',10
	dc.b	'Dunno.Fc',10
	dc.b	'Economy12.Mod',10
	dc.b	'Endtheme.Fc3',10
	dc.b	'Evilspell.Fc3',10
	dc.b	'Factory.mod',10
	dc.b	'Frantic.Fc',10
	dc.b	'Gates Jambala 1-2.Fc',10
	dc.b	'Gonadscr.Mod',10
	dc.b	'Harmonies.mod',10
	dc.b	'Her1.Mod',10
	dc.b	'Ice 1.Fc',10
	dc.b	'Intronumber038.Mod',10
	dc.b	'Introton.Mod',10
	dc.b	'It.Mod',10
	dc.B	'Jess/OVR 1.Fc4',10
	dc.B	'Jess/OVR 2.Fc4',10
	dc.b	'Kitwanker.Mod',10
	dc.b	'Loader.Mod',10
	dc.b	'Mach.Fc',10
	dc.b	'Magfields2.Fc',10
	dc.b	'MentalFrust.mod',10
	dc.b	'Mnoise.Fc4',10
	dc.b	'Monday.mod',10
	dc.b	'Monty On The Run.Fc4',10
	dc.b	'P.Mod',10
	dc.b	'Paradox2.Fc3',10
	dc.b	'Paradoxi.Fc4',10
	dc.b	'Pullover.mod',10
	dc.b	'Purodex.mod',10
	dc.b	'PurpleShades.mod',10
	dc.b	'Rape',''','Em All.Fc',10
	dc.b	'Revolutionary.Fc',10
	dc.b	'Rings Of Medusa.Fc4',10
	dc.b	'Russian.mod',10
	dc.b	'Share.Mod',10
	dc.b	'Shitchip 2.Mod',10
	dc.b	'Spaceship.Bp',10				,-1,	2,43		; 2'43
	dc.b	'Starworx.Mod',10
	dc.b	'Strill.Mod',10
	dc.b	'Syfuid.mod',10
	dc.b	'Technochip.Mod',10
	dc.b	'Technoquartz.Mod',10
	dc.b	'The End.Fc4',10
	dc.b	'Trsi.Fc',10
	dc.b	'Tune-O-Mat.Mod',10
	dc.b	'Vision.Fc3',10
	dc.b	'WondereW.mod',10
	dc.b	'Znthchip.Mod',10
	dc.b	'Zzzax1.Bp',10					,-1,	3,19		; 3'19
	
	dc.b	0
	even


	
		ds.l	128
stack:	even

listRndMusic:	ds.w	MAX_MUSIC
listOffset:		ds.l	MAX_MUSIC+4
timeList:		ds.w	MAX_MUSIC


pScreen:		dc.l	$78000
pCustomChip:	ds.l	1

musicCursor:	dc.w	MUSIC_START
pClearCursor:	dc.l	0
currentMusic:	dc.w	-1
iCurrentTiming:	dc.w	-1

pCurrentDriver:	dc.l	0

bLoading:			dc.b	0
bEndMusicTrigger:	dc.b	0
bFullscreen:		dc.b	$ff
				even

nRaster:			ds.w	1
pRaster:			ds.l	1
pColors:			dc.l	colors + $190
colors:				
			incbin	"color.bin"
			even
colorEnd:

fontGfx:	incbin	"font6.bin"		; 6 octets par lettre
fontSize:	incbin	"font6.siz"		; 1 octet par lettre donnant la largeur a skipper en pixel.
			even

font48:		
			incbin	"fnt48.bin"
			even				
			
PaulaEmulator:
			incbin	"PaulaEmulator.bin"			; 157Kb
			even

font25:
			incbin	"fnt25.bin"
			even


;----------------------------------------------------------------------------
; MUSIC DRIVER
;----------------------------------------------------------------------------
futureComposerDriver:
		include 	"MusicDriver\FutureComposer.s"
		even

moduleDriver:
		include		"MusicDriver\modplay.s"
		even
moduleDriverEnd:

soundMonitorDriver:
		include		"MusicDriver\stebp20.s"
		even



scrollerBuffer:
				ds.b	SCROLLWIN_WIDTH*25*2*SCROLLER_NBBUFFER		; 46 Kb
				even
				
screenBuffer:
				ds.b	32000+256									; 32 Kb

musicBuffer:			
		even

