
;
;
;
;
;
;
;				avena.
;
;
;
;
;
;
;
;
;
;
;
;
; Core DSP 3D routines v2 August 1996-
;
;	25.4.97		"Mini" version for a 4K intro...
;				There should be lots of areas where I can save memory
;				e.g. BSP tree code, non-sorted objects, command data
;				pre-initialising clipping data, use of built-in sine
;				table etc.
;				Total removal of clipping algorithm by using a big
;				screen????
;
;-------------------X MEMORY-----------------------------
					org	x:$000
temp_x				ds	3				;roll-over buffer!
cosX				ds	1
sinX				ds	1
cosY				ds	1
sinY				ds	1
cosZ				ds	1
sinZ				ds	1
temp1				ds	1
matrix				ds	9
light_matrix		ds	9
unit_store			ds	3
original_polygon_points
					ds	1
polygon_points		ds	1				;ScanConv labels
scan_offset			ds	1				;??
top_address			ds	1
top_height			ds	1
polygon_height		ds	1
polygon_colour		ds	1
polygon_shade		ds	1
current_object		ds	1
left_array_ptr		ds	1
right_array_ptr		ds	1
array_offset		ds	1
point_offset		ds	1

; Clipping:
smallest_z_coord	ds	1
save_r0				ds	1
save_r1				ds	1
save_r4				ds	1
save_r4_again		ds	1
save_r5				ds	1
save_r6				ds	1

file_address		ds	1
object_address		ds	1
;object_type			ds	1
which_poly_routine	ds	1
which_draw_routine	ds	1
current_clipmask	ds	1


poly_to_scan		dc	input_poly

xmin				dc	x_min
xmax				dc	x_max
ymin				dc	y_min
ymax				dc	y_max

visible_poly_count	dc	0

;-------------------------------------------------------

polygon_sort_list	ds	maximum_polys*2

texmap_buffer
				IF	texmap_handler||envmap_handler||@def(shademap_handler)
					ds	64*64
				ENDIF


;-------------------------------------------------------
one_over			ds	385
left_array			ds	5*240
right_array			ds	5*240


;-------------------------------------------------------
				org p:

;-------------------------------------------------------
;
;
;	handle_file
;
;
;
;-------------------------------------------------------
; Note: DO loop for main section not possible?

handle_file:
	clr a
	jsr handle_object

object_finished:
	move #"GET",a			; send finished signal
							; if in true mode
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get
	wait_transmit
	move #-1,x0			; "END"
	movep x0,x:<<htx
	jmp main_loop


handle_one_object:							; could be removed...
	 wait_receive
	movep x:<<hrx,a							;get object #

;-----------------------------------------------------------------
; a = number of object

handle_object:
	move a1,x:current_object

	move x:file_address,r0					;OPTI this could be fixed
	move #>C_Objects,x0						;when object decided upon
	add x0,a
	move a1,n0
	nop
	move y:(r0+n0),a
	move a1,x:object_address

	jsr prepare_object	


;Sorting methods:
; - do a first pass 1, making a list of the *address* of the poly
;     to look up later
;      ___[prepare_poly_address_list]
; - do a first pass 2, checking visibility
;    - dump a list of polygons with the z-coord of the poly and its
;      number. Save the number of visible polys
;     **** Must be in X memory!!! ****
;      ___[prepare_sort_buffer]
;    - sort the list with the general sort routine
;      ___[general_sort]
;    - for each poly, get the poly number, look up the poly address,
;      execute handle_general_polygon


	move	#shade_normals_buffer,r5
;Main Polygon Loop:
	do n0,polygon_loop
; These three will be automatically calculated when sorting added:
	  move y:(r1)+,a
	  move y:(r5)+,x0					;get flat shade
	  move y:(r4)+,n4
	  move y:(r4)+,x1
	  move r4,x:save_r4
	  move n4,x:polygon_points
	  move n4,x:original_polygon_points
	  move x0,x:polygon_shade			;usually unnecessary...
	  tst a
	  jmi _poly_invisible				;

	  move x1,x:polygon_colour
	  move a1,x:current_clipmask
	  move r1,x:save_r1
	  move r5,x:save_r5
		jsr handle_general_polygon
	  move x:save_r1,r1
	  move x:save_r5,r5
_poly_invisible:
	  move x:save_r4,r4
	  move x:original_polygon_points,n4
	  nop
	  lua (r4)+n4,r4					;next polygon
	  nop
polygon_loop:
	rts

handle_general_polygon:
		move #rotated_buffer+0,r2
		move #input_poly,r0
		move r0,x:poly_to_scan
		move x:array_offset,n0
		move #>$7fffff,a				;smallest z coord so far!

		do n4,_receive_point1
			move y:(r4)+,n2			;fetch vertex offset
			nop
			lua (r2)+n2,r3
			nop
			move y:(r3)+,x0			; organize to x,y buffers for speed!
			cmp x0,a				;x0,y:(r0)+	;now *don't* copy z
			tgt x0,a
			move y:(r3)+,x0			;
			move x0,y:(r0)+			;copy x
			move y:(r3)+,x0
			move x0,y:(r0)+n0		;copy y, skip (array_count-1) places
_receive_point1:
		move a,x:smallest_z_coord

; Now get the specialized stuff i.e. gouraud, texmap
		move x:which_poly_routine,r6
		move x:save_r4,r4
		jsr (r6)					;do other collection

		;move x:smallest_z_coord,a
		;tst a
		;jmi z_clip_invalid

		move x:current_clipmask,a
		tst a
		jeq no_x_y_clip

; Check visibility again here???
		jmp handle_x_y_clip			;do anyway for the moment
no_x_y_clip:
x_y_clip_valid:
		jsr scan_convert_all
z_clip_invalid:
x_y_clip_invalid:
	rts


scan_convert_all:
;---------------------------------------------------------------------
; set_up_x_y:
; This rout simply copies x and y points from input_poly
;	 _twice_ to scan_poly. It also gets the limits.

set_up_x_y:
	move x:poly_to_scan,r4
	move x:array_offset,n4
	move #scan_poly,r0		;r0 - first copy of poly
	move x:polygon_points,a		;USE MAC FOR SPEED
	asl a		r0,b
	add a,b	
	move b,r1				;r1 - second copy of poly
	move #>+$7fffff,a		;x0 minimum
	move #>-$800000,b		;x1 maxmimum
	move x:polygon_points,n0
;-----------LIMITS LOOP---------------
	do n0,_setup_loop_1
		 move r0,r5
		 move y:(r4)+,x0		;get and
		 move x0,y:(r0)+		;store x (no checking)
		 move x0,y:(r1)+
		 move y:(r4)+n4,x1		;get y
		 cmp x1,a	x1,y:(r0)+	;new minumum?
		 tge x1,a	r5,r2
		 cmp x1,b	x1,y:(r1)+	;new maximum?
		 tle x1,b
;-------------------------------------
_setup_loop_1:
	move a1,x:top_height
	sub a,b
	move b1,x:polygon_height
	move r2,x:top_address
	tst b
	jle _no

	move #left_array,r0
	move #right_array,r1
	move r0,x:left_array_ptr
	move r1,x:right_array_ptr
	 jsr convert_scan

	move x:array_offset,r6
	move r6,a
	move #>1,x0			;skip y,and self each time
	cmp x0,a
	jle _dont_convert

	move (r6)-			;x array already done!
	move x:poly_to_scan,r4
	move #2,n4			;skip x,y
	nop
	lua (r4)+n4,r4
	move r4,x:save_r4_again

; We need to save the regs each time
	do r6,_convert_loop
		jsr set_up_general_2
		move x:left_array_ptr,r0
		move x:right_array_ptr,r1	;ARSE!
		move (r0)+
		move (r1)+
		move r0,x:left_array_ptr
		move r1,x:right_array_ptr
		 jsr convert_scan
		move x:save_r4_again,r4
		nop				;LARD
		move (r4)+
		nop				;LARD
		move r4,x:save_r4_again
_convert_loop:

_dont_convert:
	move x:which_draw_routine,r6
	nop
	jmp (r6)
_no	rts

set_up_general_2:
	move x:point_offset,n4
	move x:polygon_points,a
	move #scan_poly,r0					;r0 - first copy of poly
										;(change 'x' values)
	asl a		r0,b
	add a,b	
	move b1,r1							;r1 - second copy of poly
	move x:polygon_points,n6
	move #2,n0							;BUG #34893849
	move #2,n1
;-----------LIMITS LOOP-----------------
	do n6,_setup_loop
		 move y:(r4)+n4,x0	;fetch gour val
		 move x0,y:(r0)+n0	;store it
		 move x0,y:(r1)+n1
_setup_loop:
	rts






; Perspective: Xp = X / [ (z/d)+1 ]
;  (z/d)+1 = z/d + d/d = (z + d) / d
;  Hence Xp = (x * d * k) / (z + d)

;
; Now clipmasks for a point are also added...in clipmask_buffer
; .. aids easy visibility tests.

perspectivize:
	move x:object_address,r1
	move #O_Points,n1
	move #rotated_buffer,r0
	move y:(r1+n1),n6		;number of points to do
	move #clipmask_buffer,r1
	move #3,n1

	do n6,_perspect
		move #>cpersp,x1			; x1 = 1/d
		move y:(r0)+,y1				; y1 = z+1/d			
		mpy x1,y1,a		y:(r0)+,x0	; x0 = xcoord
		jle _failure				; IF non-positive, don't bother
		move a0,x1					; x1= z coord
		move y:viewer_size,a		; perspective size
		rep #$18					; p.coeff= k/(z+.25)
			div x1,a
		bclr #23,a0
		move a0,x1					;x1 = perspective coeff.
		mpy x1,x0,a		y:(r0)-,x0
		mpy x1,x0,b		a1,y:(r0)+
		IF	doublescan_adjust
		asr b						;doublescan arse.
									;must fix the rotation routine!
		ENDIF
		move b1,y:(r0)+

; Now set the test bits:
		move #0,n6
		move x:xmin,x0
		cmp x0,a		x:xmax,x0
		jgt _t1
		bset #xmin_bit,n6
_t1:	cmp x0,a		x:ymin,x0
		jlt _t2
		bset #xmax_bit,n6
_t2:	cmp x0,b		x:ymax,x0
		jgt _t3
		bset #ymin_bit,n6
_t3:	cmp x0,b
		jlt _t4
		bset #ymax_bit,n6
_t4:
_failure_done:
		move n6,y:(r1)+n1		;dont store it yet - i need to think
_perspect:
	rts
_failure:
		move (r0)+				; skip the last fetch
		move #-1,n6				; set z clip on!
	jmp _failure_done
















;----------------------------------------------------
prepare_object:
	jsr calc_movement			;OPTI may not be needed
	jsr rotate_routine			;user defined!
	jsr perspectivize			;... and add cliptmasks
	jsr calc_visibility			; + calc polys' clipmasks

	;move x:object_address,r0
	;nop							;lard
	;move y:(r0),a
	;move a,x:object_type		;OPTI will be fixed

	jsr rotate_envmap_normals	;envmap

	move x:object_address,r0
	move #>O_Poly_Ptr,n0
	move #visible_buffer,r1
	move y:(r0+n0),r4
	move #>O_Polys,n0

	move #handle_envmap_poly,r6
	move #send_envmap_poly,r5
	move #>3,n6							;x,texx,texy

	move y:(r0+n0),n0			;get poly data addr
	move r6,x:which_poly_routine
	move n6,x:array_offset
	move n6,r6
	move r5,x:which_draw_routine
	move (r6)+
	move r6,x:point_offset
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
;	move #gouraud_colours,r0
;	move #-1,m0
;	wait_receive
;	movep x:<<hrx,n0
;
;	do n0,_get
;		wait_receive
;		movep x:<<hrx,x0
;		move x0,x:(r0)+
;_get:
;	jmp main_loop


;------------------------------------------------------------
; Enter with:
; r0 - start of object in _y memory_

convert_file:
; First of all, relocate the top n address offsets
; x0 is file start
; x1 is start of current object
	move r0,x:file_address
	move r0,x0
	move (r0)+			;skip: length of file
	move y:(r0)+,n6		; get: number of objects
	move (r0)+			;skip: BSP tree addr

	do n6,_add_object_positions
	 move y:(r0),a
	 add x0,a
	 move a1,y:(r0)+	;save abs pos
; Convert object itself
	 move a1,r1
	 move a1,x1
	 move #>O_Point_Ptr,n1				;OPTI
	 jsr _conv_obj						;could be hard-coded into
	 move #>O_Poly_Ptr,n1				;the object itself
	 jsr _conv_obj						;since load address will be
	 ;move #>O_Normal_Ptr,n1			;known
	 ;jsr _conv_obj
	 move #>O_Gour_Ptr,n1
	 jsr _conv_obj
	 ;move #>O_Tex_Ptr,n1
	 ;jsr _conv_obj
	 ;move #>O_BSP_Ptr,n1
	 ;jsr _conv_obj
_add_object_positions
	rts

_conv_obj:
	move y:(r1+n1),a
	add x1,a
	move a1,y:(r1+n1)
	rts


;-------------------------------------------------------
;
;
;
;	Rotation Routines
;
;
;
;-------------------------------------------------------
; calculate_trig:
;  Uses following matrix:
; [revised version from FB3 demo...]

; 1,2,3 (+cosYcosZ -cosXcosYsinZ-sinXsinY +sinXcosYsinZ-cosXsinY )
; 4,5,6 (  +sinZ          cosXcosZ               -sinXcosZ       )
; 7,8,9 (+sinYcosZ -cosXsinYsinZ+sinXcosY +sinXsinYsinZ+cosXcosY )


; NOTE: Points are initially stored for x,y,z(depth) which can be
;   altered for distortion.
; Viewer X,Y and Z positions should also be sent in this order!

; Once rotated, points stored as z (for perspective), then x and y
;   with y negativized for screen co-ordinates layout.
;   Hence [7,8,9] above are placed in the matrix first

; Optimised for speed/space improvement

calculate_trig:
	move	#-1,m2
; First do +sinXsinZ ---> y0
	move	x:sinX,x0
	move	x:sinZ,x1
	mpy	+x0,x1,a
	move	a1,y0
;          -cosXsinZ ---> temp1
	move	x:cosX,x0
	move	x:sinZ,x1
	mpy	-x0,x1,a	x:sinY,x0
	move	a1,x:temp1
;-----------------------------------------------------------------
	move			x:cosZ,x1
	mpy	+x0,x1,a	x:sinY,x0
	move a1,x:(r2)+					;7 sinYcosZ
	move			x:temp1,x1
	mpy	+x0,x1,a	x:sinX,x0
	move			x:cosY,x1
	mac	+x0,x1,a	x:sinY,x0
	move	a1,x:(r2)+			;8 -cosXsinYsinZ+sinXcosY
	mpy	+y0,x0,a	x:cosX,x0
	move	x:cosY,x1
	mac	+x0,x1,a	x:cosY,x0
	move	a1,x:(r2)+			;9 +sinXsinYsinZ+cosXcosY
;-----------------------------------------------------------------
	move	x:cosZ,x1
	mpy	x0,x1,a		x:cosY,x0
	move	a1,x:(r2)+			;1 cosYcosZ
	move	x:temp1,x1
	mpy	+x0,x1,a	x:sinX,x0
	move	x:sinY,x1
	mac	-x0,x1,a	x:cosY,x0
	move	a1,x:(r2)+			;2 -cosXcosYsinZ-sinXsinY
	mpy	+x0,y0,a	x:cosX,x0
	move	x:sinY,x1
	mac	-x0,x1,a	x:sinZ,x0
	move	a1,x:(r2)+			;3 +sinXcosYsinZ-cosXsinY
;-----------------------------------------------------------------
	move	x0,x:(r2)+			;4 sinZ
	move	x:cosX,x0
	move	x:cosZ,x1
	mpy	+x0,x1,a	x:sinX,x0
	move	a1,x:(r2)+			;5 sinXcosY
	move	x:cosZ,x1
	mpy	-x0,x1,a
	move	a1,x:(r2)+			;6 cosXcosY
	rts



;-------------------------------------------------------
calc_movement:
; First, calculate the viewer position offsets.
; These must be rotated too!
	move #viewer_x,r4
	move #matrix,r2
	move r4,r5
	move r5,r6
	move #-1,m2
	move #-1,m4
	move #-1,m5
	move #viewer_offset,r3
	move y:camera_z,a
			 move	x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	move a1,y:(r3)+
	move y:camera_x,a
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
	move a1,y:(r3)+
	move y:camera_y,a
	mac -y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	mac -y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	mac -y0,x0,a
	move a1,y:(r3)+
	rts


rotate_points:
	move x:object_address,r0
	move #>O_Point_Ptr,n0
	nop
	move y:(r0+n0),r4
object_rotate_points_patch:
fish_rotate_points_patch:
	move x:object_address,r0
	move #O_Points,n0
	move #-1,m4
	move #-1,m2
	move y:(r0+n0),n0			;number of points to do
	move r4,r5
	move r5,r6
	move #-1,m5
	move #-1,m6
	move #rotated_buffer,r0
	;-------------------
	do n0,_spin
	  move #viewer_offset,r3
	  move #matrix,r2
	  move y:(r3)+,a
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  move a1,y:(r0)+
	  move y:(r3)+,a
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  move y:(r3)+,b
	  mac -y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  mac -y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  mac -y0,x0,b	a1,y:(r0)+				;Invert y coord
	  move b1,y:(r0)+
_spin:
	;-------------------
	rts







calc_visibility:
					;optimised september 96
					;(works eventually?!)
	move x:object_address,r0
	move #O_Polys,n0			;number of polygons
	move #visible_buffer,r6
	move y:(r0+n0),n6			;poly_count[object_number]
	move #O_Poly_Ptr,n0
	move #rotated_buffer+1,r2	;use now-perspectivized co-ords!
	move y:(r0+n0),r0

	do n6,_polygon_loop
		move y:(r0)+,n1		; get count
		move (r0)+			; skip colour
		move r0,r1			; save Vertex 1 address
; Phase One
; Direction Check of polygon
		move y:(r0)+,n2		; ---- Get Vertex A nr
		nop
		lua (r2)+n2,r3		; IgPiEr
		move y:(r0)+,n2		; ---- Get Vertex B nr
		nop
		lua (r2)+n2,r4		; r4 - VertB address
		move y:(r3)+,x0		; r3 - VertA address
		move y:(r3)-,x1		;
		move y:(r4)+,a		; pipelining w.e.f. here
		move y:(r4)-,b		; remember this point?
		sub x0,a	y:(r0)+,n2	; ---- Get Vertex C nr
		sub x1,b	y:(r4)+,y0	; r4 vertB address (still!)
		move a1,x0			;yuk, ugly
		move b1,x1
		lua (r2)+n2,r5		; r5 - vertC address now
		move y:(r4)-,y1		; ignore pipeline error
		move y:(r5)+,a		; pipeline w.e.f. here
		move y:(r5)-,b
		sub y1,b			;**** spare parallel move
		sub y0,a	b,y1

		lua (r1)+n1,r0					; move to next poly data
		mpy +x0,y1,a	a,y0
		mac -x1,y0,a					;**** spare parallel move
		jle _polygon_invisible

; Phase Two:
; Get clipmasks and AND them together
		clr a	#clipmask_buffer,r4		;!
		clr b	y:(r1)+,n4
		do n1,_check_clipmasks			; n1 = points in this poly
			move y:(r4+n4),x0			; get clipmask
			or x0,b		y:(r1)+,n4		; see which apply to any...
			and x0,a					; see which apply to all polys
_check_clipmasks
		jne _polygon_invisible			; poly must be invisible!
		jset #4,b1,_polygon_invisible	; z clipping in action...
_invis_done:
		move b1,y:(r6)+					; what clips we must do
_polygon_loop:
	rts

_polygon_invisible:
		move #-1,b1
		jmp _invis_done




;-------------------------------------------------------
;
;
;	receive_object
;
;
;
;-------------------------------------------------------

receive_object
	move #cyber_file,r0
	move #-1,m0
	wait_receive
	movep x:<<hrx,n0
	move n0,y:(r0)+

	do n0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_get:
	move #cyber_file,r0
	jsr convert_file
	jmp main_loop


;-------------------------------------------------------
receive_light:
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

receive_rotation:
	move #cosX,r0
	move #-1,m0
	do #6,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	move #matrix,r2
	jsr calculate_trig
	jmp main_loop

receive_viewpoint:
	move #viewer_x,r0
	move #-1,m0
	do #7,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_get:
	jmp main_loop

receive_clipping:
	move #xmin,r0
	move #-1,m0
	do #4,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	jmp main_loop

;-------------------------------------------------------
receive_one_over:
	move #one_over,r0
	do #384,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	rts




;-------------------------------------------------------
;---------------------------------------------------------------------
; convert_scan:
; The actual scan converter, adaptable for gou and map routs
; NOTE: for gouraud and texture map routines this rout can be jumped
;       to after limit checking (see above)

;       r0,r1 - address of left, right arrays
;       x0    - offset step: 1-flat shade, 2-gouraud, 3-xy mapping etc
;		In WORLD2.ASM, automatically set


; History 5.5.95 fix for different values of x0
;           8.95 optimizations, accuracy fixes
;	         Speed very important - this consumes quite a
;	          lot of processor time...rout is now amazingly dense
;	 26.1.96 multiple values/line
;		slight optimization
;		LARD! did it wrong
;		clip checking to be added

convert_scan:
	;move x0,x:array_offset
	move x:polygon_points,n0
	move x:top_address,r6
	;move x:left_array_ptr,r0
	;move x:right_array_ptr,r1
	move #one_over,r3
	move r6,r5
	move (r6)+
	move (r6)+			;move it on to next pt
; r5 = pt1, r6 = next pt
;----------------------------------------
	do n0,do_line
	  move y:(r5)+,x0		;x co-ords
	  move y:(r6)+,x1
	  move y:(r5)+,a		;y co-ords
	  move y:(r6)+,b
	  sub a,b			;right hand side. That's 'easy'
	  jlt _do_left_side		;aha!
	  jle dont_do_it
	  move x:right_array_ptr,r2
	  jmp scan_carry_on
_do_left_side:
	    add b,a	x0,y1		;restore a
	    neg b	x1,x0
	    move 	y1,x1		;swap x0 and x1
	    move x:left_array_ptr,r2
scan_carry_on:
	  move x:top_height,y1
	  sub y1,a	x:array_offset,y0 ;a = offset
	  move a,y1
	  mpy y0,y1,a	b1,n3
	  asr a		x1,b		;halve for fractional silliness
	  move a0,n2
	  sub x0,b	x:(r3+n3),y1	; y1 = 1/(y1-y0)
	  lua (r2)+n2,r2
	  move x0,a
	  move b1,x1			; x1 = x1-x0
	  mpy x1,y1,b	y0,n2 		;  b = x1/(y1-y0)
	  ;move #>$800000,a0
	;---------- FILL LOOP ----------
	  rep n3
	    add  b,a	a1,x:(r2)+n2	;,,wahnsinn''
	;-------------------------------
dont_do_it:
	  nop			;hoargh.
do_line:
	rts


;-------------------------------------------------------
;
;		clipper
;	a total nightmare.....
;
; 27/1/96    It's getting worse
;
;-------------------------------------------------------
;
; 1.4.97     Added parts to try to fix clipping rounding errors
;            due to subtractive rounding. Perhaps swap to always find
;            the lower x/y value?
;
;
;
;
;
;

increase_clip_count MACRO
		move (r6)+
		ENDM

copy_extra_clip MACRO label
		move r0,r4
		do n5,_\label
	  	 move y:(r4)+,x0
	  	 move x0,y:(r2)+
_\label:
		ENDM

copy_r4_point	MACRO label
		move r4,r5
		do n5,_\label
	  	 move y:(r5)+,x0
	  	 move x0,y:(r3)+
_\label:
		increase_clip_count
		ENDM

do_clip		MACRO addr1,addr2
		move y:\addr2,a
		move y:\addr1,x1
		sub x1,a
		move a,y1
		move x1,a			;was a1
		macr y0,y1,a		;was 'mac'
		move a1,y:(r3)+
		ENDM

do_clip_reverse		MACRO addr1,addr2
		move y:\addr2,x1
		move y:\addr1,a
		sub x1,a
		move a,y1
		move x1,a			;was a1
		macr y0,y1,a		;was 'mac'
		move a1,y:(r3)+
		ENDM


handle_x_y_clip:
	move x:array_offset,b
	move x:point_offset,a
	move #>1,x0
	sub x0,b
	move a,n5			;dont change n5!
	move b,n3			; or n3 or n6

	move #input_poly,r0				;r0 - input
	move #output_poly,r1			;r1 - output
; Calculate end of poly:
	move r0,x1						;r2 - end of input poly
	move x:polygon_points,x0
	move x:point_offset,y0
	mpy x0,y0,a
	asr a
	move a0,a
	add x1,a
	move a,r2						;(used for copying endbit!)

	move x:current_clipmask,n6
	move x:polygon_points,a
	move a1,r6						;!!!!!

	jsset #xmin_bit,n6,do_x_min_clip
	move r6,a
	tst a
	jle _failed
	
	jsset #ymin_bit,n6,do_y_min_clip
	move r6,a
	tst a
	jle _failed

	jsset #xmax_bit,n6,do_x_max_clip
	move r6,a
	tst a
	jle _failed

	jsset #ymax_bit,n6,do_y_max_clip
	move r6,a
	tst a
	jle _failed

	move a1,x:polygon_points
	move r0,x:poly_to_scan
	jmp x_y_clip_valid
_failed:
	jmp x_y_clip_invalid

; REMEMBER: POLYS ARE IN ** Y ** MEMORY!

;------------------------------------------------------
do_x_min_clip:
	copy_extra_clip s1
	move #0,r6			;this is my counter
	move r1,r3
	move r0,r4
	do a,_test_next_point
	 move n5,n4
	 move y:(r4),a			;fetch x coord 1
	 move x:xmin,x1
	 cmp x1,a	y:(r4+n4),b	;fetch x coord 2
	 jge _inside
; We're outside. If other point is too, then don't do anything
	 cmp x1,b
	 jlt _both_outside
; Now the second is inside.... (do clipping)	
	 jsr actual_x_clip
	 jmp _no_move
_inside:
	 copy_r4_point s2		;keep r4 the same
	 cmp x1,b
	 jge _move_on			;do other point next time
	 jsr actual_x_clip
	 jmp _no_move
_both_outside:
_move_on:
	 move n5,n4
	 nop
	 lua (r4)+n4,r4
_no_move:
	nop
_test_next_point:
	jmp clip_done

;------------------------------------------------------
do_x_max_clip:
	copy_extra_clip s1
	move #0,r6			;this is my counter
	move r1,r3
	move r0,r4
	do a,_test_next_point
	 move n5,n4
	 move y:(r4),a			;fetch x coord 1
	 move x:xmax,x1
	 cmp x1,a	y:(r4+n4),b	;fetch x coord 2
	 jle _inside
; We're outside. If other point is too, then don't do anything
	 cmp x1,b
	 jgt _both_outside
; Now the second is inside.... (do clipping)	
	 jsr actual_x_clip
	 jmp _no_move
_inside:
	 copy_r4_point s2		;keep r4 the same
	 cmp x1,b
	 jle _move_on			;do other point next time
	 jsr actual_x_clip
	 jmp _no_move
_both_outside:
_move_on:
	 move n5,n4
	 nop
	 lua (r4)+n4,r4
_no_move:
	nop
_test_next_point:
	jmp clip_done






;------------------------------------------------------
do_y_min_clip:
	copy_extra_clip s1
	move #0,r6			;this is my counter
	move r1,r3
	move r0,r4
	do a,_test_next_point
	 move #>1,n4
	 nop
	 move y:(r4+n4),a		;fetch y coord 1
	 move n5,b
	 move #>1,x1
	 add x1,b
	 move b1,n4
	 move x:ymin,x1
	 cmp x1,a	y:(r4+n4),b	;fetch y coord 2
	 jge _inside
; We're outside. If other point is too, then don't do anything
	 cmp x1,b
	 jlt _both_outside

; Now the second is inside.... (do clipping)	
	 jsr actual_y_clip
	 jmp _no_move
_inside:
	 copy_r4_point s2		;keep r4 the same
	 cmp x1,b
	 jge _move_on			;do other point next time
	 jsr actual_y_clip
	 jmp _no_move
_both_outside:
_move_on:
	 move n5,n4
	 nop
	 lua (r4)+n4,r4
_no_move:
	nop
_test_next_point:
	jmp clip_done


;------------------------------------------------------
do_y_max_clip:
	copy_extra_clip s1
	move #0,r6			;this is my counter
	move r1,r3
	move r0,r4
	do a,_test_next_point
	 move #>1,n4
	 nop
	 move y:(r4+n4),a		;fetch x coord 1
	 move n5,b
	 move #>1,x1
	 add x1,b
	 move b,n4
	 move x:ymax,x1
	 cmp x1,a	y:(r4+n4),b	;fetch x coord 2
	 jle _inside
; We're outside. If other point is too, then don't do anything
	 cmp x1,b
	 jgt _both_outside
; Now the second is inside.... (do clipping)	
	 jsr actual_y_clip
	 jmp _no_move
_inside:
	 copy_r4_point s2		;keep r4 the same
	 cmp x1,b
	 jle _move_on			;do other point next time
	 jsr actual_y_clip
	 jmp _no_move

_both_outside:
_move_on:
	 move n5,n4
	 nop
	 lua (r4)+n4,r4
_no_move:
	nop
_test_next_point:
	jmp clip_done


;------------------------------------------------------
clip_done:
	move r0,r2
	move r1,r0
	move r2,r1
	move r3,r2			;r3 = whatever the dest clip reg is
	rts

do_divide_clip:
	move #0,y0
	move b1,x1			;24 bit signed frac
	clr b				;assume empty
	cmp x1,b			;is it 0?
	jeq _nodivide

	move #$7fffff,b0		;i.e. '1'...
	and #$fe,ccr			;clear carry bit
	rep #24
	 div x1,b
	bclr #23,b0
; b0 is now (1/b)
	move b0,y0			;there must be a better
	move a1,y1			;way than this!
	mpy y0,y1,a
	move a0,y0			;y0 is my multiplier...
_nodivide
	rts


; What we need to do is always take the SMALLER of the two values.
; If we have to swap them, then negate b and change r4?

; ie. instead of
;	do_clip (r4)+,(r4+n4)				;that's the x
; do a second type of do_clip call:
;	do_clip (r4+n4),(r4)+
;

actual_x_clip:
	move x1,y:(r3)+			;store the clipped xcoord first
	move b,y0
	sub a,b	
	jmi x_clip_two
	sub x1,a	(r4)+		;ignore xcoord now
	neg a
	jsr do_divide_clip
_zero:
; Fetch Y and gouraud and interpolate
	do_clip (r4)+,(r4+n4)		;y
	move n3,b
	tst b
	jeq _c2
	do n3,_c2
	 do_clip (r4)+,(r4+n4)		;y
_c2	increase_clip_count
	rts

x_clip_two
; Swap a and b round? ie. so b is the positive offset and a is the
; smaller value (ie. original b)
	neg b				;b=a-b a=a
	move y0,a
; Now we have swapped a and b round
	sub x1,a	(r4)+
	neg a				;???why always negative???
	jsr do_divide_clip

; Fetch X and Y and interpolate
	do_clip_reverse (r4)+,(r4+n4)
	move n3,b
	tst b
	jeq _c2
	do n3,_c2
	  do_clip_reverse (r4)+,(r4+n4)
_c2	increase_clip_count
	rts



;-----------------------------------------------------------------
; input:
;		a  : y value of point1
;		b  : y value of point2
;		x1 : y value to clip against
;		r3 : address of destination poly
;		r4 : address of source poly1 and poly2

actual_y_clip:
	move b,y0
	move n5,n4
	move (r3)+
	move x1,y:(r3)-				;store the clipped xcoord first.
								;this is always done.
	sub a,b						;this line accidentally removed!
	jmi y_clip_two
	sub x1,a	
	neg a
	jsr do_divide_clip
_zero:
; Fetch X and Y and interpolate
	do_clip (r4)+,(r4+n4)
	move (r3)+					;skip y - it's the same
	move (r4)+
	move n3,b
	tst b
	jeq _c2
	do n3,_c2
	  do_clip (r4)+,(r4+n4)
_c2	increase_clip_count
	rts

y_clip_two:
; Swap a and b round? ie. so b is the positive offset and a is the
; smaller value (ie. original b)
	neg b				;b=a-b a=a
	move y0,a
; Now we have swapped a and b round
	sub x1,a
	neg a				;???why always negative???
	jsr do_divide_clip

; Fetch X and Y and interpolate
	do_clip_reverse (r4)+,(r4+n4)
	move (r3)+					;skip y - it's the same
	move (r4)+
	move n3,b
	tst b
	jeq _c2
	do n3,_c2
	  do_clip_reverse (r4)+,(r4+n4)
_c2	increase_clip_count
	rts

; GENSORT.ASM

; General sort routine
; Small but beautifully formed
; Started 9/2/96, tested 9/2/96 with 20 elements

; Enter with: r0 start of list, n0 number of elements
;             (list must be in X memory)
; Elements will be sorted in DESCENDING ORDER (biggest first!)

general_sort_routine:
	move n0,r6
	move #>2,n5
	move (r6)-			;no of elements - 1, don't need to do last
	move #>2,n0
	move #>-2,n3
	do r6,_sort_loop_1
	  lua (r0)+n0,r5		;r5 - addr as we go through
	  move x:(r0),a			;get first element
	  move x:(r5)+n5,b
	  move r5,r3			;r3 - (addr of biggest so far) + 4!
	  do r6,_sort_loop_2
	    cmp b,a	x:(r5)+n5,b	b,y0
	    tle y0,a	r5,r3
_sort_loop_2:
	  move x:(r0),x0
	  move a1,x:(r0)+
	  lua (r3)+n3,r3		;ARSE!
	  move x:(r0),x1
 	  move x:-(r3),y1
	  move y1,x:(r0)+
	  move x1,x:(r3)-	y:(r6)-,b	;one less to check
	  move x0,x:(r3)
_sort_loop_1:
	rts

;
; Polygon handling routines
; - normal rotators, scan drawers, shaders
;
;
;
;	NOW ONLY COMPATIBLE WITH CORE2.ASM!!
;	- uses different offsets into input_poly now that
;   Z co-ord is no longer put in
;
;	Gouraud + texmapping added 21.1.97
;



	IF	flat_handler
handle_flat_poly:
	jsr send_flat_poly
	rts

handle_flat_shade_poly:
	move x:save_r5,r5
	jsr send_flat_shade_poly
	move x:save_r5,r5
	rts

;------------------------------------------------------------------
send_flat_poly:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>0,x0		;routine number
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

	move x:gouraud_colours_address,a0
				; get* middle* value
	move #>(128/2),y0
	move x:polygon_colour,x0
	mac x0,y0,a
	move a0,r3
	wait_transmit
	move x:(r3),x0
	movep x0,x:<<htx	; send colour
	move #left_array,r0
	move #right_array,r1

	do n0,_scan_send_sides
	   wait_transmit
	  move x:(r0)+,x0
	  movep x0,x:<<htx
	   wait_transmit
	  move x:(r1)+,a
	  sub x0,a
	  movep a1,x:<<htx
_scan_send_sides:
	rts			;adieu

;---------------------------------------
send_flat_shade_poly:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>1,x0		;routine number
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

	clr a
	move x:gouraud_colours_address,a0
	move #>(128/2),y0
	move x:polygon_colour,x0
	move x:polygon_shade,x1
	mac x0,y0,a
	move a0,b
	move #>(64/2),y0
	mac x1,y0,b
	move b1,r3
	wait_transmit
	move x:(r3),x0
	movep x0,x:<<htx	; send colour
	move #left_array,r0
	move #right_array,r1
	do n0,_scan_send_sides
	   wait_transmit
	  move x:(r0)+,x0
	  movep x0,x:<<htx
	   wait_transmit
	  move x:(r1)+,a
	  sub x0,a
	  movep a1,x:<<htx
_scan_send_sides:
	rts			;adieu

rotate_flat_normals:
	move x:object_address,r0
	move #>O_Normal_Ptr,n0		;, normal_offset
	nop
	move y:(r0+n0),r6
	move #>O_Polys,n0
	move #light_matrix,r2
	move y:(r0+n0),n6		;+0, number_of_polys
	move #shade_normals_buffer,r0

	;-------------------
	do n6,_spin
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a		#light_matrix,r2
	  move a,y:(r0)+
_spin:
	;-------------------
	rts

	ENDIF

	IF	gouraud_handler
;*********************************************************************
handle_gouraud_poly:
	move #shade_normals_buffer+0,r5
	move x:polygon_points,n4
	move #input_poly+2,r0
	move #>3,n0			;x,y,gouraud
	do n4,_get_point
	  move y:(r4)+,n5	;fetch vertex offset
	  nop
	  move y:(r5+n5),x1	;fetch gouraud normal value
	  move x1,y:(r0)+n0	;copy gouraud shade
_get_point:
	rts



;---------------------------------------
send_gouraud_poly:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>2,x0			;routine number 2
	wait_transmit
	movep x0,x:<<htx	; send signal

	move #>hrx,r6
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
	move x:gouraud_colour_address,a0
	move #>(128/2),y0
	move x:polygon_colour,x0
	mac x0,y0,a
	move a0,r3

	move #>128,y0
; The actual 'draw' Loop
;---------------------------------------
	do n6,scan_send_sides	;THIS WAS THE BUG!

	   wait_transmit
	  move x:(r0)+,x0
	   movep x0,x:<<htx	;send left value

	  move x:(r1)+,a
	  sub x0,a	    x:(r0)+,b
	   wait_transmit
	   movep a,x:<<htx	;send width

	  move x:(r1)+,x1
	  tst a
	  jle _failed		;"next!"

	  move a1,n2		;n2 = the width
	  move x1,a
	  sub b,a
	  move a,x1
	  move b,x0
; x1 offset value
; Size it:
	  move x:(r2+n2),y1
	  mpy y1,x1,a
	  move a1,x1

	  mpy x0,y0,a		;a - start val
	  mpy x1,y0,b		;b - add val
	  move a,n3

	;-----------------------
	  do n2,_plot_loop
	    wait_transmit
	    movep x:(r3+n3),x:<<hrx
	    add b,a	a,n3
_plot_loop:
_failed
	  nop
	;-----------------------
scan_send_sides:
;---------------------------------------

	rts			;adieu


rotate_gour_normals:
	jsr	set_up_rotate

; Right, now rotate the 3*1 matrix and do a dot product
;    with my unit_store vector
	move x:object_address,r0
	move #>O_Gour_Ptr,n0		;, gouraud_offset
	nop
	move y:(r0+n0),r6
	move #>O_Points,n0
	move r6,r5
	move y:(r0+n0),n6		;+0, number_of_points
	move r6,r4

	move #-1,m2
	move #light_matrix,r2
	move #shade_normals_buffer+0,r0
	move #3,n0			;skip data (kludge)
	;-------------------
	do n6,_spin
	  	   move	x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a
	  move a1,x1				;x1 - z coord
	  	   move	x:(r2)+,x0 y:(r5)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a
	  move a1,y1				;y1 - x coord
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a	#unit_store,r1
	  move a,y0				;y0 - y coord
; Now compare with dot prod:
	  move #0.5,b
	  move 		x:(r1)+,x0
	  mac x0,x1,b	x:(r1)+,x0
	  mac x0,y1,b	x:(r1)+,x0
	  macr x0,y0,b	#light_matrix,r2
	  move b1,y:(r0)+n0
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts

	ENDIF

	IF	(envmap_handler+phong_handler)||@def(shademap_handler)
rotate_envmap_normals:
rotate_phong_normals:
;    with my unit_store vector
	move x:object_address,r0
	move #>O_Gour_Ptr,n0		;, gouraud_offset
	nop
	move y:(r0+n0),r6
	move #>O_Points,n0
	move r6,r5
	move y:(r0+n0),n6		;+0, number_of_points
	move r6,r4

	move #-1,m2
	move #0.5,y1
	move #0,x1
	move #light_matrix,r2
	move #shade_normals_buffer+0,r0
	;-------------------
	do n6,_spin
	  move			x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r5)+,y0

	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r6)+,y0

	  mpy -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  mac -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  macr -y0,x0,b	#light_matrix,r2

; OK we now have x,y,z normals. We want the angle and the distance!?!
; to project them onto a cone, plane or something
	  asr b
	  add y1,b
	  asr a		b,y:(r0)+
	  add y1,a
	  move a,y:(r0)+
	  move (r0)+				;dummy value
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts

	ENDIF


	IF	texmap_handler
handle_texmap_poly:
	  move #texmap_vertices,a0
	  move a0,r5
	  move #input_poly+2,r0
	  move x:polygon_points,n4
	  move #>4,n0				;x,y,tex1,tex2
	  do n4,_get_point
	    move x:(r5)+,x1
	    move x1,y:(r0)+	;texmap val 1
	    move x:(r5)+,x0
	    move x0,y:(r0)+n0	;  ""   val 2
_get_point:
	rts
	ENDIF

	IF	envmap_handler
handle_envmap_poly:
	move #shade_normals_buffer+0,r5
	move #shade_normals_buffer+1,r6
	move x:polygon_points,n4
	move #input_poly+2,r0
	move #input_poly+3,r1
	move #>4,n0				;x,y,gouraudx,gouraudy
	move n0,n1				;x,y,gouraudx,gouraudy
	do n4,_get_point
	  move y:(r4)+,n5			;fetch vertex offset
	  move n5,n6
	  move y:(r5+n5),x1			;fetch gouraudx normal value
	  move x1,y:(r0)+n0			;copy gouraud shade
	  move y:(r6+n6),x1			;fetch gouraudy normal value
	  move x1,y:(r1)+n1			;copy gouraud shade
_get_point:
	rts

	ENDIF

	IF	texmap_handler
send_texmap_poly:
	move #>"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>3,x0
	wait_transmit
	movep x0,x:<<htx	; send signal

	move x:top_height,x0
	wait_transmit
	movep x0,x:<<htx	; send minimum y

	move x:polygon_height,a1
	move a1,n6
	wait_transmit
	movep a1,x:<<htx	; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2
	move #texmap_buffer,r4

; The actual 'draw' Loop
;---------------------------------------
	do n6,_scan_send_sides
	  move x:(r0)+,x0
	   wait_transmit
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
	  jmi _skip_line
	  jeq _skip_line
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
	    mpy y0,y1,b		#>-63,y0	;1
	    and y0,b		#>64,y0		;2
	    move a0,y1					;3!
	    mac y0,y1,b		#>64*64,y0		;4
	    add x,a		b1,n4			;5
	     wait_transmit
	    movep x:(r4+n4),x:<<htx			;7 (send)
	    move a1,y1					;6
_send_pixel:
_skip_line:
	nop
_no_poly
_scan_send_sides:
;---------------------------------------
	rts
	ENDIF

	IF	envmap_handler
;---------------------------------------
send_envmap_poly:
	move #>"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>3,x0
	wait_transmit
	movep x0,x:<<htx			; send signal

	move x:top_height,x0
	wait_transmit
	movep x0,x:<<htx			; send minimum y

	move x:polygon_height,a1
	move a1,n6
	wait_transmit
	movep a1,x:<<htx			; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2
	;move #texmap_buffer+64*32+32,r4		;centre of map
	move #texmap_buffer,r4		;topleft of map

; The actual 'draw' Loop
;---------------------------------------
	do n6,_scan_send_sides
	  move x:(r0)+,x0
	   wait_transmit
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
	  jmi _skip_line
	  jeq _skip_line
	  move x1,a
	  sub y0,b
	  sub x0,a
	  move x:(r2+n2),x1
	  move a,y1
	  mpy x1,y1,a		;parallel moves?
	  move b,y1
	  mpy x1,y1,b

	  move a,x1			;x1 - xaddfrac
	  move x0,a1		;a1  - xfrac
	  move b,x0			;x0 - yaddfrac
	  move y0,a0		;a0  - yfrac
	  move #>32*64*2,y0	;y0 - multipliers
	  move a1,y1
	  do n2,_send_pixel
	    mpy y0,y1,b		#>-63,y0		;1
	    and y0,b		#>64,y0			;2!
	    move a0,y1						;3!
	    mac y0,y1,b		#>32*64*2,y0	;4
	    add x,a		b1,n4				;5
	     wait_transmit
	    movep x:(r4+n4),x:<<htx			;7 (send)
	    move a1,y1						;6
_send_pixel:
_skip_line:
	nop
_no_poly
_scan_send_sides:
;---------------------------------------
	rts
	ENDIF



handle_shademap_poly:
; First get address of texture vertices
	move x:object_address,r0
	move #>O_Tex_Ptr,n0
	nop
	move y:(r0+n0),r6

	move #input_poly+2,r0			;x and y already done
	move x:polygon_points,n4
	move #>3,n0						;x,y,tex1,tex2,gouraud

	do n4,_get_point
		move #shade_normals_buffer+0,r5
		move y:(r4)+,n5		;fetch vertex offset
		move n5,n6
		move y:(r5+n5),x0
		lua (r6)+n6,r5
		move x0,y:(r0)+		;store gouraud

		move y:(r5)+,x1		;fetch texture value 1
		move x1,y:(r0)+		;
		move y:(r5)+,x1		;fetch texture value 2
		move x1,y:(r0)+n0
_get_point:
	rts

handle_shademap2_poly:

; First get address of texture vertices
	move x:object_address,r0
	move #>O_Tex_Ptr,n0
	nop
	move y:(r0+n0),r6				;r6 - texture addresses

	move #input_poly+2,r0			;x and y already done
	move x:polygon_points,n4
	move #>3,n0						;x,y,gouraudx,gouraudy,tex1,tex2

	do n4,_get_point
		move y:(r4)+,n5		;fetch vertex offset
 		move #shade_normals_buffer+0,r5
		nop
		lua (r5)+n5,r5		;shading values
		nop
		move y:(r5)+,x1		;fetch env value 1
		move x1,y:(r0)+		;
		move y:(r5)+,x1		;fetch env value 1
		move x1,y:(r0)+		;

		move r6,r5
		nop
		lua (r5)+n5,r5		;texture values
		nop
		move y:(r5)+,x1		;fetch texture value 1
		move x1,y:(r0)+		;
		move y:(r5)+,x1		;fetch texture value 2
		move x1,y:(r0)+n0	; skip tex2,x,y
_get_point:
	rts
;
send_shademap_poly:
	move #>"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>4,x0
	wait_transmit
	movep x0,x:<<htx	; send signal

	move x:polygon_colour,x0
	wait_transmit
	movep x0,x:<<htx	; send colour

	move x:top_height,x0
	wait_transmit
	movep x0,x:<<htx	; send minimum y

	move x:polygon_height,a1
	move a1,n6
	wait_transmit
	movep a1,x:<<htx	; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2

	move #4-1,n0
	move #4-1,n1

	do n6,_scan_send_sides
	  move x:(r0)+,x0
	   wait_transmit
	  movep x0,x:<<htx	;_send_ left value
	  move x:(r1)+,a
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx	;_send_ width

	  tst a
	  jeq _skip_line
	  jmi _skip_line

	  move a1,n2			;n2 = counter
	  move r0,r5
	  move r1,r6
	  move #temp_x,r3
	  move #temp_y,r4
	  move #3-1,m3 
	  move #3-1,m4 

	  move x:(r2+n2),x1		;x1 = 1/x value

	  move x:(r5)+,x0
	  move x:(r6)+,a
	  jsr shademap_calc_addition
	  move x:(r5)+,x0
	  move x:(r6)+,a
	  jsr shademap_calc_addition
	  move x:(r5)+,x0
	  move x:(r6)+,a
	  jsr shademap_calc_addition

		move #>64*64*16,x1
		move #>%1111111111000000,y1

; Mapping tends to vary slightly with gouraud value?

	  do n2,_send_pixel
		; Do gouraud value first:
		move			x:(r3)+,x0	y:(r4),a
		add x0,a		#>%1111000000000000,y0
		clr a			a1,x0
		mpy x0,x1,b		x0,y:(r4)+
		; Main problem is that 'and' here does not clear b0
		and y0,b		x:(r3)+,x0	y:(r4),a
		add x0,a		#>64*64,y0
		move a1,x0
		move #0,b0
		mac y0,x0,b		x0,y:(r4)+
		and y1,b		x:(r3)+,x0	y:(r4),a
		add x0,a		#>64,y0
		move a1,x0
		move #0,b0
		mac y0,x0,b		x0,y:(r4)+
		  wait_transmit
		movep b1,x:<<htx
_send_pixel:

_skip_line:
	    lua (r0)+n0,r0
	    lua (r1)+n1,r1
	nop
_no_poly
_scan_send_sides:
	move #-1,m3
	move #-1,m4
;---------------------------------------
	rts

shademap_calc_addition:
	  move x0,y:(r4)+	;save initial value
	  sub x0,a
	  move a1,y1
	  mpy x1,y1,a		;parallel moves?
	  move a1,x:(r3)+	;save addition value
	rts

send_shademap2_poly:
	move #>"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>4,x0
	wait_transmit
	movep x0,x:<<htx	; send signal

	move x:polygon_colour,x0
	wait_transmit
	movep x0,x:<<htx	; send colour

	move x:top_height,x0
	wait_transmit
	movep x0,x:<<htx	; send minimum y

	move x:polygon_height,a1
	move a1,n6
	wait_transmit
	movep a1,x:<<htx	; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2

	move #4,n0			; skip: shadex,y, texturex,y
	move #4,n1

	do n6,_scan_send_sides
	  move x:(r0)+,x0
	   wait_transmit
	  movep x0,x:<<htx	;_send_ left value
	  move x:(r1)+,a
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx	;_send_ width

	  tst a
	  jeq _skip_line
	  jmi _skip_line

	  move a1,n2			;n2 = counter
	  move r0,r5
	  move r1,r6

; These are the gouraud values:
; Lookup in tex map:-

	  move x:(r5)+,x1		;gour x position
	  move #-1,m4
	  move x:(r5)+,y0		;gour y position
	  move #texmap_buffer,r4
	  move #>64*64,y1
	  mpy y0,y1,b		#>%1111111111000000,y1
	  and y1,b			#>64,y1
	  mac x1,y1,b
	  move b1,n4
	  move x:(r6)+,x1		;gour x position
	  move x:(r6)+,y0		;gour y position
	  move #>64*64,y1
	  mpy y0,y1,b		#>%1111111111000000,y1
	  and y1,b			#>64,y1
	  mac x1,y1,b
	  move x:(r4+n4),x0	;ignore pipeline error!	;gouraud value 1
	  move b1,n4
	  nop
	  move x:(r4+n4),a							;gouraud value 2

	;move #0,x0
	;clr a
	  move x:(r2+n2),x1		;x1 = 1/x value
	  move #temp_x,r3
	  move #temp_y,r4
	  move #3-1,m3 
	  move #3-1,m4 
	  jsr shademap_calc_addition
	  move x:(r5)+,x0
	  move x:(r6)+,a
	  jsr shademap_calc_addition
	  move x:(r5)+,x0
	  move x:(r6)+,a
	  jsr shademap_calc_addition

	  move #>64*64*16,x1
	  move #>%1111111111000000,y1

; Mapping tends to vary slightly with gouraud value?

	  do n2,_send_pixel
		; Do gouraud value first:
		move			x:(r3)+,x0	y:(r4),a
		add x0,a		#>%1111000000000000,y0
		clr a			a1,x0
		mpy x0,x1,b		x0,y:(r4)+
		; Main problem is that 'and' here does not clear b0
		and y0,b		x:(r3)+,x0	y:(r4),a
		add x0,a		#>64*64,y0
		move a1,x0
		move #0,b0
		mac y0,x0,b		x0,y:(r4)+
		and y1,b		x:(r3)+,x0	y:(r4),a
		add x0,a		#>64,y0
		move a1,x0
		move #0,b0
		mac y0,x0,b		x0,y:(r4)+
		  wait_transmit
		movep b1,x:<<htx
_send_pixel:

_skip_line:
	    lua (r0)+n0,r0
	    lua (r1)+n1,r1
	nop
_no_poly
_scan_send_sides:
	move #-1,m3
	move #-1,m4
;---------------------------------------
	rts







rotate_shademap_normals:
	jsr	set_up_rotate

	if @def(normals_patch)
	  jsr normals_patch
	else
; Right, now rotate the 3*1 matrix and do a dot product
;    with my unit_store vector
	move x:object_address,r0
	move #>O_Gour_Ptr,n0		;, gouraud_offset
	nop
	move y:(r0+n0),r6
	endif

	move #>O_Points,n0
	move r6,r5
	move y:(r0+n0),n6		;+0, number_of_points
	move r6,r4

	move #-1,m2
	move #light_matrix,r2
	move #shade_normals_buffer+0,r0
	move #3,n0			;skip data (kludge)

	;-------------------
	do n6,_spin
	  	   move	x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a
	  move a1,x1				;x1 - z coord
	  	   move		x:(r2)+,x0 y:(r5)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a
	  move a1,y1			;y1 - x coord
	  	   move		x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a	#unit_store,r1
	  move a,y0				;y0 - y coord

									; Now compare with dot prod:
	  clr b
	  move 			x:(r1)+,x0
	  mac x0,x1,b	x:(r1)+,x0
	  mac x0,y1,b	x:(r1)+,x0
	  macr x0,y0,b	#light_matrix,r2
	  ;asl b			;#>$fffff0,x0
	  ;cmp x0,b
	  ;tgt x0,b						; limit to +ve values
	  move b1,y:(r0)+n0
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts

set_up_rotate:
; First rotate the unit vector:
	move #matrix,r2
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
	move a1,x:(r1)+
		 move	x:(r2)+,x0 y:(r5)+,y0
	mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	macr y0,x0,a				;x coord
	move a1,x:(r1)+
		 move	x:(r2)+,x0 y:(r6)+,y0
	mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	macr y0,x0,a				;y coord
 	move a1,x:(r1)+
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

;-------------------------------------------------------
;-------------------------------------------------------
;-------------------------------------------------------
;-------------------------------------------------------

					org	y:$b00
temp_y					ds	3				;roll-over buffer!
unit_vector				dc	0,0,$3fffff

viewer_x				dc	0
viewer_y				dc	0
viewer_z				dc	3000

camera_x				dc	0
camera_y				dc	0
camera_z				dc	$3fff

viewer_size				dc	25000
viewer_offset			ds	3

rotated_buffer			ds	3*maximum_points

shade_normals_buffer	ds	3*maximum_points
clipmask_buffer			equ shade_normals_buffer+2
		
;BSP_normals_buffer		ds	maximum_polys
;						ds	30
;BSP_stack				equ	*

visible_buffer			ds	maximum_polys
polygon_list			ds	maximum_polys
scan_poly				ds	2*20
rec_poly:				ds	2*20
input_poly:				ds	6*20
output_poly:			ds	6*20

cyber_file				ds	maximum_file_size
cyber_file_address_end:
