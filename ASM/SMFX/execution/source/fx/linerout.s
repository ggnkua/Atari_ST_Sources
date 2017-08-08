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

; todo:
; - 
;


    section	TEXT

    IFEQ STANDALONE
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

	move.l	#block2,alignpointer1

;	jsr		determineDirectionVector

	jsr		init_linerout

.mainloop

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
	ENDC



vblcount_vbl
	addq.w	#1,vblcount
	addq.w	#1,$466
	pushall
	IFEQ STANDALONE
		jsr		music+8
	ELSE
		move.l	sndh_pointer,a0
		jsr		8(a0)
	ENDC
	popall
	rte


sourcePalDoors	dc.w	$0

doorspalplace	;dc.w	$101,$112,$212,$323,$334,$444,$454,$565,$676,$777,-1,-1,-1							; ukko palette
				;dc.w	$201,$311,$321,$520,$630,$640,$750,$760,$770,$777,-1,-1,-1
				dc.w	$200,$300,$400,$520,$530,$640,$651,$761,$771,$777,-1,-1,-1
;doorspalplace	dc.w	$102,$202,$212,$222,$322,$332,$442,$552,$664,$777,-1,-1,-1							; modders favourite
;doorspalplace	dc.w	$201,$302,$312,$322,$422,$432,$542,$652,$764,$777,-1,-1,-1							; more yellow :-/
;doorspalplace	dc.w	$215,$316,$403,$512,$632,$653,$640,$440,$351,$574,-1,-1,-1						    ; rainbow like :-(=
;doorspalplace	dc.w	$212,$223,$323,$332,$432,$442,$542,$551,$662,$777,-1,-1,-1
	IFEQ loadDoorsPalette
		ds.b	15*32
	ENDC

setColorsfromSource
	lea		colors,a0
	lea		sourcePalDoors,a1
	movem.w	(a1)+,d0-d7/a2-a6
	move.w	d0,(a0)+	;	0 = 0
	move.w	d1,(a0)+	;	1 = c1
	move.w	d2,(a0)+	;	2 = c2
	move.w	d2,(a0)+	;	3 = c2
	move.w	d3,(a0)+	;	4 = c3
	move.w	d1,(a0)+	;	5 = c1
	move.w	d3,(a0)+	;	6 = c3
	move.w	d3,(a0)+	;	7 = c3
	move.w	d4,(a0)+	;	8 = c4
	move.w	d1,(a0)+	;	9 = c1
	move.w	d2,(a0)+	;	10= c2
	move.w	d2,(a0)+	;	11= c2
	move.w	d3,(a0)+	;	12= c3
	move.w	d1,(a0)+	;	13= c1
	move.w	d5,(a0)+	;	14= c5
	move.w	d4,(a0)+	;	15= c4
	move.w	d0,(a0)+	;	0 = 0
	move.w	#-1,(a0)+	;	1 = ??
	move.w	d2,(a0)+	;	2 = 2
	move.w	d2,(a0)+	;	3 = 2
	move.w	d3,(a0)+	;	4 = 3
	move.w	#-1,(a0)+	;	5 = ??
	move.w	d3,(a0)+	;	6 = 3
	move.w	d3,(a0)+	;	7 = 3
	move.w	d7,(a0)+	;	8 = 7
	move.w	d4,(a0)+	;	9 = 4
	move.w	d5,(a0)+	;	10=5
	move.w	d4,(a0)+	;	11=4
	move.w	d6,(a0)+	;	12=6
	move.w	d4,(a0)+	;	13=4
	move.w	d5,(a0)+	;	14=5
	move.w	d4,(a0)+	;	15=4
	move.w	d0,(a0)+	;	0=0
	move.w	a2,(a0)+	;	1=8
	move.w	#-1,(a0)+	;	2=?
	move.w	a4,(a0)+	;	3=a
	move.w	d3,(a0)+	;	4=3
	move.w	#-1,(a0)+	;	5=?
	move.w	d3,(a0)+	;	6=3
	move.w	d3,(a0)+	;	7=3
	move.w	d7,(a0)+	;	8=7
	move.w	a2,(a0)+	;	9=8
	move.w	d7,(a0)+	;	10=7
	move.w	a3,(a0)+	;	11=9
	move.w	d6,(a0)+	;	12=6
	move.w	d6,(a0)+	;	13=6
	move.w	d5,(a0)+	;	14=5
	move.w	d4,(a0)+	;	15=4

	move.w	d0,(a0)+	; bg

	movem.w	(a1),d0-d7				;d0 = d, d1 = e, d2 = f, d3 = g

	move.w	a2,(a0)+	; 8			;a3 = 9, a4 = a, a5 =b, a6= c
	move.w	a5,(a0)+	; b
	move.w	a4,(a0)+	; a
	move.w	d0,(a0)+	; d
	move.w	a2,(a0)+	; 8
	move.w	d1,(a0)+	; e
	move.w	a4,(a0)+	; a
	move.w	d2,(a0)+	; f
	move.w	a2,(a0)+	; 8
	move.w	a3,(a0)+	; 9
	move.w	a3,(a0)+	; 9
	move.w	d3,(a0)+	; g
	move.w	a2,(a0)+	; 8
	move.w	a3,(a0)+	; 9
	move.w	a3,(a0)+	; 9
	rts

startcolor	equ $210

border	equ	0

color1	equ startcolor
color2	equ $310
color3	equ $421
color4	equ $531
color5	equ $642
color6	equ $742
color7	equ $753
color8	equ $764
color9	equ $765
colora	equ $776
colorb	equ $777

COLORZ	equ	$707

COLORD	equ $770
COLORE	equ $077
COLORF	equ $707
COLORG	equ	$070

pallist		dc.w	p1-3,0
			dc.w	p2+2,32
			dc.w	p3-86-3,64
			dc.w	5000,96
;			dc.w	5000,128
pallistoff	dc.w	-4
palframes	dc.w	0

bars_frames	dc.w	p1-3+p2+2+p3-89



init_linerout
	IFNE STANDALONE
	move.l	screenpointer,d0
	move.l	screenpointer2,d1
	move.l	screenpointer3,d2

	; determine lowest, and sort shit out

	move.l	d1,screenpointer
	move.l	d2,screenpointer2
	ENDC

	jsr		setColorsfromSource

	move.l	screenpointer2,$ffff8200
	move.w	#$2700,sr
	move.l	#vblcount_vbl,$70
	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.l	#dummy,$120
	move.l	#dummy,$134
	move.w	#$2300,sr

	IFEQ STANDALONE
	jsr		music
	ENDC

	; when effect inits, we first mimic existing palette,
	; and set the color
	lea		$ffff8240,a0
	move.w	#0,(a0)+
	REPT 15
		move.w	#startcolor,(a0)+
	ENDR

	; then we fix the screen
	move.l	screenpointer2,a0
	move.l	screenpointer,a1
	add.w	#32000,a0
	add.w	#32000,a1

	move.w	#111-1,d7
	moveq	#-1,d0
	swap	d0
	sub.w	d0,d0
	moveq	#0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,a2
	move.l	d0,a3
	move.l	d1,a4
	move.l	d0,a5		; 1  2  3  4  5  6  7  8  9  10 11 12
	move.l	d1,a6		; d0/d1/d2/d3/d4/d5/d6/a2/a3/a4/a5/a6

.fill
o set 0
		REPT 6
			movem.l	d0-d6/a2-a6,-(a0)
			movem.l	d0-d6/a2-a6,-(a1)
o set o+8
		ENDR
		dbra	d7,.fill
		movem.l	d0-d6/a2,-(a0)
		movem.l	d0-d6/a2,-(a1)

	move.l	screenpointer,d0
	add.l	#44000,d0
	move.l	d0,lineOrDataPointer
	add.l	#6802,d0
	move.l	d0,lineAndDataPointer
	add.l	#7204,d0
	move.l	d0,myVertOffListPosPointer
	add.l	#1600,d0
	move.l	d0,myVertOffListNegPointer			;
	add.l	#1600,d0							;	61206 used

	move.l	screenpointer2,d0
	add.l	#44000,d0
	move.l	d0,pixListDataPointer
	add.l	#40320,d0
	move.l	d0,specialpointer


;pixListDataPointer				ds.l	1		;40320
;lineOrDataPointer				ds.l	1		;6802
;lineAndDataPointer				ds.l	1		;7204
;myVertOffListPosPointer		ds.l	1		;1600
;myVertOffListNegPointer		ds.l	1		;1600	--> 



; 200*20*2 = 8000 / 12 = 666 2/3 ==> 666 times + 8

	; once the screen is sorted, we can toss our own colors in

	lea		colors,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240

	jsr		generatePixelData
	jsr		genLineOrData
	jsr		genLineAndData
	jsr		generateVertOffListPos
	jsr		generateVertOffListNeg
	moveq	#0,d0
	move.w	vblcount,d0


	move.w	#0,vblcount
	move.w	#$2700,sr
	move.l	#linerout_vbl,$70
	move.w	#$2300,sr

.wait
		jsr		copyExec
		jsr		checkerboard_precalc
				exitOnSpace
	tst.w	nextScene
	bge		.wait

	rts


vblcount	dc.w	0

; waiter
; speedlistoff,
; slopex, slopey, negative, and/or
; startx1,starty1
; startx2,starty2


orand		dc.w	0
screenlist	dc.l	0
bploff		dc.w	0


; start off:
;	bpl 1 is set				1		777
;		color bpl 2				1+2		666
;		color bpl 3				1+2+3	555
;		color bpl 4				1+2+3+4	444


myDoors2
stepsize set 22
a set 0


lll	dc.w	0

doDoors
	lea		myDoors,a6	
	sub.w	#32,a6
.nextDoor
	add.w	#32,a6
.loop
	subq.w	#1,(a6)+				; frame
	bge		.nextDoor
		move.w	(a6),d6				; read offset speed
		blt		.lastDoor
		lea		speedList,a0
		add.w	d6,a0
		add.w	#4/2,d6
		cmp.w	#292/2,d6
		bne		.speedOk
			move.w	#288/2,d6
.speedOk
		move.w	d6,(a6)+			; store offset speed
		move.l	(a6)+,a5			; slope dx
		move.l	(a6)+,d3	; slopy dy
		move.w	(a6)+,negslope		; check if we're positive or negative slope
		move.w	(a6)+,orand			; check if we're doing or or and routine
		move.w	(a6)+,bploff		
		moveq	#0,d7
		move.b	(a0)+,d7
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,curStep
;		move.w	(a0)+,curStep	
	
;		addq.w	#1,lll
;		cmp.w	#14,lll
;		bne		.llll

;.llll

		move.l	screenpointer,d6

		move.l	(a6),d0
		move.l	4(a6),d1
		move.w	d7,curSpeed
		jmp		.right(pc,d7)
.right
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		jsr		doRight				; d0,d1						; remove use of memory addresses here for speed
		move.l	d0,(a6)+			; store startx right
		move.l	d1,(a6)+			; store starty right

		lea		pixList,a1
		add.w	curStep,a1
		jsr		drawLineOr



		move.l	(a6),d0
		move.l	4(a6),d1
		move.w	curSpeed,d7
		jmp		.left(pc,d7)
.left
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		jsr		doLeft				; d0,d1
		
		move.l	d0,(a6)+
		move.l	d1,(a6)+
	
		lea		pixList,a1
		add.w	curStep,a1
		jsr		drawLineOr

;		sub.w	#$100,$ffff8240
		jmp		.loop

	rts

.lastDoor
;	sub.w	#$100,$ffff8240

	rts

doPalette
	subq.w	#1,palframes
	bgt		.ok
		lea		pallist,a0
		add.w	#4,pallistoff
		add.w	pallistoff,a0
		move.w	(a0)+,palframes
		lea		colors,a1
		add.w	(a0),a1
		movem.l	(a1),d0-d7
		movem.l	d0-d7,$ffff8240
		rts
.ok
		lea		pallist+2,a0
		add.w	pallistoff,a0


	lea		colors,a1
	add.w	(a0),a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,$ffff8240


	rts

waiter	dc.l	5
defw	dc.w	3
metawait	dc.w	2
mww			dc.w	15



waitsub	dc.l	1


linerout_vbl
	pushall

	move.l	screenpointer2,$ffff8200
			swapscreens
			move.w	#0,$ffff8240
	addq.w	#1,vblcount
	jsr		doPalette

	tst.w	gridTimerB
	beq		.noTimerB


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



	add.w	#10,timer_b_source
	cmp.w	#10*12,timer_b_source
;	cmp.w	#4*13*23,timer_b_source
	bne		.okxx
		move.w	#0,timer_b_source
		neg.w	color_source

		subq.w	#1,cycle_times
		bge		.okxx
			move.w	color_source,color
			move.w	#$2700,sr			
			move.l	#perspective_bars_vbl,$70
			move.w	#$2300,sr	
.okxx
	move.w	color_source,color
	move.w	timer_b_source,timer_b_off
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#checker_timer_b2,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL
.noTimerB



		move.l	sndh_pointer,a0
		jsr		8(a0)


	jsr		doDoors
	cmp.w	#51,bars_frames
	blt		.ttttt
	jsr		doTransition
.ttttt
;	jmp		.tt
;.skip
;		move.l	d2,waiter
;.tt

	subq.w	#1,bars_frames
	bge		.ok

		subq.w	#1,gridTimes
		blt		.ok
				move.w	#0*200,d0
				move.l	offset,d1
				move.w	#-1,gridTimerB
				jsr		exampleGrid


.ok
	IFEQ STANDALONE
	jsr		music+8
	ELSE
;		move.l	sndh_pointer,a0
;		jsr		8(a0)
	ENDC
	popall

;	move.w	#$050,$ffff8240
	rte

counterd	dc.w	40
savedx		dc.l	0
gridTimes	dc.w	2
gridTimerB	dc.w	0

transitionText	incbin	"fx/doors/transition2.bin"

;textBuffer	ds.b	4*7*11			;192		308
;
;prepTransitionText
;	lea		ttx+128,a0
;	lea		textBuffer,a1
;y set 0
;	REPT 11
;o set y
;		REPT 7
;			move.l	o(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR
;
;	lea		textBuffer,a0
;	move.b	#0,$ffffc123
;	rts


doTransition
	lea		transitionText,a0
;	lea		ttx+128,a0
	move.l	screenpointer2,a1
	add.w	#187*160,a1
	add.w	#13*8,a1
y set 0
	REPT 11

			movem.l	(a0)+,d0-d6
			and.l	d0,(a1)+
			and.l	d0,(a1)+
			and.l	d1,(a1)+
			and.l	d1,(a1)+
			and.l	d2,(a1)+
			and.l	d2,(a1)+
			and.l	d3,(a1)+
			and.l	d3,(a1)+
			and.l	d4,(a1)+
			and.l	d4,(a1)+
			and.l	d5,(a1)+
			and.l	d5,(a1)+
			and.l	d6,(a1)+
			and.l	d6,(a1)+
			add.w	#160-7*8,a1
	ENDR
	rts

doTransition2
	lea		transitionText,a0
	move.l	screenpointer2,a1
	add.w	#190*160,a1
	add.w	#14*8,a1
	move.w	#8-1,d7
.ol
o set 0
		REPT 6
			move.l	(a0)+,d0
			and.l	d0,(a1)+
			and.l	d0,(a1)+
o set o+8
		ENDR
;	add.w	#160,a0
	add.w	#160-6*8,a1
	dbra	d7,.ol
	rts


timer_b_l
;	move.w	#$2700,sr
	clr.b   $FFFFFA1B.w
   	move.b  #2,$FFFFFA21.w
   	move.b  #8,$FFFFFA1B.w
   	pushd0
   	pusha0
   	pusha1
	move.b  $FFFFFA21.w,D0
tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   tb_sync

 
    move.b  #0,$FFFF820A.w  
    REPT 16
    	nop
    ENDR

    move.b  #2,$FFFF820A.w  ; 50 hz

    rte

; dx/dy = direction
; right = -dy/dx
; if y > 0, then y-dx and xfraction-dy

; uses:
;	d0	xposition		in
;	d1	yposition		in
;	d2	zero			
;	d4	direction_dx	in
;	

;	d5
doRight
	moveq	#0,d2
	tst.w	d1					; if y > 0
	bgt		.startmovesup
.startmovesright				; if y == 0, then we move right
		move.l	a5,d4		; = dx		; direction	;; so we have to divide this
		move.w	d1,d5
		sub.l	d4,d1
		subx.w	d2,d1
		addq.l	#1,d0
		rts
.startmovesup					; if y > 0, then we move up
		move.l	d3,d4
		sub.l	d4,d1
		subx.w	d2,d1
		move.l	a5,d4
		sub.w	d4,d4
		add.l	d4,d0
		rts

doLeft
	moveq	#0,d2
	tst.w	d0
	bgt		.startmovesleft
.startmovesdown
	move.l	d3,d4
	add.l	d4,d1
	addx.w	d2,d1
	move.l	a5,d4
	sub.w	d4,d4
	add.l	d4,d0
	rts
.startmovesleft
	move.l	a5,d4
	move.w	d1,d5
	sub.w	d4,d4
	add.l	d4,d1
	subq.l	#1,d0
	rts


; we do: 
; dx = right x - left x
; dy = right y - left y
;
;	d0; left x
;	d1: left y
;	d2; right x
;	d3; right y
;

negslope	dc.w	0

	IFEQ STANDALONE

directionListVectors
		dc.l	0,0
		dc.l	319,199

		dc.l	26,0
		dc.l	293,199

		dc.l	52,0
		dc.l	267,199

		dc.l	78,0
		dc.l	241,199

		dc.l	104,0
		dc.l	215,199

		dc.l	130,0
		dc.l	189,199

;	0,0
;;	26,0
;	52,0
;	78,0
;	104,0
;	130,0
source_x		dc.l	120
source_y		dc.l	0
dest_x			dc.l	200
dest_y			dc.l	199

startr_x		dc.l	160
startr_y		dc.l	0
startl_x		dc.l	0
startl_y		dc.l	0

determineDirectionVector
	lea		directionListVectors,a0
	move.w	#6-1,d7
.doit
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
;	move.l	source_x,d0
;	move.l	source_y,d1
;	move.l	d1,startr_y
;	move.l	d1,startl_y
;	move.l	dest_x,d2		
;	move.l	dest_y,d3		

	sub.w	d0,d2			;dx
	bge		.pos
		move.w	#-1,negslope	
		neg.w	d2
		neg.w	d0
		add.w	#319,d0
.pos

	move.l	d0,startr_x
	move.l	d0,startl_x


	sub.w	d1,d3			;dy
	move.l	d2,d5

	; now we have dx and dy; we want to iterate over y, so we do dx/dy, and we need fraction
	;1,606246948242188
	;dx/dy
	divu	d3,d2					; divide
	move.w	d2,d4					; put whole in lower word
	clr.w	d2						; clear lower word
	swap	d2						; put remainder in lower word
	asl.l	#8,d2					; shift up 8 positions
	divu	d3,d2					; divide again
	asl.w	#8,d2
	swap	d4						; swap words, so fraction is in lower
	or.w	d2,d4					; OR into the bits

	swap	d4						; fraction,whole

	move.l	d4,direction_dx
	move.l	d5,d2

	divu	d2,d3
	move.w	d3,d4
	clr.w	d3
	swap	d3
	asl.l	#8,d3
	divu	d2,d3
	asl.w	#8,d3
	swap	d4
	or.w	d3,d4
	swap	d4


	move.l	d4,direction_dy

	move.l	direction_dx,d0
	move.l	direction_dy,d1

	dbra	d7,.doit

	rts
	ENDC

direction_dx	dc.l	0	; dx 
direction_dy	dc.l	0	; dx 
curSpeed		dc.w	0
curStep			dc.w	0
speedListOff	dc.w	0


;	dc.w	7
;	dc.w	7
;;;	dc.w	7
	;dc.w	7
; linedraw start methods, when direction is done, is always
; x=0 && 0 <= y <= 199	or
; 0 <= x <= 319, && y = 0

; we do: 
; dx = right x - left x
; dy = right y - left y

;	d0	x		in
;	d1	y		in
;	d2	local	
;	d4	directionx
;	d5	local 0
;	d6	screen

;	d3	free
;	d7	free
;	
;	a1	; drawlist
;	a2	; ylist
;	a3	; local var
;	a4	; tmp x

;	a5	; free
;	a6	; global list
;
drawLineOr
	tst.w	negslope
	bne		.drawNegativerSlope2
		move.l	myVertOffListPosPointer,a2
	jmp		.ddd
.drawNegativerSlope2
		move.l	myVertOffListNegPointer,a2
.ddd

	add.w	bploff,a2

	cmp.w	#200,d1
	bge		.end
	cmp.w	#334,d0
	bge		.end

	moveq	#0,d5
	move.l	(a1),a1
	move.l	a5,d4
	tst.w	d1
	bge		.ypos
		move.w	#200,d1
		jmp		.startDrawPix
.ypos
	add.w	d1,d1
	add.w	d1,a2
	lsr		d1
	neg.w	d1
	add.w	#200,d1

.startDrawPix
	move.w	#334*8,a4
	moveq	#-8,d7
	rol.l	#3,d0
	rol.l	#3,d4	
	tst.w	orand
	bne		.doand	
.door
	muls	#-34,d1
	add.w	#200*34,d1
	move.l	lineOrDataPointer,a3
	jmp		(a3,d1.w)
.doand
	muls	#36,d1
	neg.w	d1
	add.w	#200*36,d1
	move.l	lineAndDataPointer,a3
	jmp		(a3,d1.w)
;.drawPix
;	REPT 200
;	cmp.w	a4,d0						;4					;2											B04C
;	bgt		.end						;8 not taken		;4											6E00 XXXX		(1st =  1A84)	6788	
;		move.w	d0,d1					;4					;2											3200
;		and.w	d7,d1					;4					;2											C247			
;		move.w	(a2)+,d6				;8					;2											3C1A
;		move.l	a1,a3					;4					;2											2649
;		add.w	d1,a3					;8					;2											D6C1
;		move.l	(a3)+,d1				;12					;2											221B
;		add.w	(a3)+,d6				;8					;2											DC5B
;		move.l	d6,a3					;4					;2											2646
;	;	not.l	d1																										;4681
;		or.w	d1,(a3)					;12					;2											8353			;C353
;		swap	d1						;4					;2											4841
;		or.w	d1,-8(a3)				;16					;4											836B FFF8		;C36B
;		add.l	d4,d0					;8					;2											D084
;		addx.w	d5,d0					;4					;2			 34 size = 96 cycles			D145
;	ENDR
.end
	rts

;200*34 = 6800 bytes


genLineOrData
;	lea		lineOrData,a0
	move.l	lineOrDataPointer,a0
	move.w	#34,d6

	move.w	#200-1,d7
	move.l	#$0000B04C,d0		;	cmp.w	a4,d0
	move.l	#$6E001A8C,d1		;	bgt 			;	xxx
	move.l	#$3200C247,d2		;	move.w	d0,d1	;	and.w	d7,d2
	move.l	#$3C1A2649,d3		;	move.w	(a2)+,d6;	move.l	a1,a3
	move.l	#$D6C1221B,d4		;	add.w	d1,a3	;	move.l	(a3)+,d1
	move.l	#$DC5B2646,d5		;	add.w	(a3)+,d6;	move.l	d6,a3
	move.l	#$83534841,a1		;	or.w	d1,(a3)	;	swap	d3
	move.l	#$836BFFF8,a2		;	or.w	d1,-8(a3)
	move.l	#$D084D145,a3		;	add.l	d4,d0	;	addx.w	d5,d0

.fill
		move.w	d0,(a0)+
		movem.l	d1-d5/a1-a3,(a0)
		add.w	#32,a0
		sub.w	d6,d1
	dbra	d7,.fill
	move.w	#$4E75,(a0)
	rts

genLineAndData
;	lea		lineAndData,a0
	move.l	lineAndDataPointer,a0
	move.l	#36,d6
	swap	d6

	move.w	#200-1,d7
	move.l	#$B04C6E00,d0		;	cmp.w	a4,d0,	;	bgt
	move.l	#$1C1C3200,d1		;	xxx				;	move.w	d0,d1			 1C16
	move.l	#$C2473C1A,d2		;	and.w	d7,d1	;	move.w	(a2)+,d6
	move.l	#$2649D6C1,d3		;	move.l	a1,a3	;	add.w	d1,a3	
	move.l	#$221BDC5B,d4		;	move.l	(a3)+,d1;	add.w	(a3)+,d6
	move.l	#$26464681,d5		;	move.l	d6,a3	;	not.l	d1
	move.l	#$C3534841,a1		;	and.w	d1,(a3)	;	swap	d1
	move.l	#$C36BFFF8,a2		;	and.w	d1,-8(a3)
	move.l	#$D084D145,a3		;	add.l	d4,d0	;	addx.w	d5,d0

.fill
		movem.l	d0-d5/a1-a3,(a0)
		add.w	#36,a0
		sub.l	d6,d1
	dbra	d7,.fill
	move.w	#$4E75,(a0)
	rts


pixList
	ds.l	15			; 2576 bytes per


generatePixelData
;	lea		pixListData,a0
	move.l	pixListDataPointer,a0
	lea		pixList,a5

	;2
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<2-1)<<14,a4
	move.l	#(1<<2-1)<<15,a6
	jsr		generatePixList

	;3
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<3-1)<<14,a4
	move.l	#(1<<3-1)<<15,a6
	jsr		generatePixList

	;4
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<4-1)<<14,a4
	move.l	#(1<<4-1)<<15,a6
	jsr		generatePixList

	;5
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<5-1)<<14,a4
	move.l	#(1<<5-1)<<15,a6
	jsr		generatePixList

	;6
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<6-1)<<14,a4
	move.l	#(1<<6-1)<<15,a6
	jsr		generatePixList

	;7
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<7-1)<<14,a4
	move.l	#(1<<7-1)<<15,a6
	jsr		generatePixList

	;8
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<8-1)<<14,a4
	move.l	#(1<<8-1)<<15,a6
	jsr		generatePixList

	;9
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<9-1)<<14,a4
	move.l	#(1<<9-1)<<15,a6
	jsr		generatePixList

	;10
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<10-1)<<14,a4
	move.l	#(1<<10-1)<<15,a6
	jsr		generatePixList

	;11
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<11-1)<<14,a4
	move.l	#(1<<11-1)<<15,a6
	jsr		generatePixList

	;12
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<12-1)<<14,a4
	move.l	#(1<<12-1)<<15,a6
	jsr		generatePixList

	;13
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<13-1)<<14,a4
	move.l	#(1<<13-1)<<15,a6
	jsr		generatePixList

	;14
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<14-1)<<14,a4
	move.l	#(1<<14-1)<<15,a6
	jsr		generatePixList

	;15
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<15-1)<<14,a4
	move.l	#(1<<15-1)<<15,a6
	jsr		generatePixList


	;16
	move.l	a0,(a5)+
	move.l	#1<<15,a3
	move.l	#(1<<16-1)<<14,a4
	move.l	#(1<<16-1)<<15,a6
	jsr		generatePixList

	rts

generatePixList
	moveq	#0,d0				; offset
	; first pixel is special
	move.l	a3,d1			; pixel value
	move.l	d1,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	; other 16 pixels are ok
	move.w	#15-1,d7
	move.l	a4,d1
.pixel	
		move.l	d1,d2
		swap	d2
		sub.w	d2,d2
		swap	d2
		move.l	d2,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		asr.l	d1			; >> 1
	dbra	d7,.pixel
	addq.w	#8,d0			; next block
;	move.w	#-1,(a0)+
	; first 16 pixels done, 19*16 left
	move.w	#19-1,d6		; outerloop
.ol
	move.w	#16-1,d7		; innerloop
	move.l	a6,d1
.il

		move.l	d1,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		lsr.l	d1
		dbra	d7,.il
	addq.w	#8,d0
	dbra	d6,.ol
	; 19*16 blocks done


	move.w	#16-1,d7		; innerloop
	move.l	a6,d1
.il2
		move.l	d1,d2
		sub.w	d2,d2
		move.l	d2,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		lsr.l	d1
		dbra	d7,.il2
	addq.w	#8,d0
	rts




generateVertOffListPos
	move.l	myVertOffListPosPointer,a0
	move.w	#160,d1
	moveq	#0,d2
	moveq	#4-1,d3

.out
	move.l	d2,d0
	move.w	#5-1,d7
.in
	REPT 40
		move.w	d0,(a0)+
		add.w	d1,d0
	ENDR
	dbra	d7,.in
	addq.w	#2,d2
	dbra	d3,.out
	rts

generateVertOffListNeg
	move.l	myVertOffListNegPointer,a0
	move.w	#160,d1
	move.l	#160*199,d2
	moveq	#4-1,d3
.out
	move.l	d2,d0
	move.w	#5-1,d7
.in
	REPT 40
		move.w	d0,(a0)+
		sub.w	d1,d0
	ENDR
	dbra	d7,.in
	add.w	#2,d2
	dbra	d3,.out
	rts


copyExec
;	tst.w	copyDone
;	bne		.exit
	lea		exec,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.l	#200*160,a1
	add.l	#200*160,a2
	move.w	#46-1,d7
.il
	REPT 20
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+

	ENDR
	dbra	d7,.il
	move.w	#$4e75,copyExec
;.exit
	rts

	SECTION DATA

;transitionText		incbin 	"fx/doors/intransition.pi1"
;	incbin	gfx/transition.pi1

myDoors
stepsize set 22
a set 0
	; +2	(1+2)
	dc.w	a,0						; frames,offset
	dc.l	$9B330001,$9F330000		; slopex,slopey
	dc.w	-1						; slope negative
	dc.w	0						; or
	dc.w	400						; bitplane 2
	dc.l	0,0						; right x/y
	dc.l	0,0						; left x/y
a set a+stepsize
	;3		(1+2+3)
	dc.w	a,0					
	dc.l	$9B330001,$9F330000
	dc.w	0					
	dc.w	0					
	dc.w	800					
	dc.l	0,0					
	dc.l	0,0					
a set a+stepsize
	;4		(1+2+3+4)
	dc.w	a,0				
	dc.l	$67330000,$7F330002
	dc.w	0
	dc.w	0
	dc.w	1200
	dc.l	126,0
	dc.l	126,0
a set a+stepsize
	;-1		(2+3+4)
	dc.w	a,0				
	dc.l	$9B330001,$9F330000		
	dc.w	-1				
	dc.w	1				
	dc.w	0				
	dc.l	0,0				
	dc.l	0,0				
a set a+stepsize
p1	set a
	;-2		(3+4)
	dc.w	a,0								; so at 109 we change palette		
	dc.l	$67330000,$7F330002
	dc.w	-1
	dc.w	1
	dc.w	400
	dc.l	126,0
	dc.l	126,0
a set a+stepsize
	;-3		(4)
	dc.w	a,0								; so at 109 we change palette		
	dc.l	$67330000,$7F330002
	dc.w	0
	dc.w	1
	dc.w	800
	dc.l	126,0
	dc.l	126,0
a set a+stepsize
p2 set a-p1
	;+1		(1+4)
	dc.w	a,0			
	dc.l	$9B330001,$9F330000	
	dc.w	-1			
	dc.w	0			
	dc.w	0			
	dc.l	0,0			
	dc.l	0,0			
a set a+stepsize
	;+2		(1+2+4)
	dc.w	a,0			
	dc.l	$9B330001,$9F330000	
	dc.w	0			
	dc.w	0			
	dc.w	400			
	dc.l	0,0			
	dc.l	0,0			
a set a+stepsize
	;-4		(1+2)
	dc.w	a,0			
	dc.l	$67330000,$7F330002
	dc.w	-1
	dc.w	1
	dc.w	1200
	dc.l	126,0
	dc.l	126,0
a set a+stepsize+9
p3 set a-p2
	;-1		(2)
	dc.w	a+8,0			
	dc.l	$67330000,$7F330002
	dc.w	0
	dc.w	1
	dc.w	0
	dc.l	126,0
	dc.l	126,0
	dc.w	-1,-1		
	dc.w	-1,-1		
	dc.w	-1,-1		


speedList
	dc.b	24,8
	dc.b	24,12
	dc.b	24,12
	dc.b	24,12
	dc.b	24,12
	dc.b	24,12
	dc.b	24,12
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,16
	dc.b	20,20
	dc.b	20,20
	dc.b	20,20
	dc.b	20,20
	dc.b	20,20
	dc.b	16,24
	dc.b	16,24
	dc.b	16,24
	dc.b	16,24
	dc.b	16,24
	dc.b	16,28
	dc.b	16,28
	dc.b	16,28
	dc.b	16,28
	dc.b	16,28
	dc.b	12,32
	dc.b	12,32
	dc.b	12,32
	dc.b	12,32
	dc.b	12,32
	dc.b	12,32
	dc.b	12,32
	dc.b	12,40
	dc.b	12,40
	dc.b	12,40
	dc.b	12,40
	dc.b	12,40
	dc.b	8,44
	dc.b	8,44
	dc.b	8,44
	dc.b	8,44
	dc.b	8,52
	dc.b	4,52
	dc.b	4,52
	dc.b	4,52
	dc.b	4,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
	dc.b	0,52
;pixlist
;off	set 0
;x set 1<<15
;		dc.w	0
;		dc.w	x
;		dc.w	off
;x set 3<<14
;		REPT 15
;			dc.l	x
;			dc.w	off
;x set x>>1
;		ENDR
;off set off+8
;
;
;	REPT 19
;x set 3<<15
;;x set %1111111111111111
;		REPT 16
;			dc.l	x
;			dc.w	off
;x set x>>1
;		ENDR
;off set off+8
;	ENDR
;x set 1<<16
;off set 160
;
;	REPT 2
;		dc.l	x
;		dc.w	off
;	ENDR

; 2*4*400 = 3200 bytes
;vertOffList						; generate this shit for profit
;y set 0
;	REPT 200
;		dc.w	y
;y set y+160
;	ENDR
;
;vertOffList2
;y set 2
;	REPT 200
;		dc.w	y
;y set y+160
;	ENDR
;
;vertOffList4
;y set 4
;	REPT 200
;		dc.w	y
;y set y+160
;	ENDR
;
;vertOffList6
;y set 6
;	REPT 200
;		dc.w	y
;y set y+160
;	ENDR
;
;vertOffListNeg
;y set 160*199
;	REPT 200
;		dc.w	y
;y set y-160
;	ENDR
;
;vertOffListNeg2
;y set 160*199+2
;	REPT 200
;		dc.w	y
;y set y-160
;	ENDR
;
;vertOffListNeg4
;y set 160*199+4
;	REPT 200
;		dc.w	y
;y set y-160
;	ENDR
;
;vertOffListNeg6
;y set 160*199+6
;	REPT 200
;		dc.w	y
;y set y-160
;	ENDR

	IFEQ 	STANDALONE
	include		lib/lib.s

	IFNE	loadmusic
music
	incbin	msx/new.snd
	ENDC
	ENDC

;ttx	incbin	fx/doors/intrans.neo


	SECTION BSS
; general stuff
	IFEQ	STANDALONE
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
block1						ds.b	65536
block2						ds.b	65536
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointer3				ds.l	1
alignpointer1				ds.l	1
	ENDC

pixListDataPointer			ds.l	1		;40320
lineOrDataPointer			ds.l	1		;6802
lineAndDataPointer			ds.l	1		;7204
myVertOffListPosPointer		ds.l	1		;1600
myVertOffListNegPointer		ds.l	1		;1600
colors	ds.b	66*2

;pixListData					ds.b	40320
;lineOrData					ds.b	6802
;lineAndData					ds.b	7204
;myVertOffListPos			ds.b	1600
;myVertOffListNeg			ds.b	1600		--> 57526

	IFNE FRAMECOUNT
framecounter				ds.w	1
	ENDC

	SECTION DATA
