****************
* P.O.V. 49    *
****************
;	OPT	o+
	bsr	set_super
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
	move.l	screen_base,a0
	add.l	#46082,a0
	move.l	a0,spec_pos
	move.b	$484.w,old484
	clr.b	$484.w

;************************************************************************
;*                  INNER CIRCLE FLEXI-SCROLLER                         *
;*                  ---------------------------                         *
;* Stolen by: MAC SYS DATA of P.O.V. 26/11/90 22:54                     *
;*      From: INNER CIRCLE 'DECADE DEMO'                                *
;* Include files:-                                                      *
;*                 FLEX.IMG into TUNE                                   *
;************************************************************************
;* Written by COUNT ZERO
	moveq.l	#1,D0
	jsr	tune

	bsr	set_palette
	bsr	save_isr
	bsr	vsync
	bsr	show_pic
	pea	text50
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	vsync
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	scroll
;	move.w	#$700,$ffff8240.w
	bsr	clear_spec
	bsr	spec
;	move.w	#$444,$ffff8240.w
;	move.w	pic+2,$ffff8240.w
	move.b	key,d0
	beq.s	main_loop

;	cmp.b	#01,d0		;escape
;	beq	exit

	tst.w	zero_counter
	beq.s	car
	subq.w	#1,zero_counter
	bra.s	check_keys
car
	cmp.b	#$b,d0		;0 key
	beq	zero
	cmp.b	#$70,d0
	beq	zero

check_keys
	cmp.b	#$53,d0
	beq	do_reset

	cmp.b	#$6d,d0		;keypad 1
	beq.s	keypad
	cmp.b	#%01101110,d0	;keypad 2
	beq.s	keypad
	cmp.b	#%01101111,d0	;keypad 3
	beq.s	keypad
	cmp.b	#%01101010,d0	;keypad 4
	bne.s	keyboard
	addq.b	#6,d0
keypad	sub.b	#$6b,d0

keyboard
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#6,d0		;5 key
	bge	main_loop	

	bsr	flush
	move.l	d0,-(sp)
	bsr	reset_isr
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
	subq.b	#2,d0
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
hz50:	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4.w,a0
	jmp	(a0)

zero	tst.w	zero_counter
	bne	car
	eor.w	#$ffff,hertz_switch
	tst.w	hertz_switch
	beq.s	hertz50
	pea	text60
do_text	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#10,zero_counter
	bra	main_loop
hertz50	pea	text50
	bra.s	do_text

zero_counter:	dc.w	0
exit:
	bsr	reset_isr
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
clear_spec
	lea	spec_values,a0
	move.w	#20-1,d0
.cnt_down
	move.b	(a0)+,d1	
	beq.s	.next
	subq.b	#1,-1(a0)
.next	move.b	(a0)+,d1	
	beq.s	.next2
	subq.b	#1,-1(a0)
.next2	move.b	(a0)+,d1	
	beq.s	.next3
	subq.b	#1,-1(a0)
.next3	move.b	(a0)+,d1	
	beq.s	.next4
	subq.b	#1,-1(a0)
.next4	dbf	d0,.cnt_down

	move.l	spec_pos,a0
	sub.w	#(50*160),a0
	moveq	#0,d1
	REPT	25
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	ENDR
	rts
	
************************************************
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_lookup,a3

	moveq.l	#0,d0
	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	bchan
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	move.w	#80-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	bchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,loopa
	bra.s	bchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)

******************
bchan
	moveq.l	#0,d0
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	cchan
	lea	spec_lookup,a3
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	cchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	cchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
******************
cchan
	moveq.l	#0,d0
	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	ps

	lea	spec_lookup,a3
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	.yes
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	ps
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)


******************** print speccy *******************
ps	move.l	spec_pos,a0
	sub.w	#160*38,a0

	lea	spec_values,a2
	move.w	#80-1,d1
.loop	move.l	a0,a1
	move.l	a0,a3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	and.w	#$ff,d0
	move.b	#%11100000,d2
.loop1	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
	and.w	#$ff,d0
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

**************************************************


scroll:	move.l	screen_base,a1
	add.w	#160*204,a1
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
	mulu	#32*4*4,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#32*4,d0	;character depth * 4 (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	32
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
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
	move.l	#coderte,$24.w
	rts

coderte	rte

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
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
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
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
	move.w	#30,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

flush	btst.b	#0,$FFFC00	;flush keyboard
	beq.s	flush2
	move.b	$FFFC02,d0
	bra.s	flush
flush2	rts

*********
* ISRs  *
*********
save_isr
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
	move.l	#new120,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
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

new120	clr.b	$fffffa1b.w
	move.l	d0,-(sp)
	moveq	#$26,d0
.aaa	dbf	d0,.aaa
	move.b	#0,$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.w	pic+2,$ffff8240.w
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
	bclr	#0,$fffffa0f.w
	clr.b	$fffffa1b.w
	move.l	(sp)+,d0
	rte

new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
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
	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.b	#$e4,$fffffa21.w
	move.b	#8,$fffffa1b.w
	jsr	tune+6
	rte

new118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	bclr	#6,$fffffa11.w
	rte

********
* Data *
********
	SECTION DATA
screen_base:	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
old118:	dc.l	0
key	dc.w	0
save1	dc.b	0
save2	dc.b	0
save3	dc.b	0
save4	dc.b	0
save5	dc.b	0
save6	dc.b	0
save7	dc.b	0
save8	dc.b	0
	even
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0
text50	dc.b	27,'Y',32+1,32+22,"50",0
text60	dc.b	27,'Y',32+1,32+22,"60",0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    "
 dc.b "MAC SYS DATA PRESENTS - "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 49.       "
 dc.b "CODING AND MUSIC RIPPING BY MAC SYS DATA, GRAFIX BY MARTIAN, "
 dc.b "ORIGINAL FONT BY OZYMANDIAS (WHO?) - THIS VERSION WAS GENTLY ABUSED BY M.S.D. "
 dc.b "AND FINALLY   THE MUSIC "
 DC.B "IS BY THE SUPERB COUNT ZERO, RIPPED "
 DC.B "FROM THE FLEXI SCROLLER SCREEN ON THE INNER CIRCLE DECADE DEMO. "
 DC.B "     I'VE JUST READ MOST OF THE NEW MAGGIE DISC (VERSION 3), "
 DC.B "I TOOK PARTICULAR INTEREST IN THE 'RIPPED OFF' SECTION.   IT "
 DC.B "WOULD APPEAR THAT WE ARE NOT THE UK'S NUMBER 1 DEMO PACKING GROUP "
 DC.B "AS RIPPED OFF HAVE RELEASED MORE DISCS THAN WE HAVE.   "
 DC.B "I'VE SEEN THE TITLES ON A COUPLE OF THEIR DISCS AND "
 DC.B "DON'T THINK THAT WE ARE IN THE SAME LEAGUE. "
 DC.B "   FOR INSTANCE P.O.V. WOULD NEVER RELEASE A PACKED MOD DISC WITH NO MODULE "
 DC.B "DRIVER ON BECAUSE IT'S SO LAME.   IF WE ADDED THE P.O.V. "
 DC.B "SOUNDTRACKER DISCS TO OUR PACKED DEMO DISCS THEN WE WOULD "
 DC.B "HAVE ABOUT 90 DISCS.   WHILST LOOKING THROUGH SOME OF "
 DC.B "THE RIPPED OFF DISCS I NOTICE THAT THEY HAVE ONLY PACKED "
 DC.B "THE EASY ONES THAT COME IN FILES - WHAT ABOUT MEGABANG 2 AND "
 DC.B "THE DEMON DEMO?  I HAD TO HACK THE CODE OFF THE DISCS AND "
 DC.B "WRITE NEW LOADERS TO GET THEM OUT.    "
 DC.B "   THIS MAY SOUND LIKE A SLAGGING BUT I AM A BIT "
 DC.B "PISSED OFF THAT SOMEBODY ELSE HAS RELEASED MORE DISCS "
 DC.B "THAT WE HAVE.        WELL WHO CARES? IT'S COMPETITION AND I THINK "
 DC.B "THERE'S PLENTY OF ROOM FOR BOTH OF US AND WE BELEIVE IN QUALITY NOT "
 DC.B "QUANTITY (HONEST!!!!!!)          "
 DC.B "HERE ARE THE GREETINGS FOR ANOTHER DISC.... "
 DC.B "MERRY XMAS TO     AUTOMATION,   MEDWAY BOYS,   POMPEY PIRATES,   "
 DC.B "GEORGE,   SKUNK,   DR.SYNE,   DTB,   ERIK PLANKTON,   "
 DC.B "INNER CIRCLE,   THE UNION,   THE REPLICANTS,   "
 DC.B "TCB,   THE LOST BOYS,   THE DEMO CLUB,   "
 DC.B "SEWER SOFTWARE,   RIPPED OFF,   MARTIAN   AND   GEN4.        "
 DC.B "TODAY IS A THURSDAY AND HARRY ENFIELD HAS COME ON THE TV SO "
 DC.B "I'LL HAVE A SHORT BREAK TO WATCH IT - IT'LL GIVE YOU SOME TIME "
 DC.B "TO WATCH THE SPECTRUM ANALSYER!         "
 DC.B "                                                          "
 DC.B "                                                          "
 DC.B "                                                          "
 DC.B "                                                          "
 DC.B "HELLO, WELL I'VE WATCHED HARRY ENFIELD BUT SMITH AND JONES "
 DC.B "HAS STARTED SO I'LL TRY TO TYPE AND WATCH AT THE SAME TIME!     "
 DC.B "  I'D LIKE TO TAKE THIS SPACE TO ASK FOR AN ARTIST AS WE HAVE "
 DC.B "NO NEW PICTURES TO USE AFTER THE NEXT 10 OR SO DISCS.  "
 DC.B "IF YOU HAVE SOME GOOD PICTURES THEN SEND THEM VIA THE DEMO CLUB. "
 DC.B "THE PICTURES MUST BE ORIGINAL AND CAN BE IN ANY PICTURE FORMAT.   "
 DC.B "     WELL WHAT DO YOU THINK OF THIS NO TOP AND BOTTOM BORDER "
 DC.B "MENU?    OKAY SO OTHER GROUPS HAVE BEEN DOING IT FOR AGES BUT "
 DC.B "THIS IS OUR FIRST SO SHUT UP!    THE SPECTRUM ANALYSER "
 DC.B "BELOW IS VERSION 2, THE ORIGINAL ONE TRIED TO PUT SHOW 4096 POINTS "
 DC.B "ON THE SCREEN WHICH IS BASICALLY IMPOSSIBLE. THIS NEW VERSION "
 DC.B "TAKES THE COMMON NOTE VALUES AND HOLDS THEM IN A TABLE, WHEN "
 DC.B "IT DETECTS ONE OF THESE 'COMMON' NOTES IT SHOWS A BAR.    I THOUGHT "
 DC.B "AUTOMATIONS ANALYSER LOOKED PRETTY GOOD SO I WROTE ONE TO LOOK "
 DC.B "EXACTLY THE SAME EVEN THOUGH IT IS MY OWN CODE.   IF YOU "
 DC.B "DON'T BELIEVE ME THEN HACK THE ROUTINE OUT OF THE MENU.   "
 DC.B "      THE DISC COPIER ON THIS DISC IS OUR STANDARD COPIER "
 DC.B "FOR P.O.V. DISCS, IT'S VERY SLOW BUT IT WILL COPY THE MENU "
 DC.B "CORRECTLY WHICH WILL HOPEFULLY LEAD TO LESS CORRUPTED "
 DC.B "DISCS. I HAVE DISASSEMBLED THE COPIER SO I CAN NOW "
 DC.B "PATCH ANY ROUTINE INTO THE CODE. I HAD A GO AT PUTTING A TUNE "
 DC.B "IN BUT THE COPIER CRASHED WHEN IT STARTED WRITING THE DESTINATION! "
 DC.B "- I'LL FIX IT SOON (I HOPE!).     "
 DC.B "I'VE BEEN WORKING ON THIS MENU FOR ABOUT A WEEK NOW BECAUSE "
 DC.B "I'VE BEEN COPYING DISCS FOR EVERYBODY ELSE IN TIME FOR XMAS. "
 DC.B "   I'VE GONE THROUGH 500 DISCS IN 4 WEEKS - I SELL BLANK DISCS "
 DC.B "AS WELL AS RELEASE THESE COMPACT DEMO DISCS.    OVER THE LAST "
 DC.B "TWO NIGHTS I COPIED 150 DISCS FOR A BLOKE AT WORK WHICH MEANT "
 DC.B "I WASN'T CODING, LAST NIGHT I WENT TO THE PUB WITH BORIS AND "
 DC.B "GOT DRUNK! THAT LEAVES 4 DAYS FOR CODING THIS MENU, I MUST "
 DC.B "HAVE SPENT 2 DAYS EXPERIMENTING WITH THE BORDER CODE AND I "
 DC.B "A NIGHT TO WRITE A NEW SPECTRUM ANALYSER.   THE HARDEST "
 DC.B "PART OF DOING THESE MENUS IS THE SCROLLTEXT, IT TAKES "
 DC.B "AGES TO TYPE ONE IN AND BORIS ALWAYS GETS ME TO DO THEM "
 DC.B "'CAUSE HE CAN NEVER THINK WHAT TO WRITE.      "
 dc.b "WELL THE TIME HAS ARRIVED FOR THE WRAP SO YOU BETTER PRESS A "
 DC.B "KEY OR YOU'LL HAVE TO ENDURE THE WHOLE SCROLLTEXT AGAIN.... "
 dc.b "                                    "
 dc.b "                                    "
 dc.b $ff
	even
spec_pos	dc.l	0
char_offset	dc.w	0
font:	dcb.b	32*4*4,0
	incbin	4plane.fnt
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

tune:	incbin	flex.img
	even
pic	incbin	pov49.PI1
	even
spec_lookup
	dc.w	$eee,0
	dc.w	$e17,1
	dc.w	$d4d,2
	dc.w	$c8e,3
	dc.w	$bd9,4
	dc.w	$b2f,5
	dc.w	$a8e,6
	dc.w	$9f7,7
	dc.w	$967,8
	dc.w	$8e0,9
	dc.w	$861,10
	dc.w	$7e8,11
	dc.w	$777,12
	dc.w	$70b,13
	dc.w	$6a6,14
	dc.w	$647,15
	dc.w	$5ec,16
	dc.w	$597,17
	dc.w	$547,18
	dc.w	$4fb,19
	dc.w	$4b3,20
	dc.w	$470,21
	dc.w	$430,22
	dc.w	$3f3,23
	dc.w	$3bb,24
	dc.w	$385,25
	dc.w	$353,26
	dc.w	$323,27
	dc.w	$2f6,28
	dc.w	$2cb,29
	dc.w	$2a3,30
	dc.w	$27d,31
	dc.w	$259,32
	dc.w	$238,33
	dc.w	$218,34
	dc.w	$1fa,35
	dc.w	$1dd,36
	dc.w	$1c2,37
	dc.w	$1a9,38
	dc.w	$191,39
	dc.w	$17b,40
	dc.w	$165,41
	dc.w	$151,42
	dc.w	$13e,43
	dc.w	$12c,44
	dc.w	$11c,45
	dc.w	$10c,46
	dc.w	$0fd,47
	dc.w	$0ee,48
	dc.w	$0e1,49
	dc.w	$0d4,50
	dc.w	$0c8,51
	dc.w	$0bd,52
	dc.w	$0b2,53
	dc.w	$0a8,54
	dc.w	$09f,55
	dc.w	$096,56
	dc.w	$08e,57
	dc.w	$086,58
	dc.w	$07e,59
	dc.w	$077,60
	dc.w	$070,61
	dc.w	$06a,62
	dc.w	$064,63
	dc.w	$05e,64
	dc.w	$059,65
	dc.w	$054,66
	dc.w	$04f,67
	dc.w	$04b,68
	dc.w	$047,69
	dc.w	$043,70
	dc.w	$03f,71
	dc.w	$03b,72
	dc.w	$038,73
	dc.w	$035,74
	dc.w	$032,75
	dc.w	$02f,76
	dc.w	$02c,77
	dc.w	$02a,78
	dc.w	$027,79

filenames:
	dc.b	"MOTLEY.DEM",0,0,0,0
	dc.b	"lostboys.DEM",0,0
	dc.b	"KATEBUSH.DEM",0,0
	dc.b	"COPIER.POV",0
	even

spec_values	dcb.b	400,0

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	48000
