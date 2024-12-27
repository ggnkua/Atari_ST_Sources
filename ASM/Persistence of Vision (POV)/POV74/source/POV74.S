****************
* P.O.V. 74    *
****************
FINAL=1		;1=assembler   0=final assembly

	bra	over
 dc.b "HACKERS BEWARE.. THIS CODE HAS (LA)MER PROTECTION."
 DC.B "    ANY ATTEMPTS TO HACK INTO IT WILL CAUSE "
 DC.B "PREMANENT DAMAGE TO YOUR ST.....   "
	even
over
	ifeq	FINAL

	lea	menucode,a0
	lea	$24000,a1
up	move.l	(a0)+,(a1)+
	cmp.l	#menuend,a0
	blt.s	up
	jmp	$24000

menucode
	ORG	$24000
	ENDC

	bsr	set_super
	clr.l	$24
	clr.l	$200
wait_for_drive
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen

;************************************************************************
;*                        GHOULS AND GHOSTS                             *
;*                        -----------------                             *
;* Stolen by: MAC SYS DATA of P.O.V. 27/08/90 17:34                     *
;*      From: AUTOMATION disc 200                                       *
;* Include files:-                                                      *
;*                 GHOULS.IMG into TUNE                                 *
;************************************************************************
; FOLIN Bros. Music
	move.b	$484,old484
	move.b	#2,$484

	ifeq	FINAL
	lea	tune,a0
	lea	$1281a,a1
	move.w	#14392/4-1,d0
trans:	move.l	(a0)+,(a1)+
	dbf	d0,trans

;****************************************************************
; There is more than one tune in this code....
; 0=jingle 0
; 1=tune 1
; 2=jingle
; 3=jingle
; 4=AUTOMATION 200
; 5=tune
; 6=AUTOMATION 201

	jsr	$1298e	;init tune

	move.l	#4,d0
	move.w	d0,$134d0
	jsr	$12830	
	ENDC

	bsr	set_palette
	bsr	save_isr
	bsr	show_pic

	move.l	#hacker_alert,$24.w
	move.b	#0,$fffffc02.w
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll1
	bsr	scroll2
;	move.w	pic+2,$ffff8240.w

	move.b	key,d0

	ifne	FINAL
	cmp.b	#01,d0		;escape
	beq	exit
	ENDC

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;keypad 0
	beq	zero
	
	tst.w	zero_counter
	beq.s	car
aa	sub.w	#1,zero_counter

car	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),d0
	move.l	d0,-(sp)

	bsr	reset_isr

	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

zero	tst.w	zero_counter
	bne	aa
	eor.w	#$555,pic+32
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop
zero_counter:	dc.w	0

do_reset
	move.l	4,a0
	jmp	(a0)

exit:	bsr	reset_isr
	move.l	old_base,a0
	bsr	set_med_rez
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
scroll1	move.l	screen_base,a1
	add.l	#160*204+(160*28),a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	lower_scroll_pointer,a4
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
	mulu	#120,d0		;30
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0		;char depth 4 bytes * 30 deep
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	lower_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	lower_text,a4
.end	move.l	a4,lower_scroll_pointer
	rts



scroll2	move.l	screen_base,a1
	lea	160(a1),a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	upper_scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset2,d6
next_char2
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#120,d0		;30
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0		;char depth 4 bytes * 30 deep
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char2	;NO!
	lea	upper_text,a5	;do reset scrolline
	bra	next_char2

.finish
	addq.w	#1,char_offset2
	and.w	#3,char_offset2
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	upper_text,a4
.end	move.l	a4,upper_scroll_pointer
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen:
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic
	lea	pic+34,a0
	move.l	screen_base,a1
	add.w	#160*36,a1
	move.w	#8-1,d7
rows:	move.w	#25-1,d6
columns:
	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	movem.l	24(a0),d0-d5
	movem.l	d0-d5,24(a1)
	movem.l	48(a0),d0-d5
	movem.l	d0-d5,48(a1)
	movem.l	72(a0),d0-d5
	movem.l	d0-d5,72(a1)
	movem.l	96(a0),d0-d5
	movem.l	d0-d5,96(a1)
	movem.l	120(a0),d0-d5
	movem.l	d0-d5,120(a1)
	movem.l	144(a0),d0-d3
	movem.l	d0-d3,144(a1)
	lea	160*8(a0),a0
	lea	160*8(a1),a1
	dbra	d6,columns
	bsr	vsync
	bsr	vsync
	sub.w	#25*160*8,a0
	sub.w	#25*160*8,a1
	add.w	#160,a1
	add.w	#160,a0
	dbf	d7,rows
	rts
pause:	move.w	d0,-(sp)
	move.w	#600,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts


****************
* ISR ROUTINES *
****************
save_isr
	move.w	#$2700,sr
	move.l	$120.w,old120
	move.l	$118.w,old118
	move.l	$70.w,old70
	move.b	$fffffa11.w,save1
	move.b	$fffffa21.w,save2
	move.b	$fffffa07.w,save3
	move.b	$fffffa09.w,save4
	move.b	$fffffa0f.w,save5
	move.b	$fffffa13.w,save6
	move.b	$fffffa1b.w,save7
	move.b	$fffffa1d.w,save8
	clr.b	$fffffa1d.w
	andi.b	#$df,$fffffa09.w
	andi.b	#$fe,$fffffa07.w
	move.l	#new120,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	move.w	#$2300,sr
	rts

reset_isr
	move.w	#$2700,sr
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.l	old70,$70.w
	move.b	save3,$fffffa07.w
	move.b	save6,$fffffa13.w
	move.b	save4,$fffffa09.w
	move.b	save7,$fffffa1b.w
	move.b	save8,$fffffa1d.w
	move.b	save2,$fffffa21.w
	move.b	save1,$fffffa11.w
	move.b	save5,$fffffa0f.w
	lea	$ffff8800.w,a0
	move.b	#7,(a0)
	move.b	(a0),d1
	ori.b	#$3f,d1
	moveq.w	#$c,d0
.loop	move.b	d0,(a0)
	clr.b	2(a0)
	dbf	d0,.loop
	move.b	#7,(a0)
	move.b	d1,2(a0)
	move.w	#$2300,sr
	rts

new120	clr.b	$fffffa1b.w
	move.l	d0,-(sp)
	moveq	#$26,d0
.aaa	dbf	d0,.aaa
	move.b	#0,$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.l	a0,-(sp)
	lea	colours+6,a0
	move.w	#34,d0		;extra lines to read the scroller
.loop	move.w	(a0)+,$ffff8242.w
	REPT	121
	nop
	ENDR
	dbf	d0,.loop
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	bclr	#0,$fffffa0f.w
	clr.b	$fffffa1b.w
	rte

new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	move.w	d0,-(sp)
	move.w	#$57e,d0
.aaa	dbf	d0,.aaa
	clr.b	$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.w	(sp)+,d0
	movem.l	d0-d7/a0-a6,-(sp)
	REPT	60
	nop
	ENDR
	lea	colours_end-6,a0
	move.w	#30,d0
.loop	move.w	-(a0),$ffff8242.w
	REPT	121
	nop
	ENDR
	dbf	d0,.loop
	clr.b	$fffffa1b.w
	move.b	#$e4-32,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	pic+4,$ffff8242.w

	ifeq	FINAL
	jsr	$12a9a
	ENDC

	movem.l	(sp)+,d0-d7/a0-a6
	clr.w	vsync_flag
	rte

new118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	bclr	#6,$fffffa11.w
	rte

hacker_alert
	clr.w	$ffff8240.w
.loop	add.w	#$001,$ffff8240.w
	nop
	bra.s	.loop

********
* Data *
********
	SECTION DATA
colours	dc.w	0,0,0
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017,$006,$005,$004
colours_end
screen_base	dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
old_base	dc.l	0
counter		dc.w	0
hertz_switch	dc.w	0

lower_scroll_pointer	dc.l	lower_text+7
lower_text
 DC.B "                    "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 74.          "
 dc.b "ALL CODING BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC BY THE "
 dc.b "GREAT FOLIN BROTHERS RIPPED FROM GHOULS AND GHOSTS.         "
 dc.b "ANOTHER DAY, ANOTHER DISC!         RIGHT ALL YOU P.O.V. "
 DC.B "COLLECTORS HAVE YOU REMEMBERED WHAT IS ON DISC 75?      "
 DC.B "WHAT DO YOU MEAN YOU HAVN'T?    I SUPPOSE I'LL HAVE TO "
 DC.B "REMIND YOU..... ON DISC 75 THERE IS A COMPREHENSIVE INFO "
 DC.B "FILE CONTAINING ALL THE INFO ABOUT OUR DISCS AND WHAT WE "
 DC.B "HAVE DONE.....  I WAS GOING TO CODE IT UP BUT I'VE NO TIME "
 DC.B "SO BORIS IS DOING IT AT THIS MINUTE SOMEWHERE IN MANCHESTER "
 DC.B "(HEY BORIS, PUT YOUR GIRLFRIEND DOWN AND GET ON THAT ST KEYBOARD!!!). "
 DC.B "   THIS IS THE SECOND MENU IN 2 DAYS SO I MAY REPEAT WHAT I SAID "
 DC.B "ON DISC 73.    AS DISC SPACE WAS TIGHT ON DISC 73 I MISSED THE "
 DC.B "GREETINGS SO HERE THEY ARE.... HI TO   AUTOMATION,   "
 DC.B "ABC CREW,   BLACK CATS,   DR. SYNE,   ERIK PLANKTON,   "
 DC.B "EMPIRE,   EQUINOX,   GEORGE,   INNER CIRCLE,   LOST BOYS,   "
 DC.B "MARTIAN,   MEDWAY BOYS,   OBERJE,   POMPEY PIRATES,   "
 DC.B "REPLICANTS,   RIPPED OFF (NICE TALKING TO YOU STICK),   "
 DC.B "SEWER SOFTWARE,   SLAYTANIC CULTS,   ST CNX,   TEX,   TCB   AND   "
 DC.B "WATCHMEN.      IF YOUR NAME IS NOT THERE THEN WE AIN'T HEARD OF "
 DC.B "YOU OR YOU'VE NOT DONE ANYTHING RECENTLY.    IF YOU WANT TO SEND "
 DC.B "SOMETHING TO ME (MAC SYS DATA) OR TO ANY OTHER MEMBER OF P.O.V. "
 DC.B "(BORIS OR OZYMANDIAS) THEN GET THE ADDRESS FROM THE TOP SCROLLER. "
 DC.B "     P.O.V. IS LOOKING FOR CONTACTS SO IF YOU'RE NOT LAME, PLEASE "
 DC.B "WRITE TO US AT THE P.O. BOX.     NOTE: WE ARE NOT INTERESTED "
 DC.B "IN SWAPPING GAMES ONLY DEMOS AND CODE.      TODAYS DATE "
 DC.B "IS 27-5-91 (BANK HOLIDAY MONDAY) AND ALL I'VE DONE IS CODE "
 DC.B "THIS MENU AND DO A COUPLE OF PACKS.   ALL I DID YESTERDAY "
 DC.B "WAS PACK AND PLAY ON MY LYNX.    YES APART FROM 2 STFMS, "
 DC.B "1 STE, 1 AMIGA, 1 SPECTRUM 128, 1 ATARI 2600 I ALSO "
 DC.B "HAVE AN ATARI LYNX AND IT'S BRILLIANT (GO BUY ONE FROM "
 DC.B "EVESHAM FOR 99 QUID COMPLETE WITH POWER SUPPLY AND ANY GAME "
 DC.B "OF YOUR CHOICE).   WITH MY LYNX I ORDERED GAUNTLET 3 AND "
 DC.B "RYGAR WARRIOR, HAS ANYONE GOT PAST LEVEL 9 ON RYGAR?     "
 DC.B "YEH THE TT RACES ARE ONLY 2 DAYS AWAY AND I'M GOING ON "
 DC.B "MY Z650, BE AT RAMSAY CORNER ON SATURDAY AT 12PM OR BE SQUARE. "
 DC.B "  I ACTUALLY DOUBT ANYBODY WILL READ THIS BEFORE I GET BACK "
 DC.B "'CAUSE I WON'T HAVE TIME TO SEND IT TO MARTIAN BEFORE I LEAVE "
 DC.B "PLUS HE KEEPS THEM FOR 3 OR 4 MONTHS BEFORE HE SENDS THEM OUT "
 DC.B "TO ALL THE PD LIBRARIES (WELL IT'S TRUE MARTIAN, YOU SLAG "
 DC.B "ME OFF FOR SAYING I HAD NO TIME BUT IT'S DIFFERENT NOW THAT "
 DC.B "YOU ARE WORKING - THINK ABOUT IT!).      BORIS ARE YOU STILL "
 DC.B "SNOGGING WITH LIZ?      GET THAT ST GOING NOW!      "
 DC.B "DOES ANYONE WANT ANOTHER ERIK PLANKTON DEMO?      YES, RIGHT "
 DC.B "I'LL WRITE ANOTH.....   ER, I'LL TELL HIM TO WRITE ANOTHER ONE (NEARLY "
 DC.B "LET THE CAT OUT OF THE BAG THERE!!!!).      WELL BROS AND SISTERS IT'S "
 DC.B "TIME TO WRAP THIS UP 'CAUSE THERE ARE MENUS TO CODE. I'VE WRITTEN "
 DC.B "MENUS UPTO 77 SO FAR BUT I'M WORKING ON A WICKED MENU "
 DC.B "THAT PLAYS A MOD FROM THE SCOOPEX 'MENTAL HANGOVER' DEMO FROM "
 DC.B "THE AMIGA BUT I'VE GOT TROUBLE GETTING THE BORDER CODE TO "
 DC.B "EXECUTE EXACTLY AT THE RIGHT TIME DUE TO THE TRACKER "
 DC.B "CODE BUT I'M SURE I CAN FIX IT.     OK, HERE IS THE END BYE! "
 DC.B "                                             "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	1plane.fnt
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

******* TOP SCROLL ******
upper_scroll_pointer
	dc.l	init_upper_text
init_upper_text
 dc.b "                                   "
 dc.b "                          "
upper_text
 dc.b "       PERSISTENCE OF VISION,      "
 DC.B "P.O. BOX 40,      THORNTON,      CLEVELEYS,      "
 DC.B "BLACKPOOL,      LANCS.      FY5 3PH              "
 DC.B "HELLO, THIS IS THE UPPER SCROLL FOR P.O.V. 74.    "
 dc.b "   THIS MENU WAS RE-CODED AS OZYMANDIAS WANTED A TOP "
 DC.B "SCROLLER 'CAUSE HE THINKS THEY LOOK NICE.      SEEING "
 DC.B "OZ IS SO KEEN ON SCROLLERS HE CAN TYPE SOME SCROLLTEXT... "
 DC.B " OVER TO YOU OZ........          "
 dc.b "POV TAKES NO BLAME FOR THE FOLLOWING ARTICLE......    "
 dc.b "RAZOR 'HARD AS SHIT' EDDIE'S GUIDE TO EATING OUT CHINESE "
 dc.b "STYLE.    WHICH CUISINE...   THERE ARE MANY "
 dc.b "DIFFERENT STYLES OF ORIENTAL CUISINE ... THE BEST KNOWN "
 dc.b "BEING PEKING STYLE OR CANTONESE STYLE. TO AVOID CONFUSION "
 dc.b "THE BEST THING TO DO IS LUMP THEM TOGETHER "
 dc.b "UNDER THE GENERAL HEADING OF 'CHINKY'.   WHEN SEATED IN "
 dc.b "THE RESTAURANT,THE FIRST THING TO DO IS HOLD UP THE FORK "
 dc.b "AND SPOON AND ADDRESS THE WAITER THUS..."
 dc.b " 'OI! MAO TSE-TUNG! GIVE US SOME COPSTICKS. I WISH TO SHOW "
 dc.b "OFF TO MY FRIENDS!'        USING CHOPSTICKS.....    "
 dc.b "THE FIRST THING TO REMEMBER IS THAT TWO CHOPSTICKS "
 dc.b "ARE QUITE DIFFERENT. ONE IS THE TOP ONE THE OTHER IS "
 dc.b "THE BOTTOM ONE. THEY ARE QUITE DIFFICULT TO TELL APART, "
 dc.b "BEING EXACTLY THE SAME SIZE AND SHAPE. BUGGER "
 dc.b "ME IF I KNOW THE DIFFERENCE.   FINALLY JUST BEFORE THE "
 dc.b "FOOD ARRIVES REMEMBER TO CALL THE WAITER, SAYING...   "
 dc.b "'OI! FLOO-DUNG! GIVE US ME FORK AND SPOON BACK!!'"
 dc.b "              WELL THAT WAS OZ!!!   OH 'ECK HERE HE COMES AGAIN.... "
 dc.b "               THE POV AGONY AUNT COLUMN.....      DEAR POV, I AM "
 dc.b "A PACKER OF DEMOS, BUT PLEASE EXPLAIN HOW TO CREATE SUCH "
 dc.b "NICE MENUS AND STUFF. I REALLY LIKE YOUR DISKS "
 dc.b "AND COLLECT THEM ALL. SIGNED   STEW.        DEAR STEW, "
 dc.b "SORRY YOU LAMER, YOU NEED TALENT. GO TO YOUR DOCTOR NOW! "
 DC.B "             I SPOKE TO OZ ABOUT THE TEXT AND HOW HE SLAGS "
 DC.B "EVERYONE OFF, HIS REPLY WAS 'WELL THEY ARE ALL LAME'.  I HAD "
 DC.B "A SHORT THINK AND HAD TO AGREE, IF YOU LOOK AROUND AT ALL THE "
 DC.B "OTHER DEMO PACKERS DISCS YOU WILL REALISE THAT P.O.V. HAVE "
 DC.B "EXCELLENT MENUS THAT ACTUALLY WORK - IF WE SAY IT RUNS IN "
 DC.B "HALF MEG THEN IT WILL - UNLIKE THE COMPETITION!         "
 dc.b "GET READY FOR THE WRAP AROUND......... GO! "
 dc.b $ff
	even
char_offset2	dc.w	0

******************* isr details *******
key	dc.w	0

old120	dc.l	0
old70	dc.l	0
old118	dc.l	0
save1	dc.b	0
save2	dc.b	0
save3	dc.b	0
save4	dc.b	0
save5	dc.b	0
save6	dc.b	0
save7	dc.b	0
save8	dc.b	0
	even

;*************************
tune:	incbin	ghouls.img
	even
pic	incbin	pov74.PI1
	even

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$ff
	even

filenames:
	dc.b	"IM.PRG",0,0,0,0,0,0,0,0,0,0
	dc.b	"RONNIE.PAK",0,0,0,0,0,0
	dc.b	"DMA4.PRG",0,0,0,0,0,0,0,0
	DC.B	"COPIER.POV",0,0,0,0,0,0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
menuend