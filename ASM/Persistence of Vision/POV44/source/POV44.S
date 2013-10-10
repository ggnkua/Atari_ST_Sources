****************
* P.O.V. 44    *
****************

	bsr	set_super
	clr.l	$24

wait_for_drive:
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
	move.b	$484,old484
	clr.b	$484

;Music from INNER CIRCLE intro
; Ripped by MAC SYS DATA
	move.l	#1,D0
	jsr	tune
	clr.l	$24
	bsr	set_palette
	bsr	set_for_border
	bsr	vsync
	bsr	show_pic
	bsr	vsync
	move.b	#0,$fffffc02.w
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$123,bor+2
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq	do_reset
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#5,d0		;4 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	lea	$ffff8240.w,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+

	move.l	(sp)+,d0
	cmp.b	#3,d0	;option 2
	bne.s	not_two
	move.l	d0,-(sp)
	move.w	#$777,$ffff825e.w
	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	$ffff825e.w
	move.l	(sp)+,d0

not_two
;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6
	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.w	(a6)+,(a0)

	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50:
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit:
	bsr	isr_off
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
scroll:	move.l	screen_base,a1
	add.w	#160*204+2,a1
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

show_pic:
	lea	position_table,a2
	move.w	#500/4-1,d0
.loop
	movem.l	d0/a0-a1,-(sp)
	bsr	v_sync
	bsr	print
	bsr	print
	bsr	print
	bsr	print
	movem.l	(sp)+,d0/a0-a1
	dbf	d0,.loop
	rts

print
	lea	pic+34,a0
	move.l	screen_base,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a2)+,d1
	move.b	(a2)+,d0
	mulu	#160*8,d0
	mulu	#8,d1
	add.w	d1,d0
	add.w	d0,a0
	add.w	d0,a1
	REPT	8
	move.w	(a0),(a1)
	move.w	2(a0),2(a1)
	move.w	4(a0),4(a1)
	move.w	6(a0),6(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
	rts


v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
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

set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off:
	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	bsr	tune+6
	clr.w	vsync_flag
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	98
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.l	#lower_border,$120.w
	rte

lower_border:
	clr.b	$fffffa1b.w	;DI all other interrupts
bor	move.w	#$000,$ffff8240.w
	lea	colours,a0
	move.w	#30-1,d0
.loop	move.w	(a0)+,$ffff8244.w
	REPT	121
	nop
	ENDR
	dbf	d0,.loop
	bclr	#0,$fffffa0f.w
	rte


********
* Data *
********
	SECTION DATA
colours
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017
	dc.w	$0

screen_base:	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.b	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 DC.B "                    DOES YOU DO OR DOES YOU DON'T COLLECT P.O.V.???????      "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 44.          "
 dc.b "YES, IT'S DISC 44 AND WE ARE STILL GOING!   AS USUAL I SHALL "
 dc.b "KICK OFF WITH THE CREDITS.... ALL CODE BY MAC SYS DATA WITH "
 dc.b "GRAFIX BY OZ AND FONT BY AUTOMATION.          THE MUSIC "
 DC.B "IS BY COUNT ZERO FROM ELECTRONIC IMAGES AND WAS RIPPED "
 DC.B "FROM THE 'INNER CIRCLE DECADE DEMO' (SCREEN ONE).       "
 dc.b "I'VE JUST RECEIVED A DEMO WRITTEN BY BORIS (OF P.O.V.) AND "
 DC.B "IT IS AMAZING.... IT'S A SAMPLED SOUND DEMO THAT PLAYS "
 DC.B "THE SAMPLE AT 15KHZ. THE AMAZING PART IS THAT THE DEMO PLAYS "
 DC.B "FOR TWO AND A HALF MINUTES AND THEN REPEATS! YES, I SAID "
 DC.B "TWO AND A HALF MINUTES!  THE SECRET OF IT'S LENGTH IS THE WAY THE DATA "
 DC.B "IS STORED ON THE DISC, I THINK BORIS SAID THAT THERE WAS 1.8 MEG "
 DC.B "OF DATA ON THE DISC AND IT IS HELD IN A PACKED FORM. THE PACKER "
 DC.B "MANAGES A 50 PERCENT COMPRESSION ON ALL SAMPLES AND WAS WRITTEN "
 DC.B "BY BORIS AND HIS MATES AT MANCHESTER UNIVERSITY. THE VERSION "
 DC.B "I HAVE IS FOR TESTING AND NOT A FINAL COPY BUT A IT SHOULD BE COMPLETED "
 DC.B "AND AVAILABLE SOON.        "
 DC.B "AND NOW FOR SOMETHING COMPLETELY DIFFERENT: IF ANYONE COLLECTS AVS "
 DC.B "DEMOS COULD THEY PLEASE HAVE A LOOK TO SEE IF THERE ARE ANY THAT "
 DC.B "FIT INTO ABOUT 8 FRAMES SO I CAN DO A CONVERSION - IT "
 DC.B "IS VERY EASY AND CAN BE DONE IN ABOUT 20 MINUTES. I WANT TO USE THEM 'CAUSE THEY CAN BE PACKED "
 DC.B "TO FILL UP THE DISCS FOR THE 1 MEG DEMOS.        WE HOPE "
 DC.B "TO HAVE A CONTACT ADDRESS SOON (WE ARE WAITING FOR THE POST OFFICE "
 DC.B "TO GIVE US A P.O. BOX) SO YOU MAY SEND DEMOS DIRECTLY TO US FOR A "
 DC.B "SPEEDIER SERVICE!         "
 DC.B "WELL HERE IS THE MOMENT YOU'VE ALL BEEN WAITING FOR --- THE GREETINGS!   " 
 DC.B "HELLO TO      DIRTY TRICKS BRIGADE (WOT NO DISCS?),   AUTOMATION,   "
 DC.B "INNER CIRCLE,   REPLICANTS,   THE LOST BOYS,   SKUNK,   DR.SYNE,   "
 DC.B "GEORGE,   POMPEY PIRATES,   THE MEDWAY BOYS,   SEWER SOFTWARE   AND   "
 DC.B "MARTIAN.       "
 DC.B "IF I DIDN'T MENTION YOU ON THE GREETINGS AND YOU KNOW US THEN "
 DC.B "YOU MUST NOT HAVE BEEN IN CONTACT FOR SOME TIME.  I HAVE GREETED "
 DC.B "LOTS OF PEOPLE WHO HAVE NEVER HEARD OF US BEFORE AND MAY NEVER "
 DC.B "AGAIN BUT SO WHAT - I RECEIVE THEIR WORK!       "
 DC.B "I FIND IT STRANGE THAT WE HAVE BEEN AROUND FOR SUCH A LONG "
 DC.B "TIME AND BASICALLY NOBODY KNOWS US.  I HAVE HEARD OF REPORTS "
 DC.B "THAT PEOPLE ARE STILL BUYING MICROMIX 1 AND 2 AND MEGABANG 1 AND 2 ON "
 DC.B "SINGLE SIDED DISCS WHEN THEY ARE READY ON P.O.V. DISCS IN THE "
 DC.B "SAME PD CATALOGUE.    THE OBJECT OF OUR ACTIVITES IS TO BRING "
 DC.B "YOU AS MANY DEMOS ON AS LITTLE DISCS AS WE CAN. OUR WORK HAS "
 DC.B "COVERED THE TOP NAMES IN DEMOS TO THE LITTLE SCUM BAGS "
 DC.B "WHO WRITE CRAPPY SAMPLED SOUND DEMOS USING MASTERSOUND AND GFA "
 DC.B "BASIC CRAP.          "
 DC.B "WHAT OF OUR COMPETITION?       WELL AS FAR AS I KNOW THERE ARE "
 DC.B "THREE OTHER GROUPS DOING COMPACTS, THEY ARE...    STEW,   "
 DC.B "OVERLANDERS   AND   RIPPED OFF.    IN THE BEGINGING THERE WAS "
 DC.B "P.O.V. AND THEN WE HEARD ABOUT STEW, TIME PASSED AND WE SAW "
 DC.B "THE OVERLANDERS LATE ENTRY AND FINALLY WE HAVE BEEN INFORMED "
 DC.B "THAT 'RIPPED OFF' IS DOING THE SAME AS US BUT I'M NOT SURE "
 DC.B "IF HE IS PACKING THE DEMOS AS WELL AS BUILDING A DEMO COMPILATION.  "
 DC.B "            WHAT DO YOU THINK OF THE SCROLL SPEED?      IS IT TOO FAST?      "
 DC.B "IF SO THEN TOUGH 'CAUSE I 'AINT SLOWING IT DOWN!                "
 DC.B "HEY I'M BACK....  I JUST GOT A PHONE CALL FROM AN OLD GIRLFRIEND "
 DC.B "(WE FINISHED 3 YEARS AGO!!) AND I'M OVER THE MOON - YEH!  "
 DC.B "I LOVE YOU RACHEL!     "
 DC.B "       TODAY I PICKED UP SOME MORE "
 DC.B "AMIGA DISCS FULL OF SOUNDTRACKER MODS AND TRACKER RIPPERS SO "
 DC.B "I'LL BE WORKING ON THE AMIGA FOR A DAY OR TWO STEALING THE MODS "
 DC.B "FOR THE 'P.O.V. + DEMO CLUB' TRACKER DISCS.  I HAVE ALSO RECEIVED "
 DC.B "4 MOD DISCS FOR THE ST-CONNEXIONS TRACKER BUT I WON'T KNOW "
 DC.B "IF TO RELEASE THEM AS P.O.V. DISCS OR NOT, I MAY MAKE THEM A "
 DC.B "P.O.V. RELEASE BUT NOT IN THE NUMBER SEQUENCE.       "
 DC.B "YOU SHOULD SEE A COUPLE OF EXTRA P.O.V. DISCS IN THE PD CATALOGUES "
 DC.B "BECAUSE BORIS AND I ARE BOTH WORKING ON SOME DEMOS OF OUR OWN. "
 DC.B "   YOU MAY NOT RECOGNIZE MY WORK BECAUSE I DON'T USE THE SAME "
 DC.B "HANDLE BUT IF YOU HACKERS DEPACK THE PROGRAM YOU WILL RECOGNIZE "
 DC.B "THE CODE.... I USE THE SAME START-UP SEQUENCE AS MY MENUS."
 DC.B "        IF ANY OF YOU WANT TO START MACHINE CODE "
 DC.B "THEN BUY (YES BUY) GENST 2 'CAUSE IT'S BRILLIANT - I THINK "
 DC.B "IT'S ABOUT TIME I BOUGHT A COPY!   ONE BUG I'VE FOUND IS THAT "
 DC.B "IT DOESN'T WORK CORRECTLY ON MY 4 MEG STE WITH MY THIRD COAST "
 DC.B "HARD DISC, THE BUG IS WITHIN GENST AND SHOWS ITSELF UP WHEN YOU "
 DC.B "TRY TO ASSEMBLE TO DISC - IT ASSEMBLES OKAY BUT IT SAVES THE "
 DC.B "FILE AS 'NONAME.PRG' OR 'TWO OVER SCORES.PRG' (THIS FONT HAS "
 DC.B "NO OVERSCORE!).   IF YOU START CODING AND GET STUCK, I AM "
 DC.B "WILLING TO HELP SO OUR P.O. BOX WILL ALSO BE THE CONTACT ADDRESS "
 DC.B "FOR PROGRAMMING HELP THAT IS IF WE GET IT GOING!    "
 DC.B "RIGHT, I THINK I'VE WAFFLED ON FOR FAR TOO SERIOUSLY LONG BY HALF "
 DC.B "SO IT'S TIME YOU PRESSED A KEY AND LOADED A DEMO   OR   PRESS "
 DC.B "ALTERNATE-CONTROL-DELETE TO RESET YOUR ST.     "
 DC.B "     BYE... "
 DC.B "                                     "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	"1plane.fnt"
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even
scroll_colour
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$100,$200,$300,$400,$500,$600,$700

******* show pic data *********
position_table
	incbin	fill.dat
;*************************
tune:	incbin	demo1.img
	even
pic	incbin	pov44.PI1
	even

text	dc.b	27,'E'
	dc.b	27,'Y',32+10,32+3,"To control the blob thingy use your"
	dc.b	27,'Y',32+11,32+16,"joystick."
	dc.b	27,'Y',32+13,32+2,"NOTE: One screen is 1 meg only, it's"
	dc.b	27,'Y',32+14,32+2,"      the screen on the bottom right."
	dc.b	27,'Y',32+17,32+3,"Press a key to load the REFLEX demo"
	dc.b	0
	even
filenames:
	dc.b	"SECRET.MSD",0,0,0,0
	dc.b	"REFLEX.MSD",0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
