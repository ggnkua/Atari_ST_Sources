; CLIPPER2.ASM
; General-purpose clipping routine
; Uses bog-standard Sutherland-Hodgman
;
; Remixed August 95
;
;
;
;
;

extra_data	equ 2			;e.g. gouraud 1, texmap 2
					;(in addition to x and ycoord)
increase_clip_count MACRO
		move (r6)+
		ENDM

copy_extra_clip MACRO label
		move r0,r4
		do #2+extra_data,_\label
	  	 move y:(r4)+,x0
	  	 move x0,y:(r2)+
_\label:
		ENDM

copy_r4_point	MACRO label
		move r4,r5
		do #2+extra_data,_\label
	  	 move y:(r5)+,x0
	  	 move x0,y:(r3)+
_\label:	increase_clip_count
		ENDM


handle_x_y_clip:
	move b1,n6			;dont change n6!

	move r0,r2			;r2 - end of input poly
					;  (used for copying endbit!)
	move #input_poly,r0		;r0 - input (same as rec_poly)
	move #output_poly,r1		;r1 - output
	move x:polygon_points,r6
	move x:polygon_points,a

	jsset #0,n6,do_x_min_clip
	move r6,a
	tst a
	jle _failed
	jsset #1,n6,do_y_min_clip
	move r6,a
	tst a
	jle _failed
	jsset #2,n6,do_x_max_clip
	move r6,a
	tst a
	jle _failed
	jsset #3,n6,do_y_max_clip
	move r6,a
	tst a
	jle _failed

	move a1,x:polygon_points
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
	 move #>extra_data+2,n4
	 move y:(r4),a			;fetch x coord 1
	 move x:x_clip_min,x1
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
	 move #>extra_data+2,n4
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
	 move #>extra_data+2,n4
	 move y:(r4),a			;fetch x coord 1
	 move x:x_clip_max,x1
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
	 move #>extra_data+2,n4
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
	 move y:(r4+n4),a		;fetch x coord 1
	 move #>1+extra_data+2,n4

	 move x:y_clip_min,x1
	 cmp x1,a	y:(r4+n4),b	;fetch x coord 2
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
	 move #>extra_data+2,n4
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
	 move #>1+extra_data+2,n4

	 move x:y_clip_max,x1
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
	 move #>extra_data+2,n4
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
	clr b
	move #$7fffff,b0		;i.e. '1'...
	and #$fe,ccr
	rep #24
	 div x1,b
	bclr #23,b0
; b0 is now (1/b)
	move b0,y0
	move a1,y1
	mpy y0,y1,a
	;asr a
	move a0,y0			;y0 is my multiplier...
	rts

;------------------------------------
do_clip		MACRO addr1,addr2
		move y:\addr2,a
		move y:\addr1,x1
		sub x1,a	x1,b
		move a,y1
		mac y0,y1,b
		move b1,y:(r3)+
		ENDM

do_clip2	MACRO addr1,addr2
		move y:\addr2,x1
		move y:\addr1,a
		sub x1,a	x1,b
		move a,y1
		mac y0,y1,b
		move b1,y:(r3)+
		ENDM
;------------------------------------

actual_x_clip:
	move x1,y:(r3)+			;store the clipped xcoord first
	move b,x0
	sub a,b		#0,y0		;b = offset
	jpl _pos
; If negative,
; Swap a and b (or neg b, tfr orig b to a)
	neg b				;cunning!
	move x0,a
	sub x1,a	(r4)+
	jeq _zero2
	neg a
	jsr do_divide_clip
_zero2:
	do_clip2 (r4)+,(r4+n4)		;that's the y
	do_clip2 (r4)+,(r4+n4)		;tex1
	do_clip2 (r4)+,(r4+n4)		;tex2
	jmp _clip_done

_pos:	sub x1,a	(r4)+
	jeq _zero
	neg a
	jsr do_divide_clip
_zero:
; Fetch X and Y and interpolate
	do_clip (r4)+,(r4+n4)		;that's the y
	do_clip (r4)+,(r4+n4)		;tex1
	do_clip (r4)+,(r4+n4)		;tex2
_clip_done
	increase_clip_count
	rts

actual_y_clip:
	move #>extra_data+2,n4
	move (r3)+
	move x1,y:(r3)-			;store the clipped xcoord first

	move b,x0
	sub a,b		#0,y0		;b = offset
	jpl _pos

; If negative,
; Swap a and b (or neg b, tfr orig b to a)
	neg b				;cunning!
	move x0,a
	sub x1,a
	jeq _zero2
	neg a
	jsr do_divide_clip
_zero2:
	do_clip2 (r4)+,(r4+n4)		;that's the x
	move (r3)+
	move (r4)+
	 do_clip2 (r4)+,(r4+n4)		;tex1
	 do_clip2 (r4)+,(r4+n4)		;tex2
	jmp _clip_done
_pos:
	sub x1,a
	jeq _zero
	neg a
	jsr do_divide_clip
_zero:
	do_clip (r4)+,(r4+n4)		;that's the x
	move (r3)+
	move (r4)+
	 do_clip (r4)+,(r4+n4)		;tex1
	 do_clip (r4)+,(r4+n4)		;tex2
_clip_done:
	increase_clip_count
	rts



