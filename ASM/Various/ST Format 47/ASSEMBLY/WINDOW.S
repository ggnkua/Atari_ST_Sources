*If you are running Devpac2, you may need to rename gemmacro.i
*to gemmacro.s, or alter the include  gemmacro.i directive below
*The IFD __G2 directive will assemble everything following it
*until an ELSE or ENDC if you are using Devpac, otherwise
*everything between ELSE and ENDC is assembled 
*make sure your compiler knows where to find the include files
*if in doubt, put everything in the root of A:\, and run
*your compiler from the root of A:\
stacksize	equ	1000
**************************
*window flags list
title_bar	equ	1
close_box	equ	2
full_box	equ	4
mover_bar	equ	8
info_box	equ	16
size_box	equ	32
up_arrow	equ	64
down_arrow	equ	128
vert_slide	equ	256
left_arrow	equ	512
right_arrow	equ	1024
hoz_slide	equ	2048
**************************




	include	gmdosmac.i
	
	IFD	__G2	*this tells us if we are running Devpac
	include	gemmacro.i
	ENDC

	move.l	4(a7),a3
	move.l	#ourstack+(stacksize*2),a7	
	bsr	initialise_program	
	
	bsr	init_aes_vdi
init_ok
WF_WORKXYWH equ 4	
	IFD	__G2
*If you have included gemmacro.i we can call the aes/vdi using the macros
	graf_mouse	#0	
	wind_get	#0,#WF_WORKXYWH	this tells us the work_size of the desktop
	ELSE
*otherwise we have to do it the hard way
**************************************
	move.w	#78,control	graf_mouse
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	clr.w	control+8
	move.w	#0,int_in
	bsr	call_aes

	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	#0,int_in
	move.w	#WF_WORKXYWH,int_in+2
	bsr	call_aes
**************************************
	ENDC
	move.w int_out+2,desktop_x
	move.w	int_out+4,desktop_y
	move.w	int_out+6,desktop_width
	move.w	int_out+8,desktop_height	

	move.w	#-1,window_number	our first window will be no.0	
number_of_windows	equ	2	change if you add more windows
*To add more windows, alter number_of_windows above, and then copy 
*everything between the dotted lines, changing any label containing 
*the number 1 to the appropriate window number
*eg window_flags1 would become window_flags3 for the third window
*----------------------------------------------------------------------
*
*try different combinations from the window flags list
*at the top of the listing
window_flags1	equ	title_bar+close_box+full_box+info_box+mover_bar+size_box

	DATA	*You can put data sections anywhere in your listing
		*as long as you use TEXT when returning to text

title_string1 dc.b ' STFormat proudly presents ',0
info_string1	dc.b	'Window 1',0
x_offset1	equ	10	the start x position relative to max size
y_offset1	equ	10	the start y position relative to max size
w_offset1	equ	-20	the start width relative to max size
h_offset1	equ	-20	the start height relative to max size
	TEXT
	move.w	#window_flags1,d0
	movem.w	desktop_x,d1-d4
	move.w	window_number,d5
	addq.w	#1,d5
	move.w	d5,window_number
	move.l	#initial_co_ords,a5
	move.w	d5,d6
	mulu.w	#8,d6	
	move.w	#x_offset1,x_coord(a5,d6.w)
	move.w	#y_offset1,y_coord(a5,d6.w)	
	move.w	#w_offset1,width(a5,d6.w)	
	move.w	#h_offset1,height(a5,d6.w)	

	move.l	#title_string1,a3
*	lea	0,a3	use this line instead of the previous line
			*if you don't want a title bar message
	move.l	#info_string1,a4
*	lea	0,a4	use this line instead of the previous line
			*if you don't want an info line message
	bsr	open_sesame

*----------------------------------------------------------------------

window_flags2	equ	title_bar+close_box+full_box+info_box+mover_bar+size_box
	DATA
title_string2 dc.b ' Two GEM windows ',0
info_string2	dc.b	'Window 2',0
x_offset2	equ	64	the start x position relative to max size
y_offset2	equ	64	the start y position relative to max size
w_offset2	equ	-128	the start width relative to max size
h_offset2	equ	-128	the start height relative to max size
	TEXT
	move.w	#window_flags2,d0
	movem.w	desktop_x,d1-d4
	move.w	window_number,d5
	addq.w	#1,d5
	move.w	d5,window_number
	move.l	#initial_co_ords,a5
	move.w	d5,d6
	mulu.w	#8,d6	
	move.w	#x_offset2,x_coord(a5,d6.w)
	move.w	#y_offset2,y_coord(a5,d6.w)	
	move.w	#w_offset2,width(a5,d6.w)	
	move.w	#h_offset2,height(a5,d6.w)	

	move.l	#title_string2,a3
*	lea	0,a3	use this line instead of the previous line
			*if you don't want a title bar message
	move.l	#info_string2,a4
*	lea	0,a4	use this line instead of the previous line
			*if you don't want an info line message
	bsr	open_sesame
	move.w	#number_of_windows-1,d7
each_window
	move.w	d7,-(sp)
	bsr	main_loop
	move.w	(sp)+,d7
	dbra	d7,each_window
*finish off	
	IFD	__G2
	v_clsvwk	close the virtual workstation
	appl_exit	tell the AES we're finished
	ELSE
	move.w	#101,contrl	v_clsvwk	
	clr.w	contrl1
	clr.w	contrl3
	move.w	current_handle,contrl6
	bsr	call_vdi
	
	move.w	#19,control	appl_exit
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	Pterm	#0	and quit
	
************************
	
init_aes_vdi
	IFD	__G2
	appl_init
	ELSE
	move.w	#10,control	appl_init
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	move.w	d0,ap_id
	IFD	__G2
	graf_handle
	ELSE
	move.w	#77,control	graf_handle
	move.w	#0,control+2
	move.w	#5,control+4
	move.w	#0,control+6
	move.w	#0,control+8
	bsr	call_aes
	ENDC
	move.w	d0,current_handle
	lea	intin,a0
	moveq	#10-1,d0	for dbra		
set_params
	move.w	#1,(a0)+
	dbf	d0,set_params
	move.w	#2,(a0)+

	IFD	__G2
	v_opnvwk			open a virtual workstation
	ELSE
	move.w	#100,contrl	v_opnvwk
	move.w	#0,contrl1
	move.w	#11,contrl3
	move.w	current_handle,contrl6
	bsr	call_vdi
	move.w	contrl6,current_handle
	ENDC
	rts


open_sesame
*on entry:-
*d0.w contains window controls flag
*d1-d4.w contain x,y,width and height of window when full size
*d5.w contains number of windows opened, NOT including this one
*a3 contains address of title string or 0 if none
*a4 contains address of info bar string or 0 if none


	move.w	d0,window_flags
	IFD	__G2
	wind_calc	window_flags,#0,d1,d2,d3,d4	want work area
	ELSE
	move.w	#108,control	wind_calc
	move.w	#6,control+2
	move.w	#5,control+4
	move.w	window_flags,int_in
	move.w	#0,int_in+2
	move.w	d1,int_in+4
	move.w	d2,int_in+6
	move.w	d3,int_in+8
	move.w	d4,int_in+10
	bsr	call_aes
	ENDC

	move.l	#max_co_ords,a5
	move.w	d5,d6
	mulu.w	#8,d6	
	movem.w	int_out+2,d1-d4
	movem.w	d1-d4,x_coord(a5,d6)
	IFD	__G2
	wind_create	window_flags,d1,d2,d3,d4
	ELSE
	move.w	#100,control	wind_create
	move.w	#5,control+2
	move.w	#1,control+4
	move.w	window_flags,int_in
	move.w	d1,int_in+2
	move.w	d2,int_in+4
	move.w	d3,int_in+6
	move.w	d4,int_in+8
	bsr	call_aes
	ENDC
	move.w	d0,this_window_h
	move.l	#window_handles,a5
	move.w	d5,d6
	mulu.w	#2,d6		each window handle is .w
	move.w	d0,0(a5,d6.w)	
	
	move.l	a3,int_in+4
	beq	no_title
	IFD	__G2
	wind_set	this_window_h,#2	set title bar
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#2,int_in+2
	bsr	call_aes
	ENDC
no_title
	move.l	a4,int_in+4
	beq	no_info
	IFD	__G2
	wind_set	this_window_h,#3	set info line
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#3,int_in+2
	bsr	call_aes
	ENDC
no_info
	move.w	d5,d6
	mulu.w	#8,d6
	move.l	#max_co_ords,a5
	movem.w	x_coord(a5,d6),d1-d4
	move.l	#initial_co_ords,a5
	move.w	d5,d6
	mulu.w	#8,d6	
	add.w	x_coord(a5,d6.w),d1
	add.w	y_coord(a5,d6.w),d2
	add.w	width(a5,d6.w),d3
	add.w	height(a5,d6.w),d4

	IFD	__G2
	wind_open	this_window_h,d1,d2,d3,d4
	ELSE
	move.w	#101,control	wind_open
	move.w	#5,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	d1,int_in+2
	move.w	d2,int_in+4
	move.w	d3,int_in+6
	move.w	d4,int_in+8
	bsr	call_aes
	ENDC

	
	rts

main_loop
	IFD	__G2
	evnt_mesag	#message_buffer	*use event_multi if you need
				*messages other than window messages
	ELSE
	move.w	#23,control	evnt_mesag
	move.w	#0,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	clr.w	control+8
	move.l	#message_buffer,addr_in
	bsr	call_aes
	
	ENDC
	lea	message_buffer,a0
	move.w	6(a0),d0	get the window handle
	clr.w	d5
	move.l	#window_handles,a5
which_window
	cmp.w	(a5)+,d0
	beq	found_window
	addq.w	#1,d5
	cmp.w	#number_of_windows,d5
	bne	which_window
	bra	main_loop
found_window
	move.w	d0,this_window_h	the relevent window handle
	move.w	(a0),d0			What message?			
	cmp.w	#20,d0			redraw?
	beq	redraw_window
	cmp.w	#21,d0			topped?
	beq	top_me
	cmp.w	#22,d0			closed?
	beq	close_me
	cmp.w	#23,d0			fulled?
	beq	full_me
	cmp.w	#27,d0			resized?
	beq	move_me	
	cmp.w	#28,d0			moved?
	beq	move_me
	bra	main_loop

*window was moved or resized
move_me	
min_width equ 80
min_height equ 100
changedwindow
	move.w	8(a0),int_in+4		new x pos
	move.w	10(a0),int_in+6		new y pos
	move.w	12(a0),d0
	cmp.w	#min_width,d0
	bhs	set_width
	moveq	#min_width,d0		use minimum width
set_width
	move.w	d0,int_in+8		width
	move.w	14(a0),d0
	cmp.w	#min_height,d0
	bhs	set_height
	moveq	#min_height,d0		use minimum height
set_height
	move.w	d0,int_in+10		height

	IFD	__G2
	wind_set	this_window_h,#5
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#5,int_in+2
	bsr	call_aes
	ENDC

	move.l	#max_co_ords,a5
	move.w	d5,d6
	mulu.w	#8,d6
	movem.w	width(a5,d6),d3-d4		old size
	cmp.w	width(a5,d6),d3
	blo	main_loop
	cmp.w	height(a5,d6),d4
	blo	main_loop
	bne	no_redraw_message
	cmp.w	width(a5,d6),d3
	beq	main_loop	
*if the new size is smaller in both directions, the AES won't
*send a redraw message.
no_redraw_message
	bsr	draw_rectangle
	bra	main_loop	


redraw_window
BEG_UPDATE	equ	1 
END_UPDATE	equ	0
WF_FIRSTXYWH	equ	11
WF_NEXTXYWH	equ	12
	IFD	__G2
	wind_update	#BEG_UPDATE	
	wind_get	this_window_h,#WF_FIRSTXYWH
	ELSE
	move.w	#107,control	wind_update
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#BEG_UPDATE,int_in
	bsr	call_aes

	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_FIRSTXYWH,int_in+2
	bsr	call_aes
	ENDC
set_rectangle
	move.w	int_out+6,d0
	or.w	int_out+8,d0	this sets zero flag if int_out+6 and int_out+8 are both 0
	beq	finished_redraw	
	lea	message_buffer,a0
	move.w	int_out+2,d1
	move.w	8(a0),d0
	cmp.w	d1,d0
	bhi	x_in_d0
	move.w	d1,d0
x_in_d0
	move.w	int_out+4,d2
	move.w	10(a0),d1
	cmp.w	d2,d1
	bhi	y_in_d1
	move.w	d2,d1
y_in_d1
	move.w	int_out+2,d3
	add.w	int_out+6,d3
	move.w	8(a0),d2
	add.w	12(a0),d2
	cmp.w	d3,d2
	ble	w_in_d2
	move.w	d3,d2
w_in_d2
	sub.w	d0,d2	clip=width-x
	bhi	there_is_width
	bra	next_rectangle
there_is_width
	move.w	int_out+4,d4
	add.w	int_out+8,d4
	move.w	10(a0),d3
	add.w	14(a0),d3
	cmp.w	d4,d3
	ble	h_in_d3
	move.w	d4,d3
h_in_d3
	sub.w	d1,d3	clip=height-y
	bhi	there_is_height
	bra	next_rectangle
there_is_height
	subq.w	#1,d2
	subq.w	#1,d3
	add.w	d0,d2
	add.w	d1,d3
	IFD	__G2
	vs_clip	#1,d0,d1,d2,d3	clipping on
	ELSE
	move.w	#129,contrl		vs_clip
	move.w	#2,contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	#1,intin
	move.w	d0,ptsin
	move.w	d1,ptsin+2
	move.w	d2,ptsin+4
	move.w	d3,ptsin+6
	bsr	call_vdi
	ENDC
	bsr	draw_rectangle		draw the window
	IFD	__G2
	vs_clip	#0,#0,#0,#0,#0		clipping off
	ELSE
	move.w	#129,contrl		vs_clip
	move.w	#2,contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	#0,intin
	bsr	call_vdi
	ENDC
next_rectangle
	IFD	__G2
	wind_get	this_window_h,#WF_NEXTXYWH
	ELSE
	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_NEXTXYWH,int_in+2
	bsr	call_aes
	ENDC
	bra	set_rectangle	
finished_redraw
	IFD	__G2
	wind_update	#END_UPDATE	
	ELSE
	move.w	#107,control	wind_update
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#END_UPDATE,int_in
	bsr	call_aes
	ENDC
	bra	main_loop
*clip the rectangle
	movem.w	8(a0),d0-d3
	add.w	d0,d2	change from xywh to top left bottom right
	add.w	d1,d3
	IFD	__G2
	vs_clip	#1,d0,d1,d2,d3	clipping on
	ELSE
	move.w	#129,contrl		vs_clip
	move.w	#2,contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	#1,intin
	move.w	d0,ptsin
	move.w	d1,ptsin+2
	move.w	d2,ptsin+4
	move.w	d3,ptsin+6
	bsr	call_vdi
	ENDC

	bsr	draw_rectangle
	bra	main_loop

top_me
WF_TOP equ 10
	IFD	__G2
	wind_set	this_window_h,#WF_TOP
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#WF_TOP,int_in+2
	bsr	call_aes
	ENDC
	bra	main_loop

full_me	
WF_CURRXYWH	equ	5
WF_PREVXYWH	equ	6
WF_FULLXYWH	equ	7
	IFD	__G2
	wind_get	this_window_h,#WF_CURRXYWH
	ELSE
	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_CURRXYWH,int_in+2
	bsr	call_aes
	ENDC
	movem.w	int_out+2,d1-d4
	movem.w	d1-d4,curr_co_ords
	IFD	__G2
	wind_get	this_window_h,#WF_PREVXYWH
	ELSE
	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_PREVXYWH,int_in+2
	bsr	call_aes
	ENDC
	movem.w	int_out+2,d1-d4
	movem.w	d1-d4,prev_co_ords
	IFD	__G2
	wind_get	this_window_h,#WF_FULLXYWH
	ELSE
	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_FULLXYWH,int_in+2
	bsr	call_aes
	ENDC
	movem.w	int_out+2,d1-d4

*we need to check if current size is full, and previous wasn't full
*if so, change to previous, else change to full
	move.l	#curr_co_ords,a5
	cmp.w	x_coord(a5),d1
	bne	to_full
	cmp.w	y_coord(a5),d2		
	bne	to_full
	cmp.w	width(a5),d3	
	bne	to_full		
	cmp.w	height(a5),d4
	
	move.l	#prev_co_ords,a5
	cmp.w	x_coord(a5),d1
	bne	to_prev		
	cmp.w	y_coord(a5),d2		
	bne	to_prev		
	cmp.w	width(a5),d3	
	bne	to_prev		
	cmp.w	height(a5),d4	
	bne	to_prev		
	bra	to_full
to_prev	
	movem.w	(a5),d1-d4
	movem.w	d1-d4,int_in+4				tell AES we want previous size
	IFD	__G2
	wind_set	this_window_h,#WF_CURRXYWH	and make current=previous
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#WF_CURRXYWH,int_in+2
	bsr	call_aes
	ENDC
	bsr	draw_rectangle		we have to redraw window, 
					*as GEM won't tell us to 
	bra	main_loop

to_full
	movem.w	d1-d4,int_in+4				tell AES we want full size
	IFD	__G2
	wind_set	this_window_h,#WF_CURRXYWH	and make current=full
	ELSE
	move.w	#105,control	wind_set
	move.w	#6,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	move.w	#WF_CURRXYWH,int_in+2
	bsr	call_aes
	ENDC
	
	bra	main_loop

close_me
	IFD	__G2
	wind_close	this_window_h	close it
	wind_delete	this_window_h	and delete it
	ELSE
	move.w	#102,control	wind_close
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	bsr	call_aes

	move.w	#103,control	wind_delete
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	this_window_h,int_in
	bsr	call_aes
	ENDC
	move.l	#window_handles,a5
	move.w	d5,d6
	mulu.w	#2,d6
	move.w	#-1,0(a5,d6)	set the stored handle to -1
	rts
draw_rectangle
	IFD	__G2
	v_hide_c			hide the mouse
	ELSE
	move.w	#123,contrl	v_hide_c
	clr.w	contrl1
	clr.w	contrl3
	move.w	current_handle,contrl6
	bsr	call_vdi
	ENDC
	IFD	__G2
	wind_get	this_window_h,#WF_WORKXYWH
	ELSE
	move.w	#104,control	wind_get
	move.w	#2,control+2
	move.w	#5,control+4
	move.w	this_window_h,int_in
	move.w	#WF_WORKXYWH,int_in+2
	bsr	call_aes
	ENDC
	move.w	int_out+2,rectx
	move.w	int_out+4,recty
	move.w	int_out+6,rectw
	move.w	int_out+8,recth
	IFD	__G2
	vsf_interior	#0
	ELSE
	move.w	#23,contrl	vsf_interior
	move.w	#0,contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	#0,intin
	bsr	call_vdi
	ENDC

	movem.w	rectx,d0-d3
	add.w	d0,d2		change from xywh to top left bottom right
	subq.w	#1,d2
	add.w	d1,d3
	subq.w	#1,d3
	IFD	__G2
	vr_recfl	d0,d1,d2,d3	filled rectangle
	v_show_c	#0		show the mouse
	ELSE
	move.w	#114,contrl		vr_recfl
	move.w	#2,contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	d0,ptsin
	move.w	d1,ptsin+2
	move.w	d2,ptsin+4
	move.w	d3,ptsin+6
	bsr	call_vdi
	
	move.w	#122,contrl	v_show_c
	clr.w	contrl1
	move.w	#1,contrl3
	move.w	current_handle,contrl6
	move.w	#0,intin
	bsr	call_vdi
	ENDC
	rts

initialise_program	
	move.l	$c(a3),d0	*length of text
	add.l	$14(a3),d0	*length of data
	add.l	$1c(a3),d0	*length of BSS
	add.l	#$100,d0	*length of basepage
	Mshrink	d0,a3		*Macro to return unwanted memory
	rts
	IFND	__G2
call_aes
	move.l	#aes_params,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out,d0
	rts

call_vdi
	move.l	#vdi_params,d1
	move.w	#$73,d0
	trap	#2
	rts

	DATA
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out
vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout
	ENDC
	BSS
desktop_x	ds.w	1
desktop_y	ds.w	1
desktop_width	ds.w	1
desktop_height	ds.w	1

rectx	ds.w	1
recty	ds.w	1
rectw	ds.w	1
recth	ds.w	1

	rsreset
x_coord	rs.w	1
y_coord	rs.w	1
width	rs.w	1
height	rs.w	1
initial_co_ords	ds.w	number_of_windows*4	storage for initial  x,y,width,height for each window
max_co_ords	ds.w	number_of_windows*4	storage for x,y,width,height for each window
curr_co_ords	ds.w	4	used to toggle full size
prev_co_ords	ds.w	4	used to toggle full size


window_flags	ds.w	1

this_window_h	ds.w	1
window_handles	ds.w	number_of_windows
window_number	ds.w	1
ap_id		ds.w	1
message_buffer	ds.b	16

ourstack	ds.w	stacksize


	IFD	__G2
	include	aeslib.s
	include	vdilib.s
	ELSE
	
*the AES parameters
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1

*the VDI parameters

current_handle	ds.w	1

contrl		ds.w	1
contrl1		ds.w	1
contrl2		ds.w	1
contrl3		ds.w	1
contrl4		ds.w	1
contrl5		ds.w	1
contrl6		ds.w	1
contrl7		ds.w	1
contrl8		ds.w	1
contrl9		ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1

intin		ds.w	128
intout		ds.w	128
ptsin		ds.w	128
ptsout		ds.w	128

	ENDC

