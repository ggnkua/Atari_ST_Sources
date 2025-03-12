*************************************************************************
*			Persistence Of Vision 119             		*
*			-------------------------			*
*									*
* Written by: Machine System Data					*
*									*
*									*
* Music from:								*
*									*
*									*
* Date: July 1992							*
*************************************************************************

YES=1
yes=1
NO=0
no=0


AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

ASM_TO_DISC=no	;this will save a couple of bytes if used but is only
		;included so you can test it from the assembler in med rez
		;or if you use your assembler in mono and assemble to disc

	opt	o+

	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200.w
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC


		lea	bss_start,a0
clear_bss	clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	clear_bss


		bsr	setup


main_loop
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w

	move.w	key,d0

	ifeq	ASM_TO_DISC
	cmp.w	#01,d0		;escape ********************
	beq.s	exit
	endc

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq.s	reset

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

exit	bsr	isr_off
	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	bsr	restore_pal
	move.b	old484,$484.w
	move.l	org_base,a0
	ifeq	ASM_TO_DISC
	bsr	set_org_rez
	ELSE
	bsr	set_low_rez
	ENDC
	move.b	#8,$fffffc02.w
	cmp.w	#"$$",$200.w
	beq.s	fiddle
	bsr	user_mode

	ifne	ASM_TO_DISC
	ifeq	AUTORUN4
	bra	exec
	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC
	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC
fiddle	bsr	user_mode
	clr.w	-(sp)
	trap	#1

reset	move.l	4.w,-(sp)
	rts

zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$002,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop

***************
* Subroutines *
***************
FONT_DEPTH	equ	40
TIMES_TO_SHIFT	equ	4

scroll		tst.w	delay
		beq.s	.no
		subq.w	#1,delay
		rts
.no		move.l	line_ptr,a6
		cmp.b	#$7f,(a6)
		bne.s	.no_delay
		addq.l	#1,line_ptr
		move.w	#120,delay
		rts
.no_delay	tst.b	(a6)
		bpl.s	.no_wrap
		lea	scroll_line,a6		;restart message
.no_wrap	tst.w	scroll_number
		bpl.s	loop2
		moveq	#0,d0
		move.b	(a6)+,d0
		move.l	a6,line_ptr
		sub.w	#32,d0			;get rid of ASCII

		lea	width_table,a5		;sort out proportional font
		add.w	d0,a5
		moveq	#0,d4
		move.b	(a5),d4
		beq.s	.no_delay		;prevent length of 0
		move.w	d4,scroll_number

		mulu	#FONT_DEPTH*4,d0		;get grafic character
		lea	font,a6
		add.l	d0,a6	;letter address is in a6

		lea	buffer,a1	;move letter into buffer
		move.w	#FONT_DEPTH-1,d0
.loop		move.l	(a6)+,(a1)+
		dbf	d0,.loop

loop2		move.l	my_base,a6
		lea	32160(a6),a6
		move.l	a6,a2
		add.w	#152,a2
		lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling

		moveq.w	#TIMES_TO_SHIFT,d7		;number of pixels to scroll every VBL
		move.w	#FONT_DEPTH-1,d1

loop		moveq	#0,d6
		move.l	d6,d5
		move.l	d5,d4
		move.w	2(a1),d5
		move.w	(a1),d4
		lsl.l	d7,d5
		lsl.l	d7,d4
		move.w	d5,2(a1)
		swap	d5
		move.w	d4,(a1)
		or.w	d5,(a1)
		swap	d4
		or.w	d4,(a2)		;put char onto right of screen
		addq.w	#4,a1		;increase buffer position
		lea	160(a2),a2	;increase screen
		dbf	d1,loop

		move.w	#FONT_DEPTH-1,d0
loopy
		moveq	#0,d1
		move.w	(a6),d1
		lsl.l	d7,d1
		move.w	d1,(a6)
		swap	d1

OFF	set	8
		REPT	19
		moveq	#0,d1
		move.w	OFF(a6),d1
		lsl.l	d7,d1
		move.w	d1,OFF(a6)
		swap	d1
		or.w	d1,OFF-8(a6)
OFF	set	OFF+8
		ENDR
		lea	160(a6),a6
		dbf	d0,loopy
		move.w	scroll_number,d1
		sub.w	d7,d1
		move.w	d1,scroll_number
		rts


zoom		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		lea	$ffff8800.w,a2
		move.b	#8,(a2)
		move.b	(a2),d4
		move.b	#9,(a2)
		move.b	(a2),d5
		move.b	#$a,(a2)
		move.b	(a2),d6
		lsr.w	#1,d4		;make it 8 different logos not 16
		lsr.w	#1,d5
		lsr.w	#1,d6
		mulu	#31*4,d4
		mulu	#31*4,d5
		mulu	#31*4,d6
		lea	zoom_data,a0
		move.l	a0,a1
		move.l	a1,a2
		add.w	d4,a0
		add.w	d5,a1
		add.w	d6,a2
		move.l	my_base,a4
		lea	160*168+8*10(a4),a4
		lea	32(a4),a5
		lea	32(a5),a6
OFF	set	0
		REPT	31
		move.w	(a0)+,OFF(a4)
		move.w	(a0)+,OFF+8(a4)
		move.w	(a1)+,OFF+4(a5)
		move.w	(a1)+,OFF+8+4(a5)
		move.w	(a2)+,OFF+6(a6)
		move.w	(a2)+,OFF+8+6(a6)
OFF	set OFF+160
		ENDR
		rts


user_mode	move.l	org_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts


restore_pal	lea	old_pal,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

		ifeq	ASM_TO_DISC
set_org_rez	move.w	org_rez,-(sp)
		bra.s	set_rez
		ENDC

set_low_rez	clr.w	-(sp)
set_rez
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


isr_off		move.w	#$2700,sr
		lea	save_area,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa21.w
		bclr	#1,$fffffa13.w
		move.w	#$2300,sr
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		rts


vsync	move.w	#$ffff,vsync_flag
.vs	tst.w	vsync_flag
	bne.s	.vs
	rts



******** save all and start interrupts *******************
setup		clr.l	-(sp)		;set supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,org_stack

.wfd		tst.w	$43e.w		;wait for disc drive light to go out
		bne.s	.wfd
.get		move.w	$ffff8604.w,d0
		btst	#7,d0
		bne.s	.get

		move.b	#$12,$fffffc02.w	;disable mouse
		or.b	#2,$ffff820a.w

		lea	old_pal,a1		;save original palette
		lea	$ffff8240.w,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)

		move.w	#3,-(sp)		;get original screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,org_base

		ifeq	ASM_TO_DISC
		move.w	#4,-(sp)		;get original rez
		trap	#14
		addq.l	#2,sp
		move.l	d0,org_rez
		ENDC

		move.l	#screen,d0		;create our own screen space
		clr.b	d0
		move.l	d0,a0
		move.l	a0,my_base

		clr.w	-(sp)			;low rez
		move.l	a0,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		lea	pic+2,a0		;set new palette
		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)

		move.b	$484.w,old484		;save old keyboard status
		move.b	#2,$484.w

		moveq	#1,d0		;start tune
		bsr	tune

		move.w	#-1,vsync_flag

		ori.w	#$700,sr	;set border code up
		lea	save_area,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

		move.l	#my_vbl,$70.w
		move.l	#my_keyboard,$118.w	;our new keyboard rout
		move.l	#border,$120.W

		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto ISR enable at RTE
		clr.b	$fffffa1b.w		;di timer B
		clr.b	$fffffa21.w		;clr timer B data
		move.w	#$2300,sr		;enable ISR


;***************************************************
;* show picture 7
;* Written by MAC SYS DATA 26/8/89 10:15
;***************************************************

		lea	pic+34,a0
		move.l	a0,a2
		add.w	#16000,a0
		add.w	#16000,a2
		move.l	my_base,a1
		move.l	a1,a3
		lea	16000(a1),a1
		lea	16000(a3),a3
		move.w	#200-1,d7
lines		move.w	#20-1,d6
words		move.l	(a0)+,(a1)+
		move.l	-(a2),-(a3)
		dbf	d6,words
		bsr	vsync
		dbf	d7,lines
		rts


*********
* ISRs  *
*********
my_vbl		movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
		clr.w	vsync_flag		;reset our vsync

		bsr	tune+8			;do the tune
		bsr	zoom

		move.l	pic+2,$ffff8240.w	;reset colours altered by border code

		addq.w	#2,pal_offset

		movem.l	(sp)+,d0-d7/a0-a6	;restore regs
		move.b	#199,$fffffa21.w	;set timer B data

		tst.w	hertz_delay
		bne.s	.dec

		move.b	#8,$fffffa1b.w		;enable timer B
		rte

.dec		subq.w	#1,hertz_delay
		move.b	#8,$fffffa1b.w		;enable timer B
		rte

		
border		clr.b	$fffffa1b.w		;di timer B
		move.w	d0,-(sp)		;wait a while!
		REPT	50
		nop
		ENDR
		moveq	#0,d0
.loop		cmp.b	$ffff8209.w,d0		;test low screen counter until at right of screen
		bne.s	.loop
		clr.b	$ffff820a.w		;60 hertz
		REPT	22			;wait until raster gets to left
		nop
		ENDR
		move.b	#2,$ffff820a.w		;back to 50 hertz

		move.w	#$002,$ffff8240.w		;alter background border colour
		move.l	a0,-(sp)
		lea	pal_table,a0
		move.w	pal_offset,d0
		and.w	#255,d0
		add.w	d0,a0
		move.w	#30-1,d0
col_loop	move.w	(a0)+,$ffff8242.w
		REPT 120
		nop
		ENDR
		dbf	d0,col_loop
		move.l	(sp)+,a0
		move.w	(sp)+,d0
		rte

my_keyboard	move.l	d0,-(sp)		;new keyboard routine
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		move.l	(sp)+,d0
		rte




********
* Data *
********
	SECTION DATA

pal_offset	dc.w	0

pal_table
 dc.w	$8b0,$130,$9a0,$220,$a90,$310,$b80,$400,$c00,$500,$d00,$600,$e00,$700,$f00,$f80
 dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$740,$ec0,$650,$dd0,$560,$ce0,$470,$bf0,$3f0,$af8
 dc.w	$2f1,$9f9,$1f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$077,$0ef,$06f,$0df
 dc.w	$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$80f,$10f,$90f,$20f,$a0f,$30f
 dc.w	$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$707,$f0e,$f06,$f8d,$f15,$f9c,$f25,$fab,$f33
 dc.w	$fba,$f42,$fc9,$f51,$fd8,$760,$ee0,$670,$df8,$5f1,$cf9,$4f2,$bfa,$3f3,$afb,$2f4
 dc.w	$9fc,$1f5,$8fd,$0f6,$0fe,$0f7,$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f
 dc.w	$03f,$0bf,$047,$0ce,$056,$0dd,$065,$0ec,$0f4,$07b,$0e3,$06a,$0d2,$059,$0c1,$048

 dc.w	$8b0,$130,$9a0,$220,$a90,$310,$b80,$400,$c00,$500,$d00,$600,$e00,$700,$f00,$f80
 dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$740,$ec0,$650,$dd0,$560,$ce0,$470,$bf0,$3f0,$af8
 dc.w	$2f1,$9f9,$1f2,$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$077,$0ef,$06f,$0df



line_ptr	dc.l	scroll_line
scroll_line
 DC.B "Persistence Of Vision 119     Menu coded by MAC SYS DATA,  "
 DC.B "Art by OZYMANDIAS,  Music by MAD MAX (don't know where it's "
 dc.b "from but Jackie of ACF ripped it!).        "
 dc.b "Release date:   11th July 1992.          This disc was released "
 dc.b "at the 16 bit show at Wembley in London, England.     "
 dc.b "If you were there you may have seen Boris and myself Mac Sys Data "
 dc.b "wandering around the show. We were easily recognised as we had "
 dc.b "black shirts with a bright green log POV on the front.     Tell you what, it's "
 dc.b "rock hard typing text in the past tense when it hasn't happened yet!    I'm "
 dc.b "writing this text on the 9th of July so I can put the discs together "
 dc.b "before I go to London.   I think Mark from Adrenalin is going with "
 dc.b "us, he is easily recognised as he has a pony tail and wears a dress  "
 dc.b "  (only joking about the dress).          Some people who use "
 dc.b "televisions and not monitors may not be able to see some lower case "
 dc.b "letters. The answer is easy....... go buy a Philips CM8833!!!!     "
 dc.b "      If I seem a bit vague then it's because I'm trying to "
 dc.b "finish off my POV tee shirt and I also want to goto the pub (again!). "
 dc.b "           This disc is pretty boring really, the menu is a bit "
 dc.b "retro and doesn't really follow the recent quality discs we have been producing."
 dc.b "          If you want to contact us (and a lot of you have been) then write "
 dc.b "to POV at the following address.....           POV,      "
 dc.b "P.O. Box 40,      Thornton-Cleveleys,      Lancashire,      "
 dc.b "FY5 3PH,      England.             "
 dc.b "I have very little to say "
 dc.b "so I'll do the greetings now.     Hi to.... "
 dc.b "ADRENALIN,     "
 dc.b "ANIMAL MINE,     "
 dc.b "BLACK CATS,     "
 dc.b "BLIND BASTARD,     "
 dc.b "CYNIX,     "
 dc.b "D-BUG,     "
 dc.b "DELTA FORCE,     "
 dc.b "DR SYNE,     "
 dc.b "ERIK PLANKTON,     "
 dc.b "EQUINOX,     "
 dc.b "FUSION,     "
 dc.b "GENESIS INC.,     "
 dc.b "GEORGE (BART),     "
 dc.b "INNER CIRCLE,     "
 dc.b "KGB,     "
 dc.b "MAD VISION,     "
 dc.b "MUG UK,     "
 dc.b "LOWLIFE,     "
 dc.b "NOW 5 A.K.A PURE ENERGY,     "
 dc.b "NOD,     "
 dc.b "PAL PD,     "
 dc.b "PIXEL TWINS,     "
 dc.b "POMPEY PIRATES,     "
 dc.b "PROPHECY PD,     "
 dc.b "REPLICANTS,     "
 dc.b "RIPPED OFF,     "
 dc.b "SEWER SOFTWARE,     "
 dc.b "SLAYTANIC CULT,     "
 dc.b "ST CNX,     "
 dc.b "STRANGER,     "
 dc.b "TCB,     "
 dc.b "THE SOURCE,     "
 dc.b "THE SYNDICATE,     "
 dc.b "UNITY,     "
 dc.b "UTOS     and     "
 dc.b "WILD!            "
 dc.b "Well that should please some people.       Today I went to the "
 dc.b "train station to get a ticket for Saturday.   The price of a "
 dc.b "'standard class' is usually about 34 pounds but because it's "
 dc.b "July it cost me 43 pounds return.    Bloody rip off!      "
 dc.b "For 43 pounds I could take my car.  British Rail complain "
 dc.b "that they don't get enough people on their trains and when "
 dc.b "it's the most popular time and people flock to fill them and "
 dc.b "boost BR's profits what do they do?      Wap up the price so all "
 dc.b "the people can't afford it and go by bus instead!    The "
 dc.b "stupid, fat headed, dick faced gits at BR.     It appears "
 dc.b "that they don't want people to go on their nice, new trains. "
 dc.b "I expect they're scared that they may get dirty or worn out.  "
 dc.b "I hope loads of people go and vandalise the railway "
 dc.b "bridges with excellent Bronx style paintings.        "
 dc.b "Whilst I'm on the rant I would like to tell all you coders this.... "
 dc.b "   YOU ARE NOT GETTING THE SOURCE CODE TO THIS MENU      why?     "
 dc.b "'cause I'm fed of people writing to me to say 'please send the "
 dc.b "source code to discs  51,52,53,54,55,56,etc..'.   I will no longer "
 dc.b "send my source code out free of charge without people sending "
 dc.b "lots of things in return.    People are now getting my "
 dc.b "menu code to swap for other things and as I was freely spread my "
 dc.b "code it was easy pickings.   Well all you scrounging gits you "
 dc.b "can get lost, the only people I'll send things to is some members "
 dc.b "of Adrenalin and some of the learners who have asked me to explain "
 dc.b "simple code.     The people who have asked me for lots of stuff will "
 dc.b "know who they are and will also know not to write to me again trying "
 dc.b "to sponge more code off me.        Okay?          "
 dc.b "This is Mac Sys Data signing off another POV compilation as I've got "
 dc.b "to write the high score routine for JET-PAC!    "
 DC.B "                         5        4        3        2        1        "
 dc.b	$ff
	even

tune	incbin "tune.mus"
	even


font	incbin	"font1.dat"
	incbin	"font2.dat"
	even

width_table
;letter widths will be rounded up to next integer/number of pixels to shift every VBL

;	    !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	23,11,17,19,22,14,15,14,15,15,18,14,14,24,14,14
;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >
 dc.b	19,15,19,19,19,19,19,19,19,19,14,14,18,22,18
;        ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M
 dc.b	23,22,21,19,15,19,19,17,19,21,11,19,20,19,28
;        N  O  P  Q  R  S  T  U  V  W  X  Y  Z  [  \
 dc.b	20,17,18,19,23,17,26,21,21,30,21,21,18,32,32
;        ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k
 dc.b	00,00,00,00,13,13,13,13,13,10,13,15,08,08,15
;        l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
 dc.b	08,21,13,12,13,13,13,10,08,13,15,21,15,13,10
;        {  |  }  ~  
 dc.b	00,00,00,00,00
	even


pic	incbin	"pov119.PI1"

zoom_number	dc.w	0

zoom_data	incbin	zoom.dat

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"MY_SOCKS.MUG",0
	even
exec2	dc.b	"$$teaparty.prg",0
	even
exec3	dc.b	"X_PARTY",0
	even
exec4	dc.b	"TOM",0
	even
exec5	dc.b	"PULSION",0
	even
exec6	dc.b	"REPS",0
	even
exec7	dc.b	"GUDUL",0
	even
exec8	dc.b	"copier.pov",0
	even


****************************
	SECTION BSS
****************************

bss_start

scroll_number	ds.w	1
vsync_flag	ds.w	1
old484		ds.w	1
old_pal		ds.b	32
org_stack	ds.l	1
org_base	ds.l	1
	ifeq	ASM_TO_DISC
org_rez		ds.w	1
	ENDC

hertz_delay	ds.w	1
hertz_toggle	ds.w	1

key		ds.w	1
delay		ds.w	1

save_area	ds.l	3
		ds.b	4

buffer		ds.b	FONT_DEPTH*4

my_base		ds.l	1
		ds.b	256
screen		ds.b	32000
		ds.b	160*46
bss_end