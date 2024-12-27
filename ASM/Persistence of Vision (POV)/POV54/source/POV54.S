****************
* P.O.V. 54    *
****************

	bsr	set_super
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484
;Music from INNER CIRCLE menu
; Ripped by MAC SYS DATA
	move.l	#1,D0
	jsr	tune
	bsr	set_palette
	bsr	save_isr
	bsr	vsync
	bsr	show_pic
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	#$700,$ffff8240.w
	bsr	clear_spec
;	move.w	#$070,$ffff8240.w
	bsr	spec
;	move.w	pic+2,$ffff8240.w
	move.b	key,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$500,bor+2
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq	do_reset
	cmp.b	#2,d0		;1 key
	blt.s	main_loop
	cmp.b	#7,d0		;6 key
	bge	main_loop	

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
	clr.w	(a1)+
	move.w	#$fff,(a1)

	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#16,d0
	add.w	d0,a6
	lea	$200,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6),(a0)

	tst.w	hertz_switch
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
	bsr	reset_isr
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
scroll:	move.l	screen_base,a1
	add.l	#160*204+(160*30),a1
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
	mulu	#120,d0		;30
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0		;char depth 4 bytes * 30 deep
	add.w	d0,a0

.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
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



clear_spec
	lea	spec_values,a0
	move.w	#80-1,d0
.cnt_down
	move.b	(a0)+,d1
	beq.s	.next
	sub.b	#1,-1(a0)
.next	dbf	d0,.cnt_down
	move.l	screen_base,a0
	add.w	#(8*160)+6,a0
	moveq	#0,d1
	REPT	26
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

	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	bchan
	moveq.l	#0,d0
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	move.w	#80-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	bchan
	beq.s	.yes
	add.w	#4,a3
	dbf	d1,loopa
	bra.s	bchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	cchan
	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	cchan
	beq.s	.yes
	add.w	#4,a3
	dbf	d1,.loop
	bra.s	cchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
******************
cchan
	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	ps

	lea	spec_lookup,a3
	lea	spec_values,a2
	moveq.l	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	.yes
	beq.s	.yes
	add.w	#4,a3
	dbf	d1,.loop
	bra.s	ps
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)


******************** print speccy *******************
ps
	move.l	screen_base,a0
	add.w	#(160*20)+6,a0

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

.nonib	add.w	#8,a0
	dbf	d1,.loop
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
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	lea	position_table,a2
	move.w	#500/4-1,d0
.loop
	movem.l	d0/a0-a1,-(sp)
	bsr	vsync
	bsr	print
	bsr	print
	bsr	print
	bsr	print
	movem.l	(sp)+,d0/a0-a1
	dbf	d0,.loop
	rts

print
	lea	pic+34,a0
	move.l	screen_base,a1
	add.w	#160*30,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a2)+,d1
	move.b	(a2)+,d0
	mulu	#160*8,d0
	mulu	#8,d1
	add.w	d1,d0
	add.w	d0,a0
	add.w	d0,a1
	REPT	8
	move.w	(a0),(a1)
	move.w	2(a0),2(a1)
	move.w	4(a0),4(a1)
	move.w	6(a0),6(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
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
	move.w	#40,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

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
bor	move.w	#$700,$ffff8242.w
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
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.b	#$e4,$fffffa21.w
	move.b	#8,$fffffa1b.w
	jsr	tune+6
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
screen_base:	dc.l	0
old484:		dc.w	0
stack_save:	dc.l	0
******************* isr details *******
key:		dc.b	0
	even
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
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 DC.B "                    "
 dc.b "I BET THEY DRINK CARLING BLACK LABEL!!     THE BEST IN THE "
 DC.B "BUSINESS (PERSISTENCE OF VISION) PRESENTS IT'S PACKED "
 DC.B "DEMO COMPILATION 54.    THIS IS MAC SYS DATA AT THE KEYBOARD "
 DC.B "TYPING THE THINGS YOU ALL HATE TO READ - YEH SCROLLTEXT.   "
 DC.B "RIGHT 'CAUSE THESE THINGS MAKE YOU ILL JUST WATCHING THEM, "
 DC.B "I'LL TRY TO MAKE IT SHORT(ISH).    TO KICK OFF WITH "
 DC.B "I WOULD LIKE TO SAY THANKS TO JOHN PASS AT THE DEMO CLUB FOR "
 DC.B "BEING SO PROMPT AT SENDING MY DISCS BACK!!!!! (IT'S AN "
 DC.B "INSIDE JOKE).    WITH THE LAST BATCH OF DISCS I RECEIVED, "
 DC.B "I GOT 2 RIPPED OFF DEMO COMPILATIONS, I MUST SAY THAT "
 DC.B "YOU BOYS MUST SPEND AT LEAST 15 SECONDS ON YOUR MENUS AS THEY "
 DC.B "LOOK VERY NICE WITH ALL THOSE EXCITING ROUTINES!!! (SARCASTIC BASTARD "
 DC.B "'CAUSE THEY'RE SHIT). "
 DC.B "I'VE ALSO FOUND OUT THAT YOU'VE GOT OBERJE FROM THE FINGERBOBS "
 DC.B "WRITING A MENU FOR YOU - WHAT A BLOODY CHEEK, YOU SHOULD WRITE YOUR "
 DC.B "OWN MENUS AND STOP BEING LAMERS.   "
 DC.B "NOW THAT'S OFF MY CHEST I'LL GIVE YOU THE GREETINGS... "
 DC.B "HI TO   DR.SYNE,   MARTIAN,   TLB,   TCB,   PHALANX   AND   INNER CIRCLE. "
 DC.B "   THIS MENU WAS CODED BY M.S.D,  GRAFIX BY OZ   AND MUSIC BY "
 DC.B "COUNT ZERO.     WELL I SAID I'D MAKE IT SHORT AND SO THIS IS THE END... "
 DC.B "PREPARE TO WRAPPPPP............  "
 DC.B "                             "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	"1plane.fnt"
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

******* show pic data *********
position_table
	incbin	fill.dat
;*************************
tune:	incbin	count1.img
	even
pic	incbin	pov54.PI1
	even

spec_lookup
	dc.w	$fd1,0
	dc.w	$bdd,1
	dc.w	$bdb,2
	dc.w	$bd9,3
	dc.w	$bd7,4
	dc.w	$bd5,5
	dc.w	$9f9,6
	dc.w	$9f7,7
	dc.w	$9f5,8
	dc.w	$7ec,9
	dc.w	$7ea,10
	dc.w	$7e8,11
	dc.w	$7e6,12
	dc.w	$7e4,13
	dc.w	$3f4,14
	dc.w	$238,15
	dc.w	$1fa,16
	dc.w	$1a9,17
	dc.w	$17b,18
	dc.w	$152,19
	dc.w	$151,20
	dc.w	$150,21
	dc.w	$13f,22
	dc.w	$13e,23
	dc.w	$11e,24
	dc.w	$11d,25
	dc.w	$11c,26
	dc.w	$11b,27
	dc.w	$11a,28
	dc.w	$fe,29
	dc.w	$fd,30
	dc.w	$fc,31
	dc.w	$fb,32
	dc.w	$ee,33
	dc.w	$e3,34
	dc.w	$e2,35
	dc.w	$e1,36
	dc.w	$e0,37
	dc.w	$d6,38
	dc.w	$d5,39
	dc.w	$d4,40
	dc.w	$d3,41
	dc.w	$d2,42
	dc.w	$bf,43
	dc.w	$be,44
	dc.w	$bd,45
	dc.w	$bc,46
	dc.w	$bb,47
	dc.w	$b3,48
	dc.w	$b2,49
	dc.w	$aa,50
	dc.w	$a9,51
	dc.w	$a8,52
	dc.w	$a7,53
	dc.w	$a6,54
	dc.w	$a0,55
	dc.w	$9f,56
	dc.w	$9e,57
	dc.w	$90,58
	dc.w	$8f,59
	dc.w	$8e,60
	dc.w	$8d,61
	dc.w	$8c,62
	dc.w	$82,63
	dc.w	$80,64
	dc.w	$7f,65
	dc.w	$7e,66
	dc.w	$7d,67
	dc.w	$7c,68
	dc.w	$7a,69
	dc.w	$78,70
	dc.w	$77,71
	dc.w	$76,72
	dc.w	$6c,73
	dc.w	$6b,74
	dc.w	$6a,75
	dc.w	$69,76
	dc.w	$68,77
	dc.w	$5e,78
	dc.w	$54,79

spec_values	dcb.b	1000,0


filenames:
	dc.b	"JOE90.DEM",0,0,0,0,0,0,0
	dc.b	"BATH.DEM",0,0,0,0,0,0,0,0
	dc.b	"CES_90.DEM",0,0,0,0,0,0
	dc.b	"BITSCAN.MSD",0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

	SECTION BSS
scroll_buffer:	ds.b	44*35+4*35
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	45000
