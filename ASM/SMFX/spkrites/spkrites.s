; 268 balls sprite record by spkr
; 2018-09-03
;
; - needs to be written to 27000+1024 in memory and run from bootdisk (most probably)
; - uses a precalced data stream to:
; 1. clear sprites each frame, based on whats tained by 2 frames ago (double buffering)
; 2. move sprites into the screen each frame, based on analysis of the sprite wave and the 2 frames before to maximize coverage (~612 move.l on avg)
; 3. or sprites into the screen to fill up the remainder of the 268 sprites
;
; the code is not synced to the vbl, so it drifts, however, over 360 frames it stays exactly the same
;
; concepts used:
; - sprite drawing code (move and or) are organized by x-position (0..15), so registers can be read once and written many times
; - delta packing the ym dump, to reduce data packed
; - clear code resides in lower memory, so that the saved data stream is smaller
; - move code uses pc relative jumps with indirect offset to make data stream smaller (this could be replaced with add.w from data stream to make it slightly faster)
; - orging the whole binary so it could be loaded from disk into ram
; 
; approach used:
; - (offline) generate and test individual frame solutions for optimal move patterns of sprites, based on random generation and sprite collision detection
; - use subsequent data to generate the clear, move and or data sets
; - generate the sprite drawing code data, and then manually optimize it over the 16 drawing methods by reusing existing values over multiple sprites
;
;
; scrolltext:
;	YEEEHAWW! ITS ANOTHER SPRITE RECORD DEMO! THIS TIME ITS SPKR OF SMFX BRINGING YOU TWICE THE BALLS THE CAREBEARS DID IN THEIR SOWHATT DEMO!
;	TOMCHI IS ROCKING THE CHIPSOUND WITH HIS TAKE ON MADMAX'S SOS ORIGINAL. REAL CODERS MAKE SPRITE RECORD DEMOS. SO TELL ME GUYS... WHERE IS YOURS?
;	VISIT SMFX.ST FOR A COMPLETE RUNDOWN OF HOW THIS DEMO WAS MADE.


USE_YM		equ	0
YM_DELTA	equ 0
genScroller	equ 1
showRasters	equ 1


loop_sprites0	equ  20
loop_sprites1	equ	 25
loop_sprites2	equ	 25
loop_sprites3	equ	 23
loop_sprites4	equ	 26
loop_sprites5	equ	 26
loop_sprites6	equ	 24
loop_sprites7	equ	 24
loop_sprites8	equ	 28
loop_sprites9	equ	 24
loop_sprites10	equ  23
loop_sprites11	equ  25	;11 and 12 are same, so make this 28
loop_sprites12	equ  28
loop_sprites13	equ  25
loop_sprites14	equ  25
loop_sprites15	equ  24

mloop_sprites0	equ  10
mloop_sprites1	equ  9
mloop_sprites2	equ  8
mloop_sprites3	equ  8
mloop_sprites4	equ  8
mloop_sprites5	equ  9
mloop_sprites6	equ  8
mloop_sprites7	equ  9
mloop_sprites8	equ  9
mloop_sprites9	equ  10
mloop_sprites10	equ  8
mloop_sprites11	equ  11; 11 and 12 are same, so make this 28
mloop_sprites12	equ  7
mloop_sprites13	equ  7
mloop_sprites14	equ  9
mloop_sprites15	equ  8



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
	org	1024+27000+28

	include macro.s
;	opt o-

	IFEQ	STANDALONE
        move.l	#stack+1000,a7
        pea     demostart
        move.w  #$26,-(sp)
        trap    #14
        addq.l  #6,sp
    
        clr.w   -(sp)
        trap    #1   
demostart
    jsr     saveAndKillTimers                                   ; kill timers and save them
    jsr     checkMachineTypeAndSetStuff                         ; check machine type, disable cache
    jsr     backupPalAndScrMemAndResolutionAndSetLowRes         ; save screen address and other display properties
    jmp		standalone_init

copyTiles
	lea		tilebuff,a2
	move.l	screenpointer,d6
	move.l	screenpointer2,d7
	add.l	#800,d6
	add.l	#800,d7
.oloop
	move.l	d6,a0
	move.l	d7,a1
	movem.l	(a2)+,d0-d4/a3/a4/a5
	move.w	#6-1,d5
.tx set 0
.loop
	REPT 5
		movem.l	d0-d4/a3/a4/a5,.tx(a0)			;4*8 = 32
		movem.l	d0-d4/a3/a4/a5,.tx(a1)
.tx	set .tx+32
	ENDR
	add.w	#32*160,a0
	add.w	#32*160,a1
	dbra	d5,.loop
	add.l	#160,d6
	add.l	#160,d7
	subq.w	#1,.times
	bge		.oloop
	rts
.times	dc.w	15

standalone_init
	jsr		init_effect
.x
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;
	rts
	ENDC
;	org	1024+27000
init_effect
	lea		memBase,a0
	move.l	#(32000*2+256)/4/4/4-1,d7
	moveq	#0,d0
.xd		
	REPT 16
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.xd
	move.l	#memBase+256,d0
	sub.b	d0,d0
	move.l	d0,screenpointer
	add.l	#32000,d0
	move.l	d0,screenpointer2

	jsr		copyTiles



;	move.w	#$111,$ffff8240		;bg
;
;	move.w	#$554,$ffff8240+2*1	;scroller
;	move.w	#$554,$ffff8240+2*8	;scroller
;	move.w	#$332,$ffff8240+2*9	;scroller
;
;	move.w	#$300,$ffff8240+2*2
;	move.w	#$300,$ffff8240+2*3
;	move.w	#$300,$ffff8240+2*10
;	move.w	#$300,$ffff8240+2*11
;
;	move.w	#$533,$ffff8240+2*4
;	move.w	#$533,$ffff8240+2*5
;	move.w	#$533,$ffff8240+2*12
;	move.w	#$533,$ffff8240+2*13
;
;	move.w	#$755,$ffff8240+2*6
;	move.w	#$755,$ffff8240+2*7
;	move.w	#$755,$ffff8240+2*14
;	move.w	#$755,$ffff8240+2*15


	move.w	#$776,$ffff8240		;bg

	move.w	#$741,$ffff8240+2*1	;scroller
	move.w	#$741,$ffff8240+2*8	;scroller
	move.w	#$731,$ffff8240+2*9	;scroller

	move.w	#$433,$ffff8240+2*2
	move.w	#$433,$ffff8240+2*3
	move.w	#$433,$ffff8240+2*10
	move.w	#$433,$ffff8240+2*11

	move.w	#$555,$ffff8240+2*4
	move.w	#$555,$ffff8240+2*5
	move.w	#$555,$ffff8240+2*12
	move.w	#$555,$ffff8240+2*13

	move.w	#$777,$ffff8240+2*6
	move.w	#$777,$ffff8240+2*7
	move.w	#$777,$ffff8240+2*14
	move.w	#$777,$ffff8240+2*15

	lea		$ffff8240,a0
	REPT 16
;		move.w	#$111,(a0)+
	ENDR

    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr
    IFEQ	genScroller
	    jsr		prepScroll
	ENDC
   	jsr		genClearCode

    IFNE	USE_YM
    	moveq	#1,d0
    	jsr		sos
    ENDC


    move.w  #0,vblcount
.w  tst.w   vblcount
    beq     .w
    	move.w	#0,vblcount


    move.w	#$2700,sr
    move.l	#effect_vbl,$70
    move.w	#$2300,sr

    move.w	#11000-1900+20,d7
.ww
	nop
	dbra	d7,.ww
.x
			jsr		mainRout

		move.w	#0,vblcount
		jmp		.x


	rts  
.vblwaiter	dc.w	20

.wvbl
    addq.w  #1,vblcount
    rte

vblcount	ds.w	1
frameListOff	dc.w	0*4


effect_vbl
	IFEQ	showRasters
    move.w  #$0,$ffff8240.w			;4
    ELSE
    	REPT 4
    		nop
    	ENDR
    ENDC	

    addq.w	#1,vblcount
    pushall
;   	movem.l	d1/a4/a1/a2/a3,-(sp)
	move.l	screenpointer2,d1
	lsr.w	#8,d1
	move.l	d1,$ffff8200

	IFEQ	USE_YM
		IFNE	YM_DELTA
		lea		songposition,a2			;8
		move.l	(a2),a3					;12
		lea		$ffff8800.w,a4			;8
		lea		$ffff8802.w,a1			;8		-> 36
.x set 0
		REPT 13
			move.b	#.x,(a4)			;16
			move.b	(a3)+,(a1)			;16		-> 13*32 = 416		--> 416 + 36 = 452
.x set .x+1
		ENDR
			move.b	(a3)+,d1			;8			
			blt		.skip				;8/12
				move.b	#.x,(a4)		;16
				move.b	d1,(a1)			;8
.skip
		move.l	a3,(a2)					;12		--> 464 + 20 = 484 branch											not use 13
										;		--> 464 + 40 = 504				-20 frames when not doing last		use13
		or.l	d7,d7
		or.l	d7,d7

		ELSE
	lea		songposition,a2				;8		
	move.l	(a2),a0						;12
    lea     $ffff8800.w,a4				;8
    lea     $ffff8802.w,a1				;8		-> 36

    moveq   #0,d0						;4
    move.b  (a0)+,d0					;8
    jmp     .loop(pc,d0.w)				;16		-> 28
.loop
        REPT 14
            move.b  (a0)+,(a4)          ;16		56
            move.b  (a0)+,(a1)          ;16 	-> 14*32 = 448
        ENDR
.skip	
    move.l  a0,(a2)						;12		--> 12+448+28+36 = 524 worst case

    ; and now we pad all the shit so we know its the same duration as the previous code... bye bye cycles ;)
    cmp.b	#13,-2(a0)					;16			
    bne		.noreg13					;8/12
    	nop
    	rept 5
    		nop
    	endr

.noreg13
	
    ; now I should make up for missed iterations
    ; 6 nops per iter
    add.w	d0,d0			;4
    neg.w	d0				;4
    jmp		.fix(pc,d0)		;16		-> 	24 to make up			=> 548+28 576 596 stable now

    REPT 14
    	or.l	d7,d7			;6*14 = 84
    	or.l	d7,d7
    	or.l	d7,d7
    	or.l	d7,d7
    ENDR
.fix
    	ENDC
		popall
	subq.w	#1,frames
	beq		.restart
	rte
.restart
		move.w	#50*80+32,frames
		move.l	#music,songposition
	rte
songposition	dc.l	music
frames			dc.w	50*80+32

	ELSE
		jsr		sos+8
		popall
	rte
	ENDC


mainRout	
	move.l	screenpointer2,a0
	addq.w	#2,a0
	move.l	a0,usp
	moveq	#0,d0

	lea		frameListClear,a6
	add.w	frameListOff,a6
	move.l	(a6),a6
	move.w	(a6)+,a5
	jsr		(a5)

	IFEQ	USE_YM
	REPT 103-9	;
		nop
	ENDR
	ENDC

	 move.l	usp,a0
	movem.l	.sprite0Regs,d0-d6
	move.w	(a6)+,a5
	jmp		sprite0move_new(pc,a5)
.sprite0Regs
	dc.l	$07E00000		;	$0,$960			.w		0,15				movem.w	(a0)+,d0-d3		28
	dc.l	$1FF80000		;	$a0,$8c0		.w		1,14				movem.l	(a0)+,d4-d6		36	--> 64
	dc.l	$3FFC0000		;	$140,$820		.w		2,13
	dc.l	$7FFE0000		;	$1e0,$780		.w		3,12				
	dc.l	$63FE1C00	;	$280,$6e0		.l		4,11
	dc.l	$C1FF3E00	;	$320,$640		.l		5,10
	dc.l	$B8FF7F00	;	$3c0,$460,$500,$5a0	.l	6,7,8,9


;---------------- move sprites 0 ----------
;---------------- move sprites 0 ----------
;---------------- move sprites 0 ----------
;---------------- move sprites 0 ----------
sprite0move_new
	REPT 	mloop_sprites0
		add.w	(a6)+,a0			;2
		move.l	d0,(a0)				;2
		move.l	d0,$960(a0)			;4
		move.l	d1,$a0(a0)			;4
		move.l	d1,$8c0(a0)			;4
		move.l	d2,$140(a0)			;4
		move.l	d2,$820(a0)			;4
		move.l	d3,$1e0(a0)			;4
		move.l	d3,$780(a0)			;4
		move.l	d4,$280(a0)			;4
		move.l	d4,$6e0(a0)			;4
		move.l	d5,$320(a0)			;4
		move.l	d5,$640(a0)			;4
		move.l	d6,$3c0(a0)			;4
		move.l	d6,$460(a0)			;4
		move.l	d6,$500(a0)			;4
		move.l	d6,$5a0(a0)			;4			--> 16*4 = 64 size
	ENDR
sprite0move
drawStart1
	movem.l	.sprite1Regs,d0-d6/a1
	move.w	(a6)+,a5
	jmp		sprite1move_new(pc,a5)
.sprite1Regs
	dc.l	$03F00000		;	$0,$960			.w							d0
	dc.l	$0FFC0000		;	$a0,$8c0		.w							d1
	dc.l	$1FFE0000		;	$140,$820		.w							d2
	dc.l	$3FFF0000		;	$1e0,$780		.w							d3
	dc.l	$31FF0E00		;	$280,$6e0		.l							d4
	dc.l	$60FF1F00		;	$320,$640		.l							d5
	dc.l	$5C7F3F80		;	$3c0,$460,$500,$5a0	.l						d6
	dc.l	$80000000		;	$328,$3c8,$468,$508,$5a8,$648				a1
drawStart0
	movem.l	.sprite0Regs,d0-d6
	move.l	(a6)+,a5
	jmp		(a5)
.sprite0Regs
	dc.l	$07E00000		;	$0,$960			.w		0,15				movem.w	(a0)+,d0-d3		28
	dc.l	$1FF80000		;	$a0,$8c0		.w		1,14				movem.l	(a0)+,d4-d6		36	--> 64
	dc.l	$3FFC0000		;	$140,$820		.w		2,13
	dc.l	$7FFE0000		;	$1e0,$780		.w		3,12				
	dc.l	$63FE1C00	;	$280,$6e0		.l		4,11
	dc.l	$C1FF3E00	;	$320,$640		.l		5,10
	dc.l	$B8FF7F00	;	$3c0,$460,$500,$5a0	.l	6,7,8,9
;---------------- move sprites 1 ----------
;---------------- move sprites 1 ----------
;---------------- move sprites 1 ----------
;---------------- move sprites 1 ----------
sprite1move_new
	REPT mloop_sprites1
		add.w	(a6)+,a0			;2
		move.l	d0,(a0)				;2
		move.l	d0,$960(a0)			;4
		move.l	d1,$a0(a0)			;4
		move.l	d1,$8c0(a0)			;4
		move.l	d2,$140(a0)			;4
		move.l	d2,$820(a0)			;4
		move.l	d3,$1e0(a0)			;4
		move.l	d3,$780(a0)			;4
		move.l	a1,$328(a0)			;4
		move.l	a1,$3c8(a0)			;4
		move.l	a1,$468(a0)			;4
		move.l	a1,$508(a0)			;4
		move.l	a1,$5a8(a0)			;4
		move.l	a1,$648(a0)			;4
		move.l	d4,$280(a0)			;4
		move.l	d4,$6e0(a0)			;4
		move.l	d5,$320(a0)			;4
		move.l	d5,$640(a0)			;4
		move.l	d6,$3c0(a0)			;4
		move.l	d6,$460(a0)			;4
		move.l	d6,$500(a0)			;4
		move.l	d6,$5a0(a0)			;4		22*4 = 88 size	
	ENDR
sprite1move
drawStart2
	movem.l	.sprite2Regs,d0-d6/a2
	move.w	(a6)+,a5
	jmp		sprite2move_new(pc,a5)
.sprite2Regs
	dc.l	$01F80000		;	0,$960							d0
	dc.l	$07FE0000		;	$a0,$8c0						d1
	dc.l	$0FFF0000		;	$140,$820						d2
	dc.l	$1FFF0000		;	$1e0,$780						d3
	dc.l	$18FF0700		;	$280,$6e0						d4
	dc.l	$307F0F80		;	$320,$640						d5
	dc.l	$2E3F1FC0		;	$3c0,$460,$500,$5a0				d6
;	dc.l	$80000000		;	$1e8,$288,$6e8,$788				a1	-		or.b	d5
	dc.l	$C0000000		;	$328,$3c8,$468,$508,$5a8,$648	a2	-		or.b	d6
;set:
;	dc.l	$80000000		;	$1e8,$288,$6e8,$788				a1	-		or.b	d5
;---------------- move sprites 2 ----------
;---------------- move sprites 2 ----------
;---------------- move sprites 2 ----------
;---------------- move sprites 2 ----------
sprite2move_new
	REPT mloop_sprites2
		add.w	(a6)+,a0			;2
		move.l	d0,(a0)				;2
		move.l	d0,$960(a0)			;4
		move.l	d1,$a0(a0)			;4
		move.l	d1,$8c0(a0)			;4
		move.l	d2,$140(a0)			;4
		move.l	d2,$820(a0)			;4
		move.l	d3,$1e0(a0)			;4
		move.l	d3,$780(a0)			;4	
		move.l	a1,$1e8(a0)	
		move.l	a1,$288(a0)	
		move.l	a1,$6e8(a0)	
		move.l	a1,$788(a0)	
		move.l	a2,$328(a0)
		move.l	a2,$3c8(a0)
		move.l	a2,$468(a0)
		move.l	a2,$508(a0)
		move.l	a2,$5a8(a0)
		move.l	a2,$648(a0)
		move.l	d4,$280(a0)
		move.l	d4,$6e0(a0)
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	d6,$3c0(a0)
		move.l	d6,$460(a0)
		move.l	d6,$500(a0)
		move.l	d6,$5a0(a0)			;26*4 = 104
	ENDR
sprite2move
drawStart3
	movem.l	.sprite3Regs,d0-d1/d3-d6/a3
	move.w	(a6)+,a5
	jmp		sprite3move_new(pc,a5)
.sprite3Regs
	dc.l	$00FC0000		;0/960						d0
	dc.l	$0C7F0380		;280/6e0					d1
;	dc.l	$0FFF0000		;1e0/780					d2

	dc.l	$03FF0000		;a0/8c0						d3
	dc.l	$07FF0000		;140/820					d4

	dc.l	$183F07C0		;320/640					d5
	dc.l	$171F0FE0		;3c0/460/500/5a0			d6
;	dc.l	$80000000		;148/828					a1			or.b	d4	a1
	dc.l	$E0000000		;328/3c8/468/508/5a8/648	a3			or.b	d6	a3
;set:
;	dc.l	$0FFF0000		;	$140,$820						d2
;	dc.l	$80000000		;$1e8,$288,$6e8,$788		a1	-		or.b	d5
;	dc.l	$C0000000		;1e8,288,6e8,788			a2			or.b	d5	a2
;---------------- move sprites 3 ----------
;---------------- move sprites 3 ----------
;---------------- move sprites 3 ----------
;---------------- move sprites 3 ----------
sprite3move_new
	REPT mloop_sprites3
		add.w	(a6)+,a0			;2
		move.l	d0,(a0)				;2
		move.l	d0,$960(a0)			;4
		move.l	d3,$a0(a0)			;4
		move.l	d3,$8c0(a0)			;4
		move.l	d4,$140(a0)			;4
		move.l	d4,$820(a0)			;4
		move.l	a1,$148(a0)
		move.l	a1,$828(a0)
		move.l	d2,$1e0(a0)
		move.l	d2,$780(a0)
		move.l	a2,$1e8(a0)			;
		move.l	a2,$288(a0)
		move.l	a2,$6e8(a0)
		move.l	a2,$788(a0)
		move.l	a3,$328(a0)
		move.l	a3,$3c8(a0)
		move.l	a3,$468(a0)
		move.l	a3,$508(a0)
		move.l	a3,$5a8(a0)
		move.l	a3,$648(a0)
		move.l	d1,$280(a0)
		move.l	d1,$6e0(a0)
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	d6,$3c0(a0)
		move.l	d6,$460(a0)
		move.l	d6,$500(a0)
		move.l	d6,$5a0(a0)			; 28
	ENDR
sprite3move
drawStart4
	movem.l	.sprite4Regs,d0-d1/d5-d7/a4
	move.w	(a6)+,a5
	jmp		sprite4move_new(pc,a5)
.sprite4Regs
	dc.l	$007E0000		;0/960							d0
	dc.l	$01FF0000		;a0/8c0							d1
;	dc.l	$80000000		;a8/8c8							d2	--> a1
;	dc.l	$03FF0000		;140/820						d3
;	dc.l	$07FF0000		;1e0/780						d4
	dc.l	$0C1F03E0		;320/640						d5
	dc.l	$0B8F07F0		;3c0/460/500/5a0				d6
	dc.l	$063F01C0		;280/6e0						d7
;	dc.l	$C0000000		;148/828						a1		or.b	d7	--> a2
;	dc.l	$E0000000		;1e8,288,6e8,788				a2		or.b	d5	--> a3
	dc.l	$F0000000		;328/3c8/468/508/5a8/648		a3		or.b	d6	--> a4
;set:
;	dc.l	$03FF0000		;a0/8c0						d3
;	dc.l	$07FF0000		;140/820					d4
;	dc.l	$80000000		;$1e8,$288,$6e8,$788		a1	
;	dc.l	$C0000000		;1e8,288,6e8,788			a2	
;	dc.l	$E0000000		;328/3c8/468/508/5a8/648	a3	
;---------------- move sprites 4 ----------
;---------------- move sprites 4 ----------
;---------------- move sprites 4 ----------
;---------------- move sprites 4 ----------
sprite4move_new
	REPT mloop_sprites4
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	d1,$a0(a0)
		move.l	d1,$8c0(a0)
		move.l	a1,$a8(a0)
		move.l	a1,$8c8(a0)
		move.l	d3,$140(a0)
		move.l	d3,$820(a0)
		move.l	a2,$148(a0)
		move.l	a2,$828(a0)
		move.l	d4,$1e0(a0)
		move.l	d4,$780(a0)
		move.l	a3,$1e8(a0)
		move.l	a3,$288(a0)
		move.l	a3,$6e8(a0)
		move.l	a3,$788(a0)
		move.l	a4,$328(a0)
		move.l	a4,$3c8(a0)
		move.l	a4,$468(a0)
		move.l	a4,$508(a0)
		move.l	a4,$5a8(a0)
		move.l	a4,$648(a0)
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	d6,$3c0(a0)
		move.l	d6,$460(a0)
		move.l	d6,$500(a0)
		move.l	d6,$5a0(a0)
		move.l	d7,$280(a0)
		move.l	d7,$6e0(a0)
	ENDR
sprite4move
drawStart5
	movem.l	.sprite5Regs,d0/d2/d5/d6/d7/a1
	move.w	(a6)+,a5
	jmp		sprite5move_new(pc,a5)
.sprite5Regs
	dc.l	$003F0000		;0/960							d0
;	dc.l	$01FF0000		;140/820						d1
	dc.l	$F8000000		;328/3c8/468/508/5a8/648		d2		
;	dc.l	$03FF0000		;1e0/780						d3
;	dc.l	$07FF0000		;140/820						d4
	dc.l	$060F01F0	;320/640							d5
	dc.l	$05C703F8	;3c0/460/500/5a0					d6
	dc.l	$031F00E0	;280/6e0							d7
	dc.l	$00FF0000		;a0/8c0							a1		
;	dc.l	$C0000000		;a8/8c8							a2		
;	dc.l	$E0000000		;148/828						a3			
;	dc.l	$F0000000		;1e8,288,6e8,788				a4		
;set:
;	dc.l	$01FF0000		;a0/8c0						d1
;	dc.l	$03FF0000		;a0/8c0						d3
;	dc.l	$07FF0000		;140/820					d4
;	dc.l	$80000000		;$1e8,$288,$6e8,$788		a1	
;	dc.l	$C0000000		;1e8,288,6e8,788			a2	
;	dc.l	$E0000000		;328/3c8/468/508/5a8/648	a3	
;	dc.l	$F0000000		;328/3c8/468/508/5a8/648	a4	
;---------------- move sprites 5 ----------
;---------------- move sprites 5 ----------
;---------------- move sprites 5 ----------
;---------------- move sprites 5 ----------
sprite5move_new
	REPT mloop_sprites5
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	a1,$a1-1(a0)
		move.l	a1,$8c1-1(a0)	
		move.l	a2,$a8(a0)
		move.l	a2,$8c8(a0)
		move.l	d1,$140(a0)
		move.l	d1,$820(a0)
		move.l	a3,$148(a0)
		move.l	a3,$828(a0)	
		move.l	d3,$1e0(a0)
		move.l	d3,$780(a0)
		move.l	a4,$1e8(a0)
		move.l	a4,$288(a0)
		move.l	a4,$6e8(a0)
		move.l	a4,$788(a0)
		move.l	d2,$328(a0)
		move.l	d2,$3c8(a0)
		move.l	d2,$468(a0)
		move.l	d2,$508(a0)
		move.l	d2,$5a8(a0)
		move.l	d2,$648(a0)
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	d6,$3c0(a0)
		move.l	d6,$460(a0)
		move.l	d6,$500(a0)
		move.l	d6,$5a0(a0)
		move.l	d7,$280(a0)
		move.l	d7,$6e0(a0)
	ENDR
sprite5move
drawStart6
	movem.l	.sprite6Regs,d0/d3/d4/d5/d6/d7/a2
	move.w	(a6)+,a5
	jmp		sprite6move_new(pc,a5)
.sprite6Regs
	dc.l	$001F0000		;0/960							d0
;	dc.l	$01FF0000		;1e0/780						d1	
;	dc.l	$F8000000		;1e8/288/6e8/788				d2	
	dc.l	$80000000		;								d3	
	dc.l	$007F0000		;a0/8c0							d4
	dc.l	$030700F8		;320/640						d5
	dc.l	$02E301FC		;3c0/460/500/5a0				d6
	dc.l	$018F0070		;280/6e0						d7
;	dc.l	$00FF0000		;140/820						a1	
	dc.l	$FC000000		;328/3c8/468/508/5a8/648		a2
;	dc.l	$E0000000		;a8/8c8							a3	
;	dc.l	$F0000000		;148/828						a4	
;set
;	dc.l	$01FF0000		;a0/8c0						d1
;	dc.l	$F8000000		;1e8/288/6e8/788			d2	
;	dc.l	$03FF0000		;a0/8c0						d3
;	dc.l	$07FF0000		;140/820					d4
;	dc.l	$00FF0000		;a0/8c0						a1		
;	dc.l	$C0000000		;1e8,288,6e8,788			a2	
;	dc.l	$E0000000		;328/3c8/468/508/5a8/648	a3	
;	dc.l	$F0000000		;328/3c8/468/508/5a8/648	a4
;---------------- move sprites 6 ----------
;---------------- move sprites 6 ----------
;---------------- move sprites 6 ----------
;---------------- move sprites 6 ----------
sprite6move_new
	REPT mloop_sprites6
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	d3,$8(a0)
		move.l	d3,$968(a0)
		move.l	d4,$a0(a0)
		move.l	d4,$8c0(a0)
		move.l	a3,$a8(a0)
		move.l	a3,$8c8(a0)
		move.l	a1,$141-1(a0)
		move.l	a1,$821-1(a0)
		move.l	a4,$148(a0)
		move.l	a4,$828(a0)
		move.l	d1,$1e0(a0)
		move.l	d1,$780(a0)
		move.l	d2,$1e8(a0)
		move.l	d2,$288(a0)
		move.l	d2,$6e8(a0)
		move.l	d2,$788(a0)
		move.l	a2,$328(a0)
		move.l	a2,$3c8(a0)
		move.l	a2,$468(a0)
		move.l	a2,$508(a0)
		move.l	a2,$5a8(a0)
		move.l	a2,$648(a0)	
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	d6,$3c0(a0)
		move.l	d6,$460(a0)
		move.l	d6,$500(a0)
		move.l	d6,$5a0(a0)
		move.l	d7,$280(a0)
		move.l	d7,$6e0(a0)
	ENDR
sprite6move
drawStart7
	movem.l	.sprite7Regs,d0/d1/d3/d5/d6/d7/a3
	move.w	(a6)+,a5
	jmp		sprite7move_new(pc,a5)
.sprite7Regs
	dc.l	$000F0000		;0/960							d0
	dc.l	$C0000000		;8/968							d1
;	dc.l	$F8000000		;148/828						d2	
	dc.l	$017100FE		;3c0/460/500/5a0				d3
;	dc.l	$007F0000		;140/820						d4	
	dc.l	$003F0000		;a0/8c0							d5
	dc.l	$00C70038		;280/6e0						d6
	dc.l	$FE000000		;								d7
;	dc.l	$00FF0000		;1e0/780						a1	
;	dc.l	$FC000000		;1e8/288/6e8/788				a2	
	dc.l	$0183007C		;320/640						a3
;	dc.l	$F0000000		;a8/8c8							a4
;set
;	dc.l	$F8000000		;1e8/288/6e8/788			d2	
;	dc.l	$007F0000		;a0/8c0						d4
;	dc.l	$00FF0000		;a0/8c0						a1		
;	dc.l	$FC000000		;328/3c8/468/508/5a8/648	a2	
;	dc.l	$F0000000		;328/3c8/468/508/5a8/648	a4
;---------------- move sprites 7 ----------
;---------------- move sprites 7 ----------
;---------------- move sprites 7 ----------
;---------------- move sprites 7 ----------
sprite7move_new
	REPT mloop_sprites7
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	d1,$8(a0)
		move.l	d1,$968(a0)
		move.l	d5,$a0(a0)
		move.l	d5,$8c0(a0)
		move.l	a4,$a8(a0)
		move.l	a4,$8c8(a0)
		move.l	d4,$140(a0)
		move.l	d4,$820(a0)
		move.l	d2,$148(a0)
		move.l	d2,$828(a0)
		move.l	a1,$1e0(a0)
		move.l	a1,$780(a0)
		move.l	a2,$1e8(a0)
		move.l	a2,$288(a0)
		move.l	a2,$6e8(a0)
		move.l	a2,$788(a0)
		move.l	d6,$280(a0)
		move.l	d6,$6e0(a0)
		move.l	a3,$320(a0)
		move.l	a3,$640(a0)
		move.l	d7,$328(a0)
		move.l	d7,$3c8(a0)
		move.l	d7,$468(a0)
		move.l	d7,$508(a0)
		move.l	d7,$5a8(a0)
		move.l	d7,$648(a0)
		move.l	d3,$3c0(a0)
		move.l	d3,$460(a0)
		move.l	d3,$500(a0)
		move.l	d3,$5a0(a0)
	ENDR
sprite7move
drawStart8
	movem.l	.sprite8Regs,d0/d1/d3/d6/a1/a3/a4
	move.w	(a6)+,a5
	jmp		sprite8move_new(pc,a5)
.sprite8Regs 
	dc.l	$00070000	;0/960							d0
	dc.l	$E0000000	;8/968							d1
;	dc.l	$F8000000	;a8/8c8							d2
	dc.l	$001F0000	;a0/8c0							d3
;	dc.l	$007F0000	;								d4
;	dc.l	$003F0000	;140/820						d5
	dc.l	$0063001C	;280/6e0						d6
;	dc.l	$FE000000	;1e8/288/6e8/788				d7
	dc.l	$FF000000	;328/3c8/468/508/5a8/648		a1
;	dc.l	$FC000000	;148/828						a2
	dc.l	$00C1003E	;320/640						a3
	dc.l	$00B8007F	;3c0/460/500/5a0				a4
;set
;	dc.l	$F8000000		;1e8/288/6e8/788			d2	
;	dc.l	$007F0000		;a0/8c0						d4
;	dc.l	$003F0000		;a0/8c0						d5
;	dc.l	$FE000000		;							d7
;	dc.l	$FC000000		;328/3c8/468/508/5a8/648	a2	
;---------------- move sprites 8 ----------
;---------------- move sprites 8 ----------
;---------------- move sprites 8 ----------
;---------------- move sprites 8 ----------
sprite8move_new
	REPT mloop_sprites8
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	d1,$8(a0)
		move.l	d1,$968(a0)
		move.l	d3,$a0(a0)
		move.l	d3,$8c0(a0)
		move.l	d2,$a8(a0)
		move.l	d2,$8c8(a0)
		move.l	d5,$140(a0)
		move.l	d5,$820(a0)
		move.l	a2,$148(a0)
		move.l	a2,$828(a0)
		move.l	d7,$1e8(a0)
		move.l	d7,$288(a0)
		move.l	d7,$6e8(a0)
		move.l	d7,$788(a0)
		move.l	a1,$328(a0)
		move.l	a1,$3c8(a0)
		move.l	a1,$468(a0)
		move.l	a1,$508(a0)
		move.l	a1,$5a8(a0)
		move.l	a1,$648(a0)
		move.l	d6,$280(a0)
		move.l	d6,$6e0(a0)
		move.l	a3,$320(a0)
		move.l	a3,$640(a0)
		move.l	a4,$3c0(a0)
		move.l	a4,$460(a0)
		move.l	a4,$500(a0)
		move.l	a4,$5a0(a0)
		move.l	d4,$1e0(a0)
		move.l	d4,$780(a0)
	ENDR
sprite8move
drawStart9
	move.l	a7,saveda7
	movem.l	.sprite9Regs,d0/d1/d2/d4/d6/a3/a4/a7
	move.w	(a6)+,a5
	jmp		sprite9move_new(pc,a5)
.sprite9Regs
	dc.l	$00030000	;0/960							d0
	dc.l	$F0000000	;8/968							d1
	dc.l	$000F0000	;a0/8c0							d2
;	dc.l	$001F0000	;								d3
	dc.l	$0031000E	;280/6e0						d4
;	dc.l	$003F0000	;								d5
	dc.l	$FF800000	;328/648						d6
;	dc.l	$FE000000	;148/828						d7
;	dc.l	$FF000000	;1e8/288/6e8/788				a1
;	dc.l	$FC000000	;a8/8c8							a2
	dc.l	$005C003F	;3c0/460/500/5a0				a3
	dc.l	$7F808000	;3c8/468/508/5a8				a4
	dc.l	$0060001F	;320/640						a7
;set
;	dc.l	$001F0000	;a0/8c0							d3
;	dc.l	$003F0000		;a0/8c0						d5
;	dc.l	$FE000000		;							d7
;	dc.l	$FF000000	;328/3c8/468/508/5a8/648		a1
;	dc.l	$FC000000		;328/3c8/468/508/5a8/648	a2	
;---------------- move sprites 9 ----------
;---------------- move sprites 9 ----------
;---------------- move sprites 9 ----------
;---------------- move sprites 9 ----------
sprite9move_new
	REPT mloop_sprites9
		add.w	(a6)+,a0
		move.l	d0,(a0)
		move.l	d0,$960(a0)
		move.l	d1,$8(a0)
		move.l	d1,$968(a0)
		move.l	d2,$a0(a0)
		move.l	d2,$8c0(a0)
		move.l	a2,$a8(a0)
		move.l	a2,$8c8(a0)
		move.l	d7,$148(a0)
		move.l	d7,$828(a0)
		move.l	a1,$1e8(a0)
		move.l	a1,$288(a0)
		move.l	a1,$6e8(a0)
		move.l	a1,$788(a0)
		move.l	d6,$328(a0)
		move.l	d6,$648(a0)
		move.l	d4,$280(a0)
		move.l	d4,$6e0(a0)
		move.l	a7,$320(a0)
		move.l	a7,$640(a0)
		move.l	d3,$140(a0)
		move.l	d3,$820(a0)
		move.l	a3,$3c0(a0)
		move.l	a3,$460(a0)
		move.l	a3,$500(a0)
		move.l	a3,$5a0(a0)
		move.l	d5,$1e0(a0)
		move.l	d5,$780(a0)
		move.l	a4,$3c8(a0)
		move.l	a4,$468(a0)
		move.l	a4,$508(a0)
		move.l	a4,$5a8(a0)	
	ENDR
sprite9move
drawStart10
	movem.l	.sprite10Regs,d0/d1/d4/d5/a2/a3/a4/a7
	move.w	(a6)+,a5
	jmp		sprite10move_new(pc,a5)
.sprite10Regs
	dc.l	$F8000000		;8/968							d0
	dc.l	$00010000						;				d1
;	dc.l	$000F0000	;320/640							d2	
;	dc.l	$001F0000	;									d3
	dc.l	$00180007	;280/6e0							d4
	dc.l	$0030000F	;320/640							d5	
;	dc.l	$FF800000		;1e8/288/6e8/788				d6
;	dc.l	$FE000000		;a8/8c8							d7
;	dc.l	$FF000000		;148/828						a1
	dc.l	$3FC0C000	;3c8/468/508/5a8					a2
	dc.l	$7FC08000	;328/648							a3
	dc.l	$002E001F	;3c0/460/500/5a0					a4
	dc.l	$00070000	;									a7
;set 
;	dc.l	$000F0000	;a0/8c0							d2
;	dc.l	$FE000000	;148/828						d7
;	dc.l	$FF000000	;1e8/288/6e8/788				a1
;	dc.l	$FF800000	;328/648						d6
;	dc.l	$001F0000	;a0/8c0							d3

;---------------- move sprites 10 ----------
;---------------- move sprites 10 ----------
;---------------- move sprites 10 ----------
;---------------- move sprites 10 ----------
sprite10move_new
	REPT mloop_sprites10
		add.w	(a6)+,a0
		move.l	d1,(a0)
		move.l	d1,$960(a0)
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	a7,$a0(a0)
		move.l	a7,$8c0(a0)
		move.l	d7,$a8(a0)
		move.l	d7,$8c8(a0)
		move.l	d2,$140(a0)
		move.l	d2,$820(a0)
		move.l	a1,$148(a0)
		move.l	a1,$828(a0)
		move.l	d6,$1e8(a0)
		move.l	d6,$288(a0)
		move.l	d6,$6e8(a0)
		move.l	d6,$788(a0)
		move.l	d4,$280(a0)
		move.l	d4,$6e0(a0)
		move.l	d5,$320(a0)
		move.l	d5,$640(a0)
		move.l	a3,$328(a0)
		move.l	a3,$648(a0)
		move.l	d3,$1e0(a0)
		move.l	d3,$780(a0)
		move.l	a4,$3c0(a0)
		move.l	a4,$460(a0)
		move.l	a4,$500(a0)
		move.l	a4,$5a0(a0)
		move.l	a2,$3c8(a0)
		move.l	a2,$468(a0)
		move.l	a2,$508(a0)
		move.l	a2,$5a8(a0)
	ENDR
sprite10move
drawStart11
	movem.l	.sprite11Regs,d0/d1/d2/d3/d5/a2/a4
	move.w	(a6)+,a5
	jmp		sprite11move_new(pc,a5)
.sprite11Regs
	dc.l	$FC000000		;8/968							d0
	dc.l	$3FE0C000	;328/648							d1
	dc.l	$000C0003	;280/6e0							d2
	dc.l	$FFC00000		;1e8/788						d3
;	dc.l	$00180007	;320/640							d4
	dc.l	$1FE0E000	;3c8/468/508/5a8					d5
;	dc.l	$FF800000		;148/828						d6
;	dc.l	$FF000000		;a8/8c8							a1
	dc.l	$0017000F	;3c0/460/500/5a0					a2
;	dc.l	$7FC08000	;288/6e8							a3
	dc.l	$00030000								;		a4
;	dc.l	$00070000								;		a7
;set
;	dc.l	$FF000000		;148/828						a1
;	dc.l	$FF800000		;1e8/288/6e8/788				d6
;	dc.l	$7FC08000	;328/648							a3
;	dc.l	$00180007	;280/6e0							d4
;	dc.l	$00070000	;									a7

;---------------- move sprites 11 ----------
;---------------- move sprites 11 ----------
;---------------- move sprites 11 ----------
;---------------- move sprites 11 ----------
sprite11move_new
	REPT mloop_sprites11		; these are the same, but 12 is max
		add.w	(a6)+,a0
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	a4,$a0(a0)
		move.l	a4,$8c0(a0)
		move.l	a1,$a8(a0)
		move.l	a1,$8c8(a0)
		move.l	a7,$140(a0)
		move.l	a7,$820(a0)
		move.l	d6,$148(a0)
		move.l	d6,$828(a0)
		move.l	d3,$1e8(a0)
		move.l	d3,$788(a0)
		move.l	d2,$280(a0)
		move.l	d2,$6e0(a0)
		move.l	a3,$288(a0)
		move.l	a3,$6e8(a0)
		move.l	d4,$320(a0)
		move.l	d4,$640(a0)
		move.l	d1,$328(a0)
		move.l	d1,$648(a0)
		move.l	a7,$1e0(a0)
		move.l	a7,$780(a0)
		move.l	a2,$3c0(a0)
		move.l	a2,$460(a0)
		move.l	a2,$500(a0)
		move.l	a2,$5a0(a0)
		move.l	d5,$3c8(a0)
		move.l	d5,$468(a0)
		move.l	d5,$508(a0)
		move.l	d5,$5a8(a0)
	ENDR
sprite11move
drawStart12
	movem.l	.sprite12Regs,d0/d4/d5/d7/a1/a2/a3
	move.w	(a6)+,a5
	jmp		sprite12move_new(pc,a5)
.sprite12Regs
	dc.l	$7E000000		;8/968							d0
;	dc.l	$3FE0C000		;288/6e8						d1
;	dc.l	$000C0003		;320/640						d2
;	dc.l	$FFC00000		;148/828						d3
	dc.l	$00060001		;280/6e0						d4
	dc.l	$FFE00000		;1e8/788						d5
;	dc.l	$FF800000		;a8/8c8							d6
	dc.l	$00010000		;280/6e0						d7
	dc.l	$1FF0E000		;328/648						a1
	dc.l	$000B0007		;3c0/460/500/5a0				a2
	dc.l	$8FF0F000		;3c8/468/508/5a8				a3
;	dc.l	$00030000		;320/640						a4
;	dc.l	$00070000		;3c0/460/500/5a0				a7
;set
;	dc.l	$FF800000		;1e8/288/6e8/788				d6
;	dc.l	$FFC00000		;1e8/788						d3
;	dc.l	$3FE0C000	;328/648							d1
;	dc.l	$000C0003	;280/6e0							d2
;	dc.l	$00030000								;		a4
;	dc.l	$00070000								;		a7

;---------------- move sprites 12 ----------
;---------------- move sprites 12 ----------
;---------------- move sprites 12 ----------
;---------------- move sprites 12 ----------
sprite12move_new
	REPT mloop_sprites12
		add.w	(a6)+,a0
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	d7,$a0(a0)
		move.l	d7,$8c0(a0)
		move.l	d6,$a8(a0)
		move.l	d6,$8c8(a0)
		move.l	a4,$140(a0)
		move.l	a4,$820(a0)
		move.l	d3,$148(a0)
		move.l	d3,$828(a0)
		move.l	d5,$1e8(a0)
		move.l	d5,$788(a0)
		move.l	d4,$280(a0)
		move.l	d4,$6e0(a0)
		move.l	d1,$288(a0)
		move.l	d1,$6e8(a0)
		move.l	d2,$320(a0)
		move.l	d2,$640(a0)
		move.l	a1,$328(a0)
		move.l	a1,$648(a0)
		move.l	a7,$1e0(a0)
		move.l	a7,$780(a0)
		move.l	a2,$3c0(a0)
		move.l	a2,$460(a0)
		move.l	a2,$500(a0)
		move.l	a2,$5a0(a0)
		move.l	a3,$3c8(a0)
		move.l	a3,$468(a0)
		move.l	a3,$508(a0)
		move.l	a3,$5a8(a0)
	ENDR
sprite12move												; same as sprite11
	move.l	saveda7,a7
	IFEQ	showRasters
		move.w	d2,$ffff8240.w
	ELSE
		REPT 3
			nop
		ENDR
	ENDC
drawStart13
	movem.l	.sprite13Regs,d0/d1/d2/d6/a2
	move.w	(a6)+,a5
	jmp		sprite13move_new(pc,a5)
.sprite13Regs	
	dc.l	$3F000000		;8/968							d0
	dc.l	$FFF00000		;1e8/788						d1
	dc.l	$00050003		;3c0/460/500/5a0				d2
;	dc.l	$FFC00000		;a8/8c8							d3
;	dc.l	$00060001		;320/640						d4
;	dc.l	$FFE00000		;148/828						d5
	dc.l	$0FF8F000		;328/648						d6
;	dc.l	$00010000		;320/640						d7
;	dc.l	$1FF0E000		;288/6e8						a1
	dc.l	$C7F8F800		;3c8/468/508/5a8				a2
;	dc.l	$00030000		;3c0/460/500/5a0				a4
; set 
;	dc.l	$FFC00000		;1e8/788						d3
;	dc.l	$FFE00000		;1e8/788						d5
;	dc.l	$1FF0E000		;328/648						a1
;	dc.l	$00060001		;280/6e0						d4
;	dc.l	$00010000		;280/6e0						d7
;	dc.l	$00030000								;		a4

;---------------- move sprites 13 ----------
;---------------- move sprites 13 ----------
;---------------- move sprites 13 ----------
;---------------- move sprites 13 ----------
sprite13move_new
	REPT mloop_sprites13
		add.w	(a6)+,a0
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	d3,$a8(a0)
		move.l	d3,$8c8(a0)
		move.l	d7,$140(a0)
		move.l	d7,$820(a0)
		move.l	d5,$148(a0)
		move.l	d5,$828(a0)
		move.l	d1,$1e8(a0)
		move.l	d1,$788(a0)
		move.l	a1,$288(a0)
		move.l	a1,$6e8(a0)
		move.l	d4,$320(a0)
		move.l	d4,$640(a0)
		move.l	d6,$328(a0)
		move.l	d6,$648(a0)
		move.l	a4,$1e0(a0)
		move.l	a4,$280(a0)
		move.l	a4,$6e0(a0)
		move.l	a4,$780(a0)
		move.l	d2,$3c0(a0)
		move.l	d2,$460(a0)
		move.l	d2,$500(a0)
		move.l	d2,$5a0(a0)
		move.l	a2,$3c8(a0)
		move.l	a2,$468(a0)
		move.l	a2,$508(a0)
		move.l	a2,$5a8(a0)
	ENDR
sprite13move
drawStart14
	movem.l	.sprite14Regs,d0/d2/d3/d5/d6/a1/a2
	move.w	(a6)+,a5
	jmp		sprite14move_new(pc,a5)
.sprite14Regs
	dc.l	$1F800000		;8/968							d0
;	dc.l	$FFF00000		;148/828						d1
	dc.l	$7FE00000		;a8/8c8							d2
	dc.l	$FFF80000		;1e8/788						d3
	dc.l	$8FF87000		;288/6e8						d5
	dc.l	$07FCF800		;328/648						d6
;	dc.l	$00010000		;								d7
	dc.l	$00020001		;3c0/460/500/5a0				a1
	dc.l	$E3FCFC00		;3c8/468/508/5a8				a2
;	dc.l	$00030000		;320/640						a4
;set
;	dc.l	$FFF00000		;1e8/788						d1
;	dc.l	$00030000								;		a4
;	dc.l	$00010000		;280/6e0						d7

;---------------- move sprites 14 ----------
;---------------- move sprites 14 ----------
;---------------- move sprites 14 ----------
;---------------- move sprites 14 ----------
sprite14move_new
	REPT mloop_sprites14
		add.w	(a6)+,a0
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	d2,$a8(a0)
		move.l	d2,$8c8(a0)
		move.l	d1,$148(a0)
		move.l	d1,$828(a0)
		move.l	d3,$1e8(a0)
		move.l	d3,$788(a0)
		move.l	a4,$320(a0)
		move.l	a4,$640(a0)
		move.l	d5,$288(a0)
		move.l	d5,$6e8(a0)
		move.l	d6,$328(a0)
		move.l	d6,$648(a0)
		move.l	d7,$1e0(a0)
		move.l	d7,$280(a0)
		move.l	d7,$6e0(a0)
		move.l	d7,$780(a0)
		move.l	a1,$3c0(a0)
		move.l	a1,$460(a0)
		move.l	a1,$500(a0)
		move.l	a1,$5a0(a0)
		move.l	a2,$3c8(a0)
		move.l	a2,$468(a0)
		move.l	a2,$508(a0)
		move.l	a2,$5a8(a0)
	ENDR
sprite14move
drawStart15
	movem.l	.sprite15Regs,d0-d6
	move.w	(a6)+,a5
	jmp		sprite15move_new(pc,a5)
.sprite15Regs	
	dc.l	$0FC00000		;8/968						d0
	dc.l	$3FF00000		;a8/8c8						d1
	dc.l	$7FF80000		;148/828					d2
	dc.l	$FFFC0000		;1e8/788					d3
	dc.l	$71FEFE00	;3c8/468/508/5a8			d4
	dc.l	$C7FC3800	;288/6e8					d5
	dc.l	$83FE7C00	;328/648					d6
;	dc.l	$00010000		;320/3c0/460/500/5a0/640	d7
;set
;	dc.l	$00010000		;280/6e0						d7
;---------------- move sprites 15 ----------
;---------------- move sprites 15 ----------
;---------------- move sprites 15 ----------
;---------------- move sprites 15 ----------
sprite15move_new
	REPT mloop_sprites15
		add.w	(a6)+,a0
		move.l	d0,$8(a0)
		move.l	d0,$968(a0)
		move.l	d1,$a8(a0)
		move.l	d1,$8c8(a0)
		move.l	d2,$148(a0)
		move.l	d2,$828(a0)
		move.l	d3,$1e8(a0)
		move.l	d3,$788(a0)
		move.l	d7,$320(a0)
		move.l	d7,$3c0(a0)
		move.l	d7,$460(a0)
		move.l	d7,$500(a0)
		move.l	d7,$5a0(a0)
		move.l	d7,$640(a0)
		move.l	d5,$288(a0)
		move.l	d5,$6e8(a0)
		move.l	d6,$328(a0)
		move.l	d6,$648(a0)
		move.l	d4,$3c8(a0)
		move.l	d4,$468(a0)
		move.l	d4,$508(a0)
		move.l	d4,$5a8(a0)
	ENDR
sprite15move
		    		swapscreens
	move.l	usp,a0
	lea		.sprite0Regs,a5
	movem.w	(a5)+,d0-d3
	movem.l	(a5)+,d4-d6
	move.w	(a6)+,a5
	jmp		sprite0or_new(pc,a5)
.sprite0Regs
	dc.w	$07E0		;	$0,$960			.w		0,15				movem.w	(a0)+,d0-d3		28
	dc.w	$1FF8		;	$a0,$8c0		.w		1,14				movem.l	(a0)+,d4-d6		36	--> 64
	dc.w	$3FFC		;	$140,$820		.w		2,13
	dc.w	$7FFE		;	$1e0,$780		.w		3,12				
	dc.l	$63FE1C00	;	$280,$6e0		.l		4,11
	dc.l	$C1FF3E00	;	$320,$640		.l		5,10
	dc.l	$B8FF7F00	;	$3c0,$460,$500,$5a0	.l	6,7,8,9

sprite0or_new
	REPT 	loop_sprites0
		add.w	(a6)+,a0			;2
		or.w	d0,(a0)				;2
		or.w	d0,$960(a0)			;4
		or.w	d1,$a0(a0)			;4
		or.w	d1,$8c0(a0)			;4
		or.w	d2,$140(a0)			;4
		or.w	d2,$820(a0)			;4
		or.w	d3,$1e0(a0)			;4
		or.w	d3,$780(a0)			;4
		or.l	d4,$280(a0)			;4
		or.l	d4,$6e0(a0)			;4
		or.l	d5,$320(a0)			;4
		or.l	d5,$640(a0)			;4	
		or.l	d6,$3c0(a0)			;4
		or.l	d6,$460(a0)			;4
		or.l	d6,$500(a0)			;4
		or.l	d6,$5a0(a0)			;4			--> 16*4 = 64 size
	ENDR
sprite0
start1
	lea		.sprite1Regs,a5
	movem.w	(a5)+,d0-d3
	movem.l	(a5)+,d4-d6
	move.w	(a6)+,a5
	jmp		sprite1or_new(pc,a5)
.sprite1Regs
	dc.w	$03F0		;	$0,$960			.w							d0
	dc.w	$0FFC		;	$a0,$8c0		.w							d1
	dc.w	$1FFE		;	$140,$820		.w							d2
	dc.w	$3FFF		;	$1e0,$780		.w							d3
	dc.l	$31FF0E00	;	$280,$6e0		.l							d4
	dc.l	$60FF1F00	;	$320,$640		.l							d5
	dc.l	$5C7F3F80	;	$3c0,$460,$500,$5a0	.l						d6
start0
	lea		sprite0Regs,a5
	movem.w	(a5)+,d0-d3
	movem.l	(a5)+,d4-d6
	move.l	(a6)+,a5
	jmp		(a5)
sprite0Regs
	dc.w	$07E0		;	$0,$960			.w		0,15				movem.w	(a0)+,d0-d3		28
	dc.w	$1FF8		;	$a0,$8c0		.w		1,14				movem.l	(a0)+,d4-d6		36	--> 64
	dc.w	$3FFC		;	$140,$820		.w		2,13
	dc.w	$7FFE		;	$1e0,$780		.w		3,12				
	dc.l	$63FE1C00	;	$280,$6e0		.l		4,11
	dc.l	$C1FF3E00	;	$320,$640		.l		5,10
	dc.l	$B8FF7F00	;	$3c0,$460,$500,$5a0	.l	6,7,8,9

sprite1or_new
	REPT loop_sprites1
		add.w	(a6)+,a0			;2
		or.w	d0,(a0)				;2
		or.w	d0,$960(a0)			;4
		or.w	d1,$a0(a0)			;4
		or.w	d1,$8c0(a0)			;4
		or.w	d2,$140(a0)			;4
		or.w	d2,$820(a0)			;4
		or.w	d3,$1e0(a0)			;4
		or.w	d3,$780(a0)			;4
		or.b	d6,$328(a0)			;4
		or.b	d6,$3c8(a0)			;4
		or.b	d6,$468(a0)			;4
		or.b	d6,$508(a0)			;4
		or.b	d6,$5a8(a0)			;4
		or.b	d6,$648(a0)			;4
		or.l	d4,$280(a0)			;4
		or.l	d4,$6e0(a0)			;4
		or.l	d5,$320(a0)			;4
		or.l	d5,$640(a0)			;4
		or.l	d6,$3c0(a0)			;4
		or.l	d6,$460(a0)			;4
		or.l	d6,$500(a0)			;4
		or.l	d6,$5a0(a0)			;4		22*4 = 88 size
	ENDR
sprite1
start2
	lea		.sprite2Regs,a5
	movem.w	(a5)+,d0-d3
	movem.l	(a5)+,d4-d6
	move.w	(a6)+,a5
	jmp		sprite2or_new(pc,a5)
.sprite2Regs
	dc.w	$01F8		;	0,$960							d0
	dc.w	$07FE		;	$a0,$8c0						d1
	dc.w	$0FFF		;	$140,$820						d2
	dc.w	$1FFF		;	$1e0,$780						d3
	dc.l	$18FF0700	;	$280,$6e0						d4
	dc.l	$307F0F80	;	$320,$640						d5
	dc.l	$2E3F1FC0	;	$3c0,$460,$500,$5a0				d6

sprite2or_new
	REPT loop_sprites2
		add.w	(a6)+,a0			;2
		or.w	d0,(a0)				;2
		or.w	d0,$960(a0)			;4
		or.w	d1,$a0(a0)			;4
		or.w	d1,$8c0(a0)			;4
		or.w	d2,$140(a0)			;4
		or.w	d2,$820(a0)			;4
		or.w	d3,$1e0(a0)			;4
		or.w	d3,$780(a0)			;4	
		or.b	d5,$1e8(a0)	
		or.b	d5,$288(a0)	
		or.b	d5,$6e8(a0)	
		or.b	d5,$788(a0)	
		or.b	d6,$328(a0)
		or.b	d6,$3c8(a0)
		or.b	d6,$468(a0)
		or.b	d6,$508(a0)
		or.b	d6,$5a8(a0)
		or.b	d6,$648(a0)
		or.l	d4,$280(a0)
		or.l	d4,$6e0(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d6,$3c0(a0)
		or.l	d6,$460(a0)
		or.l	d6,$500(a0)
		or.l	d6,$5a0(a0)			;26*4 = 104
	ENDR
sprite2
start3
	lea		.sprite3Regs,a5
	movem.w	(a5)+,d0/d1/d3
	movem.l	(a5)+,d4-d6
	move.w	(a6)+,a5
	jmp		sprite3or_new(pc,a5)
.sprite3Regs
	dc.w	$00FC		;0/960						d0
	dc.w	$03FF		;a0/8c0						d1
;	dc.w	$0FFF		;1e0/780					d2
	dc.w	$07FF		;140/820					d3
	dc.l	$0C7F0380	;280/6e0					d4
	dc.l	$183F07C0	;320/640					d5
	dc.l	$171F0FE0	;3c0/460/500/5a0			d6
;set
;	dc.w	$0FFF		;	$140,$820						d2

sprite3or_new
	REPT loop_sprites3
		add.w	(a6)+,a0			;2
		or.w	d0,(a0)				;2
		or.w	d0,$960(a0)			;4
		or.w	d1,$a0(a0)			;4
		or.w	d1,$8c0(a0)			;4
		or.w	d3,$140(a0)			;4
		or.w	d3,$820(a0)			;4
		or.b	d4,$148(a0)
		or.b	d4,$828(a0)
		or.w	d2,$1e0(a0)
		or.w	d2,$780(a0)
		or.b	d5,$1e8(a0)			;
		or.b	d5,$288(a0)
		or.b	d5,$6e8(a0)
		or.b	d5,$788(a0)
		or.b	d6,$328(a0)
		or.b	d6,$3c8(a0)
		or.b	d6,$468(a0)
		or.b	d6,$508(a0)
		or.b	d6,$5a8(a0)
		or.b	d6,$648(a0)
		or.l	d4,$280(a0)
		or.l	d4,$6e0(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d6,$3c0(a0)
		or.l	d6,$460(a0)
		or.l	d6,$500(a0)
		or.l	d6,$5a0(a0)			; 28
	ENDR
sprite3
start4
	moveq	#126,d0
	movem.l	.sprite4Regs,d4-d7
	move.w	(a6)+,a5
	jmp		sprite4or_new(pc,a5)
.sprite4Regs
;	dc.w	$007E		;0/960							d0
;	dc.w	$03FF		;140/820						d1
;	dc.w	$8000		;a8/8c8							d2
;	dc.w	$07FF		;1e0/780						d3
	dc.l	$000001FF		;a0/8c0							d4
	dc.l	$0C1F03E0		;320/640					d5
	dc.l	$0B8F07F0		;3c0/460/500/5a0			d6
	dc.l	$063F01C0		;280/6e0					d7
;set
;	dc.w	$03FF		;a0/8c0						d1
;	dc.w	$07FF		;140/820					d3

sprite4or_new
	REPT loop_sprites4
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		or.w	d4,$a0(a0)
		or.w	d4,$8c0(a0)
;		or.w	d2,$a8(a0)
;		or.w	d2,$8c8(a0)
		bset	d4,$a8(a0)
		bset	d4,$8c8(a0)
		or.w	d1,$140(a0)
		or.w	d1,$820(a0)
		or.b	d7,$148(a0)
		or.b	d7,$828(a0)
		or.w	d3,$1e0(a0)
		or.w	d3,$780(a0)
		or.b	d5,$1e8(a0)
		or.b	d5,$288(a0)
		or.b	d5,$6e8(a0)
		or.b	d5,$788(a0)
		or.b	d6,$328(a0)
		or.b	d6,$3c8(a0)
		or.b	d6,$468(a0)
		or.b	d6,$508(a0)
		or.b	d6,$5a8(a0)
		or.b	d6,$648(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d6,$3c0(a0)
		or.l	d6,$460(a0)
		or.l	d6,$500(a0)
		or.l	d6,$5a0(a0)
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
	ENDR
sprite4
start5
	moveq	#63,d0
	movem.l	.sprite5Regs,d3/d5/d6/d7
	move.w	(a6)+,a5
	jmp		sprite5or_new(pc,a5)
.sprite5Regs
;	dc.w	$003F		;0/960							d0
;	dc.w	$03FF		;1e0/780						d1
;	dc.w	$01FF		;140/820						d2
	dc.l	$0000C000		;a8/8c8						d3
	dc.l	$060F01F0	;320/640						d5
	dc.l	$05C703F8	;3c0/460/500/5a0				d6
	dc.l	$031F00E0	;280/6e0						d7
;set
;	dc.w	$03FF		;a0/8c0							d1
;	dc.w	$01FF		;a0/8c0							d4

sprite5or_new
	REPT loop_sprites5
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		move.b	d4,$a1(a0)
		move.b	d4,$8c1(a0)
		or.w	d3,$a8(a0)
		or.w	d3,$8c8(a0)
		or.w	d4,$140(a0)
		or.w	d4,$820(a0)
		or.b	d7,$148(a0)
		or.b	d7,$828(a0)
		or.w	d1,$1e0(a0)
		or.w	d1,$780(a0)
		or.b	d5,$1e8(a0)
		or.b	d5,$288(a0)
		or.b	d5,$6e8(a0)
		or.b	d5,$788(a0)
		or.b	d6,$328(a0)
		or.b	d6,$3c8(a0)
		or.b	d6,$468(a0)
		or.b	d6,$508(a0)
		or.b	d6,$5a8(a0)
		or.b	d6,$648(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d6,$3c0(a0)
		or.l	d6,$460(a0)
		or.l	d6,$500(a0)
		or.l	d6,$5a0(a0)
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
	ENDR
sprite5
start6
	moveq	#31,d0
	moveq	#127,d1
	movem.l	.sprite6Regs,d2/d3/d5-d7
	move.w	(a6)+,a5
	jmp		sprite6or_new(pc,a5)
.sprite6Regs
;	dc.w	$001F		;0/960							d0
;	dc.w	$007F		;a0/8c0							d1
	dc.l	$0000E000		;a8/8c8							d2
	dc.l	$0000F000		;148/828						d3
;	dc.w	$01FF		;1e0/780						d4
	dc.l	$030700F8	;320/640						d5
	dc.l	$02E301FC	;3c0/460/500/5a0				d6
	dc.l	$018F0070	;280/6e0						d7
;set
;	dc.w	$01FF		;a0/8c0							d4
sprite6or_new
	REPT loop_sprites6
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		bset.b	d4,$8(a0)
		bset.b	d4,$968(a0)
		or.w	d1,$a0(a0)
		or.w	d1,$8c0(a0)
		or.w	d2,$a8(a0)
		or.w	d2,$8c8(a0)
		move.b	d4,$141(a0)
		move.b	d4,$821(a0)
		or.w	d3,$148(a0)
		or.w	d3,$828(a0)
		or.w	d4,$1e0(a0)
		or.w	d4,$780(a0)
		or.b	d5,$1e8(a0)
		or.b	d5,$288(a0)
		or.b	d5,$6e8(a0)
		or.b	d5,$788(a0)
		or.b	d6,$328(a0)
		or.b	d6,$3c8(a0)
		or.b	d6,$468(a0)
		or.b	d6,$508(a0)
		or.b	d6,$5a8(a0)
		or.b	d6,$648(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d6,$3c0(a0)
		or.l	d6,$460(a0)
		or.l	d6,$500(a0)
		or.l	d6,$5a0(a0)
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
	ENDR
sprite6
start7
	lea		.sprite7Regs,a5
	movem.w	(a5)+,d0/d2/d4/d5/d6/a1
	movem.l	(a5)+,a2-a4
	move.w	(a6)+,a5
	jmp		sprite7or_new(pc,a5)
.sprite7Regs
	dc.w	$000F		;0/960							d0
;	dc.w	$007F		;140/820						d1
	dc.w	$003F		;a0/8c0							d2
;	dc.w	$F000		;a8/8c8							d3
	dc.w	$C000		;8/968							d4
	dc.w	$F800		;148/828						d5
	dc.w	$00FF		;1e0/780						d6
	dc.w	$FC00		;1e8/288/6e8/788				a1
	dc.l	$00C70038	;280/6e0						a2
	dc.l	$0183007C	;320/640						a3
	dc.l	$017100FE	;3c0/460/500/5a0				a4
;set
;	dc.w	$F000		;148/828						d3
;	dc.w	$007F		;a0/8c0							d1
sprite7or_new
	REPT loop_sprites7
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		or.w	d4,$8(a0)
		or.w	d4,$968(a0)
		or.w	d2,$a0(a0)
		or.w	d2,$8c0(a0)
		or.w	d3,$a8(a0)
		or.w	d3,$8c8(a0)
		or.w	d1,$140(a0)
		or.w	d1,$820(a0)
		or.w	d5,$148(a0)
		or.w	d5,$828(a0)
		or.w	d6,$1e0(a0)
		or.w	d6,$780(a0)
		move.l	a1,d7
		or.w	d7,$1e8(a0)
		or.w	d7,$288(a0)
		or.w	d7,$6e8(a0)
		or.w	d7,$788(a0)
		move.l	a2,d7
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
		move.l	a3,d7
		or.l	d7,$320(a0)
		or.l	d7,$640(a0)
		move.l	a4,d7
		or.b	d7,$328(a0)
		or.b	d7,$3c8(a0)
		or.b	d7,$468(a0)
		or.b	d7,$508(a0)
		or.b	d7,$5a8(a0)
		or.b	d7,$648(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
	ENDR
sprite7
start8
	lea		.sprite8Regs,a5		
	movem.w	(a5)+,d0/d1/d3/d4/d6			;
	movem.l	(a5)+,a2/a3/a4
	move.w	(a6)+,a5
	jmp		sprite8or_new(pc,a5)
.sprite8Regs 
	dc.w	$0007	;0/960							d0
	dc.w	$E000	;8/968							d1
;	dc.w	$003F	;140/820						d2
	dc.w	$FF00	;328/3c8/468/508/5a8/648		d3
	dc.w	$001F	;a0/8c0							d4
;	dc.w	$F800	;a8/8c8							d5
	dc.w	$FE00	;1e8/288/6e8/788				d6
;	dc.w	$FC00	;148/828						a1
	dc.l	$0063001C	;280/6e0						a2
	dc.l	$00C1003E	;320/640						a3
	dc.l	$00B8007F	;3c0/460/500/5a0				a4
;set
;	dc.w	$F800		;148/828						d5
;	dc.w	$003F		;a0/8c0							d2
;	dc.w	$FC00		;1e8/288/6e8/788				a1

sprite8or_new
	REPT loop_sprites8
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		or.w	d1,$8(a0)
		or.w	d1,$968(a0)
		or.w	d4,$a0(a0)
		or.w	d4,$8c0(a0)
		or.w	d5,$a8(a0)
		or.w	d5,$8c8(a0)
		or.w	d2,$140(a0)
		or.w	d2,$820(a0)
		or.w	d6,$1e8(a0)
		or.w	d6,$288(a0)
		or.w	d6,$6e8(a0)
		or.w	d6,$788(a0)
		or.w	d3,$328(a0)
		or.w	d3,$3c8(a0)
		or.w	d3,$468(a0)
		or.w	d3,$508(a0)
		or.w	d3,$5a8(a0)
		or.w	d3,$648(a0)

		move.l	a1,d7

		or.w	d7,$148(a0)
		or.w	d7,$828(a0)


		move.l	a2,d7
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
		move.l	a3,d7
		or.l	d7,$320(a0)
		or.l	d7,$640(a0)
		move.l	a4,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)			
	ENDR
sprite8
start9
	moveq	#3,d0
	moveq	#15,d2
	moveq	#-128,d4
	movem.l	.sprite9Regs,d1/d5/a1-a4				;44
	move.w	(a6)+,a5
	jmp		sprite9or_new(pc,a5)
.sprite9Regs
;	dc.w	$0003	;0/960							d0
	dc.l	$0000F000	;8/968							d1
;	dc.w	$000F	;a0/8c0							d2
;	dc.w	$FF00	;1e8/288/6e8/788				d3
;	dc.w	$FF80	;328/648						d4
	dc.l	$0000FC00	;a8/8c8							d5
;	dc.w	$FE00	;148/828						d6
	dc.l	$0031000E	;280/6e0						a1
	dc.l	$0060001F	;320/640						a2
	dc.l	$005C003F	;3c0/460/500/5a0				a3
	dc.l	$7F808000	;3c8/468/508/5a8				a4
;set
;	dc.w	$FC00	;a8/8c8							a1
;	dc.w	$FE00	;1e8/288/6e8/788				d6
;	dc.w	$FF00	;328/3c8/468/508/5a8/648		d3
sprite9or_new
	REPT loop_sprites9
		add.w	(a6)+,a0
		or.w	d0,(a0)
		or.w	d0,$960(a0)
		or.w	d1,$8(a0)
		or.w	d1,$968(a0)
		or.w	d2,$a0(a0)
		or.w	d2,$8c0(a0)
		or.w	d5,$a8(a0)
		or.w	d5,$8c8(a0)
		or.w	d6,$148(a0)
		or.w	d6,$828(a0)
		or.w	d3,$1e8(a0)
		or.w	d3,$288(a0)
		or.w	d3,$6e8(a0)
		or.w	d3,$788(a0)
		or.w	d4,$328(a0)
		or.w	d4,$648(a0)
		move.l	a1,d7
		or.l	d7,$280(a0)
		or.l	d7,$6e0(a0)
		move.l	a2,d7
		or.l	d7,$320(a0)
		or.l	d7,$640(a0)
		or.w	d7,$140(a0)
		or.w	d7,$820(a0)
		move.l	a3,d7
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		or.w	d7,$1e0(a0)
		or.w	d7,$780(a0)
		move.l	a4,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite9
start10
	movem.l	.sprite10Regs,d0/d1/d2/d5/a1/a2
	move.w	(a6)+,a5
	jmp		sprite10or_new(pc,a5)
.sprite10Regs
	dc.l	$0000F800		;8/968							d0
;	dc.w	$FE00		;a8/8c8							d1
;	dc.w	$FF80		;1e8/288/6e8/788				d4
;	dc.w	$FF00		;148/828						d3

	dc.l	$7FC08000	;328/648						d1
	dc.l	$00180007	;280/6e0						d2
	dc.l	$0030000F	;320/640						d5	
	dc.l	$002E001F	;3c0/460/500/5a0				a1
	dc.l	$3FC0C000	;3c8/468/508/5a8				a2
;set 
;	dc.w	$FE00	;148/828						d6
;	dc.w	$FF00	;328/3c8/468/508/5a8/648		d3
;	dc.w	$FF80	;328/648						d4

sprite10or_new
	REPT loop_sprites10
		add.w	(a6)+,a0
		bset.b	d6,$1(a0)
		bset.b	d6,$961(a0)
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d2,$a0(a0)
		or.w	d2,$8c0(a0)
		or.w	d6,$a8(a0)
		or.w	d6,$8c8(a0)
		or.w	d5,$140(a0)
		or.w	d5,$820(a0)
		or.w	d3,$148(a0)
		or.w	d3,$828(a0)
		or.w	d4,$1e8(a0)
		or.w	d4,$288(a0)
		or.w	d4,$6e8(a0)
		or.w	d4,$788(a0)
		or.l	d2,$280(a0)
		or.l	d2,$6e0(a0)
		or.l	d5,$320(a0)
		or.l	d5,$640(a0)
		or.l	d1,$328(a0)
		or.l	d1,$648(a0)
		move.l	a1,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		move.l	a2,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite10
start11
	moveq	#-128,d6
	moveq	#-64,d5
	movem.l	.sprite11Regs,d0/d4/d7/a1/a2/a3
	move.w	(a6)+,a5
	jmp		sprite11or_new(pc,a5)
.sprite11Regs
	dc.l	$0000FC00		;8/968							d0
;	dc.l	$7FC08000	;288/6e8						d1
;	dc.l	$00180007	;280/6e0						d2
;	dc.w	$FFC0		;1e8/788						d3
	dc.l	$000C0003	;280/6e0						d4
;	dc.w	$FF00		;a8/8c8							d5
;	dc.w	$FF80		;148/828						d6
	dc.l	$00070000	;320/640						d7
	dc.l	$3FE0C000	;328/648						a1
	dc.l	$0017000F	;3c0/460/500/5a0				a2
	dc.l	$1FE0E000	;3c8/468/508/5a8				a3
;set
;	dc.w	$FF00	;328/3c8/468/508/5a8/648			d3
;	dc.l	$7FC08000	;328/648						d1
;	dc.l	$00180007	;280/6e0						d2

sprite11or_new
	REPT loop_sprites11		; these are the same, but 12 is max
		add.w	(a6)+,a0
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d4,$a0(a0)
		or.w	d4,$8c0(a0)
		or.w	d3,$a8(a0)
		or.w	d3,$8c8(a0)
		or.w	d2,$140(a0)
		or.w	d2,$820(a0)
		or.w	d6,$148(a0)
		or.w	d6,$828(a0)
		or.w	d5,$1e8(a0)
		or.w	d5,$788(a0)
		or.l	d4,$280(a0)
		or.l	d4,$6e0(a0)
		or.l	d1,$288(a0)
		or.l	d1,$6e8(a0)
		or.l	d2,$320(a0)
		or.l	d2,$640(a0)
		move.l	a1,d7
		or.l	d7,$328(a0)
		or.l	d7,$648(a0)
		move.l	a2,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		move.l	a3,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite11
start12
	moveq	#-128,d1
	moveq	#-64,d2
	moveq	#-32,d3
	movem.l	.sprite12Regs,d0/d5/d6/d7/a2/a3
	move.w	(a6)+,a5
	jmp		sprite12or_new(pc,a5)
.sprite12Regs
	dc.l	$00007E00		;8/968							d0
;	dc.w	$FF80		;a8/8c8							d1
;	dc.w	$FFC0		;148/828						d2
;	dc.w	$FFE0		;1e8/788						d3
	
;	dc.l	$000C0003	;320/640						d4
	dc.l	$1FF0E000	;328/648						d5
	dc.l	$00060001	;280/6e0						d6
	dc.l	$00010000	;280/6e0						d7
;	dc.l	$3FE0C000	;288/6e8						a1
	dc.l	$000B0007	;3c0/460/500/5a0				a2
	dc.l	$8FF0F000	;3c8/468/508/5a8				a3
;set
;	dc.l	$3FE0C000	;328/648						a1
;	dc.l	$000C0003	;280/6e0						d4



sprite12or_new
	REPT loop_sprites12
		add.w	(a6)+,a0
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d6,$a0(a0)
		or.w	d6,$8c0(a0)
		or.w	d1,$a8(a0)
		or.w	d1,$8c8(a0)
		or.w	d4,$140(a0)
		or.w	d4,$820(a0)
		or.w	d2,$148(a0)
		or.w	d2,$828(a0)
		or.w	d3,$1e8(a0)
		or.w	d3,$788(a0)
		or.l	d6,$280(a0)
		or.l	d6,$6e0(a0)
		or.l	d5,$328(a0)
		or.l	d5,$648(a0)
		or.l	d4,$320(a0)
		or.l	d4,$640(a0)
		move.l	a1,d7
		or.l	d7,$288(a0)
		or.l	d7,$6e8(a0)
		move.l	a2,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		move.l	a3,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite12												; same as sprite11
start13
	moveq	#-16,d1
	movem.l	.sprite13Regs,d0/d4/a1/a2
	move.w	(a6)+,a5
	jmp		sprite13or_new(pc,a5)
.sprite13Regs	
	dc.l	$00003F00	;8/968							d0
;	dc.w	$FFF0		;1e8/788						d1
;	dc.w	$FFC0		;a8/8c8							d2
;	dc.w	$FFE0		;148/828						d3
	dc.l	$0FF8F000	;328/648						d4
;	dc.l	$1FF0E000	;288/6e8						d5
;	dc.l	$00060001	;320/640						d6
	dc.l	$00050003	;3c0/460/500/5a0				a1
	dc.l	$C7F8F800	;3c8/468/508/5a8				a2
;set
;	dc.l	$1FF0E000	;328/648						d5
;	dc.l	$00060001	;280/6e0						d6
;	dc.w	$FFC0		;148/828						d2
;	dc.w	$FFE0		;1e8/788						d3
sprite13or_new
	REPT loop_sprites13
		add.w	(a6)+,a0
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d2,$a8(a0)
		or.w	d2,$8c8(a0)
		or.w	d6,$140(a0)
		or.w	d6,$820(a0)
		or.w	d3,$148(a0)
		or.w	d3,$828(a0)
		or.w	d1,$1e8(a0)
		or.w	d1,$788(a0)
		or.l	d5,$288(a0)
		or.l	d5,$6e8(a0)
		or.l	d6,$320(a0)
		or.l	d6,$640(a0)
		or.l	d4,$328(a0)
		or.l	d4,$648(a0)
		move.l	a1,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$280(a0)
		or.w	d7,$6e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		move.l	a2,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite13
start14
	moveq	#-8,d3
	moveq	#3,d4
	movem.l	.sprite14Regs,d0/d2/d5-d6/a1/a2
	move.w	(a6)+,a5
	jmp		sprite14or_new(pc,a5)
.sprite14Regs
	dc.l	$00001F80		;8/968							d0
;	dc.w	$FFF0		;148/828						d1
	dc.l	$00007FE0		;a8/8c8							d2
;	dc.w	$FFF8		;1e8/788						d3
;	dc.w	$0003		;320/640						d4
	dc.l	$8FF87000	;288/6e8						d5
	dc.l	$07FCF800	;328/648						d6
	dc.l	$00020001	;3c0/460/500/5a0				a1
	dc.l	$E3FCFC00	;3c8/468/508/5a8				a2

sprite14or_new
	REPT loop_sprites14
		add.w	(a6)+,a0
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d2,$a8(a0)
		or.w	d2,$8c8(a0)
		or.w	d1,$148(a0)
		or.w	d1,$828(a0)
		or.w	d3,$1e8(a0)
		or.w	d3,$788(a0)
		or.w	d4,$320(a0)
		or.w	d4,$640(a0)
		or.l	d5,$288(a0)
		or.l	d5,$6e8(a0)
		or.l	d6,$328(a0)
		or.l	d6,$648(a0)
		move.l	a1,d7
		or.w	d7,$1e0(a0)
		or.w	d7,$280(a0)
		or.w	d7,$6e0(a0)
		or.w	d7,$780(a0)
		or.l	d7,$3c0(a0)
		or.l	d7,$460(a0)
		or.l	d7,$500(a0)
		or.l	d7,$5a0(a0)
		move.l	a2,d7
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite14	
start15
	lea		.sprite15Regs,a5
	movem.w	(a5)+,d0-d3
	movem.l	(a5)+,d5-d7
	move.w	(a6)+,a5
	jmp		sprite15or_new(pc,a5)
.sprite15Regs	
	dc.w	$0FC0		;8/968						d0
	dc.w	$3FF0		;a8/8c8						d1
	dc.w	$7FF8		;148/828					d2
	dc.w	$FFFC		;1e8/788					d3

	dc.l	$C7FC3800	;288/6e8					d5
	dc.l	$83FE7C00	;328/648					d6
	dc.l	$71FEFE00	;3c8/468/508/5a8			d7

sprite15or_new
	REPT loop_sprites15
		add.w	(a6)+,a0
		or.w	d0,$8(a0)
		or.w	d0,$968(a0)
		or.w	d1,$a8(a0)
		or.w	d1,$8c8(a0)
		or.w	d2,$148(a0)
		or.w	d2,$828(a0)
		or.w	d3,$1e8(a0)
		or.w	d3,$788(a0)
		bset	d7,$320+1(a0)
		bset	d7,$3c0+1(a0)
		bset	d7,$460+1(a0)
		bset	d7,$500+1(a0)
		bset	d7,$5a0+1(a0)
		bset	d7,$640+1(a0)
		or.l	d5,$288(a0)
		or.l	d5,$6e8(a0)
		or.l	d6,$328(a0)
		or.l	d6,$648(a0)
		or.l	d7,$3c8(a0)
		or.l	d7,$468(a0)
		or.l	d7,$508(a0)
		or.l	d7,$5a8(a0)
	ENDR
sprite15
			add.w	#4,frameListOff
			cmp.w	#4*360,frameListOff
			bne		.ok
				move.w	#0,frameListOff
.ok
		IFEQ	showRasters
			move.w	d0,$ffff8240.w
		ELSE
			REPT 3
				nop
			ENDR
		ENDC
;;;;;;; scroller
	move.l	usp,a0
	lea		-2(a0),a0
	move.l	scrollPosition,a1
.x set 6+193*160
    REPT 5
.y set .x 
    REPT 10
        move.l  (a1)+,.y(a0)
.y set .y+16
    ENDR
    lea    400(a1),a1					;5*2
.x set .x+160
    ENDR

    add.l   #2200,scrollPosition
    subq.w  #1,scrollCounter
    bne     .sok
        add.l   #2-16*2200,scrollPosition
        move.w  #16,scrollCounter
        sub.w   #1,scrollLoop
        bne     .sok
            move.w  #180,scrollLoop
            move.l  #scrollBuffer+40,scrollPosition
.sok    

	subq.w	#1,stab							;20
	bne		.skip							;12/8
;		move.b	#0,$ffffc123
		move.w	#40*16,stab					;20				
            REPT 230-4	;-15 before
            	or.l	d7,d7
            ENDR		
;            nop
.skip


	rts

scrollBuffer   	incbin	data/spkrites/scrollerfin2.bin
;				ds.b	500000
scrollPosition	dc.l	scrollBuffer
scrollCounter	dc.w	16
scrollLoop		dc.w	200
stab			dc.w	40*16


nextCode
	addq.w	#8,a0
	move.w	(a6)+,a5
	jmp		(a5)
	rts

genClearCode
	lea		genCodeData,a0
	lea		1024-8,a1
	move.l	a1,a2
	move.w	#160,d1				; for muls and add

	move.l	nextCode,(a1)+
	move.l	nextCode+4,(a1)+

.start
	moveq	#0,d0
	move.b	(a0)+,d0			; starting offset, in byte
	subq.w	#1,d0
	muls	d1,d0				; multiply by 160 so that we have the `ending situation'
	moveq	#0,d7				; 
	move.b	(a0)+,d7			; get number of lines we have to go on top; always > 0
	blt		.end				; if <0, we've reached the end
	subq.w	#1,d7
	move.w	d7,d6				; use d6 for offset
	muls	d1,d6				; *160 for offset
	sub.w	d6,d0				; move the offset `up'
.doIter
.loop
	tst.w	d7
	beq		.last
.notLast
		move.w	.op,(a1)+
		move.w	d0,(a1)+
		add.w	d1,d0
	dbra	d7,.loop
.last
	move.w	.op,(a1)+	; move operation to buffer
	move.w	d0,(a1)+	; move offset to buffer
	move.l	.op+4,(a1)+

	; write operation and offset to buffer
	jmp		.start
.end
	rts	
.op
	move.l	d0,1(a0)
	move.w	(a6)+,a5
	jmp		(a5)

genCodeData
	dc.b	1,1
	dc.b	2,2
	dc.b	3,3
	dc.b	4,4
	dc.b	5,5
	dc.b	6,6
	dc.b	7,7
	dc.b	8,8
	dc.b	9,9
	dc.b	10,10
	dc.b	11,10
	dc.b	12,12
	dc.b	13,12
	dc.b	14,13
	dc.b	15,15
	dc.b	16,16
	dc.b	17,17
	dc.b	18,18
	dc.b	19,18
	dc.b	20,20
	dc.b	21,21
	dc.b	22,18
	dc.b	23,23
	dc.b	24,18
	dc.b	25,23
	dc.b	26,22
	dc.b	27,24
	dc.b	28,27
	dc.b	29,20
	dc.b	30,30
	dc.b	31,31
	dc.b	32,28
	dc.b	33,28
	dc.b	34,31
	dc.b	35,31
	dc.b	36,21
	dc.b	37,34
	dc.b	38,30
	dc.b	39,26
	dc.b	40,35
	dc.b	41,26
	dc.b	42,28
	dc.b	43,30
	dc.b	44,31
	dc.b	45,40
	dc.b	46,37
	dc.b	47,41
	dc.b	48,27
	dc.b	49,28
	dc.b	50,31
	dc.b	51,26
	dc.b	52,26
	dc.b	53,32
	dc.b	54,31
	dc.b	55,34
	dc.b	56,43
	dc.b	57,39
	dc.b	58,30
	dc.b	59,40
	dc.b	60,41
	dc.b	61,48
	dc.b	62,34
	dc.b	63,36
	dc.b	64,38
	dc.b	65,42
	dc.b	66,25
	dc.b	67,32
	dc.b	68,28
	dc.b	69,25
	dc.b	70,30
	dc.b	71,38
	dc.b	72,39
	dc.b	73,31
	dc.b	74,49
	dc.b	75,41
	dc.b	76,49
	dc.b	77,40
	dc.b	78,49
	dc.b	79,37
	dc.b	80,26
	dc.b	81,33
	dc.b	82,35
	dc.b	83,40
	dc.b	84,29
	dc.b	85,52
	dc.b	86,27
	dc.b	87,45
	dc.b	88,59
	dc.b	89,40
	dc.b	90,30
	dc.b	91,57
	dc.b	92,36
	dc.b	93,40
	dc.b	94,43
	dc.b	95,44
	dc.b	96,31
	dc.b	97,36
	dc.b	98,30
	dc.b	99,42
	dc.b	100,30
	dc.b	101,48
	dc.b	102,61
	dc.b	103,33
	dc.b	104,33
	dc.b	105,26
	dc.b	106,38
	dc.b	107,53
	dc.b	108,34
	dc.b	109,50
	dc.b	110,32
	dc.b	111,31
	dc.b	112,39
	dc.b	113,38
	dc.b	114,40
	dc.b	115,36
	dc.b	116,40
	dc.b	117,32
	dc.b	118,39
	dc.b	119,32
	dc.b	120,27
	dc.b	121,28
	dc.b	122,50
	dc.b	123,48
	dc.b	124,34
	dc.b	125,33
	dc.b	126,35
	dc.b	127,45
	dc.b	128,41
	dc.b	129,44
	dc.b	130,36
	dc.b	131,44
	dc.b	132,71
	dc.b	133,29
	dc.b	134,35
	dc.b	135,37
	dc.b	136,33
	dc.b	137,41
	dc.b	138,28
	dc.b	139,44
	dc.b	140,46
	dc.b	141,24
	dc.b	142,60
	dc.b	143,42
	dc.b	144,35
	dc.b	145,29
	dc.b	146,40
	dc.b	147,46
	dc.b	148,40
	dc.b	149,37
	dc.b	150,30
	dc.b	151,42
	dc.b	152,34
	dc.b	153,49
	dc.b	154,32
	dc.b	155,47
	dc.b	156,35
	dc.b	157,36
	dc.b	158,43
	dc.b	159,48
	dc.b	160,44
	dc.b	161,50
	dc.b	162,49
	dc.b	163,46
	dc.b	164,36
	dc.b	165,35
	dc.b	166,47
	dc.b	167,44
	dc.b	168,43
	dc.b	169,54
	dc.b	170,34
	dc.b	171,49
	dc.b	172,47
	dc.b	173,45
	dc.b	174,42
	dc.b	175,45
	dc.b	176,39
	dc.b	177,25
	dc.b	178,43
	dc.b	179,27
	dc.b	180,33
	dc.b	181,29
	dc.b	182,25
	dc.b	183,23
	dc.b	184,25
	dc.b	185,36
	dc.b	186,26
	dc.b	187,18
	dc.b	188,39
	dc.b	189,33
	dc.b	190,23
	dc.b	191,19
	dc.b	0,-1




	IFEQ	genScroller
prepScroll
    lea     scroll+128+76*160,a0
    lea     scrollBuffer,a1
    move.l	a1,a2

.x set 0
    REPT 5
.t set 0
        REPT 11                  ; 3 times
.y set .x+.t
            REPT 10
                move.w  .y(a0),(a1)+
                move.w  .y+8(a0),(a1)+
.y set .y+16
            ENDR
.t set .t+5*160
        ENDR
.x set .x+160
    ENDR




    lea     scrollBuffer,a0
    move.w  #15-1,d7
.doShift
    lea 2200(a0),a1
.y set 440
    REPT 5
.x set .y
    moveq   #0,d0
    roxl.l  d0
    REPT 110
.x set .x-4
        move.l  .x(a0),d0
        roxl.l  d0
        move.l  d0,.x(a1)
    ENDR
.y set .y+440
    ENDR


    lea 2200(a0),a0

    dbra    d7,.doShift
    sub.l	a2,a1
    add.l	#2200,a1
    lea     scrollBuffer,a0
    move.b  #0,$ffffc123
	rts
scroll	incbin	data/spkrites/scroll.neo
	ENDC

;	section DATA
    IFEQ    STANDALONE
        include     lib/libdata.s
    ENDC

	IFEQ	USE_YM
		IFNE	YM_DELTA
music		incbin	msx/sos.1b
		ELSE
music		
		;incbin	msx/sosdelta.ym
		incbin	msx/soschildelta.ym
		ENDC
	ELSE
sos			incbin	msx/smaggn3.snd
	ENDC



	include	data/spkrites/analysis/268/final.s
;prepTile
;	lea		tile+128,a0
;	lea		tilebuff,a1
;.y set 0
;	REPT 16
;.x set .y
;		REPT 4
;			move.l	.x(a0),(a1)+
;			move.l	.x+4(a0),(a1)+
;.x set .x+8
;		ENDR
;.y set .y+160
;	ENDR
;	lea		tilebuff,a0
;	move.b	#0,$ffffc123
;	rts
;tile
;	incbin	gfx/sote.neo

tilebuff	incbin 	data/spkrites/tilebuff.bin
	

frameListClear
	dc.l	clearframe_0
	dc.l	clearframe_1
	dc.l	clearframe_2
	dc.l	clearframe_3
	dc.l	clearframe_4
	dc.l	clearframe_5
	dc.l	clearframe_6
	dc.l	clearframe_7
	dc.l	clearframe_8
	dc.l	clearframe_9
	dc.l	clearframe_10
	dc.l	clearframe_11
	dc.l	clearframe_12
	dc.l	clearframe_13
	dc.l	clearframe_14
	dc.l	clearframe_15
	dc.l	clearframe_16
	dc.l	clearframe_17
	dc.l	clearframe_18
	dc.l	clearframe_19
	dc.l	clearframe_20
	dc.l	clearframe_21
	dc.l	clearframe_22
	dc.l	clearframe_23
	dc.l	clearframe_24
	dc.l	clearframe_25
	dc.l	clearframe_26
	dc.l	clearframe_27
	dc.l	clearframe_28
	dc.l	clearframe_29
	dc.l	clearframe_30
	dc.l	clearframe_31
	dc.l	clearframe_32
	dc.l	clearframe_33
	dc.l	clearframe_34
	dc.l	clearframe_35
	dc.l	clearframe_36
	dc.l	clearframe_37
	dc.l	clearframe_38
	dc.l	clearframe_39
	dc.l	clearframe_40
	dc.l	clearframe_41
	dc.l	clearframe_42
	dc.l	clearframe_43
	dc.l	clearframe_44
	dc.l	clearframe_45
	dc.l	clearframe_46
	dc.l	clearframe_47
	dc.l	clearframe_48
	dc.l	clearframe_49
	dc.l	clearframe_50
	dc.l	clearframe_51
	dc.l	clearframe_52
	dc.l	clearframe_53
	dc.l	clearframe_54
	dc.l	clearframe_55
	dc.l	clearframe_56
	dc.l	clearframe_57
	dc.l	clearframe_58
	dc.l	clearframe_59
	dc.l	clearframe_60
	dc.l	clearframe_61
	dc.l	clearframe_62
	dc.l	clearframe_63
	dc.l	clearframe_64
	dc.l	clearframe_65
	dc.l	clearframe_66
	dc.l	clearframe_67
	dc.l	clearframe_68
	dc.l	clearframe_69
	dc.l	clearframe_70
	dc.l	clearframe_71
	dc.l	clearframe_72
	dc.l	clearframe_73
	dc.l	clearframe_74
	dc.l	clearframe_75
	dc.l	clearframe_76
	dc.l	clearframe_77
	dc.l	clearframe_78
	dc.l	clearframe_79
	dc.l	clearframe_80
	dc.l	clearframe_81
	dc.l	clearframe_82
	dc.l	clearframe_83
	dc.l	clearframe_84
	dc.l	clearframe_85
	dc.l	clearframe_86
	dc.l	clearframe_87
	dc.l	clearframe_88
	dc.l	clearframe_89
	dc.l	clearframe_90
	dc.l	clearframe_91
	dc.l	clearframe_92
	dc.l	clearframe_93
	dc.l	clearframe_94
	dc.l	clearframe_95
	dc.l	clearframe_96
	dc.l	clearframe_97
	dc.l	clearframe_98
	dc.l	clearframe_99
	dc.l	clearframe_100
	dc.l	clearframe_101
	dc.l	clearframe_102
	dc.l	clearframe_103
	dc.l	clearframe_104
	dc.l	clearframe_105
	dc.l	clearframe_106
	dc.l	clearframe_107
	dc.l	clearframe_108
	dc.l	clearframe_109
	dc.l	clearframe_110
	dc.l	clearframe_111
	dc.l	clearframe_112
	dc.l	clearframe_113
	dc.l	clearframe_114
	dc.l	clearframe_115
	dc.l	clearframe_116
	dc.l	clearframe_117
	dc.l	clearframe_118
	dc.l	clearframe_119
	dc.l	clearframe_120
	dc.l	clearframe_121
	dc.l	clearframe_122
	dc.l	clearframe_123
	dc.l	clearframe_124
	dc.l	clearframe_125
	dc.l	clearframe_126
	dc.l	clearframe_127
	dc.l	clearframe_128
	dc.l	clearframe_129
	dc.l	clearframe_130
	dc.l	clearframe_131
	dc.l	clearframe_132
	dc.l	clearframe_133
	dc.l	clearframe_134
	dc.l	clearframe_135
	dc.l	clearframe_136
	dc.l	clearframe_137
	dc.l	clearframe_138
	dc.l	clearframe_139
	dc.l	clearframe_140
	dc.l	clearframe_141
	dc.l	clearframe_142
	dc.l	clearframe_143
	dc.l	clearframe_144
	dc.l	clearframe_145
	dc.l	clearframe_146
	dc.l	clearframe_147
	dc.l	clearframe_148
	dc.l	clearframe_149
	dc.l	clearframe_150
	dc.l	clearframe_151
	dc.l	clearframe_152
	dc.l	clearframe_153
	dc.l	clearframe_154
	dc.l	clearframe_155
	dc.l	clearframe_156
	dc.l	clearframe_157
	dc.l	clearframe_158
	dc.l	clearframe_159
	dc.l	clearframe_160
	dc.l	clearframe_161
	dc.l	clearframe_162
	dc.l	clearframe_163
	dc.l	clearframe_164
	dc.l	clearframe_165
	dc.l	clearframe_166
	dc.l	clearframe_167
	dc.l	clearframe_168
	dc.l	clearframe_169
	dc.l	clearframe_170
	dc.l	clearframe_171
	dc.l	clearframe_172
	dc.l	clearframe_173
	dc.l	clearframe_174
	dc.l	clearframe_175
	dc.l	clearframe_176
	dc.l	clearframe_177
	dc.l	clearframe_178
	dc.l	clearframe_179
	dc.l	clearframe_180
	dc.l	clearframe_181
	dc.l	clearframe_182
	dc.l	clearframe_183
	dc.l	clearframe_184
	dc.l	clearframe_185
	dc.l	clearframe_186
	dc.l	clearframe_187
	dc.l	clearframe_188
	dc.l	clearframe_189
	dc.l	clearframe_190
	dc.l	clearframe_191
	dc.l	clearframe_192
	dc.l	clearframe_193
	dc.l	clearframe_194
	dc.l	clearframe_195
	dc.l	clearframe_196
	dc.l	clearframe_197
	dc.l	clearframe_198
	dc.l	clearframe_199
	dc.l	clearframe_200
	dc.l	clearframe_201
	dc.l	clearframe_202
	dc.l	clearframe_203
	dc.l	clearframe_204
	dc.l	clearframe_205
	dc.l	clearframe_206
	dc.l	clearframe_207
	dc.l	clearframe_208
	dc.l	clearframe_209
	dc.l	clearframe_210
	dc.l	clearframe_211
	dc.l	clearframe_212
	dc.l	clearframe_213
	dc.l	clearframe_214
	dc.l	clearframe_215
	dc.l	clearframe_216
	dc.l	clearframe_217
	dc.l	clearframe_218
	dc.l	clearframe_219
	dc.l	clearframe_220
	dc.l	clearframe_221
	dc.l	clearframe_222
	dc.l	clearframe_223
	dc.l	clearframe_224
	dc.l	clearframe_225
	dc.l	clearframe_226
	dc.l	clearframe_227
	dc.l	clearframe_228
	dc.l	clearframe_229
	dc.l	clearframe_230
	dc.l	clearframe_231
	dc.l	clearframe_232
	dc.l	clearframe_233
	dc.l	clearframe_234
	dc.l	clearframe_235
	dc.l	clearframe_236
	dc.l	clearframe_237
	dc.l	clearframe_238
	dc.l	clearframe_239
	dc.l	clearframe_240
	dc.l	clearframe_241
	dc.l	clearframe_242
	dc.l	clearframe_243
	dc.l	clearframe_244
	dc.l	clearframe_245
	dc.l	clearframe_246
	dc.l	clearframe_247
	dc.l	clearframe_248
	dc.l	clearframe_249
	dc.l	clearframe_250
	dc.l	clearframe_251
	dc.l	clearframe_252
	dc.l	clearframe_253
	dc.l	clearframe_254
	dc.l	clearframe_255
	dc.l	clearframe_256
	dc.l	clearframe_257
	dc.l	clearframe_258
	dc.l	clearframe_259
	dc.l	clearframe_260
	dc.l	clearframe_261
	dc.l	clearframe_262
	dc.l	clearframe_263
	dc.l	clearframe_264
	dc.l	clearframe_265
	dc.l	clearframe_266
	dc.l	clearframe_267
	dc.l	clearframe_268
	dc.l	clearframe_269
	dc.l	clearframe_270
	dc.l	clearframe_271
	dc.l	clearframe_272
	dc.l	clearframe_273
	dc.l	clearframe_274
	dc.l	clearframe_275
	dc.l	clearframe_276
	dc.l	clearframe_277
	dc.l	clearframe_278
	dc.l	clearframe_279
	dc.l	clearframe_280
	dc.l	clearframe_281
	dc.l	clearframe_282
	dc.l	clearframe_283
	dc.l	clearframe_284
	dc.l	clearframe_285
	dc.l	clearframe_286
	dc.l	clearframe_287
	dc.l	clearframe_288
	dc.l	clearframe_289
	dc.l	clearframe_290
	dc.l	clearframe_291
	dc.l	clearframe_292
	dc.l	clearframe_293
	dc.l	clearframe_294
	dc.l	clearframe_295
	dc.l	clearframe_296
	dc.l	clearframe_297
	dc.l	clearframe_298
	dc.l	clearframe_299
	dc.l	clearframe_300
	dc.l	clearframe_301
	dc.l	clearframe_302
	dc.l	clearframe_303
	dc.l	clearframe_304
	dc.l	clearframe_305
	dc.l	clearframe_306
	dc.l	clearframe_307
	dc.l	clearframe_308
	dc.l	clearframe_309
	dc.l	clearframe_310
	dc.l	clearframe_311
	dc.l	clearframe_312
	dc.l	clearframe_313
	dc.l	clearframe_314
	dc.l	clearframe_315
	dc.l	clearframe_316
	dc.l	clearframe_317
	dc.l	clearframe_318
	dc.l	clearframe_319
	dc.l	clearframe_320
	dc.l	clearframe_321
	dc.l	clearframe_322
	dc.l	clearframe_323
	dc.l	clearframe_324
	dc.l	clearframe_325
	dc.l	clearframe_326
	dc.l	clearframe_327
	dc.l	clearframe_328
	dc.l	clearframe_329
	dc.l	clearframe_330
	dc.l	clearframe_331
	dc.l	clearframe_332
	dc.l	clearframe_333
	dc.l	clearframe_334
	dc.l	clearframe_335
	dc.l	clearframe_336
	dc.l	clearframe_337
	dc.l	clearframe_338
	dc.l	clearframe_339
	dc.l	clearframe_340
	dc.l	clearframe_341
	dc.l	clearframe_342
	dc.l	clearframe_343
	dc.l	clearframe_344
	dc.l	clearframe_345
	dc.l	clearframe_346
	dc.l	clearframe_347
	dc.l	clearframe_348
	dc.l	clearframe_349
	dc.l	clearframe_350
	dc.l	clearframe_351
	dc.l	clearframe_352
	dc.l	clearframe_353
	dc.l	clearframe_354
	dc.l	clearframe_355
	dc.l	clearframe_356
	dc.l	clearframe_357
	dc.l	clearframe_358
	dc.l	clearframe_359

screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
saveda7				ds.l	1
memBase             ds.b   	32000*2+256
stack				
;    section BSS

;   IFEQ    STANDALONE
;  ENDC
