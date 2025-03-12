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

	  move a1,x1		;x1 - xaddfrac
	  move x0,a1		;a1  - xfrac
	  move b1,x0		;x0 - yaddfrac
	  move y0,a0		;a0  - yfrac
	  move #>32*64*2,y0	;y0 - multipliers
	  move a1,y1

	  do n2,_send_pixel
	    mpy y0,y1,b		#>%111111000000,y0	;1
	    and y0,b		#>64,y0				;2
	    move a0,y1							;3
	    mac y0,y1,b		#>32*64*2,y0		;4
	    add x,a			b1,n4				;5
	    move a1,y1							;6
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
