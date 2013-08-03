
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
;
; now uses @def(symbol) command to check user additions...
;
; 11.October - start on planning for more efficient visibility
;              algorithm. Points are perspectivized, if z clip
;              OK a clipmask is calculated (else clipmask is negative)
;            - For calc_vis, *after* direction algorithm, clipmask
;              of poly is calculated and stored (instead of just
;              dot product)
;            - PLUS clipmask idea extended to write over z-coord,
;              done after perspective calculation. Z_clip is now
;              bit 4 of the clipmask (z clip calc by ORing masks
;              rather than ANDing to see if poly easily offscreen)
;              Storing instead of z-coord allows easy lookup
;              and saves memory!
;              >>>>>>BUT MUCKS UP THE Z-SORTING ALGORITHM>>>>>>
;			   Solution to this found, but "proper" z-clipping is out
;			   of the question
;	24.10.96	clipmask buffer set to shade_buffer+2 to allow
;				env/phong mapping
;
;	21.1.97		Work on gouraud-shaded texture-mapping
;				started
;	14.3.97		Environment-style texture-mapping
;
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
object_type			ds	1
which_poly_routine	ds	1
which_draw_routine	ds	1
poly_to_scan		dc	input_poly

xmin				dc	x_min
xmax				dc	x_max
ymin				dc	y_min
ymax				dc	y_max
current_clipmask	ds 1

visible_poly_count	dc	0




;-------------------------------------------------------
				org p:
;-------------------------------------------------------
;
;
;	calc_object
;
;	(Carried out during screen clearing)
;
;-------------------------------------------------------
calc_object:
	move x:file_address,r0
	move #C_BSP,n0
	nop
	move y:(r0+n0),a		;get starting polygon
	tst a
	jeq _no_BSP
	 jsr rotate_BSP_normals
	 jsr Walk_BSP_Tree
_no_BSP:
	jmp main_loop










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
	move x:file_address,r0
	move #C_BSP,n0
	nop
	move y:(r0+n0),a		;get starting polygon
	move #BSP_sorted_buffer,r0
	tst a
	jeq handle_no_BSP
	jmp handle_BSP_list

object_finished:
	IF @def(three_plane)

	ELSE
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
	ENDIF
	jmp main_loop

handle_no_BSP
	clr a
	jsr handle_object
	jmp object_finished

handle_one_object:
	 wait_receive
	movep x:<<hrx,a
	jsr handle_object
	jmp object_finished

handle_BSP_list:
_little_loop:
	move x:(r0)+,a
	tst a
	jmi _loop_done
	move r0,x:save_r0
	jsr handle_object
	move x:save_r0,r0
	jmp _little_loop
_loop_done:
	jmp object_finished


;-----------------------------------------------------------------
; a = number of object
handle_object:
	move a1,x:current_object

	move x:file_address,r0
	move #>C_Objects,x0
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

	move	x:object_type,a
	jset	#16,a,handle_sorted_object
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

	;------------------------------------
handle_sorted_object:
	jsr	prepare_poly_address_list
	jsr	prepare_sort_buffer

	move #polygon_sort_list,r0
	move x:visible_poly_count,n0
	move n0,a
	tst a
	jle no_sorting_needed

	jsr	general_sort_routine

	move #polygon_sort_list,r1

	move x:visible_poly_count,n6
	do	n6,_handle_sorted_list
;Main Polygon Loop:
; These three will be automatically calculated when sorting added:
		move (r1)+			;ignore z coord
		move x:(r1)+,n4		;*number of polygon* - now look up in list
; Ignore flat shade etc:
; Look up in list:
		move #visible_buffer,r4
		nop
		move y:(r4+n4),x0			; ignore pipeline error
		nop
		move #polygon_list,r4
		nop
		move y:(r4+n4),r4			; ignore pipeline error
		move x0,x:current_clipmask

; Handle poly from now on
		move y:(r4)+,n4
		move y:(r4)+,x1
		move r4,x:save_r4
		move n4,x:polygon_points
		move n4,x:original_polygon_points
		move x0,x:polygon_shade			;usually unnecessary...
		move x1,x:polygon_colour

		move r1,x:save_r1
		move r5,x:save_r5
		jsr handle_general_polygon
		move x:save_r1,r1
		move x:save_r5,r5
_handle_sorted_list
no_sorting_needed:
	rts

prepare_poly_address_list
	move x:object_address,r0
	move #>O_Poly_Ptr,n0
	move #polygon_list,r1
	move y:(r0+n0),r4
	move #>O_Polys,n0		;IGNORE ERROR
	nop
	move y:(r0+n0),n6		;number of polys
	nop
;Main Polygon Loop:
	do n6,_loop
		move r4,y:(r1)+		;save address
		move y:(r4)+,n4		;get offset
		move (r4)+			;ignore flat shade
		lua (r4)+n4,r4		;skip n vertices
		nop					;pipeline!!
_loop:	rts


prepare_sort_buffer:
	move #0,r5					;number of polygons visible
	move #0,r6					;number of polygons visible
	move x:object_address,r0
	move #>O_Polys,n0
	move #visible_buffer,r1
	move y:(r0+n0),n6			;number of polys
	move #polygon_sort_list,r2	;X memory
	move #rotated_buffer+0,r3	;Y memory - z coord!!
	move #polygon_list,r4		;Y memory
	move #2,n0					;offset to first vertex

	do n6,_prep_loop
		move y:(r1)+,a
		move y:(r4)+,r0			;polygon address...
		tst a
		jmi _dont_get
		move y:(r0+n0),n3		; Need to store the z-coord
								; and polygon number
; Need to divide the vertex offset by 3!!!
; - No longer needed
		nop
		move y:(r3+n3),x0
		move x0,x:(r2)+			;store z
		move r6,x:(r2)+			;store poly number
		move (r5)+
_dont_get
		move (r6)+				;next polygon!
		nop
_prep_loop
 	move r5,x:visible_poly_count
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
;****************************************************************
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
	move #scan_poly,r0		;r0 - first copy of poly (change 'x' values)
	asl a		r0,b
	add a,b	
	move b1,r1		;r1 - second copy of poly
	move x:polygon_points,n6
	move #2,n0		;BUG #34893849
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
	jsr calc_movement
	jsr rotate_routine			;user defined!
	jsr perspectivize			;... and add clipmasks

	jsr calc_visibility			; + calc polys' clipmasks

	move x:object_address,r0
	nop							;lard
	move y:(r0),a
	move a,x:object_type

	IF	flat_handler
	jsset #1,a,rotate_flat_normals		;flatshade
	ENDIF

	IF	gouraud_handler
	move x:object_type,a
	jsset #2,a,rotate_gour_normals		;gouraud
	ENDIF

	IF	envmap_handler
	move x:object_type,a
	jsset #4,a,rotate_envmap_normals	;envmap
	ENDIF

	IF	gouraud_handler
	move x:object_type,a
	jsset #5,a,rotate_gour_normals		;gouraud/texmap
	ENDIF

	IF	@def(shademap_handler)
	IF shademap_handler
	move x:object_type,a
	;jsset #7,a,rotate_gour_normals		;gouraud/texmap
	jsset #7,a,rotate_shademap_normals		;gouraud/texmap
	ENDIF
	ENDIF

	IF	@def(shademap_handler)
	IF shademap_handler
	move x:object_type,a
	jsset #8,a,rotate_envmap_normals
	ENDIF
	ENDIF

	;move x:object_type,a1
	;jsset #6,a,rotate_phong_normals	;phong

	move x:object_address,r0
	move #>O_Poly_Ptr,n0
	move #visible_buffer,r1
	move y:(r0+n0),r4
	move #>O_Polys,n0
	move x:object_type,a

; Choose routines
	IF flat_handler
	move #>1,n6				;assume 1 val/line
	move #handle_flat_poly,r6		;assume flat
	move #send_flat_poly,r5
	ENDIF

	IF	flat_handler
	jclr #1,a,_n1
	move #handle_flat_shade_poly,r6
	move #send_flat_shade_poly,r5		;lard
	move #>1,n6							;x
_n1:
	ENDIF

	IF	gouraud_handler
	jclr #2,a,_n2
	move #handle_gouraud_poly,r6
	move #send_gouraud_poly,r5
	move #>2,n6							;x,gouraud
_n2:
	ENDIF

	IF	texmap_handler
	jclr #3,a,_n3
	move #handle_texmap_poly,r6
	move #send_texmap_poly,r5
	move #>3,n6							;x,texx,texy
_n3:
	ENDIF

	IF	envmap_handler
	jclr #4,a,_n4
	move #handle_envmap_poly,r6
	move #send_envmap_poly,r5
	move #>3,n6							;x,texx,texy
_n4:
	ENDIF

	IF @def(shademap_handler)
	IF shademap_handler
	jclr #7,a,_n5
	move #handle_shademap_poly,r6
	move #send_shademap_poly,r5
	move #>4,n6							;x,texx,texy,gouraud
_n5:
	jclr #8,a,_n6
	move #handle_shademap2_poly,r6
	move #send_shademap2_poly,r5
	move #>5,n6							;x,gourx,goury,texx,texy
_n6:
	ENDIF
	ENDIF

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
	 move #>O_Point_Ptr,n1
	 jsr _conv_obj
	 move #>O_Poly_Ptr,n1
	 jsr _conv_obj
	 move #>O_Normal_Ptr,n1
	 jsr _conv_obj
	 move #>O_Gour_Ptr,n1
	 jsr _conv_obj
	 move #>O_Tex_Ptr,n1
	 jsr _conv_obj
	 move #>O_BSP_Ptr,n1
	 jsr _conv_obj
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
		include	'f:\dsp_new\asm\3dsys\scancon3.asm'
		include	'f:\dsp_new\asm\3dsys\new_bsp2.asm'
		include	'f:\dsp_new\asm\3dsys\newclip3.asm'
		include	'f:\dsp_new\asm\3dsys\gensort.asm'

	if @def(three_plane)
		include 'f:\dsp_new\asm\3dsys\hand_3p.asm'
	else
		include 'f:\dsp_new\asm\3dsys\hand_tc4.asm'
	endif

;-------------------------------------------------------

;-------------------------------------------------------
;-------------------------------------------------------
;-------------------------------------------------------
;-------------------------------------------------------
					org	x:
	
					IF	gouraud_handler
gouraud_colour_address	dc	gouraud_colours
					ELSE
gouraud_colour_address	dc	0
					ENDIF

one_over			ds	385
left_array			ds	5*200
right_array			ds	5*200
BSP_sorted_buffer	ds	maximum_objects+1

;-------------------------------------------------------
				IF	texmap_handler||envmap_handler
texmap_vertices:	dc	$7e0000,$7e0000
					dc	$7e0000,$020000
					dc	$000000,$020000
					dc	$000000,$7e0000
				ENDIF

polygon_sort_list	ds	maximum_polys*2
					dc	0,0,0,0,0,0,0,0

texmap_buffer
				IF	texmap_handler||envmap_handler||@def(shademap_handler)
					ds	64*64
				ENDIF

gouraud_colours
				IF	gouraud_handler
					ds	128*maximum_colours
				ENDIF
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
		
BSP_normals_buffer		ds	maximum_polys
						ds	30
BSP_stack				equ	*

visible_buffer			ds	maximum_polys
polygon_list			ds	maximum_polys
scan_poly				ds	2*20
rec_poly:				ds	2*20
input_poly:				ds	6*20
output_poly:			ds	6*20

cyber_file				ds	maximum_file_size
cyber_file_address_end:
