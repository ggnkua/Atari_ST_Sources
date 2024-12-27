********** POV 137 **********
***********************************
*** Spectrum 512 Menu Version 2 ***
***********************************

	opt	o+,w-,ow2-,ow3-


YES=1
yes=YES
NO=0
no=NO


KBD_ISR		equ	$118
VBL_ISR		equ	$70
scr_now		equ	$24

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

	SECTION	TEXT


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC


	lea	clock,a0
.clear	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear
	lea	spec_values,a0
.clear2	clr.w	(a0)+
	cmp.l	#old_pal,a0
	blt.s	.clear2
	bsr	super_mode
	clr.b	$484.w
	move.b	#2,$ffff820a.w
	bsr	get_scr_base
	move.b	#$12,$fffffc02.w
	bsr	set_up
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	bsr	black_palette
	bsr	low_res
	bsr	show_pic

	move.l	#1,D0
	jsr	tune

	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	VBL_ISR,vbl_bak
	move.l	KBD_ISR,kbd_bak
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa09.w,a09_bak
	move.l	#main_loop,VBL_ISR
	move.l	#new_kbd,KBD_ISR
	clr.b	$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.w	(sp)+,sr

.loop
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait

	move.w	key,d0
	bsr	change_hz
	cmp.w	#$c53,d0
	beq	reset

	cmp.b	#1,d0		;ESCape to Assembler.......
	beq	exit

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	.loop
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

	move.w	#50,d7
wait	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	dbf	d7,wait

	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	vbl_bak,VBL_ISR
	move.l	kbd_bak,KBD_ISR
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.w	(sp)+,sr

	bsr	black_palette
get_out	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#8,$fffffc02.w
	bsr	vsync
	lea	$ffff8201.w,a0
	move.l	$44e.w,d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	move.w	bot_pal+18,d0
	and.w	#7,d0
	beq.s	.skip
	clr.b	$ffff820a.w
.skip
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.end
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.skip
.end
	move.b	#2,$484.w
	bsr	user_mode

		ifeq	AUTORUN4
		bra	exec

		ELSE
		clr.w	-(sp)
		trap	#1
		ENDC


exit	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	vbl_bak,VBL_ISR
	move.l	kbd_bak,KBD_ISR
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.w	(sp)+,sr
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#8,$fffffc02.w
	bsr	vsync
	lea	$ffff8201.w,a0
	move.l	$44e.w,d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	move.w	bot_pal+18,d0
	and.w	#7,d0
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
	move.b	#2,$484.w
	bsr	user_mode

		clr.w	-(sp)
		trap	#1


****************
*** Routines ***
****************

******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	40
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

show_spec
	lea	spec_buf,a0
	move.l	scr_now,a1
	add.l	#(160*218)+6,a1
	moveq	#0,d0
	REPT	(20*16)
	move.w	(a0),(a1)
	move.w	d0,(a0)+
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
	moveq	#15,d2

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
	or.w	d1,(a2,d0)

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
	or.w	d1,(a2,d0)

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
	or.w	d1,(a2,d0)

******************** print speccy *******************
ps
	lea	spec_buf+(40*7),a0
	lea	40(a0),a3

	lea	spec_values,a2
	moveq	#$7e,d2
	moveq	#(MAX_BARS/2)-1,d1
.loop
	move.w	(a2)+,d0
	beq.s	.byte2
	lsr.b	#1,d0
	move.l	a0,a1
	move.l	a3,a4
.loop1
	move.b	d2,(a1)
	move.b	d2,(a4)
	lea	-40(a1),a1
	lea	40(a4),a4
	dbf	d0,.loop1
.byte2
	move.w	(a2)+,d0
	beq.s	.next
	lsr.b	#1,d0
	lea	1(a0),a1
	lea	1(a3),a4
.loop2
	move.b	d2,(a1)
	move.b	d2,(a4)
	lea	-40(a1),a1
	lea	40(a4),a4
	dbf	d0,.loop2
.next
	addq.w	#2,a0
	addq.w	#2,a3
	dbf	d1,.loop
	rts

**************************************************


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
.ok	lea	bot_pal+18,a0
	moveq	#6,d3
.loop	move.w	(a0),d1
	move.w	d1,d2
	lsr.w	#8,d2
	and.w	#$f,d2
	eor.w	d2,d1
	move.w	d1,(a0)+
	dbf	d3,.loop
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


set_up
	move.l	#screen,d7
	clr.b	d7
	move.l	d7,scr_now
	bsr	vsync
	lea	$ffff8201.w,a0
	lsr.l	#8,d7
	movep.w	d7,(a0)

	lea	pattern+34,a0
	move.l	scr_now,a1
	add.w	#(160*200),a1
	move.w	#(160*48/4)-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts


scroller
	move.l	text_ptr,a2
	moveq	#4,d2
	moveq	#0,d0
	lea	buffer+(16*42),a0
	REPT	(16*21)
	move.w	d0,d1
	swap	d1
	move.w	-(a0),d1
	move.w	d1,d0
	rol.l	d2,d1
	move.w	d1,(a0)
	ENDR
	lea	buffer,a0
	move.w	#$fff0,d0
OFF	set	40
	REPT	16
	and.w	d0,OFF(a0)
OFF	set	OFF+42
	ENDR
	move.w	char_cnt,d0
	addq.w	#4,d0
	move.w	d0,char_cnt
	cmp.w	#20,d0
	blt	.cont
	clr.w	char_cnt
	moveq	#0,d0
	move.b	(a2)+,d0
	lea	font,a3
	lsl.w	#5,d0
	add.w	d0,a3
	lea	buffer+40,a0
OFF	set	0
	REPT	16
	move.w	(a3)+,OFF(a0)
OFF	set	OFF+42
	ENDR
.cont	lea	buffer,a0
	move.l	scr_now,a1
	add.l	#(160*201),a1
	moveq	#15,d0
.show
OFF	set	6
	REPT	20
	move.w	(a0)+,OFF(a1)
OFF	set	OFF+8
	ENDR
	addq.w	#2,a0
	add.w	#160,a1
	dbf	d0,.show
	tst.b	(a2)
	bpl	.ok
	lea	text_start,a2
.ok	move.l	a2,text_ptr
	rts


spec_cols
	move.w	sr,-(sp)
	or.w	#$700,sr
	lea	$ffff8240.w,a4
	lea	$ffff8209.w,a5
	lea	nops,a6
	lea	picture+32000,a3
	move.w	#198,d7
	moveq	#0,d0
.wait	tst.b	(a5)
	beq.s	.wait
	move.b	(a5),d0
	add.l	d0,a6
	jmp	(a6)
nops
	REPT	80
	nop
	ENDR
.again
	nop
	nop
	move.l	a4,a0
	move.l	a4,a1
	move.l	a4,a2
	REPT	8
	move.l	(a3)+,(a0)+
	ENDR
	REPT	8
	move.l	(a3)+,(a1)+
	ENDR
	REPT	8
	move.l	(a3)+,(a2)+
	ENDR
	dbf	d7,.again
	REPT	16		;lower border frig
	nop
	ENDR
	clr.b	$ffff820a.w
	REPT	4
	nop
	ENDR
	move.b	#2,$ffff820a.w
	movem.l	bot_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	(sp)+,sr
	rts


main_loop
	movem.l	d0-a6,-(sp)
	clr.w	vsync_flag
	bsr	scroller
	bsr	show_spec
	bsr	spec_cols
	lea	$200.w,a4		; Change these two lines
	bsr	tune+4			; for the new tune.
	bsr	calc_spec
;	move.w	#$700,$ffff8240.w	; This shows raster left.
	movem.l	(sp)+,d0-a6
	rte


show_pic
	lea	picture,a0
	move.l	scr_now,a1
	move.w	#(32000/4)-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
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


get_scr_base
	move.w	#3,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,old_scr
	rts


black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
	rts


low_res
	bsr	vsync
	clr.b	$ffff8260.w
	rts

vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


*** Initialised data ***

	SECTION	DATA

tune	incbin	"misfit1.mus"		; Change this for new tune.
	even

font		incbin	"ROUNDED.FNT"

char_cnt	dc.w	0
char_offset	dc.w	0
text_ptr	dc.l	text_start
text_start	incbin	"SCROLLER.TXT"
		dc.b	-1
	even

pattern		incbin	"PATTERN.PI1"

picture		incbin	"halo512.SPU"

bot_pal
	dcb.w	8,$000
	dc.w	$000, $100, $210, $320
	dc.w	$430, $540, $650, $760

spec_data	incbin	"SPECTRUM.DAT"

demo_keys
	dc.b	0, $02
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
;	dc.b	4, $06
	dc.b	0, $6d
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
;	dc.b	4, $6b
	dc.b	-1, -1
filenames
	dc.b	"gremlin.meg",0,0,0,0,0
	dc.b	"mca2",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"m_c_c_2",0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0
	even


*** Uninitialised data ***

	SECTION	BSS

clock		ds.w	1

key		ds.w	1

vsync_flag	ds.w	1

vbl_bak		ds.l	1
kbd_bak		ds.l	1
a07_bak		ds.b	1
a09_bak		ds.b	1
	even


spec_values	ds.w	MAX_BARS

old_pal		ds.w	16

old_scr		ds.l	1

save_stk	ds.l	1

buffer		ds.b	(16*42)

spec_buf	ds.b	(40*16)

		ds.b	256
screen		ds.b	32000
		ds.b	(48*160)
finish	even
bss_end
