; zyncs:
; - ff next scene
; - 01 - more: number of blocks fade in	
; - 0a border
;

vbl_per_fade	equ 5
block_size		equ 60
borderFadeSpeed	equ	1

	section TEXT
init_tosIntro
	move.w	#30,bssBuffer+_fadestepTosInit
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)

	move.w	#-1,bssBuffer+blockList+120
	jsr		genBlockLocs

	move.w	#$2700,sr
	move.l	#tosvbl,$70
	move.w	#$2300,sr

			wait_for_vbl


	move.w	#$777,$ffff8240
	lea		tospal,a0
	move.w	(a0)+,$ffff8240+2*1
	move.w	(a0)+,$ffff8240+2*3
	move.w	(a0)+,$ffff8240+2*2
	move.w	(a0)+,$ffff8240+2*6
	move.w	(a0)+,$ffff8240+2*4
	move.w	(a0)+,$ffff8240+2*12
	move.w	(a0)+,$ffff8240+2*8
	move.w	(a0)+,$ffff8240+2*9
	move.w	(a0)+,$ffff8240+2*11
	move.w	(a0)+,$ffff8240+2*10
	move.w	(a0)+,$ffff8240+2*14
	move.w	(a0)+,$ffff8240+2*15
	move.w	(a0)+,$ffff8240+2*13
	move.w	(a0)+,$ffff8240+2*5
	move.w	(a0)+,$ffff8240+2*7
	move.w	#0,nextScene
.testloop
			wait_for_vbl
			exitOnSpace
		tst.w	nextScene
		bge		.testloop
	rts

tosvbl
	move.l 	screenpointer2,$ff8200
	addq.w 	#1,$466.w
			pushall

	jsr		checkMusicTos
	jsr		drawBlocks32
	move.l	sndh_pointer,a0
	jsr		8(a0)

	tst.w	bssBuffer+fadeOut
	beq		.nofade

	subq.w	#2,bssBuffer+_fadestepTosInit
	bne		.nofade
		move.l	#borders_vbl,$70
.nofade
			popall
	rte


; make list of 60 blocks, that indicates:
; 0:	done
; 4:	draw col4
; 3:	draw col3
; 2:	draw col2
; 1:	draw col1


drawBlocks32
	move.w	#block_size-1,d7
	lea		bssBuffer+blockList,a0
	lea		bssBuffer+blockLocs,a3
	move.l	screenpointer2,a2
	;;; HSAX!
	add.w	#160,a2
	lea		drawRoutList,a4
	move.w	#-1,d6
	moveq	#0,d5
.checkBlock
		move.w	(a3)+,d1
		move.w	(a0)+,d0
		beq		.checkBlock
		blt		.stopit
.drawBlock
		; d0 is the value of the color
		subq.w	#4,d0					; here we decrement for further use, color = color - 1
		move.w	d0,-2(a0)				; save color
		; use color for determining offset
		move.l	a2,a1					
		add.w	(a4,d0.w),d1
		add.w	d1,a1

		move.w	2(a4,d0.w),d0
		blt		.fill
.clear
		moveq	#0,d3
		move.w	#32-1,d1
.l
			move.w	d5,(a1,d3.w)
			move.w	d5,8(a1,d3.w)
			add.w	#160,d3
		dbra	d1,.l
		jmp	.checkBlock
.fill
		moveq	#0,d3
		move.w	#32-1,d1
.ll	
			move.w	d6,(a1,d3.w)
			move.w	d6,8(a1,d3.w)
			add.w	#160,d3
		dbra	d1,.ll
		jmp		.checkBlock
.stopit

	move.w	#block_size,d0
	cmp.w	bssBuffer+blockActivationOffset,d0
	bne		.notdone
		move.w	#-1,bssBuffer+fadeOut
.notdone
	rts

;15 draw 1	d6,0 off	;0001	2*1		0,-1	;1,3,2,6,
;14 draw 2	d6,2 off	;0011	2*3		2,-1
;13 draw 3	d5,0 off	;0010	2*2		0,0
;12 draw 4	d6,4 off	;0110	2*6		4,-1
;11 draw 5	d5,2 off	;0100	2*4		2,0
;10 draw 6	d6,6 off	;1100	2*12	6,-1
;9 draw 7	d5,4 off	;1000	2*8		4,0
;8 draw 8	d6,0 off	;1001	2*9		0,-1
;7 draw 9	d6,2 off	;1011	2*11	2,-1
;6 draw 10	d5,0 off	;1010	2*10	0,0
;5 draw 11	d6,4 off	;1110	2*14	4,-1
;4 draw 12	d6,0 off	;1111	2*15	0,-1
;3 draw 13	d5,2 off	;1101	2*13	2,0
;2 draw 14	d5,4 off	;0101	2*5		6,0
;1 draw 15	d6,2 off	;0111	2*7		2,-1

;0 skip

checkMusicTos
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	beq		.return				; check if zync is set
	move.b	#0,$b8(a0)			; if its set, reset
	cmp.b	#$ff,d0				; check for next scene
	bne		.noExit
		move.w	#-1,nextScene
.noExit
	cmp.b	#$fe,d0
	bne		.noBorder
		move.w	#-1,bssBuffer+_flashborder
		jmp		.return
.noBorder
	cmp.b	#$10,d0
	ble		.setPal1
.setPal2
		sub.w	#$10,d0
		lea		tospal2,a0
		move.w	(a0)+,$ffff8240+2*1
		move.w	(a0)+,$ffff8240+2*3
		move.w	(a0)+,$ffff8240+2*2
		move.w	(a0)+,$ffff8240+2*6
		move.w	(a0)+,$ffff8240+2*4
		move.w	(a0)+,$ffff8240+2*12
		move.w	(a0)+,$ffff8240+2*8
		move.w	(a0)+,$ffff8240+2*9
		move.w	(a0)+,$ffff8240+2*11
		move.w	(a0)+,$ffff8240+2*10
		move.w	(a0)+,$ffff8240+2*14
		move.w	(a0)+,$ffff8240+2*15
		move.w	(a0)+,$ffff8240+2*13
		move.w	(a0)+,$ffff8240+2*5
		move.w	(a0)+,$ffff8240+2*7	
		jmp		.palSet
.setPal1
		lea		tospal,a0
		move.w	(a0)+,$ffff8240+2*1
		move.w	(a0)+,$ffff8240+2*3
		move.w	(a0)+,$ffff8240+2*2
		move.w	(a0)+,$ffff8240+2*6
		move.w	(a0)+,$ffff8240+2*4
		move.w	(a0)+,$ffff8240+2*12
		move.w	(a0)+,$ffff8240+2*8
		move.w	(a0)+,$ffff8240+2*9
		move.w	(a0)+,$ffff8240+2*11
		move.w	(a0)+,$ffff8240+2*10
		move.w	(a0)+,$ffff8240+2*14
		move.w	(a0)+,$ffff8240+2*15
		move.w	(a0)+,$ffff8240+2*13
		move.w	(a0)+,$ffff8240+2*5
		move.w	(a0)+,$ffff8240+2*7		
.palSet
	; now we know its set, number determines amount of blocks set
	lea		bssBuffer+blockList,a0
	lea		blockActivationOrderList,a1
	add.w	bssBuffer+blockActivationOffset,a1
	moveq	#15*4,d2	
	move.w	d0,d1		;
	add.w	d1,bssBuffer+blockActivationOffset
	subq.w	#1,d0
.activateBlock
		moveq	#0,d1
		move.b	(a1)+,d1		; get block offset
		move.w	d2,(a0,d1.w)	; activate block
	dbra	d0,.activateBlock
.return
	rts


_borderFadeWaiter	dc.w	borderFadeSpeed

borders_vbl
	addq.w 	#1,$466.w
	pushall
	move.l	screenpointer2,$ffff8200
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.l	sndh_pointer,a0
	jsr		8(a0)

	tst.w	bssBuffer+_fadeDone
	beq		.gogo
			tst.w	bssBuffer+_haxix
			bne		.ggg
			move.w	#-1,bssBuffer+_haxix
			move.b  #0,$FFFFFA07.w  ; tb
			move.b  #0,$FFFFFA13.w  ; tb
.ggg
			move.w	#-1,nextScene
		popall
		rte
.gogo
	move.w	top_color,$ffff8240
	tst.w	_resetColorList
	bne		.noreset
		move.l	#colorList,colorListPointer
		move.w	#-1,_resetColorList
.noreset

	jsr		checkMusicTos

	subq.w	#1,_borderWaiter
	bge		.noTB
	move.w	#$2700,sr
	move.b  #1,$FFFFFA07.w  ; tb
	move.b  #1,$FFFFFA13.w  ; tb
	move.l	timer_b_pointer,$120
	move.b  #1,$FFFFFA21.w  ; anfangszeile des rasters laden
	move.b  #8,$FFFFFA1B.w  ; ereignisz„hlermodus
	move.w	#$2300,sr
.noTB
	move.w	#0,_firstTime
	move.w	#192,_tbLines
.ttt
	popall
	rte



_borderWaiter		dc.w	11

timer_b_pointer		dc.l	timer_b_left
top_color			dc.w	$777

colorList
	dc.w	$777
	dc.w	$666
	dc.w	$555
	dc.w	$444
	dc.w	$333
	dc.w	$222
	dc.w	$111
	dc.w	$000
	dc.w	$000




colorListPointer	dc.l	colorList
_firstTime	dc.w	-1
timer_b_left
	move.w	#$2700,sr
	pusha0
	move.l	colorListPointer,a0
	move.w	(a0),$ffff8240

	REPT 15
		or.l	d7,d7
	ENDR

	move.w	#$777,$ffff8240


	subq.w	#1,_tbLines
	bgt		.kk
		move.b	#0,$FFFFFA07.w
.kk


	tst.w	_firstTime
	bne		.end
	move.w	#1,_firstTime
	subq.w	#1,_borderFadeWaiter
	bge		.end
		move.w	#borderFadeSpeed,_borderFadeWaiter
		cmp.l	#colorList+14,a0
		beq		.leftDone
			add.w	#2,a0
			move.l	a0,colorListPointer
			jmp		.end
.leftDone
	subq.w	#1,_twaiter
	bne		.end
	move.l	#timer_b_right,timer_b_pointer
	move.w	#0,_resetColorList
	move.w	#5,_twaiter
.end
	popa0
	move.w	#$2300,sr
	rte

_twaiter		dc.w	5
_resetColorList	dc.w	-1
_tbLines		dc.w	192
timer_b_right
	pusha0
	move.w	#$2700,sr
	move.w	#0,$ffff8240
	REPT 30/2
		add.w	a0,a0
	ENDR

	move.l	colorListPointer,a0
	move.w	(a0),$ffff8240

	tst.w	_firstTime
	bne		.end
	move.w	#1,_firstTime
	subq.w	#1,_borderFadeWaiter
	bge		.end
		move.w	#borderFadeSpeed,_borderFadeWaiter
		cmp.l	#colorList+14,a0
		beq		.rightDone
			add.w	#2,a0
			move.l	a0,colorListPointer

.end
	subq.w	#1,_tbLines
	bgt		.kk
		REPT 64/2
			add.w	a0,a0
		ENDR
		move.w	#$777,$ffff8240

	subq.w	#1,_tbLines
	bgt		.kk
		move.b	#0,$FFFFFA07.w


.kk	
	move.w	#$2300,sr
	popa0
	rte

.rightDone
	subq.w	#1,_tbLines
	bgt		.kk2
		REPT 64/2
			add.w	a0,a0
		ENDR
		move.w	#$777,$ffff8240
.kk2
	subq.w	#1,_twaiter
	bne		.end2
	move.w	#5,_twaiter
	move.l	#timer_b_bottom,timer_b_pointer
	move.w	#0,_resetColorList
.end2
	move.w	#$2300,sr
	popa0
	rte


timer_b_bottom
	move.w	#$2700,sr
	pusha0
	move.w	#0,$ffff8240
	subq.w	#1,_tbLines
	bgt		.kk
		subq.w	#1,_tbLines
		bgt		.kk
			move.b	#0,$FFFFFA07.w
			REPT 92/2
				add.w	a0,a0
			ENDR
			move.l	colorListPointer,a0
			move.w	(a0),$ffff8240

			subq.w	#1,_borderFadeWaiter
			bge		.end
				move.w	#borderFadeSpeed,_borderFadeWaiter
				cmp.l	#colorList+14,a0
				beq		.bottomDone
					add.w	#2,a0
					move.l	a0,colorListPointer
.end
.kk	
	move.w	#$2300,sr
	popa0
	rte

.bottomDone
	subq.w	#1,_twaiter
	bne		.okk
		move.w	#0,_resetColorList
		move.l	#timer_b_top,timer_b_pointer
		move.w	#0,_resetColorList
.okk
	move.w	#$2300,sr
	popa0
	rte

timer_b_top
	move.w	#$2700,sr
	move.w	#0,$ffff8240

	tst.w	_firstTime
	bne		.end
		move.w	#1,_firstTime
		subq.w	#1,_borderFadeWaiter
		bge		.end
			cmp.w	#$000,top_color
			beq		.done
				sub.w	#$111,top_color
				move.w	#borderFadeSpeed,_borderFadeWaiter
.end
	move.w	#$2300,sr
	rte


.done
	move.w	#-1,bssBuffer+_fadeDone
	move.w	#$2300,sr
	rte

genBlockLocs
	lea		bssBuffer+blockLocs,a0
	moveq	#0,d0
	move.w	#6-1,d7
.ol
		move.w	#10-1,d6
		move.w	d0,d1
.il
			move.w	d1,(a0)+
			add.w	#16,d1			
		dbra	d6,.il
		add.w	#32*160,d0
	dbra	d7,.ol
	rts

	section DATA

blockActivationOrderList
	dc.b	28
	dc.b	36
	dc.b	62
	dc.b	86
	dc.b	102
	dc.b	16
	dc.b	20
	dc.b	42
	dc.b	4
	dc.b	0
	dc.b	6
	dc.b	40
	dc.b	12
	dc.b	60
	dc.b	82
	dc.b	32
	dc.b	74
	dc.b	106
	dc.b	2
	dc.b	84
	dc.b	34
	dc.b	72
	dc.b	8
	dc.b	90
	dc.b	48
	dc.b	92
	dc.b	30
	dc.b	108
	dc.b	68
	dc.b	112
	dc.b	98
	dc.b	116
	dc.b	54
	dc.b	56
	dc.b	14
	dc.b	66
	dc.b	44
	dc.b	100
	dc.b	78
	dc.b	118
	dc.b	94
	dc.b	52
	dc.b	46
	dc.b	70
	dc.b	114
	dc.b	22
	dc.b	96
	dc.b	24
	dc.b	50
	dc.b	18
	dc.b	104
	dc.b	80
	dc.b	38
	dc.b	58
	dc.b	110
	dc.b	10
	dc.b	88
	dc.b	76
	dc.b	64
	dc.b	26
; we keep:
;	- amount of total blocks
;	- the list to keep the state of each block
;	- a list of activation order
;	- current pointer into the order list
;	- block locations into the screen

drawRoutList
	dc.w	2,-1			;	move.w	#$001,$ffff8240+2*7				+22	=	7
	dc.w	6,0				;	move.w	#$111,$ffff8240+2*5				-8	=	5
	dc.w	2,0				;	move.w	#$122,$ffff8240+2*13			-2	=	13
	dc.w	0,-1			;	1111	move.w	#$222,$ffff8240+2*15	+1	=	15
	dc.w	4,-1			;	1110	move.w	#$223,$ffff8240+2*14	+4	=	14
	dc.w	0,0				;	1010	move.w	#$323,$ffff8240+2*10	-1	=	10
	dc.w	2,-1			;	1011	move.w	#$333,$ffff8240+2*11	+2	=	11
	dc.w	0,-1			;	1001	move.w	#$343,$ffff8240+2*9		+1	=	9
	dc.w	4,0				;	1000	move.w	#$443,$ffff8240+2*8		-4	=	8
	dc.w	6,-1			;	1100	move.w	#$444,$ffff8240+2*12	+8 	=	12
	dc.w	2,0				;	0100	move.w	#$544,$ffff8240+2*4		-2	=	4
	dc.w	4,-1			;	0110	move.w	#$555,$ffff8240+2*6		+4	=	6
	dc.w	0,0				;	0010	move.w	#$655,$ffff8240+2*2		-1	=	2
	dc.w	2,-1			;	0011	move.w	#$665,$ffff8240+2*3		+2	=	3
	dc.w	0,-1			;	0001	move.w	#$666,$ffff8240+2*1		+1	= 	1		


		;1,3,2,6,4,12,8,

tospal	;ommitting intial 777
	dc.w	$773,$763,$753,$743,$733,$633,$533,$433,$333,$323,$313,$302,$202,$101,$0
tospal2
	dc.w	$775,$773,$772,$670,$570,$470,$371,$171,$060,$050,$040,$030,$020,$010,$0

	section BSS
	rsreset
_fadestepTosInit			rs.w	1
_fadeDone					rs.w	1
blockActivationOffset		rs.w	1
_flashborder				rs.w	1
_haxix						rs.w	1
fadeOut						rs.w	1
blockList					rs.w	61		
blockLocs					rs.w	60		; 126
	SECTION DATA