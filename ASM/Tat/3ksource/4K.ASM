; 4K.ASM
; Steven Tattersall 1997
; Comments added 7/98
;
; Code for a small DSP graphics rendering system
; Full commenting added
; You can assemble this file using the Motorola DSP Assembler,
;  available free now I think
; It needs to be converted into a .CLD file but DHS have the utils
; to do this. Devpac DSP should also create the correct file format
;
;
;	Tabs should be set at '4' in an editor
;
;










;-----------------------------------------------------------------------
; These are my general "equates" that define general addresses,
; settings for the code


; BASE.ASM

;--------------------- EQUATES--------------------------


PBC		equ	$ffe0	;Port B Control register
PCC		equ	$ffe1	;Port C Control register
PBDDR	equ	$ffe2	;Port B Data Direction Register
PCDDR	equ	$ffe3	;Port C Data Direction Register
PBD		equ	$ffe4	;Port B Data register
PCD		equ	$ffe5	;Port C Data register
HCR		equ	$ffe8	;Host Control Register
HSR		equ	$ffe9	;Host Status Register
hsr		equ	$ffe9

HRX		equ	$ffeb	;Host Receive Register
hrx		equ	$ffeb

HTX		equ	$ffeb	;Host Transmit Register
htx		equ	$ffeb

BCR		equ	$fffe	;Port A Bus Control Register

;-----------------------------------------------------------------------
; OB3 Equates:

; These define positions in the 3D object file that I use
; C_Length is at the start of the file

; in this demo, the header is stripped out - we only have 1 object
; So you can ignore these
C_Length	equ	0		;overall length of the file
C_ObjCount	equ	1		;how many objects are there?
C_BSP		equ	2		;pointer to BSP object (unused)
C_Objects	equ	3		;list of all the positions of the objects
						;in the file. these are usually stored as
						;an offset into the file, but in the 4K
						;demo they have been hand-altered to point
						;to an absolute address



; These define data referring to each object in the file
; In this example these are at the start of the file
; Positions are stored as relative to the start of the file
; These have been optimised by auto-adding the start value
; "by hand" in the object file

O_Points	equ	0		;number of points
O_Point_Ptr	equ	1		;position of the 3D point data
O_Polys		equ	2		;number of polys
O_Poly_Ptr	equ	3		;position of the polygon descriptions
O_Gour_Ptr	equ	4		;position of the shading normals, used
						;in the environment mapping routine


OFF			equ	0
ON			equ	1


;--------------------- MACROS --------------------------
; These are used for "handshaking" to ensure safe transfer
; to/from the DSP. We loop in wait_receive until the host
; tells us that it is safe to put data in the host port
; registers

wait_receive	MACRO
				jclr	#0,x:<<HSR,*
				ENDM
wait_transmit	MACRO
				jclr	#1,x:<<HSR,*
				ENDM




;----------------------------------------------------------------------
; these are the names of bits used for clipping
; when we rotate a point, we check whether it is outside our
; clipping rectangle. If so, then we set the bit.

; This gives us a quick test to clip a polygon.
; we take the clipbits for each point in the polygon
; and "or" it with a regsiter. At the end we know
; which sides of the screen to clip against

xmin_bit		EQU	0
xmax_bit		EQU	1
ymin_bit		EQU	2
ymax_bit		EQU	3
;-----------------------------------------------------------------------



; Equates:
; these describe the maximum sizes of parts of the 3d file
;
;

maximum_points		EQU	250
maximum_file_size	EQU	3100
maximum_polys		EQU	360
maximum_objects		EQU	2
maximum_colours		EQU	1

; These are the settings for clipping
x_min				EQU	-160
x_max				EQU	+160
y_min				EQU	-120
y_max				EQU	+120

; This defines the perspective effect. A bigger number causes
; more obvious perspectivization
cpersp				EQU	2*25



;----------------------------------------------------------------------
	; START
	; when making a file for use by the XBIOS, the OS jumps
	; to p:0 after loading the file. Therefore we need to
	; have installed a 'jmp' to the start of our program
	org	p:$0
	jmp $210						;run it



;----------------------------------------------------------------------
	org p:$210

	; General code to initialise port B
	; (the host port interface)
	; These are probably unnecessary

	movep	#>0,x:<<$fffe			; BCR port B bus control
	movep	#$c00,x:<<$ffff			;     interrupt priority
	movep	#>1,x:<<$ffe0			; PBC port B control
	movep	#>4,x:<<$ffe8			;     host control
	andi	#$fc,mr					; allow all interrupts

; First the 4K demo wants a copy of the sine table which is stored
; in the DSP
; It lives at position y:$100 and is 256 words in size
; Send internal sine wave:
	move #%000000100,omr				;switch on internal sine rom
	do #2,_loop1
	  move #$100,r0
	  do #256,_loop2
	   move y:(r0)+,x0
	   wait_transmit
	   movep x0,x:<<htx
_loop2:
	nop
_loop1:
	andi #%11111011,omr				;switch off internal sine rom
; Now get a copy of the "one_over" table, which is used for quick
; interpolation in scan_conversion and texture-mapping
; This is the set of values "$7fffff/x"
; They can be used to "divide" a value by x, by using a multiply
; instead - this is much quicker


	move #one_over,r0
	move #384,n0
	jsr get_x_memory

; Now receive the texture used in mapping from the 68030
	jsr	receive_texmap

; The following is the main loop. We:-
; - receive our position in the world
; - receive the rotation of the world
; - go and draw the object

; This is called several times, one for each fish!

handle_file:
	jsr receive_viewpoint
	jsr	receive_rotation
	jsr handle_object

object_finished:

; Now that we are finished we tell the 68030 that this is so
; by sending the value "-1"
	wait_transmit
	move #-1,x0				; "END"
	movep x0,x:<<htx
	jmp	handle_file






;-----------------------------------------------------------------
handle_object:
	move #cyber_file,a
	move a1,x:object_address

	jsr prepare_object

; Main Polygon Loop:
	do n0,polygon_loop
; These three will be automatically calculated when sorting added:
	  move y:(r1)+,a

	  move y:(r4)+,n4
	  move y:(r4)+,x1

	  move r4,x:save_r4
	  move n4,x:polygon_points
	  move n4,x:original_polygon_points
	  tst a
	  jmi _poly_invisible				;

	  move x1,x:polygon_colour
	  move a1,x:current_clipmask
	  move r1,x:save_r1
		jsr handle_general_polygon
	  move x:save_r1,r1

_poly_invisible:
	  move x:save_r4,x1
	  move x:original_polygon_points,a
	  add x1,a
	  move a,r4

polygon_loop:
	rts












;----------------------------------------------------------------------
handle_general_polygon:
		move #rotated_buffer+0,r2
		move #input_poly,r0
		move r0,x:poly_to_scan
		move #>$7fffff,a			;smallest z coord so far!

		move #shade_normals_buffer+0,r5
		move #shade_normals_buffer+1,r6

		do n4,_receive_point1
			move y:(r4)+,n2			;fetch vertex offset
			move n2,n5
			lua (r2)+n2,r3
			move n2,n6
			move y:(r3)+,x0			; organize to x,y buffers for speed!
			move y:(r3)+,x0			;
			move x0,y:(r0)+			;copy x
			move y:(r3)+,x0
			move x0,y:(r0)+			;copy y
		    move y:(r5+n5),x0		;fetch gouraudx normal value
			move x0,y:(r0)+
		    move y:(r6+n6),x0		;fetch gouraudx normal value
			move x0,y:(r0)+
_receive_point1:

; Now get the specialized stuff i.e. gouraud, texmap

		move x:save_r4,r4
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







;----------------------------------------------------------------------



scan_convert_all:
;---------------------------------------------------------------------
; set_up_x_y:
; This rout simply copies x and y points from input_poly
;	 _twice_ to scan_poly. It also gets the limits.

set_up_x_y:
	move x:poly_to_scan,r4
	move #>3,n4
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

	move #>3,r6
	move r6,a

	move (r6)-						;x array already done!
	move x:poly_to_scan,a
	move #>2,x0
	add x0,a
	move a1,r4

; We need to save the regs each time
	do r6,_convert_loop
;set_up_general_2:
		move #>4,n4
		move r4,x:save_r4_again

		move x:polygon_points,a
		move #scan_poly,r0			;r0 - first copy of poly
									;(change 'x' values)
		asl a		r0,b
		add a,b	
		move b1,r1					;r1 - second copy of poly
		move #2,n0					;BUG #34893849
		move x:polygon_points,n6
		move n0,n1
	;-----------LIMITS LOOP-----------------
		do n6,_setup_loop
			 move y:(r4)+n4,x0		;fetch gour val
			 move x0,y:(r0)+n0		;store it
			 move x0,y:(r1)+n1		;...twice
_setup_loop:

		move x:left_array_ptr,r0
		move x:right_array_ptr,r1
		move (r0)+
		move (r1)+
		move r0,x:left_array_ptr
		move r1,x:right_array_ptr
		 jsr convert_scan
		move x:save_r4_again,r4
		nop
		move (r4)+
_convert_loop:
_dont_convert:
	jmp send_envmap_poly
_no	rts







;----------------------------------------------------------------------


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
	move #>3,n1

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
	jsr rotate_points			;user defined!
	jsr perspectivize			;... and add cliptmasks
	jsr calc_visibility			; + calc polys' clipmasks
	jsr rotate_envmap_normals	;envmap

	move x:object_address,r0
	move #>O_Poly_Ptr,n0
	move #visible_buffer,r1
	move y:(r0+n0),r4
	move #>O_Polys,n0

	move #>3,n6							;x,texx,texy
	move y:(r0+n0),n0					;get poly data addr
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

; Given 3 angles this calculates a 3x3 rotation matrix
; suitable for world rotation

;  Uses following matrix:
; 1,2,3 (+cosYcosZ -cosXcosYsinZ-sinXsinY +sinXcosYsinZ-cosXsinY )
; 4,5,6 (  +sinZ          cosXcosZ               -sinXcosZ       )
; 7,8,9 (+sinYcosZ -cosXsinYsinZ+sinXcosY +sinXsinYsinZ+cosXcosY )

; Once rotated, points stored as z (for perspective), then x and y
;   with y negativized for screen co-ordinates layout.
;   Hence [7,8,9] above are placed in the matrix first



calculate_trig:
	move	#-1,m2
; First do +sinXsinZ ---> y0
	move	x:sinX,x0
	move	x:sinZ,x1
	mpy		+x0,x1,a
	move	a1,y0
;          -cosXsinZ ---> temp1
	move	x:cosX,x0
	move	x:sinZ,x1
	mpy		-x0,x1,a	x:sinY,x0
	move				a1,x:temp1
;-----------------------------------------------------------------
	move				x:cosZ,x1
	mpy		+x0,x1,a	x:sinY,x0
	move 	a1,x:(r2)+					;7 sinYcosZ
	move				x:temp1,x1
	mpy		+x0,x1,a	x:sinX,x0
	move				x:cosY,x1
	mac		+x0,x1,a	x:sinY,x0
	move	a1,x:(r2)+					;8 -cosXsinYsinZ+sinXcosY
	mpy		+y0,x0,a	x:cosX,x0
	move				x:cosY,x1
	mac		+x0,x1,a	x:cosY,x0
	move	a1,x:(r2)+					;9 +sinXsinYsinZ+cosXcosY
;-----------------------------------------------------------------
	move				x:cosZ,x1
	mpy		x0,x1,a		x:cosY,x0
	move	a1,x:(r2)+					;1 cosYcosZ
	move				x:temp1,x1
	mpy		+x0,x1,a	x:sinX,x0
	move				x:sinY,x1
	mac		-x0,x1,a	x:cosY,x0
	move	a1,x:(r2)+					;2 -cosXcosYsinZ-sinXsinY
	mpy		+x0,y0,a	x:cosX,x0
	move				x:sinY,x1
	mac		-x0,x1,a	x:sinZ,x0
	move	a1,x:(r2)+					;3 +sinXcosYsinZ-cosXsinY
;---------------------------------------------------------------
	move	x0,x:(r2)+					;4 sinZ
	move				x:cosX,x0
	move				x:cosZ,x1
	mpy		+x0,x1,a	x:sinX,x0
	move	a1,x:(r2)+					;5 sinXcosY
	move				x:cosZ,x1
	mpy		-x0,x1,a
	move	a1,x:(r2)+					;6 cosXcosY
	rts



;-------------------------------------------------------
; This rotates the x,y,z values of the centre of the object
; It needs to be rotated to put the object in the right position
; in a rotated world
;


calc_movement:
; First, calculate the viewer position offsets.
; These must be rotated too!
	move #viewer_z,r4
	move #matrix,r2
	move r4,r5
	move r5,r6

	move #camera_z,r3
	move #viewer_offset,r0

calc_one_rotation:
	  move y:(r3)+,a
			 move	x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r6)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	move a1,y:(r0)+
	  move y:(r3)+,a
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r5)+,y0
	mac y0,x0,a		x:(r2)+,x0 y:(r4)+,y0
	move a1,y:(r0)+
	  move y:(r3)+,a
	mac -y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	mac -y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	mac -y0,x0,a
	move a1,y:(r0)+
	rts

; this rotates the points in the object
; and puts them in "rotated_buffer"
;

rotate_points:
	move x:object_address,r0
	move #>O_Point_Ptr,n0
	nop
	move y:(r0+n0),r4
	move x:object_address,r0
	move #O_Points,n0
	move r4,r5
	move y:(r0+n0),n0						;number of points to do
	move r5,r6

	move #rotated_buffer,r0
	;-------------------
	do n0,_spin
	  move #viewer_offset,r3
	  move #matrix,r2
	  jsr calc_one_rotation
	  nop									;OPTIMIZE!
_spin:
	;-------------------
	rts


; this rotates the surface normals of the object
; to work out the shading values


rotate_envmap_normals:
;    with my unit_store vector
	move x:object_address,r0
	move #>O_Gour_Ptr,n0		;, gouraud_offset
	nop
	move y:(r0+n0),r6
	move #>O_Points,n0
	move r6,r5
	move y:(r0+n0),n6		;+0, number_of_points

	move #0.5,y1
	move #0,x1
	move #matrix+3,r2
	move #shade_normals_buffer+0,r0
	;-------------------
	do n6,_spin

	  move			x:(r2)+,x0 y:(r5)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r6)+,y0

	  mpy -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  mac -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  macr -y0,x0,b	#matrix+3,r2
	  asr b
	  add y1,b
	  asr a		b,y:(r0)+
	  add y1,a
	  move a,y:(r0)+
	  move (r0)+				;dummy value
_spin:
	rts



; This routine checks whether the polygons are "visible" or not
; i.e. whether it is turned towards the viewer
;
; If it is, then we then get the clipmasks of the points in that
; polygon and "or" them to work out which clipping we need for
; each poly

; We can also do a fast check by "and"ing the clipmasks for all the
; points: If the one bit is set for all points, then the whole object
; must be offscreen too, so we can ignore it


calc_visibility:
										;optimised september 96
	move x:object_address,r0
	move #O_Polys,n0					;number of polygons
	move #visible_buffer,r6
	move y:(r0+n0),n6					;get poly_count
	move #O_Poly_Ptr,n0
	move #rotated_buffer+1,r2			;use now-perspectivized co-ords!
	move y:(r0+n0),r0

	do n6,_polygon_loop
		move y:(r0)+,n1					; get count
		move (r0)+						; skip colour
		move r0,r1						; save Vertex 1 address

		move y:(r0)+,n2					; ---- Get Vertex A nr
		nop
		lua (r2)+n2,r3					;
		move y:(r0)+,n2					; ---- Get Vertex B nr
		move y:(r3)+,x0					; r3 - VertA address
		lua (r2)+n2,r4					; r4 - VertB address
		move y:(r3)-,x1					;
		move y:(r4)+,a					; pipelining w.e.f. here
		move y:(r4)-,b					; remember this point?
		sub x0,a		y:(r0)+,n2		; ---- Get Vertex C nr
		sub x1,b		y:(r4)+,y0		; r4 vertB address (still!)
		move a1,x0						;yuk, ugly
		move b1,x1
		lua (r2)+n2,r5					; r5 - vertC address now
		move y:(r4)-,y1					; ignore pipeline error
		move y:(r5)+,a					; pipeline w.e.f. here
		move y:(r5)-,b
		sub y1,b						;**** spare parallel move
		sub y0,a		b,y1
		lua (r1)+n1,r0					; move to next poly data
		mpy +x0,y1,a	a,y0
		mac -x1,y0,a					;**** spare parallel move
		jle _polygon_invisible

; Phase Two:  Get clipmasks and AND them together

		clr a			#clipmask_buffer,r4
		clr b			y:(r1)+,n4
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
receive_rotation:
	move #cosX,r0
	move #6,n0
	jsr get_x_memory
	move #matrix,r2
	jsr calculate_trig
	rts

receive_viewpoint:
	move #viewer_z,r0
	do #7,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+					;OPTI change to x memory
_get:
	rts


;---------------------------------------------------------------------
; convert_scan:
; The actual scan converter, adaptable for gour and map routs
;       r0,r1 - address of left, right arrays
;       x0    - offset step: 1-flat shade, 2-gouraud, 3-xy mapping etc


convert_scan:
	move x:polygon_points,n0
	move x:top_address,r6
	move #one_over,r3
	move r6,r5
	move (r6)+
	move (r6)+			;move it on to next pt
; r5 = pt1, r6 = next pt
;----------------------------------------
	do n0,do_line
	  move y:(r5)+,x0				;x co-ords
	  move y:(r6)+,x1
	  move y:(r5)+,a				;y co-ords
	  move y:(r6)+,b
	  sub a,b						;right hand side. That's 'easy'
	  jlt _do_left_side				;aha!
	  jle dont_do_it
	  move x:right_array_ptr,r2
	  jmp scan_carry_on

_do_left_side:
	    add b,a		x0,y1			;restore a
	    neg b		x1,x0
	    move 		y1,x1			;swap x0 and x1
	    move x:left_array_ptr,r2
scan_carry_on:
	  move x:top_height,y1
	  sub y1,a		#>3,y0 			;a = offset
	  move a,y1
	  mpy y0,y1,a	b1,n3
	  asr a			x1,b			;halve for fractional silliness
	  move a0,n2
	  sub x0,b		x:(r3+n3),y1	; y1 = 1/(y1-y0)
	  lua (r2)+n2,r2
	  move x0,a
	  move b1,x1					; x1 = x1-x0
	  mpy x1,y1,b	y0,n2 			;  b = x1/(y1-y0)
	  move #>$800000,a0
	  rep n3
	    add  b,a	a1,x:(r2)+n2	;
dont_do_it:
	  nop							;hoargh.
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
; This is a full general clipping routine. It makes extensive
; use of macros and is the largest part of the demo!

; The input polygon is in "input_poly" and of the form:

; x1,y1,envmapx1,envmapy1
; x2,y2,envmapx2,envmapy2
;...

; output goes to output_poly in the same form
; 'n6' is a bit mask telling the rout which sides to clip
; the poly against

; It clips the x,y values and also corrects the envmap values
; I think there are bugs in this version. The Sonolumineszenz
; code is definitely correct, use that instead




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
		jsr clipit
		ENDM

clipit:
		sub x1,a
		move a,y1
		move x1,a			;was a1
		macr y0,y1,a		;was 'mac'
		move a1,y:(r3)+
		rts

do_clip_reverse		MACRO addr1,addr2
		move y:\addr2,x1
		move y:\addr1,a
		jsr clipit
		ENDM


handle_x_y_clip:
	move #>4,a						;Number of values to clip
									;i.e. x,y, envmap1, envmap2
	move #>3,b
	move #>1,x0

	sub x0,b
	move a,n5						;don't change n5!
	move b,n3						; or n3 or n6

	move #input_poly,r0				;r0 - input
	move #output_poly,r1			;r1 - output


; Calculate end of poly:
	move r0,x1						;r2 - end of input poly
	move x:polygon_points,x0
	move #>2,y0						;automatically doubled
	mpy x0,y0,a
	move a0,a
	add x1,a
	move a,r2						;(used for copying endbit!)

	move x:current_clipmask,n6
	move x:polygon_points,a
	move a1,r6							;OPTI if desperate
										;do all four if mask<>0
										;else do none
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

;------------------------------------------------------
do_x_min_clip:
	copy_extra_clip s1
	move #0,r6							;this is my counter
	move r1,r3
	move r0,r4
	do a,_test_next_point
	 move n5,n4
	 move y:(r4),a						;fetch x coord 1
	 move x:xmin,x1
	 cmp x1,a			y:(r4+n4),b		;fetch x coord 2
	 jge _inside
; We're outside. If other point is too, then don't do anything
	 cmp x1,b
	 jlt _both_outside
; Now the second is inside.... (do clipping)	
	 jsr actual_x_clip
	 jmp _no_move
_inside:
	 copy_r4_point s2					;keep r4 the same
	 cmp x1,b
	 jge _move_on						;do other point next time
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
	 ;nop
	 move n5,b
	 move y:(r4+n4),a		;fetch x coord 1
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
	move b1,x1				;24 bit signed frac
	clr b					;assume empty
	cmp x1,b				;is it 0?
	jeq _nodivide

	move #$7fffff,b0		;i.e. '1'...
	and #$fe,ccr			;clear carry bit
	rep #24
	 div x1,b
	bclr #23,b0
; b0 is now (1/b)
	move b0,y0				;there must be a better
	move a1,y1				;way than this!
	mpy y0,y1,a
	move a0,y0				;y0 is my multiplier...
_nodivide
	rts

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
	do #3,_c2
	 do_clip (r4)+,(r4+n4)		;y
	 nop
_c2	increase_clip_count
	rts

x_clip_two
; Swap a and b round? ie. so b is the positive offset and a is the
; smaller value (ie. original b)
	neg b							;b=a-b a=a
	move y0,a
; Now we have swapped a and b round
	sub x1,a	(r4)+
	neg a							;???why always negative???
	jsr do_divide_clip

; Fetch X and Y and interpolate
	do #3,_c2
	  do_clip_reverse (r4)+,(r4+n4)
	 nop
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
	do #2,_c2
	  do_clip (r4)+,(r4+n4)
	 nop
_c2	increase_clip_count
	rts

y_clip_two:
; Swap a and b round? ie. so b is the positive offset and a is the
; smaller value (ie. original b)
	neg b				;b=a-b a=a
	move y0,a
; Now we have swapped a and b round
	sub x1,a
	neg a							;???why always negative???
	jsr do_divide_clip

; Fetch X and Y and interpolate
	do_clip_reverse (r4)+,(r4+n4)
	move (r3)+						;skip y - it's the same
	move (r4)+
	do #2,_c2
	  do_clip_reverse (r4)+,(r4+n4)
	 nop
_c2	increase_clip_count
	rts




;
; This is the routine that "draws" a polygon
; It sends the y-position of the top line, then the number of scanlines
;
; For each line it sends the left position and the width
; Then "x" words of screen data.
; That's it!
;
;-------------------------------------------------------------------------
send_envmap_poly:
	clr a				 x:top_height,x0
	 wait_transmit
	movep a,x:<<htx							; send signal

	 wait_transmit
	movep x0,x:<<htx						; send minimum y

	move x:polygon_height,a1
	move a1,n6
	 wait_transmit
	movep a1,x:<<htx						; send max y - min y

	move #left_array,r0
	move #right_array,r1
	move #one_over,r2
	move #texmap_buffer,r4					;topleft of map

; The actual 'draw' Loop
;---------------------------------------
	do n6,_scan_send_sides
	  move x:(r0)+,x0
	   wait_transmit
	  movep x0,x:<<htx					;_send_ left value
	  move x:(r1)+,a
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx					;_send_ width

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
	  mpy x1,y1,a						;parallel moves?
	  move b,y1
	  mpy x1,y1,b	a,x1
	  move x0,a1						;a1  - xfrac
	  move b,x0							;x0 - yaddfrac
	  move y0,a0						;a0  - yfrac
	  move #>32*64*2,y0					;y0 - multipliers
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
	move #>64*64,n0
	move #texmap_buffer,r0
get_x_memory
	do n0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	rts


;-------------------X MEMORY-----------------------------
					org	x:$000
cosX					ds	1
sinX					ds	1
cosY					ds	1
sinY					ds	1
cosZ					ds	1
sinZ					ds	1
temp1					ds	1
matrix					ds	9
light_matrix			ds	9
unit_store				ds	3
original_polygon_points
						ds	1
polygon_points			ds	1				;ScanConv labels
polygon_end_address		ds	1
scan_offset				ds	1
top_address				ds	1
top_height				ds	1
polygon_height			ds	1
polygon_colour			ds	1
left_array_ptr			ds	1
right_array_ptr			ds	1
array_offset			ds	1
point_offset			ds	1

; Clipping:
save_r1					ds	1
save_r4					ds	1
save_r4_again			ds	1

object_address			ds	1
current_clipmask		ds	1

poly_to_scan			ds	1			;dc	input_poly

xmin					dc	x_min
xmax					dc	x_max
ymin					dc	y_min
ymax					dc	y_max
	
;-------------------------------------------------------
texmap_buffer			ds	64*64
;-------------------------------------------------------
one_over				ds	385
left_array				ds	3*240				;x,tex-x,tex-y
right_array				ds	3*240


;-------------------------------------------------------

					org	y:$b00
viewer_z				ds	1
viewer_x				ds	1
viewer_y				ds	1

camera_z				ds	1
camera_x				ds	1
camera_y				ds	1

viewer_size				ds	1
viewer_offset			ds	3

rotated_buffer			ds	3*maximum_points

shade_normals_buffer	ds	3*maximum_points
clipmask_buffer			equ shade_normals_buffer+2

visible_buffer			ds	maximum_polys

scan_poly				ds	2*20
rec_poly:				ds	2*20
input_poly:				ds	6*20
output_poly:			ds	6*20

cyber_file:
fish:					include	"fish.obj"

cyber_file_address_end:

