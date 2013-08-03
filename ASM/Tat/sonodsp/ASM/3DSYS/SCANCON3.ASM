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
	  move #>$800000,a0
	;---------- FILL LOOP ----------
	  rep n3
	    add  b,a	a1,x:(r2)+n2	;,,wahnsinn''
	;-------------------------------
dont_do_it:
	  nop			;hoargh.
do_line:
	rts
