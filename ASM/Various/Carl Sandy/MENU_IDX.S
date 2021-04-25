* Menu_idx By Carl Sandy 14/9/90
* This program was written with HiSofts Devpac2
gdos	MACRO
	move.w		#\1,-(a7)
	trap		#1
	lea		\2(a7),a7
	ENDM

	opt x+
	include		gemmacro.s
start	move.l		4(a7),a3
	move.l		#mystack,a7
	move.l		$c(a3),d0
	add.l		$14(a3),d0
	add.l		$1c(a3),d0
	add.l		#$100,d0
	move.l		d0,-(sp)
	move.l		a3,-(sp)
	clr.w		-(sp)
	move.w		#$4a,-(sp)
	trap		#1
	lea		12(sp),sp
	appl_init
	move.w		d0,ap_id

	bsr		str_2_buff
	fsel_input	#pbuff,#fname
	cmpi.w		#0,int_out+2
	beq		quit2

	clr.w		-(a7)
	move.l		#fname,-(a7)
	gdos		$4E,8
	tst.w		d0
	bmi		error

	rsrc_load	#fname
	rsrc_gaddr	#0,#0
	move.l		addr_out,menu_addrs

	graf_mouse	#0
	menu_bar	menu_addrs,#1

waitforevent
	move.l		#messagebuf,addr_in
	evnt_multi	#17,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	cmpi.w		#16,int_out
	beq		handle_menu
	cmpi.w		#1,int_out
	beq		quit
	bra		waitforevent

** MENU Routines
handle_menu
	move.l		#messagebuf,a0
	move.w		(a0),d0
	cmp.w		#10,d0
	beq		display_idx
	bra		waitforevent
display_idx
	move.w		6(a0),menu_idx
	move.w		8(a0),smenu_idx

	clr.l		d6
	move.w		menu_idx,d6
	bsr		inascii
	move.l		#hundrd,a5
	move.l		#m_idx,a6
	bsr		stuff_alrt

	clr.l		d6
	move.w		smenu_idx,d6
	bsr		inascii
	move.l		#hundrd,a5
	move.l		#sm_idx,a6
	bsr		stuff_alrt

	form_alert	#1,#idx_alrt
	menu_tnormal	menu_addrs,menu_idx,#1
	bra		waitforevent
** END OF MENU ROUTINES

** KEYBOARD Routines
error	form_alert	#1,#error_alrt
	bra		quit2
quit	form_alert	#2,#quit_alrt
	cmpi.w		#2,int_out
	beq		waitforevent
quit2	menu_bar	menu_addrs,#0
	appl_exit
	clr.w	-(a7)
	move.w	#$4c,-(a7)
	trap	#1
** END OF KEYBOARD ROUTINES

** MISCELLANEOUS ROUTINES
str_2_buff
	move.l		#pname,a5
	move.l		#pbuff,a6
.loop	cmpi.b		#0,(a5)
	beq		.exit
	move.b		(a5)+,(a6)+
	bra		.loop
.exit	rts

stuff_alrt
.loop	cmpi.b		#0,(a5)
	beq		.exit
	move.b		(a5)+,(a6)+
	bra		.loop
.exit	rts

inascii	clr.l		d5
	move.w		d6,d5
	cmpi.b		#99,d6
	bhi		three
	move.b		#' ',hundrd
two	divu.w		#10,d6
	move.b		d6,tens
	clr.b		d6
	swap		d6
	move.b		d6,units
	cmpi.w		#9,d5
	bhi		abrt
	bra		abrt
three	move.b		#'1',hundrd
	subi.b		#100,d6
	bra		two
abrt	addi.b		#48,tens
	addi.b		#48,units
	rts
** END OF MISCELLANEOUS ROUTINES

	SECTION	DATA
pname		dc.b	'A:\*.RSC',0
fname		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0
quit_alrt	dc.b	'[2][Do You want to Quit?]'
		dc.b	'[  YES  |   NO   ]',0
error_alrt	dc.b	'[1][FILE Not Found][  QUIT  ]',0
idx_alrt	dc.b	'[1][Menu index='
m_idx		dc.b	' 00|'
		dc.b	'Sub-Menu index='
sm_idx		dc.b	' 00]'
		dc.b	'[    OK    ]',0
hundrd		dc.b	' '
tens		dc.b	' '
units		dc.b	' ',0

	SECTION	BSS
ap_id		ds.w	1
messagebuf	ds.b	16
		ds.l	100
mystack		ds.w	1
pbuff		ds.b	68
		even
menu_addrs	ds.l	1
menu_idx	ds.w	1
smenu_idx	ds.w	1

	IFEQ	__LK
	include	aeslib.s
	ENDC