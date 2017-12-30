; Math libs. all stuff in here, sin/cos/tan/exp/atan/random,etc.

;======= equates ===========================================================

* >WARNING< for these equ's: when using a new 'sintbllen' you must
* recalculate 'cos1' and 'sin1'!
sintbllen:	equ	2048		* MUST BE A EXPONENTIAL VALUE OF 2!
sin1:		equ	13176774	* sin(2ã/2048)*2^32
cos1:		equ	4294947083	* cos(2ã/2048)*2^32

Math.EXP_ITERATIONS:	=	10

; This is really awful.. To avoid distortion near angles of +-pi/4, you
; need at least 20 iterations!
Math.SATAN:		=	1			; fast but 'Sneaky ATAN'
Math.ATAN_ITERATIONS:	=	40
Math.RAD2DEG:		=	sintbllen*5000/31415	;degs/2pi

	ifne	0

Calc_NextRandom:	MACRO
	move.l	random,d0
	move.l	d0,d1
	mulu.w	d0,d0
	eor.l	d1,d0
	addq.l	#7,d0
	move.l	d0,random
	ENDM

getNextRandom:
	Calc_NextRandom
	rts

	endc

* Very fast and accurate squareroot algorithm.
* Quite lengthy, though: 66 bytes.
* INPUT: d1.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.l: squareroot of value (16.16 fixed point)
Math.sqrt:
CALC_ATARISQRT:
	moveq	#1,d2
	ror.l	#2,d2
	moveq	#$F,d3
.loop1:	cmp.l	d2,d1
	bgt.s	.endloop1
	add.l	d1,d1
	lsr.l	#1,d2
	dbf	d3,.loop1
	moveq	#0,d0
	bra.s	.is_null
.endloop1:

	sub.l	d2,d1
	move.l	d2,d0
	lsr.l	#1,d2
.loop2:	lsr.l	#1,d2
	add.l	d2,d0
	cmp.l	d0,d1
	bgt.s	.endloop2
	sub.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2
	bra.s	.end
.endloop2:

	sub.l	d0,d1
	add.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2

.end:	add.l	d0,d0
	addi.l	#$00008000,d0
.is_null:
	rts

*==========================================================================
* Sinewave table generator.
* By EarX/~fUn~, 10-5-1998
* 68020 or higher is required!
*==========================================================================

* Macro that returns the modulo of a given angle.
* INPUT: angle: type: data-register (word) or RAM (word)
Do_SinModulo:	MACRO	angle
		andi.w	#sintbllen-1,\1
		ENDM

* Macro that returns sine & cosine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: sinreg: type: data-register (long) or address-register
*                 contains: sine value (signed: -32768 to 32767)
*         cosreg: type: data-register (long) or address-register
*                 contains: cosine value (signed: -32768 to 32767)
Get_SinCos:	MACRO	base,inpreg,sinreg,cosreg
		movem.w	(\1,\2.w*4),\3/\4
		ENDM

* Macro that returns sine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: sinreg: type: data-register (long) or address-register
*                 contains: sine value (signed: -32768 to 32767)
Get_Sin:	MACRO	base,inpreg,sinreg
		move.w	(\1,\2.w*4),\3
		ENDM

* Macro that returns cosine of a given angle.
* PRECONDITION: INIT_SINETABLE has been called!
* INPUT: base: type: address-register or address or relative address
*        inpreg: type: data-register or address-register (lower word)
*                contains: angle (0=0ø, sintbllen=360ø)
* OUTPUT: cosreg: type: data-register (long) or address-register
*                 contains: cosine value (signed: -32768 to 32767)
Get_Cos:	MACRO	base,inpreg,cosreg
		move.w	2(\1,\2.w*4),\3
		ENDM

* Creates the a combined sine and cosine table for quick fetching.
* Macro is exactly 96 bytes in length :-)
* INPUT: a0: address of sine_tbl
Init_SineTable:	MACRO
		moveq	#$ffffffff,d0		* /cos(0)=1
		lsr.l	#1,d0			* \(=$7fffffff)
		moveq	#0,d1			* sin(0)=0
		move.l	#sin1,d6
		move.w	#sintbllen/4-1,d7

.genlop:	swap	d0			* Get high-word of cosa
		swap	d1			* Get high-word of sina
		move.w	d1,2+(sintbllen)*3(a0)	* Copy sina in cos-4th quadrant
		move.w	d0,sintbllen*1(a0)	* Copy cosa in sin-2nd quadrant
		sub.w	d1,2+(sintbllen)*1(a0)	* Copy -sina in cos-2nd quadrant
		sub.w	d0,sintbllen*3(a0)	* Copy -cosa in sin-4th quadrant
		sub.w	d0,2+(sintbllen)*2(a0)	* Copy -cosa in cos-3rd quadrant
		sub.w	d1,sintbllen*2(a0)	* Copy -sina in sin-3rd quadrant
		move.w	d1,(a0)+		* Save sina (16 bit signed value) in first quadrant
		move.w	d0,(a0)+		* Save cosa (16 bit signed value) in first quadrant
		swap	d0			* Change cosa back to fixedpoint
		swap	d1			* Change sina back to fixedpoint
		move.l	d1,d4			* / Backup sina 
		move.l	d0,d5			* | and cosa
		move.l	d1,d2			* | for use in
		move.l	d0,d3			* \ multiplications.
		mulu.l	d6,d3:d1		* d3:=sin1*sina
		mulu.l	#cos1,d2:d0		* d2:=cos1*cosa
		mulu.l	d6,d1:d5		* d0:=sin1*cosa
		mulu.l	#cos1,d0:d4		* d1:=cos1*sina
		sub.l	d3,d2			* d2:=(cos1*cosa)-(sin1*sina)
		add.l	d0,d1			* sina:=(sin1*cosa)+(cos1*sina)
		move.l	d2,d0			* cosa:=(cos1*cosa)-(sin1*sina)
		dbra	d7,.genlop
		ENDM

* Creates a tangens table by using the sine/cosine table.
* INPUT: sincos_tbl: address register
* OUTPUT: tan_tbl: address register
Init_TanTable:	MACRO	sincos_tbl,tan_tbl
		move.w	#sintbllen-1,d7
.gentanloop:	movem.w	(/1)+,d0-d1
		move.w	d0,d0
		beq.s	.notandiv
		lsl.l	#8,d1
		divs.w	d0,d1
.notandiv:	move.w	d1,(/2)+
		dbra	d7,.gentanloop
		ENDM

	ifne	0

;------------------------------------------------------------------------------
; exp(x) using Taylor series:
;
; exp(x)=1+x+(1/2!)x^2+(1/3!)x^3+..
; exp(x)=Sum[ n : 0<=n : x^n/n! ]
;
;------------------------------------------------------------------------------
; Proof of correctness by variation of constant N:
;
; exp(x,N)= Sum[ n : 0<=n<=N : x^n/n! ]
;
; exp(x,N+1)= exp(x,N) + x^(N+1)/(N+1)!
;
;                x      x^N
; = exp(x,N) + ----- * -----
;               N+1     N!
;
; => { T.n = x^n/n! }
;
;------------------------------------------------------------------------------
; Main invariants:
;
; exp(x,0)=T.0=1
; T.(N+1)=x/(N+1)*T.n
; exp(x,N+1) = exp(x,N) + x/(N+1)*T.n
;
;------------------------------------------------------------------------------

; Unsigned 16b fractional implementation. Inputs and outputs fixedpoint.
; Reasonably accurate, at least: when |x|>1 => |x|<#iterations*2!!
; AND when numbers can be extremely large (even more than doubleprec!).
; |x|<=1 always works fast and accurate.
; Needs 020 or higher..
;
; Better idea is to precalc e and 1/e and put them in tables.
; Then only power function is needed. This is simple cos of the short
; fractional taylor approx and the highly optimisable multiplier with
; precalced tables!! Maybe next time..
;
; INPUT:
; d0.l=x (16:16)
; OUTPUT:
; d1.l=exp(x) (16:16)
Math.exp:
; todo: power function and table stuff!

; Good fractional exp function. Even works with few iterations.
Math.fracExp:
	IFNE	1

	bsr	Fix32.toFloat
; d0.l=x (f)
	moveq	#1,d7
	move.l	#$7FFFFF00,d6			; d6.l=T.0=1.0 (f)
	move.l	d0,d5				; d5.l=x (f)
	movea.l	d6,a0				; a0=exp(x,0) (f)

.loop:	move.l	d6,d1				; d1.l=T.n (f)
	move.l	d5,d0				; d0.l=x (f)
; d0.l=x (f), d1.l=T.n (f)
	bsr	Float.mul
	move.l	d0,d6
; d6.l=x*T.n (f)
	move.l	d7,d0
	bsr	Int.toFloat
	move.l	d0,d1
	move.l	d6,d0
; d0.l=x*T.n (f), d1.l=n+1 (f)
	bsr	Float.div	
; d0.l=T.(n+1)=x/(n+1)*T.n (f)
	move.l	d0,d6				; Store T.(n+1)
	move.l	a0,d1
; d1.l=exp(x,n)
	bsr	Float.add
	movea.l	d0,a0
; d5.l=exp(x,n+1)
	addq.w	#1,d7				; n:=n+1
	cmpi.w	#Math.EXP_ITERATIONS,d7
	blt.s	.loop

	bsr	Float.toFix32
; d0.l=exp(x) (16:16)

	ELSE

	moveq	#1,d7
	move.l	#$00010000,d1
	move.l	d1,d2

.loop:	muls.l	d0,d3:d2
	move.w	d3,d2
	swap	d2
; d2.l=x*T.n (16:16)
	divs.l	d7,d2
; d2.l=T.(n+1)=x/(N+1)*T.n
	add.l	d2,d1
; d1.l=exp(x,n+1)=exp(x,n)+T.(n+1)
	addq.w	#1,d7
	cmpi.w	#Math.EXP_ITERATIONS,d7
	blt.s	.loop

	ENDC
	rts

;------------------------------------------------------------------------------
; Definition of arctan(x) using Taylor series:
;
; arctan(x)=x-x^3/3+x^5/5-..., (-1<x<+1)
;
; arctan(x)= Sum[ n : 0<=n : (-1)^n*x^(1+2n)/(1+2n) ], (-1<x<+1)
;
;------------------------------------------------------------------------------
; Proof of correctness by variation of constant N:
;
; arctan(x,N)= Sum[ n : 0<=n<=N : (-1)^n*x^(1+2n)/(1+2n) ]
;
; arctan(x,N+1)= arctan(x,N) + (-1)^(N+1)*x^(1+2(N+1))/(1+2(N+1))
;
; p.n=1+2n
; p.0=1
; p.(n+1)=p.n+2
;
; T.n=x^p.n
; T.0=x^p.0=x^1=x
; T.(n+1)=x^p.(n+1)=x^(p.n+2)=x^p.n*x*x=T.n*x*x
;
;------------------------------------------------------------------------------
; Main invariants:
;
; arctan(x,0)= (-1)^0*x^1/1= T.0= x
;
; arctan(x,N+1)= arctan(x,N) + (-1)^(N+1)*T.N*x*x/(p.N+2)
;------------------------------------------------------------------------------

; Unsigned 16b fractional implementation. Inputs and outputs fixedpoint.
; Reasonably accurate and works on old 68000.
; INPUT:
; d0.l=x (16:16) (-256.0<x<+256.0)
; OUTPUT:
; d1.l=arctan(x) (radians) (16:16)
Frac.arctan:

	move.l	d0,-(sp)
	bpl.s	.sign_okay
	neg.l	d0
.sign_okay:
	cmpi.l	#$00010000,d0
	bne.s	.calc_quadrant

; Output pi/4 (arctan(1)=pi/4).
	move.l	#31415<<14/10000,d1
	tst.l	(sp)+
	bpl.s	.sign_okay2
	neg.l	d1
.sign_okay2:
	rts

.calc_quadrant:
	bgt.s	.adjust
	bsr.s	.calc
	tst.l	(sp)+
	bpl.s	.end_sign
	neg.l	d1
.end_sign:
	rts

.adjust:
	move.l	#$01000000,d1
	lsr.l	#8,d0
	divu.w	d0,d1
	move.w	d1,d0				; d0.w=1/x (frac)
;	moveq	#$FFFFFFFF,d1
;	divu.l	d0,d1
;	move.w	d1,d0

	bsr.s	.calc
	move.l	#31415<<15/10000,d2
	sub.l	d1,d2
	move.l	d2,d1				; d1.l=pi/2-arctan(1/x)
	tst.l	(sp)+
	bpl.s	.end_sign2
	neg.l	d1
.end_sign2:
	rts
	
; d0.l=x (16:16, 0<=x<1)
; OUTPUT:
; d1.l=arctan(x) (16:16, non-negative)
.calc:

	IFNE	Math.SATAN

; atan(a) =~ x/(1+0.28*x*x)
	move.w	d0,d2
	mulu.w	d2,d2
	swap	d2				; d2.w=x*x (frac)
	mulu.w	#65536*28/100,d2		; d2.l=0.28*x*x (frac)
	move.w	#1,d2
	swap	d2				; d2.l=1+0.28*x*x (16:16)
	swap	d0				; d0.l=x<<16 (16:16)
	divu.l	d2,d0				; d0.l=x/(1+0.28*x*x)
	move.l	d0,d1
	
	ELSE

	clr.l	d1
	move.w	d0,d1				; d1.l=arctan(x,n)={n=0}=x (frac)
	moveq	#1,d2				; d2.l=p.n=2n+1
	move.w	d0,d3				; d3.l=T.n={n=0}=x (frac)
	mulu.w	d0,d0
	swap	d0				; d0.w=x*x (frac)
	moveq	#Math.ATAN_ITERATIONS/2-1,d6	; d6.w=counter

.loop:
; Calculate p.(n+1).
	addq.w	#2,d2				; d2.l=p.n+2=p.(n+1)

; Calculate T.(n+1).
	mulu.w	d0,d3				; d3.l=T.(n+1)=x*x*T.n (16:16)
	swap	d3				; d3.w=T.(n+1)=x*x*T.n (frac)
	clr.l	d5
	move.w	d3,d5
	divu.w	d2,d5				; d5.w=x*x*T.n/(p.n+2) (frac)

; Calculate arctan(x,n+1).
	sub.w	d5,d1

; Calculate p.(n+1).
	addq.w	#2,d2				; d2.l=p.n+2=p.(n+1)

; Calculate T.(n+1).
	mulu.w	d0,d3				; d3.l=T.(n+1)=x*x*T.n (16:16)
	swap	d3				; d3.w=T.(n+1)=x*x*T.n (frac)
	clr.l	d5
	move.w	d3,d5
	divu.w	d2,d5				; d5.w=x*x*T.n/(p.n+2) (frac)

; Calculate arctan(x,n+1).
	add.w	d5,d1
	dbra	d6,.loop

	ENDC

	rts

; Uses two input system..
; INPUT:
; d0.l=x (int)
; d1.l=y (int)
Frac.atan2:
	clr.l	d3
	cmp.l	d0,d1
	bhi.s	.sorted
	bne.s	.go_on
	moveq	#$FFFFFFFF,d0
	bra.s	.a_calced
.go_on:	exg	d0,d1
	not.l	d3
.sorted:swap	d0
	divu.w	d1,d0				; d0.w=a=x/y (frac)
.a_calced:

; atan(a) =~ a/(1+0.28*a*a)
	move.w	d0,d2
	mulu.w	d2,d2
	swap	d2				; d2.w=a*a (frac)
	mulu.w	#65536*28/100,d2		; d2.l=0.28*a*a (frac)
	move.w	#1,d2
	swap	d2				; d2.l=1+0.28*a*a (16:16)
	swap	d0				; d0.l=a<<16 (16:16)
	divu.l	d2,d0				; d0.l=a/(1+0.28*a*a)
	move.l	d0,d1

	tst.l	d3
	beq.s	.end
	move.l	#31415<<15/10000,d2
	sub.l	d1,d2
	move.l	d2,d1				; d1.l=pi/2-arctan(1/a)

.end:	rts


	IFNE	0

; Floating point implementation, accuracy overkill, you all know I'm sick.
; Needs 68020 or higher.
;
; integers: n, p.n
; reals:    x, x*x, T.n, arctan(x,n)
;
; INPUT:
; d0.l=x (float)
; OUTPUT:
; d1.l=arctan(x) (radians) (float)
Float.arctan:
	cmpi.l	#$40000001,d0
	bne.s	.calc_quadrant

; Output pi/4 (arctan(1)=pi/4).
	move.l	#$6487ED00,d0
	rts

.calc_quadrant:
	move.l	#$40000001,d1
	move.l	d0,-(sp)
	bsr	Float.sub			; d0.l=x-1.0 (float)
	move.l	d0,d1				; d1.l=x-1.0 (float)
	move.l	(sp)+,d0			; d0.l=x (float)
	tst.l	d1
	bgt.s	.adjust
	bra.s	.calc

.adjust:move.l	d0,d1				; d1.l=x (float)
	move.l	#$40000001,d0			; d0.l=1.0 (float)
	bsr	Float.div			; d0.l=1/x (float)
	bsr.s	.calc				; d1.l=arctan(1/x) (float)
	move.l	#$6487ED01,d0			; d0.l pi/2 (float)
	bsr	Float.sub
	move.l	d0,d1				; d1.l=pi/2-arctan(1/x) (float)
	rts
	
.calc:	move.l	d0,d1
	move.l	d0,-(sp)
	bsr	Float.mul
	move.l	d0,d4				; d4.l=x*x (float)
	move.l	(sp)+,d0
	sub.l	a6,a6				; a6=n=0
	moveq	#1,d7				; d7.l=p.n=2n+1
	move.l	d0,d1				; d1.l=arctan(x,n)={n=0}=T.n (float)
	move.l	d0,d3				; d3.l=T.n (float)

.loop:	addq.w	#2,d7				; d7.l=(p.n+2)=p.(n+1) (int)

; Calculate T.(n+1).
	move.l	d1,-(sp)
	move.l	d3,d0
	move.l	d4,d1
	bsr	Float.mul
; d0.l=T.(n+1)=x*x*T.n (float)
	move.l	d0,-(sp)
	move.l	d7,d0
	bsr	Int.toFloat
	move.l	d0,d1
	move.l	(sp),d0
; d0.l=T.(n+1)=x*x*T.n (float)
; d1.l=p.(n+1) (float)
	bsr	Float.div
	move.l	(sp)+,d3
; d3.l=T.(n+1)=x*x*T.n (float)
; d0.l=T.(n+1)=x*x*T.n/p.(n+1) (float)
	move.l	(sp)+,d1

; Calculate (-1)^(n+1)*T.(n+1).
.sign:	addq	#1,a6
	move.l	a6,d5
	btst	#0,d5
	beq.s	.end_sign
	move.l	d1,-(sp)
	bsr	Float.neg
	move.l	(sp)+,d1
.end_sign:

; Calculate arctan(x,n+1).
; d0.l=(-1)^(n+1)*T.(n+1) (float)
; d1.l=arctan(x,n) (float)
	movem.l	d3-d4,-(sp)
	bsr	Float.add
	movem.l	(sp)+,d3-d4
	move.l	d0,d1
; d1.l=arctan(x,n+1) (float)

	cmpa.w	#Math.ATAN_ITERATIONS,a6
	blt.s	.loop
	rts

	ENDC

; INPUT:
; d0.l=src1 (float)
; d1.l=src2 (float)
; OUTPUT:
; d0.l=dest (float) src1*src2
Float.mul:
	clr.l	d2
	clr.l	d3
	move.b	d0,d2				; d2.b=exp src1
	move.b	d1,d3				; d3.b=exp src2
	sub.l	d2,d0				; d0.l=mantisse src1
	sub.l	d3,d1				; d1.l=mantisse src2
	muls.l	d0,d0:d1
	add.l	d1,d1
	addx.l	d0,d0				; d0.l=mantisse of src1*src2
	subq.b	#1,d2
	add.l	d1,d1
	addx.l	d0,d0
	bvc.s	.end_normalization
	addx.b	d0,d0
	ror.l	d0
	addq.b	#1,d2
.end_normalization:
	add.b	d3,d2				; d2.b=exp of src1*src2
	move.b	d2,d0
	rts

; INPUT:
; d0.l=divident (float)
; d1.l=divisor (float)
; OUTPUT:
; d0.l=quotient (float) divident/divisor
Float.div:
	clr.l	d2
	clr.l	d3
	move.b	d0,d2				; d2.b=exp src1
	move.b	d1,d3				; d3.b=exp src2
	sub.l	d2,d0				; d0.l=mantisse src1
	sub.l	d3,d1				; d1.l=mantisse src2
	sub.b	d3,d2				; d2.b=exp of src1*src2
	asr.l	#2,d0				; divident<divisor, cos of result limit.
	clr.l	d3
	divs.l	d1,d0:d3			; d0.l=mantisse of src1*src2
	move.l	d3,d0
	add.l	d0,d0
	bvc.s	.end_normalization
	move.l	d3,d0
	addq.b	#1,d2
.end_normalization:
	move.b	d2,d0
	rts

; INPUT:
; d0.l=src1 (24b mantisse:8b exponent)
; d1.l=src2 (24b mantisse:8b exponent)
; OUTPUT:
; d0.l=dest (24b mantisse:8b exponent) src1-src2
Float.sub:
	move.b	d1,d3
	clr.b	d1
	neg.l	d1
	move.b	d3,d1

;
; m: mantissa, p: power
;
; a+b~= { m=m(a)+m(b)>>[p(a)-p(b)], p=p(a); p(a)>=p(b)
;       { m=m(b)+m(a)>>[p(b)-p(a)], p=p(b); p(a)<p(b)
;
; INPUT:
; d0.l=src1 (24b mantisse:8b exponent)
; d1.l=src2 (24b mantisse:8b exponent)
; OUTPUT:
; d0.l=dest (24b mantisse:8b exponent) src1+src2
Float.add:
	clr.l	d2
	clr.l	d3
	move.b	d0,d2				; d2.b=p(a)
	move.b	d1,d3				; d3.b=p(b)
	sub.l	d2,d0				; d0.l=m(a)
	sub.l	d3,d1				; d1.l=m(b)
	cmp.b	d3,d2				; p(a)>=p(b)??
	bge.s	.end_exg
	exg.l	d0,d1
	exg.l	d2,d3
.end_exg:
	move.b	d2,d4
	sub.b	d3,d2				; d2.b=p(a)-p(b)
	asr.l	d2,d1				; d1.l=m(b)>>[p(a)-p(b)]
	addq.b	#1,d4
	add.l	d1,d0				; d0.l=m(a)+m(b)>>[p(a)-p(b)]
	bvc.s	.normalize_loop
	addx.b	d0,d0				; if carried..
	ror.l	#1,d0				; ..make negative
	move.b	d4,d0
	rts

.normalize_loop:
	subq.b	#1,d4
	move.l	d0,d2
	add.l	d0,d0
	bvc.s	.normalize_loop
.end_normalization:
	move.l	d2,d0
	move.b	d4,d0				; d0.l={m(a)+m(b)>>[p(a)-p(b)],p=p(a)}=a+b
	rts

; INPUT:
; d0.l=src (24b mantisse:8b exponent)
; OUTPUT:
; d0.l=-src (24b mantisse:8b exponent)
Float.neg:
	move.b	d0,d1
	clr.b	d0
	neg.l	d0
	move.b	d1,d0
	rts

; INPUT:
; d0.l=src (24m:8e)
; OUTPUT:
; d0.l=src (32b signed)
Float.toInt:
	move.b	d0,d1
	clr.b	d0
	subi.b	#31,d1				; d1.b=exp-[log(r)+7]
	bpl.s	.limit_0
	neg.b	d1
	asr.l	d1,d0
	rts
.limit_0:
	clr.l	d0
	rts

; INPUT:
; d0.l=src (24m:8e)
; OUTPUT:
; d0.l=src (16:16 sgn)
Float.toFix32:
	move.b	d0,d1
	clr.b	d0
	subi.b	#15,d1				; d1.b=exp-[log(r)+7]+16
	bpl.s	.limit_0
	neg.b	d1
	asr.l	d1,d0
	rts
.limit_0:
	clr.l	d0
	rts

; INPUT:
; d0.l=src (32b signed)
; OUTPUT:
; d0.l=src (24m:8e)
Int.toFloat:
	moveq	#31,d1
	tst.l	d0
	beq.s	.limit_0
.normalize_loop:
	move.l	d0,d2
	add.l	d0,d0
	dbvs	d1,.normalize_loop
	move.l	d2,d0
	move.b	d1,d0				; d0.l={m(a)+m(b)>>[p(a)-p(b)],p=p(a)}=a+b
	rts
.limit_0:
	move.l	#$40000080,d0	
	rts

; Converts 16:16 fixed point number to floating point.
; INPUT:
; d0.l=src (32b signed)
; OUTPUT:
; d0.l=src (24m:8e)
Fix32.toFloat:
	moveq	#31,d1
	tst.l	d0
	beq.s	.limit_0
.normalize_loop:
	move.l	d0,d2
	add.l	d0,d0
	dbvs	d1,.normalize_loop
	move.l	d2,d0
	move.b	d1,d0				; d0.l={m(a)+m(b)>>[p(a)-p(b)],p=p(a)}=a+b
	subi.b	#16,d0				; /65536
	rts
.limit_0:
	move.l	#$40000080,d0	
	rts

	endc

;	BSS
;
;random:	DS.L	1
