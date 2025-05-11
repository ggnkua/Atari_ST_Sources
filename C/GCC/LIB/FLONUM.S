#
#
#	Floating point support code.  What a crock!
#
#	A float looks like:
#
#	|S|E.x.p ... |M.a.n.t.i.s.s.a ... |
#	+-+----------+--------------------+
#
#	where s is the sign bit, Exp is 8 bits of exponent, interpreted
#	as E + 126, and Mantissa is 23 bits of fraction, with a
#	hidden bit.  The point is to the left of the hidden bit.
#	Doubles have another word of mantissa following.
#
#	All these routines have calling sequences like c routines,
#	ie args on stack in backwards order, return values in d0
#

# union double_di { double d; int i[2]; };
# union flt_or_int { int i; float f; };

# #ifdef L_divdf3
# double
# _divdf3 (a, b)
#      double a, b;
# {
#   return a / b;
# }
# #endif
.text
	.even
.globl __divdf3
__divdf3:
	movel	sp@(12),sp@-
	movel	sp@(8),sp@-
	jsr	__divsf3
	addql	#8,sp
	clrl	d1		| kludge!!!
	rts			| sigh
# 
# #ifdef L_muldf3
# double
# _muldf3 (a, b)
#      double a, b;
# {
#   return a * b;
# }
# #endif

.text
	.even
.globl __muldf3
__muldf3:
	movel	sp@(12),sp@-
	movel	sp@(8),sp@-
	jsr	__mulsf3
	addql	#8,sp
	clrl	d1		| kludge!!!
	rts			| sigh
# 
# #ifdef L_negdf2
# double
# _negdf2 (a)
#      double a;
# {
#   return -a;
# }
# #endif

.text
	.even
.globl __negdf2
__negdf2:
	movel	sp@(8),d1		| get a lo
	movel	sp@(4),d0		| get a hi
	beq	negdf2_z		| zero, leave it
	eorl	#0x80000000,d0		| twiddle sign
negdf2_z:
	rts
# 
# #ifdef L_adddf3
# double
# _adddf3 (a, b)
#      double a, b;
# {
#   return a + b;
# }
# #endif

.text
	.even
.globl __adddf3
__adddf3:
	movel	sp@(12),sp@-
	movel	sp@(8),sp@-
	jsr	__addsf3
	addql	#8,sp
	clrl	d1		| kludge!!!
	rts			| sigh
# 
# #ifdef L_subdf3
# double
# _subdf3 (a, b)
#      double a, b;
# {
#   return a - b;
# }
# #endif

.text
	.even
.globl __subdf3
__subdf3:
	movel	sp@(12),sp@-
	movel	sp@(8),sp@-
	jsr	__subsf3
	addql	#8,sp
	clrl	d1		| kludge!!!
	rts			| sigh
# 
# #ifdef L_cmpdf2
# int
# _cmpdf2 (a, b)
#      double a, b;
# {
#   if (a > b)
#     return 1;
#   else if (a < b)
#     return -1;
#   return 0;
# }
# #endif

.text
	.even
.globl __cmpdf2
__cmpdf2:
	movel	sp@(4),d0	| get b hi
	movel	sp@(12),d1	| get a hi
|
| crockery.  If both neg and not equal, this algorithm lose.  find a better one!
|
	bpl	cmpdf2_p
	tstl	d0
	bpl	cmpdf2_p
	cmpl	d1,d0
	bgt	cmpdf2_m
	blt	cmpdf2_1
	beq	cmpdf2_z
cmpdf2_p:
	cmpl	d1,d0		| get a hi
	beq	cmpdf2_z	| if eq, return 0
	bgt	cmpdf2_1	| if greater, return 1
cmpdf2_m:
	movel	#-1,d0		| else return -1
	rts
cmpdf2_z:
	clrl	d0
	rts
cmpdf2_1:
	movel	#1,d0
	rts			| sigh
# 
# #ifdef L_fixunsdfsi
# _fixunsdfsi (a)
#      double a;
# {
#   return (unsigned int) a;
# }
# #endif

.text
	.even
.globl __fixunsdfsi
__fixunsdfsi:
	clrl d0
	clrl d1
	rts			| sigh
# 
# #ifdef L_fixunsdfdi
# double
# _fixunsdfdi (a)
#      double a;
# {
#   union double_di u;
#   u.i[LOW] = (unsigned int) a;
#   u.i[HIGH] = 0;
#   return u.d;
# }
# #endif

.text
	.even
.globl __fixunsdfdi
__fixunsdfdi:
	clrl d0
	clrl d1
	rts			| sigh
# 
# #ifdef L_fixdfsi
# _fixdfsi (a)
#      double a;
# {
#   return (int) a;
# }
# #endif

.text
	.even
.globl __fixdfsi
__fixdfsi:
	link	a6,#0
	movel	d2,sp@-		| save reg
	clrl	d2		| sign flag
	movel	a6@(8),d0	| get the float
	beq	fixdfsi_ret
	bpl	fixdfsi_1
	addql	#1,d2
fixdfsi_1:
	movel	d0,d1		| snag the exp
	lsrl	#7,d1
	lsrl	#8,d1
	lsrl	#8,d1
	andl	#0xFF,d1
	subl	#126,d1
	andl	#0x7FFFFF,d0	| zap cruft
	orl	#0x800000,d0	| put back hidden bit
|
| at this point the mantissa looks like 2^24 * integer value.
| if Exp is 24, we're done.  If it's less, we shift right,
| else left
|
fixdfsi_2:
	cmpl	#24,d1
	beq	fixdfsi_4	| we're done
	bmi	fixdfsi_3	| less, shift right
	lsll	#1,d0		| greater, shift it left one
	subql	#1,d1		| and dec exp
	bra	fixdfsi_2
fixdfsi_3:
	lsrl	#1,d0		| shift right one
	addql	#1,d1		| and inc exp
	bra	fixdfsi_2
fixdfsi_4:
	tstl	d2		| negative?
	beq	fixdfsi_ret
	negl	d0
fixdfsi_ret:
	movel	sp@+,d2		| get d2 back
	unlk	a6
	rts
# 
# #ifdef L_fixdfdi
# double
# _fixdfdi (a)
#      double a;
# {
#   union double_di u;
#   u.i[LOW] = (int) a;
#   u.i[HIGH] = (int) a < 0 ? -1 : 0;
#   return u.d;
# }
# #endif

.text
	.even
.globl __fixdfdi
__fixdfdi:
	clrl d0
	clrl d1
	rts			| sigh
# 
# #ifdef L_floatsidf
# double
# _floatsidf (a)
#      int a;
# {
#   return (double) a;
# }
# #endif

.text
	.even
.globl __floatsidf
__floatsidf:
	link	a6,#0		| set up frame
	movel	d2,sp@-		| save d2; sign flag
	clrl	d2		| not negative yet
	movel	#24,d1		| exponent so far
	movel	a6@(8),d0	| get the int
	beq	floatsidf_ret	| zero?
	bpl	floatsidf_1	| pos, it's ok
	negl	d0		| negate it
	addql	#1,d2		| bump sign
floatsidf_1:
|
| normalize right if necessary
|
	cmpl	#0xFFFFFF,d0	| too big?
	ble	floatsidf_2	| nope, see if need to slide left
	addql	#1,d1		| bump exp
	lsrl	#1,d0		| and slide mantissa right one
	bra	floatsidf_1
floatsidf_2:
	btst	#23,d0		| got a bit up here yet?
	bne	floatsidf_3	| nope, go left
	subql	#1,d1		| dec exp
	lsll	#1,d0		| and slide mantissa left one
	bra	floatsidf_2
floatsidf_3:
|
| now put it all together
|
	andl	#0x7FFFFF,d0	| zap hidden bit
	addl	#126,d1		| offset exp
	andl	#0xFF,d1	| trim it
	lsll	#8,d1		| shift up
	lsll	#8,d1
	lsll	#7,d1
	orl	d1,d0		| stuff it in
	tstl	d2		| negative?
	beq	floatsidf_ret
	orl	#0x80000000,d0
floatsidf_ret:
	movel	sp@+,d2
	clrl	d1		| ???
	unlk	a6
	rts			| sigh
# 
# #ifdef L_floatdidf
# double
# _floatdidf (u)
#      union double_di u;
# {
#   register double hi
#     = ((double) u.i[HIGH]) * (double) 0x10000 * (double) 0x10000;
#   register double low = (unsigned int) u.i[LOW];
#   return hi + low;
# }
# #endif

.text
	.even
.globl __floatdidf
__floatdidf:
	clrl d0
	clrl d1
	rts			| sigh
# 
# #define INTIFY(FLOATVAL)  (intify.f = (FLOATVAL), intify.i)
# 
# #ifdef L_addsf3
# int
# _addsf3 (a, b)
#      union flt_or_int a, b;
# {
#   union flt_or_int intify;
#   return INTIFY (a.f + b.f);
# }
# #endif

.text
	.even
.globl __addsf3
__addsf3:
	link	a6,#0		| don't need any locals
	moveml	#0x3F00,sp@-	| save all data registers
	movel	a6@(8),d0	| get a
	beq	addsf_ret_b	|  zero .. just return b
	movel	#23,d6		| shift count
	movel	d0,d2		| get the exponent
	lsrl	d6,d2		| and shift right
	andl	#0xFF,d2	| no sign bit
	subl	#126,d2		| offset the exponent
	movel	a6@(12),d1	| get b
	beq	addsf_ret_a
	movel	d1,d3		| get the exponent for b
	lsrl	d6,d3		| and shift right, with implicit extend
	andl	#0xFF,d3	| make sure we didn't get a sign bit
	subl	#126,d3		| off set this one too

	andl	#0x7FFFFF,d0	| mask a for mantissa
	orl	#0x800000,d0	| and put in hidden bit
	tstl	a6@(8)		| test the original value
	bpl	addsf_1		| pos, ok
	negl	d0		| neg, negate the mantissa
addsf_1:
	andl	#0x7FFFFF,d1	| mask b for mantissa
	orl	#0x800000,d1	| ditto
	tstl	a6@(12)		| test ...
	bpl	addsf_2
	negl	d1		| negate this one
addsf_2:
	cmpl	d2,d3		| compare Ea to Eb
	blt	addsf_3		| Ea > Eb

	movel	d3,d5		| get Eb
	subl	d2,d5		| subtract Ea
	asrl	d5,d0		|  yielding count to shift Ma right
	movel	d3,d5		| use this as resultant exponent
	bra	addsf_4		| and go rejoin common part
addsf_3:
	movel	d2,d5		| get Ea
	subl	d3,d5		| subtract Eb
	asrl	d5,d1		|  yielding count to shift Mb right
	movel	d2,d5		| use this as resultant exponent

addsf_4:
	clrl	d7		| zap sign flag
	addl	d1,d0		| add Mb to Ma


	beq	addsf_z		| zero? ok, go return zero
	bpl	addsf_5		| positive? ok, go scale it
	negl	d0		| negate Mr
	movel	#1,d7		| remember sign
addsf_5:
	btst	#24,d0		| carry?
	beq	addsf_6		| nope, it's ok as is
	asrl	#1,d0		| shift right one
	addql	#1,d5		| inc exp

| zzz check for overflow in here someplace

addsf_6:
	btst	#23,d0		| got a bit in the right place yet?
	bne	addsf_7		| yes, we're done
	lsll	#1,d0		| shift left one
	subql	#1,d5		| dec exponent
	bra	addsf_6
addsf_7:
	andl	#0x7FFFFF,d0	| zap out hidden bit
	addl	#126,d5		| add offset to exp
	andl	#0xFF,d5	| zap to 8 bits
	movel	#23,d6		| shift count
	lsll	d6,d5		| shift the exp up
	orl	d5,d0		| stick the exp in
	tstl	d7		| negative?
	beq	addsf_ret_a
	orl	#0x80000000,d0	| yup, negate it
	bra	addsf_ret_a
addsf_z:
	clrl	d0
	bra	addsf_ret_a
addsf_ret_b:
	movel	a6@(12),d0
addsf_ret_a:
	moveml	sp@+,#0x00FC	| snarf back all regs
	unlk	a6
	rts			| sigh
# 
# #ifdef L_negsf2
# int
# _negsf2 (a)
#      union flt_or_int a;
# {
#   union flt_or_int intify;
#   return INTIFY (-a.f);
# }
# #endif

.text
	.even
.globl __negsf2
__negsf2:
	movel	sp@(4),d0
	beq	negsf2_z
	eorl	#0x80000000,d0
negsf2_z:
	rts			| sigh
# 
# #ifdef L_subsf3
# int
# _subsf3 (a, b)
#      union flt_or_int a, b;
# {
#   union flt_or_int intify;
#   return INTIFY (a.f - b.f);
# }
# #endif

.text
	.even
.globl __subsf3
__subsf3:
	tstl	sp@(8)		| kludge.  just negate b and add
	beq	subsf_bz	| zero.  don't bother
	eorl	#0x80000000,sp@(8)	| negate it
	jmp	__addsf3
subsf_bz:
	movel	sp@(4),d0
	rts

# 
# #ifdef L_cmpsf2
# int
# _cmpsf2 (a, b)
#      union flt_or_int a, b;
# {
#   union flt_or_int intify;
#   if (a.f > b.f)
#     return 1;
#   else if (a.f < b.f)
#     return -1;
#   return 0;
# }
# #endif

.text
	.even
.globl __cmpsf2
__cmpsf2:
	movel	sp@(4),d0
	movel	sp@(12),d1	| get a hi
|
| crockery.  If both neg and not equal, this algorithm lose.  find a better one!
|
	bpl	cmpsf2_p
	tstl	d0
	bpl	cmpsf2_p
	cmpl	d1,d0
	bgt	cmpsf2_m
	blt	cmpsf2_1
	beq	cmpsf2_z
cmpsf2_p:
	cmpl	d1,d0
	beq	cmpsf2_z
	bgt	cmpsf2_1
cmpsf2_m:
	movel	#-1,d0
	rts
cmpsf2_z:
	clrl	d0
	rts
cmpsf2_1:
	movel	#1,d0
	rts			| sigh
# 
# #ifdef L_mulsf3
# int
# _mulsf3 (a, b)
#      union flt_or_int a, b;
# {
#   union flt_or_int intify;
#   return INTIFY (a.f * b.f);
# }
# #endif

.text
	.even
.globl __mulsf3
__mulsf3:
|
| multiply.  take the numbers apart.  shift each exponent down to
| 16 bits.  unsigned multiply those.  shift that down to 24 bits.
| exponent is Ea + Eb.
|

	link	a6,#-8		| 64 bit accum for mult
	moveml	#0x3F00,sp@-	| save all data registers
	movel	a6@(8),d0	| get a
	beq	mulsf3_z
	movel	a6@(12),d1	| get b
	beq	mulsf3_z
	movel	#23,d6		| shift count
	movel	d0,d2		| get the exponent
	lsrl	d6,d2		| and shift right
	andl	#0xFF,d2
	subl	#126,d2		| offset the exponent
	movel	d1,d3		| get the exponent for b
	lsrl	d6,d3		| and shift right
	andl	#0xFF,d2
	subl	#126,d3		| off set this one too

	clrl	d7		| negative result flag
	andl	#0x7FFFFF,d0	| mask a for mantissa
	orl	#0x800000,d0	| and put in hidden bit
	tstl	a6@(8)		| test the original value
	bpl	mulsf3_1	| pos, ok
	eorl	#1,d7		| remember negative
mulsf3_1:
	andl	#0x7FFFFF,d1	| mask b for mantissa
	orl	#0x800000,d1	| ditto
	tstl	a6@(12)		| test ...
	bpl	mulsf3_2
	eorl	#1,d7
mulsf3_2:
|	lsrl	#8,d1		| shift this one down
|	lsrl	#8,d0		| this one too...
|	mulu	d1,d0		| do the multiply

|	beq	mulsf3_ret	| zero? ok, just return
|	lsrl	#8,d0		| shift right again

|
| we have mantissas as follows:
|
|	|...ah...|...al...|	|...bh...|...bl...|
|
| product is composed as:
|
|			|....al * bl....|
|		|....al * bh....|
|		|....ah * bl....|
|	|....ah * bh....|
|
| then take the 24 bit chunk that's 16 bits in.

	movel	d0,d4
	andl	#0xFFFF,d4	| al
	movel	d1,d5
	andl	#0xFFFF,d5	| bl
	mulu	d5,d4		| that's al * bl
	movel	d4,a6@(-4)	| into the accum
	clrl	a6@(-8)		| zap the top part

	movel	d0,d4
	andl	#0xFFFF,d4	| al
	movel	d1,d5
	movel	#16,d6		| shift count
	lsrl	d6,d5		| bh
	mulu	d5,d4		| al * bh
	addl	d4,a6@(-6)

	movel	d0,d4
	lsrl	d6,d4		| ah
	movel	d1,d5
	andl	#0xFFFF,d5	| bl
	mulu	d5,d4		| ah * bl
	addl	d4,a6@(-6)

	movel	d0,d4
	lsrl	d6,d4		| ah
	movel	d1,d5
	lsrl	d6,d5		| bh
	mulu	d5,d4		| ah * bh
	addl	d4,a6@(-8)

	movel	a6@(-6),d0	| get the relevant part
	lsrl	#8,d0		| and shift it down

mulsf3_norm:
	btst	#23,d0		| normalized?
	bne	mulsf3_ok
	lsll	#1,d0
	subql	#1,d2
	bra	mulsf3_norm

mulsf3_ok:
	andl	#0x7FFFFF,d0	| zap hidden bit
	addl	d3,d2		| add Eb to Ea
	addl	#126,d2		| fix offset
	andl	#0xFF,d2	| whack to 8 bits
	movel	#23,d6		| shift count
	lsll	d6,d2		| shift up to right place
	orl	d2,d0		| shove it in
	tstl	d7		| sign neg?
	beq	mulsf3_ret
	orl	#0x80000000,d0	| set sign bit
	bra	mulsf3_ret
mulsf3_z:
	clrl	d0
mulsf3_ret:
	moveml	sp@+,#0x00FC	| snarf back all regs
	unlk	a6
	rts			| sigh
# 
# #ifdef L_divsf3
# int
# _divsf3 (a, b)
#      union flt_or_int a, b;
# {
#   union flt_or_int intify;
#   return INTIFY (a.f / b.f);
# }
# #endif

.text
	.even
.globl __divsf3
__divsf3:
|
| divide.  sort of like mult, exc we do shifts and subtracts to
| do the division of the mantissa.  resultant exponent is Ea - Eb.
|

	link	a6,#0		| don't need any locals
	moveml	#0x3F00,sp@-	| save all data registers
	movel	a6@(8),d0	| get a
	movel	a6@(12),d1	| get b
	movel	#23,d6		| shift count
	movel	d0,d2		| get the exponent
	lsrl	d6,d2		| and shift right
	andl	#0xFF,d2
	subl	#127,d2		| offset the exponent
	movel	d1,d3		| get the exponent for b
	lsrl	d6,d3		| and shift right
	andl	#0xFF,d3
	subl	#127,d3		| off set this one too

	clrl	d7		| negative result flag
	andl	#0x7FFFFF,d0	| mask a for mantissa
	orl	#0x800000,d0	| and put in hidden bit
	tstl	a6@(8)		| test the original value
	bpl	divsf3_1	| pos, ok
	eorl	#1,d7		| remember negative
divsf3_1:
	andl	#0x7FFFFF,d1	| mask b for mantissa
	orl	#0x800000,d1	| ditto
	tstl	a6@(12)		| test ...
	bpl	divsf3_2
	eorl	#1,d7
divsf3_2:
|
| for now, kludge.  shift Ma left and Mb right, then do an unsigned divide
| and shift the result left.  Blech
|

|	lsrl	#8,d1		| shift this one down
|	lsll	#7,d0		| this one up
|	divu	d1,d0		| do the divide
|	andl	#0xFFFF,d0	| and mask off cruft

|	beq	divsf3_ret	| zero? ok, just return
|	lsll	#8,d0		| shift left again

| same sort of trick as long divide, exc it's easier here, cause
| the numbers (mantissas) are already bit-aligned.

	clrl	d4		| accumulator
	movel	#0x800000,d5	| bit
	lsll	#7,d0		| buy a little extra accuracy...
	lsll	#7,d1
divsf3_2a:
	cmpl	d1,d0		| compare dividend to divisor
	bmi	divsf3_2b	| nope, no bit here
	orl	d5,d4		| put in the bit
	subl	d1,d0		| and subtract
divsf3_2b:
	lsrl	#1,d1		| slide divisor down
	lsrl	#1,d5		| slide bit down
	bne	divsf3_2a	| and go round again
	movel	d4,d0		| leave the result here

divsf3_3:
	btst	#23,d0		| right place yet?
	bne	divsf3_4
	lsll	#1,d0
	subql	#1,d2
	bra	divsf3_3
divsf3_4:
	andl	#0x7FFFFF,d0	| zap hidden bit
	subl	d3,d2		| sub Eb from Ea
	addl	#127,d2		| fix offset
	andl	#0xFF,d2	| whack to 8 bits
	lsll	d6,d2		| shift up to right place
	orl	d2,d0		| shove it in
	tstl	d7		| sign neg?
	beq	divsf3_ret
	orl	#0x80000000,d0	| set sign bit
divsf3_ret:
	moveml	sp@+,#0x00FC	| snarf back all regs
	unlk	a6

	rts			| sigh
# 
# #ifdef L_truncdfsf2
# int
# _truncdfsf2 (a)
#      double a;
# {
#   union flt_or_int intify;
#   return INTIFY (a);
# }
# #endif

.text
	.even
.globl __truncdfsf2
__truncdfsf2:
	movel	sp@(4),d0
	rts

# 
# #ifdef L_extendsfdf2
# double
# _extendsfdf2 (a)
#      union flt_or_int a;
# {
#   union flt_or_int intify;
#   return a.f;
# }
# #endif

.text
	.even
.globl __extendsfdf2
__extendsfdf2:
	movel	sp@(4),d0
	clrl	d1
	rts			| sigh
	.even
.text
