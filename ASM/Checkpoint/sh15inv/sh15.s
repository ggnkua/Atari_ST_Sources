; CUBE STUFF
size equ 59
dedu equ 23		;size/(number/2)
number equ 5

waitcounterconstant		equ 110
effectCounterConstant	equ 1000

framecount			equ 0
playmusic			equ 1
playmusicinvbl		equ 1
playmusicinmainloop	equ 0
rasters				equ 0

; ********** 3D ROT **********
max_nr_of_vertices	equ 80
z_on				equ 1
pers				equ 1000

; ********** checkerboard sync ****
z_sync				equ 1

fontheight			equ 33
fontchars			equ 37
textdatasize		equ	33*6*20
spriteheight		equ 16

LOGS            	EQU 1024
EXPS            	EQU 4096

; font stuff
; optional precalc stuff
offsmapFromTGA		EQU 0
spriteFromFile		EQU 0
generateFont		EQU 0
generateBanner		EQU 0

; effect stuff
effect1			EQU doChecker
effect2			EQU	doBalls
effect3			EQU doCube
effect4			EQU	doFlowMap


    section	text

	include	asm/macro.s


		allocateStackAndShrink
	lea		(pc),a0
	cmp.l	#$b000,a0
	blt		.exit
	jsr	disableMouse
	jsr	checkMachineTypeAndSetStuff
	jsr	saveAndKillTimers

	jsr	backupPalAndScrMemAndResolutionAndSetLowRes

	move.w	#$2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,gemScreenBuffer

	jsr	customScreenAlign
	jsr	init_aligned_blocks
	jsr	storeLowerMem


;;;;; SETUP COMPLETE, NOW DO INIT			
.init

	IFNE playmusic
		lea		music,a0
		move.l	a0,sndh_pointer
		jsr		initMusic
	ENDC

	move.w	#10,rastercounter
    move.w  #$2700,sr
    move.l  #top_bottom_vbl_intro,$70.w                    ;Install our own VBL
    move.w  #$2300,sr
    		wait_for_vbl

.gogo
    cmp.w	#2,colorbar
    bne		.gogo

	jsr		copyLogo

	move.w	#$743,$ffff8244

			framecount_start	

	jsr		init_exp_log
	jsr		generateSpriteToBlocksInnerCode
	IF	generateFont
		jsr		font_to_bitplane				; remove when final
	ENDC
	jsr		generatePlaneShiftCode

	IFNE generateBanner
		jsr		generateBannerPic
	ENDC

	; sort this shit out
	IF	offsmapFromTGA
		jsr		generateOffsetFromTGA			; remove when final
	ENDC
	jsr		initFlowMap						; remove when final

	move.l	c2PCodePointer,a0	
	lea		offsmap,a6
	jsr		generateFlowMapCode

	move.l	c2PCodePointer2,a0
	lea		offsmap2,a6
	jsr		generateFlowMapCode

	move.l	c2PCodePointer,currentC2PCodePointer


	jsr		init_yblock_aligned
	jsr		initZTable
	jsr		init_object						; remove when final
	jsr 	initRotationCode
	jsr		generate3bplCode
	IF	spriteFromFile
		jsr		initSprite
	ENDC
	jsr		generateDrawSpriteCode

	jsr		generateBallsCode
			framecount_stop		;--> 14 frames

	jsr		fixSourceDerp

	jsr		generateCharLookup
    move.w  #$2700,sr
    move.l  #top_bottom_vbl,$70.w                    ;Install our own VBL
    move.w  #$2300,sr


    	wait_for_vbl
    	nop
    	nop
.mainloop:
		wait_for_vbl
	jsr swapscreens

	subq.w	#1,notextcounter
	bne		.cont
		move.w	#-1,notext
.cont
	tst.w	text_precalc
	beq		.noTextPrecalc
		jsr	renderTextFrame
.noTextPrecalc

	jsr	doEffect
		raster	#$070
	jsr	doText
		raster	#$122


	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop
	;----- END --------------------------------------------

	jsr	restoreLowerMem
	jsr	restoreTimers
	jsr	restoresForMachineTypes
	jsr	stopMusic
	jsr	enableMouse
	jsr	restorePalAndScreenMemAndResolution
.exit
	rts


	IFNE generateBanner
generateBannerPic
	lea		xa1+34,a0			;19
	lea		xb2+34+19*160,a1			;3
	lea		xc3+34+22*160,a2			;24
	lea		tmppic,a3

	REPT 19
		REPT 20
		move.l	(a0)+,(a3)+
		move.l	(a0)+,(a3)+
		ENDR
	ENDR
	REPT 3
		REPT 20
		move.l	(a1)+,(a3)+
		move.l	(a1)+,(a3)+
		ENDR
	ENDR
	REPT 24
		REPT 20
		move.l	(a2)+,(a3)+	
		move.l	(a2)+,(a3)+
		ENDR
	ENDR
	lea		tmppic,a0		; 50 * 160 = 8000
	lea		xa1+2,a1	
	lea		xb2+2,a2	
	lea		xc3+2,a3
	move.b	#0,$ffffc123
	rts	
	ENDC

spriteToBlocks
	lea		spriteList,a0
	add.w	spriteListOffset,a0
	addq.w	#4,spriteListOffset
	cmp.w	#44,spriteListOffset
	bne		.cont
		move.w	#0,spriteListOffset
.cont
	move.l	(a0),a0
	move.l	a0,a1
	move.l	a0,d0
	move.l	d0,d7
	move.l	a1,d1
	move.l	blockPointer,a2
	move.l	spriteToBlocksCodePointer,a3
	jmp		(a3)

;	move.b	#0,$ffffc123
;	REPT 16
;		move.l	d7,a0									; 2047
;		REPT 16
;		move.l	d1,a1									; 2241
;			REPT 8
;				move.b	(a0)+,(a2)+		; 12			; 14D8
;				move.b	(a1)+,(a2)+						; 14D9				( ( 8*4 + 2 ) * 16 + 4 ) * 16 = 548 * 16 = 8768 + 2 = 8768
;			ENDR
;		ENDR
;		addq.l	#8,d1									; 5081
;	ENDR
;	rts



generateSpriteToBlocksInnerCode
	move.l	spriteToBlocksCodePointer,a0
	moveq	#16-1,d7
	move.l	d7,d6
	move.l	d7,d5
	move.w	#$2047,d0
	move.w	#$2241,d1
	move.l	#$14D814D9,d2
	move.w	#$5081,d3

.ol
	move.w	d0,(a0)+
	move.l	d5,d6
.il
	move.w	d1,(a0)+
	REPT 8	
		move.l	d2,(a0)+
	ENDR
	dbra	d6,.il
	move.w	d3,(a0)+
	dbra	d7,.ol

	move.w	#$4e75,(a0)+
	rts


ballcountera2
	dc.w	0
ballcountera3
	dc.w	0
ballcountera6
	dc.w	0
herp
	dc.l	0

ballcountera2max	equ 	299*4
ballcountera3max	equ 	199*4
ballcountera6max	equ 	499*4

addcounter	dc.w	0

doBalls
	move.l	sndh_pointer,a0
	add.w	#$b8,a0
	move.b	(a0),d0
	cmp.b	#1,d0
	bne		.noset
		move.b	#0,(a0)
		move.w	#26,clapcounter
.noset
		tst.w	clapcounter
		beq		.normal
			subq.w	#1,clapcounter
.normal
		move.l	screenpointeraligned2,a0
		sub.l	#32-6,a0
		move.l	blockPointer,a1
		move.l	a1,d7
		move.l	a1,usp

		lea		rastersource,a2
		move.l	rasterSource2Pointer,a3
		move.l	a2,a6

		lea		balla3,a4
		add.w	ballcountera3,a4
		add.w	(a4)+,a3
		add.w	(a4)+,a3

		;;;;;;;	add to map
		move.b	#20,d6
		move.w	clapcounter,d5
		subq.w	#1,d5
		muls	#80,d5
		move.l	a3,a5
		add.w	d5,a5
		move.l	a5,herp
o set 0	
		REPT 40
			add.b	d6,o(a5)			;	40*16 = 640
o set o+1
		ENDR

		lea		balla2,a4
		add.w	ballcountera2,a4
		add.w	(a4)+,a2
		add.w	(a4)+,a2

		lea		balla6,a4
		add.w	ballcountera6,a4
		add.w	(a4)+,a6
		add.w	(a4)+,a6


		add.w	#4,ballcountera2
		cmp.w	#ballcountera2max,ballcountera2
		blt		.go
			move.w	#0,ballcountera2
.go
		add.w	#4,ballcountera3
		cmp.w	#ballcountera3max,ballcountera3
		blt		.go2
			move.w	#0,ballcountera3
.go2
		add.w	#4,ballcountera6
		cmp.w	#ballcountera6max,ballcountera6
		blt		.go3
			move.w	#0,ballcountera6
.go3

		lea		left_table,a4
		lea		right_table,a5
		moveq	#0,d0
		moveq	#0,d1
		move.l	ballCodePointer,a1
		jsr		(a1)


		move.l	herp,a3
		move.b	#20,d6
o set 0
		REPT 40
			sub.b	d6,o(a3)
o set o+1
		ENDR
		rts

generateBallsCode
	move.l	ballCodePointer,a0
	move.l	#$45EA0028,d0		
	move.l	#$2247101B,a1		; move.l d7,a1 		; move.b	(a3)+,d0
;	move.w	#$101B,a2
	move.l	#$D01ED01A,a2		; add.b	(a6)+,d0	; add.b	(a2)+,d0
	move.l	#$101BD01E,a3		
	move.w	#$D01A,a4
	move.l	#$D2F40000,a5		; add.w	(a4,d0.w),a1
	move.l	#$D2F50000,a6

	move.l	#$31590000,d2
	move.w	#160,d3

	move.l	#$47EB0028,d4
	move.l	#$4DEE0028,d5

	moveq	#0,d1											;	h set 0
	move.l	#25-1,d7										;	rept 25
.ol															
	move.l	#20-1,d6										;	rept 20
.il
		move.w	d1,d2										;	o set h
		move.l	a1,(a0)+					;2			; move.l d7,a1 		; move.b	(a3)+,d0

		move.l	a2,(a0)+					;2			;	add.b	(a6)+,d0	;	add.b	(a2)+,d0

		move.l	a5,(a0)+					;4			;	add.w	(a4,d0.w),a1

		move.l	a3,(a0)+					;2			;	move.b	(a3)+,d0
;		move.w	a3,(a0)+					;2			;	add.b	(a6)+,d0
		move.w	a4,(a0)+					;2			;	add.b	(a2)+,d0

		move.l	a6,(a0)+				;4		--> 22	add.w	(a5,d0.w),a1
		REPT 8	
			move.l 	d2,(a0)+				;2			;	move.w	(a1)+,1234(a0)
			add.w	d3,d2									;	o set o +160
		ENDR
		addq.w	#8,d1							;2			;	h set h+8		--> 2 ---> 56 * 20 = 1120 + 12 = 1132 * 25 = 28300 + 2 = 28302
	dbra	d6,.il
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d0,(a0)+
	add.w	#160*7,d1
	dbra	d7,.ol

	move.w	#$4e75,(a0)
	rts


text_render_state
	dc.w	0
debugcounter
	dc.w	15

effectListLength equ 16

effectList
	dc.l	effect1
	dc.l	effect2
	dc.l	effect3
	dc.l	effect4

effectListoffset
	dc.w	0
effectCounter
	dc.w	effectCounterConstant
clearCounter
	dc.w	0

doCube
		raster	#$700
	jsr	clearSprites
		raster	#$070
	jsr	doRotationPoly
		raster	#$007
	jsr drawSprites
		raster	#$336
	rts

clearScreen
	move.l	screenpointeraligned2,a0
	sub.w	#32,a0
	add.w	#6,a0
	moveq	#0,d0
	move.l	#200-1,d7
.ol
o	set 0
		REPT 20
			move.w	d0,o(a0)		;12 cycles		20*200*12 = 48000
o	set o+8
		ENDR
		add.w	#160,a0				;8
	dbra	d7,.ol					;12	200*20 = 4000
	rts

doEffect
	tst.w	clearCounter
	beq		.effect
		jsr		clearScreen
		subq.w	#1,clearCounter
		beq		.generateInverse
.generateBase
			jsr	spriteToBlocks
			rts
.generateInverse
			move.l	blockPointer,a0
			move.l	picInversePointer,a1
			move.l	#16*16-1,d7
.t5
			REPT 8
				move.w	(a0)+,d0
				not.w	d0
				move.w	d0,(a1)+
			ENDR
			dbra	d7,.t5
		rts
.effect	
	lea		effectList,a0
	add.w	effectListoffset,a0
	move.l	(a0),a0
	jsr		(a0)
	subq.w	#1,effectCounter
	bne		.end
		move.w	#effectCounterConstant,effectCounter
		move.w	#2,clearCounter
		addq.w	#4,effectListoffset
		addq.w	#2,colorSchemeOffset
		cmp.w	#colorSchemeOffsetLength,colorSchemeOffset
		bne		.xx
			move.w	#0,colorSchemeOffset
.xx
		move.w	#0,clapcounter
		cmp.w	#effectListLength,effectListoffset
		bne		.end
			move.w	#0,effectListoffset
			move.l	currentC2PCodePointer,a0
			move.l	c2PCodePointer2,currentC2PCodePointer
			move.l	a0,c2PCodePointer2
.end
	rts



text_render_statelist
	dc.l	clearTextSpacesInit
	dc.l	clearTextSpaces
	dc.l	renderInit
	dc.l	renderTwoCharactersToBuffer
	dc.l	preshiftTextFrame

textSpacesAddress
	dc.l	0
textSpacesCounter
	dc.w	0


clearTextSpacesInit
	lea		textspace1,a0
	add.l	#316800,a0

	;	316800	= 5 * 63360
	;	63360 = 16 * 3960
	;	first 3960 is the source

	move.l	a0,textSpacesAddress
	move.w	#33,textSpacesCounter
	add.w	#4,text_render_state

clearTextSpaces	
	move.l	textSpacesAddress,a0

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
						; --> 12 * 4 = 48
						;	316800 / 48 = 6600 / 600 = 11
	moveq	#10-1,d7		; 10 * 20 * 112 = 44800
.x
		REPT 20
			movem.l	d0-d6/a1-a5,-(a0)				; 3960/44 = 90
		ENDR
	dbra	d7,.x

	move.l	a0,textSpacesAddress
	subq.w	#1,textSpacesCounter
	bne		.end
		addq.w	#4,text_render_state
.end
	rts

renderTextFrame
	lea		text_render_statelist,a0
	add.w	text_render_state,a0
	move.l	(a0),a0
	jsr		(a0)
	rts

renderInit
	move.l	#0,currentTextShiftIteration
	move.w	#15,textshiftcounter

	lea		textlist,a0
	add.w	textlistoffset,a0
	move.l	(a0),textStringPointer
	lea		textspacelist,a0
	add.w	textspaceoffset,a0
	move.l	(a0),currentTextSpacePointer

	move.l	textStringPointer,a0
	move.w	(a0)+,savedCharCounter
	moveq	#16,d6		; total offset in pixels for each char
	add.w	(a0)+,d6
	move.w	d6,savedCharOffset
	move.l	a0,savedCharacterPointer

	add.w	#4,text_render_state

	jsr		renderTwoCharactersToBuffer
	rts

renderTwoCharactersToBuffer						; yeah well, it seems we only really render one -_-
	jsr		renderOneCharacterToBuffer
	tst.w	savedCharCounter
	beq		.renderDone
	rts
.renderDone
		add.w	#4,text_render_state
	rts

renderOneCharacterToBuffer
	move.l	charLookupPointer,a1
	move.l	a1,usp
	move.l	#0,d3		; local var
	move.l	textDistPointer,a3
	move.l	currentTextSpacePointer,a4
	lea		textoff,a5
	move.l	#0,d3
.doletter
		moveq	#0,d0			;4		; clear 0
		move.l	savedCharacterPointer,a0
		move.w	savedCharOffset,d6
		move.b	(a0)+,d0		;8		; move ascii value of char into d0

		move.l	a0,savedCharacterPointer
		sub.b	#65,d0			;4		; align to offset font
		bge		.nospace
			add.w	#spacebardist,d6
			move.w	d6,savedCharOffset
			subq.w	#1,savedCharCounter
			bgt		.doletter
			rts
.nospace

		add.w	d0,d0			;4
		; load stuff
		move.l	a3,a6			;4
		add.w	d6,a6			;8
		add.w	(a5,d0.w),d6;16		; offset for next char
		move.w	d6,savedCharOffset

		add.w	d0,d0			;4

		move.l	usp,a1	;12
		move.l	(a1,d0.w),a1	;20

		; set up target
		move.l	a4,a2			;4
		add.w	(a6)+,a2		;12
		move.w	(a6),d5			;8 				number of shifts

		move.w	d5,d7
		neg.w	d7
		add.w	#16,d7			; to shift left
		; d5 is now number of shifts

o		SET 0
;		REPT 33
		moveq	#fontheight-1,d6
.loop
			movem.w	(a1)+,d0-d2/d4			;28

			move.w	d0,d3			; keep original in d0
			lsr.w	d5,d3			; first word ready
			or.w	d3,o(a2)		; first word in buffer
			lsl.w	d7,d0			; left part second word

			move.w	d4,d3			; keep original in d4
			lsr.w	d5,d3			; second word
			or.w	d3,d0			; right part second word
			move.w	d0,o+6(a2)		; second word in buffer

			lsl.w	d7,d4
			move.w	d4,o+12(a2)

			move.w	(a1)+,d4

			move.w	d1,d3
			lsr.w	d5,d3
			or.w	d3,o+2(a2)
			lsl.w	d7,d1

			move.w	d4,d3
			lsr.w	d5,d3
			or.w	d3,d1
			move.w	d1,o+8(a2)

			lsl.w	d7,d4
			move.w	d4,o+14(a2)

			move.w	(a1)+,d4

			move.w	d2,d3
			lsr.w	d5,d3
			or.w	d3,o+4(a2)
			lsl.w	d7,d2

			move.w	d4,d3
			lsr.w	d5,d3
			or.w	d3,d2
			move.w	d2,o+10(a2)

			lsl.w	d7,d4
			move.w	d4,o+16(a2)

			add.w	#6,a1
		add.w	#120,a2
o set o+120
;	ENDR
		dbra	d6,.loop
	subq.w	#1,savedCharCounter
	rts


preshiftTextFrame
	lea		preshiftTextList,a0
	add.w	preshiftListOffset,a0
	move.l	(a0),a0
	jsr		(a0)

	tst.w	textshiftcounter
	bne		.done
		move.w	#8,text_render_state

		add.w	#4,textspaceoffset
		lea		textspacelist,a0
		add.w	textspaceoffset,a0
		move.l	(a0),currentTextSpacePointer

		addq.w	#4,textlistoffset

		subq.w	#1,textloopcounter
		bne		.done

			move.w	#0,text_render_state
			move.w	#0,text_precalc
			move.w	#0,textspaceoffset
			move.l	#textspace1,textDataPointer
			move.l	#160*4-32,currentTextScreenOffset
			move.w	#5,textloopcounter
			cmp.w	#4*55,textlistoffset
			bne		.done
				addq.l	#1,demoloopcounter
				move.w	#0,textlistoffset

.done
	rts

demoloopcounter				dc.l	1

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

	; approach:
	;  - get value
	;  - if %10 > 0, then draw
	;  - if /10 > 0, then next

drawTimes
	move.l	demoloopcounter,d0
	cmp.l	#1,d0
	beq		.end

	move.l	screenpointeraligned,a0
	move.l	screenpointeraligned2,a1
	lea		numbers,a2
	lea		sublist,a4
	sub.l	#32-6,a0
	sub.l	#32-6,a1
	add.l	#205*160,a0
	add.l	#205*160,a1

	lea		numbers,a2
	add.w	#80,a2
	sub.w	(a4),a0
	sub.w	(a4)+,a1
o set 0
	REPT 8 
		move.b	(a2),o(a0)
		move.b	(a2)+,o(a1)
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

o set 0
	REPT 8
		move.b	(a3),o(a0)
		move.b	(a3)+,o(a1)
o set o+160

	ENDR
	ext.l	d0
	cmp.w	#0,d0
	bne		.loop
.end
	rts


text_precalc
	dc.w	1
text_clearing
	dc.w	-1
text_clearCounter
	ds.w	1
text_clearEven
	dc.w	0

clear3bpl
	move.l	screenpointeraligned2,a0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	#4,d0
	lea		textScript,a1
	add.l	(a1,d0.w),a0
	moveq	#0,d0

	move.l	clear3bplPointer,a1
	jmp		(a1)

generate3bplCode
	move.l	clear3bplPointer,a0
	moveq	#0,d6
	move.l	#fontheight*20-1,d7

	move.w	#$2140,d0
	move.w	#$3140,d1
	swap	d0
	swap	d1
	move.w	#0,d0
	move.w	#4,d1

.loop
;			move.l	d0,o(a0)				;3140 0004
;			move.w	d0,o+4(a0)				;2140 0008
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		add.w	#8,d0
		add.w	#8,d1
	dbra	d7,.loop
	move.w	#$4e75,(a0)

	rts


copyLogo
;;;;;;;;;;;; logo to screen
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	#160*4,a0
	add.w	#160*4,a1
	lea		logo,a2
	move.l	#42*20*2-1,d7
.loop
		move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
	dbra	d7,.loop

;;;;;;;;;;;; end logo to screen
	rts

customScreenAlign
	move.l	#screen1+65536,d0
	move.w	#0,d0
	move.l	d0,screenpointeraligned
	sub.l	#160*50,d0
	sub.l	#32,d0
	move.l	d0,screenpointer
	lsr.w	#8,d0
	move.l	d0,screenpointershifter
	move.l	d0,$ffff8200.w

	;align new screen address for double buffer

	move.l	screenpointeraligned,d0
	add.l	#$10000,d0
	move.l	d0,screenpointeraligned2
	sub.l	#160*50,d0
	sub.l	#32,d0
	move.l	d0,screenpointer2
	lsr.w	#8,d0
	move.l	d0,screenpointer2shifter
	rts

swapscreens:
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	d0,screenpointer2

	move.l	screenpointershifter,d0
	move.l	screenpointer2shifter,screenpointershifter
	move.l	d0,screenpointer2shifter
	
	move.l	screenpointeraligned,d0
	move.l	screenpointeraligned2,screenpointeraligned
	move.l	d0,screenpointeraligned2

	move.l	vertexloc_pointer,d0
	move.l	vertexloc2_pointer,vertexloc_pointer
	move.l	d0,vertexloc2_pointer
	
	move.l	vertexprojection_pointer,d0
	move.l	vertexprojection2_pointer,vertexprojection_pointer
	move.l	d0,vertexprojection2_pointer
	
	rts

initRotationCode:
	lea		vertexloc,a0
	lea		vertexloc2,a1
	move.l	a0,vertexloc_pointer		
	move.l	a1,vertexloc2_pointer
	moveq	#0,d0
	moveq	#0,d1
	move.l	#max_nr_of_vertices-1,d7
	
	move.l	vertexprojection_pointer,a2
	move.l	vertexprojection2_pointer,a3
	add.l	#300,d1
		
.initbuffer
		move.w	d0,(a0)+
		move.w	d0,(a1)+		
		move.l	d1,(a2)+
		move.l	d1,(a2)+
		move.l	d1,(a3)+
	dbra	d7,.initbuffer			
	rts

textshiftcounter
	dc.w	15
textloopcounter
	dc.w	5
preshiftTextFrameDone
	dc.w	-1


; ****************** DEMO CUBE *********************
; ****************** DEMO CUBE *********************
; ****************** DEMO CUBE *********************

;xx:		dc.l	0
;xy:		dc.l	0
;xz:		dc.l	0
;yx:		dc.l	0
;yy:		dc.l	0
;yz:		dc.l	0
;zx:		dc.l	0
;zy:		dc.l	0
;zz:		dc.l	0


doRotationPoly
    move.w  #256*2,d7									;8

; do angular speeds and get indices 
    move.w  currentStepX,d2								;16
    add.w   stepSpeedX,d2								;16
    cmp.w   d7,d2										;4
    blt     .goodX										;12
        sub.w   d7,d2									;4
.goodX
    move.w  d2,currentStepX								;16		--> 68

    move.w  currentStepY,d4								;16
    add.w   stepSpeedY,d4								;16
    cmp.w   d7,d4										;4
    blt     .goodY										;12
        sub.w   d7,d4									;4
.goodY
    move.w  d4,currentStepY								;16		--> 68

    move.w  currentStepZ,d6								;16
    add.w   stepSpeedZ,d6								;16
    cmp.w   d7,d6										;4
    blt     .goodZ										;12
        sub.w   d7,d6									;4
.goodZ
    move.w  d6,currentStepZ								;16		--> 68

;;;;;;;;;;;;;;;;;; ANGULAR SPEEDS DONE ;;;;;;;;;;;;;;;;;;

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		sintable1,a0								;12
	lea		sintable1+128,a1							;12

	move.w	(a0,d2.w),d1					; sin(A)	;around z axis		16
	move.w	(a1,d2.w),d2					; cos(A)						16

	move.w	(a0,d4.w),d3					; sin(B)	;around y axis		16
	move.w	(a1,d4.w),d4					; cos(B)						16

	move.w	(a0,d6.w),d5					; sin(C)	;around x axis		16
	move.w	(a1,d6.w),d6					; cos(C)						16

	; xx = cos(A) * cos(B)
.xx
	move.w	d2,d7						;						4
	muls	d4,d7						;						42				1
	asr.w	#7,d7						;xx,zz					24	
	move.w	d7,a2						;						18
															; ------> 88
	;xy = [sin(A)cos(B)]		
.xy
	move.w	d4,d7						;						4
	muls	d1,d7						;						42				2
	asr.w	#7,d7						;						24
	move.w	d7,a1						;						4
															; ------> 74
	;xz = [sin(B)]	sB
.xz
	move.w	d3,a0						;						4
															; ------> 4
	;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
.yx
    move.w	d6,d0											;	4
    muls	d1,d0	; d0 = sin(A) * cos(C)						44		
    move.w	d2,d7											;	4
    muls	d3,d7	; d7 = cos(A) * sin(B)					;	44
    asr.w	#7,d7											;	24
    muls	d5,d7	; d7 = cos(A) * sin(B) * sin(C)			;	44
	add.w	d7,d0											;	10
	asr.w	#7,d0											;	22
	move.w	d0,a3											;	4
;	move.w	d0,yx											; ------> 200

	;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
.yy
	move.w	d2,d7	; d7 = cos(A)							;	4
	neg		d7		; d7 = -cos(A)							;	4
	muls	d6,d7	; d7 = -cos(A) * cos(C)					;	44
	move.w	d1,d0		; sin(A)								4
	muls	d3,d0		; sin(A) * sin(B)						44
	asr.w	#7,d0		;										24
	muls	d5,d0		; sin(A) * sin(B) * sin(C)				44
	add.l	d0,d7		;										8
	asr.w	#7,d7		;										24
	move.w	d7,a4		;										4
															;---------> 204
	;yz = [-cos(B)sin(C)]
.yz
	move.w	d4,d7											;	4
	neg		d7												;	4
	muls	d5,d7											;	44
	asr.w	#7,d7											;	24
	move.w	d7,a6											;	4
															; ------> 80
															;--------------------> 100 + 156 + 88 + 74 + 4 + 200 + 204 + 80 = 906
	IFNE z_on
	;zx = [sin(A)sin(C) - cos(A)sin(B)cos(C)]
.zx
		move.w	d1,d0	; d0 = sin(A)
		muls	d5,d0	; d0 = sin(A) * sin(C)

		move.w	d2,d7	; d7 = cos(A)
		muls	d3,d7	; d7 = cos(A) * sin(B)
		asr.w	#7,d7	; 
		muls	d6,d7	; d7 = cos(A) * sin(B) * cos(C)

		sub.w	d7,d0	; d0 = sin(A) * sin(C) - cos(A) * sin(B) * cos(C)
		asr.w	#7,d0	;
		move.w	d0,d7
;
;	;zy = [-cos(A)sin(C) - sin(A)sin(B)cos(C)]
.zy
		move.w	d2,d0	; d0 = cos(A)
		muls	d5,d0	; d0 = cos(A) * sin(C)
		neg		d0		; d0 = -cos(A) * sin(C)

;		move.w	d1,d7	; d7 = sin(A)
		muls	d3,d1	; d7 = sin(A) * sin(B)
		asr.w	#7,d1	;
		muls	d6,d1	; d7 = sin(A) * sin(B) * cos(C)

		sub.w	d1,d0	; d0 = -cos(A) * sin(C) - sin(A) * sin(B) * cos(C)
		asr.w	#7,d0	;
		move.w	d0,d3

;	zz = [cos(B)cos(C)]
.zz
		move.w	d4,d0	; d0 = cos(B)
		muls	d6,d0 	; d0 = cos(B) * cos(C)
		asr.w	#7,d0
		move.w	d0,d4
	ENDC

;;;;;;;;;;;;;;;;;; CONSTANTS DONE ;;;;;;;;;;;;;;;;;;



.setupComplete						

	move.l	logpointer,d0		;20

	move.w	a2,d0 ;xx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xxp+2

	move.w	a0,d0	;xz			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xzp+2

	move.w	a1,d0	;xy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),xyp+2

	move.w	a3,d0	;yx			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),yxp+2

	move.w	a4,d0	;yy			;4
	add.w	d0,d0				;4
	move.l	d0,a5				;4
	move.w	(a5),yyp+2

	move.w	a6,d0				;4
	add.w	d0,d0	;yz			;4
	move.l	d0,a5				;4
	move.w	(a5),yzp+2

	IFNE	z_on
		move.w	d7,d0	;zx
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zxp+2

		move.w	d3,d0	;zy
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zyp+2

		move.w	d4,d0	;zz
		add.w	d0,d0
		move.l	d0,a5
		move.w	(a5),zzp+2
	ENDC

	move.l	currentObject,a5					; 20							
	move.l	vertexprojection2_pointer,a6		; 20
	move.l	number_of_vertices,d5				; 20
	subq	#1,d5								; 4

	move.l	zpointer,d1
	move.l	expointernorm,d2
	move.l	d2,d3

loop11
	IFNE z_on


	movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
	;	z
zxp	move.w		1234(a0),d1	;12			; z*zx ... +
zyp	add.w		1234(a1),d1	;12			; z*zy ... +
zzp	add.w		1234(a2),d1	;12			; z*zz

	; save the focallength as normal value
	move.w		d1,d0			;4
	move.l		d0,a3			;4
	move.w		(a3),d2			;8
	move.l		d2,a3			;4
	move.w		(a3),(a6)+		;12
	; end

	move.l		d1,a3		;4			; perspective value pointer
	move.w		(a3),d2		;8			; perspective value as log value
	move.w		d2,d3		;4			; duplicate				(52)

	;	x	
xxp	move.w		1234(a0),d0	;12			; x*xx ... +
xyp	add.w		1234(a1),d0	;12			; x*xy ... +
xzp	add.w		1234(a2),d0	;12			; x*xz 
	move.l		d0,a3		;4			; logpointer
	add.w		(a3),d2		;8			; add to focal length ( x * perspective )
	move.l		d2,a3		;4			; use exptable pointer
	move.w		(a3),(a6)+	;12			; get/store actual x value (64)

	;	y
yxp	move.w		1234(a0),d0	;12			; z*zx ... +
yyp	add.w		1234(a1),d0	;12			; z*zy ... +
yzp	add.w		1234(a2),d0	;12			; z*zz
	move.l		d0,a3		;4			; logpointer
	add.w		(a3),d3		;8			; add to local length ( y * perspective )
	move.l		d3,a3		;4			; use exptable pointer
	move.w		(a3),(a6)+	;12			; get/store actual y value (64)

	dbra	d5,loop11		;12			; 24 + 12 + 52 + 64 + 64 = 216
	rts

	ELSE
	movem.w	(a5)+,a0-a2	;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
	;	x	
xxp	move.w		1234(a0),d0	;12				xx is offset into table for the value, smc
xyp	add.w		1234(a1),d0	;12				xy is offset into table for the value, smc
xzp	add.w		1234(a2),d0	;12				xz is offset into table for the value, smc
	move.w		d0,(a6)+

	;	y
yxp	move.w		1234(a0),d0	;12
yyp	add.w		1234(a1),d0	;12
yzp	add.w		1234(a2),d0	;12
	move.w		d0,(a6)+

	dbra	d5,loop11
	rts

zxp	move.w		1234(a0),d0	;12
zyp	add.w		1234(a1),d0	;12
zzp	add.w		1234(a2),d0	;12
	ENDC




init_yblock_aligned
	lea		y_block,a1
	move.l	#200-1,d7
	moveq	#0,d0
	move.w	#160,d6
	swap	d6
	move.w	#160,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop

	rts



clearSprites:
	; ----- START CLEAR CUBE VERTICES -----
	move.l	vertexloc2_pointer,a0			; 20 cycles, first clear the star, load its address
	moveq.l	#0,d0
	move.l	screenpointeraligned2,d1

	move.l	number_of_vertices,d7
	subq	#1,d7
.clear
		move.w	(a0)+,d1		; 8					; 20 per
		move.l	d1,a1			; 4
o		SET 0		
		REPT spriteheight
			move.w	d0,o(a1)			; 8
			move.w	d0,o+8(a1)			; 8
o		SET o+160
		ENDR
	dbra	d7,.clear
	rts

clapcounter	dc.w	0

drawSprites
	move.l	sndh_pointer,a0
	add.w	#$b8,a0
	move.b	(a0),d0
	cmp.b	#1,d0
	bne		.noset
		move.b	#0,(a0)
		move.w	#10,clapcounter
		move.w	#22,stepSpeedX
		move.w	#0,stepSpeedY
		move.w	#4,stepSpeedZ

.noset

	move.w	vertices_xoff,d2
	move.w	vertices_yoff,d3
	; a2 screen
	move.l	spriteLookupPointer,a3
	move.l	vertexloc2_pointer,a4																;20
	move.l	vertexprojection2_pointer,a5														;20

	move.l	screenpointeraligned2,d6

	move.w	clapcounter,d0
	beq		.normalspeed
		subq.w	#1,clapcounter
		subq.w	#2,stepSpeedX
		jmp		.speeddone

.normalspeed
		move.w	#2,stepSpeedX
		move.w	#2,stepSpeedY
		move.w	#2,stepSpeedZ

.speeddone
	lea		perspectivethingie,a0
	lea		y_block,a1

	move.l	number_of_vertices,d7
	subq	#1,d7
	move.l	drawSpriteInnerCodePointer,a6
	jmp		(a6)

;;;;;;;; begin template
drawSprite
.dosprite
	move.w	(a5)+,d5									;8			2
	move.w	(a5)+,d0									;8			2
	move.w	(a5)+,d1									;8			2
	add.w	d2,d0										;4			2
	add.w	d3,d1										;4			2
	; d0 = x, d1 = y
	; now determine which sprite source to pick
	add.w	d0,d0	; since we are 8					;4			2

	move.l	a3,a2										;4			2
	add.w	d0,a2										;8			2

	move.l	(a2)+,a6	; get address for sprite		;12			2
	add.w	(a0,d5.w),a6								;20			4
	move.w	(a2)+,d6	; x offset into screen			;8			2
;	move.l	d1,a2										;4			2
;	add.w	(a2),d6		; add y offset into screen		;8			2
	add.w	(a1,d1.w),d6
	move.w	d6,(a4)+	; for clearing					;8			2
	move.l	d6,a2		; screenpointer!				;4			2

o	SET 0
	REPT spriteheight
		move.w	(a6)+,d4								;			2
		or.w	d4,o(a2)								;			4
		move.w	(a6)+,d4								;			2
		or.w	d4,o+8(a2)								;			4	--> 12*8 = 96 - 2 = 94 + 32 => 126 
o	SET o+160
	ENDR
;;;;;;;;;;; endtemplate
	dbra	d7,.dosprite
	rts
;;;;;;;;;;; drawSprite ;;;;;;;;;;;;


generateDrawSpriteCode
	lea		drawSprite,a3
	move.l	drawSpriteInnerCodePointer,a1
	move.l	a1,a6
	move.l	number_of_vertices,d7
	subq	#1,d7

.loop
		move.l	a3,a0
		REPT 31+3*8
			move.l	(a0)+,(a1)+		; 55 * 4
		ENDR
			move.w	(a0)+,(a1)+		; 55 * 4 + 2 * 
	dbra	d7,.loop
	move.w	#$4e75,(a1)+
	sub.l	a6,a1
	rts

init_exp_log:   
    bsr.s   init_log
    bsr.s   init_exp
    rts

init_log:      
    lea     log_src,A4    		; skip 0
    move.l  logpointer,d5
    move.l  d5,a2
    moveq   #-2,d6           	; index

    move.w  #-EXPS*2,(A2)+  	; NULL
    move.w  #LOGS-1-1,D7
il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0
    	move.w  d0,(a2)+        ; pos2

    	add.w   #EXPS*2,D0      ; NEG

    	move.w  d6,d5           ; take negative value into account
    	move.l  d5,a3
    	move.w  d0,(a3)         ; move in value

    	subq.w  #2,d6
    dbra    D7,il
    rts

init_exp:      
	lea		$3000,a0
	move.w	#0,d0
.cl
		move.w	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl


    move.w  #EXPS*2,D7
    lea     exp_src,a3

    move.l	expointernorm,a0
    lea		(a0,d7.w),a1
    lea		(a1,d7.w),a2

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6



    move.w  #EXPS-1,D7
ie:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

    	; this is specific for the rotation code
    	asr.w	#2,d0
    	asr.w	#2,d1
    	add.w	d0,d0
    	add.w	d0,d0
    	add.w	d1,d1
    	add.w	d1,d1
		move.w  d0,(a0)+
		move.w  d1,(a1)+
		move.w  d0,(a2)+

  		asr.w	#7,d0		; fix this in exptable
		asr.w	#7,d1		; fix this in exptable
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d1
		add.w	d1,d1

		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+


    dbra    D7,ie
    rts

init_aligned_blocks
	move.l	screenpointeraligned2,d0
	add.l	#$10000,d0
	move.l	d0,alignpointer1
	add.l	#$10000,d0
	move.l	d0,alignpointer2
	add.l	#$10000,d0
	move.l	d0,alignpointer3
	add.l	#$10000,d0
	move.l	d0,alignpointer4
	add.l	#$10000,d0
	move.l	d0,alignpointer5


;		- clear3bplPointer				5282
;		- planeShiftCodePointer			6602
;		- charLookupPointer				104
	; zpointer filling, first 512 and last 512 bytes used
	move.l	zpointer,a0										; zpointer is 		600
	add.w	#600,a0
	move.l	a0,oldLowerPointer								; oldlower is 		40960
	add.l	#40960,a0
	move.l	a0,clear3bplPointer								; clear3bpl is 		5282
	add.w	#5282,a0
	move.l	a0,vertexprojection_pointer
	add.w	#max_nr_of_vertices*3*3*2,a0					; vert_projection 	1440
	move.l	a0,vertexprojection2_pointer
	add.w	#max_nr_of_vertices*3*3*2,a0					; vert_projection2 	1440
	move.l	a0,planeShiftCodePointer						; planeshift 		6602
	add.w	#6602,a0
	move.l	a0,charLookupPointer							; charlookup 		104
	add.w	#fontchars*4,a0
	move.l	a0,textOffsetTablePointer						; textoffset 		1920
	add.w	#1920,a0										;	
	move.l	a0,textDistPointer								;	textdist		1280		
	add.w	#1280,a0
	move.l	a0,picInversePointer							; picinverse		4096  ;				65536 - 64324 = 1212 left




;		- ballCodePointer				27302
;		- c2PCodePointer				25002
;		- spriteToBlocksCodePointer		8770

	; end zpointer
	; start logpointer filling
	;		logpointer = 2048 front and 2048 back: 65536 - 4096 = 	61440 - (ballcode) 28302 - (c2pcode) 25002 = 8136
	move.l	logpointer,a0
	add.l	#2048,a0					; logtable			2048
	move.l	a0,ballCodePointer
	add.l	#27302,a0					; ballcode 			27302	
	move.l	a0,c2PCodePointer
	add.l	#25002,a0					; c2p1				25002
	move.l	a0,spriteToBlocksCodePointer
	add.l	#8770,a0					; spritetoblock		8770
										; logtable end		2048	--> 65170  ===> 366 free


	; end logpointer filling

;		- c2PCodePointer2				25002
;		- rasterSource2Pointer			6400


	; start exppointer filling
	; 24576 start ; 16384 end --> 40960 used

	lea		lastblock,a0
;	move.l	exppointer,a0
;	add.l	#24576,a0						; exppointer start		24576
	move.l	a0,drawSpriteInnerCodePointer	; drawSpriteInnerCode   17762 
	add.l	#18000,a0						; exppointer end		16384		--> 40960 ==> 24576 free

	move.l	expointernorm,a0
	add.l	#24576,a0						; exppointer start		24576
	move.l	a0,rasterSource2Pointer			; 6400
	add.l	#6400,a0	
	move.l	a0,linePointer					; 10160
	add.l	#10160,a0
	move.l	a0,spriteLookupPointer			; spritelookuptable		2560
	add.l	#2560,a0
	move.l	a0,blockPointer
	move.l	blockPointer,currentPicPointer
	add.w	#4096,a0
;	move.l	a0,c2PCodePointer2


	move.l	gemScreenBuffer,a0
	move.l	a0,c2PCodePointer2				; 25002


	rts

storeLowerMem
	lea		$1000,a0
	move.l	oldLowerPointer,a1
.m
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#$B000,a0
	bne		.m
	rts

restoreLowerMem
	move.l	oldLowerPointer,a0
	lea	$1000,a1
.m
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#$B000,a1
	bne		.m
	rts

colorSchemeOffsetLength	equ 8
currentColor					dc.w	0
colorSchemeOffset				dc.w	0
colorScheme
	dc.w	$656
	dc.w	$665
	dc.w	$666
	dc.w	$766



stripe
	dc.w	$777
topbottomcolor
	dc.w	$777
colorbar
	dc.w	-1
intro_done
	dc.w	0



top_bottom_vbl_intro:       
    move.l screenpointershifter,$ff8200

    addq    #1,$466.w
    move.w  #$2700,sr           ;Stop all interrupts

   	movem.l	d0-d7/a0,-(sp)
   	cmp.w	#2,colorbar
   	beq		.cont
   	tst.w	stripe
   	beq		.blockchoice
   	subq.w	#1,rastercounter
   	bne		.cont
   		sub.w	#$111,stripe
   		move.w	#10,rastercounter
   		jmp	.cont

.blockchoice
	tst.w	colorbar
	beq		.dogreen
	bgt		.dored
.doblue
	cmp.w	#$774,topbottomcolor
	beq		.gogreen
		subq.w	#1,rastercounter
		bne		.cont
			sub.w	#$001,topbottomcolor
			move.w	#10,rastercounter
			jmp		.cont
.gogreen
	addq.w	#1,colorbar
	jmp		.cont
.dogreen
		cmp.w	#$744,topbottomcolor
		beq		.gored
			subq.w	#1,rastercounter
			bne		.cont
				sub.w	#$010,topbottomcolor
				move.w	#10,rastercounter
				jmp		.cont
.gored
	addq.w	#1,colorbar
	jmp		.cont
.dored
		cmp.w	#$544,topbottomcolor
		beq		.godone
			subq.w	#1,rastercounter
			bne		.cont
				sub.w	#$100,topbottomcolor
				move.w	#10,rastercounter
				jmp		.cont
.godone
	addq.w	#1,colorbar
.cont

    IFNE	framecount
    	addq.w	#1,_framecounter
    ENDC

    ;Start up Timer A each VBL
    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)
    move.l	#timer_a_intro,$134.w    
    
    ;Start up Timer B each VBL
    clr.b   $fffffa1b.w         	;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

    move 	#$2400,SR

	IFNE playmusic
	IFNE playmusicinvbl
		move.l	sndh_pointer,a0
		move.b	#0,$b8(a0)
		jsr		8(a0)
	ENDC
	ENDC

	move.w	topbottomcolor,d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movem.l	d0-d7,$ffff8240

	movem.l	(sp)+,d0-d7/a0

    rte

timer_a_intro:
    move.w  #$2100,sr           ;Enable HBL
    stop    #$2100              ;Wait for HBL
    move.w  #$2700,sr           ;Stop all interrupts
    clr.b   $fffffa19.w         ;Stop Timer A

    dcb.w   84-2,$4e71          ;Zzzz

    clr.b   $ffff820a.w         ;60 Hz
    REPT 10     ;
        nop
    ENDR
    move.b  #2,$ffff820a.w          ;50 Hz

    clr.b   $fffffa19.w         	;Timer-A control (stop)

    move.b 	#0,$fffffa1b.w    
    move.l  #timer_b_intro1,$120.w        ;Install our own Timer B
    move.b  #50,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w

    rte

timer_b_intro1
	move.w	stripe,$ffff8240
    move.b  #0,$fffffa1b.w    

	move.l	#timer_b_intro2,$120.w
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte

timer_b_intro2:
	move.w	#$777,$ffff8240

    move.b  #0,$fffffa1b.w    
    move.l  #no_raster_open_border_intro,$120.w        ;Install our own Timer B
    move.b	#178-1,$fffffa21.w 
    move.b  #8,$fffffa1b.w

    rte


no_raster_open_border_intro
	movem.l	d1-d2/a0,-(sp)
     clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
                move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
        REPT 59
        	nop
        ENDR

    movem.l (sp)+,d1-d2/a0

	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR

	move.b	#2,$ffff820a.w			;50 Hz
    move    #$2400,sr    

    move.b  #0,$fffffa1b.w    
	move.l	#raster_after_lower_border_black_line_intro,$120.w
	move.b	#21,$fffffa21.w
 	move.b  #8,$fffffa1b.w
	rte

raster_after_lower_border_black_line_intro
	movem.l	d1-d2/a0,-(sp)
     clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
    move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
        REPT 59
        	nop
        ENDR
           movem.l (sp)+,d1-d2/a0

    move    #$2400,sr    
	move.w	stripe,$ffff8240
    move.b  #0,$fffffa1b.w    
    move.l  #raster_lowest_block_intro,$120.w        ;Install our own Timer B
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	rte

raster_lowest_block_intro
	move.w	topbottomcolor,$ffff8240
    move.b  #0,$fffffa1b.w    
    rte



bordercolor equ $544

bannerframes			dc.w	1800
palloffsetcounter		dc.w	5

bannerpaloffset			dc.w	13*16


top_bottom_vbl:     
    move.l screenpointershifter,$ff8200

    addq    #1,$466.w
    move.w  #$2700,sr           ;Stop all interrupts

   	movem.l	d0-d7/a0,-(sp)

    tst.w	raster
    bne		.cont
		moveq	#0,d0
		move.b	raster_position,d0
		cmp.w	#200,d0
		bge		.cont

.increase
			addq.b	#1,raster_position
			cmp.b	#200,raster_position
			bne		.cont
			move.w	#0,text_clearing
.cont


    IFNE	framecount
    	addq.w	#1,_framecounter
    ENDC

    ;Start up Timer A each VBL
    clr.b   $fffffa19.w         	;Timer-A control (stop)
    bset    #5,$fffffa07.w          ;Interrupt enable A (Timer A)
    bset    #5,$fffffa13.w          ;Interrupt mask A (Timer A)
    move.b  #98,$fffffa1f.w         ;Timer A Delay (data)
    move.b  #4,$fffffa19.w          ;Timer A Predivider (start Timer A)
    move.l	#timer_a,$134.w    
    
    ;Start up Timer B each VBL
    clr.b   $fffffa1b.w         	;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

    move 	#$2400,SR

    tst.w	colorbar
    blt		.normalcolor
    bgt		.docounter
.dofade
		subq.w	#1,colorbar
		jmp		.colordone

.docounter
	subq.w	#1,stripe
	bne		.addtocounter
		subq.w	#2,colorbar
		jmp	.colordone
.addtocounter	
		move.w	topbottomcolor,d0
		move.w	d0,d1
		swap	d0
		move.w	d1,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		movem.l	d0-d7,$ffff8240
	jmp		.colordone
.normalcolor
	move.w	#bordercolor,$ffff8240
.colordone

	lea		colorScheme,a0
	add.w	colorSchemeOffset,a0
	move.w	(a0),d1
	move.w	d1,currentColor
	lea		fontpal+16,a0
	move.w	#bgco,-16(a0)
	move.w	d1,(a0)
	lea		rastercolors,a0
	move.l	a0,rasterpointer
o	set 0
	REPT 7
		move.w	d1,o+18(a0)
o	set o+2
	ENDR	
o	set 0
	REPT 	16
		move.w	d1,o+16(a0)
o	set o+32
	ENDR


	IFNE playmusic
	IFNE playmusicinvbl
		move.l	sndh_pointer,a0
		move.b	#0,$b8(a0)
		jsr		8(a0)
	ENDC
	ENDC

   	tst.w	bannerpaloffset
   	beq		.xx
   	subq.w	#1,bannerframes
   	bgt		.nn
   		sub.w	#1,palloffsetcounter
   		bne		.nn
   		sub.w	#16,bannerpaloffset
   		move.w	#5,palloffsetcounter
   		jmp		.nn
.xx
	move.l	#logo1finished,logo1pointer
.nn


	movem.l	(sp)+,d0-d7/a0

	move.w	#6,rastercounter
    rte

timer_a:
    move.w  #$2100,sr           ;Enable HBL
    stop    #$2100              ;Wait for HBL
    move.w  #$2700,sr           ;Stop all interrupts
    clr.b   $fffffa19.w         ;Stop Timer A

    dcb.w   84-2,$4e71          ;Zzzz

    clr.b   $ffff820a.w         ;60 Hz
    REPT 10     ;
        nop
    ENDR
    move.b  #2,$ffff820a.w          ;50 Hz

    clr.b   $fffffa19.w         	;Timer-A control (stop)

    move.b 	#0,$fffffa1b.w    
    move.l  logo1pointer,$120.w        ;Install our own Timer B
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w

    ; here we determine where the timer b opening has to be scheduled
    pushd0
    	; 4 cases: 
    	;	1. raster before border, no relation
    	; 	2. last raster on border opening	(can be same as 3?)
    	;	3. raster on border opening
    	;	4. raster after border opening
    	moveq	#0,d0
    	move.b	raster_position,d0
    	cmp.w	#178,d0
    	bge		.case4
    	add.w	#6,d0
    	neg.w	d0
    	add.w	#178,d0						;normally at 229, but we have -50 (logo), -1 (timer init) = 229-51 = 178
    	bgt		.case1
    	ble		.case2
.case4
		move.b	#178,timer_b_number
		move.l	#case4_init,timer_b_pointer
		sub.b	#178,d0
		move.b	d0,raster_position_after_border
		move.b	raster_position,d0
		neg.w	d0
		add.w	#200,d0
		sub.w	#6,d0
		ble		.overlapwithblackline
		move.b	d0,black_line_number
		move.b	raster_position,d0
		cmp.w	#178,d0
		bne		.end
			subq.b	#1,black_line_number
			popd0
			rte

.overlapwithblackline
			add.w	d0,rastercounter
			subq.w	#1,rastercounter
			move.b	#1,black_line_number
			popd0
			rte
.case1
;	when we get here, we know that the raster is above the border opening, we therefor:
;	1. detemine the timer_b position for the raster
;	2. determine the border opening
		move.b	d0,border_opening_position
		move.l	#case1_init,timer_b_pointer
		move.b	raster_position,timer_b_number
		popd0
		rte
.case2
		add.w	#6,d0
		move.w	d0,border_counter
		move.l	#case2_init,timer_b_pointer
		move.b	raster_position,timer_b_number
		; here we need to determine where the black line come
		; we have:
		;	raster_position	: point where raster is at
		;				+6 	: point where raster ends
		;	border_counter	: 
		;	#200 - raster_position-6
		move.b	raster_position,d0
		cmp.w	#173,d0
		bne		.contxx
			tst.w	shittyfix
			beq		.contxx
			subq.w	#1,d0
			move.w	#0,shittyfix
.contxx
		neg.w	d0
		add.w	#200,d0
		sub.w	#6,d0
		move.b	d0,black_line_number
.end
    popd0
    rte

logo1pointer
	dc.l	logo1


logo1
    move.b 	#0,$fffffa1b.w    
    move.l  #logo2,$120.w        ;Install our own Timer B
    move.b  #23,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w
	movem.l	d0-d7/a0,-(sp)
	lea		bannerpal1,a0
	move.w	bannerpaloffset,d0
	add.w	d0,d0
	add.w	d0,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	movem.l	(sp)+,d0-d7/a0
	rte

logo2
    move.b 	#0,$fffffa1b.w    
    move.l  #logo3,$120.w        ;Install our own Timer B
    move.b  #3,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w
	movem.l	d0-d3/a0,-(sp)
	lea		bannerpal2,a0
	add.w	bannerpaloffset,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8250
	movem.l	(sp)+,d0-d3/a0
	rte

logo3
	move.b 	#0,$fffffa1b.w    
    move.l  #timer_init,$120.w        ;Install our own Timer B
    move.b  #23,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w


	movem.l	d0-d3/a0,-(sp)
	lea		bannerpal3,a0
	add.w	bannerpaloffset,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8240
	movem.l	(sp)+,d0-d3/a0
	rte

logo1finished
    move.b 	#0,$fffffa1b.w    
    move.l  #logo2finished,$120.w        ;Install our own Timer B
    move.b  #23,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w
	movem.l	d0-d7/a0,-(sp)
	lea		bannerpal1,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	movem.l	(sp)+,d0-d7/a0
	rte

logo2finished
    move.b 	#0,$fffffa1b.w    
    move.l  #logo3finished,$120.w        ;Install our own Timer B
    move.b  #3,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w
	movem.l	d0-d3/a0,-(sp)
	lea		bannerpal2,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8250
	movem.l	(sp)+,d0-d3/a0
	rte

logo3finished
	move.b 	#0,$fffffa1b.w    
    move.l  #timer_init,$120.w        ;Install our own Timer B
    move.b  #23,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b 	#8,$fffffa1b.w
	movem.l	d0-d3/a0,-(sp)
	lea		bannerpal3,a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,$ffff8240
	movem.l	(sp)+,d0-d3/a0
	rte

shittyfix
	dc.w	1

border_counter
	dc.w	0

black_line_number
	dc.b	0
	dc.b	0

border_opening_position
	dc.b	0
	dc.b	0

raster_position_after_border
	dc.b	0
	dc.b	0

; tb_1 is 30 lines of black, which covers last line
timer_init: 
	move.w	#$000,$ffff8240
    move.b  #0,$fffffa1b.w    
    tst.w	raster
    bne		.rasters_disabled
	    move.l  #timer_rasters,$120.w        ;Install our own Timer B
	    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
		rte
.rasters_disabled
	move.l	#no_rasters,$120.w
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
    rte

timer_rasters
	move.w	#$777,$ffff8240
	pusha0
	pusha1
	move.l	rasterpointer,a0					;20
	move.w	16(a0),$ffff8250
	lea		$ffff8240,a1						;8
	REPT 8
		move.l	(a0)+,(a1)+						;20*8 = 160
	ENDR

	move.b 	#0,$fffffa1b.w    						;20
	move.l  timer_b_pointer,$120.w				;24
	move.b  timer_b_number,$fffffa21.w            	;24
	move.b  #8,$fffffa1b.w							;20

	popa1
	popa0
	rte

timer_b_pointer
	dc.l	0
timer_b_number
	dc.b	0
	dc.b	0



case2_init
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,border_counter
	bne		.normal
		move.b 	#0,$fffffa1b.w    
		move.l	#case2_border_opening,$120.w
	    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
		popa1
		popa0
		rte
.normal	
	move.b 	#0,$fffffa1b.w    
    move.l  #case2,$120.w        ;Install our own Timer B
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	popa1
	popa0
	rte

case2
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,rastercounter
	subq.w	#1,border_counter		;20
	bne		.end
		move.b 	#0,$fffffa1b.w    
		move.l	#case2_border_opening,$120.w
	    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
.end
	popa1
	popa0
    rte

case2_border_opening
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz

	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,rastercounter
	beq		.schedule_end
		subq.w	#1,black_line_number

	    move.b  #0,$fffffa1b.w    
		move.l	#case2_after_border,$120.w
		move.b	#1,$fffffa21.w
	 	move.b  #8,$fffffa1b.w
		popa1
		popa0		
		rte

.schedule_end
	popa1
	popa0
    move.b  #0,$fffffa1b.w    
	move.l	#raster_after_lower_border_black_line,$120.w
	move.b	black_line_number,$fffffa21.w
 	move.b  #8,$fffffa1b.w
	rte

case2_after_border
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,black_line_number
	subq.w	#1,rastercounter
	bne		.end
		move.b 	#0,$fffffa1b.w    
		move.l	#raster_after_lower_border_black_line,$120.w
	    move.b  black_line_number,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
.end
	popa1
	popa0
	rte

case1_init
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	move.b 	#0,$fffffa1b.w    
    move.l  #case1,$120.w        ;Install our own Timer B
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	popa1
	popa0
	rte

case1
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,rastercounter		;20
	bne		.end
		move.b 	#0,$fffffa1b.w    
		move.l	#case1_border_opening,$120.w
	    move.b  border_opening_position,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
.end
	popa1
	popa0
    rte

case1_border_opening
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz

    move.b  #0,$fffffa1b.w    
	move.l	#raster_after_lower_border_black_line,$120.w
	move.b	#22,$fffffa21.w
 	move.b  #8,$fffffa1b.w
	rte

case4_init
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz

	tst.b	raster_position_after_border
	bne		.cont
		addq.b	#1,raster_position_after_border
;		subq.b	#1,black_line_number
.cont
	tst.w	rastercounter
	ble		.over
    move.b  #0,$fffffa1b.w    
	move.l	#case4_raster_init,$120.w
	move.b	raster_position_after_border,$fffffa21.w
 	move.b  #8,$fffffa1b.w
	rte
.over
	move.b 	#0,$fffffa1b.w    
	move.l	#raster_after_lower_border_black_line,$120.w
	move.b  #22,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	move.b  #8,$fffffa1b.w
	rte

case4_raster_init
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
		move.b 	#0,$fffffa1b.w    
		move.l	#case4_raster,$120.w
	    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
	popa1
	popa0
    rte

case4_raster
	pusha0
	pusha1
	move.l	rasterpointer,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.l	a0,rasterpointer
	subq.w	#1,rastercounter		;20
	bne		.end
		move.b 	#0,$fffffa1b.w    
		move.l	#raster_after_lower_border_black_line,$120.w
	    move.b  black_line_number,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
	    move.b  #8,$fffffa1b.w
.end
	popa1
	popa0
	rte


raster_position
	dc.b	1
	dc.b	1


no_rasters:
	move.w	#bgco,$ffff8240
	move.w	currentColor,$ffff8250	;0;2;4;6;8;A;C;E;0
    move.b  #0,$fffffa1b.w    
    move.l  #no_raster_open_border,$120.w        ;Install our own Timer B
    move.b	#178-1,$fffffa21.w 
    move.b  #8,$fffffa1b.w

	movem.l	d0-d7/a0,-(sp)
		lea		fontpal,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
	movem.l	(sp)+,d0-d7/a0

;	move.w	#bgco,$ffff8240
;	move.w	#fgco,$ffff8250	;0;2;4;6;8;A;C;E;0

    rte

no_raster_open_border
	movem.l	d1-d2/a0,-(sp)
     clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
                move.w  #$2700,sr

        lea $ffff8209.w,a0          ;Hardsync
        moveq   #127,d1
.sync:      tst.b   (a0)
        beq.s   .sync
        move.b  (a0),d2
        sub.b   d2,d1
        lsr.l   d1,d1
        REPT 59
        	nop
        ENDR
    movem.l (sp)+,d1-d2/a0


	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz
    move    #$2400,sr    

    move.b  #0,$fffffa1b.w    
	move.l	#raster_after_lower_border_black_line,$120.w
	move.b	#22,$fffffa21.w
 	move.b  #8,$fffffa1b.w
	rte

raster_after_lower_border_black_line
	move.w	#0,$ffff8240
    move.b  #0,$fffffa1b.w    
    move.l  #raster_lowest_block,$120.w        ;Install our own Timer B
    move.b  #1,$fffffa21.w            ;Timer B data (number of scanlines to next interrupt)   
    move.b  #8,$fffffa1b.w
	rte

raster_lowest_block
	move.w	#bordercolor,$ffff8240
	move.w	#$334,$ffff8250
    move.b  #0,$fffffa1b.w    
	rte


init_object
	move.l	#12*number+1,number_of_vertices		;12 * 4 + 1 = 49
	move.l	#cube,currentObject
	move.w	#154*4,vertices_xoff
	move.w	#93*4,vertices_yoff

	move.w	#2,stepSpeedX
	move.w	#2,stepSpeedY
	move.w	#2,stepSpeedZ

	move.l	currentObject,a0
	move.l	a0,a1
	move.l	logpointer,d6
	move.l	#max_nr_of_vertices,d7
	subq.l	#1,d7
	move.w	#$5000,d0						; base address of low memory

	move.l	#3-1,d4
.loop
	move.w	d4,d5
.il
		move.w	(a0)+,d6
		add.w	d6,d6
		move.l	d6,a2
		move.w	(a2),d1
		add.w	d0,d1
		move.w	d1,(a1)+
		dbra	d5,.il
	dbra	d7,.loop
	rts


initZTable
	move.l	zpointer,d0
	move.l	d0,a0

	moveq	#0,d1

	move.w	#255-1,d7

	move.l	#pers<<7,d3
	move.l	#pers,d5

	moveq	#-4,d6
	move.w	#-2,d0
	move.l	d0,a1

.loop
		move.l	d1,d4
		add.w	d5,d4		;8
		move.l	d3,d2		;12
		divs.w	d4,d2			;146
		add.w	d2,d2
		move.w	d2,(a0)+
		addq.w	#2,d1

		move.l	d6,d4
		add.w	d5,d4
		move.l	d3,d2
		divs.w	d4,d2
		add.w	d2,d2
		move.w	d2,(a1)

		sub.w	#2,a1
		subq.w	#2,d6

	dbra	d7,.loop

	rts


sourceoffset 	set spriteheight*160
destoffset		set 2*2*spriteheight*16

	IF spriteFromFile
initSprite
	
time set 0
	REPT 5
		lea		sprite+34,a0
		add.w	#time*spriteheight*160,a0
		lea		spritedata,a1
		add.w	#time*2*2*spriteheight*16,a1
		jsr		doStuff
time set time+1
		
	ENDR
		lea		spritedata,a0	;5120 size
		move.b	#0,$ffffc123
	rts

doStuff
	move.l	a1,a6
o set 0
	REPT spriteheight
		move.w	o(a0),(a1)+
		move.w	o+8(a0),(a1)+
o set o+160
	ENDR

	; sort the offset
	moveq	#0,d2
	move.l	#2*2*spriteheight,d3
	move.l	d3,a5
	move.l	#15-1,d4
.doit
		move.l	a6,a0
		move.l	a6,a1
		add.l	d2,a0		; n
		add.l	d3,a1		; n+1
		jsr		shiftSource1pxRight
		add.l	a5,d2		; n = n+1
		add.l	a5,d3		; n+1 = n+2
	dbra	d4,.doit
	rts

shiftSource1pxRight
	moveq.l	#0,d5
	roxr.l	#1,d5
	;a0 is source
	;a1 is dest
	move.l	#spriteheight-1,d7		; y-loop		200*20 = 4000 (*4 bytes)
.loopy
	move.l	#2-1,d6		; x-loop
.loopx
		move.w	(a0)+,d0
		roxr.w	#1,d0		; shift bit out
		move.w	d0,(a1)+
	dbra	d6,.loopx
	dbra	d7,.loopy
	rts

	ENDC


savedCharacterPointer
	dc.l	0
savedCharOffset
	dc.w	0
savedCharCounter
	dc.w	0
saveda0
	dc.l	0
saveda1
	dc.l	0

preshiftListOffset
	dc.w	0

preshiftTextList
	REPT 14
	dc.l	initdo1
	dc.l	do1n
	dc.l	do1m
	ENDR
	dc.l	initdo1
	dc.l	do1n
	dc.l	dolast

initdo1
	move.l	currentTextSpacePointer,a0
	move.l	currentTextSpacePointer,a1

	move.l	currentTextShiftIteration,d0
	add.l	d0,a0
	add.l	d0,a1
	add.w	#textdatasize,a1

	move.l	planeShiftCodePointer,a6

	jsr		(a6)
	add.w	#2,a0
	add.w	#2,a1
	move.l	a0,saveda0
	move.l	a1,saveda1
	addq.w	#4,preshiftListOffset
	rts

do1n
	move.l	saveda0,a0
	move.l	saveda1,a1
	move.l	planeShiftCodePointer,a6
	jsr		(a6)
	add.w	#2,a0
	add.w	#2,a1
	move.l	a0,saveda0
	move.l	a1,saveda1
	addq.w	#4,preshiftListOffset
	rts

do1m
	move.l	saveda0,a0
	move.l	saveda1,a1
	move.l	planeShiftCodePointer,a6
	jsr		(a6)
	add.w	#2,a0
	add.w	#2,a1
	move.l	a0,saveda0
	move.l	a1,saveda1
	addq.w	#4,preshiftListOffset
	subq.w	#1,textshiftcounter
	add.l	#textdatasize,currentTextShiftIteration	
	rts

dolast
	move.l	saveda0,a0
	move.l	saveda1,a1
	move.l	planeShiftCodePointer,a6
	jsr		(a6)
	add.w	#2,a0
	add.w	#2,a1
	move.w	#0,preshiftListOffset
	subq.w	#1,textshiftcounter
	add.l	#textdatasize,currentTextShiftIteration	
	rts

preshiftTextInit
	move.l	currentTextSpacePointer,a0
	move.l	currentTextSpacePointer,a1

	move.l	currentTextShiftIteration,d0
	add.l	d0,a0
	add.l	d0,a1
	add.w	#textdatasize,a1
	rts


generatePlaneShiftCode
	move.l	planeShiftCodePointer,a0
	move.l	#$30280000,d0
	move.l	#$E2503340,d1
	moveq	#0,d2
	move.l	#fontheight*20-1,d7
.ol
	move.l	d0,(a0)+				;4
	move.l	d1,(a0)+				;4
	move.w	d2,(a0)+				;2	===> 10 * 660
	addq.w	#6,d0
	addq.w	#6,d2
	dbra	d7,.ol

	move.w	#$4e75,(a0)
	rts

	IF generateFont
font_to_bitplane
	lea		fontdata,a1
	moveq	#0,d0
	moveq	#0,d1

	move.w	#4-1,d6

.outerloop2
	move.w	#10-1,d7
.ol
	lea		font+34,a0
	add.w	d0,a0

	; do one letter
o	set 0
	REPT fontheight 	; --> ~600b not worth generating
o2	set 0
		REPT 2
			; 2 actual words
			move.l	o+o2(a0),(a1)+
			move.w	o+o2+4(a0),(a1)+
o2	set o2+8
		ENDR
			; 1 empty word
			move.l	d1,(a1)+
			move.w	d1,(a1)+
o	set o+160
	ENDR

	; advance offset to next letter
	add.w	#16,d0
	; a1 is advanced: 3*6*33 = 594, needs additional 8910, since we skip 15 to next letter	(9504 offset between chars)
;	add.w	#8910,a1
	dbra	d7,.ol

	add.l	#(fontheight-1)*160+2*160,d0		; we already added 10*160, hence -1
	dbra	d6,.outerloop2

	; this is size:15444	594 * chars (37) ==> 21978
	lea		fontdata,a0
	move.b	#0,$ffffc123

	rts
	ENDC

drawText
	cmp.w	#5*4,textlistoffset
	bne		.cont
			jsr	drawTimes
.cont


	move.l	textDataPointer,a0
	move.w	currentTextOffset,d0

	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
;	lea		textOffsetTable,a6
	move.l	textOffsetTablePointer,a6
	add.w	d0,a6
	add.l	(a6)+,a0
	move.w	(a6),d1
	move.l	screenpointeraligned2,a1
	add.l	currentTextScreenOffset,a1
	move.l	#21,d7
	sub.w	d1,d7

	muls	#6,d7
	neg.w	d7
	add.w	#122,d7

	subq.w	#1,d1
	muls	#6,d1

	add.w	d1,a0
	move.l	a1,a2

	move.l	#fontheight-1,d6
;.ol
;	REPT 33 	;--> ~400b not worth generating
.x
		move.l	a2,a1					;4
		jmp		(pc,d7.w)				;16
		REPT 20
			move.l	(a0)+,(a1)+			;20
			move.w	(a0)+,(a1)+			;12
			add.w	#2,a1				;8		--> 40*20 + 20 + 16 = 836 * 33 = 27588 
		ENDR
		add.w	d1,a0					;8
		add.w	#160,a2					;8	
	dbra	d6,.x
;	ENDR
	rts

	; was 8*33 = 1584 + 8 + 8 = 1600 * 20 = 32000 worst case (+loop overhead)


notextcounter
	dc.w	700
notext
	dc.w	0

doText
		tst.w	notext
		beq		.end
		; around here a little statemachine
		; ( ( draw -> advance ) -> wait ) -> raster +/ clear 
		tst.w	text_clearing
		beq		.clear
		tst.w	raster			; !=0 not busy with rasters, 0 = raster
		beq		.continue			
		tst.w	waiting			; !=0 => not waiting
		beq		.wait


		jsr		drawText
		jsr		advanceTextState

		jmp		.continue
.wait	
		subq.w	#1,waitcounter
		bne		.continue
.donewaiting
		move.w	#0,raster
		move.w	#waitcounterconstant,waitcounter
		move.w	#-1,waiting
		; do something here with the vbl/rasters, so colors clear
		jmp		.continue
.clear
		move.w	#-1,preshiftTextFrameDone
		move.w	text_clearCounter,d0
		cmp.w	#5,d0
		beq		.doneClearing
			jsr		clear3bpl
			tst.w	text_clearEven
		beq		.swapEven	
			add.w	#1,text_clearCounter
			move.w	#0,text_clearEven
		jmp		.continue
.swapEven		
		move.w	#-1,text_clearEven		
		jmp		.continue
.doneClearing
		move.w	#0,text_clearCounter
		move.w	#-1,text_clearing
		move.b	#1,raster_position
		move.w	#-1,raster
.continue
		tst.w	waiting
		bne		.end
			tst.w	preshiftTextFrameDone
			beq		.end
.end
	rts


advanceTextState
	tst.w	currentTextBackgroundSet
	bne		.reset
		lea		textPathTable,a0
		add.w	textPathOffset,a0
		move.w	(a0),currentTextOffset
		add.w	#2,textPathOffset
		cmp.w	#319,currentTextOffset
		blt		.cont
			sub.w	#1,currentTextOffset
			move.w	#1,currentTextBackgroundSet
			jmp		.cont
.reset
		move.w	#0,textPathOffset

		move.w	#0,currentTextBackgroundSet
		move.w	#0,currentTextOffset
		add.w	#8,textScriptOffset
		lea		textScript,a0
		add.w	textScriptOffset,a0
		move.l	(a0)+,textDataPointer
		move.l	(a0)+,currentTextScreenOffset
		addq.w	#1,stateCounter
		cmp.w	#5,stateCounter
		bne		.cont
			move.w	#0,waiting
			move.w	#0,stateCounter
			move.w	#0,textScriptOffset
			move.l	#textspace1,textDataPointer
			move.l	#160*4-32,currentTextScreenOffset
			move.w	#1,text_precalc
.cont
	rts

doChecker
	move.l	sndh_pointer,a0
	add.w	#$b8,a0
	move.b	(a0),d0
	cmp.b	#1,d0
	bne		.contxx
		tst.w	checker_swapcols
		beq		.set1
			move.w	#0,checker_swapcols
			move.b	#0,(a0)
		jmp		.contxx
.set1
		move.w	#1,checker_swapcols
		move.b	#0,(a0)
.contxx
		
	move.l screenpointeraligned2,a0
	add.w	#6,a0
	sub.w	#32,a0

	move.l	linePointer,a1
	add.w	checker_lineoffset,a1

	tst.w	checker_swapcols
	bne		.swapcols

		add.w	#40,a1
		move.l	a1,a3
		move.l	a1,a2
		add.w	#40,a2

		jmp		.draw

.swapcols
		add.w	#40,a1
		move.l	a1,a3
		add.w	#40,a3
		move.l	a1,a2

.draw
	move.w	checker_lineinv,d7
	move.w	d7,d6
	addq.w	#1,d7

	move.l	#10-1,d5
o set 16000-8
.x
	REPT 10				;---> ~1000b
		move.l	a3,a1
		dbra	d7,*+12
			move.w	d6,d7
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
		REPT 20
			move.w	-(a1),o(a0)
o set o-8
		ENDR
	ENDR
	sub.w	#20*8*10,a0
	dbra	d5,.x

	move.l	linePointer,a1
	add.w	checker_lineoffset,a1

	tst.w	checker_swapcols
	bne		.swapcols2

		move.l	a1,a3
		add.w	#40,a3
		move.l	a1,a2
		jmp		.draw2

.swapcols2
		move.l	a1,a3
		move.l	a1,a2
		add.w	#40,a2

.draw2
	move.w	checker_lineinv,d7
	move.w	d7,d6
	addq.w	#1,d7

	move.l screenpointeraligned2,a0
	add.w	#6,a0
	sub.w	#32,a0

	add.w	#16000,a0
	move.w	#10-1,d5
.xxx
o set 0
	REPT 10				;---> ~1000b
		move.l	a3,a1
		dbra	d7,*+12
			move.w	d6,d7
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
		REPT 20
			move.w	(a1)+,o(a0)
o set o+8
		ENDR
	ENDR
	add.w	#20*8*10,a0
	dbra	d5,.xxx

;	IFNE z_sync
;	subq.w	#1,checker_zoom_counter
;	tst.w	checker_zoom_counter
;	bge		.nochange
;		move.w	#0,checker_minus
;.nochange
;	ENDC


;	subq.w	#1,checker_linecounter
;	bne		.gogo
;	move.w	#3,checker_linecounter

	tst.w	checker_minus
	beq		.gogo
	blt		.minus
		add.w	#1,checker_lineinv
		add.w	#40*2,checker_lineoffset
		cmp.w	#40*126*2,checker_lineoffset
		bne		.gogo
			move.w	#-1,checker_minus
			jmp		.gogo
.minus
		sub.w	#1,checker_lineinv
		sub.w	#40*2,checker_lineoffset
		bne		.gogo
			move.w	#1,checker_minus
.gogo
	rts


	IF offsmapFromTGA
generateOffsetFromTGA
	lea	tga+18,a0
	add.w	#20*3*64,a0
	lea	offsmap,a1
	move.w	#25-1,d7			; 25 * 40 * 2 = 2kb
.y
	add.w	#12*3,a0
	move.w	#40-1,d6
.x
		moveq	#0,d1
		addq.w	#1,a0
		move.b	(a0)+,d1
		ext.w	d1
		lsl.w	#6,d1
		add.b	(a0)+,d1
		move.w	d1,(a1)+				; 
	dbra	d6,.x
	add.w	#12*3,a0
	dbra	d7,.y

	lea		offsmap,a0		; 2000
	move.b	#0,$ffffc123

	rts
	ENDC


initFlowMap:
   ; multiply all values of curve by 64
   	lea	curve_1,a0
    move.l	#64,d1
    ;rept  256
    move.l #255,d7
t1:
      	move.w (a0),d2
      	lsr.w	#1,d2
;      	mulu.w d1,d2
		add.w	d2,d2
      	move.w d2,(a0)+
   	dbra d7,t1
      ;endr
  	


  	; multiply all values of picture by 2
  	lea	pic,a0
      	;rept  256
          move.l #8192/2-1,d7
t3:
      	move.w (a0),d2
      	add.w d2,d2
      	move.w d2,(a0)+
   	dbra d7,t3     

   	rts

fixSourceDerp
	move.l	rasterSource2Pointer,a0
	lea		rastersource,a1
	; 6400 = 1600 * 4
	moveq	#0,d0
	; 1600 / 20 = 80
	move.l	#80-1,d7
.x
	REPT 20
		move.l	(a1)+,(a0)+		;	20 * 4 * 80 = 6400
	ENDR 
	dbra	d7,.x


;textOffsetTable			; 16*20*6 = 1920
;block set 20
;	REPT 20
;mult set 0
;		REPT 16
;			dc.l	textdatasize*mult
;			dc.w	block
;mult set mult+1
;		ENDR
;block set block-1
;	ENDR
	move.l	textOffsetTablePointer,a0
	move.l	#16-1,d6
	move.l	#20-1,d7

	move.l	#textdatasize,d2
	move.w	#20,d1

.ol
	move.l	d6,d5
	move.l	#0,d0
.il
		move.l	d0,(a0)+
		move.w	d1,(a0)+
		add.l	d2,d0
	dbra	d5,.il
	subq.w	#1,d1
	dbra	d7,.ol

;textdist				; 16*20*4 => 1280
;blockoff	set 0
;	REPT 20
;x_off	set 0
;		REPT 16
;			dc.w	blockoff
;			dc.w	x_off			;15*6+2
;x_off	set x_off+1
;		ENDR
;blockoff	set blockoff+6
;	ENDR
	move.l	textDistPointer,a0
	move.l	#16-1,d6
	move.l	#20-1,d7
	moveq	#0,d0
	moveq	#0,d1

.ol2
	move.l	d6,d5
	moveq	#0,d0
.il2
		move.w	d1,(a0)+
		move.w	d0,(a0)+
		addq.w	#1,d0
		dbra	d5,.il2
	addq.w	#6,d1
	dbra	d7,.ol2

;spritelookup			;--> 20*16*8	---> 2560
;offset set -32+6
;	REPT 20
;mult set 0
;		REPT 16
;			dc.l	spritedata+mult*2*2*spriteheight
;			dc.w	offset
;			dc.w	0
;mult set mult+1
;		ENDR
;offset set offset+8
;	ENDR
	move.l	spriteLookupPointer,a0			; => 16 * 20 * 8 = 2560
	move.l	#16-1,d6
	move.l	#20-1,d7
	move.l	#spritedata,d0
	move.l	#2*2*spriteheight,d1

	moveq	#-26,d3	; offset

.ol3
	move.l	d6,d5
	move.l	d0,d2		; mult = 0
.il3	
		move.l	d2,(a0)+
		move.w	d3,(a0)+
		move.w	d3,(a0)+	; padding
		add.l	d1,d2
		dbra	d5,.il3
	addq.w	#8,d3
	dbra	d7,.ol3



	lea		lines,a0
	move.l	linePointer,a1
	;10160/4 = 2540
	move.l	#254-1,d7
.haha
	REPT 10
		move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.haha

	rts

flowmapOffsetX		dc.w	0
flowInv
	dc.w	-1
currentPicPointer
	dc.l	0


doFlowMap
	move.l	sndh_pointer,a0
	add.w	#$b8,a0
	move.b	(a0),d0
	cmp.b	#1,d0
	bne		.pointerset
		move.b	#0,(a0)
		tst.w	flowInv
		beq		.setneg
			move.w	#0,flowInv
			move.l	picInversePointer,currentPicPointer
			jmp		.pointerset
.setneg
		move.w	#-1,flowInv
		move.l	blockPointer,a1
		move.l	a1,currentPicPointer
.pointerset

	move.l	currentPicPointer,a1


	move.l	screenpointeraligned2,a0
	sub.l	#32-6,a0
	move.l	a1,d7
	move.l	a1,usp

	lea		pic,a2
	lea		curve_1,a6
	add.w	flowmapOffsetX,a6
	add.w	(a6),a2

	lea		left_table,a4
	lea		right_table,a5

	moveq	#0,d6
	moveq	#0,d5

	move.l	currentC2PCodePointer,a3
	jsr		(a3)

	add.w	#2,flowmapOffsetX
	cmp.w	#512,flowmapOffsetX
	bne		.cont
		move.w	#0,flowmapOffsetX
.cont
	rts

VIEWPORT_HEIGHT equ 25
VIEWPORT_WIDTH	equ 20

generateFlowMapCode
	move.w	#160*7,a1
	move.l	#$31590000,d4				; move.w (a1)+,x(a0)
;	move.w	#$3159,a2					
	move.w	#$4E69,a3					; move.l	usp,a1
	move.l	#$1A2A0000,d2					; move.b	1234(a2),d5	
	move.l	#$D2F45000,d0
	move.l	#$D2F55000,d1

	moveq	#0,d3		; h
;	moveq	#0,d4		; iloopcounter; o
	move.l	#160,a2

	move.l	#VIEWPORT_HEIGHT-1,d7
.ol
	move.l	#VIEWPORT_WIDTH-1,d6
.il
		move.w	d3,d4		; o set h

		move.w	a3,(a0)+		; move.l usp,a1

		move.w	(a6)+,d2		; x = ...
		move.l	d2,(a0)+		; move.b x(a2),d5
		move.l	d0,(a0)+		; add.w	(a4,d5.w),a1

		move.w	(a6)+,d2		; x = ...
		move.l	d2,(a0)+		; move.b x(a2),d5
		move.l	d1,(a0)+		; add.w	(a5,d5.w),a1

		REPT 8
			move.l	d4,(a0)+	; 	o = d4
			add.w	a2,d4
		ENDR
		addq	#8,d3
	dbra	d6,.il
	add.l	a1,d3
	dbra	d7,.ol

	move.w	#$4e75,(a0)
	rts

generateCharLookup
	move.l	charLookupPointer,a0
	lea		fontdata,a1
	move.l	a1,d1
	move.l	#594,d0						;i
	move.l	#fontchars-1,d7					; rept 26
.ol
		move.l	d1,(a0)+				; fontdata+i*594			; 26 * 4 = 104
		add.l	d0,d1					; i = i + 1
	dbra	d7,.ol
	rts



section data

blocks1
	incbin	res/sh15/8x8sprite1.bin
;blocks2
;	incbin	res/sh15/8x8sprite2.bin
blocks3
	incbin	res/sh15/8x8sprite3.bin
blocks4
	incbin	res/sh15/8x8sprite4.bin
blocks5
	incbin	res/sh15/8x8sprite5.bin
blocks6
	incbin	res/sh15/8x8sprite6.bin
blocks7
	incbin	res/sh15/8x8sprite7.bin

spriteList
	dc.l	blocks1	;0
;	dc.l	blocks1	;4
;	dc.l	blocks2	;8
;	dc.l	blocks2	;12
	dc.l	blocks3	;16
	dc.l	blocks3	;20
	dc.l	blocks4	;24
	dc.l	blocks4	;28
	dc.l	blocks5	;32
	dc.l	blocks5	;36
	dc.l	blocks6	;40
	dc.l	blocks6	;44
	dc.l	blocks7	;48
	dc.l	blocks7	;52

spritedata
	incbin	res/sh15/spritedata2.bin

	include	asm/lib.s


curve_1:
	include	res/sh15/curve_1.s

           even
pic:
	include	res/sh15/pic.s

balla2
	include res/sh15/balla2.txt
balla3
	include res/sh15/balla3.txt
balla6
	include	res/sh15/balla6.txt

rastersource
	include	res/sh15/rastersource.s		; 6400

left_table:
	dc.w    0
    dc.w    16
    dc.w    32
    dc.w    48
    dc.w    64
    dc.w    80
    dc.w    96
    dc.w    112
    dc.w    128
    dc.w    144
    dc.w    160
    dc.w    176
    dc.w    192
    dc.w    208
    dc.w    224
    dc.w    240	;16
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240	;32
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240	;48
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240
    dc.w    240	;64

right_table:
	dc.w    0
    dc.w    256
    dc.w    512
    dc.w    768
    dc.w    1024
    dc.w    1280
    dc.w    1536
    dc.w    1792
    dc.w    2048
    dc.w    2304
    dc.w    2560
    dc.w    2816
    dc.w    3072
    dc.w    3328
    dc.w    3584
    dc.w    3840	;16 
    dc.w    3840    
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840	;32
    dc.w    3840    
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840	;48
    dc.w    3840    
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840
    dc.w    3840	;64

checker_zoom_counter		dc.w	40
checker_lineoffset			dc.w	0*50
checker_lineinv				dc.w	0
checker_linecounter			dc.w	3
checker_minus				dc.w	1
checker_swapcols			dc.w	1




textPathTable
	include 	res/sh15/scrollpath2.txt



;	rastercounter idea:
;	0 = normal color						
;	1 = one fade and then normal color
;	2 = two fade and then normal color
;   3 = 3 fade and then normal color
;	4 = 4 fade and then normal color
;	5 = 5 fade and then normal color
;	6 = 6 fade and then normal color
;	x > 6, palette 7 for x-6 lines and then fade
;
; so if there is a counter that goes from 0 to 200 then:
;	counter - 6 < 0 => nothing
;	counter >= 0 => something
;	counter >= 
;
;
;	move.w	rastercounter,d0
;	sub.w	#6,d0
;	bgt		
;
;
;	if(counter > 6){
;		directly at effect part -> rastercolors+0 into palette
;		counter - 6 = amount of timer b skips,
;		schedule new timer b
;	}
;
;
bgco	equ $777
fgco	equ $665
rastercolors
;			;0	 ;1	  ;2   ;3	;4	 ;5	  ;6   ;7	;8	 ;9	  ;10  ;11	;12	 ;13  ;14  ;15		
	dc.w	bgco,$777,$777,$777,$777,$777,$777,$777,fgco,$666,$666,$666,$666,$666,$666,$666
	dc.w	bgco,$766,$666,$666,$666,$666,$666,$666,fgco,$655,$655,$655,$555,$555,$555,$555
	dc.w	bgco,$765,$655,$655,$555,$555,$555,$555,fgco,$664,$654,$644,$544,$544,$444,$444
	dc.w	bgco,$763,$653,$643,$533,$433,$333,$333,fgco,$763,$653,$643,$533,$433,$333,$333
	dc.w	bgco,$762,$653,$643,$533,$433,$323,$223,fgco,$762,$653,$643,$533,$433,$323,$323
	dc.w	bgco,$762,$653,$643,$533,$433,$323,$203,fgco,$762,$653,$643,$533,$433,$323,$213
	REPT 10
	dc.w	bgco,$762,$653,$643,$533,$433,$323,$203,fgco,$762,$653,$643,$533,$433,$323,$203
	ENDR

raster
	dc.w	1
waiting
	dc.w	1
waitcounter
	dc.w	waitcounterconstant
stateCounter
	dc.w	0

textScript
	dc.l	textspace1,160*4-32
	dc.l	textspace2,160*44-32
	dc.l	textspace3,160*84-32
	dc.l	textspace4,160*124-32
	dc.l	textspace5,160*164-32

spacebardist equ 10*4 
space	equ 2*4
stdoff	equ 19*4
textoff
	dc.w	22*4+space	;a
	dc.w	19*4+space	;b
	dc.w	20*4+space	;c
	dc.w	19*4+space		;d
	dc.w	16*4+space		;e
	dc.w	16*4+space		;f
	dc.w	22*4+space	;g
	dc.w	20*4+space		;h
	dc.w	9*4+space		;i
	dc.w	20*4+space		;j
	dc.w	20*4+space	;k
	dc.w	17*4+space	;l
	dc.w	20*4+space	;m
	dc.w	18*4+space	;n
	dc.w	stdoff+space	;o
	dc.w	19*4+space	;p
	dc.w	stdoff+space	;q
	dc.w	stdoff+space	;r
	dc.w	stdoff+space	;s
	dc.w	17*4+space	;t
	dc.w	18*4+space	;u
	dc.w	18*4+space	;v
	dc.w	20*4+space	;w
	dc.w	20*4+space	;x
	dc.w	16*4+space	;y
	dc.w	stdoff+space	;z
	dc.w	7*4+space		;.		[
	dc.w	7*4+space		;:		\
	dc.w	8*4+space		;!		]
	dc.w	15*4+space		;-		"
	dc.w	stdoff+space	;0		_
	dc.w	12*4+space		;1		'
	dc.w	17*4+space		;2		a
	dc.w	20*4+space		;3		b
	dc.w	stdoff+space	;4		c
	dc.w	20*4+space		;5		d
	dc.w	7*4+space		;,		e


textspacelist
	dc.l	textspace1
	dc.l	textspace2
	dc.l	textspace3
	dc.l	textspace4
	dc.l	textspace5

textlist
	dc.l	text01
	dc.l	text02
	dc.l	text03
	dc.l	text04
	dc.l	text05
	dc.l	text06
	dc.l	text07
	dc.l	text08
	dc.l	text09
	dc.l	text10
	dc.l	text11
	dc.l	text12
	dc.l	text13
	dc.l	text14
	dc.l	text15
	dc.l	text16
	dc.l	text17
	dc.l	text18
	dc.l	text19
	dc.l	text20
	dc.l	text21
	dc.l	text22
	dc.l	text23
	dc.l	text24
	dc.l	text25
	dc.l	text26
	dc.l	text27
	dc.l	text28
	dc.l	text29
	dc.l	text30
	dc.l	text31
	dc.l	text32
	dc.l	text33
	dc.l	text34
	dc.l	text35
	dc.l	text36
	dc.l	text37
	dc.l	text38
	dc.l	text39
	dc.l	text40
	dc.l	text41
	dc.l	text42
	dc.l	text43
	dc.l	text44
	dc.l	text45
	dc.l	text46
	dc.l	text47
	dc.l	text48
	dc.l	text49
	dc.l	text50
	dc.l	text51
	dc.l	text52
	dc.l	text53
	dc.l	text54
	dc.l	text55



;dc.b "DEAD HACKERS  "
;dc.b "SOCIETY       "
;dc.b "TOGETHER WITH "
;dc.b "CHECKPOINT    "
;dc.b "INVITES YOU TO"


text01		;1234567890123456789
	dc.w	12,18*4
	dc.b	"DEAD HACKERS"
	even
text02		;1234567890123456789
	dc.w	7,75*4
	dc.b	"SOCIETY"
;	dc.b	"abcdefghijklmnopqstu"
	even
text03		;1234567890123456789
	dc.w	13,17*4
	dc.b	"TOGETHER WITH"
	even
text04		;1234567890123456789
	dc.w	10,41*4
	dc.b	"CHECKPOINT"
	even
text05		;1234567890123456789
	dc.w	13,31*4
	dc.b	"INVITE YOU TO"
	even

;.		[
;:		\
;!		]
;-		^
;0		_
;1		`
;2		a
;3		b
;4		c
;5		d

;;     12345678901234
;dc.b "              "
;dc.b "SOMMARHACK    "
;dc.b "----------    "
;dc.b "2015          "
;dc.b "              "

text06		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even
text07		;1234567890123456789
	dc.w	10,30*4
	dc.b	"SOMMARHACK"
	even
text08		;1234567890123456789
	dc.w	14,21*4
	dc.b	"^^^^^^^^^^^^^^"
	even
text09		;1234567890123456789
	dc.w	4,102*4
	dc.b	"a","_","`","d"
	even
text10		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even


;dc.b "              "
;dc.b "JULY 3, 14:00 "
;dc.b "TO            "
;dc.b "JULY 5, 14:00 "
;dc.b "              "

text11		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even
text12		;1234567890123456789
	dc.w	14,32*4
	dc.b	"JULY be `c\__"
	even
text13		;1234567890123456789
	dc.w	2,120*4
	dc.b	"TO"
	even
text14		;1234567890123456789
	dc.w	14,32*4
	dc.b	"JULY de `c\__"
	even
text15		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even


;dc.b "THE PARTY IS  "
;dc.b "LOCATED NEXT  "
;dc.b "TO DALALVEN IN"
;dc.b "GRADO, DALARNA"
;dc.b "SWEDEN        "


text16		;1234567890123456789
	dc.w	12,33*4
	dc.b	"THE PARTY IS"
	even
text17		;1234567890123456789
	dc.w	12,24*4
	dc.b	"LOCATED NEXT"
	even
text18		;1234567890123456789
	dc.w	14,12*4
	dc.b	"TO DALALVEN IN"
	even
text19		;1234567890123456789
	dc.w	14,0*4
	dc.b	"GRADOe DALARNA"
	even
text20		;1234567890123456789
	dc.w	6,80*4
	dc.b	"SWEDEN"
	even


;      12345678901234
;dc.b "COMPETITIONS  "
;dc.b "FOR ALL ATARI "
;dc.b "MACHINES IN   "
;dc.b "DEMO, GFX AND "
;dc.b "MSX CATEGORIES"


text21		;1234567890123456789
	dc.w	12,27*4
	dc.b	"COMPETITIONS"
	even
text22		;1234567890123456789
	dc.w	13,20*4
	dc.b	"FOR ALL ATARI"
	even
text23		;1234567890123456789
	dc.w	11,40*4
	dc.b	"MACHINES IN"
	even
text24		;1234567890123456789
	dc.w	13,20*4
	dc.b	"DEMOe GFX AND"
	even
text25		;1234567890123456789
	dc.w	14,3*4
	dc.b	"MSX CATEGORIES"
	even

;      1234567890123
;dc.b "ONLY A FEW    "
;dc.b "TICKETS REMAIN"
;dc.b "SO IT IS TIME "
;dc.b "TO BOOK YOURS "
;dc.b "NOW!          "



text26		;1234567890123456789
	dc.w	10,50*4
	dc.b	"ONLY A FEW"
	even
text27		;1234567890123456789
	dc.w	14,11*4
	dc.b	"TICKETS REMAIN"
	even
text28		;1234567890123456789
	dc.w	14,38*4
	dc.b	"SO IT IS TIME"
	even
text29		;1234567890123456789
	dc.w	14,17*4
	dc.b	"TO BOOK YOURS"
	even
text30		;01234567890123456789
	dc.w	4,104*4
	dc.b	"NOW]"
	even

;      1234567890123
;dc.b "CHECK OUT THE "
;dc.b "WEB PAGE FOR  "
;dc.b "UP-TO-DATE    "
;dc.b "INFORMATIONS  "
;dc.b "AND DETAILS   "


text31		;1234567890123456789
	dc.w	13,18*4
	dc.b	"CHECK OUT THE"
	even
text32		;1234567890123456789
	dc.w	13,26*4
	dc.b	"WEB PAGE FOR"
	even
text33		;1234567890123456789
	dc.w	10,49*4
	dc.b	"UP TO DATE"
	even
text34		;1234567890123456789
	dc.w	11,36*4
	dc.b	"INFORMATION"
	even
text35		;1234567890123456789
	dc.w	11,36*4
	dc.b	"AND DETAILS"
	even


;      12345678901234
;dc.b "WE HOPE TO SEE"
;dc.b "YOU IN SUNNY  "
;dc.b "DALECARLIA    "
;dc.b "LATER THIS    "
;dc.b "SUMMER.       "

text36		;1234567890123456789
	dc.w	14,16*4
	dc.b	"WE HOPE TO SEE"
	even
text37		;1234567890123456789
	dc.w	12,36*4
	dc.b	"YOU IN SUNNY"
	even
text38		;1234567890123456789
	dc.w	10,39*4
	dc.b	"DALECARLIA"
	even
text39		;1234567890123456789
	dc.w	10,48*4
	dc.b	"LATER THIS"
	even
text40		;1234567890123456789
	dc.w	7,74*4
	dc.b	"SUMMER["
	even

;      1234567890123
;dc.b "NOW, OPEN     "
;dc.b "ANOTHER       "
;dc.b "GROLSCH       "
;dc.b "AND SCREAM    "
;dc.b "AAAATARI!!!   "

text41		;1234567890123456789
	dc.w	8,64*4
	dc.b	"NOW OPEN"
	even
text42		;1234567890123456789
	dc.w	7,68*4
	dc.b	"ANOTHER"
	even
text43		;1234567890123456789
	dc.w	7,65*4
	dc.b	"GROLSCH"
	even
text44		;1234567890123456789
	dc.w	10,39*4
	dc.b	"AND SCREAM"
	even
text45		;1234567890123456789
	dc.w	11,40*4
	dc.b	"ATAAAARI]]]"
	even

text46
	dc.w	8,69*4
	dc.b	"CREDITS\"
	even
text47
	dc.w	10,47*4
	dc.b	"CODE\ SPKR"
	even
text48
	dc.w	12,25*4
	dc.b	"GFX\ MODMATE"
	even
text49
	dc.w	8,65*4
	dc.b	"MSX\ d_d"
	even
text50
	dc.w	9,63*4
	dc.b	"TEXT\ EVL"
	even

;     1234567890123
;dc.b "              "
;dc.b "END           "
;dc.b "OF            "
;dc.b "MESSAGE       "
;dc.b "              "

text51		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even
text52		;1234567890123456789
	dc.w	3,111*4
	dc.b	"END"
	even
text53		;1234567890123456789
	dc.w	2,121*4
	dc.b	"OF"
	even
text54		;1234567890123456789
	dc.w	8,62*4
	dc.b	"MESSAGE[ "
	even
text55		;1234567890123456789
	dc.w	1,0*4
	dc.b	" "
	even



;; 200 * 2 = 400s
	REPT 40								
		dc.w	0
	ENDR
	REPT 40
		dc.w	16*2*2*spriteheight*1
	ENDR
	REPT 20
		dc.w	16*2*2*spriteheight*2
	ENDR
perspectivethingie
	REPT 20
		dc.w	16*2*2*spriteheight*2
	ENDR
	REPT 40
		dc.w	16*2*2*spriteheight*3
	ENDR
	REPT 40
		dc.w	16*2*2*spriteheight*4
	ENDR






bannerpal1
		dc.w	$544,$212,$323,$333,$555,$777,$776,$445,$444,$754,$764,$774,$545,$535,$645,$744		; target	; 9 steps
		dc.w	$544,$312,$323,$333,$555,$777,$776,$445,$444,$754,$764,$774,$545,$535,$645,$744		;r+2
		dc.w	$544,$412,$423,$433,$555,$677,$676,$445,$444,$654,$664,$674,$545,$535,$645,$644		;r+1
		dc.w	$544,$412,$423,$433,$555,$677,$676,$445,$444,$654,$664,$674,$545,$535,$645,$644		;r+1
		dc.w	$544,$512,$523,$533,$555,$577,$576,$545,$544,$554,$564,$574,$545,$535,$545,$544		;g+3
		dc.w	$544,$522,$523,$533,$555,$567,$566,$545,$544,$554,$564,$564,$545,$535,$545,$544		;g+2
		dc.w	$544,$522,$523,$533,$555,$567,$566,$545,$544,$554,$564,$564,$545,$535,$545,$544		;g+2
		dc.w	$544,$532,$533,$533,$555,$557,$556,$545,$544,$554,$554,$554,$545,$535,$545,$544		;g+1
		dc.w	$544,$542,$543,$543,$545,$547,$546,$545,$544,$544,$544,$544,$545,$545,$545,$544		;b+3
		dc.w	$544,$542,$543,$543,$545,$547,$546,$545,$544,$544,$544,$544,$545,$545,$545,$544		;b+3
		dc.w	$544,$542,$543,$543,$545,$546,$546,$545,$544,$544,$544,$544,$545,$545,$545,$544		;b+2
		dc.w	$544,$543,$543,$543,$545,$545,$545,$545,$544,$544,$544,$544,$545,$545,$545,$544		;b+1
		dc.w	$544,$543,$543,$543,$545,$545,$545,$545,$544,$544,$544,$544,$545,$545,$545,$544		;b+1
		dc.w	$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544		;bg

bannerpal2
		dc.w											$444,$112,$223,$441,$451,$551,$672,$340		; target	; 11 steps
		dc.w											$444,$212,$223,$441,$451,$551,$672,$340		;r+3
		dc.w											$444,$312,$323,$441,$451,$551,$672,$340		;r+2
		dc.w											$444,$412,$423,$441,$451,$551,$672,$440		;r+1
		dc.w											$544,$512,$523,$541,$551,$551,$572,$540		;g+3
		dc.w											$544,$512,$523,$541,$551,$551,$572,$540		;g+3
		dc.w											$544,$522,$523,$541,$551,$551,$562,$540		;g+2
		dc.w											$544,$532,$533,$541,$551,$551,$552,$540		;g+1
		dc.w											$544,$542,$543,$541,$541,$541,$542,$540		;b+4
		dc.w											$544,$542,$543,$541,$541,$541,$542,$540		;b+4
		dc.w											$544,$542,$543,$541,$541,$541,$542,$541		;b+3
		dc.w											$544,$542,$543,$542,$542,$542,$542,$542		;b+2
		dc.w											$544,$543,$543,$543,$543,$543,$543,$543		;b+1
		dc.w											$544,$544,$544,$544,$544,$544,$544,$544		;bg
bannerpal3
		dc.w	$544,$333,$774,$100,$562,$777,$776,$445												;target 		; 13 steps
		dc.w	$544,$433,$774,$200,$562,$777,$776,$445												;r+4
		dc.w	$544,$433,$774,$200,$562,$777,$776,$445												;r+3
		dc.w	$544,$433,$774,$300,$562,$777,$776,$445												;r+2
		dc.w	$544,$433,$674,$400,$562,$677,$676,$445												;r+1
		dc.w	$544,$533,$574,$500,$562,$577,$576,$545												;g+4
		dc.w	$544,$533,$574,$510,$562,$577,$576,$545												;g+3
		dc.w	$544,$533,$564,$520,$562,$567,$566,$545												;g+2
		dc.w	$544,$533,$554,$530,$552,$557,$556,$545												;g+1
		dc.w	$544,$543,$544,$540,$542,$547,$546,$545												;b+4
		dc.w	$544,$543,$544,$541,$542,$547,$546,$545												;b+3
		dc.w	$544,$543,$544,$542,$542,$546,$546,$545												;b+2
		dc.w	$544,$543,$544,$543,$543,$545,$545,$545												;b+1
		dc.w	$544,$544,$544,$544,$544,$544,$544,$544												;bg

fontdata																; thus -32kb here
	incbin	res/sh15/fontdata7.bin
fontpal
	dc.w	bgco,$762,$653,$643,$533,$433,$323,$203,fgco,$762,$653,$643,$533,$433,$323,$203


numbers:
	incbin	res/sh15/numbers.bin


	IF generateFont
font
	incbin	res/sh15/font8.pi1
	ENDC

	IF spriteFromFile
sprite
	incbin	res/sh15/heart16.pi1
	ENDC

	IF offsmapFromTGA
tga
	incbin		res/c2p/distortme1.tga			
	ENDC



	IFNE playmusic
music:	
	incbin	msx/Z2.SND
	ENDC
	even

sintable1:
	include	res/polygon/sin_ampl_127_steps_256.s


cube
;size equ 59
;dedu equ size/(number/2)
;number equ 4

val set size
	rept number
	dc.w	val,size,size
val set val-dedu
	endr

val set size
	rept number+1
	dc.w	val,-size,-size
val set val-dedu
	endr

val set size
	rept number
	dc.w	val,-size,size
val set val-dedu
	endr

val set size
	rept number
	dc.w	val,size,-size
val set val-dedu
	endr

val set size
	rept number	
	dc.w	size,val,size
val	set val-dedu
	endr

val set size
	rept number
	dc.w	-size,val,-size
val set val-dedu
	endr

val set size
	rept number
	dc.w	size,val,-size
val set val-dedu
	endr

val set size
	rept number
	dc.w	-size,val,size
val set val-dedu
	endr

val set size
	rept number
	dc.w	size,size,val
val set val-dedu
	endr

val set size
	rept number
	dc.w	-size,-size,val
val set val-dedu
	endr

val set size
	rept number
	dc.w	size,-size,val
val set val-dedu
	endr

val set size
	rept number
	dc.w	-size,size,val
val set val-dedu
	endr

	IFNE generateBanner
xa1 incbin	res/sh15/sh15-1.pi1
xb2 incbin	res/sh15/sh15-2.pi1
xc3 incbin	res/sh15/sh15-3.pi1https://bitbucket.org/spkr/sh15inv
tmppic						ds.b	50*160
	ENDC

	ds.b	200

; here we start shit that we can override

textspace1 equ logo
logo			incbin	res/sh15/topbanner1.bin
log_src:        incbin res/explog/LOG.TAB			; 8192		
exp_src:        incbin res/explog/EXP.TAB			; 8192
offsmap			incbin res/sh15/offsmap1.bin	; 2000
offsmap2		incbin res/sh15/offsmap4.bin	; 2000	-> total 20384		--> used: 4096 (blocks) 8768 (generateblockcode) --> 7520; blocks+12864 = free space - 6400 = 1120 free space
lines:			include res/sh15/lines.txt		; 10160		--> 46144

	
	even

section bss
							ds.b	fontheight*20*6*16-2*8192-2*2000-10160-8000
;textspace1					ds.b	fontheight*20*6*16	;	63360 * 5 = 316800
textspace2					ds.b	fontheight*20*6*16
textspace3					ds.b	fontheight*20*6*16
textspace4					ds.b	fontheight*20*6*16
textspace5					ds.b	fontheight*20*6*16

rastercounter				ds.w	1
rasterpointer				ds.l	1

spriteLookupPointer			ds.l	1
spriteListOffset			ds.w	1

textOffsetTablePointer		ds.l	1
textDistPointer				ds.l	1
textPathOffset				ds.w	1
textlistoffset				ds.w	1
textspaceoffset				ds.w	1

; 3d data
vertices_xoff				ds.w	1
vertices_yoff				ds.w	1
objectPathPointer			ds.l	1
currentObject				ds.l	1
currentStepX            	ds.w    1
currentStepY            	ds.w    1
currentStepZ            	ds.w    1
stepSpeedX              	ds.w    1
stepSpeedY              	ds.w    1
stepSpeedZ              	ds.w    1
number_of_vertices			ds.l	1
vertexloc_pointer			ds.l	1
vertexloc2_pointer			ds.l	1
vertexloc					ds.w	max_nr_of_vertices
vertexloc2					ds.w	max_nr_of_vertices
vertexprojection_pointer	ds.l	1
vertexprojection2_pointer	ds.l	1

charLookupPointer			ds.l	1	;4

drawSpriteInnerCodePointer	ds.l	1	;4	; this should be y_block_pointer + 3200
oldLowerPointer				ds.l	1	;4	; this should be zpointer value + 600
clear3bplPointer			ds.l	1	;4	; oldLowerPointer + 40960 ; size = 5282

planeShiftCodePointer		ds.l	1	;4
ballCodePointer				ds.l	1	;4

c2PCodePointer				ds.l	1	;4
c2PCodePointer2				ds.l	1	;4
currentC2PCodePointer		ds.l	1	;4
spriteToBlocksCodePointer	ds.l	1
blockPointer				ds.l	1

picInversePointer			ds.l	1	;4

rasterSource2Pointer		ds.l	1	;4

alignpointer1				ds.l	1	;4
alignpointer2				ds.l	1	;4
alignpointer3				ds.l	1	;4
alignpointer4				ds.l	1	;4
alignpointer5				ds.l	1	;4

gemScreenBuffer				ds.l	1

zpointer					equ		alignpointer1		; 512 bytes top and 512 bytes bottom used
expointernorm				equ		alignpointer2
logpointer					equ 	alignpointer3
exppointer					equ		alignpointer4

y_block						ds.b	800

linePointer					ds.l	1

screenpointeraligned		ds.l	1	;4
screenpointeraligned2		ds.l	1	;4

;spritedata					ds.b	16*2*2*spriteheight*5	; --> 16*2*2*5 = 320 * 16 = 5120 b per sprite, this can be saved

textStringPointer			ds.l	1	;4
textDataPointer				ds.l	1	;4
textScriptOffset			ds.w	1	;2
currentTextOffset			ds.w	1	;2
currentTextSpacePointer		ds.l	1	;4
currentTextShiftIteration	ds.l	1	;4
currentTextScreenOffset		ds.l	1	;4
currentTextBackgroundSet	ds.w	1	;2			; 235 * 4 = 940

screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1

							ds.b	50*160+32	
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
align1:						ds.b	65536
align2:						ds.b	65536
align3:						ds.b	65536
lastblock					ds.b	18000


even
