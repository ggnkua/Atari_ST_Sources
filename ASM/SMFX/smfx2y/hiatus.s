; todo:
; - bitplane animation converter
; - word-length text writer
; - multiple sequence text writer
; - load error screen (no grtz to diver?)

; - moire circles
; - zooming smfx logo
; - rotozoomer
; - sprites
; - starfield + logowobble

; c2p effects:
;	- fire
;	- tunnel
;	- rotozoomer
;	- zooming smfx logo
;	- moire circles
;	- 3d stuff

; setup:
; 1,2,3-4,5,6,7

; 0... loading... spectrum blank screen... (nice to have)
; spectrum; 
;	1). varying laoding screen on tones.... loading smfx2y
; when thing comes, we move from loading things, to raster bars
; fade to background color
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

	ENDC


GENERATE_FONT		equ FALSE
GENERATE_SPECFONT	equ	FALSE

_nr_font_rows		equ 3
_nr_font_columns	equ 20

_font_height		equ 8				; height * 4 * 20 * 3
_font_width			equ 1
_font_bitplanes		equ	4


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init
	move.l	#memBase+256,d0									;
	sub.b	d0,d0
	move.l	d0,screenpointer
	add.l	#$9000,d0										;				
	move.l	d0,screenpointer2
	add.l	#$9000,d0										;	36864 * 2 + 256		=  73984
	move.l	d0,fontBufferPointer				; 61504
	add.l	#$10000,d0										;		139520
	move.l	d0,c2pSourcePtr									; 		327680	=  467200-40000
;	move.l	d0,


;	jsr		chunkyMul			; multiply picture data into buffers, even and uneven
	nop
	nop
;	jsr		generate2pxTabs


;	jsr		c2pTest



	IFEQ	GENERATE_FONT
		jsr		prepBuffer
	ENDC
	IFEQ	GENERATE_SPECFONT
		jsr		prepCopy8x14
	ENDC
	jsr		copyFirst

	jsr		checkTag

	jsr		init_spectrum_boot

	jsr		init_spectrum_load

	jsr		init_transision

	jsr		init_demos

	jsr		init_poetry

	jsr		init_smfx2y

.x
	tst.w	$466.w
	beq		.x
	clr.w	$466.W

;	move.w	#$0,$ffff8240
	moveq	#0,d0
	move.b	music2+$b8,d0
	cmp.b	#$99,d0
	bne		.nnn2
		move.b	#0,music2+$b8
		subq.w	#1,.termtimes
		bne		.nnn2
			move.w	#-1,endDemo

.nnn2


		jsr		crankIt
		tst.w	endDemo
		beq		.nostop
			jsr		terminateDemo
			jmp		.endd
.nostop

    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;
    rts
.termtimes	dc.w	3
.endd
	moveq	#0,d0
	move.l	screenpointer2,a0
	move.l	screenpointer,a1
	move.w	#200-1,d7
.cl
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
	dbra	d7,.cl

;	move.l	#dummy,$114.w
;	move.l	#dummy,$70.w
;	clr.b	$fffffa09.w         ;Interrupt enable B (Timer-C & D)
;	clr.b	$fffffa15.w         ;Interrupt mask B (Timer-C & D)
;	jsr		music2+4
;		move.l	#dummy,$68.w				;Install our own HBL (dummy)
;		move.l	#dummy,$134.w				;Install our own Timer A (dummy)
;		move.l	#dummy,$120.w				;Install our own Timer B
;		move.l	#dummy,$114.w				;Install our own Timer C (dummy)
;		move.l	#dummy,$110.w				;Install our own Timer D (dummy)
;		move.l	#dummy,$118.w				;Install our own ACIA (dummy)
;		clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
;		clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
;		clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
;		clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
;	move.l	#$08000000,$ffff8800.w		;Silence!
;	move.l	#$09000000,$ffff8800.w
;	move.l	#$0a000000,$ffff8800.w


	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

	move.w	#$777,$ffff8240
	move.w	#$0,$ffff8240+2*1
	move.w	#$0,$ffff8240+2*2


;	lea		smfx2y+128+65*160,a0
;	move.l	screenpointer2,a1
;	add.w	#32000-10*160+2,a1
;	jsr		copy8x14

	lea		a8x14Buffer,a0
	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	jsr		copy8x14b


.dddd
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .dddd                                       ;


	move.l	#dummy,$114.w
	move.l	#dummy,$70.w
	clr.b	$fffffa09.w         ;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w         ;Interrupt mask B (Timer-C & D)
	jsr		music2+4
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
	move.l	#$08000000,$ffff8800.w		;Silence!
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	rts
	ENDC

waitFrames macro
	move.w	#\1,waitFramesTmp
.wait\@
	tst.w	$466.w
	beq		.wait\@
		move.w	#0,$466.w
		subq.w	#1,waitFramesTmp
		bge		.wait\@

        ENDM
waitFramesTmp 	dc.w	-1       

; this puts a black screen, removes and shows thing
init_spectrum_boot
	move.w	#-1,$ffff8240+0*2
	move.w	#-1,$ffff8240+1*2
	; paint black
    move.l	screenpointer2,a0
    move.w	#-1,d0
    move.w	#200-1,d7
.doLine
.x set 0
	REPT 20
		move.w	d0,.x(a0)
.x set .x+8
	ENDR
	add.w	#160,a0
	dbra	d7,.doLine
	; turn black
	move.w	#0,$ffff8240+1*2
	move.w	#0,$ffff8240+3*2
	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

;	lea		smfx2y+128+8*160,a0
;	move.l	screenpointer2,a1
;	add.w	#32000-10*160+2,a1
;	jsr		copy8x14

	lea		a8x14Buffer+1*2*14*8,a0
	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	jsr		copy8x14b



	move.w	#0,$466.w
	move.w	#$2700,sr
	move.l	#spectrum_boot_vbl,$70
	move.w	#$2300,sr
.xxx
	tst.w	$466.w
	beq		.xxx
	move.w	#0,$466.w
	subq.w	#1,.twaiter
	bge		.xxx

	move.w	#-1,$ffff8240+1*2

			waitFrames 150

	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	move.w	#0,d0
.y set 0
	REPT 10
.x set .y
		REPT 14
			move.w	d0,.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR

;	lea		smfx2y+128+17*160,a0
;	move.l	screenpointer2,a1
;	add.w	#32000-10*160+2,a1
;	jsr		copy8x14


	lea		a8x14Buffer+2*2*14*8,a0
	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	jsr		copy8x14b

			waitFrames	40

;	lea		smfx2y+128+25*160,a0
;	move.l	screenpointer2,a1
;	add.w	#32000-10*160+2,a1
;	jsr		copy8x14

	lea		a8x14Buffer+3*2*14*8,a0
	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	jsr		copy8x14b


			waitFrames 20

;	lea		smfx2y+128+33*160,a0
;	move.l	screenpointer2,a1
;	add.w	#32000-10*160+2,a1
;	jsr		copy8x14

	lea		a8x14Buffer+4*2*14*8,a0
	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	jsr		copy8x14b


			waitFrames 20

	move.l	screenpointer2,a1
	add.w	#32000-10*160+2,a1
	move.w	#0,d0
.y set 0
	REPT 8
.x set .y
		REPT 14
			move.w	d0,.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR

			waitFrames 20
	rts


.twaiter	dc.w	150


			
	IFEQ	GENERATE_SPECFONT
; copy 8x14 = 8 height, 14*2 = 
prepCopy8x14
	lea		a8x14Buffer,a1
	lea		smfx2y+128+65*160,a0
	jsr		cp814
	lea		smfx2y+128+8*160,a0
	jsr		cp814
	lea		smfx2y+128+17*160,a0
	jsr		cp814
	lea		smfx2y+128+25*160,a0
	jsr		cp814
	lea		smfx2y+128+33*160,a0
	jsr		cp814
	lea		smfx2y+128,a0
	jsr		cp814




	lea		a8x14Buffer,a0
	move.b	#0,$ffffc123


	rts

cp814
.y set 0
	REPT 8
.x set .y
		REPT 14
			move.w	.x(a0),(a1)+
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	rts
	

copy8x14
.y set 0
	REPT 8
.x set .y
		REPT 14
			move.w	.x(a0),.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	rts
	ENDC

copy8x14b
.y set 0
	REPT 8
.x set .y
		REPT 14
			move.w	(a0)+,.x(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	rts



spectrum_boot_vbl
	addq.w	#1,$466.w
	rte



init_transision
	
	move.w	#$2700,sr
	move.l	#transision_vbl,$70.w
	move.w	#$2300,sr

.ttt
	tst.w	endTransition
	beq		.ttt


	rts
endTransition	dc.w	0

offset		dc.w	0
oldoffset	dc.w	0

fallDown			;189 lines
	move.l	screenpointer2,a0
	move.l	screenpointer,a1
	add.w	#128,a1
;	lea		pssst+128,a1
	move.w	offset,d0					; get current offset
	muls	#160,d0						; to scanline
	add.l	d0,a0						; offset to screen

	move.w	oldoffset,d7
	move.w	d7,d0
	muls	#160,d0
	sub.l	d0,a0
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
.lll
		movem.l	d0-d6/a2-a6,0(a0)
		movem.l	d0-d6/a2-a6,48(a0)
		movem.l	d0-d6/a2-a6,96(a0)	;144
		movem.l	d0-d3,144(a0)
		add.w	#160,a0
	dbra	d7,.lll

	move.w	#194,d7
	sub.w	offset,d7
	blt		.exit
	; we can skip first and last 32 pixel

		lea		16(a1),a1				;16 pixels 8 bytes, thus 64 pixels is 32 bytes 160-32 = 128
.doLine
		movem.l	(a1)+,d0-d6/a2-a6		;48
		movem.l	d0-d6/a2-a6,16(a0)				;48
		movem.l	(a1)+,d0-d6/a2-a6		;48
		movem.l	d0-d6/a2-a6,64(a0)				;96
		movem.l	(a1)+,d0-d6/a2				;48
		movem.l	d0-d6/a2,112(a0)
		lea		32(a1),a1
		lea		160(a0),a0
	dbra	d7,.doLine

	move.w	offset,oldoffset
	add.w	#1,offset
	rts
.exit
	move.l	screenpointer,a0
	moveq	#0,d0
	move.w	#200-1,d7
.dl
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.dl
	move.w	#$4e75,fallDown
	move.w	#1,goBackCol
	rts
goBackCol	dc.w	0

transision_vbl
	addq.w	#1,$466.w
	add.w	#1,frameCount
	jsr		checkForColorList

	tst.w	go
	blt		.ok
		tst.w	goBackCol
		bne		.doBack
		lea		colorList,a0
		lea		wave,a1
		add.w	waveOff,a1
		move.w	(a1),d0
		add.w	d0,d0
		move.w	(a0,d0.w),$ffff8240
		move.w	(a0,d0.w),$ffff8240+8*2

		cmp.w	#10*2,colOff
		bne		.tt
			move.w	#$4e75,checkForColorList
			move.w	(a0,d0.w),d0
			lea		$ffff8240,a1
			REPT 16
				move.w	d0,(a1)+
			ENDR	
.tt
		
		add.w	#2,waveOff
		cmp.w	#256,waveOff
		blt		.ok
			sub.w	#256,waveOff
			jmp	.ok
.doBack
		lea		colorListBack,a0
		lea		wave,a1
		add.w	waveOff,a1
		move.w	(a1),d0
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		lea		$ffff8240,a1
		REPT 16
			move.w	d0,(a1)+
		ENDR	

		cmp.w	#$234,d0
		bne		.endd
			move.w	#-1,endTransition
			rte
.endd
		add.w	#2,waveOff
		cmp.w	#256,waveOff
		blt		.ok
			sub.w	#256,waveOff
.ok

	jsr		fallDown



	rte
go			dc.w	-2
frameCount	dc.w	 0

checkForColorList
	moveq	#0,d0
	move.b	music+$b8,d0
	cmp.b	#$20,d0
	bne		.ok
		move.b	#0,music+$b8
		add.w	#1,go
;		lea		colorList2,a0
;		lea		colorList4,a1
;		lea		colorList5,a2
;		lea		colorList6,a3
;		lea		colorList7,a4
;		move.w	colOff,d0
;		move.w	(a0,d0.w),$ffff8240+2*2
;		move.w	(a1,d0.w),$ffff8240+4*2
;		move.w	(a2,d0.w),$ffff8240+5*2
;		move.w	(a3,d0.w),$ffff8240+6*2
;		move.w	(a4,d0.w),$ffff8240+7*2


		add.w	#2,colOff
.ok
	rts
colOff	dc.w	0	
waveOff	dc.w	0
wave	
	include	data/wave.s
	include	data/wave.s


colorListBack
	dc.w	$234	;0
	dc.w	$234	;1
	dc.w	$234	;2
	dc.w	$234	;3
	dc.w	$234	;4
	dc.w	$345	;5
	dc.w	$456	;6
	dc.w	$567	;7
	dc.w	$677	;8
	dc.w	$777	;9
	dc.w	$777	;10
	dc.w	$777	;10


colorList
	dc.w	$000	;0
	dc.w	$001	;1
	dc.w	$012	;2
	dc.w	$123	;3
	dc.w	$234	;4
	dc.w	$345	;5
	dc.w	$456	;6
	dc.w	$567	;7
	dc.w	$677	;8
	dc.w	$777	;9
	dc.w	$777	;10
	dc.w	$777	;10


init_demos
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	moveq	#0,d0
	add.w	#180*160,a0
	add.w	#180*160,a1
	move.w	#20-1,d7
.cl
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cl

	waitFrames 135
	jsr		music2
	move.w  #$2700,sr
	move.l	#music2+8,sndadd+2
	move.l	musicMetaPointer,a0
	move.b	#7,(a0)
	move.b	#8,38(a0)
	move.l	#$090a0b00,4(a0)	



	move.w	#$345,$ffff8240+13*2
	move.w	#$556,$ffff8240+14*2
	move.w	#$777,$ffff8240+15*2



;		bset	#4,$fffffa09.w			; timer-d
;		bset	#4,$fffffa15.w			;
;		or.b	#%101,$fffffa1d.w		; %111 = divide by 200
;		move.b	#128,$fffffa25.w			; 2457600/200/41 approx 300 Hz
;		move.l	#td,$110.w			; own timer-d

;	jsr		music
    move.l  #.wvbl,$70
    move.w  #$2300,sr


    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466

    move.w	#$2700,sr
    move.l	#demos_vbl,$70
    move.w	#$2300,sr

.xxx
		jsr		crankIt
	    tst.w	textFadeOff
		bne		.xxx
    
	waitFrames	1

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	moveq	#0,d0
	move.w	#200-1,d7
.cl2
		REPT 20
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
	dbra	d7,.cl2
	rts  
.vblwaiter	dc.w	20

.wvbl
    addq.w  #1,$466.w
    rte


init_music
    clr.b   $fffffa07.w         ;MFP interrupt Enable A (Timer-A & B)
    clr.b   $fffffa13.w         ;MFP interrupt Mask A (Timer-A & B)
    bclr    #3,$fffffa17.w          ;MFP automatic end of interrupt
	move.l  #sndh_play,$114.w          ;Install Timer C
	bset	#5,$fffffa09.w         ;Interrupt enable B (Timer-C & D)
	bset	#5,$fffffa15.w         ;Interrupt mask B (Timer-C & D)
	rts


init_spectrum_load
	move.w	#$2700,sr
	jsr		init_music

	lea		pssst,a0
	move.l	screenpointer,a1
	jsr		cranker

	move.l	#timer_hbl,$68.w


    move.w	#$2300,sr
    jsr		music


	move.w	#-1,$ffff8240+1*2
	move.w	#0,$ffff8240+3*2

	lea		a8x14Buffer+5*2*14*8,a0
	move.l	screenpointer2,a1
	add.w	#640+2,a1
	jsr		copy8x14b

;	lea		smfx2y+128,a0
;	move.l	screenpointer2,a1
;	add.w	#640+2,a1
;.y set 0
;	REPT 8
;.x set .y
;		REPT 8
;			move.w	.x(a0),.x(a1)
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR


    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466

;    movem.l	pssst+4,d0-d7
	move.l	screenpointer,a0
	movem.l	4(a0),d0-d7
    movem.l	d0-d7,$ffff8240

    move.w	#$2700,sr
    move.l	#spectrum_vbl,$70
    move.w	#$2300,sr
    move.w	#$2100,sr
.tt

    tst.w	load_done
    beq		.tt
    	move.w	#0,$ffff8240

		    waitFrames	50

	rts  
load_done	dc.w	0

; this should be a `walking' timer
; lets use timer a
spectrum_vbl
	addq.w	#1,$466.w
	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
   	jsr		doMusicSwitch
   	jsr		doMusicPicture


	rte
doMusicPicture
	moveq	#0,d0
	move.b	music+$b8,d0
	cmp.b	#$11,d0
	bne		.end
		move.b	#0,music+$b8
		; now copy a line
		jsr		copyLinePssst
.end
	rts

copyLinePssst
;	lea		pssst+128,a0
	move.l	screenpointer,a0
	add.w	#128,a0
	move.l	screenpointer2,a1
	add.w	.offset,a0
	add.w	.offset,a1

	subq.w	#1,.hack
	bge		.nh
		subq.w	#1,.timerbtimes
		bge		.nh
			move.w	#$2300,sr
			move.l	#dummy,$68.w
			move.w	#0,$ffff8240
			move.w	#-1,load_done
.nh

	subq.w	#1,.times
	bgt		.ok
		move.w	#14,.times
		add.w	#14*2*160,.offset
.ok	
	jsr		copy20Block

	tst.w	.hack
	bge		.nh1
		jsr		copy20Block
		jsr		copy20Block
		sub.w	#2*160,a0
		sub.w	#2*160,a1
.nh1

	add.w	#13*160,a0
	add.w	#13*160,a1

	jsr		copy20Block

	tst.w	.hack
	bge		.nh2
		jsr		copy20Block
		jsr		copy20Block
		sub.w	#2*160,a0
		sub.w	#2*160,a1
.nh2

	add.w	#13*160,a0
	add.w	#13*160,a1

	jsr		copy20Block

	add.w	#160,.offset
	rts

.offset	dc.w	0
.times	dc.w	14
.hack	dc.w	66
.timerbtimes	dc.w	1

copy20Block
	REPT 20
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	rts


doMusicSwitch
   	moveq	#0,d0
   	move.b	music+$b8,d0
   	beq		.end
   		cmp.b	#$11,d0
   		beq		.end
   		move.b	#0,music+$b8
   		add.w	d0,d0
   		lea		valList,a0
   		move.w	(a0,d0),flipSource
.end
	rts

valList
	dc.w	0
	dc.w	70		;1
	dc.w	67		;2	x
	dc.w	50		;3
	dc.w	40		;4
	dc.w	30		;5
	dc.w	20		;6
	dc.w	10		;7	x


timer_hbl
	subq.w	#1,.flipTimer
	bge		.ok
	move.w	flipSource,.flipTimer
	tst.w	.flip
	bgt		.red
.blue
		move.w	#$066,$ffff8240
		neg.w	.flip
	rte
.red
		move.w	#$600,$ffff8240
		neg.w	.flip
.ok
	rte
.flip	dc.w	1
.flipTimer	dc.w	40
flipSource	dc.w	40


demos_vbl
    move.w  #$0234,$ffff8240
    addq.w	#1,$466.w
			pushall
 
	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	move.l	c2pPalPtr,a0
	add.w	c2pPalOff,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240
	jsr		doTextFade

;	move.l	screenpointer2,$ffff8200
			swapscreens
		    move.w	#$234,$ffff8240
;		    jsr		writeText
			jsr		herpText
;		    jsr		writeTextAt
			jsr		herpc2p

            popall
    rte


sndh_play:  
        pushall
        lea     sndhwait(pc),a0
        move.w  sndh_freq,d0
        sub.w   d0,(a0)
        bpl.s   noplay
	        add.w   #200,(a0)
sndadd
	        jsr     music+8
noplay:    
        popall
        rte
sndhwait:  dc.w    200
sndh_freq:  dc.w    56              ;1-200 Hz

;------------------------------------------- END UTILITY STUFF -----------------------------------------------
;------------------------------------------- END UTILITY STUFF -----------------------------------------------
;------------------------------------------- END UTILITY STUFF -----------------------------------------------



	IFEQ	GENERATE_FONT
prepBuffer
	lea		font+128,a6										; load font
	lea		sourceFont,a1									; load target
	move.w	#_nr_font_rows-1,d7								; this is how many rows = 3
.oloop
	move.l	a6,a0											; set thing
	move.w	#_nr_font_columns-1,d6							; this is how many columns = 20
.iloop
.x set 0
		REPT _font_height
			move.l	.x(a0),(a1)+
.x set .x+160
		ENDR

		lea		8(a0),a0
		dbra	d6,.iloop
	lea		160*(_font_height+1)(a6),a6						; 
	dbra	d7,.oloop


	lea		sourceFont,a0
	sub.l	a0,a1
;	move.b	#0,$ffffc123
	rts
	ENDC


copyFirst
	lea		sourceFont,a0
	move.l	fontBufferPointer,a1
	lea		1024(a1),a1						; skip space = 8 height, 4 bitplanes, 2 width, 16 spaces = 1024

	move.w	#60-1,d7
.oloop
.x2 set 0
			REPT _font_height
				move.l	(a0)+,.x2(a1)
.x2 set .x2+8
			ENDR
			lea		1024(a1),a1
	dbra	d7,.oloop
	; now that everything is in place, lets shift!
	; testprint
;	move.w	#10-1,d7
;	move.l	fontBufferPointer,a0
;	move.l	a0,a3
;	move.l	screenpointer,a1
;	move.l	screenpointer2,a2
;.lll
;.y set 0
;	REPT 8
;.x set .y
;		move.l	(a3),.x(a1)
;		move.l	(a3)+,.x(a2)
;		move.l	(a3),.x+8(a1)
;		move.l	(a3)+,.x+8(a2)
;.y set .y+160
;	ENDR
;	lea		1024(a0),a0
;	move.l	a0,a3
;	add.w	#16,a1
;	add.w	#16,a2
;	dbra	d7,.lll

	move.l	fontBufferPointer,a0
	lea		64(a0),a1		; target
	move.w	#60-1,d7
.shiftChar
		move.w	#15-1,d6
.doShiftRight
		REPT _font_height
			move.w	(a0)+,d0		; pl1	x0
			move.w	(a0)+,d1		; pl2	x0
			move.w	(a0)+,d2		; pl1	x1
			move.w	(a0)+,d3		; pl2	x1
			roxr.w	d0
			roxr.w	d2
			roxr.w	d1
			roxr.w	d3
			move.w	d0,(a1)+
			move.w	d1,(a1)+
			move.w	d2,(a1)+
			move.w	d3,(a1)+
		ENDR
		dbra	d6,.doShiftRight
		add.w	#64,a0		
		add.w	#64,a1
	dbra	d7,.shiftChar
	move.l	fontBufferPointer,a0
	sub.l	a0,a1
;	move.b	#0,$ffffc123						
	rts

; ---------------------------------- END PRECALC / GENERATION --------------------------------
; ---------------------------------- END PRECALC / GENERATION --------------------------------
; ---------------------------------- END PRECALC / GENERATION --------------------------------
; ---------------------------------- END PRECALC / GENERATION --------------------------------

textBuffer	
			dc.b	"THIS IS THE EXAMPLE TEST",-1
			dc.b	"TEXDTWRITER, IT NEEDS TO",-1
			dc.b	"TESTED AND SOME WORK IS ",-1
			dc.b	"NEEDED TO USE IT IN THE ",-1
			dc.b	"DEMO....................",-1
			dc.b	"DEMO....................",-1


	even
textXPos	dc.w	0

positionTableOffset
.offsetScreen	set 0
	REPT 20
.offsetFont		set 0
		REPT 16
			dc.w	.offsetScreen,.offsetFont
.offsetFont		set .offsetFont+64
		ENDR
.offsetScreen set .offsetScreen+8
	ENDR

textBufferOff		dc.w	0
screenpointerOff	dc.w	0

;tmpoff	dc.l	0
;tmpoffcnt	dc.w	50
;writeTextTest
;	move.l	screenpointer,a0
;	move.l	screenpointer2,a1
;	move.l	fontBufferPointer,a2
;	add.l	tmpoff,a2
;
;	REPT 16
;.y set 0
;		REPT 8
;.x set .y
;			move.l	(a2),.x(a0)
;			move.l	(a2)+,.x(a1)
;			move.l	(a2),.x+8(a0)
;			move.l	(a2)+,.x+8(a1)
;.y set .y+160
;		ENDR
;		add.w	#9*160,a0
;		add.w	#9*160,a1
;	ENDR
;
;	subq.w	#1,tmpoffcnt
;	bge		.ok
;		move.w	#50,tmpoffcnt
;		add.l	#1024,tmpoff
;.ok
;
;	rts
wordBufferOff	dc.w	0


wordBuffer
	dc.l	word1,131*160
	dc.l	word2,131*160+80
;	dc.l	word3,21*160
	dc.l	word4,142*160
	dc.l	word5,142*160+80
;	dc.l	word6,31*160+80
;	dc.l	word7,41*160
	dc.l	word8,153*160
	dc.l	word9,153*160+80
	dc.l	word10,164*160
;	dc.l	word11,61*160
	dc.l	word12,164*160+80
	dc.l	word13,175*160
	dc.l	word14,175*160+80
	dc.l	terminator,186*160

		; format:	offset,nr_chars,b
word1	dc.b 	6,"CYCLES",-1
	even
word2	dc.b	8,"YANARTAS",-1
	even
word4	dc.b	5,"PULSE",-1
	even
word5	dc.b	10,"MOSQUIDOTS",-1
	even
word8	dc.b	9,"EXECUTION",-1
	even
word9	dc.b	5,"JUXTA",-1
	even
word10	dc.b	13,"JUXTAPOSITION",-1
	even
word12	dc.b	8,"RECYCLES",-1
	even
word13	dc.b	10,"PLOT TWIST",-1
	even
word14	dc.b	12,"SMAG-FX NO.1",-1
	even


terminator	dc.b	1," ",-1
	even

writeTextAt
	nop
	lea		wordBuffer,a6
	add.w	wordBufferOff,a6
	move.l	(a6)+,a0
	move.l	screenpointer,a4
	move.l	screenpointer2,a5
	add.l	(a6),a4
	move.l	a4,noregs
	add.l	(a6)+,a5					; offset
	lea		fontSpace,a2
	lea		positionTableOffset,a3
	moveq	#0,d7
	move.b	(a0)+,d7
	move.l	fontBufferPointer,a1
	move.l	a1,usp
	move.w	textXPos,d1

	cmp.w	#4*2*13,wordBufferOff
	bgt		.ttt
		add.w	#4*2,wordBufferOff
		jmp		dochar
.ttt
	rts



herpText
	moveq	#0,d0
	move.b	music2+$b8,d0
	cmp.b	#$10,d0
	bne		.nnn
		move.b	#0,music2+$b8
		jsr		writeTextAt

.nnn
	
	rts

endDemo	dc.w	0

noregs	dc.l	0
wordInProgress	dc.w	0

writeText
	nop
	lea		textBuffer,a0
	add.w	textBufferOff,a0
	move.l	screenpointer,a4
	move.l	screenpointer2,a5
	add.w	#26*160,a5
	add.w	#26*160,a4
	add.w	screenpointerOff,a5
	add.w	screenpointerOff,a4
	move.l	a4,noregs
	move.w	textXPos,d1
	lea		fontSpace,a2
	lea		positionTableOffset,a3
	move.w	#1-1,d7
	move.l	fontBufferPointer,a1
	move.l	a1,usp


	add.w	#1,textBufferOff
;	cmp.w	#120,textBufferOff
;	ble		.okkkk
;		rts
;.okkkk

dochar
		moveq	#0,d0
		move.b	(a0)+,d0
		bge		.okkk
.ttt
			add.w	#10*160,screenpointerOff
			move.w	#0,textXPos
			move.w	#0,textBufferOff
			rts
;			jmp		.charDone
.okkk	
		move.w	textXPos,d1
		sub.b	#32,d0
		add.w	d0,d0
		move.w	(a2,d0.w),d3
		add.l	d0,d0
		asl.l	#8,d0


		move.l	usp,a1
		add.l	d0,a1			; select char

		move.w	d1,d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	a5,a6
		move.l	noregs,a4
		add.w	(a3,d2.w),a6
		add.w	(a3,d2.w),a4
		add.w	2(a3,d2.w),a1
		add.w	d3,d1
		move.w	d1,textXPos

		; prints char
.x set 0
		REPT 2
			movem.l	(a1)+,d0/d2/d3/d4/d5/d6
			or.l	d0,.x(a6)
			or.l	d0,.x(a4)
			move.l	d0,d1
			swap	d0
			or.l	d0,d1
			or.l	d1,.x+4(a6)
			or.l	d1,.x+4(a4)


			or.l	d2,.x+8(a6)
			or.l	d2,.x+8(a4)
			move.l	d2,d1
			swap	d2
			or.l	d2,d1
			or.l	d1,.x+12(a6)
			or.l	d1,.x+12(a4)


			or.l	d3,.x+160(a6)
			or.l	d3,.x+160(a4)
			move.l	d3,d1
			swap	d3
			or.l	d3,d1
			or.l	d1,.x+164(a6)
			or.l	d1,.x+164(a4)


			or.l	d4,.x+168(a6)
			or.l	d4,.x+168(a4)
			move.l	d4,d1
			swap	d4
			or.l	d4,d1
			or.l	d1,.x+172(a6)
			or.l	d1,.x+172(a4)

			or.l	d5,.x+320(a6)
			or.l	d5,.x+320(a4)
			move.l	d5,d1
			swap	d5
			or.l	d5,d1
			or.l	d1,.x+324(a6)
			or.l	d1,.x+324(a4)

			or.l	d6,.x+328(a6)
			or.l	d6,.x+328(a4)
			move.l	d6,d1
			swap	d6
			or.l	d6,d1
			or.l	d1,.x+332(a6)
			or.l	d1,.x+332(a4)
.x set .x+480
		ENDR

		movem.l	(a1)+,d0/d2/d3/d4
		or.l	d0,.x(a6)
		or.l	d0,.x(a4)
		move.l	d0,d1
		swap	d0
		or.l	d0,d1
		or.l	d1,.x+4(a6)
		or.l	d1,.x+4(a4)

		or.l	d2,.x+8(a6)
		or.l	d2,.x+8(a4)
		move.l	d2,d1
		swap	d2
		or.l	d2,d1
		or.l	d1,.x+12(a6)
		or.l	d1,.x+12(a4)

		or.l	d3,.x+160(a6)
		or.l	d3,.x+160(a4)
		move.l	d3,d1
		swap	d3
		or.l	d3,d1
		or.l	d1,.x+164(a6)
		or.l	d1,.x+164(a4)


		or.l	d4,.x+168(a6)
		or.l	d4,.x+168(a4)
		move.l	d4,d1
		swap	d4
		or.l	d4,d1
		or.l	d1,.x+172(a6)
		or.l	d1,.x+172(a4)
.charDone
	dbra	d7,dochar
	rts

;--------------------------- END TEXT WRITER -----------------------------
;--------------------------- END TEXT WRITER -----------------------------
;--------------------------- END TEXT WRITER -----------------------------
;--------------------------- END TEXT WRITER -----------------------------

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


pal1
	dc.w	$234,$621,$331,$221,$541,$351,$751,$022,$034,$461,$054,$613,$212,$345,$556,$777	;0
	dc.w	$234,$621,$331,$221,$541,$351,$751,$122,$134,$461,$154,$613,$212,$345,$556,$777	;1
	dc.w	$234,$622,$332,$222,$542,$352,$752,$222,$234,$462,$254,$623,$222,$345,$556,$777	;2	
	dc.w	$234,$633,$333,$333,$543,$353,$753,$333,$334,$463,$354,$633,$333,$345,$556,$777	;3
	dc.w	$234,$644,$444,$444,$544,$454,$754,$444,$444,$464,$454,$644,$444,$345,$556,$777	;4
	dc.w	$234,$655,$555,$555,$555,$555,$755,$555,$555,$565,$555,$655,$555,$345,$556,$777	;5
	dc.w	$234,$666,$666,$666,$666,$666,$766,$666,$666,$666,$666,$666,$666,$345,$556,$777	;6

	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$345,$556,$777	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$345,$556,$777	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$345,$556,$777	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$345,$556,$777	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$345,$556,$777	;11

pal2
	dc.w	$234,$011,$023,$123,$134,$146,$157,$257,$167,$267,$177,$277,$111,$345,$556,$777	;0f
	dc.w	$234,$111,$123,$133,$134,$146,$157,$257,$167,$267,$177,$277,$111,$345,$556,$777	;1
	dc.w	$234,$222,$223,$233,$234,$246,$257,$257,$267,$267,$277,$277,$222,$345,$556,$777	;2
	dc.w	$234,$333,$333,$333,$334,$346,$357,$357,$367,$367,$377,$377,$333,$345,$556,$777	;3
	dc.w	$234,$444,$444,$444,$444,$446,$457,$457,$467,$467,$477,$477,$444,$345,$556,$777	;4
	dc.w	$234,$555,$555,$555,$555,$556,$557,$557,$567,$567,$577,$577,$555,$345,$556,$777	;5
	dc.w	$234,$666,$666,$666,$666,$666,$667,$667,$667,$667,$677,$677,$666,$345,$556,$777	;6

	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$345,$556,$777	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$345,$556,$777	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$345,$556,$777	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$345,$556,$777	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$345,$556,$777	;11

pal3
	dc.w	$234,$334,$223,$445,$456,$556,$567,$667,$677,$001,$101,$112,$212,$324,$434,$234 ;0
	dc.w	$234,$334,$223,$445,$456,$556,$567,$667,$677,$111,$111,$112,$212,$324,$434,$234	;1
	dc.w	$234,$334,$223,$445,$456,$556,$567,$667,$677,$222,$222,$222,$222,$324,$434,$234	;2
	dc.w	$234,$334,$333,$445,$456,$556,$567,$667,$677,$333,$333,$333,$333,$334,$434,$334	;3
	dc.w	$234,$444,$444,$445,$456,$556,$567,$667,$677,$444,$444,$444,$444,$444,$444,$444	;4
	dc.w	$234,$555,$555,$555,$556,$556,$567,$667,$677,$555,$555,$555,$555,$555,$555,$555	;5
	dc.w	$234,$666,$666,$666,$666,$666,$667,$667,$677,$666,$666,$666,$666,$666,$666,$666	;6

	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234	;11

;pal4
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000
;	dc.w	$234,$110,$200,$310,$320,$400,$520,$510,$530,$710,$720,$730,$220,$640,$600,$000

pal5
	dc.w	$234,$011,$022,$122,$133,$222,$233,$333,$244,$344,$444,$455,$566,$666,$777,$000	;0
	dc.w	$234,$111,$122,$122,$133,$222,$233,$333,$244,$344,$444,$455,$566,$666,$777,$111	;1
	dc.w	$234,$222,$222,$222,$233,$222,$233,$333,$244,$344,$444,$455,$566,$666,$777,$222	;2
	dc.w	$234,$333,$333,$333,$333,$333,$333,$333,$344,$344,$444,$455,$566,$666,$777,$333	;3
	dc.w	$234,$444,$444,$444,$444,$444,$444,$444,$444,$344,$444,$455,$566,$666,$777,$444	;4
	dc.w	$234,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$566,$666,$777,$555	;5
	dc.w	$234,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$777,$666	;6

	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234	;11


pal6
	dc.w	$234,$731,$741,$721,$711,$632,$403,$304,$205,$503,$602,$512,$702,$612,$523,$622	;0
	dc.w	$234,$731,$741,$721,$711,$632,$413,$314,$215,$513,$612,$512,$712,$612,$523,$622	;1
	dc.w	$234,$732,$742,$722,$722,$632,$423,$324,$225,$523,$622,$522,$722,$622,$523,$622	;2
	dc.w	$234,$733,$743,$733,$733,$633,$433,$334,$335,$533,$633,$533,$733,$633,$533,$633	;3
	dc.w	$234,$744,$744,$744,$744,$644,$444,$444,$445,$544,$644,$544,$744,$644,$544,$644	;4
	dc.w	$234,$755,$755,$755,$755,$655,$555,$555,$555,$555,$655,$555,$755,$655,$555,$655	;5
	dc.w	$234,$766,$766,$766,$766,$666,$666,$666,$666,$666,$666,$666,$766,$666,$666,$666	;6

	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234	;11

textFade
	dc.w	$234,$234,$234	;0
	dc.w	$234,$234,$334	;1
	dc.w	$234,$234,$444	;2
	dc.w	$234,$334,$555	;3
	dc.w	$345,$445,$666	;4
	dc.w	$345,$556,$777	;5

textFadeOff
	dc.w	5*2*3

doTextFade
	lea		textFade,a0
	add.w	textFadeOff,a0
	movem.w	(a0),d0-d2
	movem.w	d0-d2,$ffff8240+13*2

	subq.w	#1,.textFadeWaiter
	bgt		.end
	move.w	#3,.textFadeWaiter
;		move.b	#0,$ffffc123
		sub.w	#2*3,textFadeOff
		ble		.stops
.end
	rts
.stops
	move.w	#0,textFadeOff
	rts
.textFadeWaiter	dc.w	1970


tab2px_1p					ds.l	1
tab2px_2p					ds.l	1

chunkyMul
	lea		c2pdata6,a0
	move.w	#100-1,d6
.frame
		move.l	#(64+4)*40-1,d7
.loop
			move.b (a0),d0
			add.b	d0,d0
			add.b	d0,d0
			move.b	d0,(a0)+
		dbra	d7,.loop
	dbra	d6,.frame
	lea		c2pdata6,a1
	sub.l	a1,a0
	move.b	#0,$ffffc123



	lea		c2pdata5,a0
	move.w	#54-1,d6
.frame2
		move.l	#(64+4)*40-1,d7
.loop2
			move.b (a0),d0
			add.b	d0,d0
			add.b	d0,d0
			move.b	d0,(a0)+
		dbra	d7,.loop2
	dbra	d6,.frame2

	lea		c2pdata5,a1
	sub.l	a1,a0
	move.b	#0,$ffffc123

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

calcTab
	moveq	#16-1,d7
	moveq	#0,d1
.outer
	moveq	#16-1,d6
	moveq	#0,d0
	move.l	a0,d3
.inner
			move.l	(a1,d1.w),d2
			or.l	(a2,d0.w),d2
			move.l	d2,(a0)+
			addq.w	#4,d0
		dbra	d6,.inner

		add.l	#%0000010000000000,d3
		move.l	d3,a0
		addq.w	#4,d1
	dbra	d7,.outer
	rts

c2pPalPtr	dc.l	pal2
c2pPalOff	dc.w	11*32
c2pPtr		dc.l	c2pdata6
c2pInc		dc.l	(64+4)*40
c2pMax		dc.l	(64+4)*40*100
c2pFrames	dc.l	370

c2pend
	rts
c2p_2to4_classic
	tst.w	doCranker
	bne		c2pend
	subq.w	#1,framewaiter
	bgt		.kkk
		move.w	#framewaiterConst,framewaiter
		move.l	c2pInc,d0
		move.l	c2pMax,d1
		add.l	d0,chunkyOff
		cmp.l	chunkyOff,d1
		bne		.kkk
			move.l	#0,chunkyOff
.kkk

	subq.l	#1,c2pFrames
	bgt		.kkk2
			move.l	#0,chunkyOff
			jsr		changeC2PEffect
			rts
.kkk2

	;-------- do fade
	cmp.l	#24,c2pFrames
	ble		.adder
	
	subq.w	#1,.palwaiter
	bgt		.cont1
		move.w	#2,.palwaiter

	sub.w	#32,c2pPalOff
	bge		.kkkz
		move.w	#0,c2pPalOff
.kkkz
	jmp		.cont1
.adder
	add.w	#32,c2pPalOff
	cmp.w	#11*32,c2pPalOff
	ble		.cont1
		move.w	#11*32,c2pPalOff
	;------ end fade
.cont1

	move.l	c2pSourcePtr,a0
	add.l	chunkyOff,a0


	move.l	screenpointer,a6
	add.w	c2pScreenOffset,a6
	add.w	c2pscreenOff,a6
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3

.x set 0
	REPT 80
		movem.l	d0-d3,.x-8(a6)
.x set .x+160
	ENDR


	sub.w	.off,a0
	lea		TAB1,a1
	lea		TAB2,a2
	lea		TAB3,a3
	lea		TAB4,a4

	tst.w	block
	blt		.8block

.0block


off	SET 0
	REPT 40
		REPT 8
			move.b	(a0)+,d0
			move.l	(a1,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a2,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a3,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a4,d0.w),d5
			movep.l	d5,off(a6)

			move.b	(a0)+,d0
			move.l	(a1,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a2,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a3,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a4,d0.w),d5
			movep.l	d5,off+1(a6)
off		SET off+8
		ENDR		

		move.b	(a0)+,d0
		move.l	(a1,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a2,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a3,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a4,d0.w),d5
		movep.l	d5,off(a6)

off		SET	off+96+160
	ENDR
	jmp		.cpy

.8block
off	SET 0
	REPT 40
		move.b	(a0)+,d0
		move.l	(a1,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a2,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a3,d0.w),d5
		move.b	(a0)+,d0
		or.l	(a4,d0.w),d5
		movep.l	d5,off+1(a6)

		REPT 8
off set off+8
			move.b	(a0)+,d0
			move.l	(a1,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a2,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a3,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a4,d0.w),d5
			movep.l	d5,off(a6)
	
			move.b	(a0)+,d0
			move.l	(a1,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a2,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a3,d0.w),d5
			move.b	(a0)+,d0
			or.l	(a4,d0.w),d5
			movep.l	d5,off+1(a6)
		ENDR		
off		SET	off+96+160
	ENDR

.cpy
	move.l	a6,a0

o	set 0
	REPT 40
		movem.l	o(a0),d0-d7/a1/a2						;8 = 4
		movem.l	d0-d7/a1/a2,o+160(a0)
		movem.l	o+40(a0),d0-d7/a1/a2		;12 = 6
		movem.l	d0-d7/a1/a2,o+160+40(a0)
o	set o+320
	ENDR


	subq.w	#1,.speedwaiter
	bge		.end
		move.w	#4,.speedwaiter

	add.w	#1,.off
	cmp.w	#4,.off			; then we need to, a) switch block or b) move screen
	bne		.endblock
		move.w	#0,.off
		tst.w	block		; if positive, then swap block
		bgt		.swapblock
.changeOFfset
		neg.w	block
		add.w	#8,c2pscreenOff
		jmp		.endblock
.swapblock
	neg.w	block

.endblock
.end
	rts
.palwaiter		dc.w	2
.off			dc.w	0
.speedwaiter	dc.w	4
c2pscreenOff		dc.w	16	


chunkyOff			dc.l	0
framewaiterConst	equ		2
framewaiter			dc.w	framewaiterConst
	
herpc2p
	moveq	#0,d0
	move.b	music2+$b8,d0
	cmp.b	#$20,d0
	bne		.skip
		move.b	#0,music2+$b8
		move.w	#1,c2pOn
.skip
	
	tst.w	c2pOn
	beq		.end
		jsr		c2p_2to4_classic
.end


	rts

c2pOn		dc.w	0
block		dc.w	1
uneven		dc.w	1













init_poetry
	lea		$ffff8240+13*2,a0
	lea		textFade+5*3*2,a1
	rept 3
	move.w	(a1)+,(a0)+
	endr

	move.w	#$2700,sr
	move.l	#poetry_vbl,$70
	move.w	#$2300,sr


.xxx
	tst.w	nopoetry
	beq		.xxx


	rts

poetry_vbl
	addq.w	#1,$466.w
	pushall

	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	swapscreens


	jsr		poetryTextAt

	popall

	rte


poetryBuffer
	dc.l	poetry1x,1*160	
	dc.w	0,0

;	my machine, your machine						2
	dc.l	poetry1,1*160	
	dc.w	0,0
	dc.l	poetry2,1*160	
	dc.w	0,0
	dc.l	poetry3,1*160	
	dc.w	0,0
	dc.l	poetry4,1*160	
	dc.w	0,0
	dc.l	poetry5,1*160	
	dc.w	0,0
;	our beloved machines			3		7
	dc.l	poetry6,12*160	
	dc.w	0,0
	dc.l	poetry7,12*160	
	dc.w	0,0
	dc.l	poetry8,12*160	
	dc.w	0,0
	dc.l	poetry9,12*160	
	dc.w	0,0
;	this time we spent together		5		12
	dc.l	poetry10,23*160	
	dc.w	0,0
	dc.l	poetry11,23*160	
	dc.w	0,0
	dc.l	poetry12,23*160	
	dc.w	0,0
	dc.l	poetry13,23*160	
	dc.w	0,0
;	these bonds we build			4		16
	dc.l	poetry14,34*160	
	dc.w	0,0
	dc.l	poetry15,34*160	
	dc.w	0,0
	dc.l	poetry16,34*160	
	dc.w	0,0
	dc.l	poetry17,34*160	
	dc.w	0,0
	dc.l	poetry18,34*160	
	dc.w	0,0
;	all the code we write			5		21
	dc.l	poetry19,45*160	
	dc.w	0,0
	dc.l	poetry20,45*160	
	dc.w	0,0
	dc.l	poetry21,45*160	
	dc.w	0,0
	dc.l	poetry21a,45*160	
	dc.w	0,0
	dc.l	poetry22,45*160	
	dc.w	0,0
	dc.l	poetry23,45*160	
	dc.w	0,0
;	all the pixels we plot			5		26
	dc.l	poetry24,56*160	
	dc.w	0,0
	dc.l	poetry25,56*160	
	dc.w	0,0
	dc.l	poetry26,56*160	
	dc.w	0,0
	dc.l	poetry27,56*160
	dc.w	0,0
	dc.l	poetry28,56*160
	dc.w	0,0
	dc.l	poetry29,56*160
	dc.w	0,0


;	and all the waves we square		6		32
	dc.l	poetry30,67*160
	dc.w	0,0
	dc.l	poetry31,67*160
	dc.w	0,0
	dc.l	poetry32,67*160
	dc.w	0,0
	dc.l	poetry33,67*160
	dc.w	0,0
	dc.l	poetry34,67*160
	dc.w	0,0
; the demos we forge				4		36
	dc.l	poetry35,78*160
	dc.w	0,0
	dc.l	poetry36,78*160
	dc.w	0,0
	dc.l	poetry37,78*160
	dc.w	0,0
	dc.l	poetry38,78*160
	dc.w	0,0
	dc.l	poetry39,78*160
	dc.w	0,0
;	for our machines				3		39
	dc.l	poetry40,89*160
	dc.w	0,0
	dc.l	poetry41,89*160
	dc.w	0,0
;	our beloved machines			3		42
	dc.l	poetry42,89*160
	dc.w	0,0
	dc.l	poetry43,89*160
	dc.w	0,0

;;;;;;;
	dc.l	poetry44,100*160
	dc.w	0,0
	dc.l	poetry45,100*160
	dc.w	0,0
	dc.l	poetry46,100*160
	dc.w	0,0
	dc.l	poetry47,100*160
	dc.w	0,0
	dc.l	poetry48,100*160
	dc.w	0,0

	dc.l	poetry49,111*160
	dc.w	0,0
	dc.l	poetry50,111*160
	dc.w	0,0
	dc.l	poetry51,111*160
	dc.w	0,0
	dc.l	poetry52,111*160
	dc.w	0,0

	dc.l	poetry53,122*160
	dc.w	0,0
	dc.l	poetry54,122*160
	dc.w	0,0
	dc.l	poetry55,122*160
	dc.w	0,0
	dc.l	poetry56,122*160
	dc.w	0,0
	dc.l	poetry57,122*160
	dc.w	0,0
	dc.l	poetry57a,122*160
	dc.w	0,0

	dc.l	poetry58,133*160
	dc.w	0,0
	dc.l	poetry59,133*160
	dc.w	0,0
	dc.l	poetry60,133*160
	dc.w	0,0
	dc.l	poetry61,133*160
	dc.w	0,0
	dc.l	poetry61a,133*160
	dc.w	0,0

	dc.l	poetry62,144*160
	dc.w	0,0
	dc.l	poetry63,144*160
	dc.w	0,0
	dc.l	poetry64,144*160
	dc.w	0,0
	dc.l	poetry65,144*160
	dc.w	0,0
	dc.l	poetry66,144*160
	dc.w	0,0
	dc.l	poetry67,144*160
	dc.w	0,0

	dc.l	poetry68,155*160
	dc.w	0,0
	dc.l	poetry69,155*160
	dc.w	0,0
	dc.l	poetry70,155*160
	dc.w	0,0

	dc.l	poetry71,166*160
	dc.w	0,0
	dc.l	poetry72,166*160
	dc.w	0,0
	dc.l	poetry73,166*160
	dc.w	0,0

	dc.l	poetry74,177*160
	dc.w	0,0
	dc.l	poetry75,177*160
	dc.w	0,0

	dc.l	poetry76,188*160
	dc.w	0,0
	dc.l	poetry77,188*160
	dc.w	0,0
	dc.l	poetry78,188*160
	dc.w	0,0
	dc.l	poetry79,188*160
	dc.w	0,0



	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0
	dc.l	terminator,111*160
	dc.w	0,0



poetry1x		
	dc.b	0,"",-1		;	my
	even
poetry1		
	dc.b	2,"MY",-1		;	my
	even
poetry2		
	dc.b	11,"MY MACHINE,",-1		;	my machine
	even
poetry3		
	dc.b	16,"MY MACHINE, YOUR",-1		;	you
	even
poetry4		
	dc.b	25,"MY MACHINE, YOUR MACHINE;",-1		;	your machine
	even
poetry5		
	dc.b	29,"MY MACHINE, YOUR MACHINE; OUR",-1		;	your machine
	even
poetry6		
	dc.b	7,"BELOVED",-1		;	our machine
	even
poetry7		
	dc.b	17,"BELOVED MACHINES.",-1
	even
poetry8		
	dc.b	22,"BELOVED MACHINES. THIS",-1
	even
poetry9		
	dc.b	27,"BELOVED MACHINES. THIS TIME",-1
	even
poetry10	
	dc.b	2,"WE",-1
	even
poetry11	
	dc.b	8,"WE SPEND",-1
	even
poetry12	
	dc.b	18,"WE SPEND TOGETHER.",-1
	even
poetry13	
	dc.b	24,"WE SPEND TOGETHER. THESE",-1
	even
poetry14	
	dc.b	5,"BONDS",-1
	even
poetry15	
	dc.b	8,"BONDS WE",-1
	even
poetry16	
	dc.b	15,"BONDS WE BUILD;",-1
	even
poetry17	
	dc.b	19,"BONDS WE BUILD; ALL",-1
	even
poetry18	
	dc.b	23,"BONDS WE BUILD; ALL THE",-1
	even
poetry19	
	dc.b	7,"OPCODES",-1
	even
poetry20	
	dc.b	10,"OPCODES WE",-1
	even
poetry21	
	dc.b	16,"OPCODES WE PUNCH",-1
	even
poetry21a
	dc.b	20,"OPCODES WE PUNCH IN,",-1
	even
poetry22	
	dc.b	24,"OPCODES WE PUNCH IN, ALL",-1
	even
poetry23
	dc.b	28,"OPCODES WE PUNCH IN, ALL THE",-1
	even
poetry24
	dc.b	6,"PIXELS",-1
	even
poetry25
	dc.b	9,"PIXELS WE",-1
	even
poetry26
	dc.b	14,"PIXELS WE PLOT",-1
	even
poetry27
	dc.b	18,"PIXELS WE PLOT AND",-1
	even
poetry28
	dc.b	22,"PIXELS WE PLOT AND ALL",-1
	even
poetry29
	dc.b	26,"PIXELS WE PLOT AND ALL THE",-1
	even
poetry30
	dc.b	5,"WAVES",-1
	even
poetry31
	dc.b	8,"WAVES WE",-1
	even
poetry32
	dc.b	16,"WAVES WE SQUARE.",-1
	even
poetry33
	dc.b	20,"WAVES WE SQUARE. THE",-1
	even
poetry34
	dc.b	26,"WAVES WE SQUARE. THE DEMOS",-1
;	dc.b	5,"DEMOS",-1
	even
poetry35
	dc.b	2,"WE",-1
	even
poetry36
	dc.b	8,"WE FORGE",-1
	even
poetry37
	dc.b	12,"WE FORGE FOR",-1
	even
poetry38
	dc.b	16,"WE FORGE FOR OUR",-1
	even
poetry39
	dc.b	26,"WE FORGE FOR OUR MACHINES,",-1
	even
poetry40
	dc.b	3,"OUR",-1
	even
poetry41
	dc.b	11,"OUR BELOVED",-1
	even
poetry42
	dc.b	15,"OUR BELOVED OLD",-1
	even
poetry43
	dc.b	27,"OUR BELOVED OLD MACHINES...",-1
	even

poetry44
	dc.b	2,"MY",-1
	even
poetry45
	dc.b	9,"MY SCENE,",-1
	even
poetry46
	dc.b	14,"MY SCENE, YOUR",-1
	even
poetry47
	dc.b	21,"MY SCENE, YOUR SCENE;",-1
	even
poetry48
	dc.b	25,"MY SCENE, YOUR SCENE; OUR",-1
	even
poetry49
	dc.b	9,"WONDERFUL",-1
	even
poetry50
	dc.b	15,"WONDERFUL ATARI",-1
	even
poetry51
	dc.b	22,"WONDERFUL ATARI SCENE.",-1
	even
poetry52
	dc.b	26,"WONDERFUL ATARI SCENE. THE",-1
	even
poetry53
	dc.b	7,"PARTIES",-1
	even
poetry54
	dc.b	10,"PARTIES WE",-1
	even
poetry55
	dc.b	17,"PARTIES WE ATTEND",-1
	even
poetry56
	dc.b	20,"PARTIES WE ATTEND TO",-1
	even
poetry57
	dc.b	24,"PARTIES WE ATTEND TO AND",-1
	even
poetry57a
	dc.b	27,"PARTIES WE ATTEND TO AND IN",-1
	even
poetry58
	dc.b	6,"COMPOS",-1
	even
poetry59
	dc.b	9,"COMPOS WE",-1
	even
poetry60
	dc.b	15,"COMPOS WE FACED",-1
	even
poetry61
	dc.b	20,"COMPOS WE FACED EACH",-1
	even
poetry61a
	dc.b	27,"COMPOS WE FACED EACH OTHER.",-1
	even


poetry62
	dc.b	3,"BUT",-1
	even
poetry63
	dc.b	10,"BUT ALWAYS",-1
	even
poetry64
	dc.b	12,"BUT ALWAYS A",-1
	even
poetry65
	dc.b	19,"BUT ALWAYS A SMILE,",-1
	even
poetry66
	dc.b	23,"BUT ALWAYS A SMILE, FOR",-1
	even
poetry67
	dc.b	26,"BUT ALWAYS A SMILE, FOR WE",-1
	even
poetry68
	dc.b	3,"ARE",-1
	even
poetry69
	dc.b	15,"ARE CELEBRATING",-1
	even
poetry70
	dc.b	19,"ARE CELEBRATING OUR",-1
	even
poetry71
	dc.b	8,"MACHINE.",-1
	even
poetry72
	dc.b	12,"MACHINE. OUR",-1
	even
poetry73
	dc.b	24,"MACHINE. OUR MAGNIFICENT",-1
	even
poetry74
	dc.b	5,"ATARI",-1
	even
poetry75
	dc.b	14,"ATARI MACHINE.",-1
	even
poetry76
	dc.b	2,"BE",-1
	even
poetry77
	dc.b	8,"BE COOL,",-1
	even
poetry78
	dc.b	13,"BE COOL, STAY",-1
	even
poetry79
	dc.b	23,"BE COOL, STAY OLDSCHOOL!",-1
	even

; an audience to show to,
; a scene to share with,
; with individuals 
; individuals to admire
; groups to compete with and hone skills for
; pushing the envelope and grinding the gears
; of our beloved machines


wordBufferOff2	dc.w	0

poetryTextAt
	tst.w	.fadeShit
	bne		.doFade
	moveq	#0,d0
	move.b	music2+$b8,d0
	cmp.b	#$50,d0
	bne		.ttt
	move.b	#0,music2+$b8
	nop
	lea		poetryBuffer,a6
	add.w	wordBufferOff2,a6
	move.l	(a6)+,a0
	move.l	screenpointer,a4
	move.l	screenpointer2,a5
	add.l	(a6),a4
	move.l	a4,noregs
	add.l	(a6)+,a5					; offset
	lea		fontSpace,a2
	lea		positionTableOffset,a3
	moveq	#0,d7
	move.b	(a0)+,d7
	move.l	fontBufferPointer,a1
	move.l	a1,usp
	move.w	(a6)+,d0
	add.w	d0,textXPos


	cmp.w	#4*3*41*2,wordBufferOff2
	bgt		.ttt2
		add.w	#4*3,wordBufferOff2
		jmp		dochar
.ttt
	rts
.ttt2	
	move.w	#1,.fadeShit
	rts
.fadeShit	dc.w	0
.doFade
	lea		textFade,a0
	add.w	.fadeOff,a0
	movem.w	(a0),d0-d2
	movem.w	d0-d2,$ffff8240+13*2

	subq.w	#1,.fader
	bge		.kkk
		move.w	#4,.fader
		sub.w	#3*2,.fadeOff
		bge		.kkk
			move.w	#0,.fadeOff
			move.l	screenpointer,a0
			move.l	screenpointer2,a1
			move.w	#200-1,d7
			moveq	#0,d0
.cl3
			REPT 20
				move.l	d0,(a0)+
				move.l	d0,(a0)+
				move.l	d0,(a1)+
				move.l	d0,(a1)+
			ENDR
			dbra	d7,.cl3
			move.w	#-1,nopoetry
.kkk

	rts
.fadeOff	dc.w	3*2*5
.fader		dc.w	5
nopoetry	dc.w	0
	section DATA

_spacer	equ 2
; width per char
fontSpace
	dc.w	_spacer+8		;space
	dc.w	_spacer+4		;!
	dc.w	_spacer+6		;"
	dc.w	_spacer+10		;#
	dc.w	_spacer+10		;$
	dc.w	_spacer+10		;%
	dc.w	_spacer+10		;&
	dc.w	_spacer+5		;`
	dc.w	_spacer+8		;(
	dc.w	_spacer+8		;)
	dc.w	_spacer+10		;*
	dc.w	_spacer+10		;+
	dc.w	_spacer+3		;,
	dc.w	_spacer+6		;'
	dc.w	_spacer+3		;.
	dc.w	_spacer+10		;/
	dc.w	_spacer+10		;0
	dc.w	_spacer+10		;1
	dc.w	_spacer+10		;2	
	dc.w	_spacer+10		;3
	dc.w	_spacer+10		;4
	dc.w	_spacer+10		;5
	dc.w	_spacer+10		;6
	dc.w	_spacer+10		;7
	dc.w	_spacer+10		;8
	dc.w	_spacer+10		;9
	dc.w	_spacer+3		;:
	dc.w	_spacer+3		;;
	dc.w	_spacer+10		;<
	dc.w	_spacer+6		;=
	dc.w	_spacer+10		;>
	dc.w	_spacer+10		;?
	dc.w	_spacer+10		;@
	dc.w	_spacer+10		;A
	dc.w	_spacer+10		;B
	dc.w	_spacer+10		;C
	dc.w	_spacer+10		;D
	dc.w	_spacer+10		;E
	dc.w	_spacer+10		;F
	dc.w	_spacer+10		;G
	dc.w	_spacer+10		;H
	dc.w	_spacer+8		;I
	dc.w	_spacer+10		;J
	dc.w	_spacer+10		;K
	dc.w	_spacer+10		;L
	dc.w	_spacer+10		;M
	dc.w	_spacer+10		;N
	dc.w	_spacer+10		;O
	dc.w	_spacer+10		;P
	dc.w	_spacer+10		;Q
	dc.w	_spacer+10		;R
	dc.w	_spacer+10		;S
	dc.w	_spacer+10		;T
	dc.w	_spacer+10		;U
	dc.w	_spacer+10		;V
	dc.w	_spacer+10		;W
	dc.w	_spacer+10		;X
	dc.w	_spacer+10		;Y
	dc.w	_spacer+10		;Z


td
	move.b	#0,$ffffc123
	rte
    IFEQ    STANDALONE
        include     lib/lib.s
    ENDC
; split music
music		incbin	msx/4DRNTRAB.SND
music2		incbin	msx/42.SND

checkTag
	lea		music2,a0
;TAGtracker:	ds.l	2		; MYM?TRAK	
	move.w	#'MY',d0
	move.l	#'TRAK',d1
.search
	cmp.w	(a0)+,d0
	bne		.search
	add.w	#2,a0
	cmp.l	(a0)+,d1
	bne		.search
.found
		move.l	a0,musicMetaPointer
;		move.b	#0,$ffffc123
	rts

musicMetaPointer		ds.l	1

	IFEQ	GENERATE_FONT
sourceFont	ds.b	$00000780			;1920
font		incbin	gfx/font.neo
	ELSE
sourceFont	incbin	gfx/textwriter/sourcefont.bin
	ENDC

	IFEQ	GENERATE_SPECFONT
smfx2y	incbin	gfx/smfx2y.neo
a8x14Buffer	ds.b	6*2*14*8
	ELSE
a8x14Buffer	incbin 	gfx/spectext.bin
	ENDC

pssst	
	incbin	gfx/pssst/hiatus2.crk

	dc.b	0,0,0,0
c2pdata5	
	incbin	data/gif/c2p6a.crk
	even

	dc.b	0,0,0,0
c2pdata6	
	incbin	data/gif/c2p6.crk
	even

	dc.b	0,0,0,0
c2pdata8
	incbin	data/gif/c2p8a.crk
	even

;	dc.b	0,0,0,0
;c2pdata9
;	incbin	data/gif/c2p9.crk
;	even

	dc.b	0,0,0,0
c2pdata12
	incbin	data/gif/c2p12.crk
	even

	dc.b	0,0,0,0
c2pdata16
	incbin	data/gif/c2p16.crk
	even

c2pScreenOffset	dc.w	10*160

changeC2PEffect
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	add.w	c2pscreenOff,a0
	add.w	c2pscreenOff,a1
	add.w	c2pScreenOffset,a0
	add.w	c2pScreenOffset,a1
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
.y set 0
	REPT 80
.x set .y
		movem.l	d0-d6/a2-a6,.x(a0)									;12/2 = 6 blocks
		movem.l	d0-d6/a2-a6,.x(a1)									;12/2 = 6 blocks
		movem.l	d0-d5,.x+48(a0)
		movem.l	d0-d5,.x+48(a1)
.y set .y+160
	ENDR


	lea		c2pList,a0
	add.w	c2pListOff,a0
	move.l	(a0)+,c2pPtr
	move.l	(a0)+,c2pMax
	move.l	(a0)+,c2pPalPtr
	move.l	(a0)+,c2pFrames
;	move.w	#0,c2pPalOff
	move.l	#0,chunkyOff
	move.w	#16,c2pscreenOff
	move.w	#1,block


	add.w	#4*4,c2pListOff
	cmp.w	#4*4*4,c2pListOff
	bne		.kkk
		move.w	#0,c2pListOff
.kkk
	move.w	#-1,doCranker

	rts

doCranker	dc.w	-1

c2pListOff	dc.w	0
c2pList
	dc.l	c2pdata5,(64+4)*40*54,pal1,380
	dc.l	c2pdata8,(64+4)*40*50,pal3,370
	dc.l	c2pdata12,(64+4)*40*56,pal5,370
	dc.l	c2pdata16,(64+4)*40*25,pal6,410


crankIt
	tst.w	doCranker
	beq		.end
		move.l	c2pPtr,a0
		move.l	c2pSourcePtr,a1
		jsr		cranker
		move.w	#0,doCranker
.end
	rts



terminateDemo
	move.w	#$2700,sr
	move.l	#dummyF,$70.w
	move.l	#dummy,$120.w
	move.w	#$2300,sr



	lea		$ffff8240,a0
	REPT 16
		move.w	#$777,(a0)+
	ENDR

	rts

dummyF
	addq.w	#1,$466.w
	rte


init_smfx2y
	move.w	#$2700,sr
	move.l	#smfx2y_vbl,$70
	move.w	#$2300,sr
	move.w	#100*160,c2pScreenOffset
	jsr		doSMFXPal

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	lea		smfx2y+128,a2
	move.w	#75-1,d7
.cpl
	REPT 40
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cpl

	rts

dddd	
	REPT 16
		dc.w	$770
	ENDR

timer_b
	pushall
	move.l	c2pPalPtr,a0
	add.w	c2pPalOff,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240
	popall
	rte

smfx2y_vbl
    move.w  #$0234,$ffff8240
    addq.w	#1,$466.w
			pushall
			jsr		doSMFXPal

    clr.b   $fffffa1b.w         													;6
    bset    #0,$fffffa07.w          												;7
    bset    #0,$fffffa13.w          												;7
	move.l	#timer_b,$120													;6
	move.b	#80,$fffffa21.w															;5
	bclr	#3,$fffffa17.w															;7
    move.b  #8,$fffffa1b.w          												;5		---> 43


 
	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
			swapscreens
			jsr		herpc2p

            popall
	rte

doSMFXPal
	lea		smfx2yPal,a0
	add.w	.smfx2yPalOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	subq.w	#1,.smfx2yWaiter
	bge		.end
		move.w	#3,.smfx2yWaiter
		sub.w	#16*2,.smfx2yPalOff
		bge		.end
			move.w	#0,.smfx2yPalOff
.end
	rts
.smfx2yPalOff	dc.w	11*16*2
.smfx2yWaiter	dc.w	4
smfx2yPal	
	dc.w	$234,$700,$600,$660,$770,$060,$666,$066,$006,$007,$606,$707,$000,$000,$000,$777	;0
	dc.w	$234,$711,$611,$661,$771,$161,$666,$166,$116,$117,$616,$717,$111,$111,$111,$777	;1
	dc.w	$234,$722,$622,$662,$772,$262,$666,$266,$226,$227,$626,$727,$222,$222,$222,$777	;2
	dc.w	$234,$733,$633,$663,$773,$363,$666,$366,$336,$337,$636,$737,$333,$333,$333,$777	;3
	dc.w	$234,$744,$644,$664,$774,$464,$666,$466,$446,$447,$646,$747,$444,$444,$444,$777	;4
	dc.w	$234,$755,$655,$665,$775,$565,$666,$566,$556,$557,$656,$757,$555,$555,$555,$777	;5

	dc.w	$234,$766,$666,$666,$776,$666,$666,$666,$666,$667,$666,$767,$666,$666,$666,$777	;6
	dc.w	$234,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$667,$345,$556,$777	;7
	dc.w	$234,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$556,$345,$556,$777	;8
	dc.w	$234,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$445,$345,$556,$777	;9
	dc.w	$234,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$335,$345,$556,$777	;10
	dc.w	$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$234,$345,$556,$777	;11



smfx2y	incbin 	gfx/pssst/smfx2y.neo

	include	lib/cranker.s


	section BSS


c2pSourcePtr		ds.l	1
fontBufferPointer	ds.l	1


    IFEQ    STANDALONE
memBase             ds.b    418*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
    ENDC