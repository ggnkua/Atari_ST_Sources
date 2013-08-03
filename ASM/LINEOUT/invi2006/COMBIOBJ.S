; todo:
; speed optimisation!!!!
; - limit background restoral (possibly delta clearing)
; - test width of poly for jump table or dbf filler!
; - delta polys when polys get too wide

PERSPECTIVE:=	1
;WAIT_FOR_KEY:=	1
MEASURE_CPU:=	0

MAX_Y:=		200
MAX_VERTICES:=	100

	include	mat.s

;--

DEBUG_KEYS:=	0
BACKGOUND_PIC:=	0
RASTERS:=	1

SCREEN_ROWS:=	25
FONT_HEIGHT:=	8
SCREEN_SCANS:=	SCREEN_ROWS*FONT_HEIGHT
TOTAL_ROWS:=	SCREEN_ROWS*2

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Stm1.mainloop
	dc.l	Stm1.init
	dc.l	Stm1.rt_init		; 2
	dc.l	Stm1.deinit
	dc.l	Stm1.set_no_rot		; 4
	dc.l	Stm1.start_rot		; 5
	dc.l	Stm1.switch_scroll	; 6
	dc.l	0

;- plugin routines ---------------------------------------------------------

Stm1.init:
	bsr	calc_inv_table
	bsr	precalc_mul_table
	bsr	Polygon.calcInvTable

;--

	lea	scr_table,a0
	move.l	screen_buffers_adr,d0
	move.l	d0,(a0)+
	addi.l	#64000,d0
	move.l	d0,(a0)+

	move.w	#SCREEN_ROWS-1,base_row_index
	move.w	#0,old_base_row_index
	move.w	#TOTAL_ROWS-1,hidden_row_index
	move.w	#SCREEN_ROWS,old_hidden_row_index

	lea	wave_table,a6
	move.l	a6,wave_step
	movem.l	(a6),d0-d1
	move.l	d0,wave_adr
	move.l	d1,wave_end_adr

	ifne	BACKGOUND_PIC
	bsr	copy_screens
	endc
	bsr	Combi.initconvascii
	bsr	scale_text
	bsr	preshift_font

	moveq	#6,d0
	cmpi.w	#vga60,monitormode
	bne.s	.end
	moveq	#5,d0
.end:	move.l	d0,scroll_update_speed
	rts

Stm1.rt_init:
	move.l	#giga_vbl,palirq

	bsr	Stm1.set_no_rot

; why doesn't this always work?!
	movea.l	screen_buffers_adr,a0
	bsr	CLEAR_STSCREEN
	movea.l	screen_buffers_adr,a0
	lea	32000(a0),a0
	bsr	CLEAR_STSCREEN
	movea.l	screen_buffers_adr,a0
	adda.l	#32000*2,a0
	bsr	CLEAR_STSCREEN
	movea.l	screen_buffers_adr,a0
	adda.l	#32000*3,a0
	bsr	CLEAR_STSCREEN

	move.l	frmcnt,first_frame
	rts

Stm1.deinit:
	ifd	WAIT_FOR_KEY
	lea	.str2(pc),a4
	clr.l	d7
	move.w	$04BC.w,d7
	bsr	mkhex4

	pea	.str(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	endc

	move.l	#dummy,palirq
	rts

.str:	dc.b	"grote kutactie lot nr: $"
.str2:	dc.b	"0123",10,13,0
	even

; input:
; d7.w=number
; a4: dst buffer..
mkhex4:	moveq	#4-1,d5
;	rol.l	#8,d7
	swap	d7
.hex1:	rol.l	#4,d7
	move.w	d7,d6
	and.w	#$f,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a4)+
	dbf	d5,.hex1
	rts	

;--------------------------------------------------------------------------

Stm1.mainloop:
	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	else
	ifeq	testmode
	move.w	#$0002,$FFFF8240.w
	endc
	endc

	bsr	clear_square

;--------------------------------------------------------------------------
; gigascroll stuff 

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0077,$FFFF8240.w
	endc
	endc

; update wave index..
	movea.l	wave_adr,a1
	tst.w	Stm1.scroll_on
	beq.s	.ok
	addq	#4,a1
	cmpa.l	wave_end_adr,a1
	blt.s	.ok

; install new wave..
	movea.l	wave_step,a6
	tst.w	Stm1.scroll_on
	beq.s	.skip_wave_inc
	addq.l	#8,a6
.skip_wave_inc:
	move.l	a6,wave_step
	tst.l	(a6)
	bne.s	.no_wrap
	lea	wave_table,a6
	move.l	a6,wave_step
.no_wrap:
	move.l	(a6)+,a1
	move.l	a1,wave_start_adr
	move.l	(a6)+,wave_end_adr

.ok:	move.l	a1,wave_adr

; update text offsets..
	move.l	text_offset,d0
	tst.w	Stm1.scroll_on
	beq.s	.skip_scroll
;	addq.l	#3,d0				; old.. too slow..
;	addq.l	#6,d0				; for 50 Hz update
;	addq.l	#5,d0				; for 60 Hz update
	add.l	scroll_update_speed,d0
.skip_scroll:
	move.l	d0,text_offset
	move.l	d0,d1
	add.l	(a1),d0
; clip when negative text position..
	bpl.s	.clipped
	clr.l	d0
.clipped:
	move.l	d0,super_text_pos
	lsr.l	#4,d0
	lsr.l	#4,d1
; wrap when necessary..
	cmpi.w	#TEXT_SIZE,d1
	blt.s	.text_pos_ok
	subi.w	#TEXT_SIZE,d1
	lsl.l	#4,d1
	move.l	d1,text_offset
	subi.w	#TEXT_SIZE,d0
	bpl.s	.text_pos_ok
	moveq	#0,d0
.text_pos_ok:

; calc actual text pointer..
	lea	word_infotext,a0
	adda.w	d0,a0
	adda.w	d0,a0
	move.l	a0,Combi.text_up_ptr

; paint some new base line..
	move.w	base_row_index,d0
	mulu.w	#160*FONT_HEIGHT,d0
	movea.l	scr_table,a0				; a0: log screen
	adda.l	d0,a0					; a0: vbase
	move.l	a0,vbase
	move.l	Combi.text_up_ptr,a1
	bsr	paint_shiftedtext

; paint (copy) some new hidden row..
	move.w	hidden_row_index,d0
	mulu.w	#160*FONT_HEIGHT,d0
	movea.l	scr_table,a0				; a0: log screen
	adda.l	d0,a0
	movea.l	vbase,a1
	bsr	copy_row

; copy old line..
	move.w	old_base_row_index,d0
	mulu.w	#160*FONT_HEIGHT,d0
	movem.l	scr_table,a0-a1				; a0: log screen, a1: phys screen
	adda.l	d0,a0					; a0: vbase
	adda.l	d0,a1					; a0: vbase
	bsr	copy_row

; copy this to old hidden row..
	move.w	old_hidden_row_index,d0
	mulu.w	#160*FONT_HEIGHT,d0
	movem.l	scr_table,a0-a1				; a0: log screen, a1: phys screen
	adda.l	d0,a0
	adda.l	d0,a1
	bsr	copy_row

; move rows up.. and wrap..
	move.w	base_row_index,d0
	move.w	d0,old_base_row_index
	subq.w	#1,d0
	bpl.s	.base_wrapped
	move.w	#SCREEN_ROWS-1,d0
.base_wrapped:
	move.w	d0,base_row_index

	move.w	hidden_row_index,d0
	move.w	d0,old_hidden_row_index
	subq.w	#1,d0
	cmpi.w	#SCREEN_ROWS,d0
	bpl.s	.hidden_wrapped
	move.w	#TOTAL_ROWS-1,d0
.hidden_wrapped:
	move.w	d0,hidden_row_index

;--------------------------------------------------------------------------
; tridi stuffs..

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0755,$FFFF8240.w
	endc
	endc

	move.w	$04BC.w,d0
	sub.w	Stm1.rot_start,d0

	lsr.w	#1,d0

	tst.w	Stm1.rot_on
	bne.s	.rot_calced
	moveq	#0,d0
.rot_calced:

	addi.w	#$1DC4,d0

	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#3,d0
	mulu.w	#5,d1
	mulu.w	#7,d2
;	lsr.l	#1,d1
;	lsr.l	#2,d2
	move.w	#600,d3
	bsr	Matrix.generate

	moveq	#0,d0
	moveq	#0,d1
	move.w	#455,d2
	bsr	Matrix.translate

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0304,$FFFF8240.w
	endc
	endc

	lea	transformed_object,a0
	lea	Matrix.temp,a1
	lea	object,a2
	bsr	Object.transform

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0440,$FFFF8240.w
	endc
	endc

	lea	polys,a1
	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7
	clr.l	vis_flags

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset

;	movea.l	scr_table,a0
	movea.l	vbase,a0

	adda.w	d0,a0
	move.l	a0,Primitive.screenadr

	lea	transformed_object+2,a2
	lea	temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a2,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	temp_poly(pc),a0
	bsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

	move.w	vis_flags+2(pc),d0
	addq.w	#1,d0
	move.w	d0,vis_flags+2
.skippy_the_bush_kangaroo:
	move.l	vis_flags(pc),d0
	add.l	d0,d0
	move.l	d0,vis_flags
.next_poly:
	dbf	d7,.loop
.end_loop:

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0f00,$FFFF8240.w
	endc
	endc

	ifne	0

	move.w	#0,d0
	move.w	#0,d1
	move.w	#60,d2	#20,d2
	move.w	#22,d3	#100,d3
	moveq	#$F,d4
	movea.l	scr_table,a0
	lea	scan_table,a1
	lea	putpix_table,a2
	bsr	Line.paint

	else

; check for visibility of polygon with mouse buttons on top..
	move.l	vis_flags(pc),d0
	btst	#7-2,d0
	beq.s	.end_lines

	lea	lines,a4
	move.w	(a4)+,d7
	beq.s	.end_lines
	subq.w	#1,d7
	moveq	#$F,d4

.line_loop:
	movea.l	vbase,a0
	move.w	(a4)+,d0
	add.w	d0,d0
	adda.w	d0,a0

	move.w	(a4)+,d0
	move.w	(a4)+,d2
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	add.w	d2,d2
	move.w	d2,d1
	add.w	d2,d2
	add.w	d1,d2
	lea	transformed_object+2,a2
	movem.w	(a2,d0.w),d0-d1
	movem.w	(a2,d2.w),d2-d3
	lea	putpix_table,a2

	move.w	d7,-(sp)
	lea	scan_table,a1
	bsr	Line.paint
	move.w	(sp)+,d7

	dbf	d7,.line_loop
.end_lines:

	endc

; swap screens..
	lea	scr_table,a0
	movea.l	(a0)+,a1
	move.l	(a0),-(a0)
	move.l	a1,4(a0)

	ifne	MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	ifeq	testmode
	move.w	vbase,$FFFF8200.w
	move.b	vbase+2,$FFFF8203.w
	endc

; wait for vbl..
	move.w	$0468.w,d0
.vbl	cmp.w	$0468.w,d0
	beq.s	.vbl
;	move.w	$0468.w,d0
;.vbl2	cmp.w	$0468.w,d0
;	beq.s	.vbl2
;	move.w	$0468.w,d0
;.vbl3	cmp.w	$0468.w,d0
;	beq.s	.vbl3

	rts

temp_poly:
	ds.w	100
first_frame:
	ds.l	1
vis_flags:
	ds.l	1

scan_table:
.offset	set	0
	rept	MAX_Y
	dc.w	.offset
.offset	set	.offset+160
	endr

putpix_table:
	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001

;--------------------------------------------------------------------------

Stm1.switch_scroll:
	not.w	Stm1.scroll_on
	rts

Stm1.set_no_rot:
	clr.w	Stm1.rot_on
	rts

Stm1.start_rot:
	move.w	$4BC.w,Stm1.rot_start
	st	Stm1.rot_on
	rts

Stm1.init_pal:
	move.w	#$0000,$FFFF8242.w		; %0001
	move.w	#$0222,$FFFF8244.w		; %0010
	move.w	#$0222,$FFFF8246.w		; %0011
	move.w	#$0444,$FFFF8248.w		; %0100
	move.w	#$0444,$FFFF824A.w		; %0101
	move.w	#$0222,$FFFF824C.w		; %0110
	move.w	#$0222,$FFFF824E.w		; %0111
	move.w	#$0333,$FFFF8250.w		; %1000
	move.w	#$0333,$FFFF8252.w		; %1001
	move.w	#$0222,$FFFF8254.w		; %1010
	move.w	#$0222,$FFFF8256.w		; %1011
	move.w	#$0333,$FFFF8258.w		; %1100
	move.w	#$0333,$FFFF825A.w		; %1101
	move.w	#$0222,$FFFF825C.w		; %1110
	move.w	#$0222,$FFFF825E.w		; %1111

	rts

precalc_mul_table:
	lea	mul_table+128*256*2,a0
	clr.w	d1

.yloop:	clr.w	d0

.xloop:	move.w	d0,d2
	move.w	d1,d3
	ext.w	d2
	ext.w	d3
	muls.w	d2,d3

	asr.w	#6,d3

	move.w	d0,d2
	lsl.w	#8,d2
	move.b	d1,d2
	ext.l	d2
	add.l	d2,d2
	move.w	d3,(a0,d2.l)
	addq.b	#1,d0
	bne.s	.xloop

	addq.b	#1,d1
	bne.s	.yloop
	rts

;--------------------------------------------------------------------------
; vertex processing plant..
;--------------------------------------------------------------------------

; seems to work ok, since there has been some patching on the overflow
; errors (caused by combination of finite accuracy and use of maximum range).
; input:
; d0.w= x rotation (a)
; d1.w= y rotation (b)
; d2.w= z rotation (c)
; d3.w= z (for non-perspective scaled projection)
Matrix.generate:
	ifeq	PERSPECTIVE
	move.l	#$00FFFFFF,d7
	divu.w	d3,d7
	endc
	lea	Matrix.temp,a0
; 1] rotate 3 axis.
	move.w	#2048-1,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	movea.w	d0,a3				; a3=xrot=a
	movea.w	d1,a4				; a4=yrot=b
	movea.w	d2,a5				; a5=zrot=c
	adda.w	a3,a3
	adda.w	a3,a3				; a3=xrot*4=4a (addressing offset)
	adda.w	a4,a4
	adda.w	a4,a4				; a4=yrot*4=4b (addressing offset)
	adda.w	a5,a5
	adda.w	a5,a5				; a5=zrot*4=4c (addressing offset)
	lea	sine_tbl,a2

; x' = + x*cos(b)*cos(c)
;      - y*cos(b)*sin(c)
;      + z*sin(b)
	movem.w	(a2,a4.w),d3/d4
	movem.w	(a2,a5.w),d5/d6
	muls.w	d4,d6				; / cos(b)*sin(c)
	add.l	d6,d6				; |
	swap	d6				; \
	muls.w	d4,d5				; / -cos(b)*sin(c)
	add.l	d5,d5				; |
	swap	d5				; |
	neg.w	d5				; \
	ifeq	PERSPECTIVE
	muls.w	d7,d6
	muls.w	d7,d5
	muls.w	d7,d3
	add.l	d6,d6
	add.l	d5,d5
	add.l	d3,d3
	swap	d6
	swap	d5
	swap	d3
	endc
	move.w	d6,(a0)+
	move.w	d5,(a0)+
	move.w	d3,(a0)+
	
; y' = + x*(sin(a)*sin(b)*cos(c)+cos(a)*sin(c))
;      + y*(cos(a)*cos(c)-sin(a)*sin(b)*sin(c))
;      - z*sin(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4
	add.w	d4,d5
	bvc.s	.skipyvd5
	addq.w	#1,d5
	neg.w	d5
.skipyvd5:
	move.w	d5,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d5
	add.l	d5,d5
	swap	d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	sub.w	d4,d5
	bvc.s	.skipyv2d5
	addq.w	#1,d5
	neg.w	d5
.skipyv2d5:
	move.w	2(a2,a4.w),d4
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	neg.w	d4
	ifeq	PERSPECTIVE
	muls.w	d7,d3
	muls.w	d7,d5
	muls.w	d7,d4
	add.l	d3,d3
	add.l	d5,d5
	add.l	d4,d4
	swap	d3
	swap	d5
	swap	d4
	endc
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	ifne	PERSPECTIVE

; z' = + x*(sin(a)*sin(c)-cos(a)*sin(b)*cos(c))
;      + y*(cos(a)*sin(b)*sin(c)+sin(a)*cos(c))
;      + z*cos(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	sub.w	d5,d4
	bvc.s	.skipzvd4
	addq.w	#1,d4
	neg.w	d4
.skipzvd4:
	move.w	d4,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	muls.w	d0,d5
	add.l	d5,d5
	swap	d5
	add.w	d4,d5
	bvc.s	.skipzvd5
	addq.w	#1,d5
	neg.w	d5
.skipzvd5:
	move.w	2(a2,a4.w),d4
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4

;	muls.w	d7,d3
;	muls.w	d7,d5
;	muls.w	d7,d4
;	add.l	d3,d3
;	add.l	d5,d5
;	add.l	d4,d4
;	swap	d3
;	swap	d5
;	swap	d4

	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	else

	addq	#6,a0

	endc

; translation vector = (0,0,0)
	clr.l	d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

; translate the matrix translation vector.
; input:
; d0.w: x translation
; d1.w: y translation
; d2.w: z translation
Matrix.translate:
	lea	Matrix.temp,a0
	add.w	d0,Matrix.TX(a0)
	add.w	d1,Matrix.TY(a0)
	add.w	d2,Matrix.TZ(a0)
	rts

calc_inv_table:
	lea	inv_table,a0
	move.l	#$7FFF,d0
	moveq	#0,d7
.loop:	move.l	d0,d1
	divu.w	d7,d1
	move.w	d1,(a0)+
	addq.w	#1,d7
	cmpi.w	#1024,d7
	blt.s	.loop
	rts

; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Object.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	mul_table+128*256*2,a4

	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3

.vertexloop:
	movem.w	(a2)+,d0-d2

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	d6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a3,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	PERSPECTIVE

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.w	d3,d3
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst(pc),a0			; a0: dst object
	;move.w	a5,d7				; d7.w=#vertices
	move.w	#160,d4
	move.w	#100,d5
	move.w	#$0100,d3			; d3.w=z_offset

	lea	inv_table,a1

; nasty unroll optimisation!
	rept	12

	ifne	PERSPECTIVE

	movem.w	(a0),d0-d2
	add.w	d3,d2

	add.w	d2,d2
	move.w	(a1,d2.w),d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#7,d0
	asr.l	#7,d1
	;lsl.l	#8,d0
	;lsl.l	#8,d1
	;divs.w	d2,d0
	;divs.w	d2,d1

	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0

	else

	move.w	(a0),d0
	asr.w	d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	d1
	add.w	d5,d1
	move.w	d1,(a0)+
	addq	#2,a0

	endc

	endr

	rts

.dst:	dc.l	0

CHUNKS:	=	8

;128/16=8
;8x24=192 cycles per scan
;(192+20)x128=16384+8192=24576+2560 cycles.. (better than ~70000)
	adda.w	d1,a0
	clr.l	d0
.yloop:
	rept	CHUNKS
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	endr
	lea	160-CHUNKS*8(a0),a0
	dbf	d7,.yloop

; fast but messes up rasters, tho..
; todo: flexible size (depending on bounding slab)
clear_square:
	move.w	base_row_index,d0
	mulu.w	#160*FONT_HEIGHT,d0
	movea.l	scr_table,a6				; a0: log screen, a1: phys screen
	adda.l	d0,a6
	moveq.l	#0,d0

; wipe incoming crap from top of screen (this crap always exists due to
; the wrapping around).

	ifne	1
	move.l	a6,d6
	lea	48+2(a6),a6
	rept	16
;	move.w	d0,(a6)+
;	move.l	d0,(a6)+
;	addq	#2,a6
;	move.w	d0,(a6)+
;	move.l	d0,(a6)+
;	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	lea	160+2-64(a6),a6
	endr
	movea.l	d6,a6
	endc

; wipe the rest.. this is 16 lines less than usual..
	lea	(53+16)*160+48+2(a6),a6
	rept	97

;	move.w	d0,(a6)+
;	move.l	d0,(a6)+
;	addq	#2,a6
;	move.w	d0,(a6)+
;	move.l	d0,(a6)+
;	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	addq	#2,a6
	move.w	d0,(a6)+
	move.l	d0,(a6)+
	lea	160+2-64(a6),a6
	endr

.end:	rts

;--------------------------------------------------------------------------

; input:
; d0.w=x0
; d1.w=y0
; d2.w=x1
; d3.w=y1
; d4.w=$F
; a0: screen
; a1: offset table
; a2: putpixel table
Line.paint:
	cmp.w	d0,d2
	bgt.s	.x_order_ok
	exg	d0,d2
	exg	d1,d3
.x_order_ok:
	sub.w	d0,d2				; d2.w=dx=abs(dx)
	sub.w	d1,d3				; d3.w=dy
	add.w	d1,d1
	move.w	d0,d5
	and.w	d4,d0				; d0.w=lx&$F
	sub.w	d0,d5				; d5.w=lx&$FFF0
	lsr.w	d5				; d5.w=chunk=(lx&$FFF0)>>2
	add.w	(a1,d1.w),d5			; d5.w=offset=y*160+chunk
	lea	(a0,d5.w),a6
	move.w	#160,d6				; d6.w=y increment
	move.w	d3,d7
	bpl.s	.y_abs
	neg.w	d7
	neg.w	d6				; negative increment!
.y_abs:	cmp.w	d2,d7
	bgt.s	.dy_greater

.dx_greater:
; todo: special masking shit!	
;	add.w	d0,d0
;	cmp.w	d0,d5
;	bgt.s	.mask_optimised
; choose a mask-optimised thingy or straight-forward put-pixel stuffs.

; for now we use a totally 100% pessimised (but simple) loop!
	move.w	d2,d5				; d5.w=abs(dx)
	move.w	d2,d3				; d3.w=abx(dx)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	moveq	#0,d1

.hor_loop:
	or.w	d0,d1
	sub.w	d7,d5
	bgt.s	.next_hor
	add.w	d2,d5
	or.w	d1,(a6)
	moveq	#0,d1
	adda.w	d6,a6
.next_hor:
	ror.w	d0
	dbcs	d3,.hor_loop

	or.w	d1,(a6)
	moveq	#0,d1
	addq	#8,a6
; beware, d3 may already be -1! no dbf possible!
	subq.w	#1,d3
	bpl.s	.hor_loop

	rts

; todo: use table to get rout decision?
.dy_greater:
	move.w	d7,d5				; d5.w=abs(dy)
	move.w	d7,d3
	add.w	d0,d0
	move.w	(a2,d0.w),d0
;	tst.w	d2
;	bmi.s	.rol_loop

	ifne	1

	lea	.jump_end(pc),a3		;  8
	neg.w	d7				;  4
	lsl.w	#4,d7				; 14 / combines to 
	jmp	(a3,d7.w)			; 14 \ 28, not 32 :))
	
	rept	200
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	*+10	;.next
	add.w	d3,d5
	ror.w	d0
	bcc.s	*+4	;.next
	addq	#8,a6
;.next:
	adda.w	d6,a6
	endr
.jump_end:

	else

.ror_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_ror
	add.w	d3,d5
	ror.w	d0
	bcc.s	.next_ror
	addq	#8,a6
.next_ror:
	adda.w	d6,a6
	dbf	d7,.ror_loop

	endc
	rts

; never gets called with dx>=0
.rol_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_rol
	add.w	d3,d5
	add.w	d0,d0
	bcc.s	.next_rol
	moveq	#1,d0
	subq	#8,a6
.next_rol:
	adda.w	d6,a6
	dbf	d7,.rol_loop
	rts

;--------------------------------------------------------------------------

Polygon.calcInvTable:
	lea	Polygon.invTable,a0
	move.l	#$8000,d1
	moveq	#2,d0
	move.w	#$7fff,(a0)+
	move.w	#$7fff,(a0)+

.posloop:
	move.l	d1,d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmpi.w	#MAX_Y+1,d0
	blt.s	.posloop
	rts

; input:
; a0: old poly (frame n-1) (#vertices (V), (x,y)[0], .., (x,y)[n-1], (x,y)[n])
; a1: new poly (frame n)   (#vertices (V), (x,y)[0], .., (x,y)[n-1], (x,y)[n])
;
; notation:
; ve = (x,y)
paint_poly_deltas:
	move.w	(a1)+,d7	; d7.w=V
	beq.s	.end
	addq	#2,a0
	subq.w	#1,d7		; d7.w=V-1

.edge_loop:
; 1) calculate envelope of delta polygon..
	lea	edge_poly,a2
	move.l	(a0)+,d0	; d0.l=(x,y)[v,0], a0: (x,y)[v+1,0]
	move.l	(a0),d1		; d1.l=(x,y)[v+1,0]
	move.l	d1,(a2)+
	move.l	d0,(a2)+	; (a2-8): {(x,y)[v+1,0], (x,y)[v,0]}
	move.l	(a1)+,(a2)+	; a0: (x,y)[v+1,1]
	move.l	(a1),(a2)+	; (a2-16): {ve[v+1,0], ve[v,0], ve[v,1], ve[v+1,1]}

; 2) split envelope into new/old parts..
	dbf	d7,.edge_loop

.end:	rts

edge_poly:
	ds.l	4*2

;--------------------------------------------------------------------------

JUMPTREE:=	1

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left_edge_table
macro_hline1fat:	macro
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d4
	and.w	32(a1,d7.w),d4
	or.w	d4,(a0,d5.w)
	bra.s	.end

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	lea	(a0,d5.w),a6		; a6: first chunk

	ifne	1 JUMPTREE

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:
.end:
	endm

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left_edge_table
macro_hline1slim:	macro
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d4
	and.w	32(a1,d7.w),d4
	or.w	d4,(a0,d5.w)
	bra.s	.end

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	lea	(a0,d5.w),a6		; a6: first chunk

	ifne	0 JUMPTREE

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:
.end:
	endm

; Subroutine that paints a flatshaded fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a5: width (bytes)
; OUTPUT: a0: start of next screenline
paint_flatfragment_fat:
	movem.l	a1-a2/a6,-(sp)
	lea	left_edge_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2

.yloop:
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

;	cmp.w	d5,d6
;	blt	.end__

	macro_hline1fat
.end_hline:

	adda.w	a5,a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; Subroutine that paints a flatshaded fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a5: width (bytes)
; OUTPUT: a0: start of next screenline
paint_flatfragment_slim:
	movem.l	a1-a2/a6,-(sp)
	lea	left_edge_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2

.yloop:
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

;	cmp.w	d5,d6
;	blt	.end__

	macro_hline1slim
.end_hline:

	adda.w	a5,a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; input:
; d6.w=n
; a1: poly (x1.w, y1.w, ..., xn.w, yn.w)
check_width:
	moveq	#$FFFFFFFF,d0
	moveq	#$00000000,d1
	subq.w	#1,d6
.loop:	move.w	(a1),d2
	cmp.w	d0,d2
	bhs.s	.no_new_left
	move.w	d2,d0
.no_new_left:
	cmp.w	d1,d2
	bls.s	.no_new_right
	move.w	d2,d1
.no_new_right:
	addq	#4,a1
	dbf	d6,.loop	
; d0.w=left x, d1.w=right x

; decision making..
	sub.w	d0,d1
	cmpi.w	#32,d1
	blt.s	.slim
.fat:	lea	paint_flatfragment_fat(pc),a4
	rts
.slim:	lea	paint_flatfragment_slim(pc),a4
	rts

; input:
; a0: poly (#vertices, (x,y), (x,y) ...)
paint_flat_poly:
	move.w	(a0)+,d7

	;move.l	a0,a1
	;move.w	d7,d6
	;bsr.s	check_width

	;lea	rts(pc),a4

	lea	paint_flatfragment_fat(pc),a4

; INPUT:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a4: trapezoid paintrout
prest_paint_poly:
; Can you tell your head from your ass?
	bsr	prest_reorder

; if not anti-clockwise, you can make it..
; todo: do the test when required..
.anti_clockwise:
	lea	prest_left_table,a6
	lea	prest_right_table,a2
;	bra.s	.dir_done
;.clockwise:
;	lea	prest_left_table,a2
;	lea	prest_right_table,a6
;.dir_done:

	lea	Polygon.invTable,a5

	lea	prest_poly2(pc),a1
	movea.l	a6,a0
	move.w	prest_max(pc),d6
	bsr	prest_calc_left_points

	lea	prest_poly2(pc),a1
	movea.l	a2,a0
	move.w	prest_max(pc),d6
	bsr	prest_calc_right_points

; Now paint trapezoids..
; d4.l=color (optional)
; a4: trapezoid paintrout
; a6: left
; a2: right
	movem.w	prest_poly2(pc),d0-d1
	move.w	d1,d6				; d1.w=d6.w=top

; Set screenstart
;	movea.l	PrimitiveMesh.background,a3
	movea.l	Primitive.screenadr,a0
	move.w	d1,d2
	mulu.w	#160,d2
;	add.l	d2,d2
	adda.l	d2,a0
;	adda.l	d2,a3
	movea.w	#160,a5

; Head..
	cmp.w	(a6),d6
	beq	.horizontal_head_l
	cmp.w	(a2),d6
	beq.s	.horizontal_head_r
; Normal triangular head..
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.l	d0,d1				; d1.l=rx start (16:16)
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)

.loop:
; d6.w=y start
; a0: start of next screenline
	cmp.w	prest_max(pc),d6
	beq.s	.end
	move.w	(a6),d7
	cmp.w	(a2),d7
	bgt.s	.left_bigger
	blt.s	.right_bigger

; Both sides equal..
;  / \
; /   \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_b
	jsr	(a4)
.skip_b:move.w	(a6)+,d6			; d6.w=y
	move.w	(a6)+,d0			; d0.w=lx start
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=rx start (16:16)
	addq	#4,a6				; a6: next left
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.right_bigger:
; Right bigger, proceed to next left..
; / \
;    \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_r
	jsr	(a4)
.skip_r:move.w	(a6)+,d6
	move.w	(a6)+,d0
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	addq	#4,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	bra.s	.loop

.left_bigger:
; Left bigger, proceed to next right..
;  / \
; /
	move.w	(a2),d7
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_l
	jsr	(a4)
.skip_l:move.w	(a2)+,d6
	move.w	(a2)+,d1
	swap	d1
	move.w	#$8000,d1			; d1.l=rx start (16:16)
	addq	#4,a2				; a2: next right
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.end:	rts

; Special fucking cases..

;   o---r
;  /    :
; l
.horizontal_head_r:
	move.w	2(a2),d1
	swap	d1
	move.w	#$8000,d1			; d1.l=right x (16:16)
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

.horizontal_head_l:
	cmp.w	(a2),d1
	beq.s	.horizontal_head
; l---o
; :    \
;       r
	swap	d0
	move.w	#$8000,d0
	move.l	d0,d1				; d1.l=right x (16:16)
	move.w	2(a6),d0
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

; l---o---r
; :       :
.horizontal_head:
	move.w	2(a6),d0
	swap	d0
	move.w	#$8000,d0			; d0.l=left x (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=right x (16:16)
	addq	#8,a6				; a6: next left
	addq	#8,a2				; a6: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

; d7.w=pointcount >=3
; a0: point table count*(x.w,y.w)
prest_reorder:
; Find min y and max y.
	movea.l	a0,a1				; a1: backup src poly
	addq	#2,a0				; a0: y coords
	move.w	d7,d6
	move.w	d7,d1				; d1.w=count-index_min[0]
	move.w	d7,d3				; d3.w=count-index_max[0]
	subq.w	#1,d6
	moveq	#$FFFFFFFF,d0			; d0.w=min[0]
	moveq	#$00000000,d2			; d2.w=max[0]
.loop:	cmp.w	(a0),d0				; y[n]<min[n-1] ?
	blo.s	.try_max			; nope -> check next
	move.w	(a0),d0				; Set new min.
	move.w	d6,d1				; Set new minindex.
.try_max:
	cmp.w	(a0),d2
	bhi.s	.next
	move.w	(a0),d2				; Set new max.
	move.w	d6,d3				; Set new maxindex.
.next:	addq	#4,a0				; a0: next point
	dbf	d6,.loop
	move.w	d0,prest_min
	move.w	d2,prest_max

; Head up!
	lea	prest_poly2(pc),a0

; Rotate the point table using a barrel shift.
; The 
; a0: dst point table
; a1: src point table
; d1.w=count - split index
; d7.w=pointcount
	move.w	d7,d4
	subq.w	#1,d7				; d7.w=#points-1
	move.w	d7,d6
	sub.w	d1,d6				; d6.w=count-(count-split)=split

; todo: d6 should not exceed 16383!
	lsl.w	#2,d6
	lea	(a1,d6.w),a2			; a2: src tail
	lsr.w	#2,d6

	move.w	d1,d5				; d5.w=headsize
.headloop:
	move.l	(a2)+,(a0)+
	dbf	d5,.headloop

	subq.w	#1,d6
	bmi.s	.tail_done
.tailloop:
	move.l	(a1)+,(a0)+
	dbf	d6,.tailloop
.tail_done:

	move.w	d4,d7
	rts

; d6.w=btm
; a0: left table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
prest_calc_left_points:
	clr.l	d2
	move.w	(a1)+,d1				; d0.w=y[0]
	move.w	(a1)+,d0				; d1.w=x[0]
.loop:
; a1: next point
	move.w	2(a1),d2				; d2.w=y[n]
	move.w	d2,(a0)+				; Store y.
	sub.w	d0,d2					; d2.w=dy
	move.w	(a1),d3					; d3.w=x[n]
	move.w	d3,(a0)+				; Store x.
	sub.w	d1,d3					; d1.w=dx

; todo: d2.w should not exceed 32767..
	add.l	d2,d2
	muls.w	(a5,d2.l),d3				; d3.l=dx<<16/dy

	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	(a1)+,d1				; d0.w=y[n]
	move.w	(a1)+,d0				; d1.w=x[n]
	cmp.w	d0,d6
	bne.s	.loop
.end:	rts

; d6.w=btm
; d7.w=#points
; a0: right table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
prest_calc_right_points:
	clr.l	d2
	move.w	(a1)+,d1				; d0.w=y[0]
	move.w	(a1)+,d0				; d1.w=x[0]

	lsl.w	#2,d7
	lea	-8(a1,d7.w),a1
	lsr.w	#2,d7
.loop:
; a1: next point
	move.w	2(a1),d2				; d2.w=y[n]
	move.w	d2,(a0)+				; Store y.
	sub.w	d0,d2					; d2.w=dy
	move.w	(a1),d3					; d3.w=x[n]
	move.w	d3,(a0)+				; Store x.
	sub.w	d1,d3					; d1.w=dx

; todo: d2.w should not exceed 32767!
	add.l	d2,d2
	muls.w	(a5,d2.l),d3				; d3.l=dx<<16/dy

	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	(a1)+,d1				; d0.w=y[n]
	move.w	(a1)+,d0				; d1.w=x[n]
	subq	#8,a1
	cmp.w	d0,d6
	bne.s	.loop
.end:	rts

prest_max:
	ds.w	1
prest_min:
	ds.w	1
prest_poly2:
	ds.l	16
prest_left_table:
	ds.l	2*16
prest_right_table:
	ds.l	2*16

Polygon.invTable:
	DS.W	MAX_Y+1

Primitive.screenadr:
	ds.l	1

rts:	rts

;--------------------------------------------------------------------------

	ifne	0

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a1: left_edge_table
hline1:	movea.l	a0,a6
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	adda.w	d5,a6			; a6: first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d5
	and.w	32(a1,d7.w),d5
	or.w	d5,(a6)
	rts

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	adda.w	d5,a6			; a6: first chunk

	ifne	1

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	rept	20
	move.w	d4,(a6)
	addq	#8,a6
	endr
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:

	rts

	endc

; keep the tables toghether, please.
left_edge_table:
	dc.w	$FFFF,$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF
	dc.w	$00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001
right_edge_table:
	dc.w	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
	dc.w	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE

mixed_edge_table:
	dc.w	$FFFF,$0000,$7FFF,$8000,$3FFF,$C000,$1FFF,$E000
	dc.w	$0FFF,$F000,$07FF,$F800,$03FF,$FC00,$01FF,$FE00
	dc.w	$00FF,$FF00,$007F,$FF80,$003F,$FFC0,$001F,$FFE0
	dc.w	$000F,$FFF0,$0007,$FFF8,$0003,$FFFC,$0001,$FFFE

;--------------------------------------------------------------------------
; gigascroll stuffs..

giga_vbl:
	bsr	Stm1.init_pal

	IFNE	RASTERS
	move.l	#raster_table+2,raster_ptr
	move.w	raster_table,$FFFF8242.w
	clr.b	$fffffa1b.w
	move.b	#FONT_HEIGHT,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#HBL_GIGA1,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	ENDC
	rts

HBL_GIGA1:
;	not.w	$FFFF8240.w

	move.l	a0,-(sp)
	move.w	d0,-(sp)

	movea.l	raster_ptr(pc),a0
	move.w	(a0)+,d0
	bmi.s	.last_raster
	move.w	d0,$FFFF8242.w
	move.l	a0,raster_ptr

	clr.b	$fffffa1b.w
	move.b	#FONT_HEIGHT,$fffffa21.w
	move.b	#8,$fffffa1b.w

.end:	move.w	(sp)+,d0
	movea.l	(sp)+,a0
	rte

.last_raster:
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	bra.s	.end

raster_ptr:
	dc.l	raster_table

raster_table:
;	dc.w	$f00,$0f0,-1

;	dc.w	$100,$200,$300,$400,$500,$600,$700,$710
;	dc.w	$720,$730,$740,$750,$760,$770,$771,$772
;	dc.w	$773,$774,$775,$776,$777,$677,$577,$477
;	dc.w	$377,-1

	dc.w	$777,$666,$555,$444,$333,$334,$335,$336
	dc.w	$337,$447,$557,$667,$777,$666,$555,$444
	dc.w	$333,$334,$335,$336,$337,$447,$557,$667
	dc.w	$777,-1

;--------------------------------------------------------------------------

preshift_font:
	lea	shift_buf,a0
	moveq	#8-1,d7

.shift_loop:
	lea	Combi.fonte,a1
	move.w	#FONT_SIZE-1,d6

.cloop:	clr.w	d1
	move.b	(a1)+,d1
	ror.w	d7,d1
	ror.w	#8,d1
	move.w	d1,(a0)+
	dbf	d6,.cloop

	dbf	d7,.shift_loop
	rts

; refreshes 1 plane text buffer using new bottom line..
; input:
; a0: screen row
; a1: text adr
paint_shiftedtext:
	tst.w	Stm1.scroll_on
	bne.s	.ok
	rts

.ok:	exg	a0,a1
	lea	Combi.asciiconv,a2
	lea	shift_buf,a3
	move.l	super_text_pos,d0
	lsr.l	d0
	andi.w	#7,d0
	mulu.w	#FONT_SIZE*2,d0
	adda.l	d0,a3

; overspill from first char..
	moveq	#0,d0
	movea.l	a3,a5
	adda.w	(a0)+,a5

off	set	0
	rept	8
	addq	#1,a5
	move.b	(a5)+,off(a1)
off	set	off+160
	endr

; body chars..
	moveq	#19-1,d3

.loop:	movea.l	a3,a4
	adda.w	(a0)+,a4
	movea.l	a3,a5
	adda.w	(a0)+,a5

; todo: special case for 1st char.. (clear background)

off	set	0
	rept	8
	move.w	off(a1),d2
	clr.b	d2
	or.w	(a4)+,d2
	or.b	(a5)+,d2
	move.b	(a5)+,off+8(a1)
	move.w	d2,off(a1)
off	set	off+160
	endr

	addq	#8,a1

	dbf	d3,.loop

; final stuff. no overspill..
	movea.l	a3,a4
	adda.w	(a0)+,a4
	movea.l	a3,a5
	adda.w	(a0)+,a5

off	set	0
	rept	8
	move.w	off(a1),d2
	clr.b	d2
	or.w	(a4)+,d2
	or.b	(a5)+,d2
	addq	#1,a5
	move.w	d2,off(a1)
off	set	off+160
	endr

	rts

;--------------------------------------------------------------------------

Combi.initconvascii:
	lea	Combi.asciiconv1,a0
	lea	Combi.asciiconv,a1
	moveq #0,d1

.loop:	moveq #0,d0
	move.b (a0)+,d0
	beq.s .endloop

	moveq	#0,d2
	move.b	d1,d2
	lsl.w	#3+1,d2
	add.w	d0,d0
	move.w	d2,(a1,d0.w)

	addq.w #1,d1
	bra.s .loop
.endloop:
	rts

; refreshes 1 plane text buffer using new bottom line..
; input:
; a0: screen row
; a1: text adr
copy_text:
	exg	a0,a1
	moveq	#0,d0
	lea	Combi.asciiconv,a2
	lea	Combi.fonte,a3
	moveq	#20-1,d3

.loop:	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	lsl	#3,d1
	lea	(a3,d1),a4
	move.b	(a4)+,(a1)
	move.b	(a4)+,160(a1)
	move.b	(a4)+,320(a1)
	move.b	(a4)+,480(a1)
	move.b	(a4)+,640(a1)
	move.b	(a4)+,800(a1)
	move.b	(a4)+,960(a1)
	move.b	(a4)+,1120(a1)
	addq.w	#1,a1

	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	lsl	#3,d1
	lea	(a3,d1),a4
	move.b	(a4)+,(a1)
	move.b	(a4)+,160(a1)
	move.b	(a4)+,320(a1)
	move.b	(a4)+,480(a1)
	move.b	(a4)+,640(a1)
	move.b	(a4)+,800(a1)
	move.b	(a4)+,960(a1)
	move.b	(a4)+,1120(a1)
	addq	#7,a1
	dbf	d3,.loop
	rts

; assuming we have pure ascii text (only 7 bits used), we can prescale by
; 2.
scale_text:
	lea	Combi.infotext,a0
	lea	word_infotext,a1
	lea	Combi.asciiconv,a2
	move.w	#TEXT_SIZE+40-1,d7
	moveq	#0,d0
.loop:	move.b	(a0),d0
	add.b	d0,d0
	move.b	d0,(a0)+
	move.w	(a2,d0),(a1)+
	dbf	d7,.loop
	rts

;--------------------------------------------------------------------------

copy_row:
	tst.w	Stm1.scroll_on
	bne.s	.ok
	rts

; todo: optimise..
; may be overlapped with 3 wiped planes.. may account for 4 raster lines..
.ok:	;moveq	#0,d0

	rept	FONT_HEIGHT*20
	move.w	(a1),(a0)

;	move.w	d0,(a0)+
;	move.l	d0,(a0)+
	addq	#8,a0

	addq	#8,a1
	endr
	rts

	ifne	BACKGOUND_PIC
copy_screens:
	movea.l	scr_table,a0
	lea	piccy+34,a1
	move.w	#8000-1,d7
.copy_loop:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop
	lea	piccy+34,a1
	move.w	#8000-1,d7
.copy_loop2:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop2

	movea.l	scr_table+4,a0
	lea	piccy+34,a1
	move.w	#8000-1,d7
.copy_loop3:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop3
	lea	piccy+34,a1
	move.w	#8000-1,d7
.copy_loop4:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop4

	rts
	endc

wave_step:
	dc.l	wave_table

wave_table:
	dc.l	big_swave,end_big_swave
	dc.l	big_swave,end_big_swave
	dc.l	big_swave,end_big_swave
	dc.l	big_swave,end_big_swave
	dc.l	big_swave,end_big_swave
	dc.l	big_swave,end_big_swave
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	fast_saw,end_fast_saw
	dc.l	wave,end_wave
	dc.l	wave,end_wave
	dc.l	wave,end_wave
	dc.l	wave,end_wave
	dc.l	wave,end_wave
	dc.l	swave,end_swave
	dc.l	swave,end_swave
	dc.l	swave,end_swave
	dc.l	swave,end_swave
	dc.l	swave,end_swave
	dc.l	0

wave_adr:
	dc.l	big_swave
wave_start_adr:
	dc.l	big_swave
wave_end_adr:
	dc.l	end_big_swave

wave:	dc.l	+0*2,+1*2,+2*2,+3*2,+4*2,+5*2,+6*2,+7*2
	dc.l	+7*2,+6*2,+5*2,+4*2,+3*2,+2*2,+1*2,+0*2
	dc.l	+0*2,-1*2,-2*2,-3*2,-4*2,-5*2,-6*2,-7*2
	dc.l	-7*2,-6*2,-5*2,-4*2,-3*2,-2*2,-1*2,+0*2
end_wave:

fast_saw:
	dc.l	+00,+03,+06,+09,+12,+09,+06,+03
	dc.l	-00,-03,-06,-09,-12,-09,-06,-03
end_fast_saw:

swave:	dc.l	+00,+08,+15,+21,+26,+30,+33,+35
	dc.l	+36,+35,+33,+30,+26,+21,+15,+08
	dc.l	-00,-08,-15,-21,-26,-30,-33,-35
	dc.l	-36,-35,-33,-30,-26,-21,-15,-08
end_swave:

big_swave:
step	set	15
pos	set	0
	rept	31
	dc.l	pos
pos	set	pos+step
step	set	step-1
	endr

step	set	15
pos	set	0
	rept	31
	dc.l	-pos
pos	set	pos+step
step	set	step-1
	endr
end_big_swave:

;--------------------------------------------------------------------------

	data

	ifne	0

test_poly:
	dc.w	4
	dc.w	22,47
	dc.w	59,10
	dc.w	12,08
	dc.w	10,40

old_test_poly:
	dc.w	3
	dc.w	19,10
	dc.w	5,20
	dc.w	27,40

	endc

.RAD:=	90

	ifne	1

	include tank-.s

	else

object:	dc.w	8
	dc.w	-.RAD,-.RAD,-.RAD
	dc.w	+.RAD,-.RAD,-.RAD
	dc.w	+.RAD,-.RAD,+.RAD
	dc.w	-.RAD,-.RAD,+.RAD
	dc.w	-.RAD,+.RAD,+.RAD
	dc.w	+.RAD,+.RAD,+.RAD
	dc.w	+.RAD,+.RAD,-.RAD
	dc.w	-.RAD,+.RAD,-.RAD

polys:	dc.w	6
	dc.w	2+1,4,7,6,1,0
	dc.w	0+1,4,6,5,2,1
	dc.w	1+1,4,0,1,2,3
	dc.w	2+1,4,5,4,3,2
	dc.w	1+1,4,4,5,6,7
	dc.w	0+1,4,0,3,4,7

lines:	dc.w	2
	dc.w	2+1,1,2
	dc.w	2+1,2,3

	endc

;--------------------------------------------------------------------------
; gigascroll..

Combi.asciiconv1:
	dc.b	" abcdefghijklmnopqrstuvwxyz0123456789!.,*"
	dc.b	"                     '|=-+\/_*&`[]()@?:;"
	dc.b	0
	even

	ds.b	2048
Combi.fonte:  dcb.b	8,0		; space..
	incbin	fnt882c.dat
font_end:
	ds.b	2048

FONT_SIZE:=	font_end-Combi.fonte

	ifne	BACKGOUND_PIC
piccy:	incbin	popstars.pi1
	endc

text_offset:
	dc.l	0 160*16

Combi.text_up_ptr:
	dc.l	Combi.infotext
Combi.infotext:
	dc.b	"                                        "
	dc.b	"yeaargh! lineout is in da house! writing this "
	dc.b	"for the outline 2006 st invitro... "
	dc.b	"we hope you can join us in the first weekend of june "
	dc.b	"at a great location with loads of other sceners and atari freaks. "
	dc.b	"this intro: not much to say about it except that it's a mixture "
	dc.b	"of oldschool and 'new' school stuff.. "
	dc.b	"and oh yeah.. it should "
	dc.b	"run on any st and falcon with 1 meg or more.. "
	dc.b	"credits: .... "
	dc.b	"code: earx, gloky/mjj. graphics: facet/lemon, havoc. music: marcer/atari legend ... "
	dc.b	"next up is some more effect stuffs.. "
	dc.b	"more info and full invitation text can be found at the end of this intro... "
	dc.b	"that's all for now.. enjoy the rest..                                       "
	dc.b	"                                                                            "
Combi.end_infotext:
	dc.b	"                                        "
	even

TEXT_SIZE:=	(Combi.end_infotext-Combi.infotext)

;--------------------------------------------------------------------------

	bss

	ds.w	1000

Matrix.temp:
	ds.b	Matrix.SIZE

	ds.w	1000

mul_table:
	ds.w	256*256

transformed_object:
	ds.w	1+MAX_VERTICES*3

Stm1.rot_on:
	ds.w	1
Stm1.rot_start:
	ds.w	1

inv_table:
	ds.w	1024

;--------------------------------------------------------------------------
; gigascroll..


Stm1.scroll_on:
	ds.w	1

Combi.asciiconv:
	ds.w	256

; screen pointers
scr_table:
	ds.l	2
vbase:	ds.l	1

hidden_row_index:
	ds.w	1
old_hidden_row_index:
	ds.w	1
base_row_index:
	ds.w	1
old_base_row_index:
	ds.w	1

shift_buf:
	ds.w	FONT_SIZE*8

super_text_pos:
	ds.l	1
scroll_update_speed:
	ds.l	1

word_infotext:
	ds.w	TEXT_SIZE+40
