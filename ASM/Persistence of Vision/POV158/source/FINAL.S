*
* POV MENU 158
*
* COMPLETED APRIL 1997 BY MSD

	opt	o+,w-,ow2-,ow3-


KBD_ISR		equ	$118
VBL_ISR		equ	$70
HBL_ISR		equ	$120
MAX_BALLS	equ	26	; If raster more than 1 vbl, decrease this by 1.
scr_now		equ	$24


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
no=NO
yes=YES
DOWNLOAD	equ	no	yes

	ifne	DOWNLOAD
	include	transmit.s
	org	$10000

Code_Start
Exec_Addr
	ENDC
***********************************************************************
	ifeq	DOWNLOAD
	SECTION	TEXT
	endc


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

	ifeq	AUTORUN4
begin	bra	start
	dc.b	"**POV 158 coded by MSD April 1997**"
	even
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
	ifeq	DOWNLOAD
	bsr	super_mode
	endc
	move.w	#$2300,sr
	bsr	check_4_falcon
	move.b	#2,$ffff820a.w
	move.b	#$12,$fffffc02.w
	bsr	get_scr_base
	bsr	low_res
	bsr	black_palette
	bsr	set_up
	bsr	show_pic
	bsr	shift_ball
	bsr	start_tune

	bsr	vsync
	move.w	sr,d0
	or.w	#$700,sr
	move.l	KBD_ISR,kbd_bak
	move.l	VBL_ISR,vbl_bak
	move.l	HBL_ISR,hbl_bak
	move.b	$fffffa09.w,a09_bak
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa13.w,a13_bak
	clr.b	$fffffa1b.w
	move.l	#new_kbd,KBD_ISR
	move.l	#vbl_isr,VBL_ISR
	move.l	#null,HBL_ISR
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#$40,$fffffa09.w
	move.w	d0,sr

.loop
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	bsr	set_screen

	jsr	tune+$8			; Call new tune here.

	eor.w	#(MAX_BALLS*2),ball_off
	bsr	scroller
	bsr	clear_sprites
	bsr	show_sprites
;	move.w	#$022,$ffff8240.w	; Show raster left.

	move.w	key,d0
	bsr	change_hz
	cmp.w	#$c53,d0
	beq	reset
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

isr_off
	move.w	sr,d0
	or.w	#$700,sr
	move.l	kbd_bak,KBD_ISR
	move.l	vbl_bak,VBL_ISR
	move.l	hbl_bak,HBL_ISR
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.b	a13_bak,$fffffa13.w
	move.w	d0,sr

	bsr	stop_tune
	bsr	black_palette
	bsr	low_res
	move.b	#$8,$fffffc02.w
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
.end	bsr	user_mode

	ifeq	AUTORUN4
	bra	exec

	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC



check_4_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***
; Execute in Supervisor mode
	move.l	$5a0,a0
	cmp.l	#0,a0
	beq.s	.nocookiejar
	move.l	$14(a0),d0	;get video shifter type?
	tst.l	d0
	beq.s	.notdma
	cmp.l	#$30000,d0
	beq.s	.yesfalcon
.notdma
.nocookiejar
	rts
.yesfalcon
	clr.w	$ffff8240.w
	move.w	#-1,$ffff825e.w
	pea	nofalcon
	move.w	#9,-(sp)
	trap	#1
.halt	bra.s	.halt
nofalcon	dc.b	27,'E'
	dc.b	27,'Y',32+10,32+10,"SORRY THIS MENU DOES NOT WORK ON AN ATARI FALCON",0
	even
***************
* Subroutines *
***************

scroller
	lea	font,a5
	move.l	scr_now,a1
	lea	160*200+6(a1),a1
	lea	bounce_addr,a3
	eor.w	#2,bounce_xor
	move.w	bounce_xor,d3
	move.l	a1,a0
	add.w	(a3,d3),a0
	moveq	#0,d0
OFF	set	0
	REPT	(20*2)
	move.w	d0,OFF(a0)
	move.w	d0,OFF+(160*30)(a0)
OFF	set	OFF+8
	ENDR
	lea	bounce_table,a2
	move.w	bounce_off,d6
	move.w	(a2,d6),d0
	move.w	d0,(a3,d3)
	add.w	d0,a1
	addq.w	#2,d6
	and.w	#(2*64)-1,d6
	move.w	d6,bounce_off
	move.l	text_ptr,a4
	move.l	a4,a3
	move.w	char_off,d7
	moveq	#0,d2
	moveq	#39,d1
.loop	moveq	#0,d0
	move.b	(a3),d0
	bpl.s	.cont
	lea	text_start,a3
	bra.s	.loop
.cont	move.l	a5,a0
	lsl.w	#7,d0
	add.w	d0,a0
	move.w	d7,d0
	lsl.w	#5,d0
	add.w	d0,a0
OFF	set	0
	REPT	32
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR
	addq.w	#1,d7
	and.w	#3,d7
	bne.s	.ok
	addq.w	#1,a3
	tst.b	(a3)
	bpl.s	.ok
	lea	text_start,a3
.ok	addq.w	#1,a1
	tst.w	d2
	beq.s	.next
	addq.w	#6,a1
.next	not.w	d2
	dbf	d1,.loop
	addq.w	#1,d7
	and.w	#3,d7
	move.w	d7,char_off
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	text_start,a4
.end	move.l	a4,text_ptr
	rts


shift_ball
	lea	ball_data(pc),a0
	lea	16*4*4(a0),a1
	move.w	#(16*15)-1,d0
.loop
	REPT	4
	move.w	(a0),d1
	swap	d1
	move.w	8(a0),d1
	asr.l	#1,d1
	move.w	d1,8(a1)
	swap	d1
	move.w	d1,(a1)
	addq.w	#2,a0
	addq.w	#2,a1
	ENDR
	addq.w	#8,a0
	addq.w	#8,a1
	dbf	d0,.loop
	rts


show_sprites
	move.l	scr_now,a0
	lea	ball_data(pc),a3
	lea	ball_addrs,a5
	add.w	ball_off,a5
	lea	first_path,a4
	move.w	first_ptr,d4
	lea	second_path,a6
	move.w	second_ptr,d6
	moveq	#8,d5
	moveq	#(MAX_BALLS-1),d0
.loop
	move.l	a3,a2
	move.l	a0,a1
	move.l	(a4,d4),d2
	add.l	(a6,d6),d2
	move.w	d2,d1
	swap	d2
	move.w	d1,d3
	lsr.w	#1,d1
	and.w	#$fff8,d1
	add.w	d1,d2
	and.w	#15,d3
	lsl.w	d5,d3
	move.w	d2,(a5)+
	add.w	d2,a1
	add.w	d3,a2
	REPT	16
	move.l	(a1),d1
	move.l	(a2)+,d2
	and.l	d2,d1
	or.l	(a2)+,d1
	move.l	d1,(a1)+
	and.l	d2,(a1)+
	move.l	(a1),d1
	move.l	(a2)+,d2
	and.l	d2,d1
	or.l	(a2)+,d1
	move.l	d1,(a1)+
	and.l	d2,(a1)+
	lea	144(a1),a1
	ENDR
	sub.w	#(4*9),d4
	and.w	#(4*1024)-1,d4
	add.w	#(4*7),d6
	and.w	#(4*1024)-1,d6
	dbf	d0,.loop
	subq.w	#8,first_ptr
	and.w	#(4*1024)-1,first_ptr
	subq.w	#4,second_ptr
	and.w	#(4*1024)-1,second_ptr
	rts

clear_sprites
	move.l	scr_now,a0
	lea	ball_addrs,a1
	add.w	ball_off,a1
	lea	picture+34,a2
	moveq	#0,d2
	moveq	#(MAX_BALLS-1),d0
.loop
	move.l	a0,a3
	move.l	a2,a4
	add.w	(a1),a3
	add.w	(a1)+,a4
OFF	set	0
	REPT	16
	move.l	OFF(a4),OFF(a3)
	move.l	OFF+4(a4),OFF+4(a3)
	move.l	OFF+8(a4),OFF+8(a3)
	move.l	OFF+12(a4),OFF+12(a3)
OFF	set	OFF+160
	ENDR
	dbf	d0,.loop
	rts


show_pic
	move.l	scr_now,a0
	move.l	a0,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,a1
	lea	picture+34,a2
	move.w	#(32000/4)-1,d0
.loop1	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d0,.loop1
	lea	pattern+34,a2
	move.w	#(160*48/4)-1,d0
.loop2	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d0,.loop2
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
.ok	lea	border_pal+18,a0
	moveq	#6,d1
.loop	move.w	(a0),d2
	ror.w	#8,d2
	move.w	d2,(a0)+
	dbf	d1,.loop
	not.w	hz_col
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#(160*248),d1
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
	move.l	old_scr,-(sp)
	move.l	old_scr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
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
	clr.b	$fffffa1b.w
	movem.l	d0-d7,-(sp)
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	clr.w	vsync_flag
	move.l	#border_isr,HBL_ISR
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

border_isr
	or.w	#$700,sr
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(sp)
	moveq	#0,d0
.wait1	cmp.b	#$60,$ffff8209.w
	bne.s	.wait1
	REPT	8
	nop
	ENDR
	lea	.nops(pc),a0
	move.b	$ffff8209.w,d0
	sub.b	#$60,d0
	add.w	d0,a0
	jmp	(a0)
.nops	REPT	38
	nop
	ENDR
	moveq	#18,d0
.wait2	dbf	d0,.wait2
	clr.b	$ffff820a.w
	nop
	movem.l	(sp)+,d0/a0
	move.b	#2,$ffff820a.w
	movem.l	d0-d7,-(sp)
	movem.l	border_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
null	bclr	#0,$fffffa0f.w
	rte


start_tune
	moveq	#0,d0		; Change this for new tune.
	jmp	tune

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


********************
* Initialised data *
********************

	ifeq	DOWNLOAD
	SECTION	DATA
	endc

border_pal
	dcb.w	8,$000
	dc.w	$000, $100, $200, $300
	dc.w	$400, $500, $600, $700

ball_data	incbin	"BALL.DAT"
first_ptr	dc.w	0
second_ptr	dc.w	0
first_path	incbin	"FIRST.PTH"
second_path	incbin	"SECOND.PTH"

font		incbin	"AMIGA.FNT"

bounce_off	dc.w	0
bounce_table	incbin	"BOUNCE.TAB"
bounce_xor	dc.w	0
bounce_addr	dcb.w	2,0
char_off	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
	dc.b	-1
	even

tune
	incbin	music.mus	; Change this to new tune.

	even

picture		incbin	"farting.PI1"
pattern		incbin	"PATTERN.PI1"

demo_keys
	dc.b	0, $02
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
	dc.b	0, $6d
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
	dc.b	-1, -1
filenames
	dc.b	"sc7.prg",0,0,0,0,0,0,0,0,0
	dc.b	"invit.prg",0,0,0,0,0,0,0
	dc.b	"stax4.prg",0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0
	even


**********************
* Uninitialised data *
**********************

	ifeq	DOWNLOAD
	SECTION	BSS
	endc

clock		ds.w	1

key		ds.w	1

ball_off	ds.w	1
ball_addrs	ds.w	(MAX_BALLS*2)

hz_col		ds.w	1

vsync_flag	ds.w	1

save_stk	ds.l	1

kbd_bak		ds.l	1
vbl_bak		ds.l	1
hbl_bak		ds.l	1
a07_bak		ds.b	1
a09_bak		ds.b	1
a13_bak		ds.b	1
	even

old_scr		ds.l	1
scr_xor		ds.l	1

		ds.b	256
screens		ds.b	(160*248*2)
finish	even


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
