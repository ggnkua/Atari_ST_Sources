*********************
   SECTION TEXT
*********************


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	YES

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC



	bsr	set_up



main_loop	bsr	v_sync
		;bsr	set_screen	;screen flip
		move.w	#$123,$ffff8240.w
	bsr	scroll
		move.w	pic+2,$ffff8240.w
		bsr	tst_key
		tst.l	d0
		beq.s	main_loop

		bsr	set_old_palette

		move.w	#1,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

	move.b	#$8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1



*******************
* CUSTOM ROUTINES *
*******************


*********** SCROLLER **********************
*
* NOTE: I used some old code dating back to POV 1 which uses ROXL
*	the next version will probably have a new 4 bit scroller.
*
*******************************************
SDEPTH		EQU	16
SWIDTH		EQU	16
BUFFER_SIZE	EQU	SDEPTH*(SWIDTH*2)

scroll	move.l	line_ptr,a5
	tst.b	(a5)
	bpl	loop3
	lea	scroll_text,a5	;restart message
	move.l	a5,line_ptr
loop3	tst.w	scroll_number
	bne	loop2
	move.w	#SWIDTH,scroll_number
	moveq	#0,d0
	move.b	(a5)+,d0
	move.l	a5,line_ptr
	sub.w	#32,d0
	mulu	#(SDEPTH*2),d0
	lea	font,a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer
	lea	sbuffer,a1
	REPT	SDEPTH/2
	move.l	(a5)+,(a1)+
	ENDR

loop2	move.l	scr_now,a5
	add.l	#160*84+2,a5
	move.l	a5,a2
	add.w	#152,a2

	move.w	#4,d3
	lea	sbuffer,a1
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
	sub.w	d3,scroll_number
	rts



***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




set_up
		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc
pic	incbin	"g:grn_man.pi1"

line_ptr	dc.l	scroll_text

scroll_text
 dc.b "A A A A A A A A WELCOME TO PERSISTENCE OF VISION OFFICIAL "
 dc.b "SOURCE CODE DISC 1. `````   "
 dc.b "RELEASE DATE: 28TH DEC 1993.          "
 DC.B "THE DISC CONTAINS SOURCE CODE, ART, MUSIC AND ALL THE RELEVENT "
 DC.B "FILES NEEDED TO RUN THE MENUS, THE DISC DOES NOT CONTAIN ANY "
 DC.B "DEMOS.   DUE TO THE AGE OF SOME MENUS, THERE ARE CERTAIN CASES WHERE "
 DC.B "EXTRA FILES MAY BE NEEDED FOR THE MENUS TO WORK. THE MISSING FILES CAN "
 DC.B "BE FOUND ON THE RELEVANT POV MENUS.  IF YOU HAVE NO ACCESS TO THESE "
 DC.B "FILES THEN A SMALL MODIFICATION TO THE CODE IS POSSIBLE. NEARLY ALL EARLY "
 DC.B "MENUS DO NOT RETURN ALL AVAILABLE MEMORY TO GEM SO LARGE PROGRAMS CANNOT "
 DC.B "BE RUN, OTHERS USE A LOADING METHOD "
 DC.B "DEVELOPED BY POV CALLED AUTORUN. SEVERAL VERSIONS OF THIS PROGRAM ARE "
 DC.B "AVAILABLE DUE TO THE PROGRAMS DEVELOPEMENT. THE PROGRAM WORKS IN "
 DC.B "CONJUNCTION WITH THE MENU, ONCE THE MENU STORED THE FILENAME TO "
 DC.B "RUN IT WOULD EXIT. AUTORUN WOULD THEN BE THE NEXT THING IN THE AUTO FOLDER."
 DC.B "  EARLY VERSIONS OF AUTORUN SIMPLY PICKED "
 DC.B "UP THE PROGRAM NAME TO RUN AT THE SCREEN ADDRESS, THE LATER VERSION (VERSION 4) "
 DC.B "LOOKED FOR THE FILENAME AT $200.  ALL VERSIONS OF AUTORUN SIMPLY GET THE FILENAME "
 DC.B "AND P-EXEC IT.   LATER MENUS ALL INCLUDE AUTORUN CODE INTO THEM AND CORRECTLY "
 DC.B "SHRINK MEMORY TO ALLOW GEM TO UTILIZE RAM EFFICIENTLY.                  "
 dc.b "THE CODE YOU CAN SEE MOVING UP BEHIND THIS SCREEN IS THE ACTUAL "
 DC.B "CODE OF POV 129 WHICH WILL BE RELEASED ON A FUTURE SOURCE CODE DISC.               "
 DC.B "IF YOU WISH TO USE THE CODE, PLEASE CREDIT POV.    YOU CAN CONTACT "
 DC.B "P.O.V. AT [[[[[[[[[        MAC SYS DATA,        "
 DC.B "P.O. BOX 40,              THORNTON-CLEVELEYS,              LANCASHIRE,              "
 DC.B "FY5 3PH,              ENGLAND.             PRESS SPACE TO QUIT TO DESKTOP.         "
 DC.B "                                             WRAP      "
 dc.b "                        ````````````````````````````````````    "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 dc.b $ff
	even

font	incbin	k:\menucode.pov\oz_font.dat
	even

	ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
	endc
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
scroll_number	ds.w	1

sbuffer		ds.b	BUFFER_SIZE

		ds.b	256
screens		ds.b	32000
		ds.b	32000

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
