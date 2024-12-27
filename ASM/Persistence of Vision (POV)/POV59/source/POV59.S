***************************
*        P.O.V. 59        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0
	move.l	a0,present_base
	bsr	set_low_rez
	bsr	show_ripped_off
	bsr	show_pov_logo
	bsr	copy_screens
	move.b	$484,old484
	clr.b	$484

;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 16/12/90 20:50                     *
;*      From: AUTOMATION disc 345                                       *
;* Include files:-                                                      *
;*                 FILENAME.IMG into TUNE                               *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=tune 0
; 1=tune 1
; 2=tune 2
; 3=tune 3
; 4=tune 4

	move.l	#2,D0
	jsr	tune

	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	set_bounce_count
	bsr	flush
main_loop:
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

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
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
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
scroll	move.l	present_base,a6
	lea	160*204(a6),a6
	movem.l	black,d0-d7/a0-a5
OFF	set 0
	REPT	120
	movem.l	d0-d7/a0-a5,OFF(a6)
OFF	set	OFF+56
	ENDR

	move.w	sine_number,d0
	cmp.w	sine_count,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.w	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.w	#1,sine_number
	move.l	present_base,a1
	lea	160*204(a1),a1
	add.w	d0,a1
	move.l	a1,last_scroll
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#124*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#124,d0		;character depth * 4 (31*4)
	add.w	d0,a0
.column
OFF	set	0
	REPT	31
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
	rts

flip_screen
	add.w	#1,screen_number
	cmp.w	#4,screen_number
	blt.s	.no_reset
	clr.w	screen_number
.no_reset
	moveq.l	#0,d0
	move.w	screen_number,d0
	mulu	#40192,d0
	move.l	screen_base,a0
	add.l	d0,a0
	move.l	a0,present_base
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$ffff8201,a0
	movep.w	d0,(a0)
	bsr	vsync
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
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
set_p	lea	$ffff8240.w,a1
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
	bsr	clear_below_screen
	rts

copy_screens
	move.l	screen_base,a1
	move.l	a1,a2
	add.l	#40192,a2
	move.l	a2,a3
	add.l	#40192,a3
	move.l	a3,a4
	add.l	#40192,a4
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,d7
	move.l	d7,(a1)+
	move.l	d7,(a2)+
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	dbf	d0,.loop

	move.l	screen_base,a0
	add.w	#160*120,a0
	add.l	#40192,a0
	move.l	a0,a1
	add.l	#40192,a1
	move.l	a1,a2
	add.l	#40192,a2
	lea	picdata,a6
	move.w	#56-1,d0
.loop2	REPT	(160/4)
	move.l	(a6),(a0)+
	move.l	8960(a6),(a1)+
	move.l	8960+8960(a6),(a2)+
	add.w	#4,a6
	ENDR
	dbf	d0,.loop2
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


wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
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
	move.w	#1005,d7
	movem.l	black,d0-d6/a1
.loop	movem.l	d0-d6/a1,(a0)
	movem.l	d0-d6/a1,32(a0)
	movem.l	d0-d6/a1,64(a0)
	movem.l	d0-d6/a1,96(a0)
	movem.l	d0-d6/a1,128(a0)
	lea	160(a0),a0
	dbf	d7,.loop
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
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
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

set_bounce_count
	lea	sine_table,a0
	moveq.l	#0,d0
.loop	add.w	#1,d0
	cmp.w	#-1,(a0)+
	bne.s	.loop
	sub.w	#1,d0
	move.w	d0,sine_count
	rts

show_ripped_off
	move.l	screen_base,a1
	lea	ripped_off+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	ripped_off+2,a0
	bsr	set_p
	move.w	#500,d7	;10 seconds
.loop2	sub.w	#1,d7
	beq.s	.ex
	bsr	v_sync
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	.loop2
	bsr	get_key
	bsr	black_out
	rts
.ex	bsr	black_out
	rts

show_pov_logo
	bsr	black_out
	move.l	screen_base,a1
	lea	pov_logo+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	pov_logo+2,a1
	bsr	fadein
	move.w	#150,d7	;3 seconds
.loop2	sub.w	#1,d7
	beq.s	.ex
	bsr	v_sync
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	.loop2
.ex	lea	black,a1
	bsr	fadein
	bsr	flush
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

fadein
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
FADEIN:	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1 LEA	PALREG,A0	;LEA PALREG+2,A0; TARGET IN A1
	MOVE #16-1,D7
FADEIN2 BSR MODIFY
	ADDQ #2,A0
	ADDQ #2,A1
	DBRA D7,FADEIN2
	MOVE #4,D0
	bsr	WAIT
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS

WAIT:	BSR.S owvbl
	DBRA D0,WAIT
	RTS

owvbl:	MOVEM.L D0-D2/A0-A2,-(SP)
	MOVE.W #37,-(sp)
	TRAP #14
	ADDQ.L #2,SP
	MOVEM.L (SP)+,D0-D2/A0-A2
	RTS
PALREG:	EQU $FF8240


MODIFY:	MOVE (A0),D0 ;PALREG
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4 ;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
 MDN1:	SUBQ #1,D4
 MOK1:	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
 MDN2:	SUB #$10,D4
 MOK2:	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
 MDN3:	SUB #$100,D4
 MOK3:	MOVE D4,(A0)
	RTS


*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	jsr	tune+4
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
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
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.b	$fffffa1b.w	;DI all other interrupts
	bclr	#0,$fffa0f
	rte

********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$777,$677,$667,$566,$556,$455,$445
	dc.w	$344,$334,$233,$223,$126,$112,$011,$001

zero_counter:	dc.w	0
screen_base:	dc.l	0
present_base:	dc.l	0
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
screen_number	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 59.    "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC FROM ?????? (STOLEN "
 dc.b "FROM AUTOMATION 345).  "
 dc.b "   BEFORE I GET IN MY USUAL WAFFLE MODE I WOULD LIKE TO SAY A "
 DC.B "WORD TO BORIS......  PLEASE HACK THIS MENU AS YOU MAY BE "
 DC.B "SURPRISED AT WHAT IS EXACTLY HAPPENING (HERE IS A HINT... "
 DC.B "I USE ADDRESS FFFF8201)         "
 dc.b "WELL IT'S A SUNDAY AND VERY SOON I'LL BE VISITING "
 DC.B "A PUBLIC HOUSE FOR A JAR OR TWO OR THREE OR FOUR OR FIVE!!! "
 DC.B "  TODAY HAS BEEN PRETTY USUAL, THAT IS TO SAY THAT I WENT "
 DC.B "OUT ON MY MOTORCYCLE WITH 4 OTHER BIKERS UPTO 'DEVILS BRIDGE' "
 DC.B "(KIRBY LONGDALE). AS USUAL ON THE WAY BACK WE ALL WENT "
 DC.B "STUPID AND DID SOME SILLY SPEEDS (WELL ALL EXCEPT 'STRANGE ANDY')."
 DC.B " POOR LITTLE ADRIAN WAS ON THE BACK OF MY Z650, I DON'T KNOW "
 DC.B "HOW HE HOLDS ON WHEN I START THRASHING THE BIKE.... IMAGINE "
 DC.B "DOING 80 MPH ROUND A CORNER, BRAKING HARD THEN CRANKING A BIKE "
 DC.B "OVER FOR A 90 DEGREE CORNER THAT HAS SUDDENLY APPEARED. THERE "
 DC.B "ARE OCCASIONS WHEN THE BRAKES DON'T SLOW THE BIKE DOWN "
 DC.B "QUITE ENOUGH FOR THE RAPIDLY APPROACHING CORNER. ON SUCH "
 DC.B "OCCASIONS YOU EITHER GO STRAIGHT INTO A HEDGE OR PUSH "
 DC.B "THE BIKE DOWN AND HOPE IT GOES ROUND..... IT USUALLY GOES "
 DC.B "ROUND THE CORNER AND YOU START THINKING ABOUT THE NEXT ONE! "
 DC.B "IF YOU GO THROUGH THE HEDGE, YOU WILL PROBABLY DROP THE BIKE. "
 DC.B "ONCE THE BIKE HAS STOPPED YOU JUMP UP AND EXAMINE IT FOR ANY "
 DC.B "DAMAGE, IT IS USUALLY HALF WAY THROUGH THE SURVEY THAT YOU "
 DC.B "NOTICE YOUR RIGHT NEE IS BLEEDING RATHER BADLY DUE TO HALF "
 DC.B "THE HEDGE BEING IMPLANTED INTO IT. IGNORING THE PAIN YOU "
 DC.B "CLAMBER ONTO THE BIKE AND RIDE IT THROUGH THE LARGE HOLE "
 DC.B "IN THE HEDGE AND BACK ONTO THE ROAD WHERE YOU THEN GO "
 DC.B "HOME VERY SLOWLY TO HIDE THE BIKE IN THE GARAGE UNTIL "
 DC.B "TOMORROW!  I'M SURE STICK OF RIPPED OFF WILL KNOW "
 DC.B "WHAT I MEAN!!!!!   "
 dc.b "                     HELLO AGAIN, IT IS NOW THURSDAY "
 DC.B "THE 21-2-91 AND I'VE JUST COME HOME FROM WORK.  WHILST "
 DC.B "GETTING OUT OF MY CAR TONIGHT I THOUGHT IT WAS A BIT NOISY "
 DC.B "SO I HAD A LOOK UNDER THE CAR AND FOUND OUT THAT THE "
 DC.B "EXHAUST WAS FALLING OFF ( MORE MONEY TO FORK OUT ). I MAY HAVE "
 DC.B "TO GO TO WORK ON MY BIKE IN THE MORNING ( IN MY SUIT! ).    "
 DC.B "OK, WELL I JUST RE-WROTE PART OF THIS MENU 'CAUSE IT "
 DC.B "WOULDN'T FIT ONTO THE DISC.       "
 DC.B "'AY UP IT'S TIME FOR GREETINGS....    HI TO   DR.SYNE,   "
 DC.B "MARTIAN (WOT NO DODGY DISCS?),   OZ,   BORIS,   AUTOMATION,   "
 DC.B "POMPEY PIRATES,   MEDWAY BOYS,   EMPIRE,   REPLICANTS,   "
 DC.B "LOST BOYS,   SEWER SOFTWARE,   TCB,   BASHER   AND   "
 DC.B "RIPPED OFF.....      "
 DC.B "OK SEEING THE MUSIC HAS ENDED WE MAY AS WELL WRAP... "
 DC.B "                                                       "
 dc.b $ff
	even
char_offset	dc.w	0
font:		incbin	pp43.fnt
font_offsets:
 dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58
 dc.b	59,60,61,62,63
	even
last_scroll	dc.l	0
sine_count	dc.w	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3,3
	dc.w	4,4,4
	dc.w	5,5
	dc.w	6,7,8,10,8,7,6
	dc.w	5,5,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1
	dc.w	$ffff
black	dcb.b	64,0

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

;*************************
tune:	incbin	345.img
pic	incbin	pov59B1.PI1
picdata	incbin	picparts.dat
	even
ripped_off	incbin	rip2.pi1
pov_logo	incbin	pov59a.pi1
filenames:
	dc.b	"DR.MSD",0,0,0,0,0,0,0,0,0,0
	dc.b	"ABC8.PAK",0,0,0,0,0,0,0,0
	dc.b	"GOLDEN.MSD",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	46000
