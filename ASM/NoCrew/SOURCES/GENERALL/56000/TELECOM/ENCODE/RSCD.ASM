

		PAGE	132,61
		OPT		CC
;***********************************************************
;
;	Reed-Solomon Coder
;
;***********************************************************


START		EQU		$0040
ilb_base	EQU		$0		; beginning of interleaf buffer
chunk		EQU		$1d		; "chunk" size + 1   (28 + 1)
buf_size 	EQU		2048		; modulo buffer size
skip_parity	EQU		116		; 
back_16		EQU		-464		; -16 * 29


	;Internal X RAM Allocation
		ORG	X:$0000

ilb	bsc	2048,0	; interleave buffer	 ilb[2048] needs to be at least
P1	ds    	1	; state 1                          55x28 words long
P2	ds	1	; state 2
G1      dc      151	; Alpha representation of the 1st generating coefficient
G2      dc      246	; Alpha representation of the 2nd generating coefficient
input	bsc	24,0	; Input Buffer        input[24]
output	bsc	32,0	; Output Buffer       output[32]


	;Internal Y RAM Allocation
		ORG	Y:$0000		; Internal Y RAM Allocation
P3	ds      1			; state 3
P4	ds      1			; state 4	


;######################################################
;	R0 - Interleave Buffer   	R4 - P3 & P4
;	R1 - Input Buffer		R5 - Table (Alpha-->power)
;	R2 - P1 & P2			R6 - Table (power-->Alpha)
;	R3 - Output Buffer		R7 - Table (power-->Alpha)
;######################################################


		ORG	P:START

	movep	#$0000,x:$fffe		;Set BCR for 0 wait states

	; initialize interleave buffer pointer
	move	#ilb_base,r0	; base
	move	#chunk,n0		; "chunk" size + 1
	move	#buf_size,m0	; modulo buffer size

	; intialize input buffer
	move	#input,r1

	move	#P1,r2

	; intialize output buffer
	move	#output,r3

	move	#P4,r4

	; initialize Alpha -> power table
	move	#TABLE2,r5

	; initialize power -> Alpha table
	move	#TABLE1,r6
	move	#TABLE1,r7


;
;	Main Loop
;		Do encode-encode process 
;		for each frame for 55 frames
;

        do #55,mainloop
		

        move #input,r1
	do #24,write_in
	move x:$f000,x1	; Inputs & outputs from simulator at x:$f000 & x:$f001 
	move x1,x:(r1)+
write_in
	move #input,r1
 

	;
	; grab first 12 data points
	;

	do	#12,first_twelve
	; load byte from input buffer and load P4
	move	x:(r1)+,x1		y:(r4)-,a

	; Add P4+INPUT, save byte to interleave buffer, load P3
	eor	x1,a		x1,x:(r0)+n0	y:(r4)+,y1

	; Move ALPHA for table lookup
	move	a,n5

	move	x:G1,a 			; load G1

	; Find ALPHA power from table
	move	y:(r5+n5),y0

	; Add powers of ALPHA & G1, load G2
	add	y0,a		x:G2,b

	; Add powers of ALPHA & G2, and store power of ALPHA1
	add	y0,b		a,n6

	; Save power of ALPHA2
	move	b,n7

	; Do inverse lookup for ALPHA1
	tfr	y1,b		y:(r6+n6),y0

	; Add P3+ALPHA1, load P1
	eor	y0,b		x:(r2)+,a

	; Add P1+ALPHA1, save new P4, load P2
	eor	y0,a		x:(r2)-,b		b,y:(r4)-

	; Do inverse lookup for ALPHA2
	move	y:(r7+n7),y0

	; Add ALPHA2+P2, save new P1
	eor	y0,b		n5,x:(r2)+

	; Save new P2 and new P3
	move	a,x:(r2)-		b,y:(r4)+
first_twelve

	;
	; move past parity locations
	;

	move	#skip_parity,n0
	nop
	move	(r0)+n0
	move	#chunk,n0	; reset n0


	;
	; grab second 12 data points
	;


	do	#12,second_twelve
	; load byte from input buffer and load P4
	move	x:(r1)+,x1		y:(r4)-,a

	; Add P4+INPUT, save byte to interleave buffer, load P3
	eor	x1,a		x1,x:(r0)+n0	y:(r4)+,y1

	; Move ALPHA for table lookup
	move	a,n5

	move	x:G1,a 			; load G1

	; Find ALPHA power from table
	move	y:(r5+n5),y0

	; Add powers of ALPHA & G1, load G2
	add	y0,a		x:G2,b

	; Add powers of ALPHA & G2, and store power of ALPHA1
	add	y0,b		a,n6

	; Save power of ALPHA2
	move	b,n7

	; Do inverse lookup for ALPHA1
	tfr	y1,b		y:(r6+n6),y0

	; Add P3+ALPHA1, load P1
	eor	y0,b		x:(r2)+,a

	; Add P1+ALPHA1, save new P4, load P2
	eor	y0,a		x:(r2)-,b		b,y:(r4)-

	; Do inverse lookup for ALPHA2
	move	y:(r7+n7),y0

	; Add ALPHA2+P2, save new P1
	eor	y0,b		n5,x:(r2)+

	; Save new P2 and new P3
	move	a,x:(r2)-		b,y:(r4)+
second_twelve


	;
	; get back to parity locations
	;

	move	#back_16,n0
	nop
	move	(r0)+n0
	move	#chunk,n0	; reset n0

	; Get P1 and P4
	clr	a	x:(r2)+,x0	y:(r4)-,y1

	; Get P2 and P3
	move	x:(r2)-,x1	y:(r4),y0

	; Save P4 to interleave buffer
	move	y1,x:(r0)+n0

	; Save P3 "
	move	y0,x:(r0)+n0

	; Save P2 "
	move	x1,x:(r0)+n0

	; Save P1 "
	move	x0,x:(r0)+n0

	; Clear P1 & P3 regs
	move	a,x:(r2)+	a,y:(r4)+

	; Clear P2 & P4 regs
	move	a,x:(r2)-	a,y:(r4)


	;
	; get back to beginning of output
	;

	move	#back_16,n0
	nop
	move	(r0)+n0
	move	#chunk,n0	; reset n0


	do	#28,output_data
	; load byte from input buffer and load P4
	move	x:(r0)+,x1		y:(r4)-,a

	; Add P4+INPUT, save byte to interleave buffer, load P3
	eor	x1,a		x1,x:(r3)+	y:(r4)+,y1

	; Move ALPHA for table lookup
	move	a,n5

	move	x:G1,a 			; load G1

	; Find ALPHA power from table
	move	y:(r5+n5),y0

	; Add powers of ALPHA & G1, load G2
	add	y0,a		x:G2,b

	; Add powers of ALPHA & G2, and store power of ALPHA1
	add	y0,b		a,n6

	; Save power of ALPHA2
	move	b,n7

	; Do inverse lookup for ALPHA1
	tfr	y1,b		y:(r6+n6),y0

	; Add P3+ALPHA1, load P1
	eor	y0,b		x:(r2)+,a

	; Add P1+ALPHA1, save new P4, load P2
	eor	y0,a		x:(r2)-,b		b,y:(r4)-

	; Do inverse lookup for ALPHA2
	move	y:(r7+n7),y0

	; Add ALPHA2+P2, save new P1
	eor	y0,b		n5,x:(r2)+

	; Save new P2 and new P3
	move	a,x:(r2)-		b,y:(r4)+
output_data

	;
	; move 4 parity bytes to output buffer
	;


	; Get P1 and P4
	clr	a	x:(r2)+,x0	y:(r4)-,y1

	; Get P2 and P3
	move	x:(r2)-,x1	y:(r4),y0

	; Save P4 to output buffer
	move	y1,x:(r3)+

	; Save P3 "
	move	y0,x:(r3)+

	; Save P2 "
	move	x1,x:(r3)+

	; Save P1 "
	move	x0,x:(r3)+

	; Clear P1 & P3 regs
	move	a,x:(r2)+	a,y:(r4)+

	; Clear P2 & P4 regs
	move	a,x:(r2)-	a,y:(r4)

        move #output,r3
	do #32,write_out
	move x:(r3)+,x1
	move x1,x:$f001 ; on simulator
write_out
	move #output,r3
mainloop

	;
	; generated tables follow
	;

	INCLUDE		'table1.asm' ; table at y:$200 -- power to alpha
	INCLUDE		'table2.asm' ; table at y:$100 -- alpha to power

	END
