;-----------------------------------------------------------------------
; Put some points on the current grid frame
;-----------------------------------------------------------------------

PlotBits:

; Get main pointers (work from 2->1, as we have already swapped pointers)

	move	x:height1ptr,r1
	move	x:height2ptr,r0
	move	x:velocity1ptr,r5
	move	x:velocity2ptr,r4

	move	#POS,r2
	move	#AMP,r7
	do	x:BITS,PUTBITS

	move	x:(r2)+,b
	move	x:(r2)+,y0
	move	#>width+2,x1
	mpy	x1,y0,a
	asr	a
	move	a0,x1
	move	x1,a
	add	b,a
	move	a,n4
	nop
	move	x:(r7)+,a
	move	x:(r4+n4),b		; should be r0 for height (r4 = velocity grid)
;	add	b,a
	move	a,x0
	do	#1,more
	move	x0,x:(r4+n4)		; as above
	move	n4,a
	move	#>1,b
	add	b,a
	move	a,n4
	nop
more
	nop
PUTBITS

	move	#INCLIST,r3
	move	x:INCNUM,n3

	move	#POS,r2
	move	#INC,r7
	do	x:BITS,MOVEBITS

	move	x:(r2),a
	move	x:(r7),b
	add	b,a
	move	#>width-5,b
	cmp	b,a
	jlt	NOR
	move	b,a
	move	x:(r3+n3),b
	neg	b
	move	b,x:(r7)
NOR
	move	#>5,b
	cmp	b,a
	jgt	NOL
	move	b,a
	move	x:(r3+n3),b
	move	b,x:(r7)
NOL
	move	a,x:(r2)
	move	(r2)+
	move	(r7)+

	move	x:(r2),a
	move	x:(r7),b
	add	b,a
	move	#>height-5,b
	cmp	b,a
	jlt	NOB
	move	b,a
	move	x:(r3+n3),b
	neg	b
	move	b,x:(r7)
NOB
	move	#>5,b
	cmp	b,a
	jgt	NOT
	move	b,a
	move	x:(r3+n3),b
	move	b,x:(r7)
NOT
	move	a,x:(r2)
	move	(r2)+
	move	(r7)+
MOVEBITS

	move	n3,a
	move	#>1,b
	add	b,a
	move	a,n3
	nop
	move	x:(r3+n3),b
	tst	b
	jge	notoffend
	clr	a
notoffend
	move	a,x:INCNUM

	rts

;-----------------------------------------------------------------------
; Put some points on the current grid frame
; These are read from the CPU
;-----------------------------------------------------------------------

ReadPlots:

; Get main pointers (work from 2->1, as we have already swapped pointers)

	move	x:height2ptr,r0

	dspread	x:BITS

	move	x:BITS,a
	tst	a
	jeq	NOBITS
	do	x:BITS,PLOTBITS

	dspread	b			; read X
	dspread	y0			; read Y

	move	#>width+2,x1
	mpy	x1,y0,a
	asr	a
	move	a0,x1
	move	x1,a
	add	b,a
	move	a,n0
	dspread	a			; amplitude
	move	a1,x:(r0+n0)		; put in grid
PLOTBITS
NOBITS
	rts
