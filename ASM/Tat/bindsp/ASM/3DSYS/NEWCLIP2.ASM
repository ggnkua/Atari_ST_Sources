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
	move b1,x1			;24 bit signed frac
	clr b				;assume empty
	cmp x1,b			;is it 0?
	jeq _nodivide

	move #$7fffff,b0	;i.e. '1'...
	and #$fe,ccr		;clear carry bit
	rep #24
	 div x1,b
	bclr #23,b0
; b0 is now (1/b)
_nodivide
	move b0,y0			;there must be a better
	move a1,y1			;way than this!
	mpy y0,y1,a
	move a0,y0			;y0 is my multiplier...
	rts

actual_x_clip:
	move x1,y:(r3)+			;store the clipped xcoord first
	sub a,b		#0,y0		;b = offset
	sub x1,a	(r4)+		;ignore xcoord now
	;jeq _zero
	neg a
	tst b
	jpl _pos
	neg a				;cunning!
	neg b
_pos
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

actual_y_clip:
	move n5,n4
	move (r3)+
	move x1,y:(r3)-			;store the clipped xcoord first
	sub a,b		#0,y0		;b = offset
	sub x1,a	
	;jeq _zero
	neg a
	tst b
	jpl _pos
	neg a				;cunning!
	neg b
_pos
	jsr do_divide_clip
_zero:
; Fetch X and Y and interpolate
	do_clip (r4)+,(r4+n4)		;that's the x
	move (r3)+					;skip y - it's the same
	move (r4)+
	move n3,b
	tst b
	jeq _c2
	do n3,_c2
	 do_clip (r4)+,(r4+n4)		;tex1
_c2	increase_clip_count
	rts

