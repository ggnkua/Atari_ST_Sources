****************
* P.O.V. 48    *
****************
	bra	code
 dc.b 	"Hey thief what do you think you are doing in my code?  "
 dc.b	"If you want the tune then bloody hack it out from the "
 dc.b	"Decade demo like I did.       "
 dc.b	"WARNING:  If you run this code it will crash your hard disc!!! "
code
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
	move.b	$484,old484
	clr.b	$484

;************************************************************************
;*                  INNER CIRCLE PIPEWORK DEMO TUNE                     *
;*                  -------------------------------                     *
;* Stolen by: MAC SYS DATA of P.O.V. 26/11/90 23:16                     *
;*      From: INNER CIRCLE 'DECADE DEMO'                                *
;* Include files:-                                                      *
;*                 PIPE.IMG into TUNE                                  *
;************************************************************************
;* Written by COUNT ZERO
	move.l	#1,D0
	jsr	tune

	bsr	set_palette
	bsr	set_for_border
	bsr	vsync
	bsr	show_pic
	bsr	vsync
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	do_vu
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	tst.w	zero_counter
	beq.s	car
	sub.w	#1,zero_counter
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
	add.b	#6,d0
keypad	sub.b	#$6b,d0

keyboard
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#6,d0		;5 key
	bge	main_loop	

	bsr	flush
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

zero	tst.w	zero_counter
	bne	car
	eor.w	#$023,bor+2
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	move.b	#0,$fffffc02.w
	bra	main_loop
zero_counter:	dc.w	0
exit:
	bsr	isr_off
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

***************
* Subroutines *
***************
do_vu	move.l	screen_base,a1
	add.w	#160*32+4,a1
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr	draw_vu

	add.w	#16,a1
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr	draw_vu

	add.w	#16,a1
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr	draw_vu

	rts
draw_vu
	cmp.b	#16,d0
	bge.s	.exitvu
	tst.b	d0
	bne.s	.not_blank
	lea	blank,a0
	bra.s	.main
.exitvu	rts
.not_blank
	and.w	#$ff,d0
	mulu	#52*4,d0
	lea	vu_blocks,a0
	add.w	d0,a0
.main
	move.w	#0,d2
	move.w	#160*102,d3
	move.w	#52-1,d0
.loop
	move.w	(a0),(a1,d2.w)
	move.w	(a0)+,(a1,d3.w)

	move.w	(a0),8(a1,d2.w)
	move.w	(a0)+,8(a1,d3.w)

	add.w	#160,d2
	sub.w	#160,d3
	dbf	d0,.loop
	rts






scroll:	move.l	screen_base,a1
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
	mulu	#32*4*4,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#32*4,d0	;character depth * 4 (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	32
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+2
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+154
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

	clr.w	$26
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
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	move.l	screen_base,a1
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

flush	btst.b	#0,$FFFC00	;flush keyboard
	beq.s	flush2
	move.b	$FFFC02,d0
	bra.s	flush
flush2	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync
	jsr	tune+6
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
	movem.l	fontpal+2,d1-d7
	movem.l	d1-d7,$ffff8242.w
	bclr	#0,$fffa0f
	rte


********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$710,$020,$267,$750,$730,$760,$225
	dc.w	$050,$222,$333,$444,$555,$666,$111,$777

screen_base:	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
old118:	dc.l	0
olda07:	dc.b	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    "
 DC.B "PERSISTENCE OF VISION PACKED DEMO DISC 48.         CHECKING FOR A VIRUS..."
 DC.B ".............................................................."
 DC.B "   WARNING YOU HAVE THE P.O.V. MENU VIRUS LOOSE IN YOUR SYSTEM.   "
 DC.B "PLEASE TURN YOUR ST OFF NOW...               "
 DC.B "                                         "
 DC.B "HA-HA-HA-HA I WONDER HOW MANY LAMERS HAVE JUST TURNED OFF.  "
 DC.B "   BLOODY HELL THERE ARE SOME THICK SODS AROUND, I'VE JUST "
 DC.B "BEEN READING SOME OF THE LETTERS THAT HAVE BEEN SEND TO ST-FORMAT AND "
 DC.B "ST-USER, I CAN'T BELEIVE THAT PEOPLE CAN BE SO THICK.     "
 DC.B "   WELL I SUPPOSE I'D BETTER GET ON WITH THIS TEXT.....     "
 DC.B "BUT FIRST THE CREDITS - "
 dc.b "CODING AND FONT BY MAC SYS DATA WITH GRAFIX BY OZ.  THE MUSIC "
 DC.B "IS BY THE MEGA WICKED COUNT ZERO. I (MAC SYS DATA) RIPPED IT "
 DC.B "FROM THE PIPE SCREEN ON THE 'INNER CIRCLE DECADE DEMO'. "
 dc.b "     THE NAFF VU METERS WERE A LATE EXTRA TO THIS MENU AS "
 DC.B "I REALISED THAT I HAD LOADS OF DISC SPACE (UNLIKE THE PREVIOUS "
 dc.b "MENUS).  "
 DC.B "    IF YOU ARE A KEEN "
 DC.B "P.O.V. FAN YOU SHOULD REMEMBER WHAT COMPUTERS I HAVE "
 DC.B "CRAMMED INTO MY BEDROOM WELL, I'VE GOT ANOTHER! (NO NOT ANOTHER BEDROOM "
 DC.B ", ANOTHET COMPUTER MR. THICKY).    I'VE "
 DC.B "BOUGHT A SECONDHAND 520STFM FOR TESTING P.O.V. DISCS, MY ROOM NOW "
 DC.B "LOOK LIKE A COMPUTER SHOP.     HERE IS A LIST OF WHAT I HAVE "
 DC.B "SET UP IN MY ROOM.....   "
 DC.B "A 4 MEG STE,   CM8833 MONITOR,   45 MEG HARD DISC,   1040 STFM,   "
 DC.B "SECOND DISC DRIVE FOR STFM,   NAFF HITACHI TV,   520 STFM,   (SAME NAFF TV),   "
 DC.B "1 MEG AMIGA,   SECOND DRIVE FOR AMIGA,   (SAME NAFF TV),   STAR LC10,   "
 DC.B "WS2000 MODEM (UNUSED)   AND   A VIDEO DIGITIZER FOR THE AMIGA WITH "
 DC.B "SECURITY CAMERA!      AS YOU CAN SEE I HAVE A LOT OF EQUIPMENT.     TO "
 DC.B "GO WITH THE COMPUTERS I HAVE ABOUT 1200 DISCS FULL OF GAMES AND DEMOS WITH "
 DC.B "A FURTHER 400 BLANK SONY DISCS IN BOXES WAITING TO BE USED (OR SOLD).  "
 DC.B "OH YEAH, I NEARLY FORGOT TO MENTION THE LARGE STEREO SYSTEM "
 DC.B "LURKING NEAR THE DOOR.   WHAT ELSE IS THERE....... OH YEAH, I'VE ALSO GOT A CASIO CZ-230-S SOMEWHERE "
 DC.B "AROUND HERE!          LOOKING ABOUT ME ON THE FLOOR I CAN SEE 3 DISC "
 DC.B "BOXES,   450 BLANK SONY DISCS,   MY MOTOR-CYCLE HELMET,   A PAIR "
 DC.B "OF JEANS   AND   WHAT LOOKS LIKE LAST NIGHT HACKING NOTES!   "
 DC.B "     ONE PROBLEM WITH HACKING IS THAT I PRINT ROUTINES OUT AND FORGET "
 DC.B "TO LABEL THEM UP SO SOMETIME IN THE FUTURE I WILL PICK THEM UP "
 DC.B "AND WONDER WHAT THE HELL IT'S FROM.      "
 DC.B "      HEY HAVE I DONE THE GREETINGS YET....      OKAY HERE THEY ARE "
 DC.B "THEN, HELLO TO    "
 DC.B "GEORGE,   DR. SYNE,   SKUNK,   OZ (WOT NO PICTURES),   "
 DC.B "AUTOMATION,   POMPEY PIRATES,   MEDWAY BOYS,   THE LOST BOYS,   "
 DC.B "STEW,   RIPPED OFF (WHO!),   THE DEMO CLUB,   SWSL,   "
 DC.B "BASHER,   SEWER SOFTWARE,   ERIK PLANKTON,   THE REPLICANTS,   "
 DC.B "TCB   AND   ALL GUYS AT THE BLACKPOOL CLUB (I'LL BE BACK, DON'T WORRY!).   "
 DC.B "      THIS DISC WAS RELEASED ON 11TH OF DECEMBER 1990 BY "
 DC.B "MAC SYS DATA, I HOPE TO HAVE DISC 49 OUT BEFORE XMAS DAY.       "
 DC.B "DISC 50 WILL BE DELAYED AS I WILL HAVE TO CODE A SUPER MENU AND "
 DC.B "AN INFO FILE AS BORIS SEEMS TO HAVE DISAPPEARED.  OUT OF 4 P.O.V. "
 DC.B "MEMBERS I SEEM TO BE THE ONLY ONE WORKING.     OUT OF THE "
 DC.B "OTHER 3 MEMBERS THERE IS     "
 DC.B "BORIS - DISAPPEARED BUT BELEIVED TO BE WORKING ON A DIFFERENT P.O.V. RELEASE,        "
 DC.B "ALY - LAST SEEN IN THE PUB SOME 4 WEEKS AGO        AND        "
 DC.B "OZYMANDIAS - LAST SEEN IN SEPTEMBER BEFORE STARTING SIXTH FORM.        "
 DC.B "  AS P.O.V. SEEMS TO HAVE SPLIT FOR A WHILE I THINK I'LL STOP "
 DC.B "WORK AFTER 49 AND LET BORIS CODE THE NEXT 50 MENUS!      "
 DC.B "I MAY EVEN THROW OZ OUT 'CAUSE HE SAYS HE IS TOO BUSY "
 DC.B "TO DRAW A SINGLE PICTURE.       IF THERE "
 DC.B "IS ANY ARTIST OUT THERE WHO CAN DRAW SOME DECENT PICTURES "
 DC.B "THEN DO SOME FOR ME!   SEND THEM TO ......   P.O.V.,      "
 DC.B "23 ALMA PLACE,      SPILSBY,      LINCS.,      PE23 5LB.      "
 DC.B "      I WATCHED THE NEWS TODAY AND WAS AMAZED THAT BRITAIN WAS "
 DC.B "COVERED IN SNOW - I QUICKLY LOOKED OUT OF WINDOW AND LOW AND BEHOLD "
 DC.B "NO SNOW!     THERE IS NO BLOODY SNOW IN BLACKPOOL, IT'S "
 DC.B "CLEAR AND DRY BUT COLD AND WINDY.  HOW COME WE ALWAYS "
 DC.B "MISS OUT ON THE SNOW. (I'M SORRY BUT I HAVN'T GOT A QUESTION "
 DC.B "MARK IN THIS CHARACTER SET).     OH 'ECK THE LIGHTS HAVE "
 DC.B "STARTED TO FLICKER I HOPE THE ELECTRIC DON'T GO OFF 'CAUSE "
 DC.B "MY STFM HAS BEEN PACKING A DEMO FOR THE LAST COUPLE OF "
 DC.B "HOURS AND IT'LL LOSE THE LOT.        HEY TODAY I BOUGHT "
 DC.B "THE FARM CD SINGLE 'ALTOGETHER NOW' - IT IS BRILLIANT! "
 DC.B "I'VE GOT IT BLASTING OUT NOW.       "
 DC.B "I WISH I WAS ALTOGETHER NOW!   THAT IS ALTOGETHER NOW WITH "
 DC.B "THE LOVE OF MY LIFE RACHEL WHO IS IN FENHAM WHILST I'M IN "
 DC.B "A LITTLE VILLAGE SOME 8 MILES FROM BLACKPOOL.    IF I "
 DC.B "HAD A HELICOPTER I'D FLY UP THERE EVERY WEEKEND TO SEE "
 DC.B "HER.      WELL AS IT IS NOW 9 PM AND A SATURDAY, NIGHT I'M "
 DC.B "OFF TO THE PUB FOR A FEW JARS - SEE YA TOMORROW...   "
 DC.B "           YO ME HARTIES, ARE YA OR REET.     IF YOU CAN'T "
 DC.B "UNDERSTAND THE LINGO THEN YOU 'AINT FROM LANCASHIRE.  "
 DC.B "  IT IS NOW TOMORROW!       IF YOU WANT TO SEE WHAT DEMOS WE "
 DC.B "HAVE PACKED THEN GET A COPY OF P.O.V. 50 AS SOON AS IT COMES OUT "
 DC.B "AS IT WILL CONTAIN AN INFO FILE. IF YOU CAN'T WAIT FOR DISC 50, YOU "
 DC.B "CAN ALWAYS GET DISC 40!          "
 DC.B "        OKAY GUYS AND GELS I'M FED UP OF TYPING "
 DC.B "SO I'M GOING TO WRAP THIS THING UP. SO UNTIL NEXT TIME I BID YOU ALL "
 DC.B "FAREWELL..                      P.S. DON'T FORGET THE VIRUS "
 DC.B "IS STILL IN MEMORY EVEN IF YOU RESET!!!                 (LAMERS!)     "
 dc.b "              WRAPERTY WRAP! "
 dc.b "  "
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

**************************
blank	dcb.b	52*4,0
vu_blocks	incbin	vu.dat
**************************
tune:	incbin	pipe.img
	even
pic	incbin	pov48.PI1
	even
filenames:
	dc.b	"SLEDGE.DEM",0,0,0,0
	dc.b	"CHARLIE.DEM",0,0,0
	dc.b	"ANTI.DEM",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
