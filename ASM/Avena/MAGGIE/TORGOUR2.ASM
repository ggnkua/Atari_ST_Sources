; TORGOUR2.ASM

; (C) 1995,6 Steve Tattersall


; 5.5.95  Moving on to the gouraud..... oooh
;	_Kludge_ normals buffer is 3* as big as it should really be
;	visiblity rout should really be fixed to allow 1* offsets,
;	not 3*



; Equates:
maximum_points		EQU	256
maximum_object_size	EQU	4000
maximum_polys		EQU	256






	include	'f:\dsp_new\asm\base.asm'

; Setup:
	org p:$210
	movep #>0,x:<<BCR
	movep #>1,x:<<PBC
	andi #$fc,MR
	jsr get_one_over

looptest	macro text,label
	move #"\text",x0
	cmp x0,a
	jeq \label
	endm

;-------------------------------------------------------
main_loop
	clr a
	wait_receive
	movep x:<<hrx,a1	;Receive control word

; Comparisons:
	looptest	COL,receive_colours
	looptest	OBJ,receive_object
	looptest	LIG,get_light
	looptest	MAT,get_rotation
	looptest	CAL,calc_object
	looptest	HAN,handle_object
	looptest	RTS,exit
	jmp main_loop

exit	rts
;-------------------------------------------------------

















;-------------------------------------------------------
;
;
;	calc_object
;
;	(Carried out during screen clearing)
;
;-------------------------------------------------------
calc_object:
	jsr rotate_points
	jsr rotate_gour_normals
	jsr calc_visibility
	jmp main_loop










;-------------------------------------------------------
;
;
;	handle_object
;
;
;
;-------------------------------------------------------
; Note: DO loop for main section not possible

handle_object:
	move y:torus_object+1,n0		;+1 number of polygons
	move #polygon_list,r6			;unsorted list!!!
	move #visible_buffer,r1

	move y:torus_object+1,a
	do n0,_polygon_loop

_get_polygon_loop:
	  move y:(r6)+,r4

	 ;move y:(r5)+n5,x0
	  move y:(r1)+,a
	  tst a
	  jlt _poly_invisible

	  rep #2
	    move (r4)+				;ignore in,out,colour

	  move #gour_normals_buffer+0,r5
	  move y:(r4)+,x1
	  move #rotated_buffer+1,r2
	  move #rec_poly,r0
	  move y:(r4)+,n1
	  move x1,x:polygon_colour
	  move n1,x:polygon_points

	  do n1,_get_point
	    move y:(r4)+,n2	;fetch vertex offset
	    nop
	    move n2,n5
	    lua (r2)+n2,r3
	    move y:(r5+n5),x1	;fetch gouraud normal value

	    move y:(r3)+,x0	; organize to x,y buffers for speed!
	    move x0,y:(r0)+	;copy x
	    move y:(r3)+,x0
	    move x0,y:(r0)+	;copy y
	    move x1,y:(r0)+	;copy gouraud shade
_get_point:

	move r1,x:save_r1
	;move r5,x:save_r5
	move r6,x:save_r6
	jsr scan_converter
	move x:save_r6,r6
	;move x:save_r5,r5
	move x:save_r1,r1
_poly_invisible:
	nop
_polygon_loop:

; Signify finished:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	wait_transmit
	move #"END",x0
	movep x0,x:<<htx
	jmp main_loop














;-------------------------------------------------------
;
;
;
;	ScanConverter
;
;
;
;-------------------------------------------------------
scan_converter
	jsr set_up_scan_1
	move #>1,x0
	cmp x0,a
	jlt _poly_offscreen

	move #left_array,r0		;x values
	move #right_array,r1
	move #>2,x0
	jsr convert_scan

	jsr set_up_scan_2		;gouraud values
	move #left_array+1,r0
	move #right_array+1,r1
	move #>2,x0
	jsr convert_scan

	jsr send_gouraud_poly

_poly_offscreen
	rts


;---------------------------------------------------------------------
; set_up_scan_1:
; This rout simply copies x and y points from rec_poly
;   _twice_ to scan_poly. It also gets the limits.
;   Final version will be adaptable for diff data structures.
;   Also add optimizations with pipelining (when I get the book)
;   Routine avoids use of modulo registers!

set_up_scan_1:
	move #rec_poly,r4
	clr a
	move #scan_poly,r0	;r0 - first copy of poly
	move x:polygon_points,a1
	asl a		r0,b
	add a,b	
	move b,r1		;r1 - second copy of poly
	move #>800,x0		;x0 minimum
	move #>-800,x1		;x1 maxmimum
	clr a
	move x:polygon_points,n6
	move #2,n4
; The checking routine _appears_ to operate OK

;-----------LIMITS LOOP-----------------
	do n6,setup_loop_1
	   move r0,r5
	   move y:(r4)+,a	;get and
	   move a1,y:(r0)+	;store x (no checking)
	   move a1,y:(r1)+
	   move y:(r4)+n4,a	;get y, skip the gouraud
	   move a1,y:(r0)+	;store y
	   move a1,y:(r1)+	;ignore gouraud
	   cmp x0,a		;new minumum?
	   jge scan_not_min
	     move a1,x0
	     move r5,r2		;r2 = addr of min point
scan_not_min:
	   cmp x1,a		;new maximum?
	   jle scan_not_max
	     move a1,x1
scan_not_max:
;-------------------------------------
	   nop
setup_loop_1:
	move x1,a			; x1 = max y
	sub x0,a			; x0 = min y
	move x0,x:top_height
	move a,x:polygon_height
	move r2,x:top_address
	rts




;---------------------------------------------------------------------
set_up_scan_2:
	move #rec_poly+2,r4	;only need the gourauds....
	clr a
	move #scan_poly,r0	;r0 - first copy of poly (change 'x' values)
	move x:polygon_points,a1
	asl a		r0,b
	add a,b	
	move b,r1		;r1 - second copy of poly
	clr a
	move x:polygon_points,n6
	move #3,n4
	move #2,n0
	move #2,n1

;-----------LIMITS LOOP-----------------
	do n6,setup_loop_2
	   move y:(r4)+n4,a1	;fetch gour val
	   move a1,y:(r0)+n0	;store it
	   move a1,y:(r1)+n1
setup_loop_2:
	rts













;---------------------------------------
send_gouraud_poly:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #"POL",x0
	wait_transmit
	movep x0,x:<<htx	; send signal

	move x:top_height,x0
	move x0,n0
	wait_transmit
	movep x0,x:<<htx	; send minimum y
	move x:polygon_height,x0
	move x0,n6
	wait_transmit
	movep x0,x:<<htx	; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2
	clr a
	move #gouraud_colours+64,a0
	move #>(128/2),y0
	move x:polygon_colour,x0
	mac x0,y0,a
	move a0,r3

	move #>64,y0
; The actual 'draw' Loop
;---------------------------------------
	do n6,scan_send_sides

	   wait_transmit
	  move x:(r0)+,x0
	  movep x0,x:<<htx	;send left value
	  move x:(r1)+,a
	  sub x0,a	    x:(r0)+,x0
	   wait_transmit
	  movep a1,x:<<htx	;send width
	  move x:(r1)+,x1
	  tst a
	  jle _failed		;"next!"

	  move a,n2		;n2 = the width
	  move x1,a1
	  sub x0,a
	  move a1,x1
; x1 offset value
; Size it:
	  move x:(r2+n2),y1
	  mpy y1,x1,a
	  move a,x1

	  mpy x0,y0,a		;a - start val
	  mpy x1,y0,b		;b - add val
	  move a1,n3

	;-----------------------
	  do n2,_plot_loop
	    add b,a	a1,n3
	    wait_transmit
	    movep x:(r3+n3),x:<<htx
_plot_loop:
_failed
	  nop
	;-----------------------
scan_send_sides:
;---------------------------------------

	rts			;adieu

























;-------------------------------------------------------
;
;
;
;	Rotation Routines
;
;
;
;-------------------------------------------------------

rotate_gour_normals:
; First rotate the unit vector:
	move #light_matrix,r2
	move #unit_vector,r6
	move r6,r5
	move r6,r4
	move #unit_store,r1

	move #-1,m1
	move #-1,m4
	move #-1,m5
	move #-1,m6

		 move	x:(r2)+,x0 y:(r4)+,y0
	mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	macr y0,x0,a				;z coord
	move a,x:(r1)+
		 move	x:(r2)+,x0 y:(r5)+,y0
	mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	macr y0,x0,a				;x coord
	move a,x:(r1)+
		 move	x:(r2)+,x0 y:(r6)+,y0
	mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	macr y0,x0,a				;y coord
 	move a,x:(r1)+

; Right, now rotate the 3*1 matrix and do a dot product
;    with my unit_store vector
	move #torus_object,r0
	move #7,n0			;+7, gouraud_offset
	nop
	move y:(r0+n0),r6
	move y:(r0),n6			;+0, number_of_points

	move r6,r5
	move r6,r4

	move #-1,m2
	move #matrix,r2
	move #gour_normals_buffer+0,r0
	move #3,n0			;skip data (kludge)

	;-------------------
	do n6,_spin
	  	   move	x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a
	  move a,x1				;x1 - z coord
	  	   move	x:(r2)+,x0 y:(r5)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a
	  move a,y1				;y1 - x coord
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  move #unit_store,r1

	  macr y0,x0,a
	  move a,y0				;y0 - y coord
; Now compare with dot prod:
	  	   move x:(r1)+,x0
	  mpy x0,x1,b	x:(r1)+,x0
	  mac x0,y1,b	x:(r1)+,x0
	  macr x0,y0,b

	  move #matrix,r2
	  move b,y:(r0)+n0
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts





















;-------------------------------------------------------
;
;
;
;	Small SubRoutines (Usually i/o)
;
;
;
;-------------------------------------------------------
receive_colours
	move #gouraud_colours,r0
	move #-1,m0
	wait_receive
	movep x:<<hrx,n0

	do n0,_get
	  wait_receive
	  movep x:<<hrx,x0
	  move x0,x:(r0)+
_get:
	jmp main_loop

;-------------------------------------------------------
get_light:
	move #cosX,r0
	move #-1,m0
	do #6,_get
	  wait_receive
	  movep x:<<hrx,x0
	  move x0,x:(r0)+
_get:
	move #light_matrix,r2
	jsr calculate_trig
	jmp main_loop


	include	'f:\dsp_new\asm\common.asm'
	include	'f:\dsp_new\asm\scanconv.asm'


;-------------------X MEMORY-----------------------------
		org	x:$1000

cosX			ds	1	;Rotation labels:
sinX			ds	1
cosY			ds	1
sinY			ds	1
cosZ			ds	1
sinZ			ds	1
temp1			ds	1

matrix			ds	9
light_matrix		ds	9
unit_store		ds	3

rotation_points		ds	1

polygon_points		ds	1	;ScanConv labels
scan_offset		ds	1
top_address		ds	1
top_height		ds	1
polygon_height		ds	1
polygon_colour		ds	1
polygon_shade		ds	1

left_array_ptr		ds	1
right_array_ptr		ds	1
array_offset		ds	1

save_r1			ds	1
save_r5			ds	1
save_r6			ds	1
object_address		ds	1

one_over		ds	320
left_array		ds	2*200
right_array		ds	2*200
gouraud_colours		ds	128*2


;-------------------Y MEMORY-----------------------------

		org	y:$1100
unit_vector		dc	0,0,$7fffff
rotated_buffer		ds	3*maximum_points
gour_normals_buffer	ds	3*maximum_points

visible_buffer		ds	maximum_polys
polygon_list		ds	maximum_polys
scan_poly		ds	2*20
rec_poly		ds	3*10
torus_object		ds	maximum_object_size
torus_object_end

