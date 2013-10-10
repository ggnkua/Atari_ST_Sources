****************
* P.O.V. 38    *
****************

	bsr	set_super
wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

;set for reset pic
	move.l	$502.w,old502
	move.l	#null,$502
	move.l	#$31415926,$426.w
	move.l	#reset,$42a.w

	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484

	move.l	#1,d0
	bsr	tune

	bsr	set_palette
	bsr	set_for_border
	bsr	show_pic
	bsr	animate
	move.b	#0,$fffffc02.w
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	return_screen
	bsr	animate
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,bor+2
	eor.w	#$ffff,hz_switch
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq.s	do_reset
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#7,d0		;6 key
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
	eor.b	#2,$ff820a
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
return_screen
	move.l	old_pos,d0
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	35
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7/a2/a3
	movem.l	d0-d7/a2/a3,(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
	rts

animate:
	moveq	#0,d7
	move.l	d7,d6
	move.l	d6,d5
	move.l	d5,d4
	move.l	xtable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.xno_reset
	lea	xtable,a0
	move.l	a0,xtable_pos
.xno_reset
	move.b	(a0)+,d6
	move.b	(a0)+,d5
	move.l	a0,xtable_pos

	move.l	ytable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.yno_reset
	lea	ytable,a0
	move.l	a0,ytable_pos
.yno_reset
	move.b	(a0)+,d7
	move.l	a0,ytable_pos

	mulu	#160,d7
	mulu	#8,d6

	add.w	d6,d7
	move.l	d7,old_pos
	move.l	screen_base,a1
	add.w	d7,a1

	lea	logo,a0
	mulu	#(35*40),d5
	add.w	d5,a0
	REPT	35
	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	add.w	#160-40,a1
	ENDR
	rts

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
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	lea	masks,a2
	move.w	#10-1,d3	;11 masks
.loop1:
	bsr	vsync
	move.l	screen_base,a1
	lea	pic+34,a0

	move.w	#10-1,d2
.loop2:
	move.w	#20-1,d1
.loop3:
	move.w	#20-1,d0
.loop4:
	move.w	(a2),d4
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
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	clr.l	$426
	clr.l	$42a
	move.l	old502,$502

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
	bsr	tune+$8
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
bor	move.w	#$000,$ffff8240.w
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

credits
	moveq	#0,d0
	lea	$ffff8240.w,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	pea	mess1
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	fadein
	move.w	#100,d7
de1	bsr	v_sync
	dbf	d7,de1
	bsr	fadeout

	pea	mess2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	fadein
	move.w	#100,d7
de2	bsr	v_sync
	dbf	d7,de2
	bsr	fadeout

	pea	mess3
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	fadein
	move.w	#100,d7
de3	bsr	v_sync
	dbf	d7,de3
	bsr	fadeout
	rts
fadein
	move.w	#7-1,d0
.loop	add.w	#$111,$ffff825e.w
	bsr	v_sync
	bsr	v_sync
	bsr	v_sync
	bsr	v_sync
	dbf	d0,.loop
	rts

fadeout
	move.w	#7-1,d0
.loop	sub.w	#$111,$ffff825e.w
	bsr	v_sync
	bsr	v_sync
	bsr	v_sync
	bsr	v_sync
	dbf	d0,.loop
	rts

******************************** RESET **********************
reset:	move.w	#$2700,sr
	clr.b	$ffff8260.w
	move.l	old120,$120
	move.l	old70,$70
	move.b	olda07,$FFFFFA07
	move.b	olda09,$FFFFFA09
	move.b	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21

	clr.b	$484
	move.l	#tuneisr,$4da
	lea	$80000,sp
	move.b	#7,$ffff8201	;set screen to $70000
	move.b	#0,$ffff8203
	move.b	#0,$ffff8260	;low rez
	movem.l	reset_pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	lea	reset_pic+34,a0
	lea	$70000,a1
	move.w	#32000/4-1,d0
hi:	move.l	(a0)+,(a1)+
	dbf	d0,hi
	move.b	#2,$ffff820a.w	;50hz
	move.w	#$2300,sr

	clr.l	$426.w	;stop another reset
	clr.l	$42a.w
	move.b	#$12,$fffffc02.w
	move.w	#65530,d0
.loop	nop
	dbf	d0,.loop
wait_for_key_release
	move.b	$fffffc02.w,d0
	btst	#7,d0
	beq.s	wait_for_key_release
nokey:	move.b	$fffffc02.w,d0
	btst	#7,d0
	bne.s	nokey
	move.l	4,a0
	jmp	(a0)
tuneisr	movem.l	d0-d7,-(sp)
	bsr	tune+8
	movem.l	(sp)+,d0-d7
	rts
null	nop
	rte
********
* Data *
********
	SECTION DATA
old502	dc.l	0
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
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                   MAC SYS DATA PRESENTS - P.O.V. 38    "
 DC.B "ALL CODING BY M.S.D., ART BY OZ, THE MUSIC WAS RIPPED FROM "
 DC.B "THE TCB TRACKER (FULL BLOWN VERSION NOT THE DEMO) BY MAC "
 DC.B "SYS DATA ON 16TH OF SEPTEMBER 1990 (A DAY AFTER IT WAS "
 DC.B "RELEASED!).      IF YOU WANT THE MUSIC THEN GET IN TOUCH "
 DC.B "VIA THE DEMO CLUB.          P.O.V. CONSISTS OF THE "
 DC.B "FOLLOWING MEMBERS ...   MAC SYS DATA (CODER/HACKER/PACKER),   "
 DC.B "BORIS (CODER),   OZYMANDIAS (GRAPHIX ARTIST)   AND ALY "
 DC.B "(GRAPHIX).           TODAY I RECEIVED MY ST FORMAT FOR "
 DC.B "NOVEMBER '90 AND IT'S GOT AN ARTICLE ON AN-COOL. FORMAT "
 DC.B "STATES THAT HE WROTE ALL THE MUSIC FOR THE CAREBEARS "
 DC.B "DEMOS - WELL WHAT A BLOOD LIE!  WE ALL KNOW THE BEST MUSIC "
 DC.B "PROGRAMMER IS MAD MAX AND IT WAS HIM WHO DID 99 PERCENT "
 DC.B "OF THE MUSIC IN THOSE DEMOS.   ANYWAY WHY IS IT THAT ALL "
 DC.B "AN-COOL'S SOUNDCHIP TUNES SOUND EXACTLY THE SAME AS MAD MAX'S? "
 DC.B "         ANSWER:  HE STOLE JOCHEN'S SYNTH ROUTINE. "
 DC.B "     HUH! AND HE SAYS HE WRITES ALL HIS OWN STUFF!       "
 DC.B "WELL HE MUST HAVE WRITTEN THE TRACKER 'COS IT'S FULL OF BUGS!  "
 DC.B "HA,HA,HA!            RIGHT ALY HAS JUST LEFT AFTER SEEING "
 DC.B "AN AMIGA DEMO, I WONDER WHY?      STRANGE REALLY.       "
 DC.B "WHAT A WEIRD SCROLL TEXT THIS TURNED OUT TO BE.            "
 DC.B "HEY MUM LOOK I CAN TYPE WITH NO HANDS.                     "
 DC.B "SEE!        NO HANDS,      NO BLITTER,      NO BUGS,      "
 DC.B "NO DMA,      NO MOUSE,      NO JOYSTICK,      NO COMPILED "
 DC.B "CRAP,      NO BEER,      NO BRAIN      AND      NOBODY "
 DC.B "LEFT READING THIS TEXT!          I HAVE BEEN ACCUSED OF BEING "
 DC.B "A BIT LAZY LATELY 'COS I HAVN'T WRITTEN MUCH SCROLLTEXT, WELL "
 DC.B "THERE IS AN ANSWER FOR IT AND IT'S BECAUSE I FINISHED 3 DISCS "
 DC.B "IN 2 WEEKS AND IT GETS A BIT HARD (OO-ER) TO THINK OF SOMETHING "
 DC.B "NEW FOR EVERY DISC.              WELL HERE'S A BIT OF INFO FOR YA......"
 DC.B "     COMING SOON TO A COMPUTER NEAR YOU....    THE VIC DEMO 1,   "
 DC.B "KYLIE LOCOMOTION (ARRGGHHH!),   MILLI VANILLI,   PREDATOR,   "
 DC.B "SECRET SEPERATION,   SCREE,   ODU DEMO,   SLEDGE HAMMER,   "
 DC.B "ACID MIX DEMO,   THE BLACK WIZARDS DEMO   AND   3615-GEN4 DEMO. "
 DC.B "     ALL THESE DEMOS ARE PACKED AND READY FOR A MENU.  A GOOD "
 DC.B "FEW ARE 1 MEG ONLY AND SO I AM WAITING FOR SOME 1/2 MEG DEMOS "
 DC.B "TO ARRIVE SO I CAN FILL UP THE DISCS.       IF YOU LIKE DEMOS "
 DC.B "AND CAN WRITE BASIC (THEN COMPILE IT) OR 68000 OR 'C' THEN "
 DC.B "WRITE A DEMO AND MAKE IT HALF MEG COMPATABLE. PUT LOADS OF "
 DC.B "GRAPHIC ANIMATIONS IN THE DEMO AND NOT JUST SAMPLED SOUND.   IF IT TURNS "
 DC.B "OUT PRETTY GOOD THEN SEND IT OFF TO 'THE DEMO CLUB' AND IT WILL "
 DC.B "EVENTUALLY WORK IT'S WAY TO ME TO PACK.        SOME OF THE "
 DC.B "DEMOS WE HAVE JUST RECEIVED WERE WRITTEN IN FEB 1990 WHICH IS "
 DC.B "8 MONTHS AGO SO DON'T BE PUT OFF IF A DEMO YOU WROTE DOES NOT "
 DC.B "APPEAR WITHIN 2 OR 3 MONTHS.      IF YOU DON'T USUALLY SEND "
 DC.B "THINGS TO THE DEMO CLUB (WHY NOT?) YOU CAN SEND IT TO "
 DC.B "'SOUTHWEST SOFTWARE LIBRARY' AND TELL MARTYN TO PASS IT ONTO "
 DC.B "US (P.O.V.)    OR    SEND IT TO SAMMY JOE AT THE LOSTBOYS PD "
 DC.B "LIBRARY AND ASK HIM TO SEND IT TO BORIS OF P.O.V.      "
 DC.B "THE THREE P.D. LIBRARIES HAVE ALL OUR DISCS BUT OUR OFFICIAL "
 DC.B "DISTRIBUTOR IS 'THE DEMO CLUB' AS HE CAN SUPPLY US WITH ALL "
 DC.B "THE BEST AND NEWEST DEMOS AS THEY APPEAR.        RIGHT DON'T "
 DC.B "GO AWAY 'COS I'M JUST GOING TO MAKE A BREW...               "
 DC.B "       WELL THAT WAS QUICK JUST 22 SPACES TO RUN TO THE "
 DC.B "KITCHEN, SLAM THE KETTLE ON, LIGHT THE GAS, FIND SOME COFFEE "
 DC.B "(MELLOW BIRDS), TOSS IT ALL IN A CUP (YUK-YUK), WAIT FOR THE KETTLE "
 DC.B "TO BOIL, SPILL HOT WATER EVERYWHERE APART FROM IN MY CUP, "
 DC.B "MANAGE TO GET THE LAST DROPS OF WATER IN THE CUP, ADD LOTS "
 DC.B "OF MILK 'COS I WAS A BIT SHORT OF WATER AND RUSH BACK "
 DC.B "TO MY STE.         WELL IT ACTUALLY TOOK 23 SPACES BUT I TOLD A FIBB! "
 DC.B "           OH GOD, I FORGOT TO STIR IT UP - ERRRGGHHH!      "
 dc.b "TODAYS DATE IS 23/10/90 AND I'VE JUST RIPPED THE EXHAUST OFF MY "
 DC.B "BIKE TO GET IT WELDED UP SO I'M NOW COVERED IN OIL, I WONDER "
 DC.B "IF MY HARD DISC WILL STILL WORK WHEN ITS COVERED IN OIL?     "
 DC.B "     SPEAKING OF HARD DISCS, HOW IS YOURS BORIS?       (HIS HARD "
 DC.B "DISC CRASHED AND HE LOST 20 MEG OF SOFTWARE - HA,HA,AH,HA,HA,HA,HA!!)      "
 DC.B "THE FUNNIEST PART OF IT ALL IS THAT HE HAD BACKED UP ALL THE PARTITIONS "
 DC.B "EXCEPT FOR THE 2 THAT WERE LOST!         HAVE I DONE THE GREETINGS YET? "
 DC.B "         NO?        OH WELL HERE THEY ARE - GREETINGS TO...    "
 DC.B "AUTOMATION,   DR.SYNE,   DTB,   MEDWAY BOYS,   POMPEY PIRATES,   SEWER SOFTWARE,   "
 DC.B "TCB,   AND   THE LOST BOYS.         SPECIAL SUPPLIERS GREETINGS "
 dc.b "TO   GEORGE,   THE DEMO CLUB   AND   "
 DC.B "SOUTHWEST SOFTWARE LIBRARY.        CONGRATULATIONS TO THE FOLLOWING "
 DC.B "FOR WRITING A LOT OF NEW DEMOS.... THE SKUNK,   TRAX,   ABC CREW   "
 DC.B "AND   A.C.N. (T.MARTENS AND M.KLUM).         "
 DC.B "I WILL BE PACKING 45 NEW DEMOS REAL SOON WHICH SHOULD TAKE P.O.V. WELL "
 DC.B "INTO THE 40'S, INFACT I HAVE ENOUGH DEMOS FOR 12 NEW MENUS BEFORE I TOUCH THE "
 DC.B "NEW STUFF.         IF YOU LIKE DEMOS THEN STICK WITH THE BEST - P.O.V. UK'S "
 DC.B "NUMBER 1 DEMOS PACKERS.         "
 DC.B "I'LL WRAP IT UP HERE, IF YOU WANT MORE COMPACTS THEN WRITE TO "
 DC.B "THE DEMO CLUB,     23 ALMA PLACE,     SPILSBY,      LINCS.      UK.      PE23 5LB. "
 DC.B "     BYE... "
 DC.B "                                                "
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
mess1	dc.b	27,'E'
	dc.b	27,'Y',32+6,32+10,"PERSISTENCE OF VISION"
	dc.b	27,'Y',32+9,32+9,"UK's NO.1 DEMO PACKERS"
	dc.b	27,'Y',32+12,32+16,"PRESENTS",0
mess2	dc.b	27,'E'
	dc.b	27,'Y',32+6,32+12,"DEMO COMPILATION"
	dc.b	27,'Y',32+9,32+15,"NUMBER 38",0
mess3	dc.b	27,'E'
	dc.b	27,'Y',32+6,32+10,"MEMBERS OF P.O.V. ARE"
	dc.b	27,'Y',32+8,32+14,"MAC SYS DATA"
	dc.b	27,'Y',32+10,32+17,"BORIS"
	dc.b	27,'Y',32+12,32+15,"OZYMANDIAS"
	dc.b	27,'Y',32+14,32+18,"ALY",0
cls	dc.b	27,'E',0
	even

tune:	Incbin "tracker.img"
	even
pic	incbin	"pov38.PI1"
	even

reset_pic	incbin	resetpic.pi1"
	even
********** animation data ************
xtable_pos	dc.l	xtable
xtable
	incbin	xtable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
ytable_pos	dc.l	ytable
ytable	
	incbin	ytable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
old_pos	dc.l	0
logo	incbin	logo.dat
	even

masks:	dc.w	%1111111111111111
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
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
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
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1000000000000001
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
	dc.w	%1110000000000111
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
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
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
	dc.w	%1111100000011111
	dc.w	%1111100000011111
	dc.w	%1111100000011111
	dc.w	%1111100000011111
	dc.w	%1111100000011111
	dc.w	%1111100000011111
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
	dc.w	%1111110000111111
	dc.w	%1111110000111111
	dc.w	%1111110000111111
	dc.w	%1111110000111111
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
	dc.w	%1111111001111111
	dc.w	%1111111001111111
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
	dc.b	"BEAT2.MSD",0,0,0,0,0
	dc.b	"UFO.MSD",0,0,0,0,0,0,0
	dc.b	"CRADLE.MSD",0,0,0,0
	dc.b	"WDSINES.STE",0,0,0
	dc.b	"COPIER.POV",0

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000
