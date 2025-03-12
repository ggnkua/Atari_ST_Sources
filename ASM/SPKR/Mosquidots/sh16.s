; Bugs:
;	- scroller when switching to sun vbl, forgets the last few pixels or so; cheated with using spaces there
;	- distortion of the sun is fucked up sometime, lets hope noone notices
;	- for some reason the scroller needs some more empty bytes, so just added 2000 0's...
;	- probably more, but not found
;
; Todo:
;	Clipart:
;	x convert neo to binary format for incbin
;	x adapt code to read from binary format
;	x define format together with number of bitplanes	(defailt 2 bpl)
; Fire:
;	x write out 2nd fire
; Dotsquitos
;	x write initial pixel template code
;	O something with highlights
;	x something with with random movement
; Sun
;	x generate/define rasters from picture
;	x color table rasters
;	x disting sun
;	x multiple dist patterns
;	O possibly water reflection?; not gonna happen
; Scroller
;	x implement font for scroller
;	O add sinus bounce wave; not gonna happen
; Fullscreen
;	O arbitrary code to inject during sun part, so we can move stuff in from the sides of the screen
; Tridi
;	O small objects circling around the sun	(pyramid, cube, octagon or smt)
; Logo
;	O moving it in
; 

TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1


FRAMECOUNT					equ 0
loadmusic					equ FALSE
loadscroller				equ FALSE

PLAYMUSIC					equ TRUE
playmusicinvbl				equ 1
useblitter					equ 1

screenCheck					equ false

boundarylines				equ false
rasters						equ false
tridi						equ 0

herp						equ false

bgh				equ 230
squito_y_top	equ	0*bgh
squito_y_bot	equ 16*bgh
squito_count	equ 100
squito_x_right	equ	420*4



doRaster macro
	IFEQ rasters
	move.w	#\1,$ffff8240
	ENDC
	endm

doRasterSync	macro
	IFEQ rasters
		move.w	#\1,$ffff8240
	ELSE
		REPT 4
			nop
		ENDR
	ENDC
	endm

swapClearList	macro
	move.l	clearListPointer,d0
	move.l	clearListPointer2,clearListPointer
	move.l	d0,clearListPointer2
	endm

    section	TEXT
	include lib/macro.s
		allocateStackAndShrink								; stack + superexec
	; INIT SETUP CODE ---------------------------------------
	jsr	saveAndKillTimers									; kill timers and save them
	jsr	disableMouse										; turn off mouse
	jsr	backupPalAndScrMemAndResolutionAndSetLowRes			; save screen address and other display properties
	jsr	checkMachineTypeAndSetStuff							; check machine type, disable cache
	jsr	setScreen64kAligned									; set 2 screens at 64k aligned
	IFEQ loadmusic
		move.l	#filename,d0
		move.l	#music,d1
		jsr		loadFile
		tst.w	fail
		bne		.exit
	ENDC

	IFEQ loadscroller
		jsr		loadScroller
		tst.w	fail2
		bne		.exit
	ENDC
	move.w	#-1,lulz
;	jsr		prepLogo
	jsr		prepSunBuffers
;	jsr		initSunDist
;	jsr		prepCredits


	jsr		prepareScroll
	jsr		prepStroller
;	jsr		prepLinbuffList
	jsr		init_squitos








	move.w	#$2700,sr
	move.l	#faderout,$70
	move.w	#$2300,sr

.waitloop
		nop
	tst.w	_faded
	bne		.waitloop

	jsr		init_effect


.mainloop
;		jsr		clearScreens
	tst.w	_demoDone
	beq		.exit
	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		.mainloop										;



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

_sunShiftOff	dc.l	200*2*14
_sunScreenOff	dc.w	0

_faded			dc.w	-1
_fadeoff		dc.w	0
_fadecolors		equ		14
_fadepal		dc.w	$777,$776,$765,$763,$752,$740,$730,$620,$510,$400,$300,$200,$100,$0
_fadecounterconst	equ	3
_fadecounter	dc.w	_fadecounterconst
_fadedramawaiter	dc.w 100
_vblflag	dc.w	1

faderout
	move.w	#0,_vblflag
	move.w	_fadeoff,d0
	cmp.w	#(_fadecolors-1)*2,d0
	bne		.notready
		subq.w	#1,_fadedramawaiter
		bne		.nofade
			move.w	#0,_faded
		rte
.notready
	subq.w	#1,_fadecounter
	bne		.nofade
		move.w	#_fadecounterconst,_fadecounter
		addq.w	#2,d0
		lea		_fadepal,a0
		move.w	(a0,d0),$ffff8240
		move.w	d0,_fadeoff
.nofade
	rte

init_squitos
	move.l	#squitoClearList,clearListPointer
	move.l	#squitoClearList2,clearListPointer2

	move.l	clearListPointer,a0
	move.l	clearListPointer2,a1
	move.w	#squito_count-1,d7
	move.l	screenpointer2,d0
.l
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	dbra	d7,.l
	rts



right macro
	nop
	nop
	addq.w	#4,d0		;4	1
	jmp		(a5)		;8	2		
;	ds.b 4
	endm

left macro
	nop
	nop
	subq.w	#4,d0		;4	1
	jmp		(a5)		;8	2
;	ds.b 4
	endm

up	macro	
	nop					
	add.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b 4-2
	endm

down	macro
	nop
	sub.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b 4-2
	endm

topright	macro
	addq.w	#4,d0		;4	1
	sub.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b	2
	endm

botright	macro
	addq.w	#4,d0		;4	1
	add.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b	2
	endm

topleft	macro
	subq.w	#4,d0		;4	1
	sub.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b	2
	endm

botleft	macro
	subq.w	#4,d0		;4	1
	add.w	#bgh,d1		;8	2
	jmp		(a5)		;8	2
;	ds.b	2
	endm

nomove	macro
		nop
		nop
		jmp		(a5)	;8	2
;		ds.b	6
	endm

; a0 screenptr
; a1 local pixels
; a2 clearlistpointer
; a3 squito_x_right
; a4 xposi table
; a5 .draw return address
; a6 squitoTimers
; d0 x
; d1 y
; d2 mask for and
; d3 local var
; d4 random seed
; d5 loopcounter
; d6 constant
hardsync 	equ false

drawDot								;12		3
	IFEQ 	hardsync
	REPT 49							;		46
		nop
	ENDR
	ENDC
	;;;;;;; drawdot
	move.l	usp,a0					;4		1
	lea		pixels,a1				;8		2
	add.w	d0,a1					;8		2
	add.w	(a1)+,d1				;8		2
	move.w	(a1)+,d0				;8		2
	add.w	d1,a0					;8		2
	or.w	d0,(a0)					;12		3
	move.l	a0,(a2)+				;12		3
	;;;;;;; end drawdot
	dbra	d5,squito				;12		3		--> 20 draw
	move.l	d4,_randomSeed
	rts


;	idea as follows:
;	- we know where the top band of the fullscreen dots sync is			3*160+27*230+154*160
;	- this we use as our base height address; instead of the bottom
;	- then we have a negative offset that we add (subtract) from base
moveSquitos
	move.l	screenpointer2,a0											;20	5							screenpointer
	add.w	#3*160+27*230+154*160+6,a0
	add.w	#30*230,a0
	move.l	a0,usp														;4	1
	lea		xposi,a4													;8	2
	lea		squitoTimers,a6					; list of wait timers		;8	2
	moveq	#5,d6														;4	1
	move.w	#squito_count-1,d5											;8	2

	move.l	_randomSeed,d4												;20	5
;		rol.l	d4,d4				;						need to remove this
	move.w	#7<<2,d2													;8	2
	lea		draw,a5														;8	2
	move.w	#squito_x_right,a3											;8	2
	move.l	clearListPointer2,a2										;16	4	--> 30 setup

;per dot:
;	11 to get x,y and determine reset
;		reset (a)
;		16 to do movement
;		33 to get new value
;		20 to draw
;		no reset (b)
;		49 nop
;		20 to draw

squito
	move.w	(a4)+,d0				;8				2
	move.w	(a4)+,d1				;8				2
	subq.w	#1,-(a6)				;16				4		 
	bne		drawDot					;12 taken		3		-->11
		; 							;8 not taken	2


		move.w	d6,(a6)				;8				2
		addq.l	#5,d4				;8				2
		move.w	d4,d3				;4				1
		and.w	d2,d3				;4				1
		add.w	d3,d3				;4				1
		jmp		.codeTable(pc,d3)	;16				4

.codeTable							;20				5		--> 16
	right				;0	
	left				;1
	up					;2
	down				;3
	topright			;4
	botright			;5
	topleft				;6
	botleft				;7
	nomove				;8
	up
	down
	up
	down
	left
	right
	nomove
	nomove


draw
	IFEQ hardsync
	cmp.w	#squito_y_top,d1		;8				2
	bge		.ytopok					;
									;8 not taken	2
		add.w	#bgh,d1				;8				2
		jmp		.ytopok2			;12				3	
											
.ytopok								;12				3
	REPT 4
		nop							;16				4
	ENDR
.ytopok2							;								--> 9

	cmp.w	#squito_y_bot,d1		;8				2
	blt		.ybotok
									;8				2
		sub.w	#bgh,d1				;8				2
		jmp		.ybotok2			;12				3

.ybotok								;12				3
	REPT 4
		nop							;16				4
	ENDR
.ybotok2							;								--> 9

	tst.w	d0						;4				1
	bge		.xleftok
									;8				2
		move.w	a3,d0				;4				1

.xleftok							;12				3				
									;								--> 4						

	cmp.w	#squito_x_right,d0		;8				2
	ble		.xrightok
									;8				2
		moveq	#0,d0				;4				1

.xrightok							;12				3
									;								--> 5
	ELSE
	cmp.w	#squito_y_top,d1		;8				2
	bge		.ytopok					;
		add.w	#bgh,d1
.ytopok
	cmp.w	#squito_y_bot,d1
	blt		.ybotok
		sub.w	#bgh,d1
.ybotok
	tst.w	d0
	bge		.xleftok
		move.w	a3,d0
.xleftok
	cmp.w	#squito_x_right,d0
	ble		.xrightok
		moveq	#0,d0
.xrightok

	ENDC

		move.w	d0,-4(a4)			;12				3
		move.w	d1,-2(a4)			;12				3				--> 6

.next
	;;;;;;; drawdot
	move.l	usp,a0					;4		1
	lea		pixels,a1				;8		2
	add.w	d0,a1					;8		2
	add.w	(a1)+,d1				;8		2
	move.w	(a1)+,d0				;8		2
	add.w	d1,a0					;8		2
	or.w	d0,(a0)					;12		3
	move.l	a0,(a2)+				;12		3
	;;;;;;; end drawdot
	dbra	d5,squito				;12		3		--> 20 draw
.end

	move.l	d4,_randomSeed
	rts








;;;;;;;;;;;;;;; VBL STUFF
;;;;;;;;;;;;;;; VBL STUFF
;;;;;;;;;;;;;;; VBL STUFF
;;;;;;;;;;;;;;; VBL STUFF
;;;;;;;;;;;;;;; VBL STUFF
init_effect
	moveq	#1,d0
	jsr		music

;	IFEQ	boundarylines
;		jsr		doLines
;	ENDC
;	jsr		prepareBackgroundToBuffer

	movem.l	stroller,d0-d7
	movem.l	d0-d7,$ffff8240

	move.w	#$2700,sr
	move.l	#effect_vbl,$70
;	move.l	#timer_b,$120.w					;Install our own Timer B
;	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
	move.w	#$2300,sr
	rts



lulz	dc.w	0
phase2waiter	dc.w	60

scr1Off	set 0
; 3 * 160 open border
scr1Off set scr1Off+3*160
; 28 * 230 top
scr1Off set scr1Off+28*230

effect_vbl
	move.l	screenpointer2,$ffff8200
			screenswap
			schedule_timerA_topBorder
	move.w	#-1,_clearDone

	move.l	#timer_a_opentop,$134.w			;Install our own Timer A

	move.w	#1,_timer_b_place
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#timer_b,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.w	_timer_b_place,d0
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	tst.w	_sunriseStart
	beq		initphase2

	tst.w	_strollerActive
	bne		.tt
		jsr		doFire
		jsr		rollStroller
		jsr		doGroundLine
.tt

	jsr		checkTimer
	jsr		scrollText
	jsr		doIconRout
			doRaster $700

	IFEQ	PLAYMUSIC
		jsr		music+8
	ENDC
	rte


initphase2
	move.w	#0,lulz

phase2
	move.l	scrollScreenOff,_hax

	jsr		scrollText
	jsr		delshit
	jsr		scrollText							;lulwuthax
	move.l	#scrollScreenOff2,scrollScreenOff

	IFEQ	PLAYMUSIC
		jsr		music+8
	ENDC

	move.w	#$2700,sr
	move.l	#sun_vbl,$70
	move.w	#$2300,sr
	rte

_hax	dc.l	0

; 512 cycles for scanline
; 103 nops per scanline
_timer_b_place	dc.w	1

; 16 nop less on even (2) than uneven (1)
; 

timer_b
	clr.b	$fffffa1b.w			;Timer B control (stop)
	pushall
	movem.l	stroller,d0-d7
	movem.l	d0-d7,$ffff8240

	doRaster $700

	moveq	#2,d7				;D7 used for the overscan code	;4		1
	lea		$ffff8260,a5										;8		2
	lea		$ffff820a,a6										;8		2
	move.w	_timer_b_place,d2									;3	

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

	and.w	#%1,d2						;2
	beq		.special					;2
	dcb.w	17,$4e71

herpoffset	equ 5

.special
	rept 54-49
		nop
	endr

			move.l	screenpointer2,a2			;20	5
			add.l	scrollScreenOff,a2			;24	6
			add.w	#6-14,a2					;8	2
			moveq	#0,d0						;4	1

	move.w	#200-herpoffset,_timer_b_place															;20	;5
	move.b	#200-herpoffset,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)	;20	;5
	move.l	#timer_b2,$120.w																		;24
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20	;5
	bclr	#3,$fffffa17.w			;Automatic end of interrupt										;28	;7

	doRasterSync	$007																			;16	 4

;;;;;
	move.w	#8-1,d6				;8 ==> -2			;28			; 20 left
.loop3
		nop
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-90,$4e71
			lea		14(a2),a2
		REPT 22
			move.w	d0,(a2)
			lea		8(a2),a2
		ENDR

		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
;		dcb.w	12,$4e71
		REPT 3
			move.w	d0,(a2)
			lea		8(a2),a2
		ENDR

		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	13-3-1,$4e71
;		nop
		REPT 2						
			move.w	d0,(a2)
			lea		8(a2),a2
		ENDR

	dbra	d6,.loop3			; 12 ==> -3

;;;;; 8 done


		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-4*0,$4e71
;		move.w	#$007,$ffff8242
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-1-2-1,$4e71
	move.w	#17-1,d6
;		move.w	#$070,$ffff8240

;;;; 9 done

.loop2
			nop
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	90,$4e71
			move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
			nop																		;1
			move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
			dcb.w	12,$4e71
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
			nop
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	13-1-3-1,$4e71
		dbra	d6,.loop2

;;;; 26 done

;		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
;		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	90,$4e71
;		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
;		nop																		;1
;		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
;		dcb.w	12,$4e71
;		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
;		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	13,$4e71
;
;
;		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
;		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	90,$4e71
;		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
;		nop																		;1
;		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
;		dcb.w	12,$4e71
;		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
;		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	13,$4e71



; 2 synclines to change the colors of the line
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-13,$4e71
	movem.l	linePal,d0-d3
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-11-1,$4e71
	movem.l	d0-d3,$ffff8240	;11


		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90,$4e71
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-1,$4e71


	move.w	#0,_clearDone
	doRaster	$777
	move.w	#$2300,sr
	move.w	_plane1color,$ffff8242
	move.w	_plane2color,$ffff8244
	move.w	_plane3color,$ffff8246

	popall
	rte











_linecolor	dc.w	0

timer_b2
	clr.b	$fffffa1b.w			;Timer B control (stop)
	pushall
	doRaster	$700

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

.special
	rept 54+18-40	;-2
		nop
	endr
	movem.l	stroller,d0-d6/a1			;21
	movem.l	d0-d6/a1,$ffff8240				;19		--> 40


;	move.w	stroller+6,$ffff8242.w
;	move.w	stroller+8,$ffff8244.w
;	move.w	stroller+10,$ffff8246.w

	doRasterSync $070
	move.w	#27-1,d6
.loop
			nop
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	90,$4e71
			move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
			nop																		;1
			move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
			dcb.w	12,$4e71
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
			nop
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	12-3-1,$4e71
		dbra	d6,.loop


		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-13,$4e71
		movem.l	linePal,d0-d3	;
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12-11,$4e71
		movem.l	d0-d3,$ffff8240
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-5-1,$4e71
		move.w	_linecolor,$ffff8240


;		nop
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	88-3+4,$4e71
		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3
		dcb.w	8-4,$4e71	
		move.w	#0,$ffff8240
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	85,$4e71		;
		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3
		dcb.w	11,$4e71
;		move.w	#scrollerColour,$ffff8242
		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3
		dcb.w	12-3-2-4,$4e71
		lea		fontPal-2,a0

		move.w	#9-1,d6
;		REPT 10
.loop2
		move.w	(a0)+,$ffff8242
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90,$4e71
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-3-4-1,$4e71
;		ENDR
		dbra	d6,.loop2



	doRaster $777	
	move.w	#$2300,sr
	popall
	rte



timer_a_opentop
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
	REPT 84
		nop
	ENDR

	clr.b	$ffff820a.w				;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz
	rte





timer_b_line
	move.w	#$777,$ffff8240
	move.w	#$2700,sr
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#195,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)			;20	;5
	move.l	#timer_b_sun_openlower_fullscreen,$120.w																		;24
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20	;5
	bclr	#3,$fffffa17.w			;Automatic end of interrupt										;28	;7
	dcb.w	87,$4e71
	move.w	#0,$ffff8240

	move.w	#$2300,sr

	rte
xxx
	move.w	#$777,$ffff8240
	move.w	#$2700,sr
	clr.b	$fffffa1b.w			;Timer B control (stop)
	dcb.w	110,$4e71
	move.w	#0,$ffff8240
	move.w	#$2300,sr
	rte

_strollerWaiter		dc.w	1800



startsun
	moveq	#1,d0
	jsr		music
;	jsr		prepSun
	jsr		prepareScroll
	jsr		prepStroller
;	jsr		prepLinbuffList

	move.l	#scrollScreenOff2,scrollScreenOff


	move.w	#$2700,sr
	move.l	#sun_vbl,$70
	move.l	#timer_b_sun_topfullscreen,$120.w					;Install our own Timer B
	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
	move.w	#$2300,sr
	rts
 


; vbl scanline structure:
scr2Off set 0
;	- 3 lines of 160 to open border								; 3*160
scr2Off set scr2Off+3*160
;	- 27 lines of 230	fullscreen								; 27*230			--> here is the white line
scr2Off set scr2Off+27*230
;	- 154 lines of 160											; 154*160
scr2Off set scr2Off+154*160
;	- 61 lines of 230
;scrOff set scrOff+61*230


;	add.l	#31*230+197*160+2-16-63*160+8-40-72,a1

palOff	dc.w	-168
palOffWaiter	dc.w	3
distortbit		dc.w	-1
sun_vbl
	move.l	screenpointer2,$ffff8200
			screenswap
	move.w	#-1,_clearDone

	move.l	_randomSeed,d4
	rol.l	d4,d4
	move.l	d4,_randomSeed

	move.l	screenpointer2,a1		
			schedule_timerA_topBorder
			swapClearList


	move.w	#1,_timer_b_place
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#timer_b_sun_topfullscreen,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	tst.w	musicbit
	bne		.tttt
		move.w	#24*9,palOff
		move.w	#-1,musicbit
		move.w	#3,palOffWaiter
.tttt

	tst.w	_sunsetStart
	bne		.noFade
		cmp.w	#-168,palOff
		beq		.noFade
		sub.w	#24,palOff
.noFade
	lea		logoPal,a0
	add.w	palOff,a0
	movem.l	(a0),d0-d5
	movem.l	d0-d5,$ffff8240

	cmp.w	#-2,musicbit
	beq		.kkk
	subq.w	#1,palOffWaiter
	bge		.kkk
	move.w	#5,palOffWaiter
	tst.w	_sunsetStart
	beq		.kkk
	sub.w	#24,palOff
	bge		.kkk
		move.w	#0,palOff
.kkk

	lea		suncols,a0
	move.l	a0,_sunPointer


	IFEQ	PLAYMUSIC
		jsr		music+8
	ENDC



	tst.w	_clearScreenActive
	bne		.ok
			subq.w	#1,_clearScreenWaiter
			beq		.moveon
			jsr		clearLogo
			jsr		clearBgAndPixels
		rte

.ok
	jsr		clearStuff			; conditional

;	jsr		distSun
	jsr		moveSquitos



	jsr		doLogo				; conditional
	jsr		putBG				; conditional
	jsr		scrollText
	jsr		drawSun


	tst.w	distortbit
	bne		.nnn
		jsr		initSunDist2
		move.w	#-1,distortbit
.nnn


;	move.w	#$733,$ffff8240

;	-> _sunOff2 = 0
;	-> _sunsetStart = 0
	jsr		checkForOuttro
	rte

.moveon
	move.w	#0,_clearScreenDone
	jsr		checkForOuttro
	rte


_clearScreenActive	dc.w	-1
_clearScreenDone	dc.w	-1
_clearScreenWaiter	dc.w	3

checkForOuttro
	tst.w	_sunsetStart
	bne		ttend
	tst.w	_sunOff2
	bne		ttend
		move.w	#0,_clearScreenActive
		tst.w	_clearScreenDone
		bne		ttend
		move.w	#1,_clearScreenActive
;		move.b	#0,$ffffc123
outtro
		move.w	#$2700,sr
		move.l	#outtro_vbl,$70
		move.l	#outtro_timerb_hard,$120.w					;Install our own Timer B
		move.l	#dummy,$134.w			;Install our own Timer A
		move.w	#$2300,sr
		lea		_fadePal2+100*2,a0

ttend	

	rts


_fadePal2
	REPT 3
	dc.w	$777
	ENDR
	REPT 3
	dc.w	$776
	ENDR
	REPT 3
	dc.w	$775
	ENDR
	REPT 3
	dc.w	$765
	ENDR
	REPT 3
	dc.w	$764
	ENDR
	REPT 3
	dc.w	$763
	ENDR
	REPT 3
	dc.w	$762
	ENDR
	REPT 3
	dc.w	$752
	ENDR
	REPT 3
	dc.w	$751
	ENDR
	REPT 3
	dc.w	$750
	ENDR
	REPT 3
	dc.w	$740
	ENDR
	REPT 3
	dc.w	$730
	ENDR
	REPT 3
	dc.w	$720
	ENDR
	REPT 3
	dc.w	$620
	ENDR
	REPT 3
	dc.w	$610
	ENDR
	REPT 3
	dc.w	$510
	ENDR
	REPT 3
	dc.w	$500
	ENDR
	REPT 3
	dc.w	$400
	ENDR
	REPT 3
	dc.w	$300
	ENDR
	REPT 3
	dc.w	$200
	ENDR
	REPT 3
	dc.w	$100
	ENDR
	REPT 50
		dc.w	$000
	ENDR

outtro_timerb_hard
		move.w	#lineEndColor,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#black1,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	rte
black1
		move.w	#0,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#linecol1,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#197,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	rte

linecol1
		move.w	#lineEndColor,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#black2,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	rte
black2
		move.w	#0,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
	rte


clearLogo
	move.l	 screenpointer2,a0
	add.w	#3*160+6900,a0
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
	move.l	d0,a6	; 13*4 = 52 = 133
	move.w	#133-1,d7
.loop
		movem.l	d0-d6/a1-a6,-(a0)
	dbra	d7,.loop
	rts

clearBgAndPixels
	move.l	screenpointer2,a0
	add.w	#scr2Off,a0
	add.w	#70*230,a0
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
	move.l	d0,a6	; 13*4 = 52 = 15870 / 52 = 306

	move.w	#354-1,d7
.loop
		movem.l	d0-d6/a1-a6,-(a0)
	dbra	d7,.loop
	rts




_lineOff	dc.w	1
_demoDone	dc.w	-1
_credits	dc.w	1
_doneWaiter	dc.w	100
outtro_vbl
	move.w	#0,$ffff8240
	move.w	#$0,$ffff8242
	move.w	_lineOff,d0
	move.w	#200,d1

	IFEQ	PLAYMUSIC
		jsr		music+8
	ENDC


	clr.b	$fffffa1b.w			;Timer B control (stop)
	cmp.w	#100,d0
	beq		.done
	move.l	#outtro_timerb1,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	subq.w	#1,_credits
	blt		.nocredits
		jsr		copyCredits
.nocredits

	cmp.w	#100,d0
	beq		.ok
		addq.w	#1,_lineOff
.ok
	rte
.done

	subq.w	#1,_doneWaiter
	bge		.noexit
		move.l	screenpointer,a0
		move.l	screenpointer2,a1
		add.w	#98*160,a0
		add.w	#98*160,a1
		move.w	#20*5*2-1,d7
		moveq	#0,d0
.cl	
			move.l	d0,(a0)+
			move.l	d0,(a1)+
		dbra	d7,.cl
		move.w	#0,_demoDone
.noexit
	rte

copyCredits
	lea		creditsBuffer,a3
	move.l	screenpointer2,a1
	move.l	screenpointer,a2
	add.l	#98*160,a1
	add.l	#98*160,a2
y set 0
	REPT 5
o set y
		REPT 20
			move.w	(a3),o(a1)
			move.w	(a3)+,o(a2)
o set o+8
		ENDR
y set y+160
	ENDR
	rts

lalalist
	rept 200
		dc.w	0
	endr

outtro_timerb1
		move.w	#lineEndColor,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#outtro_timerb1_black,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	rte	

outtro_timerb1_black
		cmp.w	#100,d0
		beq		.ttt
		move.w	-(a0),$ffff8240
		sub.w	d0,d1
		sub.w	d0,d1
		subq.w	#1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#outtro_timerb2,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	d1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
	rte
.ttt
	move.w	#0,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte

outtro_timerb2
		move.w	#lineEndColor,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
		move.l	#outtro_timerb2_black,$120.w			;Install our own Timer B
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt	
	rte

outtro_timerb2_black
		move.w	#0,$ffff8240
		clr.b	$fffffa1b.w			;Timer B control (stop)
	rte	

_sunwaiter	dc.w	10
_sunFrames	dc.w	201
_sunOff		dc.w	197

clearStuff
	tst.w	shitDeleted
	beq		.done
		jsr		delGroundLines
		jsr		delshit
		subq.w	#1,shitDeleted
.done
	rts


; clear scroller
; clear squitos
timer_b_sun_topfullscreen
	clr.b	$fffffa1b.w			;Timer B control (stop)
	pushall

	doRaster $700

	moveq	#2,d7				;D7 used for the overscan code	;4		1
	lea		$ffff8260,a5										;8		2
	lea		$ffff820a,a6										;8		2
	move.w	_timer_b_place,d2									;3	

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

	and.w	#%1,d2						;2
	beq		.special					;2
	dcb.w	17,$4e71

.special
	rept 54-34-1		; 
		nop
	endr

	move.w	#200-herpoffset,_timer_b_place															;20		5
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)				;20		5
	move.l	#timer_b_sunline2,$120.w																;24 	6
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20		5
	bclr	#3,$fffffa17.w			;Automatic end of interrupt										;28		7
	doRasterSync	$007																			;16 	4
	move.w	#8-1,d6				;8 ==> -2															;8		2


	nop
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	dcb.w	90-14,$4e71
	move.l	screenpointer2,a2			;20	5
	add.l	scrollScreenOff,a2			;24	6
	add.w	#6,a2						;8	2
	moveq	#0,d0						;4	1
	move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
	nop																		;1
	move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
	dcb.w	12,$4e71
	move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
	nop
	move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
	dcb.w	13-1-2-1,$4e71
	sub.w	#14,a2



;	REPT 28
.loop
		nop
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-90,$4e71				;			---> 90
		lea		14(a2),a2				; 			2
		REPT 22							; 22*4 = 	88
			move.w	d0,(a2)
			lea		8(a2),a2
		ENDR
		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12-12,$4e71				;			---> 12
		REPT 3							; 3*4 = 12
			move.w	d0,(a2)		
			lea		8(a2),a2
		ENDR
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
;		dcb.w	13-12,$4e71			;			---> 11 + 1 nop at the start for the dbra ending
		REPT 2							; 2*4 = 8
			move.w	d0,(a2)	
			lea		8(a2),a2
		ENDR
	dbra	d6,.loop					; 3

; 17 left
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90-5,$4e71
		move.l	clearListPointer,a0

		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-1-2-1,$4e71
		move.w	#5-1,d6

.loop2
			nop
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	90-90,$4e71

			REPT 18
				move.l	(a0)+,a1			;3
				move.w	d0,(a1)				;2
			ENDR

			move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
			nop																		;1
			move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
			dcb.w	12-10,$4e71
			REPT 2
				move.l	(a0)+,a1			;3
				move.w	d0,(a1)				;2
			ENDR
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
			nop
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	13-1-3-1,$4e71
		dbra	d6,.loop2


;11 left
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2


	tst.w	_sunFrames					;16
	blt		.withdistx					;12	non taken
		dcb.w	90-7,$4e71


		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-1-2-1,$4e71
		move.w	#10-1,d6

;10 left
.loop3
			nop
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	90

			move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
			nop																		;1
			move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
			dcb.w	12

			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
			nop
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	13-1-3-1,$4e71

		dbra	d6,.loop3


		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90,$4e71

		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71

		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		move.w	#lineEndColor,$ffff8240
		add.w	#320,a1

	move.w	#0,_clearDone
	doRaster	$777
	popall
	rte


.withdistx	
		dcb.w	90-7-22,$4e71

	move.l	_sunPointer,a4		;20
	add.w	#2,a4				;8

	move.l	_sunDistScreenPointer,a0				;5
	move.l	_sunDistListPointer,a1					;5
	move.l	_sunDistBufferPointer,a3				;5


		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	13-1-1,$4e71
;		move.w	#10-1,d6

;10 left
.loop4
	REPT 10
			nop
			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	90

			move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
			nop																		;1
			move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
			dcb.w	12

			move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
			nop
			move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
			dcb.w	13-1-1,$4e71

;		dbra	d6,.loop4
	ENDR

		nop
		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Left border
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		dcb.w	90,$4e71

		move.w	d7,(a6)					;		move.w	d7,$ffff820a.w			;2 Right border
		nop																		;1
		move.b	d7,(a6)					;		move.b	d7,$ffff820a.w			;2
		dcb.w	12,$4e71

		move.b	d7,(a5)					;		move.b	d7,$ffff8260.w			;2 Stabilizer
		nop
		move.w	d7,(a5)					;		move.w	d7,$ffff8260.w			;2
		move.w	#lineEndColor,$ffff8240
		add.w	#320,a1

	move.w	#0,_clearDone
	doRaster	$777
	popall
	rte


_sunOff2	dc.w	24*3




timer_b_sunline2
;	move.w	#$777,$ffff8240
	move.w	#$2700,sr
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#11,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)			;20	;5
	move.l	#timer_b_sun_rasters_init,$120.w																		;24
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20	;5
	bclr	#3,$fffffa17.w			;Automatic end of interrupt										;28	;7
	dcb.w	87-10-16-20-10,$4e71

	pusha0
			lea		bgList,a0
			add.w	bgOff,a0
			move.w	(a0)+,$ffff8240
			move.w	(a0),$ffff8240+2*8
			move.l	#0,$ffff8244
			move.w	(a0),$ffff8240+2*8+2
			move.w	(a0),$ffff8240+2*8+2+4
			move.w	(a0),$ffff8240+2*8+4
	popa0

	move.w	#$2300,sr
	rte
;;; changes timer to background colouring. calls the timer_b_raster next
;;; - from nonfullscreen: line 12
timer_b_sun_rasters_init
	pusha0
	move.l	_sunPointer,a0
	move.w	(a0)+,$ffff8242
	move.l	a0,_sunPointer

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)			;20	;5
	move.l	#timer_b_sun_raster,$120.w																		;24
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))								;20	;5
	bclr	#3,$fffffa17.w			;Automatic end of interrupt										;28	;7

	popa0
	rte

; sun raster, being called each scanline, until it runs out of colors, then schedules the opening of lower border
timer_b_sun_raster
	pusha0
	move.l	_sunPointer,a0				;20
	move.w	(a0)+,$ffff8242					;8
	beq		.lowerpartend						;8
	move.l	a0,_sunPointer				;20
	popa0
	rte
	

.lowerpartend
	move.w	(a0)+,$ffff8242		
	clr.b	$fffffa1b.w			;Timer B control (stop)
	popa0
	pushall
	moveq	#2,d7				;D7 used for the overscan code	;4		1
;	lea		$ffff8260,a5										;8		2
;	lea		$ffff820a,a6										;8		2
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr	
	moveq	#0,d0
	lea		$ffff8209.w,a1		;Hardsync
	move.b	(a1),d0
	moveq	#127,d1				;
.sync:		
		cmp.b	(a1),d0
	beq.s	.sync				;
	move.b	(a1),d0				;
	sub.b	d0,d1				;
	lsr.l	d1,d1				;

	tst.w	_sunFrames					;16
	blt		.withdist					;12	non taken

	dcb.w	64-7-7,$4e71
	move.l	_sunPointer,a0		;20
	add.w	#2,a0				;8

;	move.b	#0,$ffffc123
;	move.w	#$700,$ffff8240
;	move.w	#$111,$ffff8240		;16 4
.nodist
	; todo, remove the rept 44
	REPT 44
		dcb.w	11-4,$4e71		
		move.w	(a0)+,$ffff8242		

		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88,$4e71



		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	ENDR


	dcb.w	11-4,$4e71		
	move.w	#lineEndColor,$ffff8240
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 50 Hz
	dcb.w	88,$4e71
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11,$4e71

	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz



	;Special case line for lower border
	dcb.w	8-4,$4e71		
	move.w	#0,$ffff8240
	move.w	d7,$ffff820a.w			;3 60 Hz Lower border
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 60 Hz
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	85,$4e71			
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11-3,$4e71
	lea		fontPal-2,a0
	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz

	REPT 10

		move.w	(a0)+,$ffff8250
		dcb.w	11-4,$4e71		
		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88,$4e71
		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	ENDR

	popall
	rte

.withdist

	dcb.w	64-14-15,$4e71
	move.l	_sunPointer,a6		;20
	add.w	#2,a6				;8

	move.l	_sunDistScreenPointer,a0				;5
	move.l	_sunDistListPointer,a1					;5
	move.l	_sunDistBufferPointer,a3				;5

o set 2*14
y set 160

	REPT 29
		dcb.w	11-4,$4e71		
		move.w	(a6)+,$ffff8242		

		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88-62,$4e71

		lea		o(a3),a2			; local			;2
		add.l	(a1)+,a2							;4
x set y
		REPT 14
			move.w	(a2)+,x(a0)						;4			14*4 = 56 + 2 +4  = 62
x set x+8
		ENDR
o set o+2*14
y set y+160

		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	ENDR


y set y+24

	REPT 15
		dcb.w	11-4,$4e71		
		move.w	(a6)+,$ffff8242		

		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88-62,$4e71

		lea		o(a3),a2
		add.l	(a1)+,a2
x set y
		REPT 14
			move.w	(a2)+,x(a0)
x set x+8
		ENDR
o set o+2*14
y set y+230

		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	ENDR



	dcb.w	11-4,$4e71		
	move.w	#lineEndColor,$ffff8240
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 50 Hz
	dcb.w	88,$4e71
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11,$4e71

	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz



	;Special case line for lower border
	dcb.w	8-4,$4e71		
	move.w	#0,$ffff8240
	move.w	d7,$ffff820a.w			;3 60 Hz Lower border
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 60 Hz
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	85,$4e71			
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11-3,$4e71
	lea		fontPal-2,a6
	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz

	REPT 10

		move.w	(a6)+,$ffff8250
		dcb.w	11-4,$4e71		
		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88-62,$4e71

		lea		o(a3),a2
		add.l	(a1)+,a2
x set y
		REPT 14
			move.w	(a2)+,x(a0)
x set x+8
		ENDR
o set o+2*14
y set y+230

		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	ENDR

	popall
	rte





;; opens lower fullscreen
timer_b_sun_openlower_fullscreen
	clr.b	$fffffa1b.w			;Timer B control (stop)

	pushall
	moveq	#2,d7				;D7 used for the overscan code	;4		1
;	lea		$ffff8260,a5										;8		2
;	lea		$ffff820a,a6										;8		2
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


	dcb.w	63-15,$4e71


;	move.w	#$700,$ffff8240
	dcb.w	11,$4e71		

	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 50 Hz
	dcb.w	88,$4e71
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11,$4e71

	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz


	dcb.w	11-4-4,$4e71		
	move.w	#$777,$ffff8240
	move.w	#scrollerColour,$ffff8242
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 50 Hz
	dcb.w	88,$4e71
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11,$4e71
	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz

	;Special case line for lower border
	dcb.w	8,$4e71		

	move.w	d7,$ffff820a.w			;3 60 Hz Lower border
	move.b	d7,$ffff8260.w			;3 71 Hz Left border
	move.w	d7,$ffff8260.w			;3 60 Hz
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	85,$4e71			
	move.w	d7,$ffff820a.w			;3 60 Hz Right border
	move.b	d7,$ffff820a.w			;3 50 Hz
	dcb.w	11-2,$4e71

	move.w	#9-1,d6

	move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
	move.w	d7,$ffff8260.w			;3 50 Hz

	;44 lines with left/right border
	nop
	nop
	nop

.loopd
		dcb.w	11-3,$4e71		
		move.b	d7,$ffff8260.w			;3 71 Hz Left border
		move.w	d7,$ffff8260.w			;3 50 Hz
		dcb.w	88,$4e71
		move.w	d7,$ffff820a.w			;3 60 Hz Right border
		move.b	d7,$ffff820a.w			;3 50 Hz
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3 71 Hz Stabilizer
		move.w	d7,$ffff8260.w			;3 50 Hz
	dbra	d6,.loopd
	popall
	rte


bgWaiter	dc.w	50

scroll_vbl
			schedule_timerA_topBorder
	move.l	screenpointer2,$ffff8200
			screenswap

	move.w	#1,_timer_b_place
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#timer_b,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.w	_timer_b_place,d0
	move.b	d0,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.w	#$777,$ffff8240

	move.w	#$070,$ffff8240
	jsr		clearText
	move.w	#$007,$ffff8240
	jsr		scrollText
	move.w	#$777,$ffff8240


	rte

_logoDone		dc.w	-1
_logoWaiter		dc.w	2
_logoWaiter2	dc.w	5

;prepLogo
;	lea		logo1+128,a0
;	lea		logo2+128,a1
;	lea		logoBuffer,a2
;	move.l	a2,a3
;	REPT 27
;		REPT 20
;			move.l	(a0)+,(a2)+
;			move.l	(a0)+,(a2)+
;		ENDR
;		REPT 7
;			move.l	(a1)+,(a2)+
;			move.l	(a1)+,(a2)+
;		ENDR
;		add.w	#160-2*7*4,a1
;	ENDR
;	move.l	#27*27*8,d0
;	move.b	#0,$ffffc123
;	rts
;
;logoBuffer
;	ds.b	27*27*8

doLogo
	subq.w	#1,_logoWaiter2
	bgt		.logoDone
	tst.w	_logoDone
	beq		.logoDone
	subq.w	#1,_logoWaiter
	bgt		.logoDone
	beq		.notDone
		move.w	#0,_logoDone
.notDone
	lea		logoBuffer,a0
	move.l	screenpointer2,a1
	add.w	#3*160,a1
	move.w	#27-1,d7
.loop
o set 0
		REPT 27
			move.l	(a0)+,o(a1)
			move.l	(a0)+,o+4(a1)
o set o+8
		ENDR
		add.w	#230,a1
	dbra	d7,.loop
.logoDone
	rts

;doLogo2
;	tst.w	_logoDone
;	beq		.logoDone
;	subq.w	#1,_logoWaiter
;	bgt		.logoDone
;	beq		.notDone
;		move.w	#0,_logoDone
;.notDone
;
;	lea		logo1+128,a0
;	move.l	screenpointer2,a1
;	add.w	#3*160,a1
;	move.l	a1,a2
;	move.w	#27-1,d7
;.copyLine
;o set 0
;p set 0
;	REPT 20
;		move.l	o(a0),p(a1)
;		move.l	o+4(a0),p+4(a1)
;o set o+8
;p set p+8
;	ENDR
;	add.w	#160,a0
;	add.w	#230,a1
;	dbra	d7,.copyLine
;
;	lea		logo2+128,a0
;	move.l	a2,a1
;	move.w	#27-1,d7
;.copyLine2
;o set 0
;p set 160
;	REPT 6
;		move.l	o(a0),p(a1)
;		move.l	o+4(a0),p+4(a1)
;o set o+8
;p set p+8
;	ENDR
;	add.w	#160,a0
;	add.w	#230,a1
;	dbra	d7,.copyLine2
;.logoDone
;	rts

;;;;;;;;;;;; SCROLLER STUFF
;;;;;;;;;;;; SCROLLER STUFF
;;;;;;;;;;;; SCROLLER STUFF
;;;;;;;;;;;; SCROLLER STUFF
font_characters		equ	57
font_height			equ 8
font_shifts			equ 8
scrollOff	dc.l	0


clearText
	move.l	screenpointer2,a2			;20
	add.l	scrollScreenOff,a2			;24
	add.w	#6,a2						;8
	moveq	#0,d0						;4
xx set 0
	REPT 27
o set xx
		REPT 8
			move.w	d0,o(a2)			;12		; 8 * 27 * 12 = 2592 cycles
o set o+scrollLineWidth
		ENDR
xx set xx+8
	ENDR
	rts

_clearDone	dc.w	-1	
scrollText
	checkScreen
	tst.w	_scrollerActive
	bne		.not16

.waiter
	tst.w	_clearDone
	bne		.waiter

	lea		scrollTextPrepped,a6											;12
	add.l	scrollOff,a6													;16

	lea		fontBuffer,a0													;12
	move.l	screenpointer2,a2												;20
	add.w	#6+8,a2															;8


	add.l	scrollScreenOff,a2														;8
	move.w	offset,d0														;12
	cmp.w	#8,offset
	blt		.less8

	jmp		.8ormore

.less8
	muls	#font_characters*font_height*font_shifts*2,d0
	add.l	d0,a0															;8
	move.l	a0,a3															;4

xpos set 0
		move.l	a3,a0														;4				1
		add.w	(a6)+,a0													;12				3		
o set xpos
		REPT font_height
			move.b	(a0)+,d0												;8				2
			move.b	(a0)+,o(a2)											;16				4		--> 84						;; 115 in a hardsync line
o set o+scrollLineWidth
		ENDR

xpos set 0
	REPT 27
		move.l	a3,a0														;4				1
		add.w	(a6)+,a0													;12				3
o set xpos
		movem.w	(a0)+,d0-d7													;44				11
		or.w	d0,o+scrollLineWidth*0(a2)												;12				3
		or.w	d1,o+scrollLineWidth*1(a2)												;16				4
		or.w	d2,o+scrollLineWidth*2(a2)												;16				4
		or.w	d3,o+scrollLineWidth*3(a2)												;16				4
		or.w	d4,o+scrollLineWidth*4(a2)												;16				4
		or.w	d5,o+scrollLineWidth*5(a2)												;16				4
		or.w	d6,o+scrollLineWidth*6(a2)												;16				4
		or.w	d7,o+scrollLineWidth*7(a2)												;16				4		--> 12,5 * 4 = 50

		move.l	a3,a0														;4				1
		add.w	(a6)+,a0													;12				3		
o set xpos
		REPT font_height
			move.b	(a0)+,d0												;8				2
			or.b	d0,o+1(a2)												;16				4
			move.b	(a0)+,o+8(a2)											;16				4		--> 84						;; 115 in a hardsync line
o set o+scrollLineWidth
		ENDR

xpos set xpos+8
	ENDR

	move.l	a3,a0														;4				1
	add.w	(a6)+,a0													;12				3		
o set xpos
	movem.w	(a0)+,d0-d7													;44				11
	or.w	d0,o+scrollLineWidth*0(a2)												;12				3
	or.w	d1,o+scrollLineWidth*1(a2)												;16				4
	or.w	d2,o+scrollLineWidth*2(a2)												;16				4
	or.w	d3,o+scrollLineWidth*3(a2)												;16				4
	or.w	d4,o+scrollLineWidth*4(a2)												;16				4
	or.w	d5,o+scrollLineWidth*5(a2)												;16				4
	or.w	d6,o+scrollLineWidth*6(a2)												;16				4
	or.w	d7,o+scrollLineWidth*7(a2)												;16				4		--> 12,5 * 4 = 50
	jmp		.drawdone

.8ormore
	sub.w	#8,d0
	muls	#font_characters*font_height*font_shifts*2,d0
	add.l	d0,a0
	move.l	a0,a3
	add.w	#2,a6

xpos set 0
	REPT 28
		move.l	a3,a0
		add.w	(a6)+,a0
o set xpos
		REPT font_height
			move.b	(a0)+,d0
			or.b	d0,o-7(a2)
			move.b	(a0)+,o(a2)
o set o+scrollLineWidth
		ENDR

		move.l	a3,a0
		add.w	(a6)+,a0
o set xpos
		movem.w	(a0)+,d0-d7
		or.w	d0,o(a2)
		or.w	d1,o+scrollLineWidth(a2)
		or.w	d2,o+scrollLineWidth*2(a2)
		or.w	d3,o+scrollLineWidth*3(a2)
		or.w	d4,o+scrollLineWidth*4(a2)
		or.w	d5,o+scrollLineWidth*5(a2)
		or.w	d6,o+scrollLineWidth*6(a2)
		or.w	d7,o+scrollLineWidth*7(a2)
o set o+scrollLineWidth
xpos set xpos+8
	ENDR
.drawdone
	addq.w	#2,offset					; 2 pixels
	cmp.w	#16,offset					; if we have done 16 pixels, then we need to add to offset
	bne		.not16
		move.w	#0,offset				; set local off to 0
		add.l	#4,scrollOff			; add 4 to scroll off, so this is 2 letters
		cmp.l	#scrollLength,scrollOff	;	
		ble		.not16
			move.l	#0,scrollOff
.not16
	rts

prepareScroll
	jsr		copyFontBinToBuffer
	jsr		shiftFont
	jsr		convertScrollText
	rts

convertScrollText
	lea		scroller,a0
	lea		scrollTextPrepped,a1
	move.l	#scrollLength-1,d7
.l	
		moveq	#0,d0
		move.b	(a0)+,d0
		sub.w	#35,d0
		lsl.w	#4,d0
		move.w	d0,(a1)+
	dbra	d7,.l
	rts

shiftFont
	lea		fontBuffer,a2											; source
	REPT 8
		move.l	a2,a0
		lea		font_characters*font_height*font_shifts*2(a0),a1		; dest
		move.l	a1,a2
		jsr		shiftFontOneLeft
	ENDR
	rts

shiftFontOneLeft
    move.l  #font_characters*font_height-1,d7
    moveq   #0,d0
    roxl.l  #1,d0
.shiftword
	    move.w  (a0)+,d0
	    roxl.w  #1,d0
	    move.w  d0,(a1)+
    dbra    d7,.shiftword
    rts	


; this is used to generated the font, that is incbinned later
copyFontBinToBuffer
	lea		fontBin,a0
	lea		fontBuffer,a1
	move.w	#(2*12*2*8)+4*2*8,d7
.loop
		move.w	(a0)+,(a1)+
	dbra	d7,.loop
	rts

;neoFontToBinary
;	lea		font+128,a0
;	lea		fontBuffer,a1
;	move.l	a1,a2
;	; 2 rows of 24
;y set 0
;	REPT 2
;y set y+160		; skip first line
;h set 0
;		REPT 12
;voff set 0
;			REPT font_height
;				moveq	#0,d0
;				move.b	voff+y+h(a0),d0
;				move.w	d0,(a1)+
;voff set voff+160
;			ENDR
;
;voff set 0
;h set h+1
;			REPT font_height
;				moveq	#0,d0
;				move.b	voff+y+h(a0),d0
;				move.w	d0,(a1)+
;voff set voff+160
;			ENDR
;h set h+7
;		ENDR
;y set y+8*160
;	ENDR
;
;	; 1 row of 9
;y set y+160		; skip first line
;
;h set 0
;	REPT 4
;voff set 0
;		REPT font_height
;			moveq	#0,d0
;			move.b	voff+y+h(a0),d0
;			move.w	d0,(a1)+
;voff set voff+160
;		ENDR
;
;h set h+1
;
;voff set 0
;		REPT font_height
;			moveq	#0,d0
;			move.b	voff+y+h(a0),d0
;			move.w	d0,(a1)+
;voff set voff+160
;		ENDR
;
;h set h+7
;	ENDR
;
;voff set 0
;		REPT font_height
;			moveq	#0,d0
;			move.b	voff+y+h(a0),d0
;			move.w	d0,(a1)+
;voff set voff+160
;		ENDR
;
;
;
;;	move.l	a1,d0
;;	sub.l	a2,d0
;;	move.b	#0,$ffffc123
;
;	rts



bgOff		dc.w	0
bgList
	dc.w	$000,$001
	dc.w	$001,$112
	dc.w	$002,$222
	dc.w	$112,$224
	dc.w	$113,$334

;Z01: switch icon (as now is included)
;Z02: introduce scroller
;Z03: start stroller coming in
;Z04: start sunrise
;Z05: flash of top-logo
;Z06: start sunset and exit
;Z07: sundist

_scrollerActive		dc.w	-1
_strollerActive		dc.w	-1
_sunriseStart		dc.w	-1
_sunsetStart		dc.w	-1

checkTimer
	move.l	#music,a0										;12
	move.b	$b8(a0),d0										;12

	cmp.b	#2,d0
	bne		.not2
		move.w	#0,_scrollerActive
		move.b	#0,$b8(a0)
.not2


	cmp.b	#3,d0
	bne		.not3
		move.w	#0,_strollerActive
		move.b	#0,$b8(a0)
.not3

	cmp.b	#4,d0
	bne		.not4
		move.w	#0,_sunriseStart
		move.b	#0,$b8(a0)
.not4

	rts


checkBG
	move.l	#music,a0										;12
	move.b	$b8(a0),d0										;12

	
	cmp.b	#5,d0											;8
	bne		.not5				
							;12 not taken
		move.b	#0,$b8(a0)			; reset z
		move.w	#0,musicbit
		rts
.not5

	cmp.b	#6,d0
	bne		.not6
		move.w	#0,$b8(a0)
		move.w	#0,_sunsetStart
.not6

	tst.w	inverseWaiter
	blt		.inverse
	move.b	#0,$b8(a0)			; reset z


	cmp.b	#7,d0
	bne		.not7	
		move.w	#0,distortbit
.not7
	rts


.inverse
	cmp.b	#2,d0
	bne		.end
	move.b	#0,$b8(a0)			; reset z
	lea		bgList,a0
	cmp.w	#0,bgOff
	beq		.end
		subq.w	#4,bgOff
;		sub.w	#24,palOff

.end

	rts
musicbit	dc.w	-2


;prepSun
;	lea		sun2+128,a0
;	lea		sunBuffer2,a1
;	move.l	a1,a2
;	move.l	#200-1,d7
;.loop
;o set 32
;		REPT 12
;		move.w	o(a0),(a1)+
;o set o+8
;		ENDR
;		add.w	#160,a0
;	dbra	d7,.loop
;	move.b	#0,$ffffc123	;	4800
;	rts


; condition to know that sun is set
;	-> _sunOff2 = 0
;	-> _sunsetStart = 0

sunWaiter2	dc.w	4

bgCounter2	dc.w	48


distSun
		jsr		drawDistSun
		jsr		advanceDist
	rts


drawSun
	subq.w	#1,_sunwaiter
	bgt		sunEnd
	jsr		inverseSun
	jsr		checkBG

	subq.w	#1,_sunFrames
	blt		distSun

	subq.w	#1,sunWaiter2
	bgt		sunEnd
	subq.w	#1,bgCounter2
	bne		.continue
		tst.w	_sunsetStart
		beq		.sunset
		move.w	#48,bgCounter2
			cmp.w	#16,bgOff
			beq		.continue
			addq.w	#4,bgOff
			jmp		.continue
.sunset
		move.w	#48,bgCounter2
			tst.w	bgOff
			beq		.continue
			subq.w	#4,bgOff
.continue	

	lea		newSunbuffer,a0										;12
	lea		newSunbuffer2,a2										;12
	move.l	screenpointer,a1									;20
	add.w	#27*230+2*160+32,a1									;8
	add.w	_sunOff2,a0					; per 12*2				;16
	add.w	_sunOff2,a2

y set 0
	REPT 157-24+22
o set y
		REPT 12
			move.w	(a0)+,o(a1)									;16				4 nops per inner, 155 * 12 * 4 = 7440
o set o+8
		ENDR
y set y+160
	ENDR


	add.w	#(157-24)*12*2,a2
	add.w	#22*24,a2

;y set y-160
	REPT 25
o set y+24
		REPT 12
			move.w	(a2)+,o(a1)
o set o+8
		ENDR
y set y+230
	ENDR

sunCheck
	cmp.w	#198*24,_sunOff2
	beq		sunEnd
sunChange
	add.w	#24,_sunOff2
sunEnd
	rts




sunDirection	dc.w	0

inverseWaiter	dc.w	5800-300-800

inverseSun
	tst.w	_sunsetStart
	bne		.end
	lea		sunCheck,a0
	move.w	#0,2(a0)
	lea		sunChange,a1
	move.w	#$0479,(a1)
	move.w	#201,_sunFrames
.end
	rts



; 16 pixel wide, 8 pixel high buffer, word per pixel
fireHeight		equ 	14
fireWidth		equ		16
; fire effect:
; 
; 1 2 3
; 4 5 6
; 7 8 9
;
; to determine value 2:
; 2 = (4 + 5 + 6 + 8)/4
doFire
;;;;;;;;;; top fire
	lea		_fireBuffer1+fireWidth*(fireHeight-1)*2,a0			; buffer for lowest row
	move.l	_randomSeed,d0					; get the current seed
	jsr		seedFire

	lea		_fireBuffer1+2,a0				;+1 because we skip the upmost left
	lea		_fireResult1,a5
	jsr		calcFireEffect

;;;;;;;;;; bottom fire
	lea		_fireBuffer2+fireWidth*(fireHeight-1)*2,a0			; buffer for lowest row
	move.l	_randomSeed2,d0					; get the current seed
	jsr		seedFire

	lea		_fireBuffer2+2,a0				;+1 because we skip the upmost left
	lea		_fireResult2,a5
	jsr		calcFireEffect

	rts

getrnd: ; random32
; Can't remember where I found this snippet; (it doesnt matter, we'll credit you for it anyway :)
; In:  nothing
; Out: d0.l - pseudo-random number
  move.l  getrnd_seed(pc),d4
  add.l   d4,d4
  bcc.s   .done
  eori.b  #$AF,d4
.done:
  move.l  d4,getrnd_seed
  rts
getrnd_seed:
  dc.b "XiA!"


; here we seed the bottom row
seedFire
	move.w	#fireWidth-1,d7						; we have 16 pixels to randomize
	move.w	#$7,d2
	jsr		getrnd
	and.w	#3,d4

.doRandom
		addq.l	#5,d0
		rol.l	d0,d0
		move.w	d0,d1
		and.w	d2,d1
		move.w	d1,(a0)+
		sub.w	d4,d1
		blt		.noadd
			move.w	d1,-fireWidth*2-2(a0)
.noadd
	dbra	d7,.doRandom
	move.l	d0,_randomSeed
	lea		_fireBuffer1+fireWidth*(fireHeight-1)*2,a0			; buffer for lowest row
	rts



calcFireEffect
	lea		fireWidth*2-2(a0),a1					;-1 because we need to realign
	lea		fireWidth*4(a0),a2						;+1 again, since we are smart!

	; 6 times normal
y set 0
	REPT fireHeight-2									
o set y

		movem.w	o(a1),d0-d7/a3-a4			;a0		-  1  2  3  4  5  6  7  -
											;reg	d0 d1 d2 d3 d4 d5 d6 d7 a3
		add.w	d2,d1						;a1		a  b  c  d  e  f  g  h  i
		add.w	d1,d0						;a2		-  8  9  10 11 12 13 14 -
		add.w	(a2)+,d0
		lsr.w	#2,d0	

		; ^ determine 1 = d0 + d1 + d2 + 8, divide by 4

		add.w	d3,d1	
		add.w	(a2)+,d1
		lsr.w	#2,d1	
		; ^ determine 2 = d1 + d2 + d3 + 9, divide by 4

		add.w	d4,d3	
		add.w	d3,d2	
		add.w	(a2)+,d2
		lsr.w	#2,d2	
		; ^ determine 3 = d2 d3 d4 + 10

		add.w	d5,d3	
		add.w	(a2)+,d3
		lsr.w	#2,d3			; d3 d4 d5

		add.w	d6,d5	
		add.w	d5,d4	
		add.w	(a2)+,d4
		lsr.w	#2,d4			; d4 d5 d6

		add.w	d7,d5	
		add.w	(a2)+,d5
		lsr.w	#2,d5			; d5 d6 d7

		add.w	a3,d7
		add.w	d7,d6
		add.w	(a2)+,d6		; d6 d7 a3
		lsr.w	#2,d6

		add.w	a4,d7			; d7 a3 a4
		add.w	(a2)+,d7
		lsr.w	#2,d7

		movem.w	d0-d7,o(a0)						; first 8
		lsl.l	#4,d0
		add.w	d1,d0
		lsl.l	#4,d0
		add.w	d2,d0
		lsl.l	#4,d0
		add.w	d3,d0
		lsl.l	#4,d0
		add.w	d4,d0
		lsl.l	#4,d0
		add.w	d5,d0
		lsl.l	#4,d0
		add.w	d6,d0
		lsl.l	#4,d0
		add.w	d7,d0
		movep.l	d0,0(a5)

	
o set o+8*2

		movem.w	o(a1),d0-d7						; 16 + 5*4		; get 	4	5	6	d	e	f	m

		add.w	d2,d1							;4
		add.w	d1,d0							;4			d0 += 5
		add.w	(a2)+,d0						;8			d0 += 8
		lsr.w	#2,d0							;12						; yeah this sux

		add.w	d3,d1							;4			d1 += d
		add.w	(a2)+,d1						;8			d1 += 9
		lsr.w	#2,d1							;12

		add.w	d4,d3							;4
		add.w	d3,d2							;4			d2 += d
		add.w	(a2)+,d2						;8			d2 += g
		lsr.w	#2,d2							;12

		add.w	d5,d3							;4			d3 += f
		add.w	(a2)+,d3						;8			d3 += h
		lsr.w	#2,d3							;12

		add.w	d6,d5
		add.w	d5,d4							;4			d4 += f
		add.w	(a2)+,d4						;8			d4 += i
		lsr.w	#2,d4							;12	--> 5 * 28-8 = 140-8=132

		add.w	d7,d5
		add.w	(a2)+,d5
		lsr.w	#2,d5

;		add.w	a3,d7
;		add.w	d7,d6
;		add.w	(a2)+,d6		; d6 d7 a3
;		lsr.w	#2,d6

;		add.w	a4,d7			; d7 a3 a4
;		add.w	(a2)+,d7
;		lsr.w	#2,d7


		movem.w	d0-d5,o(a0)						;12 + 5*4
		lsl.l	#4,d0
		add.w	d1,d0
		lsl.l	#4,d0
		add.w	d2,d0
		lsl.l	#4,d0
		add.w	d3,d0
		lsl.l	#4,d0
		add.w	d4,d0
		lsl.l	#4,d0
		add.w	d5,d0
		lsl.l	#4,d0
;		add.w	d6,d0
		lsl.l	#4,d0
;		add.w	d7,d0
		movep.l	d0,1(a5)


		add.w	#8,a5
		add.w	#4,a2							; skip last + first
y set y+fireWidth*2
	ENDR

	rts



; 1). do we have active iconfade, if so -> fade
; 2). if we do not have active icon fade, do we have an iconcounter? if so -> drawIcon, if iconcounter reaches 0, then we need to set fade
; 3). if we do not have an iconcounter, check for music


; a). check for music, if z is encountered, state = b
; b). drawIcon, draw twice, then set state = c
; c). fade, fade until black, then set state = d
; d). clearIcon, if done clearing, set state = a
_iconState			dc.w	0
_plane1color		dc.w	0
_plane2color		dc.w	0
_plane3color		dc.w	0

doIconRout
	move.w	_iconState,d0
	beq		.checkMusic
	cmp.w	#2,d0
	beq		.drawIcon
	cmp.w	#4,d0
	beq		.doFade
	cmp.w	#6,d0
	beq		.clearIcon
		; error
		move.b	#0,$ffffc123
		rts
;;;;; state d). icon clearage
._clearIconCounter	dc.w	2
.clearIcon
	subq.w	#1,._clearIconCounter
	blt		.clearDone
		jsr	clearIcon
	rts
.clearDone
			lea		iconListSeq,a0
			add.w	_iconoffset,a0
;			add.w	#14,a0		; next
			add.w	#4,a0				
			move.l	(a0),a0
			add.w	#4,a0		; skip first
			move.l	(a0),a0
			movem.w	(a0)+,d0-d2
		tst.w	lulz
		bne		.skipdirect
			; here we should load the shit
			move.w	d0,$ffff8240+2
			move.w	d1,$ffff8240+4
			move.w	d2,$ffff8240+6

.skipdirect
		move.w	d0,_plane1color
		move.w	d1,_plane2color
		move.w	d2,_plane3color
		move.w	#0,_iconState
		move.w	#2,._clearIconCounter
		add.w	#4,_iconoffset
.noloop
	rts

;;;;; state a). check the music for z commands
.checkMusic
	move.l	#music,a0
	move.b	$b8(a0),d0
	cmp.b	#1,d0
	bne		.noZ
		move.b	#0,$b8(a0)			; reset z
		addq.w	#2,_iconState		; next state
.noZ
	rts
.beatWaiter			dc.w	9
;;;;; state b). draw frames until buffers done
._drawIconCounter	dc.w	2
.drawIcon
	subq.w	#1,._drawIconCounter
	blt		.drawDone
		jsr	drawIcon
		rts
.drawDone
	addq.w	#2,_iconState
	move.w	#2,._drawIconCounter
	rts

;;;;; state c). fade unil done
fadeSteps			equ 14+1
fadeWaiterFrames	equ 3
firstFadeWait		equ 8
._fadeCounter	dc.w	fadeSteps
._fadeWaiter	dc.w	fadeWaiterFrames
._firstFadeWaiter	dc.w	firstFadeWait
.doFade
	subq.w	#1,._firstFadeWaiter
	subq.w	#1,._fadeWaiter
	bne		.noFade
	subq.w	#1,._fadeCounter
	blt		.fadeDone
			move.w	._fadeCounter,d0
			neg.w	d0
			add.w	#fadeSteps-1,d0
			add.w	d0,d0	;2
			move.w	d0,d1	;2
			add.w	d0,d0	;4
			add.w	d1,d0	;6
			lea		iconListSeq,a0
			add.w	_iconoffset,a0
			move.l	(a0),a0
			add.w	#4,a0
			move.l	(a0),a0
			add.w	d0,a0
			movem.w	(a0),d0-d2


		tst.w	lulz
		bne		.skipdirect2
			move.b	#0,$ffffc123
			movem.w	d0-d2,$ffff8242
.skipdirect2
			move.w	d0,_plane1color
			move.w	d1,_plane2color
			move.w	d2,_plane3color
		move.w	#fadeWaiterFrames,._fadeWaiter
		move.w	#firstFadeWait,._firstFadeWaiter
.noFade
	rts

.fadeDone
	move.w	#fadeSteps,._fadeCounter
	addq.w	#2,_iconState
	move.w	#fadeWaiterFrames,._fadeWaiter
	rts

; d4
sub1Color
	move.b	#0,$ffffc123
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.w	d4,d5
	move.w	d4,d6
	move.w	d4,d7
	and.w	#%111100000000,d5
	and.w	#%11110000,d6
	and.w	#%1111,d7
	sub.w	#%000100000000,d5
	bge		.okR
		move.w 	#0,d5
.okR
	sub.w	#%00010000,d6
	bge		.okG
		move.w	#0,d6
.okG
	sub.w	#%1,d7
	bge		.okB
		move.w	#0,d7
.okB
	move.w	d7,d4
	or.w	d5,d4
	or.w	d6,d4
	rts






doLines
	move.l	screenpointer2,a0
	add.l	#160*3,a0
	moveq	#-1,d0
o set 0
	REPT 28
		move.l	d0,o(a0)
o set o+8
	ENDR

	move.l	screenpointer2,a0
	add.l	#160*3,a0
	add.l	#230*27,a0
	moveq	#-1,d0
o set 0
	REPT 28
		move.l	d0,o(a0)
o set o+8
	ENDR

	move.l	screenpointer2,a0
	add.l	#160*3,a0
	add.l	#230*28,a0
	add.l	#160*168,a0
	add.w	#230*4,a0
o set 0
	REPT 28
		move.l	d0,o(a0)
		move.l	d0,o+4(a0)
o set o+8
	ENDR
	rts

sprite_number_of_bitplanes	equ 4
sprite_height				equ	20
sprite_spacing				equ 0
sprite_width_block			equ	3
sprite_size					equ	sprite_height*sprite_width_block*2*sprite_number_of_bitplanes
sprite_buffersize			equ sprite_size*16
sprite_surface_scanwidth	equ 230

prepStroller
.leftstroller1
;	lea		stroller+128,a0
	lea		strollerleft1,a0
	lea		buffer,a1
	jsr		doFirstSprite

	; buffer source
	lea		buffer,a0
	; skip one sprite
	lea		buffer+sprite_size,a1
	; do the other 15
	move.w	#15-1,d6
.ss1
		jsr		shiftSprite
	dbra	d6,.ss1

.leftstroller2
;	lea		stroller+128,a0					; skip first
;	add.w	#sprite_height*160,a0
;	add.w	#sprite_spacing*160,a0																			; care hax!
	lea		strollerleft2,a0
	lea		buffer+sprite_size*16,a1		; 7680
	move.l	a1,a2
	jsr		doFirstSprite

	move.l	a2,a0
	lea		8*sprite_width_block*sprite_height(a2),a1
	move.w	#15-1,d6
.ss2
		jsr		shiftSprite
	dbra	d6,.ss2


.leftstroller3
;	lea		stroller+128,a0					; skip first
;	add.w	#2*sprite_height*160,a0
;	add.w	#2*sprite_spacing*160,a0																			; care hax!
	lea		strollerleft3,a0
	lea		buffer+sprite_size*16*2,a1		; 13824
	move.l	a1,a2
	jsr		doFirstSprite

	move.l	a2,a0
	lea		sprite_size(a2),a1
	move.w	#15-1,d6
.ss3
		jsr		shiftSprite
	dbra	d6,.ss3

.rightstroller1
;	lea		stroller+128,a0					; skip first
;	add.w	#3*sprite_height*160,a0
;	add.w	#3*sprite_spacing*160,a0																			; care hax!
	lea		strollerright1,a0
	lea		buffer+sprite_size*16*3,a1		; 13824
	move.l	a1,a2
	jsr		doFirstSprite

	move.l	a2,a0
	lea		sprite_size(a2),a1
	move.w	#15-1,d6
.ss4
		jsr		shiftSprite
	dbra	d6,.ss4

.rightstroller2
;	lea		stroller+128,a0					; skip first
;	add.w	#4*sprite_height*160,a0
;	add.w	#4*sprite_spacing*160,a0																			; care hax!
	lea		strollerright2,a0
	lea		buffer+sprite_size*16*4,a1		; 13824
	move.l	a1,a2
	jsr		doFirstSprite

	move.l	a2,a0
	lea		sprite_size(a2),a1
	move.w	#15-1,d6
.ss5
		jsr		shiftSprite
	dbra	d6,.ss5

.rightstroller3
;	lea		stroller+128,a0					; skip first
;	add.w	#5*sprite_height*160,a0
;	add.w	#5*sprite_spacing*160,a0																			; care hax!
	lea		strollerright3,a0
	lea		buffer+sprite_size*16*5,a1		; 13824
	move.l	a1,a2
	jsr		doFirstSprite

	move.l	a2,a0
	lea		sprite_size(a2),a1
	move.w	#15-1,d6
.ss6
		jsr		shiftSprite
	dbra	d6,.ss6
	rts



doFirstSprite
	move.w	#sprite_height-1,d7
	move.l	a1,d6
.loop
		REPT sprite_width_block
		; block 1
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
;		add.w	#160-8*sprite_width_block,a0
	dbra	d7,.loop

	rts

shiftSprite
	; sprite height
	move.l	#sprite_height-1,d7		
.yloop
	; y-height-source
	move.w	#sprite_width_block*sprite_number_of_bitplanes*2,d5
o set 0
		REPT sprite_number_of_bitplanes	; 4 bitplanes
s set o
		move.l	#0,d0
		roxr.w	d0
			REPT sprite_width_block
				; block
				move.w	s(a0),d0
				roxr.w	d0				; shift bit out
				move.w	d0,s(a1)
s set s+8
			ENDR
o set o+2
		ENDR
		add.w	d5,a0
		add.w	d5,a1
	dbra	d7,.yloop
	rts


delStroller
	move.l	screenpointer2,a1
	add.w	_scroff,a1
	add.w	#3*160+230*6,a1
	move.w	#sprite_height+2,d7
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5

o set 0
	REPT sprite_height+2
		movem.l	d0-d5,o(a1)
o set o+sprite_surface_scanwidth
	ENDR


	move.l	screenpointer2,a1
	add.w	#29*230,a1
	add.w	#(177-herpoffset)*160,a1
	move.w	#230-38,d0
	sub.w	_scroff,d0
	add.w	d0,a1


	moveq	#0,d0
	move.l	d0,d6
	move.l	d0,d7

o set 0
	REPT sprite_height+3
		movem.l	d0-d7,o(a1)
o set o+sprite_surface_scanwidth
	ENDR
	rts


_fireoff		dc.w	10*16
_fireoff2		dc.w	11*16
_buffoff		dc.w	0
_scroff			dc.w	-16
strolldelay 	equ 1
_strolldelay	dc.w	strolldelay
_strollend		dc.w	-1
_anioff			dc.w	0
_delCounter		dc.w	0


roxFire macro
	movem.w	(a5)+,d0-d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea		.haha\@,a6
	sub.w	a1,a6
	jmp		(a6)
	REPT 16
		roxr.w	d0		;2
		roxr.w	d4		;2
		roxr.w	d1		;2
		roxr.w	d5		;2
		roxr.w	d2		;2
		roxr.w	d6		;2
		roxr.w	d3		;2
		roxr.w	d7		;2		---> 16
	ENDR	
.haha\@
	move.w	d0,o(a2)
	move.w	d4,o+8(a2)
	move.w	d1,o+2(a2)
	move.w	d5,o+10(a2)
	move.w	d2,o+4(a2)
	move.w	d6,o+12(a2)
	move.w	d3,o+6(a2)
	move.w	d7,o+14(a2)
	endm


roxFireLeft macro
	movem.w	(a5)+,d0-d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	lea		.haha\@,a6
	sub.w	a1,a6
	jmp		(a6)
	REPT 16
		roxl.w	d0		;2
		roxl.w	d4		;2
		roxl.w	d1		;2
		roxl.w	d5		;2
		roxl.w	d2		;2
		roxl.w	d6		;2
		roxl.w	d3		;2
		roxl.w	d7		;2		---> 16
	ENDR	
.haha\@
	move.w	d4,o(a2)
	move.w	d0,o+8(a2)
	move.w	d5,o+2(a2)
	move.w	d1,o+10(a2)
	move.w	d6,o+4(a2)
	move.w	d2,o+12(a2)
	move.w	d7,o+6(a2)
	move.w	d3,o+14(a2)
	endm

strollerDone
	move.w	#0,_strollend
	move.w	#lineEndColor,_linecolor
	rts

testStroller
	lea		buffer,a0
	add.w	_buffoff,a0
	add.w	_anioff,a0
	add.w	#sprite_buffersize,a0
	add.w	#sprite_size*8,a0

	move.l	screenpointer2,a1
	add.w	#100*160,a1
	move.w	#sprite_height-1,d7
.loop
	 REPT sprite_width_block
	 	move.l	(a0)+,(a1)+
	 	move.l	(a0)+,(a1)+
	 ENDR
	 add.w	#160-sprite_width_block*8,a1
	 dbra	d7,.loop
	 rts

rollStroller
	subq.w	#1,_delCounter
	bgt		delStroller
	beq		strollerDone

	tst.w	_strollend
	beq		.end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER
	lea		buffer,a0
	add.w	_buffoff,a0
	add.w	_anioff,a0

	move.l	a0,a3

	move.l	screenpointer2,a1
	add.w	_scroff,a1
	add.w	#3*160+230*7,a1
	move.l	a1,a2
	move.l	a1,a4

	move.l	#0,-8(a1)
	move.l	#0,-4(a1)
	move.l	#0,-8+10*230(a1)
	move.l	#0,-4+10*230(a1)

	move.w	#sprite_height-1,d7
.loop
		REPT sprite_width_block
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
		add.w	#sprite_surface_scanwidth-sprite_width_block*8,a1
	dbra	d7,.loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER DONE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIRE
	cmp.w	#9*16,_fireoff
	bgt		.oktt
		add.w	#8,a2
.oktt
	lea		_fireResult1,a5
	move.w	_fireoff,a1
	
	move.w	#fireHeight-5,a0
	sub.w	#5*230,a2
o set 0
.loopFireTop
		roxFire
		add.w	#230,a2
		subq.w	#1,a0
	cmp.w	#0,a0
	bne		.loopFireTop


	move.w	_fireoff,d0
	add.w	#16,d0
	cmp.w	#16*16,d0
	bne		.okcont
		move.w	#0,d0
.okcont
	move.w	d0,_fireoff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END FIRE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HANDLE FIX
	move.w #4-1,d7
.loopll
		REPT sprite_width_block
			move.l	(a3)+,d0
			or.l	d0,(a4)+
			move.l	(a3)+,d0
			or.l	d0,(a4)+
		ENDR
		add.w	#sprite_surface_scanwidth-sprite_width_block*8,a4
	dbra	d7,.loopll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END TOP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END TOP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END TOP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER BOTTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER BOTTOM
	lea		buffer+3*sprite_buffersize,a0
	move.w	#sprite_size*15,d0
	sub.w	_buffoff,d0
	add.w	d0,a0
	add.w	_anioff,a0
	move.l	a0,a3

.rightside
	move.l	screenpointer2,a1
	add.w	#(30+herpoffset+1)*230-8,a1
	add.w	#(177-herpoffset)*160,a1
	move.w	#230-38,d0
	sub.w	_scroff,d0
	add.w	d0,a1
	move.l	a1,a2
	move.l	a1,a4

	moveq	#0,d3
	move.w	#27-1,d7
.loopdiloop
o set -7*230
		REPT 3
			move.l	d3,o(a1)
			move.l	d3,o+4(a1)
o set o+8
		ENDR
	add.w	#230,a1
	dbra	d7,.loopdiloop
	move.l	a2,a1

	move.w	#sprite_height-1,d7
.loop2
		REPT sprite_width_block
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
		move.l	d3,(a1)+
		move.l	d3,(a1)+

		add.w	#sprite_surface_scanwidth-sprite_width_block*8-8,a1
	dbra	d7,.loop2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROLLER DONE


	cmp.w	#10*16,_fireoff2
	bgt		.oktt2
		sub.w	#8,a2
.oktt2

	lea		_fireResult2,a5
	move.w	_fireoff2,a1
	sub.w	#16-2*230,a2
	move.w	#fireHeight-5,a0
.lalalala
		roxFireLeft
		add.w	#230,a2
		subq.w	#1,a0
		cmp.w	#0,a0
		bne		.lalalala

	move.w	_fireoff2,d0
	add.w	#16,d0
	cmp.w	#16*16,d0
	bne		.okcont2
		move.w	#0,d0
.okcont2
	move.w	d0,_fireoff2
	lsr.w	#4,d0
	move.w	d0,_tmp



	move.w #5-1,d7
.loopllt
		REPT sprite_width_block
			move.l	(a3)+,d0
			or.l	d0,(a4)+
			move.l	(a3)+,d0
			or.l	d0,(a4)+
		ENDR
		add.w	#sprite_surface_scanwidth-sprite_width_block*8,a4
	dbra	d7,.loopllt

	add.w	#sprite_buffersize,_anioff
	cmp.w	#sprite_buffersize*3,_anioff
	bne		.oktogo
		move.w	#0,_anioff
.oktogo


	move.w	#strolldelay,_strolldelay
	add.w	#sprite_size,_buffoff				; +1 pixel
	cmp.w	#16*sprite_size,_buffoff			; loop 16?
	bne		.ok
		move.w	#0,_buffoff						; reset off
		add.w	#8,_scroff						; +1 block screen
		cmp.w	#208,_scroff					; end screen?
		bne		.ok
			move.w	#3,_delCounter
.ok
.end
	rts



clearIcon
	lea		iconListSeq,a6
	add.w	_iconoffset,a6
	move.l	(a6),a6
	move.l	(a6)+,a0			
	add.w	#4,a6
	move.w	(a6)+,d6				; width
	move.w	(a6)+,d7				; height
	subq.w	#1,d7

	move.l	screenpointer2,a1
	add.w	#3*160,a1	; top border
	add.w	(a6)+,a1				; offset

	tst.w	lulz
	beq		.gogo
		add.w	#28*230,a1
.gogo

	move.w	#160,d5					; scanline
	moveq	#0,d3


.height
o set 0
	REPT 10
		move.l	d3,o(a1)
o set o+8
	ENDR
	add.w	d5,a1
	dbra	d7,.height
	rts


_iconoffset	dc.w	0
_drawIter	dc.w	2

delshit
	; deltopline
	move.l	screenpointer2,a1
	move.l	a1,a0
	add.w	#3*160+30*230,a1
	move.l	#0,d0
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
	move.l	d0,a6				; 12 * 4 = 48, 5 per fullscreen scanline

	; top shit

	REPT 16
		movem.l	d0-d6/a3-a6,-(a1)
	ENDR	

	move.l	a0,a1
	add.l	#3*160+30*230+226*160,a0
	REPT 48
		movem.l	d0-d6/a2-a6,-(a0)
	ENDR

	add.l	#3*160+30*230+209*160,a1
	REPT 39
		movem.l	d0-d6/a2-a6,-(a1)
	ENDR

	rts


shitDeleted	dc.w	2

_groundIter		dc.w	0
_groundOffset	dc.w	0
_groundWait		dc.w	2

doGroundLine
	tst.w	_strollend
	beq		.end

	move.l	screenpointer2,a0
	add.w	#3*160+27*230,a0
	add.w	_groundOffset,a0
	lea		groundLinesList,a1
	move.w	_groundIter,d0
	add.w	d0,d0
	move.l	(a1,d0.w),a1
	jsr		(a1)




	move.l	screenpointer2,a0
	add.w	#(30+herpoffset)*230,a0
	add.w	#21*230,a0
	add.w	#(177-herpoffset)*160-8,a0
	move.w	#230-22,d0
	sub.w	_groundOffset,d0
	add.w	d0,a0

	jsr		(a1)

	subq.w	#1,_groundWait
	bne		.ok

	move.w	#2,_groundWait
	addq.w	#2,_groundIter
	cmp.w	#16,_groundIter
	bne		.ok
		add.w	#8,_groundOffset
		move.w	#0,_groundIter
.ok
.end
	rts



delGroundLines
	move.l	screenpointer,a0
	move.l	a0,a1
	move.l	screenpointer2,a2
	move.l	a2,a3
	add.w	#3*160+27*230+8+230,a0
	add.w	#3*160+27*230+8+230,a2

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7		; 8*4 = 32
	
	REPT 8
		movem.l	d0-d7,-(a0)
		movem.l	d0-d7,-(a2)
	ENDR
	rts


groundLinesList
	dc.l	ground0
	dc.l	ground1
	dc.l	ground2
	dc.l	ground3
	dc.l	ground4
	dc.l	ground5
	dc.l	ground6
	dc.l	ground7


ground0
	rts
ground1
	move.w	#-1,(a0)				;2										bpl 1
	rts
ground2
	move.l	#%00000000000000001111111111111111,(a0)				;			bpl 2
	rts
ground3
	move.w	#-1,(a0)				;6										bpl 1+2
	rts
ground4
	move.l	#0,(a0)+				;8										bpl 3
	move.w	#-1,(a0)
	rts
ground5
	move.w	#-1,(a0)				;10										bpl 1+3
	rts
ground6
	move.w	#0,(a0)+				;12										bpl 2+3
	move.w	#-1,(a0)
	rts
ground7
	move.w	#-1,(a0)				;14										bpl 1+2+3
	rts

; 10 * 160 * 2 * 2


;ikea		
;ikeaman		
;mosquito	
;motorola	
;joystick	
;parasol		
;pig			
;plane		
;strawberry
;sun			
;tent		
;toilet		
;trash		
;trash		

curSize set	linbuff
linbuff_joystick		equ curSize													;10*160*2
curSize set curSize+10*160*2*2
linbuff_atari			equ curSize
curSize set curSize+10*160*2*2
linbuff_sun				equ curSize
curSize set curSize+10*160*2*2
linbuff_plane			equ curSize
curSize set curSize+10*160*2*2
linbuff_parasol			equ curSize
curSize set curSize+10*160*2*2
linbuff_bbq				equ curSize
curSize set curSize+10*160*2*2
linbuff_beachball		equ curSize
curSize set curSize+10*160*2*2
linbuff_bee				equ curSize
curSize set curSize+10*160*2*2
linbuff_coke			equ curSize
curSize set curSize+10*160*2*2
linbuff_elk				equ curSize
curSize set curSize+10*160*2*2
linbuff_falcon			equ curSize
curSize set curSize+10*160*2*2
linbuff_ikea			equ curSize
curSize set curSize+10*160*2*2
linbuff_ikeaman			equ curSize
curSize set curSize+10*160*2*2
linbuff_mosquito		equ curSize
curSize set curSize+10*160*2*2
linbuff_motorola		equ curSize
curSize set curSize+10*160*2*2
linbuff_pig				equ curSize
curSize set curSize+10*160*2*2
linbuff_strawberry		equ curSize
curSize set curSize+10*160*2*2
linbuff_tent			equ curSize
curSize set curSize+10*160*2*2
linbuff_toilet			equ curSize
curSize set curSize+10*160*2*2
linbuff_trash			equ curSize
curSize set curSize+10*160*2*2
linbuff_system			equ curSize
curSize set curSize+10*160*2*2
linbuff_volvo			equ	curSize

;doLinbuffList	macro
;	dc.l	\1+128
;	dc.w	10,160
;	endm
;
;linBuffList
;	doLinbuffList	joystick
;	doLinbuffList	atari
;	doLinbuffList	sun
;	doLinbuffList	plane
;	doLinbuffList	parasol
;	doLinbuffList	bbq
;	doLinbuffList	beachball
;	doLinbuffList	bee
;	doLinbuffList	coke
;	doLinbuffList	elk
;	doLinbuffList	falcon
;	doLinbuffList	ikea
;	doLinbuffList	ikeaman
;	doLinbuffList	mosquito
;	doLinbuffList	motorola
;	doLinbuffList	pig
;	doLinbuffList	strawberry
;	doLinbuffList	tent
;	doLinbuffList	toilet
;	doLinbuffList	trash
;	doLinbuffList	system
;	doLinbuffList	volvo
;
;	dc.l	-1


doDef	macro
\1Def
	dc.l	linbuff_\1,picPal
	dc.w	10,160,9*160+40
	endm

	doDef	joystick
	doDef	atari
	doDef	sun
	doDef	plane
	doDef	parasol
	doDef	bbq
	doDef	beachball
	doDef	bee
	doDef	coke
	doDef	elk
	doDef	falcon
	doDef	ikea
	doDef	ikeaman
	doDef	mosquito
	doDef	motorola
	doDef	pig
	doDef	strawberry
	doDef	tent
	doDef	toilet
	doDef	trash
	doDef	system
	doDef	volvo



picPal
	dc.w	$222,$555,$777
	dc.w	$202,$541,$776
	dc.w	$201,$521,$774
	dc.w	$101,$412,$773
	dc.w	$000,$302,$770
	dc.w	$000,$202,$760
	dc.w	$000,$201,$650
	dc.w	$000,$101,$541
	dc.w	$000,$000,$521
	dc.w	$000,$000,$412
	dc.w	$000,$000,$302
	dc.w	$000,$000,$202
	dc.w	$000,$000,$201
	dc.w	$000,$000,$101
	dc.w	$000,$000,$000


iconListSeq
	dc.l	sunDef
	dc.l	planeDef
	dc.l	bbqDef
	dc.l	motorolaDef

	dc.l	sunDef
	dc.l	parasolDef
	dc.l	elkDef
	dc.l	atariDef

	dc.l	sunDef
	dc.l	tentDef
	dc.l	mosquitoDef
	dc.l	trashDef

	dc.l	sunDef
	dc.l	beachballDef
	dc.l	strawberryDef
	dc.l	joystickDef

	dc.l	sunDef
	dc.l	ikeaDef
	dc.l	systemDef
	dc.l	falconDef

	dc.l	sunDef
	dc.l	beeDef
	dc.l	volvoDef
	dc.l	pigDef

	dc.l	sunDef
	dc.l	ikeamanDef
	dc.l	atariDef
	dc.l	mosquitoDef

	dc.l	sunDef
	dc.l	mosquitoDef
	dc.l	toiletDef
	dc.l	mosquitoDef

	dc.l	mosquitoDef







;prepLinbuffList
;	rts
;	lea		linBuffList,a6
;	lea		linbuff,a1
;
;.loop
;	move.l	(a6)+,a0
;	cmp.l	#-1,a0
;	beq		.end
;	move.w	(a6)+,d6
;	move.w	(a6)+,d7
;	move.w	#1,d5
;	jsr		copyDateFromPictureToLinearBuffer
;
;	jmp		.loop
;.end
;	rts

; source	a0
; buffer	a1
; height	d7
; width		d6
; bitplanes d5
;copyDateFromPictureToLinearBuffer
;	move.w	#4,d2
;
;	move.w	d6,d1
;	add.w	d1,d1
;	add.w	d1,d1
;	add.w	d1,d1
;	neg.w	d1
;	add.w	#160,d1
;
;	subq.w	#1,d7
;	subq.w	#1,d6
;	subq.w	#1,d5
;.height
;		move.w	d6,d4
;.width
;			move.w	d5,d3
;.bitplane
;				move.l	(a0)+,(a1)+
;			dbra	d3,.bitplane
;			add.w	d2,a0
;		dbra	d4,.width
;		add.w	d1,a0
;	dbra	d7,.height
;	rts


drawIcon
	doRaster $070
	lea		iconListSeq,a6			; get list
	add.w	_iconoffset,a6			; add offset
	move.l	(a6),a6					; move definition to pointer
	move.l	(a6)+,a0			
	add.w	#4,a6
	move.w	(a6)+,d6				; width
	move.w	(a6)+,d7				; height
	lsr.w	d7
	subq.w	#1,d7
	move.l	screenpointer,a1
	add.w	#3*160,a1	; top border

	tst.w	lulz
	beq		.gogo
		add.w	#28*230,a1
.gogo

	add.w	(a6)+,a1				; offset

	move.w	#160,d5					; scanline
	add.w	d5,d5

.height
o set 0
	REPT 10
		move.l	(a0)+,o(a1)
o set o+8
	ENDR
o set 160
	REPT 10
		move.l	(a0)+,o(a1)
o set o+8
	ENDR
	add.w	d5,a1
	dbra	d7,.height
	rts


; expects filename in d0
; expects buffer address in d1

	IFEQ loadmusic
loadFile
				move.l	d0,-(SP)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #6,SP
                tst.l   D0              ;opened ok?
                bgt.s   openok

                bra     getout

openok:        	
				move.w  D0,handle       ;read the file
;                pea     music

				move.l	d1,-(SP)

                move.l  #1024*1024,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0              ;read everything?
                bgt.s   readok
getout
				move.w	#$700,$ffff8240
				move.w	#-1,fail
				add.l	#16,sp
				rts


readok:         
				move.w  handle(PC),-(SP) ;close file
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP	
	rts

filename		dc.b	"music.snd",0
	even
fail			ds.w	1
handle			ds.w	1
music						ds.b	1024*1024
	ENDC

	IFEQ	loadscroller
loadScroller
               pea     filename2(PC)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #6,SP
                tst.l   D0              ;opened ok?
                bgt.s   openok2

                bra     getout2

openok2:        	
				move.w  D0,handle2       ;read the file
                pea     scroller
                move.l  #1024*1024,-(SP)
                move.w  handle2(PC),-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0              ;read everything?
                bgt.s   readok2
getout2
				move.w	#$700,$ffff8240
				move.w	#-1,fail2
				add.l	#16,sp
				rts


readok2:         
				move.w  handle2(PC),-(SP) ;close file
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP	
	rts

filename2		dc.b	"scroller.txt",0
	even
fail2			ds.w	1
handle2			ds.w	1
scroller					ds.b	1920
	ENDC




bgCounter	dc.w	2
bgWaiter2	dc.w	2
hh equ 15

putBG
	subq.w	#1,bgWaiter2
	bgt		.exit
	subq.w	#1,bgCounter
	blt		.exit
	lea		bgBuffer,a0
	move.l	screenpointer2,a1
;	add.l	#3*160+31*230+197*160+2-16-63*160+8-40-72,a1
	add.l	#scr2Off,a1
	add.w	#2,a1
	sub.w	#15*160,a1
y set -24
	REPT hh
o set y
		REPT 20
			move.w	(a0)+,o(a1)
o set o+8
		ENDR
		add.w	#12,a0
y set y+160
	ENDR
y set y+24

	REPT 59-hh
o set y
		REPT 26
			move.w	(a0)+,+o(a1)
o set o+8
		ENDR

y set y+230
	ENDR



.exit
	rts

;testBuffer
;	lea		background+128,a0
;	move.l	screenpointer2,a1
;	add.w	#134*160,a0
;	add.w	#134*160,a1
;	move.w	#66-1,d7
;.loop
;o set 0
;		REPT 20
;			move.w	o(a0),o(a1)
;o set o+8
;		ENDR
;	add.w	#160,a0
;	add.w	#160,a1
;	dbra	d7,.loop
;	rts


;prepareBackgroundToBuffer
;	lea		background+128,a0
;	move.l	a0,a1
;	add.w	#65*160,a1
;	lea		bgBuffer,a2
;	move.l	a2,a3
;	move.w	#65-1,d7
;.loop
;o set 0
;		REPT 20
;			move.w	o(a0),(a2)+
;o set o+8
;		ENDR
;o set 0
;		REPT 6
;			move.w	o(a1),(a2)+
;o set o+8
;		ENDR
;
;		add.w	#160,a1
;		add.w	#160,a0
;	dbra	d7,.loop
;
;	move.b	#0,$ffffc123
;;	(26*2*65)	
;	rts



prepSunBuffers
	lea		sunBuffer,a0
	;200*2*12 = 4800
	lea		sunDistBuffer,a1
	jsr		shiftSunRightFirst	

	lea		-200*2*14(a1),a0

	rept 15
		jsr		shiftSunRight
	endr
	rts



; this sets up the 16 buffers
shiftSunRightFirst
	moveq	#0,d0
	roxr.w	d0			; clear extended bit
	moveq	#0,d0				; this we use to clean stuff
	move.w	#155-1,d7

.oneline
		move.w	d0,(a1)+			; left hand side is always clear
		REPT 12						; then we have 12*16 of the original
			move.w	(a0)+,(a1)+
		ENDR
		move.w	d0,(a1)+
	dbra	d7,.oneline

	lea		sunBuffer2,a2
	add.w	#24*155,a2

	moveq	#0,d0
	roxr.w	d0
	moveq	#0,d0
	move.w	#45-1,d7

.oneline2
		move.w	d0,(a1)+
		REPT 12
			move.w	(a2)+,(a1)+
		ENDR
		move.w	d0,(a1)+
	dbra	d7,.oneline2
	rts


; helper code
shiftSunRight
	moveq	#0,d0
	roxr.w	d0			; clear extended bit
	moveq	#0,d0				; this we use to clean stuff
	move.w	#200-1,d7

.oneline
		REPT 14						; then we have 12*16 of the original
			move.w	(a0)+,d1
			roxr.w	d1
			move.w	d1,(a1)+
		ENDR
	dbra	d7,.oneline
	rts

; need 2 indices, one to index the buffer, one to index the line into the buffer
; this sets up the list so that:
;	- offset 


initSunDist2
	lea		distlists,a0
	add.w	_distlistoffset,a0
	move.l	(a0),a0
	lea		sunDistList,a1

o set 0
	REPT 15
		movem.l	(a0)+,d0-d7/a2-a6			; 8+5 = 13
		movem.l	d0-d7/a2-a6,o(a1)
o set o+13*4
	ENDR

	subq.w	#4,_distlistoffset
	bge		.ok
		move.w	#8,_distlistoffset
.ok
	rts

_distlistoffset	dc.w	8

distlists
	dc.l	distList
	dc.l	distList2
	dc.l	distList3

_sunDistScreenPointer	dc.l	0
_sunDistListPointer		dc.l	0
_sunDistBufferPointer	dc.l	0

drawDistSun
	move.l	screenpointer2,a0				;5
	add.w	#27*230+2*160+24,a0								;8
	lea		sunDistList,a1				;2
	lea		sunDistBuffer,a3				;3
o set 0
y set 0
	REPT 126
		lea		o(a3),a2					;2		(1 first time)
		add.l	(a1)+,a2					;4
x set y
		REPT 14
			move.w	(a2)+,x(a0)				;4		(3 first time)					(14*4 + 6)*20 = 
x set x+8
		ENDR
o set o+2*14
y set y+160
	ENDR

	lea		160*125(a0),a0							; do 1 less
	move.l	a0,_sunDistScreenPointer
	move.l	a1,_sunDistListPointer
	; and we know that we are at 140*2*14 offset into the screen
	lea		125*2*14(a3),a3							; do 1 less
	move.l	a3,_sunDistBufferPointer

	rts



; 15 lines left for 160
; 25 lines left with 230

advanceDistMacro	macro
	move.l	(a0),d0
	sub.l	a5,d0
	bge		.ok\@
;		sub.l	d0,d0			; 0
		moveq	#0,d0
.ok\@
	move.l	d0,(a0)+
	endm

subTractAndCheck	macro
	sub.l	a5,\1
	bge		.ok\@
		moveq	#0,\1
.ok\@
	endm

advanceDistMacroAdv	macro
	movem.l	(a0),d0-d7
	subTractAndCheck	d0
	subTractAndCheck	d1
	subTractAndCheck	d2
	subTractAndCheck	d3
	subTractAndCheck	d4
	subTractAndCheck	d5
	subTractAndCheck	d6
	subTractAndCheck	d7
	movem.l	d0-d7,(a0)
	lea		32(a0),a0
	endm


advanceDist
	lea		sunDistList,a0
	move.l	#200*2*14,a5

	REPT 25
		advanceDistMacroAdv
	ENDR
	rts



;prepCredits
;	lea	credits+128,a0
;	lea	creditsBuffer,a1
;o set 0
;	REPT 5
;		rept 20
;			move.w	o(a0),(a1)+
;o set o+8
;		ENDR
;	ENDR
;	; 20*2*5
;	lea		creditsBuffer,a1
;	move.b	#0,$ffffc123
;	rts

	SECTION DATA

	include		lib/lib.s


distList
	REPT 12
o set 200*2*14*15
		REPT 16
			dc.l	o
o set o-200*2*14
		ENDR
	ENDR

distList2
	REPT 6
		REPT 16
			dc.l	200*2*14*15
		ENDR
		REPT 16
			dc.l	0
		ENDR
	ENDR

distList3
	REPT 6
o set 200*2*14*15
		REPT 16
			dc.l	o
o set o-200*2*14
		ENDR
o set 0
		REPT 16
			dc.l	o
o set o+200*2*14
		ENDR
	ENDR

xposi
	dc.w	1636,7*bgh
	dc.w	572,0*bgh
	dc.w	1584,0*bgh
	dc.w	1252,10*bgh
	dc.w	1212,16*bgh
	dc.w	212,6*bgh
	dc.w	1280,12*bgh
	dc.w	364,6*bgh
	dc.w	1288,4*bgh
	dc.w	508,1*bgh
	dc.w	860,11*bgh
	dc.w	176,4*bgh
	dc.w	1048,3*bgh
	dc.w	208,0*bgh
	dc.w	1456,15*bgh
	dc.w	1488,14*bgh
	dc.w	624,3*bgh
	dc.w	1436,5*bgh
	dc.w	416,10*bgh
	dc.w	1568,16*bgh
	dc.w	940,1*bgh
	dc.w	584,5*bgh
	dc.w	1328,9*bgh
	dc.w	1156,9*bgh
	dc.w	1380,16*bgh
	dc.w	1084,5*bgh
	dc.w	1084,12*bgh
	dc.w	984,4*bgh
	dc.w	1568,12*bgh
	dc.w	552,13*bgh
	dc.w	1048,3*bgh
	dc.w	1084,16*bgh
	dc.w	744,8*bgh
	dc.w	532,11*bgh
	dc.w	172,4*bgh
	dc.w	1116,11*bgh
	dc.w	532,0*bgh
	dc.w	1660,1*bgh
	dc.w	976,11*bgh
	dc.w	1124,6*bgh
	dc.w	1128,5*bgh
	dc.w	1244,5*bgh
	dc.w	112,5*bgh
	dc.w	992,0*bgh
	dc.w	68,15*bgh
	dc.w	1352,11*bgh
	dc.w	228,7*bgh
	dc.w	1120,9*bgh
	dc.w	1600,16*bgh
	dc.w	460,0*bgh
	dc.w	404,16*bgh
	dc.w	1216,9*bgh
	dc.w	1608,12*bgh
	dc.w	1120,9*bgh
	dc.w	656,5*bgh
	dc.w	1584,1*bgh
	dc.w	1100,11*bgh
	dc.w	644,12*bgh
	dc.w	20,16*bgh
	dc.w	1216,0*bgh
	dc.w	1500,9*bgh
	dc.w	1216,0*bgh
	dc.w	1648,6*bgh
	dc.w	1028,15*bgh
	dc.w	636,15*bgh
	dc.w	1668,10*bgh
	dc.w	1396,12*bgh
	dc.w	300,13*bgh
	dc.w	724,14*bgh
	dc.w	548,14*bgh
	dc.w	312,4*bgh
	dc.w	1492,14*bgh
	dc.w	1604,4*bgh
	dc.w	944,16*bgh
	dc.w	412,4*bgh
	dc.w	40,2*bgh
	dc.w	1372,12*bgh
	dc.w	288,13*bgh
	dc.w	240,13*bgh
	dc.w	1232,8*bgh
	dc.w	1132,12*bgh
	dc.w	240,8*bgh
	dc.w	744,5*bgh
	dc.w	496,14*bgh
	dc.w	284,10*bgh
	dc.w	1172,6*bgh
	dc.w	1500,9*bgh
	dc.w	332,14*bgh
	dc.w	1444,12*bgh
	dc.w	1372,1*bgh
	dc.w	80,14*bgh
	dc.w	412,14*bgh
	dc.w	996,7*bgh
	dc.w	1116,12*bgh
	dc.w	344,6*bgh
	dc.w	436,15*bgh
	dc.w	208,6*bgh
	dc.w	652,9*bgh
	dc.w	1220,11*bgh
	dc.w	748,15*bgh

	ds.b	4

	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	2
squitoTimers

pixels
;	line 0
	dc.w	0-16*bgh
	dc.w	32768
;	line 1
	dc.w	0-16*bgh
	dc.w	16384
;	line 2
	dc.w	0-16*bgh
	dc.w	8192
;	line 3
	dc.w	0-16*bgh
	dc.w	4096
;	line 4
	dc.w	0-16*bgh
	dc.w	2048
;	line 5
	dc.w	0-15*bgh
	dc.w	1024
;	line 6
	dc.w	0-15*bgh
	dc.w	512
;	line 7
	dc.w	0-15*bgh
	dc.w	256
;	line 8
	dc.w	0-15*bgh
	dc.w	128
;	line 9
	dc.w	0-15*bgh
	dc.w	64
;	line 10
	dc.w	0-16*bgh
	dc.w	32
;	line 11
	dc.w	0-16*bgh
	dc.w	16
;	line 12
	dc.w	0-16*bgh
	dc.w	8
;	line 13
	dc.w	0-16*bgh
	dc.w	4
;	line 14
	dc.w	0-16*bgh
	dc.w	2
;	line 15
	dc.w	0-16*bgh
	dc.w	1
;	line 16
	dc.w	8-16*bgh
	dc.w	32768
;	line 17
	dc.w	8-16*bgh
	dc.w	16384
;	line 18
	dc.w	8-16*bgh
	dc.w	8192
;	line 19
	dc.w	8-16*bgh
	dc.w	4096
;	line 20
	dc.w	8-16*bgh
	dc.w	2048
;	line 21
	dc.w	8-16*bgh
	dc.w	1024
;	line 22
	dc.w	8-16*bgh
	dc.w	512
;	line 23
	dc.w	8-16*bgh
	dc.w	256
;	line 24
	dc.w	8-16*bgh
	dc.w	128
;	line 25
	dc.w	8-16*bgh
	dc.w	64
;	line 26
	dc.w	8-17*bgh
	dc.w	32
;	line 27
	dc.w	8-17*bgh
	dc.w	16
;	line 28
	dc.w	8-17*bgh
	dc.w	8
;	line 29
	dc.w	8-17*bgh
	dc.w	4
;	line 30
	dc.w	8-17*bgh
	dc.w	2
;	line 31
	dc.w	8-17*bgh
	dc.w	1
;	line 32
	dc.w	16-17*bgh
	dc.w	32768
;	line 33
	dc.w	16-17*bgh
	dc.w	16384
;	line 34
	dc.w	16-17*bgh
	dc.w	8192
;	line 35
	dc.w	16-17*bgh
	dc.w	4096
;	line 36
	dc.w	16-17*bgh
	dc.w	2048
;	line 37
	dc.w	16-17*bgh
	dc.w	1024
;	line 38
	dc.w	16-17*bgh
	dc.w	512
;	line 39
	dc.w	16-18*bgh
	dc.w	256
;	line 40
	dc.w	16-18*bgh
	dc.w	128
;	line 41
	dc.w	16-18*bgh
	dc.w	64
;	line 42
	dc.w	16-18*bgh
	dc.w	32
;	line 43
	dc.w	16-18*bgh
	dc.w	16
;	line 44
	dc.w	16-18*bgh
	dc.w	8
;	line 45
	dc.w	16-18*bgh
	dc.w	4
;	line 46
	dc.w	16-18*bgh
	dc.w	2
;	line 47
	dc.w	16-18*bgh
	dc.w	1
;	line 48
	dc.w	24-18*bgh
	dc.w	32768
;	line 49
	dc.w	24-18*bgh
	dc.w	16384
;	line 50
	dc.w	24-18*bgh
	dc.w	8192
;	line 51
	dc.w	24-18*bgh
	dc.w	4096
;	line 52
	dc.w	24-18*bgh
	dc.w	2048
;	line 53
	dc.w	24-18*bgh
	dc.w	1024
;	line 54
	dc.w	24-18*bgh
	dc.w	512
;	line 55
	dc.w	24-18*bgh
	dc.w	256
;	line 56
	dc.w	24-18*bgh
	dc.w	128
;	line 57
	dc.w	24-18*bgh
	dc.w	64
;	line 58
	dc.w	24-19*bgh
	dc.w	32
;	line 59
	dc.w	24-19*bgh
	dc.w	16
;	line 60
	dc.w	24-19*bgh
	dc.w	8
;	line 61
	dc.w	24-19*bgh
	dc.w	4
;	line 62
	dc.w	24-20*bgh
	dc.w	2
;	line 63
	dc.w	24-20*bgh
	dc.w	1
;	line 64
	dc.w	32-20*bgh
	dc.w	32768
;	line 65
	dc.w	32-20*bgh
	dc.w	16384
;	line 66
	dc.w	32-20*bgh
	dc.w	8192
;	line 67
	dc.w	32-20*bgh
	dc.w	4096
;	line 68
	dc.w	32-20*bgh
	dc.w	2048
;	line 69
	dc.w	32-21*bgh
	dc.w	1024
;	line 70
	dc.w	32-21*bgh
	dc.w	512
;	line 71
	dc.w	32-21*bgh
	dc.w	256
;	line 72
	dc.w	32-21*bgh
	dc.w	128
;	line 73
	dc.w	32-21*bgh
	dc.w	64
;	line 74
	dc.w	32-21*bgh
	dc.w	32
;	line 75
	dc.w	32-21*bgh
	dc.w	16
;	line 76
	dc.w	32-21*bgh
	dc.w	8
;	line 77
	dc.w	32-22*bgh
	dc.w	4
;	line 78
	dc.w	32-22*bgh
	dc.w	2
;	line 79
	dc.w	32-22*bgh
	dc.w	1
;	line 80
	dc.w	40-22*bgh
	dc.w	32768
;	line 81
	dc.w	40-22*bgh
	dc.w	16384
;	line 82
	dc.w	40-22*bgh
	dc.w	8192
;	line 83
	dc.w	40-22*bgh
	dc.w	4096
;	line 84
	dc.w	40-22*bgh
	dc.w	2048
;	line 85
	dc.w	40-23*bgh
	dc.w	1024
;	line 86
	dc.w	40-23*bgh
	dc.w	512
;	line 87
	dc.w	40-23*bgh
	dc.w	256
;	line 88
	dc.w	40-24*bgh
	dc.w	128
;	line 89
	dc.w	40-24*bgh
	dc.w	64
;	line 90
	dc.w	40-24*bgh
	dc.w	32
;	line 91
	dc.w	40-25*bgh
	dc.w	16
;	line 92
	dc.w	40-25*bgh
	dc.w	8
;	line 93
	dc.w	40-25*bgh
	dc.w	4
;	line 94
	dc.w	40-26*bgh
	dc.w	2
;	line 95
	dc.w	40-25*bgh
	dc.w	1
;	line 96
	dc.w	48-26*bgh
	dc.w	32768
;	line 97
	dc.w	48-26*bgh
	dc.w	16384
;	line 98
	dc.w	48-26*bgh
	dc.w	8192
;	line 99
	dc.w	48-26*bgh
	dc.w	4096
;	line 100
	dc.w	48-26*bgh
	dc.w	2048
;	line 101
	dc.w	48-27*bgh
	dc.w	1024
;	line 102
	dc.w	48-26*bgh
	dc.w	512
;	line 103
	dc.w	48-27*bgh
	dc.w	256
;	line 104
	dc.w	48-27*bgh
	dc.w	128
;	line 105
	dc.w	48-27*bgh
	dc.w	64
;	line 106
	dc.w	48-27*bgh
	dc.w	32
;	line 107
	dc.w	48-28*bgh
	dc.w	16
;	line 108
	dc.w	48-27*bgh
	dc.w	8
;	line 109
	dc.w	48-26*bgh
	dc.w	4
;	line 110
	dc.w	48-26*bgh
	dc.w	2
;	line 111
	dc.w	48-26*bgh
	dc.w	1
;	line 112
	dc.w	56-27*bgh
	dc.w	32768
;	line 113
	dc.w	56-28*bgh
	dc.w	16384
;	line 114
	dc.w	56-28*bgh
	dc.w	8192
;	line 115
	dc.w	56-28*bgh
	dc.w	4096
;	line 116
	dc.w	56-28*bgh
	dc.w	2048
;	line 117
	dc.w	56-27*bgh
	dc.w	1024
;	line 118
	dc.w	56-26*bgh
	dc.w	512
;	line 119
	dc.w	56-25*bgh
	dc.w	256
;	line 120
	dc.w	56-26*bgh
	dc.w	128
;	line 121
	dc.w	56-25*bgh
	dc.w	64
;	line 122
	dc.w	56-25*bgh
	dc.w	32
;	line 123
	dc.w	56-25*bgh
	dc.w	16
;	line 124
	dc.w	56-25*bgh
	dc.w	8
;	line 125
	dc.w	56-24*bgh
	dc.w	4
;	line 126
	dc.w	56-24*bgh
	dc.w	2
;	line 127
	dc.w	56-24*bgh
	dc.w	1
;	line 128
	dc.w	64-24*bgh
	dc.w	32768
;	line 129
	dc.w	64-24*bgh
	dc.w	16384
;	line 130
	dc.w	64-24*bgh
	dc.w	8192
;	line 131
	dc.w	64-24*bgh
	dc.w	4096
;	line 132
	dc.w	64-24*bgh
	dc.w	2048
;	line 133
	dc.w	64-24*bgh
	dc.w	1024
;	line 134
	dc.w	64-24*bgh
	dc.w	512
;	line 135
	dc.w	64-24*bgh
	dc.w	256
;	line 136
	dc.w	64-24*bgh
	dc.w	128
;	line 137
	dc.w	64-24*bgh
	dc.w	64
;	line 138
	dc.w	64-25*bgh
	dc.w	32
;	line 139
	dc.w	64-24*bgh
	dc.w	16
;	line 140
	dc.w	64-25*bgh
	dc.w	8
;	line 141
	dc.w	64-25*bgh
	dc.w	4
;	line 142
	dc.w	64-24*bgh
	dc.w	2
;	line 143
	dc.w	64-25*bgh
	dc.w	1
;	line 144
	dc.w	72-25*bgh
	dc.w	32768
;	line 145
	dc.w	72-25*bgh
	dc.w	16384
;	line 146
	dc.w	72-24*bgh
	dc.w	8192
;	line 147
	dc.w	72-24*bgh
	dc.w	4096
;	line 148
	dc.w	72-24*bgh
	dc.w	2048
;	line 149
	dc.w	72-24*bgh
	dc.w	1024
;	line 150
	dc.w	72-25*bgh
	dc.w	512
;	line 151
	dc.w	72-25*bgh
	dc.w	256
;	line 152
	dc.w	72-25*bgh
	dc.w	128
;	line 153
	dc.w	72-25*bgh
	dc.w	64
;	line 154
	dc.w	72-24*bgh
	dc.w	32
;	line 155
	dc.w	72-25*bgh
	dc.w	16
;	line 156
	dc.w	72-24*bgh
	dc.w	8
;	line 157
	dc.w	72-24*bgh
	dc.w	4
;	line 158
	dc.w	72-24*bgh
	dc.w	2
;	line 159
	dc.w	72-24*bgh
	dc.w	1
;	line 160
	dc.w	80-24*bgh
	dc.w	32768
;	line 161
	dc.w	80-24*bgh
	dc.w	16384
;	line 162
	dc.w	80-23*bgh
	dc.w	8192
;	line 163
	dc.w	80-23*bgh
	dc.w	4096
;	line 164
	dc.w	80-23*bgh
	dc.w	2048
;	line 165
	dc.w	80-23*bgh
	dc.w	1024
;	line 166
	dc.w	80-23*bgh
	dc.w	512
;	line 167
	dc.w	80-23*bgh
	dc.w	256
;	line 168
	dc.w	80-23*bgh
	dc.w	128
;	line 169
	dc.w	80-23*bgh
	dc.w	64
;	line 170
	dc.w	80-23*bgh
	dc.w	32
;	line 171
	dc.w	80-23*bgh
	dc.w	16
;	line 172
	dc.w	80-24*bgh
	dc.w	8
;	line 173
	dc.w	80-23*bgh
	dc.w	4
;	line 174
	dc.w	80-23*bgh
	dc.w	2
;	line 175
	dc.w	80-24*bgh
	dc.w	1
;	line 176
	dc.w	88-23*bgh
	dc.w	32768
;	line 177
	dc.w	88-23*bgh
	dc.w	16384
;	line 178
	dc.w	88-24*bgh
	dc.w	8192
;	line 179
	dc.w	88-23*bgh
	dc.w	4096
;	line 180
	dc.w	88-24*bgh
	dc.w	2048
;	line 181
	dc.w	88-24*bgh
	dc.w	1024
;	line 182
	dc.w	88-24*bgh
	dc.w	512
;	line 183
	dc.w	88-24*bgh
	dc.w	256
;	line 184
	dc.w	88-24*bgh
	dc.w	128
;	line 185
	dc.w	88-24*bgh
	dc.w	64
;	line 186
	dc.w	88-25*bgh
	dc.w	32
;	line 187
	dc.w	88-24*bgh
	dc.w	16
;	line 188
	dc.w	88-25*bgh
	dc.w	8
;	line 189
	dc.w	88-25*bgh
	dc.w	4
;	line 190
	dc.w	88-25*bgh
	dc.w	2
;	line 191
	dc.w	88-25*bgh
	dc.w	1
;	line 192
	dc.w	96-25*bgh
	dc.w	32768
;	line 193
	dc.w	96-25*bgh
	dc.w	16384
;	line 194
	dc.w	96-25*bgh
	dc.w	8192
;	line 195
	dc.w	96-25*bgh
	dc.w	4096
;	line 196
	dc.w	96-25*bgh
	dc.w	2048
;	line 197
	dc.w	96-26*bgh
	dc.w	1024
;	line 198
	dc.w	96-26*bgh
	dc.w	512
;	line 199
	dc.w	96-26*bgh
	dc.w	256
;	line 200
	dc.w	96-26*bgh
	dc.w	128
;	line 201
	dc.w	96-26*bgh
	dc.w	64
;	line 202
	dc.w	96-26*bgh
	dc.w	32
;	line 203
	dc.w	96-26*bgh
	dc.w	16
;	line 204
	dc.w	96-26*bgh
	dc.w	8
;	line 205
	dc.w	96-25*bgh
	dc.w	4
;	line 206
	dc.w	96-25*bgh
	dc.w	2
;	line 207
	dc.w	96-25*bgh
	dc.w	1
;	line 208
	dc.w	104-25*bgh
	dc.w	32768
;	line 209
	dc.w	104-26*bgh
	dc.w	16384
;	line 210
	dc.w	104-26*bgh
	dc.w	8192
;	line 211
	dc.w	104-26*bgh
	dc.w	4096
;	line 212
	dc.w	104-27*bgh
	dc.w	2048
;	line 213
	dc.w	104-26*bgh
	dc.w	1024
;	line 214
	dc.w	104-27*bgh
	dc.w	512
;	line 215
	dc.w	104-27*bgh
	dc.w	256
;	line 216
	dc.w	104-27*bgh
	dc.w	128
;	line 217
	dc.w	104-27*bgh
	dc.w	64
;	line 218
	dc.w	104-27*bgh
	dc.w	32
;	line 219
	dc.w	104-28*bgh
	dc.w	16
;	line 220
	dc.w	104-27*bgh
	dc.w	8
;	line 221
	dc.w	104-28*bgh
	dc.w	4
;	line 222
	dc.w	104-28*bgh
	dc.w	2
;	line 223
	dc.w	104-28*bgh
	dc.w	1
;	line 224
	dc.w	112-28*bgh
	dc.w	32768
;	line 225
	dc.w	112-28*bgh
	dc.w	16384
;	line 226
	dc.w	112-28*bgh
	dc.w	8192
;	line 227
	dc.w	112-28*bgh
	dc.w	4096
;	line 228
	dc.w	112-29*bgh
	dc.w	2048
;	line 229
	dc.w	112-28*bgh
	dc.w	1024
;	line 230
	dc.w	112-29*bgh
	dc.w	512
;	line 231
	dc.w	112-29*bgh
	dc.w	256
;	line 232
	dc.w	112-29*bgh
	dc.w	128
;	line 233
	dc.w	112-29*bgh
	dc.w	64
;	line 234
	dc.w	112-29*bgh
	dc.w	32
;	line 235
	dc.w	112-29*bgh
	dc.w	16
;	line 236
	dc.w	112-29*bgh
	dc.w	8
;	line 237
	dc.w	112-29*bgh
	dc.w	4
;	line 238
	dc.w	112-29*bgh
	dc.w	2
;	line 239
	dc.w	112-29*bgh
	dc.w	1
;	line 240
	dc.w	120-29*bgh
	dc.w	32768
;	line 241
	dc.w	120-29*bgh
	dc.w	16384
;	line 242
	dc.w	120-29*bgh
	dc.w	8192
;	line 243
	dc.w	120-29*bgh
	dc.w	4096
;	line 244
	dc.w	120-28*bgh
	dc.w	2048
;	line 245
	dc.w	120-28*bgh
	dc.w	1024
;	line 246
	dc.w	120-28*bgh
	dc.w	512
;	line 247
	dc.w	120-28*bgh
	dc.w	256
;	line 248
	dc.w	120-28*bgh
	dc.w	128
;	line 249
	dc.w	120-28*bgh
	dc.w	64
;	line 250
	dc.w	120-28*bgh
	dc.w	32
;	line 251
	dc.w	120-28*bgh
	dc.w	16
;	line 252
	dc.w	120-27*bgh
	dc.w	8
;	line 253
	dc.w	120-27*bgh
	dc.w	4
;	line 254
	dc.w	120-27*bgh
	dc.w	2
;	line 255
	dc.w	120-26*bgh
	dc.w	1
;	line 256
	dc.w	128-26*bgh
	dc.w	32768
;	line 257
	dc.w	128-26*bgh
	dc.w	16384
;	line 258
	dc.w	128-26*bgh
	dc.w	8192
;	line 259
	dc.w	128-26*bgh
	dc.w	4096
;	line 260
	dc.w	128-26*bgh
	dc.w	2048
;	line 261
	dc.w	128-26*bgh
	dc.w	1024
;	line 262
	dc.w	128-26*bgh
	dc.w	512
;	line 263
	dc.w	128-25*bgh
	dc.w	256
;	line 264
	dc.w	128-25*bgh
	dc.w	128
;	line 265
	dc.w	128-25*bgh
	dc.w	64
;	line 266
	dc.w	128-25*bgh
	dc.w	32
;	line 267
	dc.w	128-25*bgh
	dc.w	16
;	line 268
	dc.w	128-25*bgh
	dc.w	8
;	line 269
	dc.w	128-25*bgh
	dc.w	4
;	line 270
	dc.w	128-25*bgh
	dc.w	2
;	line 271
	dc.w	128-25*bgh
	dc.w	1
;	line 272
	dc.w	136-25*bgh
	dc.w	32768
;	line 273
	dc.w	136-25*bgh
	dc.w	16384
;	line 274
	dc.w	136-25*bgh
	dc.w	8192
;	line 275
	dc.w	136-25*bgh
	dc.w	4096
;	line 276
	dc.w	136-25*bgh
	dc.w	2048
;	line 277
	dc.w	136-26*bgh
	dc.w	1024
;	line 278
	dc.w	136-26*bgh
	dc.w	512
;	line 279
	dc.w	136-26*bgh
	dc.w	256
;	line 280
	dc.w	136-27*bgh
	dc.w	128
;	line 281
	dc.w	136-27*bgh
	dc.w	64
;	line 282
	dc.w	136-27*bgh
	dc.w	32
;	line 283
	dc.w	136-27*bgh
	dc.w	16
;	line 284
	dc.w	136-27*bgh
	dc.w	8
;	line 285
	dc.w	136-27*bgh
	dc.w	4
;	line 286
	dc.w	136-27*bgh
	dc.w	2
;	line 287
	dc.w	136-27*bgh
	dc.w	1
;	line 288
	dc.w	144-27*bgh
	dc.w	32768
;	line 289
	dc.w	144-26*bgh
	dc.w	16384
;	line 290
	dc.w	144-26*bgh
	dc.w	8192
;	line 291
	dc.w	144-26*bgh
	dc.w	4096
;	line 292
	dc.w	144-26*bgh
	dc.w	2048
;	line 293
	dc.w	144-26*bgh
	dc.w	1024
;	line 294
	dc.w	144-26*bgh
	dc.w	512
;	line 295
	dc.w	144-25*bgh
	dc.w	256
;	line 296
	dc.w	144-25*bgh
	dc.w	128
;	line 297
	dc.w	144-25*bgh
	dc.w	64
;	line 298
	dc.w	144-25*bgh
	dc.w	32
;	line 299
	dc.w	144-25*bgh
	dc.w	16
;	line 300
	dc.w	144-25*bgh
	dc.w	8
;	line 301
	dc.w	144-25*bgh
	dc.w	4
;	line 302
	dc.w	144-25*bgh
	dc.w	2
;	line 303
	dc.w	144-25*bgh
	dc.w	1
;	line 304
	dc.w	152-25*bgh
	dc.w	32768
;	line 305
	dc.w	152-24*bgh
	dc.w	16384
;	line 306
	dc.w	152-24*bgh
	dc.w	8192
;	line 307
	dc.w	152-24*bgh
	dc.w	4096
;	line 308
	dc.w	152-24*bgh
	dc.w	2048
;	line 309
	dc.w	152-24*bgh
	dc.w	1024
;	line 310
	dc.w	152-24*bgh
	dc.w	512
;	line 311
	dc.w	152-24*bgh
	dc.w	256
;	line 312
	dc.w	152-24*bgh
	dc.w	128
;	line 313
	dc.w	152-24*bgh
	dc.w	64
;	line 314
	dc.w	152-24*bgh
	dc.w	32
;	line 315
	dc.w	152-24*bgh
	dc.w	16
;	line 316
	dc.w	152-24*bgh
	dc.w	8
;	line 317
	dc.w	152-24*bgh
	dc.w	4
;	line 318
	dc.w	152-24*bgh
	dc.w	2
;	line 319
	dc.w	152-24*bgh
	dc.w	1
;	line 320
	dc.w	160-24*bgh
	dc.w	32768
;	line 321
	dc.w	160-23*bgh
	dc.w	16384
;	line 322
	dc.w	160-23*bgh
	dc.w	8192
;	line 323
	dc.w	160-24*bgh
	dc.w	4096
;	line 324
	dc.w	160-24*bgh
	dc.w	2048
;	line 325
	dc.w	160-24*bgh
	dc.w	1024
;	line 326
	dc.w	160-24*bgh
	dc.w	512
;	line 327
	dc.w	160-24*bgh
	dc.w	256
;	line 328
	dc.w	160-24*bgh
	dc.w	128
;	line 329
	dc.w	160-24*bgh
	dc.w	64
;	line 330
	dc.w	160-24*bgh
	dc.w	32
;	line 331
	dc.w	160-24*bgh
	dc.w	16
;	line 332
	dc.w	160-24*bgh
	dc.w	8
;	line 333
	dc.w	160-24*bgh
	dc.w	4
;	line 334
	dc.w	160-24*bgh
	dc.w	2
;	line 335
	dc.w	160-24*bgh
	dc.w	1
;	line 336
	dc.w	168-24*bgh
	dc.w	32768
;	line 337
	dc.w	168-24*bgh
	dc.w	16384
;	line 338
	dc.w	168-24*bgh
	dc.w	8192
;	line 339
	dc.w	168-24*bgh
	dc.w	4096
;	line 340
	dc.w	168-24*bgh
	dc.w	2048
;	line 341
	dc.w	168-24*bgh
	dc.w	1024
;	line 342
	dc.w	168-24*bgh
	dc.w	512
;	line 343
	dc.w	168-24*bgh
	dc.w	256
;	line 344
	dc.w	168-24*bgh
	dc.w	128
;	line 345
	dc.w	168-24*bgh
	dc.w	64
;	line 346
	dc.w	168-24*bgh
	dc.w	32
;	line 347
	dc.w	168-24*bgh
	dc.w	16
;	line 348
	dc.w	168-24*bgh
	dc.w	8
;	line 349
	dc.w	168-24*bgh
	dc.w	4
;	line 350
	dc.w	168-24*bgh
	dc.w	2
;	line 351
	dc.w	168-24*bgh
	dc.w	1
;	line 352
	dc.w	176-24*bgh
	dc.w	32768
;	line 353
	dc.w	176-24*bgh
	dc.w	16384
;	line 354
	dc.w	176-25*bgh
	dc.w	8192
;	line 355
	dc.w	176-25*bgh
	dc.w	4096
;	line 356
	dc.w	176-25*bgh
	dc.w	2048
;	line 357
	dc.w	176-25*bgh
	dc.w	1024
;	line 358
	dc.w	176-25*bgh
	dc.w	512
;	line 359
	dc.w	176-25*bgh
	dc.w	256
;	line 360
	dc.w	176-25*bgh
	dc.w	128
;	line 361
	dc.w	176-25*bgh
	dc.w	64
;	line 362
	dc.w	176-26*bgh
	dc.w	32
;	line 363
	dc.w	176-26*bgh
	dc.w	16
;	line 364
	dc.w	176-26*bgh
	dc.w	8
;	line 365
	dc.w	176-26*bgh
	dc.w	4
;	line 366
	dc.w	176-27*bgh
	dc.w	2
;	line 367
	dc.w	176-27*bgh
	dc.w	1
;	line 368
	dc.w	184-27*bgh
	dc.w	32768
;	line 369
	dc.w	184-27*bgh
	dc.w	16384
;	line 370
	dc.w	184-27*bgh
	dc.w	8192
;	line 371
	dc.w	184-27*bgh
	dc.w	4096
;	line 372
	dc.w	184-27*bgh
	dc.w	2048
;	line 373
	dc.w	184-27*bgh
	dc.w	1024
;	line 374
	dc.w	184-27*bgh
	dc.w	512
;	line 375
	dc.w	184-27*bgh
	dc.w	256
;	line 376
	dc.w	184-27*bgh
	dc.w	128
;	line 377
	dc.w	184-27*bgh
	dc.w	64
;	line 378
	dc.w	184-27*bgh
	dc.w	32
;	line 379
	dc.w	184-26*bgh
	dc.w	16
;	line 380
	dc.w	184-26*bgh
	dc.w	8
;	line 381
	dc.w	184-26*bgh
	dc.w	4
;	line 382
	dc.w	184-25*bgh
	dc.w	2
;	line 383
	dc.w	184-25*bgh
	dc.w	1
;	line 384
	dc.w	192-25*bgh
	dc.w	32768
;	line 385
	dc.w	192-25*bgh
	dc.w	16384
;	line 386
	dc.w	192-25*bgh
	dc.w	8192
;	line 387
	dc.w	192-24*bgh
	dc.w	4096
;	line 388
	dc.w	192-24*bgh
	dc.w	2048
;	line 389
	dc.w	192-24*bgh
	dc.w	1024
;	line 390
	dc.w	192-24*bgh
	dc.w	512
;	line 391
	dc.w	192-24*bgh
	dc.w	256
;	line 392
	dc.w	192-23*bgh
	dc.w	128
;	line 393
	dc.w	192-23*bgh
	dc.w	64
;	line 394
	dc.w	192-23*bgh
	dc.w	32
;	line 395
	dc.w	192-23*bgh
	dc.w	16
;	line 396
	dc.w	192-23*bgh
	dc.w	8
;	line 397
	dc.w	192-22*bgh
	dc.w	4
;	line 398
	dc.w	192-22*bgh
	dc.w	2
;	line 399
	dc.w	192-22*bgh
	dc.w	1
;	line 400
	dc.w	200-22*bgh
	dc.w	32768
;	line 401
	dc.w	200-22*bgh
	dc.w	16384
;	line 402
	dc.w	200-22*bgh
	dc.w	8192
;	line 403
	dc.w	200-21*bgh
	dc.w	4096
;	line 404
	dc.w	200-21*bgh
	dc.w	2048
;	line 405
	dc.w	200-21*bgh
	dc.w	1024
;	line 406
	dc.w	200-21*bgh
	dc.w	512
;	line 407
	dc.w	200-21*bgh
	dc.w	256
;	line 408
	dc.w	200-21*bgh
	dc.w	128
;	line 409
	dc.w	200-20*bgh
	dc.w	64
;	line 410
	dc.w	200-20*bgh
	dc.w	32
;	line 411
	dc.w	200-20*bgh
	dc.w	16
;	line 412
	dc.w	200-20*bgh
	dc.w	8
;	line 413
	dc.w	200-20*bgh
	dc.w	4
;	line 414
	dc.w	200-20*bgh
	dc.w	2
;	line 415
	dc.w	200-19*bgh
	dc.w	1
;	line 416
	dc.w	208-19*bgh
	dc.w	32768
;	line 417
	dc.w	208-19*bgh
	dc.w	16384
;	line 418
	dc.w	208-19*bgh
	dc.w	8192
;	line 419
	dc.w	208-19*bgh
	dc.w	4096
;	line 420
	dc.w	208-19*bgh
	dc.w	2048
;	line 421
	dc.w	208-19*bgh
	dc.w	1024
;	line 422
	dc.w	208-19*bgh
	dc.w	512
;	line 423
	dc.w	208-19*bgh
	dc.w	256



;font			incbin	gfx/sh16/font4.neo
fontBin		incbin	gfx/sh16/bin/font.bin

	IFEQ loadscroller
	ELSE
scroller	


		dc.b	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HELLO@NORTHERN@FRIENDS,@ITS@GREAT@TO@SEE@YOU@ALL@AGAIN@"
		dc.b	"THIS@SOMMAR@EVENING...WE@CAN@NOT@LET@THE@OPPORTUNITY@SILENTLY@PASS@BY@TO@MAKE@ANOTHER@SMALL@DEMO...@SO@WE@GOT@TOGETHER@AND@MADE@A@MODES"
		dc.b	"T@CONTIBUTION@FOR@THE@COZIEST@ATARI@PARTY@ALIVE...@THIS@TIME@WE@WHIPPED@OUT@EPIC@FULLSCREEN@CODE@AND@THE@FIRST@EVER@FIRE@EFFECT@OUTSIDE"
		dc.b	"@THE@BORDERS@WITH@FIFTY@FRAMES@PER@SECOND...@JUST@HAVE@A@LOOK...@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@BUT@HEY...@ITS"
		dc.b	"@JULY@IN@NORTHERN@LATITUDES@SO@THIS@DEMO@MISSES@SOMETHING@FUNDAMENTAL...@AH,@YES..@@@THE@SUMMER@SUN@RISES@OVER@LOVELY@GRADO@AND@ALL@YOU@CAN"
		dc.b	"@SEE@ARE...@MOSQUIDOTS.@@@@@@@@@@@CHECK@OUT@THIS@FIRST@EVER@MOSQUITO@SIMULATOR@FOR@PLAIN@ST.@YOU@CAN@SEE@ABOUT@ONE@HUNDRED@MOSQUIDO"
		dc.b	"TS@MOVING@ACCORDING@TO@AN@INNOVATIVE@AND@CPU@DEMANDING@BLOODSMELLING@SEARCH@ALGORTIHM.@@@NASTY@BUGS@INCLUDED.@HAR@HAR@HAR...@@@@@@@@@@@"
		dc.b	"@@@ENOUGH@OF@THE@SERIOUS@TECH@TALK.@GREETINGS@TIME...@INTENSIVE@MOSQUITOBYTES@GO@OUT@TO@THE@OTHER@SOMMARHACKERS@ACCA,@AGGRESSION,@COLLA"
		dc.b	"PZE,@DAS,@DBA,@DGT,@DHL,@DEAD@GRAPEFUITS,@DEAR@HACKERS@ALIVE,@DHR,@DHT,@DNT,@DZZ,@EVOLUTION,@KUA,@LUZAKTEAM,@NATURE,@NEW@BEAT,@PHONER,"
		dc.b	"@RESERVOIR@GODS,@SOTE,@XIA@AND@ALL@WE@FORGOT.@@@@@@@@@OH@YES,@AND@DHS.@@@@@@@@@@@@@@NOW@AS@YOU@SEE@EVERYTHING@WAS@NICE@AND@CALM@IN@LOVEL"
		dc.b	"Y@SWEDEN.@ATARI@PPL@DOING@ATARI@STUFFS.@BUT@THEN@SUDDENLY@SOME@CRAZY@DHS@MEMBERS@DECIDED@TO@LIGHTEN@THE@MEGA@BBQ@STROLLER@IN@MALMGARDEN"
		dc.b	"@INITIATING@SUDDEN@ALTERNATIONS@OF@THE@SOLAR@FLARES.@@@@@@@@@@@@@@@@@@@@@@@@@@@@OK,@WE@WILL@LEAVE@YOU@WITH@THIS@LITTLE@PIECE@OF@GEOPHYS"
		dc.b	"ICAL@AWESOMENESS@AND@THANK@OUR@HOST@DHS@...@EVIL@THOSE@ARPS@ARE@FOR@YOU@...@@@@@@@@@@@@@@@@@@@@@@@@@@@BYE@BYE@AND@SEE@YOU@NEXT@YEAR@@@@"
		dc.b	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@""

	ENDC
	even

offset				dc.w	0
fontOffset			dc.l	0
scrollLength		equ 	48*80
scrollLineWidth		equ 	230
scrollerColour		equ 	$630
scrollScreenOff2	equ		3*160+27*230+154*160+47*230-8
scrollScreenOff		dc.l	3*160+28*2*230+130*160+30*230+16


stroller		incbin	gfx/sh16/bin/strollerpal.bin

strollerleft1	incbin	gfx/sh16/bin/strollerleft1.bin
strollerleft2	incbin	gfx/sh16/bin/strollerleft2.bin
strollerleft3	incbin	gfx/sh16/bin/strollerleft3.bin

strollerright1	incbin	gfx/sh16/bin/strollerright1.bin
strollerright2	incbin	gfx/sh16/bin/strollerright2.bin
strollerright3	incbin	gfx/sh16/bin/strollerright3.bin

lineEndColor	equ 	$213
linePal			dc.w	$000,$001,$002,$102,$112,$212,$213,$213
				dc.w	$000
fontPal			dc.w	$000,$403,$730,$763,$777,$575,$352,$130
bgBuffer		incbin	gfx/sh16/bin/bgBuffer2.bin


; 1 bpl sun, and is fugly
newSunbuffer	ds.b	4800
sunBuffer		incbin	gfx/sh16/bin/sunbg.bin					; 200 * 12 * 2 = 4800		
newSunbuffer2	ds.b	4800
sunBuffer2		incbin	gfx/sh16/bin/sunbg2.bin					; 200 * 12 * 2 = 4800		
suncols



	dc.w $707,$777,$776,$777,$776,$776,$776,$776,$776,$776	;10
	dc.w $775,$776,$775,$775,$774,$775,$774,$774,$764,$774	;20
	dc.w $764,$764,$754,$764,$754,$754,$753,$754,$753,$753	;30
	dc.w $743,$753,$743,$743,$742,$733,$742,$742,$733,$742	;40
	dc.w $733,$634,$733,$634,$634,$633,$634,$633,$633,$535	;50
	dc.w $633,$535,$535,$724,$535,$724,$724,$534,$724,$534	;60
	dc.w $534,$723,$534,$723,$723,$533,$723,$533,$533,$714	;70
	dc.w $533,$714,$713,$713,$714,$713,$713,$623,$713,$623	;80
	dc.w $623,$524,$623,$524,$605,$524,$605,$605,$614,$605	;90
	dc.w $614,$614,$523,$614,$523,$523,$613,$523,$613,$613	;100
	dc.w $604,$613,$604,$604,$424,$604,$424,$424,$603,$424	;110
	dc.w $603,$603,$423,$603,$423,$423,$514,$423,$514,$514	;120
	dc.w $422,$514,$422,$422,$513,$422,$513,$513,$512,$513	;130
	dc.w $512,$503,$512,$503,$503,$414,$503,$414,$414,$502	;140

	dc.w $414
	dc.w	$0,$502,$502,$413,$502,$413,$413,$412,$403,$412	;150
	dc.w $412,$403,$412,$403,$403,$313,$403,$313,$313,$402	;160
	dc.w $313,$402,$402,$401,$402,$401,$401,$312,$401,$312	;170
	dc.w $312,$213,$312,$213,$213



	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000	;	-168
	dc.w	$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000,$111	;	-144
	dc.w	$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000,$222	;	-120
	dc.w	$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$000,$333	;	-96
	dc.w	$000,$000,$000,$000,$000,$000,$001,$000,$000,$000,$001,$444	;	-72
	dc.w	$000,$000,$000,$000,$000,$000,$002,$000,$001,$000,$102,$555	;	-48
	dc.w	$000,$000,$001,$000,$001,$100,$003,$101,$102,$010,$213,$666	;	-24

logoPal		

	dc.w	$000,$101,$102,$111,$112,$211,$104,$212,$213,$121,$324,$777

	dc.w	$000,$201,$202,$211,$212,$311,$204,$312,$313,$221,$424,$777
	dc.w	$000,$201,$202,$221,$222,$321,$204,$322,$323,$231,$434,$777
	dc.w	$000,$202,$203,$222,$223,$322,$205,$323,$324,$232,$435,$777

	dc.w	$000,$302,$303,$322,$323,$422,$305,$423,$424,$332,$535,$777
	dc.w	$000,$302,$303,$332,$333,$432,$305,$433,$434,$342,$545,$777
	dc.w	$000,$303,$304,$333,$334,$433,$306,$434,$435,$343,$546,$777

	dc.w	$000,$403,$404,$433,$434,$533,$406,$534,$535,$443,$646,$777
	dc.w	$000,$403,$404,$443,$444,$543,$406,$544,$545,$453,$656,$777
	dc.w	$000,$404,$405,$444,$445,$544,$407,$545,$546,$454,$657,$777

logoBuffer	incbin	gfx/sh16/bin/logo6.bin
linbuff		incbin	gfx/sh16/bin/icons.bin




;logo1	incbin gfx/sh16/logo1n.neo
;logo2	incbin gfx/sh16/logo2n.neo
;atari		incbin		gfx/sh16/t/atari.neo
;bbq			incbin		gfx/sh16/t/bbq.neo
;beachball	incbin		gfx/sh16/t/beachball.neo
;bee			incbin		gfx/sh16/t/bee.neo
;coke		incbin		gfx/sh16/t/coke.neo
;elk			incbin		gfx/sh16/t/elk.neo
;falcon		incbin		gfx/sh16/t/falcon.neo
;ikea		incbin		gfx/sh16/t/ikea.neo
;ikeaman		incbin		gfx/sh16/t/ikeaman.neo
;mosquito	incbin		gfx/sh16/t/mosquito.neo
;motorola	incbin		gfx/sh16/t/motorola.neo
;joystick	incbin		gfx/sh16/t/joystick.neo
;parasol		incbin		gfx/sh16/t/parasol.neo
;pig			incbin		gfx/sh16/t/pig.neo
;plane		incbin		gfx/sh16/t/plane.neo
;strawberry	incbin		gfx/sh16/t/strawberry.neo
;system		incbin		gfx/sh16/t/system.neo
;sun			incbin		gfx/sh16/t/sun.neo
;tent		incbin		gfx/sh16/t/tent.neo
;toilet		incbin		gfx/sh16/t/toilet.neo
;trash		incbin		gfx/sh16/t/trash.neo
;volvo		incbin		gfx/sh16/t/volvo.neo


	IFNE	loadmusic
music	incbin		msx/MOSQUIDF.SND
	ENDC


creditsBuffer	incbin	gfx/sh16/bin/credits.bin


	SECTION BSS
; general stuff
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
; stroller
buffer						ds.b	sprite_buffersize*6
; fire stuff
_fireBuffer1				ds.b	fireWidth*(fireHeight+2)*2
_fireBuffer2				ds.b	fireWidth*(fireHeight+2)*2
_fireResult1				ds.w	8*fireHeight
_fireResult2				ds.w	8*fireHeight
_randomSeed					ds.l	1
_randomSeed2				ds.l	1
_tmp						ds.w	1
scrollTextPrepped			ds.w	scrollLength
sunDistBuffer				ds.b	200*2*14*16
sunDistList					ds.l	200
squitoClearList				ds.l	100
squitoClearList2			ds.l	100
clearListPointer			ds.l	1
clearListPointer2			ds.l	1

fontBuffer					ds.w	font_height*font_characters*8*2
							ds.b	2000
;sun
_sunPointer					ds.l	1
	IFNE FRAMECOUNT
framecounter				ds.w	1
	ENDC