*********************************************************
*   		Window creation routine			*
* ----------------------------------------------------- *
*	 Programmer: Martyn Armitage			*
*	   Written : 14/08/87				*
*   	   Updated : 14/04/89				*
* Previous updates : 06/04/89				*
* ----------------------------------------------------- *
* Pass Window_type in d0.w				*
* Pass address of Title in a0				*
* Pass total x,y,w,h, in d1-d2.l			*
* If full window req then pass d1-d2.l = 0		*
* Window is created and a Window_handle is returned	*
* in d0.w						*
* Window total coords are returned in d1-d2.l		*
* Window work coords are returned in d3-d4.l		*
* A call to open_wind with wi_handle in d0.w will	*
* put the window on the screen				*
*********************************************************
HSLIDE		equ	2048
RTARROW		equ	1024
LFARROW		equ	512
VSLIDE		equ	256
DNARROW		equ	128
UPARROW		equ	64
SIZE		equ	32
INFO		equ	16
MOVE		equ	8
FULL		equ	4
CLOSE		equ	2
NAME		equ	1

build_window	move.l	a0,title_address(a6) 
		move.l	a1,info_address(a6)
		move.w	d0,window_type(a6)	save window type
		movem.l	d1-d2,wind_x_size(a6) 	save size required
		moveq	#4,d0			d0 = wi_handle/funct id
		bsr	get_wind
		movem.l	d1-d2,scrn_x_coord(a6) 	save screen size
test_w_h	tst.l	wind_w_size(a6) 	is size specified?
		beq.s	size_got		0 = no
get_size	movem.l	wind_x_size(a6),d1-d2	get required size
size_got	move.l	#$00010000,d0
		move.w	window_type(a6),d0	d0 = calc work/wi_type
		bsr	calc_wind
		movem.l d1-d2,wind_x_coord(a6)	save working area
 		moveq	#0,d0
		move.w	window_type(a6),d0		d0 = calc total/wi_type
		bsr	calc_wind
		movem.l	d1-d2,wind_x_total(a6)	save total window area
		move.w	window_type(a6),d0
		bsr	create_wind		create window
		bmi.s	no_windows		no windows left

		tst.l	title_address(a6)	address supplied ?
		bne.s	title_got		yes
		move.l	#null_title,title_address(a6)	

title_got	move.w	d0,window_handle(a6)
		swap	d0
		move.w	#2,d0			set title
		move.l	title_address(a6),d1	get title address
		bsr	set_wind

		move.w	window_type(a6),d0	get type
		btst	#4,d0			info specified ?
		beq.s	no_info_bar		no

		move.l	info_address(a6),d0	get address
		bne.s	info_mssg		address passed
		move.l	#null_title,info_address(a6)

info_mssg	move.w	window_handle(a6),d0
		swap	d0
		move.w	#3,d0			set info
		move.l	info_address(a6),d1	get info address	
		bsr.s	set_wind

no_info_bar	move.w	window_handle(a6),d0	get window handle
		movem.l	wind_x_total(a6),d1-d2	get window size
		movem.l	wind_x_coord(a6),d3-d4	get work area

no_windows	rts				return

get_wind	move.l	d0,int_in(a6)		d0 top = wind_handle
		gem	WIND_GET		d0 btm = function id
		movem.l	int_out+2(a6),d1-d2 	d1 = x/y  d2 = w/h
		rts

get_wind_info	move.w	d0,int_in(a6)		handle
		move.w	d1,int_in+2(a6)		function
		gem	WIND_GET
		movem.w	int_out+2(a6),d0-d3	get coords
		rts

calc_wind	move.l	d0,int_in(a6)		d0 = calc_type/window_type
		movem.l	d1-d2,int_in+4(a6)	d1 = x/y  d2 = w/h
		gem	WIND_CALC
		movem.l	int_out+2(a6),d1-d2	d1 = x/y  d2 = w/h
		rts

create_wind	move.w	d0,int_in(a6)		d0 = window_type
		movem.l	d1-d2,int_in+2(a6)	d1 = x >,y >largest size
		gem	WIND_CREATE		d2 = w >,h >largest size
		rts				d0.w = window_handle

set_wind	move.l	d0,int_in(a6)		d0 = wi_handle,function id
		move.l	d1,int_in+4(a6)		a0 = addrs not always req
		move.l	d2,int_in+8(a6)		d1 = not often used
		gem	WIND_SET
		rts

open_wind	move.w	d0,int_in(a6)		d0 = wi_handle
		movem.l	d1-d2,int_in+2(a6)	d1 = x,y coords
		gem	WIND_OPEN		d2 = w,h of window
		rts	

close_wind	move.w	d0,int_in(a6)		d0 = wi_handle
		gem	WIND_CLOSE
		rts

delete_wind	move.w	d0,int_in(a6)		d0 = wi_handle
		gem	WIND_DELETE
		rts

update_wind	move.w	d0,int_in(a6)		d0 = update type
		gem	WIND_UPDATE
		rts

********************
* Window variables *
********************

window_handle	rs.w	1
window_type	rs.w	1

info_address	rs.l	1	address of info message
title_address	rs.l	1	address of window title
null_title	rs.l	1	no title required

scrn_x_coord	rs.w	1	co-ords of screen
scrn_y_coord	rs.w	1
scrn_w_coord	rs.w	1
scrn_h_coord	rs.w	1

wind_x_size	rs.w	1	co-ords of working area of window required
wind_y_size	rs.w	1
wind_w_size	rs.w	1
wind_h_size	rs.w	1

wind_x_coord	rs.w	1	co-ords of working area of window
wind_y_coord	rs.w	1
wind_w_coord	rs.w	1
wind_h_coord	rs.w	1

wind_x_total	rs.w	1	co-ords of total window size
wind_y_total	rs.w	1
wind_w_total	rs.w	1
wind_h_total	rs.w	1		
