fpfloor	ident	2,0
;
; MOTOROLA DSP56000/1 FPLIB - VERSION 2
;
; FPFLOOR - FLOATING POINT FLOOR SUBROUTINE
;
; Entry points:	floor_a	   R = floor(A)
;		floor_x	   R = floor(X)
;
;	m = 24 bit mantissa (two's complement, normalized fraction)
;
;	e = 14 bit exponent (unsigned integer, biased by +8191)
;
; Input variables:
;
;   X	x1 = mx  (normalized)
;	x0 = ex
;
;   A	a2 = sign extension of ma
;	a1 = ma  (normalized)
;	a0 = zero
;
;	b2 = sign extension of ea (always zero)
;	b1 = ea
;	b0 = zero
;
; Output variables:
;
;   R	a2 = sign extension of mr
;	a1 = mr  (normalized)
;	a0 = zero
;
;	b2 = sign extension of er (always zero)
;	b1 = er
;	b0 = zero
;
; Error conditions:	No error conditions are signaled.
;
; Assumes n0, m0, shift constant table and scaling modes
; initialized by previous call to the subroutine "fpinit".
;
; Alters Data ALU Registers
;	a2	a1	a0	a
;	b2	b1	b0	b
;	x1	x0
;
; Alters Address Registers
;	r0
;
; Alters Program Control Registers
;	pc	sr
;	ssh	ssl	sp
;
; Uses 0 locations on System Stack
;
; Author - Brett Lindsley
; Version - 2.0
; Latest Revision - February 22, 1988
;
floor_x	tfr	x0,b	x1,a		;get mx,ex
floor_a
	tst	a	#$1fff+23,x0	;check a, max exponent w/o fraction
	jeq	_done			;if a=0, result=0
	cmp	x0,b	fp_space:fp_ebias,x0	;check for max input
	jge	_done			;if max, result=input
	cmp	x0,b	b,x1		;check for fraction, save exponent
	jgt	_inrange		;jump if not less than one
	clr	a	#0,b		;if less than one, result=0
	jmp	_done
_inrange
	sub	x0,b	#>masktbl-1,x0	;subtract bias, point to mask table
	add	x0,b			;point to mask
	move	b1,r0			;put in address reg
	move	x1,b			;restore exponent
	move	p:(r0),x0		;get mask
	and	x0,a			;round fraction to negative infinity
_done
	rts
masktbl
	dc	$c00000,$e00000,$f00000
	dc	$f80000,$fc0000,$fe0000,$ff0000
	dc	$ff8000,$ffc000,$ffe000,$fff000
	dc	$fff800,$fffc00,$fffe00,$ffff00
	dc	$ffff80,$ffffc0,$ffffe0,$fffff0
	dc	$fffff8,$fffffc,$fffffe
