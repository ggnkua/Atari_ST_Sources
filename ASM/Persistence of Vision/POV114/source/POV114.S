*************************************************************************
*			Persistence Of Vision menu 114			*
*			------------------------------			*
*									*
* All coding by:	Machine System Data				*
*									*
* Art by:		Ozymandias					*
*									*
* Music by:		Sound images (from VIZ the game)		*
*									*
*									*
* 			Assemble with GENST2.08 or higher		*
* 		Originally written using DEVPAC Proffesional		*
*									*
*************************************************************************
;
; If you use this code then please give me credit.
;
; Mac Sys Data
; P.O. Box 40, Thornton-Cleveleys, Lancs., FY6 9AZ, Lancs.
;
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* EQUATES AND BITS............
*
* At P.O.V. we use a program called AUTORUN which P_EXECs the program
* from a seperate program in the AUTO folder (after the menu).
* We use AUTORUN because it allows us to use our own GEM start and it
* ensures ALL 512K demos run in 512K and don't need not 1 meg.
*
* If you have a copy of AUTORUN and use it then set 'AUTORUN4' to YES
*
* If you want to P_EXEC the program from this menu then set AUTORUN4 to NO
*
*
*
YES=1
NO=0


AUTORUN4=YES	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here




***************************
	SECTION TEXT
***************************


*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	opt	o+


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

	
	bsr	set_super
	bsr	wait_for_drive		;let the drive light go off!
	bsr	clear_bss		;best to clear this as packers leave crap in the bss
	or.b	#2,$ffff820a.w		;50Hz
	move.b	#$12,$fffffc02.w	;bye mousey
	bsr	get_old_pal
	bsr	get_org_base
	bsr	get_org_rez
	bsr	calc_screen		;make our own screen area
	bsr	set_low_rez
	move.b	$484.w,old484		;keep old keyboard settings
	clr.b	$484.w			;no bell, click, repeat, etc.

; "Viz" by Sound Images - Hacked by MUG U.K (11/9/1991)

	move.b	#1,tune+4	;there are 9 tunes here

	bsr	set_palette

	tst.w	$240.w
	bne.s	skip_intro
	move.l	#init_scroll_text,scroll_pointer
skip_intro
	bsr	set_for_border

	tst.w	$240.w
	bne.s	no_wot_pic
	move.w	#480-1,d0
wait	bsr	vsync
	dbf	d0,wait
no_wot_pic
	bsr	show_pic
	move.w	#-1,$240.w
main_loop
	bsr	vsync
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

	cmp.w	#$70,d0		;0 keypad
	beq.s	zero

	cmp.b	#$53,d0
	beq	do_reset


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

	bsr	isr_off
	bsr	set_org_base
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	old484,$484.w
	move.b	#8,$fffffc02.w
	bsr	user_mode

	ifeq	AUTORUN4
	bra	exec
	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

zero	tst.w	zero_counter
	bne	main_loop
	eor.w	#$202,bor+2
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop

do_reset
	move.l	4.w,-(sp)
	rts

exit	bsr	isr_off
	bsr	set_org_base
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
scroll	move.l	screen_base,a1
	add.w	#160*204,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#31*4,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31,d0		;char depth 30 lines
	add.w	d0,a0

.column
OFF	set	0
	REPT	31
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts


*************************************************************************
*				Service routines			*
*************************************************************************

vsync		move.w	#-1,vsync_flag
.vsync		tst.w	vsync_flag
		bne.s	.vsync
		rts

wait_for_drive	move.w	$ffff8604.w,d0
		btst	#7,d0
		bne.s	wait_for_drive
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

user_mode	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

get_old_pal	movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal
		rts

restore_pal	lea	old_pal,a0
		bra.s	set_p
set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

get_org_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,org_base
		rts

get_org_rez	move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,org_rez
		rts

calc_screen	move.l	#screen,d0
		clr.b	d0
		move.l	d0,screen_base
		rts

set_org_base	move.l	org_base,a0
		move.w	org_rez,d0
		bra.s	set_rez
set_low_rez	move.l	screen_base,a0
		clr.w	d0
set_rez		move.w	d0,-(sp)	;rez
		move.l	a0,-(sp)	;base
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts

show_pic	lea	pic+34,a0	;pic top left
		lea	160+152(a0),a2	;pic top right
		move.l	screen_base,a1
		lea	160+152(a1),a3
		move.w	#20-1,d5
.words		move.l	#%10000000000000001000000000000000,d1
		move.l	#%00000000000000010000000000000001,d2
		move.w	#16-1,d7
.bit		move.w	#200/2-1,d6
.lines		move.l	(a0),d0
		and.l	d1,d0
		move.l	d0,(a1)
		move.l	4(a0),d0
		and.l	d1,d0
		move.l	d0,4(a1)
		move.l	(a2),d0
		and.l	d2,d0
		move.l	d0,(a3)
		move.l	4(a2),d0
		and.l	d2,d0
		move.l	d0,4(a3)
		lea	320(a0),a0
		lea	320(a1),a1
		lea	320(a2),a2
		lea	320(a3),a3
		dbf	d6,.lines
		lea	-32000(a0),a0
		lea	-32000(a1),a1
		lea	-32000(a2),a2
		lea	-32000(a3),a3
		move.l	d1,d0
		lsr.l	#1,d0
		or.l	d0,d1
		move.l	d2,d0
		lsl.l	#1,d0
		or.l	d0,d2
		dbf	d7,.bit
		addq.w	#8,a0
		addq.w	#8,a1
		subq.w	#8,a2
		subq.w	#8,a3
		dbf	d5,.words
		rts



clear_bss	lea	bss_start,a0
.clear		clr.b	(a0)+
		cmp.l	#bss_end,a0
		bne.s	.clear
		rts

set_for_border	move.w	#$2700,sr
		move.l	$70.w,old70
		move.l	$120.w,old120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_70,$70.w
		move.l	#new_120,$120.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w	;auto isr enable at rte
		clr.b	$fffffa1b.w
		move.w	#$2300,sr
		rts


isr_off		bsr	vsync
		move.w	#$2700,sr
		move.l	old120,$120.w
		move.l	old70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.w	#$2300,sr
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		rts

*************************************************************************
*			Interrupt service routines (ISRs)		*
*************************************************************************


new_70							;new VBL routine
		move.l	pic+2,$ffff8240.w
		bsr	tune
		clr.w	vsync_flag
		move.l	#new_120,$120.W
		tst.w	zero_counter		;check hertz key delay
		bne.s	.dec
		clr.b	$fffffa1b.w
		move.b	#199,$fffffa21.w
		move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(sp)
	bsr	scroll
	movem.l	(sp)+,d0-a6

		rte
.dec		subq.w	#1,zero_counter
		clr.b	$fffffa1b.w
		move.b	#199,$fffffa21.w
		move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(sp)
	bsr	scroll
	movem.l	(sp)+,d0-a6

		rte

new_120		;ABSOLUTELY SOLID BORDER CODE........	new HBL routine (timer B)
		or.w	#$700,sr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$60,$ffff8209.w
		blo.s	.wait
.1		dbt	d0,.1
.2		dbt	d0,.2
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$60,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	88
		nop
		ENDR
.3		dbt	d0,.3
.4		dbt	d0,.4
		clr.b	$ffff820a.w
		nop
		movem.l	(sp)+,d0/a0
		move.b	#2,$ffff820a.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	#lower_border,$120.w
		rte

lower_border
		clr.b	$fffffa1b.w	;DI all other interrupts
bor		move.w	#$000,$ffff8240.w
		movem.l	d0/d1/a0/a1/a2,-(sp)
		moveq	#0,d0
.wait		cmp.b	#$60,$ffff8209.w
		blo.s	.wait
.1		dbt	d0,.1
.2		dbt	d0,.2
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$60,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	115
		nop
		ENDR
		move.w	#94,d0
.3		dbf	d0,.3
		lea	$ffff8242.w,a2

;this code can be changed to give raster razor lines (AKA Amiga)
		move.w	#31-1,d1	;31 lines of colour
.loop		lea	colours,a1
		REPT	40		;Timed to get 1 horizontal line of colour
		move.w	(a1)+,(a2)
		ENDR
		nop

;;;		nop			;add this nop to get vertical rasters

		dbf	d1,.loop
		movem.l	(sp)+,d0/d1/a0/a1/a2
		rte


******************************
	SECTION DATA
******************************

colours	dc.w	$200,$300,$400,$500,$600,$700,$710,$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$270,$171,$072,$073,$074,$075,$076,$077,$067,$057,$047
	dc.w	$037,$027,$017,$007,$006,$005,$004,$003,$002,$101,$200,$300



scroll_pointer	dc.l	scroll_text
init_scroll_text
 dc.b	"           P.O.V is proud to present di...    hey hold on where's "
 dc.b	"the picture?       hold on i'll go and find it.......      "
 dc.b	"                 that more like it!        "
scroll_text
 dc.b "PERSISTENCE OF VISION IS PROUD TO PRESENT DISC 114.          "
 dc.b "release date 20/04/92.     "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC "
 dc.b "FROM THE GAME 'VIZ' RIPPED BY "
 dc.b "MUG UK.        I LOVE THE WAY THIS MUSIC CHANGES MELODY AND IT "
 DC.B "SOUNDS SIMPLE, I'M GLAD TO GET AWAY FROM THE DIGI-DRUM MUSIC "
 DC.B "THAT EVERYONE IS USING AS THEY SOUND SO SIMILAR THAT THEY'RE "
 DC.B "BECOMING BORING.          "
 DC.B "     THIS IS M.S.D. ON THE KEYBOARD BRINGING YOU THE LATEST "
 DC.B "DISC IN OUR EVER GROWING COLLECTION.       ON THE FOLLOWING "
 DC.B "DISCS I WILL BE RELEASING MORE SAMPLED SOUND DEMOS BY THE A.B.C "
 DC.B "CREW.  I'LL TRY TO RELEASE THEM IN NUMERICAL ORDER SO YOUR "
 DC.B "COLLECTION WILL GROW chronologically.     AS WELL AS THE "
 DC.B "ABC DEMOS I HAVE OTHER SAMPLE ONES THAT HAVE BEEN WAITING FOR "
 DC.B "NEARLY 12 MONTHS SO I'LL RELEASE THOSE AS WELL. I'LL TRY "
 DC.B "TO AVOID PUTTING 2 SAMPLE DEMOS ON ONE DISC "
 DC.B "as I think they're pretty boring, i'll fill the discs up with "
 DC.B "small demos and intros so you'll get some variety.    YOU WILL BE GLAD TO KNOW THAT "
 DC.B "I WILL BE RELEASING SOME MORE BOOT SECTOR LOADING DEMOS "
 DC.B "SO YOU CAN COPY OVER YOUR ORIGINALS AND SAVE "
 DC.B "MONEY BUYING blanks.       hey all you amiga owners out there..."
 dc.b " have you got 'hard wired' and 'odyssey' demos?     if not then "
 dc.b "write to me and i'll send them a.s.a.p.     odyssey need 1 meg "
 dc.b "and comes on 5 discs, it takes 40 minutes to run.    hard wired "
 dc.b "comes on two discs and has an animated sequence on disc 1 and "
 dc.b "a whole load of new demo techniques on disc 2.  the vector "
 dc.b "bobs demo is good but the best bit is the 3d vector demo where "
 dc.b "the objects turn into a mush of dots then transform into a "
 dc.b "new shape (amazing).      if you want to get these demos then "
 dc.b "write to a PD library or to the usual P.O.V. PO BOX address coming up later. "
 dc.b "          what do you think of the colours in the border?     "
 dc.b "the same routine can do vertical rasters and with slight "
 dc.b "alteration will do 'copper' effects (Amiga talk!).       "
 dc.b "okay, here are the greetings....... "
 dc.b "PURE ENERGY,   BLACK CATS,   DR SYNE,   ERIK PLANKTON,   EMPIRE,   EQUINOX,   "
 dc.b "GEORGE (BART),   INNER CIRCLE,   MARTIAN,   MEDWAY BOYS,   "
 dc.b "OBERJE,   POMPEY PIRATES,   REPLICANTS,   SEWER SOFTWARE,   "
 dc.b "SLAYTANIC CULT (NICE SPEAKING TO YOU),   ST CNX,   TEX,   TCB,   WATCHMEN,   NOD + PIXEL TWINS,   "
 dc.b "PROPHECY PD,   BBC,   KGB,   ADRENALIN (EXCEPT MONSTER BEATLE),   THE SOURCE,   "
 dc.b "THE ENTERPRISE,   DELTA FORCE,   d-bug,   cynix,   electronic,   "
 dc.b "pal pd,   quartex   and   ripped off.        "
 DC.B " WELL I HOPE ALL YOU CARTER U.S.M. FANS HAVE BOUGHT THE "
 DC.B "NEW SINGLE 'THE ONLY LIVING BOY IN NEW CROSS'.   IF YOU "
 DC.B "HAVEN'T SEEN THE COVER, IT'S THE ONE WITH ALL THE CONDOM BOXES "
 DC.B "ON.    YEAH I'LL HAVE A CARTER GOLD DISC SOON AS MY BROTHER "
 DC.B "IS BRINGING 2 HOME WITH HIM SO I CAN PUT IT ON MY WALL.    "
 DC.B "      OKAY THAT'S ALL THE WAFFLE OUT OF THE WAY SO HERE IS THE "
 DC.B "SLAGGING....        ADRENALIN MEMBER 'MONSTER BEATLE' ARE YOU "
 DC.B "OUT THERE?       YOU GET MY SOURCE CODE FREE AND SEND ME NOTHING "
 DC.B "SO I DON'T KNOW HOW YOU HAVE THE NERVE TO SLAG MY CODE OFF "
 DC.B "AS YOU CAN'T DO A TENTH OF THE THINGS I DO.    WHEN YOU GROW "
 DC.B "UP AND BECOME MORE WISE YOU'LL PROBABLY LEARN THE SAYING  "
 DC.B "'PEOPLE IN GLASS HOUSES SHOULDN'T THROW STONES'.    IF "
 DC.B "YOU CONTINUE TO SLAG ME OFF THEN I'LL STOP SENDING MY SOURCE "
 DC.B "CODE SO ADRENALIN WILL CEASE TO BE.   FOR SUCH A BRILLIANT "
 DC.B "CREW YOU SEEM TO HAVE QUITE A FEW LAMERS AS YOU HAVE TO "
 DC.B "RELY ON OTHER PEOPLE SENDING YOU STUFF ALREADY CRACKED AND "
 DC.B "MENUS ALREADY WRITTEN.   WHY DOES PONY SEND ME STUFF "
 DC.B "TO SORT OUT IF ADRENALIN IS SO GOOD AND WHY DID YOU ASK "
 DC.B "PONY TO GET ME TO JOIN SO SOME DECENT HACKERS WOULD BE "
 DC.B "ATTRACTED TO ADR?     ALSO I CAN SEND MY SOURCE CODE "
 DC.B "TO WHOEVER I WANT, INFACT I'LL PROBABLY WRITE SOME SHIT-HOT "
 DC.B "MENUS FOR 'PURE ENERGY' JUST TO SPITE YOU.   IF YOU HAVE "
 DC.B "A BRAIN IN YOUR HEAD YOU'D QUIT BEING A MEMBER OF ADRENALIN AND "
 DC.B "LEARN TO CODE, ONCE YOU'VE WRITTEN MORE MENUS OF BETTER QUALITY "
 DC.B "THAN I HAVE I'LL LET YOU SLAG ME OFF BUT UNTIL THAT DATE 'FUCK OFF'."
 DC.B "        I'M SORRY TO ALL THE PEOPLE WHO DON'T LIKE SWEAR "
 DC.B "WORDS ON SCROLLERS BUT I'M PRETTY ANGRY AT THIS INDIVIDUAL "
 DC.B "WHO AT THE AGE OF 15 CAN ONLY CODE A LITTLE AND CAN'T FIGURE "
 DC.B "OUT EXTREMELY SIMPLE ROUTINES SO HE SLAGS OTHERS OFF WHO CAN.     IF MY "
 DC.B "MENUS ARE CRAP THEN WHY DO 6 CREWS USE THEM?      RIGHT "
 DC.B "I'M OFF TO POST A LETTER TO BORIS - I'LL BE BACK ON P.O.V. 115. "
 DC.B "                  YOU CAN CONTACT P.O.V. AT THE FOLLOWING "
 DC.B "ADDRESS...       P.O.V.,      P.O. BOX 40,      THORNTON-CLEVELEYS,      "
 DC.B "LANCS.,      FY5 3PH,      UK.                AND ONCE AGAIN "
 DC.B "        P.O.V.,      P.O. BOX 40,      THORNTON-CLEVELEYS,      "
 DC.B "LANCS.,      FY5 3PH,      UK.              THANKS YOU AND "
 DC.B "GOODBYE........                                            "
 DC.B "                                                           "
 dc.b $ff
	even
font		dcb.b	31*4,0
		incbin	1plane.fnt
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;	 v  w  x  y  z
 dc.b	22,23,24,25,26

	even


tune	incbin	viz.bin
	even

pic	incbin	pov114.PI1
	even


;valid keys to load demos

demo_keys
	dc.b	0, $02		;keyboard 1
	dc.b	1, $03		;         2
	dc.b	2, $04		;         3
	dc.b	3, $05		;         4
	dc.b	4, $06		;         5
	dc.b	5, $07		;         6
	dc.b	6, $08		;         7
	dc.b	7, $09		;         8
	dc.b	8, $0a		;         9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;       2
	dc.b	2, $6f		;       3
	dc.b	3, $6a		;       4
	dc.b	4, $6b		;       5
	dc.b	5, $6c		;       6
	dc.b	6, $67		;       7
	dc.b	7, $68		;       8
	dc.b	8, $69		;       9

	dc.b	-1, -1		;end of table


filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"$$",0		;$$ means quit to desktop in AUTORUN4
	even
exec2	dc.b	"mr_music",0
	even
exec3	dc.b	"SOTE",0
	even
exec4	dc.b	"TFS",0
	even
exec5	dc.b	"ULM_1",0
	even
exec6	dc.b	"DEL",0
	even
exec7	dc.b	"EGB_3D",0
	even
exec8	dc.b	"REPS",0
	even
exec9	dc.b	"COPIER.POV",0
	even


****************************
	SECTION BSS
****************************
bss_start
stack_save	ds.l	1
zero_counter	ds.w	1
old_pal		ds.w	16
org_base	ds.l	1
org_rez		ds.w	1
screen_base	ds.l	1
old484		ds.w	1
old70		ds.l	1
old120		ds.l	1
vsync_flag	ds.w	1
hertz_switch	ds.w	1

char_offset	ds.w	1

olda07		ds.b	1
olda09		ds.b	1


		ds.b	256
screen		ds.b	32000+160*47
bss_end
