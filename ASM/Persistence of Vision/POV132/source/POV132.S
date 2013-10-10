*************************************************************************
*			PERSISTENCE OF VISION 132			*
*			-------------------------			*
*									*
* Coded by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Art by:	KID							*
*									*
*									*
* Music by:	ISO of Sentry						*
*									*
*									*
*************************************************************************

	opt	o+

multinop	MACRO
		rept	\1
		nop
		endr
		ENDM






;***********************************************************************
begin		jmp	menu(pc)
run_me		tst.l	prg_name
		beq.s	clean_exit
		move.l	#null,a1
		sub.l	#run_me,a1
		add.l	#null-run_me,a1
		move.l	a1,-(sp)
		move.l	#begin-$100,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		pea	0.w
		pea	0.w
		move.l	prg_name(pc),-(sp)
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
clean_exit	clr.w	-(sp)
		trap	#1
		ds.l	128
prg_name	dc.l	0

prog1		dc.b	'playing.pov',0
	even
prog2		dc.b	'mathmati.meg',0
	even
prog3		dc.b	'copier.pov',0
	even
prog4		dc.b	'PROG4.PRG',0
	even
prog5		dc.b	'PROG5.PRG',0
	even
prog6		dc.b	'PROG6.PRG',0
	even
prog7		dc.b	'PROG7.PRG',0
	even
prog8		dc.b	'PROG8.PRG',0
	even
prog9		dc.b	'PROG9.PRG',0
	even


null		dc.l	0


menu		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
.clear_bss	clr.b	(a0)+
		subq.l	#1,d0
		bne.s	.clear_bss

		pea	0.w
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move	USP,a0
		move.l	a0,usp_save

		move.l	$ffff8200.w,base_save
		move.b	#2,$ffff820a.w		;50Hz

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,screen_base

		lsr.l	#8,d0		;set screen base
		move.b	d0,screen_low
		lsr.l	#8,d0
		move.b	d0,screen_hi

		bsr	save_old

		bsr	sort_pic

		moveq	#1,d0
		jsr	tune

		move	#$2700,SR
		jsr	set_isr
		clr.w	vsync_flag
		move	#$2300,SR

main_loop	tst.w	vsync_flag
		beq.s	main_loop

		clr.w	vsync_flag
		clr.b	$ffff8260.w

		move.b	screen_hi(pc),$ffff8201.w
		move.b	screen_low(pc),$ffff8203.w

		movem.l	left+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		moveq	#0,d0		;low rez
		moveq	#2,d1		;high rez

		lea	$ffff8260.w,a0
		lea	$ffff820a.w,a1

		move.w	#1336-1-24,d4
no_top		dbf	d4,no_top

		move.l	line_ptr,a5	;20
		tst.b	(a5)		;4
		bpl.s	.loop3
		lea	scroll_line,a5	;restart message
		move.l	a5,line_ptr
.loop3		tst.w	scroll_number
		bne.s	.loop2
		move.w	#WIDTH,scroll_number
		moveq	#0,d3
.get		move.b	(a5)+,d3
		move.l	a5,line_ptr
		sub.w	#32,d3
		mulu	#(7*2),d3	;DEPTH*2
		lea	font,a5
		add.l	d3,a5	;letter address is in a5
;transfer letter into buffer
		lea	sbuffer,a3
		REPT	7		;DEPTH of scroll font
		move.w	(a5)+,(a3)+
		ENDR
.loop2
		move	#$2100,SR
		stop	#$2100
		move	#$2300,SR
		move.w	#30-1,d4
.loop		dbf	d4,.loop

		move.b	#0,$ffff820a.w

		multinop	8

		move.b	#2,$ffff820a.w

		moveq	#12,d2

wait_scrn	move.b	$ffff8209.w,d3		;wait for left of scrn
		beq.s	wait_scrn

		sub.b	d3,d2		;get into side border solidly
		rol.w	d2,d2

		multinop	87

		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)


		move.w	#1,d3		;2

; 1 NOP=4 cycles
;***********************************************************************
;scroll routine is embeded in full screen NOPs
;---------------------------------------------
;						CYCLES
;						------

		move.l	screen_base,a5		;5
		lea	230*49+152(a5),a5	;2
		lea	224(a5),a2		;2
		lea	sbuffer,a4		;3

		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen
		lea	230(a2),a2		;2 down a line on screen
		roxl.w	(a4)+			;3 shift buffer
		move.w	sr,d6			;2 get the status regster
		and.w	d3,d6			;1 mask off all but carry flag
		or.w	d6,(a2)			;3 poke right pixel to screen

		move.b	d0,(a1)
		move.b	d1,(a1)

		and.w	#%1111111111101111,SR	;5 clear X flag
		multinop	13-5

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	12

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

;***********************************************************************
;scroller continued....
		roxl.w	224(a5)	;4
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)
		nop
;***********************************************************************

		move.b	d0,(a1)
		move.b	d1,(a1)
		nop
		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		roxl.w	224(a5)		;second line of scroller
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)

		lea	logo_back_cols,a2

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)

		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)


		roxl.w	24(a5)		;4 cycles
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;8

		and.w	#$3fff,d3	;8
		roxl.w	#1,d3		;8
		move.w	d3,(a5)		;8
		lea	230(a5),a5	;8

		roxl.w	224(a5)
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)
		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)

		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		roxl.w	224(a5)		;4th line in scroller
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)
		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)
		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)

		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		roxl.w	224(a5)
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)
		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)
		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)
		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		roxl.w	224(a5)		;5th line down
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	120(a5)
		roxl.w	112(a5)
		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)
		roxl.w	56(a5)
		roxl.w	48(a5)

		roxl.w	40(a5)
		roxl.w	32(a5)
		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)

		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		roxl.w	224(a5)		;7th line (last one)
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	168(a5)
		roxl.w	160(a5)
		roxl.w	152(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	144(a5)
		roxl.w	136(a5)
		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)

		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)
		roxl.w	72(a5)

		roxl.w	64(a5)
		roxl.w	56(a5)
		roxl.w	48(a5)
		roxl.w	40(a5)
		roxl.w	32(a5)

		roxl.w	24(a5)
		roxl.w	16(a5)
		roxl.w	8(a5)

		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5
		subq.w	#1,scroll_number

		multinop	2

		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

*******************************************************************
TOP_LINES	equ	45	;No of top lines for logo

		move.w	#TOP_LINES-1,d5	;number of lines in logo area
		nop
top_side	multinop	5
		move.w	(a2)+,$ffff8242.w	;change scroller colour
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		dbf	d5,top_side

		move.w	#168-1,d5	;2 nops
		multinop	6
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

make_pal	move.w	#0,$ffff8240.w	;DYNAMIC CODE *DO NOT ALTER*
		move.w	#0,$ffff8242.w
		move.w	#0,$ffff8244.w
		move.w	#0,$ffff8246.w
		move.w	#0,$ffff8248.w
		move.w	#0,$ffff824a.w
		move.w	#0,$ffff824c.w
		move.w	#0,$ffff824e.w
		move.w	#0,$ffff8250.w
		move.w	#0,$ffff8252.w
		move.w	#0,$ffff8254.w
		move.w	#0,$ffff8256.w
		move.w	#0,$ffff8258.w
		move.w	#0,$ffff825a.w
		move.w	#0,$ffff825c.w
		move.w	#0,$ffff825e.w

		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	3
main_no_sides	multinop	9
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		dbf	d5,main_no_sides

		moveq	#33-1,d5		;lower border code
		multinop	7
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	89

		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	89

		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	89

		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		nop
		nop
		move.b	d0,(a1)
		multinop	8
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		move.b	d1,(a1)

		multinop	87
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12

border_no_sides	move.b	d1,(a0)		;main border loop
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	9	;this would be 12 NOPS but is reduced 'cos of DBF
		dbf	d5,border_no_sides

		jsr	tune+2
;		move.w	#$123,$ffff8240.w

;* NOT USUAL POV CHECK AS WE ONLY HAVE A COUPLE OF REGISTERS LEFT
;		cmp.b	#1,$fffffc02.w		;escape
;		bne.s	key1
;		clr.l	prg_name
;		bra	stop

key1		cmp.b	#2,$fffffc02.w
		bne.s	key2
		move.l	#prog1,prg_name
		bra	stop

key2		cmp.b	#3,$fffffc02.w
		bne.s	key3
		move.l	#prog2,prg_name
		bra	stop

key3		cmp.b	#4,$fffffc02.w
		bne	main_loop	key4
		move.l	#prog3,prg_name
		bra.s	stop

key4		cmp.b	#5,$fffffc02.w
		bne.s	key5
		move.l	#prog4,prg_name
		bra.s	stop

key5		cmp.b	#6,$fffffc02.w
		bne.s	key6
		move.l	#prog5,prg_name
		bra.s	stop

key6		cmp.b	#7,$fffffc02.w
		bne.s	key7
		move.l	#prog6,prg_name
		bra.s	stop

key7		cmp.b	#8,$fffffc02.w
		bne.s	key8
		move.l	#prog7,prg_name
		bra.s	stop

key8		cmp.b	#9,$fffffc02.w
		bne.s	key9
		move.l	#prog8,prg_name
		bra.s	stop

key9		cmp.b	#$a,$fffffc02.w
		bne	main_loop
		move.l	#prog9,prg_name


stop		move.w	#$2700,sr
		move.l	base_save,$ffff8200.w
		bsr	return_old
		bsr	clear_screen
		moveq	#0,d0
		jsr	tune
		movem.l	org_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	usp_save,a0
		move	a0,USP

flush		btst	#0,$fffffc00.w
		beq.s	clear
		move.b	$fffffc02.w,d0
		bra.s	flush

clear		move.w	#$2300,sr
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		bra	run_me

*********** SCROLLER **********************
WIDTH		EQU	8
BUFFER_SIZE	EQU	7*(WIDTH*2)*2








new_vbl		move.w	#1,vsync_flag
		move.w	#$2700,sr
		move.l	#null_rte,$68.w
		move.w	#$2300,sr
		rte

null_rte	rte

save_old	move.b	$fffffa07.w,old_a07
		move.b	$fffffa09.w,old_a09
		move.b	$fffffa13.w,old_a13
		move.b	$fffffa15.w,old_a15
		move.b	$fffffa19.w,old_a19
		move.b	$fffffa1F.w,old_a1f
		move.l	$134.l,old_134
		move.l	$70.w,old_70
		move.l	$68.w,old_68
		move.l	$44e.w,old_scrn
		move.b	$ffff8260.w,old_rez
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,org_pal
		move.b	#$12,$fffffc02.w
		rts

set_isr		clr.b	$fffffa09.w
		or.b	#1,$fffffa07.w
		bclr	#3,$fffffa17.w
		move.l	#new_vbl,$70.w
		move.l	#null_rte,$68.w
		rts

return_old	move.b	old_a07,$fffffa07.w
		move.b	old_a09,$fffffa09.w
		move.b	old_a13,$fffffa13.w
		move.b	old_a15,$fffffa15.w
		move.b	old_a19,$fffffa19.w
		move.b	old_a1f,$fffffa1F.w
		move.l	old_134,$134.l
		move.l	old_70,$70.w
		move.l	old_68,$68.w
		move.l	old_scrn,$44e.w
		move.b	old_rez,$ffff8260.w
		move.b	#8,$fffffc02.w
		rts






sort_pic
;sort pic palette
		lea	big_pic+2,a0
		lea	make_pal,a1
		move.w	(a0)+,2(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,14(a1)
		move.w	(a0)+,20(a1)
		move.w	(a0)+,26(a1)
		move.w	(a0)+,32(a1)
		move.w	(a0)+,38(a1)
		move.w	(a0)+,44(a1)
		move.w	(a0)+,50(a1)
		move.w	(a0)+,56(a1)
		move.w	(a0)+,62(a1)
		move.w	(a0)+,68(a1)
		move.w	(a0)+,74(a1)
		move.w	(a0)+,80(a1)
		move.w	(a0)+,86(a1)
		move.w	(a0)+,92(a1)

		move.l	screen_base,a1
		lea	168(a1),a1
		lea	left+34,a0
		lea	160*56(a0),a2		;depth of logo
		bsr	move_data

		move.l	screen_base,a1
		lea	328(a1),a1
		lea	right+34,a0
		lea	9600(a0),a2
.loop		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	96(a0),a0
		lea	32(a1),a1
		lea	166(a1),a1
		cmp.l	a0,a2
		bne.s	.loop

		bsr	print_titles

asd		move.l	screen_base,a1
		lea	230*(57)+160(a1),a1
		lea	big_pic+34,a0

		move.w	#205-1,d7
.loop		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		move.l	8(a0),8(a1)
		move.l	12(a0),12(a1)
		move.l	16(a0),16(a1)
		move.l	20(a0),20(a1)
		move.l	24(a0),24(a1)
		move.l	28(a0),28(a1)
		move.l	32(a0),32(a1)
		move.l	36(a0),36(a1)
		move.l	40(a0),40(a1)
		move.l	44(a0),44(a1)
		move.l	48(a0),48(a1)
		move.l	52(a0),52(a1)
		move.l	56(a0),56(a1)
		move.l	60(a0),60(a1)
		move.l	64(a0),64(a1)
		move.l	68(a0),68(a1)
		move.l	72(a0),72(a1)
		move.l	76(a0),76(a1)
		move.l	80(a0),80(a1)
		move.l	84(a0),84(a1)
		move.l	88(a0),88(a1)
		move.l	92(a0),92(a1)
		move.l	96(a0),96(a1)
		move.l	100(a0),100(a1)
		move.l	104(a0),104(a1)
		move.l	108(a0),108(a1)
		move.l	112(a0),112(a1)
		move.l	116(a0),116(a1)
		move.l	120(a0),120(a1)
		move.l	124(a0),124(a1)
		move.l	128(a0),128(a1)
		move.l	132(a0),132(a1)
		move.l	136(a0),136(a1)
		move.l	140(a0),140(a1)
		move.l	144(a0),144(a1)
		move.l	148(a0),148(a1)
		move.l	152(a0),152(a1)
		move.l	156(a0),156(a1)
		move.l	160(a0),160(a1)
		move.l	164(a0),164(a1)
		move.l	168(a0),168(a1)
		move.l	172(a0),172(a1)
		move.l	176(a0),176(a1)
		move.l	180(a0),180(a1)
		move.l	184(a0),184(a1)
		move.l	188(a0),188(a1)
		move.l	192(a0),192(a1)
		move.l	196(a0),196(a1)
		move.l	200(a0),200(a1)
		move.l	204(a0),204(a1)
		move.l	208(a0),208(a1)
		move.l	212(a0),212(a1)
		move.l	216(a0),216(a1)
		move.l	220(a0),220(a1)
		move.l	224(a0),224(a1)
		lea	230(a0),a0
		lea	230(a1),a1
		dbf	d7,.loop
		rts

move_data	movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1	;160 bytes of data moved
		lea	70(a1),a1	;make upto 230 bytes which is overscan width

		cmp.l	a0,a2
		bne.s	move_data
		rts

clear_screen	move.l	screen_base,a0
		move.l	a0,a1
		add.l	#(384*160),a1
.loop		clr.l	(a0)+
		cmp.l	a0,a1
		bne.s	.loop
		rts

*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
* By:		MSD 							*
*									*
* More comments added to allow others to understand			*
*									*
*************************************************************************
*
* Now is fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0

YES=1
yes=YES
NO=0
no=NO

ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	big_pic+34,a0		;alter this to move the titles down the screen
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

NO_LINES	equ	13
		move.w	#NO_LINES-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#6,d1		;chars are 12 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	6
		move.b	BYTE_OFF(a2,d1.w),d5	;get char
		move.b	BYTE_OFF(a3,d1.w),d3	;get char mask

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ELSE	
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d3,d4			;and mask with scrn data
		or.b	d5,d4			;or char data into mask
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d3,d4			;use same mask calculated previously
		or.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ENDC
		ENDC


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+230
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII

		mulu	#6,d1		;chars are 6 bytes each

		REPT	6
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	BYTE_OFF(a3,d1.w),d3

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ELSE
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ENDC
		ENDC

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+230
		ENDR

		lea	8(a0),a0
		dbf	d6,.loop2
		lea	230*6(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts




********************************
	SECTION DATA
********************************

screen_hi	dc.b	6		;screen_base
screen_low	dc.b	0
	even

screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"    POV COMPILATION 132                 "
	dc.b	"                                        "
	dc.b	"    1: PLAYING WITH KNIVES              "
	dc.b	"    2: MATHEMATICA                      "
	dc.b	"    3: COPIER                           "
	dc.b	"                                        "
	dc.b	"    ALL TITLES ARE 1 MEG                "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    100% BUG FREE                       "
	dc.b	"         VERSION!                       "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	even

screen_titles_font	incbin	6x6_font.dat
	even


line_ptr	dc.l	scroll_line

scroll_line
 DC.B "    STAY CALM, THE MIGHTY PERSISTENCE OF VISION MACHINE HAS "
 DC.B "MOVED INTO ACTION.            "
 DC.B "MAC SYS DATA IS PROUD TO PRESENT POV DEMO COMPILATION 132 VERSION "
 dc.b "2.  RELEASE DATE 26TH APRIL 1993.      "
 dc.b "HERE'S THE CREDITS:      MENU CODED BY MAC SYS DATA,      "
 DC.B "GRAFIX BY KILLER D OF ST CONNECTIONS (OZYMANDIAS DID DO SOME "
 DC.B "GRAFIX BUT AS USUAL HE DIDN'T DO AS HE WAS ASKED - HEY OZ I SAID "
 DC.B "A 200 LINE PICTURE!!),     MUSIC BY ISO OF SENTRY.  "
 dc.b "   THIS IS VERSION 2 OF THIS MENU AS THE FIRST DIDN'T WORK "
 DC.B "ON SOME TOS VERSIONS. THE FAULT WAS MINE AS I SPUPIDLY MISS "
 DC.B "CALCULATED SOME OF THE INSTRUCTION CYCLES AND ENDED UP NOT "
 DC.B "REMOVING A COMPLETE LINE OF SIDE BORDER (BUT IT WORKED ON TOS 1.0 AND "
 DC.B "TOS 1.60 BUT NOT TOS 1.2!) SO SORRY TO YOU ALL FOR MAKING "
 DC.B "YOU COPY THIS AGAIN!!!!      "
 DC.B "      HEY GUYS I HAVE SOLD MY 520 STFM TO MY BROTHER TO MAKE "
 dc.b "SPACE FOR MY FALCON SO I NOW OWN A "
 DC.B "4 MEG STE (WITH 210 MEG HARD DISC), A "
 DC.B "1 MEG STFM (NO HARD DISC) AND A 1 MEG AMIGA A500 (NO HARD DISC). I ALSO "
 DC.B "HAVE ACCESS TO A 2 MEG AMIGA A1200 (MY OTHER BROTHERS).     "
 DC.B "I VERY, VERY, VERY NEARLY BOUGHT A 4 MEG FALCON WITH SVGA MONITOR "
 DC.B "THE OTHER DAY BUT I WAS PUT OFF WHEN OZ TOLD ME ABOUT SOME OF THE "
 DC.B "BUGS THEY HAVE FOUND...    I'LL WAIT FOR THE NEW CASE IN AUGUST!    "
 DC.B "   I AM GOING TO LOOK AT A HOUSE TOMORROW WITH MY GIRLFRIEND, IF IT'S "
 DC.B "GOOD INSIDE THEN I'LL SPEND 50,000 POUNDS STERLING AND BUY IT. HEY BILBO "
 DC.B "OF RIPPED OFF - IT I GET THIS HOUSE WE CAN HOLD THE NEXT CODING PARTY THERE (IT'S "
 DC.B "GOT A 95 FOOT BACK GARDEN!).         I HAVE BEEN RATHER BUSY THIS LAST WEEK "
 DC.B "SO I'VE GOT 3 DISCS WORTH OF STUFF READY FOR POV COMPILATIONS, "
 DC.B "UNFORTUNATELY MOST ARE 1 MEG BUT I DID FIND LOADS OF NEAT "
 DC.B "LITTLE INTROS THAT I CAN USE TO FILL THE DISCS UP.  "
 dc.b "   AS YOU CAN SEE THE DEMO 'MATHEMATICA' IS ON THIS DISC, "
 DC.B "IF ANYONE MANAGES TO RIP THE TUNE CAN THEY PLEASE SEND IT TO ME?  "
 DC.B "                  POV SENDS ITS GREETINGS TO.... "
 DC.B "ADRENALIN,   ANIMAL MINE,   BLIND BASTARD,   "
 DC.B "CYNIX,   D-BUG,   DEL,   DELTA FORCE,   DR SYNE,   ERIK PLANKTON,   "
 DC.B "EQUINOX,   ETERNITY,   FUZION,   GEORGE (BART),   "
 DC.B "INNER CIRCLE,   KGB,   MAD VISION,   MUG UK,   NEXT,   NOD,   "
 DC.B "PAL PD,   PIXEL TWINS,   "
 DC.B "PURE ENERGY,   REPLICANTS,   RIPPED OFF,   "
 DC.B "SLAYTANIC CULT,   ST CNX,   STRANGER,   "
 DC.B "THE SYNDICATE   AND   ZEEDYA (DIAMOND DESIGN).        "
 DC.B "      THERE IS LITTLE DISC SPACE LEFT SO I'LL WRAP IT HERE..... "
 DC.B "              OO-ECK, I ALMOST FORGOT THE ADDRESS.......             "
 DC.B "TO CONTACT P.O.V. WRITE TO;-         MAC SYS DATA,        "
 DC.B "P.O. BOX 40,        THORNTON-CLEVELEYS,        LANCASHIRE,        "
 DC.B "FY5 3PH,        ENGLAND.                                          "
 DC.B "                                "
 dc.b	$ff
	even

font	dcb.b	7*2,0		;DEPTH*2
	incbin	"8x8_font.dat"
	even


left	incbin	left.pi1

right	incbin	right.pi1

big_pic	incbin	manga.kid

tune	incbin	faster.xms


logo_back_cols	dcb.w	40,0
		dc.w	$044,$055,$066,$077,$066,$055,$044

	SECTION BSS
bssstart
vsync_flag	ds.w	1
stack_save	ds.l	1
screen_base	ds.l	1
old_a07		ds.b	1
old_a09		ds.b	1
old_a13		ds.b	1
old_a15		ds.b	1
old_a19		ds.b	1
old_a1f		ds.b	1
old_134		ds.l	1
old_70		ds.l	1
old_68		ds.l	1
old_scrn	ds.l	1
old_rez		ds.w	1

usp_save	ds.l	1 
base_save	ds.l	1 

org_pal		ds.b	32

scroll_number	ds.w	1

sbuffer		ds.b	BUFFER_SIZE


	ds.b	256
screens	ds.b	160*384
bssend