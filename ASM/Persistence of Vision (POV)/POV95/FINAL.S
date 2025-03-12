*
* POV Lower Side Border MENU
*

	opt	o+,w-,ow2-,ow3-


KBD_ISR		equ	$118
VBL_ISR		equ	$70
HBL_ISR		equ	$120
scr_now		equ	$24


MulNops	MACRO
	REPT	\1
	nop
	ENDR
	ENDM


	SECTION	TEXT
	bra	start
	dc.b	"    Persistence Of Vision      "
	dc.b	"P.O. BOX 40,        "
	dc.b	"THORNTON-CLEVELEYS, "
	dc.b	"BLACKPOOL,          "
	dc.b	"FY5 3PH.            "
	even
start

	lea	clock,a0
.clear	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear
	bsr	super_mode
	move.b	#2,$ffff820a.w
	move.b	#$12,$fffffc02.w
	move.b	$484.w,conterm
	clr.b	$484.w
	bsr	low_res
	bsr	black_palette
	bsr	set_up
	bsr	expand_spec
	bsr	start_tune
	bsr	draw_pic

	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	KBD_ISR,kbd_bak
	move.l	VBL_ISR,vbl_bak
	move.l	HBL_ISR,hbl_bak
	move.l	#new_kbd,KBD_ISR
	move.l	#new_vbl,VBL_ISR
	move.l	#null,HBL_ISR
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa09.w,a09_bak
	move.b	$fffffa13.w,a13_bak
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.b	#1,$fffffa13.w
	move.w	(sp)+,sr

.loop
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait

	movem.l	d6/a6,-(sp)
	jsr	tune+$8
	movem.l	(sp)+,d6/a6
	bsr	set_rasters
	bsr	scroller
	bsr	spec

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
	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	kbd_bak,KBD_ISR
	move.l	vbl_bak,VBL_ISR
	move.l	hbl_bak,HBL_ISR
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.b	a13_bak,$fffffa13.w
	clr.b	$fffffa1b.w
	move.w	(sp)+,sr

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
	move.b	conterm,$484.w
	move.b	#$08,$fffffc02.w
	bsr	user_mode
exit
	clr.w	-(sp)
	trap	#1


************
* Routines *
************

draw_pic
	bsr	vsync
	lea	picture+2,a0
	lea	$ffff8240.w,a1
	REPT	8
	move.l	(a0)+,(a1)+
	ENDR
	lea	picture+34+256,a3
	move.l	scr_now,a4
	add.w	#256,a4
	move.w	#519,d4
	move.l	#$01000100,d5
	lea	picture+34,a5
	move.l	scr_now,a6
	moveq	#0,d6
	move.l	#$80008000,d7
.loop
	bsr	vsync
	movem.l	d4-d7/a3-a6,-(sp)
	jsr	tune+$8
	movem.l	(sp),d4-d7/a3-a6
	move.w	#199,d3
.line
	tst.w	d6
	bmi.s	.noleft
	move.l	(a5),d0
	and.l	d7,d0
	or.l	d0,(a6)
	move.l	4(a5),d0
	and.l	d7,d0
	or.l	d0,4(a6)
.noleft
	lea	160(a5),a5
	lea	160(a6),a6
	subq.w	#1,d6
	rol.l	#1,d7
	bcc.s	.skip1
	subq.w	#8,a5
	subq.w	#8,a6
.skip1
	cmp.w	#320,d4
	bge.s	.noright
	move.l	(a3),d0
	and.l	d5,d0
	or.l	d0,(a4)
	move.l	4(a3),d0
	and.l	d5,d0
	or.l	d0,4(a4)
.noright
	lea	160(a3),a3
	lea	160(a4),a4
	subq.w	#1,d4
	rol.l	#1,d5
	bcc.s	.skip2
	subq.w	#8,a3
	subq.w	#8,a4
.skip2
	dbf	d3,.line
	movem.l	(sp)+,d4-d7/a3-a6
	addq.w	#1,d6
	cmp.w	#260,d6
	bge.s	.end
	ror.l	#1,d7
	bcc.s	.skip3
	addq.w	#8,a5
	addq.w	#8,a6
.skip3
	subq.w	#1,d4
	rol.l	#1,d5
	bcc.s	.skip4
	subq.w	#8,a3
	subq.w	#8,a4
.skip4
	bra	.loop
.end
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
.ok	eor.w	#(29*2),hz_col
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts


set_rasters
	lea	colour_bar,a0
	add.w	hz_col,a0
	lea	rast_colours,a1
	lea	raster_path,a2
	move.w	path_ptr,d2
	moveq	#4,d0
.loop
	move.l	a0,a4
	move.l	a1,a3
	add.w	(a2,d2),a3
	REPT	14
	move.l	(a4)+,(a3)+
	ENDR
	move.w	(a4)+,(a3)+
	add.w	#(2*18),d2
	and.w	#(2*256)-1,d2
	dbf	d0,.loop
	addq.w	#2,path_ptr
	and.w	#(2*256)-1,path_ptr
	rts


expand_spec
	lea	spec_data,a0
.init	move.w	(a0)+,d0
	bmi.s	.init
.again
	cmp.l	#spec_values,a0
	bge.s	.end
.loop
	tst.w	(a0)
	bpl.s	.next
	move.w	d0,(a0)+
	bra.s	.loop
.next
	move.w	(a0)+,d0
	bra.s	.again
.end	rts


MAX_BARS	equ	54
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.b	(a0)+
	beq.s	.next
	subq.b	#1,-1(a0)
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

	lsl.w	#1,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	or.b	d1,(a2,d0)

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
	or.b	d1,(a2,d0)

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
	or.b	d1,(a2,d0)

******************** print speccy *******************
ps
	move.l	scr_now,a0
	lea	((160*200)-2)(a0),a3
	moveq	#0,d0
	REPT	28
	move.w	d0,(a3)
	move.w	d0,(31*230)(a3)
	addq.w	#8,a3
	ENDR
	add.l	#(160*200)+(31*230)-2,a0

	lea	spec_values,a2
	moveq	#(MAX_BARS/2)-1,d1
.loop
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	moveq	#$7e,d2
.loop1
	move.b	d2,(a1)
	move.b	d2,-230(a1)
	lea	-460(a1),a1
	dbf	d0,.loop1

.nib2
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.next
	lea	1(a0),a1
	moveq	#$7e,d2
.loop2
	move.b	d2,(a1)
	move.b	d2,-230(a1)
	lea	-460(a1),a1
	dbf	d0,.loop2

.next
	addq.w	#8,a0
	dbf	d1,.loop
	rts

**************************************************


scroller
	move.l	scr_now,a2
	lea	((160*200)+(230-6))(a2),a2
	move.l	text_ptr,a4
	move.w	char_off,d7
	moveq	#0,d2
	moveq	#51,d1
.loop	moveq	#0,d0
	move.b	(a4),d0
	bpl.s	.cont
	lea	text_start,a4
	bra.s	.loop
.cont	lea	font,a0
	mulu	#(30*4*4),d0
	add.w	d0,a0
	move.w	d7,d0
	mulu	#(30*4),d0
	add.w	d0,a0
OFF	set	6
	REPT	30
	move.l	(a0)+,d0
	movep.l	d0,OFF(a2)
OFF	set	OFF+230
	ENDR
	addq.w	#1,d7
	and.w	#3,d7
	bne.s	.ok
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.ok
	lea	text_start,a4
.ok	addq.w	#1,a2
	move.w	a2,d0
	and.w	#1,d0
	bne.s	.next
	addq.w	#6,a2
.next	dbf	d1,.loop
	move.l	text_ptr,a4
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


set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	lea	$ffff8201.w,a0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	rts


new_vbl
	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.l	#raster,HBL_ISR
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(sp)
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	lea	rast_colours,a6
	move.w	#198,d6
	rte

raster
	clr.b	$fffffa1b.w
	move.w	(a6)+,$ffff8240.w
	subq.w	#1,d6
	bne.s	.skip
	move.l	#lower_border,HBL_ISR
.skip	move.b	#8,$fffffa1b.w
null	bclr.b	#0,$fffffa0f.w
	rte


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


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
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


black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
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


start_tune
	moveq	#1,d0
	jmp	tune

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


lower_border
	move.w	#$2700,sr
	MOVE.L	#$00000005,$ffff8240.w
	MOVE.L	#$02160325,$ffff8244.w
	MOVE.L	#$04350534,$ffff8248.w
	MOVE.L	#$06430753,$ffff824c.w
	MOVE.L	#$00030005,$ffff8250.w
	MOVE.L	#$02160325,$ffff8254.w
	MOVE.L	#$04350534,$ffff8258.w
	MOVE.L	#$06430753,$ffff825c.w
	clr.b	$fffffa1b.w
	movem.l	d0/a0-a1,-(sp)
	lea	$ffff8209.w,a0
	lea	spec_cols(pc),a1
	moveq	#0,d0
	move.b	(a0),d0
	sub.b	#$60,d0
	jmp	nops(pc,d0)
nops
	MulNops	93
	move.w	(a1)+,$ffff8250.w
	move.b	#0,$ffff820A.w
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820A.w
	MulNops	83
	move.b	#0,$ffff820A.w
	move.b	#2,$ffff820A.w
	MulNops	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	MulNops	5
	lea	rast_colours,a0
	moveq	#30,d0
.line
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.w	(a1)+,$ffff8250.w
	REPT	3
	move.l	#0,(a0)+
	ENDR
	MulNops	68
	move.b	#0,$ffff820A.w
	move.b	#2,$ffff820A.w
	MulNops	8
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	MulNops	6
	dbf	d0,.line
	REPT	7
	move.l	#0,(a0)+
	ENDR
	movem.l	(sp)+,d0/a0-a1
	bclr.b	#0,$fffffa0f.w
	rte


	SECTION	DATA

spec_cols
	dc.w	$003, $00b, $004, $00c, $005, $00d, $006, $00e
	dc.w	$007, $087, $017, $097, $027, $0a7, $037, $0b7
	dc.w	$047, $0c7, $057, $0d7, $067, $0e7, $077, $07e
	dc.w	$076, $07d, $075, $07c, $074, $07b, $073, $07a

spec_data
	incbin	"SPECTRUM.DAT"
	dc.w	0
spec_values	dcb.w	MAX_BARS,0

colour_bar
; Reds (50Hz)
	dc.w	$800, $100, $900, $200, $a00
	dc.w	$300, $b00, $400, $c00, $500
	dc.w	$d00, $600, $e00, $700, $f00
	dc.w	$700, $e00, $600, $d00, $500
	dc.w	$c00, $400, $b00, $300, $a00
	dc.w	$200, $900, $100, $800
; Greys	(60Hz)
	dc.w	$888, $111, $999, $222, $aaa
	dc.w	$333, $bbb, $444, $ccc, $555
	dc.w	$ddd, $666, $eee, $777, $fff
	dc.w	$777, $eee, $666, $ddd, $555
	dc.w	$ccc, $444, $bbb, $333, $aaa
	dc.w	$222, $999, $111, $888

path_ptr	dc.w	0
raster_path	incbin	"RASTER.PTH"

picture		incbin	"GREEN_PL.PI1"

font		incbin	"LEAN.FNT"

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
	dc.b	-1
	even

tune
	incbin	"290.IMG"
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
	dc.b	"$$FILENAME.EXT",0,0
	dc.b	"TWINS12.PRG",0,0,0,0,0
	dc.b	"TOILET.PRG",0,0,0,0,0,0
	dc.b	"PSYCHO.prg",0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0,0,0
	even


	SECTION	BSS

clock		ds.w	1

key		ds.w	1

hz_col		ds.w	1

rast_colours	ds.w	200

vsync_flag	ds.w	1

save_stk	ds.l	1

kbd_bak		ds.l	1
vbl_bak		ds.l	1
hbl_bak		ds.l	1
a07_bak		ds.b	1
a09_bak		ds.b	1
a13_bak		ds.b	1
conterm		ds.b	1
	even

		ds.b	256
screens		ds.b	(256*164)
finish	even
