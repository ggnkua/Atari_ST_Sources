****************
* P.O.V. 37    *
****************

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
	move.b	$484,old484
;switch blade tunme
	move.l	#1,D0
	bsr	tune
	bsr	credits
	pea	cls
	move.w	#9,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	#25,d0
.loop	bsr	v_sync
	dbf	d0,.loop
	bsr	set_palette
	move.w	#25,d0
.loop2	bsr	v_sync
	dbf	d0,.loop2
	bsr	set_for_border
	move.w	#25,d0
.loop3	bsr	vsync
	dbf	d0,.loop3
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
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$ffff,hz_switch
	eor.w	#$400,$ffff8240.w
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
	cmp.b	#$a,d0		;9 key
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
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
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
	move.w	#19-1,d3	;19 masks
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
	bsr	tune+$4
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
	lea	pal_table,a0
	move.w	#30-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
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
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b	"                   MAC SYS DATA AND CO. PRESENTS - P.O.V. "
 dc.b	"37.      "
 dc.b	"P.O.V. CONSISTS OF THE FOLLOWING ...   MAC SYS DATA,   BORIS,  OZYMANDIAS,  "
 dc.b	"AND   ALY       WE SEND OUR GREETINGS TO  -  "
 dc.b	"AUTOMATION,   DIRTY TRICKS BRIGADE,   DR.SYNE,   EMPIRE,   EQUINOX,   "
 DC.B	"GEORGE,   MARTIAN,   SEWER SOFTWARE (I'M GLAD YOU LIKE OUR DISCS),   TCB,   "
 DC.B	"THE LOST BOYS,   THE MEDWAY BOYS,   THE POMPEY PIRATES,   "
 DC.B	"THE REPLICANTS   AND   THE UNION.      "
 dc.b	"WELL AS YOU CAN SEE THIS DISC HAS SEVERAL STE ONLY DEMOS "
 DC.B "ON, THEY WERE ORIGINALLY ON A BOOT SECTOR LOADING DEMO AND YOU "
 DC.B "HAD TO LOAD THE DEMOS SERIALLY SO YOU COULDN'T JUST SELECT THE ONE YOU "
 dc.b "WANTED. AFTER EACH STE DEMO YOU HAVE TO RESET YOUR STE - SORRY BUT IT "
 dc.b "JUST HAPPENED THAT WAY!      THE NITROWAVE "
 DC.B "DEMO HAS A MENU SCREEN FROM WHICH YOU SELECT THE 3 DEMOS. AFTER EACH "
 DC.B "NITROWAVE DEMO YOUR ST WILL RESET - DON'T BLAME ME AS THIS WAS "
 DC.B "WRITTEN INTO THE ORIGINAL. WHEN YOUR ST DOES RESET YOU WILL HAVE "
 DC.B "TO SELECT THE DEMO AGAIN AND LOAD THE NEXT SCREEN.    IF YOU'RE "
 DC.B "THINKING OF COMPLAINING THEN DON'T BECAUSE THEY ORIGINALLY CAME "
 DC.B "ON ONE DISC AND WERE OVER 700K BUT NOW THEY'RE ON A COMPILATION "
 DC.B "AND ARE A VERY RESPECTABLE 365K.               OH YEH, I NEARLY "
 DC.B "FORGOT....... THE CREDITS:     MENU CODED BY MAC SYS DATA WITH "
 DC.B "SCROLL CODE BY BORIS (THANX!),  ART BY MARTIAN   AND  MUSIC "
 DC.B "FROM SWITCHBLADE.           RIGHT, ALY IS HERE SO HE CAN TYPE SOME "
 dc.b "TEXT IN......... GOT A JOKE FOR YOU           HOW DO YOU KNOW MIKE "
 DC.B "SMITH HAS A BIG DICK ?...........COS HE BROKE BOTH SARAH GREEN'S "
 DC.B "LEGS WITH HIS CHOPPER !!!!!        ARRRGGGGHHH WHAT A TERRABLE JOKE "
 DC.B "        I THINK I SHOULD WRITE FOR LANCASHIRE POLY RAG MAG!!!!!!"
 DC.B "     A BIG SOD OFF TO COLIN THOMLINSON - HE WAS SUPPOSSED TO GO ON "
 DC.B "THE THREE LEGGED PUB CRAWL WITH ME TONIGHT ( WHICH IS WHY I'M "
 DC.B "TYPING THIS SCROLLER IN )           ONLY 20K MORE TO GO       "
 DC.B "YOU CAN GET LOST IF YOU EXPECT ME TO SIT HERE ALL NIGHT AND TYPE "
 DC.B "A SCROLLER FOR THE LIKES OF YOU TO READ, I'M OFF TO THE PUB TO "
 DC.B "DROWN MY SORROWS SINCE I'M NOT GOING ON THE CRAWL. "
 DC.B "A BIG HELLO TO EVERYONE AT LANCS POLY....AND EVERYWHERE ELSE AS WELL "
 DC.B "( COME TO LANCS POLY TO STUDY AND YOU CAN HAVE A FREE HOLIDAY AT "
 DC.B "PONTINS! )            MUST GO      BEER CALLS            "
 DC.B "RAVE ON!            AL"
 DC.B "              RIGHT IT'S ME (M.S.D.) BACK NOW, I'VE JUST "
 DC.B "RECEIVED SEWER SOFTWARE DOC DISCS 20 AND 21.  HEY BOYS I LIKE "
 DC.B "THE NEW MENU IT'S BRILLIANT!    RIGHT THAT'S IT WRAP AROUND TIME...          "
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
	dc.b	27,'Y',32+9,32+15,"NUMBER 37",0
mess3	dc.b	27,'E'
	dc.b	27,'Y',32+6,32+10,"MEMBERS OF P.O.V. ARE"
	dc.b	27,'Y',32+8,32+14,"MAC SYS DATA"
	dc.b	27,'Y',32+10,32+17,"BORIS"
	dc.b	27,'Y',32+12,32+15,"OZYMANDIAS"
	dc.b	27,'Y',32+14,32+18,"ALY",0
cls	dc.b	27,'E',0
	even

tune:	Incbin "s_blade.img"
	even
pic	incbin	"pov37.PI1"

masks:	dc.w	%1111111100000000
	dc.w	%1111111100000000
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
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
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
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000001111
	dc.w	%0000000000001111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000111111111111
	dc.w	%0000111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
	dc.w	%0000000000000011
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
	dc.w	%1111111111110011
	dc.w	%1111111111110011
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
	dc.w	%1100000000000011
	dc.w	%1100000000000011
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
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
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000111111
	dc.w	%1100000000111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
	dc.w	%1100000000001111
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
	dc.w	%1111110000001111
	dc.w	%1111110000001111
	dc.w	%1111000000001111
	dc.w	%1111000000001111
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
	dc.w	%1111000000111111
	dc.w	%1111000000111111
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
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
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
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
	dc.w	%1111000000111111
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
	dc.w	%1111110000111111
	dc.w	%1111110000111111
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
	dc.w	%1111110011111111
	dc.w	%1111110011111111
	dc.w	%1111110011111111
	dc.w	%1111110011111111
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
	dc.b	"4096.DAT",0,0,0,0,0,0
	dc.b	"MULTI.DAT",0,0,0,0,0
	dc.b	"SCROLL.DAT",0,0,0,0
	dc.b	"FULL.MSD",0,0,0,0,0,0
	dc.b	"NITRO.MSD",0,0,0,0,0
	dc.b	"MOB.MSD",0,0,0,0,0,0,0
	dc.b	"TCB.WOW",0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0

	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000

