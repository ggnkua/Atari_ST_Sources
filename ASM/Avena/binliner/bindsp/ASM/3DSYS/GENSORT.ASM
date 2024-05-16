; GENSORT.ASM

; General sort routine
; Small but beautifully formed
; Started 9/2/96, tested 9/2/96 with 20 elements

; Enter with: r0 start of list, n0 number of elements
;             (list must be in X memory)
; Elements will be sorted in DESCENDING ORDER (biggest first!)

general_sort_routine:
	move n0,a
	move #>1,x0
	cmp x0,a
	jle _no_sorting

	move n0,r6
	move #>2,n5
	move (r6)-			;no of elements - 1, don't need to do last
	move #>2,n0
	move #>-2,n3
	do r6,_sort_loop_1
	  lua (r0)+n0,r5		;r5 - addr as we go through
	  move x:(r0),a			;get first element
	  move x:(r5)+n5,b
	  move r5,r3			;r3 - (addr of biggest so far) + 4!
	  do r6,_sort_loop_2
	    cmp b,a	x:(r5)+n5,b	b,y0
	    tle y0,a	r5,r3
_sort_loop_2:
	  move x:(r0),x0
	  move a1,x:(r0)+
	  lua (r3)+n3,r3	
	  move x:(r0),x1
 	  move x:-(r3),y1
	  move y1,x:(r0)+
	  move x1,x:(r3)-	y:(r6)-,b	;one fewer to check
	  move x0,x:(r3)
_sort_loop_1:
_no_sorting:
	rts
