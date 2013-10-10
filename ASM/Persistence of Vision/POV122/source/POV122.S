*************************************************************************
*				P.O.V. 122				*
*				----------				*
*									*
* Written By MACHINE SYSTEM DATA of PERSISTENCE OF VISION		*
* Date: 11/8/92								*
*									*
* All code ½ P.O.V. 1992						*
* 									*
*************************************************************************


TBCR		equ	$fffffa1b	;timer B control
TBDR		equ	$fffffa21	;timer B data
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


	opt	o+,w-


YES=1
NO=0

FINAL	equ	NO

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg


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
exec	pea	.get_type(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	cmp.w	#"$$",.type
	beq.s	.autogem
	pea	blank
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
.autogem
	clr.w	-(sp)
	trap	#1
.get_type
	move.w	$200.w,.type
	rts
.type	dc.w	0
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

	bsr	clear_bss
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
	bsr	set_low_rez		;go into low rez
	move.l	screen_1,present_base
	move.l	screen_2,last_base

	move.b	$484.w,old484		;save keyboard click/speed, etc
	clr.b	$484.w			;disable repeat/click/bell

	move.w	#1,d0
	bsr	tune

	clr.w	pic+4
	clr.w	pic+6
	clr.w	pic+8
	bsr	set_palette		;set new colours
	bsr	set_interrupts		;knock out lower border
	bsr	show_pic
	bsr	flush			;flush keyboard buffer
main_loop
	bsr	flip_screen
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	 vu
;	move.w	pic+2,$ffff8240.w


	move.b	$fffffc02.w,d0

	ifeq	FINAL
	cmp.b	#01,d0			;escape?
	beq	exit			;yes get out...
	ENDC

	cmp.b	#$b,d0			;0 key
	beq	zero

	cmp.b	#$70,d0			;0 key
	beq	zero


check_keys
	lea	key_codes,a6
.loop	cmp.b	#$ff,(a6)	;end of table?
	beq.s	main_loop	;yes
	cmp.b	(a6)+,d0	;is key one we want?
	beq.s	load		;yes so load demo
	move.b	(a6)+,d6	;NO so get offset
	bra.s	.loop		;check another key code


load	move.b	(a6),-(sp)	;store offset on stack for later use
	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70.w
	move.l	old_timerb,$120.w
	move.l	old_timera,$134.w

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	old_TBCR,TBCR
	move.b	old_TBDR,TBDR
	move.w	(sp)+,sr

		move.l	#$8000000,$ffff8800.w
		move.l	#$9000000,$ffff8800.w
		move.l	#$a000000,$ffff8800.w

	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

	moveq	#0,d0		;clear D0.L
	move.b	(sp)+,d0	;get key value off stack

*** new piece of filename selector....
	lea	filename_table,a0
	lsl.w	#2,d0		;multiply D0 by 4 (one long word)
	add.w	d0,a0
	move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
	lea	$200.w,a0
	movem.l	(a1),d0/d1/d2/d3	;move 16 bytes
	movem.l	d0-d3,(a0)		;into $200


*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on

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


zero	tst.w	zero_counter
	bne	check_keys
	eor.w	#$001,pic+2		;show a hertz change
	eor.w	#$001,hertz_col		;show a hertz change
	eor.w	#$ffff,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop

	ifeq	FINAL
exit	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70
	move.l	old_timera,$134.w
	move.l	old_timerb,$120.w

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	old_TBCR,TBCR.w
	move.b	old_TBDR,TBDR.w
	move.w	(sp)+,sr

		move.l	#$8000000,$ffff8800.w
		move.l	#$9000000,$ffff8800.w
		move.l	#$a000000,$ffff8800.w

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
	add.l	#(160*161)+4,a1		;into border
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
	lsl.w	#7,d0
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	lsl.w	#5,d0
	add.w	d0,a0		;we now point to character in A0

.column
UP3	set	-160*150
UP2	set	-160*100
UP1	set	-160*50
OFF	set	0
	REPT	DEPTH
	move.b	(a0),UP3(a1)
	move.b	(a0),UP2(a1)
	move.b	(a0),UP1(a1)
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160		;go down a line
UP1	set	UP1+160		;go down a line
UP2	set	UP2+160		;go down a line
UP3	set	UP3+160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
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



vu	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	lsr.w	#1,d0			;/2 for colours 0-7
	lsl.w	#8,d0			;shift to next RGB pos
	or.w	hertz_col,d0
	move.w	d0,pic+4		;flash col

	moveq	#0,d0
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	lsr.w	#1,d0			;\2
	or.w	hertz_col,d0
	move.w	d0,pic+6

	moveq	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	lsl.w	#3,d0			;shift into green
	and.w	#$070,d0
	or.w	hertz_col,d0
	move.w	d0,pic+8

	rts

********************
* SERVICE ROUTINES *
********************

flip_screen	;flip between 2 screens to stop flickering
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
	ifne	FINAL
	clr.l	$24.w
	ENDC
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
	add.l	#32000,d0
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
	move.l	screen_2,a2		;for flip screen
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop
	rts


black_out				;all colours black
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts



clear_bss
	lea	bss_start,a0
.clear	clr.l	(a0)+
	cmp.l	#bss_end,a0
	blt.s	.clear
	rts


set_interrupts			;save old interrupt values
	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$120.w,old_timerb
	move.l	$134.w,old_timera
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	TBCR,old_TBCR
	move.b	TBDR,old_TBDR

	MOVE.L	#new_70,$70.W		;set new interrupt values
	MOVE.L	#timerb_part2,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
	CLR.B	TBCR.W
	CLR.B	TBDR.W
	MOVE.W	#$2300,SR
	rts				;ISRs are now running




*********
* ISRs  *
*********
new_70	;every screen update...
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7		;set colours after isr
	movem.l	d0-d7,COLOUR0.w
	bsr	tune+8
	moveq	#0,d0
	move.w	d0,vsync_flag		;own screen update rout
	move.l	d0,raster_offset
	move.w	line1_colours,raster
	tst.w	zero_counter
	beq.s	.clear
	sub.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	clr.b	TBCR.w
	move.l	#timerb_part2,$120.w
	move.b	#11,TBDR.w		;next interrupt to occur at XX lines down
	move.b	#8,TBCR.w		;set interrupt method
	rte				;let's leave before interrupt occurs


timerb_part2	move.w	#0,COLOUR4.w
raster		equ	*-4
		move.w	raster,COLOUR5.w

		clr.b	TBCR.w			;stop timerb
		movem.l	d0/a0,-(sp)		;save regs
		lea	line1_colours,a0	;colours for line 1 scroller
		move.w	raster_offset,d0	;get offset into colours
		move.w	0(a0,d0.w),raster	;set raster colour
		add.w	#2,raster_offset	;increase offset
		add.w	#1,timerb_line_count	;increase a counter
		cmp.w	#17,timerb_line_count	;check line count
		beq.s	.set_next
		movem.l	(sp)+,d0/a0
		move.b	#2,TBDR.w
		move.b	#8,TBCR.w		;enable timer b
		rte
.set_next	movem.l	(sp)+,d0/a0
		move.w	pic+2+(COLOUR4-COLOUR0),COLOUR4.w
		move.w	pic+2+(COLOUR5-COLOUR0),COLOUR5.w
		move.l	#timerb_part3,$120.w
		clr.l	raster_offset
		move.b	#18,TBDR.w
		move.b	#8,TBCR.w
		rte

timerb_part3	move.w	raster,COLOUR4.w
		move.w	raster,COLOUR6.w
		clr.b	TBCR.w			;stop timerb
		movem.l	d0/a0,-(sp)		;save regs
		lea	line2_colours,a0	;colours for line 2
		move.w	raster_offset,d0	;get offset into colours
		move.w	0(a0,d0.w),raster	;set raster colour
		add.w	#2,raster_offset	;increase offset
		add.w	#1,timerb_line_count	;increase a counter
		cmp.w	#17,timerb_line_count	;check line count
		beq.s	.set_new_timerb
		movem.l	(sp)+,d0/a0
		move.b	#2,TBDR.w
		move.b	#8,TBCR.w		;enable timer b
		rte
.set_new_timerb	movem.l	(sp)+,d0/a0
		move.w	pic+2+(COLOUR4-COLOUR0),COLOUR4.w
		move.w	pic+2+(COLOUR6-COLOUR0),COLOUR6.w
		clr.l	raster_offset
		move.l	#timerb_part4,$120.w
		move.b	#18,TBDR
		move.b	#8,TBCR
		rte

timerb_part4	move.w	raster,COLOUR4.w
		move.w	raster,COLOUR6.w
		clr.b	TBCR.w			;stop timerb
		movem.l	d0/a0,-(sp)		;save regs
		lea	line3_colours,a0	;colours for line 3
		move.w	raster_offset,d0	;get offset into colours
		move.w	0(a0,d0.w),raster	;set raster colour
		add.w	#2,raster_offset	;increase offset
		add.w	#1,timerb_line_count	;increase a counter
		cmp.w	#17,timerb_line_count	;check line count
		beq.s	.set_new_timerb
		movem.l	(sp)+,d0/a0
		move.b	#2,TBDR.w
		move.b	#8,TBCR.w		;enable timer b
		rte
.set_new_timerb	movem.l	(sp)+,d0/a0
		move.w	pic+2+(COLOUR4-COLOUR0),COLOUR4.w
		move.w	pic+2+(COLOUR6-COLOUR0),COLOUR6.w
		clr.l	raster_offset
		move.l	#timerb_part5,$120.w
		move.b	#18,TBDR
		move.b	#8,TBCR
		rte

timerb_part5	move.w	raster,COLOUR4.w
		move.w	raster,COLOUR7.w
		clr.b	TBCR.w			;stop timerb
		movem.l	d0/a0,-(sp)		;save regs
		lea	line4_colours,a0	;colours for line 4
		move.w	raster_offset,d0	;get offset into colours
		move.w	0(a0,d0.w),raster	;set raster colour
		add.w	#2,raster_offset	;increase offset
		add.w	#1,timerb_line_count	;increase a counter
		cmp.w	#17,timerb_line_count	;check line count
		beq.s	.set_new_timerb
		movem.l	(sp)+,d0/a0
		move.b	#2,TBDR.w
		move.b	#8,TBCR.w		;enable timer b
		rte
.set_new_timerb	movem.l	(sp)+,d0/a0
		move.w	pic+2+(COLOUR4-COLOUR0),COLOUR4.w
		move.w	pic+2+(COLOUR7-COLOUR0),COLOUR7.w
		rte





******************************
	SECTION DATA
******************************

line1_colours	dc.w	$003,$00b,$004,$00c,$005,$00d,$006,$00e
		dc.w	$007,$00f,$00f,$00f,$00f,$00f,$00f,$777
line2_colours	dc.w	$00f,$08f,$01f,$09f,$02f,$0af,$03f,$0bf
		dc.w	$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$777
line3_colours	dc.w	$ff0,$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40
		dc.w	$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$777
line4_colours	dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$700,$e00
		dc.w	$600,$d00,$500,$c00,$400,$b00,$300,$777

scroll_pointer	dc.l	init_scroll_text
init_scroll_text
 dc.b "                                   "
 dc.b "                                   "
 dc.b "                                   "
 dc.b "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
scroll_text
 dc.b "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
 dc.b "            WELCOME TO PERSISTENCE OF VISION 122.        "
 dc.b "CREDITS:      MENU CODED BY MAC SYS DATA,      "
 dc.b "GRAFIX BY OZ    AND    MUSIC BY JEDI.       "
 dc.b "RELEASE DATE 30 AUG 1992.        "
 dc.b "YOU MAY HAVE NOTICED THAT THIS DISC IS RATHER STE "
 DC.B "ORIENTATED.   I PURPOSELY HELD ONTO THE SOUNDOFF STE DEMO "
 DC.B "SO I COULD RELEASE ANOTHER STE ONLY DISC.   I HAVE SOME SMALL STE "
 DC.B "ONLY DEMOS LINED UP BUT I'LL USE THEM AS FILLERS ON FUTURE DISCS. "
 DC.B "     OKAY TIME AND DISC SPACE IS SHORT SO I'LL END IT HERE. "
 DC.B "  QUICK GREETS TO MOOKIE (ADR),   BART (TOWER PD),   "
 DC.B "MUG UK (THE SOURCE),   BILBO (RIPPED OFF)   AND   PURE ENERGY.   "
 DC.B "   SLAGGING TO 'PACK-MAN' OF "
 DC.B "U.P.A. ----- YOU ARE A LAMER, STOP RIPPING THINGS OFF P.O.V. DISCS "
 DC.B "AND CHANGING THE TEXT TO SAY YOU PACKED IT.   I WOULDN'T MIND IF "
 DC.B "YOU LEFT THE CREDITS ON BUT TO DIRECTLY TAKE STUFF OFF A P.O.V. DISC "
 DC.B "AND CLAIM YOU PACKED IT IS OVER THE TOP.                OH YEAH BEFORE "
 DC.B "I GO I WOULD LIKE TO SAY SOMETHING TO ALL CREWS WHO ARE USING MY CODE"
 DC.B "....    CREDIT ME YOU LAMERS, I GAVE MY CODE AWAY FREELY AND ALL "
 DC.B "I WANT IS RECOGNITION FOR THE HOURS I SPENT IN FRONT OF MY STE.  "
 DC.B "I AM NOW ADOPTING A NEW POLICY OF NOT GIVING AWAY MY SOURCE CODE "
 DC.B "AS VERY FEW PEOPLE CREDIT ME OR GREET ME WHEN IT'S OBVIOUS THAT "
 DC.B "THE CODE IS MINE.                           "
 DC.B "                                                           WRAP  "
 dc.b $ff
	even


font	dcb.b	DEPTH*4,0
	incbin	1plane.fnt


font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,46,48,00,00,00,00,48,41,42,44,00,27,43,28,45

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,30,29,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,49,50,48,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even

tune	incbin	dedicace.thk
	even

pic	incbin	pic.PI1			;main menu pic


********** valid key press table
key_codes		;comment out keys you don't want to use
	dc.b	2,0	;key 1
	dc.b	3,1	;key 2
	dc.b	4,2	;key 3
	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5
;	dc.b	7,5	;key 6
;	dc.b	8,6	;key 7
;	dc.b	9,7	;key 8
;	dc.b	10,8	;key 9

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1	;keypad 2
	dc.b	$6f,2	;keypad 3
	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,4	;keypad 5
;	dc.b	$6c,5	;keypad 6
;	dc.b	$67,6	;keypad 7
;	dc.b	$68,7	;keypad 8
;	dc.b	$69,8	;keypad 9

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
;		dc.l	filename5
;		dc.l	filename6
;		dc.l	filename7
;		dc.l	filename8
;		dc.l	filename9


*** filenames no longer need to be 16 bytes long but must end
*** in 0 and must be on an even address...
****
**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"T_WORLD.STE",0
	even
filename2	dc.b	"$$SOUNDOFF.STE",0
	even
filename3	dc.b	"adm2",0
	even
filename4	dc.b	"COPIER",0
	even
;filename5	dc.b	"copier.pov",0
;	even
;filename6	dc.b	"filename.ext",0
;	even
;filename7	dc.b	"filename.ext",0
;	even
;filename8	dc.b	"filename.ext",0
;	even
;filename9	dc.b	"filename.ext",0
;	even



*************************
	SECTION BSS	
*************************
bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal		ds.b	32		;old colours

zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1


*** store for old ISR data
old70		ds.l	1
old_timera	ds.l	1
old_timerb	ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
old_TBCR	ds.b	1		;old timer B control
old_TBDR	ds.b	1		;old timer B data
	even

black			ds.b	32	;32 bytes of nothing...

;KEEP THESE TOGETHER OR IT WILL BUGGER UP
raster_offset		ds.w	1
timerb_line_count	ds.w	1
;*****************************************

char_offset		ds.w	1

org_rez			ds.w	1	;original rez
hertz_switch		ds.w	1	;hertz toggle check
hertz_col		ds.w	1	;hertz colour

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	32000		;two screens
	ds.b	32000
bss_end