*************************************************************************
*			PERSISTENCE OF VISION 133			*
*			-------------------------			*
*									*
* Coded by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Art by:	MAC SYS DATA and ALY (ex POV member)			*
*									*
*									*
* Music by:	BEN DAGLISH from DEFLECTOR relocated using Grazey's util*
*									*
*									*
*************************************************************************

	opt	o+
YES=1
yes=YES
NO=0
no=NO


FINAL	equ	NO




multinop	MACRO
		rept	\1
		nop
		endr
		ENDM




;***********************************************************************
begin		bra	start
		ds.l	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0


start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7

		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
.clear_bss	clr.b	(a0)+
		subq.l	#1,d0
		bne.s	.clear_bss

		pea	0.w
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

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

		jsr	tune		;relocate

		jsr	tune+4		;init tune

		move	#$2700,SR
		jsr	set_isr
		clr.w	vsync_flag
		move	#$2300,SR

main_loop	tst.w	vsync_flag
		beq.s	main_loop

		clr.w	vsync_flag
		clr.b	$ffff8260.w

		tst.w	hertz_delay	;16
		beq.w	.yes		;12

		subq.w	#1,hertz_delay	;20

.yes		move.b	screen_hi(pc),$ffff8201.w
		move.b	screen_low(pc),$ffff8203.w

		movem.l	big_pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		moveq	#0,d0		;low rez
		moveq	#2,d1		;high rez

		lea	$ffff8260.w,a0
		lea	$ffff820a.w,a1

		move.w	#1336-12-10,d4	;-10 for hertz delay check
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
		mulu	#(16*2),d3	;DEPTH*2
		lea	font,a5
		add.w	d3,a5	;letter address is in a5
;transfer letter into buffer
		lea	sbuffer,a4
		REPT	16		;DEPTH of scroll font
		move.w	(a5)+,(a4)+
		ENDR

.loop2		move	#$2100,SR
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

		move.w	#1,d3	;2 word to AND with scroll buffer (speedier than AND.W #1,Dx)

; 1 NOP=4 cycles
;***********************************************************************
;scroll routine is embeded in full screen NOPs
;---------------------------------------------
;						CYCLES
;						------
		move.l	screen_base,a5		;5
		lea	230*44+152(a5),a5	;2
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


;***********************************************************************
		move.b	d0,(a1)
		move.b	d1,(a1)
		lea	230(a2),a2		;2 down a line on screen
		multinop	11
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

;***********************************************************************
;scroller continued....
		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag
		or.w	d6,(a2)		; 3	poke right pixel to screen
		lea	230(a2),a2	; 2	down a line on screen

		roxl.w	(a4)+		; 3	shift buffer
		move.w	sr,d6		; 2	get the status regster
		and.w	d3,d6		; 1	mask off all but carry flag

		multinop	6
		multinop	11

;***********************************************************************

		move.b	d0,(a1)		;HERTZ fiddles
		move.b	d1,(a1)		; "	"

		multinop	11

		or.w	d6,(a2)		; 3	poke right pixel to screen

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		lea	230(a2),a2	; 2	down a line on screen
		roxl.w	(a4)+			;shift buffer
		move.w	sr,d6			;get the status regster
		and.w	d3,d6			;mask off all but carry flag
		or.w	d6,(a2)			;poke right pixel to screen

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		and.w	#%1111111111101111,SR		;clear X flag
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
		roxl.w	96(a5)
		roxl.w	88(a5)
		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)

		move.b	d0,(a1)
		move.b	d1,(a1)
		nop
		roxl.w	56(a5)
		roxl.w	48(a5)
		roxl.w	40(a5)

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)


***** INFORMATION ONLY ****************	open up 1 line of borders
;;		multinop	12
;;		move.b	d1,(a0)
;;		nop
;;		move.b	d0,(a0)
;;		multinop	89
;;		move.b	d0,(a1)
;;		move.b	d1,(a1)
;;		multinop	13
;;		move.b	d1,(a0)
;;		nop
;;		move.b	d0,(a0)
***************************************
***** INFORMATION ONLY - SCROLL 1 PIXEL LINE FULL WIDTH
;;		roxl.w	224(a5)		;4 cycles
;;		roxl.w	216(a5)		;4
;;		roxl.w	208(a5)		;4
;;		roxl.w	200(a5)		;4
;;		roxl.w	192(a5)		;4
;;		roxl.w	184(a5)		;4
;;		roxl.w	176(a5)		;4
;;		roxl.w	168(a5)		;4
;;		roxl.w	160(a5)		;4
;;		roxl.w	152(a5)		;4
;;		roxl.w	144(a5)		;4
;;		roxl.w	136(a5)		;4
;;		roxl.w	128(a5)		;4
;;		roxl.w	120(a5)		;4
;;		roxl.w	112(a5)		;4
;;		roxl.w	104(a5)		;4
;;		roxl.w	96(a5)		;4
;;		roxl.w	88(a5)		;4
;;		roxl.w	80(a5)		;4
;;		roxl.w	72(a5)		;4
;;		roxl.w	64(a5)		;4
;;		roxl.w	56(a5)		;4
;;		roxl.w	48(a5)		;4
;;		roxl.w	40(a5)		;4
;;		roxl.w	32(a5)		;4
;;		roxl.w	24(a5)		;4
;;		roxl.w	16(a5)		;4
;;		roxl.w	8(a5)		;4
;;		move.w	(a5),d3		;2
;;		and.w	#$3fff,d3	;2
;;		roxl.w	#1,d3		;2
;;		move.w	d3,(a5)		;2
;;		lea	230(a5),a5	;2
**************************************************

		roxl.w	32(a5)
		roxl.w	24(a5)
		roxl.w	16(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		roxl.w	8(a5)

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

		lea	logo_back_cols,a2

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)

		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	56(a5)
		roxl.w	48(a5)
		roxl.w	40(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)


		roxl.w	32(a5)
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

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	80(a5)
		roxl.w	72(a5)
		roxl.w	64(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

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

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	104(a5)
		roxl.w	96(a5)
		roxl.w	88(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

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

		roxl.w	224(a5)
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)

		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)

		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	128(a5)
		roxl.w	120(a5)
		roxl.w	112(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

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
		roxl.w	224(a5)		;5th line down
		roxl.w	216(a5)
		roxl.w	208(a5)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)

		multinop	3

		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	152(a5)
		roxl.w	144(a5)
		roxl.w	136(a5)

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)
		multinop	3
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
		roxl.w	224(a5)		;7th line (last one)
		roxl.w	216(a5)
		roxl.w	208(a5)
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	176(a5)
		roxl.w	168(a5)
		roxl.w	160(a5)
		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)
		multinop	3
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
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	224(a5)
		roxl.w	216(a5)
		roxl.w	208(a5)
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	200(a5)
		roxl.w	192(a5)
		roxl.w	184(a5)

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4

		nop

		move.b	d0,(a1)
		move.b	d1,(a1)
		move.w	(a5),d3
		and.w	#$3fff,d3
		roxl.w	#1,d3
		move.w	d3,(a5)
		lea	230(a5),a5

		multinop	3

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		nop
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2
		multinop	2
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4

		nop
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2
		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2

		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4

		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2
		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4

		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2
		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4

		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2

		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2
		roxl.w	224(a5)		;4 cycles
		roxl.w	216(a5)		;4
		roxl.w	208(a5)		;4
		roxl.w	200(a5)		;4

		multinop	3
		move.b	d0,(a1)
		move.b	d1,(a1)
		roxl.w	192(a5)		;4
		roxl.w	184(a5)		;4
		roxl.w	176(a5)		;4
		nop
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		roxl.w	168(a5)		;4
		roxl.w	160(a5)		;4
		roxl.w	152(a5)		;4
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		roxl.w	144(a5)		;4
		roxl.w	136(a5)		;4
		roxl.w	128(a5)		;4
		roxl.w	120(a5)		;4
		roxl.w	112(a5)		;4
		roxl.w	104(a5)		;4
		roxl.w	96(a5)		;4
		roxl.w	88(a5)		;4
		roxl.w	80(a5)		;4
		roxl.w	72(a5)		;4
		roxl.w	64(a5)		;4
		roxl.w	56(a5)		;4
		roxl.w	48(a5)		;4
		roxl.w	40(a5)		;4
		roxl.w	32(a5)		;4
		roxl.w	24(a5)		;4
		roxl.w	16(a5)		;4
		roxl.w	8(a5)		;4
		move.w	(a5),d3		;2
		and.w	#$3fff,d3	;2
		roxl.w	#1,d3		;2
		move.w	d3,(a5)		;2
		lea	230(a5),a5	;2

		subq.w	#1,scroll_number	;5

		multinop	2
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)


*******************************************************************
TOP_LINES	equ	40	;No of top lines for logo and scroller

;colours for top logo and scroller
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


		move.w	#162-1,d5
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

		jsr	tune+8		;tune ISR
;		move.w	#$123,$ffff8240.w


		moveq	#0,d0
		move.b	$fffffc02.w,d0

		IFEQ	FINAL
		cmp.b	#1,d0
		bne.s	not_esc
		clr.l	$200.w
		bra.s	stop
		ENDC

not_esc
		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$53,d0		;DEL=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a0
		move.l	(a0,d1.w),a0
		lea	$200.w,a1
		REPT	4
		move.l	(a0)+,(a1)+
		ENDR

		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50

stop		move.w	#$2700,sr
		move.l	base_save,$ffff8200.w
		bsr	return_old
		bsr	clear_screen

		move.l #$08080000,$ffff8800.w	;Clear sound registers
		move.l #$09090000,$ffff8800.w
		move.l #$0a0a0000,$ffff8800.w

		movem.l	org_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w


flush		btst	#0,$fffffc00.w
		beq.s	clear
		move.b	$fffffc02.w,d0
		bra.s	flush

clear
		IFEQ	FINAL
		tst.l	$200.w
		beq.s	assem
		ENDC
		move.w	#$2300,sr
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		bra	exec
		IFEQ	FINAL
assem		move.w	#$2300,sr
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.w	-(sp)
		trap	#1
		ENDC
zero	;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$400,make_pal+2
		eor.w	#$400,big_pic+2
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

*********** SCROLLER **********************
WIDTH		EQU	16
BUFFER_SIZE	EQU	16*(WIDTH*2)*2

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

		bsr	print_titles

		move.l	screen_base,a1
		add.w	#152,a1
		lea	big_pic+34,a0

		move.w	#262-1,d7
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


;**** the following lines get rid of any crap in the region off screen
;**** but still in the scroll region (SYNTHY saves crap there)
		move.l	screen_base,a5
		lea	230*45+130(a5),a2
		moveq	#0,d0
		rept	16		;16 lines of scroller
		move.w	d0,(a2)
		move.w	d0,8(a2)
		move.w	d0,16(a2)
		lea	230(a2),a2
		endr

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
* Revision:	1.3							*
* Date:		24/4/93							*
* By:		MSD 							*
*									*
* v 1.0 8*8 font							*
* v 1.1 8*8 font masking						*
* v 1.2 6*6 font fully masking with selective plane enable		*
* v 1.3 6*6 font fully masking with selective plane & 52 column wide	*
*									*
*************************************************************************
*
* Fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0

;YES=1
;yes=YES
;NO=0
;no=NO

ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	big_pic+34+8,a0		;alter this to move the titles down the screen
		add.w	#230*80,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

NO_LINES	equ	25

		move.w	#NO_LINES-1,d0	;max titles per menu
.loop		move.w	#(52/2)-1,d6	;52 across each line
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
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 52 CHARS)
;
; NOTE: 5 characters on left and right may not be seen on TVs but are
;	seen on monitors (well they are on my CM8833!)
;          ------1234567890123456789012345678901234567890123456789012------
	dc.b	"                                                    "
	dc.b	"     POV COMPILATION 133                            "
	dc.b	"                                                    "
	dc.b	"     1: CUDDLY DEMOS                   POV ARE      "
	dc.b	"     2: FUZION 189 MENU                             "
	dc.b	"     3: F.A.L.L. INTRO               MAC SYS DATA   "
	dc.b	"     4: UNT 13 MENU                     BORIS       "
	dc.b	"     5: ADMIRABLES INTRO              OZYMANDIAS    "
	dc.b	"     6: COPIER                                      "
	dc.b	"                                                    "
	dc.b	"     0: 50/60 HZ                        P.O.V       "
	dc.b	"                                     P.O. BOX 40    "
	dc.b	"                                      CLEVELEYS     "
	dc.b	"                                       FY5 3PH      "
	dc.b	"                                      LANCASHIRE    "
	dc.b	"                                       ENGLAND      "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"        ART BASED ON ORIGINAL BY BORIS VALLEJO      "
	dc.b	"                                                    "

	even

screen_titles_font	incbin	6x6_font.dat
	even


line_ptr	dc.l	scroll_line

scroll_line
 DC.B "ARRRGGHHH PERSISTENCE OF VISION HAS RETURNED WITH ANOTHER "
 DC.B "COMPILATION.      "
 DC.B "MAC SYS DATA IS PROUD TO PRESENT POV DEMO COMPILATION 133  "
 DC.B "RELEASE DATE 3RD MAY 1993.      "
 dc.b "HERE'S THE CREDITS:      MENU CODED BY MAC SYS DATA,      "
 DC.B "GRAFIX BY ALY (EX-POV MEMBER) AND MAC SYS DATA,   "
 DC.B "MUSIC BY BEN DAGLISH FROM DEFLECTOR (I LOVE IT!).    "
 dc.b "NOTE:  I HAVE RE-RELEASED POV 132 AS THERE IS A BUG IN THE "
 DC.B "FULL SCREEN CODE BUT IT ONLY SHOWS UP ON SOME TOS VERSIONS. THE "
 DC.B "SECOND RELEASE IS LIKE THIS MENU AND DOES WORK 100 PERCENT ON ALL "
 DC.B "TOS VERSIONS I KNOW (I CAN'T TEST IT ON TOS 1.62 ONWARDS).       "
 dc.b "   THERE IS NOT A LOT OF SCROLL TEXT ON THIS MENU AS SPACE IS "
 DC.B "TIGHT BUT HERE ARE SOME GREETINGS.... "
 DC.B "ADRENALIN,   ANIMAL MINE,   "
 DC.B "GEORGE (BART),   MUG UK   AND   RIPPED OFF (THANKS FOR LETTING US "
 dc.b "PUT THEIR FILED VERSION OF CUDDLY DEMOS ON A POV DISC).           "
 dc.b "WELL IT'S 12:01 AND IT'S RAINING (AGAIN), I WAS GOING TO DRIVE "
 DC.B "ROUND THE AREA LOOKING FOR A HOUSE AS THE LAST ONE I LOOKED AT "
 DC.B "WAS RUBBISH, I THINK I'LL STAY IN AND WATCH THE GRAND PRIX THEN "
 DC.B "GO FOR A DRIVE WITH MY GIRLFRIEND (JENNY) WHO STAYED OVER LAST NIGHT. "
 DC.B "      I NOW HAVE A NEW CALVIN AND HOBBS BOOK SO I'LL TRY TO GET "
 DC.B "OZ TO DRAW SOME PICTURES.       WELL AS I SAID, I'M NOT GOING TO "
 DC.B "WAFFLE ON AS THERE IS NOT A LOT OF DISC SPACE AND I CAN'T BE "
 DC.B "BOTHERED.               "
 DC.B "TO CONTACT P.O.V. WRITE TO;-         MAC SYS DATA,        "
 DC.B "P.O. BOX 40,        CLEVELEYS,        LANCASHIRE,        "
 DC.B "FY5 3PH,        ENGLAND.                                          "
 DC.B "                                          "
 dc.b	$ff
	even

font	incbin	oz_font.dat
	even


big_pic	incbin	dragon.kid

tune	incbin	deflec.mus


logo_back_cols	dcb.w	25,0
		dc.w	$200,$300,$400,$500,$600,$700,$710,$720
		dc.w	$730,$740,$750,$760,$670,$560,$450,$340



demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"cuddly.ro",0
	even
exec2	dc.b	"fuzion.189",0
	even
exec3	dc.b	"F_A_L_L.prg",0
	even
exec4	dc.b	"UNT.13",0
	even
exec5	dc.b	"NIRVANA.U",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even



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
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
scroll_number	ds.w	1

base_save	ds.l	1 

org_pal		ds.b	32

sbuffer		ds.b	BUFFER_SIZE


	ds.b	256
screens	ds.b	230*274
bssend