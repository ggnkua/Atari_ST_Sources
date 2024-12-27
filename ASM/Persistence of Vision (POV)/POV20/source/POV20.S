*************************
* POV 20                *
*************************

BUFFER_SIZE:	EQU	160*24+(32*24)
WIDTH:		EQU	32
BASE:		EQU	$66000	;put screen at $66000 when finally assembling
			;for 512K machines.
	bra	start
 dc.b "HELLO MR WISE GUY               "
 dc.b "WHAT DO YOU WANT?     IF YOU'RE LOOKING FOR THE TUNE OR "
 DC.B "SCREEN TRANSFER ROUTINE THEN HAVE A LOOK AT THE END OF THE "
 DC.B "PROGRAM...   THE TUNE IS ONLY 4 AND A HALF K LONG, SO IT "
 DC.B "SHOULD BE EASY TO STEAL (IT WAS EASY FOR ME TO STEAL!).   "
 DC.B "OK, HAVE FUN STEALING BUT PLEASE GIVE ME A MENTION IN THE "
 DC.B "GREETINGS ON YOUR PROGRAMS, ETC...  TA - M.S.D. 5.6.90.       "
	EVEN
start:
	move.l	sp,a5
	move.l	4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
wait_for_drive:
	move.w	$ff8604,d0
	btst	#7,d0
	bne.s	wait_for_drive
	clr.w	$444	;no verify

	bsr	hide_cursor
	bsr	save_pal
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez
	bsr	set_palette
	bsr	clear_lower_border
	bsr	transfer
	bsr	set_up_for_border
;the next two lines are to prevent a screen OFFSET on STE machines.
	clr.w	$ff8264 ;STE bit wise shift
	move.w	#$ff00,$ff820e

;************************************************************************
;*                          SUPER STUNTMAN                              *
;*                          --------------                              *
;* Stolen by: MAC SYS DATA of P.O.V. 05/09/89 20:30                     *
;*      From: AUTOMATION disc 117                                       *
;* Include files:-                                                      *
;*                 AUTO117.IMG into TUNE                                *
;************************************************************************
	move.b	$484,old484
	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION 117
; 1=Jingle
; 2=Jingle
	move.l	#0,D0
	jsr	tune

	bsr	show_hertz

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
;	move.w	(sp)+,$ffff8240.w
	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	eor.w	#$ffff,toggle
	bsr.s	show_hertz
	move.w	#10,zero_counter
	bra	main_loop

show_hertz:
	tst.w	toggle
	bne.s	not_50
	pea	in50
	bra.s	print
not_50:	pea	in60
print:	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#5,d0		;4 key
	bge	main_loop

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

	move.b	old484,$484
;key is in D0.L
	and.l	#$ff,d0
	cmp.b	#4,d0	;3 key
	beq.s	run_info
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	black_pal
; poke filename to screen
	move.l	old_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	bsr	user_mode
	clr.w	-(sp)		;to AUTORUN in AUTO folder
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp

run_info:
	tst.w	toggle
	beq.s	hz50i
	eor.b	#2,$ff820a
hz50i:
	pea	0
	pea	be
	pea	info
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	clr.w	-(sp)
	trap	#1
	
exit:	bsr	isr_off
	move.b	old484,$484
;reset rez
	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal
	bsr	show_cursor
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************


***************
* SUBROUTINES *
***************
scroll:
	move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	
	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0	;get letter
	move.l	a6,line_ptr
	cmp.b	#32,d0
	beq.s	space
	cmp.b	#"a",d0
	bge.s	letter
	cmp.b	#"!",d0
	beq.s	exclaim
	cmp.b	#".",d0
	beq.s	fullstop
	cmp.b	#"'",d0
	beq.s	invert
	cmp.b	#",",d0
	beq.s	comma
	cmp.b	#"?",d0
	beq.s	question
	cmp.b	#"2",d0
	beq.s	n2
	cmp.b	#"0",d0
	beq.s	n0
letter:
	sub.w	#65,d0	;NOT ASCII BOUND - A=65, B=66, C=67
	mulu	#16*24,d0
	lea	font_set,a6
	add.l	d0,a6	;letter address is in a6
	bra.s	put
n0:	lea	font+384*41,a6
	bra.s	put
n2:	lea	font+384*43,a6
	bra.s	put
fullstop:
	lea	font+384*39,a6
	bra.s	put
exclaim:
	lea	font+384*35,a6
	bra.s	put
invert:
	lea	font+384*31,a6
	bra.s	put
question:
	lea	font+384*36,a6
	bra.s	put
comma:
	lea	font+384*37,a6
	bra.s	put
space:	lea	font,a6
;transfer letter into buffer
; each line in buffer is 160+16 bytes long.
put:	move.w	#24-1,d0
	lea	buffer+160,a1
put2:	movem.l	(a6),d2/d3/d4/d5
	movem.l	d2/d3/d4/d5,(a1)
	add.w	#16,a6
	add.w	#160+16,a1
	dbf	d0,put2

loop2:
	lea	buffer,a5	;scroll buffer
	move.l	a5,a4
	move.w	#3-1,d1
planes:	
	move.w	#24-1,d0
loopy:
	roxl	168(a5)
	roxl	160(a5)
	roxl	152(a5)
	roxl	144(a5)
	roxl	136(a5)
	roxl	128(a5)
	roxl	120(a5)
	roxl	112(a5)
	roxl	104(a5)
	roxl	96(a5)
	roxl	88(a5)
	roxl	80(a5)
	roxl	72(a5)
	roxl	64(a5)
	roxl	56(a5)
	roxl	48(a5)
	roxl	40(a5)
	roxl	32(a5)
	roxl	24(a5)
	roxl	16(a5)
	roxl	8(a5)
	roxl	(a5)

	add.w	#160+16,a5
	dbf	d0,loopy
	addq.w	#2,a4	;next plane
	move.l	a4,a5
	dbf	d1,planes
	sub.w	#1,scroll_number
	rts


show_buffer:	;puts scrolline buffer to screen
	lea	buffer,a0
	move.l	#BASE+32320,a1
	move.w	#24-1,d0
.loop:
	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.w	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.w	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.w	28(a0),28(a1)
	move.l	32(a0),32(a1)
	move.w	36(a0),36(a1)
	move.l	40(a0),40(a1)
	move.w	44(a0),44(a1)
	move.l	48(a0),48(a1)
	move.w	52(a0),52(a1)
	move.l	56(a0),56(a1)
	move.w	60(a0),60(a1)
	move.l	64(a0),64(a1)
	move.w	68(a0),68(a1)
	move.l	72(a0),72(a1)
	move.w	76(a0),76(a1)
	move.l	80(a0),80(a1)
	move.w	84(a0),84(a1)
	move.l	88(a0),88(a1)
	move.w	92(a0),92(a1)
	move.l	96(a0),96(a1)
	move.w	100(a0),100(a1)
	move.l	104(a0),104(a1)
	move.w	108(a0),108(a1)
	move.l	112(a0),112(a1)
	move.w	116(a0),116(a1)
	move.l	120(a0),120(a1)
	move.w	124(a0),124(a1)
	move.l	128(a0),128(a1)
	move.w	132(a0),132(a1)
	move.l	136(a0),136(a1)
	move.w	140(a0),140(a1)
	move.l	144(a0),144(a1)
	move.w	148(a0),148(a1)
	move.l	152(a0),152(a1)
	move.w	156(a0),156(a1)
	add.w	#160,a1
	add.w	#160+16,a0
	dbf	d0,.loop
	rts


*************************************
* INTERRUPT SERVICE ROUTINES (ISRs) *
*************************************
vert_isr:	;$70
	CLR.B	$FFFF8260.W
	MOVEM.L D0-d7,-(A7)

	MOVEM.L pic+2(PC),d0-d7
	MOVEM.L d0-d7,$FFFF8240.W

	clr.w	$ff8264 ;STE bit wise shift
	move.w	#$ff00,$ff820e

	move.l	a0,d0
	move.l	pal_position,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_colour_reset
	move.l	#pal_table,pal_position
no_colour_reset:
	move.l	d0,a0
	MOVEM.L (sp)+,D0-d7
	MOVE.B	#49,counter	;49/50 of a second

	MOVE.L	#horiz_isr,$120.W
	clr.w	horiz_sync

	movem.l d0-d7/a0-a6,-(sp)
	jsr	tune+$e
;flash the disc drive light
	move.b	#8,$ff8800
	move.b	$ff8800,d7
	cmp.b	#15,d7
	blt.s	no_flash
	move.b	#14,$ff8800
	bclr	#1,$ff8802
	movem.l (sp)+,d0-d7/a0-a6
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	#3,$FFFFFA21.W
	rte
no_flash:
	move.b	#14,$ff8800
	or.b	#%00000010,$ff8802
	movem.l (sp)+,d0-d7/a0-a6
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	#3,$FFFFFA21.W
	rte

horiz_isr:	;$120
	move.b	#4,$fffffa21.w	;4/50 of a second (a frame) makes it in the
	move.l	#go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	98
	nop
	ENDR
	CLR.B	$FFFF820A.W
	REPT	29
	nop
	ENDR
	MOVE.B	#2,$FFFF820A.W
f1:	MOVE.L	#intheborder,$120.W
	rte

intheborder:
	;move.b	#0,$ffff8260.w	;(can be changed to get a med rez scroller)
	clr.b	$fffa1b
	move.l	#$02250447,$ffff8242.w
	move.l	#$01140336,$ffff8246.w
	bclr	#0,$fffa0f
	rte

********************
* SERVICE ROUTINES *
********************

set_up_for_border:
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


clear_lower_border:
	move.l	#BASE,a0
	add.l	#32000,a0
	move.w	#47-1,d0
clr_:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,clr_
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

transfer:
	move.l	#BASE,a0
	add.w	#32000,a0
	lea	pic+34,a1
	add.w	#32000,a1
line	move.l	#BASE,a2
	lea	-160(a1),a1
	cmp.l	#pic,a1		;are we at top of the pic?
	ble.s	transfer_done
build_line:
	movem.l	(a1)+,d0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	lea	-160(a1),a1
	cmp.l	a0,a2
	bne.s	build_line
	lea	-160(a0),a0
	bra.s	line
move_block:
	movem.l	d0-d7,(a2)
	lea	$20(a2),a2
	moveq	#3,d0
t_wait:	dbf	d0,t_wait
	rts
transfer_done:
	rts

pause:	move.w	d0,-(sp)
	move.w	#1000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
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
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

black_pal:
	lea	$ffff8240.w,a0
	move.w	#8-1,d0
.loop:	clr.l	(a0)+
	dbf	d0,.loop
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
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

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
ei_mouse:
	dc.b	$14,8
	even
di_mouse:
	dc.b	$12,$1a
	even

	ds.l	40

********
* Data *
********
	section data
pal_position:	dc.l	pal_table
pal_table:
	dc.w	$f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w	$f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w	$eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w	$aF0,$270,$9F0,$170,$8F0,$070,$0F1,$078
	dc.w	$0F2,$079,$0F3,$07A,$0F4,$07B,$0F5,$07C
	dc.w	$0F6,$07D,$0F7,$07E,$0E7,$06F,$0D7,$05F
	dc.w	$0C7,$04F,$0B7,$03F,$0A7,$02F,$097,$01F
	dc.w	$087,$00F,$806,$10E,$905,$20D,$A04,$30C
	dc.w	$B03,$40B,$C02,$50A,$D01,$609
	dc.w	$ffff
	dc.w	$f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w	$f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w	$eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w	$aF0,$270,$9F0,$170,$8F0,$070,$0F1,$071
	dc.w	$0F2,$072,$0F3,$073,$0F4,$074,$0F5,$075


stack_save:	dc.l	0
old70:	dc.l	0
old120: dc.l	0
olda07: dc.l	0
olda09: dc.b	0
olda17: dc.b	0
olda1b: dc.b	0
olda21: dc.b	0
old484:	dc.b	0
toggle:	dc.w	0	;50 hertz
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

scroll_number:	dc.w	32
old_pal:	ds.b	32
line_ptr:
	dc.l	scroll_line

scroll_line:
 dc.b "MAC SYS DATA PRESENTS "
 dc.b "DISC 20.  "
 dc.b "ALL CODE AND GRAFIX BY "
 dc.b "MAC SYS DATA.   "
 dc.b "MUSIC STOLEN FROM SUPER STUNT MAN BY MAC SYS DATA.      "
 DC.B "WELL HERE WE ARE AGAIN WITH SOME MORE PACKED DEMOS ON OUR "
 DC.B "20TH DISC.  ON THIS ONE IS THE FIRST EVER PACKED STE ONLY DEMO, "
 DC.B "IT WAS WRITTEN BY THE OVERLANDERS AND IS RATHER SIMPLE BUT IT "
 DC.B "DOES SHOW OFF THE STE'S DMA SOUND AND HARDWARE SCROLLING.    "
 DC.B "THIS IS OUR 20TH DISC AND I'M RUNNING OUT OF IDEAS FOR MENUS. "
 DC.B "I DIDN'T REALLY WANT TO USE THE SAME OLD MENU CODE LIKE AUTOMATION "
 DC.B "AND OUR DEMO PACKING COMPETETER 'STEW'.  I'LL TRY TO TAKE TIME OUT "
 DC.B "AND WRITE A COUPLE OF NEW MENUS.     THE HARDEST PART OF DOING THESE "
 DC.B "DISCS IS WRITING THE MENU CODE AND SCROLLINES, IF I WANTED I COULD "
 DC.B "JUST PUT A SCREEN UP SAYING PRESS CERTAIN KEYS FOR THE FOLLOWING "
 DC.B "DEMOS AND NOT HAVE A TUNE OR SCROLLER BUT THAT WOULD BE CRAPPY AND CHEAP. "
 DC.B "      I'LL TRY TO GET SOME EFFECTS ON FUTURE DISCS LIKE BOUNCING LOGOS AND "
 DC.B "TRACKING SPRITES, ETC.        I'M SORRY FOR THE SLIGHT GLITCH THAT APPEARS "
 dc.b "IN THE SCROLLER BUT THE SCROLL ROUTINE USES ROXL AND I SCROLL FOUR PIXELS "
 dc.b "EVERY FRAME THEN TRANSFER THE SCROLLINE TO THE SCREEN. I SHOULD HAVE WRITTEN "
 dc.b "A PROPER SCROLLER THAT SCROLLED THE SCREEN FOUR TIMES OR USED FOUR CHARACTER "
 dc.b "SETS BUT NEVER MIND, THE MENU IS BASICALLY THE SAME.         RIGHT THAT'S ALL I'M GOING TO SAY "
 DC.B "ON THIS ONE 'COS I CAN'T BE ARSED TYPING ANY MORE......  BYE... M.S.D.     "
 DC.B "                                            "
	dc.b	$ff,$ff,$ff,$ff
	even
in50:	dc.b	27,'Y86',"50 Hertz PAL ",0
	even
in60:	dc.b	27,'Y86',"60 Hertz NTSC",0
	even
font:
	dcb.b	0,384	;one chars length
font_set:
	incbin	"32x24.fnt"
	even
pic	incbin	"pov20.PI1"
	even
tune:	incbin	"auto117.img"
	even
filenames:
	dc.b	"ALF.MSD",0,0,0,0,0,0,0
	dc.b	"STE_ACID.MSD",0,0
info:	dc.b	"INFO20.POV",0,0,0,0
	even
buffer: dcb.b	0,BUFFER_SIZE
be: