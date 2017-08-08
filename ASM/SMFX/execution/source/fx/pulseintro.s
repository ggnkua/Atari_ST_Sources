; zync:
; ff = next scene
; dd = show word
; 1 = fade pulse in
; 2 = fade scroller in
; 3 = exec screen
; 4 = cpt screen
; 5 = dhs screen
; 6 = spawn snake
; 7 = fadeout
;
	section TEXT

fontheight		equ 29						; unrepting give me 2k
fontwidth		equ 2						; 70 * 6
letterswidth	equ 20/fontwidth
lettersheight	equ 1

pulseFramesPerFade	equ 2
bgFramesPerFade		equ 15

init_pulseStartEffect	
	move.l	screenpointer2,a0
	jsr		cleara0

	moveq	#0,d0
	lea		wewereat,a0
	lea		$ffff8240,a1
	lea		16(a1),a2
	REPT 4
		move.l	d0,(a1)+
		move.l	(a0)+,(a2)+		
	ENDR

	move.l	alignpointer6,d0
	add.l	#$8100,d0
	move.l	d0,bssBuffer+_outtropoint1
	add.l	#5000,d0
	move.l	d0,bssBuffer+_outtropoint2

	lea		bssBuffer+_pointList,a0
	move.l	bssBuffer+_outtropoint1,(a0)+
	move.l	bssBuffer+_outtropoint1,(a0)+
	move.l	bssBuffer+_outtropoint2,(a0)+
	move.l	bssBuffer+_outtropoint1,(a0)+
	move.l	bssBuffer+_outtropoint2,(a0)+
	move.l	bssBuffer+_outtropoint1,(a0)+
	move.l	bssBuffer+_outtropoint1,bssBuffer+currentPointAddress

	jsr		genOuttro2
	jsr		genOuttro3

	lea		smfxpic,a0
	move.l	alignpointer9,a1
	jsr		d_lz77

	move.w	#$2700,sr
	move.l	#wherewerewe_vbl,$70
	move.w	#$2300,sr

	move.l	alignpointer3,bssBuffer+y_block_pointer			; 200*4
	move.l	alignpointer3,d0
	add.l	#200*4,d0		; size y_block
	add.l	#640,d0			; pointer is used also with negative offset
	move.l	d0,bssBuffer+pixelToPreshiftOffsetTablePointer
	add.l	#1280,d0
	add.l	#160,d0
	move.l	d0,bssBuffer+pixelToBlockOfffsetTablePointer

	move.l	alignpointer4,bssBuffer+x_block_pointer
	move.l	alignpointer5,bssBuffer+preshiftFontPointer

	jsr		generatepixelToPreshiftOffsetTable
	jsr		generatepixelToBlockOffsetTable
	jsr		init_yblock_aligned				; populate y table
	jsr		init_xblock_aligned				; populate x table
	jsr		preShiftFontInit
	jsr		preShiftFont					

	lea		execscreen,a0
	move.l	alignpointer6,a1
	add.w	#37*160-128,a1
	jsr		d_lz77

	move.l	alignpointer6,a0
	add.w	#37*160-128,a0
	lea		execscreen,a1
	moveq	#0,d0
	REPT 32
		move.l	(a0),(a1)+
		move.l	d0,(a0)+
	ENDR

	; copy checkpoint screen to buffer 8
	lea		cptlogo,a0
	move.l	alignpointer7,a1
	jsr		d_lz77

	move.l	alignpointer7,a0
	move.l	alignpointer8,a1
	move.w	#124-1,d7
	add.w	#42*160,a1
.ol	
	add.w	#6*8,a1
	REPT 10
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	add.w	#4*8,a1
	dbra	d7,.ol


	lea		outtrotext,a0
	move.l	a0,bssBuffer+_scrollerTextSourcePointer

	move.w	#3,bssBuffer+pixelPosition
	move.w	#0,bssBuffer+_scrollTextOffset

.wewereatloop
			exitOnSpace
		cmp.w	#329-30-25,bssBuffer+wherewerewecounter
		bne		.wewereatloop

	lea		$ffff8240,a0
	lea		totalPalette,a1
	add.w	pulseFadeInOffset,a1
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a0)

	move.l	screenpointer,savedscreenpointer
	move.l	screenpointer2,savedscreenpointer2
	add.l	#96*160,screenpointer
	move.l	alignpointer1,d0
	add.l	#96*160,d0
	move.l	d0,screenpointer2

	move.l	screenpointer2,$ffff8200

	move.w	#$2700,sr
	move.l	#pulseintro_vbl,$70
	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
	move.l	#dummy,$120.w
	move.w	#$2300,sr

	move.w	#0,nextScene
.mainloop
			exitOnSpace
	tst.w	smfx
	beq		.no

		jsr		copySMFX
.no
	tst.w	nextScene
		bge		.mainloop

.waiter
	wait_for_vbl
	subq.w	#1,artisticwait
	bge		.waiter
	rts

smfx	dc.w	0
artisticwait	dc.w	150

;;;;;;;; WHERE WERE WE ;;;;;;;;;

fadewaiterframes	equ 1

;;;;;;;;;; new where were we

wherewerewe_vbl
	move.l	screenpointer2,$ffff8200
	addq.w	#1,$466.w
	addq.w	#1,bssBuffer+wherewerewecounter
	pushall
		jsr		whereWereWe

		move.l	sndh_pointer,a0
		jsr		8(a0)
	popall
	rte

checkForActivate
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.w	#$dd,d0
	bne		.end
		subq.w	#1,_tmpTimes
		blt		.next
			move.b	#0,$b8(a0)
			move.w	#50,_tmpWaiter
			move.w	#-1,_copyDone
			move.w	#-1,_resetFade
			move.w	#-1,_fadeActive
			lea		_copyList,a0
			add.w	_copyListOff,a0
			move.l	(a0),bssBuffer+copyPointer
			add.w	#4,_copyListOff
			lea		_backList,a0
			add.w	_backListOff,a0
			move.l	(a0),bssBuffer+backPointer
			add.w	#4,_backListOff
.end	
.kkk
	rts
.next
	move.w	#4,_tmpTimes
	move.w	#7*7*2,_fadeOffset
	move.w	#-1,_WhereWereWeFadeOut
	move.w	#-1,_fadeActive
	rts

cleara0
	move.w	#200-1,d7
	moveq	#0,d0
.loop
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.loop
	rts

_copyList
	dc.l	doCopy		;copyWhere
	dc.l	doCopy		;copyWere
	dc.l	doCopy		;copyWe
	dc.l	doCopy		;copyQue
	dc.l	removeBack	;removeWhereBack
	dc.l	removeBack	;removeWereBack
	dc.l	removeBack	;removeWeBack
	dc.l	removeBack	;removeQueBack

_backList
	dc.l	copyBack	;copyWhereBack
	dc.l	copyBack	;copyWereBack
	dc.l	copyBack	;copyWeBack
	dc.l	copyBack	;copyQueBack
	dc.l	deRemove	;removeWhere
	dc.l	deRemove	;removeWere
	dc.l	deRemove	;removeWe
	dc.l	deRemove	;removeQue


; beat -> 
;	activate!
;	- reset fade for 1-7
;	- copy
;	- start where fade 1-7
;	- when fade done; copy 4th bitplane
whereWereWe
	jsr		checkForActivate			;	simulates music trigger
	jsr		resetFade
	jsr		copyShit
	jsr		doFade
	jsr		fillBack
	rts

fillBack
	tst.w	_doBack
	beq		.noCopyBack
		move.l	bssBuffer+backPointer,a0
		jsr		(a0)
.noCopyBack	
	rts

resetFade
	tst.w	_resetFade					;	reset fade 1-7
	beq		.noResetFade
		tst.w	_WhereWereWeFadeOut
		bne		.setMaxFade
			move.w	#0,_fadeOffset
			move.w	#0,_resetFade
			jmp		.noResetFade
.setMaxFade
			move.w	#8*7*2,_fadeOffset
			move.w	#0,_resetFade
.noResetFade
	rts

copyShit
	tst.w	_copyDone					;	copy
	beq		.noCopy
		move.l	bssBuffer+copyPointer,a0
		jsr		(a0)
.noCopy
	rts


doFade
	tst.w	_fadeActive
	beq		.end

	tst.w	_WhereWereWeFadeOut
	bne		.fadeOut

	subq.w	#1,_wherewerewe
	bgt		.end
		move.w	#fadewaiterframes,_wherewerewe
		lea		doWeWereFadeTable,a0
		lea		$ffff8242,a1
		add.w	_fadeOffset,a0
		REPT 7
			move.w	(a0)+,(a1)+
		ENDR

		add.w	#7*2,_fadeOffset
		cmp.w	#8*7*2,_fadeOffset
		bne		.end	
			move.w	#7*7*2,_fadeOffset
			move.w	#0,_fadeActive
			move.w	#-1,_doBack
	rts

.fadeOut

		lea		doWeWereFadeTable,a0
		add.w	_fadeOffset,a0
		lea		$ffff8242,a1
		REPT 7
			move.w	(a0)+,(a1)+
		ENDR

		sub.w	#7*2,_fadeOffset
		bge		.end
			move.w	#0,_fadeOffset
			move.w	#0,_fadeActive
			move.w	#-1,_doBack
.end
	rts


_tmpWaiter		dc.w	50
_tmpTimes		dc.w	4

textoff		equ 	70*160+40

copyListOff	dc.w	0
copyList
	dc.l	where
	dc.w	0,5-1,160-40

	dc.l	were
	dc.w	32,5-1,160-40

	dc.l	we
	dc.w	56,3-1,160-24

	dc.l	que
	dc.w	56,3-1,160-24

doCopy
	tst.w	_copyDone
	beq		.end
		move.w	#0,_copyDone
		lea		copyList,a6
		add.w	copyListOff,a6

		move.l	(a6)+,a0			; source
		move.l	screenpointer2,a1
		add.w	#textoff,a1
		add.w	(a6)+,a1			; offset
		move.w	#34-1,d7
		move.w	(a6)+,d2			; width
.doLine
			move.w	d2,d6
.doWidth
				move.l	(a0)+,d0
				or.l	d0,(a1)+
				move.w	(a0)+,d0
				or.w	d0,(a1)+
				add.w	#2,a1
			dbra	d6,.doWidth
			add.w	(a6),a1
		dbra	d7,.doLine
		add.w	#10,copyListOff
.end
	rts

doBackOff	dc.w	0
doBackList		
	dc.w	0,-1,%11111<<11,4-1,160-40				; where - back - fill
	dc.w	32,-1,%111<<13,3-1,160-32				; were - back - fill
	dc.w	56,-1,%11111111111111<<2,1-1,160-16		; we - back - fill
	dc.w	56,-1,%111<<13,3-1,160-32				; que - back - fill

	dc.w	0,0,%11111111111,4-1,160-40				; where - back - remove
	dc.w	32,0,%1111111111111,3-1,160-32			; were - back - remove
	dc.w	56,0,0,1-1,160-16						; we - back - remove
	dc.w	56,0,0,3-1,160-32						; que - back - remove

removeBack
copyBack
	lea		doBackList,a6
	add.w	doBackOff,a6

	move.l	screenpointer2,a0
	add.w	#6+textoff,a0
	add.w	(a6)+,a0				; add text specific text off
	move.w	(a6)+,d0				; fill or remove
	beq		.remove
		move.w	#0,_fadeOffset
		lea		doWeWereFadeTable,a5
		lea		$ffff8242,a4
		add.w	_fadeOffset,a5
		REPT 7
			move.w	(a5)+,(a4)+
		ENDR
		jmp		.ok
.remove
		move.w	#0,_copyDone
.ok
	move.w	(a6)+,d1				; move text specific mask
	move.w	#34-1,d7
	move.w	(a6)+,d2				; text specific iterations
.doLine
		move.w	d2,d6
.doWidth
			move.w	d0,(a0)
			add.w	#8,a0
		dbra	d6,.doWidth
		move.w	d1,(a0)
		add.w	#8,a0
		add.w	(a6),a0				; offset
	dbra	d7,.doLine

	move.w	#0,_doBack
	add.w	#10,doBackOff
	rts

removeListOffset	dc.w	0
removeList	
	dc.w	0,%11111111111,4-1,160-40
	dc.w	32,%11111111111,3-1,160-32
	dc.w	56,%1,1-1,160-16
	dc.w	56,%11111111111,3-1,160-32

deRemove
	lea		removeList,a6
	add.w	removeListOffset,a6

	move.l	screenpointer2,a0
	add.w	#textoff,a0
	add.w	(a6)+,a0				; text offset
	moveq	#0,d0
	move.w	(a6)+,d1				; mask
	move.w	#34-1,d7
	move.w	(a6)+,d2				; width
.doLine
		move.w	d2,d6
.doWidth
			and.l	d0,(a0)+
			and.w	d0,(a0)+
			add.w	#2,a0
		dbra	d6,.doWidth
		and.w	d1,(a0)+
		and.w	d1,(a0)+
		and.w	d1,(a0)+
		add.w	#2,a0
		add.w	(a6),a0
	dbra	d7,.doLine
	move.w	#0,_doBack
	add.w	#8,removeListOffset
	rts

_wherewerewe	dc.w	fadewaiterframes
doWeWereFadeOff	dc.w	0
doWeWereFadeTable
	dc.w	$000,$000,$000,$000,$000,$000,$000	;0	
	dc.w	$102,$102,$102,$102,$102,$102,$102	;1
	dc.w	$112,$112,$112,$112,$112,$112,$102	;2
	dc.w	$123,$123,$123,$123,$123,$112,$102	;3
	dc.w	$233,$233,$233,$233,$123,$112,$102	;4
	dc.w	$243,$243,$243,$233,$123,$112,$102	;5
	dc.w	$556,$556,$243,$233,$123,$112,$102	;6
	dc.w	$777,$556,$243,$233,$123,$112,$102	;7
	dc.w	$777,$556,$243,$233,$123,$112,$102	;7

;;;;;;;;;;; end where were we



;hurrrr				dc.w	60*50-440
hurrtimer			dc.w	1
hurroff				dc.w	0
hurroffsteps		equ 	4
_pulseFadeWaiter			dc.w	1
_bgFadeWaiter				dc.w	1
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO ROUTES ;;;;;;;;;;;
pulseintro_curtain
	pushall
	subq.w	#1,_screenSwap
	bgt		.noswap
	move.l 	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ff8200
.noswap

	addq.w 	#1,$466.w
	moveq	#0,d0
	lea		$ffff8240,a0
	move.w	#0,(a0)

    move.w  #$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
	move.l	#tbl,$120
    move.b  #1,$fffffa21.w
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    move.w	#$2300,sr

	jsr		doWeAreHerePalette	
	move.l	sndh_pointer,a0
	jsr		8(a0)

	popall
	rte

tbl
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	pushall

	moveq	#2,d7				;D7 used for the overscan code	;4		1
	lea		$ffff8260,a5										;8		2
	lea		$ffff820a,a6										;8		2

	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr	

	moveq	#0,d0
	lea		$ffff8209.w,a0		;Hardsync
	move.b	(a0),d0
	moveq	#127,d1				;
.sync:		
		cmp.b	(a0),d0
	beq.s	.sync				;
	move.b	(a0),d0				;
	sub.b	d0,d1				;
	lsr.l	d1,d1				;

	rept 62-2-2-1-6
		NOP
	endr
;	movem.l	tbcols,d0-d5/a2/a3
	lea		bssBuffer+_tbcols,a0
	lea		$ffff8240,a1	;8
	move.w	#200-1,d6
	move.l	a1,a2
	move.l	(a0)+,(a1)		;12
	moveq	#0,d0

;	move.b	#0,$fffc123
	tst.w	_fadeInActive					;4
	bne		.dontUpdatePalatte				;3 not taken


	rept 9-3-2-1
		nop
	endr
.ol
    move.b	d7,(a5)
    move.w	d7,(a5)

    move.l	d0,(a2)+
    move.l	d0,(a2)+
    move.l	d0,(a2)+
    move.l	d0,(a2)+
    move.l	d0,(a2)+
    REPT 45-8
    	or.l	d7,d7
    ENDR
    nop
    move.w	d7,(a6)
    nop
    move.b	d7,(a6)

    REPT 6-2
    	or.l	d7,d7
    ENDR
    nop
    move.l	(a0)+,d0

    move.b	d7,(a5)
    move.l	a1,a2
    move.w	d7,(a5)
    	move.l	d0,(a2)+		;12		4
    	move.l	d0,(a2)+		;12		8
    	move.l	d0,(a2)+		;12		12
    REPT 6 ;+3+4
;    	nop
    ENDR

    	dbra	d6,.ol
	move.w	#$0,$ffff8240
	jmp		.continueStuff

.dontUpdatePalatte

	rept 9-3-1-2-1
		nop
	endr
.ol2
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		REPT 44
			add.l	d4,d4
		ENDR

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-3,$4e71
		dbra	d6,.ol2
		move.w	#$0,$ffff8240
	

.continueStuff
	tst.w	_direction
	blt		.okt
	jsr		doCurtainFullScreen
	subq.w	#1,curtainPlace
	bge		.okt
		move.w	#-1,_fadeInActive
.okt
	jsr		checkMusicPulse

    popall
    rte



_fadeInActive	dc.w	0
curtainPlace	dc.w	100

doCurtainFullScreen
	; default all white
	lea		bssBuffer+_tbcols,a0
	move.l	a0,a1
	add.w	#200*4,a1
	move.w	#100-1,d7
	lea		weAreHerePalette,a3
	move.l	(a3),d0
.il
		move.l	d0,(a0)+		;400 bytes, dbra
		move.l	d0,-(a1)
	dbra	d7,.il

	move.w	curtainPlace,d0
	ble		.open

	lea		bssBuffer+_tbcols,a0
	move.l	a0,a1
	add.w	#200*4,a1
	move.w	#0,d1
.fill
		move.l	d1,(a0)+
		move.l	d1,-(a1)
	dbra	d0,.fill
	rts
.open
   rts

_ttdone	dc.w	0
copySMFX
	tst.w	_ttdone
	bne		.end
		move.w	#-1,_ttdone
	move.l	screenpointer2,a0
	add.w	#3*160,a0
	add.w	#47*230,a0
	add.w	#19*230,a0

	move.l	alignpointer9,a1
	move.w	#74-1,d7
.xl
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		REPT 24
			move.l	(a1)+,(a0)+
			move.l	(a1)+,(a0)+
		ENDR
		add.w	#230-25*8,a0
	dbra	d7,.xl
.end
	rts

pulseintro_vbl
	pushall
	subq.w	#1,_screenSwap
	bgt		.noswap
	move.l 	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ff8200
.noswap

	addq.w 	#1,$466.w
	move.w	#0,$ffff8240

	move.l	sndh_pointer,a0
	jsr		8(a0)

	jsr		checkMusicPulse
	tst.w	_active
	bne		.skipshit

	jsr		selectNextScreenAndSetPal
			raster	#$100
	jsr		clearFontLine
	jsr		clearTimes
			raster	#$030
	jsr		drawStringAtPixel
			raster	#$002
	jsr		advancePixelPosition
			raster	#$504
	jsr		drawTimes2
			raster	#$333
	jsr		drawPixelThings2
	jsr		clearGarbage
	jmp		.tttt

.clearStuff	dc.w	2

.skipshit	
	tst.w	.clearStuff
	ble		.curtain
		jsr		clearFontLine
		jsr		clearTimes
		swapscreens
		jsr		clearFontLine
		jsr		clearTimes
		swapscreens
		sub.w	#1,.clearStuff
			move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	#116*160,a0
	add.w	#116*160,a1
	move.l	#0,d0
o set 0
	rept 3
		move.l	d0,o+4(a0)
		move.l	d0,o(a0)
		move.l	d0,o+4(a1)
		move.l	d0,o(a1)
o set o+160
	endr

		jmp		.ok2

.curtain
 	move.w	#-1,smfx	
	move.w	#$2700,sr
	move.l	#pulseintro_curtain,$70
	move.w	#$2300,sr
	lea		$ffff8240,a0
	moveq	#0,d0
	rept 8
		move.l	d0,(a0)+
	endr
	popall
	rte

.ok2
	jsr		doWeAreHerePalette
.tttt
			raster	#$0
			swapscreens
	popall
	rte	


_magicTimer		dc.w	210
_magicWaiter	dc.w	3
_direction		dc.w	0

doWeAreHerePalette
	tst.w	weAreHerePaletteOff
	blt		.outdone

	subq.w	#1,_magicTimer
	bge		.skip
	subq.w	#1,_magicWaiter
	bge		.end
		move.w	#3,_magicWaiter

		tst.w	_direction
		bne		.fadeout
		cmp.w	#12*32,weAreHerePaletteOff
		beq		.indone
		add.w	#32,weAreHerePaletteOff
.end
	lea		weAreHerePalette,a0
	add.w	weAreHerePaletteOff,a0
	add.w	#4,a0
	lea		$ffff8244,a1
	REPT 7
		move.l	(a0)+,(a1)+
	ENDR
.skip
	tst.w	_direction
	blt		.out
	lea		weAreHerePalette,a0
	add.w	weAreHerePaletteOff,a0
	add.w	#4,a0
	lea		$ffff8244,a1
	REPT 7
		move.l	(a0)+,(a1)+
	ENDR
	rts
.out
	lea		weAreHerePaletteOut,a0
	add.w	weAreHerePaletteOff,a0
	add.w	#4,a0
	lea		$ffff8244,a1
	REPT 7
		move.l	(a0)+,(a1)+
	ENDR
	rts

.fadeout
	cmp.w	#32*15,weAreHerePaletteOff
	beq		.outdone
		lea		weAreHerePaletteOut,a0
		add.w	weAreHerePaletteOff,a0

		lea		bssBuffer+_tbcols,a1
		move.l	32(a0),(a1)
		add.w	#4,a0

		lea		$ffff8244,a1
		REPT 7
			move.l	(a0)+,(a1)+
		ENDR
		add.w	#32,weAreHerePaletteOff
	rts

.indone
	move.w	#30,_magicTimer
	move.w	#-1,_direction
	move.w	#0,weAreHerePaletteOff
	rts

.outdone
		move.l	screenpointer2,a0
		add.w	#3*160,a0
		add.w	#47*230,a0
		moveq	#0,d0
		move.w	#60,d7
.clear
		REPT 26*2
			move.l	d0,(a0)+
			move.l	d0,(a0)+
		ENDR
		dbra	d7,.clear
.ok	
	rts

_cs					dc.w	2
tosoff				dc.w	0
weAreHerePaletteOff	dc.w	0

weAreHerePalette
	incbin	"fx/pulseintro/FADEPAL.PAL"

weAreHerePaletteOut
	incbin	"fx/pulseintro/OUT2.PAL"

clearTimes
	move.l	screenpointer2,a1
	add.l	#188*160+128,a1
	moveq	#0,d0
	move.w	#4-1,d7
.ol
y set 0
		rept 12
			move.l	d0,y(a1)
			move.l	d0,y+4(a1)
y set y+160
		endr
		add.w	#8,a1
		dbra	d7,.ol
	rts

; ff = next scene
; 1 = fade pulse in
; 2 = fade scroller in
; 3 = exec screen
; 4 = cpt screen
; 5 = dhs screen
; 6 = spawn snake
; 7 = fadeout

checkMusicPulse
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	beq		.return				; check if zync is set
	move.b	#0,$b8(a0)			; if its set, reset
	cmp.b	#$ff,d0				; check for next scene
	bne		.noExit
		move.w	#-1,nextScene
.noExit
	cmp.b	#1,d0								;		- 	z01 lifeline fadein
	bne		.no1
		move.w	#-1,_pulseFadeActive
		rts
.no1
	cmp.b	#2,d0
	bne		.no2
		move.w	#-1,_scrollerActive				;		-	z02 scroller fadein
		rts
.no2
	cmp.b	#3,d0
	bne		.no3
		move.w	#-1,_glitch1_executionscreen	;		-	z03	execution show
		rts
.no3

	cmp.b	#4,d0
	bne		.no4
		move.w	#-1,_glitch2_cptscreen	;		-	z03	execution show
		rts
.no4
	cmp.b	#5,d0
	bne		.no5
		move.w	#-1,_glitch3_dhsscreen	;		-	z03	execution show
		rts
.no5
	cmp.b	#6,d0
	bne		.no7
		move.w	#-1,_spawnSnake
		rts
.no7
	cmp.b	#7,d0
	bne		.no6
		move.w	#-1,_pulseFadeOut
		rts
.no6
	cmp.b	#9,d0
	bne		.no9
		neg.w	_invertColors
		rts
.no9
	cmp.b	#$a,d0
	bne		.no10
		move.w	#-1,_whiteFlash
		move.w	#0,pulseFadeInOffset
		tst.w	.firste
		beq		.kk
		addq.w	#3,bssBuffer+_scrollTextOffset
		cmp.w	#55,bssBuffer+_scrollTextOffset
		blt		.noresett
			sub.w	#55,bssBuffer+_scrollTextOffset
.noresett
.kk
			move.w	#-1,.firste
		rts
.no10
	cmp.b	#$b,d0
	bne		.no11
		move.w	#1,_bgFadeWaiter
		move.w	#-14,bgFadeInOffset
.no11
	cmp.b	#$bb,d0
	bne		.nobb
		move.b	#0,$bf(a0)
		move.w	#-1,sommarhackActive
.nobb
.return
	rts

.firste	dc.w	0

doOneMore			dc.w	-1
doOneMorePointer	dc.l	0

selectNextScreenAndSetPal	; but we really need to differentiate here, because we need to set pal +1 from the setscreen, so setnextscreen and setpal
	subq.w	#1,_showExecPal									; check for execution screen
	ble		.h
		movem.l	execscreen+4,d0-d7
		movem.l	d0-d7,$ffff8240
		subq.w	#1,glitch_frames
		bne		.nopal			
			move.w	#0,_showExecPal
			move.w	#3,glitch_frames
			move.w	#0,_glitch1_executionscreen
			move.w	#1,_screenSwap
			move.l	#execscreen+4,doOneMorePointer
			move.w	#3,doOneMore
			jmp		.nopal
.h
	subq.w	#1,_showCPTPal									; check for checkpoint screen
	ble		.g
		movem.l	cptpal,d0-d7
		movem.l	d0-d7,$ffff8240

		subq.w	#1,glitch_frames
		bne		.nopal
			move.w	#0,_showCPTPal
			move.w	#3,glitch_frames
			move.w	#0,_glitch2_cptscreen
			move.w	#1,_screenSwap
			move.l	#cptpal,doOneMorePointer
			move.w	#3,doOneMore
			jmp		.nopal
.g
	subq.w	#1,_showDHSPal									; check for dhs screen
	ble		.f
		movem.l	execscreen+4,d0-d7
		movem.l	d0-d7,$ffff8240
		subq.w	#1,glitch_frames
		bne		.nopal
			move.w	#0,_showDHSPal
			move.w	#3,glitch_frames
			move.w	#0,_glitch3_dhsscreen
			move.w	#1,_screenSwap
			move.l	#execscreen+4,doOneMorePointer
			move.w	#3,doOneMore
			jmp		.nopal
.f
	tst.w	_invertColors									; check for color inversion
	bgt		.noInvert
		lea		totalPalette,a0
		sub.w	#32,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		jmp		.nopal
.noInvert
	tst.w	_whiteFlash										; check for white flash
	beq		.noflash
		lea		totalPalette,a0
		add.w	pulseFadeInOffset,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		add.w	#32,pulseFadeInOffset
		cmp.w	#pulseNormalOffset,pulseFadeInOffset
		bne		.nopal
			move.w	#0,_whiteFlash
		jmp		.nopal

.noflash	

	tst.w	_glitch1_executionscreen
	beq		.noshow
		move.w	#100,_showExecPal
		move.w	#100,_screenSwap
		move.l	alignpointer6,$ff8200
.noshow

	tst.w	_glitch2_cptscreen
	beq		.noshow2
		move.w	#100,_showCPTPal
		move.w	#100,_screenSwap
		move.l	alignpointer8,$ff8200
.noshow2

	tst.w	_glitch3_dhsscreen
	beq		.noshow3
		move.w	#100,_showDHSPal
		move.w	#100,_screenSwap
		move.l	alignpointer6,$ff8200
.noshow3

.doPal
	tst.w	_pulseFadeActive
	beq		.ttt
	subq.w	#1,_pulseFadeWaiter
	bne		.ttt
		move.w	#pulseFramesPerFade,_pulseFadeWaiter
		sub.w	#32,pulseFadeInOffset
		cmp.w	#pulseNormalOffset,pulseFadeInOffset
		bge		.tt
		move.w	#pulseNormalOffset,pulseFadeInOffset
.tt
	lea		totalPalette,a0
	add.w	pulseFadeInOffset,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
.ttt
	tst.w	_scrollerActive
	beq		.tt2
		jsr 	fixColors
.tt2
	; we are either fading in, or we are fading from black to ....
		lea		scroller_text_color_fadelist,a0
		add.w	bgFadeInOffset,a0
		move.w	(a0),$ffff8240+2*8
		lea		scroller_text_color_fadelist,a0
		add.w	counterOffset,a0
		move.w	(a0),$ffff8240+2*4
.nopal
	subq.w	#1,doOneMore
	beq		.hahabug
	blt		.tok
		move.l	doOneMorePointer,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		jmp		.kkk
.tok
	tst.w	_pulseFadeOut
	beq		.kkk
		lea		hurrcolors,a0
		add.w	hurroff,a0
		movem.w	(a0),d0-d3
		move.w	d0,$ffff8240+2*1
		move.w	d0,$ffff8240+2*4
		move.w	d0,$ffff8240+2*9
		move.w	d2,$ffff8240+2*2
		move.w	d2,$ffff8240+2*10
		move.w	d1,$ffff8240+2*3
		move.w	d1,$ffff8240+2*11
		move.w	d3,$ffff8240+2*8
		subq.w	#1,hurrtimer
		bne		.kkk
			move.w	#15,hurrtimer
			add.w	#8,hurroff
			cmp.w	#8*hurroffsteps,hurroff
			ble		.kkk
				move.w	#8*hurroffsteps,hurroff
				move.w	#0,_pulseFadeOut
				move.w	#-1,_active
.kkk
	rts


.hahabug
	lea		totalPalette,a0
	add.w	pulseFadeInOffset,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
		lea		scroller_text_color_fadelist,a0
		add.w	bgFadeInOffset,a0
		move.w	(a0),$ffff8240+2*8
		lea		scroller_text_color_fadelist,a0
		add.w	counterOffset,a0
		move.w	(a0),$ffff8240+2*4
		rts

flashFrames	equ	2

fixColors
	move.w	bgFadeInOffset,d0
	beq		.noChange
	bgt		.moreThanZero
.lessThanZero
		subq.w	#1,_bgFadeWaiter
		bne		.rts
			move.w	#flashFrames,_bgFadeWaiter
			addq.w	#2,bgFadeInOffset
		rts
.moreThanZero
		subq.w	#1,_bgFadeWaiter
		bne		.rts
			move.w	#bgFramesPerFade,_bgFadeWaiter
			subq.w	#2,bgFadeInOffset
			subq.w	#2,counterOffset
		rts
.noChange
.rts
	rts


pulseNormalOffset	equ	7*32

clearGarbage
	move.l	screenpointer2,a0
	moveq	#0,d0
	move.l	d0,(a0)
	move.l	d0,2(a0)
	move.l	d0,160(a0)
	move.l	d0,162(a0)
	rts

copyExecution
	move.w	#136,d7
	add.w	#37*160,a1
.ol
		REPT 20
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
	dbra	d7,.ol
	rts

preShiftFontInit
	lea		scrollerfont,a3
	move.l	bssBuffer+preshiftFontPointer,a4
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
	move.l	bssBuffer+preshiftFontPointer,a4
	move.l	#letterswidth-1,d7
	moveq	#0,d5
.shiftChar
		move.l	a4,a0
		move.l	a4,a1
		add.l	#2*(fontwidth+1)*fontheight,a1
		move.w	#15-1,d6
.ol1
		move.w	#fontheight-1,d5
.xxx
			movem.w	(a0)+,d0-d2
			roxr.w	d0
			roxr.w	d1
			roxr.w	d2
			move.w	d0,(a1)+
			move.w	d1,(a1)+
			move.w	d2,(a1)+
			dbra	d5,.xxx
		dbra	d6,.ol1
		add.l	#(fontwidth+1)*2*fontheight*16,a4
	dbra	d7,.shiftChar
	rts

drawPixelThings2
	move.w	#74*4,d1
	move.l	screenpointer2,d6										; screen pointer
	move.l	d6,d5													; save screenpointer
	move.l	bssBuffer+x_block_pointer,d0										; x_block
	move.l	d0,d3													; save

	lea		.colorTable,a0
	moveq	#0,d4
	move.w	bssBuffer+colorListOffset,d4
	move.l	bssBuffer+currentPointAddress,a6			; current head
	; make sure we dont have double -1
	move.w	(a6),d0
	bge		.continue
		addq.w	#4,bssBuffer+colorListOffset
		cmp.w	#64*4,bssBuffer+colorListOffset
		beq		.loop
		jmp		.found
.loop
		move.w	#0,bssBuffer+itercount
		move.w	#0,bssBuffer+colorListOffset

		lea		bssBuffer+_pointList,a6
		add.w	bssBuffer+_pointlistOff,a6
		move.l	(a6),a6
		move.l	a6,bssBuffer+currentPointAddress
		add.w	#4,bssBuffer+_pointlistOff
		rts
.continue
	; search the next pointer
.search
	; search for first x-value that is not d0
	lea		4(a6),a6
	cmp.w	(a6),d0
	beq		.search
	; when we hit here, we know that a6 points to the first x-value thats different, so from here we can move back
	; store this for the next iteration
.found
	move.l	a6,d2		
	move.w	d0,d7						; d6 is current streak
	move.l	(a0,d4.w),a5
	; draw pixel

.drawPixel
	move.w	-(a6),d5					; y
	move.w	-(a6),d0					; x
	cmp.w	d0,d7						; streak ended?
	bne		.streakend

.continuestreak
	move.w	d0,d3						; we draw 2 by 2
	addq.w	#4,d3						; x = x+1 for 2 by 2 block
	move.w	d5,d6

	move.l	d0,a3					;4		; first pixel x
	add.w	(a3)+,d6				;8		;	x offset
	move.l	d6,a2					;4		; screen + offset for x		
	move.w	(a3)+,d6				;8		; mask

	move.l	d3,a4					;4		; pixel + 1
	add.w	(a4)+,d5				;8
	move.l	d5,a3							; screen + offset for x+1
	move.w	(a4)+,d5						; mask

	; masks and addresses sreen:
	;	x	> a2 screen, d6 mask
	;	x+1	> a3 screen, d5 mask
	jmp		(a5)

.streakend
	cmp.w	bssBuffer+itercount,d4
	bne		.checkmore
		add.w	#4,bssBuffer+itercount
		move.l	d2,bssBuffer+currentPointAddress
		rts

.checkmore
	addq.w	#4,d4						; here we change the drawing pixel method, bump offset by 4
	cmp.w	d1,d4						; check if we should stop drawing or not
	bne		.letsgo
		move.l	d2,bssBuffer+currentPointAddress
		rts
.letsgo
	move.w	d0,d7					; we have a new stream, so change the x value 
	move.l	(a0,d4.w),a5
	jmp		.continuestreak			; lets draw!

.colorjump
.color1								; bpl 1
	or.w	d6,96*160(a2)					;2
	or.w	d6,97*160(a2)				;4
	or.w	d5,96*160(a3)					;2
	or.w	d5,97*160(a3)				;4
	jmp		.drawPixel				;4		16
	ds.b	8
.color2								; bpl 1+2
	or.w	d6,2+96*160(a2)				;4
	or.w	d6,160+2+96*160(a2)			;4
	or.w	d5,2+96*160(a3)				;4
	or.w	d5,160+2+96*160(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4
.color3		
	not.w	d5
	not.w	d6						; bpl 2

	and.w	d6,96*160(a2)				;4
	and.w	d6,160+96*160(a2)			;4
	and.w	d5,96*160(a3)				;4
	and.w	d5,160+96*160(a3)			;4
	jmp		.drawPixel				;4		;20
	ds.b	4
.color4								; bpl 1+3
	not.w	d6						;2
	and.w	d6,2+96*160(a2)				;4
	and.w	d6,160+2+96*160(a2)			;4
	not.w	d5						;2
	and.w	d5,2+96*160(a3)				;4
	and.w	d5,160+2+96*160(a3)			;4
	jmp		.drawPixel				;4	;24
.color5								; bpl 3
	jmp		.drawPixel				;4
	ds.b	4

.colorTable
	dc.l	.color1					; 2x color1
	dc.l	.color1					; 11x drawpix
	dc.l	.drawPixel				; 2x color2
	dc.l	.drawPixel				; 13 drawpix
									; 2x color3
									; 14 drawpix
									; 2x color4
									; 32x drawpix
									;----> 78 * 4 = 312
	dc.l	.drawPixel	
	dc.l	.drawPixel	
	dc.l	.drawPixel	
	dc.l	.drawPixel	

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.color2
	dc.l	.color2
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.color3
	dc.l	.color3
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.color4
	dc.l	.color4

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel

	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
	dc.l	.drawPixel
.colorTableEnd

;; in case we're scrounging for some bytes...
;genColorTable
;	move.l	#color1,d0
;	move.l	#color2,d1
;	move.l	#color3,d2
;	move.l	#color4,d3
;	move.l	#drawPixel,d4
;
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+
;	move.w	(a1)+,d7
;.x1
;		move.l	d4,(a0)+
;	dbra	d7,.x1
;	move.l	d1,(a0)+
;	move.l	d1,(a0)+
;	move.w	(a1)+,d7
;.x2
;		move.l	d4,(a0)+
;	dbra	d7,.x2
;	move.l	d2,(a0)+
;	move.l	d2,(a0)+
;	move.w	(a1)+,d7
;.x3
;		move.l	d4,(a0)+
;	dbra	d7,.x3
;	move.l	d3,(a0)+
;	move.l	d3,(a0)+
;	move.w	(a1)+,d7
;.x4
;		move.l	d4,(a0)+
;	dbra	d7,.x4
;	rts



stringOff	dc.w	86*160			;	86*160
stringOff2	dc.w	86*160
sppointer	dc.l	0
sommarhackActive	dc.w	0

doSommarhack
	lea		helloworld,a0
	move.l	screenpointer2,a1
	add.w	#86*160+16,a1
	move.w	#29-1,d7
.il
o set 0
	REPT 16
		move.w	(a0)+,o+6(a1)
o set o+8
	ENDR
	add.w	#160,a1
	dbra	d7,.il

lala
		move.w	#-1,_whiteFlash
		move.w	#0,pulseFadeInOffset
		move.w	#$4e75,lala
	rts

; idea is to do: draw char at pixel
; d0,d1,d2,d3,d4,d5
drawStringAtPixel
	tst.w	sommarhackActive
	bne		doSommarhack
	move.w	bssBuffer+pixelPosition,bssBuffer+_pixelPosition
	move.l	screenpointer2,a2
	tst.w	_invertColors
	bge		.xxx
	add.w	stringOff,a2
	jmp		.yyy
.xxx
	add.w	#86*160,a2
.yyy

	add.w	#6,a2
	move.l	a2,sppointer
	move.l	bssBuffer+_scrollerTextSourcePointer,a2
	add.w	bssBuffer+_scrollTextOffset,a2
	lea		characterWidthTable,a3
	move.l	bssBuffer+pixelToBlockOfffsetTablePointer,a4
	move.l	bssBuffer+pixelToPreshiftOffsetTablePointer,a5
	move.l	bssBuffer+preshiftFontPointer,a6
	move.w	#20*8,d3
	move.w	#-3*8,d5
	move.b	#65,d6
.doChar
	move.w	bssBuffer+_pixelPosition,d0
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
		add.w	#10,bssBuffer+_pixelPosition
		cmp.w	d5,d1
		beq		.special2
		jmp		.doChar
.nospace
	add.w	d0,d0
	move.w	(a3,d0.w),d4
	lsr.w	#2,d4
	add.w	d4,bssBuffer+_pixelPosition
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
	add.w	#1,bssBuffer+_scrollTextOffset
	cmp.w	#55,bssBuffer+_scrollTextOffset
	bge		.resetshit
	add.w	d4,bssBuffer+pixelPosition
	jmp		.doChar

.resetshit
	move.w	#0,bssBuffer+_scrollTextOffset
	move.w	#1,bssBuffer+pixelPosition
	jmp		.doChar

advancePixelPosition
	tst.w	_invertColors
	blt		.inverted		
	sub.w	#1,bssBuffer+pixelPosition
	rts

.inverted
	sub.w	#6,bssBuffer+pixelPosition
	rts

;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; OUTTRO END ;;;;;;;;;;;;;;

_demoloopcounter	dc.l	231337-277
_cc					dc.w	384

drawTimes2
	subq.w	#1,_cc
	bne		.kk
		addq.l	#1,_demoloopcounter
		move.w	#384,_cc
.kk
	tst.w	_invertColors
	bge		.kkk
		addq.l	#1,_demoloopcounter
.kkk
	move.l	_demoloopcounter,d0
	move.l	screenpointer2,a1
	lea		numbers+80,a2
	lea		sublist,a4
	add.l	#190*160,a0
	add.l	#190*160,a1

	sub.w	(a4),a0
	sub.w	(a4)+,a1
o set 4
	REPT 8 
		move.b	(a2)+,d6
		or.b	d6,o(a1)
o set o+160
	ENDR

	move.w	#10,d7
	lea		numbers,a2
.loop
	divs	d7,d0
	move.l	d0,d1
	swap	d1

	add.w	d1,d1	;2
	add.w	d1,d1	;4
	add.w	d1,d1	;8
	lea		(a2,d1.w),a3
	sub.w	(a4),a0
	sub.w	(a4)+,a1

o set 4
	REPT 8
		move.b	(a3)+,d6
		or.b	d6,o(a1)
o set o+160

	ENDR
	ext.l	d0
	cmp.w	#0,d0
	bne		.loop
.end
	rts


init_yblock_aligned
	move.l	bssBuffer+y_block_pointer,a1
	move.l	#200-1,d7
	moveq	#0,d0
	move.l	#160<<16+160,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop
	rts

clearFontLine
	move.l	screenpointer2,a0
	add.w	stringOff2,a0
	add.w	#6,a0
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

	tst.w	_invertColors
	bgt		.ttt

	tst.w	_tdirection
	beq		.go
	blt		.up
.down
		sub.w	#2*160,stringOff2
		cmp.w	#72*160,stringOff2
		bge		.go
			move.w	#-1,_tdirection
	jmp		.go
.up
		add.w	#2*160,stringOff2
		cmp.w	#92*160,stringOff2
		ble		.go
			move.w	#1,_tdirection
.go
	move.w	stringOff,d0
	move.w	stringOff2,stringOff
	move.w	d0,stringOff2
	rts
.ttt
	move.w	stringOff,d0
	move.w	stringOff2,stringOff
	move.w	d0,stringOff2
	move.w	#86*160,stringOff
	rts

_tdirection	dc.w	-1
	
; generate table for individual pixels for each 320 placements on screen
; format: offset,mask
; from left to right
init_xblock_aligned
	move.l	bssBuffer+x_block_pointer,a1
	move.w	#$8000,d5
	moveq	#0,d1
	moveq	#20-1,d7
.ol
	moveq	#16-1,d6
	move.w	d5,d0
.il
			move.w	d1,(a1)+
			move.w	d0,(a1)+
			lsr.w	#1,d0
		dbra	d6,.il
		addq	#8,d1
	dbra	d7,.ol
	rts	

; generate shit
generatepixelToPreshiftOffsetTable
	move.l	bssBuffer+pixelToPreshiftOffsetTablePointer,a1
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
	move.l	bssBuffer+pixelToBlockOfffsetTablePointer,a1
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

genOuttro2
	move.l	bssBuffer+_outtropoint1,a0
	sub.w	#$100,a0
	move.w	#$100>>2-1,d7
.ccc
		move.l	#-1,(a0)+
	dbra	d7,.ccc
hoho
	move.w	#780,d2

	moveq	#0,d0
	move.w	#18560,d1
	move.w	#13-1,d7								;13
.l
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		add.w	#4,d0
	dbra	d7,.l

 	lea		outtropoints_source,a1
	move.w	#502-1,d7								;502
.l2
		move.l	(a1)+,(a0)+
		dbra	d7,.l2
	
	move.w	#416,d0
	move.w	#103-1,d7								;103
.l3
		move.w	d0,(a0)+
		move.w	d1,(a0)+		
		addq.w	#4,d0
	dbra	d7,.l3

	lea		outtropoints_source,a1
	move.w	#502-1,d7								;502
.l4
		move.w	(a1)+,d0
		add.w	d2,d0
		move.w	d0,(a0)+
		move.w	(a1)+,(a0)+
	dbra	d7,.l4
	move.w	#21-1,d7								;21		--> 1141
	move.w	#1196,d0
.l5
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		addq.w	#4,d0
	dbra	d7,.l5
	move.w	#-1,(a0)+
	move.w	#-1,(a0)+
	rts


genOuttro3
	move.l	bssBuffer+_outtropoint2,a0
	sub.w	#$100,a0
	move.w	#$100>>2-1,d7
.ccc
		move.l	#-1,(a0)+
	dbra	d7,.ccc
	move.w	#780,d2

	moveq	#0,d0
	move.w	#18560,d1
	move.w	#13-1,d7								;13
.l
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		add.w	#4,d0
	dbra	d7,.l

 	lea		outtropoints_source,a1
	move.w	#502-1,d7								;502
.l2
		move.l	(a1)+,(a0)+
		dbra	d7,.l2
	
	move.w	#416,d0
	move.w	#214-1,d7
.l3
		move.w	d0,(a0)+
		move.w	d1,(a0)+		
		addq.w	#4,d0
	dbra	d7,.l3
	move.w	#-1,(a0)+
	move.w	#-1,(a0)+

	rts	

	SECTION DATA 
		ds.b	100
numbers	incbin	"fx/pulseintro/numbers2.bin"
		ds.b	100
sublist
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines

haxSpace
moveTab															; label for checkerdist
x_table_fill													; label for fullscreen tridi, 3900 size
intro															; label for greetings unpacked
music		incbin	"msx/execint4.l77"							;	47768	18317(l77)	
	even
x_table_eor														; label for fullscreen tridi, 3900 size
;;;;;;;;;;;;;;;;;;;;;; PULSE INTRO
;;;;;;;;;;;;;;;;;;;;;; PULSE INTRO
;;;;;;;;;;;;;;;;;;;;;; PULSE INTRO
;;;;;;;;;;;;;;;;;;;;;; PULSE INTRO
_wewerefaderwaiter	dc.w	4
_faderShowWaiter	dc.w	248-60
_invertColors		dc.w	1
glitch_frames		dc.w	3
glitch1_frames		dc.w	3
glitch2_frames		dc.w	3
glitch3_frames		dc.w	3
_screenSwap			dc.w	-1

hurrcolors
			;1   ;3   ;2	;8 		12
	dc.w	$302,$102,$202,$112
	dc.w	$201,$001,$101,$001
	dc.w	$100,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	0,0,0,0
wewereat				dc.w	$000, $777, $556, $243, $233, $123, $112, $102
outtrotext			;		 and the beat goes on and on and the beat goes on and on and the beat goes on and on
					dc.b	"AGC JFD BDAJ EHDI HG AGC HG AGC JFD BDAJ EHDI HG AGC HG AGC JFD BDAJ EHDI HG AGC HG"
	even
cptpal 					dc.w	$000,$777,$765,$566,$654,$455,$545,$443,$433,$332,$323,$101,$212,$111,$100,$201
execscreen				incbin	"fx/pulseintro/exec4.l77"		;22048 (orig) 6012 (l77) 3725 (arj)			-2300		6012					(3725)
planarBuffer	; scale 1bpl
scalelogo		; scale 3bpl
smfxpic					incbin	"fx/pulseintro/smfx.l77"		;14208 (orig) 8744 (l77) 7463 (arj)			-1300 		8744					(11188)
cptlogo					incbin	"fx/pulseintro/cpt.l77"			;9920 (orig) 5069 (l77)  4133 (arj)			-900		5079					(15321)
	even	

where					incbin	"fx/pulseintro/where.bin"		;1020	(561 arj)										1020					(15882)		
were					incbin	"fx/pulseintro/were.bin"		;1020	(490 arj)										1020					(16372)
we						incbin	"fx/pulseintro/we.bin"			;612	(361 arj)										612						(16733)
que						incbin	"fx/pulseintro/que.bin"			;612	(455 arj)										612						(17188)
scrollerfont			incbin	"fx/pulseintro/fontnew.bin"		;1160	(548 arj)										1160					(17736)
outtropoints_source		include	"fx/pulseintro/outtro3.s"		;2042													2042		27902

;sommarhack				incbin	"fx/pulseintro/helloworld.pi1"
helloworld				incbin	"fx/pulseintro/helloworld.bin"
;;;;;;;;;;;;;;;;;;;; TITLE SCREEN
;;;;;;;;;;;;;;;;;;;; TITLE SCREEN
;;;;;;;;;;;;;;;;;;;; TITLE SCREEN


;;;;;;;;;;;;;;;;;;;; SYNCSINE
;;;;;;;;;;;;;;;;;;;; SYNCSINE
;;;;;;;;;;;;;;;;;;;; SYNCSINE
y1s						include "fx/syncsine/y1asource64.s"		;128
y2s						include "fx/syncsine/y2asource512.s"	;1024
x1s						include "fx/syncsine/x1bsource273.s"	;546
x2s						include "fx/syncsine/x2bsource128.s"	;256
z1s						include "fx/syncsine/z6source128.s"		;256													2210		30112

planarpic				incbin	"fx/rotoz/textureplanar128x128.4bpl"					;8192	/ 6909									38304
rotoz					incbin	"fx/syncsine/texture_3bpl_finalz.bin"					;24000											62304

sync_we					incbin	"fx/syncsine/we.bin"			;480
sync_never				incbin	"fx/syncsine/never.bin"			;1080
sync_left				incbin	"fx/syncsine/left.bin"			;720

transition				incbin	"fx/syncsine/transitionf2.pi1"					; 19554 / 11037



;;;;;; MORE PULSE INTRO SHIT	
	; pack this shir up!
	dc.w	$777,$475,$675,$575,$665,$475,$675,$575,$665,$475,$675,$575,$665,$475,$675,$575			; 50*32 = 1600

totalPalette					
			;0	 ;1	  ;2   ;3	;4	 ;5	  ;6   ;7	;8	 ;9	  ;10  ;11	;12	 ;13  ;14  ;15

	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$666,$766,$667,$767,$666,$766,$667,$767,$667,$766,$667,$767,$666,$766,$667,$767
	dc.w	$555,$655,$556,$656,$555,$655,$556,$656,$556,$655,$556,$656,$555,$655,$556,$656
	dc.w	$444,$545,$445,$545,$444,$545,$445,$545,$445,$545,$445,$545,$444,$545,$445,$545
	dc.w	$333,$433,$334,$434,$333,$433,$334,$434,$334,$433,$334,$434,$333,$433,$334,$434
	dc.w	$222,$423,$223,$323,$222,$423,$223,$323,$223,$423,$223,$323,$222,$423,$223,$323
	dc.w	$111,$312,$112,$212,$111,$312,$112,$212,$112,$312,$112,$212,$111,$312,$112,$212			; 7*32 offset
.normal
	dc.w	$000,$302,$102,$202,$000,$302,$102,$202,$000,$302,$102,$202,$000,$302,$102,$202			;0			; 32 offset	
	dc.w	$000,$302,$202,$202,$000,$302,$102,$202,$000,$302,$102,$202,$000,$302,$102,$202			;1			
	dc.w	$000,$302,$302,$302,$000,$302,$302,$302,$000,$302,$302,$302,$000,$302,$302,$302			;2
	dc.w	$000,$313,$313,$313,$000,$313,$313,$313,$000,$313,$313,$313,$000,$313,$313,$313			;3
	dc.w	$000,$423,$423,$423,$000,$423,$423,$423,$000,$423,$423,$423,$000,$423,$423,$423			;4
	dc.w	$000,$534,$534,$534,$000,$534,$534,$534,$000,$534,$534,$534,$000,$534,$534,$534			;5
	dc.w	$000,$545,$545,$545,$000,$545,$545,$545,$000,$545,$545,$545,$000,$545,$545,$545			;6
	dc.w	$000,$655,$655,$655,$000,$655,$655,$655,$000,$655,$655,$655,$000,$655,$655,$655			;7
	dc.w	$000,$767,$767,$767,$000,$767,$767,$767,$000,$767,$767,$767,$000,$767,$767,$767			;8
	dc.w	$000,$777,$777,$777,$000,$777,$777,$777,$000,$777,$777,$777,$000,$777,$777,$777			;9
	dc.w	$000,$777,$777,$777,$000,$777,$777,$777,$000,$777,$777,$777,$000,$777,$777,$777			;10
	dc.w	$000,$776,$776,$776,$000,$776,$776,$776,$000,$776,$776,$776,$000,$776,$776,$776			;11
	dc.w	$000,$775,$775,$775,$000,$775,$775,$775,$000,$775,$775,$775,$000,$775,$775,$775			;12
	dc.w	$000,$774,$774,$774,$000,$774,$774,$774,$000,$774,$774,$774,$000,$774,$774,$774			;13
	dc.w	$000,$773,$773,$773,$000,$773,$773,$773,$000,$773,$773,$773,$000,$773,$773,$773			;14
	dc.w	$000,$772,$772,$772,$000,$772,$772,$772,$000,$772,$772,$772,$000,$772,$772,$772			;15
	dc.w	$000,$771,$771,$771,$000,$771,$771,$771,$000,$771,$771,$771,$000,$771,$771,$771			;16
	dc.w	$000,$770,$770,$770,$000,$770,$770,$770,$000,$770,$770,$770,$000,$770,$770,$770			;17
	dc.w	$000,$760,$760,$760,$000,$760,$760,$760,$000,$760,$760,$760,$000,$760,$760,$760			;18
	dc.w	$000,$750,$750,$750,$000,$750,$750,$750,$000,$750,$750,$750,$000,$750,$750,$750			;19
	dc.w	$000,$740,$740,$740,$000,$740,$740,$740,$000,$740,$740,$740,$000,$740,$740,$740			;20
	dc.w	$000,$730,$730,$730,$000,$730,$730,$730,$000,$730,$730,$730,$000,$730,$730,$730			;21
	dc.w	$000,$720,$720,$720,$000,$720,$720,$720,$000,$720,$720,$720,$000,$720,$720,$720			;22
	dc.w	$000,$710,$710,$710,$000,$710,$710,$710,$000,$710,$710,$710,$000,$710,$710,$710			;23
	dc.w	$000,$700,$700,$700,$000,$700,$700,$700,$000,$700,$700,$700,$000,$700,$700,$700			;24
	dc.w	$000,$600,$600,$600,$000,$600,$600,$600,$000,$600,$600,$600,$000,$600,$600,$600			;25
	dc.w	$000,$500,$500,$500,$000,$500,$500,$500,$000,$500,$500,$500,$000,$500,$500,$500			;26
	dc.w	$000,$400,$400,$400,$000,$400,$400,$400,$000,$400,$400,$400,$000,$400,$400,$400			;27
	dc.w	$000,$300,$300,$300,$000,$300,$300,$300,$000,$300,$300,$300,$000,$300,$300,$300			;28
	dc.w	$000,$200,$200,$200,$000,$200,$200,$200,$000,$200,$200,$200,$000,$200,$200,$200			;29
	dc.w	$000,$100,$100,$100,$000,$100,$100,$100,$000,$100,$100,$100,$000,$100,$100,$100			;30
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000			;31	31*32

	dc.w	$000,$302,$102,$202,$000,$302,$102,$202,$112,$302,$102,$202,$112,$302,$102,$202						; 32 offset	
	dc.w	$000,$202,$002,$102,$000,$202,$002,$102,$001,$202,$002,$102,$001,$202,$002,$102							;-1
	dc.w	$000,$201,$001,$101,$000,$201,$001,$101,$001,$201,$001,$101,$001,$201,$001,$101							;-2
	dc.w	$000,$101,$001,$001,$000,$101,$001,$001,$000,$101,$001,$001,$000,$101,$001,$101							;-3
	dc.w	$000,$101,$001,$001,$000,$101,$001,$001,$000,$101,$001,$001,$000,$101,$001,$101							;-4
	dc.w	$000,$001,$001,$001,$000,$001,$001,$001,$000,$001,$001,$001,$000,$001,$001,$001							;-5
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000							;-6
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000							;-7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000							;-8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000							;-8


bgFadeInOffset	dc.w	2*7


	dc.w	$777
	dc.w	$667
	dc.w	$556
	dc.w	$445
	dc.w	$334
	dc.w	$223
	dc.w	$112
scroller_text_color_fadelist
; end state
	dc.w	$112	; -1
	dc.w	$112	; -2
	dc.w	$111	;-3
	dc.w	$101	;-4
	dc.w	$001	;-5
	dc.w	$001	;-6
	dc.w	$000	;-7
	dc.w	$000

pulseFadeInOffset	dc.w	32*(31+7)
counterOffset		dc.w	2*7

spacebardist 		equ 10*4 
space				equ 3*4
stdoff				equ 19*4
characterWidthTable
	dc.w	23*4+space		;a
	dc.w	18*4+space		;b
;	dc.w	18*4+space		;c
	dc.w	22*4+space		;d
	dc.w	14*4+space		;e
;	dc.w	14*4+space		;f
	dc.w	20*4+space		;g
	dc.w	22*4+space		;h
;	dc.w	6*4+space		;i
;	dc.w	12*4+space		;j
;	dc.w	21*4+space		;k
;	dc.w	14*4+space		;l
;	dc.w	26*4+space		;m
	dc.w	20*4+space		;n
	dc.w	29*4+space		;o
;	dc.w	17*4+space		;p
;	dc.w	29*4+space		;q
;	dc.w	19*4+space		;r
	dc.w	16*4+space		;s
	dc.w	16*4+space		;t
;	dc.w	20*4+space		;u
;	dc.w	23*4+space		;v
;	dc.w	29*4+space		;w
;	dc.w	22*4+space		;x
;	dc.w	21*4+space		;y
;	dc.w	17*4+space		;z
;	dc.w	7*4+space		;.		[
;	dc.w	7*4+space		;:		\
;	dc.w	8*4+space		;!		]
;	dc.w	15*4+space		;-		^
;	dc.w	stdoff+space	;0		_
;	dc.w	12*4+space		;1		'
;	dc.w	17*4+space		;2		a
;	dc.w	20*4+space		;3		b
;	dc.w	stdoff+space	;4		c
;	dc.w	20*4+space		;5		d
;	dc.w	7*4+space		;,		e


haxSpace2

	SECTION BSS
	rsreset

_pixelPosition						rs.w	1
pixelPosition						rs.w	1
_scrollTextOffset					rs.w	1


preshiftFontPointer					rs.l	1
pixelToPreshiftOffsetTablePointer	rs.l	1
pixelToBlockOfffsetTablePointer		rs.l	1
currentPointAddress					rs.l	1
y_block_pointer						rs.l	1
x_block_pointer						rs.l	1
_scrollerTextSourcePointer			rs.l	1	
_outtropoint1						rs.l	1
_outtropoint2						rs.l	1
copyPointer							rs.l	1
backPointer							rs.l	1		;	21*4 = 84
_pointList							rs.l	7
_pointlistOff						rs.w	1		;	28
wherewerewecounter					rs.w	1
colorListOffset						rs.w	1
itercount							rs.w	1
_tbcols								rs.w	400


_resetFade							ds.w	1
_fadeActive							ds.w	1
_wewereatfadeout					ds.w	1
_pulseFadeActive					ds.w	1
_scrollerActive						ds.w	1
_showExecPal						ds.w	1
_glitch1_executionscreen			ds.w	1
_glitch2_cptscreen					ds.w	1
_glitch3_dhsscreen					ds.w	1
_invertWaiter						ds.w	1
_whiteFlash							ds.w	1
_pulseFadeOut						ds.w	1
_spawnSnake							ds.w	1
_showCPTPal							ds.w	1
_showDHSPal							ds.w	1
_fadeOffset							ds.w	1
_copyListOff						ds.w	1
_backListOff						ds.w	1
_copyDone							ds.w	1
_doBack								ds.w	1
_WhereWereWeFadeOut					ds.w	1		;	27*2 = 54
_active								ds.w	1	
codebufferPointer					ds.l	1



	SECTION DATA