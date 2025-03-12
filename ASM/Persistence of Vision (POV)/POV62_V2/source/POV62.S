****************
* P.O.V. 43    *
****************

	bsr	set_super
wait_for_drive
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

	move.b	#$12,$fffffc02.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

; Spherical intro (sort of) by MAD MAX
	move.l	#1,D0
	jsr	tune

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
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

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

	cmp.b	#$70,d0		;0 keypad
	beq.s	zero

car	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

zero	tst.w	zero_counter
	bne.s	car
	eor.w	#$4,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
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
hz50	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit:
	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
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
CHARACTER_DEPTH=32

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
	mulu	#CHARACTER_DEPTH*4*4,d0		;30 * 4 * (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#(CHARACTER_DEPTH*4),d0		;character depth  (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	CHARACTER_DEPTH
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
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
	tst.w	zero_counter
	bne.s	.not_z
	rts
.not_z	sub.w	#1,zero_counter
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

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

calc_screen	lea	screen,a0
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
	lea	pic+34,a0
	move.l	screen_base,a1
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
	clr.l	d0
	jsr	tune
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
	jsr	tune+8
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
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bclr	#0,$fffa0f
	rte



********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$777,$677,$667,$566,$556,$455,$445
	dc.w	$344,$334,$233,$223,$126,$112,$011,$001

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
zero_counter	dc.w	10
	even
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 62 "
 dc.b "VERSION 2 (FIXED 12-12-93).    "
 dc.b "ALL CODE BY MAC SYS DATA WITH GRAFIX BY OZ. THE MUSIC "
 DC.B "IS BY MAD MAX FROM THE THALION TUNE DEMO (ON P.O.V. 56) AND "
 dc.b "IS CALLED 'SPHERICAL TITLE (NEARLY)'.      TODAYS DATE IS "
 DC.B "1-3-91 AND SADAM HAS GIVEN UP THE WAR WHICH MEANS OZ WILL HAVE "
 DC.B "TO DRAW SOME MORE PICTURES THAT DO NOT MENTION THE WAR (HEY OZ "
 DC.B "I CAN'T USE THE 'BURN BUSH BURN' PIC NOW!)      "
 dc.b "RIGHT I'VE JUST RECEIVED SOME DISCS FROM MARTIAN (YES MORE DISCS) "
 DC.B "WHICH MEANS I HAVE 68 DEMOS TO PACK..... WOW!!!   IN THE PAST "
 DC.B "WE WERE CONSTANTLY SHORT OF DEMOS BUT NOW IT SEEMS THAT WE ARE "
 DC.B "CONSTANTLY SHORT OF MENUS TO USE. I COULD ALWAYS USE SOME OLD "
 DC.B "MENUS BUT I DON'T LIKE DOING THAT AS IT IS TACKY. OK SO I HAVE "
 DC.B "USED THE SAME MENUS A COUPLE OF TIMES BUT IT IS HARD TO THINK "
 DC.B "OF SOMETHING NEW FOR EACH MENU.     SOME OF THE NEW DEMOS "
 DC.B "I HAVE RECEIVED ARE ON 11 SECTOR DISCS WHICH MEANS THEY ARE "
 DC.B "VERY BIG EVEN WHEN PACKED. SOME DEMOS MAY NOT GO ON A "
 DC.B "P.O.V. COMPILATION DISC BUT WILL BE A P.O.V. PACK AS I THINK IT IS LAME TO HAVE "
 DC.B "A MENU WITH ONLY 1 DEMO ON IT.      "
 DC.B "I'VE JUST HAD A LOOK THROUGH THE DEMOS I HAVE AND "
 DC.B "I'VE FIGURED OUT THAT MOST ARE EITHER MASTERSOUND OR STOS DEMOS. "
 DC.B "THERE ARE A COUPLE OF AUTOPLAY DEMOS BUT THEY POSE NO PROBLEM "
 DC.B "AS I HAVE ALREADY PACKED SEVERAL OF THE SAME TYPE.   DID YOU "
 DC.B "REALISE THAT THERE ARE NOT THAT MANY DIFFERENT TYPES "
 DC.B "OF LOADERS ON DEMOS?     ONE EXAMPLE IS A MASTERSOUND DEMO, "
 DC.B "THESE USE THE SAME CODE ALL THE TIME SO THEY ARE EASY TO "
 DC.B "PACK. TO MAKE MY LIFE EASIER I HAVE WRITTEN A MASTERSOUND "
 DC.B "DEMO PACKER THAT DOES ALL THE HARD WORK FOR YOU. TO USE IT YOU HAVE "
 DC.B "TO ENSURE THE STANDARD MASTERSOUND FILENAMES ARE PRESENT AND "
 DC.B "ICE PACKER V2.11 IS IN THE ROOT DIRECTORY. YOU SET THE PROGRAM "
 DC.B "GOING BY SELECTING AN OPTION TO SPLIT THE PICTURE, ONCE DONE "
 DC.B "YOU PRESS 3 TO RUN THE PACKER. AFTER PACKING THE PICTURE DATA "
 DC.B "YOU EXIT THE PACKER THUS GOING BACK TO MY PROGRAM, YOU THEN "
 DC.B "PRESS OPTION 4 TO JOIN THE PICTURE.       USING THE SIMILAR "
 DC.B "METHOD THE SAMPLE,FONT AND TEXT ARE PACKED. ONCE DONE THE BOOT.PRG "
 DC.B "FILE IS PACKED AS A PROGRAM FILE AND THEN RENAMED, I ASSEMBLE "
 DC.B "A SMALL ROUTINE TO SAY 'PACKED BY ....' AND INSERT THE NEW "
 DC.B "FILENAME FOR BOOT.PRG AND THAT'S IT!        I ORIGINALLY WROTE "
 DC.B "THE PROGRAM FOR BORIS SO HE COULD PACK DEMOS BUT HE SAID I "
 DC.B "WAS THE PACKER IN THE GROUP - I'M NOT TOO BOTHERED 'CAUSE "
 DC.B "I WROTE THE PROGRAM (IN 68000) IN UNDER 3 HOURS FROM SCRATCH. "
 DC.B "I MAY INCLUDE THE UTILITY ON A FUTURE P.O.V. DISC, OR THEN AGAIN "
 DC.B "I MAY NOT!     ONE THING I AM WRITING IS A SET OF GUIDE NOTES "
 DC.B "FOR PACKING SEVERAL DIFFERENT TYPES OF DEMOS, THEY MAY "
 DC.B "FIND THEIR WAY TO A PD LIBRARY SO IF YOU'RE INTO PACKING "
 DC.B "DEMOS, YOU BETTER KEEP YOUR EYES ON THOSE CATALOGUES....    I HAVE "
 DC.B "PURPOSELY DELAYED THE RELEASE OF PACKING NOTES TO PREVENT "
 DC.B "THE MARKET BEING FULL OF 'TIN POT PACKERS' LIKE THE "
 DC.B "GAMES AREA IS.....      THERE ARE TWO MAJOR DEMO PACKING "
 DC.B "GROUPS IN THE U.K., WE ARE THE BEST (OF COURSE) 'CAUSE WE "
 DC.B "PACK EVERYTHING WE GET AND WE WRITE ALL OUR OWN STUFF IN 68000.  "
 DC.B "THE OTHER PACKING GROUP IS CALLED "
 DC.B "'RIPPED OFF' WHO ALSO PACK DEMOS PRETTY DECENTLY BUT "
 DC.B "DON'T WRITE ALL THEIR OWN STUFF (LAMERS) BUT AT LEAST "
 DC.B "THEY DON'T USE PAMPUK LIKE OTHER LAMERS I COULD MENTION (STEW).   "
 DC.B "    HA-HA-HA!!!    IF YOU CAN'T PACK THE DATA FILES THEN DON'T BOTHER PACKING THE "
 DC.B "PROGRAM FILE!     "
 DC.B "  RIGHT THIS IS THE END OF YET ANOTHER P.O.V. PACKED DEMO COMPILATION "
 DC.B "DISC AND I'M ALREADY THINGING OF P.O.V. 63..... BYE!    "
 DC.B "                        "
 DC.B "                                     (WOT NO GREETING?)           "
 dc.b $ff
	even
char_offset	dc.w	0
font:	incbin	font.fnt
font_offsets:
 dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49
 dc.b	50,51,52,53,54,55,56,57,58
 dc.b	59,60,61,62,63
	even

;*************************
tune:	incbin	spheric.mus
	even
pic	incbin	pov62.PI1
	even

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3
	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$ff
	even

filenames:
	dc.b	"JELYBEAN.DEM",0,0,0,0
	dc.b	"REDDWARF.MSD",0,0,0,0
	dc.b	"TWINS7.MSD",0,0,0,0,0,0
	dc.b	"ENGINE.DEM",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
