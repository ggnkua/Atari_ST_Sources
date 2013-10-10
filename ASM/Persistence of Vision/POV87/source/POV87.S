*************************
*** Spectrum 512 Menu ***
*************************
***    P.O.V. 87      ***
*************************
	opt	o+,w-,ow2-,ow3-


KBD_ISR		equ	$118
VBL_ISR		equ	$70
scr_now		equ	$24


	SECTION	TEXT

start
	lea	clock,a0
.clear	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear
	bsr	super_mode
	move.b	$484.w,old484
	clr.b	$484.w
	move.b	#2,$ffff820a.w
	bsr	get_scr_base
	bsr	set_up
	bsr	black_palette
	bsr	low_res
	bsr	show_pic

	moveq	#1,d0
	bsr	tune

	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	VBL_ISR,vbl_bak
	move.l	#main_loop,VBL_ISR
	move.w	(sp)+,sr

.loop
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	move.w	#-1,-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq.w	#4,sp
	lsl.w	#8,d0
	move.b	$fffffc02.w,d0
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

	add.w	d1,d1
	lea	filenames,a0	;move filename and path
	lea	$200.w,a1
	add.w	d1,a0
	REPT	8
	move.l	(a0)+,(a1)+
	ENDR

	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	vbl_bak,VBL_ISR
	move.w	(sp)+,sr

	bsr	black_palette

	moveq	#0,d0
	jsr	tune

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
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
	move.b	old484,$484.w
	bsr	user_mode

	clr.w	-(sp)
	trap	#1


*** Routines ***

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
	lsr.w	#4,d2
	eor.w	d2,d1
	move.w	d1,(a0)+
	dbf	d3,.loop
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


vu_meters
	move.l	scr_now,a0
	add.l	#(160*218)+6,a0
	lea	$ffff8800.w,a3
	moveq	#$7e,d3
	move.b	#10,(a3)
	move.b	(a3),d0
	bsr	show_vu
	move.b	#9,(a3)
	move.b	(a3),d0
	bsr	show_vu
	move.b	#8,(a3)
	move.b	(a3),d0
	bsr	show_vu
	rts

show_vu
	ext.w	d0
	move.l	a0,a1
	lea	153(a0),a2
	moveq	#15,d1
	sub.w	d0,d1
.on
OFF	set	0
	REPT	4
	move.b	d3,OFF(a1)
	move.b	d3,OFF(a2)
OFF	set	OFF+160
	ENDR
	subq.w	#1,a2
	addq.w	#1,a1
	move.w	a2,d2
	btst	#0,d2
	beq.s	.cont
	subq.w	#6,a2
	addq.w	#6,a1
.cont	dbf	d0,.on
.off
OFF	set	0
	REPT	4
	clr.b	OFF(a1)
	clr.b	OFF(a2)
OFF	set	OFF+160
	ENDR
	subq.w	#1,a2
	addq.w	#1,a1
	move.w	a2,d2
	btst	#0,d2
	beq.s	.skip
	subq.w	#6,a2
	addq.w	#6,a1
.skip	dbf	d1,.off
	add.w	#(160*5),a0
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
	moveq	#0,d1
	move.w	-(a0),d1
	lsl.l	d2,d1
	or.w	d0,d1
	move.w	d1,(a0)
	swap	d1
	move.w	d1,d0
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
;	move.l	a4,a0
;	move.l	a4,a1
;	move.l	a4,a2
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
	REPT	16
	nop
	ENDR
	clr.b	$ffff820a.w
	REPT	5
	nop
	ENDR
	move.b	#2,$ffff820a.w
	movem.l	bot_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	MOVE.W	(A7)+,SR
	RTS


main_loop
	movem.l	d0-a6,-(sp)
	clr.w	vsync_flag
	bsr	scroller
	bsr	spec_cols
	bsr	vu_meters
	bsr	tune+8
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

tune
	incbin	max14.mus
	even

font		incbin	"SLANT.FNT"

char_cnt	dc.w	0
char_offset	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
	dc.b	-1
	even

pattern		incbin	"PATTERN.PI1"

picture		incbin	"PIC.SPU"

bot_pal
	dcb.w	8,$000
	dc.w	$000, $010, $020, $030
	dc.w	$040, $050, $060, $070

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
	dc.b	"DIRE.512",0,0,0,0,0,0,0,0	;filename
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;path

	dc.b	"PACK.PRG",0,0,0,0,0,0,0,0
	dc.b	"\MBEAT.ONE",0,0,0,0,0,0

	dc.b	"PACK.PRG",0,0,0,0,0,0,0,0
	dc.b	"\MBEAT.TWO",0,0,0,0,0,0

	dc.b	"COPIER.POV",0,0,0,0,0,0
	dc.b	0
	even


*** Uninitialised data ***

	SECTION	BSS

old484		ds.w	1

clock		ds.w	1

vsync_flag	ds.w	1

vbl_bak		ds.l	1

old_scr		ds.l	1

save_stk	ds.l	1

buffer		ds.b	(16*42)

		ds.b	256
screen		ds.b	32000
		ds.b	(48*160)
finish	even
