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
;
; ---------------------------------------------------------------------

				setdefault	maximum_points,400
				setdefault	maximum_file_size,4000
				setdefault	maximum_polys,200
				setdefault	maximum_objects,3
				setdefault	maximum_colours,1

				setdefault	maximum_drawlist_count,5
				setdefault	maximum_drawlist_size,30
				setdefault	maximum_drawlist_buffer_size,200

				setdefault	maximum_world_size,10

				setdefault	maximum_object_count,200

				setdefault	flat_handler,OFF
				setdefault	gouraud_handler,OFF
				setdefault	texmap_handler,OFF
				setdefault	phong_handler,OFF
				setdefault	envmap_handler,OFF
				setdefault	shademap_handler,OFF
				setdefault	shademap2_handler,OFF
				setdefault	doublescan_adjust,ON

;--------------------X MEMORY---------------------------------------------
					org	x:$000
temp_x					ds	3				;roll-over buffer
cosX					ds	1
sinX					ds	1
cosY					ds	1
sinY					ds	1
cosZ					ds	1
sinZ					ds	1
temp1					ds	1
maptemp_x				ds	1

matrix					ds	9
light_matrix			ds	9
object_matrix			ds	9
light_rotated_matrix	ds	9
object_rotated_matrix	ds	9

unit_store				ds	3
original_polygon_points	ds	1
polygon_points			ds	1				;ScanConv labels
scan_offset				ds	1				;??
top_address				ds	1
top_height				ds	1
polygon_height			ds	1
polygon_colour			ds	1
polygon_shade			ds	1
current_shape			ds	1
left_array_ptr			ds	1
right_array_ptr			ds	1
array_offset			ds	1
point_offset			ds	1
	
;--------------------------------------------------------------------------

smallest_z_coord		ds	1
save_r0					ds	1
save_r1					ds	1
save_r4					ds	1
save_r4_again			ds	1
save_r5					ds	1
save_r6					ds	1
	
;--------------------------------------------------------------------------
file_address			ds	1
object_address			ds	1
object_type				ds	1
which_poly_routine		ds	1
which_draw_routine		ds	1
poly_to_scan			dc	input_poly
;--------------------------------------------------------------------------
	
xmin					dc	x_min
xmax					dc	x_max
ymin					dc	y_min
ymax					dc	y_max
c_persp					dc	50
z_shade_multiplier:		dc	50				;same as perspective?
z_shade_add:			dc	-$100000


current_clipmask		ds	1
visible_poly_count		dc	0

;--------------------------------------------------------------------------
											; Drawlist labels:
current_world_address: 	ds	1
current_drawlist_address ds	1
drawlist_object_count:	ds	1
drawlist_sort_flag:		ds	1
;--------------------------------------------------------------------------
				org p:

main_loop:
	clr a
	wait_receive
	movep x:<<hrx,x0							;Receive control word

	move #standard_command_list,r0
	move #_back1,r1
	jmp do_command_test
_back1:
	IF @def(user_command_list)
		move #user_command_list,r0
		move #main_loop,r1
		jmp do_command_test
	ELSE
		jmp main_loop
	ENDIF

do_command_test:
	move 	p:(r0)+,a						; command word
	move	p:(r0)+,r2						; address of routine
	tst a
	jmi (r1)
	cmp x0,a
	jne do_command_test
	jmp (r2)

standard_command_list:
				IF		gouraud_handler
				dc	"COL",receive_colours
				ENDIF

				dc	"CAL",calc_world
				dc	"HAN",handle_file			;obsolete for v2
				dc	"HA1",handle_one_object		;obsolete for v2

				dc	"OBJ",receive_object
				dc	"LIG",receive_light
				dc	"MAT",receive_rotation
				dc	"VIE",receive_viewpoint
				dc	"TEX",receive_texmap
				dc	"CLI",receive_clipping
				dc	"DLS",receive_drawlists
				dc	"WOR",receive_world
				dc	"OBS",receive_objects
				dc	"POI",receive_points
				dc	"TPO",receive_texture_points
				dc	"RTS",exit
				dc	-1

;----------------------------------------------------------------------
;
;													calc_world:
;
;----------------------------------------------------------------------
; 'calc_world' now means draw all the drawlists that are in
; the list...


calc_world:
	move #world_buffer,r0
	move r0,x:current_world_address

calc_next_drawlist:
	move x:current_world_address,r0
	move #drawlist_address_buffer,r1
	move x:(r0)+,x0
	move #>-1,a
	cmp	x0,a	x0,n1
	jeq object_finished						;-1 for end of world

	move r0,x:current_world_address

	move x:(r1+n1),r0						;r0 address of this drawlist
	nop
	
;----------------------------------------------------------------------
;
;													calc_drawlist:
;
;----------------------------------------------------------------------

; r0 address of this drawlist. Save r0 in current_drawlist_address
; before sorting and drawing...

calc_drawlist:
	move x:(r0)+,n6					; n6: number of objects in list
	move n6,x:drawlist_object_count
	move x:(r0)+,a1
	move a1,x:drawlist_sort_flag
									; ignore the sort flag for the moment
									; - assume it is to be sorted


; Stage 1
; Get the address, x, y and z of the object and copy them to
; drawlist_position_buffer.
; Translate x,y and z for camera movement and allow 3 free
; spaces for the rotated values.

	move #drawlist_position_buffer,r1

	do n6,_parse_drawlist
		move x:(r0)+,x0
		move #>Object_Size,y0
		mpy x0,y0,a		#object_buffer,x0
		asr a								;correct the multiplication
		move a0,a1
		add x0,a		#>Object_X,n2		;a now addr of object coords
		move a1,r2
		move #world_viewer_x,r4
		lua	(r2)+n2,r3						;r2: address of x,y and z
		move a1,y:(r1)+						;save the object address
		move x:(r3)+,a						;ideally, this needs lots
		move y:world_viewer_x,x0			;of parallel moves
		sub x0,a
		move a1,y:(r1)+
		move x:(r3)+,a
		move y:world_viewer_y,x0
		sub x0,a
		move a1,y:(r1)+
		move x:(r3)+,a
		move y:world_viewer_z,x0
		sub x0,a			#>3,n1
		move a1,y:(r1)+
		lua (r1)+n1,r1						;skip the next 3 spaces
_parse_drawlist:

; Now traverse the list of drawlist_position_buffer to
; generate drawlist_sort_list

; Copy the address to drawlist_sort_list
; Rotate the other coordinates using 'matrix' and copy to
; drawlist_position_buffer. Also copy the z coordinate to
; drawlist_sort_list.

	move #drawlist_position_buffer,r4		;r4: position_buffer
	move #drawlist_sort_list,r0				;r0: sort_buffer

	do n6,_make_sort_buffer
		move r4,x1
		move (r4)+							;ignore object address
		move #matrix,r2
		move r4,r5
		move r4,r6
			 move		x:(r2)+,x0 y:(r4)+,y0
		mpy y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
		mac y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
		macr y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
		move a1,y:(r4)+
		mpy y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
		mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
		macr y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
		move a1,y:(r4)+
		mpy y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
		mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
		macr y0,x0,a
		move a1,y:(r4)+
		move a1,x:(r0)+							;copy to sort_buffer too
		move x1,x:(r0)+							;then copy address
_make_sort_buffer
	move #-1,x0
	move x0,x:(r0)+
	move x0,x:(r0)+					;token to show list finished...


	move #drawlist_sort_list,r0
	move n6,n0						;number of objects

	move x:drawlist_sort_flag,a1
	jclr #0,a1,_nosort

	jsr	general_sort_routine
_nosort:

; OK now the sort list has been sorted to give the order to
; draw the objects.
; We now look back to the entry in the drawlist_position_buffer
; to give viewer_x/y/z. We also reference back to the original
; object_buffer to get the shape of the object.
; In future we will also reference rotation and/or bounding
; boxes, but for the moment this is enough ;)

	move #drawlist_sort_list,r0

calc_next_object:
	nop
	move (r0)+		
	move x:(r0)+,a							; r4 : addr of drawlist_position
											; -1 if finished
	tst a
	jmi calc_next_drawlist

	move a1,r4
	move r0,x:current_drawlist_address

	move #>3,n4
	move #>4,n2
	move y:(r4)+,r2							; r2 : addr of object info

	;lua (r4)+n4,r4
	nop
	move x:(r2)+n2,a1						;get shape used
											;copy x,y,z to viewer_x,y,z
	move a1,x:current_shape

	move y:(r4)+,x0
	move x0,y:viewer_x
	move y:(r4)+,x0
	move x0,y:viewer_y
	move y:(r4)+,x0
	move x0,y:viewer_z

	move r2,r0								;r0 address of angles
	jsr make_object_angles

	move #object_matrix,r2					;r2 destination
	jsr	calculate_trig

	move #matrix,r0
	move #object_matrix,r1
	move #object_rotated_matrix,r2
	jsr multiply_matrix

	move #light_matrix,r0
	move #object_matrix,r1
	move #light_rotated_matrix,r2
	jsr multiply_matrix

	move #-1,x0
	move x:current_shape,a
	cmp x0,a
	jeq	_lensflare

	jsr	handle_object_2
	move x:current_drawlist_address,r0
	jmp calc_next_object

_lensflare:
	jsr	handle_lensflare
	move x:current_drawlist_address,r0
	jmp calc_next_object


;---------------------------------------------------------------------
;
;													handle_file:
;
;---------------------------------------------------------------------
; Note: DO loop for main section not possible?

handle_file:
	move x:file_address,r0
	clr a
	jsr handle_object

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
	move #-1,x0				; "END"
	movep x0,x:<<htx
	ENDIF
	jmp main_loop


;---------------------------------------------------------------------
;
;													handle_one_object:
;
;---------------------------------------------------------------------

handle_one_object:
	 wait_receive
	movep x:<<hrx,a
	jsr handle_object
	jmp object_finished


handle_lensflare:
		jsr	calc_movement
		move #viewer_offset,r0

		move x:c_persp,x1			; x1 = 1/d
		move y:viewer_offset+2,y1
									; y1 = z+1/d			
		mpy x1,y1,a		y:viewer_offset,x0	; x0 = xcoord
		jle _failure				; IF non-positive, don't bother
		move a0,x1					; x1= z coord
		move y:viewer_size,a		; perspective size
		rep #$18					; p.coeff= k/(z+.25)
			div x1,a
		bclr #23,a0
		move a0,x1					;x1 = perspective coeff.
		mpy x1,x0,a		y:viewer_offset+1,x0
		mpy -x1,x0,b
		IF	doublescan_adjust
		asr b						;doublescan arse.
									;must fix the rotation routine!
		ENDIF
		move a1,x1
; Now send these coords
		move #"GET",a
_send_get:
		wait_receive
		movep x:<<hrx,x0
		cmp x0,a
		jne _send_get

		move #>5,x0		;routine number 5
		wait_transmit
		movep x0,x:<<htx	; send signal

		wait_transmit
		 movep x1,x:<<htx	;	was a1
		wait_transmit
		 movep b1,x:<<htx
		wait_transmit
		 movep x1,x:<<htx
_failure:
	rts

;---------------------------------------------------------------------
;
;													handle_object:
;
;---------------------------------------------------------------------
; a = number of object in cyber file
;---------------------------------------------------------------------
handle_object:
	move a1,x:current_shape
handle_object_2:

	move x:file_address,r0
	move #>C_Objects,x0
	move x:current_shape,a
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
;      ___[prepare_sort_buffer]
;    - sort the list with the general sort routine
;      ___[general_sort]
;    - for each poly, get the poly number, look up the poly address,
;      execute handle_general_polygon

	move	x:object_type,a
	jset	#16,a,handle_sorted_object			;testing

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

;---------------------------------------------------------------------

;												handle_sorted_object:

;---------------------------------------------------------------------
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
		move y:(r4+n4),x0
		move #shade_normals_buffer+0,r4
		move x0,x:current_clipmask		;fetch clipping information
		move y:(r4+n4),x0				;fetch polygon shading
		move #polygon_list,r4
		move x0,x:polygon_shade
		move y:(r4+n4),r4
		nop

; Handle poly from now on
		move y:(r4)+,n4
		move y:(r4)+,x1
		move r4,x:save_r4
		move n4,x:polygon_points
		move n4,x:original_polygon_points
		move x1,x:polygon_colour

		move r1,x:save_r1
		move r5,x:save_r5
		jsr handle_general_polygon
		move x:save_r1,r1
		move x:save_r5,r5
_handle_sorted_list
no_sorting_needed:
	rts

;---------------------------------------------------------------------

;												prepare_poly_address_list:

;---------------------------------------------------------------------
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


;---------------------------------------------------------------------

;												prepare_sort_buffer:

;---------------------------------------------------------------------
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
		move (r5)+				;
_dont_get
		move (r6)+				;increment polygon number
		nop
_prep_loop
 	move r5,x:visible_poly_count
	rts


;---------------------------------------------------------------------

;												handle_general_polygon:

;---------------------------------------------------------------------
handle_general_polygon:
		move #rotated_buffer+0,r2
		move #input_poly,r0
		move r0,x:poly_to_scan
		move x:array_offset,n0
		move #>$7fffff,a			;smallest z coord so far!

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

; Now get the specialized stuff i.e. gouraud, texmap:

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


;---------------------------------------------------------------------
scan_convert_all:
;---------------------------------------------------------------------
; set_up_x_y:
; This rout simply copies x and y points from input_poly
;	 _twice_ to scan_poly. It also gets the limits.

set_up_x_y:
	move x:poly_to_scan,r4
	move x:array_offset,n4
	move #scan_poly,r0			;r0 - first copy of poly
	move x:polygon_points,a		;USE MAC FOR SPEED
	asl a		r0,b
	add a,b	
	move b,r1					;r1 - second copy of poly
	move #>+$7fffff,a			;x0 minimum
	move #>-$800000,b			;x1 maxmimum
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
	move #>1,x0								;skip y,and self each time
	cmp x0,a
	jle _dont_convert

	move (r6)-								;x array already done!
	move x:poly_to_scan,r4
	move #2,n4								;skip x,y
	nop
	lua (r4)+n4,r4
	move r4,x:save_r4_again

; We need to save the regs each time
	do r6,_convert_loop
		jsr set_up_general_2
		move x:left_array_ptr,r0
		move x:right_array_ptr,r1
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
	move #scan_poly,r0						;r0 - first copy of poly (change 'x' values)
	asl a		r0,b
	add a,b	
	move b1,r1								;r1 - second copy of poly
	move x:polygon_points,n6
	move #2,n0
	move #2,n1
;-----------LIMITS LOOP-----------------
	do n6,_setup_loop
		 move y:(r4)+n4,x0				;fetch gouraud val
		 move x0,y:(r0)+n0				;store it
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
	move y:(r1+n1),n6				;number of points to do
	move #clipmask_buffer,r1
	move #3,n1

	do n6,_perspect
		move x:c_persp,x1			; x1 = 1/d
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
		mpy -x1,x0,b	a1,y:(r0)+
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
	nop							;
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

	IF shademap_handler
	move x:object_type,a
	;jsset #7,a,rotate_gour_normals		;gouraud/texmap
	jsset #7,a,rotate_shademap_normals		;gouraud/texmap
	ENDIF

	IF shademap_handler
	move x:object_type,a
	jsset #8,a,rotate_envmap_normals
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
	move #>1,n6						;assume 1 val/line
	move #handle_flat_poly,r6		;assume flat
	move #send_flat_poly,r5
	ENDIF

	IF	flat_handler
	jclr #1,a,_n1
	move #handle_flat_shade_poly,r6
	move #send_flat_shade_poly,r5	;lard
	move #>1,n6						;x
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

	jclr #9,a,_n7
	move #handle_texmap_poly,r6
	move #send_texmap9_poly,r5
	move #>3,n6							;x,texx,texy
_n7:
	ENDIF

	IF	envmap_handler
	jclr #4,a,_n4
	move #handle_envmap_poly,r6
	move #send_envmap_poly,r5
	move #>3,n6							;x,texx,texy
_n4:
	ENDIF

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
	jclr #10,a,_n10
	move #handle_shade030_poly,r6
	move #send_shademap_poly,r5
	move #>4,n6							;x,texx,texy,texz!
_n10:
	jclr #11,a,_n11
	move #handle_shadez_poly,r6
	move #send_shademap_poly,r5
	move #>4,n6							;x,texx,texy,depthshade
_n11:

	ENDIF

	move y:(r0+n0),n0			;get poly data addr
	move r6,x:which_poly_routine
	move n6,x:array_offset
	move n6,r6
	move r5,x:which_draw_routine
	move (r6)+
	move r6,x:point_offset
	rts



















;--------------------------------------------------------------------------
;
; 													calculate_trig:
; calculates 3x3 matrix
;
; INPUT  CosX --> SinZ
; OUTPUT X:(r2)+
;
;--------------------------------------------------------------------------
;  Uses following matrix:

; 1,2,3 (      +cosYcosZ              -cosYsinZ          -sinY   )
; 4,5,6 (+cosXsinZ-sinXsinYcosZ +cosXcosZ+sinXsinYsinZ -sinXcosY )
; 7,8,9 (+sinXsinZ+cosXsinYcosZ +sinXcosZ-cosXsinYsinZ +cosXcosY )

; NOTE: Points are initially stored for x,y,z(depth) which can be
;   altered for distortion.
; Viewer X,Y and Z positions should also be sent in this order!

; Optimised for speed/space improvement
; This was semi-removed after resorting the element list
;--------------------------------------------------------------------------
calculate_trig_2:
calculate_trig:
	jsr		init_trig
	jsr		calc_1
	jsr		calc_4
	jsr		calc_7
	rts


; 1,2,3 (      +cosYcosZ              -cosYsinZ          -sinY   )
; 4,5,6 (+cosXsinZ-sinXsinYcosZ +cosXcosZ+sinXsinYsinZ -sinXcosY )
; 7,8,9 (+sinXsinZ+cosXsinYcosZ +sinXcosZ-cosXsinYsinZ +cosXcosY )
init_trig:
; First do +sinYcosZ ---> y0
	move	x:sinY,x0
	move	x:cosZ,x1
	mpyr	+x0,x1,a
	move	a1,y0
;          +sinYsinZ ---> temp1
	move	x:sinY,x0
	move	x:sinZ,x1
	mpyr	+x0,x1,a
	move	a1,x:temp1
	rts

;--------------------------------------------------------------------------
; 1,2,3 (      +cosYcosZ              -cosYsinZ          -sinY   )
; 4,5,6 (+cosXsinZ-sinXsinYcosZ +cosXcosZ+sinXsinYsinZ -sinXcosY )
; 7,8,9 (+sinXsinZ+cosXsinYcosZ +sinXcosZ-cosXsinYsinZ +cosXcosY )
calc_1:
	move x:cosY,x0
	move x:cosZ,x1
	mpyr x0,x1,a
	move a1,x:(r2)+					;1 +cosYcosZ

	move x:cosY,x0
	move x:sinZ,x1
	mpyr -x0,x1,a
	move a1,x:(r2)+					;2 -cosYsinZ

	move x:sinY,a
	neg a
	move a1,x:(r2)+					;3 -sinY
	rts

;--------------------------------------------------------------------------
; 1,2,3 (      +cosYcosZ              -cosYsinZ          -sinY   )
; 4,5,6 (+cosXsinZ-sinXsinYcosZ +cosXcosZ+sinXsinYsinZ -sinXcosY )
; 7,8,9 (+sinXsinZ+cosXsinYcosZ +sinXcosZ-cosXsinYsinZ +cosXcosY )
calc_4:
	move x:cosX,x0
	move x:sinZ,x1
	mpy x0,x1,a
	move x:sinX,x0
	macr -x0,y0,a
	move a1,x:(r2)+					;4 +cosXsinZ-sinXsinYcosZ

	move x:cosX,x0
	move x:cosZ,x1
	mpy x0,x1,a	
	move x:sinX,x0
	move x:temp1,x1
	macr +x0,x1,a
	move a1,x:(r2)+					;5 +cosXcosZ+sinXsinYsinZ

	move x:sinX,x0
	move x:cosY,x1
	mpyr -x0,x1,a
	move a1,x:(r2)+					;6 -sinXcosY
	rts

;--------------------------------------------------------------------------
; 1,2,3 (      +cosYcosZ              -cosYsinZ          -sinY   )
; 4,5,6 (+cosXsinZ-sinXsinYcosZ +cosXcosZ+sinXsinYsinZ -sinXcosY )
; 7,8,9 (+sinXsinZ+cosXsinYcosZ +sinXcosZ-cosXsinYsinZ +cosXcosY )
calc_7:
	move x:sinX,x0
	move x:sinZ,x1
	mpy x0,x1,a
	move x:cosX,x0
	macr +x0,y0,a
	move a1,x:(r2)+					;7 +sinXsinZ+cosXsinYcosZ

	move x:sinX,x0
	move x:cosZ,x1
	mpy x0,x1,a	
	move x:cosX,x0
	move x:temp1,x1
	macr -x0,x1,a
	move a1,x:(r2)+					;8 +sinXcosZ-cosXsinYsinZ

	move x:cosX,x0
	move x:cosY,x1
	mpyr +x0,x1,a
	move a1,x:(r2)+					;9 +cosXcosY
	rts



;--------------------------------------------------------------------------

;													calc_movement

;--------------------------------------------------------------------------
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
	move y:camera_x,a
			 move	x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	macr y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	move a1,y:(r3)+
	move y:camera_y,a
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	macr y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
	move a1,y:(r3)+
	move y:camera_z,a
	mac y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
	macr y0,x0,a
	move a1,y:(r3)+
	rts


;--------------------------------------------------------------------------
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
	  move #object_rotated_matrix,r2
	  move y:(r3)+,a
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  move a1,x1
	  move y:(r3)+,a
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  move y:(r3)+,b
	  mac y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,b
	  move b1,y:(r0)+						;z
	  move x1,y:(r0)+						;x
	  move a1,y:(r0)+						;y
_spin:
	rts







;--------------------------------------------------------------------------
;												calc_visibility
;--------------------------------------------------------------------------
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
		move y:(r0)+,n1			; get count
		move (r0)+				; skip colour
		move r0,r1				; save Vertex 1 address
; Phase One
; Direction Check of polygon
		move y:(r0)+,n2			; ---- Get Vertex A nr
		nop	
		lua (r2)+n2,r3			; IgPiEr
		move y:(r0)+,n2			; ---- Get Vertex B nr
		nop
		lua (r2)+n2,r4			; r4 - VertB address
		move y:(r3)+,x0			; r3 - VertA address
		move y:(r3)-,x1			;
		move y:(r4)+,a			; pipelining w.e.f. here
		move y:(r4)-,b			; remember this point?
		sub x0,a	y:(r0)+,n2	; ---- Get Vertex C nr
		sub x1,b	y:(r4)+,y0	; r4 vertB address (still!)
		move a1,x0				;yuk, ugly
		move b1,x1
		lua (r2)+n2,r5			; r5 - vertC address now
		move y:(r4)-,y1			; ignore pipeline error
		move y:(r5)+,a			; pipeline w.e.f. here
		move y:(r5)-,b
		sub y1,b				;**** spare parallel move
		sub y0,a	b,y1

		lua (r1)+n1,r0			; move to next poly data
		mpy +x0,y1,a	a,y0
		mac -x1,y0,a			;**** spare parallel move
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




;--------------------------------------------------------------------------
;
;														receive_object
;
;--------------------------------------------------------------------------
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


;--------------------------------------------------------------------------
;
;														receive_light
;
;--------------------------------------------------------------------------
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

;----------------------------------------------------------------------
;
;													receive_colours:
;
;----------------------------------------------------------------------
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


;--------------------------------------------------------------------------
;
;														convert_file:
;
;--------------------------------------------------------------------------
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


;--------------------------------------------------------------------------
;
;													receive_rotation:
;
;--------------------------------------------------------------------------

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


;--------------------------------------------------------------------------
;
;													receive_viewpoint:
;
;--------------------------------------------------------------------------
receive_viewpoint:
	move #world_viewer_x,r0
	move #-1,m0
	do #7,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_get:
	jmp main_loop

;--------------------------------------------------------------------------
;
;													receive_clipping:
;
;--------------------------------------------------------------------------
receive_clipping:
	move #xmin,r0
	move #-1,m0
	do #7,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	jmp main_loop

;--------------------------------------------------------------------------
;
;													receive_one_over:
;
;--------------------------------------------------------------------------
receive_one_over:
	move #one_over,r0
	do #384,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	rts

;--------------------------------------------------------------------------
;
;													receive_drawlists:
;
;--------------------------------------------------------------------------
receive_drawlists:
	move	#drawlist_address_buffer,r0
	move	#drawlist_buffer,r1
	wait_receive
	movep	x:<<hrx,x0					;x0 number of lists
	do	x0,_receive_list
		move	r1,x:(r0)+				;save position of this list
		wait_receive
		movep	x:<<hrx,x1				;x1 length of list - 1
		move	x1,x:(r1)+				;save word
		wait_receive
		movep	x:<<hrx,y0				;sort flag
		move	y0,x:(r1)+
		do	x1,_receive_word
			wait_receive
			movep	x:<<hrx,y0			;object number
			move	y0,x:(r1)+
_receive_word:
		nop
_receive_list:
	jmp	main_loop

;--------------------------------------------------------------------------
;
;													make_object_angles:
;
; Calculates cos and sines for 3 angles
; INPUT   x:(r0) address of angles
; OUTPUT  x:CosX+  cos/sin values
;--------------------------------------------------------------------------
make_object_angles:
	move #cosX,r1
	move #>$ff,x0				;AND value
	move #>$40,x1

	ori #%000000100,omr			;switch on internal sine rom
	move #>$140,r2				;cos table
	move #>$100,r3				;sine table	
	move #>$ff,m2
	move #>$ff,m3
	do #3,_angloop
		move x:(r0)+,a1			;get angle
		and x0,a
		move a1,n3
		move a1,n2
		move y:(r3+n3),y0
		move y:(r2+n2),y1
		move y1,x:(r1)+			;cos
		move y0,x:(r1)+			;sin
_angloop:
	move #-1,m2
	move #-1,m3
	andi #%11111011,omr			;switch off sine rom
	rts


;--------------------------------------------------------------------------
;
;													multiply_matrix:
; Takes 2 3x3 matrices and multiplies them together
; INPUT  X:(R0)+  input matrix 1
;        X:(R1)+  input matrix 2
; OUTPUT X:(R2)+  output matrix
;--------------------------------------------------------------------------


multiply_matrix:
; r0 is the overall (top) row address. It cycles 0,0,0,3,3,3,6,6,6
; r3 is the row address used in multiplying (throwaway)

; r1 is the overall column address. It remains at 0
; r4 is the copy column address. It cycles 0,1,2,0,1,2,0,1,2
; r5 is the column address used in multiplying (throwaway)

		move #>3,n5
		move #>3,n0

		do #3,_matloop1
			move r1,r4						;reset r4
			do #3,_matloop2
				move r0,r3
				move r4,r5
				move x:(r3)+,x0
				move x:(r5)+n5,y0
				mpy x0,y0,a
				move x:(r3)+,x0
				move x:(r5)+n5,y0
				mac x0,y0,a
				move x:(r3)+,x0
				move x:(r5)+n5,y0
				macr x0,y0,a
				move a1,x:(r2)+					;output
				move (r4)+
_matloop2:
			move (r0)+n0						;update row
_matloop1:
		rts

;--------------------------------------------------------------------------
;
;													receive_world:
;
;--------------------------------------------------------------------------

receive_world:
	move #world_buffer,r0
	wait_receive
	movep x:<<hrx,x0					;first word is no of lists

	do x0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	move #-1,x0
	move x0,x:(r0)+						;end marker
	jmp	main_loop

;--------------------------------------------------------------------------
;
;													receive_objects:
;
;--------------------------------------------------------------------------
receive_objects:
	move #object_buffer,r0
	wait_receive
	movep x:<<hrx,n0					;first word is the offset
	wait_receive
	movep x:<<hrx,x0					;second word is the length
	lua (r0)+n0,r0
	do x0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	jmp	main_loop
		

;--------------------------------------------------------------------------
;
;													receive_points:
;
;--------------------------------------------------------------------------
receive_points:
	move #>O_Point_Ptr,n1
	jsr	get_object_address
	jsr	fetch_y_memory
	jmp	main_loop

receive_texture_points:
	move #>O_Tex_Ptr,n1
	jsr	get_object_address
	jsr	fetch_y_memory
	jmp	main_loop

get_object_address:
	move x:file_address,r0
	move #>C_Objects,x0
	 wait_receive
	movep x:<<hrx,a			;get object #
	add x0,a
	move a1,n0
	nop
	move y:(r0+n0),r1
	nop
	move y:(r1+n1),r0
	rts

fetch_y_memory:
	 wait_receive
	movep x:<<hrx,x0			;how many?
	do x0,_fetch_y
		 wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_fetch_y:
	rts

;--------------------------------------------------------------------------
		include	'd:\dsp\asm\3dsys\scancon3.asm'
		include	'd:\dsp\asm\3dsys\newclip3.asm'
		include	'd:\dsp\asm\3dsys\gensort.asm'
		IF @def(three_plane)
		include 'd:\dsp\asm\3dsys\hand_3p.asm'
		ELSE
		include 'd:\dsp\asm\3dsys\hand_tc4.asm'
		ENDIF

last_p_address:
;--------------------------------------------------------------------------

					org	x:
	
					IF	gouraud_handler||flat_handler
gouraud_colours_address	dc	gouraud_colours
					ELSE
gouraud_colours_address	dc	0
					ENDIF

one_over			ds	384
left_array			ds	5*200
right_array			ds	5*200

;--------------------------------------------------------------------------

				IF	texmap_handler||envmap_handler
texmap_vertices:	dc	$7e0000,$7e0000
					dc	$7e0000,$020000
					dc	$000000,$020000
					dc	$000000,$7e0000
				ENDIF

polygon_sort_list	ds	maximum_polys*2
					dc	0,0,0,0,0,0,0,0

; --------------------------------------------------------------------------
; BUFFERS FOR WORLD HANDLING:

world_buffer		ds	maximum_world_size

; Contains simply a list of drawlists to handle
; Format :
;                                word*N_Drawlists  index of each drawlist
;                                word              -1

; --------------------------------------------------------------------------
drawlist_address_buffer:
					ds	maximum_drawlist_count
; Contains the start addresses of all the drawlists

drawlist_sort_list	ds	maximum_drawlist_size*2
drawlist_buffer		ds	maximum_drawlist_buffer_size

object_buffer		ds	maximum_object_count*Object_Size


; --------------------------------------------------------------------------
texmap_buffer
					IF	texmap_handler||envmap_handler||shademap_handler
					ds	64*64
					ENDIF
gouraud_colours
					IF	gouraud_handler||flat_handler
					ds	128*maximum_colours
					ENDIF

;--------------------------------------------------------------------------

					org	y:0
maptemp_y			ds	1

					org	y:$1000
drawlist_position_buffer:
						ds	maximum_drawlist_size*Drawlist_Object_Size

map_data:				dc	64*64
						dc	64

map_data_128:			dc	128*128
						dc	128

map_data_256:			dc	256*256
						dc	256

temp_y					ds	3				;roll-over buffer!
unit_vector				dc	0,0,$3fffff

viewer_x				ds	1
viewer_y				ds	1
viewer_z				ds	1

world_viewer_x			dc	0
world_viewer_y			dc	0
world_viewer_z			dc	3000

camera_x				dc	0
camera_y				dc	0
camera_z				dc	$3fff

viewer_size				dc	25000
viewer_offset			ds	3

rotated_buffer			ds	3*maximum_points
shade_normals_buffer	ds	3*maximum_points
clipmask_buffer			equ shade_normals_buffer+2
		
visible_buffer			ds	maximum_polys
polygon_list			ds	maximum_polys

scan_poly				ds	2*20
rec_poly:				ds	2*20
input_poly:				ds	6*20
output_poly:			ds	6*20

cyber_file				ds	maximum_file_size
cyber_file_address_end:
;--------------------------------------------------------------------------
