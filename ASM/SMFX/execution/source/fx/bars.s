; todo:
;	- fix doors palette final
;	- integrate checkerboard code with doors
;	- stop zoom at right size
;	- and swapm in code to checkerboard vbl
;	- run the stuff
;	- finalize the checkerboard code

; aim:
;V	1.	x loops of checkerboard moving
;V	2.	change perspective while checkerboard moving
;V	3.	slowly stop checkerboard moving
;	->> new file
;V	4.	zoom out checkerboard, padding left and right according to final state
;	5.	zoom in checkerboard; wobble a bit there (in/out zoom, elastic; with open borders according to final state)
;	6.	start next effect

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

FRAMECOUNT					equ 0
loadmusic					equ FALSE
PLAYMUSIC					equ true
playmusicinvbl				equ true
useblitter					equ 1
	ENDC


checkerBackGroundColor		equ $333
checkerFrontColor			equ $777


    section	TEXT

    IFEQ	STANDALONE

	include lib/macro.s
		allocateStackAndShrink								; stack + superexec
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache
	jsr	setScreen64kAligned									; set 2 screens at 64k aligned
	IFEQ loadmusic
		jsr	loadMusic
		tst.w	fail
		bne		.exit
	ENDC		
.init

	IFEQ PLAYMUSIC
		lea		music,a0
		move.l	a0,sndh_pointer
		; init the music
		jsr		initMusic
	ENDC

		
	jsr		init_aligned_blocks
	jsr		initplane
	jsr		checkerboard_precalc2
	jsr		checkerboard_init


.mainloop:

		wait_for_vbl
	; ---- END ----
		
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop
	;----- END --------------------------------------------
.exit
	move.w	#$2700,sr
	move.l	#dummyvbl,$70.w				;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#dummy,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr
	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	restoreTimers
	IFEQ	PLAYMUSIC
		jsr	stopMusic
	ENDC
	jsr	enableMouse
	rts
; ***************************************** END MAINLOOP ************

checkerboard_init
	move.w	#$2700,sr
	move.l	#moving_checker_vbl,$70
	move.w	#$2300,sr
	rts


checkerboard_precalc2
		move.l	alignpointer2,d0
		move.l	d0,linesPointer
		add.w	#10880,d0

		jsr		initLines
		move.w	#0*200,d0
		jsr		exampleGrid
		swapscreens
		jsr		exampleGrid		
		move.w	#-1,_check_precalc_done
	rts	
	ENDC


checkerboard_precalc
	move.l	specialpointer,d0
	move.l	d0,slopeListPointer
	add.w	#536,d0					; ----> 10880 +  9202*2 + 536
	move.l	d0,linesPointer
	add.w	#10880,d0
	add.w	#9202,d0
	move.l	d0,specialpointer


	move.l	#haxSpace,d0
	move.l	d0,grid1sPointer
	add.l	#16000,d0
	add.l	#200,d0
	move.l	d0,linesSourcePointer
	lea		grid1s,a0
	move.l	grid1sPointer,a1
	jsr		d_lz77

	lea		lines2,a0
	move.l	linesSourcePointer,a1
	jsr		d_lz77

	jsr		initLines

	jsr		genLalaList
	jsr		init_scale_3bpl
	move.w	#$4e75,checkerboard_precalc
	rts




; plane 1 is filled
; plane 4 is filled
; so we need clearing method

	IFD DEMOSYSTEM
	ELSE
timer_a_opentop
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
	REPT 84
		nop
	ENDR

	clr.b	$ffff820a.w			;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz
	rte
	ENDC



zoom_fs	dc.w	0


initLines
	move.l	linesSourcePointer,a0
	move.l	linesPointer,a1
	move.w	#4-1,d7
.copySource
		REPT 20
			move.l	(a0)+,(a1)+
		ENDR
	dbra	d7,.copySource
	move.w	#136-4-1,d7
	lea		40(a1),a2
.copyAndNegate
		REPT 10
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			not.l	d0
			move.l	d0,(a2)+
		ENDR
		add.w	#40,a1	
		add.w	#40,a2
	dbra	d7,.copyAndNegate
	rts		




zooming_checker_vbl
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
	pushall

		swapscreens				; dont use jmp when it returns with rts, use branch then
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.w	#0,timer_b_off
	move.w	#1,color
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#checker_timer_b,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#-1,zoom_fs

	move.w	#$2700,sr
	move.l	#zooming_checker_fs_vbl,$70
	move.w	#$2300,sr

	move.l	sndh_pointer,a0
	jsr		8(a0)


	move.l	screenpointer,a0
	jsr		drawCheckerBoard

	popall
	rte


checker_timer_b_curtain
	move.w	#checkerBackGroundColor,$ffff8240				;	+2
	move.w	#checkerFrontColor,$ffff8240+2*6	;6		;	+6
	move.w	#checkerFrontColor,$ffff8240+2*4	;4		;	+10
	move.w	#checkerBackGroundColor,$ffff8240+2*2	;2		;	+14

	pushd0
	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_openbottom2,$120.w
	move.w	#228,d0
	sub.b	checker_timer_b_curtain_open,d0
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	rte








checker_timer_b_openbottom
		move.w	#$2100,sr
		stop	#$2100

		dcb.w	48,$8080

		clr.b	$ffff820a.w			;60 Hz
		dcb.w	5,$4e71				;
		move.b	#2,$ffff820a.w			;50 Hz		
		rte



checker_timer_b_openbottomZ
	move.w	#$2700,sr
	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    nop
    nop
    nop
    nop

    move.b  #0,$FFFF820A.w  
 	cmp.b	#29,checker_timer_b_curtain_open				;20		5
 	bne		.ok												;8		2
 		nop
    REPT 18-8-5
    	nop
    ENDR
	move.b  #2,$FFFF820A.w  ; 50 hz


	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_curtain_lower,$120.w
	move.b	checker_timer_b_curtain_close,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
    rte

.ok
    REPT 18-8-5
    	nop
    ENDR
	move.b  #2,$FFFF820A.w  ; 50 hz


	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_curtain_lower,$120.w
	move.b	checker_timer_b_curtain_close,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
    rte
	

checker_timer_b_openbottomAA
	move.w	#$2700,sr
	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    move.b  #0,$FFFF820A.w  
 	cmp.b	#29,checker_timer_b_curtain_open				;20		5
 	bne		.ok												;8		2
 	nop
 		move.w	#$000,$ffff8240+2*4								;16		4
		move.w	#$000,$ffff8240									;16		4		
	
    REPT 18-8-8-1-1
    	nop
    ENDR
	move.b  #2,$FFFF820A.w  ; 50 hz

	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_curtain_lower,$120.w
	move.b	checker_timer_b_curtain_close,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
    rte

.ok

    REPT 18-8-1-1
    	nop
    ENDR
	move.b  #2,$FFFF820A.w  ; 50 hz

	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_curtain_lower,$120.w
	move.b	checker_timer_b_curtain_close,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
    rte



checker_timer_b_openbottom2
	move.w	#$2700,sr
	pushd0
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    move.b  #0,$FFFF820A.w  
 	cmp.b	#29,checker_timer_b_curtain_open				;20		5
	bne		.ok												;8		2
	nop														;4		1
	move.w	#$000,$ffff8240+2*4								;16		4
	move.w	#$000,$ffff8240									;16		4		
	move.b  #2,$FFFF820A.w  ; 50 hz
	jmp		.tttt
.ok
	REPT 4
		or.l	d0,d0
	ENDR  
	nop 
	move.b  #2,$FFFF820A.w  ; 50 hz
.tttt

	clr.b	$fffffa1b.w
	move.l	#checker_timer_b_curtain_lower,$120.w
	move.b	checker_timer_b_curtain_close,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
    rte



checker_timer_b_curtain_lower
	move.w	#$000,$ffff8240
	move.w	#$000,$ffff8240+2*4
	clr.b	$fffffa1b.w
	rte

checker_timer_b_curtain_open		dc.b	29
checker_timer_b_curtain_total_open	dc.b	0
checker_timer_b_border_open			dc.b	200
checker_timer_b_curtain_close		dc.b	0

timer_b_curtain	dc.b	29,0
timer_b_open	dc.w	200

; so we have height size; and this determines
;	if height > 100
;	-> upper list = 29 - (height-100)
;	-> loser list = height - 100
clearShit	dc.w	2
clearShit2			dc.w	8
clearShitActive		dc.w	0

totalFadeWaiter		dc.w	1
totalFadeOff		dc.w	-2
totalFadePalette	dc.w	$667,$677,$777,$776,$766,$666,$656,$556,$555,$455,$445,$444,$434,$334,checkerBackGroundColor,checkerBackGroundColor,checkerBackGroundColor
					dc.w	$000,$111,$222,$333,$444,$555,$656,$556,$555,$455,$445,$444,$434,$334,checkerBackGroundColor,checkerBackGroundColor,checkerBackGroundColor


logoColorsOffset	dc.w	0
logoColors
	dc.w	$777,$777,$777,$777,$777,$777	;0
	dc.w	$776,$776,$776,$777,$777,$666	;12	
	dc.w	$776,$776,$776,$777,$666,$555	;24
	dc.w	$776,$666,$666,$666,$555,$444	;36
	dc.w	$775,$666,$666,$555,$444,$333	;48	
	dc.w	$775,$665,$665,$554,$444,$333	;60


    dc.w    $777,$777,$777,$777,$777,$777    ; i made changes in this set of colors!
    dc.w    $776,$766,$766,$776,$666,$666
    dc.w    $776,$765,$765,$665,$555,$555
    dc.w    $775,$764,$764,$554,$544,$444
    dc.w    $774,$754,$754,$544,$533,$333
    dc.w    $774,$753,$753,$544,$522,$312

	dc.w	$777,$777,$777,$777,$777,$777
	dc.w	$656,$655,$655,$767,$766,$766	;12
	dc.w	$545,$544,$544,$656,$655,$765	;24
	dc.w	$434,$544,$544,$645,$643,$654	;36
	dc.w	$323,$433,$433,$534,$542,$643	;48
	dc.w	$212,$322,$322,$423,$431,$543
	

firstFadeOff	dc.w	0
firstFadeTimer	dc.w	5


firstFade	
	lea		logoColors,a0
	add.w	firstFadeOff,a0
	lea		$ffff8240+2*11,a1
	move.w	(a0)+,-8(a1)
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+	

	subq.w	#1,firstFadeTimer
	bge		.noAdd
		move.w	#5,firstFadeTimer
		add.w	#12,firstFadeOff
		cmp.w	#72,firstFadeOff
		bne		.noAdd
			move.w	#$4e75,firstFade
.noAdd
	rts

oldCheckerHeight	dc.w	0

; so I want to fadeout/fadein at a certain threshold
; hard color lookup value, based on checkerheight
;	checker_height,offset_color table
;	together with a base offset for shit

logoColorOffsetTable
	REPT 5
		dc.w	0
	ENDR
	REPT 5
		dc.w	12
	ENDR
	REPT 5
		dc.w	24
	ENDR
	REPT 5
		dc.w	36
	ENDR
	REPT 5
		dc.w	48
	ENDR
	REPT 6
		dc.w	60
	ENDR

times30		dc.w	3
logoColorsPalette	dc.w	0

zooming_checker_fs_vbl
	move.l 	screenpointer2,$ff8200							; put new screenpointer in effect
			pushall
			screenswap			
			schedule_timerA_topBorder
	move.l	#timer_a_opentop,$134.w						;Install our own Timer A
	addq.w	#1,$466.W
	move.w	#0,timer_b_off
	move.w	#1,color


	jsr		firstFade

	move.w	#$0,$ffff8240+2*6	;6
	move.w	#$0,$ffff8240+2*4	;4
	move.w	#$0,$ffff8240+2*2	;2

	move.w	#$666,$ffff8240+2*5	;4		;	+10			;776

	;this si where we do the fade
	move.w	checker_height,d0
	cmp.w	#31,d0
	bge		.txx
		cmp.w	#0,d0
		bne		.cont
			move.w	#72,logoColorsPalette
.cont

		lea		logoColorOffsetTable,a1
		add.w	d0,d0
		add.w	d0,a1


		lea		logoColors,a0
		add.w	logoColorsPalette,a0
		add.w	(a1),a0
	lea		$ffff8240+2*11,a1
	move.w	(a0)+,-8(a1)
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

.txx

	jsr		firstFade

	tst.w	lalatimes
	bgt		.okkk
		tst.w	checker_minus
		bge		.ttt
		cmp.w	#30,checker_height
		bgt		.ttt
			subq.w	#1,totalFadeWaiter
			bge		.ttt
				move.w	#4,totalFadeWaiter
				add.w	#2,totalFadeOff
				lea		totalFadePalette,a0
				add.w	totalFadeOff,a0
				move.w	(a0),checker_timer_b_curtain+8
				move.w	(a0),checker_timer_b_curtain+14
				move.w	34(a0),checker_timer_b_curtain_lower+2
				move.w	34(a0),checker_timer_b_curtain_lower+8
				MOVE.W	34(a0),$ffff8240
				MOVE.W	34(a0),$ffff8240+4*2

.ttt
	tst.b	checker_timer_b_curtain_total_open						; check if we need to schedule dynamic timers
	bne		.okkk																		; if not zero, we're static
		move.w	checker_height,d0
		cmp.w	#102,d0
		blt		.okkk
			cmp.w	#135,d0
			bne		.kkkk
				move.b	#-1,checker_timer_b_curtain_total_open
.kkkk
			move.w	d0,d1
; determine open top
			sub.w	#102,d1
			move.w	d1,d0
			neg.w	d1
			add.w	#29,d1
			bgt		.positive
				move.w	#1,d1
.positive
			move.b	d1,checker_timer_b_curtain_open				; top border timer
			move.b	d0,checker_timer_b_curtain_close			; bottom border lines
.okkk


	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	checker_timer_b_curtain_open,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#checker_timer_b_curtain,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.w	#200,timer_b_open

	jsr		clearPlane
	jsr		clearCheckerBoardTop

	move.l	screenpointer,a0
	jsr		drawCheckerBoard
	move.l	screenpointer,a0
	moveq	#0,d0

	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR

	move.l	sndh_pointer,a0
	jsr		8(a0)

	jsr		drawsmfxanim

	popall
	rte

_expand			dc.w	0
_offsetbumper	dc.w	2
_offsetsave		dc.w	0

clearPlane

	tst.w	clearShitActive
	beq		.ok
	subq.w	#1,clearShit2
	blt		.ok

	move.l	screenpointer2,a0
	add.w	_offsetsave,a0
	moveq	#0,d0
	move.w	#67-1,d7
.cl
o set 2
		REPT 20
			move.w	d0,o(a0)
o set o+8
		ENDR
		add.w	#160,a0
	dbra	d7,.cl

	subq.w	#1,_offsetbumper
	bne		.ok
		move.w	#2,_offsetbumper
		add.w	#67*160,_offsetsave
.ok
	rts

animoff	dc.w	0
animfade
	dc.w	$555
	dc.w	$545
	dc.w	$545
	dc.w	$545
	dc.w	$544
	dc.w	$544
	dc.w	$444
	dc.w	$434
	dc.w	$433
	dc.w	$333
	dc.w	$323
	dc.w	$322
	dc.w	$222
	dc.w	$212
	dc.w	$211
	dc.w	$111
	dc.w	$111
	dc.w	$101
	dc.w	$101
	dc.w	$100
	dc.w	$100
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000

genLalaList
	moveq	#0,d5
	move.l	#111,d0
	move.l	#134,d1		; total width
	divu	d1,d0				; d0 is current width so we have size	(1/xstep)
	move.w	d0,d5				; save
	clr.w	d0					; clear	
	swap	d0
	asl.l	#8,d0				
	divu	d1,d0		
	asl.w	#8,d0
	swap	d5
	or.w	d0,d5
	swap	d5

	moveq	#0,d0
	moveq	#0,d1
	move.w	#134,d7
	move.w	#57*14*6,d2
	move.l	slopeListPointer,a1
.dl
		add.l	d5,d0
		addx.w	d1,d0
		move.w	d2,d3
		muls	d0,d3
		move.l	d3,(a1)+

	dbra	d7,.dl
	rts


drawsmfxanim
	move.w	checker_height,d0
	cmp.w	#3,d0
	beq		.clear
	blt		.ok
		move.l	planarpicbsspointer,a0
		sub.w	#3-1,d0
		beq		.clear
		move.l	slopeListPointer,a1
		add.w	d0,d0
		add.w	d0,d0
		add.l	(a1,d0.w),a0
		move.l	screenpointer,a1
		add.l	#(74+29)*160,a1
		move.w	#55-1,d7
.doLine
o set 24
		REPT 14
			move.l	(a0)+,o(a1)
			move.w	(a0)+,o+6(a1)
o set o+8
		ENDR
		add.w	#160,a1
		dbra	d7,.doLine
.ok
	rts

.clear
		move.l	screenpointer,a1
		add.l	#(83+29)*160,a1
		move.w	#40-1,d7
		moveq	#0,d0
.doLine2
o set 24
		REPT 14
			move.l	d0,o(a1)
			move.w	d0,o+6(a1)
o set o+8
		ENDR
		add.w	#160,a1
		dbra	d7,.doLine2
		rts		

ww				dc.w	2
timer_b_source	dc.w	0
color_source	dc.w	-1
cycle_times		dc.w	12	;12

checker_timer_b2
	pusha0
	pushd0
	tst.w	color
	blt		.this
.other;
	move.w	#checkerBackGroundColor,$ffff8240+2*2
	move.w	#checkerFrontColor,$ffff8240+6*2
	jmp		.x
.this
	move.w	#checkerBackGroundColor,$ffff8240+6*2
	move.w	#checkerFrontColor,$ffff8240+2*2
.x
	neg.w	color
	lea		barsMovingList,a0
	add.w	timer_b_off,a0
	move.b	(a0),d0
	blt		.openBorder
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	addq.w	#1,timer_b_off

	popd0
	popa0
	rte	
.openBorder
	sub.b	#128+2,d0
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#openborderlala,$120
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popd0
	popa0
	rte

savedpalx	ds.w	16

openborderlala
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
     clr.b   $fffffa1b.w                     ;Timer B control (stop)
 
        lea $ffff8209.w,a0          ;Hardsync						;8
        moveq   #127,d1												;4
.sync:      tst.b   (a0)											;8
        beq.s   .sync												;8
        move.b  (a0),d2												;8
        sub.b   d2,d1												;4
        lsr.l   d1,d1												;10
 ;      	movem.l	exec_pal,d0-d7						;80

	lea		paletteList,a0				;8 -> 12
	add.w	paletteOffx,a0				;16
	movem.l	(a0),d0-d7					;76

        REPT 37-28
        	nop
        ENDR
       	movem.l	d1-d7,$ffff8244					;76

	clr.b	$ffff820a.w			;60 Hz
	REPT 2
		nop
	ENDR
		move.l	d0,$ffff8240


    move.b  #2,$FFFF820A.w  ; 50 hz

    clr.b   $fffffa1b.w                     ;Timer B control (stop)
	move.l	#palette_timer_b,$120
	move.b	#5,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	add.w	#12*32,paletteOffx
    add.w	#2,lineOffx

    movem.l (sp)+,d0-d7/a0

    rte

palette_timer_b
	pushall
	clr.b	$fffffa1b.w			;Timer B control (stop)
	tst.w	_paletteFadeDirection
	lea		lineNumbers,a0
	add.w	lineOffx,a0
	move.w	(a0),d0
	blt		.end	
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	lea		paletteList,a0
	add.w	paletteOffx,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	add.w	#12*32,paletteOffx
	add.w	#2,lineOffx


	popall
	rte
.end
	subq.w	#1,_palwaiter
	bge		.okk
	tst.w	_paletteFadeDirection
	bne		.fadeout
.fadein
	move.w	#1,_palwaiter
	add.w	#32,paletteOffxBase
	cmp.w	#11*32,paletteOffxBase
	ble		.okk
		move.w	#11*32,paletteOffxBase
.okk
	move.w	paletteOffxBase,paletteOffx
	move.w	#0,lineOffx
	popall
	rte

.fadeout
	move.w	#1,_palwaiter
	sub.w	#32,paletteOffxBase
	bge		.okx
		move.w	#0,paletteOffxBase
.okx
	move.w	paletteOffxBase,paletteOffx
	move.w	#0,lineOffx
	popall
	rte

_palwaiter		dc.w	1
lineNumbers:   DC.W 4,6,5,5,5,5,5,6,-1
	even


perspective_frames	dc.w	102
display_logo_frames	dc.w	100
lolwaitert			dc.w	3

perspective_bars_vbl
	addq.w	#1,$466.w

	move.l	screenpointer,$ffff8200
	pushall
			swapscreens				; dont use jmp when it returns with rts, use branch then
	move.w	#$0,$ffff8240

	cmp.w	#12,perspective_frames
	bgt		.kkkk
		subq.w	#1,lolwaitert
		bge		.kkkk
			move.w	#3,lolwaitert
			add.w	#$111,checker_timer_b+2
.kkkk

	move.w	#0,timer_b_off
	move.w	#1,color

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#checker_timer_b,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.l	sndh_pointer,a0
	jsr		8(a0)

	cmp.w	#26,perspective_frames
	bne		.xxx
			move.w	#-1,_paletteFadeDirection
.xxx
	subq.w	#1,perspective_frames
	blt		.cont
	jsr		turnGrid
	move.w	#0*200,d0
	move.l	offset,d1
	jsr		exampleGrid
	jsr		progressGrid

	subq.w	#1,display_logo_frames
	bge		.okx
		jsr		clearLogo
.okx

	popall

	rte


.cont
	move.w	#0*200,d0
	move.l	offset,d1
	jsr		exampleGrid

	swapscreens
	subq.w	#1,again
	bge		.ok
	move.w	#$2700,sr
	move.l	#zooming_checker_vbl,$70
	move.w	#$2300,sr
	move.w	#2,again

.ok
	popall
	rte

cleartimes	dc.w	2
clearLogo
	subq.w	#1,cleartimes
	blt		.ok
	move.l	screenpointer2,a0
	add.w	#160*200,a0
	move.w	#80-1,d7
	moveq	#0,d0
.il
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a0)+
		ENDR
	dbra	d7,.il
.ok
	rts
again	dc.w	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; checkerboard routs
;;;;;
checker_height			dc.w	20
checker_lineoffset		dc.w	20*80
checker_counter			dc.w	5
checker_counter_count	dc.w	2
checker_minus			dc.w	1
checker_max				dc.w	135*80
checker_cycle			dc.w	2
; default size is 4;		320 pixels per line (40 bytes)
;							negative value is followed
; target size is 44;
; thus 40*40 added, lets code some shit
cctimes	dc.w	2
clearCheckerBoardTop
	subq.w	#1,cctimes
	blt		.skip
	move.l	screenpointer2,a0
	sub.w	#320,a0
	move.w	#33-1,d7
	moveq	#0,d0
.clearLine
o set 0
	REPT 20
		move.w	d0,o(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.clearLine
.skip
	rts





savedScreen	dc.l	0

drawCheckerBoard
	;a0,a1,a2,a3,a4,a5,a6
	;d3,d4,d5,d7
	;d0,d1,d2,d6

;	move.l 	screenpointer,a0			; screenpointer
	add.w	#4,a0						; write to plane 3
	tst.w	zoom_fs
	beq		.nn
		add.w	#29*160,a0
.nn
	move.l	a0,savedScreen						; save pointer

	move.w	checker_height,d7			; half height
	addq.w	#2,d7						; +2 ?
	move.w	d7,a5						; save?

;	lea		lines,a6					; line
	move.l	linesPointer,a6
	add.w	checker_lineoffset,a6		; linepointer

	move.l	a6,a1						; linepointer saved 1
	move.l	a1,a3						; linepointer saved 2
	move.l	a1,a2						; linepointer saved 3
	add.w	#40,a2						; a2 = inverted linepointer

	move.w	a5,d3						; saved height
	move.w	d3,d4						; saved height 2
	subq.w	#1,d4						; saved height 3 (-1)

	move.l	#132-2,d5					; half of screen size
	add.w	#16000+320,a0				; we start at the middle, line 99 (to -> 0)
.firstblock_top
		move.l	a3,a1					; restore source address
		dbra	d7,*+12					; we first do half the block, before we invert
			move.l	a2,a1					; here we invert
			move.l	a3,a2
			move.l	a1,a3
			jmp		.restblock_top_init		; and do the rest of the top half of the screen
o set 0
		REPT 20
			move.w	(a1)+,o(a0)							; 24 * 10 = 200
o set o+8
		ENDR
		sub.w	#160,a0										;8
	dbra	d5,.firstblock_top										;12 ===> (240 + 36) * 100 = 27600
	jmp		.bottompart

.restblock_top_init
	sub.w	#160,a0
;	lea		lines,a1
	move.l	linesPointer,a1
	add.w	checker_lineoffset,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2	

	move.l	a2,a1
	move.l	a3,a2
	move.l	a1,a3
	lsr.w	#1,d5
;	sub.w	#1,d5
	blt		.bottompart

.restblock_top
		move.l	a3,a1
		dbra	d3,*+12
			move.w	d4,d3
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
o set 0
		REPT 20
			move.w	(a1)+,o(a0)
o set o+8
		ENDR
		move.l	a3,a1
		REPT 20
			move.w	(a1)+,o(a0)
o set o+8
		ENDR
	sub.w	#320,a0
	dbra	d5,.restblock_top

;;;;;;;;;;;;;;;;;;;;;; 2nd half of screen
.bottompart
	move.l	a6,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2

	move.w	a5,d7
	move.w	d7,d3


	move.l	savedScreen,a0
	add.w	#16000+480,a0
	move.w	#134-1,d5							; this is 100 lines

.firstblock_bottom
		move.l	a3,a1
		dbra	d7,*+12							; this is checked everyline
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
			jmp		.restblock_bottom_init
o set 0
		REPT 20
			move.w	(a1)+,o(a0)					; this is one line
o set o+8
		ENDR
		add.w	#160,a0
	dbra	d5,.firstblock_bottom
	jmp		.endpart

.restblock_bottom_init
;	lea		lines,a1
	move.l	linesPointer,a1
	add.w	checker_lineoffset,a1
	move.l	a1,a3
	move.l	a1,a2
	add.w	#40,a2
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
	lsr.w	#1,d5
	sub.w	#1,d5
	blt		.endpart
.restblock_bottom
		move.l	a3,a1
		dbra	d3,*+12							; this is checked everyline
			move.w	d4,d3
			move.l	a2,a1
			move.l	a3,a2
			move.l	a1,a3
o set 0
		REPT 20
			move.w	(a1)+,o(a0)					; this is one line
o set o+8
		ENDR
		move.l	a3,a1
		REPT 20
			move.w	(a1)+,o(a0)					; this is one line
o set o+8
		ENDR
		add.w	#320,a0
	dbra	d5,.restblock_bottom

.endpart
	tst.w	checker_lineoffset
	bne		.tttt
		move.l	savedScreen,a0
		move.w	#0,d0
o set 0
		REPT 200								; eww, this should have been generated
			move.w	d0,o(a0)
			move.w	d0,o+8(a0)
o set o+160
		ENDR
.tttt


	move.l	savedScreen,a0
	add.l	#(100+135)*160,a0
	move.w	#2,d7
	moveq	#0,d0
.clearline
o set 0
		REPT 20
			move.w	d0,o(a0)
o set o+8
		ENDR
		add.w	#160,a0
		dbra	d7,.clearline

	cmp.w	#2,checker_height
	bne		.continue
		subq.w	#1,lalatimes
		blt		.dotransition
.continue




	subq.w	#1,checker_counter
	bne		.gogo
		move.w	checker_counter_count,checker_counter
	tst.w	checker_minus
	beq		.gogo
	blt		.minus
		add.w	#1,checker_height
		add.w	#40*2,checker_lineoffset
		move.w	checker_max,d0
		cmp.w	checker_lineoffset,d0
		bne		.gogo
			move.w	#-1,checker_minus
;			add.w	#1,checker_counter_count
			add.w	#1,checker_cycle
			jmp		.gogo
.minus
		sub.w	#1,checker_height
		sub.w	#40*2,checker_lineoffset
		bne		.gogo
			move.w	#1,checker_minus
.gogo
	rts
.dotransition
	subq.w	#1,drawtimes
	bne		.haha
		move.w	#-1,nextScene
.haha
	rts

;133 times
;111 scale times
; so I need tables that had 111/133 slope

drawtimes	dc.w	30
lalatimes	dc.w	4



initplane
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#264-1,d7
	move.w	#-1,d0
.loop
o set 2
	REPT 20
		move.w	d0,o(a0)
		move.w	d0,o(a1)
o set o+8
	ENDR
	add.w	#160,a0
	add.w	#160,a1
	dbra	d7,.loop
	rts

;;;;;;; 
; bars routs
;;;;;;;

turnGrid
	subq.w	#1,ww
	bgt		.ok
		move.w	#2,ww
		add.w	#10,timer_b_list_select
.ok
	rts

timer_b_list_direction	dc.w	1
timer_b_list_select		dc.w	0		;2*51*13







checker_timer_b
	move.w	#$000,$ffff8240
	pusha0
	pushd0
	tst.w	color
	blt		.this
.other
	move.w	#checkerBackGroundColor,$ffff8240+2*2
	move.w	#checkerFrontColor,$ffff8240+6*2
	jmp		.x
.this
	move.w	#checkerFrontColor,$ffff8240+2*2
	move.w	#checkerBackGroundColor,$ffff8240+6*2
.x

	neg.w	color
	lea		timer_b_list,a0
	add.w	timer_b_list_select,a0
	add.w	timer_b_off,a0
	move.b	(a0),d0
	blt		.openBorder
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	addq.w	#1,timer_b_off

	popd0
	popa0
	rte
.openBorder
	sub.b	#128+2,d0
	bne		.kkk
		popd0
		popa0
		jmp		openborderlala
.kkk
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#openborderlala,$120
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popd0
	popa0
	rte



color		dc.w	1
timer_b_off	dc.w	0





progressGrid
	tst.w	offdir
	bne		.negative
.positive
	add.l	#$500,offset
	cmp.l	#$FF00,offset
	bne		.end
		tst.w	constantoffset		; first time we hit this, flip and set
		bne		.flipdirection
			move.w	#40,constantoffset
			move.l	#0,offset
			jmp		.end
.flipdirection
		move.w	#-1,offdir
	jmp		.end
.negative
	sub.l	#$500,offset
	bne		.end
		tst.w	constantoffset		; first time we hit this, flip and set
		beq		.flipdirection2
			move.w	#0,constantoffset
			move.l	#$FF00,offset
			jmp		.end
.flipdirection2
		move.w	#0,offdir
.end
	rts

offdir
	dc.w	-1
offset
	dc.l	$FF00
constantoffset
	dc.w	40
offsetcontinued
	dc.w	-1

	IFEQ STANDALONE
init_aligned_blocks
	move.l	screenpointer2,d0
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
	add.l	#$10000,d0
	move.l	d0,alignpointer6
	rts
	ENDC

exampleGrid
	move.l	grid1sPointer,a0
	add.w	#40*200,a0
	move.l	screenpointer2,a1
	add.w	#4,a1
	; offset is d0
	; fraction is d1
;	moveq	#0,d0
	add.w	#100*160,a1
	moveq	#0,d2
	move.l	#100-1,d7
	move.w	constantoffset,d6

	add.w	d0,a0	
	moveq	#0,d0
.il
	move.l	a0,a2
o set 0
	REPT 20
		move.w	(a2)+,o(a1)
o set o+8
	ENDR
	add.w	d6,a0
	add.w	d1,d0
	bcc.s	.x
	add.w	#40,a0
.x
	add.w	#160,a1
	dbra	d7,.il

	move.l	grid1sPointer,a0
	add.w	#40*200,a0
	move.l	screenpointer2,a1
	add.w	#100*160+4,a1
	moveq	#0,d2
	move.l	#101-1,d7
	move.w	constantoffset,d6
	moveq	#-1,d0
.il2
	move.l	a0,a2
o set 0 
	REPT 20
		move.w	(a2)+,o(a1)
o set o+8
	ENDR
	sub.w	d6,a0
	sub.w	d1,d0
	bcc.s	.x2
		sub.w	#40,a0
.x2
	sub.w	#160,a1
	dbra	d7,.il2
	rts




	section DATA
	; encoding, get the last one to be -1 to signal open border
	; ooh look, its an animation
timer_b_list
;	0
	dc.b	1			
	dc.b	7	
	dc.b	8	
	dc.b	10	
	dc.b	12	
	dc.b	15	
	dc.b	20	
	dc.b	28	
	dc.b	41	
	dc.b	57+128		;65	
;	1
	dc.b	1	
	dc.b	7	
	dc.b	8	
	dc.b	10	
	dc.b	13	
	dc.b	16	
	dc.b	21	
	dc.b	29	
	dc.b	42	
	dc.b	52+128		;67	
;	2
	dc.b	2	
	dc.b	7	
	dc.b	9	
	dc.b	11	
	dc.b	13	
	dc.b	17	
	dc.b	22	
	dc.b	30	
	dc.b	43	
	dc.b	45+128		;69	
;	3
	dc.b	2	
	dc.b	8	
	dc.b	9	
	dc.b	11	
	dc.b	14	
	dc.b	17	
	dc.b	23	
	dc.b	31	
	dc.b	45	
	dc.b	39+128		;71	
;	4
	dc.b	2	
	dc.b	8	
	dc.b	10	
	dc.b	12	
	dc.b	14	
	dc.b	18	
	dc.b	24	
	dc.b	32	
	dc.b	46	
	dc.b	33+128		;72	
;	5
	dc.b	2	
	dc.b	8	
	dc.b	10	
	dc.b	12	
	dc.b	15	
	dc.b	19	
	dc.b	24	
	dc.b	33	
	dc.b	48	
	dc.b	28+128		;74	
;	6
	dc.b	3	
	dc.b	9	
	dc.b	10	
	dc.b	12	
	dc.b	15	
	dc.b	19	
	dc.b	25	
	dc.b	34	
	dc.b	49	
	dc.b	23+128		;76	
;	7
	dc.b	3	
	dc.b	9	
	dc.b	11	
	dc.b	13	
	dc.b	16	
	dc.b	20	
	dc.b	26	
	dc.b	35	
	dc.b	50	
	dc.b	16+128		;77	
;	8
	dc.b	4	
	dc.b	9	
	dc.b	11	
	dc.b	14	
	dc.b	17	
	dc.b	21	
	dc.b	27	
	dc.b	36	
	dc.b	51	
	dc.b	9+128		;78	
;	9
	dc.b	5	
	dc.b	10	
	dc.b	12	
	dc.b	14	
	dc.b	17	
	dc.b	22	
	dc.b	28	
	dc.b	37	
	dc.b	52	
	dc.b	2+128		;80	
;	10
	dc.b	5	
	dc.b	10	
	dc.b	12	
	dc.b	15	
	dc.b	18	
	dc.b	22	
	dc.b	29	
	dc.b	38	
	dc.b	50+128		;54	
	dc.b	81	
;	11
	dc.b	6	
	dc.b	11	
	dc.b	13	
	dc.b	15	
	dc.b	18	
	dc.b	23	
	dc.b	30	
	dc.b	39	
	dc.b	44+128		;55	
	dc.b	82	
;	12
	dc.b	6	
	dc.b	11	
	dc.b	13	
	dc.b	16	
	dc.b	19	
	dc.b	24	
	dc.b	30	
	dc.b	40	
	dc.b	40+128		;56	
	dc.b	82	
;	13
	dc.b	7	
	dc.b	12	
	dc.b	14	
	dc.b	16	
	dc.b	20	
	dc.b	25	
	dc.b	31	
	dc.b	41	
	dc.b	33+128		;57	
	dc.b	83	
;	14
	dc.b	7	
	dc.b	12	
	dc.b	14	
	dc.b	17	
	dc.b	20	
	dc.b	25	
	dc.b	32	
	dc.b	42	
	dc.b	30+128		;58	
	dc.b	84	
;	15
	dc.b	8	
	dc.b	13	
	dc.b	15	
	dc.b	17	
	dc.b	21	
	dc.b	26	
	dc.b	33	
	dc.b	43	
	dc.b	23+128		;59	
	dc.b	84	
;	16
	dc.b	8	
	dc.b	13	
	dc.b	15	
	dc.b	18	
	dc.b	22	
	dc.b	27	
	dc.b	34	
	dc.b	44	
	dc.b	18+128		;59	
	dc.b	85	
;	17
	dc.b	9	
	dc.b	14	
	dc.b	16	
	dc.b	19	
	dc.b	23	
	dc.b	28	
	dc.b	35	
	dc.b	45	
	dc.b	10+128		;60	
	dc.b	85	
;	18
	dc.b	9	
	dc.b	14	
	dc.b	16	
	dc.b	19	
	dc.b	23	
	dc.b	28	
	dc.b	35	
	dc.b	46	
	dc.b	9+128		;61	
	dc.b	85	
;	19
	dc.b	10	
	dc.b	15	
	dc.b	17	
	dc.b	20	
	dc.b	24	
	dc.b	29	
	dc.b	36	
	dc.b	46	
	dc.b	2+128		;61	
	dc.b	85	
;	20
	dc.b	10	
	dc.b	15	
	dc.b	18	
	dc.b	21	
	dc.b	25	
	dc.b	30	
	dc.b	37	
	dc.b	43+128		;47	
	dc.b	62	
	dc.b	85	
;	21
	dc.b	11	
	dc.b	16	
	dc.b	18	
	dc.b	21	
	dc.b	25	
	dc.b	31	
	dc.b	38	
	dc.b	39+128		;48	
	dc.b	62	
	dc.b	84	
;	22
	dc.b	11	
	dc.b	16	
	dc.b	19	
	dc.b	22	
	dc.b	26	
	dc.b	31	
	dc.b	39	
	dc.b	35+128		;48	
	dc.b	62	
	dc.b	84	
;	23
	dc.b	12	
	dc.b	17	
	dc.b	20	
	dc.b	23	
	dc.b	27	
	dc.b	32	
	dc.b	39	
	dc.b	29+128		;49	
	dc.b	63	
	dc.b	83	
;	24
	dc.b	12	
	dc.b	18	
	dc.b	20	
	dc.b	24	
	dc.b	28	
	dc.b	33	
	dc.b	40	
	dc.b	24+128		;50	
	dc.b	63	
	dc.b	82	
;	25
	dc.b	13	
	dc.b	18	
	dc.b	21	
	dc.b	24	
	dc.b	28	
	dc.b	34	
	dc.b	41	
	dc.b	20+128		;50	
	dc.b	63	
	dc.b	82	
;	26
	dc.b	13	
	dc.b	19	
	dc.b	22	
	dc.b	25	
	dc.b	29	
	dc.b	35	
	dc.b	41	
	dc.b	15+128		;50	
	dc.b	63	
	dc.b	81	
;	27
	dc.b	14	
	dc.b	20	
	dc.b	22	
	dc.b	26	
	dc.b	30	
	dc.b	35	
	dc.b	42	
	dc.b	10+128		;51	
	dc.b	63	
	dc.b	80	
;	28
	dc.b	14	
	dc.b	20	
	dc.b	23	
	dc.b	27	
	dc.b	31	
	dc.b	36	
	dc.b	43	
	dc.b	5+128		;51	
	dc.b	63	
	dc.b	79	
;	29
	dc.b	15	
	dc.b	21	
	dc.b	24	
	dc.b	27	
	dc.b	32	
	dc.b	37	
	dc.b	43+128		;43	
	dc.b	51	
	dc.b	63	
	dc.b	78	
;	30
	dc.b	15	
	dc.b	22	
	dc.b	25	
	dc.b	28	
	dc.b	32	
	dc.b	37	
	dc.b	40+128		;44	
	dc.b	52	
	dc.b	62	
	dc.b	76	
;	31
	dc.b	15	
	dc.b	23	
	dc.b	26	
	dc.b	29	
	dc.b	33	
	dc.b	38	
	dc.b	35+128		;44	
	dc.b	52	
	dc.b	62	
	dc.b	75	
;	32
	dc.b	16	
	dc.b	24	
	dc.b	26	
	dc.b	30	
	dc.b	34	
	dc.b	39	
	dc.b	30+128		;45	
	dc.b	52	
	dc.b	61	
	dc.b	74	
;	33
	dc.b	16	
	dc.b	25	
	dc.b	27	
	dc.b	31	
	dc.b	34	
	dc.b	39	
	dc.b	27+128		;45	
	dc.b	52	
	dc.b	61	
	dc.b	72	
;	34
	dc.b	17	
	dc.b	25	
	dc.b	28	
	dc.b	31	
	dc.b	35	
	dc.b	40	
	dc.b	23+128		;45	
	dc.b	52	
	dc.b	60	
	dc.b	71	
;	35
	dc.b	17	
	dc.b	26	
	dc.b	29	
	dc.b	32	
	dc.b	36	
	dc.b	40	
	dc.b	19+128		;46	
	dc.b	52	
	dc.b	60	
	dc.b	69	
;	36
	dc.b	18	
	dc.b	27	
	dc.b	30	
	dc.b	33	
	dc.b	37	
	dc.b	41	
	dc.b	13+128		;46	
	dc.b	52	
	dc.b	59	
	dc.b	68	
;	37
	dc.b	19	
	dc.b	28	
	dc.b	31	
	dc.b	34	
	dc.b	37	
	dc.b	41	
	dc.b	9+128		;46	
	dc.b	52	
	dc.b	58	
	dc.b	66	
;	38
	dc.b	20	
	dc.b	29	
	dc.b	32	
	dc.b	35	
	dc.b	38	
	dc.b	42	
	dc.b	3+128		;46	
	dc.b	51	
	dc.b	57	
	dc.b	65	
;	39
	dc.b	20	
	dc.b	30	
	dc.b	33	
	dc.b	35	
	dc.b	39	
	dc.b	42+128		;42	
	dc.b	46	
	dc.b	51	
	dc.b	56	
	dc.b	63	
;	40
	dc.b	21	
	dc.b	31	
	dc.b	34	
	dc.b	36	
	dc.b	39	
	dc.b	38+128		;43	
	dc.b	46	
	dc.b	51	
	dc.b	56	
	dc.b	61	
;	41
	dc.b	22	
	dc.b	32	
	dc.b	35	
	dc.b	37	
	dc.b	40	
	dc.b	33+128		;43	
	dc.b	46	
	dc.b	50	
	dc.b	55	
	dc.b	60	
;	42
	dc.b	22	
	dc.b	33	
	dc.b	36	
	dc.b	38	
	dc.b	40	
	dc.b	30+128		;43	
	dc.b	46	
	dc.b	50	
	dc.b	54	
	dc.b	58	
;	43
	dc.b	23	
	dc.b	35	
	dc.b	36	
	dc.b	39	
	dc.b	41	
	dc.b	25+128		;43	
	dc.b	46	
	dc.b	49	
	dc.b	53	
	dc.b	56	
;	44
	dc.b	24	
	dc.b	36	
	dc.b	37	
	dc.b	39	
	dc.b	41	
	dc.b	22+128		;44	
	dc.b	46	
	dc.b	49	
	dc.b	52	
	dc.b	55	
;	45
	dc.b	25	
	dc.b	37	
	dc.b	38	
	dc.b	40	
	dc.b	42	
	dc.b	17+128		;44	
	dc.b	46	
	dc.b	48	
	dc.b	51	
	dc.b	53	
;	46
	dc.b	26	
	dc.b	38	
	dc.b	39	
	dc.b	41	
	dc.b	42	
	dc.b	13+128		;44	
	dc.b	46	
	dc.b	48	
	dc.b	50	
	dc.b	52	
;	47
	dc.b	27	
	dc.b	39	
	dc.b	40	
	dc.b	41	
	dc.b	43	
	dc.b	9+128		;44	
	dc.b	45	
	dc.b	47	
	dc.b	48	
	dc.b	50	
;	48
	dc.b	28	
	dc.b	40	
	dc.b	41	
	dc.b	42	
	dc.b	43	
	dc.b	5+128		;44	
	dc.b	45	
	dc.b	46	
	dc.b	47	
	dc.b	48	
;	49
	dc.b	31	
	dc.b	42	
	dc.b	42	
	dc.b	43	
	dc.b	41+128		;43	
	dc.b	44	
	dc.b	45	
	dc.b	46	
	dc.b	46	
	dc.b	47	
;	50
	dc.b	33	
	dc.b	43	
	dc.b	43	
	dc.b	43	
	dc.b	37+128		;44	
	dc.b	44	
	dc.b	44	
	dc.b	45	
	dc.b	45	
	dc.b	45	
;	51
	dc.b	35	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	32+128			;32	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	

;	51
	dc.b	35	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	32+128			;32	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	

;	51
	dc.b	35	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	32+128			;32	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	
	dc.b	44	

barsMovingList

	;	0
	dc.b	1	;-85.247968352191	6			1
	dc.b	7	;-78.488829565408	13			8
	dc.b	8	;-70.423439073028	21			15
	dc.b	10	;-60.632629686045	31			25
	dc.b	12	;-48.496409277245	43			37
	dc.b	15	;-33.057324860388	58			52
	dc.b	20	;-12.754699638587	78			72
	dc.b	28	;15.139242753271	106			100
	dc.b	41	;55.861209123085	147			141		+ 57 = 198
	;	dc.b	65	;120.90273106053	212			59+128
	dc.b	57+128
	;	2
	dc.b	1	;-84.679071968123	6			1
	dc.b	7	;-77.814820039227	13			8
	dc.b	8	;-69.612246166621	21			16
	dc.b	10	;-59.63767496827	31			26
	dc.b	12	;-47.247367857656	43			38
	dc.b	16	;-31.442811510578	59			54
	dc.b	21	;-10.587260810535	80			75
	dc.b	29	;18.201176358385	109			104
	dc.b	42	;60.511666373648	151			146
	;	dc.b	68	;128.79546249124	219			52		= 198
	dc.b	53+128
	;	4
	dc.b	1	;-84.101674314217	6			1
	dc.b	7	;-77.129836553111	13			8
	dc.b	8	;-68.786546687066	21			16
	dc.b	10	;-58.622986520513	31			26
	dc.b	13	;-45.970519903608	44			39
	dc.b	16	;-29.787340404499	60			55
	dc.b	21	;-8.3559215278257	81			76
	dc.b	30	;21.370852486966	111			106
	dc.b	44	;65.36503210419	155				150
	;	dc.b	72	;137.14130468309	227			48		= 198
	dc.b	49+128
	;	6
	dc.b	2	;-83.51558339862	6			2
	dc.b	7	;-76.433608896733	13			9
	dc.b	8	;-67.945947991696	21			17
	dc.b	10	;-57.587971370131	31			27
	dc.b	13	;-44.664926406752	44			40
	dc.b	17	;-28.089332964813	61			57
	dc.b	22	;-6.0578136402109	83			79
	dc.b	31	;24.65405980795	114				110
	dc.b	46	;70.434882427265	160			156
	;	dc.b	76	;145.98042942977	236			42		=198
	dc.b	43+128
	;	8
	dc.b	3	;-82.920601404395	6			3
	dc.b	7	;-75.725857915219	13			10
	dc.b	9	;-67.090043138867	22			19
	dc.b	11	;-56.532012546715	33			30
	dc.b	13	;-43.32960559781	46			43
	dc.b	17	;-26.347128437244	63			60
	dc.b	23	;-3.6898947423817	86			83
	dc.b	32	;28.057009228226	118			115
	dc.b	48	;75.736032208951	166			163		
	;	dc.b	80	;155.35790185836	246			35		=198
	dc.b	36+128
	;	10
	dc.b	3	;-82.316524466912	6			3
	dc.b	7	;-75.006295135949	13			10
	dc.b	9	;-66.218410231066	22			19
	dc.b	11	;-55.454467855687	33			30
	dc.b	13	;-41.963530484469	46			43
	dc.b	17	;-24.558978472659	63			60
	dc.b	23	;-1.2489347362358	86			83
	dc.b	33	;31.586373106403	119			116
	dc.b	50	;81.284679654752	169			166
	;	dc.b	84	;165.32444890355	253			32
	dc.b	33+128

	;	12
	dc.b	4	;-81.703142440959	6			4
	dc.b	7	;-74.274622376526	13			11
	dc.b	9	;-65.330611721469	22			20
	dc.b	11	;-54.354668575912	33			31
	dc.b	14	;-40.565626217168	47			45
	dc.b	18	;-22.723041274765	65			63
	dc.b	24	;1.2684988698377	89			87
	dc.b	34	;35.249328919475	123			121
	dc.b	52	;87.098571630618	175			173
	;	dc.b	89	;175.93737730033	264			25
	dc.b	26+128

	;	14
	dc.b	4	;-81.080238656995	6			4
	dc.b	8	;-73.530531332778	14			12
	dc.b	9	;-64.426193681556	23			21
	dc.b	11	;-53.231918075769	34			32
	dc.b	14	;-39.134767268595	48			46
	dc.b	18	;-20.837375272256	66			64
	dc.b	25	;3.866057065352	91				89
	dc.b	35	;39.053607983707	126			124
	dc.b	54	;93.197193273262	180			178
	;	dc.b	94	;187.26167617214	274			20
	dc.b	21+128

	;	16
	dc.b	5	;-80.447589665976	6			5
	dc.b	8	;-72.7737031456	14				13
	dc.b	9	;-63.504685027206	23			22
	dc.b	11	;-52.085490341666	34			33
	dc.b	14	;-37.669774411315	48			47
	dc.b	19	;-18.899932269708	67			66
	dc.b	25	;6.5476270046894	92			91
	dc.b	36	;43.007549925648	128			127
	dc.b	57	;99.601986157705	185			184
	;	dc.b	100	;199.37134902239	285			14
	dc.b	15+128	

	;	18
	dc.b	6	;-79.804964972103	7			6
	dc.b	8	;-72.00380794537	15			14
	dc.b	9	;-62.565596700502	24			23
	dc.b	12	;-50.914628412476	36			35
	dc.b	15	;-36.169411476508	51			50
	dc.b	19	;-16.908550026426	70			69
	dc.b	26	;9.3173514164305	96			95
	dc.b	38	;47.120163710919	134			133
	dc.b	59	;106.33660016908	193			192
	;	dc.b	106	;212.35103281397	299			8
	dc.b	7+128

	;	20
	dc.b	6	;-79.152126752829	7			6
	dc.b	8	;-71.22050437255	15			14
	dc.b	10	;-61.608420804256	25			24
	dc.b	12	;-49.718542712785	37			36
	dc.b	15	;-34.632381875048	52			51
	dc.b	20	;-14.860944206716	72			71
	dc.b	27	;12.179649958872	99			98
	dc.b	39	;51.401196170708	138			137
	;	dc.b	62	;113.42718531395	200			199 --> -1
	dc.b	62+128
	dc.b	113	;226.29797901623	313
	;	22
	dc.b	7	;-78.488829565408	7
	dc.b	8	;-70.423439073028	15
	dc.b	10	;-60.632629686045	25
	dc.b	12	;-48.496409277245	37
	dc.b	15	;-33.057324860388	52
	dc.b	20	;-12.754699638587	72
	dc.b	28	;15.139242753271	100
	dc.b	41	;55.861209123085	141			57
	;	dc.b	65	;120.90273106053	206
	dc.b	58+128
	dc.b	120	;241.3244946835	326

grid1s		incbin	"fx/bars/bars.l77"						;16000 (orig) 3805 (l77) 2488 (arj)		-1400
	even
lines2		incbin	"fx/bars/linesfinal.l77"					;5600 (orig) 1070 (l77) 938 (arj)		-100

exec		incbin	"fx/checker/execrast2.bin"				;7360 (orig) 5066 (l77) 4568 (arj)		-2800
paletteList	incbin	"fx/checker/executerasters.bin"			;3456 (orig) 1647 (l77) 1294 (arj)		-2100

	IFEQ STANDALONE
	IFEQ PLAYMUSIC
music:	
	incbin		msx/exec29.snd
	ENDC
	include		lib/lib.s
	ENDC

	even

	section BSS
	IFEQ STANDALONE

screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	32000+65536
screen2:					ds.b	65536
align1:						ds.b	65536
align2:						ds.b	65536
align3:						ds.b	65536
align4:						ds.b	65536
align5:						ds.b	65536
align6:						ds.b	65536
alignpointer1				ds.l	1
alignpointer2				ds.l	1
alignpointer3				ds.l	1
alignpointer4				ds.l	1
alignpointer5				ds.l	1
alignpointer6				ds.l	1	
oldLower					ds.b	$a000
nextScene					ds.w	1
	ENDC

_paletteFadeDirection		ds.w	1
paletteOffx					ds.w	1
paletteOffxBase				ds.w	1
lineOffx					ds.w	1
fadeOffx					ds.w	1
linesPointer				ds.l	1
slopeListPointer			ds.l	1
grid1sPointer				ds.l	1
linesSourcePointer			ds.l	1
