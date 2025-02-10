;-----------------------------------------------------------------------
; Set up grid pointers
; Height grids are in external X memory, Velocity grids in external Y memory
; The pointers are in internal X memory
;-----------------------------------------------------------------------

SetUpPointers:

	move	#>height1,x0
	move	x0,x:height1ptr
	move	#>velocity1,x0
	move	x0,x:velocity1ptr
	move	#>height2,x0
	move	x0,x:height2ptr
	move	#>velocity2,x0
	move	x0,x:velocity2ptr
	rts

;-----------------------------------------------------------------------
; Clear grid buffers
;-----------------------------------------------------------------------

ClearBuffers:

	move	#>h1,r0
	move	#>h2,r1
	move	#>v1,r4
	move	#>v2,r5
	clr	a
	do	#height+2,CLRY
	nop
	do	#width+2,CLRX
	move	a,x:(r0)+	a,y:(r4)+
	move	a,x:(r1)+	a,y:(r5)+
CLRX
	nop
CLRY
	nop
	rts
