; TORTEX.ASM

; (C) 1995,6 Steve Tattersall




; Equates:
maximum_points		EQU	256
maximum_object_size	EQU	4000
maximum_polys		EQU	256











	include	'f:\dsp_new\asm\base.asm'

; Setup:
	org p:$210
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
	looptest	TEX,receive_texmap
	looptest	VER,receive_vertex
	looptest	OBJ,receive_object
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
	  move y:(r1)+,a
	  tst a
	  jlt _poly_invisible

	  rep #2
	    move (r4)+			;ignore in,out,colour

	  move y:(r4)+,x0		;get colour
	  move #texmap_vertices,a0
	move #0,x0			;!!!
	  move #>8/2,y0
	  mac x0,y0,a
	  move a0,r5

	  move #rotated_buffer+1,r2
	  move #rec_poly,r0
	  move y:(r4)+,n1
	  move n1,x:polygon_points

	  do n1,_get_point
	    move y:(r4)+,n2	;fetch vertex offset
	    nop
	    lua (r2)+n2,r3
	    move x:(r5)+,x1

	    move y:(r3)+,x0	; organize to x,y buffers for speed!
	    move x0,y:(r0)+	;copy x
	    move x:(r5)+,x0	y:(r3)+,y0
	    move y0,y:(r0)+	;copy y
	    move x1,y:(r0)+	;texmap val 1
	    move x0,y:(r0)+	;  ""   val 2

_get_point:
	move r1,x:save_r1
	move r6,x:save_r6
	jsr scan_converter
	move x:save_r6,r6
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
	move #>3,x0
	jsr convert_scan

	jsr set_up_scan_2		;tex values #1
	move #left_array+1,r0
	move #right_array+1,r1
	move #>3,x0
	jsr convert_scan

	jsr set_up_scan_3		;tex values #1
	move #left_array+2,r0
	move #right_array+2,r1
	move #>3,x0
	jsr convert_scan

	jsr send_texmap_poly

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
	move #3,n4
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

set_up_scan_3
	move #rec_poly+3,r4
	jmp set_up_general

set_up_scan_2:
	move #rec_poly+2,r4

set_up_general
	clr a
	move #scan_poly,r0	;r0 - first copy of poly (change 'x' values)
	move x:polygon_points,a1
	asl a		r0,b
	add a,b	
	move b,r1		;r1 - second copy of poly
	clr a
	move x:polygon_points,n6
	move #4,n4
	move #2,n0		;BUG #34893849
	move #2,n1

; The checking routine _appears_ to operate OK
;-----------LIMITS LOOP-----------------
	do n6,setup_loop_2
	   move y:(r4)+n4,a1	;fetch gour val
	   move a1,y:(r0)+n0	;store it
	   move a1,y:(r1)+n1
setup_loop_2:
	rts













;---------------------------------------
send_texmap_poly:
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
	move #texmap_buffer,r4
	move #save_buffer,r3

; The actual 'draw' Loop
;---------------------------------------
	do n6,scan_send_sides
	   wait_transmit
	  move x:(r0)+,x0
	  movep x0,x:<<htx	;_send_ left value
	  move x:(r1)+,a
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx	;_send_ width

	  move x:(r0)+,x0	;xtex start
	  move a1,n2		;n2 = counter
	  move x:(r1)+,x1	;xtex end
	  move x:(r0)+,y0	;ytex start
	  move x:(r1)+,b	;ytex end

	  tst a
	  jle _skip_line

	  move x1,a
	  sub y0,b
	  sub x0,a

	  move x:(r2+n2),x1
	  move a,y1
	  mpy x1,y1,a		;parallel moves?
	  move b,y1
	  mpy x1,y1,b

	  move a,x1		;x1 - xaddfrac
	  move x0,a1		;a1  - xfrac
	  move b,x0		;x0 - yaddfrac
	  move y0,a0		;a0  - yfrac
	  move #>64*64,y0	;y0 - multipliers
	  move a1,y1

	  do n2,_send_pixel
	    mpy y0,y1,b		#>%111111000000,y0	;1
	    and y0,b		#>64,y0			;2
	    move a0,y1					;3!
	    mac y0,y1,b		#>64*64,y0		;4
	    add x,a		b1,n4			;5

;for next time. Also acts as pipeliner!
	    move a1,y1					;6
	     wait_transmit
	    movep x:(r4+n4),x:<<htx			;7 (send)
_send_pixel:
_skip_line:

	nop
scan_send_sides:
;---------------------------------------
	rts			;adieu






































;-------------------------------------------------------
;
;
;
;	Small SubRoutines (Usually i/o)
;
;
;
;-------------------------------------------------------
receive_texmap:
	move #texmap_buffer,r0
receive_x:
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
receive_vertex:
	move #texmap_vertices,r0
	jmp receive_x


	include	'f:\dsp_new\asm\common.asm'
	include	'f:\dsp_new\asm\scanconv.asm'


;-------------------X MEMORY-----------------------------
		org	x:$400

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

left_array_ptr		ds	1
right_array_ptr		ds	1
array_offset		ds	1

save_r1			ds	1
save_r5			ds	1
save_r6			ds	1
save_buffer		ds	3	;??

object_address		ds	1
one_over		ds	320

texmap_vertices		ds	16*2

left_array		ds	3*200		;x val, xtex, ytex
right_array		ds	3*200

texmap_buffer:		ds	64*64
texmap_buffer_end
;-------------------Y MEMORY-----------------------------

			org	y:$1100
rotated_buffer		ds	3*maximum_points
visible_buffer		ds	maximum_polys
polygon_list		ds	maximum_polys
scan_poly		ds	2*20
rec_poly		ds	4*10
torus_object		ds	maximum_object_size
torus_object_end

