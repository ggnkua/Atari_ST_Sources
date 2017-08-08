; write the buffers as pointers
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



gentableEntrySize	equ	100

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
	add.l	#$10000,d0
	move.l	d0,alignpointer7
	add.l	#$10000,d0
	IFEQ loadmusic
		jsr	loadMusic
		tst.w	fail
		bne		.exit
	ENDC	


	jsr		init_greetings




.mainloop

;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines





	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		.mainloop										;

	
.exit
	move.b	#0,$ffffc123
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

music_cheat
	rept 20
		nop
	endr
	rts

	ENDC

greetings_preCalc
	jsr		init_greetings_pointers

	jsr 	generateStartX			
	jsr 	generateEndX		
	jsr		generateHDrawTable1bpl
	jsr		init_yblock_aligned_greetings

	lea		clearScreenDefs,a1
	move.l	clearScreenbuffer1Pointer,a0
	jsr		generateClearScreenAlt

	lea		clearScreenDefs2,a1
	move.l	clearScreenbuffer2Pointer,a0
	jsr		generateClearScreenAlt

	lea		clearScreenDefs3,a1
	move.l	clearScreenbuffer3Pointer,a0
	jsr		generateClearScreenAlt

	; this needs to go						; OH GEEZ AND ITS THE FINAL, AND IT DIDNT GO ;.....
	lea		frames_packed,a0
	move.l	savedListPointer,a1
	jsr		d_lz77

	lea		intro_packed,a0
	lea		intro,a1
	jsr		d_lz77

	move.l	#intro,listPointer
	move.l	#offsets2,offsetPointer


	move.w	#$4e75,greetings_preCalc
	rts

init_greetings
	jsr		greetings_preCalc
	jsr		music_ym_init

	wait_for_vbl

	IFEQ STANDALONE
	move.l	#music_cheat,sndh_pointer
	move.l	sndh_pointer,a0
	jsr		(a0)
	ENDC


	;;;;;;; here we need to init the scaling

	move.l	savedscreenpointer2,screenpointer2
	move.l	savedscreenpointer,screenpointer

	move.w	#$2700,sr
	move.l	#greetings_vbl,$70
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.l	#timer_a_opentop_greetings,$134.w			;Install our own Timer A
	move.l	#timer_b_openbottom_greetings,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.l	#229*160,a0
	add.l	#229*160,a1
	move.l	#-1,d0
	move.w	#0,d0
	swap	d0
	moveq	#0,d1
	move.w	#44-1,d7

.ol
	add.w	#8*8,a0
	add.w	#8*8,a1
	REPT 12
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d0,(a1)+
		move.l	d1,(a1)+
	ENDR
	dbra	d7,.ol
	move.w	#3-1,d7
.ol2
	REPT 20
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		move.l	d1,(a1)+
	ENDR
	dbra	d7,.ol2

	move.w	#0,$466.w
	move.w	#0,nextScene
.x

	IFNE STANDALONE
		jsr		doTwoMore
		move.w	#$4e75,doTwoMore
		move.l	alignpointer8,divtablepointer					; 2 big
 		jsr		initDivTable
		move.l	alignpointer9,rotation_perspectivePointer
		jsr		initZTable
		move.l	alignpointer10,lowerMemStore
		jsr		copyAndClearLowerMem

		tst.w	generateNew
		bge		.skipGenerate
			jsr		doMore
			move.w	#$4e75,doMore
.skipGenerate


	ENDC
			exitOnSpace
	tst.w	nextScene
	beq		.x

	move.w	#0,nextScene
	move.w	#$2700,sr
	move.l	#greetings_transition_vbl,$70
	move.w	#$2300,sr

.xx
			exitOnSpace
	tst.w	nextScene
	beq		.xx
	moveq	#0,d0
	move.w	$466,d0
	rts




greetings_transition_vbl
	pushall
	addq.w	#1,$466.w
			schedule_timerA_topBorder
		move.w	#7,timerbtimes
    clr.b   $fffffa1b.w         ;Timer B control (stop)
;	move.l	#timer_a_opentop_greetings,$134.w			;Install our own Timer A
	move.l	#timer_b_colorlist,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #32,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

	jsr		doColors
	move.l	sndh_pointer,a0
	jsr		8(a0)

	subq.w	#1,framesttt
	bge		.lll
		move.w	#-1,nextScene
.lll	

	popall
	rte

transitionColorListOffsetSource	dc.w	29*2
transitionColorListOffset		dc.w	0
transitionColorListPointer		dc.l	0

							dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000
									;0		1	2	3	4		5	6	7	8
transitionColorList			dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000
                            dc.w    $100,$200,$300,$401,$501,$510,$520,$620,$630    
                            dc.w    $730,$740,$750,$760,$770,$771,$772,$773,$774    
                            dc.w    $775,$776,$777,$777,$777,$777,$777,$777,$777    
                            dc.w    $777,$777,$777,$777,$777,$777,$777,$777,$777




transitionColorListWaiter	dc.w	4
doColors
	; reset list
	move.w	transitionColorListOffsetSource,transitionColorListOffset
	; load first value
	lea		transitionColorList,a0
	add.w	transitionColorListOffset,a0
	move.w	(a0)+,d0
	move.l	a0,transitionColorListPointer
	; set colors and shit
	lea		$ffff8240,a0
	rept 16
		move.w	d0,(a0)+
	endr
	subq.w	#1,transitionColorListWaiter
	bge		.kk
		move.w	#2,transitionColorListWaiter
		sub.w	#2,transitionColorListOffsetSource
		bge		.kk
			move.w	#0,transitionColorListOffsetSource
.kk
	rts


framesttt	dc.w	93

;timerbtimes	dc.w	0

timer_b_colorlist
	pusha0
	pusha1
	move.l	transitionColorListPointer,a0
	move.w	(a0)+,d0
	lea		$ffff8240,a1
	rept 16
		move.w	d0,(a1)+
	endr
	subq.w	#1,timerbtimes
	blt		.kk
	move.l	a0,transitionColorListPointer
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.l	#timer_b_colorlist,$120
    move.b  #32,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte
.kk
	clr.b	$fffffa1b.w				;Timer B control (stop)
	popa1
	popa0
	rte	

timer_a_opentop_greetings
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

generateNew		dc.w	1

timer_b_openbottom_greetings
	move.w	#$2100,sr
	stop	#$2100
    move.w  #$2700,sr
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


        REPT 35
        	nop
        ENDR
;        move.w	#$7,$ffff8240
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz

    clr.b   $fffffa1b.w                     ;Timer B control (stop)
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#$ff,d0
	bne		.noz
		move.w	#-1,nextScene
		move.b	#0,$b8(a0)
.noz
	cmp.b	#$66,d0
	bne		.noz2
		move.w	#-1,nextScene
		move.b	#0,$b8(a0)
		jmp		.mym
		movem.l (sp)+,d0-d7/a0
 		rte

.noz2
	tst.w	nextScene
	bne		.ym
.mym
	jsr		8(a0)
	jmp		.cont
.ym	
	jsr		music_ym_play
.cont
    movem.l (sp)+,d0-d7/a0

    rte

;1000		= 0.5	8
;1100		= 0.75	B
;1010		= 0.625 A

fraction	dc.l	$A2000000
total		dc.l	0


frameCounter	dc.w	0

greetings_vbl
	pushall
	addq.w	#1,$466.w
			schedule_timerA_topBorder

    clr.b   $fffffa1b.w         ;Timer B control (stop)
;	move.l	#timer_a_opentop_greetings,$134.w			;Install our own Timer A
	move.l	#timer_b_openbottom_greetings,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.w	#0,$ffff8240

squarecolor
	move.w	#squarestartcolor,$ffff8246
	jsr		doSquareFade
	jsr		doBackGroundOutFade
	jsr		doFadeGreetings
	move.l	screenpointer,$ffff8200
	jsr		clearRout
	jsr		checkMusicForGreetings
	jsr		doSquareEffect
	jsr		doGreetings
			screenswap

	popall
	rte

doBackGroundOutFade
	subq.w	#1,idontcareanymorewaiter
	bge		.end
		subq.w	#1,dontcareWaiter
		bge		.end
			move.w	#5,dontcareWaiter
			sub.w	#2,dontcareoff
			bge		.end
				move.w	#0,dontcareoff

.end
			lea		dontcareList,a0
			add.w	dontcareoff,a0
			move.w	(a0)+,$ffff8240

	rts

dontcareWaiter	dc.w	5
dontcareoff	dc.w	16
dontcareList
	dc.w	$777
	dc.w	$666
	dc.w	$555
	dc.w	$444
	dc.w	$333
	dc.w	$222
	dc.w	$111
	dc.w	$000
	dc.w	$000
	dc.w	$000

squareFadeWaitDuration	equ	170	
squareFadesSelect	dc.w	-22
squareFadesOff		dc.w	0

; initial start color
squarestartcolor	equ $334
; this is the initial tab; 
; first entry = faded out, last entry = visible
;	a. font on white background fade
;	b. font on square fade
fadeTab
	;		a	 b
	dc.w	$777,squarestartcolor
	dc.w	$666,$334
	dc.w	$555,$223
	dc.w	$444,$223
	dc.w	$333,$112
	dc.w	$222,$112
	dc.w	$111,$001
	dc.w	$000,$000



;

; these are the transition fades for the subsequent table values
; 
; fades for the square; 5 entries
;						;0		1	2	3	4	5	6		7	8		9	10
squareFades	


; first
	dc.w $334,$344,$343,$342,$342,$452,$451,$451,$450,$450
	dc.w $450,$451,$551,$551,$552,$552,$652,$652,$653,$653
	dc.w $653,$653,$554,$554,$454,$455,$455,$356,$356,$356
;	dc.w $356,$355,$454,$453,$463,$562,$662,$661,$761,$760
;	dc.w $760,$770,$771,$772,$773,$774,$775,$776,$777,$777
	dc.w $356,$355,$354,$454,$453,$452,$451,$551,$551,$550
	dc.w $550,$551,$552,$553,$663,$664,$665,$775,$776,$777

	dc.w $777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w $777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w $777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777




; fade for the font, from square color (start), to font color (end); 5 entries
fadeTabColors		;dc.w	$700,$600,$500,$400,$300,$200,$100,$000
						dc.w	$707,$700,$007,$007,$007,$007,$007,$007 
;					dc.w	$205,$204,$104,$103,$003,$002,$001,$000
						dc.w	$700,$070,$070,$070,$070,$070,$070,$070
;					dc.w	$643,$543,$432,$321,$211,$210,$100,$000
						dc.w	$551,$451,$451,$451,$441,$441,$441,$341
;					dc.w	$047,$036,$025,$014,$003,$002,$001,$000
						dc.w	$752,$652,$652,$653,$653,$643,$643,$544
;					dc.w	$770,$660,$550,$440,$330,$220,$110,$000
						dc.w	$777,$656,$656,$656,$545,$545,$434,$450 
; fade for the font color to the background color (no overlap square)

fadeTabBackColors	
					dc.w	$777,$666,$555,$444,$333,$222,$111,$000
					dc.w	$777,$666,$555,$444,$333,$222,$111,$000
					dc.w	$777,$666,$555,$444,$333,$222,$111,$000
					dc.w	$777,$666,$555,$444,$333,$222,$111,$000
					dc.w	$777,$666,$555,$444,$333,$222,$111,$000



squareFadeWaiter	dc.w	3
					ds.b	2
squareFadeActive	dc.w	0
					ds.b	2
fadeTabSelect		dc.w	0
					ds.b	2

; this thing fades the square
;	- active/not active
;	- if active, count timer
;	- if timer is gone, do fade
;		- 2 types of fade
;			- fade select	\__ both set by active setter
;			- fade step		/


doSquareFade
	tst.w	squareFadeActive																		;4
	beq		.end																					;12 taken
		subq.w	#1,squareFadeWaiter		; we only do stuff if our timer is done
		bge		.end
			move.w	#2,squareFadeWaiter
			lea		squareFades,a0
			add.w	squareFadesSelect,a0
			add.w	squareFadesOff,a0
;			move.b	#0,$ffffc123
			move.w	(a0),squarecolor+2
			add.w	#2,squareFadesOff
			cmp.w	#22,squareFadesOff
			bne		.end
				move.w	#20,squareFadesOff
				move.w	#0,squareFadeActive
				lea		fadeTabColors,a0
;				lea		fadeTabBackColors,a2
				add.w	fadeTabSelect,a0
;				add.w	fadeTabSelect,a2
				lea		fadeTab,a1
o set 2
				REPT 8
;					move.w (a2)+,(a1)+
;					move.w (a0)+,o(a1)
o set o+2
				ENDR
				add.w	#16,fadeTabSelect
.end
	rts																								;4

greetingsCounter	dc.w	5
greetingsLastTimeCounter	dc.w	5

checkMusicForGreetings
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.w	#$a,d0
	bne		.ok
		move.b	#0,$b8(a0)
		move.w	#47,greetingFrames				; greetings animation

		move.w	#-1,greetingsActive				; activate greetings
		add.w	#16,fadeTabSelect
		move.w	#-1,squareFadeActive
		subq.w	#1,greetingsLastTimeCounter
		beq		.lastTimer
.normalTimer
		move.w	#squareFadeWaitDuration,squareFadeWaiter			; plan the fade!
		jmp		.timerDone
.lastTimer
		move.w	#200,squareFadeWaiter
		move.w	#230,idontcareanymorewaiter
.timerDone
		move.w	#0,squareFadesOff
		add.w	#22,squareFadesSelect

		subq.w	#1,greetingsCounter
		bne		.noReset
			move.l	#0,greetingsOff
.noReset

		subq.w	#1,generateNew
.ok
	rts

idontcareanymorewaiter	dc.w	31000
greetingsActive		dc.w	0
greetingsOff		dc.l	0
greetingFrames		dc.w	48

doGreetings
	tst.w	greetingsActive
	bge		.skip
	move.l	screenpointer,a0
	move.l	planarpicbsspointer,a1
	add.l	greetingsOff,a1
	add.w	#111*160,a0
	move.w	#50-1,d7
.cp
o set 32+4
	REPT 12
		move.w	(a1)+,o(a0)
o set o+8
	ENDR
	add.w	#160,a0
	dbra	d7,.cp
.skip
	rts

;frame_select	dc.w	11


frame_select	dc.w	21
debugframes		dc.w	32
numer_of_cycles	dc.w	39
clearRout
	lea		clearList,a0
	add.w	frameCounter,a0
	move.l	(a0),a0
	jsr		(a0)
	rts

doSquareEffect
	move.l	listPointer,a5				; current pointer into the data
	move.l	offsetPointer,a6			; current offset list for loop variables for each frame
	move.w	(a6)+,d0					; have we reached the end?
	bge		.ok							; if we havent, dont reset
		move.l	#offsets,a6					; reset
		move.l	savedListPointer,a5			; 
		move.w	(a6)+,d0
		move.w	#0,frameCounter

		subq.w	#1,numer_of_cycles			; if we have looped, is it time to quit?
		bge		.ok
			move.w	#-1,nextScene
.ok
	subq.w	#1,d0						; -1 for dbra
	lea		.return(pc),a3
.loop
	pushd0	
		jmp	drawEdgeList
.return
	popd0	
	dbra	d0,.loop

	move.l	fraction,d0					; do the fraction thing, for framerate throttle
	add.l	d0,total					; 
	bcc		.skipsave					; do we have overflow?

	add.w	#4,frameCounter				; if we have overflow, we increase framecounter
	; 
	tst.w	greetingsActive				; is greetings active?
	bge		.notActive

		subq.w	#1,greetingFrames			; one less greeting frame
		beq		.continue		
		blt		.setGreetingsInactive
			add.l	#1200,greetingsOff			; increase greetings frame
			jmp		.continue
.setGreetingsInactive
			add.l	#1200,greetingsOff			; increase greetings frame
			move.w	#0,greetingsActive
.continue
.notActive

	move.l	a6,offsetPointer
	move.l	a5,listPointer
	jmp		.skipsave
.skipsave

.skipeffect
	rts

init_yblock_aligned_greetings
	move.l	y_block_pointer_greetings,a1
	move.l	#290-1,d7
	moveq	#0,d0
	move.l	#160,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop
	rts



drawEdgeList
	moveq	#-4,d5						;4								; xxxxx00 mask
	move.l	y_block_pointer_greetings,a1			;20		; smc = -8				; y off pointer
	move.w	(a5)+,d0					;8								; determine y_off from screen
	add.w	d0,d0						;4
	add.w	d0,d0						;4
	add.w	d0,a1
	move.l	screenpointer,a0			;20		; smc = -8
	add.l	(a1),a0						;16								; screen + y off
	move.l	x_start_pointer_1bpl,d0		;20		; smc = -8				; start mask
	move.l	x_end_pointer_1bpl,d1		;20		; smc = -8				; end mask
	move.l	drawTablePointer1bpl,d2		;20		; smc = -8				; generated loopcode
	moveq	#-1,d3						;4								; full 16 pixel segment
	move.w	(a5)+,d4					;8								; number of lines
	subq.w	#1,d4						;8								; used for dbra
	move.l	d2,a4						;4								; 
	jmp		(a4)	


init_greetings_pointers
	IFNE STANDALONE
	move.l	h1,screenpointer
	move.l	h2,screenpointer2
	ENDC

	move.l	alignpointer1,d0
	move.l	d0,x_start_pointer_1bpl				;1280
	add.l	#1280,d0
	move.l	d0,y_block_pointer_greetings					;1096
	add.l	#274*4,d0
	move.l	d0,clearScreenbuffer1Pointer					;13698
	add.l	#13698,d0
	move.l	d0,clearScreenbuffer2Pointer					;16302
	add.l	#16302,d0
	move.l	d0,clearScreenbuffer3Pointer					;18234
	add.l	#18234,d0							;	----> 50610

	move.l	alignpointer2,drawTablePointer1bpl
	move.l	alignpointer3,d0
	move.l	d0,x_end_pointer_1bpl	;1280
	add.l	#1280,d0
	move.l	d0,listPointer			;
	move.l	d0,savedListPointer
	add.l	#64492,d0
	move.l	d0,planarpicbsspointer				; 

	IFEQ	STANDALONE
		move.l	#greetings3,planarpicbsspointer
	ENDC
	; so alignpointer 4 is tainted.... by a few bytes
	; so a little under 7*64kb free
	rts

;29 kb of data
; idea -> divide into 20 settings, each has an offset and a number
; 20*47*2 => 1880

clearList
	REPT 17
		dc.l	funStuff2	;clearScreen1bpl_a
	ENDR
	REPT 17
		dc.l	funStuff3
	ENDR
	REPT 16
		dc.l	funStuff
	ENDR

clearScreenDefs						;c	; 13698
	dc.b	40,0,0,7,13,-1
	dc.b	20,0,0,9,11,-1
	dc.b	140,0,0,15,5,-1
	dc.b	20,0,0,14,6,-1
	dc.b	53,0,0,11,9,-1
	dc.b	-1
	even

clearScreenDefs2					;a
	dc.b	24,0,11,7,2,-1		;24
	dc.b	19,0,6,14,0,-1		;43
	dc.b	19,0,4,16,0,-1		;62
	dc.b	60,0,0,20,0,-1		;122
	dc.b	10,0,1,18,1,-1		;132
	dc.b	35,0,2,17,1,-1		;
	dc.b	33,0,3,17,0,-1
	dc.b	2,0,3,17,0,-1
	dc.b	33,0,4,14,2,-1
	dc.b	38,0,5,8,7,-1
	dc.b	-1
	even

clearScreenDefs3
	dc.b	8,0,17,3,0,-1				;8
	dc.b	12,-1,2,6,9,3,-1			;20
	dc.b	20,-1,2,8,6,4,-1			;40
	dc.b	20,-1,1,9,5,5,-1			;60
	dc.b	20,-1,1,10,4,5,-1			;80
	dc.b	25,-1,0,13,3,4,-1			;105
	dc.b	30,-1,0,15,1,4,-1			;135
	dc.b	65,0,0,20,0,-1				;200	
	dc.b	20,0,0,20,0,-1				;220
	dc.b	10,0,1,19,0,-1				;230
	dc.b	15,0,2,18,0,-1				;245
	dc.b	10,0,3,17,0,-1				;255
	dc.b	10,0,4,16,0,-1				;265
	dc.b	8,0,5,15,0,-1					;273
	dc.b	-1
	even

funStuff3
	moveq	#0,d0
	move.l	screenpointer,a0
	move.l	clearScreenbuffer3Pointer,a1
	jmp		(a1)

funStuff2
	moveq	#0,d0
	move.l	screenpointer,a0
	move.l	clearScreenbuffer2Pointer,a1
	jmp		(a1)


funStuff
	moveq	#0,d0
	move.l	screenpointer,a0
	move.l	clearScreenbuffer1Pointer,a1
	jmp		(a1)



generateClearScreenAlt
	move.l	a0,a2
	move.l	#$31400000,d0
	moveq	#0,d1
	move.w	#200,d2
.doBlock
	move.w	d1,d0
	moveq	#0,d7
	move.b	(a1)+,d7
	cmp.b	#-1,d7
	beq		.end
.doInnerBlock
		subq.w	#1,d7
		moveq	#0,d6
		moveq	#0,d5
		moveq	#0,d4

		move.b	(a1)+,d6				; determine the initial offset
		blt		.alt
		move.b	(a1)+,d6
		lsl.w	#3,d6					;*8
		move.b	(a1)+,d5				; number of iterations
		subq.w	#1,d5
		move.b	(a1)+,d4				; number of after offsets
		lsl.w	#3,d4
.ol
			move.w	d5,d3
			add.w	d6,d0
.il
				move.l	d0,(a0)+
				addq.w	#8,d0
			dbra	d3,.il
			add.w	d4,d0
			add.w	#160,d1
			subq.w	#1,d2
			beq		.fixshit
.fixedshit
	dbra	d7,.ol
	moveq	#0,d7
	move.b	(a1)+,d7
	blt		.doBlock
		illegal
.end
	move.w	.l,(a0)+
.l	rts	

.fixshit
	moveq	#0,d1		; because we reset the stuff
	move.l	#$41E87D00,(a0)+
	jmp		.fixedshit


.alt
		move.b	(a1)+,d6
		lsl.w	#3,d6					;*8
		move.w	d6,a2
		move.b	(a1)+,d5				; number of iterations
		subq.w	#1,d5
		move.b	(a1)+,d4				; number of after offsets
		lsl.w	#3,d4
		move.w	d4,a3
		moveq	#0,d6
		move.b	(a1)+,d6
		subq.w	#1,d6					; number of 2nd iterations
		move.w	d6,a4
.ol2
			move.w	d5,d3
			move.w	a4,d6
			add.w	a2,d0
.il2
				move.l	d0,(a0)+
				addq.w	#8,d0
			dbra	d3,.il2

			add.w	a3,d0
.il3
				move.l	d0,(a0)+
				addq.w	#8,d0
			dbra	d6,.il3

			add.w	#160,d1
			subq.w	#1,d2
			beq		.fixshit
	dbra	d7,.ol2
	moveq	#0,d7
	move.b	(a1)+,d7
	blt		.doBlock



;clearScreen1bpl_b
;	moveq	#0,d0
;	move.l	screenpointer,a0
;
;;22..41	
;o set 0
;
;	REPT 8
;o set o+8*17
;		REPT 3
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 12
;o set o+8*2
;		REPT 6
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*9
;		REPT 3
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 20
;o set o+8*2
;		REPT 8
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*6
;		REPT 4
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;
;	REPT 20
;o set o+8*1
;		REPT 9
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*5
;		REPT 5
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;
;	REPT 20
;o set o+8*1
;		REPT 10
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*4
;		REPT 5
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;
;	REPT 25
;		REPT 13
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*3
;		REPT 4
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 30
;		REPT 15
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*1
;		REPT 4
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 65
;		REPT 20
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;	add.w	#200*160,a0
;o set 0
;
;	REPT 20
;		REPT 20
;			move.w	d0,o(a0)				
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 10							;
;o set o+8
;		REPT 19
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 15							;
;o set o+8*2
;		REPT 18
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 10							;
;o set o+8*3
;		REPT 17
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 10							;
;o set o+8*4
;		REPT 16
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 8							;
;o set o+8*5
;	REPT 15
;		move.w	d0,o(a0)
;o set o+8
;	ENDR
;	ENDR
;
;	rts
;
;
;
;
;
;
;clearScreen1bpl_c
;	moveq	#0,d0
;	move.l	screenpointer,a0
;o set 0
;	REPT 40
;		REPT 7
;			move.w	d0,o(a0)			;3140 0008
;o set o+8
;		ENDR
;o set o+8*13
;	ENDR
;
;	REPT 20
;		REPT 9
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*11
;	ENDR
;
;	REPT 140
;		REPT 15
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*5
;	ENDR
;	add.w	#160*200,a0
;
;o set 0
;	REPT 20
;		REPT 14
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*6
;	ENDR
;
;	REPT 53
;		REPT 11
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*9
;	ENDR
;
;	rts
;
;
;
;
;
;
;clearScreen1bpl_a
;	moveq	#0,d0
;	move.l	screenpointer,a0
;
;; frames 0..21
;o set 0
;	REPT 24
;o set o+11*8
;		REPT 7
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+16
;	ENDR
;
;
;	REPT 19
;o set o+6*8
;		REPT 14
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;
;	REPT 19
;o set o+4*8
;		REPT 16
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 60
;		REPT 20
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 10
;o set o+8
;		REPT 18
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8
;	ENDR
;
;	add.w	#(70+38+24)*160,a0
;o set 0
;	REPT 35
;o set o+2*8
;		REPT 17
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8
;	ENDR
;
;	REPT 35
;o set o+3*8
;		REPT 17
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;	ENDR
;
;	REPT 33
;o set o+4*8
;		REPT 14
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*2
;	ENDR
;
;	REPT 38
;o set o+5*8
;		REPT 8
;			move.w	d0,o(a0)
;o set o+8
;		ENDR
;o set o+8*7
;	ENDR
;
;
;	rts






;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines

lalaCode
	jmp		$123456
fixCode
	rts
	move.l	drawTablePointer1bpl,d0
	move.l	d0,lalaCode+2

	add.l	#$10000,d0
	move.l	d0,a0
	lea		lalaCode,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	rts


generateStartX
	move.l	x_start_pointer_1bpl,a0
	move.l	#20-1,d7

	move.l	#gentableEntrySize,d0 		; val

.ol
	moveq	#16-1,d6	; do 16 il
	moveq	#-1,d1		; %1111111111111111
.il
		move.w	d0,(a0)+	; val,
		move.w	d1,(a0)+	; mask

		lsr.w	#1,d1
	dbra	d6,.il
	add.w	#gentableEntrySize*20,d0
	dbra	d7,.ol

	; 20*16*4 = 1280
	rts

generateEndX
	move.l	x_end_pointer_1bpl,a0

	move.l	#20-1,d7

	moveq	#0,d0
.ol
	moveq	#16-1,d6
	move.w	#%1000000000000000,d1
.il
		move.w	d0,(a0)+
		move.w	d1,(a0)+

		asr.w	#1,d1
	dbra	d6,.il
	add.w	#gentableEntrySize,d0
	dbra	d7,.ol
	rts


drawLineInitTemplate
	move.w	(a5)+,d0					;8				;2		; get x_start
	move.w	(a5)+,d1					;8				;2		; get x_end
;	and.w	d5,d0						;4				;2		; zero out lower 2 bits
;	and.w	d5,d1						;4				;2		; zero out lower 2 bits
	move.l	d0,a1						;4				;2		; get address of xstart table
	move.l	d1,a2						;4				;2		; get address of xend table
	move.w	(a1)+,d2					;8				;2		; get offset xstart
	add.w	(a2)+,d2					;8				;2		; add offset xend
	move.w	(a1)+,d0					;8				;2		; get mask xstart
	move.w	(a2)+,d1					;8				;2		; get mask xend
	move.l	d2,a1						;4				;2		; use gotten offset for drawroutine
	jmp		(a1)						;8				;2		; jump to draw routine						;--> 24

generateHDrawTable1bpl
	move.l	drawTablePointer1bpl,a0
	lea		lalaCode+2,a2
	move.l	a0,(a2)


	move.l	drawTablePointer1bpl,a0			;40018
	move.l	a0,a5
	sub.l	#2,a5
	moveq	#0,d0					;$xbase=0
	moveq	#0,d1					;$xval
	moveq	#20,d2					;condition
	move.w	#$3143,d3
	move.w	#$8368,d4				

	lea		drawLineInitTemplate,a6
	REPT 5
		move.l	(a6)+,(a0)+
	ENDR

	move.l	drawTablePointer1bpl,a0
	add.w	#gentableEntrySize,a0


	moveq	#0,d7					;$x=0
.loop_x								;for($x=0;$x<20;$x++)-----------------------------------------------\
		move.w	d0,d1				;$xval = $xbase														|
		moveq	#0,d6				;$y=0																|
.loop_y								;for($y=0;$y<20;$t++)................................				|
			move.l	a0,a1			;													.				|
			cmp.w	d7,d6			;													.				|
			blt		.t_minus_i_lt0	;$diff < 0											.				|
			beq		.t_minus_i_eq0	;$diff == 0											.				|
.t_minus_i_gt0						;$diff > 1											.				|
			move.w	d0,d1			;													.				|
			move.w	#$8168,(a1)+	; or.w	d0,x(a0)									.				|
			move.w	d1,(a1)+		;  x												.				|
			add.w	#8,d1			;													.				|
			move.w	d6,d5			;													.				|
			sub.w	d7,d5			;													.				|
			subq.w	#2,d5			;													.				|
			blt		.x				;													.				|
.move_w_loop						;													.				|
;				move.w	#$3143,(a1)+; move.w	d3,x(a0) with....						.				|
				move.w	d3,(a1)+	; move.w	d3,x(a0) with....						.				|
				move.w	d1,(a1)+	;	.... $xval as offset							.				|
				addq.w	#8,d1		;													.				|
			dbra	d5,.move_w_loop	;													.				|
.x									;													.				|
;			move.w	#$8368,(a1)+	; or.w	d1,x(a0)									.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0)									.				|
			move.w	d1,(a1)+		;													.				|
;			move.w	#$4ed2,(a1)+	;	jmp (a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+	; dbra d4,
			move.w	a4,d2
			blt		.kkk
				move.w	#4,(a1)+
				move.w	#$4ed3,(a1)+
				move.l	-2(a2),(a1)+
				move.l	2(a2),(a1)+
				jmp		.nextiter_y		;													.				|
.kkk
			move.w	a4,(a1)+
			move.w	#$4ed3,(a1)+	; jmp (a3)
			jmp		.nextiter_y		;													.				|
									;													.				|
.t_minus_i_eq0						;$diff == 0	; only hit at first step 				.				|
			move.w	#$c240,(a1)+	; and.w d0,d1										.				|
;			move.w	#$8368,(a1)+	; or.w	d1,x(a0) with.....							.				|
			move.w	d4,(a1)+		; or.w	d1,x(a0) with.....							.				|
			move.w	d1,(a1)+		;	..... $xval as offset							.				|
;			move.w	#$4ed2,(a1)+	; jmp	(a2)										.				|
			move.l	#$41e800a0,(a1)+
			move.l	a5,a4
			sub.l	a1,a4
			move.w	#$51CC,(a1)+	
			move.w	a4,d2
			blt		.kkk2
				move.w	#4,(a1)+
				move.w	#$4ed3,(a1)+
				move.l	-2(a2),(a1)+
				move.l	2(a2),(a1)+
				jmp		.nextiter_y		;													.				|
.kkk2
			move.w	a4,(a1)+
			move.w	#$4ed3,(a1)+	; jmp (a3)
			jmp		.nextiter_y		;													.				|
.t_minus_i_lt0						;$diff < 0											.				|
.nextiter_y							;													,				|
			add.w	#gentableEntrySize,a0			; empty												.				|
			addq.w	#1,d6			; $y++												.				|
			cmp.w	#20,d6			; $y<20												.				|
		bne	.loop_y					; <..................................................				|
		addq.w	#8,d0				;																	|
		addq.w	#1,d7				; $x++																|
		cmp.w	#20,d7				; $x<20																|
	bne	    .loop_x					; <-----------------------------------------------------------------/


	rts


d_lz77		
		addq.l	#4,a0		; Skip original length
		bra.s	.loadtag

.literal
	rept	8
		move.b	(a0)+,(a1)+     ; Copy 8 bytes literal string
	endr
         
.loadtag	
		move.b	(a0)+,d0	; Load compression TAG
		beq.s	.literal	; 8 bytes literal string?


		moveq.l	#8-1,d1         ; Process TAG per byte/string
.search		add.b	d0,d0		; TAG <<= 1
		bcs.s	.compressed

		move.b  (a0)+,(a1)+     ; Copy another literal byte
		dbra	d1,.search

		bra.s	.loadtag


.compressed	moveq.l	#0,d2
		move.b  (a0)+,d2        ; Load compression specifier
		beq.s	.break		; End of stream, exit

		moveq.l	#$0f,d3		; Mask out stringlength
		and.l	d2,d3

		lsl.w	#4,d2		; Compute string location
		move.b	(a0)+,d2
		movea.l	a1,a2
		suba.l	d2,a2


		add.w	d3,d3		; Jump into unrolled string copy loop
		neg.w	d3
		jmp     .unroll(pc,d3.w)

	rept	15
		move.b	(a2)+,(a1)+
	endr
.unroll		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+

		dbra	d1,.search

		bra.s	.loadtag

.break		rts





fadeOffxx	dc.w	0
greetingsFadeWaiter		dc.w	5
greetingsFadeOutTimer	dc.w	5

; idea is that we have 2 ways, fade in, fade out
; if active, we fade in
; if inactive, we fade out, fadeouttimer is set

famesGreetingsShow		equ 	40

doFadeGreetings
	lea		fadeTab,a1													;2
	add.w	fadeOffxx,a1												;4
;	move.l	(a1)+,$ffff8240+2*6											;6

	tst.w	greetingsActive												;4
	beq		.inactive													;3 taken
		nop																;1


;------------------ 20 nop
.greetingsActive
	move.w	#famesGreetingsShow,greetingsFadeOutTimer					;5
	subq.w	#1,greetingsFadeWaiter										;5
	bge		.ok33														;3
		nop
		move.w	#5,greetingsFadeWaiter									;5
	add.w	#4,fadeOffxx												;5
	cmp.w	#8*4,fadeOffxx												;5
	bne		.ok51														;3
		nop
		move.w	#7*4,fadeOffxx											;5 --------> 56
		rts
.ok28
	REPT 5
;		nop
	ENDR
.ok33
	REPT 13
;		nop
	ENDR
.ok36
	REPT 13
;		nop
	ENDR
.ok49
	REPT 2
;		nop
	ENDR
.ok51	; 56-51
	REPT 5
;		nop
	ENDR
	rts

;----------------- 20 nop
.inactive																;
	subq.w	#1,greetingsFadeOutTimer									;5
	bge		.ok28														;3 taken
		nop
		subq.w	#1,greetingsFadeWaiter									;5
		bge		.ok36													;3
			nop
			move.w	#5,greetingsFadeWaiter								;5
			sub.w	#4,fadeOffxx										;5
			bge		.ok49												;3
				nop
				move.w	#0,fadeOffxx									;5
				rept 2
					nop
				endr
				rts

	SECTION DATA

offsetPointer		dc.l	offsets
listPointer			dc.l	0	;frames
savedListPointer	dc.l	0
offsets				include	"fx/greetings/offsets.s"
offsets2			include	"fx/greetings/offsets3.s"
frames_packed		incbin	"fx/greetings/frames.l77"	


intro_packed			
					incbin	"fx/greetings/introframes3.l77"

	IFEQ STANDALONE
greetings3			incbin	"fx/greetings/greetings3.bin"
	ENDC


	IFEQ STANDALONE
alignpointer1				dc.l	0
alignpointer2				dc.l	0
alignpointer3				dc.l	0
alignpointer4				dc.l	0
alignpointer5				dc.l	0
alignpointer6				dc.l	0
alignpointer7				dc.l	0


	include		lib.s

music
;	incbin		msx/exec40.snd
	even
	ENDC

	SECTION BSS
; general stuff
	IFEQ	STANDALONE
screenpointer3				dc.l	-1
screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
block1:						ds.b	65536
block2:						ds.b	65536
block3:						ds.b	65536
block4:						ds.b	65536
block5:						ds.b	65536
block6:						ds.b	65536
block7:						ds.b	65536
block8:						ds.b	65536
block9:						ds.b	65536
nextScene			ds.w	1
				ds.l	1		273*4 -->
planarpicbsspointer	ds.l	1
	ENDC
y_block_pointer_greetings		ds.l	1
clearScreenbuffer1Pointer		ds.l	1	13698
clearScreenbuffer2Pointer		ds.l	1	16302
clearScreenbuffer3Pointer		ds.l	1	18234
x_start_pointer_1bpl		ds.l	1
x_end_pointer_1bpl			ds.l	1
drawTablePointer1bpl		ds.l	1
