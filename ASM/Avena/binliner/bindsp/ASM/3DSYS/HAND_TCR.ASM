handle_flat_poly
	rts


handle_flat_shade_poly:
	rts

;---------------------------------------
send_flat_poly:
	move #"GET",a
_send_get:
	wait_receive
	movep x:<<hrx,x0
	cmp x0,a
	jne _send_get

	move #>0,x0			;routine number
	wait_transmit
	movep x0,x:<<htx		; send signal

	move x:top_height,x0
	wait_transmit
	movep x0,x:<<htx		; send minimum y

	move x:polygon_height,x0
	move x0,n0
	wait_transmit
	movep x0,x:<<htx		; send max y - min y

	move #gouraud_colours+64,a0	; get middle value
	move #>(128/2),y0
	move x:polygon_colour,x0
	mac x0,y0,a
	move a0,r3
	wait_transmit
	move x:(r3),x0
	movep x0,x:<<htx		; send colour
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
	wait_transmit
	movep x0,x:<<htx	; send minimum y

	move x:polygon_height,x0
	move x0,n0
	wait_transmit
	movep x0,x:<<htx	; send max y - min y

	clr a
	move #gouraud_colours+64,a0 ; get middle value
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


;*********************************************************************
handle_gouraud_poly:
	move #shade_normals_buffer+0,r5
	move x:polygon_points,n4
	move #rec_poly+3,r0
	move #>4,n0		;x,y,z,gouraud
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
	move #gouraud_colours,a0
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
	move #matrix,r2
	move #shade_normals_buffer+0,r0
	;move #3,n0			;skip data (kludge)
	;-------------------
	do n6,_spin
	  move		x:(r2)+,x0 y:(r4)+,y0
	  mpy y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  asr a
	  add y1,a
	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r6)+,y0

	  mpy -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  mac -y0,x0,b	x:(r2)+,x0 y:(r6)+,y0
	  macr -y0,x0,b	#matrix,r2
; OK we now have x,y,z normals. We want the angle and the distance!?!
; to project them onto a cone, plane or something
	  asr a
	  add y1,a
	  asr b
	  add y1,b
	  move b,y:(r0)+
	  move a,y:(r0)+
	  move x1,y:(r0)+			;dummy value
_spin:
	;-------------------
	move #-1,m1
	move #-1,m2
	rts

;*********************************************************************
handle_texmap_poly:
	  move #texmap_vertices,a0
	  move a0,r5
	  move #rec_poly+3,r0
	  move x:polygon_points,n4
	  move #>4,n0
	  do n4,_get_point
	    move x:(r5)+,x1
	    move x1,y:(r0)+	;texmap val 1
	    move x:(r5)+,x0
	    move x0,y:(r0)+n0	;  ""   val 2
_get_point:
	rts

;*********************************************************************
handle_envmap_poly:
	move #shade_normals_buffer+0,r5
	move #shade_normals_buffer+1,r6
	move x:polygon_points,n4
	move #rec_poly+3,r0
	move #rec_poly+4,r1
	move #>5,n0		;x,y,z,gouraudx,gouraudy
	move n0,n1		;x,y,z,gouraudx,gouraudy
	do n4,_get_point
	  move y:(r4)+,n5	;fetch vertex offset
	  move n5,n6
	  move y:(r5+n5),x1	;fetch gouraudx normal value
	  move x1,y:(r0)+n0	;copy gouraud shade
	  move y:(r6+n6),x1	;fetch gouraudy normal value
	  move x1,y:(r1)+n1	;copy gouraud shade
_get_point:
	rts

;---------------------------------------
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
	rts			;adieu


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

	  move a,x1		;x1 - xaddfrac
	  move x0,a1		;a1  - xfrac
	  move b,x0		;x0 - yaddfrac
	  move y0,a0		;a0  - yfrac
	  move #>64*128*2,y0	;y0 - multipliers
	  move a1,y1
	  do n2,_send_pixel
	    mpy y0,y1,b		#>-127,y0		;1
	    and y0,b		#>128,y0		;2!
	    move a0,y1					;3!
	    mac y0,y1,b		#>64*128*2,y0		;4
	    add x,a		b1,n4			;5
	     wait_transmit
	    movep b1,x:<<htx			;7 (send)
	    move a1,y1					;6
_send_pixel:
_skip_line:
	nop
_no_poly
_scan_send_sides:
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

