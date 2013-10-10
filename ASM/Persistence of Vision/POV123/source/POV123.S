*************************************************************************
*				P.O.V. 123				*
*				----------				*
*									*
* Written By MACHINE SYSTEM DATA of PERSISTENCE OF VISION		*
*									*
*									*
* Art by: OZYMANDIAS and MAC SYS DATA					*
*									*
*									*
* Date: August 1992							*
*									*
*									*
* All code ½ P.O.V. 1992						*
* 									*
*************************************************************************
*
* P.O.V.
* P.O Box 40
* Thornton-Cleveleys
* Lancashire
* FY5 3PH
* England
*
*

	opt	o+,w-


YES=1
NO=0

FINAL=NO

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg


VBL		equ	$70
TIMERB		equ	$120
TBCR		equ	$fffffa1b
TBDR		equ	$fffffa21
COLOUR0		equ	$ffff8240
COLOUR1		equ	$ffff8242
COLOUR2		equ	$ffff8244
COLOUR3		equ	$ffff8246
COLOUR4		equ	$ffff8248
COLOUR5		equ	$ffff824a
COLOUR6		equ	$ffff824c
COLOUR7		equ	$ffff824e
COLOUR8		equ	$ffff8250
COLOUR9		equ	$ffff8252
COLOUR10	equ	$ffff8254
COLOUR11	equ	$ffff8256
COLOUR12	equ	$ffff8258
COLOUR13	equ	$ffff825a
COLOUR14	equ	$ffff825c
COLOUR15	equ	$ffff825e


************************************************************************
			SECTION TEXT
************************************************************************


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
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
*******************************************************************



	bsr	clear_bss
	bsr	set_super		;set supervisor mode
	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	save_pal		;save old palette
	bsr	get_base		;get present screen base
	bsr	get_rez
	bsr	black_out		;make all colours black
	bsr	calc_screen		;calc our own screen address
	move.l	screen_1,a0		;new screen base
	bsr	set_low_rez		;go into low rez
	move.l	screen_1,present_base
	move.l	screen_2,last_base

	move.b	$484.w,old484		;save keyboard click/speed, etc
	clr.b	$484.w			;disable repeat/click/bell

	bsr	set_palette		;set new colours
	bsr	set_isr
	bsr	show_pic
	bsr	flush			;flush keyboard buffer

main_loop	bsr	flip_screen
		bsr	vsync
;		move.w	#$070,COLOUR0.w
		bsr	scroll
;		move.w	pic+2,COLOUR0.w

		move.w	key,d0

		IFEQ	FINAL
		cmp.w	#1,d0			;escape?
		beq	exit			;yes get out...
		ENDC

		cmp.w	#$b,d0			;0 key
		beq	zero

		cmp.w	#$70,d0			;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi.s	main_loop
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

		bsr	stop_isr

		move.l	old_base,a0		;put screen back to original
		bsr	set_org_rez		;go org rez for assembler/desktop
		bsr	restore_pal		;restore colours
		move.b	#8,$fffffc02.w		;mouse back on
		move.b	old484,$484.w		;keyclick, etc
		bsr	flush			;clear keyboard buffer

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50		move.b	#8,$fffffc02.w		;mouse back on

		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp


		ifeq	AUTORUN4
		bra	exec

		ELSE

		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC


zero		tst.w	zero_counter
		bne	main_loop
		eor.w	#$003,pic+2		;show a hertz change
		eor.w	#$ffff,hertz_switch	;toggle a check
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

		IFEQ	FINAL
exit		bsr	stop_isr

	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!

		ENDC
***************
* Subroutines *
***************

DEPTH	equ	32

scroll	move.l	last_base,a1
	lea	160*72(a1),a1
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words
	moveq	#0,d4
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0	;find correct offset
	mulu	#8*DEPTH,d0	;8 bytes wide * DEPTH
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	lsl.w	#5,d0		;*DEPTH
	add.w	d0,a0		;we now point to character in A0
.column
OFF	set	0
	REPT	DEPTH
	move.b	(a0)+,d3
	move.b	d3,OFF(a1)
	move.b	d3,160+OFF(a1)
	move.b	d3,320+OFF(a1)
	move.b	d3,480+OFF(a1)
OFF	set	OFF+4*160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#7,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#7,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)		;is scroll text end?
	bpl.s	.end		;NO!
	lea	scroll_text,a4	;reset scroll text
.end	move.l	a4,scroll_pointer
	rts


********************
* SERVICE ROUTINES *
********************

flip_screen	;flip between 2 screens to stop bob flickering
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq	.1
	move.l	screen_2,a0
.1	move.l	a0,present_base
	eor.w	#-1,screen_number
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$fffff8201.w,a0
	movep.w	d0,(a0)
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts


vsync	move.w	#$ffff,vsync_flag	;custom routine to wait
vs	tst.w	vsync_flag		;for screen refresh
	bne.s	vs
	rts


set_super
	move.l	d7,user_stack

	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


save_pal			;save old colours
	lea	old_pal,a1
	lea	COLOUR0.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


restore_pal			;put back original colours
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	COLOUR0.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


get_base			;get org screen address
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts


get_rez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts


calc_screen	;calc our own screen address...
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_1
	add.l	#40192,d0
	move.l	d0,screen_2
	rts


set_med_rez
	move.w	#1,-(sp)
	bra.s	set_rez
set_org_rez
	move.w	org_rez,-(sp)
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
set_rez	move.l	a0,-(sp)	;screen address is in A0
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


show_pic			;show the pic
	lea	pic+34,a0
	move.l	present_base,a2
	move.l	screen_2,a1
	move.w	#32000/4-1,d1
.copy	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d1,.copy
	rts


black_out				;all colours black
	movem.l	black,d0-d7
	movem.l	d0-d7,COLOUR0.w
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)	;ROM wait for screen update
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


clear_bss
	lea	bss_start,a0
.clear	clr.l	(a0)+
	cmp.l	#bss_end,a0
	blt.s	.clear
	rts


set_isr		ori.w	#$700,sr
		lea	storage,a0
		move.l	$118.w,(a0)+
		move.l	VBL.w,(a0)+
		move.l	TIMERB.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13,(a0)+
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

		move.l	#new_70,VBL.w		;set new interrupt values
		move.l	#new_timerb,TIMERB.w
		move.l	#new_kbd,$118.w

		clr.b	TBCR.w		;Stop timer B
		or.b	#1,$fffffa07.w	;Timerb interrupt enable register A
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w	;enable auto A-INTERRUPT IN SERVICE clear
		move.w	#$2300,sr	;start ISRs
		rts


stop_isr	bsr	vsync
		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$118.w
		move.l	(a0)+,VBL.w
		move.l	(a0)+,TIMERB.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.w	#$2300,sr
		rts


*********
* ISRs  *
*********
new_70	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7		;set colours after isr
	movem.l	d0-d7,COLOUR0.w
	bsr	tune+$98
	clr.w	vsync_flag		;own screen update rout
	clr.w	colour_offset
	tst.w	zero_counter
	beq.s	.clear
	sub.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	clr.b	TBCR.w
	move.l	#new_timerb,TIMERB.w
	move.b	#72,TBDR.w
	move.b	#8,TBCR.w		;set interrupt method
	rte				;let's leave before interrupt occurs


new_timerb	move.l	a0,-(sp)
		move.l	d0,-(sp)
		move.l	#$00040004,$ffff8240+4.w
		lea	colours,a0
		move.w	colour_offset,d0
		move.w	(a0,d0.w),$ffff8242.w
		clr.b	TBCR.w
		move.l	#faster_timerb,TIMERB.w
		add.w	#2,colour_offset
		move.b	#2,TBDR.w
		move.b	#8,TBCR.w
		move.l	(sp)+,d0
		move.l	(sp)+,a0
		rte

faster_timerb	move.l	a0,-(sp)
		move.l	d0,-(sp)
		lea	colours,a0
		move.w	colour_offset,d0
		move.w	(a0,d0.w),$ffff8242.w
		add.w	#2,colour_offset
		move.l	(sp)+,d0
		move.l	(sp)+,a0
		rte

new_kbd	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte

******************************
	SECTION DATA
******************************

colours	dc.w	$200,$a00,$300,$b00,$400,$c00,$500,$d00
	dc.w	$600,$e00,$700,$f80,$f10,$f90,$f20,$fa0
	dc.w	$f30,$fb0,$740,$fc0,$f50,$fd0,$f60,$fe0
	dc.w	$f70,$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0
	dc.w	$bf0,$3f0,$af0,$2f0,$9f8,$1f1,$8f9,$0f2
	dc.w	$0fa,$0f3,$0fb,$0f4,$0fc,$0f5,$0fd,$0f6
	dc.w	$0fe,$0f7,$07f,$0ef,$06f,$0df,$05f,$0cf
	dc.w	$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "           WELCOME TO PERSISTENCE OF VISION 123.        "
 dc.b "CREDITS: MENU CODED BY MAC SYS DATA,   "
 dc.b "GRAFIX BY OZ AND MSD,   MUSIC BY RALPH RUDSKI.   RELEASE DATE: 1ST SEPT 1992.       "
 DC.B "YEAH I JUST SOLD MY MOTORCYCLE, IT WAS A KAWASAKI Z650 AND WAS MADE "
 DC.B "IN 1978 (BRITISH 'S' REG).  I ONLY HAVE MY FORD FIESTA XR2 FOR "
 DC.B "TRANSPORT UNTIL I GET ANOTHER BIKE.  I FANCY BUYING "
 DC.B "A HONDA CBR600 OR ONE OF THE NEW 250CC BIKES AS THEY ALL GO "
 DC.B "LIKE THE CLAPPERS.      ANYWAY ENOUGH OF THIS AND ONTO SOME "
 DC.B "SERIOUS WORDS.....           "
 DC.B "BE WARNED THIS DISC CONTAINS "
 DC.B "SOME SERIOUS SLAGGING....   THERE ARE 3 DECENT DEMO PACKING "
 DC.B "GROUPS IN THE UK;   P.O.V.,  RIPPED OFF  AND  THE SOURCE.    "
 DC.B "    THERE HAS NOW APPEARED ANOTHER CREW CALLED U.P.A.     "
 DC.B "THEY HAVE DONE 5 DISCS SO FAR AND I WAS SHOWN THEM THE OTHER NIGHT."
 DC.B "    I HAD A LOOK AND NOTICED THEY WERE USING MEDWAY BOYS, P.O.V. AND "
 DC.B "DREAM WEAVERS MENU CODE.   I LOADED SOME OF THE DEMOS AND NOTICED "
 DC.B "THEY LOADED A LOT OF DATA SO I LOOKED AT THE DIRECTORIES..  "
 DC.B "OH WHAT'S THIS I'VE FOUND.... PICTURES NOT PACKED?        I "
 DC.B "CONTINUED UNTIL DISC 5 WHERE I SAW THE BAT DEMO.     THE DEMO "
 DC.B "LOADED AND DEPACKED SO I CHECKED TO SEE IF THEY HAD PACKED THE "
 DC.B "PICTURES, WHAT A SHOCK I GOT..     IF YOU TAKE A LOOK YOU "
 DC.B "WILL NOTICE THEY HAVE RIPPED THE VERSION I DID ON P.O.V. 9.  "
 DC.B "  THE MEMBER CALLED 'PACK-MAN' HAS CHANGED MY TEXT TO SAY "
 DC.B "HE PACKED IT BUT THE DOPEY GIT LEFT MY FILENAMES.     IF YOU "
 DC.B "ARE READING THIS 'PACK-MAN' THEN FORGET SENDING SOME DISCS "
 DC.B "AS I WOULDN'T GIVE YOU THE TIME OF DAY.   IF YOU WANT TO GET "
 DC.B "BACK INTO THE P.O.V. GOOD BOOKS THEN YOU'D BETTER APPOLOGIZE "
 DC.B "ON ONE YOUR MENUS AND GIVE P.O.V. FULL CREDIT FOR ALL THE "
 DC.B "PAST STUFF AND GIVE US CREDIT ON FUTURE DISCS WHERE YOU USE OUR "
 DC.B "PACKS AND CODE.     U.P.A. --- LAMERS!               "
 DC.B "HERE ARE THE GREETINGS..     "
 DC.B "U.P.A. - NOT!           "
 DC.B "ABC CREW,     "
 dc.b "ADRENALIN,     "
 dc.b "ANIMAL MINE,     "
 dc.b "DEL,     "
 DC.B "DR.SYNE,     "
 DC.B "ERIK PLANKTON,     "
 DC.B "EMPIRE,     "
 DC.B "EQUINOX,     "
 DC.B "GEORGE (TOWER PD),     "
 DC.B "INNER CIRCLE,     "
 DC.B "KGB (FRANCE),     "
 DC.B "LOST BOYS,     "
 DC.B "REPLICANTS,     "
 DC.B "RIPPED OFF,     "
 DC.B "SEWER SOFTWARE,     "
 DC.B "SLAYTANIC CULT,     "
 DC.B "ST CNX,     "
 dc.b "STRANGER (FREDDY),     "
 DC.B "TCB,     "
 DC.B "THE SOURCE,     "
 dc.b "TNT CREW,     "
 DC.B "AND     "
 DC.B "THE WATCHMEN.       "
 DC.B "THAT'S ALL, SO WARP!                                               "
 DC.B "                                                   "
 dc.b $ff
	even

font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,46,48,00,00,00,00,48,41,42,44,00,27,43,28,45

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,30,29,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,00,48,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even


tune	incbin	ralph_n5.mux
	even

font	dcb.b	DEPTH*8,0
	incbin	big1.fnt
	incbin	big2.fnt

pic	incbin	pic.pi1


********** valid key press table
demo_keys	dc.b	0, $02		;key 1
		dc.b	1, $03		;key 2
		dc.b	2, $04		;key 3
		dc.b	3, $05		;key 4
		dc.b	4, $06		;key 5
		dc.b	5, $07		;key 6
;		dc.b	6, $08		;key 7
;		dc.b	7, $09		;key 8
;		dc.b	8, $0a		;key 9

		dc.b	0, $6d		;keypad 1
		dc.b	1, $6e		;keypad 2
		dc.b	2, $6f		;keypad 3
		dc.b	3, $6a		;keypad 4
		dc.b	4, $6b		;keypad 5
		dc.b	5, $6c		;keypad 6
;		dc.b	6, $67		;keypad 7
;		dc.b	7, $68		;keypad 8
;		dc.b	8, $69		;keypad 9
		dc.b	-1, -1


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"SWINGOUT.MSD",0
	even
filename2	dc.b	"X_SHADE.PRG",0
	even
filename3	dc.b	"PUL_149.PRG",0
	even
filename4	dc.b	"PUL_159.PRG",0
	even
filename5	dc.b	"JMP_2.PRG",0
	even
filename6	dc.b	"COPIER.POV",0
	even
filename7	dc.b	"filename.ext",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even




*************************
	SECTION BSS	
*************************
bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal		ds.b	32		;old colours

colour_offset	ds.w	1

zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1
key		ds.w	1

*** store for old ISR data
storage		ds.l	6

	even

black			ds.b	32	;32 bytes of nothing...

char_offset		ds.w	1

org_rez			ds.w	1	;original rez
hertz_switch		ds.w	1	;hertz toggle check

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	40192		;two screens
	ds.b	40192
bss_end