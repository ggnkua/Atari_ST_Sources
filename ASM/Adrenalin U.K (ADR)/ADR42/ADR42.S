*************************************************************************
*				ADRENALIN MENU 42			*
*			 	-----------------			*
*									*
* Coded by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Art by:	BIOFEEDBACK						*
*									*
*									*
* Music by:	Lap							*
*									*
*									*
*************************************************************************

	opt	o+,w-
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

;		move.l	$ffff8200.w,base_save
		move.b	#2,$ffff820a.w		;50Hz

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,screen_base
		move.l	d0,d7

		lsr.l	#8,d0		;set screen base
		move.b	d0,screen_low
		lsr.l	#8,d0
		move.b	d0,screen_hi

		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		clr.b	$ffff8260.w
		lsr.l	#8,d7
		lea	$ffff8201.w,a6
		movep.w	d7,(a6)

		bsr	save_old

		bsr	fade_1st_pic

		bsr	sort_pic

		move.l	#reset_vector,$42a.w
		move.l	#$31415926,$426.w

		moveq	#1,d0
		jsr	music		;init music

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

.yes		move.b	screen_hi,$ffff8201.w
		move.b	screen_low,$ffff8203.w

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
		REPT	16/2		;DEPTH of scroll font
		move.l	(a5)+,(a4)+
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

		move.l	screen_base,a5		;5
		add.l	#(230*3)+152-32+6,a5
		lea	224(a5),a2		;2
		lea	sbuffer,a4		;3

offset		set	0
		move.w	230+offset(a5),offset(a5)	;4 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	75-74

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	12-10
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	89-85
		move.b	d0,(a1)		;HERTZ fiddles
		move.b	d1,(a1)		; "	"
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		rept	89-85
		nop
		endr
		move.b	d0,(a1)
		move.b	d1,(a1)
		rept	13
		nop
		endr
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

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		nop
		nop

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		nop
		nop
		nop
		nop

		move.b	d0,(a1)
		move.b	d1,(a1)

		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	2

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	4

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		nop
		nop
		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		nop
		nop

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		nop
		nop
		nop

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		nop
		nop

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		nop
		nop

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

		multinop	89

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		lea	32200(a5),a5
offset		set	0

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	12-10

		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	12-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	12-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	12-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
		multinop	89-85

		move.b	d0,(a1)
		move.b	d1,(a1)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	13-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	12-10

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth
offset		set	offset+230
		move.w	230+offset(a5),offset(a5)	;5 nops worth

		multinop	89-80

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

		move.w	(a4),230+offset(a5)
		move.w	2(a4),(a4)		;4 nops
		move.w	4(a4),2(a4)		;5 nops
		move.w	6(a4),4(a4)		;5 nops
		move.w	8(a4),6(a4)		;5 nops
		move.w	10(a4),8(a4)		;5 nops
		move.w	12(a4),10(a4)		;5 nops
		move.w	14(a4),12(a4)		;5 nops
		move.w	16(a4),14(a4)		;5 nops
		move.w	18(a4),16(a4)		;5 nops
		move.w	20(a4),18(a4)		;5 nops
		move.w	22(a4),20(a4)		;5 nops
		move.w	24(a4),22(a4)		;5 nops
		move.w	26(a4),24(a4)		;5 nops
		move.w	28(a4),26(a4)		;5 nops
		move.w	30(a4),28(a4)		;5 nops
		move.w	32(a4),30(a4)		;5 nops
		subq.w	#1,scroll_number	;decrease counter
		multinop	89-83-5

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

		multinop	13	;-4
;		move.w	#-1,offset(a5)

		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

		multinop	3-2
		move.w	#162-1-2,d5

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

		moveq	#36-1,d5		;lower border code

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
		multinop	12	;-3
;		move.w	#$700,$ffff8240.w

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

		jsr	music+$22	;music ISR
;		move.w	#$123,$ffff8240.w

		moveq	#0,d0
		move.b	$fffffc02.w,d0

		IFEQ	FINAL
		cmp.b	#1,d0
		bne.s	not_esc
		clr.l	$200.w
		bra.s	stop
		ENDC

not_esc		cmp.w	#11,d0		;0 keyboard
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
		move.l	old42a,$42a.w
		move.l	old426,$426.w
		moveq	#0,d0
		jsr	music
;		move.l	base_save,$ffff8200.w
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
		eor.w	#$400,big_pic+2
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

*********** SCROLLER **********************
WIDTH		EQU	18
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
		move.l	$426.w,old426
		move.l	$42a.w,old42a
		rts

set_isr		move.w	#$2700,sr
		clr.b	$fffffa09.w
		or.b	#1,$fffffa07.w
		bclr	#3,$fffffa17.w
		move.l	#new_vbl,$70.w
		move.l	#null_rte,$68.w
		move.w	#$2300,sr
		rts

return_old	move.b	old_a07,$fffffa07.w
		move.b	old_a09,$fffffa09.w
		move.b	old_a13,$fffffa13.w
		move.b	old_a15,$fffffa15.w
		move.b	old_a19,$fffffa19.w
		move.b	old_a1f,$fffffa1f.w
		move.l	old_134,$134.l
		move.l	old_70,$70.w
		move.l	old_68,$68.w
		move.l	old_scrn,d7
		move.l	d7,$44e.w
		move.w	#$2300,sr
		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.b	old_rez,$ffff8260.w
		lsr.l	#8,d7
		lea	$ffff8201.w,a6
		movep.w	d7,(a6)
		move.b	#8,$fffffc02.w
		rts


fade_1st_pic	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.l	screen_base,a0
		lea	illegal+34,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a1)+,(a0)+
		dbf	d0,.loop
		lea	illegal+2,a1
		bsr	fadein
		move.w	#20000-1,d7
.wait		move.w	#11,-(sp)
		trap	#1
		addq.w	#2,sp
		tst.l	d0
		bmi.s	.yes
		dbf	d7,.wait
		bra.s	.down
.yes		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
.down		lea	black,a1
		bsr	fadein
		rts
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein		move.w	#7,d6
		move.l	a1,a2
next_value	lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		add.w	#2,a0
		add.w	#2,a1
		dbf	d7,.loop
		move.w	#4,d0
		bsr	vbl
		move.l	a2,a1
		dbf	d6,next_value
		rts
vbl		movem.l	d0-d3/d7/a0-a3,-(sp)
		move.l	d0,d7
.loop		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		dbf	d7,.loop
		movem.l	(sp)+,d0-d3/d7/a0-a3
		rts
modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#$7,d2
		and.w	#$7,d3
		cmp.w	d2,d3
		beq.s	MOK1
		bmi.s	MDN1
		addq.w	#1,d4
		bra.s	MOK1
MDN1		SUBQ #1,D4
MOK1		MOVE D0,D2
		MOVE D1,D3
		AND #$70,D2
		AND #$70,D3
		CMP D2,D3
		BEQ.S MOK2
		BMI.S MDN2
		ADD #$10,D4
		BRA.S MOK2
MDN2		SUB #$10,D4
MOK2		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3
		BEQ.S MOK3
		BMI.S MDN3
		ADD #$100,D4
		BRA.S MOK3
MDN3		SUB #$100,D4
MOK3		MOVE D4,(A0)
		RTS




sort_pic	bsr	print_titles

		move.l	screen_base,a1
		add.w	#152+230*3,a1
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

; bug fixed to prevent stack overflow (lines going up screen)
; and to stop odd word screen alignment.
reset_vector	move.w	#$2700,sr
		move.l	#$deadface,$42a.w
old42a		equ	*-6
		move.l	#$beefface,$426.w
old426		equ	*-6
		or.b	#2,$ffff820a.w		;50Hz
		move.l	#reset_vector,sp
		move.l	#screens,d7
		clr.b	d7
		move.l	d7,reset_screen
		move.l	d7,a1
		lea	adrnot+34,a0
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		movem.l	adrnot+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		clr.b	$ffff8260.w
		move.l	reset_screen,d7
		lsr.l	#8,d7
		lea	$ffff8201.w,a6
		movep.w	d7,(a6)
		move.w	$ffff8240.w,d0
		rept	122
		nop
		endr
		move.w	#-1,$ffff8240.w
		rept	122
		nop
		endr
		move.w	d0,$ffff8240.w
		clr.b	$ff8260.l
		move.l	#screens,d7
		clr.b	d7
		lsr.l	#8,d7
		lea	$ffff8201.w,a6
		movep.w	d7,(a6)
.here		bra	.here
reset_screen	dc.l	0
adrnot		incbin	penot.pi1	;correct reset pic


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
	dc.b	"     ADR COMPILATION 42                             "
	dc.b	"                                                    "
	dc.b	"     1: GAME 1                        ADR ARE       "
	dc.b	"     2: GAME 2                                      "
	dc.b	"     3: GAME 3                    SPACEMAN SPIFF    "
	dc.b	"     4: GAME 4                        MOOKIE        "
	dc.b	"     5: GAMR 5                      BIOFEEDBACK     "
	dc.b	"     6: COPIER                                      "
	dc.b	"                                                    "
	dc.b	"     0: 50/60 HZ                        A.D.R       "
	dc.b	"                                       ADDRESS      "
	dc.b	"                                        STREET      "
	dc.b	"                                        TOWN        "
	dc.b	"                                        COUNTY      "
	dc.b	"                                       ENGLAND      "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "
	dc.b	"                                                    "

	even

screen_titles_font	incbin	6x6_font.dat
	even


line_ptr	dc.l	scroll_line

scroll_line
 DC.B "ADRENALIN UK PRESENTS COMPILATION 42  "
 DC.B "RELEASE DATE 12TH OCTOBER 1993.      "
 dc.b "HERE'S THE CREDITS:      MENU CODED BY SPACEMAN SPIFF.      "
 DC.B "                                          "
 dc.b	$ff
	even

font	incbin	oz_font.dat
	even


big_pic	incbin	blublobs.kid

music	incbin	dungeon.mus


logo_back_cols	dcb.w	25,0
		dc.w	$200,$300,$400,$500,$600,$700,$710,$720
		dc.w	$730,$740,$750,$760,$670,$560,$450,$340

illegal		incbin	illegal.pi1
;adrnot		incbin	adrnot.pi1	;adrnot.pi1 is a test reset pic by MSD


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
old_rez		ds.b	1
	even
old_134		ds.l	1
old_70		ds.l	1
old_68		ds.l	1
old_scrn	ds.l	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
scroll_number	ds.w	1
base_save	ds.l	1 

org_pal		ds.b	32

black		ds.b	32

sbuffer		ds.b	BUFFER_SIZE


	ds.b	256
screens	ds.b	230*274
bssend