

SHAKE			equ 1
ANALYSE			equ 1
OPTIMIZED_SIZE 	equ 0

CHECKER_SPEED_CHANGE		equ 1

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

EFFECT_HEIGHT				equ 199

USEA7						equ 0

MAXCOUNT					equ FALSE

LINESIZE					equ 80
STRUCTSIZE					equ 64
	IFEQ	OPTIMIZED_SIZE
NUMBER_OF_LINES				equ 68	340/4
	ELSE
NUMBER_OF_LINES				equ 340
	ENDC

genlower					equ 0

savedA7						equ	$2000-18
checker_size0				equ $2000-14
checker_size1				equ $2000-12
checker_size2				equ $2000-10
checker_size3				equ $2000-8
checker_size4				equ $2000-6
checker_size5				equ $2000-4

scanLineLeft				equ $2000-2	
drawlistStruct1				equ $2000				; size 4096		$2000 - $2fff	; next up: $3000
							;; I need multiple drawlistStructs here......
							;; and this is 
determineSmallestNumber6	equ $3000				; 000016FE		$3000 - $46ff	; next up: $4700
scanLineCode				equ $4700+$3800			; 00001AB0		$4700 - $66ff	; next up: $6700	


GENERATE_SCANLINE_OFFSET 	equ $2fa8+$3800
	IFEQ genlower
generateScanLine			equ	$4700+$30+$3800
	ENDC

rasters						equ 1

checker_yoff0_start			equ	0*8
checker_yoff1_start			equ	0*8
checker_yoff2_start			equ	0*8
checker_yoff5_start			equ	0*8
checker_yoff3_start			equ	0*8
checker_yoff4_start			equ	0*8
		
sizeoffset					equ 0*8
		
	IFEQ	STANDALONE
CHECKER_EFFECT_CYCLES			equ 160 ;145
CHECKER_EFFECT_VBL				equ 56+8*CHECKER_EFFECT_CYCLES
CHECKER_CYCLE_STEPS					equ 8
CHECKER_FADEOUT_START_DELAY_VBL	equ 140
CHECKER_FADEOUT_BLACK_VBL		equ 3
CHECKER_FADEOUT_VBLSKIP_PER_STEP	equ 2

CHECKER_FLASH_WAITER_VBL			equ 500
CHECKER_FLASH_INTERVAL_VBL			equ 24
	ENDC

c0pos						equ		23			 	
c1pos						equ		30				
c2pos						equ		41				
c5pos						equ		56				
c3pos						equ		88				
c4pos						equ		150			
endpos						equ		314			

checker_size0_start			equ c0pos*8		;	10-20
checker_size1_start			equ c1pos*8		;	20-40
checker_size2_start			equ c2pos*8		;	40-70
checker_size5_start			equ c5pos*8		;	70-110	
checker_size3_start			equ c3pos*8		;	110-160
checker_size4_start			equ c4pos*8		;	160-220
end							equ endpos*8	



pl1	equ $211
pl2	equ $322
pl3	equ $433
pl4	equ $544
pl5	equ $655
pl6	equ $766




	

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1
PACKEDSTUFF EQU 0
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
;	lea		lines,a0
;	move.b	#0,$ffffc123		;27200
	
	jsr		musicPlayer
	jsr		init_demo
	move.w	#500,effect_vbl_counter
	jsr		init_checker


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


init_checker

	jsr		precalcChecker

	move.w	#0,$466.w
.tt
	tst.w	$466.w
	beq		.tt

	move.w	#$2700,sr
	move.l	#checker_vbl,$70
	move.w	#$2300,sr
	rts
.wvbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
		pushall
		IFNE	STANDALONE
		jsr		musicPlayer+8
		ENDC
		popall

	rte

myFadeLookuptablePointer	ds.l	1	;ds.b	2*2048
makeFadeTable
	moveq	#0,d1	;g
	moveq	#0,d2	;b


	move.l	myFadeLookuptablePointer,a0
	move.l	a0,a1
	moveq	#0,d0	;r
	move.w	#8-1,d7
.doRed										;d0 source, d4 local
		move.l	a1,a2
		moveq	#0,d1	;g
		move.w	d0,d4
		subq.w	#1,d4
		bgt		.okr
			moveq	#1,d4
.okr	
		asl.w	#8,d4
		move.w	#8-1,d3
.doGreen									;d1 source, d5 local
			move.l	a2,a3
			move.w	d1,d5
			subq.w	#1,d5
			bgt		.okg
				moveq	#1,d5
.okg
			asl.w	#4,d5
			moveq	#0,d2	;b

;------------------- BLUE
.doBlue										;d2 source, d6 local

innerloopMacro macro
				move.w	d2,d6		; local
				subq.w	#1,d6		; -1
				bgt		.ok\@
					moveq	#1,d6	; if < 0, then 0
.ok\@
				; compose
				add.w	d4,d6
				add.w	d5,d6
				move.w	d6,(a3)+
				addq.w	#1,d2
	endm

			REPT 8
					innerloopMacro
			ENDR
			; 8 done, next 8 skipped
;-------------------------
			addq.w	#1,d1
			lea		32(a2),a2
		dbra	d3,.doGreen
		addq.w	#1,d0
		lea		512(a1),a1
	dbra	d7,.doRed
	rts

precalcChecker
	move.l	screen1,d0
		move.l	d0,d1
		add.l	#$8000,d1
		move.l	d1,xposPointer
	move.l	screen2,d0
		move.l	d0,d1
		add.l	#$8000,d1
		move.l	d1,sizePalettePointer
		add.l	#2560,d1
	add.l	#$10000,d0
	move.l	d0,myHaxListPointer
	add.l	#2048,d0
	move.l	d0,my16versionsPointer
	add.l	#179200,d0
	move.l	d0,myFadeLookuptablePointer
	add.l	#1911*2,d0
	move.l	d0,my16versionsTablePointer



;	IFNE	OPTIMIZED_SIZE
	lea		linescrk,a0
	move.l	my16versionsPointer,a1
	add.l	#27200*2,a1
	jsr		cranker
;	ENDC


	lea		tablecrk,a0
	move.l	my16versionsTablePointer,a1
	jsr		cranker


;	jsr		setSpeed
	jsr		makeFadeTable

	jsr		doZoom


	move.w	#0,check_layer_disabled0
	move.w	#0,check_layer_disabled1
	move.w	#0,check_layer_disabled2
	move.w	#0,check_layer_disabled3
	move.w	#0,check_layer_disabled4
	move.w	#0,check_layer_disabled5

	move.w	#337*8,checker_size0		
	move.w	#337*8,checker_size1
	move.w	#337*8,checker_size2
	move.w	#337*8,checker_size5
	move.w	#337*8,checker_size3
	move.w	#337*8,checker_size4

	move.w	#0,checker_yoff0
	move.w	#0,checker_yoff1
	move.w	#0,checker_yoff2
	move.w	#0,checker_yoff3
	move.w	#0,checker_yoff4
	move.w	#0,checker_yoff5
	move.w	#32,checker_xoff0
	move.w	#32,checker_xoff1
	move.w	#32,checker_xoff2
	move.w	#32,checker_xoff3
	move.w	#32,checker_xoff4
	move.w	#32,checker_xoff5

	
	jsr		shiftChecker16Places
	jsr		genXposList
	move.l	#preparePointersIntoSourceScanLines,ppiss
	move.l	#drawListPointers,dlp

	jsr		copySmallestNumber
	jsr		copyDrawCode

	lea		myHaxList,a0
	move.l	myHaxListPointer,a1
	REPT	8*256/4
		move.l	(a0)+,(a1)+
	ENDR

	move.w	#$4e75,GENERATE_SCANLINE_OFFSET				; hax

	jsr		generateColors
	jsr		initDrawListStruct
	move.w	#$4e75,precalcChecker
	rts





;OFF0	dc.l ((checker_size1_start-checker_size0_start)<<13)/CHECKER_CYCLE_STEPS
;OFF1	dc.l ((checker_size2_start-checker_size1_start)<<13)/CHECKER_CYCLE_STEPS
;OFF2	dc.l ((checker_size5_start-checker_size2_start)<<13)/CHECKER_CYCLE_STEPS
;OFF5	dc.l ((checker_size3_start-checker_size5_start)<<13)/CHECKER_CYCLE_STEPS
;OFF3	dc.l ((checker_size4_start-checker_size3_start)<<13)/CHECKER_CYCLE_STEPS
;OFF4	dc.l ((end-checker_size4_start)<<13)/CHECKER_CYCLE_STEPS

;setSpeed
;	moveq	#0,d0
;	move.l	d0,d1
;	move.l	d0,d2
;	move.l	d0,d3
;	move.l	d0,d4
;	move.l	d0,d5
;	move.l	d0,d6
;
;	move.w	#checker_size0_start,d0	
;	move.w	#checker_size1_start,d1
;	move.w	#checker_size2_start,d2
;	move.w	#checker_size5_start,d5
;	move.w	#checker_size3_start,d3
;	move.w	#checker_size4_start,d4
;	move.w	#end,d6
;
;	sub.w	d4,d6
;	sub.w	d3,d4
;	sub.w	d5,d3
;	sub.w	d2,d5
;	sub.w	d1,d2
;	sub.w	d0,d1
;
;	move.w	#13,d0			; need to add 1
;
;	lsl.l	d0,d1
;	lsl.l	d0,d2
;	lsl.l	d0,d3
;	lsl.l	d0,d4
;	lsl.l	d0,d5
;	lsl.l	d0,d6
;
;	move.w	current_checker_cycle_steps,d0
;	lsl.l	#8,d0
;
;	divs	d0,d6
;	swap	d6
;	sub.w	d6,d6
;	swap	d6
;	lsl.l	#8,d6
;	move.l	d6,OFF4
;
;	divs	d0,d4
;	swap	d4
;	sub.w	d4,d4
;	swap	d4
;	lsl.l	#8,d4
;	move.l	d4,OFF3
;
;	divs	d0,d3
;	swap	d3
;	sub.w	d3,d3
;	swap	d3
;	lsl.l	#8,d3
;	move.l	d3,OFF5
;
;	divs	d0,d5
;	swap	d5
;	sub.w	d5,d5
;	swap	d5
;	lsl.l	#8,d5
;	move.l	d5,OFF2
;
;	divs	d0,d2
;	swap	d2
;	sub.w	d2,d2
;	swap	d2
;	lsl.l	#8,d2
;	move.l	d2,OFF1
;
;
;	divs	d0,d1
;	swap	d1
;	sub.w	d1,d1
;	swap	d1
;	lsl.l	#8,d1
;	move.l	d1,OFF0
;
;	rts
;
current_checker_cycle_steps	dc.w	8

checker_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
;    	cmp.w	#2,$466
;    	bne		.notbad
;    		lea	$ffff8240,a0
;    		REPT 16
;    			move.w	#$700,(a0)+
;    		ENDR
;.notbad
    	move.w	#0,$466
    		IFNE	STANDALONE
			jsr		init_deadline_pointers
			jsr		precalcAnim
			ENDC
    	tst.w	effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts


timer_b_open_curtain_check
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain_stable,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

a7free	dc.w	0

checker_vbl	
	addq.w	#1,vblvar
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	subq.w	#1,effect_vbl_counter

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_check,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

			pushall
	move.l 	screenpointer,$ff8200	
			screenswap										; swap screenpointers		

	move.w	#$000,$ffff8240

	subq.w	#1,.fixPaletteTimes
	bgt		.doColors
		jsr		doColors
		jmp		.colsdone	
.doColors
		jsr		fixPalette					; zoom part
		jmp		.colsdone
.colsdone
	tst.w	doAnim
	beq		.tt
		lea		.deadLineCols,a0
		add.w	.deadLineOff,a0
		move.w	(a0),$ffff8240+2
		subq.w	#1,.deadLineWaiter
		bge		.tt
			move.w	#1,.deadLineWaiter
			subq.w	#2,.deadLineOff
			bge		.tt
				move.w	#0,.deadLineOff

;		move.w	#$777,$ffff8240+2
;		move.b	#0,$ffffc123
.tt

	move.w	fadeStep,d4
	ble		.skipFade
	lea		$ffff8240+2,a0
	move.l	myFadeLookuptablePointer,a1
	move.w	#$777,d1
	move.w	#15-1,d6
.dc
		move.w	d4,d7
		move.w	(a0),d0
		and.w	d1,d0
.dd
		add.w	d0,d0
		move.w	(a1,d0),d0
	dbra	d7,.dd
	move.w	d0,(a0)+
	dbra	d6,.dc
.skipFade

		jsr		musicPlayer+8


	jsr		resetDrawListStructNew							; clear pointer list
	jsr		doSizeStuff										; do size stuff and set checkerMask
	jsr		preparePointersIntoSourceScanLines				; do stuff with x and get pointers
	jsr		populateDrawListStruct							; populate the struct with current frame				
	move.w	#0,(a6)+

	IFEQ	genlower
		jsr		scanLineCode								; 
	ELSE
		jsr		drawUniqueLinesNew			; draw every first unique line to the screen
	ENDC
	jsr		copyUniqueLinesNew2			; copy lines
;	jsr		stencilLoonies

		tst.w	doAnim
		beq		.noanim
		IFNE	STANDALONE
			subq.w	#1,.animdelay
			bge		.noanim
   			jsr		displayPic1bpl
   		ENDC
.noanim

	subq.w	#1,.fadeWaiter
	bge		.txx
		move.w	#CHECKER_FADEOUT_VBLSKIP_PER_STEP,.fadeWaiter
		add.w	#1,fadeStep
		cmp.w	#7,fadeStep
		ble		.kkkx
			move.w	#7,fadeStep
.kkkx
		subq.w	#1,.fadeWaiter2
		bge		.txx
			move.w	#32000,.fadeWaiter
			move.w	#0,fadeStep
.txx
	popall
	rte
.animdelay		dc.w	11
.fixPaletteTimes	dc.w	504
.fadeWaiter			dc.w	CHECKER_FADEOUT_START_DELAY_VBL
.fadeWaiter2		dc.w	7+CHECKER_FADEOUT_BLACK_VBL
.deadLineCols
	dc.w	$777
	dc.w	$666
	dc.w	$555
	dc.w	$444
	dc.w	$333
	dc.w	$222
.deadLineOff	dc.w	10
.deadLineWaiter	dc.w	13

vblvar		dc.w	0
fadeStep	dc.w	0
doAnim		dc.w	0

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


doSizeStuff
	move.w	#%0*STRUCTSIZE,d7

	jsr		doZoom

;------------------------------------
; check if layers are disabled,
;	and act accordingly
;------------------------------------
	move.w	#%000001*STRUCTSIZE,d6
checkAndDisableLayer	macro
	tst.w	check_layer_disabled\1
	bne		.end\@
		move.w	#337*8,checker_size\1
		move.w	#0,checker_yoff\1
		move.w	#32,checker_xoff\1
		eor.w	d6,d7
;		IFEQ	\1-4
;			move.b	#0,$ffffc123
;		ENDC
.end\@
	add.w	d6,d6
	endm
	checkAndDisableLayer 0
	checkAndDisableLayer 1
	checkAndDisableLayer 2
	checkAndDisableLayer 3
	checkAndDisableLayer 4
	checkAndDisableLayer 5

	move.w	#%111111111111000,d2
	move.w	#100*8,d3
	move.w	#%000001*STRUCTSIZE,d6
;------------------------------------
; combines checker size and y-off,
;	such that mask is correct and
;	correct checker_yoff is contained
;------------------------------------
doCheckerSizeStuff	macro
	tst.w	check_layer_disabled\1
	beq		.end\@
	move.w	checker_size\1,d0
	move.w	d0,d1
	lsr.w	d0
	neg.w	d0
	add.w	yoff_checker\1,d0
	add.w	d3,d0
	bgt		.positive\@
.again2\@
		eor.w	d6,d7
		add.w	d1,d0
		blt		.again2\@
.positive\@
	and.w	d2,d0
.again\@
		cmp.w	d0,d1
		bgt		.done\@
			sub.w	d1,d0
			eor.w	d6,d7
			jmp		.again\@
.done\@
	tst.w	d0
	bne		.kkk1\@
		eor.w	d6,d7
		add.w	d1,d0
.kkk1\@
	move.w	d0,checker_yoff\1
.end\@
	add.w	d6,d6
	endm
;------------------------------------
	doCheckerSizeStuff 0
	doCheckerSizeStuff 1
	doCheckerSizeStuff 2
	doCheckerSizeStuff 3
	doCheckerSizeStuff 4
	doCheckerSizeStuff 5




	move.w	d7,checkerMask
	rts

check_layer_disabled0	dc.w	1
check_layer_disabled1	dc.w	1
check_layer_disabled2	dc.w	1
check_layer_disabled5	dc.w	1
check_layer_disabled3	dc.w	1
check_layer_disabled4	dc.w	1

; we have offset to the right, we move right
;	- so after size shifts to the right, we cna go to 0 and flip the bit pattern
;	- 

; need to add reverse lookup here
;	
;
;	list of data:
;	

;b0
;b8
;c0
;c8
;d0
;d8
;e0
;e8
;f0
;f8
;100
;108
;110
;118
;120
;128
;130
;138
;140
;148
;150
;158
;160
;168
;170
;178
;180
;188
;190
;198
;1a0
;1a8
;1b0
;1b8
;1c0
;1c8
;1e0
;1e8
;200
;208
;220
;228
;240
;248
;260
;268
;280
;288
;2a0
;2a8
;2c0
;2c8
;300
;308
;330
;338
;370
;378
;3b0
;3b8
;3f0
;3f8
;430
;438
;470
;478
;4b0
;4b8
;550
;558
;5f0
;5f8
;6a0
;6a8
;690
;698
;740
;748
;7e0
;7e8
;880
;888
;920
;928
;930
;938

o0	equ	0
o1	equ	0
o2	equ	0
o3	equ	0
o4	equ	0
o5	equ	0


shakeOffset0
	dc.w	0,1*o0,1*o0,1*o0,2*o0,2*o0,2*o0,4*o0,4*o0,5*o0,4*o0,4*o0,4*o0,2*o0,2*o0,2*o0,1*o0,1*o0,1*o0
shakeOffset1
	dc.w	0,1*o1,1*o1,1*o1,2*o1,2*o1,2*o1,4*o1,4*o1,5*o1,4*o1,4*o1,4*o1,2*o1,2*o1,2*o1,1*o1,1*o1,1*o1
shakeOffset2
	dc.w	0,1*o2,1*o2,1*o2,2*o2,2*o2,2*o2,4*o2,4*o2,5*o2,4*o2,4*o2,4*o2,2*o2,2*o2,2*o2,1*o2,1*o2,1*o2
shakeOffset3
	dc.w	0,1*o3,1*o3,1*o3,2*o3,2*o3,2*o3,4*o3,4*o3,5*o3,4*o3,4*o3,4*o3,2*o3,2*o3,2*o3,1*o3,1*o3,1*o3
shakeOffset4
	dc.w	0,1*o4,1*o4,1*o4,2*o4,2*o4,2*o4,4*o4,4*o4,5*o4,4*o4,4*o4,4*o4,2*o4,2*o4,2*o4,1*o4,1*o4,1*o4
shakeOffset5
	dc.w	0,1*o5,1*o5,1*o5,2*o5,2*o5,2*o5,4*o5,4*o5,5*o5,4*o5,4*o5,4*o5,2*o5,2*o5,2*o5,1*o5,1*o5,1*o5

shakeOff	dc.w	0		;18

shakeWaiter	dc.w	40

; prepares buffers into a0,a1,a2,a3
; rapes a0,a1,a2,a3,a4,d0,d1
preparePointersIntoSourceScanLines
	; here we do the shakeOff
	IFEQ	SHAKE
	subq.w	#1,shakeWaiter
	bge		.noshake
		move.w	#50,shakeWaiter
		move.w	#18*2,shakeOff
.noshake
	move.w	shakeOff,d1

	lea		shakeOffset0,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff0

	lea		shakeOffset1,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff1

	lea		shakeOffset2,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff2

	lea		shakeOffset3,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff3

	lea		shakeOffset4,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff4

	lea		shakeOffset5,a0
	move.w	(a0,d1.w),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,.shakeOff5

	sub.w	#2,shakeOff
	bge		.sook
		move.w	#0,shakeOff
.sook
	ENDC


	move.w	checkerMask,d7									; this is the mask to be used, starting out at 0
	move.l	my16versionsPointer,a0					; source to scanline daa
;	lea		myXposList,a6							; position list, to lookup pixel to distance; formata a.l,a.l;b.l,b.l
	move.l	xposPointer,a6
	move.l	a0,a1									; layer1		
	move.l	a0,a2									; layer2
	move.l	a0,a3									; layer3
	move.l	a0,a4									; layer4
	move.l	a0,a5									; layer5
	move.w	#%000001*STRUCTSIZE,d6					; mask to flip bits
	moveq	#0,d0									; clear d0
;------------------------------------
; takes the checker_size and applies it to the scanlines source part
;	selecting the right size, then also applies the checker_xoff to the line
;------------------------------------
apply_XOff_to_ScanlineSource	macro
	move.w	checker_size\1,d0						; get current size
	IFEQ	ANALYSE
		move.w	d0,(a7)+
	ENDC
;	move.b	#0,$ffffc123

	IFEQ	OPTIMIZED_SIZE
;		move.b	#0,$ffffc123
		lsr.w	d0
		add.l	(a7,d0.w),a\1
	ELSE
	add.w	d0,d0			;4		16				; -> to 160
	add.w	d0,d0			;4		32				;
	move.l	d0,d1			;4		32				;	
	add.w	d1,d1			;4		64				;
	add.w	d1,d1			;4		128				;
	add.w	d0,d1	;80/160	;4		160				;
	add.l	d1,a\1			;8	 					; select proper value from list, based on size (vertical offset)
	ENDC

	IFEQ	SHAKE
	tst.w	check_layer_disabled\1
	beq		.disabled\@
		move.w	checker_xoff\1,d0						; get xoff value
		add.w	.shakeOff\1,d0
		bgt		.positive\@								; 
		jmp		.addagain\@
.disabled\@
	ENDC
	move.w	checker_xoff\1,d0						; get xoff value
	bgt		.positive\@								; 
.addagain\@
		eor.w	d6,d7
		add.w	checker_size\1,d0
		ble		.addagain\@
;		bgt		.positive\@
;		jmp		.addagain\@
.positive\@
	add.l	(a6,d0.w),a\1							; 
	add.w	d6,d6
	endm
;------------------------------------

	
	move.l	a7,.saveda7
	IFEQ	ANALYSE
		move.l	.mysaveptr,a7
	ENDC
		IFEQ	OPTIMIZED_SIZE
		move.l	my16versionsTablePointer,a7
		ENDC
	apply_XOff_to_ScanlineSource 0
	apply_XOff_to_ScanlineSource 1
	apply_XOff_to_ScanlineSource 2
	apply_XOff_to_ScanlineSource 3
	apply_XOff_to_ScanlineSource 4
	apply_XOff_to_ScanlineSource 5

	IFEQ	ANALYSE
		move.l	a7,.mysaveptr
	ENDC
	move.l	.saveda7,a7

	move.w	d7,checkerMask
	movem.l	a0-a5,scanlinePointers
	IFEQ	ANALYSE
	subq.w	#1,.times
	bge		.kkk
		jmp		myFix
.kkk
	ENDC
;	and.w	#%000100*STRUCTSIZE,d7
	rts
	IFEQ	SHAKE
.shakeOff0	dc.w	0
.shakeOff1	dc.w	0
.shakeOff2	dc.w	0
.shakeOff3	dc.w	0
.shakeOff4	dc.w	0
.shakeOff5	dc.w	0
	ENDC

.saveda7	dc.l	0
	IFEQ	ANALYSE
.times		dc.w	2000

.mysaveptr	dc.l	mysave

mysave		ds.w	6*2010

myTable		ds.l	$a88			; 10784	from size -> offset.l

myMark		ds.l	$a88

myLines		ds.b	100*160
	

; so this takes teh recorded values,
; creates a new lookup table that goes from size -> offset into new table
; so to make this, we get the size
;	for each newly found size
myFix
	move.w	#$2700,sr
	lea		mysave,a0			; get my recorded values
	lea		myTable,a1			; get my offset table

	lea		myLines,a2
	lea		myMark,a3
	move.l	my16versionsPointer,a6
	move.w	#6*2000-1,d7
	move.b	#0,$ffffc123
.doOne
	move.w	(a0)+,d0			; get size
	lsr.w	d0
	tst.l	(a3,d0.w)			; see if we already done this
	bne		.skip				; if not empty, skip!
		move.l	#-1,(a3,d0.w)
		; new entry, now save the offset in current mylines
		move.l	a2,d6			; current position
		sub.l	#myLines,d6		; subtract base position
		add.l	d6,d6			; because we skip 2
		move.l	d6,(a1,d0.w)	; save offset to index of size
		; determine the target line then
		muls	#40,d0			; offset into source 
		move.l	a6,a5			; 
		add.l	d0,a5			; current version, ready to read 160 bytes to myLines
		REPT 20
			move.l	(a5)+,(a2)+		
		ENDR

.skip
	dbra	d7,.doOne

	lea		myTable,a0			;590*4 = 2360
	lea		myLines,a1
	sub.l	a1,a2
	move.b	#0,$ffffc123
	nop
	rts
	ENDC
; BACKING FIELD SIZE - this is the fraction part for the position, that gets translated to the actual checker size
real_checker_size0	dc.l	0
real_checker_size1	dc.l	0
real_checker_size2	dc.l	0	
real_checker_size5	dc.l	0
real_checker_size3	dc.l	0
real_checker_size4	dc.l	0

; actual y offset for in screen
yoff_checker0			dc.w	0
yoff_checker1			dc.w	0
yoff_checker2			dc.w	0
yoff_checker5			dc.w	0
yoff_checker3			dc.w	0
yoff_checker4			dc.w	0

; BACKING FIELD Y-OFFSET for dispositions
yoff_source_checker0	dc.w	0*8
yoff_source_checker1	dc.w	0*8
yoff_source_checker2	dc.w	0*8
yoff_source_checker5	dc.w	0*8
yoff_source_checker3	dc.w	0*8
yoff_source_checker4	dc.w	0*8

; ACTUAL Y-OFFSET
checker_yoff0	dc.w	0
checker_yoff1	dc.w	0
checker_yoff2	dc.w	0
checker_yoff5	dc.w	0
checker_yoff3	dc.w	0
checker_yoff4	dc.w	0



; BACKING FIELD X-OFFSET for disposition
xoff_source_checker0	dc.w	0*8
xoff_source_checker1	dc.w	0*8
xoff_source_checker2	dc.w	0*8
xoff_source_checker5	dc.w	0*8
xoff_source_checker3	dc.w	0*8
xoff_source_checker4	dc.w	0*8

; ACTUAL X-OFFSET
checker_xoff0	dc.w	-16*8*6
checker_xoff1	dc.w	-16*8*6
checker_xoff2	dc.w	-16*8*6
checker_xoff5	dc.w	-16*8*6
checker_xoff3	dc.w	-16*8*6
checker_xoff4	dc.w	-16*8*6

yoff_source	dc.w	0*8
xoff_source	dc.w	0*8


OFF0	dc.l ((checker_size1_start-checker_size0_start)<<13)/CHECKER_CYCLE_STEPS
OFF1	dc.l ((checker_size2_start-checker_size1_start)<<13)/CHECKER_CYCLE_STEPS
OFF2	dc.l ((checker_size5_start-checker_size2_start)<<13)/CHECKER_CYCLE_STEPS
OFF5	dc.l ((checker_size3_start-checker_size5_start)<<13)/CHECKER_CYCLE_STEPS
OFF3	dc.l ((checker_size4_start-checker_size3_start)<<13)/CHECKER_CYCLE_STEPS
OFF4	dc.l ((end-checker_size4_start)<<13)/CHECKER_CYCLE_STEPS


doZoom
	subq.w	#1,.zoomsteps
	blt		.cycle

;	IFEQ	CHECKER_SPEED_CHANGE
;		subq.w	#1,.speedwaiter
;		bge		.okkx
;			move.w	#8,.speedwaiter
;			sub.w	#1,current_checker_cycle_steps
;		cmp.w	#4,current_checker_cycle_steps
;		bge		.tttt
;			move.w	#4,current_checker_cycle_steps
;.tttt
;		jsr		setSpeed
;.okkx
;	ENDC
	

		move.l	OFF0,d0
		add.l	d0,real_checker_size0				;10 -> 20
		move.w	real_checker_size0,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size0

		move.l	OFF1,d0
		add.l	d0,real_checker_size1				;20-> 40			1
		move.w	real_checker_size1,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size1

		move.l	OFF2,d0
		add.l	d0,real_checker_size2			; 40 -> 70			1.5
		move.w	real_checker_size2,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size2

		move.l	OFF5,d0
		add.l	d0,real_checker_size5				; 70 -> 110			2
		move.w	real_checker_size5,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size5

		move.l	OFF3,d0
		add.l	d0,real_checker_size3			;110 -> 160				2.5
		move.w	real_checker_size3,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size3	

		move.l	OFF4,d0
		add.l	d0,real_checker_size4				;160 -> 280
		move.w	real_checker_size4,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,checker_size4

;		cmp.w	#266,real_checker_size4
;		bge		.cycle

	rts

.cycle	


;		move.w	current_checker_cycle_steps,d0
;		subq.w	#1,d0
;		move.w	d0,.waiter
		add.w	#2,colorOffSet
.ok


	cmp.l	#colors,a0
	bne		.kkkkz
		move.w	#0,colorOffSet
.kkkkz



		move.w	current_checker_cycle_steps,.zoomsteps
		subq.w	#1,.zoomsteps
;		move.w	#CHECKER_CYCLE_STEPS-1,.zoomsteps			; reset number of frames
		move.w	#checker_size0_start,checker_size0			; reset display size
		move.w	#checker_size1_start,checker_size1			; reset display size
		move.w	#checker_size2_start,checker_size2			; reset display size
		move.w	#checker_size5_start,checker_size5			; reset display size
		move.w	#checker_size3_start,checker_size3			; reset display size
		move.w	#checker_size4_start,checker_size4			; reset display size

		move.w	#checker_size0_start>>3,real_checker_size0	; reset fraction size
		move.w	#checker_size1_start>>3,real_checker_size1	; reset fraction size
		move.w	#checker_size2_start>>3,real_checker_size2	; reset fraction size
		move.w	#checker_size5_start>>3,real_checker_size5	; reset fraction size
		move.w	#checker_size3_start>>3,real_checker_size3	; reset fraction size
		move.w	#checker_size4_start>>3,real_checker_size4	; reset fraction size


;		move.w	yoff_source_checker3,yoff_source_checker4
;		move.w	yoff_source_checker5,yoff_source_checker3
;		move.w	yoff_source_checker2,yoff_source_checker5
;		move.w	yoff_source_checker1,yoff_source_checker2
;		move.w	yoff_source_checker0,yoff_source_checker1
;		move.w	yoff_source,yoff_source_checker0

		movem.w	yoff_source_checker0,d0-d4
		movem.w	d0-d4,yoff_source_checker1
		move.w	yoff_source,yoff_source_checker0

		movem.w	d0-d4,yoff_checker1
		move.w	yoff_source_checker0,yoff_checker0
;		move.w	yoff_source_checker1,yoff_checker1
;		move.w	yoff_source_checker2,yoff_checker2
;		move.w	yoff_source_checker5,yoff_checker5
;		move.w	yoff_source_checker3,yoff_checker3
;		move.w	yoff_source_checker4,yoff_checker4



;		move.w	xoff_source_checker3,xoff_source_checker4
;		move.w	xoff_source_checker5,xoff_source_checker3
;		move.w	xoff_source_checker2,xoff_source_checker5
;		move.w	xoff_source_checker1,xoff_source_checker2
;		move.w	xoff_source_checker0,xoff_source_checker1
;		move.w	xoff_source,xoff_source_checker0

		movem.w	xoff_source_checker0,d0-d4	
		movem.w	d0-d4,xoff_source_checker1
		move.w	xoff_source,xoff_source_checker0


		move.w	xoff_source_checker4,checker_xoff4
		move.w	xoff_source_checker3,checker_xoff3
		move.w	xoff_source_checker5,checker_xoff5
		move.w	xoff_source_checker2,checker_xoff2
		move.w	xoff_source_checker1,checker_xoff1
		move.w	xoff_source_checker0,checker_xoff0

;;		move.w	check_layer_disabled3,check_layer_disabled4
;		move.w	check_layer_disabled5,check_layer_disabled3
;		move.w	check_layer_disabled2,check_layer_disabled5
;		move.w	check_layer_disabled1,check_layer_disabled2
;		move.w	check_layer_disabled0,check_layer_disabled1
;		move.w	#1,check_layer_disabled0

		movem.w	check_layer_disabled0,d0-d4
		movem.w	d0-d4,check_layer_disabled1
		move.w	#1,check_layer_disabled0


		subq.w	#1,.waiter
		bge		.kkkk
;			move.b	#0,$ffffc123
				move.w	#0,check_layer_disabled0
				subq.w	#1,.layerdisable
				bge		.kkkk
					move.w	#-1,doAnim
.kkkk

		subq.w	#1,.skipwaiter
		bge		.sk	
			subq.w	#1,.skiptt
			blt		.sk
				move.w	#0,check_layer_disabled0
.sk



		lea		movement,a0
		add.w	.moveoff,a0
		move.w	(a0)+,yoff_source
		move.w	(a0)+,xoff_source
		add.w	#4,.moveoff
		cmp.w	#500*4,.moveoff
		bne		.kkkkx
			move.w	#0,.moveoff
.kkkkx
		rts
.moveoff		dc.w	0
.speedwaiter	dc.w	4
.skipwaiter		dc.w	60
.zoomsteps		dc.w	CHECKER_CYCLE_STEPS-1
.waiter			dc.w	CHECKER_EFFECT_CYCLES
.skipTimes		dc.w	0
.layerdisable	dc.w	2
.skiptt			dc.w	5



colorRamp	
	dc.w	$200,$200,$300,$300			;0	
	dc.w	$311,$311,$411,$411			;1
	dc.w	$422,$422,$522,$522			;2
	dc.w	$622,$622,$633,$633			;5
	dc.w	$733,$733,$744,$744			;3
	dc.w	$755,$755,$766,$766			;4

updateColors
	lea		colorRamp,a0
	add.w	.colorOff,a0
	move.w	(a0),d0
	move.w	8(a0),d1
	move.w	16(a0),d2
	move.w	24(a0),d3
	move.w	32(a0),d4
	move.w	40(a0),d5


	move.w	d0,$ffff8240+1*2				; pl 1					; -6

	move.w	d1,$ffff8240+2*2				; pl 1+2				; -5
	move.w	d1,$ffff8240+3*2

	move.w	d2,$ffff8240+4*2				; pl 3					; -4
	move.w	d2,$ffff8240+5*2				; pl 3+1

	move.w	d3,$ffff8240+6*2				; pl 3+2								a6
	move.w	d3,$ffff8240+7*2				; pl 3+2+1

	move.w	d4,$ffff8240+8*2				; pl 4					; -3
	move.w	d4,$ffff8240+10*2				; pl 4+2
	move.w	d4,$ffff8240+12*2				; pl 4+3
	move.w	d4,$ffff8240+14*2				; pl 4+3+2

	move.w	d5,$ffff8240+9*2				; pl 4+1				; -2		; cancel plane 1 at plane 4
	move.w	d5,$ffff8240+11*2				; pl 4+2+1							; or.w	pl4
	move.w	d5,$ffff8240+13*2				; pl 4+3+1							; or.w	pl1
	move.w	d5,$ffff8240+15*2				; pl 4+3+2+1

	subq.w	#1,.waiter
	bge		.ok
		move.w	current_checker_cycle_steps,d0
		lsr.w	d0
		subq.w	#1,d0
		move.w	d0,.waiter
;		move.w	#(CHECKER_CYCLE_STEPS/2)-1,.waiter
		add.w	#4,.colorOff
		cmp.w	#8,.colorOff
		bne		.ok
			move.w	#0,.colorOff
.ok
	rts
.waiter	dc.w	CHECKER_CYCLE_STEPS/2
.colorOff	dc.w	0



drawListPointers	
	REPT 50
		dc.w	0
	ENDR



copyUniqueLinesNew2									;8k ! generate this rout
	move.l	#drawListPointers,a0
.startNew		
	move.w	(a0)+,d7		; move index of datastruct
	beq		.endNew			; if 0, then quit
		move.w	d7,a1
		move.w	(a1)+,d7		; if we get here, we know for sure that we're not fucked.copyLoadRegsNew
		move.l	a1,usp
.firstColumn
	move.l	(a1)+,a6
	move.w	(a1)+,d6
;	blt		.endNew
	movem.l	120(a6),d0-d5/a2-a5
.jmpStart
	jmp		.fillStartColumn(pc,d6)
.fillStartColumn
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+120(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.nextColumn80
	move.l	(a1)+,a6
	move.w	(a1)+,d6
;---------------------------------------------------
	jmp		.fillStartColumn2(pc,d6)
.fillStartColumn2
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+120(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.nextColumn80
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	jmp		.jmpStart

.nextColumn80
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	80(a6),d0-d5/a2-a5
.jmpStart2
	jmp		.fillSecondColumn(pc,d6)
.fillSecondColumn
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+80(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.nextColumn40
	move.l	(a1)+,a6
	move.w	(a1)+,d6
;---------------------------------------------------
	jmp		.fillSecondColumn2(pc,d6)
.fillSecondColumn2
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+80(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.nextColumn40
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	jmp		.jmpStart2				;12		TODO test with unrolled loops, there is a max depth of this.....

.nextColumn40
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	40(a6),d0-d5/a2-a5
.jmpStart3
	jmp		.fillThirdColumn(pc,d6)
.fillThirdColumn
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+40(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.lastColumn
		move.l	(a1)+,a6
		move.w	(a1)+,d6
;---------------------------------------------------
	jmp		.fillThirdColumn2(pc,d6)
.fillThirdColumn2
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+40(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	cmp.w	a1,d7
	beq		.lastColumn
		move.l	(a1)+,a6
		move.w	(a1)+,d6
		jmp		.jmpStart3
;---------------------------------------------------
.lastColumn
	move.l	usp,a1
	move.l	(a1)+,a6
	move.w	(a1)+,d6
	movem.l	0(a6),d0-d5/a2-a5
.jmpStart4
	jmp		.fillLastColumn(pc,d6)
.fillLastColumn
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+0(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	nop
	cmp.w	a1,d7
	beq		.startNew
		move.l	(a1)+,a6
		move.w	(a1)+,d6
;---------------------------------------------------
	jmp		.fillLastColumn2(pc,d6)
.fillLastColumn2
y set (200-1)*160
		REPT 200
			movem.l	d0-d5/a2-a5,y+0(a6)			; copy 10 regs = 40 bytes, is 1/4th of a scanline
y set y-160
		ENDR
	nop
	cmp.w	a1,d7
	beq		.startNew
		move.l	(a1)+,a6
		move.w	(a1)+,d6
		jmp		.jmpStart4
.endNew
	rts

checkerMask	dc.w	0

populateDrawListStruct

	; - set up register sources, by size and xoff
	;		a0,a1,a2,a3		scanline data pointers and offset selection from preshift	; replace a0 with d4, use a0 for some list
	;		a4 is drawstructlist
	;		a5 local var
	;		a6	myYList

	;		d0,d1,d2,d3		local offsets, lines remaining
	;		d5 				y value offset
	;		d6				number of lines to be filled
	;		d7 				bitmask
.waiter
	tst.w	a7free
	beq		.okgo
		add.w	#$001,$ffff8240
	jmp		.waiter
.okgo

	move.w	checkerMask,d7
	lea		myHaxList,a0
		move.l	a0,usp
		or.w	#$2000,d7					; drawlistStruct address hardcoded; todo: SMC


	; original sizes
	move.w	checker_size0,a3				
	move.w	checker_size1,a1
	move.w	checker_size2,a2
	move.w	checker_size5,a6
	move.l	a6,usp


	; localsizes
	move.l	myHaxListPointer,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5

	move.w	checker_yoff0,d0
	move.w	checker_yoff1,d1
	move.w	checker_yoff2,d2
	move.w	checker_yoff3,d3
	move.w	checker_yoff4,d4
	move.w	checker_yoff5,d5

	lea		drawListPointers,a6
	IFEQ MAXCOUNT
		move.w	#0,count
	ENDC

	; use y-offset to determine inverted and final local sizes
	; currently omitted
	move.l	a7,savedA7
	move.l	screenpointer2,a7			; harhar
	add.w	#160,a7	
	move.w	#EFFECT_HEIGHT*8,d6					; number of lines to be filled	*2, because we premult by 2
	; in use:
	;	usp,a0,a4,a5,a6
	;	d0,d1,d2,d3,d4,d5,d6,d7
	;	a1,a2,a3
	jmp		determineSmallestNumber6

;savedA7	dc.l	0





shiftChecker16Places
;	IFEQ	OPTIMIZED_SIZE
;		lea		optimized_lines,a0
;		move.l	my16versionsPointer,a1
;		move.w	#NUMBER_OF_LINES-1,d7
;.copy
;.o set 0
;	REPT 2
;		movem.l	(a0)+,d1-d6/a2/a3/a4/a5					;92
;		movem.l	d1-d6/a2/a3/a4/a5,.o(a1)					;88
;.o set .o+40
;	ENDR
;	lea		80(a1),a1
;	sub.w	#20*4,a0
;	REPT 4
;		movem.l	(a0)+,d1-d5
;		not.l	d1
;		not.l	d2
;		not.l	d3
;		not.l	d4
;		not.l	d5
;		move.l	d1,(a1)+
;		move.l	d2,(a1)+
;		move.l	d3,(a1)+
;		move.l	d4,(a1)+
;		move.l	d5,(a1)+
;	ENDR
;	dbra	d7,.copy
;
;
;	ELSE
	move.l	my16versionsPointer,a0
	add.l	#27200*2,a0
	move.l	my16versionsPointer,a1
	move.l	#80*2*NUMBER_OF_LINES,d0		; this is the offset per 16 versions
; first we copy the inital version
	move.w	#NUMBER_OF_LINES-1,d7
.copy
.o set 0
	REPT 2
		movem.l	(a0)+,d1-d6/a2/a3/a4/a5					;92
		movem.l	d1-d6/a2/a3/a4/a5,.o(a1)					;88
.o set .o+40
	ENDR
	lea		80(a1),a1
	sub.w	#20*4,a0
	REPT 4
		movem.l	(a0)+,d1-d5
		not.l	d1
		not.l	d2
		not.l	d3
		not.l	d4
		not.l	d5
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.l	d3,(a1)+
		move.l	d4,(a1)+
		move.l	d5,(a1)+
	ENDR
	dbra	d7,.copy
;	ENDC

; now we have the first 256 entires copies, restore a0
;	lea	my16versions,a0		; this contains the first 512 lines of 40 bytes
	move.l	my16versionsPointer,a0
	move.w	#15-1,d7
.doOneX
	move.w	#NUMBER_OF_LINES-1,d6
.doShift
	moveq	#0,d0
	roxr.w	d0
	; roxr one line
	REPT 4
	movem.l	(a0)+,d0-d4
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	ENDR
	moveq	#0,d0
	roxr.w	d0
	; roxr the negative one
	REPT 4
	movem.l	(a0)+,d0-d4
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	move.l	d0,(a1)+
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	ENDR

	dbra	d6,.doShift
	dbra	d7,.doOneX

;	sub.l	my16versionsPointer,a1

	rts


copySmallestNumber
	IFEQ	PACKEDSTUFF
	lea		treecodecrk,a0
	lea		determineSmallestNumber6,a1			;$3000
	jsr		cranker
	ELSE
	lea		treestart,a0		;source
	lea		$3000,a1						;dest
	move.l	#treeend,d7
	sub.l	#treestart,d7
	lsr.w	#1,d7
	subq.w	#1,d7
.copy
		move.w	(a0)+,(a1)+
		dbra	d7,.copy

	ENDC
	rts


copyDrawCode
	IFEQ	PACKEDSTUFF
	lea		drawcodecrk,a0
	lea		scanLineCode,a1
	jsr		cranker
	move.l	#ppiss,scanLineCode+2
	move.l	#dlp,scanLineCode+$24+2
	ELSE
	lea 	drawStart,a0
	lea		scanLineCode,a1
	move.l	#drawEnd,d7
	sub.l	#drawStart,d7
	lsr.w	#1,d7
	subq.w	#1,d7
.copy
		move.w	(a0)+,(a1)+
		dbra	d7,.copy
	ENDC
	rts



	SECTION DATA
; TODO: genreate this
myHaxList									; when done together thisis: 256*8 = 2048 b
o set 0
x set 0
;	REPT NUMBER_OF_LINES
	REPT 340
		dc.w	(-o+200*2)*3
		dc.w	x
		dc.w	x
		dc.w	(-o+200*2)*3
o set o+2
x set x+160
	ENDR

; 19*16*4		= 1216
; move this to lower; free ze bytes!
;myXposList					; 
;x set 20+2*9
;	REPT 22												; 22*16*8 = 2816
;bufferoff	set 0
;		REPT 16
;			dc.l	x+bufferoff
;			dc.l	x+bufferoff
;bufferoff	set bufferoff+80*2*NUMBER_OF_LINES
;		ENDR	
;x set x-2
;	ENDR

xposPointer		ds.l	1			;2816

genXposList
	move.l	xposPointer,a0
	move.l	#20+2*9,d0
	move.l	#80*2*NUMBER_OF_LINES,d1		; inc
	move.w	#22-1,d7
.ol
	move.l	d0,d6		; bufferoff+x
	REPT 16
		move.l	d6,(a0)+
		move.l	d6,(a0)+
		add.l	d1,d6
	ENDR
	subq.l	#2,d0
	dbra	d7,.ol


;	lea		myXposList,a0
;	move.l	xposPointer,a1
;	move.w	#2816/4-1,d7
;.ddd
;		cmp.l	(a0)+,(a1)+
;		beq		.kkk
;			move.b	#0,$ffffc123
;.kkk
;	dbra	d7,.ddd
	rts

;--------------
;DEMOPAL - colorlist of colors non-fade, so the list of colors for the flythrough
;--------------		
	dc.w	$622,$732,$752,$772,$667,$466
	dc.w	$355,$254,$143,$033,$022,$112
colors	
	REPT 8
	dc.w	$212,$312,$422,$622,$732,$752		
	dc.w	$772,$667,$466,$355,$254,$143		
	dc.w	$033,$022,$112,$212,$312,$422
	dc.w	$622,$732,$752,$772,$667,$466
	dc.w	$355,$254,$143,$033,$022,$112		;60*8 = 480
	ENDR
colors2
; just +$111,+$222,+$333
;	REPT 8
;	dc.w	$323,$423,$533,$733,$743,$763		
;	dc.w	$773,$777,$577,$466,$365,$254		
;	dc.w	$144,$133,$223,$323,$423,$533
;	dc.w	$733,$743,$763,$773,$777,$577
;	dc.w	$466,$365,$254,$144,$133,$223		;60*8 = 480
;	ENDR
;
;	REPT 8
;	dc.w	$434,$534,$644,$744,$754,$774		
;	dc.w	$774,$777,$677,$577,$476,$365		
;	dc.w	$255,$244,$334,$434,$534,$644
;	dc.w	$744,$754,$774,$774,$777,$677
;	dc.w	$577,$476,$365,$255,$244,$334		;60*8 = 480
;	ENDR
;
;	REPT 8
;	dc.w	$545,$645,$755,$755,$765,$775		
;	dc.w	$775,$777,$777,$677,$577,$476		
;	dc.w	$366,$355,$445,$545,$645,$755
;	dc.w	$755,$765,$775,$775,$777,$777
;	dc.w	$677,$577,$476,$366,$355,$445		;60*8 = 480
;	ENDR

	REPT 8
	dc.w	$313,$412,$522,$722,$743,$763		
	dc.w	$773,$777,$477,$366,$265,$154		
	dc.w	$044,$033,$223,$313,$412,$522
	dc.w	$722,$743,$763,$773,$777,$477
	dc.w	$366,$265,$154,$044,$033,$223		;60*8 = 480
	ENDR

	REPT 8
	dc.w	$414,$513,$633,$733,$754,$764		
	dc.w	$774,$777,$577,$377,$276,$165		
	dc.w	$055,$044,$334,$414,$513,$633
	dc.w	$733,$754,$764,$774,$777,$577
	dc.w	$377,$276,$165,$055,$044,$334		;60*8 = 480
	ENDR

	REPT 8
	dc.w	$525,$624,$744,$744,$765,$775		
	dc.w	$775,$777,$677,$477,$377,$276		
	dc.w	$166,$055,$445,$525,$624,$744
	dc.w	$744,$765,$775,$775,$777,$677
	dc.w	$477,$377,$276,$166,$055,$445		;60*8 = 480
	ENDR



offList
	dc.w	0
	dc.w	480
	dc.w	480
	dc.w	960
	dc.w	960
	dc.w	1440
	dc.w	1440
	dc.w	1440
	dc.w	1440
	dc.w	960
	dc.w	960
	dc.w	480
	dc.w	480
	dc.w	0
offListOff	dc.w	26

colorOff	dc.w	0

doColors
	lea		colors2,a0
	sub.w	colorOffSet,a0

	subq.w	#1,.waiterrr
	bge		.kkk
		lea		offList,a1
		add.w	offListOff,a1
		move.w	(a1),.localOff
		subq.w	#2,offListOff
		bge		.kkk
			move.w	#CHECKER_FLASH_INTERVAL_VBL,.waiterrr
			move.w	#26,offListOff
.kkk
	add.w	.localOff,a0

	move.l	(a0)+,d0
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.l	(a0)+,d4
	lea		$ffff8240+2,a1

	move.l	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d4,(a1)+
	move.l	d4,(a1)+
	move.l	d4,(a1)+

	rts
.localOff	dc.w	0	
.waiter		dc.w	CHECKER_CYCLE_STEPS-2
.waiterrr	dc.w	CHECKER_FLASH_WAITER_VBL	
colorOffSet	dc.w	0

;--------------
;DEMOPAL - FADE CHECKER list; colorlist of the checkerboard layers, F
;--------------		
; format:
;	dcb.w	x,y		; x times color y, where x is the number of thresholds the color `spans'
;	y is the color used for these spans
;	each `threshold' means a `size-layer'
colorTable
	dcb.w	3,$112	;3
	dcb.w	3,$212	;6
	dcb.w	3,$212	;6
	dcb.w	3,$312	;9
	dcb.w	3,$412	;12
	dcb.w	5,$512	;17
	dcb.w	6,$612	;23
	dcb.w   6,$730	;29
	dcb.w	6,$740	;35
	dcb.w	5,$750	;40
	dcb.w	5,$760	;45
	dcb.w	4,$770	;49
	dcb.w	3,$771	;52
	dcb.w	2,$772	;54
	dcb.w	2,$773	;56
	dcb.w	2,$774	;58
	dcb.w	2,$775	;60
	dcb.w	2,$776	;62
	dcb.w	2,$777	;64
	dc.w	-1


generateColors
	move.l	sizePalettePointer,a0
	lea		thresholds,a1
	moveq	#0,d0
	lea		colorTable,a2

.again
	move.w	(a1)+,d7			;get threshold
	blt		.exit
	lsr.w	#2,d7
	move.w	(a2)+,d6			;get color
.loop
		move.w	d6,(a0)+
		addq.w	#2,d0
		cmp.w	d0,d7
		bgt		.loop
		jmp		.again
.exit
	rts

; list of thresholds that marks the sizes
thresholds
	dc.w	$b8
	dc.w	$c0
	dc.w	$c8
	dc.w	$d0
	dc.w	$d8
	dc.w	$e0
	dc.w	$e8
	dc.w	$f0
	dc.w	$f8
	dc.w	$100
	dc.w	$108
	dc.w	$118
	dc.w	$120
	dc.w	$128
	dc.w	$130
	dc.w	$138
	dc.w	$140
	dc.w	$148
	dc.w	$158
	dc.w	$160
	dc.w	$168
	dc.w	$170
	dc.w	$178
	dc.w	$180
	dc.w	$188
	dc.w	$190
	dc.w	$198
	dc.w	$1a0
	dc.w	$1a8
	dc.w	$1b0
	dc.w	$1b8
	dc.w	$1c0
	dc.w	$1e0
	dc.w	$200
	dc.w	$220
	dc.w	$240
	dc.w	$260
	dc.w	$280
	dc.w	$2a0
	dc.w	$2c0
	dc.w	$2f8
	dc.w	$300
	dc.w	$338
	dc.w	$340
	dc.w	$378
	dc.w	$3b8
	dc.w	$3f0
	dc.w	$3f8
	dc.w	$430
	dc.w	$438
	dc.w	$470
	dc.w	$478
	dc.w	$4b0
	dc.w	$550
	dc.w	$558
	dc.w	$5f8
	dc.w	$698
	dc.w	$6a0
	dc.w	$740
	dc.w	$7e0
	dc.w	$7e8
	dc.w	$888
	dc.w	$928
	dc.w	$930
	dc.w	$940
	dc.w	-1







fixPalette
;	rts
;	lea		sizePalette,a0
	move.l	sizePalettePointer,a0

	move.w	checker_size0,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),$ffff8240+1*2			; color

	move.w	checker_size1,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),d0
	move.w	d0,$ffff8240+2*2
	move.w	d0,$ffff8240+3*2

	move.w	checker_size2,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),d0
	move.w	d0,$ffff8240+4*2
	move.w	d0,$ffff8240+5*2

	move.w	checker_size5,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),d0
	move.w	d0,$ffff8240+6*2
	move.w	d0,$ffff8240+7*2

	move.w	checker_size3,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),d0
	move.w	d0,$ffff8240+8*2
	move.w	d0,$ffff8240+10*2
	move.w	d0,$ffff8240+12*2
	move.w	d0,$ffff8240+14*2

	move.w	checker_size4,d0
	lsr.w	#2,d0
	move.w	(a0,d0.w),d0
	move.w	d0,$ffff8240+9*2	
	move.w	d0,$ffff8240+11*2	
	move.w	d0,$ffff8240+13*2	
	move.w	d0,$ffff8240+15*2	
	rts



;-----------

initDrawListStruct
	lea		drawlistStruct1,a0
	move.w	#0,d0
	move.w	#64-1,d7
.loop
		move.w	d0,(a0)
		lea		STRUCTSIZE(a0),a0
		dbra	d7,.loop
	rts

resetDrawListStructNew
	lea		drawListPointers,a1				; so I load the pointers
	move.w	#0,d0
	REPT 50
		move.w	(a1)+,d1						; get a value from the list
		beq		quitResetting					; is it -1? then end of list
			move.w	d1,a2
			move.w	d0,(a2)				; set used pointer to -1
	ENDR
quitResetting
	rts

doMaxCountMonitor	macro
	IFEQ	MAXCOUNT
	addq.w	#1,count
	ENDC
	endm

; 	usp
;	a0
;	a4
;	a5
;	a6
markScanLineChange macro
	; first we load the appropriate table thing, which basically means:
	;	- before changing mask, use mask to lookup t
	move.l	\1,a0					;4
	move.w	d7,a4					;4
	move.w	(a4),a5					;8
	move.w	a5,\1					;4	
	bne		.notFirstTime\@
		; so its our first time, make sure the a5 pointer is not -1, but is set correctly
		lea		2(a4),a5			;8
		move.w	d7,(a6)+			;8
.notFirstTime\@
	move.l	a7,(a5)+				;12	
	move.w	(a0)+,(a5)+				;12
	move.w	a5,(a4)					;8
	add.w	(a0)+,a7				;8		--> 72
	endm

a7substitute	ds.l	1

	IFNE	PACKEDSTUFF
treestart
;determineSmallestNumber6
	cmp.w	d0,d1												
	bgt.w	.d0_smallest_d1_done								
	beq.w	.d0_d1_equal										
.d1_smallest_d0_done											;done
		cmp.w	d1,d2											
		bgt.w	.d1_smallest_d0_d2_done							;done			
		beq		.d1_d2_smallest_d0_done							;done				
.d2_smallest_d0_d1_done											;done					
			cmp.w	d2,d3											 
			bgt.w	.d2_smallest_d0_d1_d3_done					;done		
			beq.w	.d2_d3_smallest_d0_d1_done					;done				
.d3_smallest_d0_d1_d2_done										;done				
				cmp.w	d3,d4	 
				bgt		.d3_smallest_d0_d1_d2_d4_done			;done				
				beq		.d3_d4_smallest_d0_d1_d2_done			;done		
.d4_smallest_d0_d1_d2_d3_done		
					cmp.w	d4,d5
					bgt		.d4_smallest_d0_d1_d2_d3_d5_done	;done
					beq		.d4_d5_smallest_d0_d1_d2_d3_done	;done
.d5_smallest_d0_d1_d2_d3_d4_done								;done
	sub.w	d5,d6		; 12 loss
	ble		.maherp
		sub.w	d5,d0
		sub.w	d5,d1
		sub.w	d5,d2
		sub.w	d5,d3
		sub.w	d5,d4
				markScanLineChange d5
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.maherp
	add.w	d6,d5
			markScanLineChange d5
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d4_d5_smallest_d0_d1_d2_d3_done								; done
	sub.w	d4,d6
	ble		.end1
		sub.w	d4,d0
		sub.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
				markScanLineChange d4
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end1
	add.w	d6,d4
			markScanLineChange d4
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d4_smallest_d0_d1_d2_d3_d5_done								; done
	sub.w	d4,d6
	ble		.end13
		sub.w	d4,d0
		sub.w	d4,d1
		sub.w	d4,d2
		sub.w	d4,d3
		sub.w	d4,d5
				markScanLineChange d4
		move.w	checker_size4,d4
		eor.w	#%010000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end13
	add.w	d6,d4
			markScanLineChange d4
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d3_smallest_d0_d1_d2_d4_done									; done
	cmp.w	d3,d5
	bgt		.d3_smallest_d0_d1_d2_d4_d5_done					; done
	beq		.d3_d5_smallest_d0_d1_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d3_d5_smallest_d0_d1_d2_d4_done								; done
	sub.w	d3,d6
	ble		.end2
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d4
				markScanLineChange d3
		move.w	checker_size3,d3
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end2
	add.w	d6,d3
			markScanLineChange d3
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d3_smallest_d0_d1_d2_d4_d5_done								; done
	sub.w	d3,d6
	ble		.end233
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d4
		sub.w	d3,d5
				markScanLineChange d3
		move.w	checker_size3,d3
		eor.w	#%001000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end233
	add.w	d6,d3
			markScanLineChange d3
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d3_d4_smallest_d0_d1_d2_done									; done
	cmp.w	d3,d5
	bgt		.d3_d4_smallest_d0_d1_d2_d5_done					; done
	beq		.d3_d4_d5_smallest_d0_d1_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d3_d4_smallest_d0_d1_d2_d5_done								; done	
	sub.w	d3,d6
	ble		.end3
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
		sub.w	d3,d5
				markScanLineChange d3
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end3
	add.w	d6,d3
			markScanLineChange d3
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d3_d4_d5_smallest_d0_d1_d2_done								; done									
	sub.w	d3,d6
	ble		.end3a
		sub.w	d3,d0
		sub.w	d3,d1
		sub.w	d3,d2
				markScanLineChange d3
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111000*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.end3a
	add.w	d6,d3
			markScanLineChange d3
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_smallest_d0_done											; done		
	cmp.w	d1,d3
	bgt.s	.d1_d2_smallest_d0_d3_done							; done												
	blt		.d3_smallest_d0_d1_d2_done							; done		
;	bra		.d1_d2_d3_smallest_d0_done							; done		
.d1_d2_d3_smallest_d0_done										; done			
		cmp.w	d1,d4		
		bgt		.d1_d2_d3_smallest_d0_d4_done						; done								
		beq		.d1_d2_d3_d4_smallest_d0_done						; done	
		bra		.d4_smallest_d0_d1_d2_d3_done						; done	
;------------------------------------------------------------
.d1_d2_smallest_d0_d3_done										; done											
	cmp.w	d1,d4
	bgt		.d1_d2_smallest_d0_d3_d4_done						; done									
	beq		.d1_d2_d4_smallest_d0_d3_done						; done						
	bra		.d4_smallest_d0_d1_d2_d3_done						; done											
;------------------------------------------------------------
.d1_d2_smallest_d0_d3_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_smallest_d0_d3_d4_d5_done					; done
	beq		.d1_d2_d5_smallest_d0_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------		
.d1_d2_d5_smallest_d0_d3_d4_done
	sub.w	d1,d6
	ble		.ok7z
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok7z
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------									
.d1_d2_smallest_d0_d3_d4_d5_done								; done
	sub.w	d1,d6
	ble		.ok7y
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
		eor.w	#%000110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok7y
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_d4_smallest_d0_d3_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d4_smallest_d0_d3_d5_done					; done
	beq		.d1_d2_d4_d5_smallest_d0_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d2_d4_d5_smallest_d0_d3_done								; done
	sub.w	d1,d6
	ble		.ok777z
		sub.w	d1,d0
		sub.w	d1,d3
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777z
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_d4_smallest_d0_d3_d5_done								; done
	sub.w	d1,d6
	ble		.ok777
		sub.w	d1,d0
		sub.w	d1,d3
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size4,d4
		eor.w	#%010110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts						
;------------------------------------------------------------		
.d1_d2_d3_smallest_d0_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d3_smallest_d0_d4_d5_done					; done
	beq		.d1_d2_d3_d5_smallest_d0_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d1_d2_d3_d5_smallest_d0_d4_done								; done								
	sub.w	d1,d6
	ble.s	.ok2z
		sub.w	d1,d0							
		sub.w	d1,d4							
				markScanLineChange d1
		move.w	a1,d1							
		move.w	a2,d2
		move.w	checker_size3,d3
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok2z
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_d3_smallest_d0_d4_d5_done								; done								
	sub.w	d1,d6
	ble.s	.ok2
		sub.w	d1,d0							
		sub.w	d1,d4							
		sub.w	d1,d5				
				markScanLineChange d1
		move.w	a1,d1							
		move.w	a2,d2
		move.w	checker_size3,d3
		eor.w	#%001110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok2
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_d3_d4_smallest_d0_done									; done
	cmp.w	d1,d5
	bgt		.d1_d2_d3_d4_smallest_d0_d5_done					; done
	beq		.d1_d2_d3_d4_d5_smallest_d0_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d1_d2_d3_d4_d5_smallest_d0_done								; done
	sub.w	d1,d6
	ble		.ok222z
		sub.w	d1,d0
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok222z
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d2_d3_d4_smallest_d0_d5_done								; done
	sub.w	d1,d6
	ble		.ok222
		sub.w	d1,d0
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011110*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok222
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_d3_done										; done				
	cmp.w	d1,d4	
	bgt		.d1_smallest_d0_d2_d3_d4_done						; done			
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;	bra		.d1_d4_smallest_d0_d2_d3_done
.d1_d4_smallest_d0_d2_d3_done													
	cmp.w	d1,d5
	bgt		.d1_d4_smallest_d0_d2_d3_d5_done					; done
	beq		.d1_d4_d5_smallest_d0_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d4_d5_smallest_d0_d2_d3_done								; done
	sub.w	d1,d6
	ble.s	.zok3
		sub.w	d1,d0							
		sub.w	d1,d2
		sub.w	d1,d3
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110010*STRUCTSIZE,d7			
		jmp		determineSmallestNumber6
.zok3
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d4_smallest_d0_d2_d3_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok3
		sub.w	d1,d0							
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size4,d4
		eor.w	#%010010*STRUCTSIZE,d7			
		jmp		determineSmallestNumber6
.ok3
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_d3_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_smallest_d0_d2_d3_d4_d5_done					; done
	beq		.d1_d5_smallest_d0_d2_d3_d4_done					; done	
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;-----------------------------------------------------------
.d1_d5_smallest_d0_d2_d3_d4_done								; done
	sub.w	d1,d6
	ble.s	.zok444
		sub.w	d1,d0
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok444
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;-----------------------------------------------------------
.d1_smallest_d0_d2_d3_d4_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok444
		sub.w	d1,d0
		sub.w	d1,d2
		sub.w	d1,d3
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		eor.w	#%000010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok444
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_smallest_d0_d2_done											; done					
	cmp.w	d1,d3
	bgt		.d1_smallest_d0_d2_d3_done							; done				
	blt.w	.d3_smallest_d0_d1_d2_done							; done						
;------------------------------------------------------------
.d1_d3_smallest_d0_d2_done										; done										
	cmp.w	d1,d4
	bgt		.d1_d3_smallest_d0_d1_d4_done						; done	
	beq		.d1_d3_d4_smallest_d0_d2_done						; done					
	bra		.d4_smallest_d0_d1_d2_d3_done						; done						
;------------------------------------------------------------
.d1_d3_d4_smallest_d0_d2_done									; done
	cmp.w	d1,d5
	bgt		.d1_d3_d4_smallest_d0_d2_d5_done					; done
	beq		.d1_d3_d4_d5_smallest_d0_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------												
.d1_d3_d4_d5_smallest_d0_d2_done								; done
	sub.w	d1,d6
	ble.s	.ok4aab
		sub.w	d1,d0
		sub.w	d1,d2	
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4aab
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d3_d4_smallest_d0_d2_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok4
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d1_d3_smallest_d0_d1_d4_done									; done
	cmp.w	d1,d5
	bgt		.d1_d3_smallest_d0_d2_d4_d5_done					; done
	beq		.d1_d3_d5_smallest_d0_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d1_d3_d5_smallest_d0_d2_d4_done								; done
	sub.w	d1,d6
	ble.s	.ok4aaac
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d4
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4aaac
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts	
;------------------------------------------------------------
.d1_d3_smallest_d0_d2_d4_d5_done								; done
	sub.w	d1,d6
	ble.s	.ok4a
		sub.w	d1,d0
		sub.w	d1,d2	
		sub.w	d1,d4
		sub.w	d1,d5
				markScanLineChange d1
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%001010*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok4a
	add.w	d6,d1
			markScanLineChange d1
			move.l	savedA7,a7
	rts	
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_done										; done				
	cmp.w	d2,d4						
	bgt		.d2_smallest_d0_d1_d3_d4_done						; done				
	beq		.d2_d4_smallest_d0_d1_d3_done						; done									
	bra		.d4_smallest_d0_d1_d2_d3_done						; done							
;------------------------------------------------------------
.d2_d4_smallest_d0_d1_d3_done									; done
	cmp.w	d2,d5
	bgt		.d2_d4_smallest_d0_d1_d3_d5_done					; done
	beq		.d2_d4_d5_smallest_d0_d1_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d4_d5_smallest_d0_d1_d3_done								; done
	sub.w	d2,d6
	ble		.ok55a
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d5
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok55a
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_d4_smallest_d0_d1_d3_d5_done								; done
	sub.w	d2,d6
	ble		.ok55
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d5
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size4,d4
		eor.w	#%010100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok55
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_d4_done									; done
	cmp.w	d2,d5
	bgt		.d2_smallest_d0_d1_d3_d4_d5_done					; done
	beq		.d2_d5_smallest_d0_d1_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d5_smallest_d0_d1_d3_d4_done								; done
	sub.w	d2,d6
	ble.s	.ok5x
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d4
				markScanLineChange d2
		move.w	a2,d2
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok5x
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_smallest_d0_d1_d3_d4_d5_done								; done
	sub.w	d2,d6
	ble.s	.ok5
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d3
		sub.w	d2,d4
		sub.w	d2,d5
				markScanLineChange d2
		move.w	a2,d2
		eor.w	#%000100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok5
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_smallest_d1_done											; done				
	cmp.w	d0,d2												
	bgt.s	.d0_smallest_d1_d2_done								; done						
	blt.w	.d2_smallest_d0_d1_done								; done						
;	bra.s	.d0_d2_smallest_d1_done								; done	
		cmp.w	d0,d3
		bgt		.d0_d2_smallest_d1_d3_done							; done	
		blt.w	.d3_smallest_d0_d1_d2_done							; done
		bra.w	.d0_d2_d3_smallest_d1_done							; done						
;------------------------------------------------------------
.d0_d1_equal													; done
	cmp.w	d1,d2
	bgt.w	.d0_d1_smallest_d2_done								; done				
	blt.w	.d2_smallest_d0_d1_done								; done			
;	bra.w	.d0_d1_d2_equal										; done				
		cmp.w	d2,d3
		bgt.w	.d0_d1_d2_smallest_d3_done							; done
		blt.w	.d3_smallest_d0_d1_d2_done							; done						
		bra.w	.d0_d1_d2_d3_equal									; done	
;------------------------------------------------------------
.d0_smallest_d1_d2_done											; done
	cmp.w	d0,d3												
	bgt		.d0_smallest_d1_d2_d3_done							; done	
	blt.w	.d3_smallest_d0_d1_d2_done							; done	
;	bra.w	.d0_d3_smallest_d1_d2_done							; done		
;.d0_d3_smallest_d1_d2_done										; done			
		cmp.w	d0,d4
		bgt		.d0_d3_smallest_d1_d2_d4_done						; done			
		blt		.d4_smallest_d0_d1_d2_d3_done						; done
;.d0_d3_d4_smallest_d1_d2_done
	cmp.w	d0,d5
			bgt		.d0_d3_d4_smallest_d1_d2_d5_done					; done
			beq		.d0_d3_d4_d5_smallest_d1_d2_done					; done
			bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_done										; done												
	cmp.w	d2,d4
	bgt		.d2_d3_smallest_d0_d1_d4_done						; done									
	beq		.d2_d3_d4_smallest_d0_d1_done						; done							
;	bra		.d4_smallest_d0_d1_d2_d3_done						; done	
		cmp.w	d4,d5
		bgt		.d4_smallest_d0_d1_d2_d3_d5_done				; done
		beq		.d4_d5_smallest_d0_d1_d2_d3_done				; done
		bra		.d5_smallest_d0_d1_d2_d3_d4_done				; done
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_d4_done									; done
	cmp.w	d2,d5
	bgt		.d2_d3_smallest_d0_d1_d4_d5_done					; done
	beq		.d2_d3_d5_smallest_d0_d1_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_d5_smallest_d0_d1_d4_done								; done			
	sub.w	d2,d6
	ble.s	.ok777a
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d4
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size3,d3
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok777a
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_d3_smallest_d0_d1_d4_d5_done								; done		
	sub.w	d2,d6
	ble.s	.ok77
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d4
		sub.w	d2,d5
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size3,d3
		eor.w	#%001100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok77
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_d3_d4_smallest_d0_d1_done									; done
	cmp.w	d2,d5
	bgt		.d2_d3_d4_smallest_d0_d1_d5_done					; done
	beq		.d2_d3_d4_d5_smallest_d0_d1_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d2_d3_d4_d5_smallest_d0_d1_done								; done
	sub.w	d2,d6
	ble.s	.ok888
		sub.w	d2,d0
		sub.w	d2,d1
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok888
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d2_d3_d4_smallest_d0_d1_d5_done								; done
	sub.w	d2,d6
	ble.s	.ok88
		sub.w	d2,d0
		sub.w	d2,d1
		sub.w	d2,d5
				markScanLineChange d2
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011100*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok88
	add.w	d6,d2
			markScanLineChange d2
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d2_smallest_d1_done											; done
	cmp.w	d0,d3
	bgt		.d0_d2_smallest_d1_d3_done							; done	
	blt.w	.d3_smallest_d0_d1_d2_done							; done
	bra.w	.d0_d2_d3_smallest_d1_done							; done						
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_done										; done	
	cmp.w	d0,d4
	bgt		.d0_smallest_d1_d2_d3_d4_done						; done	
	beq		.d0_d4_smallest_d1_d2_d3_done						; done
	bra		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------
.d0_d4_smallest_d1_d2_d3_done									; done	
	cmp.w	d0,d5
	bgt		.d0_d4_smallest_d1_d2_d3_d5_done					; done
	beq		.d0_d4_d5_smallest_d1_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d4_d5_smallest_d1_d2_d3_done								; done
	sub.w	d0,d6
	ble.s	.ok100
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size4,d4
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok100
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d4_smallest_d1_d2_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.zok100
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size4,d4
		eor.w	#%010001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok100
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_smallest_d1_d2_d3_d4_d5_done					; done
	beq		.d0_d5_smallest_d1_d2_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d5_smallest_d1_d2_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok10
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok10
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_smallest_d1_d2_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok10
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		eor.w	#%000001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok10
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_done											; done
	cmp.w	d0,d3
	bgt.w	.d0_d1_smallest_d2_d3_done							; done
	blt.w	.d3_smallest_d0_d1_d2_done							; done
	bra.w	.d0_d1_d3_smallest_d2_done							; done
;------------------------------------------------------------
.d0_d1_d2_equal													; done
	cmp.w	d2,d3
	bgt.w	.d0_d1_d2_smallest_d3_done							; done
	blt.w	.d3_smallest_d0_d1_d2_done							; done						
	bra.w	.d0_d1_d2_d3_equal									; done	
;------------------------------------------------------------
.d0_d2_smallest_d1_d3_done										; done				
	cmp.w	d0,d4
	bgt		.d0_d2_smallest_d1_d3_d4_done						; done						
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------
.d0_d2_d4_smallest_d1_d3_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d4_smallest_d1_d3_d5_done					; done
	beq		.d0_d2_d4_d5_smallest_d1_d3_done					; done
	blt		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d4_d5_smallest_d1_d3_done
	sub.w	d0,d6
	ble.s	.ok82
		sub.w	d0,d1
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok82
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------	
.d0_d2_d4_smallest_d1_d3_d5_done
	sub.w	d0,d6
	ble.s	.aok82
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size4,d4
		eor.w	#%010101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.aok82
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d2_smallest_d1_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_smallest_d1_d3_d4_d5_done					; done
	beq		.d0_d2_d5_smallest_d1_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d5_smallest_d1_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok8
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok8
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------	
.d0_d2_smallest_d1_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok8
		sub.w	d0,d1
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		eor.w	#%000101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok8
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_done										; done			
	cmp.w	d0,d4
	bgt		.d0_d3_smallest_d1_d2_d4_done						; done			
	blt		.d4_smallest_d0_d1_d2_d3_done						; done				
;------------------------------------------------------------
.d0_d3_d4_smallest_d1_d2_done									; done
	cmp.w	d0,d5
	bgt		.d0_d3_d4_smallest_d1_d2_d5_done					; done
	beq		.d0_d3_d4_d5_smallest_d1_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d3_d4_d5_smallest_d1_d2_done								; done
	sub.w	d0,d6
	ble.s	.zzok11
		sub.w	d0,d1
		sub.w	d0,d2
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zzok11
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d3_d4_smallest_d1_d2_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok11
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok11
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d3_smallest_d1_d2_d4_d5_done					; done
	beq		.d0_d3_d5_smallest_d1_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d3_d5_smallest_d1_d2_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok111
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		move.w	checker_size3,d3
		eor.w	#%101001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok111
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts	
;------------------------------------------------------------
.d0_d3_smallest_d1_d2_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok111
		sub.w	d0,d1
		sub.w	d0,d2
		sub.w	d0,d4
		sub.w	d0,d5

				markScanLineChange d0
		move.w	a3,d0
		move.w	checker_size3,d3
		eor.w	#%001001*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok111
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts	
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_done										; done						
	cmp.w	d0,d4
	bgt		.d0_d1_smallest_d2_d3_d4_done						; done	
	blt		.d4_smallest_d0_d1_d2_d3_done						; done						
;------------------------------------------------------------
.d0_d1_d4_smallest_d2_d3_done
	cmp.w	d0,d5
	bgt		.d0_d1_d4_smallest_d2_d3_d5_done					; done
	beq		.d0_d1_d4_d5_smallest_d2_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d4_d5_smallest_d2_d3_done
	sub.w	d0,d6
	ble.s	.zok12a
		sub.w	d0,d2
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%110011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok12a
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d4_smallest_d2_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok12a
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size4,d4
		eor.w	#%010011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok12a
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_smallest_d2_d3_d4_d5_done					; done
	beq		.d0_d1_d5_smallest_d2_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d5_smallest_d2_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.ok12
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%100011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok12
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_smallest_d2_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.zok12
		sub.w	d0,d2
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		eor.w	#%000011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok12
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_done										; done							
	cmp.w	d0,d4
	bgt		.d0_d1_d3_smallest_d2_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done
;------------------------------------------------------------	
.d0_d1_d3_d4_smallest_d2_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d3_d4_smallest_d2_d5_done					; done
	beq		.d0_d1_d3_d4_d5_smallest_d2_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d1_d3_d4_d5_smallest_d2_done								; done
	sub.w	d0,d6
	ble.s	.ok133z
		sub.w	d0,d2
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok133z
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d3_d4_smallest_d2_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok133
		sub.w	d0,d2
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok133
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d3_smallest_d2_d4_d5_done					; done
	beq		.d0_d1_d3_d5_smallest_d2_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d3_d5_smallest_d2_d4_done								; done					
	sub.w	d0,d6
	ble.s	.aok13
		sub.w	d0,d2
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%101011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.aok13
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d3_smallest_d2_d4_d5_done								; done					
	sub.w	d0,d6
	ble.s	.ok13
		sub.w	d0,d2
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	checker_size3,d3
		eor.w	#%001011*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok13
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_done										; done
	cmp.w	d0,d4			
	bgt		.d0_d1_d2_smallest_d3_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done		
;------------------------------------------------------------
.d0_d1_d2_d4_smallest_d3_done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d4_smallest_d3_d5_done					; done
	beq		.d0_d1_d2_d4_d5_smallest_d3_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d4_d5_smallest_d3_done								; done					
	sub.w	d0,d6
	ble.s	.zokkkk
		sub.w	d0,d3
				markScanLineChange d0
		move.w	a3,d0
;		move.w	checker_size5,d5
		move.l	usp,a0
		move.w	a0,d5
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size4,d4
		eor.w	#%110111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zokkkk
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_d4_smallest_d3_d5_done								; done
	sub.w	d0,d6
	ble.s	.okkkk
		sub.w	d0,d3
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size4,d4
		eor.w	#%010111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.okkkk
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_smallest_d3_d4_d5_done					; done
	beq		.d0_d1_d2_d5_smallest_d3_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d5_smallest_d3_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok14
		sub.w	d0,d3
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.l	usp,a0
		move.w	a0,d5
		move.w	a1,d1
		move.w	a2,d2
		eor.w	#%100111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok14
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_smallest_d3_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok14
		sub.w	d0,d3
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		eor.w	#%000111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok14
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_done										; done
	cmp.w	d0,d4
	bgt		.d0_d2_d3_smallest_d1_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done			
;------------------------------------------------------------
.d0_d2_d3_d4_smallest_d1_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d3_d4_smallest_d1_d5_done					; done
	beq		.d0_d2_d3_d4_d5_smallest_d1_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------		
.d0_d2_d3_d4_d5_smallest_d1_done								; done
	sub.w	d0,d6
	ble.s	.zok9zz
		sub.w	d0,d1
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok9zz
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------		
.d0_d2_d3_d4_smallest_d1_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok9zz
		sub.w	d0,d1
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok9zz
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d2_d3_smallest_d1_d4_d5_done					; done
	beq		.d0_d2_d3_d5_smallest_d1_d4_done					; done
	blt		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------	
.d0_d2_d3_d5_smallest_d1_d4_done								; done	
	sub.w	d0,d6
	ble.s	.ok99
		sub.w	d0,d1
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size3,d3
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok99
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d2_d3_smallest_d1_d4_d5_done								; done				
	sub.w	d0,d6
	ble.s	.ok99z
		sub.w	d0,d1
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a2,d2
		move.w	checker_size3,d3
		eor.w	#%001101*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok99z
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_equal												; done								
	cmp.w	d0,d4
	bgt		.d0_d1_d2_d3_smallest_d4_done						; done
	blt		.d4_smallest_d0_d1_d2_d3_done						; done		
;------------------------------------------------------------
.d0_d1_d2_d3_d4_equal			
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d3_d4_smallest_d5_done					; done
	beq		.d0_d1_d2_d3_d4_d5_equal							; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------			
.d0_d1_d2_d3_d4_d5_equal										; done
	sub.w	d0,d6
	ble.s	.zok15z
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%111111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok15z
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_d4_smallest_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok15z
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		move.w	checker_size4,d4
		eor.w	#%011111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok15z
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_smallest_d4_done									; done
	cmp.w	d0,d5
	bgt		.d0_d1_d2_d3_smallest_d4_d5_done					; done
	beq		.d0_d1_d2_d3_d5_smallest_d4_done					; done
	bra		.d5_smallest_d0_d1_d2_d3_d4_done					; done
;------------------------------------------------------------
.d0_d1_d2_d3_d5_smallest_d4_done								; done
	sub.w	d0,d6
	ble.s	.zok15a
		sub.w	d0,d4
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		move.l	usp,a0
		move.w	a0,d5
		eor.w	#%101111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.zok15a
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
.d0_d1_d2_d3_smallest_d4_d5_done								; done
	sub.w	d0,d6
	ble.s	.ok15a
		sub.w	d0,d4
		sub.w	d0,d5
				markScanLineChange d0
		move.w	a3,d0
		move.w	a1,d1
		move.w	a2,d2
		move.w	checker_size3,d3
		eor.w	#%001111*STRUCTSIZE,d7
		jmp		determineSmallestNumber6
.ok15a
	add.w	d6,d0
			markScanLineChange d0
			move.l	savedA7,a7
	rts
;------------------------------------------------------------
treeend
	ENDC


doScanLineNew	macro
	move.l	(a3)+,d3			;12				32 pixels layer 3 = plane 3, inverse
	bne		.normal\@

	; when we get here, we know that plane 4, is 32 px, so we only wnat to have layer 4 and layer 5 done
	; a0 is advanced
	moveq	#-1,d3			;4
	moveq	#-1,d7			;4
	move.w	(a5)+,d0		;8				move.l	(a5)+,d0		;12
	move.w	(a5)+,d4		;8				move.w	d0,d4			;4
	lea		4(a0),a0		;8
	lea		4(a1),a1		;8
	lea		4(a2),a2		;8
	lea		4(a6),a6		;8		7*8 = 56	
	jmp		.end\@

.normal\@
	move.l	(a0)+,d0			;12				32 pixels layer 0 = plane 0
	and.l	d3,d0				;8				NOT 4 on plane 0
	move.l	(a5)+,d7			;12				32 pixels of layer 5
	or.l	d7,d0				;8		52		OR layer 5 to plane 0		(layer 5 =  plane 0 + plane 4, so I dont want overlap, hence NOT layer 4)

	move.l	(a1)+,d1			;12				32 pixels layer 1 = plane 1
	move.l	(a2)+,d2			;12				32 pixels layer 2 = plane 2, inverse
	and.l	d2,d1				;8				NOT 3 on plane 1
	move.l	(a6)+,d6			;12				32 pixels of laayer 6
	or.l	d6,d1				;8		52		OR laayer 6 to plane 3		(layer 6 = plane 2 + plane 3, so I dont want overlap)

	not.l	d2					;8				inverse the inverse pixels of layer 2 to fit plane 2
	or.l	d6,d2				;8		16		OR layer 6 into plane 2

	not.l	d3					;8				invserse the inverse of pixels of laayer 4 to fit plane 4
	or.l	d7,d3				;8	16-->136	OR laayer 5 into plane 4
	
	move.w	d0,d4				;4				because of movem, I want to reorder the words
	move.w	d1,d5				;4
	move.w	d2,d6				;4
	move.w	d3,d7				;4		16

	swap	d0					;4				because of movem I want to reorder the words
	swap	d1					;4
	swap	d2					;4
	swap	d3					;4		16		
.end\@
	movem.w	d0-d7,x(a4)			;28				60		--> 196... 10* 196 = 1960

	endm





getNextScanLine	macro

	move.l	usp,a4
	move.w	(a4)+,a6
	move.l	a4,usp
	jmp		GENERATE_SCANLINE_OFFSET(a6)

	endm



	IFNE PACKEDSTUFF
drawStart
drawUniqueLinesNew
ds1
	movem.l	scanlinePointers,a0-a5

	move.l	a0,d0		;
	move.l	a1,d1		;
	move.l	a2,d2		;
	move.l	a3,d3	
	move.l	a4,d4
	move.l	a5,d6
ds2
	lea		save0,a0
	movem.l	d0-d4/d6,(a0)
ds3
	movem.l	save0,a0-a3/a5

	move.l	d4,a5				; herp
ds4
	move.l	dlp,a4
	move.l	a4,usp
	jmp		getNextScanLine1
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
			doScanLineNew	0,0
x set x+16
		ENDR
ds5
		movem.l	save0,a0-a3/a5
getNextScanLine1
				getNextScanLine
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLineMinus
	ENDC
x set 0
		REPT 10
			doScanLineNew	1,0
x set x+16
		ENDR
ds6
		movem.l	save0,a0-a3/a5
getNextScanLine2
				getNextScanLine	
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
			doScanLineNew	0,1
x set x+16
		ENDR
ds7
		movem.l	save0,a0-a3/a5
getNextScanLine3
				getNextScanLine
;---------------------------------------------------
	IFEQ	genlower
	ELSE
generateScanLine
	ENDC
x set 0
		REPT 10
			doScanLineNew	1,1
x set x+16
		ENDR

;		movem.l	save0,a0-a3/a5
getNextScanLine4
;				getNextScanLine	
;---------------------------------------------------
doEnd
	rts	
						;	4				;	5
;	0001	=	1			1					1		-4+5, preventing 4 on 1, but is 5
;	0010	=	2			2					2		
;	0011	=	3			2 	on 1			2 on 1
;	0100	=	4			3					3
;	0101	=	5			3 	on 1			3 on 1
;	0110	=	6			3 	on 2			3 on 2
;	0111	=	7			3 	on 2+1			3 on 2+1
;	1000	=	8			4					4 		+5, so that 
;	1001	=	9			4 	on 1			5
;	1010	=	10			4 	on 2			4 on 2
;	1011	=	11			4 	on 1+2			5 on 2
;	1100	=	12			4 	on 3			4 on 3
;	1101	=	13			4 	on 1+3			5 on 3
;	1110	=	14			4 	on 2+3			4 on 2+3
;	1111	=	15			4 	on 1+2+3		5 on 2+3


;----- for each scanline mask in the table do
; TODO: if we scrounge cycles; we can evenly space the cases, and do a direct jump into the code, instead of indirect; would save 12*16 cycles total (or 12*32 5 layer)

save0	ds.l	1
save1	ds.l	1
save2	ds.l	1
save3	ds.l	1
save4	ds.l	1
save5	ds.l	1

spaceUp	macro
	ds.b	32*2-4*(3+\1)
	endm


directJumpTable	
.bm00000x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine						;4		
			spaceUp 2
.bm00001x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm00010x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm00011x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 4
.bm00100x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 1
.bm00101x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 2
.bm00110x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 2
.bm00111x
	move.l	2(a6),a4			; yoff				;2
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm01000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 1
.bm01001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 2
.bm01010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 2
.bm01011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	jmp		generateScanLine
			spaceUp 3
.bm01100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	jmp		generateScanLine
			spaceUp 0
.bm01101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	jmp		generateScanLine
			spaceUp 1
.bm01110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	jmp		generateScanLine
			spaceUp 1
.bm01111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	jmp		generateScanLine
			spaceUp 2
.bm10000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	jmp		generateScanLine
			spaceUp 3
.bm10001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm10010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm10011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 5
.bm10100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm10101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm10110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm10111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm11000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm11010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm11011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 4
.bm11100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 1
.bm11101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 2
.bm11111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	jmp		generateScanLine
			spaceUp 3
.bm100000x
	move.l	2(a6),a4			; yoff	
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm100010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm100011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm100100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm100101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm100111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm101000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm101010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm101011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm101100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 1
.bm101101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm101111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm110000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
 	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm110010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm110011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 6
.bm110100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm110101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm110111x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a3),a3
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm111000x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111001x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm111010x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 4
.bm111011x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a2),a2
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 5
.bm111100x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 2
.bm111101x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a0),a0
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111110x
	move.l	2(a6),a4			; yoff										
	move.l	save5,a6
	lea		LINESIZE(a1),a1
	lea		LINESIZE(a5),a5
	lea		LINESIZE(a6),a6
	jmp		generateScanLine
			spaceUp 3
.bm111111x
	move.l	2(a6),a4			; yoff						;2						
	move.l	save5,a6
	lea		LINESIZE(a0),a0									;4
	lea		LINESIZE(a1),a1									;4
	lea		LINESIZE(a5),a5									;4
	lea		LINESIZE(a6),a6									;4
	jmp		generateScanLine							;4	thus: (x+2)*4 where x is number of bit = 1
			spaceUp 4

drawEnd
	ENDC


stencilLoonies
	lea		loonies+128+191*160+15*8,a0
	move.l	screenpointer2,a1
	add.l	#191*160+15*8,a1
.y set 0
	REPT 7
.x set .y
	REPT 5
	move.l	.x(a0),d0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
.x set .x+8
	ENDR
	lea		160(a0),a0
	lea		160-40(a1),a1
	ENDR
	rts


myHaxListPointer			ds.l	1
my16versionsPointer			ds.l	1
my16versionsTablePointer	ds.l	1
sizePalettePointer			ds.l	1
loonies		;incbin	"data/checkerboard/loonies.neo"
treecodecrk	incbin	"data/checkerboard/treecode.crk"
	even
drawcodecrk	incbin	"data/checkerboard/drawcode.crk"
	even
;lines	
movement	include	"data/checkerboard/move.s"
;	include		"data/checkerboard/lines5.s"						; pack this, unpacak this to upper part of generated shifts, then when used, overwrite
													; frees 27k
;linescrk	incbin	"data/checkerboard/lines.crk"	
;	even
	section DATA

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
musicPlayer	incbin "msx/soschi.snd"


    ENDC

tablecrk	incbin	"data/checkerboard/otable.crk"
	even
linescrk	incbin	"data/checkerboard/olines.crk"
	even

;optimized_table	incbin	"data/checkerboard/optimized_table3.bin"	
;optimized_lines	incbin	"data/checkerboard/optimized_lines2.bin"




    IFEQ	STANDALONE
	section BSS

    rsreset
memBase             ds.b    2024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1

	ENDC
ppiss				ds.l	1
dlp					ds.l	1
scanlinePointers	ds.l	6
