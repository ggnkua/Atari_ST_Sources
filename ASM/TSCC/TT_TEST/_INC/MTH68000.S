*******************************************************************************
*									      *
*	       Motorola 680x0 fixedpoint math library v1.4		      *
*									      *
* Assembles with hisoft devpac						      *
* by ray//.tscc	     2002-2005						      *
*									      *
*******************************************************************************
* www: http://ray.tscc.de						      *
* eml: ray.tscc.de							      *
*******************************************************************************
*									      *
* Implemented instructions (to be performed on dataregisters only)	      *
*									      *
* fint		round off to integer value				      *
* fabs		absolute value						      *
* fmul		fixedpoint multiply		²			      *
* fdiv		fixedpoint divide		²			      *
* fsin		sine							      *
* fcos		cosine							      *
* ftan		tangent							      *
* fatan		arctan							      *
* fetox		base 2 exponentiation 					      *
* fsqrt		square root						      *
*									      *
*									      *
* ²Supports the same addressing modes as muls.w/divs.w			      *
*									      *
*******************************************************************************
		opt	c-		; Case sensivity off


*******************************************************************************
*									      *
*  Macro for defininig fixedpoint values in scientific notation		      *
*									      *
* Examples:								      *
*									      *
* pi		dcfix.w	31415,e-4	define pi as 8.8 value		      *
* e		dcfix.l	271828,e-5	define e as 24.8 value		      *
*									      *
* The range of valid exponents is [-5;5]				      *
*									      *
*******************************************************************************
dcfix	macro	mantissa,exponent
	ifc	'\2','e-5'
		dc.\0	\1<<8/100000
		mexit
	endc

	ifc	'\2','e-4'
		dc.\0	\1<<8/10000
		mexit
	endc

	ifc	'\2','e-3'
		dc.\0	\1<<8/1000
		mexit
	endc

	ifc	'\2','e-2'
		dc.\0	\1<<8/100
		mexit
	endc

	ifc	'\2','e-1'
		dc.\0	\1<<8/10
		mexit
	endc

	ifc	'\2','e0'
		dc.\0	\1<<8
		mexit
	endc

	ifc	'\2','e1'
		dc.\0	\1<<8*10
		mexit
	endc

	ifc	'\2','e2'
		dc.\0	\1<<8*100
		mexit
	endc

	ifc	'\2','e3'
		dc.\0	\1<<8*1000
		mexit
	endc

	ifc	'\2','e4'
		dc.\0	\1<<8*10000
		mexit
	endc

	ifc	'\2','e5'
		dc.\0	\1<<8*100000
		mexit
	endc

	fail	illegal exponent
		endm


*******************************************************************************
*									      *
*  Macro for defininig fixedpoint equates in scientific notation	      *
*									      *
* Examples:								      *
*									      *
* 		fequ	pi,31415,e-4	define pi			      *
*									      *
* The range of valid exponents is [-5;5]				      *
*									      *
*******************************************************************************
fequ		macro	label,mantissa,exponent
	ifc	'\3','e-5'
\1		equ	\2<<8/100000
		mexit
	endc

	ifc	'\3','e-4'
\1		equ	\2<<8/10000
		mexit
	endc

	ifc	'\3','e-3'
\1		equ	\2<<8/1000
		mexit
	endc

	ifc	'\3','e-2'
\1		equ	\2<<8/100
		mexit
	endc

	ifc	'\3','e-1'
\1		equ	\2<<8/10
		mexit
	endc

	ifc	'\3','e0'
\1		equ	\2<<8
		mexit
	endc

	ifc	'\3','e1'
\1		equ	\2<<8*10
		mexit
	endc

	ifc	'\3','e2'
\1		equ	\2<<8*100
		mexit
	endc

	ifc	'\3','e3'
\1		equ	\2<<8*1000
		mexit
	endc

	ifc	'\3','e4'
\1		equ	\2<<8*10000
		mexit
	endc

	ifc	'\3','e5'
\1		equ	\2<<8*100000
		mexit
	endc

	fail	illegal exponent
		endm


; Constants

		fequ	pi,314159,e-5
		fequ	e,271828,e-5



*******************************************************************************
*									      *
*	fint dn								      *
*									      *
*	Return the magnitude of dn (8.8), signed			      *
*									      *
*	No registers modified						      *
*									      *
*******************************************************************************
fint		macro
		asr.w	#8,\1
	
		endm


*******************************************************************************
*									      *
*	fabs dn								      *
*									      *
*	Return the absolute value of a number				      *
*									      *
*	No registers modified						      *
*									      *
*******************************************************************************
fabs		macro
.\@abs		neg.w	\1
		bmi.s	.\@abs

		endm


*******************************************************************************
*									      *
*	fmul dx,dy							      *
*									      *
*	Multiply two fixed point numbers (8.8), signed			      *
*									      *
*	Returns a 24.8 bit result					      *
*	No registers modified						      *
*									      *
*******************************************************************************
fmul		macro
		muls.w	\1,\2
		asr.l	#8,\2
	
		endm


*******************************************************************************
*									      *
*	fdiv dx,dy							      *
*									      *
*	Divide dx (24.8) by dy (8.8), signed				      *
*									      *
*	Returns an 8.8 bit result					      *
*	No registers modified						      *
*									      *
*******************************************************************************
fdiv		macro
		asl.l	#8,\2
		divs.w	\1,\2

		endm


*******************************************************************************
*									      *
*	fsin dn								      *
*									      *
*	Compute sine of dn (fineangle range is 16 bits)			      *
*									      *
*	Returns an 8.8 bit result					      *
*	No registers modified						      *
*									      *
*	Pade approximation:						      *
*	  sin(x) = x(60-7xý)/(60+3xý)					      *
*									      *
*******************************************************************************
fsin		macro

; Determine quadrant and clamp angle

		bclr.l	#14,\1		; Even or odd quadrant?
		beq.s	.\@even		; Even

		eori.w	#$3fff,\1	; Reverse the curve otherwise

.\@even		bclr.l	#15,\1		; Which semicircle?
		beq.s	.\@first		; First

		neg.w	\1		; Mirror curve against x-axis
					; on the second one
.\@first

; Approximate

		muls.w	#2*pi,\1	; Translate into radians
		swap.w	\1

		move.w	\1,-(sp)	; x
		fmul	\1,\1
		move.w	\1,-(sp)	; xý

		asl.w	#3,\1		; 8xý
		sub.w	(sp),\1		; 7xý
		neg.w	\1
		addi.w	#60<<8,\1	; 60-7xý
		muls.w	2(sp),\1	; x(60-7xý)	16.16
		move.l	\1,-(sp)

		move.w	4(sp),\1	; xý
		add.w	\1,\1		; 2xý
		add.w	4(sp),\1	; 3xý
		addi.w	#60<<8,\1	; 60+3xý
		move.w	\1,-(sp)
		move.l	2(sp),\1
		divs.w	(sp)+,\1	; x(60-7xý)/(60+3xý)

		addq.l	#8,sp
		endm


*******************************************************************************
*									      *
*	fcos dn								      *
*									      *
*	Compute cosine of dn (fineangle range is 16 bits)		      *
*									      *
*	Returns an 8.8 bit result					      *
*	No registers modified						      *
*									      *
*******************************************************************************
fcos		macro
		addi.w	#$3fff,\1	; cos(x) = sin(x+ã/2)
		fsin	\1

		endm


*******************************************************************************
*									      *
*	ftan dn								      *
*									      *
*	Compute tangent of dn (fineangle range is 16 bits)		      *
*									      *
*	Returns an 8.8 bit result					      *
*	No registers modified						      *
*									      *
*******************************************************************************
ftan		macro
		move.w	\1,-(sp)
		fcos	\1
		move.w	\1,-(sp)

		move.w	2(sp),\1
		fsin	\1

		tst.w	(sp)
		bne.s	.\@compute	; Catch borderline cases with cos(x)=0

		fmul	#$7fff,\1	; Return +/-ß
		bra.s	.\@exit

.\@compute	ext.l	\1
		fdiv	(sp),\1		; tan(x) = sin(x)/cos(x)

.\@exit		addq.w	#4,sp

		endm


*******************************************************************************
*									      *
*	fatan dn							      *
*									      *
*	Compute arctan of the given argument				      *
*									      *
*	Returns an 8.8 bit result					      *
*	No registers modified						      *
*									      *
*	Pade approximation:						      *
*	  x(15+4xý)/(15+9xý)						      *
*									      *
*******************************************************************************
fatan		macro

; Preadjust

		clr.w	-(sp)		; adj = 0

		cmpi.w	#1<<8,\1
		ble.s	.\@below

		move.w	\1,-(sp)
		move.l	#-1<<16,\1
		divs.w	(sp)+,\1	; x = -1/x

		move.w	#pi/2,(sp)	; adj = ã/2

.\@below	cmpi.w	#-1<<8,\1
		bgt.s	.\@above

		move.w	\1,-(sp)
		move.l	#-1<<16,\1
		divs.w	(sp)+,\1	; x = -1/x

		move.w	#-pi/2,(sp)	; adj = -ã/2

; Approximate

.\@above	move.w	\1,-(sp)	; x
		fmul	\1,\1
		move.w	\1,-(sp)	; xý
		add.w	\1,\1
		add.w	\1,\1		; 4xý
		move.w	\1,-(sp)

		addi.w	#15<<8,\1
		move.w	\1,-(sp)	; 15+4xý
		fmul	6(sp),\1
		move.l	\1,-(sp)	; x(15+4xý)

		move.w	4(sp),\1
		add.w	6(sp),\1
		add.w	8(sp),\1
		move.w	\1,-(sp)	; 15+9xý

		move.l	2(sp),\1
		fdiv	(sp)+,\1	; x(15+4xý)/(15+9xý)

		lea.l	12(sp),sp

		add.w	(sp)+,\1	; Add adj

		endm


*******************************************************************************
*									      *
*	fetox dx,dy							      *
*									      *
*	Compute exp2 to dx (8.8), unsigned				      *
*									      *
*	Returns a 24.8 bit result in dy					      *
*	No registers modified						      *
*									      *
*	Pade approximation:						      *
*	  (3+x)/(3-x)							      *
*									      *
*******************************************************************************
fetox		macro
		move.w	\1,-(sp)

		moveq.l	#1,\2		; Process magnitude by bitshifting
		lsr.w	#8,\1
		lsl.w	\1,\2		; 2^int(x) = 1<<int(x)

		move.w	(sp),\1		; Restore x
		move.w	\2,-(sp)

		andi.w	#$ff,\1		; Process fraction using approximation
		move.w	\1,\2
		neg.w	\1
		addi.w	#3<<8,\1	; (3-x)
		addi.w	#3<<8,\2	; (3+x)
		ext.l	\2
		fdiv	\1,\2		; 2^frac(x) ~ (3+x)/(3-x)

		mulu.w	(sp)+,\2	; 2^x = 2^(int(x)+frac(x))
					;     = 2^int(x)*2^frac(x)
		move.w	(sp)+,\1
		endm


*******************************************************************************
*									      *
*	fsqrt dx,dy							      *
*									      *
*	Compute squareroot of dx (16.8)					      *
*									      *
*	Returns a 24.8 bit result in dy					      *
*	No registers modified						      *
*									      *
*******************************************************************************
fsqrt		macro
		move.l	\1,-(sp)
		asl.l	#8,\1		; Shift to 16.16 precision
		move.l	\1,\2		; b=a=r
		
.\@iterate	move.l	(sp),\1
		divu.w	\2,\1		; b=r/a
		ext.l	\1
		add.l	\1,\2		; a=(b+a)/2
		asr.l	#1,\2
		
		cmp.l	\1,\2
		bgt.s	.\@iterate	; Computing with signed numbers here in
					; order to allow fast longword extension
		move.l	(sp)+,\1

        	endm