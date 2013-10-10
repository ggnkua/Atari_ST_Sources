***************
* P.O.V. 39    *
****************

	BRA.S	start
 dc.b "Hello asshole, you must be lame looking "
 dc.b "around here for something to steal unless you're stealing "
 dc.b "the tune.   bye         "
start:
	bsr	set_super
	bsr	wfd
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	set_1low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484
;************************************************************************
;*                            MENACE                                    *
;*                            ------                                    *
;* Stolen by: MAC SYS DATA of P.O.V. 19/08/90 10:42                     *
;*      From: NEW ORDER 8                                               *
;* Include files:-                                                      *
;*                 MENACE.IMG into TUNE                                 *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=tune 0
; 1=tune 1 - main theme
; 2=tune 2

	moveq	#0,D0
	BSR	tune

	bsr	set_palette
	bsr	set_for_border
	bsr	show_pic
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
	beq	zero
carryon	cmp.b	#$53,d0
	beq.s	do_reset
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#5,d0		;4 key
	bge.s	main_loop	

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

	tst.w	hz_switch
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

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484
	bsr	user_mode

	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
scroll:
	move.l	screen_base,a1
	add.w	#160*203,a1
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
	mulu	#120,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1
	tst.w	d4
	beq.s	.skip
	add.w	#6,a1
.skip	not.w	d4
	addq.w	#1,d6
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5
	tst.b	(a5)
	bpl	next_char
	lea	scroll_text,a5
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

zero	tst.w	zero_counter
	beq.s	aa
	sub.w	#1,zero_counter
	bra	carryon
aa:	eor.w	#$111,bor+2
	eor.w	#$ffff,hz_switch
	move.w	#10,zero_counter
	bra	main_loop

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
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
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

set_1low_rez:
	move.l	screen_base,a0
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
	lea	masks,a2
	move.w	#14-1,d3	;14 masks
.loop1:
	bsr	vsync
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#10-1,d2
.loop2:	move.w	#20-1,d1
.loop3:	move.w	#20-1,d0
.loop4:	move.w	(a2),d4
	move.w	(a0),d5
	and.w	d4,d5
	move.w	d5,(a1)

	move.w	(a2),d4
	move.w	2(a0),d5
	and.w	d4,d5
	move.w	d5,2(a1)

	move.w	(a2),d4
	move.w	4(a0),d5
	and.w	d4,d5
	move.w	d5,4(a1)

	move.w	(a2),d4
	move.w	6(a0),d5
	and.w	d4,d5
	move.w	d5,6(a1)

	add.w	#2,a2
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop4
	sub.w	#20*2,a2

	sub.w	#160*20,a0
	sub.w	#160*20,a1

	add.w	#8,a0
	add.w	#8,a1
	dbf	d1,.loop3

	add.w	#19*160,a0
	add.w	#19*160,a1
	dbf	d2,.loop2

	add.w	#20*2,a2
	dbf	d3,.loop1
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
	move.w	#40*47,d0
clr	clr.l	(a0)+
	dbf	d0,clr
	rts

wfd:	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wfd
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
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
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
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	tune+$e
	clr.w	vsync_flag
	move.w	pic+4,$ffff8242.w
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
	movem.l	d0/a0,-(sp)
bor	move.w	#$345,$ffff8240.w
	lea	pal_table,a0
	move.w	#30-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	move.w	pic+2,$ffff8240.w
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$300,$b00,$400,$c00,$500,$d00,$600,$e00
	dc.w	$700,$f00,$f10,$f10,$f20,$f20,$f30,$f30
	dc.w	$f40,$f40,$f50,$f50,$f60,$760,$d70,$670
	dc.w	$c70,$570,$b70,$470,$a70,$370


********
* Data *
********
	SECTION DATA
hz_switch	dc.w	0
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
zero_counter:	dc.w	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                   MAC SYS DATA PRESENTS - P.O.V. 39    "
 DC.B "ALL CODING BY M.S.D., ART BY ALY, THE MUSIC WAS RIPPED FROM "
 DC.B "MENACE BY MAC SYS DATA         P.O.V. CONSISTS OF THE "
 DC.B "FOLLOWING MEMBERS ...   MAC SYS DATA (CODER/HACKER/PACKER),   "
 DC.B "BORIS (CODER),   OZYMANDIAS (GRAPHIX ARTIST)   AND ALY "
 DC.B "(GRAPHIX).           "
 DC.B "GREETINGS TO...    "
 DC.B "AUTOMATION,   DR.SYNE,   DTB,   MEDWAY BOYS,   POMPEY PIRATES,   SEWER SOFTWARE,   "
 DC.B "TCB,   AND   THE LOST BOYS.         SPECIAL SUPPLIERS GREETINGS "
 dc.b "TO   GEORGE,   THE DEMO CLUB   AND   "
 DC.B "SOUTHWEST SOFTWARE LIBRARY.        CONGRATULATIONS TO THE FOLLOWING "
 DC.B "FOR WRITING A LOT OF NEW DEMOS.... THE SKUNK,   TRAX,   ABC CREW   "
 DC.B "AND   A.C.N. (T.MARTENS AND M.KLUM).         "
 dc.b "I'M SORRY FOR NOTHING MOVING BUT THERE ISN'T ENOUGH DISC SPACE LEFT TO DO "
 DC.B "ANYTHING DECENT.    DISC 40 WILL BE RELEASED AS SOON AS I'VE "
 DC.B "CODING AN INFO PROGRAM.     PERSISTENCE OF VISION HAS NOW BEEN "
 DC.B "PACKING DEMOS FOR ABOUT 18 MONTHS INFACT IT WAS EXACTLY 12 MONTHS AGO "
 DC.B "THAT I WAS CODING DISC 8!   SO THAT'S 31 MENU DISCS IN 12 MONTHS PLUS "
 DC.B "A SOUNDTRACKER MENU FOR THE DEMO CLUB PLUS A COUPLE OF DEMOS "
 DC.B "AND TO TOP IT ALL I'M STILL THE MAIN DISTRIBUTOR FOR OTHER PEOPLES "
 DC.B "COMPACTS!        IF YOU THINK THAT I SPEND ALL MY TIME ON MY COMPUTER "
 DC.B "THEN YOU'RE DEAD RIGHT!!!    I ALSO HAVE A FULL TIME JOB INSTALLING "
 DC.B "COMPUTER AND NETWORK EQUIPMENT (ETHERNET MAINLY BUT ALSO EPS80 (BT) LINES "
 DC.B "AND ALL INTERNAL LINKS IN BUILDINGS). I EVEN GET TO PLAY WITH SOME PC'S "
 DC.B "BUT THAT'S JUST MESSING BECAUSE I WAS TOLD I WASN'T GOOD ENOUGH TO "
 DC.B "SET PC SOFTWARE UP - (IT'S THE STUPID SYSTEM WHERE I WORK - THE PASS "
 DC.B "MARK IS 80 PERCENT AND I GOT 78 SO I DIDN'T GET THE JOB EVEN "
 DC.B "THOUGH I'VE BEEN DOING IT FOR 12 MONTHS PLUS MOST OF THE OTHER "
 DC.B "PROGRAMMERS AT WORK COULDN'T GET 50 PERCENT!)  "
 DC.B "      WELL I'VE HAD ENOUGH AND DISC SPACE IS RUNNING OUT SO I'LL WRAP IT "
 DC.B "UP.   BYE......                                                "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	"was274.fnt"
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

tune:	Incbin	menace.img
	even
pic	incbin	"pov39.PI1"
	even

masks:
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000

	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000

	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000

	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110

	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000000110000000
	dc.w	%0000000110000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000001111000000
	dc.w	%0000001111000000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000011111100000
	dc.w	%0000011111100000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000111111110000
	dc.w	%0000111111110000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0001111111111000
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0011111111111100
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

filenames:
	dc.b	"ACID.MSD",0,0,0,0,0,0
	dc.b	"SCREE.MSD",0,0,0,0,0
	dc.b	"COPIER.POV",0

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
