* Picture displayer
* by James Ingram, 1994
* handles SPEED packed PI1 pics.

	opt	o+,ow-

link	equ	1

	ifnd	link
	opt	x+
	endc


	ifd	link
	OPT	GST,CASE
	
	XREF	file_selector,load_a_file
	XREF	res_mem,rel_mem,print_mes,conin_no_echo
	XREF	dta,search_file,open_file,read_file,close_file
	XREF	super_on,super_off
	XREF	set_dta,search_next
	endc


	include aes_defs.i
	include	lens.i


	include	proghead.s

	bsr	init
	
loop:
	bsr	display_menu
	bsr	get_option
	bsr	process_option
	bra	loop


init:
* set dta
	move.l	#dta,a0
	bsr	set_dta

* wipe all the pictures...
	move.l	#pictures,a0
	move.w	#256-1,d0

wipe:
	clr.l	(a0)+
	dbra	d0,wipe


	move.l	#screen,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,scrn_addr
	sub.l	#34,d0
	move.l	d0,unpack_addr
	rts

init_scrn:
* mouse off
	dc.w	$a00a

* store old palette
	bsr	super_on
	movem.l	$ffff8240.w,d0-7
	movem.l	d0-7,old_pal

	bsr	super_off

* store old res
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7

	move.w	d0,old_res

* store screen address
	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,old_scrn

	moveq	#-1,d0
	move.l	scrn_addr,d1
	bsr	set_scrn
	rts

set_scrn:
	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	rts

rest_scrn:
	move.w	old_res,d0
	move.l	old_scrn,d1
	bsr	set_scrn

	bsr	super_on
	movem.l	old_pal,d0-7
	movem.l	d0-7,$ffff8240.w
	bsr	super_off

* mouse on
	dc.w	$a009
	rts





quitter:
	clr.w	-(a7)
	trap	#1

display_menu:
	lea	menu(pc),a0
	bsr	print_mes

	rts

get_option:
	bsr	accept_option
	bsr	pos_inval_opt
*	bsr	val_opt
	rts

accept_option:
	sf	opt_valid
	bsr	conin_no_echo
	move.l	d0,option
	rts

pos_inval_opt:
	bsr	validate_option
.while:
	tst.b	opt_valid
	beq.s	.end_while

	bsr	accept_option
	bra.s	.while

.end_while:
	rts


validate_option:
* validate the option
	move.l	option,d0
	swap	d0

* was a command issued (Function key?)
	cmp.w	#$3b,d0
	blt.s	.not_command

	cmp.w	#$44,d0
	bgt.s	.not_command

* yup!
	sub.b	#$3b,d0
	add.b	#"1",d0

	cmp.b	#":",d0
	bne.s	.not_10

	move.b	#"0",d0
.not_10:

	move.w	#"F ",d1
	move.b	d0,d1
	move.w	d1,key
	rts

.not_command:
	move.w	d0,key
	rts

process_option:
	moveq	#0,d0
	move.w	key,d0
	cmp.w	#"F0",d0
	beq	quitter

	cmp.w	#"F1",d0
	beq	load_a_pic

	cmp.w	#"F2",d0
	beq	auto_load

	move.w	d0,next_pic

	bsr	init_scrn

	st	disp_loop
.while:
	tst.b	disp_loop
	beq.s	.end_while

	bsr	pic_req
	bra.s	.while

.end_while:
	bsr	rest_scrn
	rts

pic_req:
* picture requested....
* does it exist?

	moveq	#0,d0
	move.w	next_pic,d0

	move.l	#pictures,a0
	lsl.w	#2,d0
	add.l	d0,a0

	tst.l	(a0)
	bne.s	.exists

* picture does not exist!
	sf	disp_loop
	rts

.exists:
* display the picture...
	move.w	next_pic,disp_key
	move.l	(a0),a0
	move.l	#"DISP",display_type
	bsr	display_a_pic

	rts

not_packed:
* copy picture to buffer
	move.l	unpack_addr,a1
	move.w	#32034/4-1,d0
.copy:
	move.l	(a0)+,(a1)+
	dbra	d0,.copy
	bra	pack_rej


display_a_pic:
* address of picture in a0...
* what type of picture is it?

	pea	(a0)

	bsr	super_on
	move.l	(a7),a0

	cmp.l	#"SPv3",(a0)
	bne.s	not_packed

* it is a packed picture!
* depack it...

	move.l	(a7),a0
* first, copy it to the buffer...
	move.l	a0,a1
	move.l	#packed_pic,a2
	move.l	a2,a0

	move.w	#32034/4-1,d0
.copy:
	move.l	(a1)+,(a2)+
	dbra	d0,.copy


	bsr	unpack

pack_rej:
	move.l	unpack_addr,a0
	movem.l	2(a0),d0-7
	movem.l	d0-7,to_pal

* now set up resolution...
	move.w	(a0),d0
	cmp.w	#2,d0
	beq.s	.high_res

	move.b	d0,to_res
	bra.s	.low_res

.high_res:
* it's a high-res picture!
	move.b	#1,to_res
	bsr	conv_high_to_med

.low_res:
	move.l	$70.w,old_70
	move.l	#change_70,$70.w

	bsr	super_off

	move.l	(a7)+,a0

	st	valid_disp_opt
.while:
	tst.b	valid_disp_opt
	beq.s	.end_while

	bsr	get_option
	bsr	process_disp_option
	bra.s	.while

.end_while:
	rts

change_70:
	movem.l	d0-7,-(a7)

	move.b	to_res,$ffff8260.w
	movem.l	to_pal,d0-7
	movem.l	d0-7,$ffff8240.w

	movem.l	(a7)+,d0-7
	move.l	old_70,$70.w
	rte


process_disp_option:
* if F2 is pressed, then cancel any auto-load.
* if any other F key pressed, do nothing
* if <esc> pressed, wipe picture from memory... if it is in memory!
* if <SPACE> pressed, free picture's memory area...
* if any other key pressed, then attempt to store picture

	move.w	key,d0
	lsr.w	#8,d0
	tst.w	d0
	bne	function_key

* not a function key!
	moveq	#0,d0
	move.w	key,d0
	cmp.w	#1,d0
	beq	escape

	cmp.w	#57,d0
	beq	space

* should I be storing or displaying???
	move.l	display_type,d1
	cmp.l	#"LOAD",d1
	beq.s	.storing

* display another picture...
	move.w	key,next_pic
	sf	valid_disp_opt
	rts


.storing:
* store this picture on the key pressed.
	lsl.w	#2,d0
	move.l	#pictures,a0
	add.l	d0,a0

* used already???
	tst.l	(a0)
	bne.s	.used
* no!
	move.l	pic_addr,(a0)

	sf	valid_disp_opt
	rts

.used:
	bsr	super_on

	move.w	#-1,d0
	move.w	#$8240,a0
	move.w	(a0),d7

	move.w	d7,d6
	not.w	d6

.flash:
	move.w	d6,(a0)
	move.w	d7,(a0)
	dbra	d0,.flash
	bsr	super_off

	rts

space:
	move.l	pic_addr,d0
	bsr	rel_mem
	sf	valid_disp_opt
	sf	disp_loop
	rts

escape:
* is this pictured LOADed or is it DISPlayed?
	move.l	display_type,d0
	cmp.l	#"LOAD",d0
	beq.s	loaded_pic

* picture is DISPlayed...
	moveq	#0,d0
	move.w	disp_key,d0
	lsl.w	#2,d0
	move.l	#pictures,a6
	add.l	d0,a6
	move.l	(a6),d0

	bsr	rel_mem
	clr.l	(a6)
	sf	valid_disp_opt
	sf	disp_loop
	rts

loaded_pic:
* picture was LOADed... so treat it as if SPACE were pressed
	sf	valid_disp_opt
	sf	disp_loop
	bra	space

function_key:
* was it F2?
	move.w	key,d0
	cmp.w	#"F2",d0
	beq.s	f2

* no!
	sf	disp_loop

	rts

f2:
	clr.w	auto_flag
	sf	valid_disp_opt
	sf	disp_loop
	bra	space


conv_high_to_med:
	rts

auto_load:
* load pictures 1 by 1 until no more or F2 has been pressed again...

	bsr	init_scrn

	st	auto_flag
	lea	star(pc),a0
	bsr	search_file

	tst.w	d0
	bne.s	.end_while

.while:
	tst.b	auto_flag
	beq.s	.end_while

	move.l	#dta+f_name,a0
	bsr	my_load
	tst.l	d0
	bpl.s	.ok

	sf	auto_flag
	bra.s	.while

.ok:
	move.l	d0,pic_addr

	move.l	pic_addr,a0
	move.l	#"LOAD",display_type
	bsr	display_a_pic
	bsr	search_next
	tst.w	d0
	beq.s	.ok2

	sf	auto_flag
.ok2:

	bra	.while

.end_while:
	bsr	rest_scrn
	rts


my_load:
	move.l	a0,a6

	move.l	dta+f_len,d0
	bsr	res_mem
	tst.l	d0
	bpl.s	.ok

* memory error!
	moveq	#-1,d0
	rts

.ok:
	move.l	a6,a0
	move.l	d0,a6
	bsr	open_file

	move.l	dta+f_len,d0
	move.l	a6,a0
	bsr	read_file
	bsr	close_file

	move.l	a6,d0
	move.l	dta+f_len,d1

	rts


load_a_pic:
	lea	star(pc),a0
	bsr	file_selector

	tst.l	d0
	bpl.s	.ok

	rts

.ok:
	moveq	#0,d0
	bsr	load_a_file
	tst.l	d0
	bpl.s	.ok2
	rts

.ok2:
	move.l	d0,pic_addr
	bsr	init_scrn

	move.l	pic_addr,a0
	move.l	#"LOAD",display_type
	bsr	display_a_pic
	bsr	rest_scrn

	rts



	ifnd	link
	include	aes_shel.s
	include	bits.s
	include	gem_shel.s
	include	files.s
	endc

* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

unpack:
	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)

	move.l	unpack_addr,a1
	add.l	(a7),a1

	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:
	movem.l	(sp)+,d0-a6

	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032


my_pal:
	dc.w	$000
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff


menu:
	dc.b	27,"E"
	dc.b	"ShowPic V1.0",10,13,10
	dc.b	"F1  = load a picture",10,13
	dc.b	"F2  = autoloader",10,13
	dc.b	"F10 = QUIT",10,13,10
	dc.b	"Press key whilst picture shown to store",10,13
	dc.b	"Press SPACE to skip picture",10,13
	dc.b	"Press ESC whilst picture shown to wipe",10,13
	dc.b	10
	dc.b	"Border flashes on and off = key taken",10,13
	dc.b	0

star	dc.b	"*.PI?",0

quit	dc.b	0
opt_valid	dc.b	0
valid_disp_opt	dc.b	0
disp_loop	dc.b	0
	even

	section	bss

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512


key	ds.w	1


option	ds.l	1
command	ds.l	1

pictures	ds.l	256
scrn_addr	ds.l	1
pic_addr	ds.l	1
unpack_addr	ds.l	1


	ds.b	5000
stack:

.pal	ds.b	34
screen	ds.b	256
	ds.b	32000
	ds.b	32


old_scrn:
	ds.l	1
old_pal:
	ds.b	32
old_res:
	ds.w	1

display_type:
	ds.l	1		; LOADED or DISPlayed from keyboard

disp_key:
	ds.w	1		; key displayed picture is attached to
next_pic	ds.w	1	; key for next pic to display

auto_flag:	ds.w	1	; auto-load flag

packed_pic:
	ds.b	33000


old_70:
	ds.l	1
to_res	ds.w	1
to_pal	ds.b	32

	