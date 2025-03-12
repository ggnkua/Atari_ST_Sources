
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

; At each point, r0,r1 = current,new height grid pointer
;		 r4,r5 = current,new velocity grid pointer

GenGrid:

	do	#height,GENY
	nop
	do	#width,GENX


; Calculate new velocity
; This is :	  (DAMPEN * last velocity) + (REACT * surrounding height difference)

	move	y:(r4),y0		; velocity
	move	x:DAMPEN,x0
	mpy	x0,y0,a			; DAMPEN * velocity
	asl	a	#>-1,n0
	clr	a	a1,x1		; store this in x1, a = surrounding heigts total

; a += h(x-1,y), n0 already set up by last bit

	move	x:(r0+n0),b
	add	b,a	#>1,n0

; a += h(x+1,y)

	nop
	move	x:(r0+n0),b
	add	b,a	#>-width,n0

; a += h(x,y-1)

	nop
	move	x:(r0+n0),b
	add	b,a	#>width,n0

; a += h(x,y+1)

	nop
	move	x:(r0+n0),b
	add	b,a

; average (divide by 4)
; get difference = average of others - this height

	asr	a
	asr	a	x:(r0),b	; b = this height
	sub	b,a			; difference

; REACT * difference

	move	x:REACT,x0	a,y0
	mpy	x0,y0,a
	asl	a

; Total everything up : (DAMPEN * last velocity) - GRAVITY + (REACT * surrounding height difference)
; First 2 terms held in x1
; Last term in a

	move	x1,b
	add	b,a

; Put in new velocity y:(r5)

	move	a1,y:(r5)

; Calculate new height
; This is : last height + last velocity (bounded to MAX)
; If height is out of bounds, then the velocity is cleared.

	move	x:(r0),a	y:(r5),b	; height,velocity
	add	b,a	x:MAX,b
	jpl	_above0
	clr	a
	move	a1,y:(r5)
_above0
	cmp	b,a
	jle	_belowMAX
	clr	b	b,a
	move	b1,y:(r5)
_belowMAX
	move	a1,x:(r1)	; set new height

; Move pointers on to next grid element

	move	(r0)+
	move	(r1)+	
	move	(r4)+	
	move	(r5)+
	
GENX
	nop
GENY
	nop
	rts
