; todo:
; generate a route tab for copying lines
; - different width sizes for resuse
;
;
;
;
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
loadmusic					equ true
PLAYMUSIC					equ true
playmusicinvbl				equ true
loadpals					equ false
	ENDC



calcTabMetaRout		equ calcTabMeta
c2pGenerated		equ true

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx
	incdir	fx/plasma

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
		jsr		loadMusic
		tst.w	fail
		bne		.exit
	ENDC	

	move.l	#music,sndh_pointer

	IFEQ loadpals
	jmp	gogo

pal1filename	dc.b 	"pal1.pal",0
pal2filename	dc.b 	"pal2.pal",0
pal3filename	dc.b 	"pal3.pal",0
	even

gogo
		move.l	#pal1filename,d0
		move.l	#pal1fadex,d1
		jsr		loadFile
		tst.w	fail
		bne		exit

		move.l	#pal2filename,d0
		move.l	#pal2fadex,d1
		jsr		loadFile
		tst.w	fail
		bne		exit	

		move.l	#pal3filename,d0
		move.l	#pal3fadex,d1
		jsr		loadFile
		tst.w	fail
		bne		exit			
	ENDC

	move.l	sndh_pointer,a0
	jsr		(a0)
	jsr		init_meta
.mainloop



	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
	bne		.mainloop										;



.exit
exit
	move.w	#$700,$ffff8240
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

musicfilename				dc.b	"msx\meta.snd",0
	even

loadMusic	
		move.l	#musicfilename,d0
		move.l	#music,d1

loadFile
				move.l	d0,-(SP)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #6,SP
                tst.l   D0              ;opened ok?
                bgt.s   .openok

                bra     .getout

.openok:        	
				move.w  D0,handle       ;read the file
;                pea     music

				move.l	d1,-(SP)
                move.l  #1024*128,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0              ;read everything?
                bgt.s   .readok
.getout
				move.w	#$700,$ffff8240
				move.w	#-1,fail
				add.l	#16,sp
				rts


.readok:         
				move.w  handle(PC),-(SP) ;close file
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP	
	rts
fail			ds.w	1
handle			ds.w	1

	ENDC



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
music_vbl
	pushall
		move.l	sndh_pointer,a0
		jsr		8(a0)
	popall
	rte

init_meta
	move.w	#$2700,sr
	move.l	#dummy,$134
	move.l	#music_vbl,$70
	move.w	#$2300,sr

	lea	$ffff8240,a0
	moveq	#0,d0
	rept 8
		move.l	d0,(a0)+
	endr

	move.l	screenpointer,d0
	move.l	screenpointer2,d1
	move.l	screenpointer3,d2
	cmp.l	d0,d1
	bgt		.ok
		; d1 < d0
		move.l	d0,a0
.ok
	move.l	d0,a0
	move.l	a0,a1
;	move.l	screenpointer,a0
	add.l	#$10000,a1
	move.l	a1,a2
	add.l	#$10000,a2
	move.w	#274-1,d7
	moveq	#0,d0
.ol
	REPT 20	
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.ol

	IFEQ STANDALONE
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
	ENDC

	move.l	alignpointer1,screenpointer3
	move.l	alignpointer2,tab2px_1p
	move.l	alignpointer3,tab2px_2p
	move.l	alignpointer4,ball1pointer
	move.l	alignpointer5,ball2pointer
	move.l	alignpointer6,ball3pointer
	move.l	alignpointer7,generatedC2P
	move.l	generatedC2P,d0
	add.l	#56450,d0
	move.l	d0,generatedC2P_copy
	add.l	#2306+24,d0
	move.l	d0,vertStripesPointer
	add.l	#2306,d0
	move.l	d0,doublescanlinespointer			; 100 * 34 + 2 = 3402
	add.l	#3500,d0
	move.l	d0,fixBlocksPointer
	add.l	#1538,d0
	move.l	d0,clearsmcscreenstuffpointer

	jsr		generate2pxTabsMeta				;19 this generates the 2 px tabs, this way the tabs are set up that the source picture can be read
	jsr		generateC2PMeta
	jsr		generateC2PCopyMetaBall
	jsr		generateVertStripesInner
	jsr		generateDoubleScanlines
	jsr		genFixBlocks
	jsr		genClearSMCScreenStuff


	move.l	plasma1pointer,a0
	move.l	ball1pointer,a1
	jsr		genBall
	move.l	ball1pointer,at1

	move.l	plasma2pointer,a0
	move.l	ball2pointer,a1
	jsr		genBall

	move.l	plasma3pointer,a0
	move.l	ball3pointer,a1
	jsr		genBall

	move.w	#$2700,sr
	move.l	#dummy,$120
	move.l	#meta_vbl,$70
	move.w	#$2300,sr
	move.w	#34+26,c2poffset1
	move.w	#48+30,c2poffset2
	move.w	#52+28,c2poffset3

	move.w	#0,$466.w
	lea		pal5fade,a0
	move.l	a0,fadepointer
	move.w	#13,fadecounter


.ml1:	
;;;;;;;;;;;;;; META INNER
; stage 1: introduce 3x1 checkers, with fade
; stage 2: flash, do picture, stage 1 stuff no longer, remove blocks
		move.l	screenpointer,$ffff8200

		jsr		doSMC				
		jsr		c2p_1to2_per2			; all	
		jsr		fixBlocks			; stage 1
		jsr		doVertStripes		; stage 1
		jsr		doHortStripes		; stage 1
		jsr		restoreSMC	

		jsr		drawPanel1
		jsr		doSMCRight				
		jsr		c2p_1to2_per2right
		jsr		restoreSMCRight	
		jsr		clearSMCScreenStuff	
		jsr		copy_c2p_lines			; all
		jsr		doSMCStep
		jsr		doc2pOffset			
		jsr		removeBlocks		; stage 2 -> when done, move to stage 3
		jsr		swapscreens_c2p				; dont use jmp when it returns with rts, use branch then


				exitOnSpace
		tst.w	stage4
		blt		.stage4
		jmp		.ml1

	rts
.stage4
	move.w	#7*30+20,framecounter
	move.w	#0,blockremovelistoffset
.ml2
		move.l	screenpointer,$ffff8200
		jsr		c2p_1to2_per2right
		jsr		copy_c2p_lines			; all
		jsr		doc2pOffset			

		jsr		paintBlocks
		jsr		increaseFrame
		jsr		swapscreens_c2p				; dont use jmp when it returns with rts, use branch then

		subq.w	#1,framecounter
		bgt		.okxx
			move.l	savedscreenpointer,d0
			move.l	savedscreenpointer2,d1
			move.l	d0,screenpointer
			move.l	d1,screenpointer2
			rts
			move.l	sndh_pointer,a0
			move.b	#0,$b8(a0)
			move.w	#$2700,sr
			move.l	#doTheOutRout_vbl,$70
			move.w	#$2300,sr
			jmp		.outrout
.okxx
			exitOnSpace
	jmp		.ml2

.outrout
	
			exitOnSpace
	tst.w	nextScene
	beq		.outrout
	rts

unpackPlasma
	lea		haxSpace,a0
	move.l	a0,plasma1pointer
	add.l	#$4000,a0
	move.l	a0,plasma2pointer
	add.l	#$4000,a0
	move.l	a0,plasma3pointer
	add.l	#$4000,a0
	move.l	a0,panelpointer
	add.l	#12800,a0
	move.l	a0,panel2pointer

	lea		plasma1,a0
	move.l	plasma1pointer,a1
	jsr		d_lz77

	lea		plasma2,a0
	move.l	plasma2pointer,a1
	jsr		d_lz77

	lea		plasma3,a0
	move.l	plasma3pointer,a1
	jsr		d_lz77

	
	lea		panel,a0
	move.l	panelpointer,a1
	jsr		d_lz77

	lea		panel2,a0
	move.l	panel2pointer,a1
	jsr		d_lz77

	move.w	#$4e75,unpackPlasma

	rts

drawWaiter		dc.w	95
drawRoutListOff	dc.w	0

drawPanel1
	tst.w	drawPanelStop
	blt		.end
	subq.w	#1,drawWaiter
	blt		.doit
.end
		rts
.doit
	lea		drawRoutListx,a0
	add.w	drawRoutListOff,a0
	move.l	(a0),a0
	add.w	#4,drawRoutListOff
	move.l	#%11111111111111001111111111111100,d6
	move.l	#%00111111111111110011111111111111,d5
	bne		.doit2
.exit
	rts

.doit2
	jmp		(a0)

drawRoutListx
	dc.l	drawTop			
	dc.l	drawTop
	dc.l	drawTopLast
	dc.l	drawMid
	dc.l	drawMid
	dc.l	drawMidLast
	dc.l	drawBottom
	dc.l	drawBottom
	dc.l	drawBottomLast
	dc.l	moMoreDraw

draw
.il
	REPT 3
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
		move.l	(a0)+,(a1)
		and.l	d6,(a1)+
		move.l	(a0)+,(a1)
		and.l	d6,(a1)+

		move.l	(a0)+,(a1)
		and.l	d5,(a1)+
		move.l	(a0)+,(a1)
		and.l	d5,(a1)+

	REPT 3
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR

	add.w	#160-64,a0
	add.w	#160-64,a1
	dbra	d7,.il
	rts

drawTopLast
	move.w	#20,drawWaiter
drawTop
;	lea		panel_square+34,a0
	move.l	panel2pointer,a0
	move.l	screenpointer2,a1
	add.w	#96+34,a0
	add.w	#96,a1
	move.w	#66-1,d7
	jmp		draw

drawMidLast
	move.w	#20,drawWaiter
drawMid
;	lea		panel_square+34,a0
	move.l	panel2pointer,a0
	move.l	screenpointer2,a1
	add.w	#70*160,a0
	add.w	#70*160,a1
	add.w	#96+34,a0
	add.w	#96,a1
	move.w	#60-1,d7
	jmp		draw

drawBottomLast
	move.w	#20,drawWaiter
drawBottom
;	lea		panel_square+34,a0
	move.l	panel2pointer,a0
	move.l	screenpointer2,a1
	add.w	#134*160,a0
	add.w	#134*160,a1
	add.w	#96+34,a0
	add.w	#96,a1
	move.w	#63-1,d7
	jmp		draw

moMoreDraw
	move.w	#-1,drawPanelStop
	rts
drawPanelStop	dc.w	0



doTheOutRout_vbl
	pushall
	move.l	screenpointer2,$ffff8200
	swapscreens

	addq.w	#1,$466.w
			schedule_timerA_topBorder
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #228,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.l	sndh_pointer,a0
	jsr		8(a0)

	popall
	rte




fadeoff	dc.w	0

topcolorpal		dc.l	pal1fade
topoff			dc.w	0
middlecolorpal	dc.l	pal2fade
middleoff		dc.w	0
bottomcolpal	dc.l	pal3fade
bottomoff		dc.w	0

meta_timer_b_pointer		dc.l	stripetop
timer_b_position	dc.b	62+4
_stage2				dc.b	0

meta_vbl
	addq 	#1,$466.w
	pushall

	tst.b	_stage2
	blt		.ok
	subq.w	#1,_flashwaiter
	bge		.ok	
;		move.b	#0,$ffffc123
		move.l	#flash_timer_b,meta_timer_b_pointer
		move.b	#1,timer_b_position
		move.b	#-1,_stage2
		move.l	#pal5fade+7*16*2,topcolorpal
		move.w	#0,topoff
.ok	
	tst.w	stage3
	beq		.ok2

.ok2

	move.l	topcolorpal,a0
	add.w	topoff,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR
	move.w	#$000,$ffff8240
	move.l	sndh_pointer,a0
	cmp.b	#$22,$b8(a0)
	bne		.ttt
		move.w	#$070,$ffff8240
		move.b	#0,$b8(a0)
.ttt

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	timer_b_position,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	meta_timer_b_pointer,$120.w
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))


	jsr		doPicture1

	jsr		meta_doFade
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popall
	rte

_pdone		dc.w	2
_poff		dc.l	0
doPicture1
	tst.b	_stage2
	beq		.done
	subq.w	#1,_pdone
	blt		.done
		move.l	screenpointer,a0
		move.l	screenpointer2,a1
		move.l	screenpointer3,a2
		move.l	panelpointer,a3
		add.w	#96,a0
		add.w	#96,a1
		add.w	#96,a2
		move.l	_poff,d0
		add.l	d0,a0
		add.l	d0,a1
		add.l	d0,a2
		add.w	_poff2,a3
		move.w	#100-1,d7
.dl	
o set 0
			REPT 1
				movem.l	(a3)+,d0-d6/a4		; 8 regs
				movem.l	d0-d6/a4,(a0)
				movem.l	d0-d6/a4,(a1)
				movem.l	d0-d6/a4,(a2)

				movem.l	(a3)+,d0-d6/a4
				movem.l	d0-d6/a4,32(a0)
				movem.l	d0-d6/a4,32(a1)
				movem.l	d0-d6/a4,32(a2)
			ENDR
		add.l	#160,a0
		add.l	#160,a1
		add.l	#160,a2
;		add.l	#160-56,a3
		dbra	d7,.dl

		move.w	#100*8*8,_poff2
		move.l	#100*160,_poff
.done
	rts

_poff2	dc.w	0

;pbuffer	ds.b	200*8*8
;
;prepPanel2
;	lea		panel+34,a0
;	lea		pbuffer,a1
;y set 0
;	REPT 200
;o set y
;		REPT 8
;			move.l	o(a0),(a1)+
;			move.l	o+4(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR	
;	lea		pbuffer,a0
;	move.b	#0,$ffffc123
;	rts

flash_timer_b
	move.w	#$777,$ffff8240
	
	clr.b	$fffffa1b.w
	move.l	#flash_timer_b_close,$120.w
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

flash_timer_b_close
	move.w	#$000,$ffff8240
	rte


stripetop
	move.w	#$2700,sr
	pusha0
	pusha1
		move.l	middlecolorpal,a1
		add.w	middleoff,a1
		lea		$ffff8240,a0
		REPT 8
			move.l	(a1)+,(a0)+
		ENDR
		clr.b	$fffffa1b.w
		move.l	#stripebottom,$120.w
		move.b	#65,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	popa1
	popa0
	rte

stripebottom
	move.w	#$2700,sr
	pusha0
	pusha1
		move.l	bottomcolpal,a0
		add.w	bottomoff,a0
		lea		$ffff8240,a1
		REPT 8
			move.l	(a0)+,(a1)+
		ENDR
	popa1
	popa0
	rte

firstoff	equ	topoff
secondoff	equ	bottomoff
thirdoff	equ	middleoff

_flashwaiter	dc.w	6000
_removewaiter	dc.w	70
meta_flashtimer	equ		15+220
fadeFrames	equ		2
fadeTimer	dc.w	3
tt1			dc.w	12+8-4
mt2			dc.w	12+8-4
bt3			dc.w	12+8

meta_doFade
	tst.w	stage3
	bne		.stage3
	tst.b	_stage2
	blt		.wholefader
	subq.w	#1,fadeTimer
	bge		.skip
.first
		move.w	#fadeFrames,fadeTimer
		subq.w	#1,tt1
		blt		.second
			add.w	#2*16,firstoff
			cmp.w	#17*32,firstoff
			bne		.skip
				move.w	#16*32,firstoff
			rts
.second
		move.w	#fadeFrames,fadeTimer
		subq.w	#1,mt2
		blt		.third
			add.w	#2*16,secondoff
			cmp.w	#13*32,secondoff
			bne		.skip
				move.w	#12*32,secondoff
			rts

.third
		move.w	#fadeFrames,fadeTimer
		subq.w	#1,bt3
		blt		.special
			add.w	#2*16,thirdoff
			cmp.w	#13*32,thirdoff
			bne		.skip
				move.w	#12*32,thirdoff
			rts
.special
		; here we can signal that we're done
		tst.w	_ll
		bne		.skip
		move.w	#-1,_ll
		move.w	#meta_flashtimer,_flashwaiter
.skip
	rts
.wholefader
	subq.w	#1,fadeTimer
	bge		.skip
		move.w	#fadeFrames,fadeTimer
		add.w	#2*16,topoff
		cmp.w	#15*2*16,topoff
		bne		.dopalsmc
			move.w	#14*2*16,topoff
			move.w	#26,fadeTimer
	rts

.dopalsmc
	move.l	topcolorpal,a0
	add.w	topoff,a0
	move.w	(a0),flash_timer_b+2
	rts

.stage3
	subq.w	#1,fadeTimer
	bge		.skip
		move.w	#fadeFrames,fadeTimer
		add.w	#2*16,topoff
		cmp.w	#27*2*16,topoff
		bne		.okxx
			move.w	#26*2*16,topoff
.okxx
	rts


_ll	dc.w	0


genFixBlocks
	move.l	fixBlocksPointer,a0					;1538
	move.l	#$21400000,d0

	move.w	#32-1,d7					; rept 32
	moveq	#0,d1						; y
	move.w	#320,d5						; +320
.ol
	move.w	#12-1,d6					; 
	move.w	d1,d0
.il
		move.l	d0,(a0)+
		addq.w	#8,d0
		dbra	d6,.il
	add.w	d5,d1
	dbra	d7,.ol
	move.w	#$4e75,(a0)+
	rts

	
fixBlocks
	move.l	screenpointer2,a0
	add.w	#4*160,a0
	; fix blocks if 
	cmp.w	#8,tt1
	ble		.check2
.doit
	moveq	#-1,d0	
	move.l	fixBlocksPointer,a1
	jmp		(a1)

;y set 0
;	REPT 32
;o set y
;		REPT 12
;			move.l	d0,o(a0)				;16	* 12 * 96				;2140 xxxx
;o set o+8
;		ENDR
;y set y+320
;	ENDR
;	rts

.check2
	cmp.w	#8,mt2
	ble		.check3
		add.w	#64*2*160,a0
		jmp		.doit

.check3
	cmp.w	#8,bt3
	ble		.end
		add.w	#64*160,a0
		jmp		.doit
.end
	rts	


flip			dc.w	1
vblcounter		dc.w	0
effectcounter	dc.w	0
fadecounter		dc.w	0
c2poffset1		dc.w	0
c2poffset2		dc.w	0
c2poffset3		dc.w	0
c2p_x_off		dc.w	0
overlayoff		dc.w	0	
overlayminus	dc.w	-1

overlaywidth	equ 8

doVertStripes
	tst.b	_stage2
	blt		.skip
	;2px
;	move.l	#%11111111111111101111111111111110,d0
;	move.l	#%01111111111111110111111111111111,d1
	;4px
	move.l	#%11111111111111001111111111111100,d0
	move.l	#%00111111111111110011111111111111,d1
	move.l	screenpointer2,a0
	add.w	#24+4*160,a0

	move.l	vertStripesPointer,a1
	jmp	(a1)

;	REPT 96											;2.5k
;	and.l	d0,(a0)+	;+4					;20
;	and.l	d0,(a0)+	;+4					;20
;	and.l	d1,(a0)+	;+4					;20
;	and.l	d1,(a0)+	;+4	--> 16			;20
;	add.w	#16,a0							;8
;	and.l	d0,(a0)+	;+4					;20	
;	and.l	d0,(a0)+	;+4					;20
;	and.l	d1,(a0)+	;+4					;20
;	and.l	d1,(a0)+	;+4	--> 16			;20
;	add.w	#320-16-24-32+24,a0				;8		=> 2*88 = 176*96 = 16896 (10% vbl)
;	ENDR
.skip
	rts

generateVertStripesInner
	move.l	vertStripesPointer,a0
	move.w	#96-1,d7
	move.l	#$C198C198,d0
	move.l	#$C398C398,d1
	move.l	#$41E80010,d2
	move.l	d0,d3
	move.l	d1,d4
	move.l	#$41E80110,d5

.genCode
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		move.l	d4,(a0)+
		move.l	d5,(a0)+				; 96 * 24 + 2 = 2306
	dbra	d7,.genCode
	move.w	#$4e75,(a0)+
	rts


doHortStripes
	tst.b	_stage2
	blt		.skip

	move.l	screenpointer2,a0
	add.w	#62*160+12*8+4*160,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7			; 12 regs, we need to clear 192/16 = 12 blocks; 12 blocks per 2 longwords = 24 longwords
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4

	movem.l	d0-d7/a1-a4,-(a0)				;104		
	movem.l	d0-d7/a1-a4,-(a0)				;104
	add.w	#320+12*8,a0					;8
	movem.l	d0-d7/a1-a4,-(a0)				;104
	movem.l	d0-d7/a1-a4,-(a0)				;104

	add.w	#62*160+12*8,a0					;8
	movem.l	d0-d7/a1-a4,-(a0)				;104
	movem.l	d0-d7/a1-a4,-(a0)				;104
	add.w	#320+12*8,a0					;8
	movem.l	d0-d7/a1-a4,-(a0)				;104
	movem.l	d0-d7/a1-a4,-(a0)				;104
.skip
	rts


; for this blocklist
;	screen -> target offset
;
;	source -> left/right selection
;			  source offset			-> can be encoded with upper bit set for left right
; source is: 128x160
_paintdone	dc.w	0
paintBlocks
	tst.w	_paintdone
	beq		.skippaint
		tst.w	blockremovelistoffset
		blt		.skippaint

	move.l	screenpointer,d4
	move.l	screenpointer2,d5
	move.l	screenpointer3,d6
	lea		blockremovelist,a3
	add.w	blockremovelistoffset,a3
	move.l	panel2pointer,a4
	add.w	#34,a4
;	lea		panel2+34,a4

	move.l	#%00000000111111110000000011111111,d0
	move.l	d0,d1
	not.l	d1
	move.w	#%0111111111111111,d3
	
	move.w	#8-1,d7
.loop
	move.l	(a3)+,d2
	blt		.left
.right

	move.w	d2,d4	
	move.w	d2,d5	
	move.w	d2,d6
	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,a2

	swap	d2
;	and.w	d3,d2		; only needed for left
	move.l	a4,a5	; panel
	add.w	d2,a5	; source address panel

o set 0
	REPT 8
		move.l	o(a5),d2
		and.l	d0,d2
		or.l	d2,o-96(a0)
		or.l	d2,o-96(a1)
		or.l	d2,o-96(a2)
		move.l	o+4(a5),d2
		and.l	d0,d2
		or.l	d2,o+4-96(a0)
		or.l	d2,o+4-96(a1)
		or.l	d2,o+4-96(a2)
o set o+160
	ENDR
	dbra	d7,.loop


	add.w	#8*4,blockremovelistoffset
	cmp.w	#400*4,blockremovelistoffset
	blt		.ok
		move.w	#-1,blockremovelistoffset
		move.w	#255,stage5
.skippaint
				move.w	#-1,_paintdone

	rts
.left	
	move.w	d2,d4	
	move.w	d2,d5	
	move.w	d2,d6
	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,a2

	swap	d2
	and.w	d3,d2		; only needed for left
	move.l	a4,a5	; panel
	add.w	d2,a5	; source address panel

o set 0
	REPT 8
		move.l	o(a5),d2
		and.l	d1,d2
		or.l	d2,o-96(a0)
		or.l	d2,o-96(a1)
		or.l	d2,o-96(a2)
		move.l	o+4(a5),d2
		and.l	d1,d2
		or.l	d2,o+4-96(a0)
		or.l	d2,o+4-96(a1)
		or.l	d2,o+4-96(a2)
o set o+160
	ENDR
	dbra	d7,.loop

	add.w	#8*4,blockremovelistoffset
	cmp.w	#400*4,blockremovelistoffset
	blt		.ok
		move.w	#-1,blockremovelistoffset
		move.w	#61,stage5
.ok
	rts


blockremovelistoffset	dc.w	0
_removedone		dc.w	0
stage3			dc.w	0
stage5			dc.w	0
removeBlocks
	tst.w	_pdone
	bge		.skipremove
		tst.w	blockremovelistoffset
		blt		.skipremove
	subq.w	#1,_removewaiter
	bge		.ok
	move.l	screenpointer,d4
	move.l	screenpointer2,d5
	move.l	screenpointer3,d6

	lea		blockremovelist,a3
	add.w	blockremovelistoffset,a3

	move.l	#%00000000111111110000000011111111,d0
	move.l	d0,d1
	not.l	d1
	move.w	#8-1,d7
.loop
	move.l	(a3)+,d2
	blt		.left
.right
	move.w	d2,d4
	move.w	d2,d5
	move.w	d2,d6
	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,a2

o set 0
	REPT 8
		and.l	d0,o(a0)
		and.l	d0,o+4(a0)
		and.l	d0,o(a1)
		and.l	d0,o+4(a1)
		and.l	d0,o(a2)
		and.l	d0,o+4(a2)
o set o+160
	ENDR
	dbra	d7,.loop
	add.w	#8*4,blockremovelistoffset
	cmp.w	#400*4,blockremovelistoffset
	blt		.ok
		move.w	#-1,blockremovelistoffset
		move.w	#-1,stage3
	rts
.left
	move.w	d2,d4
	move.w	d2,d5
	move.w	d2,d6
	move.l	d4,a0
	move.l	d5,a1
	move.l	d6,a2

o set 0
	REPT 8
		and.l	d1,o(a0)
		and.l	d1,o+4(a0)
		and.l	d1,o(a1)
		and.l	d1,o+4(a1)
		and.l	d1,o(a2)
		and.l	d1,o+4(a2)
o set o+160
	ENDR	
	dbra	d7,.loop

	add.w	#8*4,blockremovelistoffset
	cmp.w	#400*4,blockremovelistoffset
	blt		.ok

		move.w	#-1,blockremovelistoffset
		move.w	#-1,stage3
.ok
.skipremove
	rts




fadepointer		dc.l	0

offset1		dc.w 	0
offset2		dc.w 	40
offset3		dc.w 	0

doc2pOffset
	add.w	#4,offset1
	cmp.w	#120*2,offset1
	bne		.done1
		move.w	#0,offset1
.done1

	add.w	#4,offset2
	cmp.w	#100*2,offset2
	bne		.done2
		move.w	#0,offset2
.done2

	add.w	#4,offset3
	cmp.w	#150*2,offset3
	bne		.done3
		move.w	#0,offset3
.done3

	rts

VIEWPORT_Y	equ	96
VIEWPORT_X	equ	12
SOURCE_Y	equ 256
SOURCE_X	equ	256

doadd		equ 1
dosub		equ 1

; 256 vs 160 => 96 +-
; 256 vs 100 => 156 +-
; todo, something with 1 pixel
c2p_1to2_per2right
	tst.w	stage3
	beq		.skip
	lea		c2ppath1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	move.l	ball2pointer,a0
	add.w	c2poffset1,d0
	and.w	#%1,d1
	beq		.whole1
	and.w	#-2,d0
.whole1
	add.w	d0,a0

	lea		c2ppath2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	add.w	c2poffset2,d0
	move.w	d0,d1
	move.l	ball3pointer,a1
	and.w	#%1,d1
	beq		.whole2
	and.w	#-2,d0
.whole2
	add.w	d0,a1


	lea		c2ppath3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	add.w	c2poffset3,d0
	move.l	ball1pointer,a2
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	and.w	#-2,d0
.whole3
	add.w	d0,a2

	move.l	tab2px_1p,d0
	move.l	d0,d7
	move.l	tab2px_2p,d1
	move.l	d1,d6
	move.l	screenpointer2,a6
	add.w	c2p_x_off,a6
	move.w	#5*160-8,d0
	move.w	smcstep,d1
	sub.w	#4,d1
	blt		.skip
	add.w	d1,d1
	sub.w	d1,d0
	add.w	d0,a6
	add.l	paneloff,a6

	move.l	generatedC2P,a4
	jmp		(a4)
.skip
	rts
endit
	rts

c2p_1to2_per2
	tst.w	stage4
	bne		endit

	lea		c2ppath1,a6
	add.w	offset1,a6
	move.w	(a6),d0
	move.w	d0,d1
	move.l	ball1pointer,a0
	add.w	c2poffset1,d0
	and.w	#%1,d1
	beq		.whole1
	and.w	#-2,d0
.whole1
	add.w	d0,a0

	lea		c2ppath2,a6
	add.w	offset2,a6
	move.w	(a6),d0
	add.w	c2poffset2,d0
	move.w	d0,d1
	move.l	ball2pointer,a1
	and.w	#%1,d1
	beq		.whole2
	and.w	#-2,d0
.whole2
	add.w	d0,a1


	lea		c2ppath3,a6
	add.w	offset3,a6
	move.w	(a6),d0
	add.w	c2poffset3,d0
	move.l	ball1pointer,a2
	move.w	d0,d1
	and.w	#%1,d1
	beq		.whole3
	and.w	#-2,d0
.whole3
	add.w	d0,a2

	move.l	tab2px_1p,d0
	move.l	d0,d7
	move.l	tab2px_2p,d1
	move.l	d1,d6
	move.l	screenpointer2,a6
	add.w	c2p_x_off,a6
	add.w	#4*160,a6

	move.w	smcstep,d0
	add.w	d0,d0
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2


	IFEQ c2pGenerated
		move.l	generatedC2P,a4
		jmp		(a4)


;	ELSE
;	move.b	#0,$ffffc123
;	jmp		*+600
;	nop
;harhar
;o set 0
;	REPT VIEWPORT_Y
;		REPT VIEWPORT_X
;			move.w	(a0)+,d0			;8							;2
;			add.w	(a1)+,d0			;8							;2
;			add.w	(a2)+,d0			;8							;2
;			move.l	d0,a3				;4							;2
;			move.l	(a3),d5				;12							;2
;			move.w	(a0)+,d1			;8							;2
;			add.w	(a1)+,d1			;8							;2
;			add.w	(a2)+,d1			;8							;2
;			move.l	d1,a3				;4							;2
;			or.l	(a3),d5				;16		-->		84			;2
;			movep.l	d5,o(a6)										;4	24
;o SET o+1
;			move.w	(a0)+,d0			;8
;			add.w	(a1)+,d0			;8
;			add.w	(a2)+,d0			;8
;			move.l	d0,a3				;4
;			move.l	(a3),d5				;12
;			move.w	(a0)+,d1			;8
;			add.w	(a1)+,d1			;8
;			add.w	(a2)+,d1			;8
;			move.l	d1,a3				;4
;			or.l	(a3),d5				;16							;48	* VIEWPORT_X (12)= 576		
;			movep.l	d5,o(a6)
;o	SET o+7
;		ENDR
;		add.w	#SOURCE_X-VIEWPORT_X*8,a0
;		add.w	#SOURCE_X-VIEWPORT_X*8,a1
;		add.w	#SOURCE_X-VIEWPORT_X*8,a2
;o 	SET o+160+160-8*VIEWPORT_X
;	ENDR															;576 + 12 = 588 * 96 = 56448
;	rts
	ENDC

; width = 16, then we have adding a0,a1,a2
; 


increaseFrame
	tst.w	stage5
	beq		.no
	bgt		.minus


	move.l	paneloff,d0
	add.l	#4*160,d0
	cmp.l	#204*160,d0
	blt		.ok
		move.l	#204*160,d0
		jmp		.no
.ok
	move.l	d0,paneloff
	move.l	screenpointer2,a0
	move.l	screenpointer3,a1
	add.l	d0,a0
	add.l	d0,a1
	sub.w	#160*4,a0
	sub.w	#160*4,a1
	moveq	#0,d0
	REPT 8
		add.w	#64,a0
		add.w	#64,a1
		REPT 12
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
	ENDR
.no

	rts
.minus
;	move.w	stage5,d0

	subq.w	#2,stage5
	rts





;	so if we want to move to the left, we make the thing smaller per block, and we want to cut the blocks on the right, so we need to alter the code
;	so 96 times we have to smc, plus we need to add to the offset of a0,a1,a2
;
;	lea		#SOURCE_X-VIEWPORT_X*8 + 8,a0		41E8	xxxx
;	lea		#SOURCE_X-VIEWPORT_X*8 = 8,a1		43E8	xxxx
;	lea		#SOURCE_X-VIEWPORT_X*8 = 8,a2		45E8	xxxx
;	jmp		*586					$6000 


; RESTORE
	;	move.w	(a0)+,d0			3018		move.l	#$3018D059,d1
	;	add.w	(a1)+,d0			D059		move.l	#$d05a2640,d2
	;	add.w	(a2)+,d0			D05A		move.l	#$2a133218,d3
	;	move.l	d0,a3				2640		move.l	#$d259d25a,d4
	;	move.l	(a3),d5				2A13		
	;	move.w	(a0)+,d1			3218
	;	add.w	(a1)+,d1			D259
	;	add.w	(a2)+,d1			D25A

restoreSMCRight
	tst.w	stage4
	bne		.end
	tst.w	stage3
	beq		.end
	move.l	generatedC2P,a0
	move.l	#$3018D059,d1
	move.l	#$d05a2640,d2
	move.l	#$2a133218,d3
	move.l	#$d259d25a,d4
	move.l	#588,d5
	lea		smcConsts,a6
	move.w	smcstep,d0
	cmp.w	#48,d0
	bge		.end
;	beq		.end
	sub.w	#4,d0
	blt		.end
	neg.w	d0
	add.w	#44,d0
	add.w	d0,a6
	add.w	(a6),a0
	jmp		doRestoreSMC

.end
	rts

restoreSMC
	tst.w	stage4
	bne		endLeft
	tst.w	stage3
	beq		endLeft
	move.l	generatedC2P,a0
	move.l	#$3018D059,d1
	move.l	#$d05a2640,d2
	move.l	#$2a133218,d3
	move.l	#$d259d25a,d4
	move.l	#588,d5
	
	lea		smcConsts,a6
	add.w	smcstep,a6
	add.w	(a6),a0
doRestoreSMC
o set 0
	REPT 48								; 96*4 = 384
		movem.l	d1-d4,o(a0)
o set o+588
;		add.w	d5,a0
	ENDR
	add.w	#588*48,a0
o set 0
	REPT 48								; 96*4 = 384
		movem.l	d1-d4,o(a0)
;		add.w	d5,a0
o set o+588
	ENDR
endLeft
	rts


smcstep		dc.w	0
doSMCRight
	tst.w	stage4
	bne		skipSMCright
	tst.w	stage3
	beq		skipSMCright	
		move.l	generatedC2P,a0
		move.l	#$41e80000,d1
		move.l	#$43e90000,d2
		move.l	#$45ea0000,d3
		move.l	#$60000000,d4			; jump over 1 iter = 50

		move.w	#SOURCE_X-VIEWPORT_X*8,d1
		move.w	#SOURCE_X-VIEWPORT_X*8,d2
		move.w	#SOURCE_X-VIEWPORT_X*8,d3
		lea		smcConsts,a6
		move.w	smcstep,d0
;		beq		skipSMCright
		cmp.w	#48,d0
		bge		skipSMCright

			sub.w	#4,d0
			blt		skipSMCright
			neg.w	d0
			add.w	#44,d0
			add.w	d0,a6
			add.w	(a6)+,a0
			add.w	(a6)+,d4
			add.w	d0,d0

			add.w	d0,d1
			add.w	d0,d2
			add.w	d0,d3

	
	jmp		doit

skipSMCright
	rts
doSMC
	tst.w	stage4
	bne		skipSMCleft
	tst.w	stage3
	beq		skipSMCleft
	move.l	generatedC2P,a0
	move.l	#$41e80000,d1
	move.l	#$43e90000,d2
	move.l	#$45ea0000,d3
	move.l	#$60000000,d4			; jump over 1 iter = 50

	move.w	#SOURCE_X-VIEWPORT_X*8,d1
	move.w	#SOURCE_X-VIEWPORT_X*8,d2
	move.w	#SOURCE_X-VIEWPORT_X*8,d3

	lea		smcConsts,a6
	move.w	smcstep,d0
	beq		skipSMCleft
	add.w	d0,a6
	add.w	(a6)+,a0
	add.w	(a6)+,d4
	add.w	d0,d0

	add.w	d0,d1
	add.w	d0,d2
	add.w	d0,d3

doit
	move.l	#588,d5

	REPT 95
;		move.l	d1,(a0,d0.l)		;20		; REPT 4									;	move.l	d1,(a0)+	movem.l	d1-d4,(a0)		
;		move.l	d2,4(a0,d0.l)		;20		; 	move.l	(a0),(a2)+			;20			;	move.l	d2,(a0)+	add.l	d5,a0
;		move.l	d3,8(a0,d0.l)		;20		; 	move.l	(a1)+,(a0)+			;20			;	move.l	d3,(a0)+
;		move.l	d4,12(a0,d0.l)		;20		; ENDR										;	move.l	d4,(a0)+
;		add.l	d5,d0				;8		; add.l	(a1)+,a0				;16			;	add.l	d5,a0
		movem.l	d1-d4,(a0)
		add.l	d5,a0
	ENDR									; eww, I wasted cycles here..... movem.l	d1-d4,o(a0); o set o+588....

		movem.l	d1-d3,(a0)
		move.w	#$4e75,12(a0)

skipSMCleft
	rts


clearsmcscreenstuffpointer	ds.l	1

genClearSMCScreenStuff
	move.l	clearsmcscreenstuffpointer,a0
	move.l	#$21400000,d0		;a0
	move.l	#$23400000,d1		;a1
	move.w	#320-12,d2
	move.w	#96-1,d7
.ol
		move.l	d0,(a0)+
		addq.w	#4,d0
		move.l	d0,(a0)+
		addq.w	#4,d0
		move.l	d0,(a0)+
		addq.w	#4,d0
		move.l	d0,(a0)+

		move.l	d1,(a0)+
		addq.w	#4,d1
		move.l	d1,(a0)+
		addq.w	#4,d1
		move.l	d1,(a0)+
		addq.w	#4,d1
		move.l	d1,(a0)+				;8*4*96+2 = 3074

		add.w	d2,d0
		add.w	d2,d1
	dbra	d7,.ol
	move.w	#$4e75,(a0)+
	rts

clearSMCScreenStuff
	tst.w	stage3
	beq		.skip
		move.l	screenpointer2,a1
		move.l	screenpointer3,a0
		add.w	#96+4*160,a0
		add.w	#96+4*160,a1
		move.w	smcstep,d0
		add.w	d0,d0
		sub.w	d0,a0
		sub.w	d0,a1
		move.l	#0,d0
		move.l	clearsmcscreenstuffpointer,a6
		jmp		(a6)

;o set 0
;		REPT 96							;
;			move.l	d0,o(a0)
;			move.l	d0,o+4(a0)
;			move.l	d0,o+8(a0)
;			move.l	d0,o+12(a0)
;;			move.l	d0,o(a1)
;			move.l	d0,o+4(a1)
;			move.l	d0,o+8(a1)
;			move.l	d0,o+12(a1)
;o set o+320
;		ENDR
.skip
	rts

smcwaiterconst	equ		0
smcwaiter		dc.w	5
clearcounter	dc.w	0
smcdirection	dc.w	1
stage4			dc.w	0
s4w				dc.w	4
doSMCStep
	tst.w	stage3
	beq		.end

	subq.w	#1,smcwaiter
	bge		.end
		move.w	#smcwaiterconst,smcwaiter

	tst.w	smcdirection
	blt		.subtract
	move.w	#4,clearcounter
	add.w	#4,smcstep
	cmp.w	#48,smcstep
	ble		.end
;		move.b	#0,$ffffc123
		move.w	#48,smcstep
		subq.w	#1,s4w
		bge		.tttt
		move.w	#-1,stage4
		neg.w	smcdirection
.tttt
.subtract
	rts
	move.w	#4,clearcounter
	sub.w	#4,smcstep
	bge		.end
		move.w	#0,smcstep
		neg.w	smcdirection
.end
	rts

smcConsts
	;	number of blocks -> offset into code, offset into textures
	dc.w	11*48,-1				;0
	dc.w	11*48,46				;4
	dc.w	10*48,46+48*1			;8
	dc.w	9*48,46+48*2			;12
	dc.w	8*48,46+48*3			;16
	dc.w	7*48,46+48*4			;20
	dc.w	6*48,46+48*5			;24
	dc.w	5*48,46+48*6			;28
	dc.w	4*48,46+48*7			;32
	dc.w	3*48,46+48*8			;36
	dc.w	2*48,46+48*9			;40
	dc.w	1*48,46+48*10			;44
	dc.w	0,46+48*11				;48



addbit	dc.w	0

copy_c2p_lines
	move.l	screenpointer2,a6
	add.w	#160*4,a6
	add.w	c2p_x_off,a6
	tst.w	stage4
	beq		.okxx
		add.w	#64,a6
		jmp		.ok
.okxx

	tst.w	stage3
	beq		.ok

		move.l	doublescanlinespointer,a4
		jmp		(a4)

.ok
		move.l	generatedC2P_copy,a4
		jmp		(a4)

;	IFNE	c2pGenerated
;		lea		generatedC2P_copy,a4
;		jmp		(a4)
;	ELSE
;x 	SET 0
;	REPT VIEWPORT_Y
;		movem.l	x(a6),d0-d7/a0-a5			; 56	-> 14*4								;124								;	4CEE 3FFF xxxx
;		movem.l	d0-d7/a0-a5,x+160(a6)												;124								;	48EE 3FFF xxxx+160
;		movem.l	x+56(a6),d0-d7/a0-a1		; 10*4 = 96										;128								;	4CEE 3FFF yyyy+56
;		movem.l	d0-d7/a0-a1,x+160+56(a6)	; 112		--> 48 left					;128								;	48EE 3FFF yyyy+56+160
;x	SET x+320
;	ENDR
;	rts
;	move.l	generatedC2P_copy,a4
;	jmp		(a4)
;	ENDC


generateC2PCopyMetaBall
	move.l	generatedC2P_copy,a0
	move.l	#$4CEE3FFF,a1		;movem.l	x(a6),d0-d7/a0-a5
	move.l	#$48EE3FFF,a2		;movem.l	d0-d7/a0-a5,x(a6)
	move.l	#$4CEE03FF,a3		;movem.l	x(a6),d0-d7/a0-a1
	move.l	#$48EE03FF,a4		;movem.l	d0-d7/a0-a,x(a6)

	move.l	#VIEWPORT_Y,d7
	moveq	#0,d0
	move.w	#160,d1

	move.w	#56,d2
	move.w	#160*2-56,d3

.loop
	move.l	a1,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x

	move.l	a2,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160

	add.w	d2,d0				;	x+56+56
	move.l	a3,(a0)+			;	movem.l	x(a6),d0-d7/a0-a5
	move.w	d0,(a0)+			;	x+56+56

	add.w	d2,d1				;	x+160+56+56
	move.l	a4,(a0)+			;	movem.l	d0-d7/a0-a5,x(a6)
	move.w	d1,(a0)+			;	x+160+56+56

	add.w	d3,d0				;	pad to next 
	add.w	d3,d1				;	pad to next

	dbra	d7,.loop

	move.w	#$4e75,(a0)+

	rts






;$3018D059		a1
;(D059)
;$905A2640		a2
;(2640)
;$2A133218		a3
;(3218)
;$D259925A		a4
;(925A)
;$26418A93		a5
;(8A93)
;0BCE xxxx		d0
;0BCE yyyy		d1

;41E8 0060	lea x,a0
;43E9 0060	lea x,a1
;45EA 0060	lea x,a2
generateC2PMeta
	move.l	generatedC2P,a0
	move.l	#$3018D059,a1			; 3018 = move.w (a0)+,d0	D059 = add.w	(a1)+,d0
	move.l	#$D05A2640,a2			; D05A = add.w	(a2)+,d0	2640 = move.l	d0,a3
	move.l	#$2A133218,a3			; 2A13 = move.l	(a3),d5		3218 = move.w	(a0)+,d1
	move.l	#$D259D25A,a4			; D259 = add.w	(a1)+,d1	D25A = add.w	(a2)+,d1
	move.l	#$26418A93,a5			; 2641 = move.l	d1,a3		8A93 = or.l		(a3),d5
	move.l	#$0BCE0000,d0			; 08CE 0000 movep.l	d5,x(a6)

	move.l	#$41E80060,d3			; lea +160(a2),a2
	move.w	#SOURCE_X-12*8,d3
	move.l	d3,a6
	move.l	#$43E90060,d2			; lea +160(a1),a1
	move.w	#SOURCE_X-12*8,d2
	move.l	#$45EA0060,d3			; lea +160(a2),a2
	move.w	#SOURCE_X-12*8,d3



;	move.l	#$0BCE0000,d1
	add.w	#160,d1
	move.w	#320-12*8,d4

	move.l	#VIEWPORT_Y-1,d7
	move.l	#12-1,d5

.ol
	move.l	d5,d6
.il
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#1,d0
		move.l	a1,(a0)+
		move.l	a2,(a0)+
		move.l	a3,(a0)+
		move.l	a4,(a0)+
		move.l	a5,(a0)+
		move.l	d0,(a0)+
		addq.w	#7,d0
		dbra	d6,.il
	move.l	a6,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add.w	d4,d0
	dbra	d7,.ol

	move.w	#$4e75,(a0)+
	rts



genBall
	move.l	a1,a2
	add.l	#255*256,a2
	move.w	#0,d6
	move.w	#128-1,d7
	move.w	#0,d0	; clear
	move.w	#0,d2
	; i dont need to inverse the bits, I need to inverse the bytes
.ol
	; first copy first 128 bytes
	REPT 32
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	ENDR
	; then inverse the following 128 bytes
	sub.w	#128,a0
	add.w	#128,a1
	add.w	#128,a2
	move.w	#32-1,d6
.il	
	REPT 128/32
		move.b	(a0)+,d0
		move.b	d0,-(a1)
		move.b	d0,-(a2)
	ENDR
	dbra	d6,.il
;	add.w	#128,a0
	add.w	#128,a1
	sub.w	#128+256,a2

	dbra	d7,.ol
	rts

generate2pxTabsMeta

	move.l	tab2px_1p,a0
	lea		TAB1,a1
	lea		TAB2,a2
	jsr		calcTabMetaRout

	move.l	tab2px_2p,a0
	lea		TAB3,a1
	lea		TAB4,a2
	jsr		calcTabMetaRout

	rts

_flipperinner	dc.w	1
_flipperouter	dc.w	1

calcTabMeta
	move.l	#64-1,d7
	moveq	#0,d1
.outer
	move.l	#256-1,d6
	moveq	#0,d0
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			tst.w	_flipperinner
			bge		.up
.down		
			subq.w	#4,d0
			bge		.innerok
				neg.w	_flipperinner
				move.w	#0,d0
				jmp		.innerok
.up
			addq.w	#4,d0
			cmp.w	#64,d0
			bne		.innerok
				move.w	#60,d0
				neg.w	_flipperinner
.innerok
.noresetin
		dbra	d6,.inner

		tst.w	_flipperouter
		bge		.upouter
.downouter
		subq.w	#4,d1
		bge		.outerok
			neg.w	_flipperouter
			move.w	#0,d1
			jmp		.outerok

.upouter
		addq.w	#4,d1
		cmp.w	#64,d1
		bne		.outerok
			neg.w	_flipperouter
			move.w	#60,d1
.outerok
	dbra	d7,.outer
	rts

	IFEQ STANDALONE
;;;
;	3 screens:		1 display, 1 display-candidate, 1 back
;		effect displays:	- display
;		code writes to:		- display-candidate
;
;	when effect is done:
;	1).	it swap screens -> candidate becomes display, back becomes candidate, display becomes back
;	2). it signals that its done, so that the mainloop
; it signals that its done
;		writes to back
;	as soon as vbl is done, it swaps 

; swaps screens
; TRASHES:	d0
swapscreens:
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	d0,screenpointer2
		
		move.l	screenpointershifter,d1
		move.l	screenpointer2shifter,d2
		move.l	d2,screenpointershifter
		move.l	d1,screenpointer2shifter

		rts

; 
swapscreens_c2p:
		move.l	screenpointer,d0
		move.l	screenpointer2,screenpointer
		move.l	screenpointer3,screenpointer2
		move.l	d0,screenpointer3
		
		rts		
; *************** CHUNKY CODE *****************

;;;;;;;;;;;;;;;;;;;; RESTORE ALL REGISTERS CODE ;;;;;;;;;;;;;;;;;;;;;	




;;; data layout:
;;; b b
;;; 00000000 00000000
; value range from 0..15
; 00111100 00111100
; 1 bpl = 1
; 2 bpl = 4
; 3 bpl = 8


calcTab
	moveq	#16-1,d7
	moveq	#0,d1
.outer
	move.l	#48-1,d5
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
		dbra	d6,.inner
.inner2
			move.l	d2,(a0)+
		dbra	d5,.inner2
		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer
	rts




; screenpointer a6
cp
		movem.l	(a6)+,d0-d7/a0-a5				;56					124		;4
		movem.l	d0-d7/a0-a5,160-56(a6)			;					124		;6
		movem.l	(a6)+,d0-d7/a0-a5				;112				124		;4
		movem.l	d0-d7/a0-a5,160-56(a6)			;					124		;6
		movem.l	(a6)+,d0-d7/a0-a3				;48					108		;4
		movem.l	d0-d7/a0-a3,160-48(a6)			;					108		;6	-> 4*124 + 2*108 + 8 = 496 + 216 + 8 = 720 cycles per line 720 * 100 = 72000
		lea		160(a6),a6							;					8	;4
generateDoubleScanlines
		move.l	doublescanlinespointer,a1
		move.w	#96-1,d7
		movem.l	cp,d0-d6/a0		;32
		move.w	cp+32,a2
.copy
			movem.l	d0-d6/a0,(a1)
			add.w	#32,a1
			move.w	a2,(a1)+
		dbra	d7,.copy
		move.w	#$4e75,(a1)+
		rts
generate2pxTabs

	move.l	tab2px_1p,a0
	lea		TAB1,a1
	lea		TAB2,a2
	jsr		calcTab

	move.l	tab2px_2p,a0
	lea		TAB3,a1
	lea		TAB4,a2
	jsr		calcTab

	rts
		ENDC

	SECTION DATA




pal1fade

			;1	;2		;3	;4	;5	;6		;7	;8	;9	;10	 ;11	;12	;13	 ;14	;15  ;16
o set 0
	REPT 8
		dc.w	0
		REPT 15
			dc.w	o
		ENDR
o set o+$111
	ENDR
pal1fadex
	incbin	pal1.pal


pal2fade
o set 0
	REPT 8
		dc.w	0
		REPT 15
			dc.w	o
		ENDR
o set o+$111
	ENDR
pal2fadex
	incbin	pal2.pal


pal3fade
o set 0
	REPT 8
		dc.w	0
		REPT 15
			dc.w	o
		ENDR
o set o+$111
	ENDR
pal3fadex
	incbin	pal3.pal


pal5fade
o set 0
	REPT 8
		dc.w	0
		REPT 15
			dc.w	o
		ENDR
o set o+$111
	ENDR
	REPT 16
		dc.w	$777
	ENDR

;	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;1
;	dc.w	$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;2
;	dc.w	$666,$000,$000,$000,$001,$001,$001,$002,$001,$001,$001,$000,$000,$000,$000,$000		;3
;	dc.w	$666,$000,$000,$000,$001,$001,$001,$002,$001,$001,$001,$000,$000,$000,$000,$000		;4
;	dc.w	$555,$000,$001,$001,$002,$002,$012,$012,$002,$002,$002,$001,$001,$001,$000,$000		;5
;	dc.w	$555,$000,$001,$001,$002,$002,$012,$012,$002,$002,$002,$001,$001,$001,$000,$000		;6
;	dc.w	$444,$001,$011,$011,$012,$012,$122,$122,$012,$012,$012,$011,$011,$001,$000,$000		;7
;	dc.w	$444,$001,$011,$011,$012,$012,$122,$122,$012,$012,$012,$011,$011,$001,$000,$000		;8
;	dc.w	$333,$001,$011,$012,$022,$122,$122,$222,$122,$122,$022,$012,$011,$001,$000,$000		;9
;	dc.w	$333,$001,$011,$012,$022,$122,$122,$222,$122,$122,$022,$012,$011,$001,$000,$000		;10
;	dc.w	$222,$001,$011,$012,$022,$122,$123,$223,$123,$122,$022,$012,$011,$001,$000,$000		;11
;	dc.w	$111,$001,$011,$012,$022,$122,$123,$223,$123,$122,$022,$012,$011,$001,$000,$000		;12

;	dc.w	$700,$101,$201,$401,$521,$642,$764,$777,$666,$664,$543,$451,$340,$230,$110,$100		;13				;<------		first palette


	dc.w	$0000,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777	;1
	dc.w	$0000,$0766,$0766,$0766,$0766,$0776,$0776,$0776,$0776,$0776,$0776,$0777,$0777,$0777,$0777,$0777	;2
	dc.w	$0000,$0666,$0666,$0666,$0666,$0666,$0766,$0766,$0766,$0766,$0766,$0766,$0776,$0777,$0777,$0777	;3
	dc.w	$0000,$0655,$0655,$0655,$0655,$0665,$0665,$0765,$0765,$0765,$0765,$0766,$0766,$0766,$0777,$0777	;4
	dc.w	$0000,$0555,$0655,$0655,$0655,$0655,$0655,$0755,$0765,$0764,$0765,$0765,$0766,$0766,$0777,$0777	;5
	dc.w	$0000,$0544,$0544,$0544,$0644,$0654,$0654,$0754,$0754,$0764,$0765,$0755,$0665,$0766,$0777,$0777	;6
	dc.w	$0000,$0434,$0533,$0534,$0543,$0543,$0643,$0643,$0653,$0653,$0654,$0655,$0665,$0666,$0777,$0777	;7	
	dc.w	$0000,$0433,$0533,$0533,$0533,$0543,$0643,$0643,$0653,$0653,$0654,$0654,$0665,$0666,$0767,$0777	;8
	dc.w	$0000,$0423,$0422,$0423,$0532,$0542,$0642,$0642,$0642,$0652,$0653,$0654,$0655,$0666,$0767,$0777	;9
	dc.w	$0000,$0322,$0422,$0422,$0522,$0532,$0532,$0632,$0642,$0652,$0653,$0644,$0655,$0655,$0767,$0777	;10
	dc.w	$0000,$0312,$0411,$0412,$0421,$0431,$0531,$0631,$0641,$0641,$0652,$0643,$0654,$0655,$0767,$0777	;11
	dc.w	$0000,$0211,$0311,$0311,$0411,$0421,$0521,$0621,$0631,$0641,$0642,$0643,$0654,$0655,$0767,$0777	;12

	dc.w 	$000,$201,$300,$301,$410,$420,$520,$620,$630,$640,$641,$643,$654,$655,$767,$777						;<----- first

	dc.w    $0000,$0201,$0300,$0301,$0410,$0420,$0520,$0620,$0630,$0640,$0641,$0643,$0654,$0655,$0767,$0777
	dc.w    $0000,$0201,$0300,$0301,$0410,$0420,$0520,$0620,$0630,$0640,$0641,$0643,$0654,$0655,$0767,$0777
	dc.w    $0000,$0201,$0300,$0301,$0310,$0420,$0421,$0521,$0631,$0641,$0641,$0643,$0654,$0655,$0767,$0777
	dc.w    $0000,$0201,$0211,$0301,$0310,$0420,$0421,$0521,$0631,$0641,$0643,$0643,$0654,$0655,$0767,$0777
	dc.w    $0000,$0201,$0211,$0301,$0321,$0322,$0421,$0521,$0631,$0641,$0543,$0643,$0654,$0655,$0767,$0777
	dc.w    $0000,$0201,$0211,$0301,$0321,$0322,$0421,$0522,$0631,$0641,$0543,$0643,$0654,$0656,$0767,$0777
	dc.w    $0000,$0111,$0211,$0312,$0321,$0322,$0421,$0522,$0532,$0641,$0543,$0643,$0653,$0656,$0767,$0777
	dc.w    $0000,$0111,$0211,$0312,$0321,$0322,$0421,$0522,$0532,$0631,$0543,$0643,$0653,$0656,$0667,$0777
	dc.w    $0000,$0111,$0112,$0312,$0321,$0322,$0421,$0522,$0532,$0631,$0643,$0643,$0653,$0656,$0667,$0777
	dc.w    $0000,$0111,$0112,$0312,$0221,$0222,$0421,$0433,$0532,$0631,$0545,$0643,$0653,$0656,$0667,$0777
	dc.w    $0000,$0111,$0112,$0312,$0222,$0222,$0422,$0433,$0532,$0631,$0545,$0643,$0653,$0656,$0667,$0777
	dc.w    $0000,$0111,$0112,$0312,$0222,$0223,$0422,$0434,$0533,$0631,$0545,$0643,$0653,$0656,$0667,$0777
	dc.w    $0000,$0111,$0112,$0312,$0222,$0223,$0422,$0434,$0533,$0632,$0545,$0643,$0653,$0656,$0667,$0777
;;; prg header fo rloading


;target	ds.b	128*128
;
;makeBinaries
;	lea		ball128,a0
;	lea		target,a1
;	jsr		makeBinary
;
;	lea		ball100,a0
;	lea		target,a1
;	jsr		makeBinary
;
;	lea		ball46,a0
;	lea		target,a1
;	jsr		makeBinary
;	rts
;ball128
;makeBinary
;	move.l	a1,a2
;	REPT 128
;		REPT 64
;			move.w	(a0)+,(a1)+
;		ENDR
;	add.w	#128,a0
;	ENDR
;	move.b	#0,$ffffc123
;	rts

;prepS
;	lea	sss+34,a0
;	lea	style,a3
;	lea	skill,a4
;	lea	smfxx,a5
;	move.w	#60-1,d7
;.il
;o set 0
;	REPT 8
;		move.w	o(a0),(a3)+
;		move.w	o+60*160(a0),(a4)+
;		move.w	o+120*160(a0),(a5)+
;o set o+8
;	ENDR
;	add.w	#160,a0
;	dbra	d7,.il
;	rts

plasma1pointer	ds.l	1
plasma2pointer	ds.l	1
plasma3pointer	ds.l	1

plasma1	incbin	"fx/plasma/plasma1.l77"			;16k	(3231)		1902 arj	
plasma2	incbin	"fx/plasma/plasma2.l77"			;16k	(3434)		2111 arj
plasma3	incbin	"fx/plasma/plasma3.l77"			;16k	(5313)		3417 arj


	IFEQ STANDALONE

TAB1:
                DC.B $00,$00,$00,$00		;0
                DC.B $C0,$00,$00,$00		;4
                DC.B $00,$C0,$00,$00		;8
                DC.B $C0,$C0,$00,$00		;12
                DC.B $00,$00,$C0,$00		;16
                DC.B $C0,$00,$C0,$00		;20
                DC.B $00,$C0,$C0,$00		;24
                DC.B $C0,$C0,$C0,$00		;28
                DC.B $00,$00,$00,$C0		;32
                DC.B $C0,$00,$00,$C0		;36
                DC.B $00,$C0,$00,$C0		;40
                DC.B $C0,$C0,$00,$C0		;44
                DC.B $00,$00,$C0,$C0		;48
                DC.B $C0,$00,$C0,$C0		;52
                DC.B $00,$C0,$C0,$C0		;56
                DC.B $C0,$C0,$C0,$C0		;60
TAB2:
                DC.B $00,$00,$00,$00		;0
                DC.B $30,$00,$00,$00		;4
                DC.B $00,$30,$00,$00		;8
                DC.B $30,$30,$00,$00		;12
                DC.B $00,$00,$30,$00		;16
                DC.B $30,$00,$30,$00		;20
                DC.B $00,$30,$30,$00		;24
                DC.B $30,$30,$30,$00		;28
                DC.B $00,$00,$00,$30		;32
                DC.B $30,$00,$00,$30		;36
                DC.B $00,$30,$00,$30		;40
                DC.B $30,$30,$00,$30		;44
                DC.B $00,$00,$30,$30		;48
                DC.B $30,$00,$30,$30		;52
                DC.B $00,$30,$30,$30		;56
                DC.B $30,$30,$30,$30		;60
TAB3:
                DC.B $00,$00,$00,$00		;0
                DC.B $0C,$00,$00,$00		;4
                DC.B $00,$0C,$00,$00		;8
                DC.B $0C,$0C,$00,$00		;12
                DC.B $00,$00,$0C,$00		;16
                DC.B $0C,$00,$0C,$00		;20
                DC.B $00,$0C,$0C,$00		;24
                DC.B $0C,$0C,$0C,$00		;28
                DC.B $00,$00,$00,$0C		;32
                DC.B $0C,$00,$00,$0C		;36
                DC.B $00,$0C,$00,$0C		;40
                DC.B $0C,$0C,$00,$0C		;44
                DC.B $00,$00,$0C,$0C		;48
                DC.B $0C,$00,$0C,$0C		;52
                DC.B $00,$0C,$0C,$0C		;56
                DC.B $0C,$0C,$0C,$0C		;60
TAB4:
                DC.B $00,$00,$00,$00		;0
                DC.B $03,$00,$00,$00		;4
                DC.B $00,$03,$00,$00		;8
                DC.B $03,$03,$00,$00		;12
                DC.B $00,$00,$03,$00		;16
                DC.B $03,$00,$03,$00		;20
                DC.B $00,$03,$03,$00		;24
                DC.B $03,$03,$03,$00		;28
                DC.B $00,$00,$00,$03		;32
                DC.B $03,$00,$00,$03		;36
                DC.B $00,$03,$00,$03		;40
                DC.B $03,$03,$00,$03		;44
                DC.B $00,$00,$03,$03		;48
                DC.B $03,$00,$03,$03		;52
                DC.B $00,$03,$03,$03		;56
                DC.B $03,$03,$03,$03		;60
    ENDC

blockremovelist	include "fx/plasma/blockremovelist2.s"
				
	even


	include 	"fx/plasma/c2ppath2.txt"

panelpointer	ds.l	1
panel2pointer	ds.l	1

panel			incbin	"fx/plasma/p1_text3b.l77"		;(12800/7596)
paneloff		dc.l	0
panel2			
panel_square	incbin	"fx/plasma/p1_notext2.l77"		;(32034/14540)

	IFEQ STANDALONE
alignpointer1				dc.l	block2
alignpointer2				dc.l	block3
alignpointer3				dc.l	block4
alignpointer4				dc.l	block5
alignpointer5				dc.l	block6
alignpointer6				dc.l	block7
alignpointer7				dc.l	block8


	include		lib.s
	include		

music		incbin	main.snd
	ds.b	1024*1024
	ENDC



	SECTION BSS
; general stuff
	IFEQ	STANDALONE

screenpointer				ds.l	1
screenpointer2				ds.l	1
screenpointer3				ds.l	1
screenpointershifter		ds.l	1
screenpointer2shifter		ds.l	1
screen1:					ds.b	65536+65536
screen2:					ds.b	65536
block1:						ds.b	65536	;1
block2:						ds.b	65536	;2
block3:						ds.b	65536	;3
block4:						ds.b	65536	;4
block5:						ds.b	65536	;5
block6:						ds.b	65536	;6
block7:						ds.b	65536	;7
block8:						ds.b	65536	;7
block9:						ds.b	65536	;7
block10:						ds.b	65536	;7
doublescanlinespointer	ds.l	1

	ENDC


;generatedC2P			ds.b	97200+2
at1							ds.l	1
at2							ds.l	1
generatedC2P			ds.l	1			;56450
generatedC2P_copy		ds.l	1			;2306
tab2px_1p				ds.l	1	equ		alignpointer2
tab2px_2p				ds.l	1	equ		alignpointer3
ball1pointer			ds.l	1
ball2pointer			ds.l	1
ball3pointer			ds.l	1
vertStripesPointer		ds.l	1
fixBlocksPointer		ds.l	1	;1538

