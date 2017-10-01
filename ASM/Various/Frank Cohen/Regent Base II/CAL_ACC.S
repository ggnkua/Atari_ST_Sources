	section	text
*	nolist
	opt	a+

dostart	lea	mystack,a7
	
**** do appl_init
	move.l	#appl_init,aespb
	bsr	gem
	move.w	intout,ap_id
**** GRAF_Handle
	move.l	#graf_handle,aespb
	bsr	gem
	move.w	intout,current_handle
*
**** open virtual workstation

virtual	bsr	clear_control
	move.w	#100,control
	move.w	#11,control+6
	move.w	current_handle,control+12
	move.w	#1,d2		value to store in successive words
	move.w	#9,d3		number of words to store-1
	lea	intin,a2	where to store them
.vloop	move.w	d2,(a2)+
	dbra	d3,.vloop
	move.w	#2,intin+20
	bsr	vdi		call the vdi subroutine

*	move.l	#graf_mouse,aespb
*	clr.w	intin
*	bsr	gem
	

******
* get character sizes
******
	bsr	clear_control
	move.w	#38,control
	bsr	vdi
	move.l	ptsout+4,d3 *char_width
	addq.w	#1,d3		add 1 to char height
	move.l	d3,char_width

******	
***** close virtual workstation
******

*	bsr	clear_control
*	move.w	#101,control
*	bsr	vdi

*****
* get system date....month and year only
*****

	move.w	#$2a,-(sp)
	trap	#1
	addq.l	#2,sp
	lsr.l	#5,d0
	move.l	d0,d1
	andi.w	#$f,d1
	subq.w	#1,d1
	mulu	#90,d1
	move.w	d1,h_slide		save month as horizontal slider position
	lsr.l	#4,d0
	add.w	#180,d0
	move.w	d0,v_slide		save year as vertical slider position

*
* ready to start the program
* first, determine the size of the window 
*
	clr.l	d6
	clr.l	d5
	move.w	box_width,d6
	mulu	#27,d6	       *27 chars wide
	move.w	d6,window_width    *interior width of window
	asr.w	#1,d6       *take 1/2 of width as offset
	move.w	d6,d7
	move.w	box_height,d5
	mulu	#9,d5		*nine lines high
	addq.l	#4,d5
	move.w	d5,window_height   *interior window height
	asr.w	#1,d5               *take 1/2 of height as offset
	move.w	d5,d4
	move.w	d4,centery
rez_size	move.l	#wind_get,aespb
	move.w      #4,intin+2         *field command for total size of window
	clr.w       intin              *window zero, screen
	bsr         gem
	
figure	move.w      intout+6,d6	       *window width
	move.w      intout+8,d5        *window height
	asr.w       #1,d6              *half window width
	move.w	d6,center	       *save window x center
	asr.w       #1,d5              *half window height
	sub.w       d7,d6              *interior x-coordinate of window
	sub.w       d4,d5   	       *interior y-coordinate of window
	move.w      d6,inner_x
	move.w      d5,inner_y
	add.w	char_height,d5
	move.w	d5,line1
	move.w	d5,current_line
	
calc_wind	move.l	#wind_calc,aespb
	clr.w       intin		calculate outer dimensions
	move.w	field,intin+2	window attributes
	move.w	inner_x,intin+4	inner x start point
	move.w	inner_y,intin+6	inner y start point
	move.w	window_width,intin+8	inner width
	move.w	window_height,intin+10	inner height
	bsr	gem
	move.w	intout+2,outer_x
	move.w	intout+4,outer_y
	move.w	intout+6,out_width
	move.w	intout+8,out_height

************************************************
	move.w	ap_id,intin
	move.l	#acc_name,addrin
	move.l	#menu_register,aespb
	bsr	gem
	move.w	intout,menu_id

wait	move.l	#message_buf,addrin
	move.l	#evnt_mesag,aespb
	bsr	gem
	
	lea	message_buf,a4
	move.w	(a4),d6

	tst.w	active
	bne	test_event
	
	cmp.w	#40,d6
	bne	wait
	
	move.w	8(a4),d5
	cmp.w	menu_id,d5
	bne	wait
	
	move.w	#1,active		ours was called, show it active and open window
	bra	create_w	


test_event	cmp.w	#41,d6
	bne	w_test
	move.w	6(a4),d5
	cmp.w	menu_id,d5
	bne	w_test
	clr.w	active
	move.w	#-1,w_handle
	bra	wait
	

* was window moved?

w_test	cmp.w	#28,d6
	beq	move_window
	
* Redraw?

	cmp.w	#20,d6
	beq	redraw
	
	
* was window topped?
	
	cmp.w	#21,d6
	beq	topped

* was close button hit?

	cmp.w	#22,d6
	beq	close	yep...close everything

* was horizontal slider moved?

	cmp.w	#25,d6
	beq	hor_slide	yep...do slider routine

* was vertical slider moved?

	cmp.w	#26,d6
	beq	ver_slide	yep..do slider routine

* was window arrowed?	

	cmp.w	#24,d6
	bne	wait	nope, wait for another message

* window was arrowed.....see what happened
	
	clr.l	d5
	move.w	8(a4),d5
	lea	arrowed,a3
	mulu	#4,d5
	add.l	d5,a3
	move.l	(a3),a3
	jmp	(a3)


topped	move.w	6(a4),intin
	move.l	#wind_set,aespb
	move.w	#10,intin+2
	bsr	gem
	bra	wait
	
***********************************
** redraw by walking the rectangle list
***********************************

redraw	move.w	6(a4),hand
	move.l	#wind_update,aespb
	move.w	#1,intin
	bsr	gem		block user input
	
	move.w	hand,intin
	move.w	#11,intin+2
	bsr	get_window
	
	bsr	clip
	bsr	calc_year
	bsr	cls		clear screen and put up info
	
redraw_next
	move.w	#12,intin+2
	bsr	get_window
	tst.w	intout+6
	beq	chk_height
do_rect	bsr	clip
	bsr	cls
	bra	redraw_next
chk_height	tst.w	intout+8
	bne	do_rect
	
	clr.w	intin
	move.l	#wind_update,aespb
	bsr	gem
	bra	wait
	

********** create window

create_w	move.l	#wind_create,aespb
	move.w	field,intin
	move.w	outer_x,intin+2
	move.w	outer_y,intin+4
	move.w	out_width,intin+6
	move.w	out_height,intin+8
	bsr	gem
	move.w	intout,w_handle

	move.l	#wind_name,intin+4
	move.w	#2,intin+2
	move.w	w_handle,intin
	move.l	#wind_set,aespb
	bsr	gem
	
	
********* open window

	move.l	#form_dial,aespb
	lea	intin,a3
	move.w	#1,(a3)+
	move.w	center,(a3)+
	move.w	centery,(a3)+
	clr.l	(a3)+
	move.w	outer_x,(a3)+
	move.w	outer_y,(a3)+
	move.w	out_width,(a3)+
	move.w	out_height,(a3)+
	bsr	gem
	
	
o_window	move.l	#wind_open,aespb
	move.w	w_handle,intin
	move.w	outer_x,intin+2
	move.w	outer_y,intin+4
	move.w	out_width,intin+6
	move.w	out_height,intin+8
	bsr	gem		*open the window

***** set the sliders

	move.l	#wind_set,aespb
	move.w	w_handle,intin
	move.w	#1,intin+4
	move.w	#16,intin+2
	bsr	gem		*sets vertical slider size (=1)
	move.w	#15,intin+2
	bsr	gem		*sets horizontal slider size
	
	move.w	#9,intin+2
	move.w	v_slide,intin+4
	bsr	gem		*sets position of vertical slider

	move.w	#8,intin+2
	move.w	h_slide,intin+4
	bsr	gem		*sets horizontal slider position
	
	bra	wait

***** calculate the year itself

calc_year	move.l	#wind_get,aespb
	move.w	w_handle,intin
	move.w	#8,intin+2
	bsr	gem		*get the position of the horizontal slider
	move.w	intout+2,h_slide
	
	move.w	#9,intin+2
	bsr	gem
	move.w	intout+2,v_slide	*get position of vertical slider
	
	
figure_start_day
	clr.l	d7
	move.w	v_slide,d7
	add.w	#1800,d7		*0=1800, so offset by that amount
	move.w	d7,current_year	*save computed year
	move.l	d7,d6
	subq.w	#1,d6		*set for previous occurances
	divu	#400,d6		*determine # of leap centuries have passed
	subq.w	#4,d6		*4 have already passed as of 1800
	move.w	d6,leap_centuries	*store number of leap centuries
	move.l	d7,d6		*reset year
	subq.w	#1,d6		*set for previous occurrances
	divu	#100,d6		*# of centuries that have passes
	sub.w	#18,d6		*18 have already passed
	move.w	d6,non_leap_centuries   *total number of centuries...will be offset by leap centuries later
	move.l	d7,d6
	subq.w	#1,d6
	lsr.w	#2,d6		*see how many leap years have passed
	sub.w	#450,d6		*number that have passed as of 1800
	move.w	d6,leap_years
	move.w	#29,month_length+2	consider each year as a leap year
	move.l	d7,d6
	divu	#400,d6
	swap	d6
	tst.w	d6 		comparison made here
	beq	l_set
	move.l	d7,d6
	divu	#100,d6
	swap	d6
	tst.w	d6
	beq	l_cleared		if year/100=int(year/100), it ain't a leap year
	move.l	d7,d6
	divu	#4,d6		see if this is a leap year
	swap	d6
	tst.w	d6		comparison here...if no remainder, leap year
	beq	l_set
l_cleared	move.w	#28,month_length+2	reset Feb length if no leap year
l_set	move.l	d7,d6			
	sub.w	#1800,d6
	mulu	#365,d6		number of days that have passed since 1800
	divu	#7,d6		get offset of straight 365 day years
	swap	d6
	add.w	leap_centuries,d6	add 1 day for each leap century
	add.w	leap_years,d6	add 1 day for each leap year
	add.w	#3,d6		add 3, since 1800 started on day #3 (Wednesday)
	sub.w	non_leap_centuries,d6	subtract number of leap years added that shouldn't have been
	and.l	#$FFFF,d6		clear upper word of register...set up for division
	divu	#7,d6
	swap	d6
	move.w	d6,year_start	d6 low byte contains day# of start of yer
		
	
new_month	lea	month_length,a2	pointer to length of month buffer
	lea	month_start,a3	pointer to buffer for starting day of month
	move.w	year_start,(a3)	initialize January to date determined in above calculation
	move.l	#10,d3		counter register...continues til d3=-1
month_loop	clr.l	d4		start off with cleared register
	move.w	(a3)+,d4		get starting day of previous month and increment pointer
	add.w	(a2)+,d4		add # of days in month
	divu	#7,d4		determine # of weeks..remainder=day of week month starts on
	swap	d4		remainder where we can get to it
	move.w	d4,(a3)		store day start in buffer at appropriate place
	dbra	d3,month_loop	continue til all months done
	
**** determine which month to display

disp_month	move.l	#wind_get,aespb
	move.w	w_handle,intin
	move.w	#8,intin+2
	bsr	gem		determine slider position
	
	clr.l	d6
	move.w	intout+2,d6
	divu	#90,d6		1000/11=90, so d6 low byte will return month #-1
	and.l	#$ff,d6		only take integer amount
	asl.w	#1,d6		multiply by 2 for word offset
	move.l	d6,d5		copy answer to d5
	asl.w	#1,d5		d5=longword offset from start of list
	
	lea	month_add,a0
	move.l	(a0,d5.w),month_text_address	store starting address of month text
	lea	month_length,a0
	move.w	(a0,d6.w),number_days	store # of days in month
	lea	month_start,a0
	move.w	(a0,d6.w),start_day	store starting day

	rts
	
****************
** display the calendar
****************
cls	dc.w	$a00a	hide mouse
	
display	bsr	clear_control
	move.w	#23,control
	move.w	#1,control+6
	move.w	#0,intin
	bsr	vdi

	bsr	clear_control
	move.w	#114,control
	move.w	#2,control+2
	bsr	vdi		draw filled rectangle		
	
	bsr	clear_control
	clr.l	d6
	move.w	current_year,d6
	bsr	bin_asc
	
	lea	ascii_buf,a4
	move.l	#4,d4
	bsr	set_text		set text in top line of window
	move.w	line1,ptsin+2
	move.w	line1,current_line
	bsr	center_text
	move.w	#8,control
	move.w	#1,control+2
	bsr	vdi		write it to the screen
	move.w	char_height,d2
	add.w	d2,current_line     *go to next line
	
d_monthname	move.l	month_text_address,a4
	move.b	(a4)+,d4		get length of month text
	bsr	set_text		set text in intin array
	bsr	center_text
	move.w	current_line,ptsin+2
	bsr	vdi		write it to screen
	move.w	char_height,d2
	add.w	d2,current_line     *go to next line
	
	lea	days,a4
	move.b	(a4)+,d4
	bsr	set_text
	move.w	current_line,ptsin+2
	move.w	inner_x,ptsin
	bsr	vdi
	move.w	char_height,d2
	add.w	d2,current_line     *go to next line

******************
** display individual days
******************

	move.l	#1,d6
	
day_loop	clr.l	d5
	cmp.w	#7,start_day
	bne	day_ok
	move.w	char_height,d2
	add.w	d2,current_line     *go to next line
	clr.w	start_day
day_ok	move.w	start_day,d5
	mulu	#4,d5		character offset of day
	addq.w	#1,d5
	mulu	char_width,d5	pixel offset of day
	add.w	inner_x,d5		start of box
	lea	ascii_buf+3,a4
	moveq.l	#2,d4		length of string
	cmp.w	#9,d6 
	ble	no_cor
	moveq.w	#2,d4		length of string=2
	move.w	char_width,d3
	lsr.w	#1,d3
	sub.w	d3,d5
	lea	ascii_buf+2,a4
no_cor	move.w	d5,ptsin		save x position of where to write day
	move.w	current_line,ptsin+2
	bsr	bin_asc		convert the number to ascii
	bsr	set_text
	move.w	#8,control
	move.w	#1,control+2

	bsr	vdi
	addq.w	#1,start_day
	addq.w	#1,d6
	cmp.w	number_days,d6
	ble	day_loop
	dc.w	$A009	show mouse

	rts
	
*******************************************
* set clipping
	
clip	bsr	clear_control
	move.w	#129,control
	move.w	#2,control+2
	move.w	#1,control+6

	movem.l	intout+2,d0-d1
	move.l	d0,ptsin
	add.l	d0,d1
	subq.w	#1,d1
	swap	d1
	subq.w	#1,d1
	swap	d1
	move.l	d1,ptsin+4
	
*	move.w	inner_x,d3
*	move.w	d3,ptsin
*	add.w	window_width,d3
*	subq.w	#1,d3
*	move.w	d3,ptsin+4
*	move.w	inner_y,d3
*	move.w	d3,ptsin+2
*	add.w	window_height,d3
*	subq.w	#1,d3
*	move.w	d3,ptsin+6

	move.w	#1,intin		clipping ON
	bsr	vdi		set clipping rectangle

	rts	

*************************************

page_up	move.w	v_slide,d6
	sub.w	#10,d6
page_up1	bpl	.ok
	clr.w	d6
.ok	move.w	d6,v_slide
	bra	set_window
	

page_down	move.w	v_slide,d6
	add.w	#10,d6
page_down1	cmp.w	#1000,d6
	ble	.ok
	move.w	#1000,d6
.ok	move.w	d6,v_slide
	bra	set_window
	

line_up	move.w	v_slide,d6
	subq.w	#1,d6
	bra	page_up1


line_down	move.w	v_slide,d6
	addq.w	#1,d6
	bra	page_down1
	
page_left	move.w	h_slide,d6
	beq	.not_ok
	sub.w	#90,d6
.not_ok	move.w	d6,h_slide
	bra	set_window
	
page_right	move.w	h_slide,d6
	add.w	#90,d6
	cmp.w	#1000,d6
	bhs	.not_ok
	move.w	d6,h_slide
.not_ok	bra	set_window

	
hor_slide	move.w	8(a4),d6
	and.l	#$FFFF,d6
	divu	#90,d6
	and.l	#$FFFF,d6
	mulu	#90,d6
	move.w	d6,h_slide
	bra	set_window
	
ver_slide	move.w	8(a4),d6
	move.w	d6,v_slide
	bra	set_window
	
move_window	movem.l	message_buf+8,d0-d1	load d0 and d1 with window values
	movem.l	d0-d1,intin+4
	movem.l	d0-d1,outer_x
	
*	lea	message_buf+8,a3
*	lea	intin+4,a4
*	move.w	(a3),outer_x
*	move.w	(a3)+,(a4)+
*	move.w	(a3),outer_y
*	move.w	(a3)+,(a4)+
*	move.w	(a3),out_width
*	move.w	(a3)+,(a4)+
*	move.w	(a3),out_height
*	move.w	(a3)+,(a4)+

	move.w	#1,intin
	move.w	field,intin+2
	move.l	#wind_calc,aespb
	bsr	gem
	
	move.w	intout+2,inner_x
	move.w	intout+4,inner_y
	move.w	intout+6,window_width
	move.w	intout+8,window_height
	
	move.w	window_width,d3
	lsr.w	#1,d3
	add.w	inner_x,d3
	move.w	d3,center
	
	move.w	window_height,d3
	lsr.w	#1,d3
	add.w	inner_y,d3
	move.w	d3,centery
	
	move.w	inner_y,d3
	add.w	char_height,d3
	move.w	d3,line1
	
	move.w	w_handle,intin
	move.w	#5,intin+2
	move.l	#wind_set,aespb
	bsr	gem
	bra	wait
	
***********************
	
set_window	move.l	#wind_set,aespb
	move.w	w_handle,intin
	move.w	#8,intin+2
	move.w	h_slide,intin+4
	bsr	gem
	move.w	#9,intin+2
	move.w	v_slide,intin+4
	bsr	gem
	move.w	w_handle,intin
	move.w	#5,intin+2
	move.w	outer_X,intin+4
	move.w	outer_y,intin+6
	move.w	out_width,intin+8
	move.w	out_height,intin+10
	bsr	gem
	bra	redraw

*** window close
	
close	move.l	#wind_close,aespb
	move.w	w_handle,intin
	bsr	gem

	move.l	#form_dial,aespb
	lea	intin,a3
	move.w	#2,(a3)+
	move.w	center,(a3)+
	move.w	centery,(a3)+
	clr.l	(a3)+
	move.w	outer_x,(a3)+
	move.w	outer_y,(a3)+
	move.w	out_width,(a3)+
	move.w	out_height,(a3)
	bsr	gem

*** window delete
	
	move.l	#wind_delete,aespb
	move.w	w_handle,intin
	bsr	gem
	clr.w	active
	move.w	#-1,w_handle
	bra	wait


clear_control
	lea	control,a3
	moveq	#5,d3
.cloop	clr.w	(a3)+
	dbra	d3,.cloop
	rts

gem	move.l	#aespb,d1
	move.w	#200,d0		magic number
	trap	#2
	rts

vdi	move.l	#vdipb,d1
	moveq.l	#$73,d0
	trap	#2
	rts

* set text in intin array....a4 points to text, d4=length

set_text	movem.l	d4-d7/a4-a6,-(sp)
	move.w	d4,control+6	length of text in control(3)
	clr.l	d6
	move.l	d6,d7
	move.l	d6,d5
	lea	intin,a5
	subq.w	#1,d4	adjust length
.set_text	move.b	(a4)+,d6
	move.w	d6,(a5)+
	dbra	d4,.set_text
	movem.l	(a7)+,d4-d7/a4-a6
	rts

* binary to ascii conversion....d6=data to convert


bin_asc	movem.l	d4-d7/a4-a6,-(sp)
	lea	ascii_buf+3,a4
	move.l	#'    ',-3(a4)	clear ascii buffer
.binloop	divu	#10,d6
	swap	d6
	add.w	#$30,d6
	move.b	d6,(a4)
	subq.l	#1,a4
	swap	d6
	and.l	#$FFFF,d6
	bne	.binloop
	movem.l	(sp)+,d4-d7/a4-a6
	rts
	
* figure starting point for text in window

center_text	mulu	char_width,d4	figure pixels needed to display this text
	asr.w	#1,d4		take 1/2 of the length
	move.w	center,d5		x center of window already determined
	sub.w	d4,d5		this is the starting of centered text
	move.w	d5,ptsin		store it for the function call
	rts
	
**********	
	
get_window	move.l	#wind_get,aespb
	move.w	hand,intin
	bsr	gem
	rts
**********	

	section	data

**** data statements....don't add anything above current_handle
	even

arrowed		dc.l	page_up,page_down,line_up,line_down,page_left,page_right,page_left,page_right

wind_name		dc.b	189,"1989 Larry D. Duke",0,0

* GEM LIBRARIES

appl_init 	 	dc.w	10,0,1,0,0
appl_exit		dc.w	19,0,1,0,0

wind_get 		dc.w    	104,2,5,0,0
wind_create 	dc.w    	100,5,1,0,0
wind_set 		dc.w    	105,6,1,0,0
wind_open		dc.w    	101,5,5,0,0
wind_close		dc.w    	102,1,1,0,0
wind_delete 	dc.w    	103,1,1,0,0
wind_update 	dc.w    	107,1,1,0,0
wind_find		dc.w	106,2,1,0,0
wind_calc		dc.w	108,6,5,0,0

graf_handle 	dc.w    	77,0,5,0,0
graf_mouse		dc.w	78,1,1,1,0

evnt_mesag 		dc.w    	23,0,1,1,0

form_dial		dc.w	51,9,1,1,0

menu_register	dc.w	35,1,1,1,0

field		dc.w	%0000111111001011
aespb		dc.l	control,global,intin,intout,addrin,addrout
vdipb		dc.l	control,intin,ptsin,intout,ptsout
month_length	dc.w	31,28,31,30,31,30,31,31,30,31,30,31

days		dc.b	27,'Sun Mon Tue Wed Thu Fri Sat'
january		dc.b	7
		dc.b	'January'
February		dc.b	8
		dc.b	'February'
march		dc.b	5
		dc.b	'March'
april		dc.b	5
		dc.b	'April'
May		dc.b	3
		dc.b	'May'
june		dc.b	4
		dc.b	'June'
july		dc.b	4
		dc.b	'July'
august		dc.b	6
		dc.b	'August'
september		dc.b	9
		dc.b	'September'
october		dc.b	7
		dc.b	'October'
november		dc.b	8
		dc.b	'November'
december		dc.b	8
		dc.b	'December'

acc_name		dc.b	'  Calendar ',0
		even
month_add		dc.l	january,february,march,april,may,june,july,august,september,october,november,december
		
	section	bss

*** bss section
		
		even
		
control		ds.w	30
intin		ds.w	128
ptsin		ds.w	256
intout		ds.w	128
ptsout		ds.w	12
global		ds.w	30
addrout		ds.l	2
addrin		ds.l	2

current_handle	ds.w	1
box_width
char_width		ds.w	1
box_height
char_height		ds.w	1
ap_id		ds.w	1
inner_x		ds.w	1
inner_y		ds.w	1
outer_x		ds.w	1
outer_y		ds.w	1
out_width		ds.w	1
out_height		ds.w	1
window_height	ds.w	1
window_width	ds.w	1
w_handle		ds.w	1
center		ds.w	1
centery		ds.w	1
h_slide		ds.w	1
v_slide		ds.w	1
current_year	ds.w	1
leap_centuries	ds.w	1
non_leap_centuries	ds.w	1
leap_years		ds.w	1
year_start		ds.w	1
number_days		ds.w	1
start_day		ds.w	1
month_text_address	ds.l	1
month_start		ds.w	12
line1		ds.w	1
current_line	ds.w	1
current_day		ds.w	1
ascii_buf		ds.w	2
message_buf		ds.w	8
menu_id		ds.w	1
active		ds.w	1
hand		ds.w	1

		ds.l	256
mystack		ds.l	1
end_bss		ds.w	1