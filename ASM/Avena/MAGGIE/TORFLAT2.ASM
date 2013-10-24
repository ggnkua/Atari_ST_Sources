; TORFLAT2.ASM
; April '95-

; (C) 1995,6 Steve Tattersall


;  - Scan Converter
;  - Matrix + Rotation Routines

; History:
; 22.4 ScanConv appears not to work (FIXED 22.4)
;      Stack bug fixed
;      Pipeline of convert_scan saves wads of time already!
;      Routine looks lightning fast. Is also expandable for gour and
;       mapping routines and 030-free running (I've split it into 3 routs)
;      Rotation and perspective projection routines added

; 3.5  What the hell's wrong??
;      Nothing! All works now, realized no sorting is necessary for
;       tori, everything's blitzschnell and hunkydory. *Grin*





; Equates:

maximum_points		EQU	370
maximum_object_size	EQU	5100
maximum_polys		EQU	370













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
	looptest	OBJ,receive_object
	looptest	MAT,get_rotation
	looptest	CAL,calc_object
	looptest	HAN,handle_object
	looptest	RTS,exit
	jmp main_loop
;-------------------------------------------------------
exit	rts
















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
	jsr rotate_normals
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
	move #normals_buffer,r5			;unsorted normals
	move #visible_buffer,r1
	;jmp skip_handle

	do n0,_polygon_loop

_get_polygon_loop:
	  move y:(r6)+,r4

	  move y:(r5)+,x0			;get the normal anyway
	  move y:(r1)+,a
	  tst a
	  jlt _poly_invisible

	  rep #2
	    move (r4)+				;ignore in,out,colour

	  move y:(r4)+,x1
	  move #rotated_buffer+1,r2
	  move #rec_poly,r0
	  move y:(r4)+,n1
	  move x0,x:polygon_shade
	  move x1,x:polygon_colour
	  move n1,x:polygon_points
; Note: this routine is not very efficient, perhaps copying
;   the poly to scan_poly in one go is quicker?

	  do n1,_get_point
	    move y:(r4)+,n2
	    nop
	    lua (r2)+n2,r3
	    nop
	    move y:(r3)+,x0
	    move x0,y:(r0)+	;copy x
	    move y:(r3)+,x0
	    move x0,y:(r0)+	;copy y
_get_point:
	move r1,x:save_r1
	move r5,x:save_r5
	move r6,x:save_r6
	jsr scan_converter
	move x:save_r6,r6
	move x:save_r5,r5
	move x:save_r1,r1
_poly_invisible:
	nop
_polygon_loop:

; Signify finished:
skip_handle
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #"END",x0
	wait_transmit
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
	jle _poly_offscreen

	move #left_array,r0
	move #right_array,r1
	move #>1,x0
	jsr convert_scan
	jsr send_poly

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
	move x:polygon_points,n0

; The checking routine _appears_ to operate OK

;-----------LIMITS LOOP-----------------
	do n0,setup_loop_1
	   move r0,r5
	   move y:(r4)+,a	;get and
	   move a1,y:(r0)+	;store x (no checking)
	   move a1,y:(r1)+
	   move y:(r4)+,a
	   move a1,y:(r0)+	;store y
	   move a1,y:(r1)+
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



;---------------------------------------
send_poly:

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
	move x0,n0
	wait_transmit
	movep x0,x:<<htx	; send max y - min y

	move x:polygon_colour,x0
	wait_transmit
	movep x0,x:<<htx	; send colour

; This for flat poly:-
	move x:polygon_shade,x0
	wait_transmit
	movep x0,x:<<htx	; send shade value colour

	move #left_array,r0
	move #right_array,r1

	do n0,scan_send_sides
	   wait_transmit
	  move x:(r0)+,x0
	  movep x0,x:<<htx
	   wait_transmit
	  move x:(r1)+,x0
	  movep x0,x:<<htx
scan_send_sides:
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





rotate_normals:
	move #torus_object,r0
	move #4,n0			;+4, normals_offset
	nop
	move y:(r0+n0),r6
	move #1,n0
	move #-1,m6
	
	move y:(r0+n0),n0		;+1, number_of_polys
	move #-1,m6
	move #matrix,r2
	move #-1,m2
	move #normals_buffer,r0

	;-------------------
	do n0,_spin
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a
	  move #matrix,r2
	  move a1,y:(r0)+
_spin:
	;-------------------
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

	include	'f:\dsp_new\asm\common.asm'
	include	'f:\dsp_new\asm\scanconv.asm'



;-------------------X MEMORY-----------------------------
		org	x:$200

cosX			ds	1	;Rotation labels:
sinX			ds	1
cosY			ds	1
sinY			ds	1
cosZ			ds	1
sinZ			ds	1
temp1			ds	1
matrix			ds	9
rotation_points		ds	1

polygon_points		ds	1	;ScanConv labels
scan_offset		ds	1		;??
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

one_over		ds	200
left_array		ds	1*200
right_array		ds	1*200


;-------------------Y MEMORY-----------------------------

		org	y:$800
rotated_buffer		ds	3*maximum_points
normals_buffer		ds	maximum_polys
visible_buffer		ds	maximum_polys
polygon_list		ds	maximum_polys
scan_poly		ds	2*20
rec_poly		ds	2*10
torus_object		ds	maximum_object_size


