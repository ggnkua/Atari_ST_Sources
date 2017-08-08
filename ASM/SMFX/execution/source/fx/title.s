;; title screen
;
;	zync:
; ff = next scene
; 01 = flash
; 02 = title screen
; $4x = x number of snakes flash
; $5x = x number of snakes
;
; ; add cinema scope to borders when title screen flash
;
; todo:
;	-	add random function
;	- 	use random to do left/right
;	-	add code to draw pre-determined outline
;	-	use flag when done;
;
; lets have some snakes run over the screen; they appear at one pixel (corner case, previous pixel = -1)
; the snakes should produce the outline of the title screen, whereas other snakes would just do random background stuff
; a). random snakes (draw to bitplane 1)
; b). non-random snakes (draw to bitplane 2)
;
; initially same color, thus color 1 = color 2 = color 3
; 
; since we use double buffer, each frame draws 2 pixels:
;	- determine nexpos randomly and then:
;	- to draw = prevpos + next pos
; 4 archetype situations (p is prev, n is next):
; 1(up):	n		2(right):	p n		3(down):	p		4(left):	n p
;			p										n
; case 1 and 3 are trivial, since they are the same mask +-linewidth
; case 2 and 4 are nontrivial since they can lie within or not within the same word/bitplane, single operation of or.w apart from edges of the word
;
;
;	16 possibilities for current encoding (4 bits)
;	4 possibilities for next step (2 bits)
;	lookup table of 64 enties
;
;
;	ok:
;	- each snake has a pattern to draw
;	- vert, hor
;		- start/end is one pixel
;		- main is two pixels	
;	- each snake has a direction
;		- each frame, snake may go left or right, or keep course
;		- this is done by doing a random roll
;	- each snake has a number of steps it does before it dies
;	- so we have:
;		- a random seed of snakes:
;			- nr of steps left
;			- direction -> determines next step, NORTH, EAST, SOUTH, WEST
;			- current state	-> encodes pixel
;			- position	-> 200*20 positions
;
;	so we have:
;		- nr of steps left, if -1 then end
;		- nr of steps left, if 0, then no new `next pixel'
;		- for each step,
;			- old step = curstep
;			

snakeColor		equ	$222

title_code_size	equ 22
nr_of_snakes	equ 200
randmask		equ 64-2

	SECTION DATA
_randomSeed			dc.l	729251116678
_snakesInit		dc.w	0

	SECTION TEXT

init_title_screen

	sub.l	#64*160,screenpointer
	sub.l	#64*160,screenpointer2

	move.l	$134,tmp
	move.l	#music2,sndh_pointer
	jsr		initMusic
	move.l	tmp,$134

	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)



	move.w	#$2700,sr
	move.l	#default_vbl,$70
	move.w	#$2300,sr
	wait_for_vbl
	clr.b	$ffff820a.w				;60 Hz
	nop
	wait_for_vbl
	nop
	nop
	wait_for_vbl
	move.b	#2,$ffff820a.w			;50 Hz
	nop
	nop



	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#200-1,d7
	moveq	#0,d0

.loop1
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.w	d0,(a1)+
	ENDR
	dbra	d7,.loop1

	move.w	#$2700,sr
	move.l	#title_vbl,$70
	move.w	#$2300,sr

	move.w	#snakeColor,$ffff8240+2*2
	move.w	#snakeColor,$ffff8240+2*4
	move.w	#snakeColor,$ffff8240+2*6

	move.w	#$0,$ffff8240+2*8

	move.w	#snakeColor,$ffff8240+2*10
	move.w	#snakeColor,$ffff8240+2*12
	move.w	#snakeColor,$ffff8240+2*14

	; for rotozoom
	move.l	alignpointer3,c2plookuptablepointer
	move.l	alignpointer7,text1pointer
	move.l	alignpointer9,text2pointer

	move.l	#haxSpace,d0							;			--->>>> 
	move.l	d0,bssBuffer+x_off_and_mask_pointer
	add.l	#320*4,d0								;-1280
	move.l	d0,bssBuffer+y2pointer
	add.l	#1536*2,d0								;-3072
	move.l	d0,bssBuffer+y1pointer
	add.l	#512*2,d0								;-1024
	move.l	d0,bssBuffer+x1pointer
	add.l	#8*273*2,d0								;-4368
	move.l	d0,bssBuffer+x2pointer
	add.l	#9*128*2,d0								;-2304
	move.l	d0,bssBuffer+z1pointer
	add.l	#512*2,d0								;-1024
	move.l	d0,bssBuffer+advanceSpritesCodePointer				; 
	add.l	#4578,d0								;-4578		; ---> 17650
	move.l	d0,chunkytextpointer

	jsr		generateSineTables
	jsr		generateAdvanceSpritesCode


.mainloop
	wait_for_vbl
	jsr		doPrecalc
			exitOnSpace
	tst.w	hardcodedSceneTimer
	ble		.hehe
	jmp		.mainloop
.hehe
	rts

doPrecalc
	tst.w	_precalcDone
	bne		.done
	jsr		copyTitleBG
	jsr		generateC2PLookupTable

	; todo
	lea		planarpic,a0
	move.l	chunkytextpointer,a1
	jsr		planarToChunky					;10 frames
	; todo

	jsr		generateTextureTables
	jsr		copyRoto
	move.w	#-1,_precalcDone
.done
	rts

; 480 bytes
copyRoto
	lea		rotoz,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2

	add.l	#260*160,a1
	add.l	#260*160,a2
	add.l	#170*160,a1
	add.l	#170*160,a2

	add.l	#200*160,a1
	add.l	#200*160,a2
	add.l	#200*120,a0
	move.w	#200-1,d7
.l
	REPT 20
		move.l	-(a0),d0
		move.l	d0,-(a1)
		move.l	d0,-(a2)
		move.w	-(a0),d0
		move.w	d0,-(a1)
		move.w	d0,-(a2)
		sub.w	#2,a1
		sub.w	#2,a2
	ENDR
	dbra	d7,.l
	rts

title_vbl
	move.w	#0,$ffff8240
	pushall
	move.l 	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ff8200
	addq.w 	#1,$466.w

	jsr		doTitleScreen
	jsr		checkMusicTitle
	jsr		doFlash

	cmp.w	#4,_titleState
	bge		.noSnakes
		jsr		moveSnakes
		jsr		startSnake
.noSnakes
	jsr		paintOutline			; todo fix shit	in seperate parts and zync

	move.l	sndh_pointer,a0
	jsr		8(a0)

	subq.w	#1,hardcodedSceneTimer
	cmp.w	#1025,hardcodedSceneTimer
	bge		.kkk
		jsr		ping
.kkk

	move.l	screenpointer2,a0
	moveq	#0,d0
	REPT 20	
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
		swapscreens
	popall

	rte



ping
	tst.w	_ddd
	bne		.ttt
		move.w	#-1,_ddd
.ttt
	subq.w	#1,pingwaiter
	bne		.kk
		cmp.w	#15*32,pingoff
		beq		.kk
			move.w	#3,pingwaiter
			add.w	#32,pingoff
.kk
    move.w  #$2700,sr
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
	move.l	#btest,$120
    move.b  #1,$fffffa21.w
    bclr    #3,$fffffa17.w          ;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
    move.w	#$2300,sr

	subq.w	#1,thisColOffWaiter
	bgt		.kx
		move.w	#3,thisColOffWaiter
		add.w	#2,thisColOff
		cmp.w	#14,thisColOff
		ble		.kx
			move.w	#14,thisColOff
.kx

	lea		cinemaColorList,a0
	add.w	thisColOff,a0
	move.w	(a0),$ffff8240

	lea		pinglist,a0
	add.w	pingoff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	rts	



btest
	move.w	#$2700,sr
	move.w	#0,$ffff8240
    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#btestend,$120
	move.b  #199,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
	move.w	#$2300,sr
	rte

btestend
	move.w	#$2700,sr
	pusha0
	lea		cinemaColorList,a0
	add.w	thisColOff,a0
	move.w	(a0),$ffff8240
	popa0

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.w	#$2300,sr
	rte



pinglist
	incbin	fx/title/PING2.PAL
;	incbin	fx/title/PING.PAL
;	incbin	fx/title/emz2.PAL


title_border
	pushall
	moveq	#0,d0
	jsr		sscrl_setup_list		;Setup syncscroller combinations

	move.l 	screenpointer,d0
	add.l	sscrl_offset,d0			;Add syncscroller offset (scroll position)

	lsr.w	#8,d0
	move.l	d0,$ff8200							; put new screenpointer in effect

			screenswap
	addq.w	#1,$466

	move.w	#$2700,sr			;Stop all interrupts

	;Start up Timer A each VBL
	clr.b	$fffffa19.w			;Timer-A control (stop)
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer A)
	bset	#5,$fffffa13.w			;Interrupt mask A (Timer A)
	move.b	#94,$fffffa1f.w			;Timer A Delay (data)
	move.b	#4,$fffffa19.w			;Timer A Predivider (start Timer A)
	
	;Start up Timer B each VBL
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.l	#tbs,$120.w			;Install our own Timer B
	move.b	#28,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.w	#$2300,sr

	jsr		checkMusicTitle

	subq.w	#1,hardcodedSceneTimer
	jsr		ping

	move.l	#27,d7
.xxx
		add.l	d4,d4
	dbra	d7,.xxx
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popall
	rte

tbs:	
	move.w	#$2700,sr
	pushd0

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#tbs_bottom,$120
	move.b  #199,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus

	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

	move.w	#0,$ffff8240


	move.w	#$2300,sr
	popd0
	rte

tbs_bottom
	move.w	#$2700,sr
	move.w	cinemaColor,$ffff8240
	move.w	#$2300,sr
    rte


doTitleScreen
	tst.w	_doTitleScreen
	beq		.end
		lea		titleJump,a0
		add.w	_titleState,a0
		move.l	(a0),a0
		jmp		(a0)
.end
	rts

; here we dont have splits
palFadeIn
	lea		_titleScreenPal,a0
	add.w	_titleScreenPalOff,a0
	move.w	(a0),d0
	lea		$ffff8242,a0
	REPT 15
		move.w	d0,(a0)+
	ENDR
	subq.w	#1,_titleScreenPalWaiter
	bne		.nostep
		move.w	#5,_titleScreenPalWaiter
		subq.w	#2,_titleScreenPalOff
		bge		.nostep
			move.w	#0,_titleScreenPalOff
			add.w	#4,_titleState
			move.w	#7*16,_titleScreenPalOff
.nostep
	rts


_titleScreenPalNew
;	incbin	"fx/title/FADEIN.PAL"
;	incbin	"fx/title/FADEIN2.PAL"
	incbin	"fx/title/FADEIN3.PAL"

; here we have splits
palFadeOut
	lea		_titleScreenPalNew,a0
	add.w	_titleScreenPalOffNew,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	subq.w	#1,_titleScreenPalWaiter
	bne		.nostep
		move.w	#5,_titleScreenPalWaiter
		sub.w	#16*2,_titleScreenPalOffNew
		bge		.nostep
			move.w	#0,_titleScreenPalOffNew
.nostep
	rts


copyTitleBG
	lea		title_pic_bin,a0
	move.l	screenpointer2,a1
	move.l	screenpointer,a2
	move.w	#85-1,d7
	add.w	#56*160+6,a1
	add.w	#56*160+6,a2
.ol
x set 0
		REPT 20
			move.w	(a0)+,d0
			or.w	d0,x(a1)
			or.w	d0,x(a2)
			move.w	(a0)+,d0
			or.w	d0,x(a1)
			or.w	d0,x(a2)
			move.w	(a0)+,d0
			or.w	d0,x(a1)
			or.w	d0,x(a2)
			move.w	(a0)+,d0
			or.w	d0,x(a1)
			or.w	d0,x(a2)
x set x+8
		ENDR
	add.w	#160,a1
	add.w	#160,a2
	dbra	d7,.ol
	rts

copyTitleCounter	dc.w	2

copyTitlePic

	subq.w	#1,_titlePicCopyCount
	bne		.copyPic
		add.w	#4,_titleState
		rts
.copyPic
	subq.w	#1,copyTitleCounter
	blt		.doSecond
.doFirst


	move.l	screenpointer2,a0

	lea		title_pic_bin,a1
	add.w	#56*160,a0
	move.w	#43-1,d7
.dd
	move.l	a0,a3
x	set 6
	REPT 20
		move.w	x(a0),d0
		not.w	d0
		and.w	d0,(a3)+
		and.w	d0,(a3)+
		and.w	d0,(a3)+
		and.w	d0,(a3)+	
x set x+8	
	ENDR

	REPT 5
		movem.l	(a1)+,d0-d6		;7
		or.l	d0,(a0)+
		or.l	d1,(a0)+
		or.l	d2,(a0)+
		or.l	d3,(a0)+
		or.l	d4,(a0)+
		or.l	d5,(a0)+
		or.l	d6,(a0)+
	ENDR
		movem.l	(a1)+,d0-d4
		or.l	d0,(a0)+
		or.l	d1,(a0)+
		or.l	d2,(a0)+
		or.l	d3,(a0)+
		or.l	d4,(a0)+
	dbra	d7,.dd
	rts
.doSecond
	move.l	screenpointer2,a0
	add.w	#(56+43)*160,a0
	lea		title_pic_bin,a1
	add.w	#43*160,a1
	move.w	#42-1,d7
	jmp		.dd

checkMusicTitle
	moveq	#0,d0
	move.l	sndh_pointer,a0
	move.b	$b8(a0),d0
	beq		_xend
	blt		.nextscene
.positive
		move.b	#0,$b8(a0)
		cmp.w	#$40,d0
		ble		.normal
.morethan64
		cmp.w	#$50,d0
		bgt		.snakesnoflash
		beq		.derp
.snakeswithflash
			move.w	#14*2,flashoff
			sub.w	#$40,d0
			move.w	d0,_number_of_snakes
			rts
.snakesnoflash
			sub.w	#$50,d0
			move.w	d0,_number_of_snakes
			rts
.derp
	rts

;;;; normal 0....40 range
.normal
	cmp.w	#1,d0
	bne		.noflash
		move.w	#14*2,flashoff
		rts
.noflash
	cmp.w	#2,d0
	bne		.notitle
		move.w	#-1,_doTitleScreen
		rts
.notitle

	cmp.w	#3,d0
	bne		.nooutline
		addq.w	#1,_nrOutlineActive
		cmp.w	#4,_nrOutlineActive
		ble		.nooutline
			move.w	#4,_nrOutlineActive
.nooutline

	rts
;;;;;;; end normal
	
.nextscene
		move.w	#0,hardcodedSceneTimer
		move.b	#0,$b8(a0)
_xend
	rts


paintOutline
	move.w	_nrOutlineActive,d7
	beq		.end
	subq.w	#1,d7
	moveq	#0,d5
	lea		started,a6
	lea		firstpixs,a5
	lea		herpoffs,a4
.loop
	tst.w	(a6)+
	beq		.skipthis
		move.l	screenpointer2,a0
		add.l	sscrl_offset,a0
		add.w	#2,a0
		lea		pixdata,a1
		add.w	(a4)+,a1
		tst.w	(a5)+
		bne		.notfirst
			move.w	(a1)+,d0
			move.w	(a1)+,d1
			or.w	d1,(a0,d0.w)
			move.w	#-1,-2(a5)
			jmp		.last
.notfirst	
		move.w	(a1)+,d0
		blt		.last
			move.w	(a1)+,d1
			or.w	d1,(a0,d0.w)
			add.w	#4,-2(a4)
			move.w	(a1)+,d0
			blt		.last
		move.w	(a1)+,d1
		or.w	d1,(a0,d0.w)
.last
	dbra	d7,.loop
	rts

.skipthis
	add.w	#2,a5
	add.w	#2,a4
	dbra	d7,.loop
.end
	rts

doFlash
	tst.w	_doTitleScreen
	bne		.x
	lea		flash,a0
	add.w	flashoff,a0
	move.w	(a0),$ffff8240+2*2
	move.w	(a0),$ffff8240+2*4
	move.w	(a0),$ffff8240+2*10
	move.w	(a0),$ffff8240+2*12
	move.w	(a0),$ffff8240+2*14
	move.w	(a0)+,$ffff8240+2*6
	subq.w	#1,flashtimer
	bgt		.x
		sub.w	#2*2,flashoff
		bge		.x
			move.w	#0,flashoff
.x
	rts

startSnakePulseIntro
	tst.w	_spawnSnake
	beq		skipSnake
	move.w	#0,_spawnSnake
	move.w	_snakesInit,d5
	moveq	#0,d7
	jmp		startSnakePulse

startSnake
	move.w	_snakesInit,d5
	move.l	sndh_pointer,a0
	moveq	#0,d7
	move.w	_number_of_snakes,d7
	subq.w	#1,d7
	blt		skipSnake
	move.w	#0,_number_of_snakes
startSnakePulse
	move.l	screenpointer2,d6
	move.l	currentSnakePointer,a1
	lea		last,a2
	lea		.nextSnake,a3

.startSnake
	cmp.w	#nr_of_snakes,d5
	beq		skipSnake
	addq.w	#1,d5
	move.w	#1200,(a1)
	move.w	4(a1),d0			;encoding
	move.w	6(a1),d6			;offset
	move.l	d6,a0
	add.w	#4+32*160,a0
	jmp		(a2,d0.w)

.nextSnake
	add.w	#8,a1
	dbra	d7,.startSnake
	move.w	d5,_snakesInit
	move.l	a1,currentSnakePointer
skipSnake
	rts


; snakes at +4
; outline at 0
moveSnakes
	move.l	_randomSeed,d3
	rol.l	d3,d3
	addq.w	#5,d3

	move.w	#8,d4
	move.w	#160,d5
	move.l	screenpointer2,d6
	move.w	#nr_of_snakes-1,d7

	lea		snakes,a1
	lea		last,a2
	lea		.nextsnake,a3
	lea		randomActionList,a4
	lea		directionList,a6


.doSnake
	subq.w	#1,(a1)+
	blt		.skipmove
	bgt		.normalmove
.laststep

	; no random, just same direction
	move.w	2(a1),d1
	move.w	4(a1),d6
	move.l	d6,a0
	add.w	#4+32*160,a0
	add.l	sscrl_offset,a0
	add.w	#6,a1
	jmp		(a2,d1.w)

.normalmove
	tst.w	_doTitleScreen
	blt		.laststep

	move.w	(a1)+,d0		; get direction, this should be offset to N,E,S,W
	; determine if direction changes, can do +-4
	; do random d10
	; if 1-2 left
	; if 3-4 right
	; if 5-10 nothing
	addq.w	#5,d3
	move.w	d3,d1
	and.w	#randmask,d1
	add.w	(a4,d1.w),d0
	move.w	d0,-2(a1)

	move.l	(a6,d0.w),a5	; get pointer to start of the draw routine
	move.w	(a1)+,d1		; get position encoding, this needs to be a factor of x and has 16 entries/cases
	move.w	(a1)+,d6		; screen + offset
	move.l	d6,a0						;4				;2	; screen address
	add.w	#4+32*160,a0
	jmp		(a5,d1.w)

.skipmove
	add.w	#6,a1
.nextsnake
	dbra	d7,.doSnake			
	move.l	d3,_randomSeed
	rts													;2	--> 20

tablething
north
	;up 0
	or.w	#%1<<15,(a0)				;16				;4		; prev pixel
	or.w	#%1<<15,-160(a0)			;20				;6	; current pixel
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)										;2
;	rts													;---> 18s
	ds.b	4

	;up 1
	or.w	#%1<<14,(a0)
	or.w	#%1<<14,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 2
	or.w	#%1<<13,(a0)
	or.w	#%1<<13,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 3
	or.w	#%1<<12,(a0)
	or.w	#%1<<12,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 4
	or.w	#%1<<11,(a0)
	or.w	#%1<<11,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 5
	or.w	#%1<<10,(a0)
	or.w	#%1<<10,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 6
	or.w	#%1<<9,(a0)
	or.w	#%1<<9,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 7
	or.w	#%1<<8,(a0)
	or.w	#%1<<8,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 8
	or.w	#%1<<7,(a0)
	or.w	#%1<<7,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 9
	or.w	#%1<<6,(a0)
	or.w	#%1<<6,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 10
	or.w	#%1<<5,(a0)
	or.w	#%1<<5,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 11
	or.w	#%1<<4,(a0)
	or.w	#%1<<4,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 12
	or.w	#%1<<3,(a0)
	or.w	#%1<<3,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 13
	or.w	#%1<<2,(a0)
	or.w	#%1<<2,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 14
	or.w	#%1<<1,(a0)
	or.w	#%1<<1,-160(a0)
	sub.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

	;up 15
	or.w	#%1<<0,(a0)
	or.w	#%1<<0,-160(a0)
	sub.w	d5,d6						;4				;2	; 
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4

last
	;up 0
	or.w	#%1<<15,(a0)				;16				;4	; prev pixel
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 1
	or.w	#%1<<14,(a0)
	jmp		(a3)
;	rts													;2	--> 20
firstpixs				ds.w	4
tmp						ds.l	1
pingoff					ds.w	1
_ddd					ds.w	1
	ds.b	16-16

	;up 2
	or.w	#%1<<13,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 3
	or.w	#%1<<12,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 4
	or.w	#%1<<11,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 5
	or.w	#%1<<10,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 6
	or.w	#%1<<9,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 7
	or.w	#%1<<8,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 8
	or.w	#%1<<7,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 9
	or.w	#%1<<6,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 10
	or.w	#%1<<5,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 11
	or.w	#%1<<4,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 12
	or.w	#%1<<3,(a0)
	jmp		(a3)
;	rts													;2	--> 20

_precalcDone			ds.w	1
firstpix				ds.w	1
_titleState				ds.w	1
flashoff				ds.w	1
derp					ds.w	1
_nrOutlineActive		ds.w	1
_doTitleScreen			ds.w	1
_number_of_snakes		ds.w	1

	ds.b	16-16

	;up 13
	or.w	#%1<<2,(a0)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	16

	;up 14
	or.w	#%1<<1,(a0)
	jmp		(a3)
;	rts													;2	--> 20
titleJump
	dc.l	palFadeIn
	dc.l	copyTitlePic
	dc.l	palFadeOut	

	ds.b	16-12

	;up 15
	or.w	#%1<<0,(a0)
	jmp		(a3)
;	rts													;2	--> 20
_titleScreenPal
	dc.w	$777
	dc.w	$666
	dc.w	$555
	dc.w	$444
	dc.w	$333
	dc.w	snakeColor
currentSnakePointer	dc.l	snakes
	ds.b	16-16

west
	;left 0
	or.w	#%1<<15,(a0)				;				;4	; draw prev
	or.w	#%1,-8(a0)					;				;6	; draw cur
	subq.w	#8,-2(a1)					;				;4	; adjust offset
	move.w	#title_code_size*15,-4(a1)					;6	
	jmp		(a3)
;	rts													;2	--> 20
;	ds.b	10-10

	;left 1
	or.w	#%11<<14,(a0)				;				;4
	move.w	#title_code_size*0,-4(a1)	;				;6
	jmp		(a3)										;2
;	rts													
	ds.b	10

	;left 2
	or.w	#%11<<13,(a0)
	move.w	#title_code_size*1,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 3
	or.w	#%11<<12,(a0)
	move.w	#title_code_size*2,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 4
	or.w	#%11<<11,(a0)
	move.w	#title_code_size*3,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 5
	or.w	#%11<<10,(a0)
	move.w	#title_code_size*4,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 6
	or.w	#%11<<9,(a0)
	move.w	#title_code_size*5,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 7
	or.w	#%11<<8,(a0)
	move.w	#title_code_size*6,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 8
	or.w	#%11<<7,(a0)
	move.w	#title_code_size*7,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 9
	or.w	#%11<<6,(a0)
	move.w	#title_code_size*8,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 10
	or.w	#%11<<5,(a0)
	move.w	#title_code_size*9,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 11
	or.w	#%11<<4,(a0)
	move.w	#title_code_size*10,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 12
	or.w	#%11<<3,(a0)
	move.w	#title_code_size*11,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 13
	or.w	#%11<<2,(a0)
	move.w	#title_code_size*12,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 14
	or.w	#%11<<1,(a0)
	move.w	#title_code_size*13,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10

	;left 15
	or.w	#%11<<0,(a0)
	move.w	#title_code_size*14,-4(a1)
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10


south
	;down 0
	or.w	#%1<<15,(a0)				;16				;4
	or.w	#%1<<15,160(a0)			;20				;6
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 1
	or.w	#%1<<14,(a0)
	or.w	#%1<<14,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 2
	or.w	#%1<<13,(a0)
	or.w	#%1<<13,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 3
	or.w	#%1<<12,(a0)
	or.w	#%1<<12,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 4
	or.w	#%1<<11,(a0)
	or.w	#%1<<11,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 5
	or.w	#%1<<10,(a0)
	or.w	#%1<<10,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 6
	or.w	#%1<<9,(a0)
	or.w	#%1<<9,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 7
	or.w	#%1<<8,(a0)
	or.w	#%1<<8,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 8
	or.w	#%1<<7,(a0)
	or.w	#%1<<7,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 9
	or.w	#%1<<6,(a0)
	or.w	#%1<<6,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 10
	or.w	#%1<<5,(a0)
	or.w	#%1<<5,160(a0)
	add.w	d5,d6						;4				;2	; update current position		
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 11
	or.w	#%1<<4,(a0)
	or.w	#%1<<4,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 12
	or.w	#%1<<3,(a0)
	or.w	#%1<<3,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 13
	or.w	#%1<<2,(a0)
	or.w	#%1<<2,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 14
	or.w	#%1<<1,(a0)
	or.w	#%1<<1,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4
	;down 15
	or.w	#%1<<0,(a0)
	or.w	#%1<<0,160(a0)
	add.w	d5,d6						;4				;2	; update current position
	move.w	d6,-2(a1)					;12				;4	; update offset
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	4




east
	;right 0
	or.w	#%11<<14,(a0)						;4
	move.w	#title_code_size*1,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 1
	or.w	#%11<<13,(a0)						;4
	move.w	#title_code_size*2,-4(a1)			;6
	jmp		(a3)								;2
;	rts													;2	--> 20
	ds.b	10
	;right 2
	or.w	#%11<<12,(a0)
	move.w	#title_code_size*3,-4(a1)			;6
	jmp		(a3)
;	rts				
	ds.b	10
	;right 3
	or.w	#%11<<11,(a0)
	move.w	#title_code_size*4,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 4
	or.w	#%11<<10,(a0)
	move.w	#title_code_size*5,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 5
	or.w	#%11<<9,(a0)
	move.w	#title_code_size*6,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 6
	or.w	#%11<<8,(a0)
	move.w	#title_code_size*7,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 7
	or.w	#%11<<7,(a0)
	move.w	#title_code_size*8,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 8
	or.w	#%11<<6,(a0)
	move.w	#title_code_size*9,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 9
	or.w	#%11<<5,(a0)
	move.w	#title_code_size*10,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 10
	or.w	#%11<<4,(a0)
	move.w	#title_code_size*11,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
	ds.b	10
	;right 11
	or.w	#%11<<3,(a0)
	move.w	#title_code_size*12,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
herpoffs	
	dc.w	237*4
	dc.w	711*4
	dc.w	0
	dc.w	475*4
thisColOffWaiter	dc.w	3
	ds.b	10-10
	;right 12
	or.w	#%11<<2,(a0)
	move.w	#title_code_size*13,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
started
	dc.w	-1
	dc.w	-1
	dc.w	-1
	dc.w	-1
_titleScreenPalOffNew	dc.w	7*16*2

	ds.b	10-10
	;right 13
	or.w	#%11<<1,(a0)
	move.w	#title_code_size*14,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
_titleScreenPalWaiter	dc.w	5
_titlePicCopyCount		dc.w	5
thisColOff				ds.w	1
pingwaiter				dc.w	1

	ds.b	10-8
	;right 14
	or.w	#%11<<0,(a0)
	move.w	#title_code_size*15,-4(a1)			;6
	jmp		(a3)
;	rts													;2	--> 20
;	ds.b	10
_titleBGDone			dc.w	2
delay					dc.w	5
hardcodedSceneTimer		dc.w	3040
flashtimer				dc.w	4
_titleScreenPalOff		dc.w	10
	;right 15
	or.w	#%1,(a0)			;4
	or.w	#%1<<15,8(a0)		;6
	move.w	#0,-4(a1)			;6
	addq.w	#8,-2(a1)			;4
	jmp		(a3)				;2
;	rts													;2	--> 20
;	ds.b	10-10


	SECTION DATA

;format; steps/active,direction,position in bitplane,screenoffset
; todo, remove inactive, saveds
snakes		include		"fx/title/testlines2.s"											;800b

randomActionList		; 16 entries, 8 nothing, 4 left, 4 right
	dc.w	0	;4
	dc.w	0
	dc.w	0
	dc.w	0	;-4
	dc.w	-4
	dc.w	0
	dc.w	0	;-4
	dc.w	0
	dc.w	0
	dc.w	4
	dc.w	0;	4
	dc.w	0;	-4
	dc.w	0
	dc.w	0;	4
	dc.w	0
	dc.w	0
	dc.w	0	;4
	dc.w	0
	dc.w	0
	dc.w	0	;-4
	dc.w	0
	dc.w	0	;4
	dc.w	0	;-4
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0;	4
	dc.w	0;	-4
	dc.w	0;	-4
	dc.w	0;	4
	dc.w	0
	dc.w	0
	rept 32
		dc.w	0
	endr							; 64*2 = 128 bytes

flash	
	dc.w	snakeColor,snakeColor
	dc.w	$333,$334
	dc.w	$444,$445
	dc.w	$555,$556
	dc.w	$666,$667
	dc.w	$555,$556
	dc.w	$444,$445
	dc.w	$333,$334

	REPT 6
	dc.l	north
	dc.l	east
	dc.l	south
	dc.l	west
	dc.l	north
	dc.l	east
	dc.l	south
	dc.l	west
	ENDR
directionList
	REPT 6
	dc.l	north
	dc.l	east
	dc.l	south
	dc.l	west
	dc.l	north
	dc.l	east
	dc.l	south
	dc.l	west
	ENDR						; 320 bytes


title_pic_bin		incbin	"fx/title/title8.bin"		;13600 -> 8470 	-5
pixdata				include	"fx/title/outline3.s"		;4 kb pixdata
	dc.w	-1,-1
	ds.b	16

	SECTION BSS
; all needed bss are neatly hidden....
