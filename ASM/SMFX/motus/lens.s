GENERATE_OFFSMAP	equ false
GENERATE_EYES		equ false
SKIP_LINES_TOP		equ 1
SKIP_LINES_BOTTOM 	equ 2

AFTER_EFFECT_WAITER	equ 40

; what we got in detail:
;	0. cinema scope bars opening
;	1. fullscreen 320x200 picture scrolling in vertically from below
;		- add elastic bounce?
;	2. lens effect comes in from above
;	3. lens moves around a bit




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
SHOW_CPU			equ 0
USE_MYM_DUMP				equ 1
LENS_AFTER_EFFECT_FADEWAITER	equ 90

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

    section	DATA

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init



standalone_init
	jsr		init_effect
	jsr		init_lens

	rts


init_effect

	move.l	#membase+65536,d0			;	1
	sub.w	d0,d0						;
	move.l	d0,screenpointer			;	
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts



	ENDC

herp	equ 1500

scrubMem
	move.w	#herp-1,d7
	add.w	#(1700-herp)*4,a0
	moveq	#0,d0
.s
	REPT 100
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.s
	rts

init_lens
	move.l	screen1,a0
	jsr		scrubMem

	jsr		initlensPointers

	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2



	lea		flarecrk,a0
	move.l	directoryPointer,a1
	jsr		cranker

	move.l	directoryPointer,a0
	move.l	a0,d0
	sub.l	#2,d0
	REPT 16
		add.l	d0,(a0)+
	ENDR

;	lea		directory,a0
;	move.l	#directory,d0
;	sub.l	#2,d0
;	REPT 16
;	add.l	d0,(a0)+
;	ENDR




;	jsr		testEye
	move.w	#0,leftEyeOffset
	move.w	#0,chunkyEyeOffset

	tst.w	musicInit
	bne		.skipMusicInit
		IFEQ	STANDALONE
			IFEQ	USE_MYM_DUMP
		initMusic	musicmyv,musicmys,musicmysend
			ENDC
		ENDC
		move.w	#-1,musicInit
.skipMusicInit

	IFEQ	USE_MYM_DUMP
		IFEQ	STANDALONE
		move.l	#.noMusicVBL,$70
	    lea     replayroutine,a0
		jsr		findEntryAndExitCode
		move.w	#14*50,d7					;19600
		jsr		dumpMymFrames
		ENDC
	ENDC


	IFEQ	GENERATE_OFFSMAP
		jsr		generateOffsetMap			; generate offset map from tga
	ELSE
		lea		offsetsrc,a0
		move.l	offsetsPointer,a1
		jsr		cranker
	ENDC

;	jsr		prepAni

	jsr		unpackExplode


;	move.l	explodepic_pointer,a0
;	add.l	#200*160

	move.l	explodepic_pointer,a0
	add.l	#200*160+128,a0
;	lea		explode_pic+128,a0
	lea		haxEye,a1
	add.w	#88*160,a0
.y set 11*8
	REPT 10
.x set .y
		REPT 2
			move.l	.x(a0),(a1)+
			move.l	.x+4(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR

	jsr		genScroller

	jsr		init_explode_scrollin
	jsr		init_explode_lens_effect
.xx
	tst.w	_times
	bge		.xx


;	move.w	#100,_times
;.y
;	wait_for_vbl
;				move.l	screenpointer2,a0
;				move.l	a0,usp
;				jsr		changeBuffer

;	subq.w	#1,_times
;	bge		.y



	jsr		run_explode_lens_effect

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#200-1,d7
	moveq	#0,d0
.cl
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
	dbra	d7,.cl

	rts
.noMusicVBL
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	rte
.waitvbls	dc.w	80
;;;;;;;;;;;;;;;;;;;; REAL DEMOCODE STARTS HERE


;		19	20	21	22	23	
;	17	18	2	3	4	24	25
;	40	16	1		5	6	26
;	39	15		0		7	27
;	38	14	13		9	8	28
;	37	36	12	11	10	30	29
;		35	34	33	32	31	




;	screenXOff	0..79
;	yoffset		-62..200

; 262
;
;	8			0-20		21
;	15			21-59		38
;	17			60-100		40
;	20			101-162		63
;	17			162-202		40
;	15			203-241		38
;	8			242-262		21		--> 

initlensPointers
	move.l	screen1,d0
		move.l	d0,d1
		add.l	#$8000+5600,d1
		move.l	d1,leftEyeChunky1Pointer
		add.l	#9020,d1
		move.l	d1,leftEyeChunky2Pointer
		add.l	#9020,d1
	add.l	#$10000,d0					;	2
		move.l	d0,d1
		add.l	#$8000+5600,d1
		move.l	d1,rightEyeChunky1Pointer
		add.l	#9020,d1
		move.l	d1,rightEyeChunky2Pointer
		add.l	#9020,d1
			move.l	d1,animationPointer

	add.l	#$10000,d0					;	3
	move.l	d0,tab1px_1p	
		move.l	d0,d1
		add.l	#16384,d1
		move.l	d1,offsetsPointer
		add.l	#12288,d1
		move.l	d1,unrolledCodePointer1
		add.l	#29208,d1								;7600 left
		move.l	d1,leftEyeBufferPointer
		add.l	#7216,d1
	add.l	#$10000,d0					;	4
	move.l	d0,tab1px_2p
		move.l	d0,d1
		add.l	#16384,d1
		move.l	d1,unrolledCodePointer2
		add.l	#28330+2,d1
		move.l	d1,scrollerPointer
		add.l	#8000,d1
		add.l	#63*2,d1
		move.l	d1,ytablePointer
		add.l	#200*2,d1
		move.l	d1,clearPointer
		add.l	#800,d1									;11550 left
		move.l	d1,rightEyeBufferPointer				;6560
		add.l	#6560,d1
		move.l	d1,xPositionTabPointer
		add.l	#800,d1								; 4134 left
		move.l	d1,eyeSpritesPointer
		add.l	#3000,d1
		move.l	d1,xeyesYPointer
		add.l	#600,d1

	add.l	#$10000,d0					;	5
	move.l	d0,tab1px_3p	
		move.l	d0,d1
		add.l	#16384,d1
		move.l	d1,leftEyeChunky3Pointer
		add.l	#9020,d1
		move.l	d1,rightEyeChunky3Pointer
		add.l	#9020,d1
		move.l	d1,canvasPointer
		add.l	#600,d1

		move.l	d1,xeyesLeftXPointer
		add.l	#1200,d1
		move.l	d1,xeyesRightXPointer
		add.l	#1200,d1					;	28112 left
		move.l	d1,directoryPointer
		add.l	#12000,d1
		move.l	d1,rightEyeBufferPointer				;6560
		add.l	#6560,d1

		IFEQ	STANDALONE
		move.l	d1,musicBufferPointer
		ENDC

	add.l	#$18000,d0					;	6		6*65536 + 354816
	move.l	d0,explodepic_pointer
	add.l	#$10000,d0
	add.l	#$10000,d0



	move.l	d0,chunkyPicEvenPointer
	add.l	#118272-28672+4480,d0					;94080
	move.l	d0,chunkyPicUnEvenPointer
	add.l	#118272-28672+4480,d0
	move.l	d0,chunkyPicUnEvenPointer2
	add.l	#118272-28672+4480,d0				;					748032-72576 total
	move.w	#$4e75,initlensPointers
	rts

unpackExplode
	lea		explode_src,a0
;	lea		explode_pic,a1
	move.l	explodepic_pointer,a1
	jsr		cranker
	move.w	#$4e75,unpackExplode
	rts

xeyesYdefs
	dc.b	46
	dc.b	42
	dc.b	30
	dc.b	18
	dc.b	30
	dc.b	42
	dc.b	62		;600

xeyesLeftXdefs
	dc.b	41*2
	dc.b	10*2
	dc.b	13*2
	dc.b	6*2
	dc.b	13*2
	dc.b	10*2
	dc.b	30*2		;600

xeyesRightXdefs
	dc.b	51*2
	dc.b	14*2
	dc.b	13*2
	dc.b	6*2
	dc.b	13*2
	dc.b	50*2		;600
	even


genxeyesY
	move.l	xeyesYPointer,a0
	moveq	#0,d0
	moveq	#7-1,d7
	lea		xeyesYdefs,a6
.ol
		moveq	#0,d6
		move.b	(a6)+,d6
.il
			move.w	d0,(a0)+
		dbra	d6,.il
		add.w	#14,d0
	dbra	d7,.ol

	move.l	xeyesLeftXPointer,a0
	moveq	#0,d0
	lea		xeyesLeftXdefs,a6
	moveq	#7-1,d7
.ol2
		moveq	#0,d6
		move.b	(a6)+,d6
.il2
			move.w	d0,(a0)+
		dbra	d6,.il2
		addq.w	#2,d0
	dbra	d7,.ol2

	move.l	xeyesRightXPointer,a0
	moveq	#0,d0
	lea		xeyesRightXdefs,a6
	moveq	#7-1,d7
.ol3
		moveq	#0,d6
		move.b	(a6)+,d6
.il3
			move.w	d0,(a0)+
		dbra	d6,.il3
		addq.w	#2,d0
	dbra	d7,.ol3
	rts



;	0..79
;
;	8			0-5
;	15			6-17
;	17			18-31
;	20			32-47
;	17			48-61
;	15			62-73
;	8			74-79


; start 48	==> 80	
; end 240

; eye = 140


;		0	1	2	3	4
;	5	6	7	8	9	10	11
;	12	13	14		15	16	17
;	18	19		20		21	22
;	23	24	25		26	27	28
;	29	30	31	32	33	34	35
;		36	37	38	39	40


movementOffsets
	dc.w	 0, 1, 2, 2, 2, 3, 4
	dc.w	 5, 6, 7, 8, 9,10,11
	dc.w	12,13,14,20,15,16,17
	dc.w	18,19,20,20,20,21,22
	dc.w	23,24,25,20,26,27,28
	dc.w	29,30,31,32,33,34,35
	dc.w	36,37,38,38,38,39,40




movementOff	dc.w	0
movementLeft
	dc.w	7,10		;0
	dc.w	8,10		;1
	dc.w	9,10		;2
	dc.w	10,10		;3
	dc.w	11,10		;4

	dc.w	6,11		;5		
	dc.w	7,11		;6
	dc.w	8,11		;7
	dc.w	9,11		;8
	dc.w	10,11		;9
	dc.w	11,11		;10
	dc.w	12,11		;11

	dc.w	6,12		;12
	dc.w	7,12		;13
	dc.w	8,12		;14
	dc.w	10,12		;15
	dc.w	11,12		;16
	dc.w	12,12		;17

	dc.w	6,13		;18	
	dc.w	7,13		;19
	dc.w	9,13		;20
	dc.w	11,13		;21
	dc.w	12,13		;22

	dc.w	6,14		;23
	dc.w	7,14		;24
	dc.w	8,14		;25
	dc.w	10,14		;26
	dc.w	11,14		;27
	dc.w	12,14		;28

	dc.w	6,15		;29
	dc.w	7,15		;30
	dc.w	8,15		;31
	dc.w	9,15		;32
	dc.w	10,15		;33
	dc.w	11,15		;34
	dc.w	12,15		;35

	dc.w	7,16		;36
	dc.w	8,16		;37
	dc.w	9,16		;38
	dc.w	10,16		;39
	dc.w	11,16		;40


init_explode_lens_effect
	jsr		generatexPositionTab
	jsr		genUnrolledCode1
	jsr		genUnrolledCode2
	jsr		genTables
	jsr		genClears
	jsr		calc1pxTab_upper_new
	jsr		generateChunkyFromPic_new		; generate chunkyPics from picture

	lea		animation,a0
	move.l	animationPointer,a1
	jsr		cranker


	IFEQ	GENERATE_EYES
		jsr		prepExplodeEyes
	ENDC
	jsr		genxeyesY
	jsr		initEyeGenLeft
	jsr		initEyeGenRight


	move.w	#0,chunkyEyeOffset
	move.w	#0,leftEyeOffset
	move.w	#0,rightEyeOffset

	move.w	#$4e75,init_explode_lens_effect
	rts

logoAnimation
	tst.w	aniUp
	beq		.up
		move.l	usp,a1
		add.w	#187*160+136,a1
		moveq	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.w	#13-1,d7
.dl
		movem.l	d0-d5,(a1)
		add.w	#160,a1
		dbra	d7,.dl
.up
;	lea		animation,a0
	move.l	animationPointer,a0
	add.w	animationOff,a0
	subq.w	#1,aniWaiter
	bge		.okkk
		move.w	#1,aniWaiter
	add.w	#3*8*13,animationOff
	cmp.w	#20*3*8*13,animationOff
	bne		.okkk
		move.w	#0,animationOff
.okkk
	move.l	usp,a1
	add.w	#(187)*160,a1
	move.w	aniVertOff,d0
	add.w	d0,d0			;2
	move.w	d0,d1			;2
	add.w	d0,d0	;4
	add.w	d0,d0	;8
	add.w	d0,d1		;10
	jmp		.drawCode(pc,d1)
.drawCode
.x set 136
	REPT 13
		movem.l	(a0)+,d0-d5			;13*6*4			108/60/60			;4
		movem.l	d0-d5,.x(a1)											;6	--> 10
.x set .x+160
	ENDR
	tst.w	aniUp
	bne		.down
	subq.w	#1,aniVertOffWater
	bge		.cont
		move.w	#3,aniVertOffWater
		subq.w	#2,aniVertOff
		bge		.cont
			move.w	#0,aniVertOff
.cont
	rts
.down
	subq.w	#1,aniVertOffWater
	bge		.cont
		move.w	#3,aniVertOffWater
		addq.w	#2,aniVertOff
		cmp.w	#13,aniVertOff
		ble		.cont
			move.w	#13,aniVertOff
	rts

aniVertOffWater	dc.w	50
aniUp			dc.w	0
animationOff	dc.w	0
aniWaiter		dc.w	2
aniVertOff		dc.w	13
fixTopLine
;	move.l	screenpointer2,a0
	subq.w	#1,.times
	bge		.ok
		move.w	#$4e75,fixTopLine
.ok
	move.l	usp,a0
	moveq	#0,d1
	move.l	d1,d0	;1
	move.l	d1,d2	;2
	move.l	d1,d3	;3
	move.l	d1,d4	;4
	move.l	d1,d5	;5
	move.l	d1,d6	;6
	move.l	d1,d7	;6
	move.l	d1,a1	;7
	move.l	d1,a2	;8
	move.l	d1,a3	;9

.x set 16
	REPT 3
		movem.l	d0-d7/a1-a3,.x(a0)				;400+36 = 436		;4*8 = 32 3*11
.x set .x+44
	ENDR
	rts
.times	dc.w	110

movePosition	macro
	lea		spiral,a0
	add.w	spiralOff,a0
	move.w	(a0)+,d1
	move.w	d1,xPosition
	move.w	(a0)+,d2
	move.w	d2,yoffset

	move.w	xPositionOld,d0
	sub.w	d1,d0
	bgt		.right
.left	
		move.w	#-1,xdir
		jmp		.cont2
.right
		move.w	#1,xdir
.cont2
	move.w	xdirOld,xdirOlder
	move.w	xdir,xdirOld

	move.w	xPosition,xPositionOld

;;---------
	move.w	yoffsetOld,d0
	sub.w	d2,d0
	bge		.up
.down
		move.w	#1,ydir
		jmp		.cont
.up
		move.w	#-1,ydir
.cont

	add.w	#4,spiralOff

	cmp.w	#202,yoffset
	blt		.done
		moveq	#0,d0
		move.w	effect_frames,d0
;		move.b	#0,$ffffc123
		move.w	#-1,lens_effect_done
		move.w	#1,aniUp
		move.w	#40,aniVertOffWater
.done
	endm
spiralOff	dc.w	0

lens_out_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	move.l	screenpointer2,$ffff8200
	subq.w	#1,_times
	pushall

	clr.b   $fffffa1b.w         	
    bset    #0,$fffffa07.w          
    bset    #0,$fffffa13.w          
    move.l	#timer_b_cinema,$120	; schedule timer b to open lower
    move.b  #1,$fffffa21.w        
	bclr	#3,$fffffa17.w			
    move.b  #8,$fffffa1b.w   
	IFEQ	USE_MYM_DUMP 	 

		jsr		replayMymDump
	ELSE
		IFNE	STANDALONE
		jsr		musicPlayer+8
		ENDC
	ENDC


	tst.w	lensFadeActive
	beq		.ok
	subq.w	#1,fadeDelay
	bge		.ok
	lea		lens_fadeTab,a0
	add.w	lens_fadeOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	move.w	#0,$ffff8240
	swap	d0
	move.w	d0,timer_b_cinema+2
	subq.w	#1,.waiter
	bge		.ok
		move.w	#1,.waiter
		add.w	#16*2,lens_fadeOff
		cmp.w	#16*2*16,lens_fadeOff
		bne		.ok
			move.w	#16*2*15,lens_fadeOff
			move.w	#0,lensFadeOutDone
.ok


	move.l	screenpointer2,a0
	move.l	a0,usp
	jsr		logoAnimation											; logo animation

		tst.w	lensFadeActive
		bne	.skipeye
			lea		finEyeOffset,a0
			add.w	finEyesOff,a0
			move.w	(a0)+,rightEyeOffset
			move.w	(a0)+,leftEyeOffset
			jsr		fixEyes
			tst.w	finEyesOff
			bne		.nohax
				move.l	screenpointer2,a0
				lea		haxEye,a1
				add.w	#88*160,a0
.yy set 11*8
				REPT 10
.xx set .yy
					REPT 2
						move.l	(a1)+,.xx(a0)
						move.l	(a1)+,.xx+4(a0)
.xx set .xx+8
					ENDR
.yy set .yy+160
				ENDR
.nohax
			subq.w	#1,.eyewaiter
			bge		.skipeye
				move.w	#7,.eyewaiter
				subq.w	#4,finEyesOff
				bge		.skipeye
					move.w	#0,finEyesOff
.skipeye


			swapscreens
	popall

	rte
.eyewaiter	dc.w	25
.waiter	dc.w	1


run_explode_lens_effect
	move.w	#1,ydir
	move.w	#-62,yoffset

	move.w	#$2700,sr
	move.l	#lens_vbl,$70
	move.w	#$2300,sr
	clr.w	$466
.mainloop	
	wait_for_vbl
		move.w	#0,$ffff8240
		addq.w	#1,effect_frames
		IFEQ	SHOW_CPU
			move.w	#$007,$ffff8240
		ENDC
	tst.w	lens_effect_done
	beq		.mainloop
	move.w	#LENS_AFTER_EFFECT_FADEWAITER,_times

	; here change to new vbl
	move.l	#lens_out_vbl,$70

.waiters
	wait_for_vbl
		jsr		init_tunnel_pointers
		jsr		precalc_tunnel1

	tst.w	_times
	bge		.waiters

	move.w	#-1,lensFadeActive
.fadeout
			wait_for_vbl
			jsr		precalc_tunnel2

	tst.w	lensFadeOutDone
	bne		.fadeout
.next
	rts
fadeDelay		dc.w	32		AFTER_EFFECT_WAITER+90
effect_frames		dc.w	0
lensFadeOutDone		dc.w	-1
lens_effect_done	dc.w	0

lensFadeActive		dc.w	0

finEyeOffset	;right	;left
	dc.w	20*10*16,20*11*16
	dc.w	32*10*16,32*11*16
	dc.w	38*10*16,38*11*16
finEyesOff
	dc.w	8

;38,32;20


lens_fadeTab
	dc.w	$777,$201,$411,$621,$632,$743,$754,$765,$000,$666,$655,$555,$444,$332,$222,$211
	dc.w	$777,$312,$522,$732,$743,$754,$765,$776,$111,$666,$766,$666,$555,$443,$333,$322
	dc.w	$777,$423,$633,$743,$754,$765,$776,$777,$222,$777,$777,$777,$666,$554,$444,$433
	dc.w	$777,$534,$744,$754,$765,$776,$777,$777,$333,$777,$777,$777,$777,$665,$555,$544
	dc.w	$777,$645,$755,$765,$776,$777,$777,$777,$444,$777,$777,$777,$777,$776,$666,$655
	dc.w	$777,$756,$766,$776,$777,$777,$777,$777,$555,$777,$777,$777,$777,$777,$777,$766
	dc.w	$777,$767,$777,$777,$777,$777,$777,$777,$666,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777

	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777

	dc.w	$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766,$766
	dc.w	$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655,$655
	dc.w	$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544,$544
	dc.w	$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433,$433
	dc.w	$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322,$322
	dc.w	$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211,$211
	dc.w	$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

lens_fadeOff	dc.w	0
xPositionOld	dc.w	0





putFlare
	move.w	xPosition,d0
	add.w	#12,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	xPositionTabPointer,a2
	add.w	d0,a2
	and.w	#$f*4,d0
;	lea		directory,a1
	move.l	directoryPointer,a1
	add.w	d0,a1
	move.l	(a1),a0
	move.l	screenpointer2,a1
	move.l	a1,usp
	add.w	(a2),a1
	add.w	#1760+24,a1
	move.w	yoffset,d0
	move.w	d0,d1			
	lsl.w	#5,d0		; 
	move.w	d0,d2		;32
	add.w	d0,d0		
	add.w	d0,d0		
	add.w	d2,d0
	add.w	d0,a1

	jmp		(a0)


fixTopBot	macro
	; now fix top and bottom
	; a5 is sorted, we copy 2 lines top and 2 lines below
	move.l	a5,a1
	move.l	usp,a2
	sub.l	a2,a5		; x and y offset

;	lea		explode_pic+128,a0
	move.l	explodepic_pointer,a0
	add.l	#128+200*160,a0
	add.l	a5,a0					; add offset to explode
	; now copy stuff, top and bottom
	tst.w	ydir
	blt		.boty
.topy
.y set 0
	REPT 8
.x set .y
		REPT 1
		movem.l	-160+.x(a0),d0-d7/a2-a5		; 32 px
		movem.l	d0-d7/a2-a5,-160+.x(a1)
.x set .x+8
		ENDR
.y set .y-160
	ENDR
	jmp		.conty

.boty
.y set -480
	REPT 8
.x set .y
		REPT 1
		movem.l	64*160+.x(a0),d0-d7/a2-a5	; 32 px
		movem.l	d0-d7/a2-a5,64*160+.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
.conty
	endm



lens_vbl
	pushall
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	move.l	screenpointer2,$ffff8200


	clr.b   $fffffa1b.w         	
    bset    #0,$fffffa07.w          
    bset    #0,$fffffa13.w          
    move.l	#timer_b_cinema,$120	; schedule timer b to open lower
    move.b  #1,$fffffa21.w        
	bclr	#3,$fffffa17.w			
    move.b  #8,$fffffa1b.w   
	IFEQ	USE_MYM_DUMP 	 
		jsr		replayMymDump
	ELSE
		IFNE	STANDALONE
		jsr		musicPlayer+8
		ENDC
	ENDC
	move.l	screenpointer2,a0
	move.l	a0,usp
	jsr		logoAnimation											; logo animation

	tst.w	lens_effect_done
	bne		.skip
		jsr		restoreThing											; restore the screen
		jsr		changeBuffer											; change the buffer
		jsr		c2p_1to1_indirect_offset_upper_highres_optimized_new	; do effect
		jsr		putFlare
				fixTopBot												; because bugs?
				movePosition

		move.w	xPosition,d0
		move.l	xPositionTabPointer,a0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,a0
		move.w	(a0)+,screenXOff
		move.w	(a0)+,chunkyMapOffset

		jsr		fixTopLine												; fix top line
.skip
				swapscreens

	move.w	#$0,$ffff8240				; set black background

	popall
	rte

timer_b_cinema
	move.w	#$777,$ffff8240
    clr.b   $fffffa1b.w     
    move.l	#timer_b_cinema_bot,$120	; schedule timer b to open lower
    move.b  #199,$fffffa21.w        
    move.b  #8,$fffffa1b.w          
    rte

timer_b_cinema_bot
	move.w	#0,$ffff8240
    clr.b   $fffffa1b.w         	
	rte	   

	IFEQ	GENERATE_OFFSMAP
generateOffsetMap
	lea		tga+18,a0				; this is a 160x100 picture
	move.l	offsetsPointer,a1
	moveq	#0,d2
	move.w	#64-1,d7				; we cut out 64 height
.y
		move.w	#96-1,d6				; we cut out 96 width
.x
			addq.w	#1,a0				; first byte is empty
			moveq	#0,d1
			move.b	(a0)+,d1
			;mulu	#14*16,d1			;48 this is the width of the picture source, in our case 12*16
			; 224
			;	128 + 64 + 32
			lsl.w	#5,d1
			move.w	d1,d3	;32
			add.w	d1,d1	;64
			add.w	d1,d3	;32+64
			add.w	d1,d1	;128
			add.w	d3,d1	;224		; *224
			move.b	(a0)+,d2
			add.w	d2,d1
			add.w	d1,d1
			move.w	d1,(a1)+
		dbra	d6,.x
		; 96*3 done
		lea	(160-96)*3(a0),a0
	dbra	d7,.y
	move.l	a1,a2
	sub.l	offsetsPointer,a2
	move.l	offsetsPointer,a0
;	move.b	#0,$ffffc123					;00003000 = 12288
	rts

testOffsetMap
	lea		tga+18,a0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d6
	moveq	#0,d5
	moveq	#0,d4
	move.w	#64-1,d7
.y
	move.w	#96-1,d6				; we cut out 96 width
	move.w	d3,d4
	move.w	#0,a6
.x
		addq.w	#1,a0				; first byte is empty
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d2			; this is value
		move.b	(a0)+,d1
		muls	#160,d2
		add.w	d2,d1
		cmp.w	d4,d1
		beq		.kkk
			move.w	#1,a6
.kkk	
		addq.w	#1,d4

	dbra	d6,.x
		; 96*3 done
;			move.b	#0,$ffffc123
		cmp.w	#1,a6
		bne		.skip
			move.b	#0,$ffffc123
.skip
		lea		(160-96)*3(a0),a0
		add.w	#160,d3
		addq.w	#1,d5
	dbra	d7,.y
	rts	
	ENDC

chunkyMapOffset	dc.w	0
chunkypicOffset	dc.w	0
yoffset			dc.w	200
ydir			dc.w	-1
xdir			dc.w	1


bouncetimes		dc.w	3

calc1pxTab_upper_new

	lea		TAB1,a0
	lea		TAB2,a1
	move.l	tab1px_1p,a5
	jsr		makeTab31

	lea		TAB2,a0
	lea		TAB3,a1
	move.l	tab1px_2p,a5
	jsr		makeTab32

	lea		TAB4,a0
	move.l	tab1px_3p,a5
	jsr		makeTab33
	rts

; used: d0,d1,d2,d3,d4,d5,d6,d7
makeTab31
	move.w	#16-1,d7
;	moveq	#0,d4
	move.l	#$20202020,d4
	move.l	#0,a6
.loop1
		move.w	#16-1,d6
		moveq	#0,d3
		move.l	(a0,a6.w),d2
		and.l	#$80808080,d2
.loop2
			move.l	(a0,d3.w),d5
			and.l	#$40404040,d5
			moveq	#0,d1
			REPT 16
				move.l	(a1,d1.w),d0
;				and.l	#$20202020,d0
				and.l	d4,d0
				or.l	d5,d0
				or.l	d2,d0
				move.l	d0,(a5)+					;16*16*16*4 = 16384
				addq.w	#4,d1
			ENDR
			addq.w	#4,d3
		dbra	d6,.loop2
;		addq.w	#4,d4
		addq.w	#4,a6
	dbra	d7,.loop1
	rts

makeTab32
	move.w	#16-1,d7
;	moveq	#0,d4
	move.l	#$04040404,d4
	move.l	#0,a6
.loop1
		move.w	#16-1,d6
		moveq	#0,d3
		move.l	(a0,a6.w),d2
		and.l	#$10101010,d2
.loop2
			move.l	(a1,d3.w),d5
			and.l	#$08080808,d5
			moveq	#0,d1
			REPT 16
				move.l	(a1,d1.w),d0
;				and.l	#$04040404,d0				
				and.l	d4,d0				
				or.l	d5,d0
				or.l	d2,d0
				move.l	d0,(a5)+					;16*16*16*4 = 16384
				addq.w	#4,d1
			ENDR
			addq.w	#4,d3
		dbra	d6,.loop2
;		addq.w	#4,d4
		addq.w	#4,a6
	dbra	d7,.loop1
	rts

makeTab33
	move.w	#16-1,d7
	move.l	#$01010101,d2
	move.l	#$02020202,d5
.loop1	
		move.w	#16-1,d6
		moveq	#0,d3
.loop2
			moveq	#0,d1
			move.l	(a0,d3.w),d4
;			and.l	#$02020202,d4
			and.l	d5,d4
			REPT 16
				move.l	(a0,d1.w),d0
;				and.l	#$01010101,d0
				and.l	d2,d0
				or.l	d4,d0
				move.l	d0,(a5)+					;16*16*16*4 = 16384
				addq.w	#4,d1
			ENDR
			addq.w	#4,d3
		dbra	d6,.loop2
	dbra	d7,.loop1
	rts	




changeBufferLeft	macro
.y set 0
		movem.l	(a0)+,d0-d7/a2		
		move.l	d0,.y+24(a1)						;1	/12/24	
.y set .y+16*14*2
		movem.l	d1-d3,.y+20(a1)						;2	/10/20
.y set .y+16*14*2
		movem.l	d4-d7/a2,.y+16(a1)					;3	/8/16
		movem.l	(a0)+,d0-d7/a2-a6	
.y set .y+16*14*2
		movem.l	d0-d5,.y+14(a1)						;4	/7/14
.y set .y+16*14*2
		movem.l	d6-d7/a2-a6,.y+12(a1)				;5	/6/12
		movem.l	(a0)+,d0-d7
.y set .y+16*14*2
		movem.l	d0-d7,.y+10(a1)						;6	/5/10
		movem.l	(a0)+,d0-d7/a2-a6
.y set .y+16*14*2
		movem.l	d0-d6,.y+12(a1)						;7	/6/12
.y set .y+16*14*2		
		movem.l	d7/a2/a3/a4/a5/a6,.y+14(a1)			;8	/7/14
		movem.l	(a0)+,d0-d7/a2-a5				
.y set .y+16*14*2		
		movem.l	d0-d4,.y+16(a1)						;9	/8/16
.y set .y+16*14*2		
		movem.l	d5/d6/d7/a2,.y+18(a1)				;a	/9/18
.y set .y+16*14*2		
		movem.l	a3/a4/a5,.y+22(a1)					;b	/11/22
	endm


; right eye								15x10 = 15
;
;	1,2,3,4,5,6,7,8,9,a,b,c,d,e,f
;1	0,0,0,0,0,0,1,1,1,1,0,0,0,0,0		6+5=11		4/2
;2	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0		4+5=9		8/4
;3	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0		3+5=8		10/5
;4	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0		2+5=7		12/6
;5	0,1,1,1,1,1,1,1,1,1,1,1,1,1,0		1+5=6		14/7	
;6	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1		1+5=6		14/7
;7	1,1,1,1,1,1,1,1,1,1,1,1,1,1,0		0+5=5		14/7
;8	0,1,1,1,1,1,1,1,1,1,1,1,1,0,0		1+5=6		12/6
;9	0,0,1,1,1,1,1,1,1,1,1,0,0,0,0		2+5=7		10/5
;a	0,0,0,0,1,1,1,1,1,1,0,0,0,0,0		4+5=9		6/3

changeBufferRight	macro
.y set -2
		movem.l	(a0)+,d0-d7/a2-a4
		movem.l	d0-d1,.y+22(a1)						;1	2/4
.y set .y+16*14*2
		movem.l	d2/d3/d4/d5,.y+18(a1)				;2	4/8
.y set .y+16*14*2
		movem.l	d6/d7/a2/a3/a4,.y+16(a1)			;3	5/10
		movem.l	(a0)+,d0-d7/a2-a6
.y set .y+16*14*2
		movem.l	d0-d5,.y+14(a1)						;4	6/12
.y set .y+16*14*2
		movem.l	d6-d7/a2-a6,.y+12(a1)				;5	7/14
		movem.l	(a0)+,d0-d6
.y set .y+16*14*2
		movem.l	d0-d6,.y+12(a1)						;6	7/14
		movem.l	(a0)+,d0-d7/a2-a6
.y set .y+16*14*2
		movem.l	d0-d6,.y+10(a1)						;7	7/14
.y set .y+16*14*2
		movem.l	d7/a2/a3/a4/a5/a6,.y+12(a1)			;8	6/12
		movem.l	(a0)+,d0-d7
.y set .y+16*14*2
		movem.l	d0-d4,.y+14(a1)						;9	5/10
.y set .y+16*14*2
		movem.l	d5/d6/d7,.y+18(a1)					;10	3/6
	endm

moveIndexLeft	dc.w	0
moveIndexRight	dc.w	0
chunkyEyeOffset	dc.w	0
leftEyeOffset	dc.w	0
rightEyeOffset	dc.w	0

changeBuffer
	move.w	yoffset,d0			;-62..200
	add.w	#62,d0				; 0..262
;	lea		xeyesY,a0
	movem.l	xeyesYPointer,a0-a2		;a1 xeyesLeftXPointer, a2 xeyesLeftXPointer
	add.w	d0,d0
	move.w	(a0,d0.w),d0		; yoff

	move.w	xPosition,d1
	add.w	#32,d1
	add.w	d1,d1
	move.w	d0,d2
	add.w	(a1,d1.w),d0
	add.w	(a2,d1.w),d2


	lea		movementOffsets,a0
;	move.w	(a0,d0.w),moveIndexLeft
;	move.w	(a0,d2.w),moveIndexRight
;
;	move.w	moveIndexLeft,d0
;	muls	#220,d0			;	128 + 64 + 16 + 8 + 4
;
;	move.w	d0,chunkyEyeOffset
;
;	move.w	moveIndexLeft,d0
;;	move.b	#0,$ffffc123
;;	muls	#11*16,d0			; 176 = 128 + 32 + 16
;	lsl.w	#4,d0		;
;	move.w	d0,d1
;	add.w	d0,d0
;	add.w	d0,d1
;	add.w	d0,d0
;	add.w	d0,d0
;	add.w	d1,d0
;	move.w	d0,leftEyeOffset
;
;	move.w	moveIndexRight,d0
;;	muls	#10*16,d0			; 128 + 32 
;	lsl.w	#5,d0
;	move.w	d0,d1
;	add.w	d0,d0
;	add.w	d0,d0
;	add.w	d1,d0
;
;	move.w	d0,rightEyeOffset


	move.w	(a0,d0.w),d0		;moveIndexLeft
	move.w	(a0,d2.w),d1		;moveIndexRight
	move.w	d0,d2
	muls	#220,d2				;chunkyEyeOffset
	move.w	d0,d3				
	lsl.w	#4,d3				; 16
	move.w	d3,d4						;16
	add.w	d3,d3				; 32
	add.w	d3,d4						;48
	add.w	d3,d3				;64
	add.w	d3,d3				;128
	add.w	d4,d3				;		176 	leftEyeOffset
	move.w	d1,d4
	lsl.w	#5,d4
	move.w	d4,d5
	add.w	d4,d4
	add.w	d4,d4
	add.w	d5,d4				;rightEyeOffset
	movem.w	d0-d4,moveIndexLeft

;moveIndexLeft	
;moveIndexRight	
;chunkyEyeOffset
;leftEyeOffset	
;rightEyeOffset	


	move.l	leftEyeChunky1Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicEvenPointer,a1
	add.l	#88*16*2*14+5*2*16,a1
			changeBufferLeft

	move.l	leftEyeChunky2Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicUnEvenPointer,a1
	add.l	#88*16*2*14+5*2*16,a1
			changeBufferLeft

	move.l	leftEyeChunky3Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicUnEvenPointer2,a1
	add.l	#88*16*2*14+5*2*16,a1
			changeBufferLeft

	move.w	moveIndexRight,d0
	muls	#220,d0
	move.w	d0,chunkyEyeOffset

	move.l	rightEyeChunky1Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicEvenPointer,a1
	add.l	#87*16*2*14+5*2*16+2+96,a1
			changeBufferRight

	move.l	rightEyeChunky2Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicUnEvenPointer,a1
	add.l	#87*16*2*14+5*2*16+2+96,a1
			changeBufferRight

	move.l	rightEyeChunky3Pointer,a0
	add.w	chunkyEyeOffset,a0
	move.l	chunkyPicUnEvenPointer2,a1
	add.l	#87*16*2*14+5*2*16+2+96,a1
			changeBufferRight

fixEyesIndirect
	move.l	leftEyeBufferPointer,a0
	add.w	leftEyeOffset,a0
	move.l	usp,a1
;	move.l	screenpointer2,a1
	move.l	explodepic_pointer,a6
;	lea		explode_pic+128+89*160+8*8,a6
	add.l	#128+289*160+8*8,a6
	add.w	#89*160+8*8,a1

	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set 0
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d7
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)

	move.l	rightEyeBufferPointer,a0
	add.w	rightEyeOffset,a0
;	move.l	screenpointer2,a1
	move.l	usp,a1
	add.w	#88*160+11*8,a1
;	lea		explode_pic+128+88*160+11*8,a6
	move.l	explodepic_pointer,a6
	add.l	#128+288*160+11*8,a6

	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set 0
	movem.l	d0-d3,.y(a1)			;8
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)			;8
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)			;
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d7/a2/a3/a4/a5
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)
.y set .y+160
	movem.l	d4-d7,.y(a1)
	movem.l	d4-d7,.y(a6)
.y set .y+160
	movem.l	a2-a5,.y(a1)
	movem.l	a2-a5,.y(a6)
	movem.l	(a0)+,d0-d3
.y set .y+160
	movem.l	d0-d3,.y(a1)
	movem.l	d0-d3,.y(a6)

;	add.w	#10*16,rightEyeOffset
;	add.w	#11*16,leftEyeOffset
;	add.w	#220,chunkyEyeOffset
;	cmp.w	#220*41,chunkyEyeOffset
;	bne		.ok
;		move.w	#0,chunkyEyeOffset
;		move.w	#0,leftEyeOffset
;		move.w	#0,rightEyeOffset
;.ok	
	rts

fixEyes
	move.l	screenpointer2,a0
	move.l	a0,usp
	jmp		fixEyesIndirect


generateChunkyFromPic_new		;12*16*199 = 38208 in 192 px width => 384 byte per line
;	lea		explode_pic+128,a0
	move.l	explodepic_pointer,a0
	add.l	#200*160+128,a0
	lea		160(a0),a0				; skip first line
	; 4*8 32 bytes offset left and right
	move.l	chunkyPicEvenPointer,a1
	move.l	chunkyPicUnEvenPointer,a2
	move.l	chunkyPicUnEvenPointer2,a3

	move.w	#199-1,d7		; 199 lines				
.doLine
	lea		24(a0),a0		; skip first 64 pixels
	move.w	#14-1,d6
.do16px
		movem.w	(a0)+,d0-d3		; 4 bitplanes
		REPT 16
;			moveq	#0,d4		; clear
			add.w	d3,d3
;			roxl.w	d3			; get bit plane4
			roxl.w	d4			; put bit plane4
			add.w	d2,d2
;			roxl.w	d2			; get pit plane3
			roxl.w	d4			; put bit plane3
			add.w	d1,d1
;			roxl.w	d1			; get bit plane2
			roxl.w	d4			; put bit plane2
			add.w	d0,d0
;			roxl.w	d0			; get bit plane1
			roxl.w	d4			; put bit plane1
			add.w	d4,d4	
			add.w	d4,d4		; *4
			move.w	d4,(a1)+	; store word <<2					16*2*14*199	= 89152
			lsl.w	#4,d4		; shift up a byte
			move.w	d4,(a2)+	; store word <<6					16*2*12*199		
			lsl.w	#4,d4		; shift up a byte
			move.w	d4,(a3)+	; store word <<6					16*2*12*199
		ENDR
		dbra	d6,.do16px
		lea		24(a0),a0		; skip last 64 pixels
	dbra	d7,.doLine
	; and now clear the rest		; 89152 done, 94080 used ==> 4928 cleared	= 1232 registers
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a0
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

	move.w	#112-1,d7
.ll
		movem.l	d0-d6/a0/a4/a5/a6,(a1)
		movem.l	d0-d6/a0/a4/a5/a6,(a2)
		movem.l	d0-d6/a0/a4/a5/a6,(a3)
		lea		11*4(a1),a1
		lea		11*4(a2),a2
		lea		11*4(a3),a3
		dbra	d7,.ll

	move.w	#140*4-1,d7
.ll2
		movem.l	d0-d6/a0/a4/a5/a6,(a3)
		lea		11*4(a3),a3
		dbra	d7,.ll2


	rts

;.skiplast8




;.y set 0
;	REPT 8
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR
;
;	REPT 64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7
;.off	set .y
;		normalLineSkipFirst8
;.y set .y+160
;	ENDR
;
;	REPT 7
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR
genUnrolledCode2
	move.l	unrolledCodePointer2,a6
	movem.l	ct1,d2-d7/a0-a4
;.y set 0
;	REPT 8
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR
;; normalLineSkipFirst8Short pattern:
;	off+8 lea 16 + .ct1 0,1,8,9,16,17,24 + lea 64

	move.w	#0,.var_y
	move.w	#8-1,d0
.gen1
		move.w	.var_y,.var_off
		add.w	#8,.var_off
		move.l	#$4DEE0000+16,(a6)+		;lea	16(a6),a6
		move.w	#3-1,d1
.lll	
			;0
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset	
			add.w	#1,.var_off
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset
			add.w	#7,.var_off

		dbra	d1,.lll	; 1,8; 9,16; 17;24						

		;24
		movem.l	d2-d7/a0-a4,(a6)		;
		lea		44(a6),a6				;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		move.w	.var_off,(a6)+			; offset	

		move.l	#$4DEE0000+64,(a6)+		;lea	64(a6),a6
		add.w	#160,.var_y
	dbra	d0,.gen1

;	REPT 64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7
;.off	set .y
;		normalLineSkipFirst8
;.y set .y+160
;	ENDR
;; normalLineSkipFirst8 pattern:
; .ct	(1,8,9,16,17,24,25,32),33 + lea 48
	move.w	#64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7-1,d0
.gen2
		move.w	.var_y,.var_off
		move.w	#4-1,d1
.lll2
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#1,.var_off
			move.w	.var_off,(a6)+			; offset	
			;8
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#7,.var_off		
			move.w	.var_off,(a6)+			; offset
		dbra	d1,.lll2

		;33
		movem.l	d2-d7/a0-a4,(a6)		;
		lea		44(a6),a6				;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		add.w	#1,.var_off
		move.w	.var_off,(a6)+			; offset	

		move.l	#$4DEE0000+48,(a6)+		;lea	48(a6),a6
		add.w	#160,.var_y
	dbra	d0,.gen2

;	REPT 7
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR	
	IFEQ	USE_MYM_DUMP
	move.w	#7-1,d0
.gen3
		move.w	.var_y,.var_off
		add.w	#8,.var_off
		move.l	#$4DEE0000+16,(a6)+		;lea	16(a6),a6
		move.w	#3-1,d1
.lll3	
			;0
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset	
			add.w	#1,.var_off
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset
			add.w	#7,.var_off

		dbra	d1,.lll3	; 1,8; 9,16; 17;24						

		;24
		movem.l	d2-d7/a0-a4,(a6)		;
		lea		44(a6),a6				;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		move.w	.var_off,(a6)+			; offset	



		move.l	#$4DEE0000+64,(a6)+		;lea	64(a6),a6
		add.w	#160,.var_y
	dbra	d0,.gen3
	ENDC
	move.w	#$4e75,(a6)+
	rts
.var_y		dc.w	0
.var_off	dc.w	0


genUnrolledCode1
	move.l	unrolledCodePointer1,a6
	movem.l	ct1,d2-d7/a0-a4
;.y set 0
;	REPT 8
;.off	set .y
;		normalLineSkipLast8Short	
;.y set .y+160
;	ENDR
	move.w	#0,.var_y
	move.w	#8-1,d0
.gen1
		move.w	.var_y,.var_off

		move.l	#$4DEE0000+16,(a6)+		;lea	16(a6),a6
		move.w	#3-1,d1
.lll	
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#1,.var_off
			move.w	.var_off,(a6)+			; offset	
			;8
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#7,.var_off
			move.w	.var_off,(a6)+			; offset

		dbra	d1,.lll	; 1,8; 9,16; 17;24

		;25
		movem.l	d2-d7/a0-a4,(a6)		;
		lea		44(a6),a6				;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		add.w	#1,.var_off
		move.w	.var_off,(a6)+			; offset	

		add.w	#160,.var_y
		move.l	#$4DEE0000+64,(a6)+			; lea 64(a6),a6
	dbra	d0,.gen1

;	REPT 64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7
;.off	set .y
;		normalLineSkipLast8
;
;.y set .y+160
;	ENDR
	move.w	#64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7-1,d0
.gen2
		move.w	.var_y,.var_off
		move.w	#4-1,d1
.lll2
			;0
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset	
			add.w	#1,.var_off
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			move.w	.var_off,(a6)+			; offset	
			add.w	#7,.var_off			

		dbra	d1,.lll2

		;32
		movem.l	d2-d7/a0-a4,(a6)			;
		lea		44(a6),a6					;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		move.w	.var_off,(a6)+				; offset	

		add.w	#160,.var_y
		move.l	#$4DEE0000+48,(a6)+			; lea 48(a6),a6		
	dbra	d0,.gen2


;
;	REPT 7
;.off	set .y
;		normalLineSkipLast8Short	
;.y set .y+160
;	ENDR
;.end

	IFEQ	USE_MYM_DUMP
	move.w	#7-1,d0
.gen3
		move.w	.var_y,.var_off

		move.l	#$4DEE0000+16,(a6)+		;lea	16(a6),a6
		move.w	#3-1,d1
.lll3
			;1
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#1,.var_off
			move.w	.var_off,(a6)+			; offset	
			;8
			movem.l	d2-d7/a0-a4,(a6)		;
			lea		44(a6),a6				;
			move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
			move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
			add.w	#7,.var_off
			move.w	.var_off,(a6)+			; offset

		dbra	d1,.lll3	; 1,8; 9,16; 17;24

		;25
		movem.l	d2-d7/a0-a4,(a6)		;
		lea		44(a6),a6				;
		move.l	#$22428691,(a6)+		;move.l	d2,a1		;or.l	(a1),d3 	
		move.l	#$4e6d07CD,(a6)+		;move.l	usp,a5 		;	movep.l
		add.w	#1,.var_off
		move.w	.var_off,(a6)+			; offset	

		add.w	#160,.var_y
		move.l	#$4DEE0000+64,(a6)+			; lea 64(a6),a6
	dbra	d0,.gen3
	ENDC
	move.w	#$4e75,(a6)+

;	move.l	unrolledCodePointer1,a0
;	sub.l	a0,a6
;	move.b	#0,$ffffc123
	rts
.var_y		dc.w	0
.var_off	dc.w	0
;;  normalLineSkipLast8Short
;	lea	16 .ct 1,(8,9,16,17,24,25) + lea 64
;; normalLineSkipLast8 pattern:
;	.ct1 (0,1,8,9,16,17,24,25),32 + lea 48
;; normalLineSkipFirst8Short pattern:
;	lea 16 + .ct1 0,1,8,9,16,17,24 + lea 64
;; normalLineSkipFirst8 pattern:
; .ct	(1,8,9,16,17,24,25,32),33 + lea 48
ct1
	movem.w	(a6)+,d3-d7/a0/a1/a5		;4	d2
	move.w	(a2,d3.w),d0				;4	d3
	add.w	(a3,d4.w),d0				;4	d4
	add.w	(a4,d5.w),d0				;4	d5
	move.w	(a2,d6.w),d1				;4	d6
	add.w	(a3,d7.w),d1				;4	d7
	add.w	(a4,a0.w),d1				;4	a0
	move.w	(a3,a1.w),d2				;4	a1
	add.w	(a4,a5.w),d2				;4	a2
	move.l	d0,a1						;2	a3
	move.l	(a1),d3						;2	
	move.l	d1,a1						;2	a4
	or.l	(a1),d3						;2	
	move.l	d2,a1						;2		;
	or.l	(a1),d3						;2		;8691
	move.l	usp,a5						;2		;4e6d
ct2
	movep.l	d3,1234(a5)					;4	d0		;07CDxxxx
;-----
	lea		48(a6),a6					;4	d1		;4DEEyyyy














normalLineSkipLast8Short	macro
		lea		16(a6),a6
		movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

		move.w	(a2,d3.w),d0				;16	
		add.w	(a3,d4.w),d0				;16
		add.w	(a4,d5.w),d0				;16
		move.w	(a2,d6.w),d1				;16
		add.w	(a3,d7.w),d1				;16
		add.w	(a4,a0.w),d1				;16
		move.w	(a3,a1.w),d2				;16									112
		add.w	(a4,a5.w),d2				;16									52

		move.l	d0,a1						;4
		move.l	(a1),d3						;12
		move.l	d1,a1						;4
		or.l	(a1),d3						;16
		move.l	d2,a1						;4	
		or.l	(a1),d3						;16									56

		move.l	usp,a5
		movep.l	d3,.off+1(a5)				;24									24	--> 506 per 16	===>	31,625
.off	set .off+8
		REPT 3
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5
			movep.l	d3,.off(a5)					;24									24
;----------------------------------d4,d5,d6,d7/a0
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5
			movep.l	d3,.off+1(a5)				;24									24	--> 506 per 16	===>	31,625
.off	set .off+8
		ENDR
		lea		48+16(a6),a6
	endm




normalLineSkipLast8	macro
		REPT 4
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5
			movep.l	d3,.off(a5)					;24									24
;----------------------------------d4,d5,d6,d7/a0
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5
			movep.l	d3,.off+1(a5)				;24									24	--> 506 per 16	===>	31,625
.off	set .off+8
		ENDR

			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off(a5)					;24									24
		lea		48(a6),a6
	endm

;; normalLineSkipFirst8Short pattern:
;	off+8 lea 16 + .ct1 0,1,8,9,16,17,24 + lea 64
normalLineSkipFirst8Short macro
			lea		16(a6),a6
.off set .off+8
		REPT 3
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off(a5)					;24									24
;----------------------------------d4,d5,d6,d7/a0
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off+1(a5)				;24									24	--> 506 per 16	===>	31,625
.off	set .off+8
		ENDR

			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off(a5)					;24									24

	lea		64(a6),a6
	endm


normalLineSkipFirst8 macro
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off+1(a5)					;24									24

.off set .off+8
		REPT 4
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off(a5)					;24									24
;----------------------------------d4,d5,d6,d7/a0
			movem.w	(a6)+,d3-d7/a0-a1/a5			;40		7	3*8+4*4 = 40			40

			move.w	(a2,d3.w),d0				;16	
			add.w	(a3,d4.w),d0				;16
			add.w	(a4,d5.w),d0				;16
			move.w	(a2,d6.w),d1				;16
			add.w	(a3,d7.w),d1				;16
			add.w	(a4,a0.w),d1				;16
			move.w	(a3,a1.w),d2				;16									112
			add.w	(a4,a5.w),d2				;16									52

			move.l	d0,a1						;4
			move.l	(a1),d3						;12
			move.l	d1,a1						;4
			or.l	(a1),d3						;16
			move.l	d2,a1						;4	
			or.l	(a1),d3						;16									56

			move.l	usp,a5

			movep.l	d3,.off+1(a5)				;24									24	--> 506 per 16	===>	31,625
.off	set .off+8
		ENDR

	lea		48(a6),a6
	endm

xPosition		dc.w	2*4*16
screenXOff		dc.w	7*8
screenXOffOld	dc.w	0
screenXOffOlder	dc.w	0
yoffsetOld		dc.w	0
yoffsetOlder	dc.w	0


c2p_1to1_indirect_offset_upper_highres_optimized_new
;	move.l	tab1px_1p,d0
;	move.l	tab1px_2p,d1
;	move.l	tab1px_3p,d2
;	move.l	chunkyPicUnEvenPointer2,a2
;	move.l	chunkyPicUnEvenPointer,a3
;	move.l	chunkyPicEvenPointer,a4
;	move.l	offsetsPointer,a6

	movem.l	tab1px_1p,d0/d1/d2/a2/a3/a4/a6

	move.w	screenXOff,d3
	move.w	screenXOffOld,screenXOffOlder
	move.w	d3,screenXOffOld
	lsl.w	#2,d3
	sub.w	chunkyMapOffset,d3
	add.w	d3,a2
	add.w	d3,a3
	add.w	d3,a4

	move.w	yoffset,d3
	move.w	yoffsetOld,yoffsetOlder
	move.w	d3,yoffsetOld
	addq.w	#2,d3
	move.w	d3,d4
	muls	#14*16*2,d4		;46	; 12*16*2 = 32*14 = 64 * 7		;32*14	448 = 256 + 128 + 64

	add.l	d4,a2
	add.l	d4,a3
	add.l	d4,a4

	lsl.w	#5,d3		;16
	move.w	d3,d4		;4
	add.w	d3,d3		;4
	add.w	d3,d3		;4
	add.w	d4,d3		;4
	add.w	#2*160+24,d3
	add.w	screenXOff,d3

	move.l	usp,a5
	add.w	d3,a5

;	lea		myOffsets+192,a6
	add.w	#192,a6
	add.w	chunkyMapOffset,a6

	
	move.l	a5,usp


	cmp.w	#16,chunkyMapOffset
	ble		.skipfirst8
		move.l	unrolledCodePointer1,a1
		jmp		(a1)
;.start
;.skiplast8
;.y set 0
;	REPT 8
;.off	set .y
;		normalLineSkipLast8Short	
;.y set .y+160
;	ENDR
;
;
;	REPT 64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7
;.off	set .y
;		normalLineSkipLast8
;
;.y set .y+160
;	ENDR
;
;	REPT 7
;.off	set .y
;		normalLineSkipLast8Short	
;.y set .y+160
;	ENDR
;.end

; 96 but we use 64+16 = 80
;;;;;;;;;;;;;;;;;;;;; this is the skip first 8 px part
.skipfirst8
	lea		16(a6),a6
	move.l	unrolledCodePointer2,a1
	jmp		(a1)
;.start2		
;.y set 0
;	REPT 8
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR
;
;	REPT 64-SKIP_LINES_TOP-SKIP_LINES_BOTTOM-8-7
;.off	set .y
;		normalLineSkipFirst8
;.y set .y+160
;	ENDR
;
;	REPT 7
;.off	set .y
;		normalLineSkipFirst8Short
;.y set .y+160
;	ENDR
;.end2

	; and where we need to fix some stuff left
;	move.l	a5,a1


.dddd
	rts


genTables
	move.l	ytablePointer,a0			;262*2
	sub.w	#62*2,a0
	move.w	#-62*160,d0
	move.w	#160,d1
	move.w	#62-1,d7
.o1
		move.w	d0,(a0)+
		add.w	d1,d0
	dbra	d7,.o1

	moveq	#0,d0
	move.w	#100-1,d7
.o2
		move.w	d0,(a0)+
		add.w	d1,d0
		move.w	d0,(a0)+
		add.w	d1,d0
	dbra	d7,.o2

	rts



restoreThing
;	move.l	screenpointer2,a0
	move.l	usp,a0
;	lea		explode_pic+128,a1
	move.l	explodepic_pointer,a1
	add.w	#200*160+128,a1
	move.w	screenXOffOlder,d0
	add.w	#3*8,d0
	add.w	d0,a0
	add.w	d0,a1
	move.l	ytablePointer,a2
	move.w	yoffsetOlder,d5
	add.w	d5,d5
	add.w	d5,a2
	add.w	(a2),a0
	add.w	(a2),a1

	tst.w	xdirOld
	bgt		.clearRight

	move.l	clearPointer,a2
	tst.w	d5
	bge		.ok
		neg.w	d5
		move.w	d5,d0
		add.w	d5,d5
		add.w	d5,d0
		add.w	d0,d0
		jmp		(a2,d0)
;		jmp		.ok(pc,d7)
.ok
		jmp		(a2)
;.y set -8
;	REPT 62
;		movem.l	.y(a1),d0-d3
;		movem.l	d0-d3,.y(a0)
;.y set .y+160
;	ENDR
;	rts

.clearRight
	move.l	clearPointer,a2
	add.w	#40,a0
	add.w	#40,a1
	tst.w	d5
	bge		.ok2
		neg.w	d5
		move.w	d5,d0
		add.w	d5,d5
		add.w	d5,d0
		add.w	d0,d0
		jmp		(a2,d0)
.ok2
		jmp		(a2)
;.y set 32
;	REPT 62
;		movem.l	.y(a1),d0-d3
;		movem.l	d0-d3,.y(a0)
;.y set .y+160
;	ENDR
;	rts

genClears
	move.l	clearPointer,a0
	move.l	.tmp1,d0
	move.l	.tmp2,d1
	move.w	#-8,d2
	move.w	#160,d3
	move.w	#62-1,d7
.doLine
		move.l	d0,(a0)+
		move.w	d2,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		add.w	d3,d2
	dbra	d7,.doLine
	move.w	#$4e75,(a0)+
	rts
.tmp1
		movem.l	1234(a1),d0-d3
.tmp2
		movem.l	d0-d3,1234(a0)



xdirOlder	dc.w	0
xdirOld		dc.w	0




generatexPositionTab
	move.l	xPositionTabPointer,a0
	moveq	#0,d0
	move.w	#30,d1
	move.w	#11-1,d7
.ol
		move.w	d1,d2
		move.w	#16-1,d6
.il
			move.w	d0,(a0)+
			move.w	d2,(a0)+
			subq.w	#2,d2
		dbra	d6,.il
		addq.w	#8,d0
	dbra	d7,.ol
	rts



;
;	tst.w	xdir
;	blt		.right
;.left
;	subq.w	#2,xPosition
;	add.w	#4,chunkyMapOffset
;	cmp.w	#32,chunkyMapOffset
;	bne		.endx
;		move.w	#0,chunkyMapOffset
;		subq.w	#1,screenXOff
;		bge		.endx
;			move.w	xPosition,d0
;			move.w	chunkyMapOffset,d1
;			move.w	screenXOff,d2
;			move.b	#0,$ffffc123
;			neg.w	xdir
;			move.w	#30,chunkyMapOffset
;			move.w	#0,screenXOff
;			jmp		.endx
;
;.right
;	addq.w	#2,xPosition
;	sub.w	#4,chunkyMapOffset
;	bge		.endx
;		move.w	#30,chunkyMapOffset
;		add.w	#1,screenXOff
;		cmp.w	#10,screenXOff
;		bne		.endx
;			move.w	xPosition,d0
;			move.w	chunkyMapOffset,d1
;			move.w	screenXOff,d2
;			move.b	#0,$ffffc123
;			move.w	#0,chunkyMapOffset
;			move.w	#9,screenXOff
;			neg.w	xdir
;.endx
;	rts




;;;;;;;;;;; code for opening

init_explode_scrollin
;	movem.l	explode_pic+4,d0-d7
;	movem.l	d0-d7,$ffff8240
	move.w	#$777,timer_b_open_curtain+2
	move.w	#$2700,sr
	move.l	#explode_scrollin_vbl,$70
	move.w	#$2300,sr
	rts

explode_scrollin_vbl
	move.l	screenpointer2,$ffff8200
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount


	;Start up Timer B each VBL
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#timer_b_open_curtain_stable,$120.w
	move.b	#183,$fffffa21.w		;Timer B data
	move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt      

	pushall

	lea		scrollPal,a0
	add.w	scrollPalOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	move.w	#0,$ffff8240
	subq.w	#1,.scrollWaiter
	bge		.kk
		move.w	#5,.scrollWaiter
		add.w	#32,scrollPalOff
		cmp.w	#7*32,scrollPalOff
		ble		.kk
			move.w	#7*32,scrollPalOff
.kk


;	jsr		calcTimerBVals
	jsr		scrollInExplode
			swapscreens
	IFEQ	USE_MYM_DUMP
		jsr		replayMymDump
	ELSE
		IFNE	STANDALONE
		jsr		musicPlayer+8
		ENDC
	ENDC

	popall
	rte
.scrollWaiter	dc.w	30

scrollPalOff	dc.w	0

scrollPal
	dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
	dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
	dc.w	$0777,$0767,$0777,$0777,$0777,$0777,$0777,$0777
	dc.w	$0666,$0777,$0766,$0666,$0777,$0777,$0777,$0777
	dc.w	$0777,$0756,$0766,$0776,$0777,$0777,$0777,$0777
	dc.w	$0555,$0666,$0766,$0666,$0777,$0777,$0777,$0766
	dc.w	$0777,$0645,$0755,$0765,$0776,$0777,$0777,$0777
	dc.w	$0444,$0666,$0766,$0666,$0777,$0776,$0666,$0655
	dc.w	$0777,$0534,$0744,$0754,$0765,$0776,$0777,$0777
	dc.w	$0333,$0666,$0655,$0555,$0777,$0665,$0555,$0544
	dc.w	$0777,$0423,$0633,$0743,$0754,$0765,$0776,$0777
	dc.w	$0222,$0666,$0655,$0555,$0666,$0554,$0444,$0433
	dc.w	$0777,$0312,$0522,$0732,$0743,$0754,$0765,$0776
	dc.w	$0111,$0666,$0655,$0555,$0555,$0443,$0333,$0322
	dc.w	$0777,$0201,$0411,$0621,$0632,$0743,$0754,$0765
	dc.w	$0000,$0666,$0655,$0555,$0444,$0332,$0222,$0211

;smfxpaltop
;	dc.w	$777,$666,$774,$762,$751,$640,$730,$710,$600,$362,$242,$132,$222,$112,$111,$001

genScroller
	move.l	scrollerPointer,a0
	move.w	#200-1,d7
	movem.l	.tmp,d0-d1	
	moveq	#2,d2
	move.w	#40,d3
.doline
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		add.w	d3,d2
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		add.w	d3,d2
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		add.w	d3,d2
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.w	d2,(a0)+
		add.w	d3,d2
	dbra	d7,.doline
	move.w	#$4e75,(a0)+
	rts
.tmp
			movem.l	(a0)+,d0-d7/a2-a3				;4	
			movem.l	d0-d7/a2-a3,1234(a1)				;6		10*4*200 = 8000


scrollInExplode
;	lea		explode_pic+128+160,a0
	move.l	explodepic_pointer,a0
	add.l	#128+160,a0
	move.l	screenpointer2,a1

	; only diffence is a1 offset
	move.w	yoffset,d0
	bge		.okxxx
.isneg
;		move.b	#0,$ffffc123
		move.w	#1,d1
		neg.w	d0
		muls	#160,d0
		add.w	d0,a0
	jmp	.conttt
.okxxx

	move.w	d0,d1			
	addq.w	#1,d0
;	muls	#160,d0
	lsl.w	#5,d0		; 
	move.w	d0,d2		;32
	add.w	d0,d0		
	add.w	d0,d0		
	add.w	d2,d0
	add.w	d0,a1

	move.w	d1,d2
	muls	#160,d2
	sub.w	d2,a1
.conttt
	sub.w	#2,a1
	muls	#40,d1
	move.l	scrollerPointer,a2
	jsr		(a2,d1)
;	jmp		.jmplala(pc,d1)
;.jmplala
;.x set 2
;	REPT 200
;		REPT 4	
;			movem.l	(a0)+,d0-d7/a2-a3				;4	
;			movem.l	d0-d7/a2-a3,.x(a1)				;6		10*4*200 = 8000
;.x set .x+40
;		ENDR
;	ENDR
	lea		sublist,a0
	add.w	suboff,a0
	add.w	#2,suboff
	cmp.w	#250,suboff
	ble		.kkk
		move.w	#250,suboff
.kkk
	move.w	(a0),d0
	sub.w	d0,yoffset
	cmp.w	#-200,yoffset
	bge		.ok
;		move.w	#0,yoffset
		move.w	#-200,yoffset
		subq.w	#1,_times
		bge		.ok
			move.w	#$4e75,scrollInExplode
.ok
	rts
sublist
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3			;35*2 = 70
	REPT 	58		; 45*2 = 90
		dc.w	4
	ENDR
	dc.w	4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1	;4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
suboff		dc.w	0
_times		dc.w	3
;;;;;;;;;;;; TEST CODE FOR PALETTES


xtable	
.offset set 0
	REPT 16
		dc.w	.offset			; source
		dc.w	0				; dest
.offset set .offset+11*8*2
	ENDR
.offset set 0
	REPT 16
		dc.w	.offset			; source
		dc.w	8				; dest				;32*4	=	128
.offset set .offset+11*8*2
	ENDR

xtableRight
.offset set 0
	REPT 16
		dc.w	.offset			; source
		dc.w	0				; dest
.offset set .offset+10*8*2
	ENDR
.offset set 0
	REPT 16
		dc.w	.offset			; source
		dc.w	8				; dest				;32*4	=	128
.offset set .offset+10*8*2
	ENDR

initEyeGenLeft
	lea		spriteLeft,a0
	move.l	eyeSpritesPointer,a1
	move.w	#11-1,d7
.cp
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.cp

	move.l	eyeSpritesPointer,a0
	move.l	a0,a1
	add.w	#11*8*2,a1
	jsr		shift15

		move.w	#41-1,.times
.again
		lea		movementLeft,a0
		add.w	movementOff,a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		add.w	#4,movementOff
		cmp.w	#41*4,movementOff
		bne		.ok
			move.w	#0,movementOff
.ok	
		jsr		genEyeFrameLeft
		subq.w	#1,.times
		bge		.again

	move.w	#0,movementOff
	move.w	#0,leftEyeOffset
	move.w	#0,chunkyEyeOffset

	rts
.times	dc.w	0

initEyeGenRight
	move.w	#0,movementOff
	move.w	#0,chunkyEyeOffset

	lea		spriteRight,a0
	move.l	eyeSpritesPointer,a1
	move.w	#11-1,d7
.cp
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.cp

	move.l	eyeSpritesPointer,a0
	move.l	a0,a1
	add.w	#10*8*2,a1
	jsr		shift1510

		move.w	#41-1,.times
.again
		lea		movementLeft,a0
		add.w	movementOff,a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		subq.w	#1,d0
		subq.w	#1,d1
		add.w	#4,movementOff
		cmp.w	#41*4,movementOff
		bne		.ok
			move.w	#0,movementOff
.ok	
		jsr		genEyeFrameRight
		subq.w	#1,.times
		bge		.again


	rts
.times	dc.w	0


genEyeFrameRight
	; first clear the canvas
	jsr		clearCanvasRight

	; draw the eye onto the canvas
	add.w	d0,d0
	add.w	d0,d0
	lea		xtableRight,a2
	add.w	d0,a2					
	move.l	eyeSpritesPointer,a0
	add.w	(a2)+,a0				; +offset source
	move.l	canvasPointer,a1
	add.w	(a2)+,a1				; +offset dest
	lsl.w	#4,d1
	sub.w	#32,d1
	add.w	d1,a1					; +y offset dest
	jsr		doCopyPart10
	jsr		doMaskAndEyeRight
	jsr		makeChunkyRight
	
	move.l	screenpointer2,a0
	move.l	canvasPointer,a1
	add.w	#10*2*8,a1
	move.l	rightEyeBufferPointer,a2
	add.w	rightEyeOffset,a2
.y set 0
.y2 set 0
	REPT 10
		movem.l	(a1)+,d0-d3
		movem.l	d0-d3,.y2(a2)
.y set .y+160
.y2 set .y2+16
	ENDR
	add.w	#10*16,rightEyeOffset
	rts	



genEyeFrameLeft
	; first clear the canvas
	jsr		clearCanvas

	; draw the eye onto the canvas
	add.w	d0,d0
	add.w	d0,d0
	lea		xtable,a2
	add.w	d0,a2
	move.l	eyeSpritesPointer,a0
	add.w	(a2)+,a0				; +offset source
	move.l	canvasPointer,a1
	add.w	(a2)+,a1				; +offset dest
	lsl.w	#4,d1
	add.w	d1,a1					; +y offset dest
	jsr		doCopyPart
	jsr		doMaskAndEye
	jsr		makeChunky

	move.l	screenpointer2,a0
	move.l	canvasPointer,a1
	add.w	#11*2*8,a1
	move.l	leftEyeBufferPointer,a2
	add.w	leftEyeOffset,a2
.y set 0
.y2 set 0
	REPT 11
		movem.l	(a1)+,d0-d3
		movem.l	d0-d3,.y2(a2)
.y set .y+160
.y2 set .y2+16
	ENDR

	add.w	#11*16,leftEyeOffset
	rts




; left eye
;	 1,2,3,4,5,6,7,8,9,a,b,c,d,e,f		15x11
;	
;1	0,0,0,0,0,0,0,1,1,0,0,0,0,0,0
;2	0,0,0,0,0,1,1,1,1,1,1,0,0,0,0
;3	0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
;4	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
;5	0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
;6	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;7	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;8	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
;9	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0
;a	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0
;b	0,0,0,0,0,0,1,1,1,1,1,0,0,0,0

;	s7,d2:	s7						11*15 = 165,	left: 2+6+9+12+15+14+12+10+9+5 = 94
;	s5,d6	
;	s3,d9
;	s2,d12
;	d15
;	s1,d14
;	s2,d12
;	s3,d10
;	s4,d9
;	s6,d5


makeChunky
	; this thing makes the chunky, from template I would reckon
	move.l	canvasPointer,a0
	add.w	#11*2*8,a0
	lea		leftEyeDefs,a2
	move.l	leftEyeChunky1Pointer,a3
	add.w	chunkyEyeOffset,a3
	move.l	leftEyeChunky2Pointer,a4
	add.w	chunkyEyeOffset,a4
	move.l	leftEyeChunky3Pointer,a5
	add.w	chunkyEyeOffset,a5
	add.w	#220,chunkyEyeOffset
	jmp		.doScanLine
.doScanLine22
	add.w	#8,a0
.doScanLine
	movem.w	(a0)+,d0-d3
	move.w	(a2)+,d7
	beq		.end

	lsl.w	d7,d0
	lsl.w	d7,d1
	lsl.w	d7,d2
	lsl.w	d7,d3
	
	move.w	(a2)+,d7

.loop
		add.w	d3,d3
		roxl.w	d4
		add.w	d2,d2
		roxl.w	d4
		add.w	d1,d1
		roxl.w	d4
		add.w	d0,d0
		roxl.w	d4
		add.w	d4,d4
		add.w	d4,d4
		move.w	d4,(a3)+
		lsl.w	#4,d4		
		move.w	d4,(a4)+		
		lsl.w	#4,d4		
		move.w	d4,(a5)+	
	dbra	d7,.loop

	move.w	(a2)+,d7
	blt		.doScanLine22
	movem.w	(a0)+,d0-d3
.loop2
		add.w	d3,d3
		roxl.w	d4
		add.w	d2,d2
		roxl.w	d4
		add.w	d1,d1
		roxl.w	d4
		add.w	d0,d0
		roxl.w	d4
		add.w	d4,d4
		add.w	d4,d4
		move.w	d4,(a3)+
		lsl.w	#4,d4		
		move.w	d4,(a4)+		
		lsl.w	#4,d4		
		move.w	d4,(a5)+	
	dbra	d7,.loop2
	jmp		.doScanLine
.end	
	rts


leftEyeDefs	
	dc.w	12,2-1,0-1		;2
	dc.w	10,6-1,0-1		;6		+1
	dc.w	8,8-1,2-1		;10		+1
	dc.w	7,9-1,3-1		;12		
	dc.w	6,10-1,4-1		;14
	dc.w	5,11-1,5-1		;16
	dc.w	6,10-1,4-1		;14
	dc.w	7,9-1,3-1		;12
	dc.w	8,8-1,2-1		;10
	dc.w	9,7-1,1-1		;8
	dc.w	11,5-1,1-1		;6			110
	dc.w	0

chunkyEyeOffset2	dc.w	0

makeChunkyRight
	move.l	canvasPointer,a0
	add.w	#10*2*8,a0
	lea		rightEyeDefs,a2
	move.l	rightEyeChunky1Pointer,a3
	add.w	chunkyEyeOffset2,a3
	move.l	rightEyeChunky2Pointer,a4
	add.w	chunkyEyeOffset2,a4
	move.l	rightEyeChunky3Pointer,a5
	add.w	chunkyEyeOffset2,a5
	add.w	#220,chunkyEyeOffset2
	; line 1
	jmp		.doScanLine
.doScanLine22
	add.w	#8,a0
.doScanLine
	movem.w	(a0)+,d0-d3
	move.w	(a2)+,d7
	beq		.end

	lsl.w	d7,d0
	lsl.w	d7,d1
	lsl.w	d7,d2
	lsl.w	d7,d3
	
	move.w	(a2)+,d7

.loop
		add.w	d3,d3
		roxl.w	d4
		add.w	d2,d2
		roxl.w	d4
		add.w	d1,d1
		roxl.w	d4
		add.w	d0,d0
		roxl.w	d4
		add.w	d4,d4
		add.w	d4,d4
		move.w	d4,(a3)+
		lsl.w	#4,d4		
		move.w	d4,(a4)+		
		lsl.w	#4,d4		
		move.w	d4,(a5)+	
	dbra	d7,.loop

	move.w	(a2)+,d7
	blt		.doScanLine22
	movem.w	(a0)+,d0-d3
.loop2
		add.w	d3,d3
		roxl.w	d4
		add.w	d2,d2
		roxl.w	d4
		add.w	d1,d1
		roxl.w	d4
		add.w	d0,d0
		roxl.w	d4
		add.w	d4,d4
		add.w	d4,d4
		move.w	d4,(a3)+
		lsl.w	#4,d4		
		move.w	d4,(a4)+		
		lsl.w	#4,d4		
		move.w	d4,(a5)+	
	dbra	d7,.loop2
	jmp		.doScanLine
.end	
	rts


; right eye								15x10 = 15
;
;	1,2,3,4,5,6,7,8,9,a,b,c,d,e,f
;1	0,0,0,0,0,0,1,1,1,1,0,0,0,0,0		6+5=11		4/2
;2	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0		4+5=9		8/4
;3	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0		3+5=8		10/5
;4	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0		2+5=7		12/6
;5	0,1,1,1,1,1,1,1,1,1,1,1,1,1,0		1+5=6		14/7	
;6	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1		1+5=6		14/7
;7	1,1,1,1,1,1,1,1,1,1,1,1,1,1,0		0+5=5		14/7
;8	0,1,1,1,1,1,1,1,1,1,1,1,1,0,0		1+5=6		12/6
;9	0,0,1,1,1,1,1,1,1,1,1,0,0,0,0		2+5=7		10/5
;a	0,0,0,0,1,1,1,1,1,1,0,0,0,0,0		4+5=9		6/3

rightEyeDefs
	dc.w	11,4-1,0-1
	dc.w	9,7-1,1-1
	dc.w	8,8-1,2-1
	dc.w	7,9-1,3-1
	dc.w	6,10-1,4-1
	dc.w	6,10-1,4-1
	dc.w	5,11-1,3-1
	dc.w	6,10-1,2-1
	dc.w	7,9-1,1-1
	dc.w	9,6-1,0-1
	dc.w	0
 
doMaskAndEye
	lea		maskLeft,a0
	lea		faceLeft,a1
	move.l	canvasPointer,a2
	add.w	#11*2*8,a2
	move.w	#11-1,d7
.maskLine
		movem.l	(a0)+,d0-d3		; mask
		and.l	d0,(a2)			; apply mask
		move.l	(a1)+,d0		; face
		or.l	d0,(a2)+		; apply face

		and.l	d1,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+

		and.l	d2,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+

		and.l	d3,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+
	dbra	d7,.maskLine
	rts

doMaskAndEyeRight
	lea		maskRight,a0
	lea		faceRight,a1
	move.l	canvasPointer,a2
	add.w	#10*2*8,a2
	move.w	#10-1,d7
.maskLine
		movem.l	(a0)+,d0-d3		; mask
		and.l	d0,(a2)			; apply mask
		move.l	(a1)+,d0		; face
		or.l	d0,(a2)+		; apply face

		and.l	d1,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+

		and.l	d2,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+

		and.l	d3,(a2)
		move.l	(a1)+,d0
		or.l	d0,(a2)+
	dbra	d7,.maskLine
	rts

doCopyPart
	move.w	#11-1,d7
.copyLine
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.copyLine
	rts

doCopyPart10
	move.w	#10-1,d7
.copyLine
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.copyLine
	rts

clearCanvas
	move.l	canvasPointer,a0
	add.w	#11*2*8,a0
	moveq	#0,d7
	move.w	#11-1,d6
.cl
	REPT 4
		move.l	d7,(a0)+
	ENDR
	dbra	d6,.cl
	rts

clearCanvasRight
	move.l	canvasPointer,a0
	add.w	#10*2*8,a0
	moveq	#0,d7
	move.w	#10-1,d6
.cl
	REPT 4
		move.l	d7,(a0)+
	ENDR
	dbra	d6,.cl
	rts

shift15
	move.w	#15-1,.times
.doTime
.y set 0
	REPT 11
		movem.w	(a0)+,d0-d7
		roxr.w	d0
		roxr.w	d4
	
		roxr.w	d1
		roxr.w	d5
	
		roxr.w	d2
		roxr.w	d6
	
		roxr.w	d3
		roxr.w	d7
		movem.w	d0-d7,.y(a1)
.y set .y+16
	ENDR
	lea		16*11(a1),a1
	subq.w	#1,.times
	bge		.doTime
	rts
.times dc.w	0

shift1510
	move.w	#15-1,.times
	moveq	#0,d0
	roxr.w	d0
.doTime
.y set 0
	REPT 10
		movem.w	(a0)+,d0-d7
		roxr.w	d0
		roxr.w	d4
	
		roxr.w	d1
		roxr.w	d5
	
		roxr.w	d2
		roxr.w	d6
	
		roxr.w	d3
		roxr.w	d7
		movem.w	d0-d7,.y(a1)
.y set .y+16
	ENDR
	lea		16*10(a1),a1
	subq.w	#1,.times
	bge		.doTime
	rts
.times dc.w	0



	SECTION DATA
	IFEQ	GENERATE_EYES
prepExplodeEyes
	lea		explode_eyes+128,a0
	lea		faceLeft,a1
	jsr		copyFirst

	; generate mask
	lea		explode_eyes+128+11*160,a0
	lea		maskLeft,a1
	jsr		copyFirst

	; generate eye sprites
	lea		explode_eyes+128+22*160,a0
	lea		spriteLeft,a1
	jsr		copyFirst


	lea		explode_eyes+128+40*160,a0
	lea		faceRight,a1
	jsr		copyFirst10

	; generate mask
	lea		explode_eyes+128+50*160,a0
	lea		maskRight,a1
	jsr		copyFirst10

	; generate eye sprites
	lea		explode_eyes+128+62*160,a0
	lea		spriteRight,a1
	jsr		copyFirst10	

	jmp		prepAni

smfxani			incbin	"data/lens/smfxani.neo"
smfxanibuffer	ds.b	20*8*3*13
prepAni
	lea		smfxani+128,a0
	lea		smfxanibuffer,a1
.z set 0
	REPT 15
.y set .z
		REPT 13
.x set .y
			REPT 3
				move.l	.x(a0),(a1)+
				move.l	.x+4(a0),(a1)+
.x set .x+8
			ENDR
.y set .y+160
		ENDR
.z set .z+13*160
	ENDR


.z set 3*8
	REPT 5
.y set .z
		REPT 13
.x set .y
			REPT 3
				move.l	.x(a0),(a1)+
				move.l	.x+4(a0),(a1)+
.x set .x+8
			ENDR
.y set .y+160
		ENDR
.z set .z+13*160
	ENDR

	move.b	#0,$ffffc123
	lea		smfxanibuffer,a0
	lea		spriteLeft,a0
	lea		faceLeft,a0
	lea		maskLeft,a0
	lea		spriteRight,a0
	lea		maskRight,a0
	lea		faceRight,a0
	rts

copyFirst
.y set 0
.y2 set 0
	REPT 11
		movem.l	.y(a0),d0-d3
		movem.l	d0-d3,.y2(a1)
.y set .y+160
.y2 set .y2+16
	ENDR
	rts

copyFirst10
.y set 0
.y2 set 0
	REPT 10
		movem.l	.y(a0),d0-d3
		movem.l	d0-d3,.y2(a1)
.y set .y+160
.y2 set .y2+16
	ENDR
	rts

spriteLeft	ds.b	11*16		
faceLeft	ds.b	11*16
maskLeft	ds.b	11*16

spriteRight	ds.b	10*16
maskRight	ds.b	10*16
faceRight	ds.b	10*16


explode_pic	
explode_eyes		incbin	"data/lens/explode-eye.neo"

	ELSE
; CAREFUL HERE WE CAN CLEAR ANOTHER 4400 BYTES, BY CRUNCHING SPACE, AND CHANGE PRECALC STUFF

;directory
;	incbin	data/lens/out.tos
;	include	data/lens/flare3.s			;10952



spriteLeft		incbin	"data/lens/spriteleft.bin"							; 176
faceLeft		incbin	"data/lens/faceleft.bin"							; 176
maskLeft		incbin	"data/lens/maskLeft.bin"							; 176
spriteRight		incbin	"data/lens/spriteright.bin"							; 160
maskRight		incbin	"data/lens/maskright.bin"							; 160
faceRight		incbin	"data/lens/faceright.bin"							; 160
animation		;incbin	"data/lens/animation.bin"
				incbin	"data/lens/smfxani.crk"								;2167
	even
explode_pic		
flarecrk
	incbin	data/lens/flare.crk
	even

	ENDC
	IFEQ	GENERATE_OFFSMAP
tga					incbin	"data/lens/gen160x100.tga"						;	
	ELSE
offsetsrc			incbin	"data/lens/lensoffsmap.crk"						;				11288
	even
	ENDC
explode_src		
;			incbin	"data/lens/explode.crk"							;32128		/ 	18219		--> 
			incbin	"gfx/explode/explode-merge.crk"
	even

spiral		;incbin	"data/lens/spiral.bin"
		;	include "data/lens/spiral.s"
			include "data/lens/t.s"											;1736


			IFEQ	STANDALONE
TAB1:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$C0,$00,$00,$00		;4
	dc.b	$00,$C0,$00,$00		;8
	dc.b	$C0,$C0,$00,$00		;12
	dc.b	$00,$00,$C0,$00		;16
	dc.b	$C0,$00,$C0,$00		;20
	dc.b	$00,$C0,$C0,$00		;24
	dc.b	$C0,$C0,$C0,$00		;28
	dc.b	$00,$00,$00,$C0		;32
	dc.b	$C0,$00,$00,$C0		;36
	dc.b	$00,$C0,$00,$C0		;40
	dc.b	$C0,$C0,$00,$C0		;44
	dc.b	$00,$00,$C0,$C0		;48
	dc.b	$C0,$00,$C0,$C0		;52
	dc.b	$00,$C0,$C0,$C0		;56
	dc.b	$C0,$C0,$C0,$C0		;60
TAB2:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$30,$00,$00,$00		;4
	dc.b	$00,$30,$00,$00		;8
	dc.b	$30,$30,$00,$00		;12
	dc.b	$00,$00,$30,$00		;16
	dc.b	$30,$00,$30,$00		;20
	dc.b	$00,$30,$30,$00		;24
	dc.b	$30,$30,$30,$00		;28
	dc.b	$00,$00,$00,$30		;32
	dc.b	$30,$00,$00,$30		;36
	dc.b	$00,$30,$00,$30		;40
	dc.b	$30,$30,$00,$30		;44
	dc.b	$00,$00,$30,$30		;48
	dc.b	$30,$00,$30,$30		;52
	dc.b	$00,$30,$30,$30		;56
	dc.b	$30,$30,$30,$30		;60
TAB3:
	DC.B	$00,$00,$00,$00		;0
	dc.b	$0C,$00,$00,$00		;4
	dc.b	$00,$0C,$00,$00		;8
	dc.b	$0C,$0C,$00,$00		;12
	dc.b	$00,$00,$0C,$00		;16
	dc.b	$0C,$00,$0C,$00		;20
	dc.b	$00,$0C,$0C,$00		;24
	dc.b	$0C,$0C,$0C,$00		;28
	dc.b	$00,$00,$00,$0C		;32
	dc.b	$0C,$00,$00,$0C		;36
	dc.b	$00,$0C,$00,$0C		;40
	dc.b	$0C,$0C,$00,$0C		;44
	dc.b	$00,$00,$0C,$0C		;48
	dc.b	$0C,$00,$0C,$0C		;52
	dc.b	$00,$0C,$0C,$0C		;56
	dc.b	$0C,$0C,$0C,$0C		;60
TAB4:
	dc.b	$00,$00,$00,$00		;0
	dc.b	$03,$00,$00,$00		;4
	dc.b	$00,$03,$00,$00		;8
	dc.b	$03,$03,$00,$00		;12
	dc.b	$00,$00,$03,$00		;16
	dc.b	$03,$00,$03,$00		;20
	dc.b	$00,$03,$03,$00		;24
	dc.b	$03,$03,$03,$00		;28
	dc.b	$00,$00,$00,$03		;32
	dc.b	$03,$00,$00,$03		;36
	dc.b	$00,$03,$00,$03		;40
	dc.b	$03,$03,$00,$03		;44
	dc.b	$00,$00,$03,$03		;48
	dc.b	$03,$00,$03,$03		;52
	dc.b	$00,$03,$03,$03		;56
	dc.b	$03,$03,$03,$03		;60
	ENDC
;;;;;;;;;;; optimized code shit
	
	IFEQ	STANDALONE
		include		lib.s
		include		cranker.s
		include		lib/mymdump.s
		include		musicplayer.s
	ENDC

explodepic_pointer			ds.l	1

tab1px_1p					ds.l	1
tab1px_2p					ds.l	1
tab1px_3p					ds.l	1
chunkyPicUnEvenPointer2		ds.l	1
chunkyPicUnEvenPointer		ds.l	1
chunkyPicEvenPointer		ds.l	1
offsetsPointer				ds.l	1

unrolledCodePointer1		ds.l	1
unrolledCodePointer2		ds.l	1
scrollerPointer				ds.l	1
ytablePointer				ds.l	1
clearPointer				ds.l	1
leftEyeBufferPointer		ds.l	1
rightEyeBufferPointer		ds.l	1
leftEyeChunky1Pointer		ds.l	1
leftEyeChunky2Pointer		ds.l	1
leftEyeChunky3Pointer		ds.l	1
rightEyeChunky1Pointer		ds.l	1
rightEyeChunky2Pointer		ds.l	1
rightEyeChunky3Pointer		ds.l	1
canvasPointer				ds.l	1
eyeSpritesPointer			ds.l	1
xeyesYPointer				ds.l	1
xeyesLeftXPointer			ds.l	1
xeyesRightXPointer			ds.l	1
xPositionTabPointer			ds.l	1
animationPointer			ds.l	1
musicBufferPointer			ds.l	1
directoryPointer			ds.l	1
haxEye						ds.b	10*16
; general stuff
	IFEQ	STANDALONE
	SECTION BSS
membase						ds.b	700*1024			; 750kb needed so far
screenpointer				ds.l	1
screenpointer2				ds.l	1
screen1:					ds.l	1
screen2:					ds.l	1
musicInit					ds.w	1
cummulativeCount			ds.w	1



;canvasLeft	ds.b	3*11*2*8		; 33*32 px, 3 parts, 4 bitplanes					;528
;maskLeft	ds.b	11*2*8			; 11*32 px, 1 part, 4 bitplanes	mask for face		;176
;faceLeft	ds.b	11*2*8			; 11*32 px, 1 part, 4 bitplanes face				;176
;eyeSprites	ds.b 	11*8*2*16		; y=11, x=32 (2 blocks), 16 versions				;2816

;canvasRight		ds.b	3*10*2*8		; 33*32 px, 3 parts, 4 bitplanes					;528
;maskRight		ds.b	10*2*8			; 11*32 px, 1 part, 4 bitplanes	mask for face		;176
;faceRight		ds.b	10*2*8			; 11*32 px, 1 part, 4 bitplanes face				;176
;eyeSpritesRight	ds.b 	10*8*2*16		; y=11, x=32 (2 blocks), 16 versions				;2816

; 43 frames max!

;leftEyeBuffer	ds.b	11*16*40	;	7040
;rightEyeBuffer	ds.b	10*16*40	;	6400

						
;leftEyeChunky1	ds.b	220*40		;8800
;leftEyeChunky2	ds.b	220*40		;8800
;leftEyeChunky3	ds.b	220*40		;8800
;rightEyeChunky1	ds.b	220*40		;8800
;rightEyeChunky2	ds.b	220*40		;8800
;rightEyeChunky3	ds.b	220*40		;8800		52800



	ENDC


; left eye
;	 1,2,3,4,5,6,7,8,9,a,b,c,d,e,f		15x11
;
;1	0,0,0,0,0,0,0,1,1,0,0,0,0,0,0
;2	0,0,0,0,0,1,1,1,1,1,1,0,0,0,0
;3	0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
;4	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
;5	0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
;6	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;7	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;8	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
;9	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0
;a	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0
;b	0,0,0,0,0,0,1,1,1,1,1,0,0,0,0

;	s7,d2			11*15 = 165,	left: 2+6+9+12+15+14+12+10+9+5 = 94
;	s5,d6
;	s3,d9
;	s2,d12
;	d15
;	s1,d14
;	s2,d12
;	s3,d10
;	s4,d9
;	s6,d5

;
; right eye								15x10 = 15
;
;	1,2,3,4,5,6,7,8,9,a,b,c,d,e,f
;1	0,0,0,0,0,0,1,1,1,1,0,0,0,0,0
;2	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0
;3	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0
;4	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
;5	0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
;6	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;7	1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
;8	0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
;9	0,0,1,1,1,1,1,1,1,1,1,0,0,0,0
;a	0,0,0,0,1,1,1,1,1,1,0,0,0,0,0
;
;	s6,d4
;	s4,d8
;	s3,d10
;	s2,d12
;	s1,d13
;	s1,d14
;	d14
;	s1,d12
;	s2,d9
;	s4,d7							; 103

; eye placements:
;	
;	9	10	11	12	13	14	15
;	32	1	2	3	4	5	16
;	31	40				6	17
;	30	39		0		7	18
;	29	38				8	19
;	28	37	36	35	34	33	20
;	27	26	25	24	23	22	21
;
;	

;	x,y - 9,13	;left
;	x,y	- 8,12
