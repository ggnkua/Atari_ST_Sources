# /* Subroutines needed by GCC output code on some machines.  */
# /* Compile this file with the Unix C compiler!  */
# 
# #include "config.h"
# 
# union double_di { double d; int i[2]; };
# union flt_or_int { int i; float f; };
# 
# #ifdef WORDS_BIG_ENDIAN
# #define HIGH 0
# #define LOW 1
# #else
# #define HIGH 1
# #define LOW 0
# #endif
# 
# #ifdef L_umulsi3
# _umulsi3 (a, b)
#      unsigned a, b;
# {
#   return a * b;
# }
# #endif

.text
	.even
.globl __umulsi3
__umulsi3:
	link a6,#0		| 0 bytes of local
	movel d2,sp@-		| push d2
	movel a6@(8),d2		| get a
	beq umul_zero		| 0? return 0
	movel a6@(12),d1	| get b
	beq umul_zero		| 0? return 0

	mulu d1,d2		| mul bottom parts
	movel d2,d0		| save that
	movew a6@(8),d2		| get hi part of a
	beq umul_1		| zero, skip it
	movel a6@(12),d1	| get b
	mulu d1,d2		| mul a hi by b lo
	lsll #8,d2		| shift over
	lsll #8,d2		|  ...twice...
	addl d2,d0		| add that in
umul_1:
	clrl d1
	movew a6@(12),d1	| get b hi
	beq umul_ret
	movel a6@(8),d2		| and a lo
	mulu d1,d2		| mult those
	lsll #8,d2		| shift it over
	lsll #8,d2		|  ... twice...
	addl d2,d0		| and add that in
	bra umul_ret		| go home
umul_zero:
	clrl d0			| return 0
umul_ret:
	movel sp@+,d2		| get d2 back

	unlk a6			| flush frame
	rts
#
# #ifdef L_mulsi3
# _mulsi3 (a, b)
#      int a, b;
# {
#   return a * b;
# }
# #endif

.text
	.even
.globl __mulsi3
__mulsi3:
	link a6,#-2		| one word of local
	clrw a6@(-2)		| zap the local; it's our neg flg

	movel a6@(12),d0	| get b
	bpl muls1		| pos, ok
	negl d0			| negate it
	addqw #1,a6@(-2)	| and inc the flag
muls1:
	movel d0,sp@-		| push adjusted b
	movel a6@(8),d0		| get a
	bpl muls2		| pos, ok
	negl d0			| negate it
	subqw #1,a6@(-2)	| and dec the flag
muls2:
	movel d0,sp@-		| push adjusted a
	jbsr __umulsi3		| do an unsigned mult
	addql #8,sp		| flush args
	tstw a6@(-2)		| flag set?
	beq muls3		| nope, go ahead and return
	negl d0			| negate the result
muls3:

	unlk a6			| unlink the frame
	rts			| done!
#
# #ifdef L_udivsi3
# _udivsi3 (a, b)
#      unsigned a, b;
# {
#   return a / b;
# }
# #endif

.text
	.even
.globl __udivsi3
__udivsi3:
	link a6,#0

	movel d2,sp@-		| check our bags
	movel d3,sp@-
	movel d4,sp@-

	clrl d0			| d0 will be accum
	movel a6@(8),d1		| d1 is a, dividend
	movel a6@(12),d2	| d2 is b, divisor
	movel #1,d3		| get a 1 into bit 0 of bit mask
	movel #31,d4		| d4 is bit num for testing need to sub
udiv_sl:

	btst d4,d2		| bit get to top yet?
	bne udiv_sr		| yes, start testing for subtraction
	lsll #1,d3		| shift bitnum left
	lsll #1,d2		| shift divisor left
	bra udiv_sl
udiv_sr:
	cmpl d2,d1		| divisor > dividend?
	beq udiv_sub
	bcs udiv_s
udiv_sub:
	subl d2,d1		| take divisor (shifted) out of dividend
	orl d3,d0		| set this bit in d0
	tstl d1			| anything left?
	beq udiv_done		| nope
udiv_s:
	subql #1,d4		| dec bitnum (new only)
	lsrl #1,d2		| shift right one
	lsrl #1,d3		| and the bitnum too
	bne udiv_sr		| more bits, keep dividing

udiv_done:
	movel sp@+,d4
	movel sp@+,d3		| get bags back
	movel sp@+,d2

	unlk a6
	rts
#
# #ifdef L_divsi3
# _divsi3 (a, b)
#      int a, b;
# {
#   return a / b;
# }
# #endif

.text
	.even
.globl __divsi3
__divsi3:
	link a6,#-2		| 2 bytes of local
	clrw a6@(-2)		| zap the local; it's our neg flg

	movel a6@(12),d0	| get b
	bge divs1		| pos, ok
	negl d0			| negate it
	addqw #1,a6@(-2)	| and inc the flag
divs1:
	movel d0,sp@-		| push adjusted b
	movel a6@(8),d0		| get a
	bge divs2		| pos, ok
	negl d0			| negate it
	subqw #1,a6@(-2)	| and dec the flag
divs2:
	movel d0,sp@-		| push adjusted a
	jbsr __udivsi3		| do an unsigned div
	addql #8,sp		| flush args
	tstw a6@(-2)		| flag set?
	beq divs3		| nope, go ahead and return
	negl d0			| negate the result
divs3:

	unlk a6			| unlink the frame
	rts			| done!
#
# #ifdef L_umodsi3
# _umodsi3 (a, b)
#      unsigned a, b;
# {
#   return a % b;
# }
# #endif

.text
	.even
.globl __umodsi3
__umodsi3:
	link a6,#-4
	movl d2,sp@-
	movel a6@(12),sp@-
	movel a6@(8),sp@-
	jbsr __udivsi3
	movel d0,d0
	movel a6@(12),sp@-
	movel d0,sp@-
	jbsr __mulsi3
	movel d0,d2
	movel a6@(8),d1
	subl d2,d1
	movel d1,a6@(-4)
	movel a6@(-4),d0
	movl a6@(-8),d2
	unlk a6
	rts
# 
# #ifdef L_modsi3
# _modsi3 (a, b)
#      int a, b;
# {
#   return a % b;
# }
# #endif

.text
	.even
.globl __modsi3
__modsi3:
	link a6,#-4
	movl d2,sp@-
	movel a6@(12),sp@-
	movel a6@(8),sp@-
	jbsr __divsi3
	movel d0,d0
	movel a6@(12),sp@-
	movel d0,sp@-
	jbsr __mulsi3
	movel d0,d2
	movel a6@(8),d1
	subl d2,d1
	movel d1,a6@(-4)
	movel a6@(-4),d0
	movl a6@(-8),d2
	unlk a6
	rts

