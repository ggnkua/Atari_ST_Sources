PRODUCTIVE_TV_CHANGE_1_LINES	equ 98
PRODUCTIVE_TV_CHANGE_2_LINES	equ 10






FOCALLENGTH 			equ 280				; more is less deformed?
FOCALOPT				equ 0					; asr.w #6 in the table generation, 1 scanline profit
SCANLINEWIDTH			equ 160
sintable_size_subpixel	equ 512*2
SHOWMASK				equ 1


number_of_vertices_subpixel	equ 6


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

BE_PRODUCTIVE_FADE_WAITER		equ 100
BE_PRODUCTIVE_FADE_SPEED		equ 1				; higher is slower


;MYM_DUMP1_START					equ AFTER_FLOWER_EFFECT_FRAMES-20				; finetuning for MYM dump starting, where -20 is current finetune value, range <= 0
MYM_DUMP1_NR_PATTERNS			equ 16											; dump duration in patterns, patterns * rows * speed = 16*64*3 = 3072
; starting positions for dump, this is where the dumper must start
MYM_DUMP1_SONG_POS				equ	$13											; when dumping starts, use this song position
MYM_DUMP1_CHAN1_PATTR			equ $0											; when dumping starts, channel 1 is using this pattern
MYM_DUMP1_CHAN2_PATTR			equ $0f											; when dumping starts, channel 2 is using this pattern
MYM_DUMP1_CHAN3_PATTR			equ $0c											; when dumping starts, channel 13is using this pattern

MYM_DUMP1_SONG_POS_NEXT			equ $14											; when current song pattern is done, this is the next pattern
MYM_DUMP1_CHAN1_PATTR_NEXT		equ $0a											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN2_PATTR_NEXT		equ $0b											; when song pattern is done, this is next pattern for channel 1
MYM_DUMP1_CHAN3_PATTR_NEXT		equ $11											; when song pattern is done, this is next pattern for channel 1

; adjusting player settings for continuing playing, after the dumper has done

MYM_DUMP1_SONG_POS_END			equ	$23											; we need to skip the player, since the dumping has been done, but the
MYM_DUMP1_CHAN1_PATTR_END		equ $2c											;	actual player hasnt advanced its position yet, so we modify this here
MYM_DUMP1_CHAN2_PATTR_END		equ $2d
MYM_DUMP1_CHAN3_PATTR_END		equ $0e

MYM_DUMP1_SONG_POS_NEXT_END		equ $24
MYM_DUMP1_CHAN1_PATTR_NEXT_END	equ $0a
MYM_DUMP1_CHAN2_PATTR_NEXT_END	equ $0b
MYM_DUMP1_CHAN3_PATTR_NEXT_END	equ $0e
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
	jsr		init_demo
	jsr		init_after_flower
	move.w	#32000,effect_vbl_counter
	jsr		after_flower_mainloop

.demostart


	
.x
		move.l	screenpointer2,$ffff8200
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts



init_demo
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	move.w	#$f00,$ffff8240+5*2
	rts
	ENDC


init_after_flower
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screenpointer2,d0
	move.l	screen2,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0
	add.l	#$10000,d0

	move.l	d0,xtable2Pointer				
	add.l	#960,d0
	move.l	d0,xtable2_noslopePointer		
	add.l	#960,d0
	move.l	d0,myDrawRoutPosPointer			
	add.l	#2910,d0
	move.l	d0,myDrawRoutNegPointer			
	add.l	#2910,d0
	move.l	d0,myDrawRoutPosNoSlopePointer	
	add.l	#2430,d0
	move.l	d0,myDrawRoutNegNoSlopePointer	
	add.l	#2430,d0														;12600
	move.l	d0,clearScreenSubpixelPointer							
	add.l	#5498,d0														;18098
	move.l	d0,eorScreenSubpixelPointer
	add.l	#10994,d0														;29092
	move.l	d0,productiveBufferPointer
	add.l	#13120,d0
	move.l	d0,ytable2ptr
	add.l	#400,d0
	move.l	d0,ul1ptr
	add.l	#3360,d0
	IFEQ	STANDALONE
	move.l	d0,musicBufferPointer
	ELSE
	lea		peep,a0
	move.l	a0,musicBufferPointer
	ENDC
	move.l	d0,musicDumperPointer

	IFNE	STANDALONE
	lea		songPositionData,a0
	move.b	#MYM_DUMP1_SONG_POS,(a0)+		; pattern
	move.b	#MYM_DUMP1_CHAN1_PATTR,(a0)+
	move.b	#MYM_DUMP1_CHAN2_PATTR,(a0)+
	move.b	#MYM_DUMP1_CHAN3_PATTR,(a0)+

	move.b	#MYM_DUMP1_SONG_POS_NEXT,(a0)+
	move.b	#MYM_DUMP1_CHAN1_PATTR_NEXT,(a0)+
	move.b	#MYM_DUMP1_CHAN2_PATTR_NEXT,(a0)+
	move.b	#MYM_DUMP1_CHAN3_PATTR_NEXT,(a0)+
	jsr		doMymStuff
	
	lea		advanceSNDData,a0

	move.b	#MYM_DUMP1_SONG_POS_END,(a0)+		; pattern
	move.b	#MYM_DUMP1_CHAN1_PATTR_END,(a0)+
	move.b	#MYM_DUMP1_CHAN2_PATTR_END,(a0)+
	move.b	#MYM_DUMP1_CHAN3_PATTR_END,(a0)+

	move.b	#MYM_DUMP1_SONG_POS_NEXT_END,(a0)+
	move.b	#MYM_DUMP1_CHAN1_PATTR_NEXT_END,(a0)+
	move.b	#MYM_DUMP1_CHAN2_PATTR_NEXT_END,(a0)+
	move.b	#MYM_DUMP1_CHAN3_PATTR_NEXT_END,(a0)+
	ENDC

;--------------
;DEMOPAL - color of vertical bars from transition
;--------------
	move.w	#$420,$ffff8240+4*2
	move.w	#$420,$ffff8240+5*2
	move.w	#$420,$ffff8240+6*2
	move.w	#$420,$ffff8240+7*2

    move.w  #$2700,sr
    move.l  #after_flower_vbl,$70
    move.w  #$2300,sr



	jsr		prepProductive
	jsr		preshiftProductive


	jsr		genClearSubpixel


   	jsr		subpixel_init

   	lea		ul1,a0
   	move.l	ul1ptr,a1
   	jsr		cranker


   	rts
after_flower_vbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    subq.w	#1,effect_vbl_counter
    move.l	screenpointer,$ffff8200
    pushall
    swapscreens
    move.w	#0,$ffff8240

    tst.w	allColsOn
    beq		.nocol
;--------------
;DEMOPAL - color of whole screen/scene, when the first bar hits top and has removed the `old' motus logo
;--------------

		move.w	#223,$ffff8240+1*2
		move.w	#445,$ffff8240+2*2
		move.w	#667,$ffff8240+3*2

		move.w	#$420,$ffff8240+4*2
		move.w	#$420,$ffff8240+5*2
		move.w	#$420,$ffff8240+6*2
		move.w	#$420,$ffff8240+7*2

		move.w	#$401,$ffff8240+8*2
		move.w	#$777,$ffff8240+9*2	
		move.w	#$777,$ffff8240+10*2
		move.w	#$777,$ffff8240+11*2
		move.w	#$420,$ffff8240+12*2
.nocol

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	tst.w	productiveTBOFF
	bne		.norm
		tst.w	allColsOn
		beq		.norm
		move.l	#timer_b_open_curtain_splits,$120.w
		subq.w	#1,.bgFlashWaiter
		bge		.cc
			lea		.bgFlashTab,a0
			add.w	.bgFlashOff,a0
			move.w	(a0),timer_b_open_curtain_splits+2
			subq.w	#1,.bgFlashOffWaiter
			bge		.cc
				move.w	#1,.bgFlashOffWaiter
				subq.w	#2,.bgFlashOff
				bge		.cc
					move.w	#0,.bgFlashOff
		jmp	.cc
.norm
		move.l	#timer_b_open_curtain,$120.w

.cc
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w	

	jsr		doProductiveColors

    IFNE	STANDALONE
    	subq.w	#1,.normalFrames
    	blt		.doMym
	    	jsr		musicPlayer+8
	    	jmp		.continue
.doMym
			jsr		replayMymDump
			jsr		advanceSNDPosLocal
.continue
    ENDC

    	jsr		doBarsThing
    	jsr		doCube
    	jsr		beProductiveScroll
    popall
    rte
.mymwaiter	dc.w	120
.bgFlashWaiter	dc.w	240
.bgFlashOffWaiter	dc.w	0
.bgFlashOff	dc.w	36
;--------------
;DEMOPAL - background color flash when the triangle hits teh ground
;--------------
.bgFlashTab
	dc.w	$111
	dc.w	$211
	dc.w	$311
	dc.w	$312
	dc.w	$322
	dc.w	$422
	dc.w	$423
	dc.w	$433
	dc.w	$533
	dc.w	$533
	dc.w	$533
	dc.w	$433
	dc.w	$423
	dc.w	$422
	dc.w	$322
	dc.w	$312
	dc.w	$311
	dc.w	$211
	dc.w	$111



	IFNE STANDALONE
.normalFrames	dc.w	MYM_DUMP1_START
	ENDC

	IFNE	STANDALONE
advanceSNDPosLocal
	jsr		advanceSNDPos
	move.w	#$4e75,advanceSNDPosLocal
	rts
	ENDC


doProductiveColors
	lea		productiveColorFade,a0
	add.w	productiveColorFadeOff,a0
	move.l	(a0)+,$ffff8240+2*1
	move.w	(a0)+,$ffff8240+2*3

	move.l	(a0)+,timer_b_open_curtain_split2+2
	move.w	(a0)+,timer_b_open_curtain_split2+10

	move.l	(a0)+,timer_b_open_curtain_split3+2
	move.w	(a0)+,timer_b_open_curtain_split3+10

	subq.w	#1,.waiter
	bge		.end
		move.w	#3,.waiter
		add.w	#9*2,productiveColorFadeOff
		cmp.w	#6*9*2,productiveColorFadeOff
		ble		.end
			move.w	#6*9*2,productiveColorFadeOff
			subq.w	#1,.ttt
			bge		.end
			move.w	#-1,productiveTBOFF
.end
	rts
.ttt	dc.w	5
.waiter	dc.w	326-45

productiveTBOFF	dc.w	0

productiveWhiteFade	dc.w	0


productiveColorFadeOff	dc.w	0
;--------------
;DEMOPAL - fade of the `be productive' to white
;--------------
productiveColorFade
			;col1,col2,col3,  col1,col2,col3,	col1,col2,col3
	dc.w	$0001,$0723,$0764,$0001,$0732,$0773,$0001,$0633,$0674
	dc.w	$0112,$0723,$0764,$0112,$0732,$0773,$0112,$0644,$0674
	dc.w	$0223,$0734,$0764,$0223,$0743,$0774,$0223,$0755,$0675
	dc.w	$0334,$0745,$0775,$0445,$0754,$0775,$0445,$0766,$0776
	dc.w	$0556,$0756,$0776,$0556,$0765,$0776,$0556,$0777,$0777
	dc.w	$0667,$0767,$0777,$0667,$0776,$0777,$0667,$0777,$0777
haxLoc
	dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777




timer_b_open_curtain_splits
	move.w	#$111,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#PRODUCTIVE_TV_CHANGE_1_LINES,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_split2,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

;--------------
;DEMOPAL - colorsplit for be productive text
;--------------
timer_b_open_curtain_split2
	move.l	#$0010732,$ffff8240+2*1			; label + 2 .l   
	move.w	#$773,$ffff8240+2*3				; label + 10 .w
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#PRODUCTIVE_TV_CHANGE_2_LINES,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_open_curtain_split3,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

;--------------
;DEMOPAL - next color split for be productive text
;--------------
timer_b_open_curtain_split3
	move.l	#$0010633,$ffff8240+2*1
	move.w	#$674,$ffff8240+2*3
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199-PRODUCTIVE_TV_CHANGE_1_LINES-PRODUCTIVE_TV_CHANGE_2_LINES,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte




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

after_flower_mainloop
    move.w  #0,$466
.w  
	tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	tst.w	effect_vbl_counter
    	blt		.next

    	IFNE	STANDALONE
    	jsr		precalc_voxel
    	ENDC

    	IFNE	STANDALONE
    	tst.w	.www
    	beq		.kkk
	    	move.w	#MYM_DUMP1_NR_PATTERNS*192-1,d7					; MYM_DUMP1_NR_PATTERNS * 192 
			jsr		dumpMymFrames
			move.w	#0,.www
.kkk
		ENDC
		jsr		scrumbMem
    jmp		.w
.next
	rts
.www		dc.w	1

ul1ptr		ds.l	1
ul2ptr		ds.l	1

scrumbMem
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.l	#200*160,a0
	add.l	#200*160,a1
	move.w	#50-1,d7
	moveq	#0,d0
.ddd
	REPT 40
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.ddd

;	lea		underline+128+160,a0
	move.l	ul1ptr,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.l	#201*160,a1
	add.l	#201*160,a2
	move.w	#21-1,d7
	moveq	#0,d0
	REPT 8
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	ENDR
.dddd
		movem.l	(a0)+,d0-d6/a3/a4/a5
		movem.l	d0-d6/a3/a4/a5,(a1)
		movem.l	d0-d6/a3/a4/a5,(a2)
		movem.l	(a0)+,d0-d6/a3/a4/a5
		movem.l	d0-d6/a3/a4/a5,40(a1)
		movem.l	d0-d6/a3/a4/a5,40(a2)
		movem.l	(a0)+,d0-d6/a3/a4/a5
		movem.l	d0-d6/a3/a4/a5,80(a1)
		movem.l	d0-d6/a3/a4/a5,80(a2)
		movem.l	(a0)+,d0-d6/a3/a4/a5
		movem.l	d0-d6/a3/a4/a5,120(a1)
		movem.l	d0-d6/a3/a4/a5,120(a2)
		lea		160(a1),a1
		lea		160(a2),a2
	dbra	d7,.dddd

	move.w	#$4e75,scrumbMem
	rts



subpixel_init
;	lea		cubeVertices,a0
	lea		triangleVertices,a0
	lea		currentVerticesSP,a1
	REPT number_of_vertices_subpixel*3
		move.w	(a0)+,(a1)+
	ENDR


	; for printvertices
	jsr		genYTable2
	; for eorfill
	jsr		genSlopeTables
	jsr		generateDrawTables
	move.w	#$4e75,subpixel_init
	rts

genSlopeTables
	move.l	xtable2_noslopePointer,a0
	move.l	#10,d3
	jsr		genXTableDraw

	move.l	xtable2Pointer,a0
	move.l	#12,d3
	jsr		genXTableDraw

	rts	

_currentStepXSubPixel	dc.w	56
_currentStepYSubPixel	dc.w	0
_currentStepZSubPixel	dc.w	0

triangleVertices
a set 105
b set 91

		dc.w	-a*2,-b*2+(b*2)/3,0
		dc.w	0,b*2+(b*2)/3,0
		dc.w	a*2,-b*2+(b*2)/3,0

a set 15
b set 13

		dc.w	-a*2,-b*2+(b*2)/3,0
		dc.w	0,b*2+(b*2)/3,0
		dc.w	a*2,-b*2+(b*2)/3,0


genYTable2
;	lea		ytable2,a0
	move.l	ytable2ptr,a0
	moveq	#0,d0
	move.w	#SCANLINEWIDTH,d1
	move.w	#200-1,d6
.loop
		move.w	d0,(a0)+
		add.w	d1,d0
	dbra	d6,.loop
	rts








generateDrawTables
;	lea		myDrawRoutPos,a0
	move.l	myDrawRoutPosPointer,a0
	lea		myDrawRoutPosStart,a2
	lea		myDrawRoutPosEnd,a3
	jsr		copyCodeTemplate

;	lea		myDrawRoutNeg,a0
	move.l	myDrawRoutNegPointer,a0
	lea		myDrawRoutNegStart,a2
	lea		myDrawRoutNegEnd,a3
	jsr		copyCodeTemplate

;	lea		myDrawRoutPosNoSlope,a0
	move.l	myDrawRoutPosNoSlopePointer,a0
	lea		myDrawRoutPosNoSlopeStart,a2
	lea		myDrawRoutPosNoSlopeEnd,a3
	jsr		copyCodeTemplate

;	lea		myDrawRoutNegNoSlope,a0
	move.l	myDrawRoutNegNoSlopePointer,a0
	lea		myDrawRoutNegNoSlopeStart,a2
	lea		myDrawRoutNegNoSlopeEnd,a3
	jsr		copyCodeTemplate

	rts

genXTableDraw
	move.w	#xbars-1,d6
	moveq	#0,d0		;xoff
	moveq	#0,d1		;joff

.ol	
	REPT 8
		move.w	d0,(a0)+	;xoff
		move.w	d1,(a0)+	;joff
		add.w	d3,d1		;joff inc
	ENDR
	addq.w	#1,d0			;xoff inc
	REPT 8
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		add.w	d3,d1
	ENDR
	addq.w	#2,d1			; joff inc
	addq.w	#7,d0			; xoff inc

	dbra	d6,.ol
	rts



copyCodeTemplate
	sub.l	a2,a3			; number of bytes
	move.l	a3,d4			; save
	lsr.w	#1,d4			; shit down
	sub.w	#1,d4			; one less
	move.l	#xbars-1,d6
.copy
	move.w	d4,d5
	move.l	a2,a1
.doOne
			move.w	(a1)+,(a0)+
		dbra	d5,.doOne

	dbra	d6,.copy
	rts

;+	d7	eor		pixel 10000000
;+	d6	eor		pixel 01000000	
;+	d4	eor 	pixel 00100000
;+	d2	bchg	pixel 00010000	bit 4
;+	d3	eor		pixel 00001000
;+	d2	eor		pixel 00000100
;+	d0	bchg	pixel 00000010	bit 1
;+	d0	eor		pixel 00000001


myDrawRoutPosStart
;	REPT 20
	eor.b	d5,(a0)
	add.w	a1,a0					; add dy int							;2
	add.w	a3,d1					; add dy frac							;2
	bcc.s	*+6						; skip if no overflow					;4
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)+
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d5,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPosEnd

myDrawRoutNegStart
	eor.b	d5,(a0)
	add.w	a1,a0					; add dy int							;2
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)+
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d5,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutNegEnd
	

myDrawRoutPosNoSlopeStart
	eor.b	d5,(a0)
	add.w	a3,d1					; add dy frac							;2
	bcc.s	*+6						; skip if no overflow					;4
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)+
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d5,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPosNoSlopeEnd

myDrawRoutNegNoSlopeStart
	eor.b	d5,(a0)
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)+
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d5,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d6,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d4,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d2,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d3,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d2,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	bchg	d0,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	eor.b	d0,(a0)
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0

myDrawRoutNegNoSlopeEnd



doCube
	subq.w	#1,.waiter
	bge		.end
	jsr		clearScreen1plOpt1

	move.w	_currentStepXSubPixel,d2
	move.w	_currentStepYSubPixel,d4
	move.w	_currentStepZSubPixel,d6
	lea		currentVerticesSP,a2					;8	
	move.l	a2,usp
	lea		projectedVerticesSP,a4				;8
	jsr		calculateRotatedProjectionMulTable


	move.w	_currentStepXSubPixel2,d2
	move.w	_currentStepYSubPixel,d4
	move.w	_currentStepZSubPixel,d6
	lea		currentVerticesSP+3*3*2,a2					;8	
	move.l	a2,usp
	lea		projectedVerticesSP+3*8,a4				;8
	jsr		calculateRotatedProjectionMulTable



;	jsr		cullCubeNormals
	jsr		drawCubeEdges
	jsr		eorFillScreen1plOpt
	jsr		increaseStep

	lea		cubePath,a0
	add.w	pathOff,a0
	move.l	(a0),cubeOff

	add.w	#4,pathOff
	cmp.w	#234*4,pathOff
	ble		.end
		move.w	#234*4,pathOff
		move.w	#$4e75,doCube
.end
	rts
.waiter			dc.w	50
cubeOff			dc.l	200*160
pathOff			dc.w	0
cubePath		include	"data/after_flower/path.s"

increaseStep
	add.w	#2,_currentStepXSubPixel
	and.w	#sintable_size_subpixel-1,_currentStepXSubPixel

	sub.w	#6,_currentStepXSubPixel2
	and.w	#sintable_size_subpixel-1,_currentStepXSubPixel2


.end
	rts	

_currentStepXSubPixel2	dc.w	0

clearVals
	dc.w	40,100	
	dc.w	48,122
	dc.w	56,140
	dc.w	64,156
	dc.w	72,160
	dc.w	80,160
	dc.w	88,156
	dc.w	96,150
	dc.w	104,120
	dc.w	112,100
	dc.w	-1





genClearSubpixel
	lea		clearVals,a0
	move.l	clearScreenSubpixelPointer,a1
	move.l	eorScreenSubpixelPointer,a3
	move.l	a1,a2
	move.l	a3,a4
	move.w	#160,d2
	move.l	.code,d0
	move.l	.codeEor1,d3
	move.l	.codeEor2,d4

.genClearColumn
	move.w	(a0)+,d1
	blt		.end
	move.w	(a0)+,d7
	jsr		genClearCodeSubpixel
	jmp		.genClearColumn
.end
	move.w	#$4e75,(a1)+
	move.w	#$4e75,(a3)+

	rts
.code
	move.w	d0,$1234(a0)
.codeEor1
	move.w	$1234(a0),d0							;4
.codeEor2
	eor.w	d0,$1234(a0)				;6


genClearCodeSubpixel
	move.w	#20*160,d0		;yoff
	add.w	d1,d0			;yoff+xoff
	move.w	d7,d6
	neg.w	d6
	add.w	#160,d6
	lsr.w	#1,d6
	muls	#160,d6
	add.w	d6,d0
	move.w	d0,d3
	move.w	d0,d4
	add.w	d2,d4
.gen
		move.l	d0,(a1)+
		move.l	d3,(a3)+
		move.l	d4,(a3)+
		add.w	d2,d0
		add.w	d2,d3
		add.w	d2,d4
	dbra	d7,.gen
	rts


clearColumn	macro
y_off set \1*SCANLINEWIDTH
x_off set \2
height set \3

y_start set ((160-height)/2)*SCANLINEWIDTH

y set y_off+x_off+y_start
	REPT height
		move.w	d0,y(a0)				;4				
y set y+SCANLINEWIDTH
	ENDR
	endm

cubevertWaiter	dc.w	3

clearScreen1plOpt1
	move.l	screenpointer2,a0
	add.w	#6,a0
	add.l	cubeOff,a0
	IFEQ SHOWMASK
		moveq	#-1,d0
	ELSE
		moveq	#0,d0
	ENDC
	move.l	clearScreenSubpixelPointer,a6
	jmp		(a6)

;			clearColumn	20,40,100	
;			clearColumn	20,48,122
;			clearColumn	20,56,140
;			clearColumn	20,64,156
;			clearColumn	20,72,160
;			clearColumn	20,80,160
;			clearColumn	20,88,156
;			clearColumn	20,96,150
;			clearColumn	20,104,120
;			clearColumn	20,112,100
;	rts

eorfill macro
y_off set \1*SCANLINEWIDTH
x_off set \2
height set \3

y_start set ((160-height)/2)*SCANLINEWIDTH

y set y_off+x_off+y_start
	REPT height-1
		move.w	y(a0),d0							;4
		eor.w	d0,y+SCANLINEWIDTH(a0)				;6
y set y+SCANLINEWIDTH
	ENDR
	endm

eorFillScreen1plOpt
	move.l	screenpointer2,a0
	add.l	cubeOff,a0
	add.w	#6,a0
	move.l	eorScreenSubpixelPointer,a6
	jmp		(a6)
;			eorfill	20,40,100						;90
;			eorfill	20,48,122						;212
;			eorfill	20,56,140						;352
;			eorfill	20,64,156						;506
;			eorfill	20,72,160					;666
;			eorfill	20,80,160						;826	
;			eorfill	20,88,156						;980
;			eorfill	20,96,150						;1126
;			eorfill	20,104,120						;1246
;			eorfill	20,112,100						;1336
;	rts


drawEdge macro
;	lea		projectedVertices,a0
	move.l	a5,a0
	move.l	\1*8+0(a0),d0
	move.l	\1*8+4(a0),d1
	move.l	\2*8(a0),d2
	move.l	\2*8+4(a0),d3
	move.l	usp,a0
	add.w	#\3,a0
	jsr		drawLines
	move.w	(a6),(a2)
;	move.w	smcStore,(a2)
	endm



drawCubeEdges
	move.l	screenpointer2,a0
	lea		projectedVerticesSP,a5
	lea		smcStore,a6
;	move.l	#ytable2,d7
	move.l	ytable2ptr,d7
	add.l	cubeOff,a0
	add.w	#6,a0
	move.l	a0,usp
;	tst.w	facesVisible
;	beq		.skipFront
		drawEdge 0,1,0
		drawEdge 1,2,0
		drawEdge 2,0,0

		drawEdge 3,4,0
		drawEdge 4,5,0
		drawEdge 5,3,0


;		drawEdge 3,0,0				;0,1,2,3
;.skipFront
	rts


matrixValues		ds.w	9
; rotation matrix code
; determines the rotation matrix and rotates the vertices, using multiplications

_sinAsp		equr d1
_cosAsp		equr d2
_sinBsp		equr d3
_cosBsp		equr a2
_sinCsp		equr d5
_cosCsp		equr d6
calculateRotatedProjectionMulTable
	lea		_sintable512,a0
	lea		_sintable512+(sintable_size_subpixel/4),a1
   

	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),a2					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

	lea		matrixValues,a3

;	xx = [cosA * cosB]
	move.w	_cosBsp,d4					;d4
	muls	_cosAsp,d4					;d2
	swap	d4
	move.w	d4,.xx+2

;	xy = [sinA * cosB]
	move.w	_cosBsp,d4					;d4					;d4 free
	muls	_sinAsp,d4					;d1
	swap	d4
	move.w	d4,.xy+2

;	xz = [sinB]	
	move.w	_sinBsp,d4
	asr.w	#1,d4
	move.w	d4,.xz+2


;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinAsp,d4
	muls	_cosCsp,d4
	move.w	_cosAsp,d0
	muls	_sinBsp,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinCsp,d0
	add.l	d4,d0
	swap	d0
	move.w	d0,.yx+2

;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosAsp,d4
	neg		d4
	muls	_cosCsp,d4
	move.w	_sinAsp,d0
	muls	_sinBsp,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinCsp,d0
	add.l	d4,d0
	swap	d0
	move.w	d0,.yy+2


;	yz = [-cosB * sinC]
	move.w	_cosBsp,d4					;d4
	neg.w	d4
	muls	_sinCsp,d4					;d5
	swap	d4
	move.w	d4,.yz+2


;;	zx = [sinA * sinC - cosA * sinB * cosC]
;	move.w	_sinAsp,d4
;	muls	_sinCsp,d4
;	move.w	_cosAsp,d0
;	muls	_sinBsp,d0
;	lsl.l	#1,d0
;	swap	d0
;	muls	_cosCsp,d0
;	sub.l	d0,d4
;	move.l	d4,_zxsp								; save for culling
;	swap	d4
;	IFEQ	PRECISEROTATION
;	move.w	d4,.zx+2
;	ELSE
;	move.w	d4,(a3)+
;	ENDC

;;	zy = [-cosA * sinC - sinA * sinB * cosC]
;	move.w	_cosAsp,d4
;	muls	_sinCsp,d4
;	neg.l	d4
;	move.w	_sinAsp,d0
;	muls	_sinBsp,d0
;	lsl.l	#1,d0
;	swap	d0
;	muls	_cosCsp,d0
;	sub.l	d0,d4
;	move.l	d4,_zysp								; save for culling
;	swap	d4
;	IFEQ	PRECISEROTATION
;	move.w	d4,.zy+2
;	ELSE
;	move.w	d4,(a3)+
;	ENDC
;
;
;;;	zz = [cosB * cosC]
;	move.w	_cosBsp,d4
;	muls	_cosCsp,d4
;	move.l	d4,_zzsp
;	swap	d4
;	IFEQ	PRECISEROTATION
;	move.w	d4,.zz+2
;	ELSE
;	move.w	d4,(a3)+
;	ENDC
	
.rotatePrecise
	move.l	usp,a2
	move.w	#number_of_vertices_subpixel/2,d6
	subq.w	#1,d6
	move.l	#SCANLINEWIDTH<<16,a0
	move.l	#99<<16,a1
.rotateNew
	movem.w	(a2)+,d0-d2			;24

	move.l	d0,d3				;4						; move.l	#xx,d3		;12
.xx	muls	#313,d3				;44						; move.l	#xy,d4		;12
	move.l	d1,d4				;4						; move.l	#xz,d5		;12
.xy	muls	#313,d4				;44						; add.l		d3,d5		;8
	add.l	d4,d3				;8						; add.l		d4,d5		;8		
	move.l	d2,d4				;4						; lsl.l		#7,d5		;24		76 vs
.xz	muls	#313,d4				;44
	add.l	d4,d3				;8		160						

	move.l	d0,d4
.yx	muls	#323,d4
	move.l	d1,d5
.yy	muls	#323,d5
	add.l	d5,d4
	move.l	d2,d5
.yz muls	#323,d5
	add.l	d5,d4

	add.l	a0,d3
	add.l	a1,d4

	move.l	d3,(a4)+
	move.l	d4,(a4)+


;.zx	muls	#313,d0
;.zy	muls	#313,d1
;.zz	muls	#313,d2
;	add.l	d0,d2
;	add.l	d1,d2									;16 ; 16
;
;
;	move.l	#256<<20,d0		;focal length														;12
;	move.l	d0,d1																				;4
;	lsl.l	#4,d2			; z value				; 16.4 ; 12									;16
;	add.l	d2,d1			; focallength + z													;8
;	lsl.l	#2,d1			; 6 bits of fraction with it										;12
;	swap	d1																					;4
;	divs	d1,d0			; lower holds value													;144	--> 200 cycles
;
;	asr.w	#2,d0
;
;	add.l	d4,d4			;8	
;	add.l	d4,d4			;8
;	add.l	d4,d4			;8
;	add.l	d4,d4			;8
;	swap	d4
;	muls	d0,d4	
;	add.l	d3,d3			;8
;	add.l	d3,d3			;8
;	add.l	d3,d3			;8
;	add.l	d3,d3			;8
;	swap	d3
;	muls	d0,d3



	dbra	d6,.rotateNew
	rts


blank	ds.l	1
skipLines
	lea		blank,a2
	rts

upslope	dc.w	0


errorCorrect	macro
		move.l	d6,d3			; FyInc			
		lsl.l	#8,d3			; max 512
		swap	d3
		mulu	d5,d3
		lsr.l	#8,d3
		tst.w	upslope
		beq		.adderr
.suberr
		sub.l	d3,d1
		jmp		.noCorrection
.adderr
		add.l	d3,d1
	endm

divideShit	macro
		divideShitDiv
	ENDM


divideShitDiv	macro
	; determine slope
	; dx/dy				; dx = d2; 16.16 int.frac
	;					; dy = d3; 16.16 int.frac	of both, only max 512 bits used (can assume 256 as well)
						;							2^9 = 512, so we have 7 bits left for fraction 

	; divs stuff:
	;	uuuu llll
	;	---- dddd
	;	--> 
	;	put 2 longwords in, get two words out, one word int, one int frac
	;	y/x = 
	;	
	;	I want output like: 16 int, 16 frag
	lsl.l	#8,d3		; up 7, because source int is max 512
	lsl.l	#8,d2		; ditto

	sub.w	d3,d3		; clear lower

	swap	d3			
	swap	d2			

	divu	d2,d3		; result is whole

	move.w	d3,d6		; whole
	sub.w	d3,d3		; clear lower

	divu	d2,d3		; divide remaining
	swap	d6			; swap
	move.w	d3,d6		; remainder
	endm




; d0,d1,d2,d3 in
drawLines
; 	lea		ytable2,a1
	move.l	d7,a1
	move.w	#0,upslope
	cmp.l	d0,d2
	bge.s	.noswap
		exg		d0,d2
		exg		d1,d3
.noswap
	move.l	d0,d5
	add.l	#$ffff,d5
	sub.w	d5,d5								; round x_left
	move.l	d2,d4
	add.l	#$ffff,d4
	sub.w	d4,d4								; round x_right
	sub.l	d5,d4														; d5 = ceil (xleft)
	ble		skipLines

	sub.l	d0,d2		; x_right - x_left 
	ble		skipLines

	sub.l	d1,d3		; y_right - y_left
	bgt		.up
		move.w	#-1,upslope
		neg.l	d3
.up
	divideShit

; # the error we lost is (1.0-orig_y_frac) or (ceil_y - orig_y)
; Fxerr = (ix0 << 16) - Fx0			# ceil'd x minus original x = +ve error lost
	move.l	d5,d2
	sub.l	d0,d5									; x_rounding_error	
	beq.s	.noCorrection	
; # compensate Y for rounding error in X
; # CAUTION: I HAVE NO FUCKING IDEA why the int(...) cast is needed around the shift. it's shifting an int. wtf ?_? python
; # if you remove this, the PlotPixelRaw complains of non-integer parameters
; Fyscan = Fy0 + int(int(Fyinc * Fxerr) >> 16)	# assumes ceil() for rounding earlier
;		move.l	d7,d3			; FyInc			
;		lsl.l	#8,d3			; max 512
;		swap	d3
;		mulu	d5,d3
;		lsr.l	#8,d3
;		tst.w	upslope
;		beq		.adderr
;.suberr
;		sub.l	d3,d1
;		jmp		.noCorrection
;.adderr
;		add.l	d3,d1
	errorCorrect
.noCorrection
	; d6 is 16.16


 

	; y offset to screen
	add.l	#$ffff,d1			; y_corrected + 0.9999	
	swap	d1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	; we need to put this here for some slope opt
	move.w	d6,a3
	swap 	d6				; int slope
	add.w	d6,d6
	bne		.gotSlope
	; if this is 0, then we dont need no stinkin slopes, and this influences the xtable selection AND drawRout detection
.noSlope
;	lea		xtable2_noslope,a1
	move.l	xtable2_noslopePointer,a1
	tst.w	upslope
	beq		.positive_noslope
;		lea		myDrawRoutNegNoSlope,a2
		move.l	myDrawRoutNegNoSlopePointer,a2
	jmp		.go
.positive_noslope
;		lea		myDrawRoutPosNoSlope,a2		; for smc
		move.l	myDrawRoutPosNoSlopePointer,a2
	jmp		.go

.gotSlope
	move.w	(a1,d6.w),d6
	; x offset to screen
;	lea		xtable2,a1			; xtable
	move.l	xtable2Pointer,a1
	tst.w	upslope
	beq		.positive
 		neg.w	d6
;		lea		myDrawRoutNeg,a2
		move.l	myDrawRoutNegPointer,a2
	jmp		.go
.positive
;		lea		myDrawRoutPos,a2		; for smc
		move.l	myDrawRoutPosPointer,a2
.go

	swap	d2					; get integer
	add.w	d2,d2				; *4
	add.w	d2,d2
	add.w	d2,a1				; add x_left starting position
;	add.w	(a1)+,d1			; x+y-offset
;	add.w	d1,a0
	add.w	(a1)+,d1			; x+y-offset
	add.w	d1,a0

	move.l	a2,a4
	swap	d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	(a1,d4.w),a2
;	move.w	(a2),smcStore		; make this smc, and free up a3
	move.w	(a2),(a6)		; make this smc, and free up a3
	move.w	#$4E75,(a2)			; rts

	; using for SMC
	;	a0		screenpointer
	;	a1		?
	;	a2,a3

	add.w	(a1),a4
	
	move.w	d6,a1
	move.w	#%10000000,d5
	move.w	#%01000000,d6				; this can be moved outside loop?
	move.w	#%00100000,d4
	moveq	#8,d3
	moveq	#4,d2
	moveq	#1,d0
	swap	d1
	jmp		(a4)	


fillLine
	move.w	#$111,$ffff8242
	move.l	screenpointer2,a0
	moveq	#-1,d0
	subq.w	#1,.times1x
	blt		.times2
	lea		71*160+64(a0),a0
	move.w	#29-1,d7
.gogo
.x set 0	
		REPT 12
			move.w	d0,.x(a0)
.x set .x+8
		ENDR
		lea		320(a0),a0
	dbra	d7,.gogo
	rts
.times2
	subq.w	#1,.times2x
	blt		.times3
	lea		5*160+64(a0),a0
	move.w	#31-1,d7
	jmp		.gogo

.times3
	subq.w	#1,.times3x
	blt		.endit
	lea		133*160+64(a0),a0
	move.w	#31-1,d7
	jmp		.gogo

.endit
	move.w	#$4e75,beProductiveScroll2VBL
	rts
.times1x	dc.w	2
.times2x	dc.w	2
.times3x	dc.w	2


beProductiveScroll2VBL

;	jsr		copyProductiveScroll
	jsr		copyProductiveScroll1plan




	add.w	#20*41*4,productiveSourceOff
	cmp.w	#20*41*4*4,productiveSourceOff
	bne		.ks

		move.w	#0,productiveSourceOff
		add.w	#1,productiveSteps
		cmp.w	#19,productiveSteps
		bne		.ks
			move.w	#20*41*4*3,productiveSourceOff
			move.w	#18,productiveSteps
			move.w	#$4e75,copyProductiveScroll1plan
			subq.w	#1,.times
			blt		.quitit
			jsr		fillLine
.ks
	rts
.quitit
	move.w	#$4e75,beProductiveScroll2VBL
	rts
.times	dc.w	6



beProductiveScroll
	subq.w	#1,.start
	bge		.ks

		subq.w	#1,.1planwait
		blt		.do1plan
			jsr		copyProductiveScroll
			jmp		.cont
.do1plan
		jsr		copyProductiveScroll1plan
.cont

	sub.w	#1,.waiter
	bge		.ks
		move.w	#1,.waiter
	add.w	#20*41*4,productiveSourceOff
	cmp.w	#20*41*4*4,productiveSourceOff
	bne		.ks
		move.w	#0,productiveSourceOff
		add.w	#1,productiveSteps
		cmp.w	#20,productiveSteps
		bne		.ks
			move.w	#$4e75,beProductiveScroll
.ks

	rts
.waiter		dc.w	1
.start		dc.w	320-9
.1planwait	dc.w	29-10

productiveBufferPointer	dc.l	0

copyProductiveScroll
	move.l	productiveBufferPointer,a0
;	lea		productiveBuffer,a0
	move.l	screenpointer2,a1
	add.w	#82*160,a1

	move.w	productiveSteps,d7
	add.w	productiveSourceOff,a0
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	neg.w	d7
	add.w	#19,d7

.lt
.y set 0
.y2 set 0
	REPT 41
		move.l	.y(a0),.y2(a1)
.y set .y+80
.y2 set .y2+160
	ENDR
	lea		4(a0),a0
	lea		8(a1),a1
	dbra	d7,.lt
	rts

copyProductiveScroll1plan
	move.l	productiveBufferPointer,a0
;	lea		productiveBuffer,a0
	move.l	screenpointer2,a1
	add.w	#82*160,a1

	move.w	productiveSteps,d7
	add.w	productiveSourceOff,a0
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	neg.w	d7
	add.w	#19,d7

.lt
.y set 0
.y2 set 0
	REPT 41							;738
		move.l	.y(a0),d0
		move.l	d0,d1
		swap	d0
		or.w	d1,d0
		swap	d0
		sub.w	d0,d0
		move.l	d0,.y2(a1)
.y set .y+80
.y2 set .y2+160
	ENDR
	lea		4(a0),a0
	lea		8(a1),a1
	dbra	d7,.lt


		subq.w	#1,.ttttx
		bge		.lll
			move.w	#BE_PRODUCTIVE_FADE_SPEED,.ttttx
			sub.w	#$111,$ffff8242
			bgt		.lll
				move.w	#$111,$ffff8242
.lll
			move.w	$ffff8242,d0
			move.w	d0,haxLoc


	rts
.ttttx		dc.w	BE_PRODUCTIVE_FADE_WAITER	


productiveSourceOff	dc.w	0
productiveSteps		dc.w	0

beProductive
;	lea		productive+128,a0
;	lea		productiveBuffer,a0
;	lea		productiveBuffer+38*20*4,a0			; 4
	move.l	productiveBufferPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	move.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	add.w	#82*160,d0 
	add.w	d0,a1
	add.w	d0,a2
.y set 0
	REPT 41								;1804
		move.l	(a0)+,d0
		move.l	d0,.y(a1)
		move.l	d0,.y(a2)
		move.l	(a0)+,d0
		move.l	d0,.y+8(a1)
		move.l	d0,.y+8(a2)
		move.l	(a0)+,d0
		move.l	d0,.y+16(a1)
		move.l	d0,.y+16(a2)
		move.l	(a0)+,d0
		move.l	d0,.y+24(a1)
		move.l	d0,.y+24(a2)
		lea		20*4-4*4(a0),a0
.y set .y+160
	ENDR
	rts

doBarsThing
	lea		barSine,a0
	add.w	barOff,a0
	add.w	#0,a0
	move.w	(a0),d7
	bne		.kkk
		move.w	#1,d7
.kkk
	cmp.w	#200,d7
	bne		.kkka
		move.w	#-1,.bar1top
		move.w	#0,d0
		jsr		beProductive
;--------------
;DEMOPAL - color of vertical bars from transition; extra ? :)
;--------------		
		move.w	#$420,$ffff8240+4*2
		move.w	#$420,$ffff8240+5*2
		move.w	#$420,$ffff8240+6*2
		move.w	#$420,$ffff8240+7*2
		move.w	#-1,allColsOn

.kkka
	move.w	.bar1top,d1
	move.w	#0,d0
	jsr		drawBar2

;	add.w	#$020,$ffff8240

	lea		barSine,a0
	add.w	barOff,a0
	add.w	#-14,a0
	move.w	(a0),d7
	bne		.kkk2
		move.w	#1,d7
.kkk2

	cmp.w	#200,d7
	bne		.kkka2
		move.w	#-1,.bar2top
		move.w	#32,d0
		jsr		beProductive
.kkka2
	move.w	.bar2top,d1

	move.w	#32,d0
	jsr		drawBar2

;	add.w	#$020,$ffff8240

	lea		barSine,a0
	add.w	barOff,a0
	add.w	#-28,a0
	move.w	(a0),d7
	bne		.kkk3
		move.w	#1,d7
.kkk3


	cmp.w	#200,d7
	bne		.kkka3
		move.w	#-1,.bar3top
		move.w	#64,d0
		jsr		beProductive
.kkka3
	move.w	.bar3top,d1


	move.w	#64,d0
	jsr		drawBar
;	add.w	#$020,$ffff8240


	lea		barSine,a0
	add.w	#-42,a0
	add.w	barOff,a0
	move.w	(a0),d7
	bne		.kkk4
		move.w	#1,d7
.kkk4

	cmp.w	#200,d7
	bne		.kkka4
		move.w	#-1,.bar4top
		move.w	#96,d0
		jsr		beProductive
.kkka4
	move.w	.bar4top,d1

	move.w	#96,d0
	jsr		drawBar

;	add.w	#$020,$ffff8240

	lea		barSine,a0
	add.w	#-56,a0
	add.w	barOff,a0
	move.w	(a0),d7
	bne		.kkk5
		move.w	#1,d7
.kkk5

	cmp.w	#200,d7
	bne		.kkka5
		move.w	#-1,.bar5top
		move.w	#128,d0
		jsr		beProductive
.kkka5
	move.w	.bar5top,d1

	move.w	#128,d0
	jsr		drawBar
;	add.w	#$020,$ffff8240

	add.w	#2,barOff
	cmp.w	#112*2,barOff
	blt		.okxx
		move.w	#$4e75,doBarsThing
.okxx
;	jsr		clearBlocks
.skipbars
	rts
.bar1top	dc.w	0
.bar2top	dc.w	0
.bar3top	dc.w	0
.bar4top	dc.w	0
.bar5top	dc.w	0

allColsOn	dc.w	0

drawBar

	move.l	screenpointer2,a6
	add.w	#320,a6
	add.w	d0,a6
	moveq	#0,d0
	moveq	#-1,d2


	tst.w	d7
	ble		.sttt


	tst.w	d1					; 0 = no clear
	beq		.noclear

	move.w	#200-1,d6
	sub.w	d7,d6
	blt		.skip
.clear
		move.w	d0,4(a6)
		move.w	d0,12(a6)
		move.w	d0,20(a6)
		move.w	d0,28(a6)
		lea		160(a6),a6
	dbra	d6,.clear
.skip
	jmp		.bot
.noclear
	; need to adjust
	move.w	#200-1,d6
	sub.w	d7,d6
	muls	#160,d6
	add.w	d6,a6

.bot
	subq.w	#1,d7
.dd
		move.w	d2,4(a6)
		move.w	d2,12(a6)
		move.w	d2,20(a6)
		move.w	d2,28(a6)
		lea		160(a6),a6
	dbra	d7,.dd
.sttt
	rts

drawBar2
	move.w	-4(a0),d6		; old val
	move.l	screenpointer2,a6
	add.w	#320,a6
	add.w	d0,a6
	moveq	#0,d0
	moveq	#-1,d2


	tst.w	d7
	ble		.sttt


	tst.w	d1					; 0 = no clear
	beq		.noclear

	move.w	#200-1,d6
	sub.w	d7,d6
	blt		.skip
.clear
		move.w	d0,4(a6)
		move.w	d0,12(a6)
		move.w	d0,20(a6)
		move.w	d0,28(a6)
		lea		160(a6),a6
	dbra	d6,.clear
.skip
	jmp		.sttt
.noclear

	; need to adjust
	move.w	#200-1,d6
	sub.w	d7,d6
	muls	#160,d6
	add.w	d6,a6
.bot

	moveq	#0,d2
	moveq	#-1,d3
	sub.w	d3,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d2,d6
	move.l	d3,a0
	move.l	d2,a1
	move.l	d3,a2

	subq.w	#1,d7
.dd
		movem.l	d2/d3/d4/d5/d6/a0/a1/a2,(a6)
		lea		160(a6),a6
	dbra	d7,.dd
.sttt
	rts

barOff	dc.w	0
	REPT 30
		dc.w	0
	ENDR
barSine	
	include	"data/diag/barMove3.s"
	REPT 30
		dc.w	0
	ENDR


	section DATA
	IFEQ	STANDALONE
_sintable512					include	"data/sintable_amp32768_steps512.s"
	ENDC
_zxsp								ds.l	1
_zysp								ds.l	1
_zzsp								ds.l	1
facesVisible	
	ds.w	6
	dc.w	-1

xbars equ 15			

xtable2Pointer				ds.l	1			;960
xtable2_noslopePointer		ds.l	1			;960
myDrawRoutPosPointer		ds.l	1			;2910
myDrawRoutNegPointer		ds.l	1			;2910
myDrawRoutPosNoSlopePointer	ds.l	1			;2430
myDrawRoutNegNoSlopePointer	ds.l	1			;2430


;xtable2							ds.b	xbars*64			
;xtable2_noslope					ds.b	xbars*64			
;myDrawRoutPos					ds.b	xbars*194
;myDrawRoutNeg					ds.b	xbars*194			
;myDrawRoutPosNoSlope			ds.b	xbars*162
;myDrawRoutNegNoSlope			ds.b	xbars*162			

currentVerticesSP				ds.w	32
projectedVerticesSP				ds.w	32
ytable2ptr						ds.l	1
smcStore						ds.w	1





roxr4	macro 	;bpl1_extend, bpl2_extend, bpl1_next_extend, bpl2_next_extend

	; bpl1
		movem.w	(a0)+,d0-d7		;8 = 4 blocks			; .... !!!! is format
		swap 	d0	;bpl1
		sub.w	d0,d0
		swap 	d1	;bpl2
		sub.w	d1,d1
		swap 	d2	;bpl1
		sub.w	d2,d2
		swap 	d3	;bpl2
		sub.w	d3,d3
		swap 	d4	;bpl1
		sub.w	d4,d4
		swap 	d5	;bpl2
		sub.w	d5,d5
		swap 	d6	;bpl1
		sub.w	d6,d6
		swap 	d7	;bpl2
		sub.w	d7,d7

		ror.l	#4,d0	;1
		ror.l	#4,d1	;2
		ror.l	#4,d2	;1
		ror.l	#4,d3	;2
		ror.l	#4,d4	;1
		ror.l	#4,d5	;2
		ror.l	#4,d6	;1
		ror.l	#4,d7	;2

		move.w	d6,\3
		move.w	d7,\4


		swap	d6		;1
		swap	d7		;2

		or.w	d4,d6
		or.w	d5,d7

		swap	d4
		swap	d5

		or.w	d2,d4
		or.w	d3,d5

		swap	d2
		swap	d3

		or.w	d0,d2
		or.w	d1,d3

		swap	d0
		swap	d1

		move.w	d7,7*2(a1)

		move.w	\1,d7
		or.w	d7,d0
		move.w	\2,d7
		or.w	d7,d1

		movem.w	d0-d6,(a1)
		lea		8*2(a1),a1

	endm

preshiftProductive
;	lea		productiveBuffer,a0					; 0
;	lea		productiveBuffer+38*20*4,a1			; 4
	move.l	productiveBufferPointer,a0
	move.l	a0,a1
	add.w	#41*20*4,a1

	move.w	#41*3-1,.times
.rockit
		move.l	#0,a2
		move.l	a2,a3

		roxr4	a2,a3,a4,a5		;4
		roxr4	a4,a5,a2,a3		;8
		roxr4	a2,a3,a4,a5		;12
		roxr4	a4,a5,a2,a3		;16
		roxr4	a2,a3,a4,a5		;20
	subq.w	#1,.times
	bge		.rockit
	rts
.times


prepProductive
	lea		productivecrk,a0
	move.l	productiveBufferPointer,a1
	jsr		cranker
	rts

;	lea		productive+128,a0
;	move.l	productiveBufferPointer,a1
;	move.l	a1,a2
;	add.w	#79*160,a0
;	move.w	#41-1,d7
;.cp
;.x set 0
;	REPT 20
;		move.l	.x(a0),(a1)+
;.x set .x+8
;	ENDR
;	lea		160(a0),a0
;	dbra	d7,.cp
;
;	sub.l	a2,a1
;	move.b	#0,$ffffc123
;
;	rts

productivecrk	incbin	"data/diag/beproductive.crk"			;1927
	even

ul1	incbin	"data/ul1.crk"
	even
ul2	incbin	"data/ul2.crk"
	even

;productive		incbin	"gfx/productive.neo"

clearScreenSubpixelPointer	dc.l	0
eorScreenSubpixelPointer	dc.l	0


	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
		include		lib/mymdump.s
		include		musicplayer.s			;30kb
    ENDC


    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
musicBufferPointer	ds.l	1
cummulativeCount	ds.w	1
snd
	ENDC
