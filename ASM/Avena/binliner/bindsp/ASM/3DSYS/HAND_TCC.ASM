handle_flat_poly:
handle_flat_shade_poly:
send_flat_poly:
send_flat_shade_poly:
rotate_flat_normals:
send_gouraud_poly:
handle_gouraud_poly:
rotate_gour_normals:
rotate_envmap_normals:
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
; Change later
	move x:current_object,x0
	wait_transmit
	movep x0,x:<<htx	; send texture number....

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
	    mpy y0,y1,b		#>-63,y0		;1
	    and y0,b		#>64,y0			;2
	    move a0,y1					;3!
	    mac y0,y1,b		#>64*64,y0		;4
	    add x,a		;b1,n4			;5
	     wait_transmit
	    movep b1,x:<<htx				;7 (send)
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
	rts			;adieu



















