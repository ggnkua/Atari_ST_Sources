*****************************************************************
*			P.O.V. 106				*
*			---------				*
* WRITTEN BY MAC SYS DATA					*
*****************************************************************
;* Screen flipping menu
;* Present screen pointed to label PRESENT SCREEN
;


FINAL		equ	0	;0=no   1=yes
RASTER_TIMINGS	equ	0


SPRITE_WIDTH	equ	5
SPRITE_DEPTH	equ	22


	bsr	set_super
	clr.w	$200.w
	IFNE	FINAL
	move.l	#msd,$24.w
	ENDC

msd	move.b	#$12,$fffffc02.w

;clear BSS
	lea	stopper,a0
.loop	clr.l	-(a0)
	cmp.l	#old70,a0
	bgt.s	.loop

	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out

	move.l	scr_now,a0
	move.l	a0,screen_base
	bsr	set_low_rez
	bsr	shift_pov
	move.b	$484,old484
	clr.b	$484
	bsr	intro

*** ATOMINO music ripped by MUG UK.

	move.l	#1,D0
	jsr	tune

	bsr	cls
	bsr	set_for_border
	bsr	show_pic
	bsr	set_bounce_count
	bsr	flush
	bsr	disc_number

main_loop
	bsr	vsync
	bsr	set_screen		;screen flip

	IFNE	RASTER_TIMINGS	;only show rasters if wanted and <>FINAL copy
	IFEQ	FINAL
	move.w	#$123,$ffff8240.w
	ENDC
	ENDC

	bsr	scroll

	IFNE	RASTER_TIMINGS
	IFEQ	FINAL
	move.w	#$007,$ffff8240.w
	ENDC
	ENDC
	bsr	return_screen

	IFNE	RASTER_TIMINGS
	IFEQ	FINAL
	move.w	#$040,$ffff8240.w
	ENDC
	ENDC

	bsr	disc_number

	IFNE	RASTER_TIMINGS
	IFEQ	FINAL
	move.w	picture_pal,$ffff8240.w
	ENDC
	ENDC

	move.b	$fffffc02.w,d0

	IFNE	FINAL
	cmp.b	#01,d0		;escape
	beq	exit
	ENDC

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
	eor.w	#$002,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	lsl.w	#2,d0
	add.w	d0,a6
	move.l	(a6),a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#$8,$fffffc02.w
	move.b	old484,$484
	bsr	black_out
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4.w,-(sp)
	rts


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



***************
* Subroutines *
***************
shift_pov
	lea	pov_pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop

	lea	pov,a1
	move.w	#16-1,d7
shift_loop
	move.l	screen_base,a0
	move.l	a0,a6
	add.w	#8,a0
	move.w	#SPRITE_DEPTH-1,d2
repeat
OFF	set	0
	REPT	SPRITE_WIDTH
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat

	add.w	#160*6,a0
	move.w	#SPRITE_DEPTH-1,d2
repeat2
OFF	set	0
	REPT	SPRITE_WIDTH
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat2
	move.l	a6,a0
	move.w	#(SPRITE_DEPTH*2)+8-1,d6
.loop	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	#8,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop
	rts

return_screen
	move.l	buffered,d0
	move.l	scr_now,a0
	add.l	d0,a0
	lea	logo+34,a1
	add.l	d0,a1
	REPT	SPRITE_DEPTH
	movem.l	(a1),d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	rts

disc_number
	move.l	table_pos,a0
	cmp.w	#-1,(a0)
	bne.s	.no_reset
	lea	sine,a0
	move.l	a0,table_pos
.no_reset
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.w	(a0)+,d0	;word/offset
	move.w	(a0)+,d1	;y offset (post*160)
	move.l	a0,table_pos
	move.b	d0,d2
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8
	add.w	d1,d0
	move.l	last_position,buffered
	move.l	d0,last_position

	move.l	scr_now,a0
	add.l	d0,a0
	lea	pov,a1		;grafix
	and.w	#$f,d2
	mulu	#(8*SPRITE_WIDTH*SPRITE_DEPTH),d2
	add.l	d2,a1		;grafix
	add.l	d2,a1		;mask
	lea	8*SPRITE_WIDTH*SPRITE_DEPTH(a1),a2	;masks
	move.w	#SPRITE_DEPTH-1,d7
.loop
	REPT	SPRITE_WIDTH
	move.l	(a2)+,d1	;mask data
	move.l	(a0),d0		;screen data
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	ENDR
	add.w	#160-(SPRITE_WIDTH*8),a0
	dbf	d7,.loop
	rts


scroll	move.l	scr_now,a6
	add.l	#160*230,a6
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
	move.l	scr_now,a1
	add.l	#160*230,a1
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
	mulu	#31*4*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31*4,d0		;character depth * 4 (31*4)
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

vsync	move.w	#-1,vsync_flag
vs	tst.w	vsync_flag
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

save_pal
	lea	old_pal,a0
	lea	$ffff8240,a1
set_p	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a0)
	rts

restore_pal
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	bra.s	set_p

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#49152,d1
	eor.l	d0,d1
	move.l	d1,scr_xor


set_screen
	move.l	scr_now,d6
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,scr_now
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts


set_med_rez
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

cls	move.l	screen_base,a0
	move.w	#32000/4-1,d0
.cls	clr.l	(a0)+
	dbf	d0,.cls
	rts

show_pic
;move pic pal into storage
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,picture_pal

;move logo on top of pic
	lea	pic+34,a1
	REPT	(160/4)
	clr.l	-(a1)
	ENDR

	lea	logo+(160*27)+68,a0
	move.w	#27-1,d0	;logo depth
.loop	REPT	(160/4)
	move.l	-(a1),-(a0)
	ENDR
	dbf	d0,.loop

	move.l	scr_now,d6
	move.l	d6,a1
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,a2

	lea	logo+34,a0
	move.w	#(32000+(160*27))/4-1,d0
sho	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,sho

	movem.l	picture_pal,d0-d7		;recover pal and set new colours
	movem.l	d0-d7,$ffff8240.w
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

set_for_border
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.l	$118.w,old118
	move.b	$fffffa11.w,save1
	move.b	$fffffa21.w,save2
	move.b	$fffffa07.w,save3
	move.b	$fffffa09.w,save4
	move.b	$fffffa0f.w,save5
	move.b	$fffffa13.w,save6
	move.b	$fffffa1b.w,save7
	move.b	$fffffa1d.w,save8

	clr.l	$4da
	MOVE.L	#new70,$70.W
	MOVE.L	#null,$120.W

	clr.b	$fffffa1d.w
	andi.b	#$df,$fffffa09.w
	andi.b	#$fe,$fffffa07.w
	bclr	#3,$fffffa17.w
	move.l	#new120,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	MOVE.W	#$2300,SR
	rts


isr_off	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.l	old70,$70.w
	move.b	save3,$fffffa07.w
	move.b	save6,$fffffa13.w
	move.b	save4,$fffffa09.w
	move.b	save7,$fffffa1b.w
	move.b	save8,$fffffa1d.w
	move.b	save2,$fffffa21.w
	move.b	save1,$fffffa11.w
	move.b	save5,$fffffa0f.w
	lea	$ffff8800.w,a0
	move.b	#7,(a0)
	move.b	(a0),d1
	ori.b	#$3f,d1
	moveq.w	#$c,d0
.loop	move.b	d0,(a0)
	clr.b	2(a0)
	dbf	d0,.loop
	move.b	#7,(a0)
	move.b	d1,2(a0)
	move.w	#$2300,sr
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

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


intro	lea	intro_pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	intro_pic+2,a1
	bsr	fadein
	move.w	#5000,d7
.pau	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.ex
	dbf	d7,.pau
.ex	lea	black,a1
	bsr	fadein
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1	LEA	PALREG,A0	;LEA PALREG+2,A0; TARGET IN A1
	move.w	#16-1,d7
FADEIN2	BSR	MODIFY
	addq.w	#2,a0
	addq	#2,a1
	dbf	d7,FADEIN2
	move.w	#4,d0
	BSR	WAIT
	MOVE.L A2,A1
	DBRA	D6,FADEIN1
	RTS

WAIT:	bsr	v_sync
	DBRA D0,WAIT
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




*********************************
*		ISRs		*
*********************************
new120	clr.b	$fffffa1b.w
	move.l	d0,-(sp)
	moveq	#$26,d0
.aaa	dbf	d0,.aaa
	move.b	#0,$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.l	fontpal,$ffff8240.w
	move.l	fontpal+4,$ffff8240+4.w
	move.l	fontpal+8,$ffff8240+8.w
	move.l	fontpal+12,$ffff8240+12.w
	move.l	fontpal+16,$ffff8240+16.w
	move.l	fontpal+20,$ffff8240+20.w
	move.l	fontpal+24,$ffff8240+24.w
	move.l	fontpal+28,$ffff8240+28.w
	move.l	(sp)+,d0
null	rte

new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	picture_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	move.w	d0,-(sp)
	move.w	#$57e,d0
.aaa	dbf	d0,.aaa
	clr.b	$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.w	(sp)+,d0
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	.not_z
	sub.w	#1,zero_counter
.not_z	clr.b	$fffffa1b.w
	move.b	#228,$fffffa21.w
	move.b	#8,$fffffa1b.w
	jsr	tune+8
	movem.l	(sp)+,d0-d7/a0-a6
	rte

new118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	bclr	#6,$fffffa11.w
	rte



********
* Data *
********
	SECTION DATA
fontpal	incbin	font.col


scroll_pointer	dc.l	scroll_text+7
scroll_text
 dc.b "                             "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 106.            "
 dc.b "ALL CODE BY abc, GRAFIX BY OZ AND MUSIC BY MAD MAX FROM ATOMINO "
 dc.b "RIPPED BY MUG UK.       RELEASE DATE 1ST MARCH 1992.        "
 DC.B "        BEFORE ALL THE USUAL WAFFLE I WOULD LIKE TO SAY THANKS "
 DC.B "TO A FEW PEOPLE....     BORIS FOR ALL HIS RECENT WORK,   OZ FOR "
 DC.B "YET ANOTHER DISC OF NEW PICTURES,   PROPHECY PD FOR ALL THE RECENT "
 DC.B "STUFF,   TOWER PD FOR HIS DISTRIBUTION AND COLLECTING,   "
 DC.B "KGB IN FRANCE FOR THE 'FILLER' SCREENS,  MUG UK FOR THE MUSIC "
 DC.B "AND OTHER BITS AND PIECES   AND FINALLY   A BIG "
 DC.B "THANKS TO LEO AT W.J.S. DESIGN FOR THE AMIGA DEVELOPMENT SYSTEM "
 DC.B "THAT BLEW MY AMIGA UP!!!!            WHAT IS THE PD SCENE COMING "
 DC.B "TO?      ONCE UPON A TIME IT WAS FUN TO WRITE STUFF BUT NOW IT "
 DC.B "SEEMS EVERYONE IS AGAINST HAVING FUN.   THIS RECENT CLAMP DOWN "
 DC.B "ON SAMPLE SOUND DEMOS, OKAY SO THE MATERIAL IS COPYRIGHT BUT "
 DC.B "DOES IT EFFECT THE RECORD SALES?      I DOUBT IT!      "
 DC.B "ALL THIS 'COPYRIGHT' IS A LOAD OF SHITE AS "
 DC.B "MATERIAL HAS BEEN STOLEN FROM PEOPLE FOR YEARS IN THE RECORD "
 DC.B "INDUSTRY.   IN A RECENT RAID ON A PD LIBRARY THERE WAS QUITE "
 DC.B "A FEW SAMPLED SOUND DEMOS TAKEN HOWEVER THEY WERE ALL CRAP ONES. "
 DC.B "  IT'S OBVIOUS THAT THE TRADING STANDARDS PEOPLE HAVEN'T A CLUE."
 DC.B "   WE HAVE DONE 3 OF THE BEST SAMPLE SOUND DEMOS EVER AND THEY "
 DC.B "WEREN'T TAKEN!       AS IT'S GETTING A BIT MORE RISKY TO "
 DC.B "PRODUCE SAMPLE SOUND DEMOS WE ARE NOW SEAKING WRITTEN PERMISSION "
 DC.B "FROM A CERTAIN WELL KNOWN 'INDIE' GROUP TO PRODUCE AS MANY "
 DC.B "SAMPLE SOUND DEMOS AS WE CAN.    THE PERMISSION SHOULD "
 DC.B "BE A FORMALITY AS I KNOW BOTH MEMBERS PERSONNALLY AND MY "
 DC.B "BROTHER WORKS FOR THEM (PLUS ONE BAND MEMBER HAS AN STE!).   "
 DC.B "                 THERE ARE NO GREETS HERE SO YOU CAN PRESS A KEY NOW!     "
 DC.B "        THIS IS DISC 106 IN OUR COLLECTION OF PACKED DEMOS AND AS "
 DC.B "THERE ARE 3 MAJOR CREWS PACKING DEMOS I WOULD LIKE TO TELL YOU "
 DC.B "WHAT OUR OBJECTIVES ARE;-     "
 DC.B "    THE IDEA WAS TO GET MORE DEMOS ONTO ONE DISC TO SAVE "
 DC.B "DISCS.    IT STARTED WELL AS MANY EARLY DEMOS WERE ON SINGLE SIDED "
 DC.B "DISCS BUT RECENTLY DEMOS ARE ON DOUBLE SIDED AND MANY DEMOS ARE "
 DC.B "NOW PACKED.  THE RESULT IS THAT WE CANNOT FIT MANY DEMOS ON "
 DC.B "ONE DISC AND SO WE USE 'FILLERS' TO COMPLETELY FILL THE DISC UP. "
 DC.B "   THE FILLERS ARE SMALL DEMOS OR INTROS THAT ONLY HAVE ONE "
 DC.B "SCREEN.     AS OUR DISC COLLECTION STARTED TO GROW I GOT "
 DC.B "LAZY AND STARTED THROWING ANY OLD DEMO ON WHICH MADE THE "
 DC.B "OVERALL QUALITY OF P.O.V. DISCS GO DOWN.     OVER A YEAR AGO "
 DC.B "I STARTED A NEW JOB WHICH LEFT LESS TIME TO DO MENUS BUT "
 DC.B "IT DID MAKE ME THINK MORE CAREFULLY WHAT MATERIAL TO PUT "
 DC.B "ON THE DISC.     YOU PROBABLY NOTICED THAT SINCE ABOUT DISC 80 THE "
 DC.B "MENUS HAVE GOT BETTER AND THE DEMOS WE PUT ON THEM HAVE GOT "
 DC.B "MORE INTERESTING.     I STILL HAVE QUITE A FEW OLD DEMOS "
 DC.B "TO PUT ON DISCS PLUS SOME NICE MEGADEMOS SO STICK WITH US. "
 DC.B "                OKAY GO AHEAD AND MAKE MY DAY, PRESS A KEY. "
 DC.B "                                                        "
 DC.B "                                                      WRAP   "
 dc.b $ff
	even

char_offset	dc.w	0
font		dcb.b	31*4*4,0
		incbin	font.fnt
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,34,43,00,00,00,00,35,28,29,45,00,31,32,33,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	37,38,39,40,41,42,43,44,45,46,27,00,00,00,00,30,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,47,48,49

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even
last_scroll	dc.l	0
sine_count	dc.w	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0
	dc.w	1,1,1,1,1
	dc.w	2,2,2,2
	dc.w	3,3,3
	dc.w	4,4
	dc.w	5
	dc.w	6
	dc.w	8
	dc.w	10
	dc.w	8
	dc.w	6,5
	dc.w	4,4
	dc.w	3,3,3
	dc.w	2,2,2,2
	dc.w	1,1,1,1,1
	dc.w	$ffff
black	dcb.b	64,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,4	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,3	;keypad 5
	dc.b	$6c,3	;keypad 6
	dc.b	$ff
	even

******************** bob **************
last_position	dc.l	0
buffered	dc.l	0
table_pos	dc.l	sine
sine	incbin	sine1.dat
	dc.w	$ffff,$ffff
	even


filenames	dc.l	exec1,exec2,exec3,exec4,exec5,exec6
exec1	dc.b	"OMEGA",0
	even
exec2	dc.b	"SHTROUM",0
	even
exec3	dc.b	"BIG_BLU",0
	even
exec4	dc.b	"PARADISE",0
	even
exec5	dc.b	"AGGRES_2",0
	even
exec6	dc.b	"COPIER.POV",0
	even

;*************************
tune	incbin	atomino2.mus
intro_pic
	incbin	intro.pi1
pov_pic	incbin	pov.pi1

logo	incbin	pov_cool.dat
pic	incbin	pov106.PI1

	even


	SECTION BSS

old70	ds.l	1
old120	ds.l	1
old118	ds.l	1

picture_pal	ds.b	32

screen_base	ds.l	1

scr_now		ds.l	1
scr_xor		ds.l	1

old484		ds.w	1
stack_save	ds.l	1

vsync_flag	ds.w	1

old_base	ds.l	1
hertz_switch	ds.w	1

zero_counter	ds.w	1



save1	ds.b	1
save2	ds.b	1
save3	ds.b	1
save4	ds.b	1
save5	ds.b	1
save6	ds.b	1
save7	ds.b	1
save8	ds.b	1
	even
key	ds.b	1
	even
pov	ds.b	(SPRITE_DEPTH*(SPRITE_WIDTH*8)*16)*2
old_pal	ds.b	32
	ds.b	256
screens	ds.b	49152
	ds.b	49152
stopper