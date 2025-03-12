
;-----------------------------------------------------------------------
; Swap the pointers and set up pointer registers.
;-----------------------------------------------------------------------

SwapPointers:

	move	x:height1ptr,r0		
	move	x:height2ptr,r1
	move	r0,x:height2ptr
	move	r1,x:height1ptr

	move	x:velocity1ptr,r4
	move	x:velocity2ptr,r5
	move	r4,x:velocity2ptr
	move	r5,x:velocity1ptr
	rts

;-----------------------------------------------------------------------
; Main generation routine
;-----------------------------------------------------------------------

Generate:

; Get main pointers (work from 2->1, as we have already swapped pointers)

	move	x:height1ptr,r1
	move	x:height2ptr,r0
	move	x:velocity1ptr,r5
	move	x:velocity2ptr,r4

; Move pointers inwards (fake edge around grid)

	move	(r1)+
	move	(r0)+
	move	(r4)+
	move	(r5)+

; Get surrounding pointers. These are pointers to the old height grid surrounding
; the current point we are working on.

	move	r0,a
	move	#>width+2,b
	sub	b,a
	move	a,r2		;above pointer
	move	r0,a
	add	b,a
	move	a,r3		;below pointer
	move	r0,a
	move	#>1,b
	sub	b,a
	move	a,r6		;left pointer
	move	r0,a
	add	b,a
	move	a,r7		;right pointer

; At each point, r0,r1 = current,new height grid pointer
;                r4,r5 = current,new velocity grid pointer
;                r2,r3,r6,r7 = surrounding points on old height grid
GenGrid:

	do	#height,GENY
	nop
	do	#width,GENX

; Calc new velocity
; = REACT * surrounding height difference + DAMPEN * last velocity

	move	x:(r2)+,a		; get above height
	move	x:(r3)+,b		; get below height
	add	b,a	x:(r6)+,b	; add them, get left height
	add	b,a	x:(r7)+,b	; add them, get right height
	add	b,a			; add them
	asr	a			
	asr	a	x:(r0),b	; divide by 4 (average), get last height
	sub	b,a			; height difference
	move	x:REACT,x0	a,y0	; get REACT, store height diff in y0 (for mpy)
	mpy	x0,y0,a	y:(r4)+,b	; mpy with REACT, get last velocity
	asl	a
	move	x:DAMPEN,x0	b,y0	; get DAMPEN, store last V in y0 (for mpy)
	mpy	x0,y0,b
	asl	b
	add	b,a			; add to total
	move	a1,y:(r5)		; put new velocity in grid

; When we calc the new height, it must be bounded against MAX and 0. If is has to
; be bounded, then we can either clear the velocity as well, or leave it alone.
; Each way has a different visual effect. CLEARVELOCITY is used to decide what to do
; in this situation. If is is set, then we use NewHeightCV instead of NewHeight to
; calculate the new height.

	move	x:CLEARVELOCITY,b
	tst	b
	jne	NewHeightCV

; Calc new height
; = last height + new velocity
; Remember, new velocity already in A
; Height must be bounded against MAX and 0. If bounding is performed, then
; the velocity is set to 0 (ie. the element has stopped moving).

NewHeight:

	move	x:(r0)+,b		; last height
	add	b,a	x:MAX,b		; add to velocity, get MAX in B
	jpl	_above0			; is it >0 ?
	clr	a			; no, clear it
_above0
	cmp	b,a			; is it <= MAX ?
	jle	_belowMAX
	move	b,a			; no, make it = MAX
_belowMAX
	jmp	DoneHeight

NewHeightCV:

	move	x:(r0)+,b		; last height
	add	b,a	x:MAX,b		; add to velocity, get MAX in B
	jpl	_above0			; is it >0 ?
	clr	a			; no, clear it
	move	a1,y:(r5)		; clear velocity as well
_above0
	cmp	b,a			; is it <= MAX ?
	jle	_belowMAX
	clr	b	b,a		; no, make it = MAX, clear b (to put in velocity)
	move	b1,y:(r5)		; clear velocity
_belowMAX

DoneHeight:

	move	a1,x:(r1)+		; put new height in grid
	move	(r5)+			; move new velocity ptr on to next element

GENX
; Move pointers on an extra 2 pixels at the end of a line
; to skip fake border on right and on left on next line

	move	(r0)+
	move	(r1)+
	move	(r4)+
	move	(r5)+
	move	(r2)+
	move	(r3)+
	move	(r6)+
	move	(r7)+

	move	(r0)+
	move	(r1)+
	move	(r4)+
	move	(r5)+
	move	(r2)+
	move	(r3)+
	move	(r6)+
	move	(r7)+
	nop
GENY
	nop
	rts

;-----------------------------------------------------------------------
; Put soft edges around grid
; This is done by pulling points outwards so that each grid edge point
; matches the point in from it. This will stop waves rebounding and
; causing interference inside the grid.
;-----------------------------------------------------------------------

PutSoftEdges
	
; Pull heights along top of grid
; (remember, grid width = width+2)
; Also remember that the pointers point to the second real line (ie. the
; first display line)

	move	x:height2ptr,a
	move	#>width+2,b
	sub	b,a
	move	a,r0
	move	x:height1ptr,r1
	move	(r0)+
	move	(r1)+

	do	#width,_top
	move	x:(r1)+,x0
	move	x0,x:(r0)+
_top

; Now do bottom edge

	move	x:height2ptr,a
	move	#>(width+2)*(height)+1,b
	add	b,a
	move	a,r0
	move	x:height1ptr,a
	move	#>(width+2)*(height-1)+1,b
	add	b,a
	move	a,r1
	do	#width,_bottom
	move	x:(r1)+,x0
	move	x0,x:(r0)+
_bottom

; Do left edge

	move	x:height2ptr,a
	move	#>(width+2),b
	add	b,a
	move	a,r0
	move	x:height1ptr,a
	move	#>(width+2)+1,b
	add	b,a
	move	a,r1
	move	#>width+2,n0
	move	#>width+2,n1
	do	#height,_left
	move	x:(r1)+n1,x0
	move	x0,x:(r0)+n0
_left

; Do right edge

	move	x:height2ptr,a
	move	#>(width+2)+(width+1),b
	add	b,a
	move	a,r0
	move	x:height1ptr,a
	move	#>(width+2)+(width),b
	add	b,a
	move	a,r1
	move	#>width+2,n0
	move	#>width+2,n1
	do	#height,_right
	move	x:(r1)+n1,x0
	move	x0,x:(r0)+n0
_right

	rts
