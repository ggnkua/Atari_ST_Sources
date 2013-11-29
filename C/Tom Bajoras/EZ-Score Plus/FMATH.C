#define	BIAS	1023
#define FBIAS	127

#define TRUE	1
#define FALSE	0
#define expand_float(Areg, exp, frac, temp) move.l	(Areg), frac \
			asl.l		#8, frac \
			asl.l		#3, frac \
			bset		#31, frac \
			move		4(Areg), temp \
			lsr			#5, temp \
			or			temp, frac \
			move		(Areg), exp \
			asr			#4, exp \
			and			#0x07ff, exp

extern _fadd(), _fadd2(), _fsub(), _fmul(), _fdiv(), _fcom();
extern _fadd32(), _fadd322(), _fsub32();
extern _fadd32();

extern __norm(), __norm32();

static double _f10 = 10.0;
static float f1 = 1.0;
static double df1 = 1.0;

int _maxprec = 7;

static int	save_ccs;
static int	sign_thing;

double	_fpreg0;
double 	_fpreg1;
double	_fpreg2;

#define	eu	D4		/* exponent u */
#define ev	D5		/* exponent v */
#define fu	D6		/* fractional part of u */
#define fv	D7		/* fractional part of v */
#define	fw	D2		/* fractional part of result */
#define ew	D3		/* exponent of result */
	

#define	BIAS32	127

static dummy32(a, b)
float *a, *b;
{
	asm {
	_fsub32:						;*** Floating point subtract
			link	A6, #0
			movem.l	D0-D7/A0/A1, -(A7)
			move.l	b(A6), A1
			move	#0x8000, D0	;Used to set final sign
			move	D0, sign_thing(A4)
			eor		D0, (A1)	;invert sign of source
			bra		_fadd322		;call add
	_fadd32:
			link	A6, #0
			movem.l	D0-D7/A0/A1, -(A7)
			move.l	b(A6), A1		;put source address into A1
			clr		sign_thing(A4)	;don't invert final sign
			bra		_fadd322		;So linker will load it
			nop						;Make sure optimizer doesn't
	_fadd322:
			move.l	a(A6), A0		;Address of destination goes in A0
			move	(A0), eu		;and dest is in eu
			move.l	(A0), fu
			asr		#7, eu
			asl.l	#8, fu
			bset	#31, fu
			lsr.l	#1, fu
			and		#0xff, eu		;if exponent is 0 the number is 0
			bne		not01
			clr.l	fu
	not01:
			move	(A1), ev		;put source into v
			move.l	(A1), fv
			asr		#7, ev
			asl.l	#8, fv
			bset	#31, fv
			lsr.l	#1, fv
			and		#0xff, ev
			bne		not02
			clr.l	fv
	not02:
			
			move	(A0), D1
			move.l	fu, fw		;Put largest value in u and w, smaller goes
			move	eu, ew		;in v
			move	eu, D0
			sub		ev, D0
			bgt		noprob
			bne		contt
			cmp.l	fv, fu
			bge		noprob
	contt:
			move	ev, eu
			move.l	fv, fu
			move	ew, ev
			move.l	fw, fv
			move	eu, ew
			move.l	fu, fw
			move	(A1), (A0)	;use sign of b because its bigger
	noprob:
			tst.l	fv			;if source is 0 then no need to add
			beq		done_add

			move	eu, D0		;u is much bigger than v
			sub		ev, D0
			beq		noshift		;don't shift if going to shift by 0
			cmp		#31, D0
			bgt		done_add
			
			lsr.l	D0, fv		;shift left by difference in exponents
	noshift:
			move	(A1), D0	;set fv to 2's compliment number
			eor		D1, D0
			btst	#15, D0
			beq		same_sign
			neg.l	fv
	same_sign:
			add.l	fv, fw		;do add
	done_add:
			move	sign_thing(A4), D0	;set sign correctly
			eor		D0, (A1)

	__norm32:
			move.l	fw, D0
			and.l	#~0xff, D0
			bne		loop
			clr		ew			;ew is 0 for 0
			bra		pack
	loop:
			subq	#1, ew
			asl.l	#1, fw
			bcc		loop
			addq	#2, ew		;set ew correctly to get ready for loop
			
	reround:
			move	fw, D0		;Round
			and		#0x100, D0
			beq		pack		;if no need to round ready to pack
			move	fw, D0
			and		#0x2ff, D0
			beq		pack
			add.l	#0x200, fw
			bcc		pack		;if no overflow ready to pack
			lsr.l	#1, fw		;else shift fw 
			addq	#1, ew		;increase exponent
			bra		reround
			
	pack:
			lsr.l	#1, fw
			lsr.l	#8, fw
			and		#0xff, ew
			asl		#7, ew
			swap	fw
			or		ew, fw
			move	(A0), D0	;put sign in fw
			and		#0x8000, D0
			or		D0, fw
			swap	fw
			move.l	fw, (A0)
			movem.l	(A7)+, D0-D7/A0/A1
	}
}

static dummy(a, b)
double *a, *b;
{
	asm {
	_fcom: 							;Compare floating point numbers
			link	A6, #0
			movem.l	D0-D3/A0, -(A7)
			move.l	a(A6), A0		;Get to source (through the pointer) 
			move.l	(A0)+, D0		;put source in D0/D1
			move.l	(A0), D1
			move.l	b(A6), A0
			move.l	(A0)+, D2		;Put destination in D2/D3
			move.l	(A0), D3
			tst.l	D0				;if Negative 
			bpl		notneg1
			not.l	D0				;sort of negate D0/D1
			not.l	D1
			bset	#31, D0
	notneg1:
			tst.l	D2				;if D2 is negative
			bpl 	notneg2
			not.l	D2				;sort of negate D2/D3
			not.l	D3
			bset	#31, D2			;set the high bit (because its negative)
	notneg2:
			sub.l	D3, D1			;do 64 bit compare
			subx.l	D2, D0
			movem.l	(A7)+, D0-D3/A0
			unlk	A6				;because a link was done
			move	SR, save_ccs(A4)	;save CCR because it will be killed
			rts
	_fdiv:							;Floating point divide
			link	A6, #0
			movem.l	D0-D7/A0/A1, -(A7)	;save registers
			move.l	a(A6), A0			;address of source is in A0
			move.l	b(A6), A1			;address of result is in A1
			expand_float(A0, ew, fw, D0)
			beq		is_zero

			expand_float(A1, ev, fv, D0)
			beq		is_zero

			sub		ev, ew				;Set up exponent
			add		#BIAS-1, ew
			
			clr.l	fu					;used as low long word for fw
			clr.l	eu					;used as low long word for fv
			move	#32-1, D0
	divloop:							;do 64/32 bit divide
			asl.l	#1, D1
			cmp.l	fw, fv
			bcs		set				;lower 
			bne		cont
			cmp.l	fu, eu
			bhi		cont
	set:
			addq	#1, D1			;set lowest bit in D1
			sub.l	eu, fu
			subx.l	fv, fw
	cont:
			lsr.l	#1, fv	
			roxr.l	#1, eu
			
			dbf		D0, divloop
			move.l	D1, fw			;Put result into fw

			move	(A1), D0
			eor		D0, (A0)		;set sign
			bra		__norm			;normalize and exit
	_fmul:							;** Floating-point Multiply
			link	A6, #0			;no local vars
			movem.l	D0-D7/A0/A1, -(A7)	;save registers
			move.l	a(A6), A0		;Destination is at A0
			expand_float(A0, ew, fw, D0)
			beq		is_zero

			move.l	b(A6), A1		;Source is at A1
			expand_float(A1, ev, fv, D0)
			beq		is_zero
			
			sub		#BIAS, ew		;Set up exponent
			add		ev, ew

			move.l	fw, eu			;do the long multiply using 4 multiplies
			swap	eu
			move.l	fv, ev
			swap	ev
			move	eu, D1
			mulu	ev, D1
			move	fw, D0
			mulu	fv, D0
			mulu	eu, fv
			mulu	ev, fw
			swap	fv
			swap	fw
			clr.l	eu
			clr.l	ev
			move	fv, eu
			move	fw, ev
			clr		fv
			clr		fw
			add.l	fv, D0
			addx.l	eu, D1
			add.l	fw, D0
			addx.l	ev, D1

			tst.l	D0			;if the low long word is non zero
			beq		noch
			bset	#1, D1		;set bit in high word for rounding
	noch:
			move.l	D1, fw		;Move D1 to result
		
			move	(A1), D0
			eor		D0, (A0)	;set sign
			bra		__norm
	is_zero:
			clr.l	fw			;This is for special case of source or dest
			bra		__norm		;being zero in multiply or divide
	_fsub:						;*** Floating point subtract
			link	A6, #0
			movem.l	D0-D7/A0/A1, -(A7)
			move.l	b(A6), A1
			move	#0x8000, D0	;Used to set final sign
			move	D0, sign_thing(A4)
			eor		D0, (A1)	;invert sign of source
			bra		_fadd2		;call add
	_fadd:
			link	A6, #0
			movem.l	D0-D7/A0/A1, -(A7)
			move.l	b(A6), A1		;put source address into A1
			clr		sign_thing(A4)	;don't invert final sign
	_fadd2:
			move.l	a(A6), A0		;Address of destination goes in A0
			expand_float(A0, eu, fu, D0)
			bne		not01
			clr.l	fu
	not01:
			expand_float(A1, ev, fv, D0)
			bne		not02
			clr.l	fv
	not02:
			move	(A0), D1
			lsr.l	#1, fu
			lsr.l	#1, fv
			move.l	fu, fw		;Put largest value in u and w, smaller goes
			move	eu, ew		;in v
			move	eu, D0
			sub		ev, D0
			bgt		noprob
			bne		contt
			cmp.l	fv, fu
			bge		noprob
	contt:
			move	ev, eu
			move.l	fv, fu
			move	ew, ev
			move.l	fw, fv
			move	eu, ew
			move.l	fu, fw
			move	(A1), (A0)	;use sign of b because its bigger
	noprob:
			tst.l	fv			;if source is 0 then no need to add
			beq		done_add

			move	eu, D0		;u is much bigger than v
			sub		ev, D0
			beq		noshift		;don't shift if going to shift by 0
			cmp		#31, D0
			bgt		done_add
			
			lsr.l	D0, fv		;shift left by difference in exponents
	noshift:
			move	(A1), D0	;set fv to 2's compliment number
			eor		D1, D0
			btst	#15, D0
			beq		same_sign
			neg.l	fv
	same_sign:
			add.l	fv, fw		;do add
	done_add:
			move	sign_thing(A4), D0	;set sign correctly
			eor		D0, (A1)

	__norm:						;normalize
			move.l	fw, D0
			and.l	#~0xff, D0
			bne		loop
			clr.l	D1			;to store a 0
			clr.l	fw
			bra		pack0
	loop:
			subq	#1, ew
			asl.l	#1, fw
			bcc		loop
			addq	#2, ew		;set ew correctly to get ready for loop
			
	reround:
			move	fw, D0		;Round
			and		#0x100, D0
			beq		pack		;if no need to round ready to pack
			move	fw, D0
			and		#0x2ff, D0
			beq		pack
			add.l	#0x100, fw
			bcc		pack		;if no overflow ready to pack
			lsr.l	#1, fw		;else shift fw 
			addq	#1, ew		;increase exponent
			bra		reround
			
	pack:						;for 64 bits
			and		#~0x1ff, fw
			move.l	fw, D1
			lsr.l	#4, fw
			lsr.l	#8, fw
			and		#0x07ff, ew
			asl		#4, ew
			swap	fw
			and		#0xf, fw
			or		ew, fw
			move	(A0), D0	;put sign in fw
			and		#0x8000, D0
			or		D0, fw
			swap	fw
	pack0:
			move.l	fw, (A0)+	;first 32 bits
			asl		#4, D1
			swap	D1
			clr		D1
			move.l	D1, (A0)	;second 32 bits
			movem.l	(A7)+, D0-D7/A0/A1
	}
}

int 	(*jmp_tbl[])() = {
		_fadd, _fsub, _fmul, _fdiv, _fcom, /* fudge */__norm, __norm32 };

_ffunc(action, dest, source)	/* do a floating point operation */
double *source, *dest;
int action;
{
	int		type;
	double	temp;

	asm { 
		movem.l	D0-D2/A0, -(A7) 
	}
	
	type = action & 0xff00;		/* Type is the high byte of the action */
	action &= 0xff;				/* The action (add, subtract etc. is low byte */
	if (type == 0x2000) {		/* if source is int */
		asm {
			move.l	source(A6), A0
			move	(A0), D0
			ext.l	D0				;change it to a long
			move.l	D0, temp(A6)	;put it in a memory location
		}
		_from_long(&temp);			/* change a long to working float size */
		source = &temp;				/* set source address at new float */
	}
	else if (type == 0x2800 || type == 0x1000) {/* If source is a long */
		asm {									/* or float */
			move.l	source(A6), A0	/* put source in a new place */
			move.l	(A0), temp(A6)
		}
		if (type == 0x2800)
			_from_long(&temp);			/* change source to double */
		else
			_from_float(&temp);
		source = &temp;				/* set source pointer */
	}
	
	(*jmp_tbl[action])(dest, source);	/* call correct math function */

	asm { 
		movem.l 	(A7)+, D0-D2/A0 	/* restore registers */
		unlk		A6
		move.l		(A7), 10(A7)		/* return taking off passed params */
		adda		#10, A7
		move		save_ccs(A4), CCR
		rts
	}
	
}

extern _0from_long(), _0to_long(), _0from_float(), _0to_float();
extern _1from_long(), _1to_long(), _1from_float(), _1to_float();
extern _2from_long(), _2to_long(), _2from_float(), _2to_float();
extern _to_long(), _from_long(), _to_float(), _from_float();

extern _incfloat(), _decfloat(), _incdouble(), _decdouble();

_fmathops()
{

asm {
;
;		Incfloat etc. routine expect the address of the opernand to be
;		on the stack when they are called
;
_incdouble:
		pea		df1(A4)
	    move.l	8(A7), -(A7)		;make a copy of the address
		jsr		_fadd
		addq	#8, A7
		move.l	(A7), 4(A7)
		addq	#4, A7
		rts
_incfloat:
		pea		f1(A4)
	    move.l	8(A7), -(A7)		;make a copy of the address
		jsr		_fadd32
		addq	#8, A7
		move.l	(A7), 4(A7)
		addq	#4, A7
		rts
_decdouble:
		pea		df1(A4)
		move.l	8(A7), -(A7)
		jsr		_fsub
		addq	#8, A7
		move.l	(A7), 4(A7)
		addq	#4, A7
		rts
_decfloat:
		pea		f1(A4)
		move.l	8(A7), -(A7)
		jsr		_fsub32
		addq	#8, A7
		move.l	(A7), 4(A7)
		addq	#4, A7
		rts
;
;
;
;
_0from_long:			 
	move.l	D0, _fpreg0(A4)
	pea		_fpreg0(A4)
	jsr		_from_long
	addq	#4, A7
	rts

_0to_long:
	pea		_fpreg0(A4)
	jsr		_to_long
	addq	#4, A7
	move.l	_fpreg0(A4), D0
	rts

_0from_float:			 
	move.l	D0, _fpreg0(A4)
	pea		_fpreg0(A4)
	jsr		_from_float
	addq	#4, A7
	rts

_0to_float:
	pea		_fpreg0(A4)
	jsr		_to_float
	addq	#4, A7
	move.l	_fpreg0(A4), D0
	rts

_1from_long:			 
	move.l	D1, _fpreg1(A4)
	pea		_fpreg1(A4)
	jsr		_from_long
	addq	#4, A7
	rts

_1to_long:
	pea		_fpreg1(A4)
	jsr		_to_long
	addq	#4, A7
	move.l	_fpreg1(A4), D1
	rts

_1from_float:			 
	move.l	D1, _fpreg1(A4)
	pea		_fpreg1(A4)
	jsr		_from_float
	addq	#4, A7
	rts

_1to_float:
	pea		_fpreg1(A4)
	jsr		_to_float
	addq	#4, A7
	move.l	_fpreg1(A4), D1
	rts

_2from_long:			 
	move.l	D2, _fpreg2(A4)
	pea		_fpreg2(A4)
	jsr		_from_long
	addq	#4, A7
	rts

_2to_long:
	pea		_fpreg2(A4)
	jsr		_to_long
	addq	#4, A7
	move.l	_fpreg2(A4), D2
	rts

_2from_float:			 
	move.l	D2, _fpreg2(A4)
	pea		_fpreg2(A4)
	jsr		_from_float
	addq	#4, A7
	rts

_2to_float:
	pea		_fpreg2(A4)
	jsr		_to_float
	addq	#4, A7
	move.l	_fpreg2(A4), D2
	rts
}
}

_to_float(dptr)
double *dptr;
{
asm {
			movem.l		D0/D1/A0, -(A7)			;save registers
			move.l		dptr(A6), A0			;Get pointer to number in A0
			move.l		(A0), D0				;move high long word to D0
			move.l		4(A0), D1				;move low to D1
			bne			not0
			tst.l		D0
			beq			done
			
	not0:
			asl.l		#1, D1					;shift number 3 bits to left
			roxl.l		#1, D0
			asl.l		#1, D1
			roxl.l		#1, D0
			asl.l		#1, D1
			roxl.l		#1, D0
			move.l		(A0), D1				;Get sign bit
			and.l		#0x80000000, D1
			add.l		#(BIAS32-BIAS)<<23, D0	;change bias to 32 bit bias
			or.l		D1, D0					;Replace sign bit
	done:
			move.l		D0, (A0)				;store number were old number 
			movem.l		(A7)+, D0/D1/A0			;was and restore registers
	}
}

_from_float(fptr)
float *fptr;
{
asm {
			movem.l		D0/D1/A0, -(A7)			;save registers
			move.l		fptr(A6), A0			;Get pointer to number in A0
			clr.l		D1
			move.l		(A0), D0				;move high long word to D0
			bne			not0
			clr.l		D0
			bra			done
	not0:
			asr.l		#1, D0					;shift number 3 bits to left
			roxr.l		#1, D1
			asr.l		#1, D0
			roxr.l		#1, D1
			asr.l		#1, D0
			roxr.l		#1, D1
			and.l		#0x8fffffff, D0			;Get rid of repeated sign bits
			add.l		#(BIAS-BIAS32)<<20, D0	;change bias to 64 bit bias
	done:
			move.l		D0, (A0)+				;store number were old number 
			move.l		D1, (A0)				;was
			movem.l		(A7)+, D0/D1/A0			;restore registers
	}
}

_to_long(float_ptr)
double *float_ptr;
{
	asm {
			movem.l		D0-D2/A0, -(A7)
			move.l		float_ptr(A6), A0
			expand_float(A0, D0, D1, D2) 	;Get fraction part in D1 exp in D0
			bne			not_zero
			clr.l		D1
			bra			noshift
	not_zero:
			sub			#BIAS+31, D0
			neg			D0
			beq			noshift
			lsr.l		D0, D1
	noshift:
			btst		#7, (A0)
			beq			notneg
			neg.l		D1
	notneg:
			move.l		D1, (A0)
			movem.l		(A7)+, D0-D2/A0
	}
}

_from_long(long_ptr)
long *long_ptr;
{
	asm {
			movem.l		D0-D7/A0/A1, -(A7)
			move.l		long_ptr(A6), A0
			move.l		(A0), fw
			bne			not_zero
			clr			ew
			clr.l		fw
			bra			ok
	not_zero:
			bgt			notneg
			neg.l		fw
	notneg:
			move		#30+BIAS, ew
			move.l		fw, D0
			and.l		#~0xff, D0
			bne			ok
			asl.l		#8, fw
			sub			#8, ew
	ok:
			jmp			__norm
	}
}

/*
	convert floating point number to a string of digits
*/
fconvert(y, p, exp_ptr, prec)
register char *y;		/* starts as pointer to double */
register char *p;
int *exp_ptr;
int prec;
{
	register long saveD1, saveD3;
	register int exp10;
	char *startp;
	int	zero = FALSE;
	double	number;
	
	startp = p;
	number = * (double *) y;
	asm {
			clr		exp10
			lea		number(A6), y
	chex:
			move	(y), saveD1
			lsr		#4, saveD1
			and		#0x7ff, saveD1
			beq		gotzero
			sub		#BIAS, saveD1
			tst		saveD1
			bgt		greater
			cmp		#-3, saveD1
			blt		less
			bra		expok
	greater:
			addq	#1, exp10
			pea		_f10(A4)
			move.l	y, -(A7)
			jsr		_fdiv
			addq	#8, A7
			bra		chex
	less:
			subq	#1, exp10
			pea		_f10(A4)
			move.l	y, -(A7)
			jsr		_fmul
			addq	#8, A7
			bra		chex
	expok:
			move.l	(y), D3		;Get fractional part in D3
			asl.l	#8, D3
			asl.l	#3, D3
			move	4(y), D0	;Get 11 bits from low 32 bits and
			lsr		#5, D0		;add that to the 21 bits already in D3
			or		D0, D3
			bset	#31, D3
			tst		saveD1
			beq		iszero
			neg		saveD1
			lsr.l	saveD1, D3
	iszero:
			move	#'0', D0
			asl.l	#1, D3
			bcc		contin
			addq	#1, D0
	contin:
			move.b	D0, (p)+
			move	prec(A6), D0
	nextch:
			clr		D1
			asl.l	#1, D3
			roxl	#1, D1
			move.l	D3, saveD3
			move	D1, saveD1
			asl.l	#1, D3
			roxl	#1, D1
			asl.l	#1, D3
			roxl	#1, D1
			add.l	saveD3, D3
			addx	saveD1, D1
			add		#'0', D1
			move.b	D1, (p)+
			dbf		D0, nextch
			clr.b	(p)
			bra		done
gotzero:	addq	#1, zero(A6)
done:
	}
	if (zero) {
		p = startp;
		for (saveD1 = 0; saveD1 < prec; saveD1++)
			*p++ = '0';
		*p = 0;
	}
	else {
		p = startp+prec+1;
		if (*startp == '0')
			p++;
		*--p += 5;
		while (*p > '9') {
			*p -= 10;
			(*--p)++;
		}
		if (*startp == '0') {
			p = startp;
			y = p+1;
			while (*p++ = *y++)
				;
			exp10--;
		}
		*(startp+prec) = 0;
	}
	*exp_ptr = exp10;
}

int exponent(x)
double x;
{
	asm {
			move	x(A6), D0
			asr		#4, D0
			and		#0x7ff, D0
			beq		gotzero
			sub		#BIAS, D0
	gotzero:
	}
}

double putexp(x, e)
double x;
int e;
{
	asm {
			move	e(A6), D0
			move	x(A6), D1
			and		#~0x800f, D1	; Don't do anything if the exponent
			beq		done			; is zero
			andi	#0x800f, x(A6)
			add		#BIAS, D0
			and		#0x7ff, D0
			asl		#4, D0
			or		D0, x(A6)
	done:
	}
	return x;
}
