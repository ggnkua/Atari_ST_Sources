; (C) 1995,6 Steve Tattersall


;---------------------------------------------------------------------
; convert_scan:
; The actual scan converter, adaptable for gou and map routs
; NOTE: for gouraud and texture map routines this rout can be jumped
;       to after limit checking (see above)

;       r0,r1 - address of left, right arrays
;       x0    - offset step e.g. 1-flat shade, 2-gouraud, 3-xy mapping

; History 5.5.95 fix for different values of x0

convert_scan:
	move r0,x:left_array_ptr
	move r1,x:right_array_ptr
	move x0,x:array_offset

	move x:polygon_points,n0
	move x:top_address,r6
	move x:top_address,r5
	move (r6)+
	move (r6)+			;move it on to next pt

; r5 = pt1, r6 = next pt
;----------------------------------------
	do n0,do_line
	  move y:(r5)+,x0	;x co-ords:
	  move y:(r6)+,x1
	  clr a
	  clr b
	  move y:(r5)+,a	;y co-ords:
	  move y:(r6)+,b
	  cmp a,b
	  jlt do_left_side	;aha!

	  jle dont_do_it
	  sub a,b		;right hand side. That's 'easy'
	  move x:right_array_ptr,r2
	  jmp scan_carry_on
do_left_side:
	    move a,y1
	    move b,a
	    move y1,b		; swap a and b
	    sub  a,b
	    move x0,y1
	    move x1,x0
	    move y1,x1		; swap x0 and x1
	    move x:left_array_ptr,r2
scan_carry_on:
	  move x:top_height,y1
	  move b1,n3		;counter
	  sub y1,a	x:array_offset,y0	;a = offset
	  move a1,y1
	  mpy y0,y1,a
	  asr a			;halve for fractional silliness
	  move a0,n2

	  move x1,b
	  lua (r2)+n2,r2
	  move #one_over,r3
	  move x:array_offset,n2 ;for gouraud buffers etc. Just as fast
	  sub x0,b
	  clr a

	  move x0,a
	  move #>$800000,a0
	  move b1,x1		;x1= x1-x0
	  move x:(r3+n3),y1	;y1 = 1/(y1-y0)
	  mpy x1,y1,b		;b = x1/(y1-y0) i.e: what to add. easy.

	;---------- FILL LOOP ----------
; Now we can fill:
	  rep n3
	    add  b,a	a1,x:(r2)+n2
	;-------------------------------
dont_do_it:
	  nop			;hoargh.
do_line:
	rts



