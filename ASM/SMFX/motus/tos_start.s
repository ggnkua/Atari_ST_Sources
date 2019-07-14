

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

    section	DATA

	include macro.s

	IFEQ	STANDALONE
			initAndRun	init_effect

init_effect
	jsr		init_demo
	jsr		init_tos_start


.demostart


	
.x
    cmp.b   #$39,$fffffc02.w                                ; spacebar to exit
    bne     .x                                       ;

	rts



init_demo
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	jsr		musicPlayer
	rts
	ENDC

masksRight
	dc.w	%0
	dc.w	%1000000000000000	
	dc.w	%1100000000000000	
	dc.w	%1110000000000000	
	dc.w	%1111000000000000	
	dc.w	%1111100000000000	
	dc.w	%1111110000000000	
	dc.w	%1111111000000000	
	dc.w	%1111111100000000	
	dc.w	%1111111110000000	
	dc.w	%1111111111000000	
	dc.w	%1111111111100000	
	dc.w	%1111111111110000	
	dc.w	%1111111111111000	
	dc.w	%1111111111111100	
	dc.w	%1111111111111110	
	dc.w	%1111111111111111

masksLeft
	dc.w	0
	dc.w	%0000000000000001	
	dc.w	%0000000000000011	
	dc.w	%0000000000000111	
	dc.w	%0000000000001111	
	dc.w	%0000000000011111	
	dc.w	%0000000000111111	
	dc.w	%0000000001111111	
	dc.w	%0000000011111111	
	dc.w	%0000000111111111	
	dc.w	%0000001111111111	
	dc.w	%0000011111111111	
	dc.w	%0000111111111111	
	dc.w	%0001111111111111	
	dc.w	%0011111111111111	
	dc.w	%0111111111111111	
	dc.w	%1111111111111111	

myLine	ds.b	40

generateLine
	tst.w	wobbleOff
	blt		.end

	; reset line
	lea		myLine,a0
	moveq	#0,d0
	move.w	#10-1,d7
.cl
		move.l	d0,(a0)+
	dbra	d7,.cl


	lea		wobble,a2
	add.w	wobbleOff,a2
	moveq	#0,d7
	move.w	(a2),d7
	add.w	wobbleBase,d7
	subq.w	#1,d7
	cmp.w	#137,d7
	ble		.ok
.do137
		move.w	#137,d7
.ok
	; now we have number of pixels to be drawn left right

	lea		myLine,a0
	lea		20(a0),a0
	move.l	a0,a1

	move.l	d7,d6
	lsr.l	#4,d6
	subq.w	#1,d6
	blt		.none
	moveq	#-1,d0
.do16
		move.w	d0,(a0)+
		move.w	d0,-(a1)
	dbra	d6,.do16
.none
	and.w	#%1111,d7
	add.w	d7,d7
	lea		masksLeft,a2
	lea		masksRight,a3
	move.w	(a2,d7),-(a1)
	move.w	(a3,d7),(a0)+

	; now we have the line, lets copy it
	move.l	screenpointer2,a0
	lea		myLine,a3
	movem.w	(a3)+,d0-d6/a1-a2/a4		; 8 + 6 = 10

	move.w	#200-1,d7

.lll
.x set 0
;	REPT 200
		move.w	d0,.x(a0)
		move.w	d1,8+.x(a0)
		move.w	d2,16+.x(a0)
		move.w	d3,24+.x(a0)
		move.w	d4,32+.x(a0)
		move.w	d5,40+.x(a0)
		move.w	d6,48+.x(a0)
		move.w	a1,56+.x(a0)
		move.w	a2,64+.x(a0)
		move.w	a4,72+.x(a0)
.x set .x+160
;	ENDR
	lea		160(a0),a0
	dbra	d7,.lll
;	add.l	#160*200,a0

	move.w	#73-1,d7
.lll2
.x set 0
;	REPT 73
		move.w	d0,.x(a0)
		move.w	d1,8+.x(a0)
		move.w	d2,16+.x(a0)
		move.w	d3,24+.x(a0)
		move.w	d4,32+.x(a0)
		move.w	d5,40+.x(a0)
		move.w	d6,48+.x(a0)
		move.w	a1,56+.x(a0)
		move.w	a2,64+.x(a0)
		move.w	a4,72+.x(a0)
.x set .x+160
;	ENDR
	lea		160(a0),a0
	dbra	d7,.lll2

	sub.l	#160*273,a0

	movem.w	(a3)+,d0-d6/a1-a2/a4		; 8 + 6 = 10
	move.w	#200-1,d7
.lll3
.x set 80
;	REPT 200
		move.w	d0,.x(a0)
		move.w	d1,8+.x(a0)
		move.w	d2,16+.x(a0)
		move.w	d3,24+.x(a0)
		move.w	d4,32+.x(a0)
		move.w	d5,40+.x(a0)
		move.w	d6,48+.x(a0)
		move.w	a1,56+.x(a0)
		move.w	a2,64+.x(a0)
		move.w	a4,72+.x(a0)
.x set .x+160
;	ENDR
	lea		160(a0),a0
	dbra	d7,.lll3

;	add.l	#160*200,a0

	move.w	#73-1,d7
.lll4
.x set 80
;	REPT 73
		move.w	d0,.x(a0)
		move.w	d1,8+.x(a0)
		move.w	d2,16+.x(a0)
		move.w	d3,24+.x(a0)
		move.w	d4,32+.x(a0)
		move.w	d5,40+.x(a0)
		move.w	d6,48+.x(a0)
		move.w	a1,56+.x(a0)
		move.w	a2,64+.x(a0)
		move.w	a4,72+.x(a0)
.x set .x+160
;	ENDR
	lea		160(a0),a0
	dbra	d7,.lll4
.end
	rts

init_tos_start
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screen2,d0
	add.l	#$10000,d0
	move.l	screenpointer2,a0
	move.l	a0,$ffff8200
	rept 8
		move.b	#-1,(a0)
		move.b	#-1,2(a0)
		move.b	#-1,4(a0)
		move.b	#-1,6(a0)
		add.w	#160,a0
	ENDR

	move.w	#0,$ffff8242
;	move.l	screenpointer2,a0
;	move.w	#-1,152(a0)
;	add.l	#273*160,a0
;	move.w	#-1,152(a0)
;	move.w	#-1,152-10*160(a0)


    move.w  #$2700,sr
    move.l  #.wvbl,$70
	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
	move.l	#timer_b_openbottom,$120.w			;Install our own Timer B
    move.w  #$2300,sr

.tt
    tst.w	.cont
    beq		.tt

    move.w  #$2700,sr
    move.l  #.wvbl2,$70
	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
    move.w  #$2300,sr


    rts
.cont	dc.w	0
.wvbl
;    IFNE	STANDALONE
		addq.w	#1,$466.w
		addq.w	#1,cummulativeCount
    	pushall
    	jsr		musicPlayer+8
    	moveq	#0,d0
    	move.b	musicPlayer+$b8,d0
    	cmp.w	#1,d0
    	bne		.skip
    		lea		fade,a0
    		add.w	fadeoff,a0
    		move.w	(a0),$ffff8240+2*15
    		subq.w	#1,fadewait
    		bge		.skip
    			move.w	#2,fadewait
    			subq.w	#2,fadeoff
    			bge		.skip
    				move.w	#0,fadeoff
    				move.w	#-1,.cont
				    move.l	screenpointer2,$ffff8200
				    move.l	screenpointer2,a0
				    REPT 8
				    	move.b	#0,(a0)
				    	move.b	#0,2(a0)
				    	move.b	#0,4(a0)
				    	move.b	#0,6(a0)
				    	add.w	#160,a0
				    ENDR
				    move.b	#0,musicPlayer+$b8

.skip
    	popall
;    ENDC
	rte

.wvbl2
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
    move.l	screenpointer,$ffff8200
    		swapscreens
    tst.w	rasterList
    beq		.doBlack
.doWhite
		move.w	#-1,$fff8240
		jmp		.ccc
.doBlack
		move.w	#0,$ffff8240
.ccc
			schedule_timerA_topBorder

;    clr.b   $fffffa1b.w         ;Timer B control (stop)
;    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
;    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
;	move.l	#timer_b_openbottom,$120.w			;Install our own Timer B
;    move.b  #229,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
;    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
;	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	move.w	#227,timer_b_counter
	move.l	#rasterList,ptr

	clr.b   $fffffa1b.w         ;Timer B control (stop)
	bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
	bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
	move.l	#timer_b_top,$120.w			;Install our own Timer B

	move.b  #1,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	jsr		generateRasterList
;    IFNE	STANDALONE
    	jsr		musicPlayer+8
    	moveq	#0,d0
    	move.b	musicPlayer+$b8,d0
    	beq		.skip2
    		add.w	#2,sizeOff
    		move.w	#0,wobbleOff
    		add.w	#28,wobbleBase
    		move.b	#0,musicPlayer+$b8	
.skip2
	jsr		generateLine
;    ENDC
    rte

generateRasterList
	lea		rasterList,a0
	move.l	a0,a1
	move.l	#-1,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	lea		274*2(a0),a0			;548
	move.w	#13-1,d7				;520
.clear
		movem.l	d0-d6/a2-a4,-(a0)
	dbra	d7,.clear
	movem.l	d0-d5,-(a0)

	tst.w	wobbleOff
	blt		.end
	lea		rasterList,a0
	moveq	#0,d0
	add.w	#137*2,a0
	lea		-2(a0),a1
	tst.w	.herp
	beq		.do137
	lea		wobble,a2
	add.w	wobbleOff,a2
	move.w	(a2),d7
	add.w	wobbleBase,d7
	subq.w	#1,d7
	cmp.w	#137,d7
	ble		.ok
.do137
		move.w	#137,d7
		move.w	#0,.herp
.ok
.x
		move.w	#0,-(a0)
		move.w	#0,(a1)+
	dbra	d7,.x
	move.w	#-1,(a1)+
	add.w	#2,wobbleOff
.end
	rts
.herp 	dc.w	-1


wobble
	dc.w	1
	dc.w	1
	dc.w	2
	dc.w	2
	dc.w	3
	dc.w	3
	dc.w	4
	dc.w	4
	dc.w	5
	dc.w	5
	dc.w	6
	dc.w	6
	dc.w	7
	dc.w	8
	dc.w	8
	dc.w	9
	dc.w	10
	dc.w	10
	dc.w	11
	dc.w	12
	dc.w	12
	dc.w	13
	dc.w	14
	dc.w	15
	dc.w	16
	dc.w	17
	dc.w	19
	dc.w	20
	dc.w	21
	dc.w	23
	dc.w	25
	dc.w	27
	dc.w	28
	dc.w	30
	dc.w	31
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	31
	dc.w	31
	dc.w	30
	dc.w	30
	dc.w	30
	dc.w	29
	dc.w	29
	dc.w	29
	dc.w	28
	dc.w	28
	dc.w	28
	REPT 100
		dc.w	28
	ENDR

wobbleBase	dc.w	-28

wobbleOff
	dc.w	-1




rasterList	
	REPT 276
		dc.w	-1
	ENDR

ptr				dc.l	rasterList
timer_b_counter	dc.w	227


size	dc.w	0

sizes	dc.w	1,35,70,105,137
sizeOff	dc.w	0

; 28 frames per time

;--------------
;DEMOPAL - tos block fade
;--------------
; - this is the fade for the tos pointer, using $fff for st/ste, going from highest offset to 0
fade
	dc.w 	$fff		;0
	dc.w	$667
	dc.w	$666
	dc.w	$665
	dc.w	$555
	dc.w	$544
	dc.w	$444
	dc.w	$334
	dc.w	$333
	dc.w	$332
	dc.w	$222
	dc.w	$112
	dc.w	$111
	dc.w	$110
	dc.w	$000		;14*2
fadeoff	dc.w 28
fadewait	dc.w	0

tos_start_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    	move.w	#0,$466
    	subq.w	#1,effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts

timer_a_opentop
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

timer_b_top
	pusha0
		move.l	ptr,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,ptr
	popa0

	subq.w	#1,timer_b_counter
	bge		.end	
		clr.b   $fffffa1b.w         ;Timer B control (stop)
		move.b  #1,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
		move.l	#timer_b_openbottom,$120.w			;Install our own Timer B
		move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
		bclr	#3,$fffffa17.w			;Automatic end of interrupt
		pusha0
			move.l	ptr,a0
			move.w	(a0)+,timer_b_smc+2
			move.l	a0,ptr
		popa0
.end
	rte


timer_b_openbottom
	clr.b	$ffff820a.w			;60 Hz
timer_b_smc
	move.w	#$555,$ffff8240.w
	REPT 5-4
		nop
	ENDR
	move.b	#2,$ffff820a.w			;50 Hz

	clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.b  #1,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_below,$120.w			;Install our own Timer B
	move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	rte


timer_b_below
	pusha0
		move.l	ptr,a0
		move.w	(a0)+,$ffff8240
		move.l	a0,ptr
	popa0
	rte
	
	section DATA

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
musicPlayer
	incbin	msx/MOTUS.SND
    ENDC






    IFEQ	STANDALONE
	section BSS
    rsreset
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC
