*************************************************************************
*				TRuST PD INTRO				*
*				~~~~~~~~~~~~~~				*
*									*
* Written by MAC SYS DATA of P.O.V.					*
* Date: 6/5/91								*
*									*
* Assemble with GENST 2.08 or higher					*
*									*
* Include files;-							*
*		TRUST1.PI1						*
*		TRUST2.PI1						*
*		MAIN.PI1						*
*		MAX15.MUS						*
*		LANDER_1.FNT						*
*		PATH.DAT						*
*									*
*************************************************************************
	OPT	o+,w-

	bra	over
 dc.b	"½ MAC SYS DATA of PERSISTENCE OF VISION¿ 1991.     "
 dc.b	"P.O.V.,     P.O. BOX 40,   THORNTON-CLEVELEYS,   "
 DC.B	"BLACKPOOL,      FY6 9AZ,      UK.       TEL: 0253 700382 FOR "
 DC.B	"DIRECT CONTACT WITH MAC SYS DATA.      "
	even

over	bsr	load_text
	bsr	set_super		;go into supervisor
	move.b	#$12,$fffffc02.w	;disable mouse
	bsr	get_screen_base		;get present screen address
	bsr	get_old_palette		;save old palette
	bsr	get_original_rez	;save original rez (0 from the auto folder)
	cmp.w	#2,original_rez		;MONO so lets get out of here...
	beq	exit
	bsr	set_low_rez		;go into low rez
	bsr	black_out		;make all colours black
	bsr	print_pic		;show first picture
;Music by MAD MAX
	moveq	#1,d0			;initialise the tune
	jsr	tune
	move.l	#tune+8,$4da.w		;set tune running
	bsr	fade_pic		;do subroutine to fade TRUST PD
	bsr	black_out
	lea	main+34,a0		;show main picture
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
sho	move.l	(a0)+,(a1)+
	dbf	d0,sho
	lea	black,a0
	lea	main+2,a1
	bsr	fadein			;fade in black to main pic palette

	bsr	start_isr

wait	bsr	v_sync			;wait for raster to get to top
;	move.w	#$123,$ffff8240.w	;programmers raster timings...
	bsr	scroll			;go subroutine for scroller
	bsr	dots
	bsr.s	clear_spec
	bsr	calc_spec
;	move.w	pic+2,$ffff8240.w
	bsr	tst_key			;has a key been pressed subroutine
	tst.l	d0			;well if there a key
	beq.s	wait			;NO!

	bsr	get_key
	bsr	isr_off
	clr.l	$4da.w			;stop tune
	lea	$ffff8800.w,a0		;turn off sound chip
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	bsr	set_old_palette		;set old palette
	bsr	set_org_rez
exit	move.b	#$8,$fffffc02.w		;enable mouse
	bsr	set_user		;go user mode

	clr.w	-(sp)			;exit to desktop
	trap	#1



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
	add.l	#(160*171),a1
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
.next
	dbf	d0,.cnt_down

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
	add.l	#(170+13)*160,a0

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop
	move.w	(a2)+,d0
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

.nib3	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4	move.w	(a2)+,d0
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








NUM_DOTS=128

dots	lea	path,a0
	moveq	#0,d0
	move.w	offset,d0
	move.l	screen_base,a1
	move.w	last_offset,d2
	and.w	#$fff,d0
	lea	main+34,a5
	move.w	6(a5,d2.w),6(a1,d2.w)	;clear old dot by putting pic back
	move.w	#NUM_DOTS,d7			;number of dots
	move.w	(a0,d0.w),d1
	move.w	d1,last_offset
.loop	and.w	#$fff,d0
	move.w	(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	lea	pixels,a3
	lsl.w	#1,d2
	move.w	(a3,d2.w),d2
	or.w	d2,6(a1,d1.w)
	addq.w	#4,d0
	dbf	d7,.loop
	addq.w	#4,offset

	lea	path2,a0
	moveq	#0,d0
	move.w	offset2,d0
	move.w	last_offset2,d2
	and.w	#$fff,d0
	move.w	2(a5,d2.w),2(a1,d2.w)	;clear old dot by putting pic back
	move.w	#NUM_DOTS,d7			;number of dots
	move.w	(a0,d0.w),d1
	move.w	d1,last_offset2
.loop2	and.w	#$fff,d0
	move.w	(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	lsl.w	#1,d2
	move.w	(a3,d2.w),d2
	or.w	d2,2(a1,d1.w)
	addq.w	#4,d0
	dbf	d7,.loop2
	addq.w	#4,offset2
	rts




WIDTH=5
DEPTH=32
scroll	move.l	screen_base,a1		;screen address
	add.w	#160*100,a1		;go down 100 lines
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#0,d4
	moveq	#40,d5			;40 columns per screen width
	move.w	char_offset,d6
next_char
	move.b	(a5),d7			;get a letter
	sub.b	#32,d7			;rid off ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#(DEPTH*WIDTH)*4,d0	;calc letter position
	add.w	d0,a0
	move.w	d6,d0
	mulu	#(DEPTH*4),d0
	add.w	d0,a0
.column
OFF	set	0			;print 1 column of letter
	REPT	DEPTH
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish			;have we done 40 columns?

	addq.w	#1,a1			;lower byte of word
	tst.w	d4
	beq.s	.skip			;if D4=0 then do next word
	addq.w	#6,a1			;else goto odd word on screen
.skip	not.w	d4
	addq.w	#1,d6			;character offset
	cmp.w	#WIDTH,d6
	blt	.column
	clr.w	d6
	addq.w	#1,a5			;scroll pointer
	tst.b	(a5)			;is end of text?
	bpl	next_char		;NO!
	move.l	scroll_pos,a5		;do reset scrolline
	bra	next_char

.finish
;we have done 40 columns so now check for end of letter...
	addq.w	#1,char_offset
	cmp.w	#WIDTH,char_offset
	blt.s	.end
	clr.w	char_offset
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	move.l	scroll_pos,a4		;reset scroll text pointer
.end	move.l	a4,scroll_pointer
	rts

***********************
* SUBROUTINES SECTION *
***********************
black_out			;make all colours black
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

print_pic
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

v_sync	movem.l	d0-d3/a0-a3,-(sp)	;sync raster to top of screen
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key	move.w	#11,-(sp)		;test for a key press
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)		;read keyboard
	trap	#1
	addq.l	#2,sp
	rts

set_super
	clr.l	-(sp)			;set to supervisor mode so we can
	move.w	#$20,-(sp)		;access system registers
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save		;save old supervisor stack value
	rts

set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

get_old_palette
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette
	lea	pic+2,a0
	bra.s	set_pal
set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_org_rez
	move.w	original_rez,-(sp)
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

fade_pic
	lea	black,a0
	lea	pal1,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal1,a0
	lea	pal2,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal2,a0
	lea	pal3,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal3,a0
	lea	pal4,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal4,a0
	lea	pal5,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal5,a0
	lea	pal6,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal6,a0
	lea	pal7,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	pal7,a0
	lea	black,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi	skip

	lea	black,a0
	lea	white,a1
	bsr	fadein
	bsr	tst_key
	tst.l	d0
	bmi.s	skip

	move.w	#30,d0
.loop	bsr	v_sync
	dbf	d0,.loop

	lea	pic2+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop2	move.l	(a0)+,(a1)+
	dbf	d0,.loop2

	lea	white,a0
	lea	pic2+2,a1
	move.w	#2,fade_speed
	bsr.s	fadein

	move.w	#60,d0
.loop3	bsr	v_sync
	dbf	d0,.loop3

	lea	white,a0
	lea	black,a1
	move.w	#5,fade_speed
	bsr.s	fadein

	moveq	#0,d1
	move.l	screen_base,a0
	move.w	#32000/4-1,d0
.loop4	move.l	d1,(a0)+
	dbf	d0,.loop4

bye	movem.l	main+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
skip	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra.s	bye

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	move.w	#7,d6
	move.l	a1,a2
FADEIN1	lea	$ffff8240.w,a0
	move.w	#16-1,d7
.loop	bsr.s	modify
	addq.w	#2,a0
	addq	#2,a1
	dbf	d7,.loop
	move.w	fade_speed,d0
	bsr.s	WAIT
	MOVE.L A2,A1
	DBRA D6,FADEIN1
	RTS

WAIT:	bsr	v_sync
	dbf	d0,WAIT
	rts


modify	MOVE (A0),D0 ;PALREG
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


start_isr
	move.w	#$2700,sr
; Store original vector slots
	move.l	$120.w,hbc
	move.l	$70.w,v_blank
	move.l	$70.w,old_70
	move.b	$fffffa09.w,a09
	move.b	$fffffa07.w,a07
	move.b	$fffffa13.w,a13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#new_120,$120.w
	move.l	#new_70,$70.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr
	rts


new_120	addq.w	#1,line_count
	cmp.w	#28,line_count
	bge.s	.ex
	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,isr_data
	move.l	(sp)+,a0
.ex	move.b	#0,$fffffa1b.w
	move.b	#1,$fffffa21.w		;1 line of each colour.....
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

new_70	;$70
	move.b	#0,$fffffa1b.w	;timer B
	move.l	#b_line,isr_data
	clr.w	line_count
	move.b	#171,$fffffa21.w
	move.b	#8,$fffffa1b.w
	dc.w	$4ef9
old_70	dc.l	0


isr_off	move.w	#$2700,sr
	move.l	v_blank,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	hbc,$120.w
	move.b	a07,$fffffa07.w
	move.b	a09,$fffffa09.w
	move.b	a13,$fffffa13.w
	move.w	#$2300,sr
	rts

load_text
	lea	filename,a6
	move.w	#2,-(sp)
	pea	filename
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	try_next_text_file
found	clr.w	-(sp)
	move.l	a6,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	no_text_file
	move.l	d0,d7
	pea	text_buffer
	move.l	#300000,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	no_text_file
	move.l	d0,d6
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	#text,scroll_pos
	move.l	#text,scroll_pointer

;sort out CR/LF and any other character less than 32
	lea	text+10,a0
	lea	text_buffer,a1
	move.l	a1,a2
	add.l	d6,a1
	move.b	#$ff,(a1)+
	move.b	#$ff,(a1)+
	move.b	#$ff,(a1)+
	move.b	#$ff,(a1)+
.sort	move.b	(a2)+,d0
	beq.s	.end
	bmi.s	.end
	cmp.b	#31,d0
	ble.s	.sort

	cmp.b	#'A',d0
	blt.s	.skip
	and.b	#$ff-$20,d0
.skip	move.b	d0,(a0)+
	bra.s	.sort
.end
	move.w	#20-1,d0
.fill	move.b	#' ',(a0)+
	dbf	d0,.fill
	move.b	#-1,(a0)+
	move.b	#-1,(a0)+
	move.b	#-1,(a0)+
	move.b	#-1,(a0)
	rts

try_next_text_file
	lea	filename2,a6
	move.w	#2,-(sp)
	move.l	a6,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bpl	found
no_text_file
	rts

	
****************
* DATA SECTION *
****************
	SECTION DATA
hbc		dc.l	0
v_blank		dc.l	0
a09		dc.b	0
a07		dc.b	0
a13		dc.b	0
	even
line_count	dc.w	0	;count of horizontal line down screen for new_120
isr_data	dc.l	b_line
b_line
 dc.w	$020,$030,$040,$050,$060,$070
 dc.w	$170,$270,$370,$470,$570,$670,$770
 dc.w	$770,$760,$750,$740,$730,$720,$710
 dc.w	$601,$502,$403,$304,$205,$106,0

****************
* DATA SECTION *
****************
fade_speed	dc.w	3
stack_save	dc.l	0
screen_base	dc.l	0
original_rez	dc.w	0
old_palette	ds.w	16

black	dcb.w	16,0

pal1	dc.w	$000,$777,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal2	dc.w	$000,$000,$777,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal3	dc.w	$000,$000,$000,$777,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal4	dc.w	$000,$000,$000,$000,$777,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal5	dc.w	$000,$000,$000,$000,$000,$777,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal6	dc.w	$000,$000,$000,$000,$000,$000,$777,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pal7	dc.w	$000,$000,$000,$000,$000,$000,$000,$777
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

white	dc.w	$000,$777,$777,$777,$777,$777,$777,$777
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

pic	incbin	trust1.pi1
pic2	incbin	trust2.pi1
main	incbin	main.pi1
tune	incbin	max15.mus
scroll_pos	dc.l	scroll_text
scroll_pointer		dc.l	init_scroll_text+7
init_scroll_text	dc.b	"                "
scroll_text
;*************************
;default text iF TRUST_PD.TXT file is not found
;*************************


 DC.B "TRUST PD - QUALITY PD FOR THE ATARI ST.       IF YOU WANT MORE DETAILS OF THIS PD LIBRARY "
 DC.B "SEND OFF TO THE ABOVE ADDRESS.         CREDITS.      CODING "
 DC.B "BY MAC SYS DATA OF PERSISTENCE OF VISION,      "
 DC.B "GRAFIX BY MAC SYS DATA,      FONT BY OZYMANDIAS,      TUNE "
 DC.B "BY MAD MAX.        PRESS A KEY TO CONTINUE.         "
 DC.B "                               "


******************************************************
 dc.b "                                         "
	dc.b $ff,$ff
	even

char_offset	dc.w	0
font	dcb.b	WIDTH*DEPTH*4,0
	incbin	lander_1.fnt
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,29,43,00,00,00,00,41,40,41,45,00,26,43,27,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	40,31,32,33,34,35,36,37,38,39,28,00,00,00,00,44,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,23,11,12,13,14,15,16

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	17,18,19,20,21,22,42,24,25,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even


last_offset	dc.w	0
offset	dc.w	0

last_offset2	dc.w	20
offset2		dc.w	0

pixels	dc.w	%1000000000000000
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001

path	incbin	path.dat
path2	incbin	path2.dat

spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0


filename	dc.b	"TRUST_PD.TXT",0
	even
filename2	dc.b	"\auto\TRUST_PD.TXT",0
	even

text	dcb.b	16,32
text_buffer	dc.l	0
