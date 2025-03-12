***************************
*        P.O.V. 58        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
BOB_OFFSET	equ	28	;alters spacing between each bob
			;must be in steps of 4
			; eg 4,8,12,16,20,24,28,32,36,40,etc...

	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0	;screen_base
	move.l	a0,a1
	add.l	#160*204,a1
	move.l	a1,last_scroll
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

;set up bobs
	lea	bob_lib_pos,a0
	move.l	present_table,a1
	move.l	a1,(a0)
	add.w	#BOB_OFFSET,a1
	move.l	a1,-6(a0)
	add.w	#BOB_OFFSET,a1
	move.l	a1,-12(a0)
	add.w	#BOB_OFFSET,a1
	move.l	a1,-18(a0)

;************************************************************************
;*                            TURRICAN                                  *
;*                            --------                                  *
;* Stolen by: MAC SYS DATA of P.O.V. 13/02/91 19:00                     *
;*      From: MEDWAY BOYS 88a                                           *
;* Include files:-                                                      *
;*                 TURRICAN.IMG into TUNE                               *
;************************************************************************
; MAD MAX TUNE.... (Look for TFMX and COSI)
;****************************************************************
; There is only one tune in this code....
; 0=Sound off
; 1=Medway boys 88a
	move.l	#1,D0
	jsr	tune

	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	return_bobs
	bsr	bobs
	bsr	scroll
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
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
hz50	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
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
scroll	move.l	last_scroll,a0
	movem.l	black,d0-d7
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	add.w	#160*31,a0
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	move.w	sine_number,d0
	cmp.w	#54-1,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.b	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.w	#1,sine_number
	move.l	screen_base,a1
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
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
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
	moveq.l	#0,d0
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
	clr.b	$fffffa1b.w	;DI all other interrupts
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte


return_bobs	move.w	last_sou_pos,d0
	bsr	return_bob
	move.w	last_wes_pos,d0
	bsr	return_bob
	move.w	last_sof_pos,d0
	bsr	return_bob
	move.w	last_lib_pos,d0
	bsr	return_bob
	rts
bobs	lea	bob_lib_pos,a6
	lea	logo+(16*16*3),a1
	bsr	do_bobs
	move.l	#bob_sof_pos,a6
	lea	logo+(16*16*2),a1
	bsr	do_bobs
	move.l	#bob_wes_pos,a6
	lea	logo+(16*16),a1
	bsr	do_bobs
	move.l	#bob_sou_pos,a6
	lea	logo,a1
	bsr	do_bobs
	rts

do_bobs	move.l	(a6),a0
	cmp.l	end_of_table,a0
	bne.s	.no_reset
	move.l	present_table,a0
.no_reset
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.w	(a0)+,d0	;x
	move.w	(a0)+,d1	;y
	move.w	d0,d2
	move.l	a0,(a6)

	lsr.w	#1,d0
	and.w	#$1f8,d0

	and.w	#15,d2
	mulu	#16*8*16,d2

	add.w	d1,d0
	move.w	d0,4(a6)
	move.l	screen_base,a0
	add.w	d0,a0

	add.w	d2,a1
	lea	16*4*16(a1),a2
	REPT	16
	move.l	(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,(a0)

	move.l	4(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,4(a0)

	move.l	8(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,8(a0)

	move.l	12(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,12(a0)

	add.w	#160,a0
	ENDR

	rts

return_bob
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	16
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	rts


********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$777,$677,$667,$566,$556,$455,$445
	dc.w	$344,$334,$233,$223,$126,$112,$011,$001

zero_counter:	dc.w	0
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
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 58 (BUG FREE "
 dc.b "VERSION - HOPEFULLY)    IF YOUR VERSION HAS NOT GOT V3 IN THE BOTTOM RIGHT "
 DC.B "OF THE SCREEN THEN IT IS AN OLD VERSION. THIS MENU WAS "
 dc.b "RE-RELEASED ON 2-7-91 BECAUSE THE NEW STE MACHINES DID NOT LIKE THE "
 dc.b "FANTASIA DEMO.   I TRACKED THE PROBLEM DOWN TO THE WAY THE "
 dc.b "CODER CHECKS FOR THE NEW TOS VERSION. IN THE FIRST STE MACHINES "
 DC.B "IT WAS 1.60, THE CODER CHECKS FOR THIS AND IF IT ISN'T CORRECT "
 DC.B "MAKES AN ALERT BOX TELLING YOU TO GO FORTH AND BUY AN STE.  NOW "
 DC.B "ATARI MADE A COCK-UP OF THE FIRST STE ROM AND SO BROUGHT ANOTHER "
 DC.B "VERSION OUT CALLED 1.62.   DUE TO THE DEMO ONLY LIKING 1.60 "
 DC.B "IT DID NOT RECOGNIZE 1.62, I HAVE NOW MADE THE DEMO WORK ON "
 DC.B "VERSIONS 1.60 AND ABOVE (IT SHOULD WORK ON THE TT NOW).         "
 dc.b "AFTER ALL THAT I THINK IT'S CREDITS TIME..... ALL CODE BY MAC "
 DC.B "SYS DATA, GRAFIX BY OZ, MUSIC FROM TURRICAN (MAD MAX) "
 dc.b "AND FONT RIPPED FROM THE POMPEY PIRATES.         "
 dc.b "THIS DISC IS FOR ALL YOU STE OWNERS (ESP THOSE WITH 1 MEG). "
 DC.B "  THESE DEMOS HAVE BEEN WAITING IN THE WINGS TO BE RELEASED "
 DC.B "BUT WERE DELAYED BECAUSE MOST STE ONLY DEMOS REQUIRE "
 DC.B "GEM TO BE INITIALISED BEFORE THEY WILL RUN.  WE AT P.O.V. BELIEVE ALL "
 DC.B "DEMOS SHOULD BE EXECUTABLE FROM THE MENU.   I HOPE I NEVER "
 DC.B "SEE A P.O.V. MENU THAT REVERTS BACK TO THE DESKTOP FOR YOU "
 DC.B "TO 'DOUBLE CLICK THAT DEMO'.     "
 dc.b "  WELL ONCE MORE THE BOBS HAVE APPEARED ON A MENU, I "
 DC.B "REALLY MUST CODE UP SOMETHING ELSE 'CAUSE I'VE USED THE BOBS "
 DC.B "ON TWO MENUS AND ONE INTRO.... (WOW!)      TODAYS DATE IS "
 DC.B "15-2-91 AND TODAY I LEFT MY JOB (SOB, SOB) BUT I START MY "
 DC.B "NEW ONE ON MONDAY THE 18TH OF FEB (YEH!).    I AM NOW OFFICIALLY "
 DC.B "A NETWORK SPECIALIST TRAINEE BUT DUE TO MY NEW JOB BEING 60 MILES "
 DC.B "AWAY I WILL HAVE LESS TIME FOR P.O.V. (BOO). I WILL CONTINUE "
 DC.B "TO RELEASE DISCS WHEN I GET TIME BUT I CAN'T PROMISE "
 DC.B "THE SAME OUTPUT AS WE HAVE HAD IN THE PAST (I'VE ALREADY TYPED "
 DC.B "THIS SOMEWHERE).        "
 DC.B "IF YOU ARE INTO WRITING 68000 AND WOULD LIKE TO JOIN P.O.V. "
 DC.B "TO WRITE MENUS THEN GET IN TOUCH VIA ANY GOOD PD LIBRARY "
 DC.B "AND SUPPLY DETAILS OR EXAMPLES OF YOUR WORK. WE ARE "
 DC.B "LOOKING FOR A MENU CODER ONLY (I WILL STILL PACK THE DEMOS "
 DC.B "AS THESE TAKE LESS TIME THAN WRITING MENUS!).     "
 DC.B "    OK HERE ARE THE GREETINGS....  HI TO   AUTOMATION,   "
 DC.B "INNER CIRCLE,   THE REPLICANTS,   SEWER SOFTWARE,   THE LOST BOYS,   "
 DC.B "THE CAREBEARS,   AN COOL,   THE MEDWAY BOYS,   THE POMPEY PIRATES,   "
 DC.B "ERIK PLANKTON,   AXE OF DELIGHT,   THE EMPIRE,   ST CNX,   "
 DC.B "TUFTY,   SWSL,   THE DEMO CLUB,   DR.SYNE,   MARTIAN   AND   THE SKUNK."
 DC.B "        P.O.V. CONSISTS OF THE FOLLOWING MEMBERS... "
 DC.B "MAC SYS DATA (CODER/HACKER/PACKER),   BORIS (CODER),   "
 DC.B "OZYMANDIAS (MEGA GRAFIX MAN)   AND   ALY (GRAFIX - SOMETIMES).   "
 DC.B "   WELL THIS IS ALL I HAVE TO SAY FOR THIS ONE SO LOOK OUT FOR P.O.V. "
 DC.B "59 REAL SOON......  "
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

black	dcb.b	34,0

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
tune:	incbin	med88.img
pic	incbin	pov58.PI1
	even

bob_sou_pos	dc.l	0
last_sou_pos	dc.w	0
bob_wes_pos	dc.l	0
last_wes_pos	dc.w	0
bob_sof_pos	dc.l	0
last_sof_pos	dc.w	0
bob_lib_pos	dc.l	0
last_lib_pos	dc.w	0

end_of_table	dc.l	endbobs
present_table	dc.l	bob1

tables	dc.l	bob1
	dc.l	endbobs

bob1	incbin	bob1.dat
	incbin	bob4.dat
	incbin	bob2.dat
	incbin	bob2.dat
	incbin	bob2.dat
	incbin	bob6.dat
	incbin	bob6.dat
	incbin	bob6.dat
	incbin	bob3.dat
	incbin	bob5.dat
	incbin	bob7.dat
	incbin	bob3.dat
endbobs

logo	incbin	shifted.dat
	even


filenames:
	dc.b	"$$FANTASIA.STE",0,0
	dc.b	"SUNNY.STE",0,0,0,0,0,0,0
	dc.b	"WORLD.STE",0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
