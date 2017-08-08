; zaa to trigger flashes

	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC


	IFEQ STANDALONE

		incdir	..


		section	text



start:		
	pea	demo				;Run demo in supervisor
	move.w	#$26,-(sp)			;supexec()
	trap	#14				;
	addq.l	#6,sp				;

	clr.w	-(sp)				;pterm()
	trap	#1				;



demo:	
	lea		save_screenadr,a0		;Save old screen address
	move.b	$ffff8201.w,(a0)+		;
	move.b	$ffff8203.w,(a0)+		;
	move.b	$ffff820d.w,(a0)+		;

	movem.l	$ffff8240.w,d0-d7		;Save old palette
	movem.l	d0-d7,save_pal			;

	move.l	#music,sndh_pointer

	move.b	$ffff8260.w,save_res		;Save old resolution
	clr.b	$ffff8260.w			;Set low resolution

	move.b	#$12,$fffffc02.w		;Kill mouse

	;----

	move.l	#screen1+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	add.l	#$10000,d0
	move.l	d0,screenpointer2



	move.l	screenpointer2,$ffff8200.w

	move.w	#$2700,sr			;Stop all interrupts
	lea	save_vect_mfp,a0
	move.l	$70.w,(a0)+			;Save old VBL
	move.l	$68.w,(a0)+			;Save old HBL
	move.l	$134.w,(a0)+			;Save old Timer A
	move.l	$120.w,(a0)+			;Save old Timer B
	move.l	$114.w,(a0)+			;Save old Timer C
	move.l	$110.w,(a0)+			;Save old Timer D
	move.l	$118.w,(a0)+			;Save old ACIA
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	clr.b	$fffffa07.w			;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w			;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w			;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w			;Interrupt mask B (Timer-C & D)

	lea		dummy,a0
	move.l	#brainhurts_vbl,$70.w			;Install our own VBL
	move.l	a0,$68.w			;Install our own HBL
	move.l	a0,$134.w
	move.l	a0,$120.w
	move.l	#brainhurts_timer_a,$134.w			;Install our own Timer A
	move.l	#dummy,$120.w			;Install our own Timer B
	move.l	a0,$114.w			;Install our own Timer C
	move.l	a0,$110.w			;Install our own Timer D
	move.l	a0,$118.w			;Install our own ACIA

	move.w	#$2300,sr			;Interrupts back on

	move.l	#$7700601,d0
	move.l	#$6600552,d1
	move.l	#$5500403,d2
	move.l	#$4400304,d3
	move.l	#$3300205,d4
	move.l	#$2200106,d5
	move.l	#$0770007,d6
	move.l	#$7770070,d7
	movem.l	brainpalette,d0-d7
	movem.l	d0-d7,$ffff8240

	moveq	#1,d0
	move.l	sndh_pointer,a0
	jsr		(a0)

	;---------------------------------------
.mainloop:	
	tst.w	vblcount			;Wait VBL
	beq.s	.mainloop			;
	clr.w	vblcount			;

	cmp.b	#$39,$fffffc02.w		;Space?
	bne.s	.mainloop			;
	;----------------------------------------


	move.w	#$2700,sr			;Stop all interrupts
	lea	save_vect_mfp,a0
	move.l	(a0)+,$70.w			;Restore old VBL
	move.l	(a0)+,$68.w			;Restore old HBL
	move.l	(a0)+,$134.w			;Restore old Timer A
	move.l	(a0)+,$120.w			;Restore old Timer B
	move.l	(a0)+,$114.w			;Restore old Timer C
	move.l	(a0)+,$110.w			;Restore old Timer D
	move.l	(a0)+,$118.w			;Restore old ACIA
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	move.w	#$2300,sr			;Interrupts back on

	move.b	save_res,$ffff8260.w		;Restore old resolution

	movem.l	save_pal,d0-d7			;Restore old palette
	movem.l	d0-d7,$ffff8240.w		;

	lea	save_screenadr,a0		;Restore old screen address
	move.b	(a0)+,$ffff8201.w		;
	move.b	(a0)+,$ffff8203.w		;
	move.b	(a0)+,$ffff820d.w		;

	move.b	#$8,$fffffc02.w			;Enable mouse

	rts
	ENDC

brainhurts_init:
	move.l	#0,sscrl_offset
;	jsr		prepPics
	move.l	sndh_pointer,a0
	move.b	#0,$b8(a0)

	move.w	#$2700,sr
	move.l	#brainhurts_vbl,$70.w			;Install our own VBL
	move.l	#brainhurts_timer_a,$134.w			;Install our own Timer A
	move.l	#dummy,$120.w			;Install our own Timer B
	move.w	#$2300,sr

.x
			exitOnSpace
	tst.w	nextScene
	bge		.x

	rts
movetimer	dc.w	10000
brainhurts_vbl:		
	move.l	d0,-(sp)
	move.l	a0,-(sp)

;	pushd0
;	pusha0
	moveq	#0,d0
	lea		$ffff8240,a0
	rept 8
		move.l	d0,(a0)+
	endr
	jsr		sscrl_setup_list		;Setup syncscroller combinations
	jsr		brainhurts_scroll_movement

	move.l	screenpointer2,d0			;Get base screen
	add.l	sscrl_offset,d0			;Add syncscroller offset (scroll position)
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w			;Set screen

	move.l	sndh_pointer,a0
	cmp.b	#$aa,$b8(a0)
	beq		.flashTimerA
	;Start up Timer A each VBL
	clr.b	$fffffa19.w			;Timer-A control (stop)
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer A)
	bset	#5,$fffffa13.w			;Interrupt mask A (Timer A)
	move.b	#94,$fffffa1f.w			;Timer A Delay (data)
	move.b	#4,$fffffa19.w			;Timer A Predivider (start Timer A)
	move.l	#brainhurts_timer_a,$134.w			;Install our own Timer A
	bclr	#3,$fffffa17.w			;Automatic end of interrupt

	sub.w	#32,brainoff
	bge		.kkk
		move.w	#0,brainoff
.kkk

	move.l	sndh_pointer,a0
	jsr		8(a0)
	move.b	$b8(a0),d0
	cmp.b	#$ff,d0
	bne		.okz
		move.w	#-1,movetimer
.okz

	subq.w	#1,movetimer
	bge		.ok
		move.w	#1,_scrollDirection
;		move.b	#0,$fffc123
	move.l	screenpointer2,a1				;5
	add.w	screenOff,a1					;4
	add.w	#8*160,a1
	moveq	#0,d0
		add.l	#266*230,a1
		move.l	d0,0(a1)
		move.l	d0,4(a1)



		subq.w	#1,scrolloutframes
		bge		.ok
			move.w	#-1,nextScene
.ok
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	rte

.flashTimerA
	move.b	#0,$b8(a0)
	;Start up Timer A each VBL
	clr.b	$fffffa19.w			;Timer-A control (stop)
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer A)
	bset	#5,$fffffa13.w			;Interrupt mask A (Timer A)
	move.b	#94,$fffffa1f.w			;Timer A Delay (data)
	move.b	#4,$fffffa19.w			;Timer A Predivider (start Timer A)
	move.l	#brainhurts_flashtimer_a,$134.w			;Install our own Timer A
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	move.w	#32*7,brainoff

	jsr		drawText

	move.l	sndh_pointer,a0
	jsr		8(a0)

	move.l	(sp)+,a0
	move.l	(sp)+,d0
	rte


scrolloutframes	dc.w	50
_waiter	dc.w	50
brainoff	dc.w	0


brainhurts_timer_a:	
	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
		dcb.w 	84,$4e71			;Zzzz
	clr.b	$ffff820a.w			;60 Hz
		dcb.w 	9,$4e71				;
	move.b	#2,$ffff820a.w			;50 Hz

	lea	$ffff8209.w,a0			;Hardsync
	moveq	#127,d1				;
.sync:		
	tst.b	(a0)				;
	beq.s	.sync				;
	move.b	(a0),d2				;
	sub.b	d2,d1				;
	lsr.l	d1,d1				;

;		dcb.w	61,$4e71


		;lea		brainpalette,a2		

		lea		brainpalette,a2								;3
		add.w	brainoff,a2									;4
		movem.l	(a2),d0-d6/a1								;76 = -2
		dcb.w	61-21-2-5,$4e71

;		movem.l	brainpalette,d0-d6/a1				;80 = 20
;		dcb.w	61-21-2,$4e71
		lea		$ffff8240,a4
	IFEQ STANDALONE
	ELSE
	nop
	ENDC


	;Do the Syncscroll 
	lea		sscrl_jumplist,a3	;3
	move.l	(a3)+,a0			;3
	moveq	#2,d7				;1
	rept	7
		jsr	(a0)				;4*7=28  Seven scanlines of different linewidth
	endr

	move.l	d0,(a4)+
	move.l	d1,(a4)+

	rept 6
;		nop
	endr



		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3


		movem.l	d2-d6/a1,(a4)
		dcb.w	88-29-2-14-2-1,$4e71

	move.w	#219-1-1-180,d6							; 219 total, but 38 first --> 181 left

	IFEQ STANDALONE
	ELSE
	nop
	ENDC

	move.l	mybrainhurtsPointer,a2					;3
	add.l	sourceOff,a2					;5
	move.l	screenpointer2,a1				;5
	add.w	screenOff,a1					;4
;
	tst.w	_scrollDirection				;4
	blt		.left							;3 taken
	nop
.right
	add.w	#8*160-4,a1						;
	jmp		.cont
.left										; path = 4+2+3 = 9
	add.w	#8*160+216,a1					;2
	nop
	nop
	nop
.cont
	
		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-2,$4e71

.il
		nop
		nop

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

	REPT 7	; 7*12= 84										; need to do this 270 times
	move.l	(a2)+,(a1)+						;5				
	move.l	(a2)+,(a1)+						;5	
	add.w	#230-8,a1						;2
	ENDR

		dcb.w	88-84,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-2-3,$4e71
		dbra	d6,.il



		nop
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		REPT 44
		add.l	d4,d4
		ENDR

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-2-2,$4e71

		move.w	#180-1,d6

.il2
		nop
		nop

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		REPT 44
		or.l	d7,d7
		ENDR
;		dcb.w	88,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-2-3,$4e71
		dbra	d6,.il2

		nop	

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		REPT 44
		or.l	d7,d7
		ENDR

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	8,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	85,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-2,$4e71

		move.w	#44-1,d6

;	REPT 44
.il3
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		REPT 44
		or.l	d7,d7
		ENDR

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11-3,$4e71
		dbra	d6,.il3

;	ENDR
	jsr copyData
	movem.l	(sp)+,d0-a6
	rte




brainhurts_flashtimer_a
		movem.l	d0-a6,-(sp)
	move.w	#$2100,sr			;Enable HBL
	stop	#$2100				;Wait for HBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa19.w			;Stop Timer A
		dcb.w 	84,$4e71			;Zzzz
	clr.b	$ffff820a.w			;60 Hz
		dcb.w 	9,$4e71				;
	move.b	#2,$ffff820a.w			;50 Hz

	lea	$ffff8209.w,a0			;Hardsync
	moveq	#127,d1				;
.sync:		
	tst.b	(a0)				;
	beq.s	.sync				;
	move.b	(a0),d2				;
	sub.b	d2,d1				;
	lsr.l	d1,d1				;

;		dcb.w	61,$4e71


		;lea		brainpalette,a2		

		lea		brainpalette,a2								;3
		add.w	brainoff,a2									;4
		movem.l	(a2),d0-d6/a1								;76 = -2
		dcb.w	61-21-2-5,$4e71

;		movem.l	brainpalette,d0-d6/a1				;80 = 20
;		dcb.w	61-21-2,$4e71
		lea		$ffff8240,a4
	IFEQ STANDALONE
	ELSE
	nop
	ENDC


	;Do the Syncscroll 
	lea		sscrl_jumplist,a3	;3
	move.l	(a3)+,a0			;3
	moveq	#2,d7				;1
	rept	7
		jsr	(a0)				;4*7=28  Seven scanlines of different linewidth
	endr

	move.l	d0,(a4)+
	move.l	d1,(a4)+

	rept 6
;		nop
	endr
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3


		movem.l	d2-d6/a1,(a4)

	movem.l	(sp)+,d0-a6
	rte


first	dc.w	0

sourceOff		dc.l	0
screenOff		dc.w	0
copyDataLeftRight	dc.w	-1
leftMax			dc.w	26


	;a0,a3
	;d7
	;d6 taken

copyData
	tst.w	_scrollDirection
	beq		.skip
	blt		.leftScroll
.rightScroll	
;	move.b	#0,$ffffc123
	sub.l	#270*8,sourceOff
	blt		.ok2
	sub.w	#8,screenOff	
	rts
.ok2
	move.l	#-8*270,sourceOff
	sub.w	#8,screenOff
	rts
.skip
	rts

.leftScroll
	subq.w	#1,leftMax
	blt		.ok
	add.l	#270*8,sourceOff
	add.w	#8,screenOff	

	rts
.ok
	move.w	#0,leftMax
	add.w	#8,screenOff	
	rts

_scrollDirection	dc.w	-1

;spam
;	REPT 270
;	move.l	(a2)+,(a1)+						;5				
;	move.l	(a2)+,(a1)+						;5	
;	add.w	#230-8,a1						;2
;	ENDR
;	add.w	#135*230,a1						;2

;d set 0
;	REPT 135
;	move.l	(a0)+,d(a1)						;6
;	move.l	(a0)+,d+4(a1)					;6
;d set d+230
;	ENDR
;	rts

		;Just scroll a few lines and then reset back to top
brainhurts_scroll_movement:
;	subq.w	#1,waiter
;	bgt		.ok
	tst.w	_scrollDirection
	blt		.left
.right
	cmp.l	#224+16,sscrl_offset
	beq		.done
	sub.l	#8,sscrl_offset
	bgt		.ok
		neg.w	_scrollDirection
		move.w	#0,screenOff
		move.l	#0,sourceOff
		move.w	#26,leftMax
	rts
.left
	add.l	#8,sscrl_offset
	cmp.l	#224*2,sscrl_offset
	bne		.ok
		neg.w	_scrollDirection
;		sub.l	#8*270,sourceOff
		move.w	#0,screenOff
.ok
	rts

.done
	move.w	#0,_scrollDirection
	rts
	

drawText
	lea		drawRoutSpecs,a0
	add.w	drawRoutOff,a0
	move.l	(a0)+,a6				;source
	move.l	screenpointer2,a2				;5
	add.w	screenOff,a2					;4
	add.l	(a0)+,a2
	move.w	(a0)+,d0
	move.w	(a0)+,d7

	; now we have d0
	move.w	d0,d5
	subq.w	#1,d5		;loopcounter
	; nowe calc offset
	add.w	d0,d0		;2
	add.w	d0,d0		;4
	add.w	d0,d0		;8
	neg.w	d0
	add.w	#230,d0		; offset!


.ol
	move.w	d5,d6
.il
		move.l	(a6)+,(a2)+
		move.l	(a6)+,(a2)+
		dbra	d6,.il	
		add.w	d0,a2
	dbra	d7,.ol

	sub.w	#12,drawRoutOff
	bge		.ok
		move.w	#24,drawRoutOff
.ok
	rts

;prepPics
;	lea		my+34,a0
;	lea		mybuffer,a1
;	move.w	#32-1,d7
;.il
;	REPT 6
;		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a1)+
;	ENDR
;	add.w	#(20-6)*8,a0
;	dbra	d7,.il
;
;
;	lea		brain+34,a0
;	lea		brainbuffer,a1
;	move.w	#33-1,d7
;.il2
;	REPT 10
;		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a1)+
;	ENDR
;	add.w	#(20-10)*8,a0
;	dbra	d7,.il2
;		
;
;	lea		hurts+34,a0
;	lea		hurtsbuffer,a1
;	move.w	#31-1,d7
;.il3
;	REPT 9
;		move.l	(a0)+,(a1)+
;		move.l	(a0)+,(a1)+
;	ENDR
;	add.w	#(20-9)*8,a0
;	dbra	d7,.il3	
;
;	lea		mybuffer,a0
;	lea		brainbuffer,a1
;	lea		hurtsbuffer,a2
;	move.b	#0,$ffffc123
;	rts

drawRoutOff	dc.w	24
drawRoutSpecs
	dc.l	hurtsbuffer,230*235+198+64-8			;8
		dc.w	9,31-1						;4
	dc.l	brainbuffer,230*203+190+64-8
		dc.w	10,33-1
	dc.l	mybuffer,230*179+222+64-8
		dc.w	6,32-1
		
		section	DATA


mybuffer		incbin	"fx/picture/my2.bin"	
brainbuffer		incbin	"fx/picture/brain.bin" 
hurtsbuffer		incbin	"fx/picture/hurts.bin"

brainpalette		
	dc.w	$000,$101,$567,$456,$445,$345,$334,$234,$223,$123,$112,$012,$777,$542,$433,$556		;0
	dc.w	$111,$111,$567,$456,$445,$345,$334,$234,$223,$123,$112,$112,$777,$542,$433,$556		;1
	dc.w	$222,$222,$567,$456,$445,$345,$334,$234,$223,$223,$222,$222,$777,$542,$433,$556		;2
	dc.w	$333,$333,$567,$456,$445,$345,$334,$334,$333,$333,$333,$333,$777,$543,$433,$556		;3
	dc.w	$444,$444,$567,$456,$445,$445,$444,$444,$444,$444,$444,$444,$777,$544,$444,$556		;4
	dc.w	$555,$555,$567,$556,$555,$555,$555,$555,$555,$555,$555,$555,$777,$555,$555,$556		;5
	dc.w	$666,$666,$667,$666,$666,$666,$666,$666,$666,$666,$666,$666,$777,$666,$666,$666		;6
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777		;7

mybrainhurts2
				incbin	"fx/picture/mybrainhurts4.l77"	;60480/35374			; lets do this like removing the top 270*8 bytes from the memory before we start this effect, and place this binary smartly somewhere
;				ds.b	270*8


mybrainhurtsPointer	ds.l	1

unpackBrainHurts
	move.l	alignpointer8,a0
	moveq	#0,d0
	move.w	#270*8/4-1,d7
.cl
		move.l	d0,(a0)+
	dbra	d7,.cl

	move.l	a0,mybrainhurtsPointer

	lea		mybrainhurts2,a0
	move.l	mybrainhurtsPointer,a1

	jsr		d_lz77
	moveq	#0,d0
	move.w	#270*8/4-1,d7
.cl2
		move.l	d0,(a1)+
	dbra	d7,.cl2

	move.w	#$4e75,unpackBrainHurts
	rts

	IFEQ STANDALONE
sscrl_offset:	dc.l	0
dummy:		rte
music	incbin	msx/stnews.snd

sscrl_linewidths:
	dc.l	sscrl_line0			;+000 bytes
	dc.l	sscrl_line1			;-002 bytes
	dc.l	sscrl_line2			;+024 bytes
	dc.l	sscrl_line3			;+044 bytes
	dc.l	sscrl_line4			;+070 bytes
	dc.l	sscrl_line5			;+026 bytes
	dc.l	sscrl_line6			;-106 bytes

sscrl_combo_table:
	dc.b 	0,0,0,0,0,0,0,0  		;0
 	dc.b 	6,4,3,1,1,1,0,0  		;2
 	dc.b 	6,4,3,1,1,0,0,0  		;4
 	dc.b 	6,4,3,1,0,0,0,0  		;6
 	dc.b 	6,4,3,0,0,0,0,0  		;8
 	dc.b 	6,4,2,2,1,0,0,0  		;10
 	dc.b 	6,4,2,2,0,0,0,0  		;12
 	dc.b 	6,5,4,2,0,0,0,0  		;14
 	dc.b 	6,5,5,4,0,0,0,0  		;16
 	dc.b 	2,1,1,1,0,0,0,0  		;18
 	dc.b 	2,1,1,0,0,0,0,0  		;20
 	dc.b 	2,1,0,0,0,0,0,0  		;22
 	dc.b 	2,0,0,0,0,0,0,0  		;24
 	dc.b 	5,0,0,0,0,0,0,0  		;26
 	dc.b 	6,4,4,1,1,1,0,0  		;28
 	dc.b 	6,4,4,1,1,0,0,0  		;30
 	dc.b 	6,4,4,1,0,0,0,0  		;32
 	dc.b 	6,4,4,0,0,0,0,0  		;34
 	dc.b 	3,1,1,1,1,0,0,0  		;36
 	dc.b 	3,1,1,1,0,0,0,0  		;38
 	dc.b 	3,1,1,0,0,0,0,0  		;40
 	dc.b 	3,1,0,0,0,0,0,0  		;42
 	dc.b 	3,0,0,0,0,0,0,0  		;44
 	dc.b 	2,2,1,0,0,0,0,0  		;46
 	dc.b 	2,2,0,0,0,0,0,0  		;48
 	dc.b 	5,2,0,0,0,0,0,0  		;50
 	dc.b 	5,5,0,0,0,0,0,0  		;52
 	dc.b 	6,4,4,2,1,1,0,0  		;54
 	dc.b 	6,4,4,2,1,0,0,0  		;56
 	dc.b 	6,4,4,2,0,0,0,0  		;58
 	dc.b 	6,5,4,4,0,0,0,0  		;60
 	dc.b 	4,1,1,1,1,0,0,0  		;62
 	dc.b 	4,1,1,1,0,0,0,0  		;64
 	dc.b 	4,1,1,0,0,0,0,0  		;66
 	dc.b 	4,1,0,0,0,0,0,0  		;68
 	dc.b 	4,0,0,0,0,0,0,0  		;70
 	dc.b 	2,2,2,0,0,0,0,0  		;72
 	dc.b 	5,2,2,0,0,0,0,0  		;74
 	dc.b 	5,5,2,0,0,0,0,0  		;76
 	dc.b 	5,5,5,0,0,0,0,0 		;78
 	dc.b 	3,3,1,1,1,1,0,0  		;80
 	dc.b 	3,3,1,1,1,0,0,0  		;82
 	dc.b 	3,3,1,1,0,0,0,0  		;84
 	dc.b 	3,3,1,0,0,0,0,0  		;86
 	dc.b 	3,3,0,0,0,0,0,0  		;88
 	dc.b 	4,2,1,1,0,0,0,0  		;90
 	dc.b 	4,2,1,0,0,0,0,0  		;92
 	dc.b 	4,2,0,0,0,0,0,0  		;94
 	dc.b 	5,4,0,0,0,0,0,0  		;96
 	dc.b 	5,2,2,2,0,0,0,0  		;98
 	dc.b 	5,5,2,2,0,0,0,0  		;100
 	dc.b 	5,5,5,2,0,0,0,0  		;102
 	dc.b 	6,4,4,4,0,0,0,0  		;104
 	dc.b 	4,3,1,1,1,1,0,0  		;106
 	dc.b 	4,3,1,1,1,0,0,0  		;108
 	dc.b 	4,3,1,1,0,0,0,0  		;110
 	dc.b 	4,3,1,0,0,0,0,0  		;112
 	dc.b 	4,3,0,0,0,0,0,0  		;114
 	dc.b 	4,2,2,1,0,0,0,0  		;116
 	dc.b 	4,2,2,0,0,0,0,0  		;118
 	dc.b 	5,4,2,0,0,0,0,0  		;120
 	dc.b 	5,5,4,0,0,0,0,0  		;122
 	dc.b 	5,5,2,2,2,0,0,0  		;124
 	dc.b 	5,5,5,2,2,0,0,0  		;126
 	dc.b 	3,3,3,1,1,0,0,0  		;128
 	dc.b 	3,3,3,1,0,0,0,0  		;130
 	dc.b 	3,3,3,0,0,0,0,0  		;132
 	dc.b 	4,4,1,1,1,0,0,0  		;134
 	dc.b 	4,4,1,1,0,0,0,0  		;136
 	dc.b 	4,4,1,0,0,0,0,0  		;138
 	dc.b 	4,4,0,0,0,0,0,0  		;140
 	dc.b 	4,2,2,2,0,0,0,0  		;142
 	dc.b 	5,4,2,2,0,0,0,0  		;144
 	dc.b 	5,5,4,2,0,0,0,0  		;146
 	dc.b 	5,5,5,4,0,0,0,0  		;148
 	dc.b 	5,5,5,2,2,2,0,0  		;150
 	dc.b 	4,3,3,1,1,1,0,0  		;152
 	dc.b 	4,3,3,1,1,0,0,0  		;154
 	dc.b 	4,3,3,1,0,0,0,0  		;156
 	dc.b 	4,3,3,0,0,0,0,0  		;158
 	dc.b 	4,4,2,1,1,0,0,0  		;160
 	dc.b 	4,4,2,1,0,0,0,0  		;162
 	dc.b 	4,4,2,0,0,0,0,0  		;164
 	dc.b 	5,4,4,0,0,0,0,0  		;166
 	dc.b 	5,4,2,2,2,0,0,0  		;168
 	dc.b 	5,5,4,2,2,0,0,0  		;170
 	dc.b 	5,5,5,4,2,0,0,0  		;172
 	dc.b 	3,3,3,3,1,0,0,0  		;174
 	dc.b 	3,3,3,3,0,0,0,0  		;176
 	dc.b 	4,4,3,1,1,1,0,0 		;178
 	dc.b 	4,4,3,1,1,0,0,0 		;180
 	dc.b 	4,4,3,1,0,0,0,0 		;182
 	dc.b 	4,4,3,0,0,0,0,0 		;184
 	dc.b 	4,4,2,2,1,0,0,0  		;186
 	dc.b 	4,4,2,2,0,0,0,0  		;188
 	dc.b 	5,4,4,2,0,0,0,0  		;190
 	dc.b 	5,5,4,4,0,0,0,0  		;192
 	dc.b 	5,5,4,2,2,2,0,0  		;194
 	dc.b 	5,5,5,4,2,2,0,0  		;196
 	dc.b 	4,3,3,3,1,1,0,0  		;198
 	dc.b 	4,3,3,3,1,0,0,0  		;200
 	dc.b 	4,3,3,3,0,0,0,0  		;202
 	dc.b 	4,4,4,1,1,1,0,0  		;204
 	dc.b 	4,4,4,1,1,0,0,0  		;206
 	dc.b 	4,4,4,1,0,0,0,0  		;208
 	dc.b 	4,4,4,0,0,0,0,0  		;210
 	dc.b 	4,4,2,2,2,0,0,0  		;212
 	dc.b 	5,4,4,2,2,0,0,0  		;214
 	dc.b 	5,5,4,4,2,0,0,0  		;216
 	dc.b 	5,5,5,4,4,0,0,0  		;218
 	dc.b 	3,3,3,3,3,0,0,0  		;220
 	dc.b 	4,4,3,3,1,1,1,0  		;222
 	dc.b 	4,4,3,3,1,1,0,0  		;224
 	dc.b 	4,4,3,3,1,0,0,0  		;226
 	dc.b 	4,4,3,3,0,0,0,0  		;228
 	dc.b 	4,4,4,2,1,1,0,0  		;230
 	dc.b 	4,4,4,2,1,0,0,0  		;232
 	dc.b 	4,4,4,2,0,0,0,0  		;234
 	dc.b 	5,4,4,4,0,0,0,0  		;236
 	dc.b 	5,4,4,2,2,2,0,0  		;238
 	dc.b 	5,5,4,4,2,2,0,0  		;240
 	dc.b 	5,5,5,4,4,2,0,0  		;242
 	dc.b 	4,3,3,3,3,1,0,0  		;244
 	dc.b 	4,3,3,3,3,0,0,0  		;246
 	dc.b 	4,4,4,3,1,1,1,0  		;248
 	dc.b 	4,4,4,3,1,1,0,0  		;250
 	dc.b 	4,4,4,3,1,0,0,0  		;252
 	dc.b 	4,4,4,3,0,0,0,0  		;254

sscrl_jumplist:	
	dc.l	sscrl_line0	
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0
	dc.l	sscrl_line0


				
;------------------------------------------------------
; Syncscroller routines and data
;------------------------------------------------------

palette:	
	dc.w	$0000,$0224,$0422,$0424,$0444,$0557,$0755,$0757
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


sscrl_setup_list:					;Setup the jumptable each VBL
	move.l	screenpointer2,d2
	add.l	sscrl_offset,d2
	and.l	#$000000ff,d2

	lea	sscrl_combo_table,a1		;List of all 256/2 offset combos
	lsr.w	#1,d2				;Reduce to 128 combinations
	lsl.w	#3,d2				;Align with address list (8 byte boundary)
	add.l	d2,a1

	lea	sscrl_linewidths,a0		;List of routs with different linewidths
	lea	sscrl_jumplist,a2		;

	rept	7
		moveq	#0,d0
		move.b	(a1)+,d0			;Get routine to run (0-6)
		lsl.w	#2,d0				;Align to address list (4 byte boundary)
		move.l	(a0,d0.w),(a2)+			;Write address to list
	endr

	rts

;-------------- Overscan routines

	;160 byte line
sscrl_line0:	
	dcb.w	117,$4e71
	move.l	(a3)+,a0			;3 fetch next address
	rts					;4

	;158 byte line
sscrl_line1:	
	dcb.w	94,$4e71
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	17,$4e71
	move.l	(a3)+,a0			;3
	rts					;4

	;184 byte line
sscrl_line2:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	dcb.w	86,$4e71
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	10,$4e71
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;204 byte line
sscrl_line3:	
	dcb.w	96,$4e71
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	15,$4e71
	move.l	(a3)+,a0			;3
	rts					;4

	;230 byte line
sscrl_line4:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	dcb.w	88,$4e71
	move.w	d7,$ffff820a.w			;3
	move.b	d7,$ffff820a.w			;3
	dcb.w	8,$4e71
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;186 byte line
sscrl_line5:	
	dcb.w	2,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	dcb.w	102,$4e71
	move.l	(a3)+,a0			;3
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	nop
	rts					;4

	;54 byte line
sscrl_line6:	
	dcb.w	42,$4e71
	move.b	d7,$ffff8260.w			;3
	move.w	d7,$ffff8260.w			;3
	dcb.w	69,$4e71
	move.l	(a3)+,a0			;3
	rts					;4



			section	bss

vblcount:	ds.w	1

screen1						ds.b	65536+65536
screen2						ds.b	65536
block1						ds.b	65536
screenpointer				ds.l	1
screenpointer2				ds.l	1

nextScene	ds.w	1
save_pal:	ds.w	16
save_screenadr:	ds.l	1
save_vbl:	ds.l	1
save_hbl:	ds.l	1
save_ta:	ds.l	1
save_tb:	ds.l	1
save_tc:	ds.l	1
save_td:	ds.l	1
save_acia:	ds.l	1
save_vect_mfp:	ds.b	28+8
save_res:	ds.b	1
		even	
sndh_pointer	ds.l	1
	ELSE
	ENDC
