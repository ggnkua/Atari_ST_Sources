start
*********************
   SECTION TEXT
*********************

;	opt	o+,w-
;******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
;YES	equ	1
;yes	equ	YES
;NO	equ	0
;no	equ	NO
;DOWNLOAD	equ	 no
;
;	ifne	DOWNLOAD
;	include	transmit.s
;	org	$20000
;
;Code_Start
;Exec_Addr
;	ENDC

;	opt	p+

	bsr	set_up
pmain_loop	bsr	pvsync
;		move.w	#$123,$ffff8240.w
	bsr.s	scroll
;		move.w	ppic+2(pc),$ffff8240.w

		cmp.b	#$39,$fffffc02.w
		bne.s	pmain_loop

	move.w	4.w,-(sp)
	rts
	bsr	pset_old_palette



	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)

		move.w	#1,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

	move.b	#$8,$fffffc02.w
	bsr	pset_user

	clr.w	-(sp)
	trap	#1


*******************
* CUSTOM ROUTINES *
*******************

SDEPTH		EQU	16
SWIDTH		EQU	16
BUFFER_SIZE	EQU	SDEPTH*(SWIDTH*2)

scroll	lea	line_ptr(pc),a4
	move.l	(a4),a5
	tst.b	(a5)
	bpl	loop3
	lea	scroll_text(pc),a5	;restart message
	move.l	a5,(a4)
loop3	lea	scroll_number(pc),a3
	tst.w	(a3)
	bne	loop2
	move.w	#SWIDTH,(a3)
	moveq	#0,d0
	move.b	(a5)+,d0
	move.l	a5,(a4)
	sub.w	#32,d0
	mulu	#(SDEPTH*2),d0
	lea	pfont(pc),a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer
	lea	sbuffer(pc),a1
	REPT	SDEPTH/2
	move.l	(a5)+,(a1)+
	ENDR

loop2	move.l	pscr_now(pc),a5
	add.l	#160*184,a5
	move.l	a5,a2
	add.w	#152,a2

	move.w	#4,d3
	lea	sbuffer(pc),a1
	move.w	#(SDEPTH)-1,d0

loopy
offset	set	0
	move.w	offset(a5),d2
	sub.w	d6,d6			;clear X flag
	roxl.l	d3,d2
	move.w	d2,offset(a5)
offset	set	offset+8
  	rept	19
	moveq	#0,d2
	move.w	offset(a5),d2
	move.w	d2,d4
	sub.w	d6,d6			;clear X flag
	roxl.l	d3,d2			;low word (right)
	move.w	d2,offset(a5)

; Optimised code, why shift right by 12 when we can shift left by 4 and SWAP
;;;	lsr.w	#8,d4		;24 cycles
;;;	lsr.w	#4,d4		;16 cycles
;;;			total	 40

	and.w	#$f000,d4	;12 cycles
	asl.l	#4,d4		;16 cycles
	swap	d4		; 4 cycles
;			total	 32

	or.w	d4,offset-8(a5)
offset	set	offset+8
	endr

;scroll buffer into right of screen
bp	move.w	(a1),d4		;shift buffer
	move.w	d4,d5
	and.w	#%0000111111111111,d4
	roxl.l	#4,d4
	move.w	d4,(a1)+

;;;	lsr.w	#8,d5
;;;	lsr.w	#4,d5
	and.w	#$f000,d5	;12 cycles
	asl.l	#4,d5		;16 cycles
	swap	d5		; 4 cycles

	or.w	d5,152(a5)		;poke right pixel to screen
	lea	160(a5),a5
	dbf	d0,loopy
	lea	scroll_number(pc),a3
	sub.w	d3,(a3)
	rts






***********************
* SUBROUTINES SECTION *
***********************
pvsync	lea	pvsync_flag(pc),a0
	move.w	#-1,(a0)
.sync	tst.w	(a0)
	bne.s	.sync
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


pset_user
	move.l	stack_save(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


pset_old_palette
	lea	pold_palette(pc),a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


pre_timerb	clr.b	$fffffa1b.w
		move.l	a0,-(sp)
		lea	timerb(pc),a0
		move.l	a0,$120.w
		move.l	(sp)+,a0
		move.b	#1,$fffffa21.w
;		move.b	#8,$fffffa1b.w
		rte

timerb		move.l	a0,-(sp)
		move.l	d0,-(sp)
		move.w	col_offset(pc),d0
		lea	colours(pc),a0
		add.w	d0,a0
		move.w	(a0),$ffff8242.w
		lea	col_offset(pc),a0
		add.w	#2,(a0)
		move.l	(sp)+,d0
		move.l	(sp)+,a0
		rte

pnewvbl
		movem.l	d0-a6,-(sp)
		lea	col_offset(pc),a0
		clr.w	(a0)
		lea	pvsync_flag(pc),a0
		clr.w	(a0)
		clr.b	$fffffa1b.w
		lea	pre_timerb(pc),a0
		move.l	a0,$120.w
		move.b	#199-16,$fffffa21.w
		lea	tune+8(pc),a0
		jsr	(a0)
		movem.l	(sp)+,d0-a6
		move.b	#8,$fffffa1b.w
		rte

set_up
;		ifeq	DOWNLOAD
;		clr.l	-(sp)		;supervisor
;		move.w	#$20,-(sp)
;		trap	#1
;		addq.l	#6,sp
;		lea	stack_save(pc),a3
;		move.l	d0,(a3)
;		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		lea	pscreen_base(pc),a3
		move.l	d0,(a3)

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		lea	poriginal_rez(pc),a3
		move.w	d0,(a3)

		movem.l	$ffff8240.w,d0-d7
		lea	pold_palette(pc),a3
		movem.l	d0-d7,(a3)

		movem.l	ppic+2(pc),d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		lea	scroll_text(pc),a3
		lea	line_ptr(pc),a2
		move.l	a3,(a2)

		lea	fiddle(pc),a3
		add.w	#32000,a3
		move.l	a3,d0
		clr.b	d0
		lea	pscr_now(pc),a2
		move.l	d0,(a2)
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		lea	scr_xor(pc),a4
		move.l	d1,(a4)

		lea	ppic+34(pc),a0
		move.l	pscr_now(pc),a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		move.w	#$2700,sr
		lea	storage(pc),a0
		move.l	$70.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

	move.l	#1,d0
	lea	tune(pc),a0
	jsr	(a0)

		lea	pre_timerb(pc),a0
		move.l	a0,$120.w
		lea	pnewvbl(pc),a0
		move.l	a0,$70.w
		bclr	#3,$fffffa17.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		move.w	#$2300,sr


		move.w	#$2300,sr

pset_screen	move.l	pscr_now(pc),d6
		move.l	scr_xor(pc),d7
		eor.l	d7,d6
		lea	pscr_now(pc),a3
		move.l	d6,(a3)
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

;	ifeq	DOWNLOAD
*******************
;   SECTION DATA
*******************
;	endc

sbuffer		ds.b	BUFFER_SIZE
scroll_number	ds.w	1
pscr_now	ds.l	1
scr_xor		ds.l	1
stack_save	ds.l	1
pold_palette	ds.w	16
pscreen_base	ds.l	1
poriginal_rez	ds.w	1
col_offset	dc.w	0
pvsync_flag	dc.w	0


line_ptr	dc.l	0

scroll_text
 dc.b "           WELCOME O USER OF PACIFIST TO PERSISTENCE OF VISION COMPILATION 159. "
 dc.b "RELEASE DATE: 23 AUG 1997.          "
 dc.b "CODING BY MAC SYS DATA,     FONT BY OZ,     GRAPHICS BY MAC SYS DATA."
 dc.b "     DISC MAKING AND SCROLLTEXT BY MAC SYS DATA.     "
 dc.b "ST/STE MOD REPLAY AT 25MHZ ON STE, 12MHZ ON STFM.     "
 dc.b "AS YOU MAY HAVE GUESTED, THIS MENU DOES NOT WORK UNDER PACIFIST DUE TO THE MOD "
 DC.B "CODE.  YOU CAN TRY RUNNING THE MENUS FROM THE DESKTOP BUT MOST USE HARDWARE TRICKS "
 DC.B "AND SOME USE THE HARDWARE ONLY AVAILABLE ON THE STE SO THEY WILL NOT WORK.      "
 DC.B "       YOU MAY BE INTERESTED TO KNOW THAT YOU CAN NOW GET THE RECENT "
 DC.B "POV MENUS ON THE INTERNET AT  WWW.FATAL-DESIGN.COM  THANKS TO JON AND "
 DC.B "CREW FOR THE HARD WORK. "
 DC.B "     QUICK GREETS TO  JON AT FATAL DESIGN,  PANDEMONIUM,   TSCC   AND "
 DC.B "ALL THE PC DEMO CREWS.      I HAVE NOT GREETED MANY ATARI CREWS 'COS "
 DC.B "THEY HAVE ALL GIVEN UP.  NO-ONE WRITES TO ME ANY MORE AND I HAVEN'T SEEN "
 DC.B "A NEW DEMO FOR ABOUT A YEAR. "
 DC.B "       IT IS NOW AUGUST 1997 AND TODAY I SPENT A   L O T   OF MONEY.    I"
 DC.B " WENT TO PRESTON IN LANCASHIRE, ENGLAND AND BOUGHT A BRAND NEW CAR.    I AM"
 DC.B " NOW THE OWNER OF A SEAT IBIZA CUPRA 2 LITRE 16 VALVE SPEED MACHINE - 150 BHP,"
 DC.B " 130 MPH, 0-60 IN 7.6 SECONDS......   FAST   - IT OUT PERFORMS THE NEW BMW Z3 1.9 LITRE"
 DC.B " SPORTS CAR, IN FACT IT OUT PERFORMS A LOT OF CARS."
 DC.B "                                 "
 dc.b "YOU CAN E-MAIL ME (MSD) AT THE FOLLOWING ADDRESS      POV@BNFL.COM"
 DC.B "    OR    MRSD1@BNFL.COM    OR    POV@BNFL.CO.UK    THERE ARE OTHER ADDRESSES"
 DC.B " BUT I WON'T BORE YOU....."
 DC.B "                    BYE, BYE...................."
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 dc.b $ff
	even
colours	dc.w	$300,$400,$500,$600,$700,$720,$730,$740,$750
	dc.w	$760,$770,$671,$572,$473,$474,$375

storage	ds.b	14
tune	incbin	gore2.thk
pfont	incbin	oz_font.dat
ppic	incbin	pacifist.pi1


	even

;	ifeq	DOWNLOAD
*******************
;   SECTION BSS
*******************
;	endc


		ds.b	256
pscreens	ds.b	32000
		ds.b	32000

fiddle	equ	pscreens-32000

;	IFNE	DOWNLOAD
;Code_End
;Code_Length	equ	Code_End-Code_Start
;	ENDC
stop
