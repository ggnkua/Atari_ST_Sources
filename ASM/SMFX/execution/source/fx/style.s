; first:
;	O code seemless switch from normal to open top/lower border; not gonna happen, because we take a closed border approach
;	- write raster code that takes into account the number of lines of curtain opened
;		- raster code for the timer b code itself
;		- but also for scheduling; timer b scheduling has a max value, since it doesnt totally open
;		- make sure the panel colors are restored properly
;
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

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

										;3360	336000
    section	TEXT


    IFEQ	STANDALONE

	include macro.s
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


	jsr		init_style
.mainloop

;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines







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

dummyMusic
	rept 20
		nop
	endr
	rts

	ENDC

init_style_pointers
	move.l	screenpointer,d0
	add.l	#280*160,d0
	move.l	d0,panelBufferPointer
	lea		haxSpace,a0
	add.l	#93986,a0
	move.l	a0,rasterListPointer
	move.l	a0,rasterListPointerSaved
	rts

precalc_style
	jsr		generateRasterValues
	jsr		generateTheFadeShit
	move.w	#$4e75,precalc_style
	rts


;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines
init_style
	jsr		init_style_pointers
	jsr		precalc_style


	move.l	rasterListPointerSaved,a0
	move.w	#14-1,d7
	moveq	#0,d0
.l
		move.l	d0,-(a0)
	dbra	d7,.l


	jsr		prepPanel
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	#32000,a0
	add.w	#32000,a1
	add.w	#64,a0
	add.w	#64,a1
	move.w	#30-1,d7
	moveq	#0,d0
.il
	REPT 12
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	add.w	#64,a0
	add.w	#64,a1
	dbra	d7,.il

	IFEQ STANDALONE

	move.l	screenpointer2,a1
	move.l	screenpointer,a2

	lea		panel+34,a3
	move.w	#200-1,d7
.dl	
o set 0
		REPT 1
			movem.l	(a3)+,d0-d6/a4		; 8 regs
			movem.l	d0-d6/a4,(a1)
			movem.l	d0-d6/a4,(a2)

			movem.l	(a3)+,d0-d5
			movem.l	d0-d5,32(a1)
			movem.l	d0-d5,32(a2)
		ENDR
		add.l	#160,a1
		add.l	#160,a2
		add.l	#160-56,a3
	dbra	d7,.dl


	move.l	#dummyMusic,sndh_pointer

	ENDC
	move.w	#$2700,sr
	move.l	#style_vbl,$70
	move.w	#$2300,sr
	move.w	#0,vblcounter
.x
	IFNE STANDALONE
	jsr		greetings_preCalc
	jsr		init_scale_1bpl
	ENDC
			exitOnSpace
	tst.w	nextScene
	beq		.x
	rts




timerbtimes			dc.w	100
rasterListOff		dc.w	0
numberOfRasterLines	dc.w	99




timer_b_execution_raster
	pushall
	move.w	#$2100,sr
	stop	#$2100
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.w	#$2700,sr
	move.l	rasterListPointer,a0
	add.w	rasterListOff,a0
	movem.l	(a0)+,d0-d6/a1						;76		19
	move.w	numberOfRasterLines,d7



.l
	REPT 27+11-3
		or.l	d7,d7							
	ENDR
	movem.l	d0-d6/a1,$ffff8240
		movem.l	(a0)+,d0-d6/a1						;76		19
	REPT 5+3
		or.l	d7,d7
	ENDR
	nop

	dbra	d7,.l
	rept 19
		or.l	d7,d7
	endr
	; here we move back in the stuff, we may need to unrollt he loop by one into here, so we can do case: number of raster lines is 1
	cmp.w	#100,panelOff
	bge		.end

	lea		panelPalette,a0
	add.w	panelPaletteOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240

	subq.w	#1,rasterFader
	bge		.skip
		move.w	#4,rasterFader
		sub.w	#32,panelPaletteOff
		bge		.skip
			move.w	#0,panelPaletteOff
.skip

	jmp		.x
.end
	move.w	bgcol,$ffff8240
.x
	move.l	sndh_pointer,a0
	jsr		8(a0)
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

	popall
	rte





drawExec
nextnextframe
	move.l	screenpointer2,a1
	add.w	#50*160,a1
	lea		execution,a2
	moveq	#0,d0
	move.w	#29-1,d7
.il
	REPT 20
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.il


	move.w	#98-1,d7
.ol
	REPT 20
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
	ENDR
	dbra	d7,.ol	

	move.l	screenpointer2,a1
	add.w	#32000,a1

	move.w	#4-1,d7
.xl
	REPT 20
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.xl	
	move.w	#-1,execDone
.quit
	rts




; copy execution logo by line
; using paneloff. determine number of lines to copy, and starting position
; we start using fixed position, 100
; then we take the paneloff
; so we have twice the paneloff for dbra

; panelOff = disance from mid
; 2*PanelOff = loop counter
; PanelOff <= 50
; offset into source = mid minus 160*loop

doExecutionByLine
	tst.w	nomore
	blt		.quit

	move.l	screenpointer2,a0
	lea		execution,a1

	move.w	#50,d0					; middle of source pic
	move.w	#100,d1					; middle of screen

	move.w	panelOff,d2				; paneloff
	cmp.w	#42,d2
	ble		.ok
		move.w	#42,d2
.ok
	move.w	d0,d3
	sub.w	d2,d0			; start
	add.w	d2,d3			; end

	move.w	d1,d4
	sub.w	d2,d1
	add.w	d2,d4

	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	d4,d7
	add.w	d4,d4
	add.w	d4,d4
	add.w	d7,d4

	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,d3
	move.w	d3,d7
	add.w	d3,d3
	add.w	d3,d3
	add.w	d7,d3

	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d7
	add.w	d0,d0
	add.w	d0,d0
	add.w	d7,d0

	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	d1,d7
	add.w	d1,d1
	add.w	d1,d1
	add.w	d7,d1

	move.l	a0,a2
	add.w	d1,a0		; top
	add.w	d4,a2		; bottom

	move.l	a1,a3
	add.w	d0,a1		; top
	add.w	d3,a3		; bottom

	cmp.w	#4,d2
	ble		.okx
		move.w	#4,d2
.okx
	move.w	d2,d6


.looptop
	REPT 20
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
	ENDR
	dbra	d2,.looptop

.loopbot
	REPT 20
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
	ENDR
	sub.w	#320,a3
	sub.w	#320,a2
	dbra	d6,.loopbot
.quit
	rts





panelOff	dc.w	0
movePanel
	tst.w	nomore
	blt		.quit

	cmp.w	#100,panelOff
	beq		.end
	bgt		.quit
;	lea		panel+34,a0
	move.l	panelBufferPointer,a0
	move.l	screenpointer2,a1
	move.w	#100-1,d7
	sub.w	panelOff,d7

	move.w	panelOff,d0
	lsl.w	#6,d0
;	muls	#64,d0

	add.w	d0,a0
.ol
	REPT 8
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	add.w	#160-64,a1
	dbra	d7,.ol

	rept 3
		moveq	#0,d1
		REPT 8
			move.l	d1,(a1)+
			move.l	d1,(a1)+
		ENDR
		add.w	#160-64,a1
	endr
	cmp.w	#40,panelOff
	ble		.kk
		REPT 8
			move.l	d1,(a1)+
			move.l	d1,(a1)+
		ENDR

.kk

	move.l	panelBufferPointer,a0
	add.w	#8*8*100,a0
	move.l	screenpointer2,a1
	add.w	#101*160,a1
	move.w	panelOff,d0
	muls	#160,d0
	add.w	d0,a1
	move.w	#100,d7
	sub.w	panelOff,d7

	sub.w	#320,a1
	rept 3
	REPT 8
		move.l	d1,(a1)+
		move.l	d1,(a1)+
	ENDR
	add.w	#160-64,a1
	endr

.ol2
	REPT 8
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	add.w	#160-64,a1
	dbra	d7,.ol2

	add.w	#1,panelOff
	cmp.w	#100,panelOff
	ble		.ll
		move.w	#101,panelOff
.ll
	rts
.end
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	moveq	#0,d0
	rept 4
		rept 8
			move.l	d0,(a0)+	
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		endr
		add.w	#160-64,a0	
		add.w	#160-64,a1
	endr 

	move.w	#-1,nomore
.quit
	rts


generateRasterValues
	lea		paldefs,a0
	lea		palvals,a1
	move.l	rasterListPointerSaved,a2
	move.w	#98-1,d7
	moveq	#0,d0
.ll
		REPT 16
			move.b	(a0)+,d0
			add.w	d0,d0
			move.w	(a1,d0.w),(a2)+
		ENDR
	dbra	d7,.ll

	move.l	rasterListPointerSaved,a0
	rept 16
		move.l	#0,-(a0)
	endr

	move.l	rasterListPointerSaved,a0
	add.w	#32*100,a0
	rept 16
		move.w	#0,(a0)+
	endr
	rts


nomore		dc.w	0
timer		dc.w	102
drawShit	dc.w	0


timerAWaiter	dc.w	100

copyPanel
	tst.w	timerAWaiter
	bgt		.skip

	move.l	screenpointer2,a0
	moveq	#0,d0
	move.w	#40,d7
.ol
	REPT 8
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	add.w	#160-8*8,a0
	dbra	d7,.ol

	move.l	screenpointer2,a1
	add.w	#29*160,a1

	lea		panel+34,a3
	move.w	#200-1,d7
.dl	
o set 0
		REPT 1
			movem.l	(a3)+,d0-d6/a4		; 8 regs
			movem.l	d0-d6/a4,(a1)

			movem.l	(a3)+,d0-d5
			movem.l	d0-d5,32(a1)
		ENDR
		add.l	#160,a1
		add.l	#160,a2
		add.l	#160-56,a3
	dbra	d7,.dl
.skip
	rts




timer_a_opentop_style
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
	REPT 42
		or.l	d7,d7
	ENDR

	clr.b	$ffff820a.w			;60 Hz
	REPT 9
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz
	rte


timer_b_openbot_style
	move.w	#$2100,sr
	stop	#$2100
    move.w  #$2700,sr

	movem.l	d0-d7/a0,-(sp)
 
        move.w  #$2700,sr
             clr.b   $fffffa1b.w                     ;Timer B control (stop)

        lea $ffff8209.w,a0          ;Hardsync						;8
        moveq   #127,d1												;4
.sync:      tst.b   (a0)											;8
        beq.s   .sync												;8
        move.b  (a0),d2												;8
        sub.b   d2,d1												;4
        lsr.l   d1,d1												;10

        REPT 35
        	nop
        ENDR
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz

    clr.b   $fffffa1b.w                     ;Timer B control (stop)
	move.l	sndh_pointer,a0
	jsr		8(a0)

    movem.l (sp)+,d0-d7/a0
    rte

;panelPalette	ds.b	32



panelPalette	
			
			dc.w 	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
			dc.w 	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$001,$111	;32
			dc.w 	$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$000,$100,$100,$101,$112,$222	;64
			dc.w 	$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$101,$200,$210,$212,$223,$333	;96
			dc.w 	$000,$000,$000,$000,$000,$000,$100,$101,$200,$300,$212,$310,$320,$323,$334,$444	;128
			dc.w 	$000,$000,$000,$100,$000,$001,$200,$212,$311,$410,$323,$421,$431,$434,$445,$555	;160
			dc.w 	$000,$000,$001,$201,$111,$112,$311,$323,$422,$521,$434,$532,$542,$545,$556,$666	;192
			dc.w 	$000,$111,$112,$312,$222,$223,$422,$434,$533,$632,$545,$643,$653,$656,$667,$777	;224

panelPaletteOff	dc.w	224
;;;;;;;;;;;;
; we have panel offset, we use this to schedule the timer, the offset into the rasterlist thing,
; and the number of lines
rasterBPosition	dc.w	0

fixTimerBPositionAndRasterShit
;	move.l	#rasterlistbuffer,a0
	move.l	rasterListPointerSaved,a0
	move.w	panelOff,d0
	beq		.end
	;0 = 100
	cmp.w	#51,d0
	ble		.okx
		move.w	#51,d0
.okx
	move.w	#97,d6
	sub.w	d0,d6
	move.w	d6,rasterBPosition
	move.w	#49,d1
	sub.w	d0,d1
;	blt		.tt

	add.w	d1,d1	;2
	add.w	d1,d1	;4
	add.w	d1,d1	;8
	add.w	d1,d1	;16
	add.w	d1,d1	;32

	add.w	d1,a0
	move.l	a0,rasterListPointer

	;numberOfRasterLines
	;now fix the counter
	move.w	panelOff,d0
	add.w	#1,d0
	add.w	d0,d0


	cmp.w	#100,d0
	ble		.ok2
		move.w	#100,d0
.ok2

.end
	move.w	d0,numberOfRasterLines
	rts

sceneWaiter	dc.w	200

rasterFader	dc.w	30

style_vbl
	pushall
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
			screenswap
	lea		panelPalette,a0
	add.w	panelPaletteOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240

	addq.w	#1,vblcounter

	move.w	#100,d0
	sub.w	panelOff,d0
	bgt		.ok
		move.w	#1,d0
.ok
	jsr		fixTimerBPositionAndRasterShit
	move.w	#100,timerbtimes

	clr.b	$fffffa1b.w				;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.w	rasterBPosition,d0
	move.b	d0,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_execution_raster,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	jsr		movePanel
	jsr		doExecutionByLine
	subq.w	#1,sceneWaiter
	bge		.xxx
		IFNE	STANDALONE
			move.w	#-1,nextScene
		ELSE
		ENDC
.xxx
		popall

	tst.w	nomore
	beq		.skip
		subq.w	#1,frametimer
		beq		.style_static_vbl
.skip
	rte
.style_static_vbl
	move.w	#2,frametimer
	move.w	#$2700,sr
	move.l	#style_noswap_vbl,$70
	move.l	screenpointer,$ffff8200
	move.w	#$2300,sr
	rte


style_noswap_vbl
	pushall
	addq.w	#1,$466.w
	move.l	screenpointer,$ffff8200
	move.w	#98,numberOfRasterLines
	move.l	rasterListPointerSaved,rasterListPointer
	addq.w	#1,vblcounter

	clr.b	$fffffa1b.w				;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#48,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_execution_raster,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	jsr	nextnextframe

	move.w	#$2700,sr
	move.l	#style_static_vbl,$70
	move.l	screenpointer2,$ffff8200
		
	move.w	#$2300,sr

	popall
	rte

doOnce	dc.w	0

style_static_vbl
	pushall

	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
			screenswap
	move.w	#98,numberOfRasterLines
	move.l	rasterListPointerSaved,rasterListPointer

	addq.w	#1,vblcounter
	lea		fadePal,a0
	add.w	fadePalOff,a0
	move.w	(a0),bgcol

	move.w	bgcol,$ffff8240

			schedule_timerA_topBorder
	move.l	#timer_a_opentop_style,$134.w
	clr.b	$fffffa1b.w				;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#48+29,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_execution_raster,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))


	jsr		changeBackDrop

	tst.w	doOnce
	bne		.skip
		jsr	nextnextframe
		move.w	#-1,doOnce
.skip
	
	subq.w	#1,herpwaiter
	bge		.skipadd
		move.w	#9,herpwaiter
		add.w	#32*101,rasterListOff
		cmp.w	#32*101*7,rasterListOff
		ble		.skipadd
			move.w	#32*101*7,rasterListOff
			move.w	#$2700,sr
			move.l	#style_borders_vbl,$70
			move.w	#$2300,sr
.skipadd

.noVBL
	popall
	rte

fadePalOff	dc.w	0
bgcol		dc.w	0
bgcolWaiter	dc.w	-1
					;0	1	2	 3		4 	5	6 		7	8	9	10	  11	12  13 	14    15
fadePal		dc.w	$0,$100,$101,$211,$212,$322,$323,$433,$434,$544,$545,$655,$656,$766,$767,$777

style_borders_vbl
	pushall
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
			screenswap

	move.l	#$7770777,d0
	lea		$ffff8240,a0
	REPT 8
		move.l	d0,(a0)+
	ENDR
bgcolcode
	move.w	#$777,$ffff8240
			schedule_timerA_topBorder
	move.l	#timer_a_opentop_style,$134.w
	clr.b	$fffffa1b.w				;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_openbot_style,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	jsr		doBGFade
	jsr		fillScreen
	jsr		clearScreen

	popall
	rte


styleTimer	dc.w	5
doBGFade
	subq.w	#1,styleTimer
	bgt		.skip
	lea		fadePal,a0
	add.w	fadePalOff,a0
	move.w	(a0),bgcolcode+2
	subq.w	#2,fadePalOff
	bge		.skip
		move.w	#0,fadePalOff
		move.w	#-1,nextScene

.skip
	rts


fillScreen
	rts
	move.l	screenpointer2,a0
	move.l	screenpointer,a1
	move.w	#274-1,d7
	move.w	#-1,d0
.il
o set 2
	REPT 20
		move.w	d0,o(a0)
		move.w	d0,o(a1)
o set o+8
	ENDR
	add.w	#160,a0
	add.w	#160,a1
	dbra	d7,.il
	move.w	#$4e75,fillScreen
	rts


clearScreen
	moveq	#0,d0
	move.l	screenpointer2,a0
	add.w	#89*160,a0
	add.w	#89*160,a1
	move.w	#90-1,d7

.ol
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.ol
	subq.w	#1,frametimer
	bne		.kk
	move.w	#$4e75,clearScreen
	move.w	#$4e71,fillScreen
.kk
	rts

herpwaiter	dc.w	40
frametimer	dc.w	2

backdropstep	dc.w	0
changeBackDrop									; this we need to edit
	tst.w	backdropstep
	blt		.level2
	move.l	rasterListPointerSaved,a0
	lea		101*32(a0),a1
	move.w	backdropstep,d0
	add.w	d0,d0	;2
	add.w	d0,d0	;4
	add.w	d0,d0	;8
	add.w	d0,d0	;16
	add.w	d0,d0	;32
	move.w	d0,d1
	move.l	a0,a1
	add.w	d0,a0
	move.w	#$0,d7

o set 0
	REPT 8
		move.w	d7,(a0)
		add.w	#32*101,a0
;o set o+32*101
	ENDR
	sub.w	d0,a1
o set 0
	REPT 9
		move.w	d7,o(a1)
		add.w	#32*101,a1
;o set o+32*101
	ENDR
	addq.w	#1,backdropstep
	cmp.w	#50,backdropstep
	ble		.ok

		move.w	#50,backdropstep
		move.w	#-1,backdropstep
.ok	
	rts
.level2
;	lea		rasterlistbuffer,a0
	move.l	rasterListPointerSaved,a0
;	move.w	bgcol,d0
	move.w	bgcol,d0

	move.w	#8-1,d7
.l
o set 0
	REPT 100
		move.w	d0,o(a0)
o set o+32
	ENDR
	add.w	#32*101,a0

	dbra	d7,.l


	subq.w	#1,bgcolWaiter
	bge		.okx
		move.w	#2,bgcolWaiter
		add.w	#2,fadePalOff
		cmp.w	#16*2,fadePalOff
		bne		.okx

			move.w	#15*2,fadePalOff
.okx

	rts






prepPanel
	move.l	panel2pointer,a0
	add.w	#34,a0
;	lea		panelBuffer,a1
	move.l	panelBufferPointer,a1
	move.w	#200-1,d7
.il
o set 0
		REPT 8
			move.l	o(a0),(a1)+
			move.l	o+4(a0),(a1)+
o set o+8
		ENDR
		add.w	#160,a0
	dbra	d7,.il	
	lea		panel+2,a0
	move.w	#0,(a0)
	rts

generateTheFadeShit
;	lea		rasterlistbuffer,a0
	move.l	rasterListPointerSaved,a0
	lea		101*32(a0),a6
	move.w	#101*7-1,d7

	move.w	(a0),d6

	move.w	#$700,a1
	move.w	#$070,a2
	move.w	#$007,a3
	move.w	#$010,a4
	move.w	#$100,a5

	move.w	#$700,d3
	move.w	#$070,d4
	move.w	#$007,d5
.loop
	lea		-101*32(a6),a0

	move.w	d6,(a0)
	add.w	#2,a0
	add.w	#2,a6
	REPT 15

	move.w	(a0)+,d0			; color in d0
	move.w	d0,d1
	move.w	d0,d2

	and.w	d3,d0		;r
	and.w	d4,d1		;g
	and.w	d5,d2		;b

	add.w	a5,d0
	cmp.w	a1,d0
	ble		*+4
		move.w	a1,d0
;.okr

	add.w	a4,d1
	cmp.w	a2,d1
	ble		*+4
		move.w	a2,d1
;.okg


	addq.w	#$001,d2
	cmp.w	a3,d2
	ble		*+4
		move.w	a3,d2
;.okb

	or.w	d2,d1
	or.w	d1,d0

	move.w	d0,(a6)+
	ENDR
	dbra	d7,.loop

	; now we add the great black bars
	move.w	#0,d0
	move.l	rasterListPointerSaved,a0
o set 2*32
	REPT 8
		move.w	d0,o(a0)
		move.w	d0,o+94*32(a0)
		move.w	#0,o+97*32(a0)
		move.w	#0,o+98*32(a0)
o set o+101*32
	ENDR


	rts

	SECTION DATA
palvals				incbin	"fx/style/exec.pal"			
execution			incbin	"fx/style/exec2.bin"			;15680/7111
	even

paldefs
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,87,89,92,15,94,90,86,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,87,89,92,15,94,90,86,$0,$0,$0,$0,$0,0
	dc.b	1,0,86,11,94,15,93,82,2,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,86,11,94,15,93,82,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,64,35,15,84,67,82,83,60,2,$0,$0,$0,$0,0
	dc.b	1,0,2,64,35,15,84,67,82,83,60,$0,$0,$0,$0,0
	dc.b	1,0,7,102,103,45,15,90,101,2,$0,$0,$0,$0,$0,0
	dc.b	1,0,7,102,103,45,15,90,2,101,$0,$0,$0,$0,$0,0
	dc.b	1,0,6,15,8,9,10,2,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,6,15,8,9,10,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,10,9,8,7,6,5,14,11,12,2,$0,$0,$0,0
	dc.b	1,0,2,10,9,8,7,6,5,14,11,12,$0,$0,$0,0
	dc.b	1,0,6,11,15,14,8,2,4,7,9,$0,$0,$0,$0,0
	dc.b	1,0,6,11,15,14,8,4,7,9,$0,$0,$0,$0,$0,0
	dc.b	1,0,5,14,13,10,6,11,12,9,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,5,14,13,10,6,11,12,9,$0,$0,$0,$0,0
	dc.b	1,0,13,14,9,10,12,11,7,8,15,2,$0,$0,$0,0
	dc.b	1,0,13,14,9,10,12,11,7,2,8,15,$0,$0,$0,0
	dc.b	1,0,2,6,14,10,12,9,15,11,13,7,8,$0,$0,0
	dc.b	1,0,2,6,14,10,12,9,15,11,13,7,8,$0,$0,0
	dc.b	1,0,16,22,21,20,18,17,2,15,14,23,19,24,$0,0
	dc.b	1,0,16,22,21,20,18,17,2,15,14,23,19,24,$0,0
	dc.b	1,0,2,12,14,15,13,8,7,4,3,5,6,9,11,10
	dc.b	1,0,12,14,15,13,8,2,7,4,3,5,6,9,11,10
	dc.b	1,0,32,15,36,33,34,35,30,31,27,29,25,28,2,26
	dc.b	1,0,32,15,36,33,34,35,2,30,31,27,29,25,28,26
	dc.b	1,0,13,15,11,6,8,10,9,12,7,14,2,4,5,0
	dc.b	1,0,13,15,11,6,8,10,9,12,7,2,14,4,5,0
	dc.b	1,0,46,15,44,43,31,41,2,37,39,40,18,42,45,38
	dc.b	1,0,46,15,44,43,31,41,37,39,40,18,42,45,2,38
	dc.b	1,0,52,13,50,19,49,25,15,48,32,39,51,2,47,0
	dc.b	1,0,2,52,13,50,19,49,25,15,48,32,39,51,47,0
	dc.b	1,0,4,14,9,8,7,6,2,15,11,12,5,13,10,0
	dc.b	1,0,4,14,9,8,7,6,2,15,11,12,5,13,10,0
	dc.b	1,0,59,15,58,57,53,37,55,60,61,56,21,54,2,0
	dc.b	1,0,59,15,58,57,53,37,55,60,2,61,56,21,54,0
	dc.b	1,0,49,15,44,67,64,16,63,2,59,66,62,68,65,25
	dc.b	1,0,49,15,44,67,64,16,63,59,66,62,68,65,2,25
	dc.b	1,0,2,12,15,13,9,11,6,8,10,14,7,4,5,0
	dc.b	1,0,12,15,13,9,11,2,6,8,10,14,7,4,5,0
	dc.b	1,0,2,68,15,74,73,28,72,33,8,70,71,5,69,75
	dc.b	1,0,68,15,74,73,28,2,72,33,8,70,71,5,69,75
	dc.b	1,0,2,79,80,40,72,24,15,31,77,81,61,78,76,0
	dc.b	1,0,79,80,40,72,24,15,31,77,2,81,61,78,76,0
	dc.b	1,0,2,4,7,5,6,9,8,10,12,14,15,13,11,3
	dc.b	1,0,4,7,5,6,9,8,10,12,14,15,13,11,3,2
	dc.b	1,0,2,85,88,11,91,89,90,94,82,92,93,86,15,87
	dc.b	1,0,85,88,11,91,89,90,94,82,92,93,86,15,2,87
	dc.b	1,0,2,12,10,11,13,9,8,5,6,4,7,15,14,0
	dc.b	1,0,12,10,11,13,9,8,5,6,4,7,15,14,2,0
	dc.b	1,0,2,5,8,7,9,10,12,11,3,6,13,15,14,4
	dc.b	1,0,5,8,7,9,10,12,11,2,3,6,13,15,14,4
	dc.b	1,0,2,3,4,6,11,14,9,7,12,13,10,15,8,5
	dc.b	1,0,3,4,6,11,14,9,7,12,13,2,10,15,8,5
	dc.b	1,0,2,8,10,11,13,12,15,14,6,9,5,7,$0,0
	dc.b	1,0,8,10,11,13,2,12,15,14,6,9,5,7,$0,0
	dc.b	1,0,2,7,9,10,11,15,13,8,12,5,6,14,4,0
	dc.b	1,0,7,9,10,11,15,13,8,12,2,5,6,14,4,0
	dc.b	1,0,2,7,8,10,12,14,9,3,4,11,15,5,6,0
	dc.b	1,0,7,8,10,12,14,9,3,4,11,2,15,5,6,0
	dc.b	1,0,2,56,90,60,4,7,101,15,104,103,$0,$0,$0,0
	dc.b	1,0,56,90,60,4,7,101,15,104,103,$0,$0,$0,$0,0
	dc.b	1,0,2,7,102,103,60,90,15,101,104,$0,$0,$0,$0,0
	dc.b	1,0,7,102,103,60,90,15,101,104,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,7,101,4,56,102,60,45,$0,$0,$0,$0,$0,0
	dc.b	1,0,7,101,4,56,102,2,60,45,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,76,15,73,9,98,97,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,76,15,73,9,98,97,2,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,95,46,100,73,99,79,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,95,46,100,73,99,79,2,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,76,79,96,99,73,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,76,79,96,99,73,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0
	dc.b	1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,0

	IFEQ STANDALONE
panel	incbin	gfx/panel.pi1
pal			dc.w	$000,$100,$200,$300,$400,$500,$600,$700,$720,$740,$760,$770,$772,$774,$776,$777		;12				; second
	ENDC
execDone	dc.w	0


	IFEQ STANDALONE
alignpointer1				dc.l	block1
alignpointer2				dc.l	block2
alignpointer3				dc.l	block3
alignpointer4				dc.l	block3
alignpointer5				dc.l	block3


	include		lib.s
	include		

	IFNE	loadmusic
music
	incbin		stnews.snd
	ENDC
	ENDC

	SECTION BSS
; general stuff
	IFEQ	STANDALONE
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
block1:						ds.b	65536
block2:						ds.b	65536
block3:						ds.b	65536
nextScene					ds.b	4
vblcounter	ds.w	1
haxSpace					ds.b	70000

	ELSE

	ENDC


panelBufferPointer					ds.l	1	
rasterListPointer					ds.l	1	
rasterlistbufferPointer				ds.l	1
rasterListPointerSaved				ds.l	1

