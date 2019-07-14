
MAKE_DIAG 			equ FALSE
PACKTOTAL			equ 0

CURRENT_NUMBER_OF_STARTING_DOTS	equ 79-2-4-6
;;;;;;;;;;;;;; SINE DOTS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; SINE DOTS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;; SINE DOTS ;;;;;;;;;;;;;;
bgcolor				equ $ffff8240
nr_of_dots 			equ 100
nr_of_partitions	equ 17
max_nr_of_vertices	equ 6400			; max in vbl with music is 643


;--------------
;DEMOPAL - sineflower colors for the 3 `places', front/middle/back
;--------------
front				equ $741	
middle				equ	$630		
back				equ	$420		



	
LOGS            	EQU 1024
EXPS            	EQU 4096



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
CHECK_VBL_OVERFLOW	equ 0
SHOW_CPU	equ 1

	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	include macro.s

	IFEQ	STANDALONE
			initAndRun	standalone_init


standalone_init
;	jsr		prepMotNeo
;	jsr		genBlock
	jsr		init_effect
	IFEQ	MAKE_DIAG
		jsr		prepDiag
	ENDC

	jsr		init_diagvhs
	move.w	#700,effect_vbl_counter

;	jsr		prepSinFlow

;	jsr		prepPot1
;	jsr		prepPotAtari
;	jsr		prepPot2
;	jsr		prepPot2b

	jsr		diagvhs_mainloop

	rts



init_effect
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	add.l	#$10000,d0
	rts
	ENDC

diagvhs_mainloop
.w2
	tst.w   $466.w
    beq     .w2
    IFEQ	CHECK_VBL_OVERFLOW
    	cmp.w	#2,$466.w
    	blt		.okido
    		move.b	#0,$ffffc123
    		nop
    		move.w	#$300,$ffff8240
.okido
	ENDC
    	move.w	#0,$466.w
    	subq.w	#1,effect_vbl_counter
    	blt		.next

		jsr		init_sineflower


    	jmp		.w2
.next	
	rts


init_diagvhs
	move.l	screen2,d0
	add.l	#$10000,d0
	move.l	d0,logpointer							
	move.l	d0,d1
	add.l	#2048,d1							;2048	/	2048
	move.l	d1,x_block_aligned_pointer				
	add.l	#1280,d1							;1280	/	3328
	move.l	d1,y_block_aligned_pointer				
	add.l	#800,d1								;800	/	4128
	move.l	d1,tableSourcePointer					
	add.l	#25600,d1							;25600	/	29728
	move.l	d1,clearScreen1bplPointer				
	add.l	#8542,d1							;8542	/	38270
	move.l	d1,expunpack_pointer
	add.l	#8192,d1							;8192	/	46462
	move.l	d1,logunpack_pointer
	add.l	#8192,d1							;8192	/	54654
	move.l	d1,blockLocsPointer
	add.l	#2164,d1							;2164	/	56818
	move.l	d1,blockLocsPointer2
	add.l	#2164,d1							;2164	/	58982
	move.l	blockLocsPointer,a0
	move.l	#-1,(a0)
	move.l	blockLocsPointer2,a0
	move.l	#-1,(a0)										
	move.l	d1,timer_b_code_list_pointer
	add.l	#4320,d1							;4320	/	63302


	add.l	#$10000,d0
	move.l	d0,x_table_explode_pointer
	add.l	#1280,d0							;1280	/	1280
	move.l	d0,savedTable_pointer					
	add.l	#435200,d0							;435200	/	436480

NR_SINE_LOOPS equ 4

	move.l	d0,sine_xgeneric_pointer
	add.l	#((NR_SINE_LOOPS*3)+1)*4096,d0							;65536	/	502016
	move.l	d0,sine_ygeneric_pointer
	add.l	#((NR_SINE_LOOPS*3)+1)*4096,d0							;65536	/	567552
	move.l	d0,mySpacePointer
	add.l	#21200,d0							;21200	/	588752
	move.l	d0,blockPosPointer
	add.l	#5400,d0							;5400	/	606952
	move.l	d0,blockPosXoffPointer
	add.l	#1128,d0							;1128	/	608080
	move.l	d0,blockPosXPointer
	add.l	#1128,d0							;1128	/	609208
	move.l	d0,motusColorPointer
	add.l	#8000,d0							;8000	/	617208
	move.l	d0,rasterListPointerSaved			;12*200*7		16800
	add.l	#16800,d0
	add.l	#$1000,d0
	move.l	d0,explode_clear1aPointer
	move.l	d0,a0
	move.w	#-1,(a0)
	add.l	#402,d0
	move.l	d0,explode_clear1bPointer
	move.l	d0,a0
	move.w	#-1,(a0)
	add.l	#402,d0
	move.l	d0,explode_clear2aPointer
	move.l	d0,a0
	move.w	#-1,(a0)
	add.l	#402,d0
	move.l	d0,explode_clear2bPointer
	move.l	d0,a0
	move.w	#-1,(a0)
	add.l	#402,d0

	move.l	d0,smfx_blocks_pointer
	add.l	#1612,d0
	move.l	d0,atari_blocks_pointer
	add.l	#1204,d0
	move.l	d0,smfxDiagPointer
	add.l	#12800,d0							;12800	/	601552	
	move.l	d0,sinflowpointer
	add.l	#2400,d0
	move.l	d0,savescene1ptr
	add.l	#3888,d0
	move.l	d0,savescene2ptr
	add.l	#4416,d0
	move.l	d0,skillstijl1ptr
	add.l	#3480,d0
	move.l	d0,skillstijl2ptr
	add.l	#4512,d0
	move.l	d0,blockPtr
	add.l	#2342,d0

	jsr		generateTimerCode
	jsr		generateXTable


	IFEQ	PACKTOTAL
	lea		totalcrk,a0
	move.l	smfx_blocks_pointer,a1	
	jsr		cranker												;7 vbl
	move.l	atari_blocks_pointer,explode_block_pointer
	ELSE

	lea		smfxblockscrk,a0
	move.l	smfx_blocks_pointer,a1
	jsr		cranker

	lea		atariblockscrk,a0
	move.l	atari_blocks_pointer,a1
	jsr		cranker
	move.l	atari_blocks_pointer,explode_block_pointer

	lea		smfxdiagcrk,a0
	move.l	smfxDiagPointer,a1
	jsr		cranker

	lea		sinflowcrk,a0
	move.l	sinflowpointer,a1
	jsr		cranker

	lea		savescene1crk,a0
	move.l	savescene1ptr,a1
	jsr		cranker

	lea		savescene2crk,a0
	move.l	savescene2ptr,a1
	jsr		cranker

	lea		skillstijl1crk,a0
	move.l	skillstijl1ptr,a1
	jsr		cranker

	lea		skillstijl2crk,a0
	move.l	skillstijl2ptr,a1
	jsr		cranker

	ENDC

	jsr		genBlock

	move.w	#$000,$ffff8240+9*2
	move.w	#$666,$ffff8240+15*2

	move.w	#$111,$ffff8240+8*2

	jsr		init_xblock_aligned						; x mask and offsets
	jsr		init_yblock_aligned						; y offsets 

	jsr		generateVHSDrawTables			; needs a 1926*10 pointer

    move.w  #$2700,sr
    move.l  #diag_vbl,$70
    move.w  #$2300,sr


    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    rts
;--------------
;DEMOPAL - we are back fade palette
;--------------
; starts at 0, ends at the end.
logoFade
	dc.w	$666,$000
	dc.w	$666,$000
	dc.w	$666,$000
	dc.w	$555,$000
	dc.w	$545,$000
	dc.w	$445,$000
	dc.w	$345,$001
	dc.w	$345,$001
	dc.w	$344,$001
	dc.w	$344,$001
	dc.w	$334,$001
	dc.w	$334,$001
	dc.w	$234,$001
	dc.w	$234,$001
	dc.w	$223,$101
	dc.w	$223,$101
	dc.w	$123,$101
	dc.w	$123,$101
	dc.w	$122,$101
	dc.w	$122,$111
	dc.w	$112,$111
	dc.w	$112,$111
	dc.w	$111,$111



.wvbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    rte

diag_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,.myCount


	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	
	pushall

		IFNE	STANDALONE
			jsr		musicPlayer+8
;			move.l	#dummy,$110.w
		ENDC
	move.l	screenpointer2,$ffff8200


		cmp.w	#$777,moveBarsDone
		beq		.herpherp
	; DO BARS STUFF
			jsr		doBarsColors			; set colors of bars
			cmp.w	#$111,$ffff8240+2*2
			bne		.kkkk2
				move.w	#front,$ffff8240+2*2
.kkkk2
			jsr		setLogoColor			; fade logo

			jsr		doStep1					; (1) draw initial line
			jsr		doStep1					; (1) draw initial line
			jsr		doStep1					; (1) draw initial line
		
			cmp.w	#$4e75,doStep1			; if already moved in
			bne		.skip
				subq.w	#1,.www				; waiter
				tst.w	.www
				bge		.skip
				jsr		doStepStuff			; (2) unfold the lines
				jsr		copySMFX			; (3) copy in smfx
;				jsr		moveBars			; (4) move the bars
.skip
.skipBarsShit


	subq.w	#1,.xxx
	bge		.skip2	
		tst.w	cycleDots
		bne		.skipc
.herpherp
			addq.w	#3,current_nr_of_dots
			cmp.w	#100,current_nr_of_dots
			ble		.okdots
				move.w	#100,current_nr_of_dots
				move.l	#sineflower_vbl2,$70
				move.w	#$4e75,haxCols

.okdots
;			move.b	#0,$ffffc123
;			jsr		cycleDotColors
;			jmp		.ttttt
.skipc
		move.w	#2,colorOffset
		move.l	clearScreen1bplPointer,a0
		move.w	colorOffset,8(a0)				;

.ttttt
		move.l	clearScreen1bplPointer,a0
		jsr		(a0)
		jsr		drawDots
		jsr		incrementFlowerOffsets
.skip2

	tst.w	.www
	bge		.ksss
		jsr		moveBars			; (4) move the bars
		move.l	screenpointer2,a0
		add.w	#200*160,a0
		move.l	#0,-8(a0)
		move.l	#0,-4(a0)
		move.l	#0,-168(a0)
		move.l	#0,-164(a0)
.ksss

	move.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	screenpointer2,a6
	lea		160(a6),a6
	movem.l	d0-a1,-(a6)
	movem.l	d0-a1,-(a6)
	movem.l	d0-a1,-(a6)
	movem.l	d0-a1,-(a6)





			swapscreens
	popall
	rte
.www	dc.w	1
.xxx	dc.w	282
.myCount	dc.w	0
cycleDots	dc.w	-1


setLogoColor
	cmp.w	#$4e75,removeSMFX
	beq		.doTestCode
	subq.w	#1,.fff
	bge		.ok
	lea		$ffff8240+9*2,a0
	lea		$ffff8240+15*2,a2
	lea		logoFade,a1
	add.w	.fadeOff,a1
	move.w	(a1)+,(a2)
	move.w	(a1)+,(a0)

		add.w	#4,.fadeOff
		cmp.w	#20*4,.fadeOff
		ble		.ok
			move.w	#20*4,.fadeOff
			jsr		removeSMFX
.ok
	rts
.fff 	dc.w	210
.fadeOff	dc.w	0
.doTestCode
	subq.w	#1,.www
	bge		.ok
	; here the smfx is gone, we can do some other stuff, like copy the background in, for test
	subq.w	#1,.times
	blt		.ok

	move.w	#5,d0
	sub.w	.times,d0
	muls 	#20*160,d0
	move.l	sinflowpointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#40*160+80,a1
	add.w	#40*160+80,a2
	add.w	d0,a1
	add.w	d0,a2

	lsr.w	#3,d0			; we have 20 per line
	add.w	d0,a0

	move.w	#20-1,d7
.cp
.x set 0
	REPT 10
		move.w	(a0)+,d0
		or.w	d0,.x+6(a1)
		or.w	d0,.x+6(a2)
.x set .x+8
	ENDR
	add.w	#160,a1
	add.w	#160,a2
		
	dbra	d7,.cp


	rts
.times	dc.w	6
.www	dc.w	30

sinflowpointer	ds.l	1


doStepStuff
	lea		stepSequence,a0
	add.w	stepSquenceOff,a0
	lea		drawStepRoutList,a1
	move.w	(a0)+,d1
	cmp.w	#-1,d1
	beq		.quit
	move.w	(a0)+,d0
	move.w	(a0)+,d6
	move.w	(a0)+,d2
	move.l	a0,usp
	move.l	(a1,d2.w),a1
	jsr		(a1)


	move.l	usp,a0
	lea		drawStepRoutList,a1
	move.w	(a0)+,d1
	cmp.w	#-1,d1
	beq		.quit
	move.w	(a0)+,d0
	move.w	(a0)+,d6
	move.w	(a0)+,d2
	move.l	a0,usp
	move.l	(a1,d2.w),a1
	jsr		(a1)

	add.w	#8,stepSquenceOff
	rts
.quit
	move.w	#$4e75,doStepStuff
	rts

drawStepRoutList
	REPT 10
		dc.l	0
	ENDR
	dc.l	drawStep2_10
	dc.l	drawStep2_11		; 4
	dc.l	drawStep2_12		; 2
	dc.l	drawStep2_13		; 1+2
	dc.l	drawStep2_14		; 1
	dc.l	drawStep2_15		; 4+8

stepSquenceOff	dc.w	0
	
; this code is responsible for moving multiple bars
moveBars
	subq.w	#1,.waiter
	bge		.end

	move.w	#0,moveBarsDone
	lea		myDataList,a6
.loop
	subq.w	#1,(a6)+
	bge		.skipThis
		move.w	#-1,moveBarsDone
;----------- do thing
		move.l	a6,usp
		move.w	(a6)+,.herp
		move.w	(a6)+,.oldherp
		move.w	(a6)+,.olderherp
		move.w	(a6)+,.barcolorrout
		subq.w	#1,(a6)+
		bge		.ok
			; this is where the size increases
			move.w	#5,-2(a6)
			add.w	#4,(a6)
			cmp.w	#9*4,(a6)
			ble		.ok
				move.w	#9*4,(a6)
				move.w	#32000,-12(a6)
.ok
		move.w	(a6)+,.size

		move.l	screenpointer2,a0
		move.w	.olderherp,d0
		sub.w	#198,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		tst.w	(a6)+
		blt		.do8th
		cmp.w	#1,-2(a6)
		beq		.do14
		cmp.w	#3,-2(a6)
		beq		.do12
		cmp.w	#2,-2(a6)
		beq		.do13
.doNormal
			lea		tableSizes,a2
			move.l	(a2),a1
			add.w	d0,a1
			move.w	(a1)+,d1
			move.w	(a1)+,d0
			move.w	(a1)+,d6
			jsr		removeStep2
			jmp		.cont
.do14
			lea		tableSizes,a2
			move.l	(a2),a1
			add.w	d0,a1
			move.w	(a1)+,d1
			move.w	(a1)+,d0
			move.w	(a1)+,d6		
			jsr		removeStep14
			jmp		.cont
.do13
			lea		tableSizes,a2
			move.l	(a2),a1
			add.w	d0,a1
			move.w	(a1)+,d1
			move.w	(a1)+,d0
			move.w	(a1)+,d6		
			jsr		removeStep13
			jmp		.cont
.do12
			lea		tableSizes,a2
			move.l	(a2),a1
			add.w	d0,a1
			move.w	(a1)+,d1
			move.w	(a1)+,d0
			move.w	(a1)+,d6		
			jsr		removeStep12
			jmp		.cont		
.do8th
			lea		tableSizes+10*4,a2
			move.l	(a2),a1
			add.w	d0,a1
			move.w	(a1)+,d1
			move.w	(a1)+,d0
			move.w	(a1)+,d6
			jsr		removeStep
.cont

		move.w	.herp,d0
		sub.w	#198,d0
		add.w	d0,d0		;*2
		move.w	d0,d1		; save
		add.w	d0,d0		;*4
		add.w	d1,d0		;*6
		lea		tableSizes,a2
		add.w	.size,a2
		move.l	(a2),a1
		add.w	d0,a1
		move.w	(a1)+,d1
		move.w	(a1)+,d0
		move.w	(a1)+,d6
		lea		drawStepRoutList,a5
		add.w	.barcolorrout,a5
		move.l	(a5),a5
		jsr		(a5)

		move.l	usp,a5
		move.w	.oldherp,.olderherp
		move.w	.herp,.oldherp

		move.w	-16(a6),d0	;
		neg.w	d0
		add.w	d0,d0
		lea		distanceTab,a0
		move.w	(a0,d0),d0
		add.w	d0,.herp

;		add.w	#2,.herp
		move.w	.herp,(a5)+
		move.w	.oldherp,(a5)+
		move.w	.olderherp,(a5)+

		cmp.w	#$777,(a6)
		bne		.loop

;----------- do thing
.skip
.done
;	tst.w	moveBarsDone
;	bne		.end
		subq.w	#1,.bugFrames
		bge		.end
			subq.w	#1,.barsDoneWaiter
			bge		.skipd
;				move.b	#0,$fffc123
				move.w	#$777,moveBarsDone
.skipd
			move.w	#0,colorOffset
			move.l	screenpointer2,a0
			moveq	#0,d0
			move.l	d0,d1
			move.l	d0,d2
			move.l	d0,d3
			move.l	d0,d4
			move.l	d0,d5
			move.l	d0,d6
			move.l	d0,d7
			add.w	#149*160,a0
;			rts
.x set -8
			REPT 16
				movem.l	d0-d1,.x(a0)
.x set .x+160
			ENDR

.x set .x-8
			REPT 16
				movem.l	d0-d3,.x(a0)
.x set .x+160
			ENDR

.x set .x-8
			REPT 16
				movem.l	d0-d5,.x(a0)
.x set .x+160
			ENDR
.x set .x-8
			REPT 16
				movem.l	d0-d7,.x(a0)
.x set .x+160
			ENDR

.x set -8
			move.l	#1<<16+1,d0
			move.l	#1<<16,d1
			not.l	d0
.x set .x-15*160	; 134
			REPT 15
			and.l	d0,.x(a0)					;134
			and.l	d0,.x+4(a0)
			and.l	d0,.x+1*16*160-8(a0)			;150
			and.l	d0,.x+4+1*16*160-8(a0)
			and.l	d0,.x+2*16*160-16(a0)			;166
			and.l	d0,.x+4+2*16*160-16(a0)		
			and.l	d0,.x+3*16*160-24(a0)			;182
			and.l	d0,.x+4+3*16*160-24(a0)			
			and.l	d0,.x+4*16*160-32(a0)			;182
			and.l	d0,.x+4+4*16*160-32(a0)			
			add.l	d0,d0
			sub.l	d1,d0
.x set .x+160
			ENDR




.end
	rts
.skipThis
	add.w	#14,a6
	cmp.w	#$777,(a6)
	bne		.loop
	jmp		.done
	rts
.size			dc.w	0
.sizeWaiter		dc.w	0
.herp			dc.w	0
.oldherp		dc.w	0
.olderherp		dc.w	0
.barcolorrout	dc.w	0
.waiter			dc.w	80
.bugFrames		dc.w	100
.barsDoneWaiter	dc.w	85
moveBarsDone	dc.w	0




;format:
;	0;	waiter
;	2;	xposition
;	4;	xposition2
;	6;	xposition3
;	8;	color/rout/bar
;	10;	sizewaiter
;	12;	currentSize
;	14;	kind of rout

myDataList
	dc.w	10,249,248,248,10*4,66-57,0,0
	dc.w	10+21,239,238,238,11*4,68-57,0,0
	dc.w	10+63,219,218,218,12*4,72-57,0,0			;3
	dc.w	10+42,229,228,228,13*4,70-57,0,2			;2
	dc.w	10+84,209,208,208,14*4,73-57,0,1			;1
	dc.w	10+105,199,198,198,15*4,74-57,0,-1			;9
	dc.w	$777

barsList
	dc.w	$8240+6*2
	dc.w	$8240+4*2
	dc.w	$8240+2*2
	dc.w	$8240+3*2
	dc.w	$8240+1*2
	dc.w	$8240+12*2

;--------------
;DEMOPAL - bar fade colors
;--------------
; - corresponds to barsList above (color indices for the st registers)
; - each dc.w entry is the fadepalette for one bar
; - from left to fadeout (right)
;	
barsFadeList
;	dc.w	$052,$163,$274,$163,$152,$151,$141,$131,$121,$111	; green
;	dc.w	$105,$216,$327,$216,$116,$115,$114,$113,$112,$111	; blue
;	dc.w	$401,$512,$623,$512,$511,$511,$411,$311,$211,$111	; purple
;	dc.w	$602,$713,$724,$713,$612,$511,$411,$311,$211,$111	; red
;	dc.w	$731,$742,$753,$742,$631,$521,$411,$311,$211,$111	; orage
;	dc.w	$760,$771,$772,$771,$661,$551,$441,$331,$221,$111	; yellow

    dc.w	$301,$412,$523,$634,$523,$512,$412,$311,$211,$111	; purple-blue ; modmate palette ###
	dc.w	$401,$512,$623,$512,$511,$511,$411,$311,$211,$111	; purple
	dc.w	$602,$713,$724,$713,$612,$511,$411,$311,$211,$111	; red
	dc.w	$731,$742,$753,$742,$631,$521,$411,$311,$211,$111	; orage
	dc.w    $740,$751,$762,$761,$631,$521,$411,$311,$211,$111   ; +++new+++  
	dc.w	$760,$771,$772,$771,$661,$551,$441,$331,$221,$111	; yellow

doBarsColors
	lea		barsList,a0
	lea		barsFadeList,a1
	lea		myDataList,a2

	cmp.w	#$4e75,removeSMFX
	bne		.np
		move.w	#0,d2
		jmp		.cc
.np
		move.w	#-1,d2
.cc

	move.w	#6-1,d7
.ll
		move.w	(a0)+,a6			; get address
		move.w	12(a2),d0			; size
		lsr.w	d0
		move.w	(a1,d0.w),d1
		move.w	d1,(a6)
;		cmp.w	#$4e75,removeSMFX
		tst.w	d2
		bne		.skip
			move.w	d1,8*2(a6)			
			cmp.l	#$ffff8240+12*2,a6
			bne		.skip
				move.w	d1,2*2(a6)
.skip
		lea		16(a2),a2
		lea		20(a1),a1
	dbra	d7,.ll
	rts

distanceTab		include 	"data/diag/locs2.s"

tableSizes
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

generateVHSDrawTables
	move.l	mySpacePointer,a0
	lea		tableSizes,a6
	move.l	a0,(a6)+
	move.l	#%00000011111111110000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011111111100000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011111111000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011111110000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011111100000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011111000000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011110000000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011100000000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000011000000000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%00000010000000000000000000000000,d0
	jsr		genVHSTab

	move.l	a0,(a6)+
	move.l	#%11111111111111111100000000000000,d0
	jsr		genVHSTab


	rts

genVHSTab
	moveq	#0,d7
	roxr.l	d7

	moveq	#0,d1
	move.w	#104,d2

	move.l	d0,(a0)+
	ror.l	d0
	move.w	d2,(a0)+

	move.w	#144-16-4,d5
	move.w	#160,d4

	move.w	#20-1,d7
.l
	move.w	#16-1,d6
	move.l	d0,d1
.doLoop
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		subq.w	#1,d5
		bge		.kk
			move.l	d1,d0
			add.w	d4,d2
			jmp		.kk2
.kk
		ror.l	d1
.kk2

	dbra	d6,.doLoop
	tst.w	d5
	blt		.skipadd
	add.w	#8,d2
.skipadd
	dbra	d7,.l
	rts


;tables1
;	dc.w	0,%0000001000000000,96		;198 start						;6
;.off set 0
;	REPT 20
;	dc.w	%0000000100000000,0,104+.off		;199
;	dc.w	%0000000010000000,0,104+.off		;200
;	dc.w	%0000000001000000,0,104+.off		;201
;	dc.w	%0000000000100000,0,104+.off		;202
;	dc.w	%0000000000010000,0,104+.off		;203
;	dc.w	%0000000000001000,0,104+.off		;204
;	dc.w	%0000000000000100,0,104+.off		;205
;	dc.w	%0000000000000010,0,104+.off		;206
;	dc.w	%0000000000000001,0,104+.off		;207
;	dc.w	0,%1000000000000000,104+.off		;208
;	dc.w	0,%0100000000000000,104+.off		;209
;	dc.w	0,%0010000000000000,104+.off		;210
;	dc.w	0,%0001000000000000,104+.off		;211
;	dc.w	0,%0000100000000000,104+.off		;212
;	dc.w	0,%0000010000000000,104+.off		;213
;	dc.w	0,%0000001000000000,104+.off		;214			-- 16		20*16*6	= 1920 + 6 = 1926
;.off set .off+8
;	ENDR
;
;tables2
;	dc.w	0,%0000001100000000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000110000000,0,104+.off		;199
;	dc.w	%0000000011000000,0,104+.off		;200
;	dc.w	%0000000001100000,0,104+.off		;201
;	dc.w	%0000000000110000,0,104+.off		;202
;	dc.w	%0000000000011000,0,104+.off		;203
;	dc.w	%0000000000001100,0,104+.off		;204
;	dc.w	%0000000000000110,0,104+.off		;205
;	dc.w	%0000000000000011,0,104+.off		;206
;	dc.w	%0000000000000001,%1000000000000000,104+.off		;207
;	dc.w	0,%1100000000000000,104+.off		;208
;	dc.w	0,%0110000000000000,104+.off		;209
;	dc.w	0,%0011000000000000,104+.off		;210
;	dc.w	0,%0001100000000000,104+.off		;211
;	dc.w	0,%0000110000000000,104+.off		;212
;	dc.w	0,%0000011000000000,104+.off		;213
;	dc.w	0,%0000001100000000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables3
;	dc.w	0,%0000001110000000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111000000,0,104+.off		;199
;	dc.w	%0000000011100000,0,104+.off		;200
;	dc.w	%0000000001110000,0,104+.off		;201
;	dc.w	%0000000000111000,0,104+.off		;202
;	dc.w	%0000000000011100,0,104+.off		;203
;	dc.w	%0000000000001110,0,104+.off		;204
;	dc.w	%0000000000000111,0,104+.off		;205
;	dc.w	%0000000000000011,%1000000000000000,104+.off		;206
;	dc.w	%0000000000000001,%1100000000000000,104+.off		;207
;	dc.w	0,%1110000000000000,104+.off		;208
;	dc.w	0,%0111000000000000,104+.off		;209
;	dc.w	0,%0011100000000000,104+.off		;210
;	dc.w	0,%0001110000000000,104+.off		;211
;	dc.w	0,%0000111000000000,104+.off		;212
;	dc.w	0,%0000011100000000,104+.off		;213
;	dc.w	0,%0000001110000000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables4
;	dc.w	0,%0000001111000000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111100000,0,104+.off		;199
;	dc.w	%0000000011110000,0,104+.off		;200
;	dc.w	%0000000001111000,0,104+.off		;201
;	dc.w	%0000000000111100,0,104+.off		;202
;	dc.w	%0000000000011110,0,104+.off		;203
;	dc.w	%0000000000001111,0,104+.off		;204
;	dc.w	%0000000000000111,%1000000000000000,104+.off		;205
;	dc.w	%0000000000000011,%1100000000000000,104+.off		;206
;	dc.w	%0000000000000001,%1110000000000000,104+.off		;207
;	dc.w	0,%1111000000000000,104+.off		;208
;	dc.w	0,%0111100000000000,104+.off		;209
;	dc.w	0,%0011110000000000,104+.off		;210
;	dc.w	0,%0001111000000000,104+.off		;211
;	dc.w	0,%0000111100000000,104+.off		;212
;	dc.w	0,%0000011110000000,104+.off		;213
;	dc.w	0,%0000001111000000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;
;tables5
;	dc.w	0,%0000001111100000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111110000,0,104+.off		;199
;	dc.w	%0000000011111000,0,104+.off		;200
;	dc.w	%0000000001111100,0,104+.off		;201
;	dc.w	%0000000000111110,0,104+.off		;202
;	dc.w	%0000000000011111,0,104+.off		;203
;	dc.w	%0000000000001111,%1000000000000000,104+.off		;204
;	dc.w	%0000000000000111,%1100000000000000,104+.off		;205
;	dc.w	%0000000000000011,%1110000000000000,104+.off		;206
;	dc.w	%0000000000000001,%1111000000000000,104+.off		;207
;	dc.w	0,%1111100000000000,104+.off		;208
;	dc.w	0,%0111110000000000,104+.off		;209
;	dc.w	0,%0011111000000000,104+.off		;210
;	dc.w	0,%0001111100000000,104+.off		;211
;	dc.w	0,%0000111110000000,104+.off		;212
;	dc.w	0,%0000011111000000,104+.off		;213
;	dc.w	0,%0000001111100000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables6
;	dc.w	0,%0000001111110000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111111000,0,104+.off		;199
;	dc.w	%0000000011111100,0,104+.off		;200
;	dc.w	%0000000001111110,0,104+.off		;201
;	dc.w	%0000000000111111,0,104+.off		;202
;	dc.w	%0000000000011111,%1000000000000000,104+.off		;203
;	dc.w	%0000000000001111,%1100000000000000,104+.off		;204
;	dc.w	%0000000000000111,%1110000000000000,104+.off		;205
;	dc.w	%0000000000000011,%1111000000000000,104+.off		;206
;	dc.w	%0000000000000001,%1111100000000000,104+.off		;207
;	dc.w	0,%1111110000000000,104+.off		;208
;	dc.w	0,%0111111000000000,104+.off		;209
;	dc.w	0,%0011111100000000,104+.off		;210
;	dc.w	0,%0001111110000000,104+.off		;211
;	dc.w	0,%0000111111000000,104+.off		;212
;	dc.w	0,%0000011111100000,104+.off		;213
;	dc.w	0,%0000001111110000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;
;
;tables7
;	dc.w	0,%0000001111111000,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111111100,0,104+.off		;199
;	dc.w	%0000000011111110,0,104+.off		;200
;	dc.w	%0000000001111111,0,104+.off		;201
;	dc.w	%0000000000111111,%1000000000000000,104+.off		;202
;	dc.w	%0000000000011111,%1100000000000000,104+.off		;203
;	dc.w	%0000000000001111,%1110000000000000,104+.off		;204
;	dc.w	%0000000000000111,%1111000000000000,104+.off		;205
;	dc.w	%0000000000000011,%1111100000000000,104+.off		;206
;	dc.w	%0000000000000001,%1111110000000000,104+.off		;207
;	dc.w	0,%1111111000000000,104+.off		;208
;	dc.w	0,%0111111100000000,104+.off		;209
;	dc.w	0,%0011111110000000,104+.off		;210
;	dc.w	0,%0001111111000000,104+.off		;211
;	dc.w	0,%0000111111100000,104+.off		;212
;	dc.w	0,%0000011111110000,104+.off		;213
;	dc.w	0,%0000001111111000,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables8
;	dc.w	0,%0000001111111100,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111111110,0,104+.off		;199
;	dc.w	%0000000011111111,0,104+.off		;200
;	dc.w	%0000000001111111,%1000000000000000,104+.off		;201
;	dc.w	%0000000000111111,%1100000000000000,104+.off		;202
;	dc.w	%0000000000011111,%1110000000000000,104+.off		;203
;	dc.w	%0000000000001111,%1111000000000000,104+.off		;204
;	dc.w	%0000000000000111,%1111100000000000,104+.off		;205
;	dc.w	%0000000000000011,%1111110000000000,104+.off		;206
;	dc.w	%0000000000000001,%1111111000000000,104+.off		;207
;	dc.w	0,%1111111100000000,104+.off		;208
;	dc.w	0,%0111111110000000,104+.off		;209
;	dc.w	0,%0011111111000000,104+.off		;210
;	dc.w	0,%0001111111100000,104+.off		;211
;	dc.w	0,%0000111111110000,104+.off		;212
;	dc.w	0,%0000011111111000,104+.off		;213
;	dc.w	0,%0000001111111100,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables9
;	dc.w	0,%0000001111111110,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111111111,0,104+.off		;199
;	dc.w	%0000000011111111,%1000000000000000,104+.off		;200
;	dc.w	%0000000001111111,%1100000000000000,104+.off		;201
;	dc.w	%0000000000111111,%1110000000000000,104+.off		;202
;	dc.w	%0000000000011111,%1111000000000000,104+.off		;203
;	dc.w	%0000000000001111,%1111100000000000,104+.off		;204
;	dc.w	%0000000000000111,%1111110000000000,104+.off		;205
;	dc.w	%0000000000000011,%1111111000000000,104+.off		;206
;	dc.w	%0000000000000001,%1111111100000000,104+.off		;207
;	dc.w	0,%1111111110000000,104+.off		;208
;	dc.w	0,%0111111111000000,104+.off		;209
;	dc.w	0,%0011111111100000,104+.off		;210
;	dc.w	0,%0001111111110000,104+.off		;211
;	dc.w	0,%0000111111111000,104+.off		;212
;	dc.w	0,%0000011111111100,104+.off		;213
;	dc.w	0,%0000001111111110,104+.off		;214			-- 16
;.off set .off+8
;	ENDR
;
;tables10
;	dc.w	0,%0000001111111111,96		;198 start
;.off set 0
;	REPT 20
;	dc.w	%0000000111111111,%1000000000000000,104+.off		;199
;	dc.w	%0000000011111111,%1100000000000000,104+.off		;200
;	dc.w	%0000000001111111,%1110000000000000,104+.off		;201
;	dc.w	%0000000000111111,%1111000000000000,104+.off		;202
;	dc.w	%0000000000011111,%1111100000000000,104+.off		;203
;	dc.w	%0000000000001111,%1111110000000000,104+.off		;204
;	dc.w	%0000000000000111,%1111111000000000,104+.off		;205
;	dc.w	%0000000000000011,%1111111100000000,104+.off		;206
;	dc.w	%0000000000000001,%1111111110000000,104+.off		;207
;	dc.w	0,%1111111111000000,104+.off		;208
;	dc.w	0,%0111111111100000,104+.off		;209
;	dc.w	0,%0011111111110000,104+.off		;210
;	dc.w	0,%0001111111111000,104+.off		;211
;	dc.w	0,%0000111111111100,104+.off		;212
;	dc.w	0,%0000011111111110,104+.off		;213
;	dc.w	0,%0000001111111111,104+.off		;214			-- 16
;.off set .off+8
;	ENDR

stepSequence
;	dc.w	%0,0,96,15*4
	dc.w	0,%0000001100000000,96,15*4		; 198	;	2
	dc.w	0,%0000001110000000,96,15*4		; 198	;	3	
	dc.w	0,%0000001111000000,96,15*4
	dc.w	0,%0000001111100000,96,15*4
	dc.w	0,%0000001111110000,96,15*4
	dc.w	0,%0000001111111000,96,15*4
	dc.w	0,%0000001111111100,96,15*4
	dc.w	0,%0000001111111110,96,15*4
	dc.w	0,%0000001111111111,96,15*4

	dc.w	0,%1100000000000000,104,14*4
	dc.w	0,%1110000000000000,104,14*4
	dc.w	0,%1111000000000000,104,14*4
	dc.w	0,%1111100000000000,104,14*4
	dc.w	0,%1111110000000000,104,14*4
	dc.w	0,%1111111000000000,104,14*4
	dc.w	0,%1111111100000000,104,14*4
	dc.w	0,%1111111110000000,104,14*4
	dc.w	0,%1111111111000000,104,14*4

	dc.w	0,%0000000000110000,104,13*4
	dc.w	0,%0000000000111000,104,13*4
	dc.w	0,%0000000000111100,104,13*4
	dc.w	0,%0000000000111110,104,13*4
	dc.w	0,%0000000000111111,104,13*4

	dc.w	%0000000000111111,%1000000000000000,112,13*4
	dc.w	%0000000000111111,%1100000000000000,112,13*4
	dc.w	%0000000000111111,%1110000000000000,112,13*4
	dc.w	%0000000000111111,%1111000000000000,112,13*4

	dc.w	0,%0000110000000000,112,12*4
	dc.w	0,%0000111000000000,112,12*4
	dc.w	0,%0000111100000000,112,12*4
	dc.w	0,%0000111110000000,112,12*4
	dc.w	0,%0000111111000000,112,12*4
	dc.w	0,%0000111111100000,112,12*4
	dc.w	0,%0000111111110000,112,12*4
	dc.w	0,%0000111111111000,112,12*4
	dc.w	0,%0000111111111100,112,12*4

	dc.w	%0000000000000011,%0000000000000000,120,11*4
	dc.w	%0000000000000011,%1100000000000000,120,11*4
	dc.w	%0000000000000011,%1110000000000000,120,11*4
	dc.w	%0000000000000011,%1111000000000000,120,11*4
	dc.w	%0000000000000011,%1111100000000000,120,11*4
	dc.w	%0000000000000011,%1111110000000000,120,11*4
	dc.w	%0000000000000011,%1111111000000000,120,11*4
	dc.w	%0000000000000011,%1111111100000000,120,11*4

	dc.w	0,%0000000011000000,120,10*4
	dc.w	0,%0000000011100000,120,10*4
	dc.w	0,%0000000011110000,120,10*4
	dc.w	0,%0000000011111000,120,10*4
	dc.w	0,%0000000011111100,120,10*4
	dc.w	0,%0000000011111110,120,10*4
	dc.w	0,%0000000011111111,120,10*4
	dc.w	%0000000011111111,%1000000000000000,128,10*4
	dc.w	%0000000011111111,%1100000000000000,128,10*4
	dc.w	%0000000011111111,%1100000000000000,128,10*4

	dc.w	-1

removeSMFX
;	lea		smfxdiagbuffer,a0
	move.l	smfxDiagPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
;	add.w	#10*160+8,a0
	add.w	#10*160+8,a1
	add.w	#10*160+8,a2
	move.w	.offset,d0
	add.w	d0,a1
	add.w	d0,a2
	lsr.w	#1,d0
	add.w	d0,a0
	move.w	#10-1,d7
.lll
;.y set 0
;		REPT 10						;20
;			movem.l	(a0)+,d0-d6
;			move.l	(a0)+,d0
;			not.l	d0
;			and.l	d0,(a1)+
;			and.l	d0,(a2)+
;			move.l	(a0)+,d0
;			not.l	d0
;			and.l	d0,(a1)+
;			and.l	d0,(a2)+
;.y set .y+8
;		ENDR
		movem.l	(a0)+,d0-d6			;7
		not.l	d0
		not.l	d1
		not.l	d2
		not.l	d3
		not.l	d4
		not.l	d5
		not.l	d6
		and.l	d0,(a1)+
		and.l	d0,(a2)+
		and.l	d1,(a1)+
		and.l	d1,(a2)+
		and.l	d2,(a1)+
		and.l	d2,(a2)+
		and.l	d3,(a1)+
		and.l	d3,(a2)+
		and.l	d4,(a1)+
		and.l	d4,(a2)+
		and.l	d5,(a1)+
		and.l	d5,(a2)+
		and.l	d6,(a1)+
		and.l	d6,(a2)+
		movem.l	(a0)+,d0-d6			;7
		not.l	d0
		not.l	d1
		not.l	d2
		not.l	d3
		not.l	d4
		not.l	d5
		not.l	d6
		and.l	d0,(a1)+
		and.l	d0,(a2)+
		and.l	d1,(a1)+
		and.l	d1,(a2)+
		and.l	d2,(a1)+
		and.l	d2,(a2)+
		and.l	d3,(a1)+
		and.l	d3,(a2)+
		and.l	d4,(a1)+
		and.l	d4,(a2)+
		and.l	d5,(a1)+
		and.l	d5,(a2)+
		and.l	d6,(a1)+
		and.l	d6,(a2)+
		movem.l	(a0)+,d0-d5			;6
		not.l	d0
		not.l	d1
		not.l	d2
		not.l	d3
		not.l	d4
		not.l	d5
		and.l	d0,(a1)+
		and.l	d0,(a2)+
		and.l	d1,(a1)+
		and.l	d1,(a2)+
		and.l	d2,(a1)+
		and.l	d2,(a2)+
		and.l	d3,(a1)+
		and.l	d3,(a2)+
		and.l	d4,(a1)+
		and.l	d4,(a2)+
		and.l	d5,(a1)+
		and.l	d5,(a2)+

		lea		80(a1),a1
		lea		80(a2),a2
	dbra	d7,.lll

	add.w	#320*5,.offset
	cmp.w	#150*160,.offset
	ble		.skip
			move.w	#$4e75,removeSMFX
.skip
	rts
.offset dc.w	0
.waiter	dc.w	10


	IFEQ	MAKE_DIAG

prepDiag
	lea		smfxdiag+128,a0
	lea		smfxdiagbuffer,a1
	move.l	a1,a2
	add.w	#10*160+8,a0
	move.w	#160-1,d7
.cp
.x set 0
		REPT 10
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
		lea		160(a0),a0
	dbra	d7,.cp

	move.l	a2,a0
	move.b	#0,$ffffc123
	rts

smfxdiag				incbin	"gfx/diag4.neo"
	ENDC


copySMFX
	subq.w	#1,.waiter
	bge		.skip
;		lea		smfxdiag+128,a0
;		lea		smfxdiagbuffer,a0
		move.l	smfxDiagPointer,a0
		move.l	screenpointer,a1
		move.l	screenpointer2,a2
;		add.w	#10*160+8,a0
		add.w	#10*160+8,a1
		add.w	#10*160+8,a2
;		add.w	.offset,a0
		add.w	.offset,a1
		add.w	.offset,a2
		move.w	.offset,d0
		lsr.w	#1,d0
		add.w	d0,a0
		move.w	#2-1,d7
.lll
;.y set 0
;		REPT 10
;			move.l	(a0)+,d0
;			or.l	d0,(a1)+
;			or.l	d0,(a2)+
;			move.l	(a0)+,d0
;			or.l	d0,(a1)+
;			or.l	d0,(a2)+
;.y set .y+8
;		ENDR
		movem.l	(a0)+,d0-d6 ;7
		or.l	d0,(a1)+	
		or.l	d0,(a2)+	
		or.l	d1,(a1)+	
		or.l	d1,(a2)+	
		or.l	d2,(a1)+	
		or.l	d2,(a2)+	
		or.l	d3,(a1)+	
		or.l	d3,(a2)+	
		or.l	d4,(a1)+	
		or.l	d4,(a2)+	
		or.l	d5,(a1)+	
		or.l	d5,(a2)+	
		or.l	d6,(a1)+	
		or.l	d6,(a2)+	
		movem.l	(a0)+,d0-d6 ;7
		or.l	d0,(a1)+	
		or.l	d0,(a2)+	
		or.l	d1,(a1)+	
		or.l	d1,(a2)+	
		or.l	d2,(a1)+	
		or.l	d2,(a2)+	
		or.l	d3,(a1)+	
		or.l	d3,(a2)+	
		or.l	d4,(a1)+	
		or.l	d4,(a2)+	
		or.l	d5,(a1)+	
		or.l	d5,(a2)+	
		or.l	d6,(a1)+	
		or.l	d6,(a2)+	
		movem.l	(a0)+,d0-d5 ;6
		or.l	d0,(a1)+	
		or.l	d0,(a2)+	
		or.l	d1,(a1)+	
		or.l	d1,(a2)+	
		or.l	d2,(a1)+	
		or.l	d2,(a2)+	
		or.l	d3,(a1)+	
		or.l	d3,(a2)+	
		or.l	d4,(a1)+	
		or.l	d4,(a2)+	
		or.l	d5,(a1)+	
		or.l	d5,(a2)+	
		lea		80(a1),a1
		lea		80(a2),a2
		dbra	d7,.lll

		add.w	#320,.offset
		cmp.w	#150*160,.offset
		ble		.skip
			move.w	#$4e75,copySMFX
.skip
	rts
.offset dc.w	0
.waiter	dc.w	10

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


doStep1
	move.l	screenpointer,a0
	move.l	screenpointer2,a1

	move.w	.xpos,d0
	move.w	.ypos,d1

;	lea		x_table,a2
	move.l	x_block_aligned_pointer,a2
	move.l	y_block_aligned_pointer,a3
;	lea		y_table,a3

	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1

	add.w	d0,a2		
	move.w	(a2)+,d0		;offset x
	move.w	(a2)+,d3		; mask
	add.w	d1,a3
	add.w	d1,a3
	add.w	(a3),d0

	add.w	d0,a0
	add.w	d0,a1

	or.w	d3,4(a0)
	or.w	d3,6(a0)
	or.w	d3,4(a1)
	or.w	d3,6(a1)

	subq	#1,.ypos
	ble		.quit
	add.w	#1,.xpos

	rts
.quit
		move.w	#$4e75,doStep1
	rts
.xpos	dc.w	0
.ypos	dc.w	198


; first step, draw diagonal per pixel,
; start 0,200, and move topright
; second step, draw whole diagonals in 1 to x pixel width

; lets draw from top to bottom? because then we can skip the top if needed, since we intent to move to the right....
; need 10 variations, 1 to 10 pixels; we can partition into steps of 16

; lets start with 2 pixels
;	

; 5 draws: cheapest:
;	1
;	2
;	4
;	9


; 15, color 4+8 = 12
drawStep2_15
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.l	a0,a1
	move.w	d6,d5
	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0	

	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.l	d0,.y+4(a0)
		or.l	d1,.y-8+4(a0)
.y set .y+16*160-8
	ENDR
	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0	

	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.l	d0,.y+4(a0)
		or.l	d1,.y-8+4(a0)
		or.l	d2,.y-16+4(a0)
.y set .y+16*160-8										;6*4 = 24 saved, 16
	ENDR
	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2
	add.w	#160,a0

	dbra	d7,.lll2

	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 8
			move.l	d0,.y+4(a1)
.y set .y+160
		ENDR
.kk	
	rts

;14, color 1
drawStep2_14
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.l	a0,a1
	move.w	d6,d5
	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.w	d0,.y(a0)
		or.w	d1,.y-8(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.w	d0,.y(a0)
		or.w	d1,.y-8(a0)
		or.w	d2,.y-16(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	add.w	#160,a0

	dbra	d7,.lll2

	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 10
			move.w	d0,.y(a1)
.y set .y+160
		ENDR
.kk
	rts

;13 color 3 (1+2)				purple
drawStep2_13
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.l	a0,a1
	move.w	d6,d5

	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1


	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.l	d0,.y(a0)
		or.l	d1,.y-8(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1


	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.l	d0,.y(a0)
		or.l	d1,.y-8(a0)
		or.l	d2,.y-16(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	add.w	#160,a0

	dbra	d7,.lll2

	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 10
			move.l	d0,.y(a1)
.y set .y+160
		ENDR
.kk
	rts

; 12 color 2
drawStep2_12
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.w	d6,d5
	move.l	a0,a1
	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.w	d0,.y+2(a0)
		or.w	d1,.y-8+2(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.w	d0,.y+2(a0)
		or.w	d1,.y-8+2(a0)
		or.w	d2,.y-16+2(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	add.w	#160,a0

	dbra	d7,.lll2

	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 8
			move.w	d0,.y+2(a1)
.y set .y+160
		ENDR
.kk
	rts

;11 colo 4		this is blue
drawStep2_11
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.l	a0,a1
	move.w	d6,d5
	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2


	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.w	d0,.y+4(a0)
		or.w	d1,.y-8+4(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.w	d0,.y+4(a0)
		or.w	d1,.y-8+4(a0)
		or.w	d2,.y-16+4(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2


	add.w	#160,a0

	dbra	d7,.lll2


	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 10
			move.w	d0,.y+4(a1)
.y set .y+160
		ENDR
.kk

	rts

; color 6 = 2+4, this is green
drawStep2_10
	move.l	screenpointer2,a0
	add.w	d6,a0
	move.l	a0,a1
	move.w	d6,d5
	moveq	#0,d2
	roxl.w	d2
	moveq	#0,d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1


	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		or.l	d0,.y+2(a0)
		or.l	d1,.y-8+2(a0)

.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	add.w	#160,a0
	dbra	d7,.lll

	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		or.l	d0,.y+2(a0)
		or.l	d1,.y-8+2(a0)
		or.l	d2,.y-16+2(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	add.w	#160,a0

	dbra	d7,.lll2

	cmp.w	#152,d5
	ble		.kk
		moveq	#0,d0
.y set 0
		REPT 10
			move.l	d0,.y+2(a1)
.y set .y+160
		ENDR
.kk
	rts


removeStep14
	move.l	screenpointer2,a0
	add.w	d6,a0

	moveq	#-1,d2
	roxl.w	d2
	moveq	#-1,d2

	not.w	d0
	not.w	d1

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		and.w	d1,.y-8(a0)
		and.w	d0,.y(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll
	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		and.w	d2,.y-16(a0)
		and.w	d1,.y-8(a0)
		and.w	d0,.y(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0
	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll2
	rts		


removeStep12
	add.w	#2,d6
	jmp		removeStep14

removeStep13
	move.l	screenpointer2,a0
	add.w	d6,a0

	moveq	#-1,d2
	roxl.w	d2
	moveq	#-1,d2

	not.w	d0
	not.w	d1

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		and.l	d1,.y-8(a0)
		and.l	d0,.y(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll
	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		and.l	d2,.y-16(a0)
		and.l	d1,.y-8(a0)
		and.l	d0,.y(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0
	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll2
	rts		

removeStep2
	move.l	screenpointer2,a0
	add.w	d6,a0

	moveq	#-1,d2
	roxl.w	d2
	moveq	#-1,d2

	not.w	d0
	not.w	d1

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		and.l	d1,.y-8(a0)
		and.w	d1,.y-8+4(a0)
		and.l	d0,.y(a0)
		and.w	d0,.y+4(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll
	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		and.l	d2,.y-16(a0)
		and.w	d2,.y-16+4(a0)
		and.l	d1,.y-8(a0)
		and.w	d1,.y-8+4(a0)
		and.l	d0,.y(a0)
		and.w	d0,.y+4(a0)
.y set .y+16*160-8
	ENDR

	add.w	#160,a0
	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	dbra	d7,.lll2
	rts	

removeStep
	move.l	screenpointer2,a0
	add.w	d6,a0

	moveq	#-1,d2
	roxl.w	d2
	moveq	#-1,d2

	not.w	d0
	not.w	d1

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1

	move.w	#7-1,d7
.lll
.y set 0
	REPT 13
		and.l	d2,.y-16+4(a0)
		and.l	d1,.y-8+4(a0)
		and.l	d0,.y+4(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2

	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2

	add.w	#160,a0
	dbra	d7,.lll
	move.w	#9-1,d7
.lll2
.y set 0
	REPT 13
		and.l	d2,.y-16+4(a0)
		and.l	d1,.y-8+4(a0)
		and.l	d0,.y+4(a0)
.y set .y+16*160-8
	ENDR

	roxl.w	d0
	roxl.w	d1
	roxl.w	d2
	move.w	d0,d6
	swap	d0
	move.w	d6,d0
	move.w	d1,d6
	swap	d1
	move.w	d6,d1
	move.w	d2,d6
	swap	d2
	move.w	d6,d2
	add.w	#160,a0

	dbra	d7,.lll2
	rts	


	
	section DATA

	IFEQ	STANDALONE
SINEFLOWER_DISPLAY_LEFT		equ 1
SINEFLOWER_MANUAL_VALUES	equ 1
	ENDC






screenOffTable			
	dc.w	144
	dc.w	144+8*160
	dc.w	144+16*160
	dc.w	144+24*160

	dc.w	144+44*160
	dc.w	144+52*160
	dc.w	144+60*160
	dc.w	144+68*160


init_sineflower
;	move.l	screen2,d0
;	add.l	#$10000,d0
;	move.l	d0,logpointer							; 2048											; move to screenpointer
;	move.l	d0,d1
;	add.l	#2048,d1
;	move.l	d1,x_block_aligned_pointer				; 2048 offset, 1280 size						; move to screenpointer
;	add.l	#1280,d1
;	move.l	d1,y_block_aligned_pointer				; 3328 offset, 800 size							; move to screenpointer
;	add.l	#800,d1
;	move.l	d1,tableSourcePointer					; 25600											; move to screenpointer
;	add.l	#25600,d1
;	move.l	d1,clearScreen1bplPointer				; 8542											; move to screenpointer
;	add.l	#$10000,d0
;	move.l	d0,savedTable_pointer					; 409600 = 6,25 * $10000
;	add.l	#435200,d0
;	move.l	d0,sine_xgeneric_pointer
;	add.l	#40*4096,d0
;	move.l	d0,sine_ygeneric_pointer
;	add.l	#40*4096,d0
;	move.l	d0,expunpack_pointer
;	add.l	#8192,d0
;	move.l	d0,logunpack_pointer
;	add.l	#8192,d0
;	move.l	d0,mySpacePointer

	lea		log_crk,a0
	move.l	logunpack_pointer,a1
	jsr		cranker

	lea		exp_crk,a0
	move.l	expunpack_pointer,a1
	jsr		cranker

	lea		sine_xgeneric_crk,a0
	move.l	sine_xgeneric_pointer,a1
	jsr		cranker

	lea		sine_ygeneric_crk,a0
	move.l	sine_ygeneric_pointer,a1
	jsr		cranker

	lea		motusColorcrk,a0
	move.l	motusColorPointer,a1
	jsr		cranker

	; now copy values
	move.l	sine_xgeneric_pointer,a0
	jsr		copySines
	move.l	sine_ygeneric_pointer,a0
	jsr		copySines

	jsr		genBlockPossXoff
	jsr		genBlockPosX
	jsr		genBlockPos


	IFEQ	SINEFLOWER_MANUAL_VALUES
		jsr		copyNumbers
		move.w	#$555,$ffff8240+8*2
	ELSE
		move.w	#4*4,x1inc
		move.w	#20*4,x2inc
		move.w	#6*4,y1inc
		move.w	#4*4,y2inc

		move.w	#8*4,x1skip
		move.w	#6*4,x2skip
		move.w	#12*4,y1skip
		move.w	#3*4,y2skip

		move.w	#4*4*120,xoff1
		move.w	#20*4*120,xoff2
		move.w	#6*4*120,yoff1
		move.w	#4*4*120,yoff2
	ENDC

	jsr		init_exp_log							; generate log tables	3 frames
	jsr		init_dots								; 
.loopx
		jsr		calcRotMatrix
		add.l	#4,saveOffset
		cmp.l	#nr_of_partitions*4,saveOffset
	bne		.loopx

	jsr		generateClearScreenCode

.again
	jsr		moveUp
	cmp.w	#$4e75,moveUp
	bne		.again

	jsr		generateRasterValues
	jsr		precalcFadeToWhite

   	move.w	#$4e75,init_sineflower
   	move.w	#0,$466.w
    rts


copySines
	; a0 source, + dest
	move.l	a0,usp
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	add.w	#4096,a1	; parition 1
	add.l	#4096*(NR_SINE_LOOPS+1),a2
	add.l	#4096*(NR_SINE_LOOPS*2+1),a3
	move.w	#NR_SINE_LOOPS-1,d7
.do4096
		move.l	usp,a0
		move.w	#4-1,d6
.il
.off set 0
			REPT 32
				movem.l	(a0)+,d0-d5/a4/a5		; 32	4096/32= 128
				movem.l	d0-d5/a4/a5,.off(a1)	
				movem.l	d0-d5/a4/a5,.off(a2)	
				movem.l	d0-d5/a4/a5,.off(a3)
.off set .off+32
			ENDR			
			lea		.off(a1),a1
			lea		.off(a2),a2
			lea		.off(a3),a3
		dbra	d6,.il
	dbra	d7,.do4096
	rts



sineflower_vbl2
;	move.b	#0,$ffffc123
	move.w	#4,colorOffset
	move.w	#$40,colorOffset2
	move.w	#2,bitPlaneFlag
	move.l	#sineflower_vbl,$70

sineflower_vbl
    addq.w	#1,cummulativeCount
	addq.w	#1,$466.w
;	cmp.w	#2,$466.w
;	bne		.kkxx
;		move.w	#$700,$ffff8240
;		move.b	#0,$ffffc123
;.kkxx
	

    move.w  #$0,$ffff8240
	move.l	screenpointer2,$ffff8200
		    pushall
	IFNE	STANDALONE
		jsr		musicPlayer+8
	ENDC
	jsr		setTimerB



	jsr		doSineScript
	jsr		adjustVals
;	jsr		drumDots						; this does zync and move out



	jsr		cycleDotColors
	move.l	clearScreen1bplPointer,a0
	jsr		(a0)



	tst.w	motusOn
	bge		.skipp
		jsr		clearBlocks
		jsr		drawMotusLogo
		jsr		drawPlayBack

.skipp


	jsr		drawDots
	jsr		incrementFlowerOffsets

;	add.w	#$1,$ffff8240

	subq.w	#1,.vbl_till_fade
	bge		.kkk
;		move.b	#0,$ffffc123
		move.w	#32000,.vbl_till_fade
		move.w	#-1,motusFade
.kkk

	tst.w	motusFade
	blt		.remove
	cmp.w	#40,.vbl_till_fade
	bge		.kkkx
;	tst.w	motusFade
;	bge		.kkkx
.remove
		jsr		removeDots
.kkkx

;	IFEQ	SHOW_CPU
;		add.w	#$040,$ffff8240
;s	ENDC
		    swapscreens
	    	popall
	rte
.vbl_till_fade	dc.w	1250-31

rasterListPointerSaved	dc.l	0	
rasterListPointerOff	dc.l	0

setTimerB
	tst.w	motusOn
	beq		.normal
	bgt		.text
		tst.w	motusFade
		bne		.doMotusFade
			clr.b	$fffffa1b.w				;Timer B control (stop)
			bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
			bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
			move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
			move.l	#timer_b_multicol_init,$120.w
			bclr	#3,$fffffa17.w			;Automatic end of interrupt
			move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
			move.w	currentRainColor,$ffff8240+8*2
			move.w	#$0,$ffff8240+15*2
			jmp		.tbset
.doMotusFade
	tst.w	.motusFadeDone
	bne		.normal
			move.l	rasterListPointerSaved,rasterListPointerX
			add.l	#12*2,rasterListPointerX
			move.l	rasterListPointerOff,d0
			add.l	d0,rasterListPointerX


			clr.b	$fffffa1b.w				;Timer B control (stop)
			bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
			bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
			move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
			move.l	#timer_b_multicol_start2_top,$120.w
			bclr	#3,$fffffa17.w			;Automatic end of interrupt
			move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		
			move.w	#197,timesTilEnd


			subq.w	#1,.ccount
			bge		.kk
				move.w	#4,.ccount
				add.l	#200*12,rasterListPointerOff
				cmp.l	#200*12*7,rasterListPointerOff
				ble		.kk
					move.l	#200*12*7,rasterListPointerOff
					move.w	#-1,.motusFadeDone
.kk	
			jmp		.tbset

.text
		clr.b	$fffffa1b.w				;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		cmp.w	#2,motusOn
		beq		.text2
.text1
			move.l	#timer_b_atari_text_init,$120.w
			jmp		.cc
.text2
			move.l	#timer_b_smfx_text_init,$120.w
.cc
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))		

		move.w	#$777,$ffff8240+8*2

		jmp		.tbset
.normal
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_open_curtain,$120.w
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w	
.tbset
	rts
.ccount			dc.w	10
.motusFadeDone	dc.w	0	
motusFade		dc.w	0
poetryPalOff	dc.w	0
timesTilEnd		dc.w	0

timer_b_multicol_start2_top
	move.w	#$111,$ffff8240
	move.l	#timer_b_multicol_start2,$120.w
	rte

rasterListPointerX		dc.l	0	


timer_b_multicol_start2
	pusha0	
		move.l	rasterListPointerX,a0
		move.l	(a0)+,$ffff8240+9*2			;24
		move.l	(a0)+,$ffff8240+11*2	;11-12
		move.l	(a0)+,$ffff8240+13*2	;13-14
		move.l	a0,rasterListPointerX
	popa0
	subq.w	#1,timesTilEnd
	bge		.kk
		move.l	#timer_b_multicol_end,$120.w
.kk
	rte


timer_b_atari_text_init
	move.w	#$111,$ffff8240
	move.l	#$1110111,$ffff8240+9*2		;+2
	move.l	#$1110111,$ffff8240+11*2	;+6
	move.l	#$1110111,$ffff8240+13*2	;+10
	move.w	#$111,$ffff8240+15*2
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#91,$fffffa21
	move.l	#timer_b_text2,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_text2
	move.l	#$1110111,$ffff8240+9*2		;+2
	move.l	#$1110111,$ffff8240+11*2	;+6
	move.l	#$1110111,$ffff8240+13*2	;+10
	move.w	#$111,$ffff8240+15*2

	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#27,$fffffa21
	move.l	#timer_b_text3,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_text3
	move.l	#$1110111,$ffff8240+9*2
	move.l	#$1110111,$ffff8240+11*2
	move.l	#$1110111,$ffff8240+13*2
	move.w	#$111,$ffff8240+15*2
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#81,$fffffa21
	move.l	#timer_b_multicol_end,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_smfx_text_init
	move.w	#$111,$ffff8240
	move.l	#$1110111,$ffff8240+9*2		;+2
	move.l	#$1110111,$ffff8240+11*2	;+6
	move.l	#$1110111,$ffff8240+13*2	;+10
	move.w	#$111,$ffff8240+15*2
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#82,$fffffa21
	move.l	#timer_b_text4,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_text4
	move.l	#$1110111,$ffff8240+9*2		;+2
	move.l	#$1110111,$ffff8240+11*2	;+6
	move.l	#$1110111,$ffff8240+13*2	;+10
	move.w	#$111,$ffff8240+15*2

	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#26,$fffffa21
	move.l	#timer_b_text5,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_text5
	move.l	#$1110111,$ffff8240+9*2
	move.l	#$1110111,$ffff8240+11*2
	move.l	#$1110111,$ffff8240+13*2
	move.w	#$111,$ffff8240+15*2

	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#91,$fffffa21
	move.l	#timer_b_multicol_end,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_multicol_endjump
	move.b	#0,$fffffa1b ; Timer B Control=off
	move.b	#8,$fffffa21
	move.l	#timer_b_multicol_end,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b ; Timer B Control=Event mode		
	rte

timer_b_multicol_end
	move.w	#$0,$ffff8240
	rte

timer_b_multicol_init
	move.w	#$111,$ffff8240
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#1+13,$fffffa21
	move.l	#timer_b_multicol_start,$120.w
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte

timer_b_multicol_start
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.b	#1,$fffffa21
	move.l	timer_b_code_list_pointer,$120
	move.b	#8,$fffffa1b ; Timer B Control=Event mode	
	rte	

timer_b_code_list_pointer	dc.l	0
;timer_b_code_list		ds.l	2000
timer_b_address_list_pointer	dc.l	0
;timer_b_address_list	ds.l	210



precalcFadeToWhite
	move.l	rasterListPointerSaved,a0		; source
	lea		200*12(a0),a1				; dest

	move.w	#$700,d6
	move.w	#$070,d5
	move.w	#$007,d4
	move.w	#$100,a6
	move.w	#$010,a5
	move.w	#$001,a4

	move.w	#7-1,d7
.doFadeStep
		move.w	#6*200-1,d3
.doReg
		move.w	(a0)+,d0		; current value

		move.w	d0,d1			; tmp
		add.w	a6,d1			;
		and.w	d6,d1			; $x00
		bne		.k1
			move.w	d6,d1
.k1
	
		move.w	d0,d2
		add.w	a5,d2
		and.w	d5,d2
		bne		.k2
			move.w	d5,d2
.k2
		add.w	d2,d1
	
		move.w	d0,d2
		add.w	a4,d2
		and.w	d4,d2
		bne		.k3
			move.w	d4,d2
.k3
		add.w	d2,d1			; dest
	
		move.w	d1,(a1)+
		dbra	d3,.doReg


	dbra	d7,.doFadeStep
	rts


drawMotusLogo
	subq.w	#1,.waiter
	bge		.no

	tst.w	.drawOff
	bne		.skipDraw
	move.l	motusColorPointer,a0
	move.l	screenpointer2,a1
;	move.l	screenpointer,a2
	move.w	.offset,d0
	add.w	d0,a1
;	add.w	d0,a2
	lsr.w	#2,d0
	add.w	d0,a0

.y set 0
	REPT 3
		movem.l	(a0)+,d0-d7/a3/a4
		movem.l	d0-d7/a3/a4,(a1)
;		movem.l	d0-d7/a3/a4,(a2)
		lea		160(a1),a1
;		lea		160(a2),a2
	ENDR
.skipDraw
	add.l	#$0000a900,.frac
	tst.w	.frac
	beq		.no
		move.w	#0,.frac
		sub.w	#160,.offset
		bge		.kkk
			move.w	#-1,.drawOff
.kkk
		sub.w	#1,.colorCounter
		bne		.no
			move.w	#4,.colorCounter
			add.w	#2,rainColorsOffset
			cmp.w	#43*2*2,rainColorsOffset
			ble		.okcol
				move.w	#43*2,rainColorsOffset
				move.w	#$4e75,clearBlocks
				move.w	#$4e75,drawMotusLogo
.okcol
			lea		rainColors,a0
			add.w	rainColorsOffset,a0
			move.w	(a0),d0
			move.w	d0,currentRainColor
.no
	rts
.drawOff	dc.w	0
.frac		dc.l	0
.waiter		dc.w	20
.offset		dc.w	196*160
.flipper	dc.w	1
.colorCounter	dc.w	3



currentRainColor	dc.w	$334
rainColorsOffset	dc.w	0

;--------------
;DEMOPAL - list of colors that the rain takes when building the `motus' logo
;--------------
; - starts from 0, and goes to end
rainColors
	dc.w	$334		;0
	dc.w	$445		;1
	dc.w	$445		;2
	dc.w	$455		;3
	dc.w	$455		;4
	dc.w	$355		;5
	dc.w	$343		;6
	dc.w	$344		;7
	dc.w	$340		;8
	dc.w	$341		;9
	dc.w	$340		;10

	dc.w	$450		;11
	dc.w	$450		;12
	dc.w	$450		;13
	dc.w	$540		;14
	dc.w	$542		;15
	dc.w	$532		;16
	dc.w	$643		;17
	dc.w	$630		;18
	dc.w	$643		;19
	dc.w	$740		;20

	dc.w	$522		;21
	dc.w	$520		;22
	dc.w	$630		;23
	dc.w	$523		;24
	dc.w	$522		;25
	dc.w	$534		;26
	dc.w	$533		;27
	dc.w	$534		;28
	dc.w	$535		;29
	dc.w	$436		;30

	dc.w	$545		;31
	dc.w	$656		;32
	dc.w	$445		;33
	dc.w	$444		;34
	dc.w	$434		;35
	dc.w	$433		;36
	dc.w	$433		;37
	dc.w	$434		;38
	dc.w	$421		;39
	dc.w	$432		;40

	dc.w	$422		;41
	dc.w	$420		;42
	dc.w	$411		;43
	dc.w	$322		
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322
	dc.w	$322




NR_BLOCK_ROWS EQU 45

moveUp
	move.l	screenpointer2,a0
	move.l	blockPosPointer,a1
;	lea		blockPos,a1
	lea		speeds,a2
	moveq	#0,d5
	move.w	#4,d6
	move.w	#NR_BLOCK_ROWS*12-1,d7					; number of blocks to fix
.checkBlock
	move.w	(a1)+,d0					; active? 0 = inactive, so activate, -1 is done, only increase vbl counter, 1 is active, so make it move and check if out of bound
	beq		.doActivate
	blt		.isDone
.isActive
		moveq	#-1,d5
		move.w	(a1),d0					; speedoff
		move.w	(a2,d0.w),d0			; speedoff -> yoff
		addq.w	#2,(a1)+				; increase speedoff
		sub.w	d0,(a1)+				; decrease yoff
		bge		.notneg					; if >= 0, still visible
			move.w	#-1,-6(a1)			; mark block done
.notneg
		add.w	#4,a1					; skip mask,vbl
		dbra	d7,.checkBlock
	tst.w	d5
	blt		.okf
		jmp		.resetStuff
.okf
	rts

.isDone	; increase vbl, gotoloop
		add.w	#6,a1					; skip speedoff,ypos,mask
		addq.w	#1,(a1)+				; add 1 to vblwait
	dbra	d7,.checkBlock				; next!
	tst.w	d5
	blt		.oke
		jmp		.resetStuff
.oke
	rts
.doActivate	; activate, move, and end loop
	moveq	#-1,d5
	move.w	#1,-2(a1)					; set active = 1, so we know in future
	add.w	d6,(a1)
	move.w	(a1),d0						; speedoff
	move.w	(a2,d0.w),d0				; get current speed
	addq.w	#2,(a1)+					; increase speedoff, for next time
	sub.w	d0,(a1)+					; decrease the ypos
	add.w	#4,a1						; skip mask,vbl
	subq.w	#4,d6
	bge		.checkBlock
	rts
.activates	dc.w	0
.resetStuff
;	lea		blockPos,a0
	move.l	blockPosPointer,a0
	move.l	blockPosXoffPointer,a2
	add.w	#NR_BLOCK_ROWS*12*2,a2
	move.l	blockPosXPointer,a3
	add.w	#NR_BLOCK_ROWS*12*2,a3

	move.w	#NR_BLOCK_ROWS*12-1,d7
	moveq	#0,d4
	move.w	#NR_BLOCK_ROWS*4-1,d5				; first
	move.w	#0,d4
	move.w	#200,d6
.llll
	;0; active,	2; speedoff, 4: ypos	6: vbl
	move.w	#0,(a0)				; reset active
	sub.w	#2,2(a0)			; remove 1 speed
	move.w	-(a2),d0			; get xoff
	add.w	d0,4(a0)			; add xoff to yoff
	move.w	-(a3),d0
	move.w	d0,6(a0)

	sub.w	d6,8(a0)		; adjust

	lea		10(a0),a0
	addq.w	#1,d4

	cmp.w	#NR_BLOCK_ROWS*10,d7
	bge		.s1
		move.w	#156,d6							;39
.s1
	cmp.w	#NR_BLOCK_ROWS*8,d7
	bge		.s2
		move.w	#112,d6							;28
.s2
	cmp.w	#NR_BLOCK_ROWS*6,d7
	bge		.s3
		move.w	#68,d6							;17
.s3
	cmp.w	#NR_BLOCK_ROWS*4,d7
	bge		.s4
		move.w	#0,d6
.s4

	dbra	d7,.llll
	move.w	#$4e75,moveUp
	rts		

drawPlayBack
	cmp.w	#$4e75,moveUp
	bne		.end

	addq.w	#1,.frames

	move.l	screenpointer2,d7
	move.l	blockPosPointer,a0
	add.w	#NR_BLOCK_ROWS*12*10,a0
	lea		speeds,a3
	move.l	blockLocsPointer2,a4
	moveq	#0,d3
	moveq	#-1,d4

	moveq	#0,d0
	moveq	#0,d1

	move.w	.endCounter,d5
	cmp.w	#NR_BLOCK_ROWS*2,d5
	ble		.z1
		move.w	#NR_BLOCK_ROWS*2,d0
.z1
	cmp.w	#NR_BLOCK_ROWS*4,d5
	ble		.z2
		move.w	#NR_BLOCK_ROWS*4,d0
.z2
	cmp.w	#NR_BLOCK_ROWS*6,d5
	ble		.z3
		move.w	#NR_BLOCK_ROWS*6,d0
.z3
	cmp.w	#NR_BLOCK_ROWS*8,d5
	ble		.z4
		move.w	#NR_BLOCK_ROWS*8,d0
.z4


	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d0
	sub.w	d0,a0
;
;
;	cmp.w	#44*2,d5
;	blt		.k1
;		moveq	#0,d0
;		move.w	.frames,d0
;.zz
;		move.b	#0,$ffffc123
;		move.w	#$4e71,.zz
;		move.w	#$4e71,.zz+2
;		move.w	#$4e71,.zz+4
;.k1
;
;	cmp.w	#44*4,d5
;	blt		.k2
;		moveq	#0,d0
;		move.w	.frames,d0
;.t
;		move.b	#0,$ffffc123
;		move.w	#$4e71,.t
;		move.w	#$4e71,.t+2
;		move.w	#$4e71,.t+4
;.k2
;
;	cmp.w	#44*6,d5
;	blt		.k3
;		moveq	#0,d0
;		move.w	.frames,d0
;.t2
;		move.b	#0,$ffffc123
;		move.w	#$4e71,.t2
;		move.w	#$4e71,.t2+2
;		move.w	#$4e71,.t2+4
;.k3
;
;	cmp.w	#44*8,d5
;	blt		.k4
;		moveq	#0,d0
;		move.w	.frames,d0
;.t3
;		move.b	#0,$ffffc123
;		move.w	#$4e71,.t3
;		move.w	#$4e71,.t3+2
;		move.w	#$4e71,.t3+4
;.k4
;
;	cmp.w	#44*10,d5
;	blt		.k5
;		moveq	#0,d0
;		move.w	.frames,d0
;.t4
;		move.b	#0,$ffffc123
;		move.w	#$4e71,.t4
;		move.w	#$4e71,.t4+2
;		move.w	#$4e71,.t4+4
;.k5



;	move.w	#43*12-1-43*4-1,d6
	move.w	#4-1,d6
	move.l	blockPtr,a1
.herp
; assumes dataset:
;	active,speedOffset,yposition,mask,vblwait
;	a0; dataset
;	a3; speed change table
;	a4; offsets for clearing
;	d7; aligned highword to screen
;doBlock macro
;.checkNext\@
;	tst.w	(a0)+				; have we died?
;	blt		.skip\@				; 	if we have, skip alltogether
;		subq.w	#1,6(a0)		; if we are active, reduce vblwaiter 
;		bge		.skip\@			;	if vblwaiter >= 0, wait some more
;	move.w	(a0),d0				; get speedoff
;	subq.w	#2,(a0)+			; reduce speedoff with 1 step
;	bge		.ok\@				; 	if we have no steps left, terminate
;		move.w	d4,-4(a0)		; die
;		addq.w	#1,d5			; add +1 to bodycount for moving window
;.ok\@
;	move.w	(a3,d0.w),d0		; speedoff -> delta y
;	add.w	d0,(a0)				; add delta y to current y
;	move.w	(a0)+,d7			; get current y+x to aligned ptr
;	move.w	(a0)+,d0			; get mask
;	move.l	d7,a6				; use aligned ptr as screenpointer
;	move.w	a6,(a4)+			; save lower word for clear code
;	or.w	d0,(a6)				; draw 
;	or.w	d0,160(a6)			; draw 
;	or.w	d0,320(a6)			; draw
;	lea		-6(a0),a0			; we need to do total of -18, but branching above, -12 left
;.skip\@
;	sub.w	#12,a0				; we need to do -12
;.next\@
;	endm
;
;	REPT NR_BLOCK_ROWS			;52*45 =  2340
;		doBlock
;	ENDR
		jsr		(a1)
	dbra	d6,.herp
	move.w	d5,.endCounter
	move.l	#-1,(a4)+
.end
	rts
.endCounter	dc.w	0
.frames		dc.w	0

blockPtr	ds.l	1			;2340

genBlock
;	lea		.next,a5
;	sub.l	#.code,a5			;52

	move.l	blockPtr,a0
	lea		.code,a6
	movem.l	.code,d0-d6/a1/a2/a3/a4/a5/a6		;52!
	move.w	#NR_BLOCK_ROWS-1,d7
.cp	
		movem.l	d0-d6/a1-a6,(a0)
		lea		52(a0),a0
	dbra	d7,.cp
	move.w	#$4e75,(a0)+
	rts




.code
.checkNext
	tst.w	(a0)+				; have we died?
	blt		.skip				; 	if we have, skip alltogether
		subq.w	#1,6(a0)		; if we are active, reduce vblwaiter 
		bge		.skip			;	if vblwaiter >= 0, wait some more
	move.w	(a0),d0				; get speedoff
	subq.w	#2,(a0)+			; reduce speedoff with 1 step
	bge		.ok				; 	if we have no steps left, terminate
		move.w	d4,-4(a0)		; die
		addq.w	#1,d5			; add +1 to bodycount for moving window
.ok
	move.w	(a3,d0.w),d0		; speedoff -> delta y
	add.w	d0,(a0)				; add delta y to current y
	move.w	(a0)+,d7			; get current y+x to aligned ptr
	move.w	(a0)+,d0			; get mask
	move.l	d7,a6				; use aligned ptr as screenpointer
	move.w	a6,(a4)+			; save lower word for clear code
	or.w	d0,(a6)				; draw 
	or.w	d0,160(a6)			; draw 
	or.w	d0,320(a6)			; draw
	lea		-6(a0),a0			; we need to do total of -18, but branching above, -12 left
.skip
	sub.w	#12,a0				; we need to do -12
.next







clearBlocks
	move.l	blockLocsPointer,a0
	move.l	screenpointer2,d0
	move.w	#0,d1
.next
	REPT 20
		move.w	(a0)+,d0
		blt		.end
			move.l	d0,a1
			move.w	d1,(a1)
			move.w	d1,160(a1)
			move.w	d1,320(a1)
	ENDR
		jmp		.next
.end
	move.l	blockLocsPointer,d0
	move.l	blockLocsPointer2,blockLocsPointer
	move.l	d0,blockLocsPointer2
	rts



; definition: 
;		active,speedoff,.yposition,mask,vblwait outside screen
;			

; 2164



blockLocsPointer	dc.l	0
blockLocsPointer2	dc.l	0


;blockLocs	dc.l	-1								;2 * 45 * 12 * 4 = 4320
;			ds.l	NR_BLOCK_ROWS*12
;blockLocs2	dc.l	-1
;			ds.l	NR_BLOCK_ROWS*12

genBlockPossXoff
	move.l	blockPosXoffPointer,a0
	move.l	#14<<16+14,d0
	move.l	#8<<16+8,d1

	move.w	#(NR_BLOCK_ROWS+2)/2-1,d7
.l
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		add.l	d1,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		add.l	d1,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		sub.l	d1,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		sub.l	d1,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	dbra	d7,.l
	rts
blockPosXoffPointer	dc.l	0

;blockPosXoff										; 47 * 12 * 2 = 1128 
;.x set 8+6
;	REPT (NR_BLOCK_ROWS+2)/2
;	REPT 3
;		dc.w	.x
;		dc.w	.x
;		dc.w	.x
;		dc.w	.x
;.x set .x+8
;	ENDR
;	REPT 3
;.x set .x-8
;		dc.w	.x
;		dc.w	.x
;		dc.w	.x
;		dc.w	.x
;	ENDR
;	ENDR
blockPosXPointer		dc.l	0

genBlockPosX
	move.l	blockPosXPointer,a0
	move.l	#%11100000000000000000111000000000,d0		;b1/b2
	move.l	#%00000000111000000000000000001110,d1		;b3/b4
	move.w	#(NR_BLOCK_ROWS+2)/2-1,d7
.l
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+

		swap	d1
		swap	d0

		move.l	d1,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d0,(a0)+

		swap	d1
		swap	d0

	dbra	d7,.l
	rts

b1	equ	%1110000000000000
b2	equ	%0000111000000000
b3	equ %0000000011100000
b4	equ %0000000000001110


;blockPosX											; 47 * 12 * 2 = 1128 
;	REPT (NR_BLOCK_ROWS+2)/2
;		REPT 3
;			dc.w	b1
;			dc.w	b2
;			dc.w	b3
;			dc.w	b4
;		ENDR
;		REPT 3
;			dc.w	b4
;			dc.w	b3
;			dc.w	b2
;			dc.w	b1
;		ENDR
;	ENDR

blockPosPointer	dc.l	0
genBlockPos
	move.l	blockPosPointer,a0
	move.w	#8*160,d0					;y
	move.w	#4*160,d1
	moveq	#0,d2
	move.w	#NR_BLOCK_ROWS-1,d7
.l
	REPT 12
		move.l	d2,(a0)+
		move.w	d0,(a0)+
		move.l	d2,(a0)+
	ENDR
	add.w	d1,d0
	dbra	d7,.l
	rts

;blockPos
;.ypos 	set	8
;	REPT NR_BLOCK_ROWS								;45*12*10	= 5400, use pointer
;		REPT 12
;			dc.w	0,0,.ypos*160,0,0
;		ENDR
;.ypos set .ypos+4
;	ENDR

; disposition
speeds
	dc.w	160*1
	dc.w	160*2
	dc.w	160*2
	dc.w	160*3
	dc.w	160*3
	dc.w	160*4
	dc.w	160*5
	dc.w	160*5
	dc.w	160*6
	dc.w	160*6
	dc.w	160*7
	dc.w	160*8
	dc.w	160*9
	dc.w	160*10
	dc.w	160*11
	dc.w	160*12
	dc.w	160*13
	dc.w	160*14
	dc.w	160*15
	dc.w	160*16
	dc.w	160*17
	dc.w	160*18
	dc.w	160*19


checkAndAdjustVal	macro
			cmp.w	(a0)+,\1		
			beq		.skip_\@
			bgt		.decrease_\@
.increase_\@
			addq.w	#4,\2
			moveq	#1,d7
			jmp		.skip_\@
.decrease_\@
			subq.w	#4,\2
			moveq	#1,d7
.skip_\@

	endm


checkAndAdjustVal2	macro
			move.w	(a0),changedDotsVals+\3
			cmp.w	(a0)+,\1		
			beq		.skip_\@
			bgt		.decrease_\@
.increase_\@
			addq.w	#8,changedDotsVals+\3
			moveq	#1,d7
			jmp		.skip_\@
.decrease_\@
			subq.w	#8,changedDotsVals+\3
			bge		.kkk\@
				move.w	#0,changedDotsVals+\3
.kkk\@
			moveq	#1,d7
.skip_\@
			cmp.w	#100,changedDots
			bne		.end\@
				move.w	changedDotsVals+\3,\2
.end\@
	endm

adjustVals
;	rts
	lea		valsList,a0
	add.w	valsoff,a0
	move.w	#0,d7				; alldone?

			subq.w	#1,.w2
			bge		.skipinc
			movem.w	x1inc,d0-d3		; all incs
					checkAndAdjustVal	d0,x1inc
					checkAndAdjustVal	d1,x2inc
					checkAndAdjustVal	d2,y1inc
					checkAndAdjustVal	d3,y2inc
.skipinc

			movem.w	x1skip,d0-d3
					checkAndAdjustVal2	d0,x1skip,0
					checkAndAdjustVal2	d1,x2skip,2
					checkAndAdjustVal2	d2,y1skip,4
					checkAndAdjustVal2	d3,y2skip,6

			subq.w	#1,.waiter
			bge		.end
			add.w	#2,changedDots
			cmp.w	#100,changedDots
			ble		.kkk
				move.w	#4,.w2
				move.w	#0,changedDots
				add.w	#16,valsoff
				move.w	#100,.waiter
				cmp.w	#19*16,valsoff
				ble		.kkk
;					move.b	#0,$ffffc123
					nop
					move.w	#0,valsoff
.kkk
.end
	rts
.waiter	dc.w	100
.w2		dc.w	5


valsoff	dc.w	0

valsList															; change this here modmate, all values *4
	; x1inc, x2inc, y1inc, y2inc, x1skip, x2skip, y1skip, y2skip
	dc.w	3*4,13*4,14*4,10*4,13*4,10*4,6*4,16*4	;0
	dc.w 15*4,08*4,05*4,08*4,13*4,11*4,04*4,04*4	;1
	dc.w 04*4,06*4,14*4,01*4,07*4,05*4,17*4,16*4	;2
	dc.w	13*4,11*4,16*4,15*4,6*4,8*4,24*4,16*4	;3
	dc.w 09*4,06*4,07*4,19*4,07*4,05*4,17*4,22*4	;4
	dc.w 03*4,07*4,06*4,07*4,10*4,04*4,15*4,04*4	;5
	dc.w	13*4,17*4,16*4,20*4,6*4,6*4,17*4,16*4	;6
	dc.w 04*4,13*4,15*4,01*4,14*4,04*4,02*4,09*4	;7
	dc.w 12*4,08*4,05*4,03*4,05*4,06*4,07*4,15*4	;8
	dc.w 05*4,07*4,15*4,07*4,06*4,08*4,05*4,06*4	;9

	dc.w	9*4,17*4,8*4,16*4,7*4,10*4,14*4,11*4	;10
	dc.w 05*4,08*4,05*4,08*4,13*4,11*4,04*4,04*4	;11
	dc.w 04*4,06*4,04*4,01*4,07*4,05*4,07*4,16*4	;12
	dc.w	13*4,11*4,16*4,15*4,6*4,8*4,24*4,16*4	;13
	dc.w 09*4,06*4,07*4,09*4,07*4,05*4,07*4,22*4	;14
	dc.w 03*4,07*4,06*4,07*4,10*4,04*4,15*4,04*4	;15
	dc.w	13*4,17*4,16*4,20*4,6*4,6*4,17*4,16*4	;16
	dc.w 04*4,13*4,05*4,01*4,04*4,04*4,02*4,09*4	;17
	dc.w 12*4,08*4,05*4,00*4,00*4,06*4,07*4,10*4	;18
	dc.w 05*4,07*4,15*4,04*4,06*4,08*4,05*4,06*4	;19


; sinecurves on dots?

removeDots
	subq.w	#1,.waiter
	bge		.skip
		sub.w	#2,current_nr_of_dots
		bge		.skip
			move.w	#0,current_nr_of_dots
.skip
	rts
.waiter	dc.w	15

drumDots
	subq.w	#1,.waiter
	bge		.skip

.doAdjust
	tst.w	.direction
	beq		.skip
	bgt		.increase
.decrease
		sub.w	#5,current_nr_of_dots
		bge		.skip
			move.w	#0,current_nr_of_dots
			move.w	#1,.direction
			move.w	#30+70,.waiter
			rts
.increase
		add.w	#5,current_nr_of_dots
;		move.w	#100,current_nr_of_dots
		cmp.w	#100,current_nr_of_dots
		blt		.skip
			move.w	#100,current_nr_of_dots
			move.w	#-1,.direction
			subq.w	#1,.waiter2
			blt		.herp
			move.w	#60,.waiter
			jmp		.skip
.herp
			move.w	#32000,.waiter

.skip
	rts
.direction	dc.w	-1
.waiter		dc.w	470
.waiter2	dc.w	1


doWait
	rts
; script
; nr_of_vbl,textRout,fadeRoutOff,fadeOffsetStart
sineScript
	; routs:
	;	-1 = nothing
	;	0 = drawSavingTheScenePoetry
	;	4 = drawAtari
	;	8 = clearArea,drawAtari
	dc.l	89,doWait								; wait original1												90
	dc.l	3,drawSavingTheScenePoetry				; draw Poetry 1 original3										93
	dc.l	54,doPoetryTextFadeIn 					; fade in text and wait	 	; 10 seconds! original429			147
	dc.l	2,drawAtari 							; draw atari		;											149
	dc.l	28,doWait								; wait original38												179
	dc.l	10,doPoetryTextFadeOut					; fade out text													189
	dc.l	35,clearAreaDrawAtariExplode			; replace area with only atari, and explode

	dc.l	69,doWait								; wait original8												70
	dc.l	3,drawSkillAndStijl						; draw Poetry 1													73
	dc.l	54-4-4-4,doPoetryTextFadeIn					; fade in text and wait											127
	dc.l	6,drawSMFX								; draw atari													129
	dc.l	30-5,doWait								; wait															
	dc.l	10,doPoetryTextFadeOut					; fade out text 1a/1b			; 278 = 5.5 seconds
	dc.l	35,clearAreaDrawAtariExplode			; replace area with only atari, (but broken)

    dc.l    64+60-8,doWait
	dc.l	2,doMotusText
	dc.l	32000,doWait,-1,-1


sineScriptOff	dc.w	0


sineFadeList
	dc.l	doPoetryTextFadeIn
	dc.l	doPoetryTextFadeOut


doSineScript
	lea		sineScript,a6
	add.w	sineScriptOff,a6
	subq.l	#1,(a6)+
	bgt		.sameScript
.nextScript
	add.w	#8,sineScriptOff
.sameScript
	; now do textRout
	move.l	(a6)+,a0
	pusha6
	jsr		(a0)
	popa6
	rts

.noTextRout
	move.l	(a6)+,d0
	blt		.noFadeRout
	lea		sineFadeList,a0
	add.l	d0,a0
	move.l	(a0),a0
	jsr		(a0)
.noFadeRout
	add.w	#4,a6
	rts

doPoetryTextFadeIn
	subq.w	#1,textWaiterIn
	bge		.skip
		move.w	#2,textWaiterIn
		add.w	#14,poetryPalOff
		cmp.w	#84,poetryPalOff
		ble		.skip
			move.w	#84,poetryPalOff
.skip

	jsr		setPoetryPals

	rts
textWaiterIn		dc.w	2

doPoetryTextFadeOut
	subq.w	#1,textWaiterOut
	bge		.skip
		move.w	#2,textWaiterOut
		sub.w	#14,poetryPalOff
		bge		.skip
			move.w	#0,poetryPalOff
.skip
	
	jsr		setPoetryPals
	move.w	#2,textWaiterIn
	move.w	#2,clearAreaDrawAtariExplodeTwice
	rts
textWaiterOut	dc.w	2


;--------------
;DEMOPAL - scene poetry text colors                  ; modmate ###
;--------------
poetryAtariText1Pal1			; atari top         ; saving
	dc.w	$111,$111,$111,$111,$111,$111,$111		;0
	dc.w	$111,$111,$111,$111,$211,$222,$111		;14
	dc.w	$111,$111,$111,$111,$311,$333,$111		;28
	dc.w	$111,$111,$211,$311,$421,$444,$111		;42
	dc.w	$111,$111,$311,$411,$531,$555,$000		;56
	dc.w	$101,$211,$412,$521,$641,$666,$000		;70
;	dc.w	$202,$312,$523,$631,$751,$777,$000		;84
	dc.w	$202,$312,$523,$631,$751,$777,$000		;84

poetryAtariText1Pal2			; atari mid         ; the
	dc.w	$111,$111,$111,$111,$111,$111,$111
	dc.w	$111,$111,$111,$111,$111,$222,$111
	dc.w	$111,$111,$111,$111,$211,$333,$111
	dc.w	$111,$111,$111,$211,$321,$444,$111
	dc.w	$111,$111,$211,$221,$431,$555,$000
	dc.w	$101,$211,$312,$321,$542,$666,$000
;	dc.w	$110,$121,$232,$343,$455,$777,$000
	dc.w	$101,$212,$323,$432,$643,$777,$000

poetryAtariText1Pal3			; atari bot         ; scene 
	dc.w	$111,$111,$111,$111,$111,$111,$111
	dc.w	$111,$111,$111,$111,$111,$222,$111
	dc.w	$111,$111,$111,$111,$121,$333,$111
	dc.w	$111,$111,$111,$111,$121,$444,$111
	dc.w	$111,$111,$111,$121,$231,$555,$000
	dc.w	$111,$121,$121,$232,$342,$666,$000
;	dc.w	$110,$121,$232,$343,$455,$777,$000
	dc.w	$110,$120,$231,$343,$453,$777,$000

poetrySMFXText1Pal1			; smfx top 				with
	dc.w	$111,$111,$111,$111,$111,$111,$111
	dc.w	$111,$111,$111,$111,$111,$222,$111
	dc.w	$111,$111,$111,$111,$121,$333,$111
	dc.w	$111,$111,$111,$111,$121,$444,$111
	dc.w	$111,$111,$111,$121,$231,$555,$000
	dc.w	$111,$121,$121,$232,$342,$666,$000
;	dc.w	$110,$121,$232,$343,$455,$777,$000
	dc.w	$110,$120,$231,$343,$453,$777,$000

poetrySMFXText1Pal2			; smfx mid				skill
	dc.w	$111,$111,$111,$111,$111,$111,$111
	dc.w	$111,$111,$111,$111,$111,$222,$111
	dc.w	$111,$111,$111,$111,$112,$333,$111
	dc.w	$111,$111,$111,$111,$123,$444,$111
	dc.w	$111,$111,$111,$122,$134,$555,$000
	dc.w	$011,$111,$022,$133,$145,$666,$000
;	dc.w	$110,$121,$232,$343,$455,$777,$000
	dc.w	$012,$022,$033,$144,$256,$777,$000

poetrySMFXText1Pal3			; smfx bot				+stijl
	dc.w	$111,$111,$111,$111,$111,$111,$111		;0
	dc.w	$111,$111,$111,$111,$211,$222,$111		;14
	dc.w	$111,$111,$111,$111,$311,$333,$111		;28
	dc.w	$111,$111,$211,$311,$421,$444,$000		;42
	dc.w	$111,$111,$311,$411,$531,$555,$000		;56
	dc.w	$101,$211,$412,$521,$641,$666,$000		;70
;	dc.w	$202,$312,$523,$631,$751,$777,$000		;84
	dc.w	$202,$312,$523,$631,$751,$777,$000		;84


ppp1	dc.l	poetryAtariText1Pal1
ppp2	dc.l	poetryAtariText1Pal2
ppp3	dc.l	poetryAtariText1Pal3


setPoetryPals
	;top color
;	lea		poetryText1Pal1,a0
	move.l	ppp1,a0
	add.w	poetryPalOff,a0
	movem.l	(a0)+,d0-d2
	move.w	(a0)+,d3
	move.l	d0,timer_b_atari_text_init+8
	move.l	d1,timer_b_atari_text_init+16
	move.l	d2,timer_b_atari_text_init+24
	move.w	d3,timer_b_atari_text_init+32

	move.l	d0,timer_b_smfx_text_init+8
	move.l	d1,timer_b_smfx_text_init+16
	move.l	d2,timer_b_smfx_text_init+24
	move.w	d3,timer_b_smfx_text_init+32


	; middle color
;	lea		poetryText1Pal2,a0
	move.l	ppp2,a0
	add.w	poetryPalOff,a0
	movem.l	(a0)+,d0-d2
	move.w	(a0)+,d3
	move.l	d0,timer_b_text2+2
	move.l	d1,timer_b_text2+10
	move.l	d2,timer_b_text2+18
	move.w	d3,timer_b_text2+26

	move.l	d0,timer_b_text4+2
	move.l	d1,timer_b_text4+10
	move.l	d2,timer_b_text4+18
	move.w	d3,timer_b_text4+26

	; bottom color
;	lea		poetryText1Pal3,a0
	move.l	ppp3,a0
	add.w	poetryPalOff,a0
	movem.l	(a0)+,d0-d2
	move.w	(a0)+,d3

	move.l	d0,timer_b_text3+2
	move.l	d1,timer_b_text3+10
	move.l	d2,timer_b_text3+18
	move.w	d3,timer_b_text3+26

	move.l	d0,timer_b_text5+2
	move.l	d1,timer_b_text5+10
	move.l	d2,timer_b_text5+18
	move.w	d3,timer_b_text5+26


	rts

generateXTable
	move.l	x_table_explode_pointer,a0
	move.w	#0,d0			;x
	move.w	#32,d2
	move.w	#20-1,d7
.ol
		sub.w	d1,d1
		REPT 16
			move.w	d0,(a0)+
			move.w	d1,(a0)+
			add.w	d2,d1
		ENDR
			addq.w	#8,d0
	dbra	d7,.ol


	rts


clearExplodeBlocks
	move.l screenpointer2,d7
;	lea		explode_clear1,a0
;	lea		explode_clear2,a1
	move.l	explode_clear1bPointer,a0
	move.l	explode_clear2bPointer,a1

	moveq	#0,d0
.doOne
	move.w	(a0)+,d7
	blt		.doTwo
		move.l	d7,a6
		move.w	d0,(a6)
		move.w	d0,160(a6)
		jmp		.doOne
.doTwo
	move.w	(a1)+,d7
	blt		.end
		move.l	d7,a6
		move.w	d0,(a6)
		move.w	d0,8(a6)
		move.w	d0,160(a6)
		move.w	d0,168(a6)
		jmp		.doTwo
.end
	move.l	explode_clear2aPointer,d0
	move.l	explode_clear2bPointer,explode_clear2aPointer
	move.l	d0,explode_clear2bPointer

	move.l	explode_clear1aPointer,d0
	move.l	explode_clear1bPointer,explode_clear1aPointer
	move.l	d0,explode_clear1bPointer


	rts

endrout
	move.w	#-1,(a1)+
	move.w	#-1,(a2)+
	rts

explode_block_pointer	dc.l	0

drawExplodeBlocks2
	move.l	screenpointer2,d7
	move.l	explode_clear1bPointer,a1
	move.l	explode_clear2bPointer,a2
	lea		.doDot,a3
	move.l	explode_block_pointer,a5
	move.l	x_table_explode_pointer,d0
;	lea		x_table,a6
	move.w	#160,d6
;	move.l	a6,usp
.doDot
	move.w	(a5)+,d0			; x
	blt		endrout
;		move.l	usp,a6
;		add.w	d0,a6
		move.l	d0,a6
		move.w	(a6)+,d7		;x
		add.w	(a5)+,d7
		add.w	#4,a5
		move.w	(a6)+,d0		;jumpoff
		move.l	d7,a0
		add.w	#-2,a0
		jmp		d_block0(pc,d0)

drawExplodeBlocks
	move.l	screenpointer2,d7
	move.l	explode_clear1aPointer,a1
	move.l	explode_clear2aPointer,a2
	lea		.doDot,a3
	move.l	explode_block_pointer,a5
	move.l	x_table_explode_pointer,d0
;	lea		x_table,a6
	move.w	#160,d6
;	move.l	a6,usp
	jmp		.doDot
.doDotSkip
		add.w	#4,a5
.doDot
	move.w	(a5)+,d0			; x
	blt		endrout
;		move.l	usp,a6
;		add.w	d0,a6
		move.l	d0,a6
		move.w	(a6)+,d7		;x
		add.w	(a5)+,d7
		blt		.doDotSkip
		move.w	(a5)+,d0
		add.w	d0,-6(a5)		; xOFF
		move.w	(a5),d0
		sub.w	d0,-4(a5)
		sub.w	d6,(a5)+
		move.w	(a6)+,d0		;jumpoff
		move.l	d7,a0
		add.w	#-2,a0
		jmp		d_block0(pc,d0)



d_block0
	or.w	#%1100000000000000,(a0)				;4
	or.w	#%1100000000000000,160(a0)			;6
	move.w	a0,(a1)+							;2
	jmp		(a3)								;2
	ds.b	18

d_block1
	or.w	#%0110000000000000,(a0)
	or.w	#%0110000000000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block2
	or.w	#%0011000000000000,(a0)
	or.w	#%0011000000000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block3
	or.w	#%0001100000000000,(a0)
	or.w	#%0001100000000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block4
	or.w	#%0000110000000000,(a0)
	or.w	#%0000110000000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block5
	or.w	#%0000011000000000,(a0)
	or.w	#%0000011000000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block6
	or.w	#%0000001100000000,(a0)
	or.w	#%0000001100000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block7
	or.w	#%0000000110000000,(a0)
	or.w	#%0000000110000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block8
	or.w	#%0000000011000000,(a0)
	or.w	#%0000000011000000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block9
	or.w	#%0000000001100000,(a0)
	or.w	#%0000000001100000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block10
	or.w	#%0000000000110000,(a0)
	or.w	#%0000000000110000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block11
	or.w	#%0000000000011000,(a0)
	or.w	#%0000000000011000,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block12
	or.w	#%0000000000001100,(a0)
	or.w	#%0000000000001100,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block13
	or.w	#%0000000000000110,(a0)
	or.w	#%0000000000000110,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block14
	or.w	#%0000000000000011,(a0)
	or.w	#%0000000000000011,160(a0)
	move.w	a0,(a1)+
	jmp		(a3)
	ds.b	18

d_block15
	or.w	#%0000000000000001,(a0)					;4
	or.w	#%1000000000000000,8(a0)				;6
	or.w	#%0000000000000001,160(a0)				;6
	or.w	#%1000000000000000,168(a0)				;6
	move.w	a0,(a2)+								;2
	jmp		(a3)									;2			26
	ds.b	6

explode_clear1aPointer	dc.l	0
explode_clear1bPointer	dc.l	0

explode_clear2aPointer	dc.l	0
explode_clear2bPointer	dc.l	0


;atari_blocks
;	include	data/diag/test3.txt			;1204

;smfx_blocks
; 	include	data/diag/test4.txt			;1612


smfx_blocks_pointer		dc.l	0
atari_blocks_pointer	dc.l	0
doMotusText
	move.w	#-1,motusOn
	rts

motusOn	dc.w	0

drawSavingTheScenePoetry
	subq.w	#1,.grace
	bge		.skip
;	lea		poetry1a+128+59*160,a0
;	lea		pot1buff,a0
	move.l	savescene1ptr,a0
	move.l	screenpointer2,a1
;	add.w	#8,a0
	add.w	#59*160,a1
	move.w	#81-1,d7
.cp
		movem.l	(a0)+,d0-d6/a2/a3/a4/a5/a6
		movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
;		lea		160(a0),a0
		lea		160(a1),a1
	dbra	d7,.cp
.skip
	move.w	#1,motusOn
	rts
.grace	dc.w	1

drawAtari
;	lea		poetry1b+128+49*160+8,a0
;	lea		pot1buffAtari,a0
	move.l	savescene2ptr,a0
	move.l	screenpointer2,a1
	add.w	#49*160,a1
	move.w	#92-1,d7
.cp
		movem.l	(a0)+,d0-d6/a2/a3/a4/a5/a6
		movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
;		lea		160(a0),a0
		lea		160(a1),a1		
	dbra	d7,.cp
	rts

clearAreaDrawAtariExplode
	move.w	#2,textWaiterOut
	subq.w	#1,clearAreaDrawAtariExplodeTwice
	blt		.skipClear
	move.l	screenpointer2,a1
	add.w	#49*160,a1

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6


	move.w	#95-1,d7
.cp
		movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
		movem.l	d0-d3,48(a1)
		lea		160(a1),a1		
	dbra	d7,.cp

.skipClear

    	jsr		clearExplodeBlocks
    	subq.w	#1,herpWaitertt
    	blt		.drawExplodeBlock1
	    	jsr		drawExplodeBlocks2
	    	jmp		.skip
.drawExplodeBlock1
			jsr		drawExplodeBlocks
			move.l	screenpointer2,a0
			add.w	#140*160+152+6,a0
			moveq	#0,d0
.y set 0
			REPT 60
				move.w	d0,.y(a0)
.y set .y+160
			ENDR
.skip
	rts
herpWaitertt					dc.w	10
clearAreaDrawAtariExplodeTwice	dc.w	2




drawSkillAndStijl
	move.l	#poetrySMFXText1Pal1,ppp1
	move.l	#poetrySMFXText1Pal2,ppp2
	move.l	#poetrySMFXText1Pal3,ppp3

	subq.w	#1,.grace
	bge		.skip
;	lea		poetry2a+128+16,a0
;	lea		pot2a,a0
	move.l	skillstijl1ptr,a0
	move.l	screenpointer2,a1
	add.w	#56*160+8,a1
	move.w	#87-1,d7
.cp
		movem.l	(a0)+,d0-d6/a2/a3/a4
		movem.l	d0-d6/a2/a3/a4,(a1)
		lea		160(a1),a1
	dbra	d7,.cp
.skip
	move.w	#2,motusOn
	rts
.grace	dc.w	1

drawSMFX
;	lea		poetry2a+128+97*160+16,a0
;	lea		pot2b,a0
	move.l	skillstijl2ptr,a0
	move.l	screenpointer2,a1
	add.w	#49*160+8,a1
	move.w	#94-1,d7
.cp
		movem.l	(a0)+,d0-d6/a2/a3/a4/a5/a6
		movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
		lea		160(a1),a1
	dbra	d7,.cp
	move.l	smfx_blocks_pointer,explode_block_pointer
	move.w	#10,herpWaitertt

	subq.w	#1,.tt
	blt		.ss
		move.l	explode_clear2aPointer,d0
		move.l	explode_clear2bPointer,explode_clear2aPointer
		move.l	d0,explode_clear2bPointer

		move.l	explode_clear1aPointer,d0
		move.l	explode_clear1bPointer,explode_clear1aPointer
		move.l	d0,explode_clear1bPointer
.ss
	rts
.tt	dc.w	1


;------------------ ACTUAL DOTS EFFECT CODE
partition_offset	dc.w	0	; ranges from 0..16*4

flowerRoutList
	dc.l	diagonalFlowerA
	dc.l	diagonalFlower
	dc.l	diagonalFlower2
	dc.l	diagonalFlower3
	dc.l	wholeFlower					; here we display the whole thing
flowerRoutListOff	dc.w	0

haxCols
;		move.w	#$0741,$ffff8240+2
		move.w	#$0741,$ffff8240+4
;		move.w	#$0741,$ffff8240+8
		rts

drawDots
	subq.w	#1,.www
	bge		.ok
		add.w	#4,flowerRoutListOff
		cmp.w	#16,flowerRoutListOff
		beq		.do32000
			move.w	#2,.www
			jmp		.ok
.do32000
		move.w	#32000,.www
;		move.w	#$4e75,haxCols

.ok
	subq.w	#1,.yyy
	bge		.ok2
;		move.w	#0,cycleDots
.ok2
	move.l	sine_xgeneric_pointer,a2
	move.l	a2,a1
	move.l	sine_ygeneric_pointer,a0
	move.l	a0,a3

	add.w	xoff1,a2
	add.w	xoff2,a1

	add.w	yoff1,a0
	add.w	yoff2,a3

	movem.w	x1skip,d2/d3/d4/a4

	move.l	savedTable_pointer,a6
	add.w	partition_offset,a6
	move.l	a6,usp
	move.w	colorOffset,d6
	move.l	screenpointer2,d5

;	cmp.w	#16,flowerRoutListOff
;	beq		.kkkZ
	jsr		haxCols
;.kkkZ
	moveq	#0,d1
	lea		flowerRoutList,a5
	add.w	flowerRoutListOff,a5
	move.l	(a5),a6
	jmp		(a6)
.www	dc.w	4
.yyy	dc.w	35

current_nr_of_dots	dc.w	CURRENT_NUMBER_OF_STARTING_DOTS
changedDots			dc.w	0
changedDotsVals		ds.w	4
wholeFlower
	move.w	current_nr_of_dots,d7
	beq		.end
	sub.w	changedDots,d7
	ble		.next
	subq.w	#1,d7
.loopWave
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions
			move.w	(a6)+,d5		;		100*10 = 1k	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loopWave																		; 1200 cycles

.next

	move.w	changedDots,d7
	movem.w	changedDotsVals,d2/d3/d4/a4
	subq.w	#1,d7
	blt		.end
.loopWave2
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions
			move.w	(a6)+,d5		;		100*10 = 1k	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loopWave2																		; 1200 cycles		
.end
	rts



diagonalFlowerA
	move.l	usp,a6
	add.w	#9*4,a6
	move.l	a6,usp
	move.w	current_nr_of_dots,d7
	subq.w	#1,d7
.loop
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions-13
			move.w	(a6)+,d5		;	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loop																		; 1200 cycles
	rts


diagonalFlower
	move.l	usp,a6
	add.w	#7*4,a6
	move.l	a6,usp
	move.w	current_nr_of_dots,d7
	subq.w	#1,d7
.loop
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions-8
			move.w	(a6)+,d5		;	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loop																		; 1200 cycles
	rts

diagonalFlower2
	move.l	usp,a6
	add.w	#6*4,a6
	move.l	a6,usp
	move.w	current_nr_of_dots,d7
	subq.w	#1,d7
.loop
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions-6
			move.w	(a6)+,d5		;	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loop																		; 1200 cycles
	rts

diagonalFlower3
	move.l	usp,a6
	add.w	#4*4,a6
	move.l	a6,usp
	move.w	current_nr_of_dots,d7
	subq.w	#1,d7
.loop
		move.l	(a0)+,d0			
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		add.l	(a3)+,d0

		move.l	usp,a6
		add.l	d0,a6

		REPT nr_of_partitions-4
			move.w	(a6)+,d5		;	
			add.w	d6,d5			;	
			move.l	d5,a5			;	
			move.w	(a6)+,d0		;	
			or.w	d0,(a5)			;	
		ENDR

		add.w	d2,a0				
		add.w	d3,a1				
		add.w	d4,a2
		add.w	a4,a3
	dbra	d7,.loop																		; 1200 cycles
	rts






incrementFlowerOffsets
	move.w	x1inc,d0
	add.w	d0,xoff1
	cmp.w	#1024*4,xoff1
	ble		.ok1
		sub.w	#1024*4,xoff1
.ok1

	move.w	x2inc,d0
	add.w	d0,xoff2
	cmp.w	#1024*4,xoff2
	ble		.ok2
		sub.w	#1024*4,xoff2
.ok2
	
	move.w	y1inc,d0	
	add.w	d0,yoff1
	cmp.w	#1024*4,yoff1
	ble		.ok3
		sub.w	#1024*4,yoff1
.ok3

	move.w	y2inc,d0
	add.w	d0,yoff2
	cmp.w	#1024*4,yoff2
	ble		.ok4
		sub.w	#1024*4,yoff2
.ok4
	rts




cycleDotColors	
	lea		colorList,a0
	move.w	colorOffset2,d4					
	add.w	d4,a0
	movem.l	(a0),d0-d3
	move.w	d0,$ffff8240+2*1
	movem.l	d1-d3,$ffff8240+2*2

	add.w	#16,d4
	cmp.w	#$70,d4
	bne		.cont
		move.w	#16,d4
.cont
	move.w	d4,colorOffset2


	subq.w	#1,bitPlaneFlag
	bne		.noCheck		;---------------\
	move.w	#2,bitPlaneFlag					;
.checkColor									;
	add.w	#2,colorOffset					;
	cmp.w	#6,colorOffset					;
	bne		.noColorReset					;
		move.w	#0,colorOffset				;
.noColorReset								;
	move.l	clearScreen1bplPointer,a0
	move.w	colorOffset,8(a0)				;
.noCheck						;<----------/
	rts
bitPlaneFlag	dc.w	1	;2

colorOffset2						ds.w	1


;------------------ DOTS CODE
init_dots								; initializes the source dots (x,y for 64*100 area)
	
	IFEQ	SINEFLOWER_DISPLAY_LEFT
	move.w	#214*2+2048,vertices_xoff
	ELSE
	move.w	#214*4+2048,vertices_xoff
	ENDC
	move.w	#100*4+1280+2048,vertices_yoff
	move.l	#6400,number_of_vertices

	move.l	tableSourcePointer,a0
	move.l	logpointer,d0
	move.l	logpointer,d1
	move.w	#100-1,d7

	move.w	#0,d0						; base address of low memory
	move.w	#$5000,d6
.oloop
	move.w	#-31*2,d1				;y
	REPT 64							; 64 * 18 = 1152
		move.l	d0,a2
		move.w	(a2),d2
		add.w	d6,d2
		move.w	d2,(a0)+

		move.l	d1,a2
		move.w	(a2),d2
		add.w	d6,d2
		move.w	d2,(a0)+
		addq.w	#2,d1
	ENDR
	addq.w	#2,d0
	dbra	d7,.oloop

	rts	



__sinA		equr d1
__cosA		equr d2
__sinB		equr d3
__cosB		equr d4
__sinC		equr d5
__cosC		equr d6
; todo:
;	- save and restore `multiple uses' of multiplication, to avoid recalculation every time
calcRotMatrix

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		_sintable512,a0
	lea		_sintable512+(512*2/4),a1
    move.w  #512*2,d7									;8
; do angular speeds and get indices 
    move.w  currentStepX,d2								;16
    cmp.w   d7,d2										;4
    blt     .goodX										;12
        sub.w   d7,d2									;4
.goodX
    move.w  d2,currentStepX								;16		--> 68
    add.w   #30*2,currentStepX								;16						; 17 * 30 = 512 vs 510, so we are 2 off, we can be MORE precise, add +1 halfway
    cmp.w	#8*30*2,currentStepX
    bne		.kkkk
    	add.w	#2,currentStepX
.kkkk
	move.w	(a0,d2.w),d1					; _sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; _cosA						16
	move.w	#$7FFF,d4
	move.w	d4,d6
	move.l	logpointer,d0		;20	
; xx = cos(A) * cos(B)
	move.w	__cosA,d7
	muls	__cosB,d7
	swap	d7
	asr.w	#7,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),d0
	move.w	d0,pxxp+2
	move.w	d0,pxxp2+2
;xy = [sin(A)cos(B)]		
	move.w	__sinA,d7
	muls	__cosB,d7
	swap	d7
	asr.w	#7,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),d0
	move.w	d0,pxyp+2
	move.w	d0,pxyp2+2
;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
	move.w	__sinA,d4
	muls	__cosC,d4	
	move.l	d4,a0			; save for zy
	move.w	__cosA,d7
	muls	__sinB,d7
	swap	d7
	add.w	d7,d7
	muls	__sinC,d7
	add.l	d7,d4	
	swap	d4
	asr.w	#7,d4
	move.w	d4,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),d0
	move.w	d0,pyxp+2
	move.w	d0,pyxp2+2
;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
	move.w	__cosA,d7
	muls	__cosC,d7
	move.l	d7,a1			; save for zx
	neg.l	d7
	move.w	__sinA,d4
	muls	__sinB,d4
	swap	d4
	add.w	d4,d4
	muls	__sinC,d4
	add.l	d4,d7
	swap	d7
	asr.w	#7,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),d0
	move.w	d0,pyyp+2
	move.w	d0,pyyp2+2

	move.l	x_block_aligned_pointer,d0
	move.l	y_block_aligned_pointer,d1
	move.l	tableSourcePointer,a5					; 20							
	move.l	number_of_vertices,d7				; 20
	lsr.w	#1,d7
	subq	#1,d7								; 4								;100
	move.w	#-4,d2								; and mask
	move.w	vertices_xoff,d3
	move.w	vertices_yoff,d4

	move.l	savedTable_pointer,a6
	add.l	saveOffset,a6

loop11
;	movem.w	(a5)+,a0/a1/a2/a3
		movem.w	(a5)+,a0/a1/a2/a3
;		move.w	(a5)+,a0
;		move.w	(a5)+,a1
		;	x	
pxxp	move.w	1234(a0),d0	;12				xx is offset into table for the value, smc
pxyp	add.w	1234(a1),d0	;12				xy is offset into table for the value, smc
		;	y
pyxp	move.w	1234(a0),d1	;12
pyyp	add.w	1234(a1),d1	;12
		
		asr.w	#5,d0
		asr.w	#5,d1

		and.w	d2,d0
		and.w	d2,d1

		add.w	d3,d0					; 
		add.w	d4,d1					; 

		move.l	d0,a0					; use x value as offset into the x_block (off,mask) table
		move.w	(a0)+,d0				; get offset
		move.l	d1,a1					; use y value as offset into the y_block (off) table
		add.w	(a1),d0					; x+y offset

		move.w	d0,(a6)+				; save offset into 
		move.w	(a0),(a6)+				; save mask

		lea		(nr_of_partitions-1)*4(a6),a6

pxxp2	move.w	1234(a2),d0	;12				xx is offset into table for the value, smc
pxyp2	add.w	1234(a3),d0	;12				xy is offset into table for the value, smc
		;	y
pyxp2	move.w	1234(a2),d1	;12
pyyp2	add.w	1234(a3),d1	;12
		
		asr.w	#5,d0
		asr.w	#5,d1

		and.w	d2,d0
		and.w	d2,d1

		add.w	d3,d0					; 
		add.w	d4,d1					; 

		move.l	d0,a0					; use x value as offset into the x_block (off,mask) table
		move.w	(a0)+,d0				; get offset
		move.l	d1,a1					; use y value as offset into the y_block (off) table
		add.w	(a1),d0					; x+y offset

		move.w	d0,(a6)+				; save offset into 
		move.w	(a0),(a6)+				; save mask

		lea		(nr_of_partitions-1)*4(a6),a6
	dbra	d7,loop11
	rts



;------------------------- CLEAR DOTS CODE GENERATION
genClearCodeRout
.loop
		move.l	d0,(a0)+
		add.w	d4,d0		
	dbra	d7,.loop
	addq.w	#8,d1
	rts

generateClearScreenCode
	move.l	clearScreen1bplPointer,a0
	move.l	a0,a1
	move.w	#$2079,(a0)+					; move.l x,a0
    move.l  #screenpointer2,(a0)+
    ; here we add #x indirect to a0
    move.w	#$41E8,(a0)+				;	lea		x(a0),a0		;2
    move.w	#0,(a0)+					;	x = 0					; <----- clearScreen1bpl+8
    move.w  #$7000,(a0)+                ;   moveq   #0,d0
;    move.w  #$7001,(a0)+                ;   moveq   #0,d0
    move.w	#160,d4
    move.w  #20-1,d6
    move.w  #200-1,d7

    move.l  #$31400000,d0				;move.w	d0,x(a0)
    ; we do coding this shit from left to right now
    IFEQ	SINEFLOWER_DISPLAY_LEFT
    moveq 	#0,d1               ; offset
    ELSE
    moveq 	#56,d1               ; offset
    ENDC

cc1 = 52
    move.w	d1,d0	; starting at 4th block (skip 3)
    add.w	#cc1*160,d0	; skip the first 20 lines
    move.w	#200-2*cc1-1,d7	; do 160 lines
    jsr		genClearCodeRout
cc2 = 31
    move.w	d1,d0	; starting at 4th block (skip 3)
    add.w	#cc2*160,d0	; skip the first 20 lines
    move.w	#200-2*cc2-1,d7	; do 160 lines
    jsr		genClearCodeRout
cc3 = 18
    move.w	d1,d0	; starting at 4th block (skip 3)
    add.w	#cc3*160,d0	; skip the first 20 lines
    move.w	#200-2*cc3-1,d7	; do 160 lines
    jsr		genClearCodeRout
cc4 = 8
    move.w	d1,d0	; starting at 4th block (skip 3)
    add.w	#cc4*160,d0	; skip the first 20 lines
    move.w	#200-2*cc4-1,d7	; do 160 lines
    jsr		genClearCodeRout
cc5 = 4
	move.w	d1,d0
	add.w	#cc5*160,d0
	move.w	#200-2*cc5-1,d7
    jsr		genClearCodeRout
cc6 = 0
	move.w	d1,d0
	add.w	#cc6*160,d0
	move.w	#200-2*cc6-1,d7
    jsr		genClearCodeRout
cc7 = 0
	move.w	d1,d0
	add.w	#cc7*160,d0
	move.w	#200-2*cc7-1,d7
    jsr		genClearCodeRout
cc8 = 0
	move.w	d1,d0
	add.w	#cc8*160,d0
	move.w	#200-2*cc8-1,d7
    jsr		genClearCodeRout
cc9 = 4
	move.w	d1,d0
	add.w	#cc9*160,d0
	move.w	#200-2*cc9-1,d7
    jsr		genClearCodeRout
cc10 = 8
	move.w	d1,d0
	add.w	#cc10*160,d0
	move.w	#200-2*cc10-1,d7
    jsr		genClearCodeRout
cc11 = 20
	move.w	d1,d0
	add.w	#cc11*160,d0
	move.w	#200-2*cc11-1,d7
    jsr		genClearCodeRout
cc12 = 33
	move.w	d1,d0
	add.w	#cc12*160,d0
	move.w	#200-2*cc12-1,d7
    jsr		genClearCodeRout
cc13 = 56
	move.w	d1,d0
	add.w	#cc13*160,d0
	move.w	#200-2*cc13-1,d7
    jsr		genClearCodeRout
; 13 * 200 = 2600
; 2600 - 248*2 = 2600 - 496 = 2104 * 16 = 33664
    move.w  #$4e75,(a0)+
	rts

;----------------- POSSIBLY SHARED CODE

; generate table for individual pixels for each 320 placements on screen
; format: offset,mask
; from left to right
init_xblock_aligned
	move.l	x_block_aligned_pointer,a1
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


init_yblock_aligned
	move.l	y_block_aligned_pointer,a1
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



;------------------ EXP LOG CODE

init_exp_log:   
init_log:      
	move.l	logunpack_pointer,a4
;    lea     log_src,A4    		; skip 0
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

init_exp:      
	lea		$3000,a0
	move.w	#0,d0
.cl
		move.w	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl

    move.w  #EXPS*2,D7
;    lea     exp_src,a3
	move.l	expunpack_pointer,a3

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6

    move.w  #EXPS-1,D7
ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1
		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+

    dbra    D7,ie2
    ; range 1000 to B000
    rts


	section DATA


colorList			
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;16			;1 front	; bpl0 = front bpl2 = back bpl3 = middle
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;32			;1 front	; bpl0 = front bpl2 = back bpl3 = middle
					dc.w	$000,	middle,	front,	front,	back,	middle,	front,	front	;48			;2 front	; bpl0 = middle bpl2 = front bpl3 = back
					dc.w	$000,	middle,	front,	front,	back,	middle,	front,	front	;64			;2 front	; bpl0 = middle bpl2 = front bpl3 = back
					dc.w	$000,	back,	middle,	middle,	front,	front,	front,	front	;80			;4 front	; bpl0 = back bpl2 = middle bpl3 = front
					dc.w	$000,	back,	middle,	middle,	front,	front,	front,	front	;96			;4 front	; bpl0 = back bpl2 = middle bpl3 = front
					dc.w	$000,	front,	back,	front,	middle,	front,	middle,	front	;112		;1 front	; bpl0 = front bpl2 = back bpl3 = middle


;sine_table_x1		
;	REPT 20
;		include	data/sinflower/xgeneric.s		; 90 * 4 = 360				4*1024 = 4096
;	ENDR
;sine_table_y1
;	REPT 20
;		include	data/sinflower/ygeneric.s		; 1616
;	ENDR


;prepSinFlow
;	lea		sinflow+128,a0
;	lea		buffer,a1
;
;.y set 80+40*160
;	REPT 120
;.x set .y
;		REPT 10
;			move.w	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;	lea		buffer,a0			; 10*2*120 = 2400
;	move.b	#0,$ffffc123
;	rts
;
;sinflow			incbin	'gfx/sinflowertest4.neo'


;sine_table_y2
;	REPT 40
;		include	data/sinflower/y2sine280.s		; 1120
;		include	data/sinflower/ygeneric.s		; 1120
;	ENDR

; explog stuff
;log_src:        incbin 	"data/explog/LOG.TAB"					; crank this
;exp_src:        incbin 	"data/explog/EXP.TAB"					; crank this







;tbcounter				dc.w	0
;rasterListPointerX		dc.l	0
;rasterListPointerSaved	dc.l	0

generateRasterValues
	lea		paldefs,a0
	lea		palvals,a1
	move.l	rasterListPointerSaved,a2
	move.w	#200-1,d7
	moveq	#0,d0
.ll
;		add.w	#1,a0
		REPT 6
			move.b	(a0)+,d0
			add.w	d0,d0
			move.w	(a1,d0.w),(a2)+
		ENDR
		add.w	#1,a0
	dbra	d7,.ll

	rts



generateTimerCode
;	lea		timer_b_code_list,a6
	move.l	timer_b_code_list_pointer,a6
;	lea		timer_b_address_list,a2
;	move.l	timer_b_address_list_pointer,a2
	move.l	a6,a4
	lea		paldefs+7*16,a0
	lea		palvals,a1
	move.w	#200-1-15-9,d7
.dotb
;		move.l	a6,(a2)+
		moveq	#7,d6						; number of registers left to skip
		lea		$ffff8240+9*2,a5			; target register
;		add.w	#1,a0			; skip first color
.gogo
		tst.b	(a0)
		beq		.doRTE
.writeTimerB
		tst.b	1(a0)
		beq		.doLast
.doTwoOrMore
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	(a1,d0.w),d1
		swap	d1
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	(a1,d0.w),d1			; .l color
		move.w	#$21fc,(a6)+			; move.l	
		move.l	d1,(a6)+				; #color
		move.w	a5,(a6)+				; palettereg
		add.w	#4,a5					; palettereg+4
		subq.w	#2,d6
		jmp		.gogo


.doLast
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	(a1,d0.w),d0	; color
		move.w	#$31fc,(a6)+	; move.w
		move.w	d0,(a6)+		; #color	
		move.w	a5,(a6)+		; $palette reg
		subq.w	#1,d6

.doRTE
		cmp.w	#199,d7
		bne		.notFirst
			move.w	#$31FC,(a6)+	; move.w	
			move.w	#$111,(a6)+		; color
			move.w	#$8240,(a6)+	; palette 
.notFirst
;		cmp.w	#0,d7
;		bne		.notLast
;			move.w	#$31FC,(a6)+	; move.w	
;			move.w	#$000,(a6)+		; color
;			move.w	#$8240,(a6)+	; palette 
;.notLast
		add.w	d6,a0			; skip remainder data to read
		neg.w	d6
		add.w	#7,d6
		move.b	d6,-15(a0)
		; point to next part	--> move.l #nextAddress,$120.w
		move.l	a6,d0			; current place
		add.l	#10,d0			; for move.l #nextTimerB,$120.w
		; if we skip, we have an empty timer_b
		move.w	#$21FC,(a6)+
		move.l	d0,(a6)+
		move.w	#$120,(a6)+
		move.w	#$4e73,(a6)+
	dbra	d7,.dotb

	lea		timer_b_multicol_endjump,a0
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.w	(a0)+,(a6)+

;	sub.l	a4,a6					;4230

	rts
.moveLCode							;	op	
	move.l	#$1234,$1234.w			;	21FC 0000 1234 1234
	move.w	#$123,$1234.w			;	31FC 0123 1234
.rteCODE
	rte								;	4E73

paldefs		; 1400 bytes, should be halved
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,20,21,$0,$0,$0,$07
	dc.b	20,21,43,$0,$0,$0,$0
	dc.b	21,43,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,29,20,41,36,$0,$0
	dc.b	 29,20,21,41,36,5,$0
	dc.b	 20,21,36,5,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	   2,29,20,3,4,$0,$0
	dc.b	   29,20,21,3,4,5,$0
	dc.b	  20,21,4,5,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	   2,19,17,3,4,$0,$0
	dc.b	   19,17,21,3,4,5,$0
	dc.b	  17,21,4,5,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,41,36,3,$0,$0,$0
	dc.b	  41,36,5,3,14,$0,$0
	dc.b	 36,5,14,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,3,32,41,36,$0,$0
	dc.b	  3,32,5,41,36,$0,$0
	dc.b	 32,5,36,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,35,12,3,32,$0,$0
	dc.b	   35,12,8,3,32,5,$0
	dc.b	  12,8,32,5,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,35,12,7,40,$0,$0
	dc.b	   35,12,8,7,40,6,$0
	dc.b	  12,8,40,6,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,7,40,31,30,$0,$0
	dc.b	  7,40,6,31,30,32,$0
	dc.b	 40,6,30,32,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	  2,35,12,7,40,$0,$0
	dc.b	   35,12,8,7,40,6,$0
	dc.b	  12,8,40,6,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,35,12,$0,$0,$0,$0
	dc.b	 35,12,8,$0,$0,$0,$0
	dc.b	 12,8,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,65,52,71,$0,$0,$0
	dc.b	65,52,40,71,67,$0,$0
	dc.b	52,40,71,67,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,52,32,71,$0,$0,$0
	dc.b	52,32,53,71,67,$0,$0
	dc.b	32,53,71,67,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,69,66,52,71,$0,$0
	dc.b	69,66,49,52,71,67,$0
	dc.b	66,49,71,67,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,31,66,69,$0,$0,$0
	dc.b	31,66,48,69,49,$0,$0
	dc.b	66,48,49,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,31,66,$0,$0,$0,$0
	dc.b	31,66,48,$0,$0,$0,$0
	dc.b	66,48,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,33,64,68,30,$0,$0
	dc.b	33,64,42,68,30,34,$0
	dc.b	64,42,30,34,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,68,30,33,64,$0,$0
	dc.b	68,30,34,33,64,42,$0
	dc.b	30,34,64,42,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,68,30,33,64,$0,$0
	dc.b	68,30,34,33,64,42,$0
	dc.b	30,34,64,42,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,33,64,68,30,$0,$0
	dc.b	33,64,42,68,30,34,$0
	dc.b	64,42,30,34,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,55,26,$0,$0,$0,$0
	dc.b	55,26,27,$0,$0,$0,$0
	dc.b	26,27,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,41,36,55,26,$0,$0
	dc.b	 41,36,5,55,26,27,$0
	dc.b	 36,5,26,27,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,41,36,29,20,$0,$0
	dc.b	 41,36,5,29,20,21,$0
	dc.b	 36,5,20,21,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,29,20,72,41,$0,$0
	dc.b	29,20,21,72,41,56,$0
	dc.b	20,21,41,56,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,72,41,$0,$0,$0,$0
	dc.b	72,41,56,$0,$0,$0,$0
	dc.b	41,56,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,72,41,46,19,$0,$0
	dc.b	72,41,56,46,19,26,$0
	dc.b	41,56,19,26,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,72,41,46,19,$0,$0
	dc.b	72,41,56,46,19,26,$0
	dc.b	41,56,19,26,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,72,41,46,19,$0,$0
	dc.b	72,41,56,46,19,26,$0
	dc.b	41,56,19,26,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,39,25,37,28,$0,$0
	dc.b	39,25,18,37,28,17,$0
	dc.b	25,18,28,17,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,39,25,37,28,$0,$0
	dc.b	39,25,18,37,28,17,$0
	dc.b	25,18,28,17,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,62,25,39,$0,$0,$0
	dc.b	62,25,23,39,18,$0,$0
	dc.b	25,23,18,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,25,23,62,54,$0,$0
	dc.b	25,23,24,62,54,38,$0
	dc.b	23,24,25,38,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,62,25,23,$0,$0,$0
	dc.b	62,25,23,24,$0,$0,$0
	dc.b	25,23,24,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,25,23,$0,$0,$0,$0
	dc.b	25,23,24,$0,$0,$0,$0
	dc.b	23,24,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,25,23,$0,$0,$0,$0
	dc.b	25,23,24,$0,$0,$0,$0
	dc.b	23,24,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,25,23,50,15,$0,$0
	dc.b	25,23,24,50,15,14,$0
	dc.b	23,24,15,14,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,57,59,50,15,$0,$0
	dc.b	57,59,16,50,15,14,$0
	dc.b	59,16,15,14,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,50,15,60,$0,$0,$0
	dc.b	50,15,16,60,47,$0,$0
	dc.b	15,16,47,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,61,58,22,$0,$0,$0
	dc.b	61,58,11,22,13,$0,$0
	dc.b	58,11,22,13,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,61,58,22,$0,$0,$0
	dc.b	61,58,11,22,13,$0,$0
	dc.b	58,11,22,13,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,58,22,$0,$0,$0,$0
	dc.b	58,22,13,$0,$0,$0,$0
	dc.b	22,13,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	 2,35,12,10,58,$0,$0
	dc.b	 35,12,8,10,58,45,$0
	dc.b	 12,8,58,45,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	63,70,44,35,12,$0,$0
	dc.b	 70,44,51,35,12,8,$0
	dc.b	 44,51,12,8,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	   2,35,12,9,8,$0,$0
	dc.b	  35,12,8,9,13,$0,$0
	dc.b	 12,8,13,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	dc.b	$0,$0,$0,$0,$0,$0,$0
	even


palvals					incbin	"data/diag/MOT.PAL"						; 512

	IFEQ	PACKTOTAL
totalcrk				incbin	"data/diag/diaginc2.crk"												;->		10542
	even
	ELSE
smfxblockscrk			incbin	"data/diag/smfxblocks.crk"				; 1612 / 880				----> 	13332
	even
atariblockscrk			incbin	"data/diag/atariblocks.crk"				; 1204	/689
	even
smfxdiagcrk				incbin	"data/diag/weareback.crk"				;12800	/ 1765
	even
sinflowcrk				incbin	"data/sinflower/backdrop.crk"			; 2400	/ (359 crk)			-2000
	even
savescene1crk			incbin	"data/diag/savescenegood.crk"				; 3888	/ 2605				-1200
	even
savescene2crk			incbin	"data/diag/savescene2.crk"				; 4416	/ 2648				-1800
	even
skillstijl1crk			incbin	"data/diag/skillstijl1.crk"				; 3480	/ 2245				-1200
	even
skillstijl2crk			incbin	"data/diag/skillstijl2.crk"				; 4512	/ 2141				-2300		
	even
	ENDC
; packed seperate: 13332
; packed total:	10542

;cat data/diag/smfxblocks.bin data/diag/atariblocks.bin data/diag/weareback.bin data/sinflower/backdrop.bin data/diag/savescene1.bin data/diag/savescene2.bin data/diag/skillstijl1.bin data/diag/skillstijl2.bin


sine_xgeneric_crk		incbin	"data/sinflower/xgeneric.crk"			; 4096	/ 276
	even
sine_ygeneric_crk		incbin	"data/sinflower/ygeneric.crk"			; 4096	/ 382
	even
log_crk					incbin	"data/explog/log.crk"					; 8192	/ 4300
	even
exp_crk					incbin	"data/explog/exp.crk"					; 8192	/ 3968
	even
motusColorcrk			incbin	"data/diag/motuscolor.crk"				;8000	/ 2556
	even
	IFEQ	STANDALONE
_sintable512			include "data/sintable_amp32768_steps512.s"		
	ENDC
savescene1ptr	dc.l	0
savescene2ptr	dc.l	0
skillstijl1ptr	dc.l	0
skillstijl2ptr	dc.l	0


;cat data/diag/MOT.PAL data/diag/smfxblocks.bin data/diag/atariblocks.bin data/sinflower/xgeneric.bin data/sinflower/ygeneric.bin data/explog/LOG.TAB data/explog/EXP.TAB data/diag/motuscolor.bin data/diag/weareback.bin data/sinflower/backdrop.bin data/diag/savescene1.bin data/diag/savescene2.bin data/diag/skillstijl1.bin data/diag/skillstijl2.bin


;motbuffer	ds.b	200*40

motusColorPointer		ds.l	1
smfxDiagPointer			dc.l	0


;prepPot1
;	lea		poetry1a+128,a0
;	lea		pot1buff,a1
;	move.l	a1,a2
;	add.w	#8+59*160,a0
;	move.w	#81-1,d7
;.cp
;.x set 0
;	REPT 6
;		move.l	.x(a0),(a1)+
;		move.l	.x+4(a0),(a1)+
;.x set .x+8
;	ENDR
;	lea		160(a0),a0
;	dbra	d7,.cp
;
;	lea		pot1buff,a0
;	move.b	#0,$ffffc123
;	rts
;
;pot1buff	ds.b	6*8*81	;3888
;poetry1a				incbin	"data/diag/poetry1.neo"

;prepPotAtari
;	lea		poetry1b+128,a0
;	lea		pot1buffAtari,a1
;	move.l	a1,a2
;	add.w	#49*160+8,a0
;	move.w	#92-1,d7
;.cp
;.x set 0
;	REPT 6
;		move.l	.x(a0),(a1)+
;		move.l	.x+4(a0),(a1)+
;.x set .x+8
;	ENDR
;	lea		160(a0),a0
;	dbra	d7,.cp
;	move.b	#0,$ffffc123
;	rts
;
;;pot2a	ds.b	5*8*87				;3480
;
;prepPot2
;	lea		poetry2a+128,a0
;	lea		pot2a,a1
;	move.l	a1,usp
;	add.w	#16,a0
;	move.w	#87-1,d7
;.cp
;		movem.l	(a0),d0-d6/a2/a3/a4			; 40
;		movem.l	d0-d6/a2/a3/a4,(a1)
;		lea		160(a0),a0
;		lea		40(a1),a1
;	dbra	d7,.cp
;	move.l	usp,a2
;	move.b	#0,$ffffc123
;
;	rts
;
;;pot2b	ds.b	6*8*94				;4512
;
;prepPot2b
;	lea		poetry2a+128+97*160+16,a0
;	lea		pot2b,a1
;	move.l	a1,usp
;	move.w	#94-1,d7
;.cp
;		movem.l	(a0),d0-d6/a2/a3/a4/a5/a6
;		movem.l	d0-d6/a2/a3/a4/a5/a6,(a1)
;		lea		160(a0),a0
;		lea		48(a1),a1
;	dbra	d7,.cp
;	move.l	usp,a2
;	move.b	#0,$ffffc123
;
;	rts
;
;poetry1b				incbin	"data/diag/poetry1_atari.neo"
;poetry2a				incbin	"data/diag/poetry2.neo"


;prepMotNeo
;	lea	motneo+128,a0
;	lea	motbuffer,a1
;.y set 0
;	REPT 200
;.x set .y
;		REPT 5
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;	lea		motbuffer,a0
;	sub.l	a0,a1
;	move.b	#0,$ffffc123
;
;	rts


	section DATA


	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC

; parts include
x_table_explode_pointer				ds.l	1

x_block_aligned_pointer				ds.l	1			;1280
y_block_aligned_pointer				ds.l	1			;800

dotsLoopPointer						ds.l	1
clearScreen1bplPointer				ds.l	1
tableSourcePointer					ds.l	1			;25600
saveOffset							ds.l	1
xoffsetcounter						ds.w	1
listoffset							ds.w	1

colorOffset							ds.w	1

; exp-log stuff
logpointer							ds.l	1

currentStepX						ds.w	1
savedTable_pointer					ds.l	1
vertices_xoff						ds.w	1
vertices_yoff						ds.w	1
number_of_vertices					ds.l	1

sine_xgeneric_pointer				ds.l	1
sine_ygeneric_pointer				ds.l	1


expunpack_pointer					ds.l	1
logunpack_pointer					ds.l	1
mySpacePointer						ds.l	1

; now to write some code to do the distance/speed function




xoff1	dc.w	0			;180
xoff2	dc.w	0			;220
yoff1	dc.w	0			;204
yoff2	dc.w	0			;280
zoff	dc.w	0			;256

x1inc	dc.w	0	
x2inc	dc.w	0	
y1inc	dc.w	0		;*2
y2inc	dc.w	0		;*2

x1skip	dc.w	0
x2skip	dc.w	0
y1skip	dc.w	0
y2skip	dc.w	0



    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC

