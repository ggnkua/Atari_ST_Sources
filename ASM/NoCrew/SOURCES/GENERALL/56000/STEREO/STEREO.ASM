;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive, West, Austin, Texas  78735-8598.
;



	page 132,66,3,3,0


	org	x:$0
input	dsm	2
output	dsm	2
missc	ds	3
storer5 ds	1

	org	y:$0
average	ds	2
temp	ds	2
storer6 ds	1
storer7 ds	1
coef	ds	3

	org	p:$0
	jmp	$40	

	org	p:$0c
	jsr 	ioprocess

	org	p:$0e
	jsr 	ioprocess

start	equ	$40
half	equ	.5
alpha	equ	.99
beta	equ	1-alpha
oneos2  equ	.70711
maxcos	equ	2.56   
coefa1	equ	.8803385
coefa2	equ	-.1985987
coefa0	equ	.3175231

sqrt	macro
	mpyr	x0,x0,b		y:(r5)+,y0
	mpy	x0,y0,b	b,x1	y:(r5)+,y0
	macr	x1,y0,b		y:(r5)+,y0
	add 	y0,b
	endm

divide	macro
	and	#$fe,ccr
	rep	#$18
	div	x0,a
	add	x0,a
	move	a0,b
	endm



	org	p:start
	or	#$03,mr
	movep	#$1a00,x:$ffed
	movep	#$3000,x:$ffff
	movep	#$4100,x:$ffec
	movep	#$ba00,x:$ffed
	movep	#$1ff,x:$ffe1
	movep	#$3,x:$ffe2
	move	#coef,r5
	move	#input,r1			;set r1 to point to
	move	#coefa1,b
	move	#coefa2,a	
	move	b,y:(r5)+
	move	#coefa0,b	
	move	a,y:(r5)+
	move	b,y:(r5)
	move	#1,m0					;input
	move	#missc+2,r2			;set r2 to point to
	move	#2,n2
	move	#input,r0
	move	#output,r3
	move	n2,n1
	move	#0,n6
	move	m0,m3
						;bottom of misc.
	move	#average,r4			;set r4 to point at
						;average locations
	move	#temp,r5			;set r5 to the temporary
	move	n6,y:(r4)+
	move	n6,y:(r4)-
	andi	#$fc,mr

loop0	jmp	loop0

ioprocess
	movep	x:$ffef,x:(r0)+
	movep	x:(r3)+,x:$ffef
	move 	n6,a
	move	r0,b
	cmp	a,b
	jseq	detect
	rti

						;I and Q locations
detect
	move	x:(r1)+,y0			;move input into  x0
	move 	x:(r1)+n1,x1	y0,y:(r5)+	;move x0 into temp.
						;move q input into x1
				 		;move q into temp
	move	x1,y:(r5)-
	move	#beta,y1			;move beta into y1 to  
						;perform average
						;calculation
	mpy	y0,y1,a		#alpha,y0	;multiply I input by beta
						;move alpha(1-beta)
						;into y0
	mpy	x1,y1,b		y:(r4)+,x0	;multiply q input by beta
						;move past I average
						;xo to continue average
	mac	x0,y0,a		y:(r4)-,x1	;acuumulate the new
						;I average and move
						;the old Q average 
						;into x1
	mac	x1,y0,b		a,y:(r4)+	;accumulate the new Q
						;average and move new
						;I average into memory
	sub	b,a	b,x1	b,y:(r4)-	;subtract Q from I to
						;get carrier value and
						;move Q average to mem.
	move	a,x:(r2)-	y:(r5)+,a	;move carrier into
						;memory an move I 
						;into a to find bias
	sub	x1,a		#0,b		;subtract bias from I
						;move Q into x0	
	cmp	b,a		y:(r5)-,x0
	jne	start1
	move	(r2)+
	move	a1,x:(r1)-
	move	a1,x:(r1)-n1
	rts
start1	asr	a		a,y:(r5)+	;Shift I* right and
						;store I*
	tfr	x0,a		a,x0		;transfer a and x0 so
						;bias can be subtracted
						;from q
	sub	x1,a		#0,r6		;subtract bias from Q
						;move #0 into r6 to
						;count the number of
						;shift lefts needed
						;to make the number be
						;between .5<b,1
	asr	a		a,y:(r5)-	;Divide Q* in half
						;store Q* in memory
	mpy	x0,x0,b		a,y0		;square I*/2
	mac	y0,y0,b	        #half,y0	;add to square Q*/2
						;Put .5 into y0 to
						;compare for sqrt
	
loop1	cmp	y0,b				;compare b to .5 to see
						;if it is greater than
						;.5 for the sqrt
						;algorithm
	jge	dosqrt				;jump if greater than
	asl	b	x:(r6)+,x1		;if b is less than .5
						;then shift b left and 
						;increment r6
	jmp	loop1				;jump to compare again
dosqrt 
	move	#coef,r5
	move	b,x0
	sqrt
	move	r6,x0
	move	#0,a
	cmp	x0,a	#temp,r5
	jeq	around1
	move  	#oneos2,y0			;now multiply the out
						;put by 1/sqrt2 for
						;every shift left 
	do	x0,enddo1
	move	b,x1				;move b into x0 to mult.
	mpy	x1,y0,b				;multiplly by 1/sqrt2
enddo1
around1	move	b,x:(r2)-	y:(r5),a	;store h and recall I*
						;to get ready to divide
						;H by I* to ger 1/cos0
	abs	a	#1,r7	
						;for the number of shift
						;lefts neede for
						;dividing H by I
loop2	cmp	a,b		y:(r5),y0	;So compare I to H
	jlt 	dodivide			;Do the divide if H<I
	asr	b	x:(r7)+,x1		;If H>I,shift H right
						;and increment the
						;counter
	jmp	loop2
dodivide
	tfr	b,a		a,x0
	divide
	move	r7,x0
	move	b,x:(r2)+n2			;store 1/cos0
	move	x:(r2),a       			;move carrier into a and
						;store 1/cos0 in x1
	rep	x0 
	asr 	a				;shift the carrier right
						;as many times as the
						;H was shifted for the
						;divide + one for the 
						;shift right of I and Q
						;before the sum of
						;squares 
						;save the new carrier
	move	b,x1	 y:(r5)+,y1
						;back to memory and 
						;move I* back into x0
	mpy	x1,y1,b	a,x:(r2) y:(r5)-,y0	;multiply I* by 1/cos0
						;and move Q* into y0
	mpy	x1,y0,a		a,y1		;multiply Q* by 1/cos0
						;and move a into x0
	sub	y1,b				;subtract the carrrier
						;from I and store (L-R)
	add	b,a		a,x0		;left
	sub	x0,b	
	asl     a
	asl	a
	asl	b
    	asl 	b	a,x:(r1)-	;right
	move	b,x:(r1)-n1
	rts
