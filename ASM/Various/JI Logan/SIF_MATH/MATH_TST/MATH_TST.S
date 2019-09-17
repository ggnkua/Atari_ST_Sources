* June 1994
*
* sif maths test programme. Written in Devpac 3.
*
* Used to demonstrate the capabilities of the SIF_MATH.S module.
*
* JI Logan, Belfast City Hospital, Lisburn Road, Belfast BT9 7AB, UK.



	opt	x+	dump long labels for debugging
	opt	a+	automatic PC mode to save bytes

	include	gemmacro.i		HiSoft file
	include	math_tst.i		rsc constants
	include	sif_math.s		math routines


	SECTION TEXT

	bra	start

* macro area

push	macro
	move.\0	\1,-(sp)
	endm

pop	macro
	move.\0	(sp)+,\1
	endm

gemdos	macro	function,tidystack
	push.w	#\1
	trap	#1
	IFGE	8-\2
	addq.l	#\2,a7
	ELSEIF
	lea	\2(a7),a7
	ENDC
	endm

bell	macro
	push.w	#$ff07
	gemdos	$2,4
	endm

select	macro	tree,object
	move.l	\1,a0		tree address
	move.w	\2,d0		object index
	mulu	#objc_size,d0	displacement in tree
	lea	0(a0,d0.l),a0	a0 points to object
	bset	#0,objc_state+1(a0)	set 'select' bit
	endm

deselect	macro	tree,object
	move.l	\1,a0		tree address
	move.w	\2,d0		object index
	mulu	#objc_size,d0	displacement in tree
	lea	0(a0,d0.l),a0	a0 points to object
	bclr	#0,objc_state+1(a0)	clear 'select' bit
	endm

draw	macro			tree,object
	move.l	\1,a0		tree address
	move.w	\2,d0		object index
	bsr	draw.sr
	endm


txt_gaddr	macro		item
	move.l	\1,d4
	bsr	txt_gaddr.sr
	endm


* subroutine area

draw.sr	move.l	a0,addr
	move.w	d0,int
	objc_offset	a0,d0
	move.l	addr,a0
	move.w	int,d0
	mulu	#objc_size,d0	displacement in tree
	lea	0(a0,d0.l),a0	a0 points to object
	graf_mouse	#256
	objc_draw	addr,int,#8,int_out+2,int_out+4,objc_w(a0),objc_h(a0)
	graf_mouse	#257
	rts

txt_gaddr.sr	rsrc_gaddr	#1,d4
	movea.l	addr_out,a5		point to object
	movea.l	objc_spec(a5),a5	point to ted_info
	movea.l	(a5),a5		point to string
	rts



	SECTION BSS

decimout	ds.w	5		word boundry

	SECTION TEXT



dcml_in	move.w	#fracend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#intstart,d5
	bge	.escloop
	move.b	#' ',sign(a5)
	move.b	#'.',dcmlpoint(a5)
	move.w	#intstart,d5
	bra	nxtevnt
hex_in	move.w	#hexend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#hexstart,d5
	bge	.escloop
	move.b	#'.',hexpoint(a5)
	move.w	#hexstart,d5
* wait for key board, left click down or close message
nxtevnt	evnt_multi	#$13,#1,#1,#1,,,,,,,,,,,#mesag_buff,,

* test which event
tst_keybd	btst.b	#0,int_out+1	keyboard event?
	bne	do_keybd
tst_button	btst.b	#1,int_out+1	button event?
	bne	do_button
tst_mesag	btst.b	#4,int_out+1
	bne	do_mesag
	bra	nxtevnt

do_keybd	move.w	int_out+10,d0
	cmpi.b	#'(',d0
	beq	exit
	cmpi.w	#$4800,d0
	beq	.up
	cmpi.w	#$5000,d0
	beq	.down
	cmpi.w	#$4B00,d0
	beq	.left
	cmpi.w	#$4D00,d0
	beq	.right
	cmpi.w	#$6200,d0
	beq	.help
	bra	.tstdcmlhex

.up	move.w	cur_objc,d0
	cmpi.w	#xdcml,d0
	beq	.xdcml
	cmpi.w	#xhex,d0
	bne	nxtevnt
	move.w	#yhex,rtn_objc
	bra	setyhex
.xdcml	move.w	#ydcml,rtn_objc
	bra	setydcml

.down	move.w	cur_objc,d0
	cmpi.w	#yhex,d0
	beq	.yhex
	cmpi.w	#ydcml,d0
	bne	nxtevnt
	move.w	#xdcml,rtn_objc
	bra	setxdcml
.yhex	move.w	#xhex,rtn_objc
	bra	setxhex

.left	move.w	cur_objc,d0
	cmpi.w	#xhex,d0
	beq	.xhex
	cmpi.w	#yhex,d0
	bne	nxtevnt
	move.w	#ydcml,rtn_objc
	bra	setydcml
.xhex	move.w	#xdcml,rtn_objc
	bra	setxdcml

.right	move.w	cur_objc,d0
	cmpi.w	#ydcml,d0
	beq	.ydcml
	cmpi.w	#xdcml,d0
	bne	nxtevnt
	move.w	#xhex,rtn_objc
	bra	setxhex
.ydcml	move.w	#yhex,rtn_objc
	bra	setyhex

.help	form_center	help_addr
	movem.w	int_out+2,d0-3
	movem.w	d0-3,help_x
	form_dial	#0,#0,#0,#0,#0,help_x,help_y,help_w,help_h
	draw	help_addr,#0
	evnt_multi	#$03,#1,#1,#1,,,,,,,,,,,,,
	form_dial	#3,#0,#0,#0,#0,help_x,help_y,help_w,help_h
	draw	form_addr,#0
	bra	nxtevnt

.tstdcmlhex	tst.b	dcmlhex
	bne	hex_input

dcml_input	cmpi.b	#'0',d0
	blt	.tryminus
	cmpi.b	#'9',d0
	ble	.charout
	bra	nxtevnt

.tryminus	cmpi.b	#'-',d0
	bne	.tryplus
	move.b	d0,sign(a5)
	bra	.drawit

.tryplus	cmpi.b	#'+',d0
	bne	.trypoint
	move.b	#' ',sign(a5)
	bra	.drawit

.trypoint	cmpi.b	#'.',d0
	bne	.trycr
.notstart	move.b	#'.',dcmlpoint(a5)
	move.w	#dcmlpoint+1,d5
	bra	.drawit

.trycr	cmpi.b	#13,d0
	bne	.trybs
	move.w	#intstart,d4
.crloop	cmpi.b	#'0',(a5,d4.w)
	blt	.probpoint
	cmpi.b	#'9',(a5,d4.w)
	ble	.notempty
.probpoint	addq.w	#1,d4
	cmpi.w	#fracend,d4
	bgt	nxtevnt
	bra	.crloop
.notempty	bra	.exit

.trybs	cmpi.b	#'/',d0
	bne	.tryesc
	cmpi.w	#intstart,d5
	bgt	.decindex
	move.b	#' ',sign(a5)
	bra	.bsout
.decindex	subq.w	#1,d5
	cmpi.w	#dcmlpoint,d5
	bne	.bsout
	subq.w	#1,d5
.bsout	move.b	#'_',0(a5,d5.w)
	bra	.drawit

.tryesc	cmpi.b	#'*',d0
	bne	nxtevnt
	move.w	#fracend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#intstart,d5
	bge	.escloop
	move.b	#' ',sign(a5)
	move.b	#'.',dcmlpoint(a5)
	move.w	#intstart,d5
	bra	.drawit

.charout	cmpi.w	#dcmlpoint,d5
	bne	.notpoint
	addq.w	#1,d5
.notpoint	cmpi.w	#fracend,d5
	ble	.notend
	move.w	#fracend+1,d5
	bra	nxtevnt
.notend	move.b	d0,0(a5,d5.w)
	addq.w	#1,d5

.drawit	draw	form_addr,cur_objc
	bra	nxtevnt
.exit	rts

hex_input	cmpi.b	#'0',d0
	blt	.trycr
	cmpi.b	#'9',d0
	bgt	.tstalpha
	andi.w	#$03,int_out+8
	beq	.charout
	add.b	#17,d0

.tstalpha	cmpi.b	#'A',d0
	blt	.exit
	cmpi.b	#'F',d0
	ble	.charout

	cmpi.b	#'a',d0
	blt	.exit
	cmpi.b	#'f',d0
	ble	.tocaps
	bra	nxtevnt

.trycr	cmpi.b	#13,d0
	bne	.trybs
	move.w	#hexstart,d5
.crloop	cmpi.b	#'_',(a5,d5.w)
	beq	nxtevnt
	addq.w	#1,d5
	cmpi.w	#hexend,d5
	ble	.crloop
	clr.l	d7
	move.w	#hexstart,d5
.hexloop	move.b	(a5,d5.w),d4
	cmpi.b	#'A',d4
	blt	.digit
	subq.b	#7,d4
.digit	sub.b	#48,d4
	move.l	#$00100000,d6
	bsr	lmul.sr
	add.l	d4,d7
	addq.w	#1,d5
	cmpi.w	#hexpoint,d5
	bne	.notpoint
	addq.w	#1,d5
.notpoint	cmpi.w	#hexend,d5
	ble	.hexloop
	st	int
	bra	.exit

.trybs	cmpi.b	#'/',d0
	bne	.tryesc
	cmpi.w	#hexstart,d5
	ble	.bsout
	subq.w	#1,d5
	cmpi.w	#hexpoint,d5
	bne	.bsout
	subq.w	#1,d5
.bsout	move.b	#'_',0(a5,d5.w)
	bra	.drawit

.tryesc	cmpi.b	#'*',d0
	bne	nxtevnt
	move.w	#hexend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#hexstart,d5
	bge	.escloop
	move.b	#'.',hexpoint(a5)
	move.w	#hexstart,d5
	bra	.drawit

.tocaps	subi.b	#32,d0
.charout	cmpi.w	#hexend,d5
	ble	.notend
	move.w	#hexend+1,d5
	bra	nxtevnt
.notend	cmpi.w	#hexpoint,d5
	bne	.dochar
	addq.w	#1,d5
.dochar	move.b	d0,0(a5,d5.w)
	addq.w	#1,d5

.drawit	draw	form_addr,cur_objc
	bra	nxtevnt
.exit	rts

do_button	objc_find	form_addr,#0,#8,int_out+2,int_out+4
	move.w	int_out,d0
	move.w	d0,rtn_objc
	cmpi.w	#ydcml,d0
	bne	tryyhex
setydcml	moveq.w	#intstart,d5
	move.w	#ydcmlhead,nxt_head
	sf	dcmlhex
	bra	objcfound
tryyhex	cmpi.w	#yhex,d0
	bne	tryxdcml
setyhex	moveq.w	#hexstart,d5
	move.w	#yhexhead,nxt_head
	st	dcmlhex
	bra	objcfound
tryxdcml	cmpi.w	#xdcml,d0
	bne	tryxhex
setxdcml	moveq.w	#intstart,d5
	move.w	#xdcmlhead,nxt_head
	sf	dcmlhex
	bra	objcfound
tryxhex	cmpi.w	#xhex,d0
	bne	noobjc
setxhex	moveq.w	#hexstart,d5
	move.w	#xhexhead,nxt_head
	st	dcmlhex
	bra	objcfound
noobjc	bell
	evnt_button	#1,#1,#0
	bra	nxtevnt
objcfound	deselect	form_addr,cur_head
	draw	form_addr,cur_head
	select	form_addr,nxt_head
	draw	form_addr,nxt_head
	move.w	nxt_head,cur_head
	move.w	rtn_objc,cur_objc
	evnt_button	#1,#1,#0
	addq.l	#4,a7
	bra	nxt_objc

do_mesag	cmp.w	#22,mesag_buff
	beq	exit		close window
	bra	nxtevnt

* programme starts here
start	move.l	4(a7),a0	base page
	move.l	$C(a0),d0	text len
	add.l	$14(a0),d0	data len
	add.l	$1C(a0),d0	BSS len
	add.l	#$100,d0	basepage
	lea	stacktop,a7	set stackpointer
	push.l	d0	push parameters
	push.l	a0
	push.w	#0
	gemdos	$4A,12	shrink memory

* Initialise application and store handle
	appl_init
	move.w	d0,appl_id

* Get VDI handle and store it in gemmac location
	graf_handle
	move.w	d0,current_handle

* Prepare int_in and open virtual workstation
	lea	int_in,a0
	moveq.w	#10-1,d0
.fill	move.w	#1,(a0)+
	dbra	d0,.fill
	move.w	#2,(a0)
	v_opnvwk

* load resource file
	rsrc_load	#rsrc_file
	tst.w	int_out
	bne	rsrc_ok
	form_alert	#1,#rsrc_alert
	bra	abort_1

* get resource form address
rsrc_ok	rsrc_gaddr	#0,#form
	move.l	addr_out,form_addr

* get resource help address
	rsrc_gaddr	#0,#help
	move.l	addr_out,help_addr

* initialise a5, d5 etc
	txt_gaddr	#ydcml
	moveq.w	#intstart,d5
	move.w	#ydcml,cur_objc
	move.w	#ydcmlhead,cur_head
	select	form_addr,cur_head

* mouse off
	graf_mouse	#256

* get form's centred coordinates
	form_center	form_addr
	movem.w	int_out+2,d0-3
	movem.w	d0-3,form_x

* calc outer window size given inner size = form + border
	subq.w	#2,d0
	subq.w	#2,d1
	addq.w	#4,d2
	addq.w	#4,d3
	movem.w	d0-3,work_x
	wind_calc	#0,wind_bits,d0,d1,d2,d3
	movem.w	int_out+2,d0-3
	movem.w	d0-3,wind_x

* create window and save handle
	wind_create	wind_bits,d0,d1,d2,d3
	move.w	d0,wind_id

* set title in move bar
	move.l	#wind_title,int_in+4
	wind_set	wind_id,#2

* open window
	wind_open	wind_id,wind_x,wind_y,wind_w,wind_h

* set style solid and colour white
	vsf_interior #1
	vsf_color	#0

* get window work and convert to vdi
	movem.w	work_x,d0-3
	add.w	d0,d2
	subq.w	#1,d2
	add.w	d1,d3
	subq.w	#1,d3
	vr_recfl	d0,d1,d2,d3

* draw form using centred coordinates
	form_dial	#0,#0,#0,#0,#0,form_x,form_y,form_w,form_h
	draw	form_addr,#0

* mouse arrow (#0) and on (#257)
	graf_mouse	#0
	graf_mouse	#257

	sf	dcmlhex

	clr.l	yhexnum
	clr.l	xhexnum

nxt_objc	cmpi.w	#ydcml,cur_objc
	beq	do_ydcml
	cmpi.w	#yhex,cur_objc
	beq	do_yhex
	cmpi.w	#xdcml,cur_objc
	beq	do_xdcml
	cmpi.w	#xhex,cur_objc
	beq	do_xhex
	bra	nxt_objc

do_ydcml	txt_gaddr	#ydcml
	bsr	dcml_in
	bsr	dcmltohex
	move.l	d7,yhexnum
	txt_gaddr	#yhex
	bsr	hex_out
	draw	form_addr,#yhex
	txt_gaddr	#ydcmlo
	bsr	hextodcmlo
	draw	form_addr,#ydcmlo
	bsr	maths_out
	bra	nxt_objc

do_yhex	txt_gaddr	#ydcml
	move.w	#fracend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#intstart,d5
	bge	.escloop
	move.b	#' ',sign(a5)
	move.b	#'.',dcmlpoint(a5)
	draw	form_addr,#ydcml
	txt_gaddr	#yhex
	bsr	hex_in
	move.l	d7,yhexnum
	txt_gaddr	#ydcmlo
	bsr	hextodcmlo
	draw	form_addr,#ydcmlo
	bsr	maths_out
	bra	nxt_objc

do_xdcml	txt_gaddr	#xdcml
	bsr	dcml_in
	bsr	dcmltohex
	move.l	d7,xhexnum
	txt_gaddr	#xhex
	bsr	hex_out
	draw	form_addr,#xhex
	txt_gaddr	#xdcmlo
	bsr	hextodcmlo
	draw	form_addr,#xdcmlo
	bsr	maths_out
	bra	nxt_objc

do_xhex	txt_gaddr	#xdcml
	move.w	#fracend,d5
.escloop	move.b	#'_',0(a5,d5.w)
	subq.w	#1,d5
	cmpi.w	#intstart,d5
	bge	.escloop
	move.b	#' ',sign(a5)
	move.b	#'.',dcmlpoint(a5)
	draw	form_addr,#xdcml
	txt_gaddr	#xhex
	bsr	hex_in
	move.l	d7,xhexnum
	txt_gaddr	#xdcmlo
	bsr	hextodcmlo
	draw	form_addr,#xdcmlo
	bsr	maths_out
	bra	nxt_objc

dcmltohex	move.w	#intstart,d5
	clr.l	d0
.intloop	move.b	(a5,d5.w),d4
	cmpi.b	#'_',d4
	beq	.notint
	cmpi.b	#'.',d4
	beq	.endint
	sub.b	#'0',d4
	mulu	#10,d0
	add.w	d4,d0
.notint	add.w	#1,d5
	bra	.intloop
.endint	cmp.l	#$00008000,d0
	bge	.overflow
	clr.l	d7
	move.l	#fracend,d5
.fracloop	clr.l	d4
	move.b	(a5,d5.w),d4
	cmp.b	#'_',d4
	beq	.notfrac
	cmp.b	#'.',d4
	beq	.endfrac
	sub.b	#'0',d4
	swap	d4
	add.l	d4,d7
	move.l	#$000A0000,d6
	bsr	ldiv.sr
.notfrac	sub.w	#1,d5
	bra	.fracloop
.endfrac	swap	d0
	add.l	d0,d7
	cmp.l	#$80000000,d7
	beq	.exit
.dosign	move.b	sign(a5),d4
	cmpi.b	#'-',d4
	bne	.exit
	neg.l	d7
	bra	.exit
.overflow	move.l	#$80000000,d7
.exit	rts


hex_out	move.w	#hexstart,d5
	cmp.l	#$80000000,d7
	beq	.overflow
.nexthex	rol.l	#4,d7
	move.w	d7,d4
	andi.b	#$000F,d4
	cmpi.b	#$A,d4
	bge	.notdcml
	add.b	#'0',d4
	bra	.hexout
.notdcml	add.b	#55,d4
.hexout	move.b	d4,(a5,d5.w)
	add.w	#1,d5
	cmpi.w	#hexpoint,d5
	bne	.notpoint
	add.w	#1,d5
.notpoint	cmpi.w	#hexend,d5
	ble	.nexthex
	bra	.exit
.overflow	move.b	#'_',(a5,d5.w)
	addq.w	#1,d5
	cmpi.w	#hexend,d5
	ble	.overflow
	move.b	#'.',hexpoint(a5)
.exit	rts

hextodcmlo	move.l	d7,d6		get value
	bmi	.neg
	move.b	#' ',sign(a5)	number is positive
	bra	.cont
.neg	neg.l	d6		negate value
	bmi	.overflow		branch infinity
	move.b	#'-',sign(a5)	number is negative
	move.l	d6,d7		store positive value
.cont	move.w	#intend,d5
	clr.w	d6
	swap	d6		get int part
.intloop	divu	#10,d6		remainder in hi d5
	swap	d6
	add.b	#$30,d6		make ascii
	move.b	d6,(a5,d5.w)	store ascii
	clr.w	d6
	swap	d6
	subq.w	#1,d5
	cmpi.w	#intstart,d5
	bge	.intloop		next integer digit
.endint	clr.l	d6
	move.w	d7,d6		get frac
	move.w	#fracstart,d5	point to lsf
.fracloop	mulu	#10,d6
	swap	d6		get fraction
	add.b	#$30,d6		make ascii
	move.b	d6,(a5,d5.w)	save fraction
	clr.w	d6
	swap	d6
	addq.w	#1,d5
	cmpi.w	#fracend,d5
	ble	.fracloop
	bra	.exit
.overflow	move.w	#intstart,d5
.overfloop	move.b	#'_',(a5,d5.w)
	addq.w	#1,d5
	cmpi.w	#fracend,d5
	ble	.overfloop
	move.b	#' ',sign(a5)
	move.b	#'.',dcmlpoint(a5)
.exit	rts

maths_out	load	yhexnum
	ladd	xhexnum
	txt_gaddr	#yaddx
	bsr	hextodcmlo
	draw	form_addr,#yaddx

	load	yhexnum
	lsub	xhexnum
	txt_gaddr	#ysubx
	bsr	hextodcmlo
	draw	form_addr,#ysubx

	load	yhexnum
	lmul	xhexnum
	txt_gaddr	#ymulx
	bsr	hextodcmlo
	draw	form_addr,#ymulx

	load	yhexnum
	ldiv	xhexnum
	txt_gaddr	#ydivx
	bsr	hextodcmlo
	draw	form_addr,#ydivx

	load	yhexnum
	root2
	txt_gaddr	#rooty
	bsr	hextodcmlo
	draw	form_addr,#rooty

	load	yhexnum
	log10
	txt_gaddr	#log10y
	bsr	hextodcmlo
	draw	form_addr,#log10y

	load	yhexnum
	log2
	txt_gaddr	#log2y
	bsr	hextodcmlo
	draw	form_addr,#log2y

	load	yhexnum
	alog2
	txt_gaddr	#alog2y
	bsr	hextodcmlo
	draw	form_addr,#alog2y

	load	yhexnum
	power	xhexnum
	txt_gaddr	#ypowerx
	bsr	hextodcmlo
	draw	form_addr,#ypowerx

	rts


* delete form
exit	movem.w	form_x,d4-d7
	form_dial	#3,#0,#0,#0,#0,d4,d5,d6,d7

* close window and delete it
	wind_close	wind_id
	wind_delete	wind_id

* free up resources
abort_1	rsrc_free

* close virtual workstation
	v_clsvwk

* exit application
	appl_exit

* terminate GEM
	push.w	#0
	gemdos	$4c,4

	SECTION	DATA

rsrc_file	dc.b	'MATH_TST.RSC',0
rsrc_alert	dc.b	'[3][Resource file missing][Quit]',0

wind_bits	dc.w	%0000000000000011  	close,title

wind_title	dc.b	'  Sign_Integer_Fraction 32-bit Maths  ',0

sign	equ	0
intstart	equ	1
intend	equ	5
dcmlpoint	equ	6
fracstart	equ	7
fracend	equ	12
hexstart	equ	2
hexpoint	equ	6
hexend	equ	10



	SECTION	BSS

* these have to remain together to be referenced by movem.w or move.l
wind_x	ds.w	1	* window frame
wind_y	ds.w 	1	*
wind_w	ds.w	1	*
wind_h	ds.w	1	*

work_x	ds.w	1	* workow work
work_y	ds.w 	1	*
work_w	ds.w	1	*
work_h	ds.w	1	*

form_addr	ds.l	1	resource form address

form_x	ds.w	1	* form coordinates
form_y	ds.w 	1	*
form_w	ds.w	1	*
form_h	ds.w	1	*

help_addr	ds.l	1	resource help address

help_x	ds.w	1	* help coordinates
help_y	ds.w 	1	*
help_w	ds.w	1	*
help_h	ds.w	1	*



appl_id	ds.w	1	application number
wind_id	ds.w	1	aes window number

cur_objc	ds.w	1
rtn_objc	ds.w	1
cur_head	ds.w	1
nxt_head	ds.w	1
dcmlhex	ds.b	1
yhexnum	ds.l	1
xhexnum	ds.l	1
addr	ds.l	1
int	ds.w	1

mesag_buff	ds.w	16	area for messages

stacklow	ds.w	10	lower overrun
stack	ds.w	299	stack area
stacktop	ds.w	1	stack start
stackhigh	ds.w	10	upper overrun


	rsreset

objc_next	rs.w	1
objc_head	rs.w	1
objc_tail	rs.w	1
objc_type	rs.w	1
objc_flags	rs.w	1
objc_state	rs.w	1
objc_spec	rs.l	1
objc_x	rs.w	1
objc_y	rs.w	1
objc_w	rs.w	1
objc_h	rs.w	1
objc_size	rs.w	0


* if not linking then include the run-times

	IFEQ	__LK
	include	aeslib.s
	include	vdilib.s
	ENDC
