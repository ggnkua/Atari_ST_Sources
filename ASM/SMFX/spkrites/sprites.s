; sprites boiler code
;1. regular sprite code, preshift 16 sprite versions, for each sprite to be painted, determine source buffer and copy it to screen (basically, bounding square copy, unoptimized)
;2. regular sprite code, generated; for each sprite, determine specific sprite draw code (basically, omit copying words that are not filled)
;3. regular sprite code, generated, but reuse registers (same as 2, but instead of using immediate addressing, preload registers if words are used more than once; -> needed for sprites that are mirrored over y)
;1a. regular sprite code, preshift 16 versions, but instead of iterate per sprite, sort the sprites per sprite source, so draw list for 0 first, then lsit for 1, etc.
;4. combine 1a and 3


; todo, in a list of linked jump execution code, based on an offset, you can use the offset that is used to determine the code to be excuted, to point to an
;	exclusive terminating rout, and thus not needing the -1 for checking to terminate the list of data

BITPLANES	equ	2			; 1 = 1 bitplane, 2 = 2 bitplanes
spriteSize 	equ 0			; 0 = 16 x 16 / 1 = 32 x 32					1 plane				2 plane
SPRITEROUT	equ 3			; 1 = naive normal							125	/ 44			92  / 31
							; 2 = generated sprite rout					145	/ 60			136	/ 49	; todo: remove blt in drawSprites, for sprites*8 cpu
							; 3 = generated sprite rout regs			160	/ 66			142 / 54
							; 4 = generated sprite rout + partition
							;	for this rout, we do code generation for setting up regs seperate from the drawing code
							;	and we use all masks into regs
spriteCodeSize	equ 1024

listSize	set 64




	IF spriteSize=0
spriteHeight	equ 16
spriteWidth		equ 16/16			; per 16 pixel blocks
		IF BITPLANES=1
nr_sprites		set	142
		ENDC
		IF BITPLANES=2
nr_sprites		set 142
		ENDC
	ENDC
	IF spriteSize=1
spriteHeight	equ 32
spriteWidth		equ 32/16			; per 16 pixel blocks
listSize		set 64*2
		IF BITPLANES=1
nr_sprites		set 44
		ENDC
		IF BITPLANES=2
nr_sprites		set 54
		ENDC
	ENDC

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

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	TEXT

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init


	jsr		init_effect

.x
	
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts
	ENDC



init_effect


	move.w	#$700,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	add.l	#$10000,d0

	move.l	d0,d1
	move.l	d1,y2pointer
	add.l	#1536*2*2,d1								;-3072
	move.l	d1,y1pointer
	add.l	#512*2*2,d1									;-1024	
	move.l	d1,x1pointer
	add.l	#8*273*2*2,d1								;-4368
	move.l	d1,x2pointer
	add.l	#9*128*2*2,d1								;-2304
	
	add.l	#$10000,d0
	move.l	d0,xPositionPointer
	add.l	#$10000,d0
	move.l	d0,drawSpriteCodeBuffersPointer
	add.l	#$10000,d0
	move.l	d0,clearSpriteCodeBuffersPointer



		jsr		generateDrawSpriteCodeBuffers
		jsr		generateClearSpriteCodeBuffers

	IF SPRITEROUT=1 
		jsr		generateXPointerNaive
		jsr		generateSineTablesNaive
	ENDC

	IF	BITPLANES=1
		jsr		prepSprites1Bitplane
	ENDC
	IF	BITPLANES=2
		jsr		prepSprites2Bitplanes
	ENDC

	IF SPRITEROUT=2
		jsr		genSpriteCodeImmediate
		jsr		genSpriteClearCode
		jsr		generateXPointerImmediate
		jsr		generateSineTablesImmediate
		lea		cspr1,a0
		move.w	#16*spriteCodeSize,(a0)+
		move.w	#16*spriteCodeSize,(a0)+
		lea		cspr2,a0
		move.w	#16*spriteCodeSize,(a0)+
		move.w	#16*spriteCodeSize,(a0)+
	ENDC

	IF	SPRITEROUT=3
		jsr		genSpriteClearCode
		jsr		generateXPointerImmediate
		jsr		generateSineTablesImmediate
		lea		cspr1,a0
		move.w	#16*spriteCodeSize,(a0)+
		move.w	#16*spriteCodeSize,(a0)+
		lea		cspr2,a0
		move.w	#16*spriteCodeSize,(a0)+
		move.w	#16*spriteCodeSize,(a0)+
		IF	BITPLANES=1
			jsr		analyseSprite1Bitplane
		ENDC
		IF	BITPLANES=2
			jsr		analyseSprite2Bitplanes
		ENDC
	ENDC

;	IF	SPRITEROUT=4
;		jsr		genSpriteClearCode
;		jsr		generateXPointerImmediate
;		jsr		generateSineTablesImmediate
;		lea		cspr1,a0
;		move.w	#16*spriteCodeSize,(a0)+
;		move.w	#16*spriteCodeSize,(a0)+
;		lea		cspr2,a0
;		move.w	#16*spriteCodeSize,(a0)+
;		move.w	#16*spriteCodeSize,(a0)+
;		jsr		analyseSprite1Bitplane
;	ENDC

	move.l	drawSpriteCodeBuffersPointer,a6
	rept 16
;		move.b	#0,$ffffc123
		add.l	#spriteCodeSize,a6
	endr
;	rts




    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr

    move.b	#0,$ffffc123
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466



    move.w	#$2700,sr
    move.l	#effect_vbl,$70
    move.w	#$2300,sr
	rts  
.vblwaiter	dc.w	20

.wvbl
    addq.w  #1,$466.w
    rte


effect_vbl
    move.w  #$0,$ffff8240
	move.l	screenpointer2,$ffff8200
		    pushall
		    IF SPRITEROUT=1
		    	add.w	#$001,$ffff8240
			    jsr		clearSpritesNaive
		    	add.w	#$001,$ffff8240
			    jsr		swapClearPointers
			    jsr		advanceSprites
		    	add.w	#$001,$ffff8240
			    jsr		drawSpritesNaive
		    ENDC

		    IF SPRITEROUT=2
		    	add.w	#$001,$ffff8240
		    	jsr		clearSpritesImmediate
		    	add.w	#$001,$ffff8240
		    	jsr		swapClearPointers
		    	add.w	#$001,$ffff8240
		    	jsr		advanceSprites
		    	add.w	#$001,$ffff8240
		    	jsr		drawSpritesImmediate
				move.w	savedHax,-2(a1)
		    ENDC

		    IF SPRITEROUT=3
		    	add.w	#$001,$ffff8240
		    	jsr		clearSpritesImmediate
		    	add.w	#$001,$ffff8240
		    	jsr		swapClearPointers
		    	add.w	#$001,$ffff8240
		    	jsr		advanceSprites
		    	add.w	#$001,$ffff8240
		    	jsr		drawSpritesImmediate
				move.w	savedHax,-2(a1)
		    ENDC

		    IF SPRITEROUT=4
		    	add.w	#$001,$ffff8240
		    	jsr		clearSpritesImmediate
		    	add.w	#$001,$ffff8240
		    	jsr		swapClearPointers
		    	add.w	#$001,$ffff8240
		    	jsr		advanceSprites
		    	add.w	#$001,$ffff8240
		    	jsr		drawSpritesImmediate
				move.w	savedHax,-2(a1)
		    ENDC

		    move.w	#$200,$ffff8240
	    	popall
		    swapscreens
	rte
;;;;;------------------ GENERIC CODE ---------------------
;;;;;------------------ GENERIC CODE ---------------------
;;;;;------------------ GENERIC CODE ---------------------
swapClearPointers	
	move.l	clearSpritesPointer2,d0
	move.l	clearSpritesPointer,clearSpritesPointer2
	move.l	d0,clearSpritesPointer
	rts

generateDrawSpriteCodeBuffers
	lea		drawSpriteCodeBuffers,a0
	move.l	drawSpriteCodeBuffersPointer,d0
	REPT 17
		move.l	d0,(a0)+
		add.w	#spriteCodeSize,d0
	ENDR
	rts

generateClearSpriteCodeBuffers
	lea		clearSpriteCodeBuffers,a0
	move.l	clearSpriteCodeBuffersPointer,d0
	REPT 17
		move.l	d0,(a0)+
		add.w	#spriteCodeSize,d0
	ENDR
	rts


prepSprites1Bitplane
	lea	sprites+128,a0
	lea	sprite0,a1
	moveq	#0,d0

;.y set 0
	moveq	#0,d6
	move.w	#spriteHeight-1,d5
.ol
;	REPT spriteHeight
		move.w	d6,d4
;.x set .y	
		move.w	#spriteWidth-1,d3
.il
;		REPT spriteWidth	
			move.w	(a0,d4.w),(a1)+
;.x set .x+8
		addq.w	#8,d4
		dbra	d3,.il
;		ENDR
		move.w	#0,(a1)+
;.y set .y+160
		add.w	#160,d6
;	ENDR
	dbra	d5,.ol

	lea		sprite0,a0
	lea		spriteHeight*(spriteWidth+1)*2(a0),a1
	move.w	#spriteHeight*15-1,d7
.ol2
		move.w	#spriteWidth,d6
.il2
;		REPT spriteWidth+1
			move.w	(a0)+,d0
			roxr.w	d0	
			move.w	d0,(a1)+
		dbra	d6,.il2
;		ENDR
	dbra	d7,.ol2
	rts

prepSprites2Bitplanes
	lea		sprites+128,a0

	add.w	#32*160,a0

	lea		sprite0,a1
	moveq	#0,d0
.y set 0
	REPT spriteHeight
.x set .y	
		REPT spriteWidth	
			move.l	.x(a0),(a1)+
.x set .x+8
		ENDR
		move.l	#0,(a1)+
.y set .y+160
	ENDR

	lea		sprite0,a0
	lea		spriteHeight*(spriteWidth+1)*4(a0),a1
	move.w	#spriteHeight*15-1,d7
.l
		REPT spriteWidth+1
			move.w	(a0)+,d0
			roxr.w	d0	
			move.w	d0,(a1)+
			lea		2(a0),a0
			lea		2(a1),a1
		ENDR
	dbra	d7,.l


	lea		sprite0,a0
	lea		spriteHeight*(spriteWidth+1)*4(a0),a1
	move.w	#spriteHeight*15-1,d7
	moveq	#0,d0
	roxr.w	d0

	lea		2(a0),a0
	lea		2(a1),a1
.l2
		REPT spriteWidth+1
			move.w	(a0)+,d0
			roxr.w	d0	
			move.w	d0,(a1)+
			lea		2(a0),a0
			lea		2(a1),a1
		ENDR
	dbra	d7,.l2

	rts

advanceSprites
	add.w	#2,sine_y1_step
	and.w	#sine_y1_step_mask,sine_y1_step
	sub.w	#10,sine_y2_step
	and.w	#sine_y2_step_mask,sine_y2_step

	add.w	#2,sine_x1_step
	and.w	#sine_x1_step_mask,sine_x1_step
	add.w	#2,sine_x2_step
	and.w	#sine_x2_step_mask,sine_x2_step
	rts
;;;;;---------------- NAIVE CODE --------------------
;;;;;---------------- NAIVE CODE --------------------
;;;;;---------------- NAIVE CODE --------------------
generateSineTablesNaive
	lea		y1s,a0							;64 words = 128 data
	move.l	y1pointer,a2
	move.w	#8-1,d7
.copy
		move.l	a0,a1
		REPT 32
			move.l	(a1)+,(a2)+
		ENDR
	dbra	d7,.copy


	lea		y2s,a0
	move.l	y2pointer,a2
	move.w	#3-1,d7								; 3 * 512 * 2 = 1536 -> 3072
.copy2
		move.l	a0,a1	
		move.w	#16-1,d6							; 512
.il2	
			REPT 16
				move.l	(a1)+,(a2)+				; 64
			ENDR
		dbra	d6,.il2

	dbra	d7,.copy2

	lea		x1s,a0
	move.l	x1pointer,a2
	move.w	#8-1,d7
.ol3
		move.l	a0,a1
		move.w	#8-1,d6
.il3
			REPT 17		
				move.l	(a1)+,(a2)+			;68		
			ENDR
		dbra	d6,.il3
		move.w	(a1)+,(a2)+
	dbra	d7,.ol3	

	lea		x2s,a0
	move.l	x2pointer,a2
	move.w	#9-1,d7
.ol4
		move.l	a0,a1
		move.w	#4-1,d6					;128
.il4
		REPT 16
			move.l	(a1)+,(a2)+			;64
		ENDR
		dbra	d6,.il4
	dbra	d7,.ol4
	rts

generateXPointerNaive
		move.l	xPositionPointer,a0
		moveq	#0,d0
		move.w	#20-1,d7						; 20*16*16*2*2*2 = 320 * 16 * 2 * 2 * 2 = 5120 * 8 =
.ol
		moveq	#0,d1
		move.w	#16-1,d6
.il
				move.w	d0,(a0)+
				move.w	d1,(a0)+
				add.w	#spriteHeight*(spriteWidth+1)*2*BITPLANES,d1
			dbra	d6,.il
			addq.w	#8,d0
		dbra	d7,.ol
	rts
	IF		SPRITEROUT=1
drawSpritesNaive
	move.l	screenpointer2,d1
	move.l	x1pointer,a1
	add.w	sine_x1_step,a1
	move.l	x2pointer,a2
	add.w	sine_x2_step,a2
	move.l	y1pointer,a3
	add.w	sine_y1_step,a3
	move.l	y2pointer,a4
	add.w	sine_y2_step,a4

	move.l	xPositionPointer,d0				; aligned

	lea		sprite0,a6
	move.l	a6,usp

	move.l	clearSpritesPointer,a6
	REPT nr_sprites
		move.w	(a1)+,d0		;8			; first x value
;		add.w	(a2)+,d0		;8			; second x value
		move.l	d0,a0			;4			; use x value as lookup
		move.w	(a0)+,d1		;8			; offset into screen
		move.l	usp,a5			;4			; use sprite lookup							; this could be 64kb aligned address; and save these cycles
		add.w	(a0),a5			;12			; add offset to source						; move.w	(a0),d2	; move.l d2,a5
		add.w	(a3)+,d1		;8			; add y1
;		add.w	(a4)+,d1		;8			; add y2
		move.l	d1,a0			;4			; use as screen
		move.w	d1,(a6)+		;8	-->72	; save screen off for clearing


				IF BITPLANES=2
.p set 0
		REPT 5
					movem.l	(a5)+,d2-d7		;2,3,4,5,6 = 6
					or.l	d2,.p(a0)
					or.l	d3,.p+8(a0)
					or.l	d4,.p+160(a0)
					or.l	d5,.p+168(a0)
					or.l	d6,.p+320(a0)
					or.l	d7,.p+328(a0)
.p set .p+480
		ENDR
		move.l	(a5)+,d2
		move.l	(a5)+,d3
		or.l	d2,.p(a0)
		or.l	d2,.p(a0)

				ENDC




.p set 0
		REPT spriteHeight
.c set .p
			REPT spriteWidth+1
				IF BITPLANES=1
					move.w	(a5)+,d0
					or.w	d0,.c(a0)
				ENDC
				IF BITPLANES=2
;					move.l	(a5)+,d5
;					or.l	d5,.c(a0)
				ENDC
.c set .c+8
			ENDR
.p set .p+160
		ENDR
	ENDR
	rts

clearSpritesNaive
	move.l	screenpointer2,d0
	move.l	clearSpritesPointer2,a0
	moveq	#0,d1
	REPT nr_sprites
		move.w	(a0)+,d0
		move.l	d0,a1
.c	set 0
		REPT spriteHeight
.p set .c
			REPT spriteWidth+1
				IF BITPLANES=1
				move.w	d1,.p(a1)
				ENDC
				IF BITPLANES=2
				move.l	d1,.p(a1)
				ENDC
.p set .p+8
			ENDR
.c set .c+160
		ENDR
	ENDR
	rts
	ENDC
;;;-------------- IMMEDIATE CODE -----------------
;;;-------------- IMMEDIATE CODE -----------------
;;;-------------- IMMEDIATE CODE -----------------
generateSineTablesImmediate
	lea		x1s,a0
	move.l	x1pointer,a2
	move.w	#8-1,d7
.ol3
		move.l	a0,a1
		move.w	#8-1,d6
.il3
			REPT 17*2		
				move.w	(a1)+,d0
				add.w	d0,d0
				move.w	d0,(a2)+			;68		
			ENDR
		dbra	d6,.il3
		move.w	(a1)+,d0
		add.w	d0,d0
		move.w	d0,(a2)+
	dbra	d7,.ol3	

	lea		x2s,a0
	move.l	x2pointer,a2
	move.w	#9-1,d7
.ol4
		move.l	a0,a1
		move.w	#4-1,d6					;128
.il4
		REPT 16*2
			move.w	(a1)+,d0
			add.w	d0,d0
			move.w	d0,(a2)+			;64
		ENDR
		dbra	d6,.il4
	dbra	d7,.ol4

	lea		y1s,a0							;64 words = 128 data
	move.l	y1pointer,a2
	move.w	#8-1,d7
.copy
		move.l	a0,a1
		REPT 32
			move.l	(a1)+,(a2)+
		ENDR
	dbra	d7,.copy


	lea		y2s,a0
	move.l	y2pointer,a2
	move.w	#3-1,d7								; 3 * 512 * 2 = 1536 -> 3072
.copy2
		move.l	a0,a1	
		move.w	#16-1,d6							; 512
.il2	
			REPT 16
				move.l	(a1)+,(a2)+				; 64
			ENDR
		dbra	d6,.il2

	dbra	d7,.copy2


	rts


generateXPointerImmediate
		move.l	xPositionPointer,a0
		move.l	drawSpriteCodeBuffersPointer,a6
		moveq	#0,d0
		move.w	#20-1,d7
.ol
		moveq	#0,d1
		move.w	#16-1,d6
.il
				move.w	d0,(a0)+
				move.w	d1,(a0)+
				move.l	#0,(a0)+
				add.l	#spriteCodeSize,d1
			dbra	d6,.il
			addq.w	#8,d0
		dbra	d7,.ol
	rts


drawSpritesImmediate
	move.l	screenpointer2,d1
	move.l	x1pointer,a1
	add.w	sine_x1_step,a1
	move.l	x2pointer,a2
	add.w	sine_x2_step,a2
	move.l	y1pointer,a3
	add.w	sine_y1_step,a3
	move.l	y2pointer,a4
	add.w	sine_y2_step,a4

	move.l	xPositionPointer,d0				; aligned

	lea		sprite0,a6
	move.l	a6,usp

	move.l	clearSpritesPointer,a6
	move.l	drawSpriteCodeBuffersPointer,d2
	move.w	nr_sprites*2(a1),savedHax
	move.w	#-1,nr_sprites*2(a1)


;	REPT nr_sprites
		move.w	(a1)+,d0		;8			; first x value
		blt		.exit
;		add.w	(a2)+,d0		;8			; second x value
		move.l	d0,a0			;4			; use x value as lookup
		move.w	(a0)+,d1		;8			; offset into screen
		move.w	(a0),d2			;12			; offset into drawing/clearing rout
		add.w	(a3)+,d1		;8			; add y1
;		add.w	(a4)+,d1		;8			; add y2
		move.w	d1,(a6)+		;8			; save total offset into screen
		move.w	d2,(a6)+		;8			; save offset for clearing rout
		move.l	d1,a0			;4			; use as screen
		move.l	d2,a5			;4			; use as drawing rout pointer
		jmp		(a5)			;8			; do the drawing rout							; jmp (a5) = -8
								;---> 88
;	ENDR
.exit
	rts
savedHax	dc.l	0

clearSpritesImmediate
	move.l	clearSpritesPointer2,a6
	move.l	clearSpriteCodeBuffersPointer,d7
	move.l	screenpointer2,d1
	moveq	#0,d0
;	REPT nr_sprites
		move.w	(a6)+,d1		;8			; get offset into screen
		move.l	d1,a0			;4			; use offset as screen
		move.w	(a6)+,d7		;8			; get clear rout
		move.l	d7,a5			;4			; use as clearing rout
		jmp		(a5)			;8			; do the clearing rout		; 16*256 value does rts
;	ENDR
;	rts





drawSpriteCodeBuffers
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

clearSpriteCodeBuffers
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0



genClear	macro
	IF BITPLANES=1
		move.w	(a0)+,d0
		beq		.skip\@
			move.w	d2,d3
			move.l	d3,(a4)+
.skip\@
		addq.w	#8,d2				; offset+8
	ENDC
	IF BITPLANES=2
		move.w	(a0)+,d0
		beq		.skipFirst\@
			move.w	(a0)+,d0
			beq		.skipSecond\@
.clearBoth\@
		move.w	d2,d0
		move.l	d0,(a4)+
		jmp		.skip\@
.skipSecond\@
		move.w	d2,d3
		move.l	d3,(a4)+
		jmp		.skip\@
.skipFirst\@
		move.w	(a0)+,d0
		beq		.skip\@
			move.w	d2,d3
			add.w	#2,d3
			move.l	d3,(a4)+
			jmp		.skip\@
.skip\@
		addq.w	#8,d2
	ENDC
	endm

genSpriteClearCode
	lea		sprite0,a0
	lea		clearSpriteCodeBuffers,a3
	move.w	#16-1,d5

	move.l	.clearCode(pc),d3
	move.l	.clearCode2(pc),d0
.doSprite
		move.l	(a3)+,a4
		move.w	#spriteHeight-1,d7
		moveq	#0,d1
.ol
			move.l	d1,d2
			move.w	#spriteWidth,d6
;			REPT spriteWidth+1
.il
				genClear
;			ENDR
			dbra	d6,.il
			add.w	#160,d1				; add 160 to y offset
		dbra	d7,.ol

		lea		.clearIter,a5
		REPT 7
			move.w	(a5)+,(a4)+
		ENDR
	dbra	d5,.doSprite
	move.l	(a3)+,a4
	move.w	.clearIterExit,(a4)+		
	rts
.clearCode
	move.w	d0,2(a0)
.clearCode2
	move.l	d0,2(a0)
.rts
	rts
.clearIter
	move.w	(a6)+,d1		;2					;
	move.l	d1,a0			;2
	move.w	(a6)+,d7		;2
	move.l	d7,a5			;2
	jmp		(a5)			;2
.clearIterExit
	rts						;2		;-> 14


genSprite	macro
	IF	BITPLANES=1
		move.w	(a0)+,d0			; value
		beq		.skip\@
			move.l	d0,(a2)+
			move.w	d2,(a2)+
.skip\@
		addq.w	#8,d2				; offset+8
	ENDC
	IF	BITPLANES=2
		move.w	(a0)+,d0			; top word
		beq		.skipFirst\@
;--------------- top word filled
			move.w	(a0)+,d4		; low word
			beq		.firstFilled\@
.bothFilled\@
			move.w	d3,(a2)+		; operand
			move.w	d0,(a2)+		; top word
			move.w	d4,(a2)+		; bot word
			move.w	d2,(a2)+		; word offset
			jmp		.skip\@
.firstFilled\@
			move.l	d0,(a2)+		; operand .w + top word
			move.w	d2,(a2)+		; word offset
			jmp		.skip\@
;--------------- end top word filled 
.skipFirst\@
		move.w	(a0)+,d0
		beq		.skip\@
;--------------- lower word filled 
			move.l	d0,(a2)+		; operand .w + low word
			move.w	d2,(a2)+		; offset
			add.w	#2,-2(a2)		; offset+2
			jmp		.skip\@
.skip\@
		addq.w	#8,d2
	ENDC


	endm

genSpriteCodeImmediate
	lea		sprite0,a0
	lea		drawSpriteCodeBuffers,a1
	move.w	#16-1,d5

	move.l	.drawCode(pc),d0			; or.w	#WORD,OFFSET(a0)
	move.w	.drawCode2(pc),d3			; or.l	#LONG,OFFSET(a0)

.doSprite
		move.l	(a1)+,a2				; get target write buffer

		move.w	#spriteHeight-1,d7		; hline
		moveq	#0,d1					; offset-y
.ol
			move.l	d1,d2				; offset-x

			REPT spriteWidth+1
				genSprite
			ENDR
			add.w	#160,d1				; add 160 to y offset
		dbra	d7,.ol

		lea		.drawIter,a5
		REPT 18
			move.w	(a5)+,(a2)+
		ENDR
	dbra	d5,.doSprite

	move.l	(a1)+,a2

	move.l	.drawIterExit,(a2)+
	move.w	.drawIterExit+2,(a2)+
	rts
.drawCode
	or.w	#-1,2(a0)
.drawCode2
	or.l	#-1,2(a0)
.rts
	rts
.drawIter
	move.w	(a1)+,d0		;2
	blt		.drawIterExit	;2					; to remove this:		alter 2*nr_sprites(a1,a2,a3,a4) so that d2 becomes 16*256, for rts, and alter a0 with extra entry
;	add.w	(a2)+,d0		;2	
	move.l	d0,a0			;2
	move.w	(a0)+,d1		;2
	move.w	(a0),d2			;2
	add.w	(a3)+,d1		;2
;	add.w	(a4)+,d1		;2
	move.w	d1,(a6)+		;2
	move.w	d2,(a6)+		;2
	move.l	d1,a0			;2
	move.l	d2,a5			;2
	jmp		(a5)			;2
.drawIterExit
	move.w	#16*spriteCodeSize,(a6)+
	move.w	#16*spriteCodeSize,(a6)+
	rts						;2		;-> 36/2

;;;;------------ GENERATED SPRITEROUT REGISTERS ------------------
;;;;------------ GENERATED SPRITEROUT REGISTERS ------------------
;;;;------------ GENERATED SPRITEROUT REGISTERS ------------------
;;;;------------ GENERATED SPRITEROUT REGISTERS ------------------
;;;;------------ GENERATED SPRITEROUT REGISTERS ------------------

;        move.w  #someval,d0             ;8
;        move.w  d0,x(a0)                ;12
;        move.w  d0,x+160(a0)            ;12
;
;        move.w  #someval,x(a0)          ;16
;        move.w  #someval,x(a0)          ;16
;
;        so from 2 and up, we're good

; time to generate some code using registers, so what do we do?
; we should parse the sprite into a list of:
;	word,times
; then we can sort this list
; then iterate through the list
; first 7 that are count > 1, will be assigned to  	
;
; sooo. lets structure stuff, each block of the sprite has 2 values;
;	`mask' and `position'
;	masks can be shared over multiple positions
;	if a mask is -1, we can do move.w instead of or.w
;	if mask is used = 2 times in sprite AND mask value is between -128 and 127 -> moveq
;	
;	so first, list of masks, and how many times
;	sort this list
;	then deal with each of them individually	
;
;	moveq	#127,d0						; -128 < x < 127
;	move.b	#0,$ffffc123
;
; 	in order to get unique list of masks and counts;
;	
;	maskList,a0
;	check if d0 is in a0
;	if not, add d0 to end of list, count 1
;	if it is, increase count by 1 in list
;	
;	maskList - mask,count,offsets	terminated with -1
;		; whats a useful datastructure
;	

findPosition2 macro
	move.l	a1,a6
	moveq	#0,d1				; index; if found, or pointer to store if found
.FPtest\@
		move.l	(a6)+,d7			
		beq		.FPnotFound\@
.FPvalidValue\@
			cmp.l	d0,d7
			beq		.FPfound\@
				addq.w	#4,d1	
				jmp		.FPtest\@
.FPnotFound\@									; if not found, d7 != d0
.FPfound\@										; if found, d7 = d0
	endm

analyseSprite2Bitplanes
	lea		sprite0,a0

	move.w	#16-1,d7					; 16 sprites to handle
.doSprite
	pushd7
;------- clear memory to 0
		jsr		clearTables				; init everything 0
		lea		maskList,a1
		lea		countList,a2
		lea		offsetList,a5
;----------- do sprite analysis -------------
.y set 0
		moveq	#0,d6				;.y
		move.w	#spriteHeight-1,d5	; rept spriteheight
.ol
;		REPT spriteHeight
;.x set .y
			move.w	d6,d4			;.x set .y
;			REPT spriteWidth+1
			move.w	#spriteWidth,d3
.il

doMask2	macro
		move.l	(a0)+,d0				; get 2 bitplanes worth
		beq		.end\@
				findPosition2
		move.l	a5,a3
		cmp.l	d0,d7
		beq		.found\@
.new\@
		move.l	d0,(a1,d1.w)
		move.l	#1,(a2,d1.w)
		lsl.w	#5,d1				; careful here!
		IF	listSize=128
			add.w	d1,d1
		ENDC

;		move.w	#.x,(a3,d1.w)
		move.w	d4,(a3,d1.w)
		jmp		.end\@
.found\@
		add.l	#1,(a2,d1.w)
		lsl.w	#5,d1
		IF	listSize=128
			add.w	d1,d1
		ENDC		
		add.w	d1,a3
.nextOff\@
		move.w	(a3)+,d1
		bge		.nextOff\@
;			move.w	#.x,-2(a3)
			move.w	d4,-2(a3)
.end\@
	endm
				doMask2		; d0,d1 ; a0,a1,a2,a3,a5
;.x set .x+8	
			addq.w	#8,d4
			dbra	d3,.il
;			ENDR
;.y set .y+160
			add.w	#160,d6
;		ENDR
		dbra	d5,.ol

	pushall

	lea		maskList,a0
	lea		countList,a1
	lea		offsetList,a2
	move.l	a2,usp

	lea		drawSpriteCodeBuffers,a5
	add.w	.spriteCodeOff,a5
	move.l	(a5),a5
	lea		clearSpriteCodeBuffers,a6
	add.w	.spriteCodeOff,a6
	move.l	(a6),a6
; now get shit done
	
	; now we iterate through the masklist, and for each mask we do stuff
	; 1). check what the mask is, first-word, second-word, longword
	; 
	moveq	#0,d6
	moveq	#0,d7					; for offsets
	move.w	#0,.regSelect				
	move.l	.clearLongWord,d4
	move.l	.clearWord,d3

.doMask
	move.l	(a0)+,d0				; get mask
	beq		.maskEnd				; if = 0, then we are done and we can finish
		tst.w	d0
		beq		.firstWordOnly
.secondWordFilled
			move.l	d0,d1
			swap	d1
			tst.w	d1
			beq		.secondWordOnly
;-------- longword ------------
.longWord								; longword
	move.l	(a1)+,d7					; count
	move.l	usp,a2
	add.w	d6,a2
	add.w	#listSize*2,d6
;	cmp.w	#2,d7
;	blt		.longWordOnce
.longWordTwoOrMore
		subq.w	#1,d7					;-1 for loop				; TODO: opt for moveq register value and move into screen, for now we assume OR
		; first load the reg
		move.w	.regCodeLongWord,(a5)+		; opcode for move.l #x,reg
		move.l	d0,(a5)+					; #x
		; then do loop for writing the code
		move.l	.orLongWord,d5
		jmp		.generateLongWordDraw		
.longWordOnce
		move.w	.orLongWordImmediate,(a5)+
		move.l	d0,(a5)+
		move.w	(a2)+,d4
		move.w	d4,(a5)+
		move.l	d4,(a6)+
		jmp		.doMask
.generateLongWordDraw
			move.w	(a2)+,d5				; put offset in lower word drawLongWord
			move.w	d5,d4					; put offset in lower word clearLongWord
			move.l	d5,(a5)+
			move.l	d4,(a6)+
		dbra	d7,.generateLongWordDraw
		jmp		.doMask
;--------- first word ------------
.firstWordOnly							; word +0
	swap	d0
	move.l	(a1)+,d7					; count
	move.l	usp,a2
	add.w	d6,a2
	add.w	#listSize*2,d6
	cmp.w	#2,d7
	blt		.firstWordOnlyOnce
.firstWordTwoOrMore
		subq.w	#1,d7					;-1 for loop
		; first load the reg
		move.w	.regCodeWord,(a5)+		; load word x in reg
		move.w	d0,(a5)+				; load value x
		move.l	.orWord,d5
		jmp		.generateWordDrawFirst
.firstWordOnlyOnce
		move.w	.orWordImmediate,(a5)+
		move.w	d0,(a5)+
		move.w	(a2)+,d4
		move.w	d4,(a5)+
		move.l	d4,(a6)+
		jmp		.doMask
.generateWordDrawFirst
			move.w	(a2)+,d5
			move.w	d5,d3
			move.l	d5,(a5)+
			move.l	d3,(a6)+
		dbra	d7,.generateWordDrawFirst
		jmp		.doMask
;--------- second word ------------
.secondWordOnly							; word +2
	move.l	(a1)+,d7					; count
	move.l	usp,a2
	add.w	d6,a2
	add.w	#listSize*2,d6
	cmp.w	#2,d7
	blt		.secondWordOnlyOnce
.secondWordTwoOrMore
		subq.w	#1,d7					;-1 for loop
		; first load the reg
		move.w	.regCodeWord,(a5)+		; load word x in reg
		move.w	d0,(a5)+				; load value x
		move.l	.orWord,d5
		jmp		.generateWordDrawSecond
.secondWordOnlyOnce
		move.w	.orWordImmediate,(a5)+
		move.w	d0,(a5)+
		move.w	(a2)+,(a5)+
		add.w	#2,-2(a5)		; add 2
		jmp		.doMask
.generateWordDrawSecond
			move.w	(a2)+,d5
			add.w	#2,d5
			move.w	d5,d3
			move.l	d5,(a5)+
			move.l	d3,(a6)+
		dbra	d7,.generateWordDrawSecond
		jmp		.doMask

.maskEnd

	; finish draw
	lea		.drawIter,a2
	REPT 	36/4
		move.l	(a2)+,(a5)+
	ENDR
	; finish cler
	lea		.clearIter,a2
	REPT	7
		move.w	(a2)+,(a6)+
	ENDR

	add.w	#4,.spriteCodeOff
	popall
	popd7
	dbra	d7,.doSprite
	rts
.spriteCodeOff	dc.w	0
.regSelect		dc.w	0
.orLongWord	
	or.l	d4,2(a0)
.orWord
	or.w	d4,2(a0)
.regCodeLongWord
	move.l	#12345,d4		; 2 = op, 4 = value
.regCodeWord
	move.w	#12345,d4		; 2 = op, 2 = vaue
.clearLongWord
	move.l	d0,2(a0)
.clearWord
	move.w	d0,2(a0)
.orLongWordImmediate
	or.l	#12345,2(a0)
.orWordImmediate
	or.w	#12345,2(a0)
.clearIter
	move.w	(a6)+,d1		;2		;
	move.l	d1,a0			;2
	move.w	(a6)+,d7		;2
	move.l	d7,a5			;2
	jmp		(a5)			;2
.drawIter
	move.w	(a1)+,d0		;2		
	blt		.drawIterExit	;2					; to remove this:		alter 2*nr_sprites(a1,a2,a3,a4) so that d2 becomes 16*256, for rts, and alter a0 with extra entry
;	add.w	(a2)+,d0		;2		
	move.l	d0,a0			;2		
	move.w	(a0)+,d1		;2
	move.w	(a0),d2			;2				alt:
	add.w	(a3)+,d1		;2					move.w	(a1)+,d0		;8 get offset to screen
;	add.w	(a4)+,d1		;2					move.l	d0,a0			;4 use as screen
	move.w	d1,(a6)+		;2					move.w	(a1)+,d2		;8 get rout
	move.w	d2,(a6)+		;2					move.l	d2,a5			;4 use as jump
	move.l	d1,a0			;2					move.w	d0,(a6)+		;8 save offset for clear
	move.l	d2,a5			;2					move.w	d2,(a6)+		;8 save rout for clear
	jmp		(a5)			;2					jmp		(a5)			;8	--> 32		vs 60		-28 per sprite
.drawIterExit
	move.w	#16*spriteCodeSize,(a6)+	;4
	move.w	#16*spriteCodeSize,(a6)+	;4
	rts						;2		;-> 36



analyseSprite1Bitplane
	lea		sprite0,a0

	move.w	#16-1,d7					; 16 sprites to handle
.doSprite
	pushd7
;------- clear memory to 0
		jsr		clearTables				; init everything 0
		lea		maskList,a1
		lea		countList,a2
		lea		offsetList,a5

;----------- do sprite analysis -------------
.y set 0
		REPT spriteHeight
.x set .y
			REPT spriteWidth+1	
doMask macro
				move.w	(a0)+,d0			; get mask
				beq		.end\@				; if 0, skip
;				jsr		findPosition		; result: d0 == d7 if found, d0 != d7 if not found, d1 is index		

;------------ find position ------------------
				move.l	a1,a6
				moveq	#0,d1				; index; if found, or pointer to store if found
.FPtest\@
				move.w	(a6)+,d7			
				beq		.FPnotFound\@
.FPvalidValue\@
					cmp.w	d0,d7
					beq		.FPfound\@
						addq.w	#2,d1	
						jmp		.FPtest\@
.FPnotFound\@									; if not found, d7 != d0
.FPfound\@										; if found, d7 = d0
;----------- position found ------------------

				move.l	a5,a3					; offsetList
				cmp.w	d0,d7
				beq		.found\@
.notFound\@
				move.w	d0,(a1,d1.w)
				move.w	#1,(a2,d1.w)
				lsl.w	#6,d1
				IF	listSize=128
					add.w	d1,d1
				ENDC
				move.w	#.x,(a3,d1.w)				
				jmp		.end\@
.found\@
				add.w	#1,(a2,d1.w)
				lsl.w	#6,d1				;*64
				IF	listSize=128
					add.w	d1,d1
				ENDC
				add.w	d1,a3
.nextOff\@
				move.w	(a3)+,d1
				bge		.nextOff\@
					move.w	#.x,-2(a3)
.end\@
	endm
				doMask

.x set .x+8
			ENDR
.y set .y+160
		ENDR
;-------- end sprite analysis ------------------
	; now to generate code

	pushall

	lea		maskList,a0
	lea		countList,a1
	lea		offsetList,a2
	move.l	a2,usp

	lea		drawSpriteCodeBuffers,a5
	add.w	.spriteCodeOff,a5
	move.l	(a5),a5
	lea		clearSpriteCodeBuffers,a6
	add.w	.spriteCodeOff,a6
	move.l	(a6),a6
;	move.b	#0,$ffffc123
	moveq	#0,d0					; offset into offsetList
	moveq	#0,d6					; to keep track of which register we're at :)


	move.w	.drawCodeRegMove,d4			; clear code
	swap	d4
	; now that all is set, lets start generating code
	; first generate all setting of registers, before anything else
.doMask
	move.w	(a0)+,d1			; mask
	beq		.end				; if we get 0, then we have no more masks
	move.w	(a1)+,d7			; count
	move.l	usp,a2
	add.w	d0,a2
	add.w	#listSize*2,d0
	cmp.w	#2,d7
	blt		.once
.twoormore
	subq.w	#1,d7			; -1 for dbra

	cmp.w	#-1,d1
	beq		.useMove
.useOr
	lea		.regCode,a3
	add.w	d6,a3
	add.w	d6,a3
	move.w	(a3)+,(a5)+			; move.w	x,dn
	move.w	d1,(a5)+			; x = mask
	lea		.drawCodeRegOr,a3
	jmp		.cont
.useMove
	; here we need to omit stuff that's used with upper word aligned, because moveq destroys
	cmp.w	#0,d6		;d0
	beq		.noMoveQ
	cmp.w	#2,d6		;d1
	beq		.noMoveQ	
	cmp.w	#4,d6		;d2
	beq		.noMoveQ
.yesmoveq	
	lea		.moveqCode,a3
	add.w	d6,a3
	move.w	(a3)+,(a5)+
	lea		.drawCodeRegMove,a3
	jmp		.cont
.noMoveQ
	lea		.regCode,a3
	add.w	d6,a3
	add.w	d6,a3
	move.w	(a3)+,(a5)+
	move.w	d1,(a5)+
	lea		.drawCodeRegMove,a3	
.cont
	add.w	d6,a3
	add.w	d6,a3
	add.w	d6,a3
	move.w	(a3)+,d5			; preload opcode
	add.w	#2,d6
	cmp.w	#8*2,d6
	bne		.doCode
		move.w	#0,d6
.doCode
		move.w	d5,(a5)+		; move.w	dn,x(a0)
		move.w	(a2)+,d4
		move.w	d4,(a5)+	
		move.l	d4,(a6)+
	dbra	d7,.doCode
	jmp		.doMask
.once
	move.w	.drawCodeImmediate,(a5)+
	move.w	d1,(a5)+
	move.w	(a2)+,d4
	move.w	d4,(a5)+
	move.l	d4,(a6)+
	jmp		.doMask
.end

	; finish draw
	lea		.drawIter,a2
	REPT 	36/4
		move.l	(a2)+,(a5)+
	ENDR
	; finish cler
	lea		.clearIter,a2
	REPT	7
		move.w	(a2)+,(a6)+
	ENDR


	add.w	#4,.spriteCodeOff
	popall
	popd7
	dbra	d7,.doSprite

	rts






.spriteCodeOff	dc.w	0
.moveqCode
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#-1,d2
	moveq	#-1,d3
	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
.regCode
	move.w	#12345,d0			;4
	move.w	#12345,d1
	move.w	#12345,d2
	move.w	#12345,d3
	move.w	#12345,d4
	move.w	#12345,d5
	move.w	#12345,d6
	move.w	#12345,d7

.drawCodeRegOr
	or.w	d0,2(a0)				;4
	dc.w	0
	or.w	d1,2(a0)
	dc.w	0
	or.w	d2,2(a0)
	dc.w	0
	or.w	d3,2(a0)
	dc.w	0
	or.w	d4,2(a0)
	dc.w	0
	or.w	d5,2(a0)
	dc.w	0
	or.w	d6,2(a0)
	dc.w	0
	or.w	d7,2(a0)
	dc.w	0
.drawCodeRegMove
	move.w	d0,2(a0)				;4
	dc.w	0
	move.w	d1,2(a0)
	dc.w	0
	move.w	d2,2(a0)
	dc.w	0
	move.w	d3,2(a0)
	dc.w	0
	move.w	d4,2(a0)
	dc.w	0
	move.w	d5,2(a0)
	dc.w	0
	move.w	d6,2(a0)
	dc.w	0
	move.w	d7,2(a0)
	dc.w	0
.drawCodeImmediate
	move.w	#12345,2(a0)
.clearIter
	move.w	(a6)+,d1		;2					;
	move.l	d1,a0			;2
	move.w	(a6)+,d7		;2
	move.l	d7,a5			;2
	jmp		(a5)			;2
.clearIterExit
	rts						;2		;-> 14
.drawIter
	move.w	(a1)+,d0		;2
	blt		.drawIterExit	;2					; to remove this:		alter 2*nr_sprites(a1,a2,a3,a4) so that d2 becomes 16*256, for rts, and alter a0 with extra entry
	add.w	(a2)+,d0		;2	
	move.l	d0,a0			;2
	move.w	(a0)+,d1		;2
	move.w	(a0),d2			;2
	add.w	(a3)+,d1		;2
	add.w	(a4)+,d1		;2
	move.w	d1,(a6)+		;2
	move.w	d2,(a6)+		;2
	move.l	d1,a0			;2
	move.l	d2,a5			;2
	jmp		(a5)			;2
.drawIterExit
	move.w	#16*spriteCodeSize,(a6)+	;4
	move.w	#16*spriteCodeSize,(a6)+	;4
	rts						;2		;-> 36



clearTables
	pushd0
	pusha0
		lea		maskList,a0
		moveq	#0,d0
		REPT listSize/2+listSize/2
			move.l	d0,(a0)+
		ENDR
		moveq	#-1,d0
		REPT listSize*64/2
			move.l	d0,(a0)+
		ENDR
	popa0
	popd0
	rts






	section DATA

clearSpritesPointer				dc.l	cspr1
clearSpritesPointer2			dc.l	cspr2
xPositionPointer				dc.l	0
x1pointer						dc.l	0
x2pointer						dc.l	0
y2pointer						dc.l	0
y1pointer						dc.l	0
drawSpriteCodeBuffersPointer	dc.l	1
clearSpriteCodeBuffersPointer	dc.l	1



y1s						
	include "data/sprites/y1asource64.s"		;128
;	include "data/credits/y1asource64.s"		;128
y2s						
	include "data/sprites/y2asource512.s"	;1024
;	include "data/credits/y2asource512.s"	;1024
x1s						
	include "data/sprites/x1bsource273.s"	;546
;	include "data/credits/x1bsource273.s"	;546
x2s						
	include "data/sprites/x2bsource128.s"	;256
;	include "data/credits/x2bsource128.s"	;256

	
sine_x1_step_mask	equ		2048*2-1
sine_x1_step		dc.w	412	;788
sine_x2_step_mask	equ		128*2-1
sine_x2_step		dc.w	44
sine_y1_step_mask	equ		64*2-1
sine_y1_step		dc.w 	14
 
sine_y2_step		dc.w	92
sine_y2_step_mask	equ		512*2-1


		include	msx/musicplayer.s


sprites
	IF spriteSize=0
		incbin	'data/sprites/sprite16x16.neo'
	ENDC
	IF spriteSize=1
		incbin	'data/sprites/sprite32x32.neo'
	ENDC

    IFEQ    STANDALONE
        include     lib/lib.s
    ENDC

	section BSS

    rsreset

sprite0
	ds.w	spriteHeight*(spriteWidth+1)*4*16


cspr1	
		ds.b	400*2
cspr2	
		ds.b	400*2


maskList		ds.w	listSize				; list of masks
countList		ds.w	listSize				; list of counts
offsetList		ds.w	listSize*64			; list of offsets per mask

    IFEQ    STANDALONE
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
    ENDC