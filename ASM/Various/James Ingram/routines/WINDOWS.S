* WINDOW shells
*  by James Ingram, July 1993


	ifd	link_library
	MODULE	WINDOWS
	XDEF	get_max_wind_work_size
	XDEF	get_wind_ext_size,get_prev_wind_ext_size,get_max_wind_ext_size
	XDEF	get_wind_hslide,get_wind_vslide,get_top_wind,get_wind_first_rect
	XDEF	get_wind_next_rect,get_wind_hsize,get_wind_vsize,get_wind_buffers
	XDEF	change_wind_kind,change_wind_name,change_wind_info
	XDEF	change_wind_size,change_wind_hslide,change_wind_vslide,change_wind_top
	XDEF	change_desktop_tree,change_wind_hsize,change_wind_vsize
	XDEF	open_window_max_size

	XDEF	create_window,open_window,close_window,delete_window


	XREF	aes
	endc

get_max_wind_work_size:
* enter with handle in d0
	moveq	#4,d1
do_wind_info:
	move.w	#get_window_information,-(a7)
	bsr	aes
	rts

get_wind_ext_size:
* d0 = handle
	moveq	#5,d1
	bra.s	do_wind_info

get_prev_wind_ext_size:
	moveq	#6,d1
	bra.s	do_wind_info


get_max_wind_ext_size:
	moveq	#7,d1
	bra.s	do_wind_info


get_wind_hslide:
	moveq	#8,d1
	bra.s	do_wind_info

get_wind_vslide:
	moveq	#9,d1
	bra.s	do_wind_info


get_top_wind:
	moveq	#10,d1
	bra.s	do_wind_info


get_wind_first_rect:
	moveq	#11,d1
	bra.s	do_wind_info


get_wind_next_rect:
	moveq	#12,d1
	bra.s	do_wind_info


get_wind_hsize:
	moveq	#13,d1
	bra.s	do_wind_info


get_wind_vsize:
	moveq	#14,d1
	bra.s	do_wind_info


get_wind_buffers:
	moveq	#15,d1
	bra.s	do_wind_info


change_wind_kind:
* handle in d0

	moveq	#1,d1
do_wind_change:
	move.w	#change_window_settings,-(a7)
	bsr	aes
	rts


change_wind_name:
* handle in d0
* name in a0
	moveq	#2,d1

do_addr_wind_change:
	move.l	a0,d2
	move.w	d2,d3
	clr.w	d2
	swap	d2
	bra.s	do_wind_change

change_wind_info:
	moveq	#3,d1
	bra.s	do_addr_wind_change

change_wind_size:
	moveq	#5,d1
	bra.s	do_wind_change


change_wind_hslide:
	moveq	#8,d1
	bra.s	do_wind_change

change_wind_vslide:
	moveq	#9,d1
	bra.s	do_wind_change


change_wind_top:
	moveq	#10,d1
	bra.s	do_wind_change


change_desktop_tree:
	moveq	#14,d1
	bra.s	do_addr_wind_change


change_wind_hsize:
	moveq	#15,d1
	bra.s	do_wind_change


change_wind_vsize:
	moveq	#16,d1
	bra.s	do_wind_change



create_window:
* enter with window co-ords in d1-d4
* and type flag in d0 (see p284)

	move.w	#allocate_a_window,-(a7)
	bsr	aes
	rts


open_window:
* enter with window handle in d0
* and co-ords in d1-d4

	move.w	#display_a_window,-(a7)
	bsr	aes
	rts


close_window:
* window handle in d0
	move.w	#erase_a_window,-(a7)
	bsr	aes
	rts


delete_window:
* handle in d0
	move.w	#deallocate_a_window,-(a7)
	bsr	aes
	rts

open_window_max_size:
* enter with d0 = flags for window
* a0 = name addr
* a1 = title addr
*
* RETURNS
*	d0 = window handle or -1 for error

	pea	(a1)
	pea	(a0)
	move.w	d0,-(a7)

	moveq	#0,d0		; handle for desktop
	bsr	get_max_wind_work_size
	movem.w	d1-d4,wind1_co_ords

	movem.w	wind1_co_ords,d1-d4
	move.w	(a7),d0
	bsr	create_window
	move.w	d0,wind_hand

	tst.w	d0
	bmi	wind_create_error

	move.w	(a7),d1
	move.w	d0,-(a7)

	btst	#0,d1
	beq.s	wind_no_name

	move.l	4(a7),a0
	bsr	change_wind_name
wind_no_name:
	move.w	2(a7),d1
	btst	#4,d1
	beq.s	wind_no_info

	move.w	(a7),d0
	move.l	8(a7),a0
	bsr	change_wind_info

wind_no_info:
	move.w	(a7),d0
	movem.w	wind1_co_ords,d1-d4
	bsr	open_window

	move.w	(a7)+,d0	; return window handle
	lea	10(a7),a7
	rts


wind_create_error:
	moveq	#-1,d0
	alert	#1,no_windows
	rts


no_windows:
	exclam
	dc.b	"[Cannot open window!  ]"
	dc.b	"[Cancel]",0
	even


	ifd	link_library
	section	bss
	endc


wind_hand:
	ds.w	1


wind1_co_ords:
	ds.w	4




