*
* POV 99 (BACK MENU)
*

	opt	o+,w-,ow2-,ow3-
	opt	o1-			Turn off bra.s optimisations


KBD_VEC		equ	$118
VERT_ISR	equ	$70
HORIZ_ISR	equ	$120
wrap_1		equ	$300
wrap_2		equ	$302
scr_now		equ	$24


	SECTION	TEXT

start
	lea	clock,a0
.clear	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear
	bsr	super_mode
	move.b	#$12,$fffffc02.w
	move.b	#2,$ffff820a.w
	bsr	low_res
	bsr	black_palette
	bsr	set_up
	bsr	show_title
	bsr	shift_ball1
	bsr	shift_ball2
	bsr	flip_font
	bsr	shift_logo
	bsr	set_palette
;************************************************************************
;*				UNKNOWN					*
;*				-------					*
;* Stolen by: MAC SYS DATA of P.O.V. 25/11/91 20:14                     *
;*      From: AUTOMATION disc 476a                                      *
;* Include files:-                                                      *
;*                 2.IMG into TUNE					*
;************************************************************************
;* music written by Count zero


	bsr	start_tune

	bsr	vsync
	move.w	sr,d0
	or.w	#$700,sr
	move.l	HORIZ_ISR,hbc_bak
	move.l	VERT_ISR,vbl_bak
	move.b	$fffffa09.w,a09_bak
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa17.w,a17_bak
	move.l	#null,HORIZ_ISR
	move.l	#vbl_isr,VERT_ISR
	clr.b	$fffffa07.w
	move.b	#$40,$fffffa09.w
	clr.b	$fffffa13.w
	move.l	KBD_VEC,kbd_bak
	move.l	#new_kbd,KBD_VEC
	move.w	d0,sr

.loop
	bsr	vsync2

	bsr	set_screen
	lea	$200.w,a4		; Change these two
	jsr	tune+$2			; lines for new tune.
	bsr	show_back
	bsr	logos_back
	bsr	show_menu
	bsr	logos_front
	bsr	scroller

	move.w	key,d0
	bsr	change_hz
	cmp.w	#$c53,d0
	beq	reset
	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi	.loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run
	lsr.w	#4,d1
	and.w	#$fff0,d1
	lea	filenames,a0
	lea	$200.w,a1
	add.w	d1,a0
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

isr_off
	move.w	sr,d0
	or.w	#$700,sr
	move.l	kbd_bak,KBD_VEC
	move.l	vbl_bak,VERT_ISR
	move.l	hbc_bak,HORIZ_ISR
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.b	a13_bak,$fffffa13.w
	move.b	a17_bak,$fffffa17.w
	move.w	d0,sr

	bsr	stop_tune
	bsr	black_palette
	bsr	low_res
	tst.w	hz_col
	beq.s	.skip
	clr.b	$ffff820a.w
.skip	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.end
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.skip
.end
	cmp.l	#"BITC",$200.w
	bne.s	.not
	pea	thanks
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	text_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bsr	black_palette
.not	move.b	#$8,$fffffc02.w
	bsr	user_mode
exit
	clr.w	-(sp)		; Exit.
	trap	#1


***************
* Subroutines *
***************

logos_back
	lea	logo_path,a2
	move.w	path_ptr,d2
	lea	logo_bounce,a3
	move.w	bounce_ptr,d3
	lea	logo_data,a4
	move.l	scr_now,a5
	add.w	#(4*100),d2
	and.w	#(4*2048)-1,d2
	addq.w	#2,d3
	cmp.w	#(2*29),d3
	blt.s	.cont
	sub.w	#(2*29),d3
.cont
	moveq	#6-1,d1
.loop
	move.l	a4,a0
	move.l	a5,a1

	add.w	(a2,d2),a1
	add.w	2(a2,d2),a0
	sub.w	(a3,d3),a1

OFF	set	0
	REPT	13
	move.l	(a0)+,d0
	or.l	d0,OFF(a1)
	or.l	d0,OFF+4(a1)
	move.l	(a0)+,d0
	or.l	d0,OFF+8(a1)
	or.l	d0,OFF+12(a1)
OFF	set	OFF+160
	ENDR

	add.w	#(4*200),d2
	and.w	#(4*2048)-1,d2
	addq.w	#4,d3
	cmp.w	#(2*29),d3
	blt.s	.skip
	sub.w	#(2*29),d3
.skip

	dbf	d1,.loop
	rts


logos_front
	lea	logo_path,a2
	move.w	path_ptr,d2
	lea	logo_bounce,a3
	move.w	bounce_ptr,d3
	lea	logo_data,a4
	move.l	scr_now,a5
	moveq	#6-1,d1
.loop
	move.l	a4,a0
	move.l	a5,a1

	add.w	(a2,d2),a1
	add.w	2(a2,d2),a0
	sub.w	(a3,d3),a1

OFF	set	0
	REPT	13
	move.l	(a0)+,d0
	or.l	d0,OFF(a1)
	or.l	d0,OFF+4(a1)
	move.l	(a0)+,d0
	or.l	d0,OFF+8(a1)
	or.l	d0,OFF+12(a1)
OFF	set	OFF+160
	ENDR

	add.w	#(4*200),d2
	and.w	#(4*2048)-1,d2
	addq.w	#4,d3
	cmp.w	#(2*29),d3
	blt.s	.skip
	sub.w	#(2*29),d3
.skip

	dbf	d1,.loop

	addq.w	#4,path_ptr
	and.w	#(4*2048)-1,path_ptr
	addq.w	#2,bounce_ptr
	cmp.w	#(2*29),bounce_ptr
	blt.s	.no_wrap
	clr.w	bounce_ptr
.no_wrap
	rts


shift_logo
	lea	logo_data,a0
	lea	(13*4*2)(a0),a1
	move.w	#(13*15)-1,d0
.loop
	move.w	4(a0),d1
	swap	d1
	move.w	(a0)+,d1
	ror.l	#1,d1
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	swap	d1
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	addq.w	#6,a0
	dbf	d0,.loop
	rts


show_menu
	lea	menu_data,a0
	move.l	scr_now,a1
	lea	menu_path,a2
	add.w	menu_ptr,a2
	add.w	(a2),a1
OFF	set	0
	REPT	64
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,OFF(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,OFF+(4*8)(a1)
OFF	set	OFF+160
	ENDR
	addq.w	#2,menu_ptr
	and.w	#(2*128)-1,menu_ptr
	rts


flip_font
	lea	font,a0
	lea	(48*16*2)(a0),a1
	move.w	#(48*16)-1,d0
.loop
	move.w	(a0)+,d1
	moveq	#16-1,d2
.flip
	lsl.w	#1,d1
	roxr.w	#1,d3
	dbf	d2,.flip
	move.w	d3,(a1)+
	dbf	d0,.loop
	rts


FontLine	MACRO
	move.w	(a0)+,(a2)
	move.w	(48*16*2)-2(a0),(8*19)(a2)
	lea	160(a2),a2
	ENDM

FontChar	MACRO
	FontLine	; 1
	FontLine	; 2
	FontLine	; 3
	FontLine	; 4
	FontLine	; 5
	FontLine	; 6
	FontLine	; 7
	FontLine	; 8
	FontLine	; 9
	FontLine	; 10
	FontLine	; 11
	FontLine	; 12
	FontLine	; 13
	FontLine	; 14
	FontLine	; 15
	FontLine	; 16
	ENDM


scroller
	move.l	scr_now,a2
	lea	(160*8)+6(a2),a2
	move.l	text_ptr,a3
	lea	font,a4
	move.l	a4,a0
	moveq	#0,d0
	move.b	(a3)+,d0
	lsl.w	#5,d0
	add.w	d0,a0
	move.w	char_off,d7
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,a0
	mulu	#12,d7			; FontLine code len = 12 bytes.
	move.w	d7,d6
	jmp	.start_rep(pc,d7)

.start_rep
	REPT	12
	FontChar
	moveq	#0,d0
	move.b	(a3)+,d0
	lsl.w	#5,d0
	move.l	a4,a0
	add.w	d0,a0
	ENDR

	neg.w	d6
	lea	.last_char(pc),a1
	jmp	(a1,d6)
	FontChar
.last_char
	
	move.l	text_ptr,a3
	addq.w	#2,char_off
	and.w	#15,char_off
	bne.s	.end
	addq.w	#1,a3
	cmp.l	#end_text-20,a3
	blt.s	.end
	lea	text_start,a3
.end
	move.l	a3,text_ptr
	rts


old_scroller
	move.l	scr_now,a2
	lea	(160*8)+6(a2),a2
	move.l	text_ptr,a3
	move.w	char_off,d7
	moveq	#0,d2
	move.w	#191,d1
.loop
	moveq	#0,d0
	move.b	(a3),d0
	bpl.s	.cont
	lea	text_start,a3
	bra.s	.loop
.cont
	lea	font,a0
	lsl.w	#5,d0
	add.w	d0,a0
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,a0
.column
	move.w	(a0)+,(a2)
	move.w	(48*16*2)-2(a0),(8*19)(a2)
	dbf	d1,.not_end
	move.l	text_ptr,a3
	move.w	char_off,d7
	addq.w	#2,d7
	and.w	#15,d7
	move.w	d7,char_off
	bne.s	.end
	addq.w	#1,a3
	tst.b	(a3)
	bpl.s	.end
	lea	text_start,a3
.end
	move.l	a3,text_ptr
	rts
.not_end
	lea	160(a2),a2
	addq.w	#1,d7
	and.w	#15,d7
	bne	.column
	addq.w	#1,a3
	tst.b	(a3)
	bpl	.loop
	lea	text_start,a3
	bra	.loop


; LoadRegs mask,dataA,dataB

LoadRegs	MACRO
	move.l	(a0)+,\2
	move.l	(a0)+,\3
	move.l	(a1)+,\1
	and.l	\1,\2
	and.l	\1,\3
	or.l	(a1)+,\2
	or.l	(a1)+,\3
	ENDM

WriteLine	MACRO
	movem.l	d2-d7,(\1)(a2)
	movem.l	d0-d7,(\1)+(4*6)(a2)
	movem.l	d0-d7,(\1)+(4*14)(a2)
	movem.l	d0-d7,(\1)+(4*22)(a2)
	movem.l	d0-d5,(\1)+(4*30)(a2)
	ENDM

WrapVert	MACRO
	addq.w	#1,wrap_1
	and.w	#31,wrap_1
	bne.s	*+6
	lea	-(32*8*4)(a0),a0
	addq.w	#1,wrap_2
	and.w	#63,wrap_2
	bne.s	*+6
	lea	-(64*12*4)(a1),a1
	ENDM


show_back
	lea	ball1_path,a0
	add.w	ball1_ptr,a0
	move.w	(a0)+,ball1_xoff
	move.w	(a0)+,ball1_yoff
	addq.w	#4,ball1_ptr
	and.w	#(4*1024)-1,ball1_ptr

	lea	ball2_path,a0
	add.w	ball2_ptr,a0
	move.w	(a0)+,ball2_xoff
	move.w	(a0)+,ball2_yoff
	addq.w	#4,ball2_ptr
	and.w	#(4*1024)-1,ball2_ptr

	lea	ball1_data,a0
	lea	ball2_data,a1
	move.l	scr_now,a2
	lea	(160*8)+8(a2),a2

	move.w	ball1_xoff,d0
	mulu	#(32*8*4),d0
	add.l	d0,a0

	move.w	ball2_xoff,d0
	mulu	#(64*12*4),d0
	add.l	d0,a1

	move.w	ball1_yoff,d0
	move.w	d0,wrap_1
	mulu	#(8*4),d0
	add.w	d0,a0

	move.w	ball2_yoff,d0
	move.w	d0,wrap_2
	mulu	#(12*4),d0
	add.w	d0,a1

	REPT	64

	LoadRegs	d7,d0,d1
	move.l	d0,a3
	LoadRegs	d0,d2,d3
	LoadRegs	d0,d4,d5
	LoadRegs	d0,d6,d7
	move.l	a3,d0

	WriteLine	0
	WriteLine	(160*64)
	WriteLine	(160*64*2)
	WrapVert
	lea	160(a2),a2
	ENDR
	rts


shift_ball1
	lea	ball_gfx,a0
	lea	ball1_data,a1
	move.w	#(32*8*4/4)-1,d0
.copy
	move.l	(a0)+,(a1)+
	dbf	d0,.copy

	lea	ball1_data,a0
	lea	(32*8*4)(a0),a1
	move.w	#(32*31)-1,d0
.loop
	moveq	#4-1,d1
.plane
	move.w	(8*3)(a0),d4
	moveq	#4-1,d2
.column
	move.w	d4,d3
	swap	d3
	move.w	(a0),d3
	move.w	d3,d4
	ror.l	#1,d3
	move.w	d3,(a1)
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d2,.column
	lea	2-(8*4)(a0),a0
	lea	2-(8*4)(a1),a1
	dbf	d1,.plane
	lea	(8*3)(a0),a0
	lea	(8*3)(a1),a1
	dbf	d0,.loop
	rts


shift_ball2
	lea	ball_gfx+(32*8*4),a0
	lea	ball2_data,a1
	move.w	#(64*8*4/8)-1,d0
.copy
	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.copy

	lea	ball2_data,a0
	move.w	#(64*63)-1,d0
.loop
	moveq	#6-1,d1
.plane
	move.w	(12*3)(a0),d4
	moveq	#4-1,d2
.column
	move.w	d4,d3
	swap	d3
	move.w	(a0),d3
	move.w	d3,d4
	ror.l	#2,d3
	move.w	d3,(a1)
	lea	12(a0),a0
	lea	12(a1),a1
	dbf	d2,.column
	lea	2-(12*4)(a0),a0
	lea	2-(12*4)(a1),a1
	dbf	d1,.plane
	lea	(12*3)(a0),a0
	lea	(12*3)(a1),a1
	dbf	d0,.loop
	rts


show_title
	move.l	scr_now,a0
	move.l	a0,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,a1
	lea	title_data,a2
	move.w	#(160*5/4)-1,d0
.loop
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d0,.loop
	rts


reset
	move.l	$4.w,-(sp)
	rts


change_hz
	tst.w	clock
	bne.s	.end
	cmp.b	#$0b,d0
	beq.s	.ok
	cmp.b	#$70,d0
	beq.s	.ok
	rts
.ok	eor.w	#$112,hz_col
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


vsync2
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	rts


set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#(160*200),d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts


super_mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts


low_res
	bsr	vsync
	clr.w	-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


set_palette
	movem.l	new_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
	rts


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


new_kbd
	movem.l	d0,-(sp)
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


vbl_isr
	clr.w	vsync_flag
	move.w	hz_col,$ffff8240.w
null	rte


********************************
* More than one tune...
*
* 1=tune 1
* 2=tune 2
* 3=tune 3

start_tune
	moveq	#3,d0			; Change these two
	jmp	tune			; lines for new tune.

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


********************
* Initialised data *
********************

	SECTION	DATA

new_pal
	dc.w	$000, $100, $211, $322
	dc.w	$433, $544, $655, $001
	dc.w	$777, $012, $123, $234
	dc.w	$345, $456, $567, $766

tune
	incbin	"ZERO.MUS"		; Change this for new tune.
	even

ball_gfx	incbin	"BALLS.DAT"

ball1_xoff	dc.w	0
ball1_yoff	dc.w	0
ball2_xoff	dc.w	0
ball2_yoff	dc.w	0

ball1_ptr	dc.w	0
ball1_path	incbin	"FIRST.PTH"
ball2_ptr	dc.w	0
ball2_path	incbin	"SECOND.PTH"

title_data	incbin	"TITLE.DAT"

menu_data	incbin	"MENU.DAT"
menu_ptr	dc.w	0
menu_path	incbin	"MENU.PTH"

logo_data
	incbin	"LOGO.DAT"
	ds.b	(13*4*2*15)
path_ptr	dc.w	0
logo_path	incbin	"LOGOMAIN.PTH"
bounce_ptr	dc.w	0
logo_bounce	incbin	"LOGO_BNC.PTH"

font
	incbin	"SMALL.FNT"
	ds.b	(48*16*2)

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
end_text
	even

demo_keys
	dc.b	0, $02
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
	dc.b	4, $06
	dc.b	0, $6d
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
	dc.b	4, $6b
	dc.b	-1, -1
filenames
	dc.b	"BITCH.LAW",0,0,0,0,0,0,0
	dc.b	"TROLL.NY",0,0,0,0,0,0,0,0
	dc.b	"CHEAT.LIE",0,0,0,0,0,0,0
	dc.b	"KGB.3",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0
	even


thanks	dc.b	27,'E'
	dc.b	27,'Y',32+8,32+10,"LIFE'S A BITCH DEMO"
	dc.b	27,'Y',32+10,32+11,"Hacked by THE LAW"
	dc.b	27,'Y',32+12,32+1,"Thanks THE LAW, I hope you don't mind"
	dc.b	27,'Y',32+14,32+14,"us using it."
	dc.b	0
	even
text_pal
	dc.w	$000,$777,$666,$555,$444,$333,$222,$111
	dc.w	$070,$060,$050,$040,$030,$020,$010,$777

**********************
* Uninitialised data *
**********************

	SECTION	BSS

clock		ds.w	1

key		ds.w	1

hz_col		ds.w	1

vsync_flag	ds.w	1

save_stk	ds.l	1

kbd_bak		ds.l	1
vbl_bak		ds.l	1
hbc_bak		ds.l	1
a09_bak		ds.b	1
a07_bak		ds.b	1
a13_bak		ds.b	1
a17_bak		ds.b	1

scr_xor		ds.l	1

ball1_data	ds.b	(32*8*4*32)
ball2_data	ds.b	(64*12*4*64)

		ds.b	256
screens		ds.b	(160*200*2)
finish	even
