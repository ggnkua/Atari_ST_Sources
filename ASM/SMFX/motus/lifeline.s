

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
CHECK_VBL_OVERFLOW	equ 0
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
	jsr		init_lifeline


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
	rts
	ENDC



init_lifeline
	move.l	screen1,screenpointer
	move.l	screen2,screenpointer2
	move.l	screen2,d0
	add.l	#$10000,d0

	move.l	d0,buzzDataPointer
	add.l	#660,d0
	move.l	d0,lifeLinePointer
	add.l	#772,d0
	move.l	d0,bufferTopPointer
	add.l	#13920,d0
	move.l	d0,bufferTop2Pointer
	add.l	#312,d0
	move.l	d0,heat_bot0Pointer
	add.l	#4352,d0
	move.l	d0,heat_bot1Pointer
	add.l	#464,d0
	move.l	d0,heat_bot2Pointer
	add.l	#176,d0
	move.l	d0,heat_bot3Pointer
	add.l	#496,d0
	move.l	d0,copyLineBufferPointer
	add.l	#2950,d0
	move.l	d0,moveHeartCodePointer
	add.l	#3200,d0

	lea		buzzData,a0
	move.l	buzzDataPointer,a1
	jsr		cranker

	lea		lifeLine,a0
	move.l	lifeLinePointer,a1
	jsr		cranker

	lea		buffertop,a0
	move.l	bufferTopPointer,a1
	jsr		cranker

	lea		buffertop2,a0
	move.l	bufferTop2Pointer,a1
	jsr		cranker

	lea		heat_bot0,a0
	move.l	heat_bot0Pointer,a1
	jsr		cranker

	lea		heat_bot1,a0
	move.l	heat_bot1Pointer,a1
	jsr		cranker

	lea		heat_bot2,a0
	move.l	heat_bot2Pointer,a1
	jsr		cranker

	lea		heat_bot3,a0
	move.l	heat_bot3Pointer,a1
	jsr		cranker

	jsr		genCopyLine
	jsr		genMoveHeart

	movem.l	heart_top_pal,d0-d7
	movem.l	d0-d7,$ffff8240
	move.w	#0,$ffff8240+1*2


	move.l	screenpointer2,$ffff8200


    move.w  #$2700,sr
    move.l  #lifeline_vbl,$70
    move.w  #$2300,sr


    	rts
.wvbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount

	pushall
	IFNE	STANDALONE
		jsr		musicPlayer+8
	ENDC
	popall
    rte




lifeline_vbl
	move.w	#0,$ffff8240
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	move.l	screenpointer2,$ffff8200
	pushall
	jsr		doTextTimer					; this puts timers for the text in
	jsr		doLifeLineFlash				; this flashes the line
	jsr		doFadeOut					; this fades out all the shit
	jsr		clearTimes		
	jsr		drawTimes2

;	cmp.w	#200,currentPosition
;	bne		.skipcol
;		move.w	#$777,$ffff8240+1*2
;.skipcol

	IFNE	STANDALONE
	jsr		musicPlayer+8
	moveq	#0,d0
	move.b	musicPlayer+$b8,d0
	beq		.skip
		move.b	#0,musicPlayer+$b8	
		move.w	#-1,doCounter
.skip
	ENDC
	jsr		move_heart_top
	jsr		move_heart_top2
	jsr		doLifeLine
	jsr		drawCounter
    jsr		move_heart_bot
    jsr		move_heart_bot2
    jsr		move_heart_bot3
    jsr		move_heart_bot4
	jsr		buzz
	

	cmp.w	#44,counterOffset
		ble		.ok2

		add.w	#2,heartPathOff
		cmp.w	#69*2,heartPathOff
		ble		.ok2
			move.w	#69*2,heartPathOff
			subq.w	#1,.herp
			bge		.ok2
				move.w	#$4e75,move_heart_top
				move.w	#$4e75,move_heart_bot
				move.w	#$4e75,move_heart_bot2
				move.w	#$4e75,move_heart_bot3
				move.w	#$4e75,move_heart_bot4
.ok2

;	move.w	#$777,$fff8240

			swapscreens
	popall
	rte
.herp	dc.w	1

blackPal	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

doFadeOut
	subq.w	#1,.tt
	bge		.end
		move.w	#4,.tt
		lea		$ffff8240,a0
		lea		blackPal,a1
		move.l	a0,a2
		moveq	#16,d0
		jsr		fade22

			lea		textFadeTable,a0
			add.w	.textOff,a0
			lea		$ffff8240+2*8,a1
			move.w	(a0),d0
			move.w	d0,d1
			swap	d0
			move.w	d1,d0
			REPT 4
				move.l	d0,(a1)+
			ENDR

		subq.w	#1,.textOffWaiter
		bge		.end
			add.w	#2,.textOff
			cmp.w	#14,.textOff
			ble		.end
				move.w	#14,.textOff
.end
	rts
.tt			dc.w	620
			dc.w	0
.textOffWaiter	dc.w	3
.textOff		dc.w	0

fadeColorZ	dc.l	0
fadeColorZ2	dc.w	0

	dc.w	$777
textFadeTable	
	dc.w	$667
	dc.w	$556
	dc.w	$445
	dc.w	$334
	dc.w	$223
	dc.w	$112
	dc.w	$110
	dc.w	$000

	dc.w	$777
textFadeTable2
	dc.w	$667
	dc.w	$556
	dc.w	$445
	dc.w	$444
	dc.w	$333
	dc.w	$322
	dc.w	$311
	dc.w	$300

specialTable
	dc.w	$

textFadeTableOff	dc.w	7*2
textFadeTableOff2	dc.w	7*2

doTextTimer
	clr.b   $fffffa1b.w         ;Timer B control (stop)
	bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
	bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
	move.l	#timer_b_split,$120.w			;Install our own Timer B

	move.b  #92+50,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	lea		textFadeTable,a0
	add.w	textFadeTableOff,a0
	move.w	(a0),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0

	lea		$ffff8240+2*8,a0
	REPT 4
		move.l	d0,(a0)+
	ENDR	

	lea		textFadeTable2,a0
	add.w	textFadeTableOff2,a0
	move.w	(a0),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,fadeColorZ

	lea		textFadeTable,a0
	add.w	textFadeTableOff2,a0
	move.w	(a0),fadeColorZ2

	subq.w	#1,.tt1
	bge		.skip1
		move.w	#3,.tt1
		subq.w	#2,textFadeTableOff
		bge		.skip1
			move.w	#0,textFadeTableOff
.skip1

	subq.w	#1,.tt2
	bge		.skip2
		move.w	#-1,bottomLineShow
;		move.w	#2,.tt2
;		tst.w	.tt2direction
;		blt		.subst
;.addst
;		add.w	#2,textFadeTableOff2
;		cmp.w	#3*2,textFadeTableOff2
;		bne		.skip2
;			neg.w	.tt2direction
;			jmp		.skip2
.subst
		subq.w	#2,textFadeTableOff2
		bge		.skip2
			move.w	#0,textFadeTableOff2
;			subq.w	#1,.timess
;			blt		.skip2
;				neg.w	.tt2direction
.skip2

	subq.w	#1,.tt3
	bge		.skip3
		move.l	#dummy,$120
		move.w	#$4e75,doTextTimer
.skip3
	rts
.tt1	dc.w	425
.tt2	dc.w	490
.tt3	dc.w	600
.tt2direction	dc.w	-1
.timess	dc.w	2

bottomLineShow	dc.w	0

timer_b_split
	pusha0
	pushd0
	lea		$ffff8240+2*8,a0
	move.l	fadeColorZ,d0
	REPT 4
		move.l	d0,(a0)+
	ENDR
	move.w	fadeColorZ2,$ffff8240+2*8
	move.w	fadeColorZ2,$ffff8240+2*9
	popd0
	popa0
	rte


drawCounter
	tst.w	doCounter
	beq		.skip2
		lea		counterColour,a0
		add.w	counterOffset,a0
		move.w	(a0),$fff8240+2*1
		subq.w	#1,counterOffsetWaiter
		bge		.skip2
			move.w	#1,counterOffsetWaiter
			add.w	#2,counterOffset
			cmp.w	#44,counterOffset
			ble		.skip2
				subq.w	#1,.tframes
				bge		.doNormal
					add.w	#2,counterOffset
					cmp.w	#96,counterOffset
					ble		.skip2
						move.w	#96,counterOffset
						move.w	#$4e75,drawCounter
						move.w	#$4e75,drawTimes2
						move.w	#2,clearTimesTimes						
						jmp		.skip2
.doNormal
				move.w	#44,counterOffset
.skip2
	rts
.tframes	dc.w	170
clearTimesTimes	dc.w	31000

doCounter	dc.w	0
counterOffsetWaiter	dc.w	1
counterOffset	dc.w	0

;--------------
;DEMOPAL - counter fade in and highlight
;--------------
; - used to fadein the counter and fade it out again once no longer needed
; starts from 0, counts up
counterColour
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700		;14
	dc.w	$710,$721,$732,$743,$754,$765,$776,$777		;30
	dc.w	$777,$667,$557,$556,$446,$445,$335,$225		;46
	dc.w	$336,$336,$447,$447,$557,$557,$667,$667,$777,$777,$666,$666,$555,$555,$444,$444		;62
	dc.w	$333,$333,$222,$222,$111,$111,$000,$000,$000,$000,$000


lifeline_mainloop
    move.w  #0,$466
.w  tst.w   $466.w
    beq     .w
    IFEQ	CHECK_VBL_OVERFLOW
    	cmp.w	#2,$466.w
    	bne		.kkk
    		move.b	#0,$ffffc123
.kkk
	ENDC
    	move.w	#0,$466
    	subq.w	#1,effect_vbl_counter
    	blt		.next
    jmp		.w
.next
	rts


;;;;;;;;;;;;;;;; CODE EFFECT


_demoloopcounter	dc.l	1039
_cc					dc.w	50

clearTimes
	subq.w	#1,clearTimesTimes
	blt		.kill
	move.l	screenpointer2,a1
	add.l	#188*160+128,a1
	moveq	#0,d0
	move.w	#4-1,d7
.ol
y set 0
		rept 12
			move.l	d0,y(a1)
			move.l	d0,y+4(a1)
y set y+160
		endr
		add.w	#8,a1
		dbra	d7,.ol
	rts
.kill
	move.w	#$4e75,clearTimes
	rts

additive	dc.l	1
cummulative	dc.l	1
ttnub		dc.w	15

drawTimes2
	subq.w	#1,_cc
	bge		.kk
.herpmod2
		move.l	additive,d0
		add.l	d0,_demoloopcounter
.herpmod
		move.w	#50,_cc
		subq.w	#5,.herpmod+2
		bge		.kk
			move.l	cummulative,d0
			add.l	d0,additive
			subq.w	#1,ttnub
			bge		.kk
				add.l	#1,cummulative
				move.w	#1,ttnub
.kk

	move.l	_demoloopcounter,d0
	move.l	screenpointer2,a1
	lea		numbers+80,a2
	lea		sublist2,a4
	add.l	#190*160,a0
	add.l	#190*160,a1

	sub.w	(a4),a0
	sub.w	(a4)+,a1
o set 0
	REPT 8 
		move.b	(a2)+,d6
		or.b	d6,o(a1)
o set o+160
	ENDR

	move.w	#10,d7
	lea		numbers,a2
.loop
	divs	d7,d0
	move.l	d0,d1
	swap	d1

	add.w	d1,d1	;2
	add.w	d1,d1	;4
	add.w	d1,d1	;8
	lea		(a2,d1.w),a3
	sub.w	(a4),a0
	sub.w	(a4)+,a1

o set 0
	REPT 8
		move.b	(a3)+,d6
		or.b	d6,o(a1)
o set o+160

	ENDR
	ext.l	d0
	cmp.w	#0,d0
	bne		.loop
.end
	rts



doHeart	dc.w	0


doLifeLineFlash
	cmp.w	#53*2,heartPathOff
	blt		.end	
		lea		lifeLineCols,a0
		add.w	lifeLineOff,a0
		move.w	(a0),$ffff8240+2*1
		move.w	(a0),lifeLineCol
			subq.w	#2,lifeLineOff
			bge		.end
				move.w	#0,lifeLineOff
				move.w	#$4e75,doLifeLineFlash
.end
	rts
.www	dc.w	2
lifeLineCol	dc.w	0
lifeLineOff	dc.w	18*2
;--------------
;DEMOPAL - lifeline (heartbeat) fade and highlight
;--------------
; - palette fade for the lifeline colors, stsarts at 36 and counts down
lifeLineCols
	dc.w	$344		;0
	dc.w	$344		;2
	dc.w	$344		;4
	dc.w	$344		;6	
	dc.w	$344		;8
	dc.w	$344		;10
	dc.w	$444		;12
	dc.w	$455		;14
	dc.w	$555		;16
	dc.w	$566		;18
	dc.w	$666		;20
	dc.w	$677		;22
	dc.w	$777		;24
	dc.w	$777		;26
	dc.w	$777		;28
	dc.w	$677		;30
	dc.w	$677		;32
	dc.w	$566		;34
	dc.w	$566		;36	
	dc.w	$455
	dc.w	$455
	dc.w	$344
	dc.w	$344
	dc.w	$233
	dc.w	$233
	dc.w	$122
	dc.w	$122
	dc.w	$011
	dc.w	$011
	dc.w	$000
	dc.w	$000

heartPathOff	dc.w	0


move_heart_top2
;	lea		buffertop2,a0
	move.l	bufferTop2Pointer,a0
	move.l	screenpointer2,a1
	lea		15*8(a1),a1

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	cmp.w	#200-93,d7
	ble		.end
		cmp.w	#200-57,d7
		ble		.doMid
		move.w	d7,d6
		sub.w	#200-57,d6
		move.w	d6,d5
		sub.w	d6,d7
.weClear
	moveq	#0,d0
	move.l	d0,d1

.ddcleardd
		movem.l	d0-d1,(a1)
		lea		160(a1),a1
	dbra	d6,.ddcleardd

.doMid
	sub.w	d7,d6			; this is what we will do
	sub.w	#200-93,d7			; and this is what we will skip, so the counter is right
	; now deterime the offset into the source
	move.w	#38,d5			; end of the line
	sub.w	d7,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d5,a0
	;22 = 16 + 4 = 2
	add.w	d7,d7	;2	
	add.w	d7,d7	;4
	add.w	d7,d7	;8
	neg.w	d7
	add.w	#8*38,d7
	jmp		.cp(pc,d7)
.cp
	REPT 38
		move.l	(a0)+,(a1)+						;2
		move.l	(a0)+,(a1)+						;2
		lea		152(a1),a1						;4		--> 8
	ENDR
.end
	rts



move_heart_top
;	lea		buffertop,a0
	move.l	bufferTopPointer,a0
	move.l	screenpointer2,a1

	lea		5*8(a1),a1

	moveq	#0,d5

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	cmp.w	#30,d7
	ble		.clearAll
		cmp.w	#173,d7		
		ble		.doMid
; here we need to skip some off the top
		move.w	d7,d6										;200				;181
		sub.w	#173,d6		; number we need to do			;27					;8
		move.w	d6,d5
		sub.w	d6,d7
.weClear

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5

.ddcleardd
		movem.l	d0-d4/a2/a3/a4,(a1)
		movem.l	d0-d4/a2/a3/a4,32(a1)
		movem.l	d0-d4,64(a1)
		lea		160(a1),a1
	dbra	d6,.ddcleardd

.doMid
	; now what do we do here, we know we have at least 30 clears to do
	move.w	#230,d6
	sub.w	d5,d6
.doNormal
	sub.w	d7,d6			; this is what we will do
	sub.w	#30,d7			; and this is what we will skip, so the counter is right
	; now deterime the offset into the source
	move.w	#171,d5			; end of the line
	sub.w	d7,d5
	asl.w	#4,d5	;16
	move.w	d5,d0
	add.w	d5,d5	;32
	add.w	d5,d5	;64
	add.w	d0,d5
	add.w	d5,a0
	;22 = 16 + 4 = 2
	add.w	d7,d7	;2	
	move.w	d7,d0	;save2
	add.w	d7,d7	;4
	add.w	d7,d0	;save 6
	add.w	d7,d7	;8
	add.w	d7,d7	;16
	add.w	d0,d7
;	muls	#26,d7
	neg.w	d7
	add.w	#22*143,d7
	move.l	moveHeartCodePointer,a5
	jsr		(a5,d7)
;	jmp		.cp(pc,d7)
;.cp
;	REPT 143															;3200 bytes
;		movem.l	(a0)+,d0-d5/a2/a3/a4/a5			;4			;26
;		movem.l	d0-d5/a2/a3/a4/a5,(a1)			;4
;		movem.l	(a0)+,d0-d5/a2/a3/a4/a5			;4	
;		movem.l	d0-d5/a2/a3/a4/a5,40(a1)		;6
;		lea		160(a1),a1						;4
;	ENDR

	jmp		.clearMid

.clearAll
	move.w	#200-1,d7
	jmp		.clear
.clearMid
	move.w	d6,d7
	jmp		.clear

.clear	
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

.ddclear
		movem.l	d0-d6/a2,8(a1)
		movem.l	d0-d6/a2,40(a1)
		lea		160(a1),a1
	dbra	d7,.ddclear
	rts

moveHeartCodePointer	ds.l	1

genMoveHeart
	move.l	moveHeartCodePointer,a0
	movem.l	.template,d0-d5
	swap	d5
	move.w	#143-1,d7
.cp
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		move.l	d4,(a0)+			;11*2*143	+ 2 = 3148
		move.w	d5,(a0)+
	dbra	d7,.cp
	move.w	#$4e75,(a0)+
	rts
.template
	movem.l	(a0)+,d0-d5/a2/a3/a4/a5			;4			;26
	movem.l	d0-d5/a2/a3/a4/a5,(a1)			;4
	movem.l	(a0)+,d0-d5/a2/a3/a4/a5			;4	
	movem.l	d0-d5/a2/a3/a4/a5,40(a1)		;6
	lea		160(a1),a1						;4


move_heart_bot4
;	lea		heat_bot3,a0
	move.l	heat_bot3Pointer,a0
	move.l	screenpointer2,a1

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	sub.w	#76,d7
	blt		.skip
		move.w	d7,d6
		neg.w	d6
		add.w	#200,d6
;		muls	#160,d6
		asl.w	#5,d6		;32
		move.w	d6,d0
		add.w	d6,d6
		add.w	d6,d6
		add.w	d0,d6
		add.w	d6,a1

		cmp.w	#30,d7
		ble		.ok2
			move.w	#30,d7
.ok2
;		lea		11*8(a0),a0
		lea		11*8(a1),a1
.copyLine
		movem.l	(a0)+,d0-d3
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+

;		lea		18*8(a0),a0
		lea		18*8(a1),a1
	dbra	d7,.copyLine
.skip
	rts



move_heart_bot3
;	lea		heart_bot+128+95*160,a0
;	lea		heat_bot2,a0
	move.l	heat_bot2Pointer,a0
	move.l	screenpointer2,a1

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	sub.w	#95,d7
	blt		.skip
		move.w	d7,d6
		neg.w	d6
		add.w	#200,d6
;		muls	#160,d6
		asl.w	#5,d6
		move.w	d6,d0
		add.w	d6,d6
		add.w	d6,d6
		add.w	d0,d6
		add.w	d6,a1

		cmp.w	#10,d7
		ble		.ok2
			move.w	#10,d7
.ok2
;		lea		8*8(a0),a0
		lea		8*8(a1),a1
.copyLine
		movem.l	(a0)+,d0-d3
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+

;		lea		18*8(a0),a0
		lea		18*8(a1),a1
	dbra	d7,.copyLine
.skip
	rts


move_heart_bot2
;	lea		heart_bot+128+38*160,a0
;	lea		heat_bot1,a0
	move.l	heat_bot1Pointer,a0
	move.l	screenpointer2,a1

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	sub.w	#38,d7
	blt		.skip
		move.w	d7,d6
		neg.w	d6
		add.w	#200,d6
;		muls	#160,d6
		asl.w	#5,d6		;32
		move.w	d6,d0
		add.w	d6,d6
		add.w	d6,d6
		add.w	d0,d6
		add.w	d6,a1

		cmp.w	#57,d7
		ble		.ok2
			move.w	#57,d7
.ok2
;		lea		9*8(a0),a0
		lea		9*8(a1),a1
.copyLine
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		or.l	d0,(a1)+
		or.l	d1,(a1)+

;		lea		19*8(a0),a0
		lea		19*8(a1),a1
	dbra	d7,.copyLine
.skip
	rts


move_heart_bot
;	lea		heart_bot+128+105*160,a0
;	lea		heat_bot0,a0
	move.l	heat_bot0Pointer,a0
	move.l	screenpointer2,a1

	lea		heartPath,a2
	add.w	heartPathOff,a2
	move.w	(a2),d7

	sub.w	#105,d7
	blt		.skip
		move.w	d7,d6
		neg.w	d6
		add.w	#200,d6
;		muls	#160,d6
		asl.w	#5,d6		;32
		move.w	d6,d0
		add.w	d6,d6
		add.w	d6,d6
		add.w	d0,d6

		add.w	d6,a1

		cmp.w	#133-66,d7
		ble		.ok2
			move.w	#133-66,d7
.ok2
;		lea		6*8(a0),a0
		lea		6*8(a1),a1

		;44 = 32 + 8 +4
		add.w	d7,d7	;2
		add.w	d7,d7	;4
		move.w	d7,d0	;save 4
		add.w	d7,d7	;8
		add.w	d7,d0	;save 12
		add.w	d7,d7	;16
		add.w	d7,d7	;32
		add.w	d0,d7	;44

		neg.w	d7
		add.w	#(133-66)*44,d7
		move.l	copyLineBufferPointer,a6
		jsr		(a6,d7)
;		jmp		.copyLine(pc,d7)
;.copyLine
;		REPT 67											; 3000 bytes
;		movem.l	(a0)+,d0-d7			; width = 128/16=8 blocks, 8 blocks is 16 .l		;4
;		or.l	d0,(a1)+																;8*2	-> 20*2 = 40 + 8 = 48
;		or.l	d1,(a1)+
;		or.l	d2,(a1)+
;		or.l	d3,(a1)+
;		or.l	d4,(a1)+
;		or.l	d5,(a1)+
;		or.l	d6,(a1)+
;		or.l	d7,(a1)+
;		movem.l	(a0)+,d0-d7			; width = 128/16=8 blocks, 8 blocks is 16 .l		;4
;		or.l	d0,(a1)+
;		or.l	d1,(a1)+
;		or.l	d2,(a1)+
;		or.l	d3,(a1)+
;		or.l	d4,(a1)+
;		or.l	d5,(a1)+
;		or.l	d6,(a1)+
;		or.l	d7,(a1)+
;		lea		6*8*2(a1),a1
;		ENDR
.skip
	rts

copyLineBufferPointer	ds.l	1

genCopyLine
	move.l	copyLineBufferPointer,a0
	move.w	#67-1,d7
	movem.l	.template,d0-d5
.genLoop
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		move.l	d4,(a0)+
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		move.l	d4,(a0)+
		move.l	d5,(a0)+			;11*4*67 + 2 = 2950

	dbra	d7,.genLoop
	move.w	#$4e75,(a0)+
	rts



.template
		movem.l	(a0)+,d0-d7			
		or.l	d0,(a1)+
		or.l	d1,(a1)+
		or.l	d2,(a1)+
		or.l	d3,(a1)+
		or.l	d4,(a1)+
		or.l	d5,(a1)+
		or.l	d6,(a1)+
		or.l	d7,(a1)+
		lea		6*8*2(a1),a1




currentPosition		dc.w	1


buzz													; 1200 bytes
;		lea		buzzData,a0
		move.l	buzzDataPointer,a0
		move.l	screenpointer2,a1
		add.w	#(76+50)*160,a1

.y set 5*8
	REPT 15
.x set .y
		REPT 10
			move.w	(a0)+,.x+6(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
	tst.w	bottomLineShow
	beq		.skip
	lea		10*3*2(a0),a0
.y set .y+3*160
	REPT 15
.x set .y
		REPT 10
			move.w	(a0)+,.x+6(a1)
.x set .x+8
		ENDR
.y set .y+160
	ENDR
.skip
	rts


doLifeLine
	tst.w	clearTimesTimes
	bge		.skip
;	lea		lifeLine,a0
	move.l	lifeLinePointer,a0
	move.l	screenpointer2,a1

	movem.w	(a0)+,d0-d3
	or.w	d0,120*160+6*8(a1)
	or.w	d1,121*160+6*8(a1)
	or.w	d2,120*160+7*8(a1)
	or.w	d3,121*160+7*8(a1)

.x set 101*160+7*8

			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)



.x set 75*160+7*8+8

			or.w	d3,.x+160*0(a1)
			or.w	d4,.x+160*1(a1)
			or.w	d5,.x+160*2(a1)
			or.w	d6,.x+160*3(a1)
			or.w	d7,.x+160*4(a1)
.x set .x+5*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160	
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160
			movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160	
			move.w	(a0)+,d0
			or.w	d0,.x+160*0(a1)


.x set 4*160+7*8+16

		REPT 20
			movem.w	(a0)+,d0-d7		;8
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160			
		ENDR
			movem.w	(a0)+,d0-d7
			or.w	d0,.x(a1)


.x set 109*160+7*8+24
	
			or.w	d1,.x+160*0(a1)
			or.w	d2,.x+160*1(a1)
			or.w	d3,.x+160*2(a1)
			or.w	d4,.x+160*3(a1)
			or.w	d5,.x+160*4(a1)
			or.w	d6,.x+160*5(a1)
			or.w	d7,.x+160*6(a1)		
.x set .x+7*160
		REPT 7								;56 + 7 = 63
			movem.w	(a0)+,d0-d7		;8
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160			
		ENDR
			movem.w	(a0)+,d0-d7
			or.w	d0,.x(a1)
			or.w	d1,.x+160(a1)
			or.w	d2,.x+320(a1)
	





.x set 74*160+7*8+32
		or.w	d3,.x+160*0(a1)
		or.w	d4,.x+160*1(a1)
		or.w	d5,.x+160*2(a1)
		or.w	d6,.x+160*3(a1)
		or.w	d7,.x+160*4(a1)		;5
.x set .x+160*5
		REPT 5
		movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160			
		ENDR
		move.w	(a0)+,d0
		or.w	d0,.x+160*0(a1)
		move.w	(a0)+,d0
		or.w	d0,.x+160*1(a1)
		move.w	(a0)+,d0
		or.w	d0,.x+160*2(a1)




.x set 89*160+7*8+40
		REPT 4
		movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)
.x set .x+8*160			
		ENDR			

.x set 114*160+7*8+48
		movem.w	(a0)+,d0-d7
			or.w	d0,.x+160*0(a1)
			or.w	d1,.x+160*1(a1)
			or.w	d2,.x+160*2(a1)
			or.w	d3,.x+160*3(a1)
			or.w	d4,.x+160*4(a1)
			or.w	d5,.x+160*5(a1)
			or.w	d6,.x+160*6(a1)
			or.w	d7,.x+160*7(a1)

.x set 119*160+7*8
	REPT 3
		move.w	(a0)+,d0
		or.w	d0,.x+56(a1)
.x set .x+160
	ENDR
.skip	
	rts







		ds.b	100
numbers	incbin	"data/lifeline/numbers2.bin"				;
		ds.b	100

sublist2
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
	dc.w	7
	dc.w	1
;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines

;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
;out:	start palette overwritten one step closer to end palette
fade22:		
		movem.l	d0-d6/a0-a2,-(sp)

		move.w	d0,d6
		subq.w	#1,d6
.loop:
		move.w	(a0)+,d0			;source
		move.w	(a1)+,d3			;dest
		move.w	d0,d1
		move.w	d0,d2
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0700,d0
		and.w	#$0700,d3
		and.w	#$0070,d1
		and.w	#$0070,d4
		and.w	#$0007,d2
		and.w	#$0007,d5

.red:		cmp.w	d0,d3
		beq.s	.green
		blt.s	.redsub
		add.w	#$0100,d0
		bra.s	.green
.redsub:	sub.w	#$0100,d0


.green:		cmp.w	d1,d4
		beq.s	.blue
		blt.s	.greensub
		add.w	#$0010,d1
		bra.s	.blue
.greensub:	sub.w	#$0010,d1


.blue:		cmp.w	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.w	#$1,d2
		bra.s	.store
.bluesub:	subq.w	#$1,d2

.store:		or.w	d1,d0
		or.w	d2,d0
		move.w	d0,(a2)+

		dbra	d6,.loop

		movem.l	(sp)+,d0-d6/a0-a2
		rts




	section DATA
;image		incbin	"data/lifeline/heartline.neo"
buzzData		incbin	"data/lifeline/buzztext.crk"			;660		/510		-150
	even
lifeLine		incbin	"data/lifeline/lifeline4.crk" 			;772		/271		-501
	even
buffertop		incbin	"data/lifeline/top0.crk"				;13920		/2130		-11790
	even
buffertop2		incbin	"data/lifeline/top1.crk"				;312		/100		-212
	even
heat_bot0		incbin	"data/lifeline/bottom0.crk"				;4352		/1088		-3264
	even
heat_bot1		incbin	"data/lifeline/bottom1.crk"				;464		/144		-320
	even
heat_bot2		incbin	"data/lifeline/bottom2.crk"				;176		/56			-120
	even
heat_bot3		incbin	"data/lifeline/bottom3.crk"				;496		/113		-383		~ 16740 saved
	even

;--------------
;DEMOPAL - heart and stuff palette
;--------------
; - palette used for the heart and stuff

heart_top_pal	
	dc.w	$000,$244,$200,$400,$621,$643,$777,$100
	dc.w	$070,$070,$070,$070,$070,$070,$070,$070


buzzDataPointer		ds.l	1
lifeLinePointer		ds.l	1
bufferTopPointer	ds.l	1
bufferTop2Pointer	ds.l	1
heat_bot0Pointer	ds.l	1
heat_bot1Pointer	ds.l	1
heat_bot2Pointer	ds.l	1
heat_bot3Pointer	ds.l	1

heartPath		include	"data/lifeline/heartpath2.s"			;148

	IFEQ	STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC




    IFEQ	STANDALONE
	section BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
	ENDC

