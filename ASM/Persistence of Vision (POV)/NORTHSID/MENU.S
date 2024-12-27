*************************************************************************
*				NORTHSIDE MENU ?         		*
*				---------------- 			*
*									*
* Written By MACHINE SYSTEM DATA of PERSISTENCE OF VISION		*
* Date: 10/8/91								*
*									*
* All code ½ P.O.V. 1991						*
* 									*
*************************************************************************
*
* The grafix on this menu were drawn by me and Aly (ex POV). The original
* pic is in 4 colours but I changed them all to grey and it looks ok so
* who cares?
*
* Right, that's it, go hack/pack something.



BOB_DEPTH=45	;bob depth in pixels
BOB_WIDTH=10	;bob width in words

BORDER_COLOUR=0		;Change this for border colours
	bsr	set_super		;set supervisor mode
	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	save_pal		;save old palette
	bsr	get_base		;get present screen base
	bsr	get_rez
	bsr	black_out		;make all colours black
	bsr	calc_screen		;calc our own screen address
					;so we are not restricted
					;to a fixed screen address
					;512 + 1024K compatable

	move.l	screen_1,a0		;new screen base
	move.l	a0,present_base		;store now
	move.l	a0,last_base
	bsr	set_low_rez		;go into low rez
	bsr	shift_bob		;draw bob to screen and shift 16 times
	bsr	clear_below_screen	;clear area below screen
	move.b	$484,old484		;save keyboard click/speed, etc
	clr.b	$484			;disable repeat/click/bell

****** Music from KILLING GAME SHOW *********
****** Ripped by MAC SYS DATA
****** Count zero music....

	move.l	#23,d0			;only one tune
	jsr	tune			;initialise tune

	bsr	set_palette		;set new colours
	bsr	set_for_border		;knock out lower border and
					;set interrupts going
	bsr	vsync
	bsr	show_pic
	bsr	do_bob			;init bob
	bsr	flush			;flush keyboard buffer

main_loop	;main coding loop......................
	bsr	flip_screen		;flip between two screens
	bsr	vsync			;wait for screen refresh
;	move.w	#$123,$ffff8240.w	;CPU time check
	bsr	return_screen		;wipe bob
	bsr	do_bob			;draw new bob
	bsr	scroll			;do scroller
;	move.w	pic+2,$ffff8240.w	;CPU time check

	move.b	$fffffc02.w,d0		;get key press value

	cmp.b	#01,d0			;escape?
	beq	exit			;yes get out...

	cmp.b	#$b,d0			;0 key
	beq.s	zero


check_keys
;Check for valid key presses from a lookup table...
	lea	key_codes,a6
.loop	cmp.b	#$ff,(a6)	;end of table?
	beq.s	main_loop	;yes
	cmp.b	(a6)+,d0	;is key one we want?
	beq.s	load		;yes so load demo
	move.b	(a6)+,d6	;NO so get offset
	bra.s	.loop		;check another key code


load	move.b	(a6),-(sp)	;store offset on stack for later use
	bsr	isr_off		;turn interrupts off
	move.l	old_base,a0	;put screen base back to original value
	bsr	set_low_rez	;go low rez (again?)
	bsr	black_out	;all black (where am I?)

	moveq	#0,d0		;clear D0.L
	move.b	(sp)+,d0	;get key value off stack

*** new piece of filename selector....
	lea	filename_table,a0
	lsl.w	#2,d0		;multiply D0 by 4 (one long word)
	add.w	d0,a0
	move.l	(a0),a1		;get filename address

*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on
	bsr	user_mode		;go user mode
	clr.w	-(sp)			;exit to next prog in AUTO folder
	trap	#1			;or desktop




zero	tst.w	zero_counter
	bne.s	check_keys
	eor.w	#$123,bor+2		;show a hertz change
	eor.w	#$ffff,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop


exit	bsr	isr_off			;off with the interrupts
	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer
	bsr	user_mode		;use mode
	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!


***************
* Subroutines *
***************
return_screen		;wipe over old bob
	move.l	mid_pos,d0
	move.l	last_position,mid_pos
	move.l	last_base,a0
	add.l	d0,a0
	lea	pic+34,a1
	add.l	d0,a1
	move.w	#BOB_DEPTH-1,d1
.loop
	REPT	BOB_WIDTH
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	add.w	#160-(8*BOB_WIDTH),a0
	add.w	#160-(8*BOB_WIDTH),a1
	dbf	d1,.loop
	rts



* the bob path is a table of values with a Y offset and a X offset
* the table is calculated in FAST BASIC and the file created is
* INCBINed into the assembler. To change the table edit the SINE.BSC
* file and run it in FAST BASIC the output file is automatically
* made.

do_bob	move.l	table_pos,a0	;get position in SINE table
	cmp.w	#-1,(a0)	;is end of table?
	bne.s	.no_reset	;NO
	lea	sine,a0		;YES
	move.l	a0,table_pos
.no_reset
	moveq.l	#0,d0		;clear 3 registers
	move.l	d0,d1
	move.l	d0,d2

	move.w	(a0)+,d0	;get word/offset
	move.w	(a0)+,d1	;get y offset (post*160)
	move.l	a0,table_pos	;update SINE table pos

* Calculate the word offset across the screen...
	move.b	d0,d2
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8

	add.w	d1,d0		;add to Y line offset
	move.l	last_base,a0
	add.w	d0,a0		;address on screen of bob

* store offset from screen base for clear bob routine later..
	move.l	d0,last_position


	lea	bob,a1		;grafix
	and.w	#$f,d2		;calculate which grafix to use (1 of 16)
	mulu	#(8*BOB_WIDTH*BOB_DEPTH),d2
	add.l	d2,a1		;add to first grafix
	add.l	d2,a1		;add again to get over mask

	lea	8*BOB_WIDTH*BOB_DEPTH(a1),a2	;find mask for that grafic



* this is it, we're going to print a bob.....
	move.w	#BOB_DEPTH-1,d7
.loop	REPT	BOB_WIDTH

* do first word (8 colours)
	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen

* do second word (8 colours)
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	ENDR

	add.w	#160-(BOB_WIDTH*8),a0	;drop down one screen line
	dbf	d7,.loop	;do until finsihed
	rts




* scroll routine..... BORIS wrote most of this ages ago but I'll
* try to explain it....

scroll	move.l	last_base,a1		;screen base
	add.l	#160*200,a1		;into border
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words

next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0	;find correct offset
	mulu	#32*4,d0	;32 lines of each character by 4 bytes wide
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	mulu	#32,d0		;char depth 32 deep
	add.w	d0,a0		;we now point to character in A0

** this bit prints 1 byte wide blocks of the font, this method makes
** it possible to redraw the scroller every screen refresh and makes
** it so the we do not have to shift the scroller. The bad part is that
** it scrolls bloody fast at 8 bits every screen refresh.
** If I didn't use this then the bob may have to be made smaller 'cause
** of the CPU time...

.column
OFF	set	0
	REPT	32		;32 lines deep font
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
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
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


user_mode
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


save_pal			;save old colours
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


restore_pal			;put back original colours
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
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
	add.l	#49152,d0
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
set_rez
	move.l	a0,-(sp)	;screen address is in A0
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


show_pic			;show the pic
	lea	pic+34,a0
	move.l	present_base,a1

	lea	32000-160(a0),a2
	lea	32000-160(a1),a3

	move.w	#200/2-1,d7
.loop	bsr	vsync
	movem.l	(a0),d0-d6	;28 bytes
	movem.l	d0-d6,(a1)
	movem.l	28(a0),d0-d6	;56
	movem.l	d0-d6,28(a1)
	movem.l	56(a0),d0-d6	;84
	movem.l	d0-d6,56(a1)
	movem.l	84(a0),d0-d6	;112
	movem.l	d0-d6,84(a1)
	movem.l	112(a0),d0-d6	;140
	movem.l	d0-d6,112(a1)
	movem.l	140(a0),d0-d4	;160
	movem.l	d0-d4,140(a1)
	lea	320(a0),a0
	lea	320(a1),a1

	movem.l	(a2),d0-d6	;28 bytes
	movem.l	d0-d6,(a3)
	movem.l	28(a2),d0-d6	;56
	movem.l	d0-d6,28(a3)
	movem.l	56(a2),d0-d6	;84
	movem.l	d0-d6,56(a3)
	movem.l	84(a2),d0-d6	;112
	movem.l	d0-d6,84(a3)
	movem.l	112(a2),d0-d6	;140
	movem.l	d0-d6,112(a3)
	movem.l	140(a2),d0-d4	;160
	movem.l	d0-d4,140(a3)
	lea	-320(a2),a2
	lea	-320(a3),a3
	dbf	d7,.loop

	move.l	present_base,a0		;copy to second screen
	move.l	screen_2,a1		;for flip screen
	move.w	#32000/4-1,d1
copy	move.l	(a0)+,(a1)+
	dbf	d1,copy
	rts


black_out				;all colours black
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)	;ROM wait for screen update
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


clear_below_screen			;clear crap under screen for
	move.l	present_base,a0		;border code
	lea	32000(a0),a0
	move.l	a0,a1
	add.l	#49152,a1
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts


set_for_border			;save old interrupt values
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W		;set new interrupt values
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts				;ISRs are now running


isr_off	bsr	vsync			;shut the interrupts down
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR


endmusic				;turn da music off man!
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


shift_bob			;make 16 values of bob so smooth scroll
	lea	bob_pic+34,a0
	move.l	present_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop

	lea	bob,a1
	move.w	#16-1,d7
shift_loop
	move.l	present_base,a0
	move.l	a0,a6
	add.w	#8,a0

	move.w	#BOB_DEPTH-1,d2
repeat
OFF	set	0
	REPT	BOB_WIDTH		;in words
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat

	move.w	#BOB_DEPTH-1,d2
repeat2
OFF	set	0
	REPT	BOB_WIDTH		;in words
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat2
	move.l	a6,a0

	move.w	#(BOB_DEPTH*2)+8-1,d6
.loop	sub.w	d4,d4
OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR

	sub.w	#6,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop

;now clear screen
	move.l	present_base,a0
	moveq	#0,d0
	move.w	#32000/4-1,d1
loop	move.l	d0,(a0)+
	dbf	d1,loop
	rts



*********
* ISRs  *
*********
vert_isr	;every screen update...
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d1		;set colours after isr
	movem.l	d0-d1,$ffff8240.w
	bsr	tune+6			;do COUNT ZERO music
	clr.w	vsync_flag		;own screen update rout
	tst.w	zero_counter
	beq.s	.clear
	sub.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w		;set interrupt method
	move.b	#199,$fffffa21.w	;next interrupt to occur 199 lines down
	bclr	#0,$fffffa0f.w		;and go interrupt
	rte				;let's leave before interrupt occurs

horiz_isr
	clr.b	$fffffa1b.w	;DI all other interrupts
	REPT	102		;wait until we are next to right border
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz

*** this bit of code here is important for timing the border
*** do NOT change or you will lose STE compatability and probably the
*** lower border
***
*** I do the following 3 lines here to prevent the user from seeing
*** the colour change in the scroller
***
	movem.l	d0/a0,-(sp)	;save regs
	move.l	colours_pos,a0	;colours for font
	move.w	#32-1,d0	;set up D0 here to save time later

***
***
	REPT	31-14		;wait a while
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz

**** WOW dudes we are in the lower border.......
bor	move.w	#BORDER_COLOUR,$ffff8240.w	;hertz color show

.loop	move.w	(a0)+,$ffff8242.w	;show colours in scroll
	REPT	121
	nop
	ENDR
	dbf	d0,.loop
	move.w	#BORDER_COLOUR,$ffff8240.w
	add.l	#2,colours_pos
	move.l	colours_pos,a0
	cmp.l	#colours_end,a0
	bge.s	.reset_cols
	movem.l	(sp)+,d0/a0		;get regs from stack
	bclr	#0,$fffffa0f.w		;test OS we are done
	rte				;carry on with main code
.reset_cols
	move.l	#colours,colours_pos
	movem.l	(sp)+,d0/a0		;get regs from stack
	bclr	#0,$fffffa0f.w		;test OS we are done
	rte

********
* Data *
********
	SECTION DATA
colours_pos	dc.l	colours
colours	dc.w	0		;for scroller
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017,$007
	dc.w	$106,$205,$304,$403,$502,$601,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$671,$572,$473,$374,$275,$176,$077
	dc.w	$167,$257,$347,$437,$527,$617,$707
	dc.w	$706,$705,$604,$503,$402,$301
colours_end
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017,$007

zero_counter	dc.w	0
screen_number	dc.w	0
present_base	dc.l	0
last_base	dc.l	0
screen_1	dc.l	0
screen_2	dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0

*** store for old ISR data
old70		dc.l	0
old120		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
	even
old_base	dc.l	0		;old screen address
org_rez		dc.w	0		;original rez
hertz_switch	dc.w	0		;hertz toggle check

scroll_pointer	dc.l	scroll_text+7
scroll_text
 DC.B "                    "
 dc.b "NORTHSIDE OF BLACKPOOL PRESENT DISC ?          "
 dc.b "MENU CODED BY MAC SYS DATA OF PERSISTENCE OF VISION,     MUSIC "
 dc.b "FROM KILLING GAME SHOW RIPPED BY MAC SYS DATA,    GRAFIX BY ALY "
 dc.b "(EX MEMBER OF P.O.V.).            "
 DC.B "GREETINGS TO..        P.O.V.,   "
 DC.B "ALL AUTOMATION,   MEDWAY BOYS,   NOW 5,   POMPEY PIRATES AND "
 DC.B "RIPPED OFF.               "
 dc.b "ANOTHER MENU AND ANOTHER COUPLE OF NAFF GAMES!!      "
 DC.B "OKAY, THROW YOUR OWN SCROLLTEXT IN HERE "
 DC.B "'CAUSE I AIN'T WRITING TEXT FOR NOBODY (EXCEPT P.O.V.!)   "
 DC.B "BYE.......        "
 DC.B "                             "
 dc.b $ff
	even


char_offset	dc.w	0
font	dcb.b	32*4,0
	incbin	1plane.fnt



**** this allows any pic of font to be used no matter in what
**** order the font appears on screen, simply change this to refer
**** to the letter position on screen
***
*** 1=top left of screen
*** there are 10 per screen width..
***
***  1   2   3   4   5   6   7   8   9   10
***  11  12  13  14  15  16  17  18  19  20
***  21  22  23  24  25  26  27  28  29  30
***  31  32  33  34  35  36  37  38  39  40
***  41  42  43  44  45  46  47  48  49  50


*** Use the program NIK_FONT.S to steal font from screen...



font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,38,43,00,00,00,00,43,40,41,45,00,44,46,39,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,00,00,00,00,00,37,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even



tune	incbin	killing.img		;count zero music
	even


pic	incbin	pic.PI1			;main menu pic


bob_pic	incbin	bob.pi1			;pic with bob in top left


mid_pos		dc.l	0		;buffer for bob
last_position	dc.l	0		;last bob pos
table_pos	dc.l	sine		;pointer into SINE table
sine	incbin	sine.dat		;here is the sine table
	dc.w	$ffff,$ffff		;end of sine table


black	dcb.b	32,0			;32 bytes of nothing...



********** valid key press table
*
* table has a key value and an offset so using different key values
* with the same offsets you can make the menu load files from
* say.. 1=game1, 2=game2, 3-game3
*  OR
* say.. F1=game1, F2=game2, F3=game3
*  OR
* say.. A=game1, B=game2, C=game3
*  OR
* say.. L=game1, W=game2, F10=game3, HELP=doc displayer!!!
*
* All you need to know is the key value (in Katherine Peels book)
*
*
*
* F1=3B
* F10=44
*
* HELP=62
*
*

key_codes
	dc.b	2,0	;key 1, offset 0
	dc.b	3,1	;key 2, offset 1
	dc.b	4,2	;key 3, offset 2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1, offset 0
	dc.b	$6e,1	;keypad 2, offset 1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,3	;keypad 5

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5


*** filenames no longer need to be 16 bytes long but must end
*** in 0 and must be on an even address...
filename1
	dc.b	"GAME1.MSD"
	dc.b	0
	even

filename2
	dc.b	"GAME2.POV"
	dc.b	0
	even

filename3
	dc.b	"DEMO3.NOR"
	dc.b	0
	even

filename4
	dc.b	"FILENAME.EXT"
	dc.b	0
	even

filename5
	dc.b	"ANOTHER.ONE"
	dc.b	0
	even



*************************
	SECTION BSS	
*************************
;Storage space allocated only when program is loaded so it doesn't
;make the file massive...

old_pal	ds.b	32		;old colours

bob	ds.b	BOB_DEPTH*(BOB_WIDTH*8)*16	;grafix
	ds.b	BOB_DEPTH*(BOB_WIDTH*8)*16	;masks

	even

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	49152		;two screens
	ds.b	49152

