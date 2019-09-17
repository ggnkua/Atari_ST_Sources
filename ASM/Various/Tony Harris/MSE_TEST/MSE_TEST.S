;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Mouse and coordinate checking routines 
;
;	By	Tony Harris.
;	Using	Devpac 2 (yes, I know it's old but I can't afford v3!)
;
;	Ok, this short program just demonstrates how to implement
;	the 'check_coord' macro and the 'check_mouse' routine.
;	they are both fairly straight forward, and can be easily
;	used in any other programs. Remember that the routine
;	'check_xy' belongs to the 'check_coord' macro.
;
;	The program loops until you move/click the mouse over 1 of
;	the 4 boxes supplied on the picture file.
;
;	The uses for such a routine is endless, buttons, sprites etc
;
;	For the sake of the demo, move the mouse into the upper
;	part of the screen before running, as one of the 4 detections
;	is sensitive to the mouse coords! not the buttons. this will
;	prevent you from the possibility of quitting straight away!
;
;	this little routine is not meant to prejudice against hi res
;	users as the routines will work just as well on mono monitors
;	but this program is just to point out the use of the routine.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	opt	x+			xtended debug

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; equates

init_a_line	equ	$a000
show_mouse	equ	$a009
hide_mouse	equ	$a00a
pointer		equ	-$160		used in check_mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_coords	macro

	movem.l	d1-5/a0,-(sp)	save regs

	move.w	#\1,d1		button condition 0,1,2,3
	lea	\2,a0		coord list

	move.w	0(a0),d2	x1
	move.w	2(a0),d3	x2
	move.w	4(a0),d4	y1
	move.w	6(a0),d5	y2

	jsr	check_xy

	movem.l	(sp)+,d1-5/a0	save regs
	endm

; this macro simply checks the current mouse state with your coords

; \1 is what conditions needs to be met
;
;	0 ...	no button needed (will report if mouse is over area)
;	1 ...	left button pressed
;	2 ...	right button pressed
;	3 ...	both together

; \2 is the list of coords to be checked with

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

os_call	macro
	move.w	#\1,-(sp)
	trap	#\2
	lea	\3(sp),sp
	endm

; standard os macro, make life a little easier

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

program_begin
	dc.w	init_a_line			init the a line
	move.l	a0,a_table			save this

	jsr	init_routine			get, set etc

	dc.w	hide_mouse			hide the mouse

	jsr	draw				draw a picture

	dc.w	show_mouse			show mouse again

*-------- main loop start

main_loop
	jsr	check_mouse			get current coords

check_box1
	check_coords	1,box_1			ok, check the first box

	move.w	coord_flag,d0			get results
	beq	check_box2			if failed, check next one
	bra	terminate			if passed, then terminate

check_box2	
	check_coords	2,box_2			now check the second

	move.w	coord_flag,d0			get results
	beq	check_box3
	bra	terminate			if passed, then terminate
check_box3
	check_coords	3,box_3			now check the third

	move.w	coord_flag,d0			get results
	beq	check_box4
	bra	terminate			if passed, then terminate

check_box4
	check_coords	0,box_4			now check the fourth

	move.w	coord_flag,d0			get results
	beq	main_loop
	bra	terminate			if passed, then terminate

*------- main loop end

terminate
	
	jsr	exit_routine			reset stuff

quit	clr.l	-(sp)
	os_call	$4c,1,0				gemdos, pterm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_routine
	os_call	4,14,2				xbios, get_rez
	move.w	d0,old_res			save it
	cmpi.w	#2,d0				is it high?
	beq	quit				quit if so!

	os_call	2,14,2				get screen address
	move.l	d0,screen			save it for later

	dc.w	hide_mouse

	move.w	#0,-(sp)			low res please
	pea	-1
	pea	-1
	os_call	5,14,12				set screen

	move.l	#picture+4,pal_address		locate palette
	jsr	set_pal				and set it

	dc.w	show_mouse

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exit_routine

	dc.w	hide_mouse

	move.w	old_res,-(sp)			save it for later
	pea	-1
	pea	-1
	os_call	5,14,12				set screen
		
	move.l	#gem_pal,pal_address		locate palette
	jsr	set_pal				and set it

	dc.w	show_mouse

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_mouse

	movem.l	a0/a1/a6/d0-2,-(sp)		save regs
	
	move.l	A_Table,a6			pointer to table of values
	lea	pointer(a6),A1

	movem.l	(a1)+,d0-2			get relevent info

	swap	d1				access button
	move.w	d1,button			save result
	move.w	d2,y_coord			save y_coord
	swap	d2				get x_coord
	move.w	d2,x_coord			save it

get_actual_button

	clr.l	d0				clear reg
	move.b	button,d0			load in value
	asl.b	#4,d0
	lsr.b	#4,d0				get actual number
	move.w	d0,button			save it

	movem.l	(sp)+,a0/a1/a6/d0-2		restore regs
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_xy
	move.w	button,d0
	cmp.w	d1,d0			exit on 1 (could be 2 or even 3)
	beq	check_x1
	bra	coord_fail		if you get here, then don't check!
check_x1
	move.w	x_coord,d0			get x_coord
	cmp.w	d2,d0
	bhs	check_x2			is it valid
	bra	coord_fail			branch if not
check_x2
	move.w	x_coord,d0
	cmp.w	d3,d0
	bls	check_y1
	bra	coord_fail
check_y1
	move.w	y_coord,d0
	cmp.w	d4,d0
	bhs	check_y2
	bra	coord_fail
check_y2
	move.w	y_coord,d0
	cmp.w	d5,d0
	bhs	coord_fail

	move.w	#1,coord_flag			its all valid, set the flag
	bra	coord_pass			then pass it
coord_fail
	move.w	#0,coord_flag			coord flag = 0 fail, 1 pass
coord_pass
	rts		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw
	move.l	#picture+128,a0			source (skip header)
	move.l	screen,a1			destination
	
	move.l	#1000-1,d7			set up loop counter
d_loop
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,d_loop
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_pal
	move.l	pal_address,-(sp)		contains address
	os_call	6,14,6				set the palette
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	data

gem_pal		dc.w	$0777,$0700,$0070,$0000,$0111,$0222,$0333,$0444
		dc.w	$0555,$0000,$0001,$0010,$0100,$0200,$0020,$0002

box_1		dc.w	7,131,8,87		X1,X2,Y1,Y2
box_2		dc.w	185,309,8,87
box_3		dc.w	7,131,113,192
box_4		dc.w	185,309,113,192

x_coord		dc.w	0
y_coord		dc.w	0
button		dc.w	0
coord_flag	dc.w	0

old_res		dc.w	0

screen		dc.l	0
pal_address	dc.l	0
A_Table		dc.l	0		Pointer to Line A Table of values

picture		incbin	'picture.neo'
	even

	end

