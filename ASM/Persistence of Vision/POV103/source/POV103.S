*************************************************************************
*			P.O.V. 103 menu					*
*			---------------					*
*									*
* Written by MAC SYS DATA						*
*									*
*									*
* Music from PREHISTORIC TALE high score				*
*									*
*************************************************************************
	OPT	o+,w-

BUFFER_SIZE	EQU	16*8
WIDTH		EQU	16

	bsr	set_super
	move.b	#$12,$fffffc02.w
	or.b	#2,$ffff820a.w	;50Hz

	lea	screens,a0
clr	clr.l	(a0)+
	cmp.l	#stopper,a0
	blt.s	clr

	bsr	get_screen_base
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_palette
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	get_original_rez
	clr.b	$ffff8260.w
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen_base
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	bsr	show_pic

	moveq.l	#1,d0		;PREHISTORIC TALE HIGH SCORE MUSIC
	jsr	tune
	bsr	save_isr


main_loop
	clr.w	vsync_flag
wai	tst.w	vsync_flag
	beq.s	wai

;	move.w	#$700,$ffff8244.w
	bsr	clear_spec
	jsr	tune+8
	bsr	calc_spec
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	copy_scroll
;	move.w	pic+6,$ffff8244.w

	move.w	key,d0

	cmp.b	#1,d0			;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;0 keypad
	beq	zero
no_hertz_change

	cmp.w	#$c53,d0
	beq	reset

; now scan keys for valid press
	lea	key_codes,a0
	move.b	key+1,d0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),-(sp)	;key press offset

	bsr	reset_isr

	moveq	#0,d0
	move.b	(sp)+,d0
	lsl.w	#2,d0		*4
	lea	filenames,a0
	move.l	(a0,d0),a0
	lea	$200.w,a1
	move.l	(a0)+,(a1)+		;AUTORUN 4 load system
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	move.b	old484,$484.w
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	set_low_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	trap	#1


exit	bsr	reset_isr
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	set_med_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	TRAP	#1


zero	tst.w	zero_counter
	bne	no_hertz_change
	eor.w	#$230,border_hz+2
	move.w	#10,zero_counter
	eor.w	#-1,hertz_toggle
	bra	main_loop

reset	move.l	4.w,-(sp)
	rts

*******************
* CUSTOM ROUTINES *
*******************
scroll	move.l	line_ptr,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne.s	loop3
	lea	scroll_line,a0	;restart message
	move.l	a0,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	moveq.l	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0
	move.l	a0,line_ptr
	sub.w	#32,d0
	lsl.w	#5,d0	;*32
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

loop2	move.l	screen_base,a0
	add.w	#(160*10),a0
	move.l	a0,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	REPT	16
	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	lea	160(a2),a2
	ENDR

	move.w	#16-1,d0
loopy:	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	move.w	(a0),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopy
	subq.w	#1,scroll_number
	rts


copy_scroll
	move.l	screen_base,a1
	lea	160*11(a1),a1
	move.l	a1,a2
	add.l	#160*225+4,a2
	move.w	#15-1,d0
.loop
OFF	set	0
	REPT	20
	move.w	OFF(a1),OFF(a2)
OFF	set OFF+8
	ENDR
	lea	160(a1),a1
	lea	160(a2),a2
	dbf	d0,.loop
	rts

******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	80
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

clear_spec
	move.l	screen_base,a1
	add.l	#160*214+(160*16),a1
	moveq	#0,d0
	REPT	(20*26)
	move.w	d0,(a1)
	addq.w	#8,a1
	ENDR
	rts

calc_spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.w	(a0)+
	beq.s	.next
	subq.w	#1,-2(a0)
.next	dbf	d0,.cnt_down

	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_data,a3
	moveq	#12,d2

	move.b	#AAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	bchan
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	cchan
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	cchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
cchan
	move.b	#CAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	ps
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	ps
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************** print speccy *******************
ps
	move.l	screen_base,a0
	add.l	#(26*160)+160*216,a0

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop	move.w	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	move.w	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	move.w	(a2)+,d0
	beq.s	.nonib
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%00001110,d2
.loop4	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

save_isr
	move.b	$484.w,old484
	clr.l	hertz_toggle
	move.w	#$2700,sr
	move.l	$120.w,old120
	move.l	$118.w,old118
	move.l	$70.w,old70
	move.b	$fffffa11.w,save1
	move.b	$fffffa21.w,save2
	move.b	$fffffa07.w,save3
	move.b	$fffffa09.w,save4
	move.b	$fffffa0f.w,save5
	move.b	$fffffa13.w,save6
	move.b	$fffffa1b.w,save7
	move.b	$fffffa1d.w,save8
	clr.b	$fffffa1d.w
	andi.b	#$df,$fffffa09.w
	andi.b	#$fe,$fffffa07.w
	move.l	#null,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
	bclr	#3,$fffffa17.w		set AEI mode
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	move.w	#$2300,sr
	rts

reset_isr
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
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.w	#$2300,sr
	rts



***********************
* SUBROUTINES SECTION *
***********************
show_pic
	move.l	screen_base,a1
	add.w	#160*29,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

set_super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

set_new_palette
	lea	pic+2,a0
	bra.s	set_pal
set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,org_base
	rts

get_original_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez
	move.w	#1,-(sp)
set_rez	move.l	org_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


******************************
*     INTERRUPT ROUTINES     *
******************************


new120	move.w	next_colour,$ffff8240.w		;poke straight away
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.w	(a0),next_colour
	move.l	a0,isr_data
	move.l	(sp)+,a0
	cmp.w	#6,counter
	bne.s	.no
	move.l	#new120_part2,$120.w
.no	addq.w	#1,counter
	rte

new120_part2
	move.w	next_colour,$ffff8240.w		;poke straight away
scroll_raster
	move.w	#$010,$ffff8242.w
	move.l	a0,-(sp)	;$120		to stop jitter

	move.l	top_raster_pos,a0
	move.w	(a0)+,scroll_raster+2
	move.l	a0,top_raster_pos

	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.l	a0,isr_data

	move.l	(sp)+,a0

	cmp.w	#8+17,counter
	bne.s	.no
	move.l	#new120_part3,$120.w
	move.w	pic+4,$ffff8242.w

.no	addq.w	#1,counter
	rte

new120_part3
	move.w	next_colour,$ffff8240.w		;poke straight away
	move.l	a0,-(sp)	;$120		to stop jitter
	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.l	a0,isr_data
	move.l	(sp)+,a0

	cmp.w	#226,counter
	beq.s	.do
	addq.w	#1,counter
	rte

.do	clr.w	counter
	move.l	#border,$120.w
	rte

border	movem.l	d0/a0,-(sp)
	move.w	#37,d0
.aaa	dbf	d0,.aaa
	nop
	nop
	nop
	nop
	nop
	move.b	#0,$ffff820a.w
border_hz
	move.w	#$237,$ffff8240.w
	nop
	nop
	nop
	nop
	nop
	move.b	#2,$ffff820a.w
	lea	border_rasters,a0
	move.w	#27-1,d0
col_loop
	move.w	(a0),$ffff8240+10.w
	move.w	(a0)+,$ffff8242.w
	move.w	54(a0),$ffff8240+8.w
	REPT	120-4-5
	nop
	ENDR
	dbf	d0,col_loop

	move.w	pic+4,$ffff8242.w
	move.w	pic+6,$ffff8244.w
	move.w	pic+8,$ffff8246.w
	move.w	pic+10,$ffff8248.w
	move.w	pic+12,$ffff824a.w
	move.w	pic+14,$ffff824c.w
	move.w	pic+16,$ffff824e.w
	move.w	pic+18,$ffff8250.w
	move.w	pic+20,$ffff8252.w
	move.w	pic+22,$ffff8254.w
	move.w	pic+24,$ffff8256.w
	move.w	pic+26,$ffff8258.w
	move.w	pic+28,$ffff825a.w
	move.w	pic+30,$ffff825c.w
	move.w	pic+32,$ffff825e.w
	clr.b	$fffffa1b.w
	movem.l	(sp)+,d0/a0
	move.l	#null,$120.w
null	rte


new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d6

	move.w	#$580,d7
.aaa	dbf	d7,.aaa

	clr.b	$ffff820a.w

	move.w	#0,$ffff8240.w		;used as timing
	nop

	move.b	#2,$ffff820a.w

	move.l	(sp)+,d7
	st	vsync_flag
	move.l	#new120,$120.w
	move.l	#b_line,isr_data
	move.l	#top_rasters,top_raster_pos
	move.w	#$010,scroll_raster+2
	tst.w	zero_counter
	beq.s	.no
	subq.w	#1,zero_counter
.no
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new118	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte












****************
* DATA SECTION *
****************
stack_save	dc.l	0
screen_base	dc.l	0
org_base	dc.l	0
original_rez	dc.w	0

******************* isr details *******
counter	dc.w	0
vsync_flag	dc.w	0

old120	dc.l	0
old70	dc.l	0
old118	dc.l	0
save1	dc.b	0
save2	dc.b	0
save3	dc.b	0
save4	dc.b	0
save5	dc.b	0
save6	dc.b	0
save7	dc.b	0
save8	dc.b	0
	even
pic	incbin	yes1.pi1
tune	incbin	high_scr.mus

isr_data	dc.l	b_line

next_colour	dc.w	$000

b_line:
 dc.w	$001,$001,$002,$002,$012,$012,$013,$013,$113,$113
 dc.w	$114,$114,$124,$124,$125,$125,$126,$126
 dcb.w	46,$237
 dc.w	$337,$237,$337,$237,$337,$337,$237,$337,$337,$337,$337
 dc.w	$347,$337,$347,$337,$347,$347,$337,$347,$347,$347,$347
 dc.w	$447,$347,$447,$347,$447,$447,$347,$447,$447,$447,$447
 dc.w	$457,$447,$457,$447,$457,$457,$447,$457,$457,$457,$457
 dc.w	$557,$457,$557,$457,$557,$557,$457,$557,$557,$557,$557
 dc.w	$567,$557,$567,$557,$567,$567,$557,$567,$567,$567,$567
 dc.w	$667,$567,$667,$567,$667,$667,$567,$667,$667,$667,$667
 dc.w	$677,$667,$677,$667,$677,$677,$667,$677,$677,$677,$677
 dc.w	$777,$677,$777,$677,$777,$777,$677,$777,$777,$777,$777
 dcb.w	10,$777
 dc.w	$677,$777,$677,$567,$763,$763,$763,$763,$763,$763,$763
 dc.w	$567,$567,$567,$567
 dc.w	$357,$567,$357,$357,$357,$357,$247,$357
 dcb.w	9,$247
 dc.w	$237,$247,$247,$237,$247
 dcb.w	16,$237
 dc.w	0,0,0,0,0,0,0,0,0,0
	even


scroll_number	dc.w	16
line_ptr	dc.l	scroll_line
buffer		dcb.b	BUFFER_SIZE,0

scroll_line
 dc.b "   PERSISTENCE OF VISION PACKED DEMO DISC 103.    "
 dc.b "THIS MENU IS DEDICATED TO OZ OUR GRAFIX ARTIST WHO DESIGNED THE "
 DC.B "PICTURE TO HAVE BACKGROUND RASTERS.     CREDITS: MENU CODED BY M.S.D.,   "
 DC.B "GRAFIX BY OZ (OF COURSE) AND MUSIC FROM PRE-HISTORIC TALE BY MAD MAX.    "
 DC.B "RELEASE DATE 1ST MARCH 1992.       AT LAST IT'S OUT, I WAITED A LONG TIME TO "
 DC.B "RELEASE THIS DISC, IT MUST HAVE BEEN READY FOR OVER 3 MONTHS BUT I HAD "
 DC.B "TO WORK ON POV 100.    THIS DISC HAS BEEN RELEASE IN A BATCH "
 DC.B "OF OVER 10 DISCS AS A COME BACK FOR POV.    IF YOU READ THE SCROLL "
 DC.B "TEXT ON DISC 99 THEN YOU WILL KNOW THAT WE WERE GIVING UP FOR A WHILE WELL, "
 DC.B "WE LIED!  THE REASON FOR NO DISC RELEASES WAS THAT BOTH BORIS AND "
 DC.B "I WERE WORKING ON OTHER PROJECTS.  I AM NOW FREE TO CODE WHATEVER I WANT "
 DC.B "AND BORIS WILL BE FREE SOON FOR SOME MENU MAKING.     "
 DC.B "I WILL TRY TO GET DISCS UPTO 125 OUT BEFORE I START ON MY "
 DC.B "NEXT PROJECT.     THERE IS A RUMOUR ABOUT US WORKING ON A "
 DC.B "GAME..... WELL IF I AM I MUST DO IT IN MY SLEEP!  HOWEVER BORIS HAS JUST "
 DC.B "FINISHED CONVERTING THE GAME LEANDER FROM THE AMIGA TO THE ST SO GO BUY IT. "
 DC.B "                    OKAY HERE ARE THE GREETINGS....... "
 DC.B "MEGA GREETS TO   OZ,   BORIS,   RED MERCURY (KGB),   BILBO (RIPPED OFF),   "
 dc.b "SPEED (THE SOURCE),   MUG UK (THE SOURCE),   DR.SYNE (ZEN),   "
 DC.B "GEORGE (TOWER PD)   AND   DEL (D.W. STABLES PD).       "
 DC.B "NORMAL GREETS TO STU (MR.X OF PROPHECY PD AND THE SOURCE),   SWSL,   "
 DC.B "DELTA FORCE,   CAPTAIN HACKS,   ADRENALIN,   ERIK PLANKTON + "
 DC.B "BLIND BASTARD AND FINALLY THE PIXEL TWINS.            "
 dc.b "QUESTION FOR ALL YOU PEOPLE OUT THERE WHO CAN'T OR DON'T "
 DC.B "WRITE DEMOS OR MENUS...   IF YOU WROTE A SCROLL TEXT, WHAT "
 DC.B "WOULD YOU WRITE?                 OKAY SO YOU'VE WRITTEN ONE "
 DC.B "SCROLL TEXT FOR ONE DISC.   NOW WRITE ANOTHER AND DON'T REPEAT "
 DC.B "THINGS FROM THE FIRST.                WELL?        NOT TOO EASY "
 DC.B "IS IT?       ONCE YOU'VE THOUGHT OF SOMETHING NEW TO WRITE "
 DC.B "AND IT'S IN 'DC.B' STATEMENTS IN THE ASSEMBLER (OR AN INCBIN) "
 DC.B "THEN HAVE A LOOK HOW LONG IT IS.      IT LOOKS A LOT DOESN'T IT? "
 DC.B "       RIGHT ASSEMBLE IT AND READ IT THROUGH.     YOU'LL "
 DC.B "REALISE THAT THE TEXT DISAPPEARS RATHER FAST SO YOU HAVE "
 DC.B "TO WRITE MORE WAFFLE.   WELL IT CARRIES ON LIKE THIS FOR "
 DC.B "A WHILE THEN YOU'LL ADD THE GREETINGS AND GIVE UP.    "
 DC.B "IF YOU ASK MOST MENU MAKERS WHAT THE HARDEST PART OF A MENU IS "
 DC.B "THEN I CAN BET THAT MOST WILL SAY THE SCROLL TEXT!      "
 DC.B "           RIGHT THIS TEXT IS SHORT AS I'VE GOT MORE MENUS "
 DC.B "TO FINISH, SO HERE COMES THE WRAPPER...        "
 DC.B "                                                          "
 dc.b	$ff

font	incbin	med_font.dAT


*************** spectrum analyzer bits and bobs ***********
spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0
***********************************************************

top_raster_pos

top_rasters
 dc.w	$020,$030,$040,$050,$060,$070
 dc.w	$1f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0
 dc.w	$f70,$f60,$f50,$f40,$f30,$f20,$f10

border_rasters
	dc.w	$800,$180,$910,$290,$a20,$3a0,$b30,$4b0
	dc.w	$c40,$5c0,$d50,$6d0,$e60,$7e0,$f70
	dc.w	$ff0,$770,$ee0,$660,$dd0,$550,$cc0,$440
	dc.w	$bb0,$330,$aa0,$220

;bottom scroller colour
	dc.w	0,0,0,0,0,0,0,0
	dc.w	$017,$027,$037,$047,$057,$067,$077
	dc.w	$076,$075,$074,$073,$072,$071,$070,$060

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5
;	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,4	;keypad 5
;	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

filenames	dc.l	exec1,exec2,exec3,exec4

exec1	dc.b	"klf",0
	even
exec2	dc.b	"3615gen4",0
	even
exec3	dc.b	"EMPIRE",0
	even
exec4	dc.b	"copier.pov",0
	even



*****************************
	SECTION BSS
*****************************

old_palette	ds.w	16

hertz_toggle	ds.w	1
zero_counter	ds.w	1

old484		ds.b	1
key		ds.w	1
	even
	ds.b	256
screens	ds.b	160*29
	ds.b	160*200
	ds.b	160*47
stopper