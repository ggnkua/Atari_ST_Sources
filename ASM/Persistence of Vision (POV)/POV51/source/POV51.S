****************
* P.O.V. 51    *
****************
;	OPT	o+
	bsr	set_super
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
	move.b	$484.w,old484
	clr.b	$484.w

;************************************************************************
;*                       INNER CIRCLE INTRO 2                           *
;*                       --------------------                           *
;* Stolen by: MAC SYS DATA of P.O.V. 26/11/90 21:00                     *
;*      From: INNER CIRCLE 'DECADE DEMO'                                *
;* Include files:-                                                      *
;*                 INNER2.IMG into TUNE                                 *
;************************************************************************
;* Written by COUNT ZERO
	moveq.l	#1,D0
	jsr	tune

	bsr	set_palette
	bsr	save_isr
	bsr	vsync
	bsr	show_pic
	bsr	show_logo
	bsr	vsync
	bsr	flush
	bsr	animate_pov
	bra	hertz50
main_loop:
	bsr	flush
	bsr	vsync
;	move.w	#$070,$ffff8240.w

	bsr	clear_pov
	bsr	animate_pov

;	move.w	#$700,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	key,d0
	beq.s	main_loop

	cmp.b	#01,d0		;escape
	beq	exit

	tst.w	zero_counter
	beq.s	car
	subq.w	#1,zero_counter
	bra.s	check_keys
car
	cmp.b	#$b,d0		;0 key
	beq	zero
	cmp.b	#$70,d0
	beq	zero

check_keys
	cmp.b	#$53,d0
	beq	do_reset

	cmp.b	#$6d,d0		;keypad 1
	beq.s	keypad
	cmp.b	#%01101110,d0	;keypad 2
	beq.s	keypad
	cmp.b	#%01101111,d0	;keypad 3
	beq.s	keypad
	cmp.b	#%01101010,d0	;keypad 4
	bne.s	keyboard
	addq.b	#6,d0
keypad	sub.b	#$6b,d0
keyboard
	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#6,d0		;5 key
	bge	main_loop	

	bsr	flush
	move.l	d0,-(sp)
	bsr	reset_isr
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

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	subq.b	#2,d0
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
hz50:	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4.w,a0
	jmp	(a0)

zero	tst.w	zero_counter
	bne	car
	eor.w	#$ffff,hertz_switch
	tst.w	hertz_switch
	beq	hertz50
	lea	hz+(16*8),a1
	move.l	screen_base,a0
	add.w	#(160*10),a0
	moveq	#0,d0
	REPT	16
	move.l	d0,(a0)
	move.l	(a1)+,152(a0)
	move.l	d0,4(a0)
	move.l	(a1)+,156(a0)
	add.w	#160,a0
	ENDR
	move.w	#10,zero_counter
	bra	main_loop
hertz50	lea	hz,a1
	move.l	screen_base,a0
	add.w	#(160*10),a0
	REPT	16
	clr.l	152(a0)
	move.l	(a1)+,(a0)
	clr.l	156(a0)
	move.l	(a1)+,4(a0)
	add.w	#160,a0
	ENDR
	move.w	#10,zero_counter
	bra	main_loop

zero_counter:	dc.w	0
exit:
	bsr	reset_isr
	bsr	flush
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

***************************************************************
*                         Subroutines                         *
***************************************************************
animate_pov
	move.l	present_queue,a0
	move.w	table_offset,d0
	add.w	d0,a0
	cmp.b	#$ff,(a0)
	bne.s	.no_reset

	clr.w	table_offset
	move.w	table_number,d0
	lsl.w	#2,d0	;*4

	lea	sine_queue,a1
	add.w	d0,a1
	cmp.l	#-1,(a1)
	bne.s	.no_queue_reset

	lea	sine_queue,a1
	clr.w	table_number
.no_queue_reset
	move.l	(a1),a0
	move.l	a0,present_queue

	addq.w	#1,table_number
	move.l	a0,present_queue
.no_reset
	moveq	#0,d0
	move.b	(a0),d0

;mulu d0 by 160
	lsl.w	#5,d0
	move.w	d0,d1
	lsl.w	#2,d0
	add.w	d1,d0

	add.w	#40,d0
	move.l	d0,last_p_pos
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pov,a0		;letter P
	lea	1920(a0),a2	;masks
	bsr.s	print_letter

	move.l	last_p_pos,d0
	add.w	#32,d0
	move.l	d0,last_o_pos
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pov+640,a0	;letter O
	lea	1920(a0),a2	;masks
	bsr.s	print_letter

	move.l	last_o_pos,d0
	add.w	#32,d0
	move.l	d0,last_v_pos
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pov+1280,a0	;letter V
	lea	1920(a0),a2
	bsr.s	print_letter
	addq.w	#1,table_offset
	rts

print_letter
	REPT	40
	move.l	(a1),d1
	move.l	4(a1),d2
	and.l	(a2)+,d1
	and.l	(a2)+,d2
	or.l	(a0)+,d1
	or.l	(a0)+,d2
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	(a1),d1
	move.l	4(a1),d2
	and.l	(a2)+,d1
	and.l	(a2)+,d2
	or.l	(a0)+,d1
	or.l	(a0)+,d2
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	lea	144(a1),a1
	ENDR
	rts

clear_pov
	move.l	screen_base,a1
	move.l	last_p_pos,d0
	add.w	d0,a1
	lea	pic+34-(160*30),a0	;correction for top border
	add.w	d0,a0
	bsr.s	.clear

	move.l	screen_base,a1
	move.l	last_o_pos,d0
	add.w	d0,a1
	lea	pic+34-(160*30),a0	;correction for top border
	add.w	d0,a0
	bsr.s	.clear

	move.l	screen_base,a1
	move.l	last_v_pos,d0
	add.w	d0,a1
	lea	pic+34-(160*30),a0	;correction for top border
	add.w	d0,a0
	bsr.s	.clear
	rts

.clear	REPT	40
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.l	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.l	28(a0),28(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	rts


scroll:	move.l	screen_base,a1
	add.l	#160*234,a1
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
	mulu	#32*4*4,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#32*4,d0	;character depth * 4 (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	32
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
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
	move.l	#coderte,$24.w
	rts

coderte	rte

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
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
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	move.l	screen_base,a1
	add.w	#30*160,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
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
	move.w	#30,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

flush	btst.b	#0,$FFFC00	;flush keyboard
	beq.s	flush2
	move.b	$FFFC02,d0
	bra.s	flush
flush2	rts

show_logo
	lea	logo,a1
	move.l	screen_base,a0
	add.w	#10*160,a0
	move.w	#16-1,d0
OFF	set 0
.loop
	REPT	20
	move.l	(a1)+,OFF(a0)
OFF	set OFF+4
	move.l	(a1)+,OFF(a0)
OFF	set OFF+4
	ENDR
	add.w	#160,a0
	dbf	d0,.loop
	rts

*********
* ISRs  *
*********
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
	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8244.w
	move.l	pic+10,$ffff8248.w
	move.l	pic+14,$ffff824c.w
	move.l	pic+18,$ffff8250.w
	move.l	pic+22,$ffff8254.w
	move.l	pic+26,$ffff8258.w
	move.l	pic+30,$ffff825c.w
	bclr	#0,$fffffa0f.w
	clr.b	$fffffa1b.w
	move.l	(sp)+,d0
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
	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.b	#$e4,$fffffa21.w
	move.b	#8,$fffffa1b.w
	jsr	tune+6
	rte

new118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	bclr	#6,$fffffa11.w
	rte

********
* Data *
********
	SECTION DATA
screen_base:	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
key	dc.w	0

old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    "
 dc.b "WELCOME TO PERSISTENCE OF VISION PACKED DEMO DISC 51.       "
 dc.b "CODING AND MUSIC RIPPING BY MAC SYS DATA, GRAFIX BY IAN C. (OF AUTOMATION - TA!), "
 dc.b "FONT BY MAC SYS DATA "
 dc.b "AND THE MUSIC IS BY COUNT ZERO, RIPPED "
 dc.b "FROM THE INNER CIRCLE DECADE DEMO (INTRO 2).       "
 dc.b "AT LAST I'VE FINISHED IT - I'VE SPENT 3 HOURS TRYING "
 DC.B "TO FIND A BUG IN THE BOUNCING P.O.V. ROUTINE BUT AS YOU CAN "
 DC.B "SEE, I FOUND IT!      TODAYS DATE IS 26:12:90 AND I SPENT "
 DC.B "ALL CHRISTMAS DAY PACKING DEMOS.    I MUST SEND MY THANKS TO "
 dc.b "MARTIAN FOR ALL THE RECENT ORIGINALS FROM WHICH I HAVE PACKED 18 "
 DC.B "DEMOS.   IF IT WASN'T FOR THE FOLLOWING SUPPLIERS P.O.V. WOULD "
 DC.B "BE ON DISC 15....... THE DEMO CLUB (OFFICIAL DISTRIBUTORS OF P.O.V. DISCS),   "
 DC.B "GEORGE S. (PLEASE GET A HANDLE),   MARTIAN (AGAIN),   SOUTHWEST SOFTWARE LIBRARY,   "
 DC.B "LOST BOYS PD LIBRARY   AND   DR. SYNE.    "
 DC.B "I HAVE JUST RECEIVED LIFE'S A BITCH DEMO BY TLB, "
 DC.B "I ASKED 5 DIFFERENT SOURCES FOR IT AND EVENTUALLY "
 DC.B "MARTIAN AQUIRED IT FROM THE SOUTHWEST SOFTWARE LIBRARY - TA!   "
 DC.B "   ONE OF OUR PAST MEMBERS (DR.SYNE) HAS NOW SENT OFF A COUPLE "
 DC.B "OF P.O.V. DISCS TO 'PAGE 6' SO WE WILL HAVE A BETTER "
 DC.B "CIRCULATION THAN ANY OTHER DEMO PACKING GROUP. YOU CAN GET "
 DC.B "P.O.V. DISCS FROM THE FOLLOWING SOURCES..... "
 DC.B "THE DEMO CLUB,     "
 DC.B "SOUTHWEST SOFTWARE LIBRARY,     "
 DC.B "THE LOST BOYS PD LIBRARY,     "
 DC.B "WEST LONDON PD,     "
 DC.B "RIVERDENE PD,     "
 DC.B "PAGE 6     "
 DC.B "AND      THE BLACKPOOL COMPUTER CLUB.      "
 DC.B "IF YOU RUN A PD LIBRARY AND WOULD LIKE TO GET YOUR HANDS ON "
 DC.B "THE P.O.V. COLLECTION THEN SEND TO 'THE DEMO CLUB' WITH "
 DC.B "A BEGGING LETTER    OR    WRITE TO.... "
 DC.B "DR.SYNE,     4 WOODLAND GROVE,     BLACKPOOL,     LANCS.,     "
 DC.B "FY3 9ET.       IF YOU HAVE SOME DEMOS THAT WE HAVE NOT PACKED "
 DC.B "THEN SEND THEM TO THE SAME ADDRESS AND WE WILL SEND BACK THE "
 DC.B "LATEST P.O.V. RELEASE.     I HAVE THE FOLLOWING DEMOS READY AND "
 DC.B "WAITING FOR A MENU.... "
 DC.B "BITSCAN DEMO,     ZOOLOOK,     VIC DEMO 1 (CRAP),     "
 DC.B "PIXEL TWINS 7 (HERE THE DRUMMER GET WICKED),     A.B.C. 8,     "
 DC.B "BANDAID 2,     WHEN HARRY MET SALLY,     THUNDERBIRDS SOUNDTRACK,     "
 DC.B "THUNDERBIRDS SPECIAL EDITION DEMO,     30 YEARS IN THE BATHROOM,     "
 DC.B "PREDATOR,     JUNGLE STE,     WAR OF THE WORLDS,     PRO-SPRITE ENGINE,     "
 DC.B "MONTH PYTHON'S HOLY GRAIL DEMO,     THE YOUNG ONES,     "
 DC.B "ALICE COOPER 'TRASH',     ALICE COOPER 'POISON',     "
 DC.B "U2 (SILVER AND GOLD) - CRAP!,     LOVE IN AN ELEVATOR,     "
 DC.B "NOD DEMO 3 (KIKKI DEE),     CALYPSO 3 (JEAN MICHEL-JARRE)     AND     "
 DC.B "THE FINGERBOBS CES '90 REPORT THINGY.   THAT WAS 23 DEMOS READY "
 DC.B "AND WAITING BUT I HAVE ALSO PACKED THE DDC DEMO BUT PART OF IT "
 DC.B "RUNS IN MONO AND I AIN'T GOT A MONO MONITOR!    I HAD "
 DC.B "PACKED THE INSPECTOR GADGET DEMO BUT WHEN I TESTED IT RECENTLY THE DAMN "
 DC.B "THING COCKED IN SO I'LL HAVE TO DO IT AGAIN AND IT'S A BITCH TO PACK. "
 DC.B "HEY SKUNK - I'M STRUGGLING WITH YOUR PRISONER DEMO, IT MAY BE "
 DC.B "ANOTHER RECODE IF I CAN'T FIX IT SOON!!!!!      "
 dc.b "SINCE I'VE PACKED ALL THE DEMOS I CAN FROM THE NEW STUFF "
 DC.B "I WILL NOW HAVE TO DIG AROUND IN THE SMALL PILE NEXT TO MY "
 DC.B "HARD DISC FOR SOMETHING ELSE TO HAVE A GO AT.      "
 dc.b "                        YO - I JUST POPPED OUT TO SEE GEORGE S. "
 DC.B "AND HE HAD 10 DISCS FULL OF DEMOS THAT I HADN'T GOT!!! THE DISCS "
 DC.B "CAME FROM RIVERDENE PDL SO I'LL PACK THE NEW DEMOS A.S.A.P AND "
 DC.B "GET SOME SENT BACK TO RIVERDENE!      RIGHT, HOLD ON I'LL START "
 DC.B "THE STFM PACKING.......              OKAY - IT'S PACKING "
 DC.B "THE DEF LEPPARD 'ANIMAL' DEMO.        "
 DC.B "ALY CAME TO MY HOUSE THE OTHER DAY WITH A LARGE SELECTION OF "
 DC.B "CD'S AND 7 INCH SINGLES. HE ASKED IF HE COULD RECORD THEM ON MY "
 DC.B "WHIZZO HI-FI SO I SAID YEH BUT DON'T TURN IT UP.  WELL HE LEFT "
 DC.B "ALL THE CD'S AND THINGS AT MY HOUSE AND THE OTHER NIGHT "
 DC.B "I LOOKED AT MY CD'S AND THOUGHT WHAT A LOAD OF SHIT, SO I PLAYED "
 DC.B "ONE OF THE CD'S ALY HAD BROUGHT ROUND.    THE CD I PUT ON WAS 'FLOODLAND' "
 DC.B "BY SISTERS OF MERCY, IT IS BRILLIANT!!!!! GO OUT AND BUY IT "
 DC.B "AT ONCE.     THE OTHER EXCELLENT GROUP ABOUT IS AN INDIE "
 DC.B "BAND CALLED CARTER (THE UNSTOPABLE SEX MACHINE), MY BROTHER (DAZ) IS A ROADIE FOR THEM (HE "
 DC.B "THROWS PEOPLE OFF THE STAGE!). ANYWAY DAZ HAS CARTER'S NEW "
 DC.B "LP ON TAPE (IT DOESN'T COME OUT UNTIL FEBRUARY) AND HE "
 DC.B "PLAYED A LITTLE ON HIS STEREO, I THEN STOLE THE TAPE AND "
 DC.B "THREW IT INTO MY TECHNICS SYSTEM AND WAPPED UP THE VOLUME - YEH!    "
 DC.B "TO CUT A LONG STORY SHORT... IT WAS AMAZING AND I SUGGEST YOU "
 DC.B "BUY THE NEW LP AS SOON AS IT COMES OUT.  IF YOU LIKE "
 DC.B "IRON MAIDEN AND MUSIC THAT IS SLIGHTLY THRASH METAL THEN "
 DC.B "THIS LP WILL FIT INTO YOUR COLLECTION PERFECTLY, IT IS "
 DC.B "ONE OF THOSE LP'S THAT HITS YOU IN THE FACE THE FIRST TIME YOU "
 DC.B "HEAR IT AND DOESN'T JUST 'GROW' ON YOU. "
 DC.B "       RIGHT ENOUGH OF THIS WAFFLE 'COS IT'S "
 DC.B "TIME FOR THE GREETINGS - HELLO TO... "
 DC.B "TCB,   INNER CIRCLE (ESP COUNT ZERO),   TLB,   THE REPLICANTS,   "
 DC.B "DR. SYNE,   AUTOMATION (PLEASE FIX MENUS 320 ONWARDS TO WORK ON "
 DC.B "THE STE),   THE POMPEY PIRATES,   MEDWAY BOYS,   SEWER SOFTWARE,   "
 DC.B "OVERLANDERS,   RIPPED OFF (WHO?)   AND   OZ (WHERE ARE YOU???).   "
 DC.B "  RIGHT THAT CONCLUDES THE GREETINGS AND THE SCROLLTEXT SO "
 DC.B "UNTIL NEXT TIME - BYE... "
 DC.B "                                          "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	32*4*4,0
	incbin	4plane.fnt
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

tune:	incbin	inner2.img
	even
pic	incbin	pov51.PI1
	even
logo	incbin	logo.dat
	even

*************** POV data ***************
last_p_pos	dc.l	0
last_o_pos	dc.l	0
last_v_pos	dc.l	0


present_queue	dc.l	table0
table_offset	dc.w	0
table_number	dc.w	0
sine_queue
	dc.l	table1
	dc.l	table2
	dc.l	table4
	dc.l	table3
	dc.l	table5
	dc.l	table6
	dc.l	table4
	dc.l	table3
	dc.l	table5
	dc.l	table6
	dc.l	table7
	dc.l	table6
	dc.l	table1
	dc.l	table7
	dc.l	table7
	dc.l	table7
	dc.l	table7
	dc.l	-1

table0	dcb.b	100,176
	dcb.b	50,177
	dcb.b	40,178
	dcb.b	30,179
	dcb.b	20,180
	dcb.b	10,181
	dcb.b	9,182
	dcb.b	8,183
	dcb.b	7,184
	dcb.b	6,185
	dcb.b	5,186
	dcb.b	4,187
	dcb.b	3,188
	dcb.b	2,189

table1	incbin	xtable.dat
table2	incbin	xtable2.dat
table3	incbin	xtable3.dat
table4	incbin	xtable4.dat
table5	incbin	xtable5.dat
table6	incbin	xtable6.dat
table7	incbin	xtable7.dat
	even
pov	incbin	pov.dat
hz	incbin	hz.dat
filenames:
	dc.b	"FBG.DEM",0,0,0,0,0,0,0
	dc.b	"ROBOCOP2.DEM",0,0
	dc.b	"SPOONS.DEM",0,0,0,0
	dc.b	"51COPIER.POV",0
	even

	SECTION BSS
old_pal:	ds.b	32
old70:	ds.l	1
old120:	ds.l	1
old118:	ds.l	1
save1	ds.b	1
save2	ds.b	1
save3	ds.b	1
save4	ds.b	1
save5	ds.b	1
save6	ds.b	1
save7	ds.b	1
save8	ds.b	1
	even
	ds.b	256
screen:	ds.b	48000
