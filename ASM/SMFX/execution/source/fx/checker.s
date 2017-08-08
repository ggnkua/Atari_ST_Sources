
    section	TEXT
herpvbl
		move.b	#2,$ffff820a.w			;50 Hz	
		addq.w	#1,$466.w
		pusha0
		move.l	sndh_pointer,a0
		jsr		8(a0)
		popa0
		rte

init_checker_board
	move.l	#$03330333,d0
	lea		$ffff8240,a0
	REPT 8
		move.l	d0,(a0)+
	ENDR

	move.w	#$2700,sr
	move.l	#herpvbl,$70
	move.w	#$2300,sr

	wait_for_vbl
	move.b	#2,$ffff820a.w			;50 Hz	


	move.l	alignpointer1,a0
	move.l	a0,leftSideVerticalPointer
	jsr		generateLeftSizeVertical

	move.w	#$2700,sr
	move.l 	screenpointer2,$ff8200							; put new screenpointer in effect
	move.l	#checkervbl,$70
	move.l	#timer_a_opentop,$134.w			;Install our own Timer A
	move.l	#timer_b_openbottom,$120.w			;Install our own Timer B
	move.w	#$2300,sr


	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#285,d7
	move.l	#0,d0
.ol
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.ol

	move.w	#checkerFrontColor,$ffff8240+3*2	
	move.w	#checkerFrontColor,$ffff8240+10*2
	move.w	#checkerFrontColor,$ffff8240+11*2
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)

	move.w	#$765,$ffff8240+2*1
	move.w	#$653,$ffff8240+2*4
	move.w	#$742,$ffff8240+2*5
	move.w	#$443,$ffff8240+2*6
	move.w	#$532,$ffff8240+2*7
	move.w	#$753,$ffff8240+2*8
	move.w	#$232,$ffff8240+2*9
	move.w	#$122,$ffff8240+2*12
	move.w	#$212,$ffff8240+2*13
	move.w	#$322,$ffff8240+2*14
	move.w	#$222,$ffff8240+2*15



.mainloop
	jsr		prepMoveTabl
	jsr		fillBackDrop
	jsr		init_style_pointers
	jsr		precalc_style
	jsr		unpackPlasma
	jsr		unpackBrainHurts

			exitOnSpace
	tst.w	nextScene
	beq		.mainloop
	rts


leftSideVerticalPointer	dc.l	0
someTicker	dc.w	0

checkervbl

	pushall
	move.l 	screenpointer,$ff8200							; put new screenpointer in effect
			screenswap										; swap screenpointers		
			schedule_timerA_topBorder

	move.w	#$333,$ffff8240
	cmp.w	#4,someTicker
	bne		.nobackdrop
		move.w	#0,$ffff8240+2*2
.nobackdrop


    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l	#timer_b_openbottom,$120
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))

	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	ble		.skipp
		move.w	d0,someTicker
		move.b	#0,$b8(a0)
.skipp

	cmp.w	#1,someTicker
	blt		.okzzz
	move.l	leftSideVerticalPointer,a0
	jsr		(a0)

	cmp.w	#2,someTicker
	blt		.okzzz
	jsr		horizontalTop
	jsr		leftTopDiagonal
	jsr		topRightDiagonal

	cmp.w	#3,someTicker
	blt		.okzzz
	jsr		rightSide_Vertical

	cmp.w	#4,someTicker
	blt		.okzzz
	jsr		bottomRightDiagonal
	jsr		cornerBottomLeft_Outer
	jsr		cornerBottomLeft_Inner
	jsr		horizontalBottom

	jsr		changeOffset


.okzzz

	move.l	sndh_pointer,a0
	jsr		8(a0)
	move.b	$b8(a0),d0
	cmp.b	#$ff,d0
	bne		.zok
		move.w	#-1,nextScene
.zok

	subq.w	#1,framesd
	bge		.ok
		move.w	#-1,nextScene
.ok
	cmp.w	#49,framesd
	bgt		.lll
		move.w	#$2700,sr
		move.l	#checkervbl2,$70
		move.w	#$2300,sr
.lll
	
	subq.w	#1,sidesWaiter
	bge		.skipsides
	jsr		doSideA
	jsr		doSideB
.skipsides

	popall
	rte

sidesWaiter	dc.w	660+25-64

framesd		dc.w	900
snazzwaiter	dc.w	4

checkervbl2
	pushall
	move.l 	screenpointer,$ff8200							; put new screenpointer in effect
			schedule_timerA_topBorder
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l	#timer_b_openbottom,$120
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	addq.w	#1,$466
	;;;;; now we calc the fullscreen shit on the screen for screenswitch
	subq.w	#1,checkerDistFadeOutWaiter
	bge		.nof
		move.w	#3,checkerDistFadeOutWaiter
		lea		checkerDistFadeOutPalette,a0
		add.w	checkerDistFadeOutPaletteOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240

		add.w	#32,checkerDistFadeOutPaletteOff
		cmp.w	#32*4,checkerDistFadeOutPaletteOff
		ble		.nof
			move.w	#32*4,checkerDistFadeOutPaletteOff
.nof


	subq.w	#1,snazzwaiter
	bge		.nono
	subq.w	#1,blockDrawTimes
	ble		.nono
		lea		blockDrawRouts,a0
		add.w	blockDrawRoutsOff,a0
		move.l	(a0),a0
		add.w	#4,blockDrawRoutsOff
		jsr		(a0)
.nono


	move.l	sndh_pointer,a0
	jsr		8(a0)

	subq.w	#1,framesd
	bgt		.ok
			move.w	#$2700,sr
			move.l	#checkervbl3,$70
			move.w	#$2300,sr
			move.w	#13,blockDrawTimes
.ok

	popall
	rte


; 29 is center, if we go < 0; then we need to start



; position = 29 = center
; if position < 0, then 
;smfx1	incbin	fx/checker/smfxb.neo
;smfx2	incbin	fx/checker/smfxb2.neo
;
;prepSMFX
;	lea		smfx1+128+160-16,a0
;	lea		smfx2+128+160-16,a1
;	move.w	#200-1,d7
;	lea		smfxpicture2,a2
;.c
;		move.l	(a0)+,(a2)+
;		move.l	(a0)+,(a2)+
;		move.l	(a0)+,(a2)+
;		move.l	(a0)+,(a2)+
;		add.w	#160-16,a0
;	dbra	d7,.c
;	move.w	#6-1,d7
;.c2
;		move.l	(a1)+,(a2)+
;		move.l	(a1)+,(a2)+
;		move.l	(a1)+,(a2)+
;		move.l	(a1)+,(a2)+
;		add.w	#160-16,a1
;	dbra	d7,.c2
;	; 206*16		;3296
;	lea		smfxpicture2,a0
;	move.b	#0,$ffffc123
;	rts


smfxOld		dc.w	0
smfxOld2	dc.w	0
smfxOff		dc.w	0
smfxOff2	dc.w	256
smfxMove	
		include	fx/checker/smfxmove.s
;		include	fx/checker/smfxmove.s

doSideB
	move.l	screenpointer2,a0
	add.w	#160-16,a0
	lea		smfxpicture2,a1
	move.l	#%11110000000000001111000000000000,d6
	moveq	#0,d2
	move.w	#29,d0				; start position
	lea		smfxMove,a6
	add.w	smfxOff2,a6
	move.w	(a6),d1
	cmp.w	#50,framesd
	ble		.skipadd	
	add.w	#4,smfxOff2
.skipadd
	and.w	#512-1,smfxOff2
	cmp.w	smfxOld2,d1
	blt		.lt
.ge
		; we go up, so clear bottom
		move.w	#-1,d4
		jmp		.cont
.lt
		; we go down, clear top
		move.w	#0,d4
.cont		
	move.w	d1,smfxOld2
	add.w	d1,d0
	bgt		.ok					; if we're positive, we're ok
.negative						; if we get here, we're negative
		move.w	#0,d1			;	offset into the screen area
		move.w	d0,d7				; iterations
		add.w	#206-1,d7			; 206 total length
		ble		.skiptop
		neg.w	d0				;	determine offset into source
		lsl.w	#4,d0			; *16
		add.w	d0,a1			; add offset into source
		jmp		.draw
.ok
		move.w	#206-1,d7
		cmp.w	#274-206,d0		; check if we have to cut d7
		blt		.inrange
			move.w	d0,d7
			sub.w	#274-206,d7
			neg.w	d7
			add.w	#206-1,d7			
.inrange
		add.w	d0,d0
		add.w	d0,d0
		add.l	(a2,d0.w),a0
.draw
		
		tst.w	d4
		beq		.nocleartop
o set 0
			REPT 26
				and.l	d6,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				lea		-160-16(a0),a0
o set o-160
			ENDR
			add.w	#26*160,a0
.nocleartop

;		muls	#20,d7
		; 20 times: 16 + 4
		add.w	d7,d7
		add.w	d7,d7	;4
		add.w	d7,d7
		add.w	d7,d7

		move.w	#16*206,d5

		sub.w	d7,d5
		jmp		.jmptable(pc,d5.w)						; generate this shit, but didnt do it, fuckit
.jmptable
	REPT 206
		and.l	d6,(a0)			;2
		move.l	(a1)+,d0		;2
		or.l	d0,(a0)+		;2

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+		;2
		move.l	(a1)+,(a0)+		;2
		add.w	#160-16,a0		;4	20					16*206=3296 bytes wasted!
	ENDR

		tst.w	d4
		bne		.noclearbot
o set 0
			REPT 24
				and.l	d6,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				lea		160-16(a0),a0
o set o+160
			ENDR
.noclearbot
	rts


.skiptop
o set 0
			REPT 24
				and.l	d6,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				lea		160-16(a0),a0
o set o+160
			ENDR
	rts


doSideA
	move.l	screenpointer2,a0
	lea		smfxpicture1,a1
	lea		ytable,a2
	move.l	#%00000000000011110000000000001111,d6
	moveq	#0,d2
	move.w	#29,d0				; start position
	lea		smfxMove,a6
	add.w	smfxOff,a6
	move.w	(a6),d1
	; up or down?
	cmp.w	#50,framesd
	ble		.skipadd
	add.w	#4,smfxOff
.skipadd
	and.w	#512-1,smfxOff
	cmp.w	smfxOld,d1
	blt		.lt
.ge
		; we go up, so clear bottom
		move.w	#-1,d4
		jmp		.cont
.lt
		; we go down, clear top
		move.w	#0,d4
.cont		
	move.w	d1,smfxOld

	add.w	d1,d0
	bgt		.ok					; if we're positive, we're ok
.negative						; if we get here, we're negative
		move.w	#0,d1			;	offset into the screen area
		move.w	d0,d7				; iterations
		add.w	#206-1,d7			; 206 total length
		ble		.skiptop
		neg.w	d0				;	determine offset into source
		lsl.w	#4,d0			; *16
		add.w	d0,a1			; add offset into source
		jmp		.draw
.ok
		move.w	#206-1,d7
		cmp.w	#274-206,d0		; check if we have to cut d7
		blt		.inrange
			move.w	d0,d7
			sub.w	#274-206,d7
			neg.w	d7
			add.w	#206-1,d7			
.inrange
		add.w	d0,d0
		add.w	d0,d0
		add.l	(a2,d0.w),a0
.draw
		
		tst.w	d4
		beq		.nocleartop
o set 0
			REPT 26
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				and.l	d6,(a0)+
				and.l	d6,(a0)+
				lea		-160-16(a0),a0
o set o-160
			ENDR
			add.w	#26*160,a0
.nocleartop
		add.w	d7,d7
		add.w	d7,d7	;4
		move.w	d7,d5
		add.w	d7,d7
		add.w	d7,d7
		add.w	d5,d7
		move.w	#20*206,d5

		sub.w	d7,d5
		jmp		.jmptable(pc,d5.w)						; generate this shit
.jmptable
	REPT 206
		move.l	(a1)+,(a0)+		;2
		move.l	(a1)+,(a0)+		;2
		move.l	(a1)+,d0		;2
		and.l	d6,(a0)			;2
		or.l	d0,(a0)+		;2
		move.l	(a1)+,d0		;2
		and.l	d6,(a0)			;2
		or.l	d0,(a0)+		;2						206*20 bytes wasted! 4120 bytes
		add.w	#160-16,a0		;4	20
	ENDR

		tst.w	d4
		bne		.noclearbot
o set 0
			REPT 24
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				and.l	d6,(a0)+
				and.l	d6,(a0)+
				lea		160-16(a0),a0
o set o+160
			ENDR
.noclearbot
	rts

.skiptop
o set 0
			REPT 24
				move.l	d2,(a0)+
				move.l	d2,(a0)+
				and.l	d6,(a0)+
				and.l	d6,(a0)+
				lea		160-16(a0),a0
o set o+160
			ENDR
	rts

ytable
o set 0
	REPT 280
		dc.l	o
o set o+160
	ENDR

;doSides
;	move.l	screenpointer2,a0
;	add.w	#160*29,a0
;	lea		smfxpicture1,a1
;	lea		smfxpicture2,a2
;	move.w	#206-1,d7
;.ds
;		move.l	(a1)+,(a0)+
;		move.l	(a1)+,(a0)+
;		move.l	(a1)+,d0
;		or.l	d0,(a0)+
;		move.l	(a1)+,d0
;		or.l	d0,(a0)+
;		add.w	#160-16,a0
;	dbra	d7,.ds
;
;
;	move.l	screenpointer2,a0
;	add.w	#160*29,a0
;	lea		smfxpicture2,a1
;	move.w	#206-1,d7
;.ds2
;		add.w	#160-16,a0
;		move.l	(a2)+,d0
;		or.l	d0,(a0)+
;		move.l	(a2)+,d0
;		or.l	d0,(a0)+
;		move.l	(a2)+,(a0)+
;		move.l	(a2)+,(a0)+
;	dbra	d7,.ds2
;
;
;
;	move.w	#$700,$ffff8240+15*2
;	rts

checkerDistFadeOutWaiter		dc.w	30
checkerDistFadeOutPalette	
					;		dc.w	checkerFrontColor,$000
					;		dc.w	$666,$111
					;		dc.w	$555,$222
					;		dc.w	$444,$333
					;		dc.w	$333,$333


	dc.w	$0333,$0765,$0000,$0777,$0653,$0742,$0443,$0532,$0753,$0232,$0777,$0777,$0122,$0212,$0322,$0222
	dc.w	$0333,$0654,$0111,$0666,$0553,$0642,$0343,$0432,$0743,$0232,$0666,$0666,$0222,$0222,$0322,$0222
	dc.w	$0333,$0543,$0222,$0555,$0543,$0532,$0343,$0332,$0543,$0332,$0555,$0555,$0223,$0322,$0332,$0222
	dc.w	$0333,$0433,$0233,$0444,$0443,$0433,$0333,$0332,$0433,$0332,$0444,$0444,$0233,$0323,$0332,$0333
	dc.w	$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333,$0333


checkerDistFadeOutPaletteOff	dc.w	0


colorFadex		dc.w	$333,$333,$223,$223,$222,$222,$112,$112,$111,$111,$001,$001,$000,$000,$000





colorFadexOff	dc.w	0

checkervbl3
	pushall
	move.l 	screenpointer2,$ff8200							; put new screenpointer in effect
			schedule_timerA_topBorder
;			schedule_timerB_bottomBorder
    clr.b   $fffffa1b.w         ;Timer B control (stop)
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.l	#timer_b_openbottom,$120
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	addq.w	#1,$466
	;;;;; now we calc the fullscreen shit on the screen for screenswitch
	lea		$ffff8240,a0
	lea		colorFadex,a1
	add.w	colorFadexOff,a1
	add.w	#2,colorFadexOff
	move.w	(a1),d0
	rept 16
		move.w	d0,(a0)
	endr

	move.l	sndh_pointer,a0
	jsr		8(a0)

	jsr		block3Draw
;	jsr		block2Draw

	subq.w	#1,blockDrawTimes
	bge		.ok
	move.w	#-1,nextScene
.ok
	popall
	rte

blockDrawTimes	dc.w	4
blockDrawRoutsOff	dc.w	0
blockDrawRouts
	dc.l	block1Draw
	dc.l	block2Draw
	dc.l	block2Draw
	dc.l	block2Draw
	dc.l	block3Draw

saved2	dc.l	0

block1Draw
	move.l	screenpointer2,a0
	move.l	screenpointer2,saved2
;	move.b	#0,$ffffc123

;	sub.l	#50*160,a0
	move.l	#90,d7
	moveq	#0,d0
.xxxx
o set 6
	REPT 29
		move.l	d0,(a0)+
		move.l	d0,(a0)+
o set o+8
	ENDR
	dbra	d7,.xxxx
	move.l	a0,savedX
	rts
savedX	dc.l	0
block2Draw
	move.l	savedX,a0
	move.l	#90,d7
	moveq	#0,d0
.xxxx
o set 6
	REPT 29
		move.l	d0,(a0)+
		move.l	d0,(a0)+
o set o+8
	ENDR
	dbra	d7,.xxxx
	move.l	a0,savedX
	rts


xzz	dc.w	4

block3Draw
	subq.w	#1,xzz
	bge		.ok
	move.l	saved2,a0
	move.l	#150,d7
	moveq	#0,d0
.xxxx
;o set 6
;	REPT 4
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		add.w	#160-16,a0
;o set o+8
;	ENDR
	dbra	d7,.xxxx
	move.w	#$4e75,block3Draw
.ok
	rts


; a0,a1,a2,a3
leftTopDiagonal
	move.l	screenpointer2,a0
	add.w	#8,a0
	lea		_offset,a1
	lea		topleft_outer,a2
	lea		vertLeft,a3
	move.l	a3,a4
;	lea		topleft_inner,a5
	move.w	#8-1,d7
.loop
		move.l	a4,a6
		move.l	a2,a3
		lea		topleft_inner,a5


		move.w	(a1)+,d0				; first
		add.w	d0,d0
		add.w	d0,a6					


		lsl.w	#3,d0
		add.w	d0,a3


		move.w	(a1)+,d0
		lsl.w	#3,d0
		add.w	d0,a5
o set 6
		REPT 8
			move.l	(a3)+,o(a0)
o set o+160
		ENDR

o set 6+8*160
			movem.l	(a6)+,d0-d6
			or.w	(a5)+,d0
			or.w	(a5)+,d1
			or.w	(a5)+,d2
			or.w	(a5)+,d3
			or.w	(a5)+,d4
			or.w	(a5)+,d5
			or.w	(a5)+,d6
			move.l	d0,o+160*0(a0)
			move.l	d1,o+160*1(a0)
			move.l	d2,o+160*2(a0)
			move.l	d3,o+160*3(a0)
			move.l	d4,o+160*4(a0)
			move.l	d5,o+160*5(a0)
			move.l	d6,o+160*6(a0)
			move.l	(a6)+,d0
			or.w	(a5)+,d0
			move.l	d0,o+160*7(a0)

		add.l	#16*160+8,a0
	dbra	d7,.loop
	rts



horizontalBottom
	move.l	screenpointer2,a0
	add.l	#256*160+24,a0
	lea		_offset,a2
	lea		hor_outer_bottom,a3
	lea		hor_inner_bottom,a4
	move.w	#7-1,d5
	moveq	#2,d6
	move.w	#4*8*2,d2
.loop
		move.w	(a2)+,d0			;outer			;8				; alt move.l ax,a3 (4), add.w (a2)+,a3 (12), move.l (a3),d0 (12)
		add.w	d0,d0
		move.l	(a3,d0.w),d0						;20

		move.w	(a2)+,d1
		add.w	d1,d1
		move.l	(a4,d1.w),d1
		jmp		(pc,d6.w)
o set 6	
		REPT 7
y set o
			REPT 8
				move.l	d0,y(a0)
				move.l	d1,y-8*160(a0)
y set y+160
			ENDR
o set o+16
		ENDR

		add.w	d2,d6
		sub.w	#16*160+8,a0
	dbra	d5,.loop
	rts




horizontalTop							;514 size
	move.l	screenpointer2,a0
	lea		_offset,a2
	lea		hor_outer,a3
	lea		hor_inner,a4
	move.w	#7-1,d5
	moveq	#0,d6
	move.w	#4*8*2,d2
.oloop
		move.w	(a2)+,d0
		add.w	d0,d0
		move.l	(a3,d0.w),d0	

		move.w	(a2)+,d1
		add.w	d1,d1
		move.l	(a4,d1.w),d1

		jmp		2(pc,d6.w)

o set 6+24
		REPT 7
y set o
			REPT 8
				move.l	d0,y(a0)
				move.l	d1,y+8*160(a0)
y set y+160
			ENDR
o set o+16
		ENDR
		add.w	d2,d6
		add.w	#16*160-8,a0
	dbra	d5,.oloop
	rts





cornerBottomLeft_Outer					;88 size
	move.l	screenpointer2,a0
	add.l	#256*160+8,a0
	lea		botleft_outer,a3
	lea		_offset,a2
	move.w	#17*32,d2
	move.w	#8-1,d7
.loop
		move.w	(a2),d0
		move.w	d2,d1
		lsl.w	#4,d0
		sub.w	d0,d1
		move.l	a3,a1
		add.w	d1,a1
o set 6
	REPT 8
		move.l	-(a1),o(a0)
o 		set 	o+160
	ENDR
		add.w	#4,a2
		sub.l	#16*160-8,a0
	dbra	d7,.loop
	rts




; used:
;	a0,a1,a2
cornerBottomLeft_Inner					;126 size
	move.l	screenpointer2,a0
	lea		_offset,a2
	add.l	#248*160+8,a0
	lea		_derp,a5
	lea		topleft_inner,a6
	move.w	#17*16,a3
	move.w	#8-1,d7
.loop
		move.l	a5,a4

		move.w	(a2)+,d0
		add.w	d0,d0
		add.w	d0,a4
		move.l	a6,a1
		move.w	(a2)+,d0
		move.w	a3,d1
		lsl.w	#3,d0
		sub.w	d0,d1
		add.w	d1,a1

o set 6
		movem.l	(a4)+,d0-d6
		or.w	-(a1),d0
		or.w	-(a1),d1
		or.w	-(a1),d2
		or.w	-(a1),d3
		or.w	-(a1),d4
		or.w	-(a1),d5
		or.w	-(a1),d6
		move.l	d0,o+160*0(a0)
		move.l	d1,o+160*1(a0)
		move.l	d2,o+160*2(a0)
		move.l	d3,o+160*3(a0)
		move.l	d4,o+160*4(a0)
		move.l	d5,o+160*5(a0)
		move.l	d6,o+160*6(a0)
		move.l	(a4)+,d0
		or.w	-(a1),d0
		move.l	d0,o+160*7(a0)
	
		sub.l	#16*160-8,a0
	dbra	d7,.loop
	rts


bottomRightDiagonal						;182 size
	move.l	screenpointer2,a0
	add.l	#256*160,a0
	lea		_offset,a2
	lea		topright_outer,a3
;	lea		topright_inner,a1
	lea		topright_inner2,a4
	move.w	#17*32,a6
	move.w	#8-1,d7
;.loop
	REPT 8
		move.w	(a2)+,d0
		lsl.w	#4,d0
		move.w	a6,d3
		sub.w	d0,d3
		move.l	a3,a5
		add.w	d3,a5

		move.w	(a2)+,d0
		lsl.w	#4,d0
		move.w	a6,d1
		sub.w	d0,d1

		lea		topright_inner,a1
		add.w	d1,a1

;; ouer
o set 136+6
	REPT 8
		move.l	-(a5),o(a0)						;28 * 8 = 224		movem.l	(a0),d0-d7 = 80 move.l	d0,o(a0) = 8*16 = 128 + 80 == 208
o 		set 	o+160
	ENDR	

		move.l	a4,a5
		add.w	d3,a5

; inner
o set 136+6
	REPT 8
;		move.l	-(a1),d0						;16	*8	= 128
;		or.l	-(a5),d0						;18
;		move.l	d0,o-8*160(a0)
o 		set		o+160
	ENDR	

	movem.l	-4*8(a1),d0-d7
	or.l	-(a5),d7
	or.l	-(a5),d6
	or.l	-(a5),d5
	or.l	-(a5),d4
	or.l	-(a5),d3
	or.l	-(a5),d2
	or.l	-(a5),d1
	or.l	-(a5),d0
	move.l	d7,136+6-8*160(a0)
	move.l	d6,136+6-7*160(a0)
	move.l	d5,136+6-6*160(a0)
	move.l	d4,136+6-5*160(a0)
	move.l	d3,136+6-4*160(a0)
	move.l	d2,136+6-3*160(a0)
	move.l	d1,136+6-2*160(a0)
	move.l	d0,136+6-1*160(a0)

	sub.l	#16*160+8,a0
	ENDR
;	dbra	d7,.loop
	rts


topRightDiagonal						;160 size
	move.l	screenpointer2,a0
	add.w	#8*160,a0
	lea		_offset,a2
	move.w	#8-1,d7
;	lea		topright_inner2,a4
	lea		topright_inner,a3
	lea		topright_outer,a6
.loop
		move.w	(a2)+,d0
		lsl.w	#4,d0
		lea		topright_inner2,a4
		add.w	d0,a4

		move.l	a6,a5
		add.w	d0,a5

		move.w	(a2)+,d0
		lsl.w	#4,d0
		move.l	a3,a1
		add.w	d0,a1
;; outer
o set 136+6-8*160
	REPT 8
		move.l	(a5)+,o(a0)
o 		set 	o+160
	ENDR

;; inner		
o set 136+6
		movem.l	(a1)+,d0-d6
		or.l	(a4)+,d0
		or.l	(a4)+,d1
		or.l	(a4)+,d2
		or.l	(a4)+,d3
		or.l	(a4)+,d4
		or.l	(a4)+,d5
		or.l	(a4)+,d6
		move.l	d0,o+160*0(a0)
		move.l	d1,o+160*1(a0)
		move.l	d2,o+160*2(a0)
		move.l	d3,o+160*3(a0)
		move.l	d4,o+160*4(a0)
		move.l	d5,o+160*5(a0)
		move.l	d6,o+160*6(a0)
		move.l	(a1)+,d0
		or.l	(a4)+,d0
		move.l	d0,o+160*7(a0)
	add.l	#16*160-8,a0
	dbra	d7,.loop
	rts

doBlock1 macro
o set 6+7*160
	movem.l	-32(a2),d0-d7		; d7 is first			; 80 cycles vs 8*16= 128
	or.l	-(a3),d7
	or.l	-(a3),d6
	or.l	-(a3),d5
	or.l	-(a3),d4
	or.l	-(a3),d3
	or.l	-(a3),d2
	or.l	-(a3),d1
	or.l	-(a3),d0

	move.l	d7,o-160*0(a0)
	move.l	d6,o-160*1(a0)
	move.l	d5,o-160*2(a0)
	move.l	d4,o-160*3(a0)
	move.l	d3,o-160*4(a0)
	move.l	d2,o-160*5(a0)
	move.l	d1,o-160*6(a0)
	move.l	d0,o-160*7(a0)

	move.l	d7,o-160*0(a6)
	move.l	d6,o-160*1(a6)
	move.l	d5,o-160*2(a6)
	move.l	d4,o-160*3(a6)
	move.l	d3,o-160*4(a6)
	move.l	d2,o-160*5(a6)
	move.l	d1,o-160*6(a6)
	move.l	d0,o-160*7(a6)

	sub.w	#32,a3
	add.w	#8*160,a0
	endm




helpm1	macro
o set y
		REPT \1-1
			move.l	\2,o(a0)
			move.l	\2,o(a6)
o set o+16*160
		ENDR
			move.l	\2,o(a0)

y set y-160
	endm

helpm2	macro
o set y
		REPT \1
			move.l	\2,o(a0)
			move.l	\2,o(a6)
o set o+16*160
		ENDR
y set y-160
	endm	

doBlock3 macro

y set 6+15*160
	movem.l	-32(a2),d0-d7
	or.l	-(a3),d7
	or.l	-(a4),d7
	or.l	-(a3),d6
	or.l	-(a4),d6
	or.l	-(a3),d5
	or.l	-(a4),d5
	or.l	-(a3),d4
	or.l	-(a4),d4
	or.l	-(a3),d3
	or.l	-(a4),d3
	or.l	-(a3),d2
	or.l	-(a4),d2
	or.l	-(a3),d1
	or.l	-(a4),d1
	or.l	-(a3),d0
	or.l	-(a4),d0
	
	helpm1	\1,d7
	helpm1	\1,d6
	helpm1	\1,d5
	helpm1	\1,d4
	helpm1	\1,d3
	helpm1	\1,d2
	helpm1	\1,d1
	helpm1	\1,d0

	movem.l	-64(a2),d0-d7
	or.l	-(a3),d7
	or.l	-(a4),d7
	or.l	-(a3),d6
	or.l	-(a4),d6
	or.l	-(a3),d5
	or.l	-(a4),d5
	or.l	-(a3),d4
	or.l	-(a4),d4
	or.l	-(a3),d3
	or.l	-(a4),d3
	or.l	-(a3),d2
	or.l	-(a4),d2
	or.l	-(a3),d1
	or.l	-(a4),d1
	or.l	-(a3),d0
	or.l	-(a4),d0
	
	helpm2	\1,d7
	helpm2	\1,d6
	helpm2	\1,d5
	helpm2	\1,d4
	helpm2	\1,d3
	helpm2	\1,d2
	helpm2	\1,d1
	helpm2	\1,d0

	sub.w	#64,a2

	endm


;y set 6
;	REPT \1
;o set 6
;		REPT 16
;			move.l	o(a2),y(a0)
;o set o+160
;y set y+160
;		ENDR
;	ENDR


; mission aborted, we'll generate them next time
;generateRightSizeVertical
;;	move.l	#rightSideVertical,a0
;;	lea		rightSideVertical,a0
;	move.w	#$2079,(a0)+			;	move.l	$addr,a0
;	move.l	#screenpointer2,(a0)+	;	$addr
;	move.w	#$41e8,(a0)+			;	lea		off(a0),a0
;	move.w	#16*160+136,(a0)+		;	off
;	move.w	#$43f9,(a0)+			;	lea		$addr,a1
;	move.l	#_offset,(a0)+			;	$addr
;
;	move.w	#$45f9,(a0)+			;	lea		$addr,a2
;	move.l	#right+4*16*4-32,(a0)+	;	addr
;	move.w	#$47f9,(a0)+			;	lea		$addr,a3
;	move.l	#middle+4*16*4,(a0)+	;	addr
;
;	move.l	#$2A4A4E63,(a0)+		;	move.l	a2,a5		;	move.l	a3,usp
;
;	move.w	#7,d7
;
;;loop
;	move.l	#$244D4e6b,(a0)+		;	move.l	a5,a2		;	move.l	usp,a3
;	move.w	#$49f9,(a0)+			;	lea		$addr,a4
;	move.l	#left+4*16*4,(a0)+		;	addr
;
;	move.l	#$3019d040,(a0)+		;	move.w	(a1)+,d0	;	add.w	d0,d0
;	move.w	#$94c0,(a0)+			;	sub.w	d0,a2
;
;	move.l	#$3019d040,(a0)+		;	move.w	(a1)+,d0	;	add.w	d0,d0
;	move.w	#$96c0,(a0)+			;	sub.w	d0,a3
;
;	move.l	#$3019d040,(a0)+		;	move.w	(a1)+,d0	;	add.w	d0,d0
;	move.w	#$98c0,(a0)+			;	sub.w	d0,a4
;
;	move.w	#$2C48,(a0)+			;	move.l	a0,a6
;	move.w	#$DDFC,(a0)+			;	add.l	x,a6
;	move.l	#(264-16*2-8)*160,(a0)+	;	x
;
;	rts



; doBlock1  	= 94
; doBlock3 1	= 176
; doBlock3 2	= 304
; doBlock3 3	= 432
; doBlock3 4	= 560
; doBlock3 5 	= 688
; doBlock3 4	= 816
; doBlock3 7 	= 944			=>  ~ 4016 byts can be saved



rightSide_Vertical
	move.l	screenpointer2,a0
	add.l	#16*160+136,a0
	lea		_offset,a1
	lea		right+4*16*4-32,a2
	lea		middle+4*16*4,a3
	move.l	a2,a5

	move.l	a5,a2
	lea		left+4*16*4,a4


	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*2-8)*160,a6
	doBlock1						;					+8*160
	lea		7*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 7							
	add.l 	#8*160-8,a0

;;;;;;;;;;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*4-8)*160,a6
	doBlock1							; 16*160
	lea		6*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 6
	add.l	#8*160-8,a0

;;;;;;;;;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*6-8)*160,a6
	doBlock1
	lea		5*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 5
	add.l	#8*160-8,a0

;;;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*8-8)*160,a6
	doBlock1					
	lea		4*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 4
	add.l	#8*160-8,a0

;;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*10-8)*160,a6
	doBlock1
	lea		3*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 3
	add.l	#8*160-8,a0

;;;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*12-8)*160,a6
	doBlock1
	lea		2*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 2
	add.l	#8*160-8,a0

;;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.w	(a1),d0
	add.w	d0,d0
	sub.w	d0,a4

	move.l	a0,a6
	add.l	#(264-16*14-8)*160,a6
	doBlock1
	lea		1*16*160(a0),a6			;4DEE 4600			+7*16*160
	doBlock3 1
	add.l	#8*160-8,a0
;;;;
	move.l	a5,a2				
	lea		middle+4*16*4,a3
	lea		left+4*16*4,a4

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a2

	move.w	(a1)+,d0
	add.w	d0,d0
	sub.w	d0,a3

	move.l	a0,a6
	add.l	#(264-16*16-8)*160,a6
	doBlock1

	rts



helpm3	macro
o set y
		REPT \1
			move.l	\2,o(a0)
			move.l	\2,o(a6)
o set o+16*160
		ENDR
y set y+160
	endm	

do8once	macro
	movem.l	(a2),d0-d7
	or.w	(a3)+,d0
	or.w	(a3)+,d1
	or.w	(a3)+,d2
	or.w	(a3)+,d3
	or.w	(a3)+,d4
	or.w	(a3)+,d5
	or.w	(a3)+,d6
	or.w	(a3)+,d7

	move.l	d0,y+160*0(a0)
	move.l	d1,y+160*1(a0)
	move.l	d2,y+160*2(a0)
	move.l	d3,y+160*3(a0)
	move.l	d4,y+160*4(a0)
	move.l	d5,y+160*5(a0)
	move.l	d6,y+160*6(a0)
	move.l	d7,y+160*7(a0)
	endm


do16 macro
y set 6+16*160

	helpm3	\1,d0
	helpm3	\1,d1
	helpm3	\1,d2
	helpm3	\1,d3
	helpm3	\1,d4
	helpm3	\1,d5
	helpm3	\1,d6
	helpm3	\1,d7

	movem.l	32(a2),d0-d7
	or.w	(a3)+,d0
	or.w	(a3)+,d1
	or.w	(a3)+,d2
	or.w	(a3)+,d3
	or.w	(a3)+,d4
	or.w	(a3)+,d5
	or.w	(a3)+,d6
	or.w	(a3)+,d7
y set y-16*160
	helpm3	\1,d0
	helpm3	\1,d1
	helpm3	\1,d2
	helpm3	\1,d3
	helpm3	\1,d4
	helpm3	\1,d5
	helpm3	\1,d6
	helpm3	\1,d7

	endm

loopreg macro

	endm

_oplistLeftSizeVertical
	dc.l	$21400000
	dc.l	$2d400000
	dc.l	$21410000
	dc.l	$2d410000
	dc.l	$21420000
	dc.l	$2d420000
	dc.l	$21430000
	dc.l	$2d430000
	dc.l	$21440000
	dc.l	$2d440000
	dc.l	$21450000
	dc.l	$2d450000
	dc.l	$21460000
	dc.l	$2d460000
	dc.l	$21470000
	dc.l	$2d470000

generateLeftSizeVertical
	lea		_oplistLeftSizeVertical,a6


	move.l	leftSideVerticalPointer,a0
	move.w	#$2079,(a0)+			;	move.l	$addr,a0
	move.l	#screenpointer2,(a0)+	;	$addr
	move.w	#$41e8,(a0)+			;	lea		off(a0),a0
	move.w	#16*160+8,(a0)+			;	off
	move.w	#$43f9,(a0)+			;	lea		$addr,a1
	move.l	#_offset,(a0)+			;	$addr
	move.w	#$49f9,(a0)+			;	lea		$addr,a4
	move.l	#vertLeft,d0
	add.l	#32,d0
	move.l	d0,(a0)+				;	$addr
	move.w	#$4bf9,(a0)+			;	lea		$addr,a5
	move.l	#vertLefti,d0		
	add.l	#16,d0
	move.l	d0,(a0)+				;	$addr
;	loop
	move.w	#160,a5
	moveq	#7,d7
	move.w	#160*16,d2

;	a0 = code buffer
;	a5 = 160
; 	d7 = # iterations main block
.generateBlock
	move.w	#6,d6					; d6 = y


	move.l	#$244c264d,(a0)+			;	move.l	a4,a2		;	move.l	a5,a3
	move.l	#$3019d040,(a0)+			;	move.w	(a1)+,d0	;	add.w	d0,d0
	move.l	#$d4c0d6d9,(a0)+			;	add.w	d0,a2		;	add.w	(a1)+,a3
; a0 is generated code
; d1 is local y (initial = 6)
; d5 is 160
;	do8once --->
;		move.l	#$4cd200ff,(a0)+		;	movem.l	(a2),d0-d7
;		move.w	#$805b,(a0)+			;	or.w	(a3)+,d0
;		move.w	#$825b,(a0)+			;	or.w	(a3)+,d1
;		move.w	#$845b,(a0)+			;	or.w	(a3)+,d2
;		move.w	#$865b,(a0)+			;	or.w	(a3)+,d3
;		move.w	#$885b,(a0)+			;	or.w	(a3)+,d4
;		move.w	#$8a5b,(a0)+			;	or.w	(a3)+,d5
;		move.w	#$8c5b,(a0)+			;	or.w	(a3)+,d6
;		move.w	#$8e5b,(a0)+			;	or.w	(a3)+,d7
;		move.w	#$2140,(a0)+			;	move.l	d0,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2141,(a0)+			;	move.l	d1,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2142,(a0)+			;	move.l	d2,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2143,(a0)+			;	move.l	d3,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2144,(a0)+			;	move.l	d4,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2145,(a0)+			;	move.l	d5,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2146,(a0)+			;	move.l	d6,off(a0)
;		move.w	d1,(a0)+				;	off
;		add.w	#160,d1					;	off + 160
;		move.w	#$2147,(a0)+			;	move.l	d7,off(a0)
	move.l	#$4cd200ff,(a0)+			;	movem.l	(a2),d0-d7
	move.l	#$805b825b,(a0)+			; 	or d0-d1
	move.l	#$845b865b,(a0)+			;	or d2-d3
	move.l	#$885b8a5b,(a0)+			;	or d4-d5
	move.l	#$8c5b8e5b,(a0)+			;	or d6-d7

	move.w	d6,d1						;	o set 6

	move.w	#$2140,d4
	REPT 8
		move.w	d4,(a0)+				; move.l	dx,off(a0)
		addq.w	#1,d4					; 	d4 =	move.l	d(x+1),off(a0)
		move.w	d1,(a0)+
		add.w	a5,d1					; off + 160
	ENDR
	tst.w	d7
	beq		.done
	; end do8once

	move.w	#16*160,d0
	muls	d7,d0
	move.w	#$4de8,(a0)+				;	lea	off(a0),a6
	move.w	d0,(a0)+					;	off

	; start do16
	move.w	#160*16+6,d6				; y set 6+16*160

	move.l	a6,a1
	jsr		generateLeftSizeVerticalCodeBlock

;	do16 part 2
	move.l	#$4CEA00FF,(a0)+			;	movem.l	off(a2),d0-d7
	move.w	#32,(a0)+					;	off=32
	move.l	#$805b825b,(a0)+			; 	or d0-d1
	move.l	#$845b865b,(a0)+			;	or d2-d3
	move.l	#$885b8a5b,(a0)+			;	or d4-d5
	move.l	#$8c5b8e5b,(a0)+			;	or d6-d7

	sub.w	#16*160,d6					; y set y-16*160

	move.l	a6,a1
	jsr		generateLeftSizeVerticalCodeBlock
	move.w	#$41e8,(a0)+			;	lea		off(a0),a0
	move.w	#8+16*1*160,(a0)+
	dbra	d7,.generateBlock
.done
	move.w	#$4e75,(a0)+
	rts




generateLeftSizeVerticalCodeBlock
	move.w	#8-1,d3
.loopreg
		move.l	(a1)+,d4
		move.l	(a1)+,d5
		move.w	d7,d0
		subq.w	#1,d0
		move.w	d6,d1						; o set y
.loop
			move.w	d1,d4					; set off = o
			move.w	d1,d5					; set off = o
			move.l	d4,(a0)+				; move.l d0,off(a0)
			move.l	d5,(a0)+				; move.l d0,off(a6)
			add.w	d2,d1					;
		dbra	d0,.loop
	add.w	a5,d6
	dbra	d3,.loopreg
	rts



;leftSide_Vertical2
;	move.l	screenpointer2,a0
;	add.l	#16*160+8,a0
;	lea		_offset,a1
;	lea		vertLeft+32,a4
;	lea		vertLefti+16,a5
;
;;;;;;;;;;;
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;	do8once
;	lea		7*16*160(a0),a6
;	do16 7
;	move.b	#0,$

;	add.w	#8+16*1*160,a0
;
;;;;;;;;;;;
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;	do8once
;	lea		6*16*160(a0),a6
;	do16 6
;	add.w	#8+16*1*160,a0
;
;;;
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;		lea		5*16*160(a0),a6
;		do16 5
;;;
;	add.w	#8+16*1*160,a0
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;		lea		4*16*160(a0),a6
;		do16 4
;;;
;	add.w	#8+16*1*160,a0
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;		lea		3*16*160(a0),a6
;		do16 3
;;;
;	add.w	#8+16*1*160,a0
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;		lea		2*16*160(a0),a6
;		do16 2
;;;
;	add.w	#8+16*1*160,a0
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;		lea		1*16*160(a0),a6
;		do16 1
;
;;;
;	add.w	#8+16*1*160,a0
;	move.l	a4,a2
;	move.l	a5,a3
;
;	move.w	(a1)+,d0
;	add.w	d0,d0
;	add.w	d0,a2
;
;	add.w	(a1)+,a3
;y set 6
;		do8once
;	rts

;16*2 = 32

prepMoveTabl
	lea		moveTabBase,a0
	lea		moveTab,a1
	move.w	#3-1,d7
.ol
	move.w	#1024/2-1,d6
	lea		moveTabBase,a0
.il
		move.l	(a0)+,(a1)+
	dbra	d6,.il
	dbra	d7,.ol
	rts

curOff		dc.w	0

unrollLoop	macro
		move.l	(a2),d1
		moveq	#0,d2
		move.w	(a1),d1
		add.w	d6,a1
		cmp.w	d0,d1
		blt		.ok\@
			and.w	d0,d1
.ok\@
		tst.w	d1
		bge		.notok\@
			and.w	d0,d1
.notok\@
		move.w	d1,(a0)+
	endm

changeOffset
	lea		_offset,a0
	lea		_fraction_offset,a2
;	move.w	#16-1,d7
	lea		moveTab,a1
	add.w	curOff,a1
	move.w	#16*2-1,d0
	move.w	distanceOff,d6
;.loop
;		move.l	(a2),d1
;		moveq	#0,d2
;		move.w	(a1),d1
;		add.w	d6,a1
;		cmp.w	d0,d1
;		blt		.ok
;			and.w	d0,d1
;.ok		
;		tst.w	d1
;		bge		.notok
;			and.w	d0,d1
;.notok
;		move.w	d1,(a0)+
;
;	dbra	d7,.loop
	rept 16
		unrollLoop
	endr

	move.l	sndh_pointer,a0
	cmp.b	#$99,$b8(a0)
	bne		.ok2
		move.b	#0,$b8(a0)
		add.w	#4,speedListOffx
.ok2
	lea		speedListx,a0
	add.w	speedListOffx,a0
	move.w	(a0)+,d0
	move.w	(a0)+,distanceOff
	add.w	d0,curOff
	and.w	#4096-1,curOff
	rts

distanceOff	dc.w	10

speedListx
	dc.w	8,12
	dc.w	10,14
	dc.w	14,18
	dc.w	18,22
	dc.w	24,26
	dc.w	28,30
	dc.w	32,36
	dc.w	34,44
	dc.w	36,50
	dc.w	38,52

speedListOffx	dc.w	0

curOffStepWaiter	dc.w	40

curOffStep			dc.w	0

_fraction_offset	ds.l	32



changeOffset3
	lea		_offset,a0
	move.w	#16-1,d7
	move.w	#16*2,d6
	move.w	#16*2,d0

.loop
	move.w	(a0),d1
	add.w	d6,d1
	cmp.w	d0,d1
	blt		.ok
		sub.w	d0,d1
.ok
	move.w	d1,(a0)+
	subq.w	#2,d6
	dbra	d7,.loop
	rts


timer_b_openbottom
		move.w	#$2100,sr
		stop	#$2100
		dcb.w	48,$8080

		clr.b	$ffff820a.w			;60 Hz
		dcb.w	5,$4e71				;
		move.b	#2,$ffff820a.w			;50 Hz		
		rte




;	move.w	#$2100,sr
;	stop	#$2100
;    move.w  #$2700,sr
;	movem.l	d1/d2/a0,-(sp)
; 
;    clr.b   $fffffa1b.w                     ;Timer B control (stop)
;    lea $ffff8209.w,a0          ;Hardsync						;8
;    moveq   #127,d1												;4
;.sync:      
;		tst.b   (a0)											;8
;	beq.s   .sync												;8
;    move.b  (a0),d2												;8
;    sub.b   d2,d1												;4
;    lsr.l   d1,d1												;10
;    REPT 29
;    	or.l d7,d7
;    ENDR
;    nop
;	clr.b	$ffff820a.w			;60 Hz
;	REPT 8
;		nop
;	ENDR
;    move.b  #2,$FFFF820A.w  ; 50 hz
;    movem.l (sp)+,d1/d2/a0
;    rte


fillBackDrop
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.l	a0,a2
	move.l	a1,a3
	move.w	#%1111,d0
	move.w	#-1,d1
	move.w	#%1111000000000000,d2

	;left
	add.w	#10,a0
	add.w	#10,a1
	move.w	#264-1,d7
.il1
		move.w	d0,(a0)
		move.w	d0,(a1)
		add.w	#160,a0
		add.w	#160,a1
		dbra	d7,.il1

	;middle
	move.l	a2,a0
	move.l	a3,a1
	move.w	#264-1,d7
.il2
o set 18
		REPT 17
			move.w	d1,o(a0)
			move.w	d1,o(a1)
o set o+8
		ENDR
		add.w	#160,a0
		add.w	#160,a1
	dbra	d7,.il2

	;right
	move.l	a2,a0
	move.l	a3,a1
	add.w	#146,a0
	add.w	#146,a1
	move.w	#264-1,d7
.il3
		move.w	d2,(a0)
		move.w	d2,(a1)
		add.w	#160,a0
		add.w	#160,a1
	dbra	d7,.il3
	move.w	#$4e75,fillBackDrop

	rts


	SECTION DATA

_derp
	REPT 2
		REPT 8
			dc.l	0
		ENDR
		REPT 8
			dc.l	%00000000000011111111<<12
		ENDR
	ENDR

topright_inner2
x set 0
	REPT 8
		REPT x
			dc.l	%11111111<<12
		ENDR
		REPT 8-x
			dc.l	0
		ENDR
x set x+1
	ENDR
x set 0
	REPT 8
		REPT x
			dc.l	0
		ENDR
		REPT 8-x
			dc.l	%11111111<<12
		ENDR
x set x+1
	ENDR
	; lol, bugshit
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0



vertLefti2
	REPT 3
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	%0000111111110000,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
		dc.w	0,0
	ENDR


vertLefti
	REPT 3
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
	ENDR

vertLeft
	REPT 3
				;CDEF0123456789ABCDEF
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
		dc.l	%11111111000000000000
	ENDR


topright_inner								; 16*8*2 = 256
;0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
;1,0
	dc.w	%0,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
;2,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
;3,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
;4,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
;5,0
	dc.w	%1000000000000000,0
	dc.w	%1000000000000000,0
	dc.w	%1000000000000000,0
	dc.w	%1000000000000000,0
	dc.w	%1000000000000000,0
	dc.w	%1000111111110000,0
	dc.w	%1000111111110000,0
	dc.w	%1000111111110000,0
;6,0
	dc.w	%1100000000000000,0
	dc.w	%1100000000000000,0
	dc.w	%1100000000000000,0
	dc.w	%1100000000000000,0
	dc.w	%1100000000000000,0
	dc.w	%1100000000000000,0
	dc.w	%1100111111110000,0
	dc.w	%1100111111110000,0
;7,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110000000000000,0
	dc.w	%1110111111110000,0
;8,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
	dc.w	%1111000000000000,0
;9,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
	dc.w	%1111100000000000,0
;10,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
	dc.w	%1111110000000000,0
;11,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
	dc.w	%1111111000000000,0
;12,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
	dc.w	%1111111100000000,0
;13,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
	dc.w	%0111111110000000,0
;14,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
	dc.w	%0011111111000000,0
;15,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
	dc.w	%0001111111100000,0
;16,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0
	dc.w	%0000111111110000,0


topleft_inner
;0
	dc.w	%0000111111110000					;17*8*2 = 272
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
;1
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
	dc.w	%0000011111111000
;2
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
;3
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
	dc.w	%0000000111111110
;4
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
	dc.w	%0000000011111111
;5
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
	dc.w	%0000000001111111
;6
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
	dc.w	%0000000000111111
;7
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
	dc.w	%0000000000011111
;8
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
	dc.w	%0000000000001111
;9
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000000000000111
	dc.w	%0000111111110111
;10
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000111111110011
	dc.w	%0000111111110011
;11
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000000000000001
	dc.w	%0000111111110001
	dc.w	%0000111111110001
	dc.w	%0000111111110001
;12
	dc.w	%0
	dc.w	%0
	dc.w	%0
	dc.w	%0
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
;13
	dc.w	%0
	dc.w	%0
	dc.w	%0
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
;15
	dc.w	%0
	dc.w	%0
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
;16
	dc.w	%0
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
;17
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0000111111110000


left
	REPT 6
		REPT 8
			dc.l	0
		ENDR
		REPT 8
			dc.l	%11110000000000000000<<12					; 6*16*4 = 384
		ENDR
	ENDR

middle
	REPT 6
		REPT 8
			dc.l	%00001111111100000000<<12					; 6*16*4 = 384
		ENDR	
		REPT 8
			dc.l	0
		ENDR
	ENDR

right
	REPT 6
		REPT 8
			dc.l	%00000000000011111111<<12					; 6*16*4 = 384
		ENDR
		REPT 8
			dc.l	0
		ENDR
	ENDR

topright_outer
								 ;;;;	
	;		 0123456789ABCDEF0123456789ABCDEF
;0
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
;1
	dc.l	%11111000000000000000<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
	dc.l	%11111000000011111111<<12
;2	
	dc.l	%11111100000000000000<<12
	dc.l	%11111100000000000000<<12
	dc.l	%11111100000011111111<<12
	dc.l	%11111100000011111111<<12
	dc.l	%11111100000011111111<<12
	dc.l	%11111100000011111111<<12
	dc.l	%11111100000011111111<<12
	dc.l	%11111100000011111111<<12
;3
	dc.l	%11111110000000000000<<12
	dc.l	%11111110000000000000<<12
	dc.l	%11111110000000000000<<12
	dc.l	%11111110000011111111<<12
	dc.l	%11111110000011111111<<12
	dc.l	%11111110000011111111<<12
	dc.l	%11111110000011111111<<12
	dc.l	%11111110000011111111<<12
;4
	dc.l	%11111111000000000000<<12
	dc.l	%11111111000000000000<<12
	dc.l	%11111111000000000000<<12
	dc.l	%11111111000000000000<<12
	dc.l	%11111111000011111111<<12
	dc.l	%11111111000011111111<<12
	dc.l	%11111111000011111111<<12
	dc.l	%11111111000011111111<<12
;5
	dc.l	%01111111100000000000<<12
	dc.l	%01111111100000000000<<12
	dc.l	%01111111100000000000<<12
	dc.l	%01111111100000000000<<12
	dc.l	%01111111100000000000<<12
	dc.l	%01111111100011111111<<12
	dc.l	%01111111100011111111<<12
	dc.l	%01111111100011111111<<12
;6
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110000000000<<12
	dc.l	%00111111110011111111<<12
	dc.l	%00111111110011111111<<12
;7	
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111000000000<<12
	dc.l	%00011111111011111111<<12
;8
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
	dc.l	%00001111111100000000<<12
;9
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
	dc.l	%00000111111110000000<<12
;10
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
	dc.l	%00000011111111000000<<12
;11
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
	dc.l	%00000001111111100000<<12
;12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
	dc.l	%00000000111111110000<<12
;13
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
	dc.l	%10000000011111111000<<12
;14
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
	dc.l	%11000000001111111100<<12
;15
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
	dc.l	%11100000000111111110<<12
;16
	dc.l	%11110000000011111111<<12		; 8 * 4 * 16=  (+512+512+256)
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12
	dc.l	%11110000000011111111<<12


botleft_outer
;0
	;		 CDEF0123456789ABCDEF	
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
;1
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
;2
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
;3
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
;4
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
;5
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
;6
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
;7
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
;8
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
;9
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%11111111011111111000
;10
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%11111111001111111100
	dc.l	%11111111001111111100
;11
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%11111111000111111110
	dc.l	%11111111000111111110
	dc.l	%11111111000111111110
;12
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
;13
	dc.l	%00000000000001111111
	dc.l	%00000000000001111111
	dc.l	%00000000000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
;14
	dc.l	%00000000000000111111
	dc.l	%00000000000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
;15
	dc.l	%00000000000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
;16 - end
	dc.l	%11111111000000001111		; 8*4*16=. 512 (+512+256)
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111


topleft_outer
;0
	;		 CDEF0123456789ABCDEF	
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
;1
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
	dc.l	%01111111100000000111
;2
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
	dc.l	%00111111110000000011
;3
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
	dc.l	%00011111111000000001
;4
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
	dc.l	%00001111111100000000
;5
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
	dc.l	%00000111111110000000
;6
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
	dc.l	%00000011111111000000
;7
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
	dc.l	%00000001111111100000
;8
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
	dc.l	%00000000111111110000
;9
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%00000000011111111000
	dc.l	%11111111011111111000
;10
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%00000000001111111100
	dc.l	%11111111001111111100
	dc.l	%11111111001111111100
;11
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%00000000000111111110
	dc.l	%11111111000111111110
	dc.l	%11111111000111111110
	dc.l	%11111111000111111110
;12
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%00000000000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
	dc.l	%11111111000011111111
;13
	dc.l	%00000000000001111111
	dc.l	%00000000000001111111
	dc.l	%00000000000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
	dc.l	%11111111000001111111
;14
	dc.l	%00000000000000111111
	dc.l	%00000000000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
	dc.l	%11111111000000111111
;15
	dc.l	%00000000000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
	dc.l	%11111111000000011111
;16 - end
	dc.l	%11111111000000001111			;8*4*16	= 512 (+256)
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111
	dc.l	%11111111000000001111



hor_outer
		;	;0123456789ABCDEF0123456789ABCDEF
	dc.l	%11110000000011111111000000001111						;64				
	dc.l	%11111000000001111111100000000111
	dc.l	%11111100000000111111110000000011
	dc.l	%11111110000000011111111000000001
	dc.l	%11111111000000001111111100000000
	dc.l	%01111111100000000111111110000000
	dc.l	%00111111110000000011111111000000
	dc.l	%00011111111000000001111111100000
	dc.l	%00001111111100000000111111110000
	dc.l	%00000111111110000000011111111000
	dc.l	%00000011111111000000001111111100
	dc.l	%00000001111111100000000111111110
	dc.l	%00000000111111110000000011111111
	dc.l	%10000000011111111000000001111111
	dc.l	%11000000001111111100000000111111
	dc.l	%11100000000111111110000000011111

hor_inner
	dc.l	%00001111111100000000111111110000						;64
	dc.l	%00000111111110000000011111111000
	dc.l	%00000011111111000000001111111100
	dc.l	%00000001111111100000000111111110
	dc.l	%00000000111111110000000011111111
	dc.l	%10000000011111111000000001111111
	dc.l	%11000000001111111100000000111111
	dc.l	%11100000000111111110000000011111
	dc.l	%11110000000011111111000000001111
	dc.l	%11111000000001111111100000000111
	dc.l	%11111100000000111111110000000011
	dc.l	%11111110000000011111111000000001
	dc.l	%11111111000000001111111100000000
	dc.l	%01111111100000000111111110000000
	dc.l	%00111111110000000011111111000000
	dc.l	%00011111111000000001111111100000

hor_outer_bottom
		;	;0123456789ABCDEF0123456789ABCDEF
	dc.l	%11110000000011111111000000001111	;12					;64
	dc.l	%11100000000111111110000000011111	;13
	dc.l	%11000000001111111100000000111111	;14
	dc.l	%10000000011111111000000001111111	;15
	dc.l	%00000000111111110000000011111111	;0
	dc.l	%00000001111111100000000111111110	;1
	dc.l	%00000011111111000000001111111100	;2
	dc.l	%00000111111110000000011111111000	;3
	dc.l	%00001111111100000000111111110000	;4
	dc.l	%00011111111000000001111111100000	;5
	dc.l	%00111111110000000011111111000000	;6
	dc.l	%01111111100000000111111110000000	;7
	dc.l	%11111111000000001111111100000000	;8
	dc.l	%11111110000000011111111000000001	;9
	dc.l	%11111100000000111111110000000011	;10
	dc.l	%11111000000001111111100000000111	;11


hor_inner_bottom
	dc.l	%00001111111100000000111111110000	;4					;64
	dc.l	%00011111111000000001111111100000	;5
	dc.l	%00111111110000000011111111000000	;6
	dc.l	%01111111100000000111111110000000	;7
	dc.l	%11111111000000001111111100000000	;8
	dc.l	%11111110000000011111111000000001	;9
	dc.l	%11111100000000111111110000000011	;10
	dc.l	%11111000000001111111100000000111	;11
	dc.l	%11110000000011111111000000001111	;12
	dc.l	%11100000000111111110000000011111	;13
	dc.l	%11000000001111111100000000111111	;14
	dc.l	%10000000011111111000000001111111	;15
	dc.l	%00000000111111110000000011111111	;0
	dc.l	%00000001111111100000000111111110	;1
	dc.l	%00000011111111000000001111111100	;2
	dc.l	%00000111111110000000011111111000	;3


moveTabBase		
	include "fx/checker/movement.s"

smfxpicture1
	incbin	"fx/checker/smfxA.bin"				; what!? not packed!

smfxpicture2
	incbin	"fx/checker/smfxB.bin"				; what!? not packed!


	SECTION BSS
_offsetDirection	ds.w	1
_offset				ds.w	20


	SECTION DATA
	