****************
* P.O.V. 45    *
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

;Music from INNER CIRCLE menu
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
 DC.B "                    "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 45.          "
 dc.b "ALL CODING BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC BY THE "
 dc.b "EXCELLENT COUNT ZERO RIPPED FROM THE INNER CIRCLE DECADE DEMO MENU BY "
 dc.b "ME (MAC SYS DATA).      HA-HA, IT'S DISC 45 AND THE SECOND DISC TONIGHT! "
 dc.b "   I MAY NOT COMPLETE THIS DISC TONIGHT AS I'M ABOUT TO GO TO THE "
 dc.b "PUB 'CAUSE IT'S A SATURDAY (1-12-90). IN FACT I'M GOING NOW!   BYE.            "
 DC.B "                                                                   "
 DC.B "HELLO AGAIN, WELL IT IS NOW SUNDAY THE 2-12-90 AND IT'S 11:30 IN THE "
 DC.B "MORNING.     OH I'VE GOT A HEADACHE!        I'VE JUST REALISED THAT "
 DC.B "I HAVE ABOUT 150 DISCS PILED ON AND AROUND MY STE.    I DON'T "
 DC.B "KNOW WHERE THEY APPEAR FROM BUT IT'S A BLOODY HARD JOB TRYING "
 DC.B "TO PUT THEM IN BOXES.     WHAT'S THIS?      OH, YEH - P.O.V. 43 WAITING "
 DC.B "TO BE TESTED!       TO MY RIGHT I HAVE A SMALL PILE OF DISCS THAT "
 DC.B "ARE WAITING FOR A HOME, THEY CONTAIN DEMOS THAT I'VE PACKED - HERE ARE "
 DC.B "A FEW TITLES.. (I KNOW I'VE DONE THIS BEFORE BUT THERE ARE A COUPLE OF EXTRA "
 DC.B "DEMOS IN THE PILE).....  MILLI VANILLA (1 MEG),     ZOOLOOK (1 MEG),     "
 DC.B "PREDATOR (1 MEG),     SLEDGE HAMMER (1 MEG),     VIC DEMO 1,     "
 DC.B "ODU (CRAP),     MR SPOONS,     JUNGLE STE,     "
 DC.B "ABC DEMO 2,     MOTLEY CREW DEMO,     "
 DC.B "TWINS 7,     CHARLIE CHAPLIN DEMO (CRAP),     "
 DC.B "ANTI-SOCIALS     AND     ABC DEMO 8.      IF "
 DC.B "YOU COUNTED THERE ARE 14 DEMOS WAITING BUT AS THE MENUS SEEM TO HAVE "
 DC.B "TAKEN A BIT OF A DIVE IN THE QUALITY DEPARTMENT I THINK I BETTER "
 DC.B "CODE UP A DECENT MENU FOR DISC 46!    THE REASON FOR THE LACK "
 DC.B "OF MOVEMENT ON THE LAST 6 DISCS IS THAT I LOOKED THROUGH MY "
 DC.B "PILE OF DEMOS AND ADDED THE FILE SIZES UP TO EQUAL 750K WHICH "
 DC.B "LEFT ABOUT 50K FOR A MENU.   IF I WANT TO MOVE THINGS AROUND "
 DC.B "IT TAKES MORE DISC SPACE UP, I HAD CODED A BRILLIANT MENU FOR "
 DC.B "THIS DISC BUT IT WOULD ONLY PACK TO 56K AND SO IT WOULDN'T FIT ON. "
 DC.B "    I FANCY DOING A VECTOR BOBS MENU WITH 3D BOBS BUT I DON'T THINK "
 DC.B "ONE WILL APPEAR FOR A WHILE 'CAUSE I WANT TO GET TO DISC 50 BY "
 DC.B "XMAS!               A COUPLE OF DAYS AGO I HAD A PROBLEM WITH "
 DC.B "GENST 2 AGAIN - THIS TIME IT KEPT WRITING THE OBJECT CODE (PRG) "
 DC.B "FILE TO ANY FOLDER ON THE HARD DISC SO I COPIED PARTITION 'E' "
 DC.B "TO 'D' AND WIPED 'E' (OKAY?).   I THEN COPIED 'D' TO 'E' SO THAT "
 DC.B "'E' WOULD BE IN CONSECUTIVE SECTORS.  I THOUGHT THAT IT MAY HELP "
 DC.B "WITH GENST AS IT DOES SEEM TO GO WONKY WHEN I'VE LOADS OF "
 DC.B "FOLDERS AND THINGS DELETED AND MOVED AROUND.    WELL AS I "
 DC.B "MOVED FILES (COPIED AND DELETED ON AN STE) I GOT THE MESSAGE "
 DC.B "THAT FILE EXISTS OVERWRITE?   I ANSWERED YES BUT THOUGHT IT STRANGE. "
 DC.B "HALF WAY THROUGH THE MOVES I THOUGHT I'D BETTER REBOOT THE MACHINE "
 DC.B "SO WHEN THE HARD DISC HAD STOPPED I SWITCHED OFF AND ON.   ONCE "
 DC.B "MY STE HAD BOOTED UP I FOUND TO MY HORROR THAT ALL THE PROGRAMS "
 DC.B "I HAD COPIED TO 'E' HAD VANISHED.   I HAVE LOST APPROX 2 MEG OF "
 DC.B "CUSTOM PROGRAMS THAT I HAD WRITTEN THAT ALLOW ME TO PACK "
 DC.B "DEMOS.  I QUICKLY FOUND THE BACKUP DISCS THAT I HAVE AND REALISED "
 DC.B "THAT THE LAST BACKUP I HAD DONE WAS IN APRIL - ONLY 7 MONTHS AGO!  "
 DC.B "    AFTER A COUPLE OF HOURS LOOKING THROUGH DISC BOXES AND OTHER "
 DC.B "PARTITIONS I HAVE RECOVERED ABOUT 1.7 MEG WHICH LEAVES A COUPLE "
 DC.B "OF DEMOS AND ALL MY HACKING AND PACKING UTILITIES WHICH I'LL "
 DC.B "NOW HAVE TO WRITE AGAIN.    I HAD THE IDEA THAT AS I HAVE TO "
 DC.B "WRITE THEM AGAIN I WOULD TRY TO DO IT IN 'C' SO I COULD "
 DC.B "USE GEM AND SO MAKE A USER FRIENDLY VERSION. AS THE IDEA "
 DC.B "GREW I THOUGHT I'D MAKE A DEMO PACKING UTILITY THAT I COULD "
 DC.B "RELEASE ONTO THE PD CIRCUIT.  THE UTILITY WOULD ALLOW "
 DC.B "YOU TO PACK MASTERSOUND DEMOS BECAUSE THEY ARE ALWAYS THE "
 DC.B "SAME AND ARE VERY EASY TO PACK, I'LL START CODING AFTER XMAS "
 DC.B "AND HOPEFULLY LEARN 'C' AT THE SAME TIME!        I HAVE "
 DC.B "BEEN GIVEN A COPY OF THE MEDWAY BOYS VIRUS PROTECTOR 3 SO "
 DC.B "I'LL PUT THAT ON THE NEXT MENU (IF IT FITS).     "
 DC.B "I WAS GOING TO DO A UTILITY COMPILATION BUT A LOT OF PROGRAMS "
 DC.B "USE GEM SO I'D HAVE TO PUT AN AUTOGEM ON THE DISC AND AS "
 DC.B "ALL THE PRESENT AUTOGEM PROGRAMS BUGGER UP ON AN STE I'M NOW "
 DC.B "STUCK.         BORIS, WHERE'S YOUR AUTOGEM PROGRAM?       "
 DC.B "      RIGHT THERE ARE MENUS TO BE CODED AND DEMOS TO BE PACKED "
 DC.B "SO I'M GOING - UNTIL NEXT TIME IT'S MAC SYS DATA SIGNING OFF "
 DC.B "..... BYE!                              "
 DC.B "                             "
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
tune:	incbin	menu.img
	even
pic	incbin	pov45.PI1
	even

filenames:
	dc.b	"ABC3.DEM",0,0,0,0,0,0
	dc.b	"LOTG.DEM",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
