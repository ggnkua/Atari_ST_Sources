;
; Polygon handling routines
;

	IF	flat_handler
handle_flat_poly:
	;move x:save_r5,r5
	;jsr send_flat_poly
	;move x:save_r5,r5
	rts

handle_flat_shade_poly:
	;move x:save_r5,r5
	;jsr send_flat_shade_poly
	;move x:save_r5,r5
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
	movep x0,x:<<htx					; send colour
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
	move #>(128),y0
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
	jsr set_up_rotate

	move x:object_address,r0
	move #>O_Normal_Ptr,n0		;, normal_offset
	nop
	move y:(r0+n0),r6
	move #>O_Polys,n0
	move #light_rotated_matrix,r2
	move y:(r0+n0),n6			;+0, number_of_polys
	move r6,r5
	move r5,r4

	move #shade_normals_buffer+0,r0
	move #3,n0

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
	  move a1,y1							;y1 - x coord
  		   move	x:(r2)+,x0 y:(r6)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a	#unit_store,r1
	  move a,y0								;y0 - y coord
; Now compare with dot prod:
	  move #0.5,b
	  move 		x:(r1)+,x0
	  mac x0,x1,b	x:(r1)+,x0
	  mac x0,y1,b	x:(r1)+,x0
	  macr x0,y0,b	#light_rotated_matrix,r2
	  move b1,y:(r0)+						;n0
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
	move x:gouraud_colours_address,a0
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
	move #light_rotated_matrix,r2
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
	  macr x0,y0,b	#light_rotated_matrix,r2
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
	move #light_rotated_matrix,r2
	move #shade_normals_buffer+0,r0
	;-------------------
	do n6,_spin
	  move		x:(r2)+,x0 y:(r5)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mpy -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  mac -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  macr -y0,x0,b	#light_rotated_matrix,r2
; OK we now have x,y normals. We want the angle and the distance!?!
; to project them onto a cone, plane or something
	  asr a
	  add y1,a
	  asr b		a1,y:(r0)+
	  add y1,b
	  move b1,y:(r0)+
	  move (r0)+				;dummy value
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts

	ENDIF


	IF	texmap_handler
handle_texmap_poly:

; First get address of texture vertices
	move x:object_address,r0
	move #>O_Tex_Ptr,n0
	nop
	move y:(r0+n0),r6				;get texture value
	move #input_poly+2,r0			;x and y already done
	move x:polygon_points,n4
	move #>3,n0						;x,y,tex1,tex2,gouraud

	do n4,_get_point
		move y:(r4)+,n6		;fetch vertex offset
		nop
		lua (r6)+n6,r5
		nop
		move y:(r5)+,x1		;fetch texture value 1
		move x1,y:(r0)+		;
		move y:(r5)+,x1		;fetch texture value 2
		move x1,y:(r0)+n0
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
	move #texmap_buffer,r3

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

	  move x:(r0)+,y0	;xtex start
	  move a1,n2		;n2 = counter

	  move x:(r1)+,x1	;xtex end
	  move x:(r0)+,x0	;ytex start
	  move x:(r1)+,b	;ytex end
	  tst a
	  jmi _skip_line
	  jeq _skip_line
	  move x1,a
	  sub x0,b			;x0 original y value
	  sub y0,a			;y0 original x value
	  move x:(r2+n2),x1

	  move a,y1
	  mpy x1,y1,a		;a1 = xfracadd	 ;parallel moves?
	  move b,y1
	  mpy x1,y1,b		;b1 = yfracadd

	  move x0,a0		;ypos
	  move a1,x1		;xadd
	  move y0,a1		;xpos
	  move b1,x0

	  move #map_data,r4
	  move a0,y0		;copy first xpos
	  move y:(r4)+,y1	;y0 - multipliers

	  do n2,_send_pixel
	    mpy y0,y1,b		#>%111111000000,y0	;1 X MOVE FREE
	    and y0,b		y:(r4)-,y1			;2 X MOVE FREE
	    move a1,y0							;3
	    mac y0,y1,b		y:(r4)+,y1			;4 X MOVE FREE
	    add x,a			b1,n3				;5
	    move a0,y0							;6
	     wait_transmit
	    movep x:(r3+n3),x:<<htx				;7 (send)
_send_pixel:
_skip_line:
	nop
_no_poly
_scan_send_sides:
;---------------------------------------
	rts


; Same as texmap_poly but
; sends *offsets* instead of data values
; also divides all x-coords by 2

send_texmap9_poly:
	move #maptemp_x,r3
	move #maptemp_y,r4

	move #>"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>4,x0
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

; The actual 'draw' Loop
;---------------------------------------
	do n6,_scan_send_sides

	  move x:(r0)+,a
	  asr a			;halve
	   wait_transmit
	  move a1,x0
	  movep x0,x:<<htx	;_send_ left value

	  move x:(r1)+,a
	  asr a				;halve again, this is *horrible*!
	  move #0,a0
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx	;_send_ width
	  move x:(r0)+,y0	;xtex start
	  move a1,n2		;n2 = counter

	  move x:(r1)+,x1	;xtex end
	  move x:(r0)+,x0	;ytex start
	  move x:(r1)+,b	;ytex end
	  tst a
	  jmi _skip_line
	  jeq _skip_line
	  move x1,a
	  sub x0,b			;x0 original y value
	  sub y0,a			;y0 original x value
	  move x:(r2+n2),x1

	  move a1,y1
	  mpy x1,y1,a		;a1 = xfracadd	 ;parallel moves?
	  move b1,y1
	  mpy x1,y1,b		;b1 = yfracadd

; new arrangement:
; xpos : a1
; xadd : x0
; ypos : b1
; yadd : y0

	  move b1,x1		;save this
	  clr b
	  move x0,b1		;ypos
	  move a1,x0		;xadd
	  clr a
	  move y0,a1		;xpos
	  move x1,y0		;yadd
	  move #>128*128,x1

	  do n2,_send_pixel
		move b1,y:(r4)					;save current x
		move b1,y1		
	    mpy x1,y1,b			#>%11111110000000,x1
		and x1,b			#>128,x1
		move #0,b0
		move a1,y1
		mac x1,y1,b			#>128*128,x1
	     wait_transmit
	    movep b1,x:<<htx
		add x0,a			y:(r4),b1					;restore y
		add y0,b
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

	  move x:(r0)+,y0	;xtex start
	  move a1,n2		;n2 = counter

	  move x:(r1)+,x1	;xtex end
	  move x:(r0)+,x0	;ytex start
	  move x:(r1)+,b	;ytex end
	  tst a
	  jmi _skip_line
	  jeq _skip_line
	  move x1,a
	  sub x0,b			;x0 original y value
	  sub y0,a			;y0 original x value
	  move x:(r2+n2),x1

	  move a,y1
	  mpy x1,y1,a		;a1 = xfracadd	 ;parallel moves?
	  move b,y1
	  mpy x1,y1,b		;b1 = yfracadd

	  move x0,a0		;ypos
	  move a1,x1		;xadd
	  move y0,a1		;xpos
	  move b1,x0

	  move #>32*64*2,y0	;y0 - multipliers
	  move a0,y1		;copy first xpos

	  do n2,_send_pixel
	    mpy y0,y1,b		#>%111111000000,y0	;1
	    and y0,b		#>64,y0				;2
	    move a1,y1							;3
	    mac y0,y1,b		#>32*64*2,y0		;4
	    add x,a			b1,n4				;5
	    move a0,y1							;6
	     wait_transmit
	    movep x:(r4+n4),x:<<htx				;7 (send)
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

handle_shade030_poly:
; First get address of texture vertices
	move x:object_address,r0
	move #>O_Tex_Ptr,n0
	nop
	move y:(r0+n0),r6

	move #input_poly+2,r0			;x and y already done
	move x:polygon_points,n4
	move #>3,n0						;x,y,tex1,tex2,tex3

	do n4,_get_point
		move y:(r4)+,n6		;fetch vertex offset
		nop
		lua (r6)+n6,r5
		nop
		move y:(r5)+,x0		;fetch texture value 1
		move y:(r5)+,x1		;fetch texture value 2
		move y:(r5)+,y0		;fetch texture value 3 (shading)
		move y0,y:(r0)+		;
		move x0,y:(r0)+		;
		move x1,y:(r0)+n0
_get_point:
	rts

handle_shadez_poly:
; First get address of texture vertices
	move x:object_address,r0
	move #>O_Tex_Ptr,n0
	nop
	move y:(r0+n0),r6

	move #input_poly+2,r0			;x and y already done
	move x:polygon_points,n4
	move #rotated_buffer,r2			;to get the 

	move #>3,n0						;x,y,tex1,tex2,tex3
	move x:z_shade_multiplier,y1

	do n4,_get_point
		move y:(r4)+,n6		;fetch vertex offset
		nop
		lua (r6)+n6,r5
		move n6,n2
		move y:(r5)+,x0		;fetch texture value 1
		move y:(r2+n2),y0	;shading goes in first...
		move y:(r5)+,x1		;fetch texture value 2
		move r0,r1
		move (r0)+
		move x0,y:(r0)+		;
		move x1,y:(r0)+n0
		mpy y1,y0,a			#>$7fffff,x0
							;adjust this for correct shading
							;may need to clip values here!
		move a1,b2			;ensure b2 is signed
		move a0,b1
		move x:z_shade_add,x1
		add	x1,b
; add on the extra texture value here
		cmp x0,b		#>$1000,x1
		tgt x0,b
		cmp x1,b
		tlt x1,b
		move b1,y:(r1)		;store shade value
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

	move #>6,x0
	wait_transmit
	movep x0,x:<<htx	; send signal

	;move x:polygon_colour,x0
	;wait_transmit
	;movep x0,x:<<htx	; send colour

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
	  move x:(r0)+,a
	  asr a			;halve
	   wait_transmit
	  move a1,x0
	  movep x0,x:<<htx	;_send_ left value

	  move x:(r1)+,a
	  asr a			;halve again, this is *horrible*!
	  move #0,a0
	  sub x0,a
	   wait_transmit
	  movep a1,x:<<htx	;_send_ width

	  ;move x:(r0)+,x0
	   wait_transmit
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
	move #light_rotated_matrix,r2
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
	  macr x0,y0,b	#light_rotated_matrix,r2
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

