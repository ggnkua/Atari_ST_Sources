
	ttl	'Mouse limiting demo'

	include	gemmacro.i

;Box co-ordinate definitions

x1	equ	80	left edge
x2	equ	240	right edge
y1	equ	50	top edge
y2	equ	150	bottom edge

;The program proper

start_of_pgm	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	appl_init		initialise application
	move	d0,ap_id	and store the app ident
	graf_handle		fetch graf handle code
	move	d0,current_handle  and store VDI handle

	lea	intin,a0	initialise intin array
	moveq	#10-1,d0	
shell1	move	#1,(a0)+	most params are 1
	dbra	d0,shell1
	move	#2,(a0)+	use RC system
	v_opnvwk		open work station
	v_hide_c		hide mouse
	v_clrwk		clr screen
	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1


shell2	bsr	main	run main program


	v_show_c	#0	show mouse
shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm


;---- Main program sub-routine ----

main	

;Intercept mouse position vector
;and save in (old_vector)
;Install new code at 'new_posn'


	vex_motv	#new_posn	
	move.l	contrl+18,old_vector

;Draw box limits on screen just
;so we can see where they are.

	move	#x1,ptsin	set up box co-ords
	move	#y1,ptsin+2
	move	#x2,ptsin+4
	move	#y1,ptsin+6
	move	#x2,ptsin+8
	move	#y2,ptsin+10
	move	#x1,ptsin+12
	move	#y2,ptsin+14
	move	#x1,ptsin+16
	move	#y1,ptsin+18
	v_pline	#5		& draw box

;Display a message on screen

	v_gtext	#30,#190,#message
		
	v_show_c	#0	show mouse cursor

;Main program loop (could be evnt_mult)

loop1	vq_mouse		test button
	tst	intout
	beq	loop1		loop till pressed

;Restore original vector when we
;exit program.

	vex_motv	old_vector	restore vector

	rts			exit program

message	dc.b	'Press either mouse button to exit.',0
	even
	

;Routine which monitors mouse co-ords
;and changes them if mouse pointer
;wanders into box area.

;Mouse position check routine
;ENTRY d0=x co-ord from mouse
;      d1=y co-ord from mouse
;      (x_store)=last x co-ord
;      (y_store)=last y co-ord
;EXIT  d0=x co-ord passed to GEM
;      d1=y co-ord passed to GEM
;      (x_store)=new x co-ord
;      (y_store)=new y co-ord

new_posn	cmp	#x1,d0	exit if d0<x1
	blt	new_posn1
	cmp	#x2,d0	exit if d0>x2
	bgt	new_posn1
	
	cmp	#y1,d1	exit if d1<y1
	blt	new_posn1
	cmp	#y2,d1	exit if d1>y2
	bgt	new_posn1
	
	move	x_store,d0  restore last x co-ord
	move	y_store,d1  restore last y co-ord
new_posn1	move	d0,x_store  save current x co-ord
	move	d1,y_store  save current y co-ord
	rts


	SECTION	data	global constants

;Fixed data (look-up tables, messages, etc) go in here
	
	SECTION	bss	temporary data

old_vector	ds.l	1	vector address store
x_store	ds.w	1	x co-ord store
y_store	ds.w	1	y co-ord store



ap_id	ds.w 	1	application ident

	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

	include	aeslib.s
	include	vdilib.s
