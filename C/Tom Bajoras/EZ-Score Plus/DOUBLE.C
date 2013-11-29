overlay "megamax"

#define	BIAS	1023
#define FBIAS	127

int _maxprec = 16;

#define bhs		bcc
#define TRUE	1
#define FALSE	0
#define expand_float(Areg, exp, frac, frac2) move.l	(Areg), frac \
			asl.l		#8, frac \
			asl.l		#3, frac \
			bset		#31, frac \
			move		4(Areg), frac2 \
			lsr			#5, frac2 \
			or			frac2, frac \
			move.l		4(Areg), frac2 \
			asl.l		#8, frac2 \
			asl.l		#3, frac2 \
			move		(Areg), exp \
			asr			#4, exp \
			and			#0x07ff, exp

extern _fadd(), _fadd2(), _fsub(), _fmul(), _fdiv(), _fcom();
extern _fadd32(), _fadd322(), _fsub32();
extern _fadd32();

extern __norm(), __norm32();

static float f1 = 1.0;
static double df1 = 1.0;

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
			bra		_fadd322		;call add so it gets loaded
			nop						;make sure optimizer doesn't get rid of it
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
			expand_float(A0, D5, D6, D7)
			beq		is_zero

			expand_float(A1, D2, D3, D4)
			beq		is_zero

			sub		D2, D5				;Set up exponent
			add		#BIAS-1, D5
			
			move	D5, -(A7)
			clr.l	D2					;clear low words of the 2 numbers
			clr.l	D5
			move	#32-1, D0
	divloop1:
			add.l	D1, D1
/*
			asl.l	#1,  D1
*/
			addq	#1, D1
			sub.l	D2, D5
			subx.l	D4, D7
			subx.l	D3, D6
			bcc		cont			;branch if number subtracted was <=
			subq	#1, D1			;clear bit that was set
			add.l	D2, D5			;add what was subtracted back
			addx.l	D4, D7
			addx.l	D3, D6
	cont:
			lsr.l	#1, D3
			roxr.l	#1, D4
			roxr.l	#1, D2
			dbf		D0, divloop1

			move.l	D1, -(A7)		;put answer on stack (high long word if ans)
			
			clr.l	D1
			addq	#1, D1
			sub.l	D2, D5
			subx.l	D4, D7
			subx.l	D3, D6
			bcc		larger			;branch if number subtracted was <=
			subq	#1, D1			;clear bit that was set
			add.l	D2, D5			;add what was subtracted back
			addx.l	D4, D7
			addx.l	D3, D6
	larger:
			
			move	#31-1, D0
			bra		cont2
	divloop2:
			add.l	D1, D1
/*
			asl.l	#1,  D1
*/
			addq	#1, D1
			sub.l	D3, D6
			subx.l	D2, D5
			subx.l	D4, D7
			bcc		cont2			;branch if number subtracted was <=
			subq	#1, D1			;clear bit that was set
			add.l	D3, D6			;add what was subtracted back
			addx.l	D2, D5
			addx.l	D4, D7
	cont2:
			lsr.l	#1, D4
			roxr.l	#1, D2
			roxr.l	#1, D3
			dbf		D0, divloop2
			add.l	D1, D1			;move over 1 more because only shifted by 30
			move.l	(A7)+, D6		;Get high long word of answer in D6
			move.l	D1, D7			;Put low long word of answer in D7
			move	(A7)+, D5		;Restore D5

			move	(A1), D0
			eor		D0, (A0)		;set sign
			bra		__norm			;normalize and exit
	_fmul:							;** Floating-point Multiply
			link	A6, #0			;no local vars
			movem.l	D0-D7/A0/A1, -(A7)	;save registers
			move.l	a(A6), A0		;Destination is at A0
			expand_float(A0, D5, D6, D7)
			beq		is_zero

			move.l	b(A6), A1		;Source is at A1
			expand_float(A1, D2, D3, D4)
			beq		is_zero
			
			sub		#BIAS, D5		;Set up exponent
			add		D2, D5

			movem.l	D5/A2/A3, -(A7)

			move.l	D6, D0
			move.l	D7, D5
			clr.l	D6
			clr.l	D7
			move.l	D7, A2
			move.l	D7, A3
			clr.l	D1
			clr.l	D2
			bra		test
	muloop:
			lsr.l	#1, D0
			roxr.l	#1, D5
			bcc		noadd
			exg		D0, A2
			exg		D5, A3
			add.l	D4, D0
			addx.l	D3, D5
			addx.l	D2, D7
			addx.l	D1, D6
			exg		D0, A2
			exg		D5, A3
	noadd:
			add.l	D4, D4
			addx.l	D3, D3
			addx.l	D2, D2
			addx.l	D1, D1
/*
			asl.l	#1, D4
			roxl.l	#1, D3
			roxl.l	#1, D2
			roxl.l	#1, D1
*/
	test:
			tst.l	D0
			bne		muloop
			tst.l	D5
			bne		muloop

			movem.l	(A7)+, D5/A2/A3
			move	(A1), D0
			eor		D0, (A0)	;set sign
			bra		__norm
	is_zero:
			clr.l	D6			;This is for special case of source or dest
			clr.l	D7
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
			expand_float(A0, D5, D6, D7)
			bne		not01
			clr.l	D6
			clr.l	D7
	not01:
			expand_float(A1, D2, D3, D4)
			bne		not02
			clr.l	D3
			clr.l	D4
	not02:
			move	(A0), D1
			lsr.l	#1, D6		;shift numbers to the right 1 so
			roxr.l	#1, D7		;add won't overflow
			lsr.l	#1, D3
			roxr.l	#1, D4
			cmp		D2, D5		;make sure larger number is in D3-D7
			bgt		noprob
			bne		contt
			cmp.l	D3, D6
			bhi		noprob
			bne		contt
			cmp.l	D4, D7
			bhs		noprob
	contt:
			exg		D2, D5		;if D2-D4 is bigger exchange
			exg		D3, D6
			exg		D4, D7
			move	(A1), (A0)	;use sign of b because its bigger
	noprob:
			move.l	D6, D0		;if source is 0 then no need to add
			or.l	D7, D0
			beq		done_add

			move	D5, D0		;u is much bigger than v
			sub		D2, D0
			beq		noshift		;don't shift if going to shift by 0
			cmp		#53, D0		;if small number is that much smaller 
			bgt		done_add	;no need to try to add it
			subq	#1, D0		;Get ready for loop
	loop1:
			lsr.l	#1, D3
			roxr.l	#1, D4
			dbf		D0, loop1		
	
	noshift:
			move	(A1), D0	;set D3-D4 to 2's compliment number
			eor		D1, D0
			btst	#15, D0
			beq		same_sign
			neg.l	D4
			negx.l	D3
	same_sign:
			add.l	D4, D7		;do add
			addx.l	D3, D6
	done_add:
			move	sign_thing(A4), D0	;set sign correctly
			eor		D0, (A1)

	__norm:						;normalize
			move.l	D6, D0
			or.l	D7, D0
			bne		loop
			clr.l	D6
			clr.l	D7
			bra		pack0
	loop:
			subq	#1, D5
			add.l	D7, D7
			addx.l	D6, D6
/*
			asl.l	#1, D7
			roxl.l	#1, D6
*/
			bcc		loop
			addq	#2, D5		;Set exponent correctly
			
	reround:
			move	D7, D0		;Round
			btst	#11, D0
			beq		pack		;if no need to round ready to pack
			and		#0xbff, D0
			beq		pack
			add.l	#0x400, D7
			bcc		nac
			addq.l	#1, D6
	nac:
			bcc		pack		;if no overflow ready to pack
			lsr.l	#1, D7		;else shift fractional part
			roxr.l	#1, D6
			addq	#1, D5		;increase exponent
			bra		reround
			
	pack:						;for 64 bits
			moveq	#12-1, D0
	loop2:	
			lsr.l	#1, D6
			roxr.l	#1, D7
			dbf		D0, loop2
			and		#0x7ff, D5
			asl		#4, D5
			swap	D6		
			and		#0xf, D6	;get ready
			or		D5, D6		;or in exponent
			move	(A0), D0	;set sign
			and		#0x8000, D0
			or		D0, D6
			swap	D6
	pack0:
			move.l	D6, (A0)+
			move.l	D7, (A0)
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
			clr.l		D7
			move.l		(A0), D6
			bne			not_zero
			clr			D5
			clr.l		D6
			clr.l		D7
			bra			ok
	not_zero:
			bgt			notneg
			neg.l		D7
			negx.l		D6
	notneg:
			move		#30+BIAS, D5
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
	int		ten = 10;
	double 	_f10 = ten;
	
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
			pea		_f10(A6)
			move.l	y, -(A7)
			jsr		_fdiv
			addq	#8, A7
			bra		chex
	less:
			subq	#1, exp10
			pea		_f10(A6)
			move.l	y, -(A7)
			jsr		_fmul
			addq	#8, A7
			bra		chex
	expok:
			move.l	(y), D3		;Get fractional part in D3,D2
			asl.l	#8, D3
			asl.l	#3, D3
			move	4(y), D0	;Get 11 bits from low 32 bits and
			lsr		#5, D0		;add that to the 21 bits already in D3
			or		D0, D3
			move.l	4(y), D2
			asl.l	#8, D2
			asl.l	#3, D2
			bset	#31, D3
			tst		saveD1
			beq		iszero
			not		saveD1		;negate and subtract 1
	rloop:
			lsr.l	#1, D3
			roxr.l	#1, D2
			dbf		saveD1, rloop
	iszero:
			move	#'0', D0
			asl.l	#1, D2
			roxl.l	#1, D3
			bcc		contin
			addq	#1, D0
	contin:
			move.b	D0, (p)+
			move	prec(A6), D0
	nextch:
			clr		D1
			asl.l	#1, D2
			roxl.l	#1, D3
			roxl	#1, D1
			move.l	D2, -(A7)
			move.l	D3, saveD3
			move	D1, saveD1
			asl.l	#1, D2
			roxl.l	#1, D3
			roxl	#1, D1
			asl.l	#1, D2
			roxl.l	#1, D3
			roxl	#1, D1
			add.l	(A7)+, D2
			addx.l	saveD3, D3
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
			and		#~0x800f, D1		;Don't do anything if the number
			beq		done
			andi	#0x800f, x(A6)		;is 0
			add		#BIAS, D0
			and		#0x7ff, D0
			asl		#4, D0
			or		D0, x(A6)
	done:
	}
	return x;
}
